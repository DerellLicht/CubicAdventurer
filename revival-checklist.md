# CubicAdventurer revival checklist (survey of repo as of 2026-10-18; status updated 2026-10-19)

## Status
- IDE: Embarcadero Delphi 13 Florence Community Edition, version 37.0.60542.8024 (13.0 base, installer `7c1ba2_RADStudio_13_CE.exe`). Installed and registered as of 2026-10-19.
- Tooling: `claude/tnt_strip.py` (see below) is ready to run against the fork.
- Next: branch the fork, run `tnt_strip.py`, install libraries, open `Source\CubicExplorer.dpr`, first Win32 compile.

## What the repo is
- Delphi 2006 (BDS 2006) project: `Source/CubicExplorer.bdsproj`, `.dpr`, `.cfg`; package suffixes `_d10`.
- ~107 .pas files, 47 .dfm forms, ~71,800 lines of Pascal.
- Pre-Unicode-Delphi code: Unicode is done with TNT Unicode Controls and WideString.
- LICENSE is MPL 1.1 (original author Marko Savolainen). Modified MPL files stay MPL; CC0 does not apply to them.

## BuildCE folder
- Original author's release tooling: snapshot/installer .bat files, a bundled dxgettext toolset for building the .pot translation template, an upload script and SVN helpers.
- Mostly obsolete (hard-coded SVN server and Z: drive paths, FTP upload). dxgettext and ExtractPOT.bat may still be useful for the locale files.
- `Compiling_Instructions.txt` (repo root) is the real prize: the author's full dependency list and install order.

## Dependencies (original list) and what to do
| Library | Used by | Status / plan |
|---|---|---|
| TNT Unicode Controls | 67 of 107 units, 25 of 47 forms | Unmaintained, pre-Unicode. Being removed with `tnt_strip.py`; modern VCL is natively Unicode (biggest task) |
| Virtual Treeview | 23 uses | Current: JAM-Software/Virtual-TreeView (V8, RAD Studio 10 to 13). TurboPack copy is archived. V8 has breaking changes vs old 5.x |
| Mustangpeak VirtualShellTools / EasyListview / Common Lib | core of the file views | TurboPack/GetIt "Mustangpeak VirtualShell" 2026.10 (13 Oct 2026), source-only, Win32/Win64, MPL 1.1. Repo also carries 6 patched copies in Source/Components/Mustangpeak |
| Toolbar2000 + SpTBXLib | 23 forms | SpTBXLib (SilverpointDev/sptbxlib) says XE2 or newer; needs TB2K plus its "TB2K Patch" step. Delphi 13 support unconfirmed |
| JCL / JVCL | JvDock, JvSimpleXml (7 files), JCL (4 files) | project-jedi; repo says Delphi 6 and newer. Delphi 13 support unconfirmed. Repo carries a partial vendored JvDock |
| Graphics32 | 9 files | graphics32/graphics32 on GitHub; Delphi 13 support unconfirmed. API changed since 1.8.x |
| GraphicEx | 5 files | Old; needs a maintained fork or replacement (not yet researched) |
| SynEdit | 3 files | TurboPack/SynEdit, Delphi 12 or later (Delphi 13 not stated) |
| PngComponents | 8 files | Modern VCL has native TPngImage; can likely drop this package |
| madExcept | 2 files | Optional crash reporter; can be removed at first (`-DmadExcept`) |
| FastMM4 | 2 files | Delphi's RTL already includes FastMM; can be removed |
| CEAction, fcl-xml, DirectX headers | vendored in repo | Build from repo; DirectX headers need checking for 64-bit |

## Vendored Components are tied to TNT
- Source/Components copies of MPShellUtilities (about 54 references), VirtualExplorerTree, VirtualExplorerEasyListview, EasyListview, JclCompressionWide and FindFileW themselves reference TNT (about 130 in total).
- Plan: replace them with current releases rather than port them. The risk is the author's own patches to those units; compare before discarding.
- `tnt_strip.py` leaves these folders alone by default and only counts their references.

## tnt_strip.py (TNT removal tool)
- Python script, default mode is a dry run. Options: `--out DIR` writes converted copies, `--in-place` modifies files (commit to git first), `--report FILE`, `--include-components`.
- Renames TNT classes (code and .dfm), TNT units in uses clauses (keeping the author's original unit order), `Wide*` routines and `Tnt_*W` wrappers that have a one-to-one modern equivalent; removes TNT packages from the .dpk; updates the `{Form: TTntForm}` annotations in the .dpr.
- Test on a copy of the fork's Source: 96 of 156 files changed, no `TTnt` left, no duplicate or empty uses entries, every replacement unit still present, second run changes nothing. Not compiled (no Delphi in the test environment).
- Still manual (listed in its report): `WideMessageBox` (about 25 calls), `WideExpandEnviromentString` and the ForUser variant, `WideStripTrailingBackslash`, `WideShellExecute`, `WideSelectDirectory`, `WideCanvasTextExtent`, `WideStripExt`, `WideIsDrive`, `WideCopyFile`, `WideDeleteDirEx`, `TntWideLastChar`. Idea: one small compatibility unit with these signatures.
- Encoding review list: string-list and memo LoadFromFile/SaveToFile/Stream calls whose default encoding changes from TNT to modern VCL (about 11 spots).

## Suggested order of attack
1. Branch the fork (e.g. `unicode-port`).
2. Run `tnt_strip.py` (dry run first, then `--in-place`) and commit; review the diff and report.
3. Install Virtual Treeview (V8), Mustangpeak VirtualShell and SynEdit via GetIt; check GetIt for JCL/JVCL and Graphics32.
4. Install TB2K + SpTBXLib manually (check Delphi 13 compatibility first); find a GraphicEx replacement.
5. Open `Source\CubicExplorer.dpr` in Delphi (it should generate a `.dproj`), set search paths, try a first build of Win32 only. Expect many compile errors; fix by category.
6. Handle the manual items from the report; review Win32 W-suffix calls, PChar/PWideChar usage (about 100 spots) and the encoding list.
7. Defer: Win64 build, DPI awareness (users report it is missing), translations, installer.

## Open questions
- Whether SpTBXLib, JCL/JVCL and Graphics32 officially support Delphi 13.
- GraphicEx replacement.
- Whether the repo's patched Mustangpeak units differ materially from the current TurboPack release.
- Whether Delphi 13 converts the old `.bdsproj` cleanly into a `.dproj`.
