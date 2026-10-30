# CubicAdventurer Changelog

## [0.99] - 2026-10-30
- Fixed: a folder view sometimes stopped showing new or renamed files until you pressed F5 (mostly the Downloads folder; the browser's temporary name stayed on screen). The library mixed up which view a folder-change signal belonged to; each signal now reaches its own view
- Fixed: the closed Workspace panel no longer watches the Desktop folder in the background until you open it
- Changed: folder names in the Folders panel now use the same font size as the file list, and the rows grow with the font so letters like g and y are no longer cut off
- Fixed: top-level labels in the Folders panel (Desktop, This PC, ...) now use the Folder text color instead of staying dark on a dark background
- Changed: with Options > General > "Show Path in Title bar" off, the title bar and taskbar now show "CubicAdventurer v0.99" (the running version) instead of "CubicExplorer"; the tray icon tooltip and the startup text also say CubicAdventurer

## [0.98] - 2026-10-26
- History now keeps the last 30 entries by default (was 10).
- Made various improvements to the Sessions engine
- Changed: only one CubicAdventurer window runs at a time; starting it again brings the existing window forward (the Single Instance option and File > New Window are gone)
- Removed: the Default File Manager Register / Unregister buttons
- Added: the Hotkeys page now tells you, as you press a key combination, whether it is free or which command already uses it
- Cleaned up the Hotkeys page (wider, no icons, commands that cannot take a hotkey are hidden, Global page removed) and the Customize > Buttons page (clearer instructions)
- Added: a Tips and Tricks guide (bookmarks, sessions, the Workspace panel, toolbar buttons, hotkeys), linked from the Start Menu
- Added: third-party notices file (authors and licenses of the libraries used), kept in the repository (not installed)
- Added: attribute background colors (System, Read-only, Hidden) now also show in the Icon, Thumbnail and Tile views
- Added: background colors for file extensions (Options > Display > Fileview > Colors)
- Added: the address bar now suggests matching folder names as you type, like Windows Explorer
- Removed: the "And Launch Files" and "Launch Files Only" choices under Bookmarks > Open All in Tabs (which still opens every folder bookmark in tabs)
- Fixed: `layout.xml` no longer collects thousands of blank lines (existing files are cleaned when loaded)
- Fixed: selected folders now keep the folder text color instead of turning black
- Added: the Folders tree now uses the file view's background, folder text, System / Read-only / Hidden colors and Unicode fallback font
- Fixed: the tray icon options (Minimize to tray, Close to tray, Start minimized to tray) could hide the window with no way to bring it back; clicking the tray icon now restores it
- Changed: the tray icon menu now offers "Show main window" and Exit (the bookmarks list is gone)
- Removed: the separate Breadcrumb Navigation toolbar (the Address Bar already shows breadcrumbs)
- Changed: the Filters and Stacks entries in the Toolbars list are now labeled "(panel toolbar)", since they only show or hide the button strip inside those panels
- Changed: new installations start with a simple Explorer-style layout (the Folders panel on the left, the file list on the right); the other panels can be opened from the View menu

## [0.97] - 2026-10-24
- Initial release (beta)
- Fixed: range-check error when listing `.png` files in Thumbnail mode
- Fixed: Options > Tabs "Auto fit tabs" worked backwards; it is now "Fit tabs to labels" and checked by default
- Added demo program image to README file
- Fixed: shortcut (`.lnk`) files were always shown without their extension; they now follow "Show file extensions"
- Changed: the tooltip of a shortcut shows the full path of its target
- Fixed: Bookmarks panel entries showed two icons
- Added: bookmarks can be re-arranged by dragging them in the Bookmarks panel, and a folder tab can be dragged onto the panel to bookmark its folder

FIRST CUBICADVENTURER RELEASE: A REVIVAL OF CUBICEXPLORER 0.96.0.1582 (MARKO SAVOLAINEN)
FOR CURRENT WINDOWS AND DELPHI 13 (WIN32). YOUR EXISTING CUBICEXPLORER SETTINGS,
layout and sessions files load.

### Added
- Folder text color, plus background colors for System, Read-only, Hidden and
  combined-attribute files (Tools > Options > Display > Fileview > Attributes).
- Fallback font for file names with characters the main font lacks (CJK, symbols).
- New About banner and credits.

### Changed
- The program is now Unicode throughout (the old TNT Unicode Controls are gone).
- Settings files ignore keys they do not know and keep defaults for missing ones.
- The dock layout (floating panels) restores correctly after a restart.
- The text editor works with the current SynEdit; syntax highlighting uses the
  highlighters' default colors.
- Help menu trimmed to what works. Version numbers are now `X.YY`.
- "Show hidden files" and "Show file extensions" moved from the View menu to
  Tools > Options > Display > Fileview > Options.
- "Restore Default Layout" moved from the Help menu to the bottom of the View menu.

### Removed
- Update check, donate and web-site menu items, Version Manager and Translate menu items

### Known limitations
- Win32 only, and not yet DPI-aware.
- English only for now; language support is not re-enabled yet.
