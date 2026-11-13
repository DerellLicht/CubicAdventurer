# CubicAdventurer: known issues, bugs and feature requests

This is the maintainer's working list. Reports from users arrive on the GitHub
[Issues](https://github.com/DerellLicht/CubicAdventurer/issues) page and are copied here
once confirmed. When an item is fixed, dropped or closed, move it to `HISTORY.md` (newest
first, with how it ended) and describe the fix in `CHANGELOG.md`.

Entry format: `CA-nnn  [bug|feature|task]  short title`, then a few lines of detail.
Numbers are never reused (highest used so far: CA-086). The exception is CA-051 to CA-059,
which were reused before 2026-10-30; `HISTORY.md` labels those.

Last updated: 2026-11-12 (version 1.04 in progress).

## Open bugs and gaps

(none at the moment)

## Checks still owed

(none at the moment)

## Wishlist

Nice-to-have ideas, taken up when there is no bug list to work on.

- **CA-082 [feature] Linked Multiple Windows ("derelict mode").** Not started; on Derell's
  think-about list (2026-11-11). A third mode in Options > General, beside Single Instance
  Only and Multiple Windows (a group box with three radio buttons replaces the single check
  box; the Options dialog may grow). Off by default; the other two modes stay as they are.
  In Linked mode the windows act as one program: Minimize on any window minimizes all (and
  restoring one restores all), the Close button closes all, and the next start brings back
  every window with its own session or tab set and position. It bypasses the On Startup
  and Tray settings. Needs a per-window record file, leader election at start, and a serial
  Exit All (one window at a time, so only one process writes the settings files). A
  preliminary spec with land-mines and open questions exists as `derelict_mode_spec.md`
  (kept outside the repo, in Derell's notes).

- **CA-085 [feature] Safer way to open a saved session (undecided).** Not started; Derell is not sure
  it matters (2026-11-12), and may be the only person it affects. Picking a session name in the
  Sessions menu loads it into the current window; Sessions > Open in New Window is a separate entry,
  and the two are easy to mix up (Derell did, during the CA-081 test). Ideas, cheapest first:
  (a) regroup or relabel the menu so the two look different (separator, heading), a few lines;
  (b) one submenu per session with "Open in this window" and "Open in New Window", so a click on a
  name never loads anything (small; the common case costs one more click, unless SpTBX allows a split
  item); (c) right-click on a session name for the same two choices (original idea; unknown whether
  Toolbar2000/SpTBXLib menu items report a right click, so a small test comes first; also hard to
  discover). Every place that lists sessions (menu, "Open in New Window" submenu, sessions toolbar)
  would need the same change.

## Deferred (not started)

- **CA-086 [bug] Turning the tray icon on disables the taskbar button's window previews.** Found by
  Derell on 2026-11-12 while testing CA-081. With the tray icon off and several windows open,
  hovering the CubicAdventurer taskbar button shows a preview of every window, and one can be
  clicked to pick it. With the tray icon on, the hover shows nothing at all, and the taskbar button
  is not drawn as active even when its window is. Derell did not click the button to see if anything
  else happens. Cause not investigated (the tray component, `TJvTrayIcon` with Visibility
  `tvVisibleTaskBar, tvVisibleTaskList`, is only a suspect, unverified). Derell decided on
  2026-11-12 to give up on the tray icon, which he finds of little use; if a user who relies on
  the tray reports this or feels strongly about it, take it up then. The tray icon itself still
  works for each window (tip, left click, menu).

- **CA-020 [feature] Language support.** Menus partly translate (sub-menus and some items
  do not). The Translate action and the PO (Portable Object, the gettext translation file
  format) editor code remain in the source; the menu items are removed. Take up when someone
  with another language asks. At that point also test loading and saving a shipped Locale `.po` in the PO translation editor (not reachable from
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

## Misc tasks

(none at the moment)

## Maintenance (internal)

(none at the moment)
