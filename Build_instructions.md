# Building CubicAdventurer (2026)

How to assemble the tools and libraries and build CubicAdventurer from source with
**Embarcadero Delphi 13 Florence, Community Edition**. Win32 only for now.

> **DRAFT.** Items marked **[CONFIRM]** were written from notes and need checking against a
> machine that has actually built the project. Library versions are those used for the first
> release.

## What you need

- Windows 10 or 11 and **Delphi 13 Florence Community Edition** (IDE version 37.0). It must be
  installed and registered.
- Git.
- The third-party libraries below. The original author's dependency list is in
  `Compiling_Instructions.txt`; it is out of date, so use this file.
- Only for packaging a release: GNU make (Cygwin; *not* Delphi's own `make.exe`), Python 3,
  Inno Setup 7 and the `gh` command-line tool. See "Packaging" at the end.

## Get the source

```
git clone https://github.com/DerellLicht/CubicAdventurer.git
```

Work on the `master` branch. The project file is `Source\CubicAdventurer.dproj`
(`CubicAdventurer.dpr` is its main source).

## Libraries

| Library | Source | How it was installed |
|---|---|---|
| Virtual Treeview 8.3 | GetIt | GetIt, built-in installer |
| Mustangpeak Common Library and ListView / VirtualShell (the shell and file-list components) | GetIt | GetIt, built-in installer. **[CONFIRM exact GetIt package names]** |
| SynEdit | GetIt | GetIt, built-in installer |
| JCL | GetIt (source only) | **Manual build**, see below |
| JVCL | GetIt (source only) | **Manual build**, see below |
| Toolbar2000 (TB2K) and SpTBXLib | GitHub (SilverpointDev/sptbxlib for SpTBX) | **Manual**, see below |
| Graphics32 | GitHub (graphics32/graphics32) | Manual. **[CONFIRM packages and paths]** |
| PngComponents | GitHub (UweRaabe/PngComponents) | Manual. **[CONFIRM packages and paths]** |

Components that ship inside the repo (CEAction, fcl-xml, DirectX headers, CubicCore, and the
patched Mustangpeak copies under `Source\Components`) need no installation.

Everything is installed for the **Win32** platform only.

### The Community Edition caveat (JCL and JVCL)

The Community Edition cannot run Delphi's command-line compiler. GetIt's installers for JCL and
JVCL therefore fail with "does not support command line compiling" **and still report
success**, so the "installed" label in GetIt is not reliable for them. GetIt only downloads the
source into its `CatalogRepository` folder. Build the packages by hand in the IDE from the group
projects as below.

### JCL

1. In GetIt, install JCL (this only downloads the source).
2. In the JCL source folder, copy `source\include\jcl.template.inc` to `jcld37win32.inc`.
3. Open `packages\JclPackagesD370.groupproj` in the IDE and choose Build All.
4. Add these to the Win32 Library path (Tools > Options > Language > Delphi > Library):
   `lib\d37\win32`, `source\include`, `source\common`, `source\windows`, `source\vcl`
   (each relative to the JCL folder, or give full paths).

### JVCL

1. In GetIt, install JVCL (source only).
2. Open `packages\D37 Packages.groupproj` and choose Build All (large: about 3 million lines;
   it takes a while).
3. Install the design-time packages. **[CONFIRM which packages and in what order]**
4. Add the JVCL `resources` folder to the Win32 Library path. Without it the build fails on
   `JvConsts.res`. Add the other JVCL source and library folders as well.
   **[CONFIRM the exact list]**

### Toolbar2000 and SpTBXLib

1. Get Toolbar2000 and apply its "TB2K Patch" step (SpTBXLib requires it).
2. Build and install the packages `tb2k_d12` and `tb2kdsgn_d12`.
3. Get SpTBXLib (it needs Delphi XE2 or newer; it works with Delphi 13) and build and install
   `SpTBXLib` and `SpTBXLibDsgn`.
4. Add both source folders to the Win32 Library path.

### Graphics32 and PngComponents

**[CONFIRM]** Both were installed by hand from their GitHub sources. List here the packages
built and the folders added to the Library path.

## Build the program

1. Open `Source\CubicAdventurer.dproj` in the IDE.
2. Make sure the target is **Win32**. Choose the **Debug** or **Release** configuration.
   Debug defines `DEBUG` and turns range checking on. Release defines `RELEASE` and leaves
   range checking off.
3. Build (Shift+F9). If the compiler shows errors that look stale after pulling changes, use
   Project > Build (not Compile) and close all files first (File > Close All).
4. The exe lands in the **repository root** (`CubicAdventurer.exe`) and the compiled units in
   `dcu\` next to it. `7z.dll` must sit beside the exe; it is in the repo root already.

Notes:

- Do not save forms in the IDE if the toolbar components cannot load (a message about
  `TCEToolbar`, `TCEToolbarAction` or `TPngImageList` means the libraries are not installed
  correctly yet). Saving then would damage the `.dfm` files.
- If you run from the IDE, the program keeps its settings next to the exe (there is no
  `settings.path` in the repo root); `settings.xml`, `layout.xml` and `sessions.xml` are
  created there and are ignored by git.
- The installed program reads its settings from `%APPDATA%\CubicAdventurer\`, controlled by
  `settings.path` in its folder (see `installer\settings.path`).

## Troubleshooting

- **A library unit is "not found" (F1026 or F2613):** its source folder is missing from the
  Library path, or only the package was built and the paths were never added.
- **`JvConsts.res` not found:** add the JVCL `resources` folder to the Library path.
- **JCL or JVCL "installed" in GetIt but nothing works:** see the Community Edition caveat above.
- **Unexpected errors right after `git pull`:** File > Close All (answer No to save prompts),
  then Build.

## Packaging a release

The program itself is built in the IDE. A `Makefile` handles the rest (GNU make required):

1. Put the new version at the top of `CHANGELOG.md` (`## [x.yy] - YYYY-MM-DD`).
2. `make sync-version` writes that version into the project file.
3. Rebuild in the IDE (Shift+F9). `make check` verifies the exe carries the version.
4. `make dist` builds the Inno Setup installer and zips it (output in `installer\output\`).
5. `make release` tags the release, pushes the tag and creates the GitHub release.

Run `make help` for the other targets.
