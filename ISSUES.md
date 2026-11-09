# CubicAdventurer: known issues, bugs and feature requests

This is the maintainer's working list. Reports from users arrive on the GitHub
[Issues](https://github.com/DerellLicht/CubicAdventurer/issues) page and are copied here
once confirmed. When an item is fixed, dropped or closed, move it to `HISTORY.md` (newest
first, with how it ended) and describe the fix in `CHANGELOG.md`.

Entry format: `CA-nnn  [bug|feature|task]  short title`, then a few lines of detail.
Numbers are never reused (highest used so far: CA-073). The exception is CA-051 to CA-059,
which were reused before 2026-10-30; `HISTORY.md` labels those.

Last updated: 2026-11-09 (version 1.04 in progress).

## Open bugs and gaps

(none at the moment)

## Checks still owed

Requested by the Portable Freeware forum user sl23. CA-069, CA-071 and CA-072 were confirmed on
2026-11-09 (see `HISTORY.md`). CA-070 waits for sl23's test (1.03 is out).

- **CA-073 [task] Test: file check boxes follow the theme.** Reported by sl23. Options > Advanced >
  FileView > CheckBoxSelection = True puts a check box in front of every item. CubicExplorer drew
  them in the theme colors; CubicAdventurer drew plain white Windows boxes. Cause: EasyListview
  paints themed check boxes only when it is compiled with its `SpTBX` switch, which the installed
  library is not (and its SpTBX code calls an older SpTBXLib routine, so the switch cannot simply
  be turned on). Fix: the item view classes in `CE_FileViewColors.pas` override `PaintCheckBox`
  and call SpTBXLib's own check box routine for themes from a skin file or a Delphi style; the
  Windows and "Default" themes still use the library's drawing. Test: switch the option on, try a
  dark theme (for example Paint It Black), look at Report, List, Icon and Thumbnail views: normal,
  hover, ticked, and a disabled item if any.

- **CA-070 [task] Test: Default File Manager (Register / Unregister).** Options > General: the
  "Show Default File Manager" check box starts unticked every time Options is shown; ticking it
  reveals the group with the two buttons. The warning text stays visible. Both buttons ask first and
  report the result. Only the current user is changed: `HKCU\Software\Classes\Folder\shell`, the
  verb key `cubicadventurer` and the default value of `Folder\shell`. Unregister puts back the old
  default (only if it still is ours). Uninstalling runs `CubicAdventurer.exe /unregister` (from
  `[UninstallRun]` in the installer script). NOT verified: that Windows 11 honours a per-user default
  verb (Win+E and some other "open folder" paths may still use Explorer). sl23 was asked to test it;
  if it does not work for him, the fallback is the old machine-wide key (`HKCR`, needs elevation),
  or removing the feature again.

## Wishlist

Nice-to-have ideas, taken up when there is no bug list to work on.

(none at the moment)

## Deferred (not started)

- **CA-020 [feature] Language support.** Menus partly translate (sub-menus and some items
  do not). The Translate action and PO editor code remain in the source; the menu items
  are removed. Take up when someone with another language asks. At that point also test
  loading and saving a shipped Locale `.po` in the PO translation editor (not reachable from
  the menus now; its UTF-8 handling was changed but never exercised).
  The `BuildCE/Tools/dxgettext` binaries (Cygwin and gettext tools that rebuilt
  `Locale/default.pot` with `ExtractPOT.bat`) were deleted on 2026-10-27; fetch dxgettext
  again (or use GNU gettext) when this is taken up. Commit before the deletion: bf3816f.
- **CA-022 [feature] High-DPI support** (users report it is missing; the README says it
  is not supported). Findings of 2026-11-03, from reading the repo only (nothing was run at
  a scaled display). The chat is saved as `Documents/High-DPI support plan.md`; its remark
  that the skins are bitmaps is wrong, see below.
  - The exe is already Per-Monitor (v2) aware (checked in Task Manager), so Windows does
    not stretch it. At 125% or more, any problem is the program's own drawing.
  - Skins (`Skins/*.skn`) are plain text files of colors, drawn live by SpTBXLib, whose
    draw calls in our code already pass `CurrentPPI`. No new art is needed; only the
    1-pixel borders and the fixed `TitleBarBorderSize` might look thin.
  - Main cost is icons: the five `TPngImageList`s in `dCE_Images.dfm` (`SmallIcons`,
    `MediumIcons`, `BookmarkImages`, `MiscImages`, `QuickViewImages`) are fixed at 16 or
    24 px. Options: stretch the existing art (soft, no new art), a vector icon set under a
    suitable license (check each one), or larger icons only at high scaling.
  - Unknown, and decides how far we get: DPI support in the patched Toolbar2000, the
    Mustangpeak list view and tree, and JVCL docking (vendoring is dropped).
  - Also to check: pixel values saved in `layout.xml`, column widths and window position
    when settings are used at a different scale; pixel sizes hard-coded in the code.
  - First step when taken up: screenshots at 150% (main window with a few panels open, and
    the Options dialog) from the Windows 11 laptop or a user; not from the desktop.
- **CA-016 [feature] Text editor: highlighter color settings.** There is no page for
  editing highlighter colors; the highlighters use the SynEdit default colors. The Text
  Editor options page (`fCE_TextEditorOptions.pas`) only has the multi-highlighter
  background check box.
  Deferred by decision (2026-10-27): the built-in text editor stays basic. Programmers
  have their own editors (drag and drop from the List view works), and making this a real
  editor is too much effort for a file manager.
- **CA-051 [bug] Text editor: Alt-drag column selection.** Not re-checked since the SynEdit
  swap. `eoAltSetsColumnMode` is missing from the editor's `Options` in
  `fCE_TextEditor.dfm`, which would explain it. Add the option, then test Alt-drag.
  Deferred with CA-016 (no further text editor development).
- **CA-021 [feature] Win64 build.**
- **CA-023 [feature] Move to a free toolchain (Lazarus / Free Pascal).** Decided to do
  this in a new thread after the Delphi release is stable. Core code is portable; the hard
  parts are SpTBX/Toolbar2000, the Mustangpeak shell components and JVCL docking.
- **CA-017 [bug] Dock layout hardening.** `DoUnAutoHideDockForm` bypasses the dock-chain
  guard; only root-level floating hosts are pre-created. Optional proper fix: derive
  `TCEDockInfoZone` with a wide `TFormBorderStyle` property (the `{$R-}` interim in
  `CE_DockInfo.pas` stays until then). Deferred (2026-10-27): nothing has gone wrong in testing; take it up when
  a user reports a layout hang.

## Misc tasks

(none at the moment)

## Maintenance (internal)

(none at the moment)
