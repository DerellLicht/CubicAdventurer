#!/usr/bin/env python3
"""
tnt_strip.py - mechanical removal of TNT Unicode Controls from a Delphi project.

What it does
  * Renames TNT classes to their standard VCL equivalents (TTntLabel -> TLabel)
    in .pas files and in the "object X: TTntY" lines of .dfm files.
  * Renames TNT units in 'uses' clauses (TntStdCtrls -> StdCtrls), drops units
    that have no equivalent (TntSystem, TntWideStrUtils), and removes duplicate
    entries that the renaming would otherwise create (a duplicate unit in one
    uses clause is a compile error).
  * Renames the TNT 'Wide*' helper routines and Tnt_*W API wrappers that have a
    one-to-one modern equivalent (WideFileExists -> FileExists, ...).
  * Removes the TNT runtime packages from .dpk 'requires' clauses.
  * Writes a Markdown report of everything it could NOT convert safely.

What it does NOT do
  * It never changes comments or string literals.
  * It does not touch the vendored Components folders unless asked to
    (--include-components); it only counts the TNT references found there.
  * It does not compile anything. Run the Delphi compiler afterwards and use
    the report's "needs attention" sections as the work list.

Safety
  * Default mode is a dry run: nothing is written except the report.
  * Use --out DIR to write converted copies elsewhere, or --in-place to
    modify files (put the tree under git first so you can review the diff).
  * Files are read and written as raw bytes (latin-1), so line endings and
    any odd bytes are preserved exactly. Running it twice changes nothing.

Usage
  python tnt_strip.py SRC_DIR                      # dry run + report
  python tnt_strip.py SRC_DIR --out OUT_DIR        # write converted copies
  python tnt_strip.py SRC_DIR --in-place           # modify in place
  python tnt_strip.py SRC_DIR --report my_report.md
"""

import argparse
import os
import re
import sys
from collections import Counter, defaultdict

# --------------------------------------------------------------------------
# Mapping tables
# --------------------------------------------------------------------------

# TNT class -> standard VCL/RTL class. Applies to .pas code and .dfm objects.
CLASS_MAP = {
    "TTntAction": "TAction",
    "TTntActionList": "TActionList",
    "TTntBevel": "TBevel",
    "TTntButton": "TButton",
    "TTntCheckBox": "TCheckBox",
    "TTntCheckListBox": "TCheckListBox",
    "TTntComboBox": "TComboBox",
    "TTntEdit": "TEdit",
    "TTntFileStream": "TFileStream",
    "TTntForm": "TForm",
    "TTntGroupBox": "TGroupBox",
    "TTntLabel": "TLabel",
    "TTntMemo": "TMemo",
    "TTntMenuItem": "TMenuItem",
    "TTntOpenDialog": "TOpenDialog",
    "TTntPanel": "TPanel",
    "TTntPopupMenu": "TPopupMenu",
    "TTntRadioButton": "TRadioButton",
    "TTntRegistry": "TRegistry",
    "TTntSaveDialog": "TSaveDialog",
    "TTntStringList": "TStringList",
    "TTntStrings": "TStrings",
}

# TNT unit -> standard unit. None means "drop it, no equivalent needed".
UNIT_MAP = {
    "TntActnList": "ActnList",
    "TntButtons": "Buttons",
    "TntCheckLst": "CheckLst",
    "TntClasses": "Classes",
    "TntClipbrd": "Clipbrd",
    "TntClipboard": "Clipbrd",
    "TntComCtrls": "ComCtrls",
    "TntDialogs": "Dialogs",
    "TntExtCtrls": "ExtCtrls",
    "TntFileCtrl": "FileCtrl",
    "TntForms": "Forms",
    "TntGraphics": "Graphics",
    "TntMenus": "Menus",
    "TntRegistry": "Registry",
    "TntStdCtrls": "StdCtrls",
    "TntSysUtils": "SysUtils",
    "TntWindows": "Windows",
    "TntSystem": None,
    "TntWideStrUtils": None,
}

# TNT-only runtime packages to remove from a .dpk 'requires' clause.
REQUIRES_DROP = {"TntUnicodeVcl", "TntUnicodeVcl_Design"}

# Identifiers with a one-to-one modern replacement. The Ansi* names are
# historical: in Unicode Delphi they are Unicode-aware and locale-aware, which
# is the closest match to TNT's Wide* case/compare routines.
IDENT_MAP = {
    # global objects
    "TntClipboard": "Clipboard",
    "TntApplication": "Application",
    # types
    "TSearchRecW": "TSearchRec",
    # file and path routines
    "WideFileExists": "FileExists",
    "WideDirectoryExists": "DirectoryExists",
    "WideExtractFileName": "ExtractFileName",
    "WideExtractFilePath": "ExtractFilePath",
    "WideExtractFileExt": "ExtractFileExt",
    "WideExtractFileDrive": "ExtractFileDrive",
    "WideExtractRelativePath": "ExtractRelativePath",
    "WideExpandFileName": "ExpandFileName",
    "WideCreateDir": "CreateDir",
    "WideSetCurrentDir": "SetCurrentDir",
    "WideGetCurrentDir": "GetCurrentDir",
    "WideDeleteFile": "DeleteFile",
    "WideRenameFile": "RenameFile",
    "WideRemoveDir": "RemoveDir",
    "WideForceDirectories": "ForceDirectories",
    "WideFindFirst": "FindFirst",
    "WideFindNext": "FindNext",
    "WideFindClose": "FindClose",
    "WideIncludeTrailingPathDelimiter": "IncludeTrailingPathDelimiter",
    "WideExcludeTrailingPathDelimiter": "ExcludeTrailingPathDelimiter",
    "WideIncludeTrailingBackslash": "IncludeTrailingBackslash",
    "WideExcludeTrailingBackslash": "ExcludeTrailingBackslash",
    "WideParamStr": "ParamStr",
    "WideParamCount": "ParamCount",
    # string routines
    "WideFormat": "Format",
    "WideStringReplace": "StringReplace",
    "WideLowerCase": "AnsiLowerCase",
    "WideUpperCase": "AnsiUpperCase",
    "WideCompareText": "AnsiCompareText",
    "WideCompareStr": "AnsiCompareStr",
    "WideSameText": "AnsiSameText",
    "WideStrComp": "StrComp",
    "WideStrIComp": "StrIComp",
    "WideSysErrorMessage": "SysErrorMessage",
    # Tnt_* wrappers around Win32 'W' APIs (argument types need a quick look)
    "Tnt_CreateProcessW": "CreateProcessW",
    "Tnt_ShellExecuteW": "ShellExecuteW",
    "Tnt_WideStringReplace": "StringReplace",
    "Tnt_GetFileVersionInfoSizeW": "GetFileVersionInfoSizeW",
    "Tnt_GetFileVersionInfoW": "GetFileVersionInfoW",
    "Tnt_VerQueryValueW": "VerQueryValueW",
    "Tnt_SHBrowseForFolderW": "SHBrowseForFolderW",
}

# The Tnt_* wrappers are listed in the report as "mapped, verify argument types".
VERIFY_TYPES = {k for k in IDENT_MAP if k.startswith("Tnt_")}

# Names that are valid on their own and must not be flagged.
WIDE_IGNORE = {"widestring", "widechar", "widestrings", "widestrutils"}

# Tnt-prefixed names that are only component instance names or event handler
# names. They are ordinary identifiers and need no change.
TNT_OK_RE = re.compile(
    r"^Tnt(Label|GroupBox|Bevel|Button)\d+$|^TntForm(Create|Close|KeyPress|Resize)$",
    re.IGNORECASE,
)

STRINGLIST_DECL_RE = re.compile(
    r"\b([A-Za-z_]\w*(?:\s*,\s*[A-Za-z_]\w*)*)\s*:\s*(?:TStringList|TStrings)\b", re.IGNORECASE
)

# Comments and string literals (for masking). Order matters.
LEX_RE = re.compile(r"//[^\n]*|\{[^}]*\}|\(\*.*?\*\)|'(?:[^'\n]|'')*'", re.DOTALL)
TNT_COMMENT_RE = re.compile(r"^[ \t]*//[ \t]*Tnt\b[^\n]*(?:\n|$)", re.IGNORECASE | re.MULTILINE)
CLAUSE_RE = re.compile(r"\b(uses|requires)\b", re.IGNORECASE)
IDENT_TOKEN_RE = re.compile(r"[A-Za-z_][A-Za-z0-9_.]*")
DFM_OBJECT_RE = re.compile(
    r"^(\s*(?:object|inherited|inline)\s+\w+\s*:\s*)(\w+)", re.IGNORECASE | re.MULTILINE
)

_IDENT_ALTERNATION = "|".join(
    re.escape(k) for k in sorted(set(CLASS_MAP) | set(IDENT_MAP), key=len, reverse=True)
)
IDENT_RE = re.compile(r"\b(" + _IDENT_ALTERNATION + r")\b", re.IGNORECASE)
_IDENT_LOOKUP = {k.lower(): v for k, v in {**CLASS_MAP, **IDENT_MAP}.items()}
_CLASS_LOWER = {k.lower() for k in CLASS_MAP}
_UNIT_LOOKUP = {k.lower(): v for k, v in UNIT_MAP.items()}
_REQUIRES_DROP_LOOKUP = {k.lower() for k in REQUIRES_DROP}


# --------------------------------------------------------------------------
# Source-text helpers
# --------------------------------------------------------------------------

def mask_text(text):
    """
    Return a copy of text, the same length, with every comment and string
    literal blanked out to spaces (newlines are kept). Because offsets are
    preserved, a match found in the masked copy can be applied to the raw text.
    """
    chars = list(text)
    for m in LEX_RE.finditer(text):
        for i in range(m.start(), m.end()):
            if chars[i] != "\n":
                chars[i] = " "
    return "".join(chars)


def line_of(text, offset):
    """Return the 1-based line number of offset within text."""
    return text.count("\n", 0, offset) + 1


def line_text(text, offset):
    """Return the stripped source line containing offset."""
    start = text.rfind("\n", 0, offset) + 1
    end = text.find("\n", offset)
    return text[start : end if end >= 0 else len(text)].strip()


# --------------------------------------------------------------------------
# uses / requires clause rewriting
# --------------------------------------------------------------------------

def rewrite_clauses(text, stats, mode, seen_all):
    """
    Rewrite every 'uses' (mode 'uses') or 'requires' (mode 'requires') clause.

    For 'uses': TNT units are renamed or dropped. A renamed unit is dropped
    instead when the clause already lists the same unit (the author's original
    entry is kept, so the original unit order is never disturbed), when an
    earlier renamed entry already added it, or when an earlier clause in the
    same file already uses it. For 'requires': the TNT runtime packages are
    dropped.

    Stale '// Tnt ...' header comments are removed from clauses that change.
    Other comments in front of a dropped item are carried over to the next
    surviving item. If every item of a 'uses' clause disappears, the whole
    clause is removed.

    seen_all is a set shared across the clauses of one file and is updated
    here. Returns the new text.
    """
    masked = mask_text(text)
    edits = []  # (start, end, replacement) applied back to front

    for cm in CLAUSE_RE.finditer(masked):
        if cm.group(1).lower() != mode:
            continue
        semi = masked.find(";", cm.end())
        if semi < 0:
            continue
        body_start, body_end = cm.end(), semi

        # split the masked body at top-level commas
        bounds = []
        pos = body_start
        for part in masked[body_start:body_end].split(","):
            bounds.append((pos, pos + len(part)))
            pos += len(part) + 1

        # names the author already listed in this clause (not TNT units)
        orig_names = set()
        for s, e in bounds:
            tok = IDENT_TOKEN_RE.search(masked[s:e])
            if tok and tok.group(0).lower() not in _UNIT_LOOKUP:
                orig_names.add(tok.group(0).lower())

        kept = []
        pending = ""  # comment text carried from dropped items
        renamed_here = set()
        first_dropped = False
        first_lead = re.match(r"\s*", text[bounds[0][0] : bounds[0][1]]).group(0)
        changed = False
        for idx, (s, e) in enumerate(bounds):
            raw = text[s:e]
            tok = IDENT_TOKEN_RE.search(masked[s:e])
            if not tok:
                kept.append(pending + raw)
                pending = ""
                continue
            name = tok.group(0)
            low = name.lower()
            new_name, drop = name, False
            if mode == "uses" and low in _UNIT_LOOKUP:
                target = _UNIT_LOOKUP[low]
                if target is None:
                    drop = True
                else:
                    key = target.lower()
                    if key in orig_names or key in renamed_here or key in seen_all:
                        drop = True
                    else:
                        new_name = target
                        renamed_here.add(key)
            elif mode == "requires" and low in _REQUIRES_DROP_LOOKUP:
                drop = True

            if drop:
                changed = True
                if idx == 0:
                    first_dropped = True
                stats["units_dropped" if mode == "uses" else "requires_dropped"] += 1
                carry = TNT_COMMENT_RE.sub("", raw[: tok.start()] + raw[tok.end() :])
                if carry.strip():
                    pending += carry.rstrip() + "\n"
                continue
            if new_name != name:
                changed = True
                stats["units_renamed"] += 1
                raw = raw[: tok.start()] + new_name + raw[tok.end() :]
            kept.append(pending + raw)
            pending = ""

        if not changed:
            continue
        seen_all |= orig_names | renamed_here
        kept = [TNT_COMMENT_RE.sub("", k) for k in kept]
        if not kept and mode == "uses":
            edits.append((cm.start(), semi + 1, ""))
            continue
        if first_dropped and kept:
            kept[0] = first_lead + kept[0].lstrip()
        new_body = ",".join(kept)
        if pending:
            new_body += "\n" + pending.rstrip()
        edits.append((body_start, body_end, new_body))

    for s, e, rep in sorted(edits, reverse=True):
        text = text[:s] + rep + text[e:]
    return text


# --------------------------------------------------------------------------
# Identifier rewriting
# --------------------------------------------------------------------------

def rewrite_identifiers(text, stats, verify_hits, path):
    """
    Replace mapped identifiers in code (never in comments or strings).
    Counts every replacement in stats and records the Tnt_* wrapper hits in
    verify_hits so the report can ask for a quick look at their arguments.
    Returns the new text.
    """
    masked = mask_text(text)
    edits = []
    for m in IDENT_RE.finditer(masked):
        old = text[m.start() : m.end()]
        new = _IDENT_LOOKUP[old.lower()]
        edits.append((m.start(), m.end(), new))
        stats["class_renames" if old in CLASS_MAP else "ident_renames"] += 1
        if old in VERIFY_TYPES:
            verify_hits.append((path, line_of(text, m.start()), line_text(text, m.start())))
    for s, e, rep in sorted(edits, reverse=True):
        text = text[:s] + rep + text[e:]
    return text


def rewrite_form_annotations(text, stats):
    """
    Update the '{FormName: TTntForm}' annotations in a .dpr uses list. They sit
    inside comments, so the identifier pass skips them, but the IDE reads them
    to learn each form's class. Returns the new text.
    """
    def repl(m):
        stats["dpr_annotations"] += 1
        return m.group(1) + _IDENT_LOOKUP[m.group(2).lower()] + m.group(3)

    pattern = re.compile(r"(\{\s*\w+\s*:\s*)(" + "|".join(re.escape(k) for k in CLASS_MAP) + r")(\s*\})", re.IGNORECASE)
    return pattern.sub(repl, text)


def rewrite_dfm(text, stats):
    """
    Rename TNT class names on the 'object Name: TTntX' lines of a .dfm file.
    Only the class position is touched, so captions and other property values
    are never altered. Returns the new text.
    """
    def repl(m):
        cls = m.group(2)
        if cls.lower() in _CLASS_LOWER:
            stats["dfm_class_renames"] += 1
            return m.group(1) + _IDENT_LOOKUP[cls.lower()]
        return m.group(0)

    return DFM_OBJECT_RE.sub(repl, text)


# --------------------------------------------------------------------------
# Report scanning (works on converted text)
# --------------------------------------------------------------------------

def find_defined_wide_names(root):
    """
    Return the lower-cased names of Wide* routines, TWide* classes and Wide*
    unit names that are DEFINED anywhere under root (including vendored
    components). These are not TNT items and must not be flagged as
    unconverted.
    """
    pat = re.compile(
        r"^\s*(?:(?:function|procedure)\s+(?:\w+\.)?(Wide\w*)|(TWide\w+)\s*=\s*(?:class|record))",
        re.IGNORECASE | re.MULTILINE,
    )
    names = set()
    for dirpath, _dirs, files in os.walk(root):
        for fn in files:
            if fn.lower().endswith((".pas", ".inc")):
                if fn.lower().endswith(".pas"):
                    names.add(os.path.splitext(fn)[0].lower())  # unit names
                with open(os.path.join(dirpath, fn), "rb") as fh:
                    for m in pat.finditer(fh.read().decode("latin-1")):
                        names.add((m.group(1) or m.group(2)).lower())
    return names


def scan_leftovers(path, text, defined_wide, findings):
    """
    Scan converted .pas/.dpr text for things a human must look at: remaining
    Tnt-prefixed names, Wide* routines or types not defined in this tree, and
    Stream/StringList load/save calls whose text-encoding behaviour changes.
    Comments and strings are ignored. Appends (path, line, text) tuples to the
    matching list in findings.
    """
    masked = mask_text(text)
    for m in re.finditer(r"\b(TTnt\w*|Tnt\w*)\b", masked):
        name = m.group(1)
        if TNT_OK_RE.match(name):
            continue
        findings["tnt_left"].append((path, line_of(text, m.start()), line_text(text, m.start())))
    for m in re.finditer(r"\b(TWide\w+|Wide[A-Z]\w*)\b", masked):
        name = m.group(1)
        low = name.lower()
        if low in WIDE_IGNORE or low in defined_wide:
            continue
        findings["wide_left"].append((path, line_of(text, m.start()), line_text(text, m.start())))
    # Encoding review: only load/save calls on variables declared as a string
    # list, plus a memo's Lines. Streams of raw bytes and XML/dock/bitmap
    # objects are not affected by the TNT removal.
    names = {n.strip() for m in STRINGLIST_DECL_RE.finditer(masked) for n in m.group(1).split(",")}
    pats = [r"\.Lines\.(?:LoadFromFile|SaveToFile|LoadFromStream|SaveToStream)\s*\("]
    if names:
        alt = "|".join(re.escape(n) for n in sorted(names, key=len, reverse=True))
        pats.append(r"\b(?:" + alt + r")\.(?:LoadFromFile|SaveToFile|LoadFromStream|SaveToStream)\s*\(")
    for m in re.finditer("|".join(pats), masked, re.IGNORECASE):
        findings["encoding"].append((path, line_of(text, m.start()), line_text(text, m.start())))


def count_vendored(root, skip_dirs):
    """
    Count TNT references inside the vendored Components folders (which this
    tool does not convert by default). Returns {relative_path: count}.
    """
    out = {}
    pat = re.compile(r"\b(TTnt\w*|Tnt\w*)\b")
    for dirpath, dirs, files in os.walk(root):
        rel = os.path.relpath(dirpath, root)
        if not any(rel == d or rel.startswith(d + os.sep) for d in skip_dirs):
            continue
        for fn in files:
            if fn.lower().endswith((".pas", ".dfm", ".inc", ".dpk")):
                p = os.path.join(dirpath, fn)
                with open(p, "rb") as fh:
                    n = len(pat.findall(mask_text(fh.read().decode("latin-1"))))
                if n:
                    out[os.path.relpath(p, root)] = n
    return out


# --------------------------------------------------------------------------
# Driver
# --------------------------------------------------------------------------

def convert_file(path, text, stats, verify_hits):
    """
    Convert one file's text according to its extension and return the new text.
    .pas and .dpr: uses clauses, then identifiers. .dpk: requires clause only.
    .dfm: class names on object lines.
    """
    ext = os.path.splitext(path)[1].lower()
    if ext in (".pas", ".dpr"):
        text = rewrite_clauses(text, stats, "uses", set())
        text = rewrite_identifiers(text, stats, verify_hits, path)
        if ext == ".dpr":
            text = rewrite_form_annotations(text, stats)
    elif ext == ".dpk":
        text = rewrite_clauses(text, stats, "requires", set())
    elif ext == ".dfm":
        text = rewrite_dfm(text, stats)
    return text


def collect_files(root, include_components):
    """
    List the files to convert: .pas/.dfm/.dpr/.dpk directly under root, plus
    everything below when include_components is set. Paths are relative.
    """
    wanted = (".pas", ".dfm", ".dpr", ".dpk")
    result = []
    for dirpath, dirs, files in os.walk(root):
        rel = os.path.relpath(dirpath, root)
        if rel != "." and not include_components:
            dirs[:] = []
            continue
        for fn in sorted(files):
            if fn.lower().endswith(wanted):
                result.append(os.path.normpath(os.path.join(rel, fn)))
    return sorted(result)


def format_hits(hits, limit=400):
    """Format (path, line, text) tuples as Markdown bullet lines."""
    lines = []
    for path, line, txt in hits[:limit]:
        lines.append("- `%s:%d`  `%s`" % (path.replace(os.sep, "/"), line, txt[:140]))
    if len(hits) > limit:
        lines.append("- ... and %d more" % (len(hits) - limit))
    return "\n".join(lines) if lines else "- (none)"


def write_report(path, stats, findings, vendored, changed_files, total_files, mode_note):
    """Write the Markdown report."""
    out = []
    out.append("# TNT removal report\n")
    out.append("Mode: %s\n" % mode_note)
    out.append("## Summary\n")
    out.append("- Files scanned: %d, files changed: %d" % (total_files, len(changed_files)))
    out.append("- Classes renamed in code: %d, in .dfm objects: %d" % (stats["class_renames"], stats["dfm_class_renames"]))
    out.append("- Identifiers/routines renamed: %d" % stats["ident_renames"])
    out.append("- Units renamed in uses clauses: %d, dropped: %d" % (stats["units_renamed"], stats["units_dropped"]))
    out.append("- TNT packages removed from requires: %d\n" % stats["requires_dropped"])
    out.append("## 1. Needs attention: TNT or Wide* names left unconverted\n")
    out.append("These had no safe one-to-one replacement. Each is either a TNT")
    out.append("routine or a routine from another library; check where it comes from.")
    out.append("Names defined inside the vendored Components copies are not listed;")
    out.append("re-check them once those copies are replaced with current releases.\n")
    out.append("**Tnt-prefixed names remaining**\n")
    out.append(format_hits(findings["tnt_left"]) + "\n")
    out.append("**Wide* names not defined in this source tree**\n")
    out.append(format_hits(findings["wide_left"]) + "\n")
    out.append("## 2. Converted, but check argument types (Tnt_*W wrappers)\n")
    out.append(format_hits(findings["verify"]) + "\n")
    out.append("## 3. Encoding review: string-list and memo load/save calls\n")
    out.append("TNT string lists handled Unicode text themselves. Modern")
    out.append("TStrings.LoadFromFile/SaveToFile use the ANSI code page unless a BOM")
    out.append("is present, so confirm each of these reads and writes the encoding")
    out.append("you intend (pass a TEncoding explicitly where unsure).\n")
    out.append(format_hits(findings["encoding"]) + "\n")
    out.append("## 4. Vendored Components still referencing TNT (not converted)\n")
    out.append("The plan is to replace these with current releases rather than port them.\n")
    if vendored:
        for p, n in sorted(vendored.items()):
            out.append("- `%s`: %d references" % (p.replace(os.sep, "/"), n))
    else:
        out.append("- (none)")
    out.append("\n## Files changed\n")
    out.append("\n".join("- `%s`" % p.replace(os.sep, "/") for p in sorted(changed_files)) or "- (none)")
    with open(path, "w", encoding="utf-8", newline="\n") as fh:
        fh.write("\n".join(out) + "\n")


def main():
    """Parse arguments, convert the files, and write the report."""
    ap = argparse.ArgumentParser(description="Remove TNT Unicode Controls from a Delphi source tree.")
    ap.add_argument("src", help="project source directory (e.g. Source)")
    ap.add_argument("--out", help="write converted copies to this directory")
    ap.add_argument("--in-place", action="store_true", help="modify files in place")
    ap.add_argument("--report", default="tnt_report.md", help="report file (default: tnt_report.md)")
    ap.add_argument("--include-components", action="store_true",
                    help="also convert files below src (vendored Components); default is top level only")
    args = ap.parse_args()

    if args.out and args.in_place:
        ap.error("use either --out or --in-place, not both")
    src = os.path.abspath(args.src)
    if not os.path.isdir(src):
        ap.error("not a directory: %s" % src)

    stats = Counter()
    verify_hits = []
    findings = defaultdict(list)
    defined_wide = find_defined_wide_names(src)
    files = collect_files(src, args.include_components)
    changed = []

    for rel in files:
        with open(os.path.join(src, rel), "rb") as fh:
            original = fh.read().decode("latin-1")
        converted = convert_file(rel, original, stats, verify_hits)
        if converted != original:
            changed.append(rel)
            if args.in_place:
                dest = os.path.join(src, rel)
            elif args.out:
                dest = os.path.join(os.path.abspath(args.out), rel)
            else:
                dest = None
            if dest:
                os.makedirs(os.path.dirname(dest), exist_ok=True)
                with open(dest, "wb") as fh:
                    fh.write(converted.encode("latin-1"))
        elif args.out:
            # keep the output directory complete: copy unchanged files too
            dest = os.path.join(os.path.abspath(args.out), rel)
            os.makedirs(os.path.dirname(dest), exist_ok=True)
            with open(dest, "wb") as fh:
                fh.write(original.encode("latin-1"))
        if rel.lower().endswith((".pas", ".dpr")):
            scan_leftovers(rel, converted, defined_wide, findings)

    findings["verify"] = verify_hits
    skip_dirs = [d for d in os.listdir(src) if os.path.isdir(os.path.join(src, d))] if not args.include_components else []
    vendored = count_vendored(src, skip_dirs)

    if args.in_place:
        note = "in place"
    elif args.out:
        note = "converted copies written to %s" % args.out
    else:
        note = "dry run (no source files written)"
    write_report(args.report, stats, findings, vendored, changed, len(files), note)

    print("scanned %d files, %d would change/changed" % (len(files), len(changed)))
    for k in sorted(stats):
        print("  %-20s %d" % (k, stats[k]))
    print("report: %s" % args.report)
    return 0


if __name__ == "__main__":
    sys.exit(main())
