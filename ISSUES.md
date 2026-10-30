# CubicAdventurer: known issues, bugs and feature requests

This is the maintainer's working list. Reports from users arrive on the GitHub
[Issues](https://github.com/DerellLicht/CubicAdventurer/issues) page and are copied here
once confirmed. When an item is fixed, delete it from this file and describe the fix in
`CHANGELOG.md`; git history keeps the rest.

Entry format: `CA-nnn  [bug|feature|task]  short title`, then a few lines of detail.
Numbers are never reused.

Last updated: 2026-10-30 (version 0.99 in progress).

## Open bugs and gaps

(none at the moment)

## Checks still owed

- **CA-060 Folders tree top-level label color.** Implemented 2026-10-30 (not compiled yet): Desktop,
  This PC, Network and the other top-level labels are not real file system directories, so they ignored
  the Folder text color and stayed in the Windows text color (dark on a dark background). They now use
  the Folder text color (Options > Display > Fileview > Attributes). The first attempt (7d4867f) fixed
  This PC, Libraries, Network, Control Panel and Recycle Bin but not the root Desktop and the drives
  (C: to G:), which the shell reports as file system items; the second attempt covers every node in the
  tree. Test: set a light Folder text color on a dark background and check Desktop and the drive
  labels; with Folder text color at Default nothing changes. Why those nodes are not `Directory` is
  unverified (the library unit that decides this was not readable here); if any stay dim, send a screenshot.
- **CA-059 Folders tree font size.** Implemented 2026-10-30 (not compiled yet): folder names in the
  Folders panel should be the same size as the names in the file list. Test: with the default
  Arial 9 pt, compare the two; then change the font in Options > Display > Fileview (a larger and a
  smaller size) and check that the tree follows at once and after a restart. Only the size is shared;
  the typeface of the tree is still the Windows desktop icon font. The old hand-edited
  `FolderPanel` `FontSize` in `settings.xml` (-1 = follow the file view) still overrides when set to a
  positive number. The row height now follows the font (text height plus 2 pixels, never below the
  old 17 pixels), so descenders such as g, j, p and y are no longer overwritten by the next row; check
  that with a large font too. A positive `FolderPanel` `LineHeight` in `settings.xml` still fixes it.
- **CA-058 file view auto-update.** Fixed 2026-10-30 (see `CHANGELOG.md`). Keep an eye on it in daily
  use, especially downloads into the Downloads tab. If a view ever stops updating again, the
  diagnostic trace build is in git history (commits 98703df to abc896b); the trace logs showed
  the watch list (`rebuild CONTROLS`) and every notification each view received.

## Wishlist

Nice-to-have ideas, taken up when there is no bug list to work on.

(none at the moment)

## Deferred (not started)

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
- **CA-020 [feature] Language support.** Menus partly translate (sub-menus and some items
  do not). The Translate action and PO editor code remain in the source; the menu items
  are removed. Take up when someone with another language asks. At that point also test
  loading and saving a shipped Locale `.po` in the PO translation editor (not reachable from
  the menus now; its UTF-8 handling was changed but never exercised).
  The `BuildCE/Tools/dxgettext` binaries (Cygwin and gettext tools that rebuilt
  `Locale/default.pot` with `ExtractPOT.bat`) were deleted on 2026-10-27; fetch dxgettext
  again (or use GNU gettext) when this is taken up. Commit before the deletion: bf3816f.
- **CA-021 [feature] Win64 build.**
- **CA-022 [feature] DPI awareness** (users report it is missing).
- **CA-023 [feature] Move to a free toolchain (Lazarus / Free Pascal).** Decided to do
  this in a new thread after the Delphi release is stable. Core code is portable; the hard
  parts are SpTBX/Toolbar2000, the Mustangpeak shell components and JVCL docking.
- **CA-017 [bug] Dock layout hardening.** `DoUnAutoHideDockForm` bypasses the dock-chain
  guard; only root-level floating hosts are pre-created. Optional proper fix: derive
  `TCEDockInfoZone` with a wide `TFormBorderStyle` property (the `{$R-}` interim in
  `CE_DockInfo.pas` stays until then). Deferred (2026-10-27): nothing has gone wrong in testing; take it up when
  a user reports a layout hang.

## Misc tasks

- **CA-005a [task] Spread the word further.** The first announcement reached fewer places
  than hoped. Brain-storm other options: Windows file-manager discussion sites on Reddit
  and similar communities, software directories, and forums for other Delphi-era tools.

## Maintenance (internal)

(none at the moment)
