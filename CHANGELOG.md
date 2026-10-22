# Changelog

The newest `## [x.yy]` header below is the version of the program: the Makefile reads it
for the installer, the tag and the GitHub release (`make version`), and
`make sync-version` copies it into the Delphi project.

## [1.00] - unreleased

First CubicAdventurer release: a revival of CubicExplorer 0.96.0.1582 (Marko Savolainen)
for current Windows and Delphi 13 (Win32). Your existing CubicExplorer settings,
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
- Update check, donate and web-site menu items.

### Known limitations
- Win32 only, and not yet DPI-aware.
- English only for now; language support is not re-enabled yet.
