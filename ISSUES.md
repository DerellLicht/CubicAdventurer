# CubicAdventurer: known issues, bugs and feature requests

This is the maintainer's working list. Reports from users arrive on the GitHub
[Issues](https://github.com/DerellLicht/CubicAdventurer/issues) page and are copied here
once confirmed. When an item is fixed, delete it from this file and describe the fix in
`CHANGELOG.md`; git history keeps the rest.

Entry format: `CA-nnn  [bug|feature|task]  short title`, then a few lines of detail.
Numbers are never reused.

Last updated: 2026-10-25 (version 0.98 in progress).

## Open bugs and gaps

- **CA-010 [feature] Attribute background colors in Tiles and Thumbnails views.** The
  System / Read-only / Hidden / Combined backgrounds only render in Report, List and
  SmallIcon views. Text colors work in every view. Possible fix: add `elsTile` and
  `elsThumbnail` view-item subclasses in `CE_FileViewColors.pas` the same way (class
  names `TEasyViewTileItem` / `TEasyViewThumbnailItem` are unverified against the
  installed library). Filmstrip behaves like the original CubicExplorer and is accepted.
- **CA-011 [bug] File view does not auto-update when files are added** (new downloads
  appear only after F5; the original CubicExplorer did the same). Suspect:
  `TCEFileView.SetNotifyFolder` (`CE_FileView.pas`, around line 1413) sets a directory
  watch only when `GetDriveType(NameForParsing) = DRIVE_FIXED`; a known-folder item gives
  a `::{GUID}` name, so the test fails. Tests: open Downloads by typed path and download
  a file; `copy nul x.txt` in a typed-path folder. Likely fix: resolve to the real
  filesystem path first.
- **CA-012 [bug] Docking a floating panel back** only triggers when its center reaches
  the program window edge (probably JVCL drop-zone logic).
- **CA-014 [bug] `layout.xml` holds about 2000 blank indentation-only lines** in the
  FileView toolbar section. Harmless.
- **CA-015 [bug] Folder text color is not applied to selected items**, and the Folders
  tree and other panels get neither the folder/attribute colors nor the glyph fallback
  font. The fallback also still boxes astral characters (some emoji), and a whole name
  switches font at once.
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

- **CA-056 [feature] Merge the Save Session and Manage Sessions dialogs.** With the unused
  Save/Load Settings group gone, Manage (list, name, automatic-save check box, Delete) and
  Save (name combo, automatic-save check box) overlap. One dialog could list the sessions,
  take a name, hold the check box, and have Save, Delete and Close buttons. Not urgent;
  needs a form redesign that should be checked on screen.
Nice-to-have ideas, taken up when there is no bug list to work on.

- **CA-051 [feature] "Add to Bookmarks" in the file view's right-click menu** (for
  folders, and perhaps for the current folder in the List view). Partly done 2026-10-24:
  the Bookmarks menu now starts with **Bookmark current folder**, so a bookmark can be
  added without opening the panel. Still open: the right-click entry. The item context
  menu is the standard Explorer shell menu; adding an entry means hooking the menu-building
  code in the file view (insert our own item into the shell menu before it is shown) and
  may not be practical for every menu. A toolbar button and a hotkey were considered and
  rejected as too hidden (toolbars are often off; a hotkey is as invisible as the panel).
- **CA-052 [feature] Make Bookmarks easier to discover.** Related to CA-051. Do not put
  usage hints in `README.md` (it is already long, and hints there are a slippery slope).
  Proposed instead: a short new-user document shipped with the program and linked from
  the Start Menu, e.g. `Quick_Start.md` or `Tips_and_Tricks.md`, that would cover Bookmarks
  among other features. Maintainer's own experience: he went years without finding Bookmarks, and they now replace
  his habit of keeping rarely used folders open in tabs. Content and name still to be discussed with the maintainer, so
  nothing is written yet. It would need an installer entry (`installer/CubicAdventurer.iss`:
  file, Start Menu icon) and can follow `Documents/Bookmarks_and_Sessions.md` as a model.

- **CA-050 [feature] Background color for selected extensions.** On Tools > Options >
  Display > Fileview > Colors, add a "Background color" checkbox. When it is checked,
  enable a second extension list with its own color selection box, identical to the
  existing extension-color one (the existing one sets the text color). Use case, from
  the maintainer's `ndir32` directory lister: make files that "should stand out" show
  up, mainly `.bak`, plus rarer ones such as `.err`. Probable approach: reuse the
  attribute-background mechanism in `CE_FileViewColors.pas` (view-item subclasses) and
  the extension-list handling in `fCE_FileView.AssignExtensionColors`. Remember the
  settings policy: new properties get constructor defaults, and old `settings.xml`
  files must still load. Backgrounds only render in Report, List and SmallIcon views
  (see CA-010).

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
- **CA-043 [task] `command-line-build.md`** is obsolete (Delphi Community Edition cannot
  compile from the command line): update it or retire it.
