# CubicAdventurer: known issues, bugs and feature requests

This is the maintainer's working list. Reports from users arrive on the GitHub
[Issues](https://github.com/DerellLicht/CubicAdventurer/issues) page and are copied here
once confirmed. When an item is fixed, dropped or closed, move it to `HISTORY.md` (newest
first, with how it ended) and describe the fix in `CHANGELOG.md`.

Entry format: `CA-nnn  [bug|feature|task]  short title`, then a few lines of detail.
Numbers are never reused (highest used so far: CA-068). The exception is CA-051 to CA-059,
which were reused before 2026-10-30; `HISTORY.md` labels those.

Last updated: 2026-11-08 (version 1.01 in progress).

## Open bugs and gaps

(none at the moment)

## Checks still owed

- **CA-068 [task] Check the automatic theme preview pictures.** Implemented, not compiled.
  When Options > Display is built (or Options is reopened) and a theme has a skin file
  but no `.png` next to it, a window explains that preview pictures are being made, shows
  a sample window beside it, applies each such theme in turn, saves `<skin>.png` and
  restores the current theme; the Cancel button becomes Okay when done. Code is the new
  unit `Source/CE_SkinPreview.pas` (shared with `tools/SkinPreview`). Check: copy a `.skn`
  without its `.png` into the `Skins` folder of the installed program, restart, open
  Options > Display: the window appears, the picture is made and shown when the theme is
  selected; no window appears the next time. Also look at: Cancel part-way; the mouse
  pointer jumps onto the button; how disturbing the flicker is (Derell to judge; fallback
  idea: one Okay button per picture); pictures come out 340 x 372 like the batch ones.

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
