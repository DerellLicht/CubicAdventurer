# CubicAdventurer: known issues, bugs and feature requests

This is the maintainer's working list. Reports from users arrive on the GitHub
[Issues](https://github.com/DerellLicht/CubicAdventurer/issues) page and are copied here
once confirmed. When an item is fixed, delete it from this file and describe the fix in
`CHANGELOG.md`; git history keeps the rest.

Entry format: `CA-nnn  [bug|feature|task]  short title`, then a few lines of detail.
Numbers are never reused.

Last updated: 2026-10-30 (version 0.98 in progress).

## Open bugs and gaps

- **CA-058 [bug] File view sometimes misses added or renamed files** (formerly CA-011, reopened
  2026-10-30). Explorer and Explorer++ show a download at once; CA sometimes shows nothing until
  F5, or shows the temporary download name and never the final name (Helium; earlier Waterfox).
  Explorer++ also leaves the temporary file behind with Helium, so part of this is how Chromium
  finishes a download. Firefox downloads worked after navigating away and back.
  From the library source (2026-10-30): a view hears about changes through a global shell
  registration (blind to programs that write silently) and a per-view
  `FindFirstChangeNotification` that one library thread waits on. That thread closes and
  reopens ALL handles on every rebuild (changes inside that gap are lost); a global gate
  (`OkToDispatch`) holds every batch while any control is dragging, editing or showing a menu;
  and a view that is not `Active` drops a batch with no requeue. Which of these loses the event
  is NOT known yet.
  TEMPORARY trace build (not compiled): `Source/Components/Mustangpeak/VSTools/VirtualShellNotifier.pas`
  is a traced copy of upstream commit 6712997 (listed in `CubicAdventurer.dpr`), plus `CA trace`
  lines in `CE_FileView.pas` (`WndProc`, `SetNotifyFolder`). Test: run DbgView and Process Monitor
  (filter on the Downloads path), download a file with Helium, send both logs. When the cause is
  known, delete the copy, its `.dpr` line and the `CA trace` lines.
  Trace build 1 result (Helium, 2026-10-30 09:00): the shell notices for the download DID reach
  the Downloads view (batches of 6 and 7 events, view active, valid root, gate open, no rebuild),
  and the view still kept the temp name. Every kernel-watch signal was `direct=True`, so the
  per-view watch is a dead end for that tab. Trace build 2 adds, per notification, its type,
  folder, `IsRootNamespace` result and `Handled` flag, begin/end markers (with item counts) around
  `RereadAndRefresh`, and the folder name on each `SIGNAL`. Run it WITHOUT clearing DbgView after
  startup so the rebuild lines are kept.

## Checks still owed

(none at the moment)

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
