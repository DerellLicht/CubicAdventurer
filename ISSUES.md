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

- **CA-018 [bug] Options > Hotkeys page cleanup.** Done and confirmed 2026-10-26: list icons
  removed, group box captions fixed. Done, not tested (2026-10-26): Options dialog 80 px wider
  (only the Hotkeys page uses the room; the other pages keep their size), Hotkeys list and its
  two columns widened, "Swith" typo fixed in the action caption and all Locale files. Still
  open: (a) the child page Options > Hotkeys > Global (system-wide hotkeys, a working feature)
  repeats the whole action list, with icons and no keys assigned; the maintainer is deciding
  whether to delete it or just tidy it. (b) Audit result, waiting for the maintainer's OK: hide
  from the hotkey lists `act_tabs_menu`, `act_stack_open`, `act_stack_save`,
  `act_help_poedit_form` (no menu item since CA-020), `act_tabs_copyhere` and
  `act_tabs_movehere`; `act_view_archiver` is dead (invisible, no handler); move
  `act_help_restore_layout` to category View.

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
  `Options.inc` / `Compilers.inc` stubs.
