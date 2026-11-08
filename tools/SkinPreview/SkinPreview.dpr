{*------------------------------------------------------------------------------
  SkinPreview - makes the preview pictures for the CubicAdventurer skins.

  For every <name>.skn in a folder it applies the skin to a small sample window
  (title bar, menu bar, toolbar, tabs, buttons, editors, list, trackbar, progress
  bar, status bar) and saves a picture of that window as <name>.png next to the
  skin. The Options > Display page shows that picture when the skin is selected.

  An existing .png is NOT overwritten (some skin authors supply their own
  preview); pass /force as a second parameter to replace them.

  /export first writes a .skn file for each skin that is built into the
  libraries (Aluminum, Athen, Dream, Eos, Human, Leopard, Xito, the Office
  skins and CubicAdventurer's Chrome) when the folder has none, so they can get
  pictures too. The program keeps using its built-in copy of those skins; the
  file is what the picture is named after. The Default skin is left out: it
  follows the Windows theme, so its look differs from machine to machine.

  Build:  File > Open this .dpr in the Delphi IDE (the IDE makes the .dproj; the
          SpTBXLib and Toolbar2000 packages that CubicAdventurer needs are all
          this project needs), then Project > Build.
  Run:    Run > Parameters: the full path of the repository's Skins folder, e.g.
          C:\repos\CubicAdventurer\Skins   (optionally followed by  /force )
          The picture is taken from the screen, so leave the mouse and other
          windows alone while it runs (a few seconds) and use 100% display
          scaling for pictures of the usual size.

  The sample window and the picture code are in Source\CE_SkinPreview.pas, which
  CubicAdventurer also uses (Options > Display makes missing pictures by itself).
  This program is for making all of them at once, e.g. before a release.
  It is not part of the CubicAdventurer build.
-------------------------------------------------------------------------------}
program SkinPreview;

{$APPTYPE GUI}

uses
  Windows, SysUtils, Classes, Forms,
  SpTBXSkins,
  // these two register the skins that are built in, not loaded from a file
  SpTBXDefaultSkins,
  SpTBXChromeSkin in '..\..\Source\Components\SpSkins\SpTBXChromeSkin.pas',
  // the sample window and the picture code, shared with CubicAdventurer
  CE_SkinPreview in '..\..\Source\CE_SkinPreview.pas';

{*------------------------------------------------------------------------------
  Write a .skn file into AFolder for every skin that is built into the libraries
  (it has a skin class, not a file) and has no file there yet. The skin is made
  current and saved with the skin manager, so the file holds exactly the colors
  the program uses. Returns how many files were written.
-------------------------------------------------------------------------------}
function ExportBuiltInSkins(const AFolder: string): Integer;
var
  pair: TSpTBXSkinsDictionaryPair;
  names: TStringList;
  i: Integer;
  fileName: string;
begin
  Result:= 0;
  names:= TStringList.Create;
  try
    for pair in SkinManager.SkinsList do
    begin
      if pair.Value.SkinClass <> nil then
      begin
        names.Add(pair.Key);
      end;
    end;
    names.Sort;
    for i:= 0 to names.Count - 1 do
    begin
      fileName:= AFolder + names[i] + '.skn';
      if not FileExists(fileName) then
      begin
        SkinManager.SetSkin(names[i]);
        SkinManager.SaveToFile(fileName);
        Inc(Result);
      end;
    end;
  finally
    names.Free;
  end;
end;

{*------------------------------------------------------------------------------
  Make the pictures: one per skin file in AFolder. Returns a summary text.
-------------------------------------------------------------------------------}
function MakePreviews(AForm: TForm; const AFolder: string; AForce: Boolean): string;
var
  sr: TSearchRec;
  files: TStringList;
  i, made, skipped, failed: Integer;
  skinFile, pngFile, skinName: string;
begin
  made:= 0;
  skipped:= 0;
  failed:= 0;
  files:= TStringList.Create;
  try
    if FindFirst(AFolder + '*.skn', faAnyFile, sr) = 0 then
    begin
      try
        repeat
          files.Add(AFolder + sr.Name);
        until FindNext(sr) <> 0;
      finally
        FindClose(sr);
      end;
    end;
    files.Sort;
    for i:= 0 to files.Count - 1 do
    begin
      skinFile:= files[i];
      pngFile:= ChangeFileExt(skinFile, '.png');
      if FileExists(pngFile) and not AForce then
      begin
        Inc(skipped);
        Continue;
      end;
      skinName:= SkinManager.AddSkinFromFile(skinFile);
      if skinName = '' then
      begin
        Inc(failed);
        Continue;
      end;
      if MakeSkinPicture(AForm, skinName, pngFile) then
      begin
        Inc(made);
      end
      else begin
        Inc(failed);
      end;
    end;
  finally
    files.Free;
  end;
  Result:= Format('Pictures made: %d'#13#10'Skipped (already have one): %d'#13#10 +
      'Failed: %d', [made, skipped, failed]);
end;

var
  form: TCESkinSampleForm;
  folder, report: string;
  force, doExport: Boolean;
  written: Integer;
begin
  Application.Initialize;
  folder:= ParamStr(1);
  if (folder = '') or not DirectoryExists(folder) then
  begin
    MessageBox(0, 'Give the full path of the Skins folder as the first parameter.',
        'SkinPreview', MB_OK or MB_ICONINFORMATION);
    Exit;
  end;
  folder:= IncludeTrailingPathDelimiter(folder);
  force:= FindCmdLineSwitch('force', ['/'], true);
  doExport:= FindCmdLineSwitch('export', ['/'], true);
  form:= TCESkinSampleForm.CreateNew(Application);
  try
    form.Show;
    form.BringToFront;
    SetCursorPos(0, 0);
    Application.ProcessMessages;
    report:= '';
    if doExport then
    begin
      written:= ExportBuiltInSkins(folder);
      report:= Format('Skin files written: %d'#13#10, [written]);
    end;
    report:= report + MakePreviews(form, folder, force);
    MessageBox(0, PChar(report), 'SkinPreview', MB_OK or MB_ICONINFORMATION);
  finally
    form.Free;
  end;
end.
