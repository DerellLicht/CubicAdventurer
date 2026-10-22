#!/usr/bin/env python3
"""
Version helper for CubicAdventurer.  The single source of the version is the newest
"## [x.yy]" header in CHANGELOG.md (see the Makefile).  Delphi cannot be run from the
command line (Community Edition), so the exe is still built in the IDE; this tool keeps
the IDE project in step with the changelog and proves the exe really carries the version.

  version_tool.py sync VERSION [Source/CubicAdventurer.dproj]
      Write VERSION (e.g. 1.05) into the project's version info: FileVersion and
      ProductVersion strings in every VerInfo_Keys line (the Base and Base_Win32 sections
      both have one, and Win32 wins), plus VerInfo_MajorVer / VerInfo_MinorVer.
      Rewrites the file only if something changes.  Edits bytes in place, so the file's
      line endings are untouched.

  version_tool.py check-dproj VERSION [Source/CubicAdventurer.dproj]
      Exit 1 (with a message) if the project does not carry VERSION.

  version_tool.py check-exe VERSION EXE
      Exit 1 if the FileVersion string inside EXE is not VERSION, i.e. the exe was built
      before the project was synced, or the IDE was not rebuilt.
"""
import re
import sys

DPROJ = "Source/CubicAdventurer.dproj"


def split_version(version):
    m = re.fullmatch(r"(\d+)\.(\d+)", version)
    if not m:
        sys.exit('version must look like "1.05", got "%s"' % version)
    return int(m.group(1)), int(m.group(2))


def sync(version, path):
    major, minor = split_version(version)
    with open(path, "rb") as fh:
        data = fh.read()
    text = data.decode("utf-8")
    new = text

    # version strings inside every VerInfo_Keys value
    def fix_keys(m):
        v = m.group(0)
        v = re.sub(r"(?<![A-Za-z])FileVersion=[^;<]*", "FileVersion=" + version, v)
        v = re.sub(r"ProductVersion=[^;<]*", "ProductVersion=" + version, v)
        return v

    new = re.sub(r"<VerInfo_Keys>.*?</VerInfo_Keys>", fix_keys, new)
    new = re.sub(r"<VerInfo_MajorVer>\d+</VerInfo_MajorVer>",
                 "<VerInfo_MajorVer>%d</VerInfo_MajorVer>" % major, new)
    new = re.sub(r"<VerInfo_MinorVer>\d+</VerInfo_MinorVer>",
                 "<VerInfo_MinorVer>%d</VerInfo_MinorVer>" % minor, new)

    if new == text:
        print("%s already at %s" % (path, version))
        return
    with open(path, "wb") as fh:
        fh.write(new.encode("utf-8"))
    print("%s updated to %s" % (path, version))
    print("REBUILD REQUIRED: build in the Delphi IDE (Shift-F9) so CubicAdventurer.exe carries it.")


def dproj_versions(path):
    with open(path, "rb") as fh:
        text = fh.read().decode("utf-8")
    found = set()
    for m in re.finditer(r"<VerInfo_Keys>.*?</VerInfo_Keys>", text):
        for key in ("FileVersion", "ProductVersion"):
            k = re.search(r"(?<![A-Za-z])" + key + r"=([^;<]*)", m.group(0))
            found.add(k.group(1) if k else "(missing)")
    maj = re.search(r"<VerInfo_MajorVer>(\d+)<", text)
    mnr = re.search(r"<VerInfo_MinorVer>(\d+)<", text)
    return found, (int(maj.group(1)) if maj else None, int(mnr.group(1)) if mnr else None)


def check_dproj(version, path):
    major, minor = split_version(version)
    found, nums = dproj_versions(path)
    if found != {version} or nums != (major, minor):
        sys.exit("ERROR: %s has version strings %s and numbers %s, expected %s.\n"
                 "Run: make sync-version" % (path, sorted(found), nums, version))
    print("%s carries %s" % (path, version))


def exe_file_version(path):
    """FileVersion string from the exe's version resource (UTF-16LE key, then value)."""
    with open(path, "rb") as fh:
        data = fh.read()
    key = "FileVersion".encode("utf-16-le") + b"\x00\x00"
    pos = 0
    while True:
        i = data.find(key, pos)
        if i < 0:
            return None
        j = i + len(key)
        while data[j:j + 2] == b"\x00\x00":   # alignment padding
            j += 2
        k = j
        while k + 1 < len(data) and data[k:k + 2] != b"\x00\x00":
            k += 2
        value = data[j:k].decode("utf-16-le", errors="replace")
        if value and re.fullmatch(r"[0-9][0-9A-Za-z.\-_ ]*", value):
            return value
        pos = i + 2


def check_exe(version, path):
    try:
        got = exe_file_version(path)
    except OSError as e:
        sys.exit("ERROR: cannot read %s (%s). Build it in the Delphi IDE first." % (path, e))
    if got is None:
        sys.exit("ERROR: no FileVersion found in %s" % path)
    if got != version:
        sys.exit('ERROR: %s says FileVersion "%s" but CHANGELOG.md says %s.\n'
                 "REBUILD REQUIRED: run make sync-version (if the project is not at %s yet), then build in the\n"
                 "Delphi IDE (Shift-F9)." % (path, got, version, version))
    print("%s carries %s" % (path, version))


def main():
    a = sys.argv[1:]
    if len(a) < 2:
        sys.exit(__doc__)
    cmd, version = a[0], a[1]
    if cmd == "sync":
        sync(version, a[2] if len(a) > 2 else DPROJ)
    elif cmd == "check-dproj":
        check_dproj(version, a[2] if len(a) > 2 else DPROJ)
    elif cmd == "check-exe":
        if len(a) < 3:
            sys.exit(__doc__)
        check_exe(version, a[2])
    else:
        sys.exit(__doc__)


if __name__ == "__main__":
    main()
