# CubicAdventurer: known issues, bugs and feature requests

This is the maintainer's working list. Reports from users arrive on the GitHub
[Issues](https://github.com/DerellLicht/CubicAdventurer/issues) page and are copied here
once confirmed. When an item is fixed, delete it from this file and describe the fix in
`CHANGELOG.md`; git history keeps the rest.

Entry format: `CA-nnn  [bug|feature|task]  short title`, then a few lines of detail.
Numbers are never reused.

Last updated: 2026-10-27 (version 0.98 in progress).

## Open bugs and gaps

- **CA-052 [bug] Tab strip gap.** Fixing it means changing `CE_SpTabBar.pas`. A `TODO` at
  `TCESpTabToolbar.RightAlignItems` notes that the custom `InternalDrawBackground`
  override was removed in favor of SpTBXLib's own drawing; revisit if tab borders look
  wrong. Needs a description or screenshot of the gap before work starts.
- **CA-053 [task] Toolbar combo box SkinType (cosmetic).** `TODO(revival)` in
  `CE_ToolbarEditorItems.pas` (about line 1067): `TSpTBXComboBox` no longer has
  `SkinType` in the current SpTBXLib, so the line is commented out. Check whether the
  combo box looks wrong under any skin; if not, delete the TODO.
- **CA-017 [bug] Dock layout hardening.** `DoUnAutoHideDockForm` bypasses the dock-chain
  guard; only root-level floating hosts are pre-created. Optional proper fix: derive
  `TCEDockInfoZone` with a wide `TFormBorderStyle` property (the `{$R-}` interim in
  `CE_DockInfo.pas` stays until then). Wait for a user report before spending time here.

## Checks still owed

- **CA-054 [task] Tray icon options, remaining checks.** Minimize to tray, Close to tray
  and Start minimized to tray were confirmed working on 2026-10-27. Still to check (not
  compiled, untested): right-click on the tray icon shows "Show main window" (bold) and
  Exit, and Show main window restores the window; restoring from the tray after the window
  was maximized returns it maximized; starting the exe again while the window is hidden
  brings it back; unchecking Show while hidden restores the window.
- **CA-030 [task] Settings loaders and old files.** `TCEAppSettings` is verified to
  ignore unknown keys and default missing ones. The other loaders (toolbar buttons, dock
  layout, sessions, `TCECustomSettingStorage` descendants) have not been reviewed for that
  policy.
- **CA-031 [task] Settings save check after the UTF-8 changes.** Change a few options
  (ideally one with a Unicode value, such as a bookmark name), exit, relaunch, and confirm
  they persisted. (The PO translation editor can no longer be reached from the menus; test
  loading and saving a shipped Locale `.po` in it under CA-020, when language support is
  taken up.)

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
  are removed. Take up when someone with another language asks.
- **CA-021 [feature] Win64 build.**
- **CA-022 [feature] DPI awareness** (users report it is missing).
- **CA-023 [feature] Move to a free toolchain (Lazarus / Free Pascal).** Decided to do
  this in a new thread after the Delphi release is stable. Core code is portable; the hard
  parts are SpTBX/Toolbar2000, the Mustangpeak shell components and JVCL docking.

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
