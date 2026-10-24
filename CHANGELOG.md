# CubicAdventurer Changelog

## [0.97] - 2026-10-23
- Initial release (beta)
- Fixed: range-check error when listing `.png` files in Thumbnail mode
- Fixed: Options > Tabs "Auto fit tabs" worked backwards; it is now "Fit tabs to labels" and checked by default
- Added demo program image to README file
- Fixed: shortcut (`.lnk`) files were always shown without their extension; they now follow "Show file extensions"
- Changed: the tooltip of a shortcut shows the full path of its target
- Fixed: Bookmarks panel entries showed two icons
- Changed: in the Bookmarks panel a single click only selects; a double-click opens the bookmark (Options > Display > Bookmarks > Single click mode still opens with one click, and then only when the mouse button is released, so dragging a bookmark never opens it)
- Fixed: the Bookmarks menu was empty until the first bookmark was added, when no bookmarks file existed yet
- Added: Bookmarks menu item "Bookmark current folder", which adds the active tab's folder without opening the Bookmarks panel

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
