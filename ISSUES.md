# CubicAdventurer: known issues, bugs and feature requests

This is the maintainer's working list. Reports from users arrive on the GitHub
[Issues](https://github.com/DerellLicht/CubicAdventurer/issues) page and are copied here
once confirmed. When an item is fixed, dropped or closed, move it to `HISTORY.md` (newest
first, with how it ended) and describe the fix in `CHANGELOG.md`.

Entry format: `CA-nnn  [bug|feature|task]  short title`, then a few lines of detail.
Numbers are never reused (highest used so far: CA-079). The exception is CA-051 to CA-059,
which were reused before 2026-10-30; `HISTORY.md` labels those.

Last updated: 2026-11-10 (version 1.04 in progress).

## Open bugs and gaps

(none at the moment)

## Checks still owed

Requested by the Portable Freeware forum user sl23. CA-069, CA-071, CA-072 and CA-073 were confirmed
on 2026-11-09 (see `HISTORY.md`). CA-070 waits for sl23's test (1.03 is out). CA-074 to CA-078 come
from Derell's own use of several windows (2026-11-10).

- **CA-074 [task] Test: sessions kept when several windows save.** Untick Options > General >
  Single Instance Only, open two windows. Load `default` in one and `Entertain Me` in the other
  (both save changes automatically), change the tabs in each, wait a few seconds, close both
  windows, start again: both sessions must show their changes. Also: save a new session in one
  window and open the Sessions menu in the other (the new name appears within a second); delete a
  session in Manage in one window and open the menu in the other (the name is gone). Before each
  change a window now merges what is in `sessions.xml` into its own copy. Limit: if two windows
  change the same session, the later save wins for that session.
- **CA-075 [task] Test: History at exit and its new caption.** History items now read "Tabs saved
  at <date time>" (they were "Session at ..."; they are not sessions). Translations of the old text
  in the `Locale` files no longer apply, so those languages show the English caption. With Auto Save
  History on and a plain tab set (no session active): exit with the tabs as started, so no new
  History item; open another folder, exit, one new item. Load the newest History item and exit
  unchanged, no new item; load an older one and exit, a new item (so "Continue from last time" comes
  back with what you last had open).
- **CA-076 [task] Test: session name in the window title.** With a saved session active the title
  reads `<session name> - CubicAdventurer v1.04`, also with one window. New Session, Detach from
  Session, or loading a History item gives the plain title; renaming the active session in Manage
  updates it; with Options > General > Show Path in Title bar on, the title stays the folder path.
- **CA-078 [task] Test: no renaming of a session that is active in a window.** With several
  windows open and different sessions active, open Sessions > Manage in any window and select a
  session that is active in this or any other window: the Name field is greyed and the note "Name
  change disabled: this session is active in a window." shows under the automatic-save check box.
  Select a session no window has active: the field works. Close the window that had it active and
  reopen Manage in another: the field is enabled again. (Each window tells the others its active
  session through a window property; nothing is stored on disk.)
- **CA-077 [task] Test: a new window opens offset from the first.** With Single Instance Only off,
  File > New Window: the new window opens one title bar height down and to the right of the open
  window (taken from where that window is now, not where it was at its last exit); a third window
  cascades from the second. Near the bottom or right edge of the screen it goes back to the top-left
  of the screen. If the open window is maximized, the new one opens as saved. Before, it covered the
  first window exactly.

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

- **CA-079 [feature] Sessions > Open in New Window.** Requested by Derell 2026-11-10: with
  several windows in use, the usual routine is to open a new window and then load a session into
  it, so one menu command should do both. Shown in the Sessions menu (and perhaps on a session's
  entry); disabled while Single Instance Only is on, like File > New Window. Open points: the new
  window must be told which session to load, and every command-line argument is now taken as a
  folder to open, so a switch such as `/session:<name>` is needed; the new window should open
  cascaded (CA-077) and the session must not be loaded in this window; and if the session is
  already active in another window, ask or just open it again (two windows saving the same
  session, the later save wins). Not started.

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
