# CubicAdventurer: known issues, bugs and feature requests

This is the maintainer's working list. Reports from users arrive on the GitHub
[Issues](https://github.com/DerellLicht/CubicAdventurer/issues) page and are copied here
once confirmed. When an item is fixed, dropped or closed, move it to `HISTORY.md` (newest
first, with how it ended) and describe the fix in `CHANGELOG.md`.

Entry format: `CA-nnn  [bug|feature|task]  short title`, then a few lines of detail.
Numbers are never reused (highest used so far: CA-084). The exception is CA-051 to CA-059,
which were reused before 2026-10-30; `HISTORY.md` labels those.

Last updated: 2026-11-12 (version 1.04 in progress).

## Open bugs and gaps

(none at the moment)

## Checks still owed

CA-069, CA-071, CA-072 and CA-073 were confirmed on 2026-11-09, CA-017 and CA-074 to CA-080 on
2026-11-11, and CA-070 on 2026-11-12 (see `HISTORY.md`). CA-081 is left from Derell's own use of
several windows.

- **CA-083 [task] Test: the tray icon tip.** Fixed 2026-11-12 (version 1.04), needs Derell's test.
  With the tray icon on, hover it: with Show Path in Title bar off the tip is the window title
  ("Entertain Me - CubicAdventurer v1.04", or without the session name for a plain tab set) and follows
  Sessions changes; with the option on the tip is `CubicAdventurer: <path>` and follows the folder.
  Turning the option on and off in Options must switch the tip at once. Windows limits the
  length of a tip, so a very long path may be cut off.

- **CA-084 [task] Test: the tray menu "Show / Hide main window".** Done 2026-11-12 (version 1.04), needs
  Derell's test. Right-click the tray icon: the first item reads "Hide main window" while the window is
  visible and "Show main window" while it is minimized or hidden, and does the same as a left click on
  the icon (hide or minimize, then restore). Derell chose this over removing the item, even though he
  finds the tray icons of little use.

- **CA-081 [task] Test: the tray with several windows, including Exit All.** With the tray icon on
  and Single Instance Only off, open two or three windows: each shows its own tray icon; use Close to
  tray and Minimize to tray in one window and in several, restore from the tray, and run File > Exit All
  (and Exit from the tray menu) while some windows are hidden in the tray. All windows must close and
  save, and no tray icon may be left behind. The tray was a source of trouble before (CA-054), so
  report anything odd.

  Tested 2026-11-12 by Derell with Minimize to Tray on: two windows (`standard`, then Sessions > Open in
  New Window > "Entertain Me") gave two taskbar buttons with the session names and two tray icons; left
  click on a tray icon toggles its window; File > Exit All with both windows open closed both, and the
  next start opened `standard`. It works. Two follow-ups were filed (CA-083, CA-084). Not explained: on
  the first try "Entertain Me" replaced `standard` and only one window stayed open; the same steps
  worked the second time and it has not come back. If it does, note whether Single Instance Only was
  on and send a DbgView log. Not tested: different tray settings in different windows (Derell
  skipped it: changing Options with several windows open is not supported, and the expected behavior
  is not defined). Kept open until Derell calls it done.

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

## Misc tasks

(none at the moment)

## Maintenance (internal)

(none at the moment)
