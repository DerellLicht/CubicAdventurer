# CubicAdventurer Changelog

## [1.00] - 2026-10-23
- Initial release
- Fixed: range-check error when listing `.png` files in Thumbnail mode

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

### Removed
- Update check, donate and web-site menu items

### Known limitations
- Win32 only, and not yet DPI-aware.
- English only for now; language support is not re-enabled yet.
