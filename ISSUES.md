# CubicAdventurer: known issues, bugs and feature requests

This is the maintainer's working list. Reports from users arrive on the GitHub
[Issues](https://github.com/DerellLicht/CubicAdventurer/issues) page and are copied here
once confirmed. When an item is fixed, delete it from this file and describe the fix in
`CHANGELOG.md`; git history keeps the rest.

Entry format: `CA-nnn  [bug|feature|task]  short title`, then a few lines of detail.
Numbers are never reused.

Last updated: 2026-10-26 (version 0.98 in progress).

## Open bugs and gaps

- **CA-012 [bug] Docking a floating panel back** only triggers when its center reaches
  the program window edge (probably JVCL drop-zone logic).
- **CA-016 [feature] Text editor.** No highlighter-settings editor (highlighters use
  SynEdit default colors). Alt-drag column selection not re-checked (probably
  `eoAltSetsColumnMode` missing from Options). Combo box SkinType TODO in
  `CE_ToolbarEditorItems.pas` (about line 1067), cosmetic. Tab strip gap would mean
  changing `CE_SpTabBar.pas`.
- **CA-017 [bug] Dock layout hardening.** `DoUnAutoHideDockForm` bypasses the dock-chain
  guard; only root-level floating hosts are pre-created. Optional proper fix: derive
  `TCEDockInfoZone` with a wide `TFormBorderStyle` property (the `{$R-}` interim in
  `CE_DockInfo.pas` stays until then). Wait for a user report before spending time here.

- **CA-018 [bug] Options > Hotkeys page needs a cleanup.** The list is built from every
  action in `dCE_Actions` (`fCE_OptionsPage_Hotkeys.pas`), so obsolete actions show up,
  especially under Help and Tools (and probably other categories). Many rows show the
  same icon (they just echo each action's `ImageIndex`, which many actions share), and
  the Name column (142 px wide, plus the icon) truncates captions to the point of
  being meaningless. Plan: (1) audit the actions and hide or delete the dead ones,
  (2) drop the icons from the list (and the title label) or at least from the tree,
  (3) widen the Name column or the whole page. Also check the category of
  `act_help_restore_layout`, which is now in the View menu.

## Wishlist

Nice-to-have ideas, taken up when there is no bug list to work on.

- **CA-052 [feature] New-user document (Quick Start or Tips and Tricks).** Do not put
  usage hints in `README.md` (it is already long, and hints there are a slippery slope).
  Proposed instead: a short new-user document shipped with the program and linked from
  the Start Menu, e.g. `Quick_Start.md` or `Tips_and_Tricks.md`, that would cover the
  features people tend to miss. Content and name still to be discussed with the
  maintainer, so nothing is written yet. It would need an installer entry
  (`installer/CubicAdventurer.iss`: file, Start Menu icon) and can follow
  `Documents/Bookmarks_and_Sessions.md` as a model.

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

- **CA-053 [task] Test the Folders tree colors.** The tree now uses the file view's folder
  text color, System / Read-only / Hidden backgrounds and the glyph fallback font
  (`CE_FolderTree.pas` `DoPaintText` / `DoBeforeCellPaint`; shared lookups in
  `CE_FileViewColors.pas`). Not compiled yet. Check: colors and attribute backgrounds show
  in the tree (including `ProgramData`), text stays readable on the tree's background
  (the folder color was chosen for the file view), selected nodes look right, the
  background bar fits the label, and the address-bar / breadcrumb folder popups still
  draw. A color change in Options probably shows in the tree only after a repaint
  (scroll or refresh). Also unexplained: on 2026-10-26 a Unicode folder name showed boxes
  in the file view but correctly in the tree; not reproduced since.
- **CA-054 [task] Test folder colors on selected items.** Select a mix of files and
  folders (focused and unfocused list): folders should keep the Folder text color like
  files keep their extension colors, not turn black. Not compiled yet. If the contrast on
  the selection bar is poor, say so and the old rule (selection color) can come back.
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
