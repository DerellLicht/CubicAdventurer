# CubicAdventurer: known issues, bugs and feature requests

This is the maintainer's working list. Reports from users arrive on the GitHub
[Issues](https://github.com/DerellLicht/CubicAdventurer/issues) page and are copied here
once confirmed. When an item is fixed, delete it from this file and describe the fix in
`CHANGELOG.md`; git history keeps the rest.

Entry format: `CA-nnn  [bug|feature|task]  short title`, then a few lines of detail.
Numbers are never reused.

Last updated: 2026-10-26 (version 0.98 in progress).

## Open bugs and gaps

- **CA-016 [feature] Text editor.** No highlighter-settings editor (highlighters use
  SynEdit default colors). Alt-drag column selection not re-checked (probably
  `eoAltSetsColumnMode` missing from Options). Combo box SkinType TODO in
  `CE_ToolbarEditorItems.pas` (about line 1067), cosmetic. Tab strip gap would mean
  changing `CE_SpTabBar.pas`.
- **CA-017 [bug] Dock layout hardening.** `DoUnAutoHideDockForm` bypasses the dock-chain
  guard; only root-level floating hosts are pre-created. Optional proper fix: derive
  `TCEDockInfoZone` with a wide `TFormBorderStyle` property (the `{$R-}` interim in
  `CE_DockInfo.pas` stays until then). Wait for a user report before spending time here.

## Wishlist

Nice-to-have ideas, taken up when there is no bug list to work on.

(none at the moment)

## Deferred (not started)

- **CA-020 [feature] Language support.** Menus partly translate (sub-menus and some items
  do not). The Translate action and PO editor code remain in the source; the menu items
  are removed. Take up when someone with another language asks.
- **CA-021 [feature] Win64 build.**
- **CA-022 [feature] DPI awareness** (users report it is missing).
- **CA-023 [feature] Move to a free toolchain (Lazarus / Free Pascal).** Decided to do
  this in a new thread after the Delphi release is stable. Core code is portable; the hard
  parts are SpTBX/Toolbar2000, the Mustangpeak shell components and JVCL docking.

## Checks still owed

- **CA-054 [task] Check the 2026-10-26 Options/Customize cleanup.** Options > Hotkeys: no
  Tabs / Stack Open / Stack Save / Translate / Show-Hide / Make Visible / New Window rows,
  Restore Default Layout under View, no Global child page. View menu has no Archiver item.
  Tools > Customize > Buttons: one icon per row, new hint readable (dialog is 16 px taller).
  Options > Hotkeys: pressing a key combination shows who owns it (or "Not assigned") under
  the Hotkeys list. Options > General: no Single Instance box and no Default File Manager
  group; File menu has no New Window; starting the program twice brings the first window
  forward (a `SingleInstance` value in an old `settings.xml` is ignored).
  Tips and Tricks (`Documents/Tips_and_Tricks.md`): the Workspace docking steps and the Start
  Menu "Tips and Tricks" link (upgrade removes the old "Bookmarks and Sessions Guide" link).
- **CA-030 [task] Settings loaders and old files.** `TCEAppSettings` is verified to
  ignore unknown keys and default missing ones. The other loaders (toolbar buttons, dock
  layout, sessions, `TCECustomSettingStorage` descendants) have not been reviewed for that
  policy.
- **CA-031 [task] Non-ASCII test of the UTF-8 changes.** Thumbnails of UTF-8 text
  files; confirm `settings.xml` still saves what matters. (The PO translation editor can
  no longer be reached from the menus; test loading and saving a shipped Locale `.po` in it
  under CA-020, when language support is taken up.)

## Misc tasks

- **CA-005a [task] Spread the word further.** The first announcement reached fewer places
  than hoped. Brain-storm other options: Windows file-manager discussion sites on Reddit
  and similar communities, software directories, and forums for other Delphi-era tools.

## Maintenance (internal)

- **CA-040 [task] Retire old packages.** Drop `CEToolbar.dpk` and `CE_Actions.dpk` (and
  `Components/CEAction/CE_Actions.*`), keep `CE_Design.dpk/.dproj`. Check first that
  nothing in the `.dpr` / `.dproj` references them.
- **CA-041 [task] Vendor the hand-installed libraries** (Graphics32, PngComponents,
  SpTBXLib, Toolbar2000) into the repo, as the original did.
- **CA-042 [task] Housekeeping.** Remove unused edits in the vendored
  `VirtualExplorerEasyListview.pas`; stale root-level `Components\fcl-xml` (needs OK);
  `.gitattributes` / CRLF decision (the repo has mixed line endings); retire the
  `Options.inc` / `Compilers.inc` stubs. Dead code left behind on 2026-10-26: the
  `SingleInstance` property and settings key (`Main.pas`, `dCE_Settings.pas`) and the unused
  Register / Unregister Default File Manager routines (`CE_ElevatedActions.pas`,
  `CE_FileUtils.pas`).
