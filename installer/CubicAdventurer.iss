; Inno Setup script for CubicAdventurer.  Modeled on the dlGrep installer.
; Build it with "make installer" (which checks that CubicAdventurer.exe was built with the
; version from CHANGELOG.md and passes that version in), or compile it by hand:
;   D:\InnoSetup7\iscc.exe /DMyAppVersion=1.00 installer\CubicAdventurer.iss
; The exe is built in the Delphi IDE (Shift-F9) and lands in the repo root.
; Output: installer\output\CubicAdventurerV<version>.setup.exe

#define MyAppName "CubicAdventurer"
; Name shown in the Start Menu and on the desktop (file and folder names keep no space).
#define MyAppDisplayName "Cubic Adventurer"
#define MyAppPublisher "Derell Licht"
#define MyAppURL "https://github.com/DerellLicht/CubicAdventurer"
#define MyAppExeName "CubicAdventurer.exe"
#define DoubleAmp(Value) StringChange(Value, "&", "&&")
; the folder that holds the repo (this script lives in <RepoRoot>\installer)
#define RepoRoot AddBackslash(SourcePath) + ".."
; The version is set only in CHANGELOG.md; the Makefile passes it in as /DMyAppVersion=x.yy.
#ifndef MyAppVersion
#error MyAppVersion is not defined: build with "make installer", or pass /DMyAppVersion=x.yy (the newest version in CHANGELOG.md)
#endif

[Setup]
; NOTE: AppId uniquely identifies this program; never reuse it for another one.
AppId={{6D3B8624-167A-4CCE-8A31-A0CFF8A41FAE}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}
; Per-user install: {autopf} becomes %LocalAppData%\Programs, so there is no UAC prompt.
; The folder page is shown, so another folder can be chosen.
PrivilegesRequired=lowest
DefaultDirName={autopf}\{#MyAppName}
DisableDirPage=no
DefaultGroupName={#MyAppDisplayName}
UninstallDisplayIcon={app}\{#MyAppExeName}
; CubicAdventurer is a 32-bit (Win32) program, so there is no ArchitecturesAllowed line:
; it installs on 32-bit and 64-bit Windows alike.
LicenseFile={#RepoRoot}\Documents\License.txt
OutputDir=output
OutputBaseFilename={#MyAppName}V{#MyAppVersion}.setup
SolidCompression=yes
WizardStyle=modern slate
; close a running CubicAdventurer before replacing its files, and restart nothing
CloseApplications=yes
RestartApplications=no

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
; The program, its helper library (7-zip, for archives), and the folders it reads at run time.
Source: "{#RepoRoot}\{#MyAppExeName}"; DestDir: "{app}"; Flags: ignoreversion
Source: "{#RepoRoot}\7z.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "{#RepoRoot}\Skins\*"; DestDir: "{app}\Skins"; Flags: ignoreversion recursesubdirs createallsubdirs
Source: "{#RepoRoot}\Locale\*"; DestDir: "{app}\Locale"; Flags: ignoreversion recursesubdirs createallsubdirs
; The default layout and settings are built into the exe (Source\Defaults), so no XML files
; are installed here: a new user gets them until the program writes its own copies.
; Where settings live: %APPDATA%\CubicAdventurer (see the comments in the file).  Delete this
; file from the install folder to keep settings next to the exe instead.
Source: "{#RepoRoot}\installer\settings.path"; DestDir: "{app}"; Flags: onlyifdoesntexist
; The licence stays in a Documents subfolder, matching the Licenses shortcut below.
Source: "{#RepoRoot}\Documents\License.txt"; DestDir: "{app}\Documents"; Flags: ignoreversion
Source: "{#RepoRoot}\README.md"; DestDir: "{app}"; Flags: ignoreversion skipifsourcedoesntexist
Source: "{#RepoRoot}\CA.example.image.jpg"; DestDir: "{app}"; Flags: ignoreversion skipifsourcedoesntexist
Source: "{#RepoRoot}\CHANGELOG.md"; DestDir: "{app}"; Flags: ignoreversion

[Icons]
Name: "{group}\{#MyAppDisplayName}"; Filename: "{app}\{#MyAppExeName}"
Name: "{group}\{cm:UninstallProgram,{#MyAppDisplayName}}"; Filename: "{uninstallexe}"
Name: "{autodesktop}\{#MyAppDisplayName}"; Filename: "{app}\{#MyAppExeName}"; Tasks: desktopicon
Name: "{group}\Licenses"; Filename: "{app}\Documents\License.txt"

; [InstallDelete] -- template, not active.  Upgrades only add and overwrite; files and
; shortcuts that a newer script no longer lists stay behind (uninstall still removes them).
; When a release retires or renames something, uncomment this section and list it, e.g.:
;[InstallDelete]
;Type: files; Name: "{app}\OldFile.txt"
;Type: files; Name: "{group}\Old Shortcut.lnk"

; Active: the Readme and Changelog shortcuts used to be .lnk files to local .md files.
[InstallDelete]
Type: files; Name: "{group}\Readme.lnk"
Type: files; Name: "{group}\Changelog.lnk"
Type: files; Name: "{group}\Bookmarks and Sessions Guide.url"

; Windows has no viewer for .md files (they open in Notepad), so the Readme, Changelog and
; Tips and Tricks shortcuts are web links that open the pages on GitHub, where Markdown is rendered.
; Shortcuts to web addresses are .url files, written with [INI] entries.  README.md and
; CHANGELOG.md are still installed above, for reading offline.
[INI]
Filename: "{group}\Readme.url"; Section: "InternetShortcut"; Key: "URL"; String: "{#MyAppURL}/blob/master/README.md"
Filename: "{group}\Tips and Tricks.url"; Section: "InternetShortcut"; Key: "URL"; String: "{#MyAppURL}/blob/master/Documents/Tips_and_Tricks.md"
Filename: "{group}\Changelog.url"; Section: "InternetShortcut"; Key: "URL"; String: "{#MyAppURL}/blob/master/CHANGELOG.md"

[UninstallDelete]
Type: files; Name: "{group}\*.url"

[Run]
Filename: "{app}\{#MyAppExeName}"; Description: "{cm:LaunchProgram,{#DoubleAmp(MyAppName)}}"; Flags: nowait postinstall skipifsilent
