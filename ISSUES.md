# CubicAdventurer: known issues, bugs and feature requests

This is the maintainer's working list. Reports from users arrive on the GitHub
[Issues](https://github.com/DerellLicht/CubicAdventurer/issues) page and are copied here
once confirmed. When an item is fixed, delete it from this file and describe the fix in
`CHANGELOG.md`; git history keeps the rest.

Entry format: `CA-nnn  [bug|feature|task]  short title`, then a few lines of detail.
Numbers are never reused.

Last updated: 2026-10-27 (version 0.98 in progress).

## Open bugs and gaps

(none at the moment)

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

- **CA-041 [task] Vendor the hand-installed libraries** (Graphics32, PngComponents,
  SpTBXLib, Toolbar2000) into the repo, as the original did. Open decision (2026-10-27):
  vendoring does not remove the need to build and install the design packages; its only
  gain is pinned, known-good versions (mainly Toolbar2000 with the SpTBX patch applied).
  Options: drop the ticket and record exact versions in `Build_instructions.md`, or vendor
  only Toolbar2000 and SpTBXLib. Check each licence allows redistribution first. The old
  `Components/PngComponents` copy was removed on 2026-10-27 (it was not the Raabe fork).
  If vendored, Mustangpeak VirtualShellTools (manual git clone) belongs on the list too.
  `git ls-remote` reached graphics32, sptbxlib, PngComponents and VirtualShellTools on
  2026-10-27 (cloning not tried). Toolbar2000 is not on GitHub. Pin the exact versions
  Derell builds with, not whatever is newest.
- **CA-042 [task] `.gitattributes` / line endings: decision.** The repo has mixed line
  endings (some files are mixed inside one file). Leaning towards leaving them alone, since
  normalising would damage the mixed files and make blame noisy. Only option considered:
  a `.gitattributes` with `* -text`, to be tested with git first.
- **CA-057 [task] Stale `Components\fcl-xml` on Derell's disk.** Not in git (the live copy
  is `Source/Components/fcl-xml`). If the folder exists in his working copy, he deletes it.
- **CA-056 [task] Review `BuildCE/`.** Old batch files, NSIS installer scripts and
  `dxgettext` tools from the original author's SVN snapshot flow, probably replaced by
  the Makefile and Inno Setup flow. Open them, check nothing uses them, then delete or keep.
