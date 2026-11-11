# CubicAdventurer: known issues, bugs and feature requests

This is the maintainer's working list. Reports from users arrive on the GitHub
[Issues](https://github.com/DerellLicht/CubicAdventurer/issues) page and are copied here
once confirmed. When an item is fixed, dropped or closed, move it to `HISTORY.md` (newest
first, with how it ended) and describe the fix in `CHANGELOG.md`.

Entry format: `CA-nnn  [bug|feature|task]  short title`, then a few lines of detail.
Numbers are never reused (highest used so far: CA-081). The exception is CA-051 to CA-059,
which were reused before 2026-10-30; `HISTORY.md` labels those.

Last updated: 2026-11-11 (version 1.04 in progress).

## Open bugs and gaps

(none at the moment)

## Checks still owed

Requested by the Portable Freeware forum user sl23. CA-069, CA-071, CA-072 and CA-073 were confirmed
on 2026-11-09 and CA-074 to CA-078 and CA-080 on 2026-11-11 (see `HISTORY.md`). CA-070 waits for sl23's
test (1.03 is out). CA-081 is left from Derell's own use of several windows, and CA-079 is new on 2026-11-11.

- **CA-079 [task] Test: Sessions > Open in New Window.** Requested by Derell 2026-11-10 (he opens a
  new window and then loads a session every time). Sessions menu, below Manage...: "Open in New
  Window" is a sub-menu listing the saved sessions; clicking one starts another copy of the program
  with the switch `/session:<name>`, which loads that session at startup instead of the On Startup
  choice (an unknown name falls back to the normal startup). This window is not changed. The item is
  disabled while Single Instance Only is on. The new window cascades (CA-077). If the session is
  already active in another window it is simply opened again (two windows, the later save wins).
  Folder arguments given with the switch open as extra tabs. A session name containing a double
  quote cannot be passed this way. Not tested yet (2026-11-11).

- **CA-081 [task] Test: the tray with several windows, including Exit All.** With the tray icon on
  and Single Instance Only off, open two or three windows: each shows its own tray icon; use Close to
  tray and Minimize to tray in one window and in several, restore from the tray, and run File > Exit All
  (and Exit from the tray menu) while some windows are hidden in the tray. All windows must close and
  save, and no tray icon may be left behind. The tray was a source of trouble before (CA-054), so
  report anything odd. Not tested yet (2026-11-11).

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
