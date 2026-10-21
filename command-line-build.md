# Command-line build of CubicAdventurer (Delphi 13 Community Edition)

Status: **untested**. Everything here is based on what we know about the install, not on a build that has actually run. Test steps 1-3 first and send me the output.

## What we know
- Delphi 13 CE, IDE version 37.0, 32-bit target (Win32) only.
- `dcc32.exe` and `dcc64.exe` ARE present in `C:\Program Files (x86)\Embarcadero\Studio\37.0\bin` (checked). The Community Edition might not license command-line use of the compiler, but the files are there; try it.
- Project: `Source\CubicAdventurer.dproj`. Default config is `Debug`, platform `Win32`.
- The exe lands in the repo root (`DCC_ExeOutput` = `..`), DCUs in `..\dcu`.
- `7z.dll` sits next to the exe (repo root).
- Library paths for the third-party packages (VirtualTreeView, SpTBX, JVCL, Mustangpeak, Graphics32, SynEdit, PngComponents, Toolbar2000, JCL) are stored per-user by the IDE, and MSBuild reads the same settings, so they should carry over. The JVCL `resources` folder must be in the Library path (for JvConsts.res).
- msbuild candidates on your machine:
  - `D:\Microsoft Visual Studio\MSBuild\Current\Bin` (VS 2026)
  - `C:\Program Files\dotnet\sdk\10.0.401` (the dotnet SDK)
  - Delphi's own `rsvars.bat` selects the .NET Framework one (`C:\Windows\Microsoft.NET\Framework\v4.0.30319`). **Use that one first.** The dotnet SDK flavor is the wrong one for Delphi targets.

## Step 1: first test (plain Command Prompt, IDE closed)
```
call "C:\Program Files (x86)\Embarcadero\Studio\37.0\bin\rsvars.bat"
cd /d D:\SourceCode\Git\CubicAdventurer\Source
msbuild CubicAdventurer.dproj /t:Build /p:Config=Debug /p:Platform=Win32 /v:minimal
```
Close the IDE first so no files are locked and no stale editor buffers get involved.

## Step 2: what to look at
- Does `rsvars.bat` print anything odd? (It just sets environment variables.)
- Does msbuild start? `msbuild /version` after the `call` line shows which one you got.
- Do you get compile errors? If so, copy the first screenful. Expected first-try problems: a missing library path (F1026/F2613 "unit not found"), or a licensing message from dcc32.
- Does the exe appear in the repo root with a new timestamp?

## Step 3: if msbuild gives trouble
Paths/environment problems are fixable. If the compiler refuses to run at all (licensing), tell me the exact message; fallbacks are:
1. Drive the IDE from a script (`bds.exe` has a build switch, to be verified on your install).
2. Keep the IDE for compiling and use a Makefile only for the surrounding steps (version stamping, packaging, tagging).

## Step 4: what I'll write once it works
- A Python wrapper (your preference over .cmd): runs `rsvars.bat`, calls msbuild, shows only warnings and errors, returns a proper exit code.
- A Makefile in your usual style: `make` (Debug), `make release`, `make clean`, `make warnings`.
- Later: the wrapper reads the version from `CHANGELOG.md` and writes it into the `.dproj` (`VerInfo_MajorVer/MinorVer/Release/Build`, `FileVersion`, `ProductVersion`).

## Useful extra switches
- Release build: `/p:Config=Release`
- Full rebuild: `/t:Rebuild`
- Clean: `/t:Clean`
- Save the log: `/fl /flp:logfile=build.log;verbosity=normal`
- Only warnings and errors: `/clp:WarningsOnly;ErrorsOnly` (or `/v:q`)

## Cautions
- Don't build from the IDE and the command line at the same time.
- `Config`/`Platform` must match what the dproj defines (Debug/Release, Win32).
- Command-line builds do NOT rewrite the `.res` files for the form designer, but they do compile `CE_Resources.rc` into `CE_Resources.res` only if the `.dproj` lists it; today the `.dpr` just links the committed `CE_Resources.res`. Resource-compiler paths in `CE_Resources.rc` point at `..\BuildCE\Snapshot_configs\*.xml`, and `settings.xml` currently exists only under `Official\` and `Snapshot\` subfolders, so don't re-run the resource compiler without fixing that path.
