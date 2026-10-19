//******************************************************************************
//  CE_WideCompat
//
//  Small compatibility layer for the CubicExplorer Unicode port.
//
//  The original code (Delphi 2006) got these three helpers from libraries
//  that are gone or have changed:
//
//    WideMessageBox       - not defined in TNT or in the current Mustangpeak
//                           libraries. Its behaviour is inferred from its ~25
//                           call sites (see the note on the function).
//    WideDeleteDirEx      - same; one call site (version manager).
//    WideSelectDirectory  - came from TntFileCtrl, which has been removed.
//
//  The signatures are kept identical to the old ones so that no call site
//  needs to change. Everything here is built on the standard RTL/VCL/WinAPI.
//******************************************************************************

unit CE_WideCompat;

interface

uses
  Windows;

function WideMessageBox(hWnd: HWND; const Caption, Text: string; uType: Integer): Integer;
function WideDeleteDirEx(const DirPath: string): Boolean;
function WideSelectDirectory(const Caption, Root: WideString; var Directory: WideString): Boolean;

implementation

uses
  SysUtils, IOUtils, FileCtrl;

{-------------------------------------------------------------------------------
  WideMessageBox

  Shows a message box and returns the button id (IDYES, IDNO, IDCANCEL, ...).

  NOTE: the argument order is (hWnd, Caption, Text, uType), i.e. the title
  comes BEFORE the message. This is the reverse of the Windows MessageBoxW
  call (lpText, lpCaption), so the two are swapped when forwarding. The order
  was deduced from every call site, e.g.
    WideMessageBox(h, _('Apply Changes'), _('Apply changes now?'), ...)
-------------------------------------------------------------------------------}
function WideMessageBox(hWnd: HWND; const Caption, Text: string; uType: Integer): Integer;
begin
  Result := MessageBoxW(hWnd, PWideChar(Text), PWideChar(Caption), UINT(uType));
end;

{-------------------------------------------------------------------------------
  WideDeleteDirEx

  Deletes a directory and everything below it. Returns True when the directory
  no longer exists afterwards (including when it did not exist to begin with),
  False if it could not be removed or the path was refused.

  The original source is not available, so this is a conservative
  re-implementation of what the single caller needs (delete a downloaded
  version folder). It never raises an exception. Safety guard: an empty path
  or a drive/share root such as 'C:\' is refused, so a bad variable can never
  turn into 'delete the whole drive'. Read-only files make the delete fail
  (the result is then False) rather than being forced.
-------------------------------------------------------------------------------}
function WideDeleteDirEx(const DirPath: string): Boolean;
var
  Path: string;
begin
  Path := ExcludeTrailingPathDelimiter(DirPath);
  if (Path = '') or SameText(Path, ExtractFileDrive(Path)) then begin
    Result := False;
    Exit;
  end;

  if DirectoryExists(Path) then begin
    try
      TDirectory.Delete(Path, True);
    except
      on Exception do begin
        // Ignored on purpose: the check below reports the real state on disk.
      end;
    end;
  end;
  Result := not DirectoryExists(Path);
end;

{-------------------------------------------------------------------------------
  WideSelectDirectory

  Shows the standard Windows "browse for folder" dialog (the VCL wrapper
  around SHBrowseForFolder, same as the TNT version used).
    Caption   - text shown above the tree
    Root      - folder the tree is rooted at ('' = whole desktop)
    Directory - IN: folder to preselect. OUT: the chosen folder, only changed
                when the user pressed OK.
  Returns True when the user pressed OK.
  Directory stays a WideString (not string) so existing callers that pass a
  WideString variable keep compiling.
-------------------------------------------------------------------------------}
function WideSelectDirectory(const Caption, Root: WideString; var Directory: WideString): Boolean;
var
  Dir: string;
begin
  Dir := Directory;
  Result := SelectDirectory(Caption, Root, Dir);
  if Result then begin
    Directory := Dir;
  end;
end;

end.
