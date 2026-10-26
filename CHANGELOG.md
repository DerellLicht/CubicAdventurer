# CubicAdventurer Changelog

## [0.98] - 2026-10-25
- History now keeps the last 30 entries by default (was 10).
- Made various improvements to the Sessions engine
- Added: third-party notices file (authors and licenses of the libraries used), kept in the repository (not installed)
- Added: attribute background colors (System, Read-only, Hidden) now also show in the Icon, Thumbnail and Tile views
- Added: background colors for file extensions (Options > Display > Fileview > Colors)
- Added: the address bar now suggests matching folder names as you type, like Windows Explorer
- Removed: the "And Launch Files" and "Launch Files Only" choices under Bookmarks > Open All in Tabs (which still opens every folder bookmark in tabs)
- Fixed: `layout.xml` no longer collects thousands of blank lines (existing files are cleaned when loaded)

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
