# CubicAdventurer revival checklist (survey of repo as of 2026-10-18; status updated 2026-10-19)

## Status (updated 2026-10-19, evening)
- IDE: Embarcadero Delphi 13 Florence Community Edition, version 37.0.60542.8024. Installed and registered.
- Done (branch `ce_convert`): `tnt_strip.py --in-place` (96 files); `CE_WideCompat.pas` and Wide* fixes; patch disabling `TNTSUPPORT` in vendored `Mustangpeak/Include/Addins.inc` delivered (confirm it was applied and pushed).
- Libraries installed in the IDE (Win32): Mustangpeak Common Library + ListView (GetIt), Virtual Treeview V8.3 (GetIt), VirtualShellTools (manual, `Delphi/Jam-VT`), SynEdit (GetIt), TB2K + SpTBXLib (manual, packages `tb2k_d12`, `tb2kdsgn_d12`, `SpTBXLib`, `SpTBXLibDsgn`), JCL (manual, see below), JVCL (manual build succeeded, see below).
- Community Edition cannot run the command-line compiler, so GetIt's installers for JCL/JVCL fail with "does not support command line compiling" and still report success. The GetIt "installed" label is not reliable for them. Workaround: GetIt only downloads the source into `CatalogRepository`; the packages are then built by hand from the group projects.
- JCL: copied `source\include\jcl.template.inc` to `jcld37win32.inc`, built `packages\JclPackagesD370.groupproj` (Build All, ok). Library paths added (Win32): `lib\d37\win32`, `source\include`, `source\common`, `source\windows`, `source\vcl`.
- JVCL: built `packages\D37 Packages.groupproj` (Build All, ok, about 3 million lines). Its library paths and design-package installs are NOT done yet.
- Next: JVCL library paths; Graphics32; GraphicEx replacement; open `Source\CubicExplorer.dpr`; first Win32 compile.

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
| Mustangpeak VirtualShellTools / EasyListview / Common Lib | core of the file views | TurboPack/GetIt "Mustangpeak VirtualShell" 2026.10 (13 Oct 2026), source-only, Win32/Win64, MPL 1.1. The project also needs `MPCommonUtilities`, which lives in the separate Common Library (github.com/TurboPack/MustangpeakCommonLib, last commit 2026-09-18); check GetIt for it too. Repo also carries 6 patched copies in Source/Components/Mustangpeak |
| Toolbar2000 + SpTBXLib | 23 forms | SpTBXLib (SilverpointDev/sptbxlib) says XE2 or newer; needs TB2K plus its "TB2K Patch" step. Delphi 13 support unconfirmed |
| JCL / JVCL | JvDock, JvSimpleXml (7 files), JCL (4 files) | project-jedi; repo says Delphi 6 and newer. Delphi 13 builds ok (JCL 2.7 lists D13 as supported). Repo carries a partial vendored JvDock; the app also needs the full JVCL for JvAppStorage, JvFormPlacement, JvSimpleXml, JvJVCLUtils and jvcl.inc |
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
- Leftover `Wide*` helpers (from its report) and how each was resolved:
  - Provided by the current Mustangpeak Common Library (`MPCommonUtilities.pas`, checked against its source): `WideExpandEnviromentString` (+ForUser), `WideStripTrailingBackslash`, `WideStripExt`, `WideIsDrive`, `WideShellExecute`. Nothing to do once that library is installed; the converter still lists them (14 lines) because it cannot see that library.
  - Replaced at the call site: `WideCanvasTextExtent` became `Canvas.TextExtent` (5 calls in CE_InfoBar), `WideCopyFile` became `CopyFileW` (1 call), `TntWideLastChar` became an inline check (1 call).
  - New `Source/CE_WideCompat.pas`, same signatures as before so no call sites change: `WideMessageBox` (about 25 calls), `WideDeleteDirEx` (1 call), `WideSelectDirectory` (2 calls). `WideMessageBox` and `WideDeleteDirEx` are not defined in TNT or in today's Mustangpeak (they probably came from the 2012-era Mustangpeak), so their behaviour was inferred from the call sites: title comes before message, result is the button id; delete is recursive and refuses drive roots.
- Syntax of the new unit was checked with Free Pascal against stand-in units (no errors); it has not been compiled with Delphi.
- Encoding review list: string-list and memo LoadFromFile/SaveToFile/Stream calls whose default encoding changes from TNT to modern VCL (about 11 spots).

## Suggested order of attack
1. Branch the fork (e.g. `unicode-port`).
2. Run `tnt_strip.py` (dry run first, then `--in-place`) and commit; review the diff and report.
3. Install Virtual Treeview (V8), Mustangpeak VirtualShell and SynEdit via GetIt; check GetIt for JCL/JVCL and Graphics32.
4. Install TB2K + SpTBXLib manually (check Delphi 13 compatibility first); find a GraphicEx replacement.
5. Open `Source\CubicExplorer.dpr` in Delphi (it should generate a `.dproj`), set search paths, try a first build of Win32 only. Expect many compile errors; fix by category.
6. Review Win32 W-suffix calls, PChar/PWideChar usage (about 100 spots) and the encoding list (the `Wide*` manual items are done, see above).
7. Defer: Win64 build, DPI awareness (users report it is missing), translations, installer.
8. Last step, once the program runs: write a new `Build_instructions.md` for the repo covering how to assemble the tools and build the project in 2026 (Delphi 13 CE, each library and how it was installed, library paths, the Community Edition command-line-compiler workaround, first-build steps). It does not need to describe the code changes. Collect the details as we go (the handoff document and this checklist are the source).

## Open questions
- Whether SpTBXLib, JCL/JVCL and Graphics32 officially support Delphi 13.
- GraphicEx replacement.
- Whether the repo's patched Mustangpeak units differ materially from the current TurboPack release.
- Whether Delphi 13 converts the old `.bdsproj` cleanly into a `.dproj`.

## Before declaring CubicAdventurer releasable (TODO)
- **Dock layout field types (CE_DockInfo.pas):** JVCL's `TJvDockInfoZone.BorderStyle` is declared `TBorderStyle` (`bsNone..bsSingle`, 0..1) but the original CE stored `TFormBorderStyle` values 0..5 in it, so legacy `layout.xml` files contain `BorderStyle` = 5. Interim fix (30dcc1e): range checking switched off around the four enum assignments (BorderStyle, FormStyle, WindowState, DockFormStyle) when loading layout.xml, plus `ReadEnumOrd` which logs and zeroes out-of-range values. Proper fix wanted: derive `TCEDockInfoZone` from `TJvDockInfoZone` with a wide `TFormBorderStyle` property, override the virtual `SetDockInfoFromControlToNode` / `SetDockInfoFromNodeToControl`, pass the class to the tree constructor, and use it in our own load/save code. Also test the layout *save* path under the debugger (Debug config has range checking on).
- **Fileview options page:** restore the Options / Display / Colors tabs and the settings behind them (extension colors, list font and background color, per-folder settings, thumbnail storage) so legacy `settings.xml` (`ExtensionColors`, `Font`, `BackgroundColor`, `PerFolderSettings`, `Thumbnails`) loads and saves unchanged. Reference: the SVN tag `0.96.0.1582` from the Google Code archive. A first draft built from screenshots is on branch `fileview_draft` (superseded once the real code is found).
