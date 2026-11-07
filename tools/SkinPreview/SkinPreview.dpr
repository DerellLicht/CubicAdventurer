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

  Not part of the CubicAdventurer build; nothing in the program uses this file.
-------------------------------------------------------------------------------}
program SkinPreview;

{$APPTYPE GUI}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, StdCtrls,
  ExtCtrls, ComCtrls, pngimage,
  TB2Dock, TB2Item, TB2Toolbar,
  SpTBXSkins, SpTBXItem, SpTBXControls, SpTBXEditors, SpTBXTabs,
  // these two register the skins that are built in, not loaded from a file
  SpTBXDefaultSkins,
  SpTBXChromeSkin in '..\..\Source\Components\SpSkins\SpTBXChromeSkin.pas';

const
  // BitBlt flag to include layered windows; not declared in Delphi's Windows unit
  CAPTUREBLT = $40000000;

type
  TPreviewForm = class(TForm)
  private
    fTitleBar: TSpTBXTitleBar;
    procedure BuildToolbars;
    procedure BuildTabsAndPanel;
    procedure BuildStatusBar;
    procedure AddButtonRow(AParent: TWinControl; ATop: Integer;
        const ACaption: string; AChecked, AEnabled: Boolean);
  public
    constructor CreateNew(AOwner: TComponent; Dummy: Integer = 0); override;
  end;

{*------------------------------------------------------------------------------
  Create the sample window. All controls are made in code, so there is no .dfm.
-------------------------------------------------------------------------------}
constructor TPreviewForm.CreateNew(AOwner: TComponent; Dummy: Integer);
begin
  inherited CreateNew(AOwner, Dummy);
  Caption:= 'Skin Preview';
  Position:= poScreenCenter;
  ClientWidth:= 340;
  ClientHeight:= 372;
  fTitleBar:= TSpTBXTitleBar.Create(Self);
  fTitleBar.Parent:= Self;
  fTitleBar.Align:= alClient;
  fTitleBar.Caption:= Caption;
  BuildToolbars;
  BuildStatusBar;
  BuildTabsAndPanel;
end;

{*------------------------------------------------------------------------------
  Menu bar (one submenu item) and a toolbar (one normal and one disabled item).
-------------------------------------------------------------------------------}
procedure TPreviewForm.BuildToolbars;
var
  dock: TSpTBXDock;
  menuBar, toolBar: TSpTBXToolbar;
  sub: TSpTBXSubmenuItem;
  item: TSpTBXItem;
begin
  dock:= TSpTBXDock.Create(Self);
  dock.Parent:= fTitleBar;
  dock.Position:= dpTop;

  menuBar:= TSpTBXToolbar.Create(Self);
  menuBar.CurrentDock:= dock;
  menuBar.MenuBar:= true;
  menuBar.FullSize:= true;
  sub:= TSpTBXSubmenuItem.Create(Self);
  sub.Caption:= 'MenuBar Item';
  menuBar.Items.Add(sub);
  item:= TSpTBXItem.Create(Self);
  item.Caption:= 'Item';
  sub.Add(item);
  item:= TSpTBXItem.Create(Self);
  item.Caption:= 'Checked Item';
  item.Checked:= true;
  sub.Add(item);
  item:= TSpTBXItem.Create(Self);
  item.Caption:= 'Radio Item';
  item.GroupIndex:= 1;
  item.Checked:= true;
  sub.Add(item);

  toolBar:= TSpTBXToolbar.Create(Self);
  toolBar.CurrentDock:= dock;
  toolBar.DockRow:= 1;
  item:= TSpTBXItem.Create(Self);
  item.Caption:= 'Toolbar Item';
  toolBar.Items.Add(item);
  item:= TSpTBXItem.Create(Self);
  item.Caption:= 'Disabled Item';
  item.Enabled:= false;
  toolBar.Items.Add(item);
end;

{*------------------------------------------------------------------------------
  Status bar with one normal and one disabled panel.
-------------------------------------------------------------------------------}
procedure TPreviewForm.BuildStatusBar;
var
  status: TSpTBXStatusBar;
  lbl: TSpTBXLabelItem;
begin
  status:= TSpTBXStatusBar.Create(Self);
  status.Parent:= fTitleBar;
  status.Align:= alBottom;
  lbl:= TSpTBXLabelItem.Create(Self);
  lbl.Caption:= 'Status Panel';
  status.Items.Add(lbl);
  status.Items.Add(TSpTBXSeparatorItem.Create(Self));
  lbl:= TSpTBXLabelItem.Create(Self);
  lbl.Caption:= 'Disabled Status Panel';
  lbl.Enabled:= false;
  status.Items.Add(lbl);
end;

{*------------------------------------------------------------------------------
  One row of the Buttons group: a button, a check box and a radio button.
-------------------------------------------------------------------------------}
procedure TPreviewForm.AddButtonRow(AParent: TWinControl; ATop: Integer;
    const ACaption: string; AChecked, AEnabled: Boolean);
var
  btn: TSpTBXButton;
  chk: TSpTBXCheckBox;
  rad: TSpTBXRadioButton;
begin
  btn:= TSpTBXButton.Create(Self);
  btn.Parent:= AParent;
  btn.SetBounds(10, ATop, 80, 24);
  btn.Caption:= ACaption;
  btn.Enabled:= AEnabled;

  chk:= TSpTBXCheckBox.Create(Self);
  chk.Parent:= AParent;
  chk.SetBounds(110, ATop + 3, 90, 18);
  chk.Caption:= ACaption;
  chk.Checked:= AChecked;
  chk.Enabled:= AEnabled;

  rad:= TSpTBXRadioButton.Create(Self);
  rad.Parent:= AParent;
  rad.SetBounds(215, ATop + 3, 90, 18);
  rad.Caption:= ACaption;
  rad.Checked:= AChecked;
  rad.Enabled:= AEnabled;
end;

{*------------------------------------------------------------------------------
  Tab strip, and below it a panel holding the Buttons, Editors and Misc groups.
-------------------------------------------------------------------------------}
procedure TPreviewForm.BuildTabsAndPanel;
var
  tabs: TSpTBXTabSet;
  panel: TSpTBXPanel;
  buttons, editors, misc: TSpTBXGroupBox;
  edit: TSpTBXEdit;
  combo: TSpTBXComboBox;
  list: TSpTBXListBox;
  track: TSpTBXTrackBar;
  progress: TSpTBXProgressBar;
begin
  tabs:= TSpTBXTabSet.Create(Self);
  tabs.Parent:= fTitleBar;
  // aligned, so the tabs always sit below the toolbars whatever their height is
  tabs.Align:= alTop;
  tabs.Height:= 24;
  tabs.Add('Controls');
  tabs.Add('Panels');
  tabs.ActiveTabIndex:= 0;

  panel:= TSpTBXPanel.Create(Self);
  panel.Parent:= fTitleBar;
  panel.Align:= alClient;

  buttons:= TSpTBXGroupBox.Create(Self);
  buttons.Parent:= panel;
  buttons.Caption:= 'Buttons';
  buttons.SetBounds(6, 4, 312, 104);
  AddButtonRow(buttons, 18, 'Normal', false, true);
  AddButtonRow(buttons, 46, 'Checked', true, true);
  AddButtonRow(buttons, 74, 'Disabled', false, false);

  editors:= TSpTBXGroupBox.Create(Self);
  editors.Parent:= panel;
  editors.Caption:= 'Editors';
  editors.SetBounds(6, 112, 150, 126);
  edit:= TSpTBXEdit.Create(Self);
  edit.Parent:= editors;
  edit.SetBounds(8, 20, 132, 21);
  edit.Text:= 'Edit';
  combo:= TSpTBXComboBox.Create(Self);
  combo.Parent:= editors;
  combo.SetBounds(8, 48, 132, 21);
  combo.Items.Add('ComboBox');
  combo.ItemIndex:= 0;
  list:= TSpTBXListBox.Create(Self);
  list.Parent:= editors;
  list.SetBounds(8, 76, 132, 42);
  list.Items.Add('List Item 1');
  list.Items.Add('List Item 2');
  list.ItemIndex:= 0;

  misc:= TSpTBXGroupBox.Create(Self);
  misc.Parent:= panel;
  misc.Caption:= 'Misc controls';
  misc.SetBounds(162, 112, 156, 126);
  track:= TSpTBXTrackBar.Create(Self);
  track.Parent:= misc;
  track.SetBounds(8, 24, 140, 30);
  track.Max:= 10;
  track.Position:= 4;
  progress:= TSpTBXProgressBar.Create(Self);
  progress.Parent:= misc;
  progress.SetBounds(8, 70, 140, 20);
  progress.Position:= 30;
end;

{*------------------------------------------------------------------------------
  Copy the client area of AForm from the screen into ABitmap. The skinned title
  bar fills the whole client area, so this is the skinned window without the frame
  Windows (or a desktop theme program such as WindowBlinds) draws around it.
-------------------------------------------------------------------------------}
function CaptureClient(AForm: TForm; ABitmap: TBitmap): Boolean;
var
  topLeft: TPoint;
  screenDC: HDC;
begin
  topLeft:= AForm.ClientToScreen(Point(0, 0));
  ABitmap.PixelFormat:= pf24bit;
  ABitmap.SetSize(AForm.ClientWidth, AForm.ClientHeight);
  screenDC:= GetDC(0);
  try
    Result:= BitBlt(ABitmap.Canvas.Handle, 0, 0, ABitmap.Width, ABitmap.Height,
        screenDC, topLeft.X, topLeft.Y, SRCCOPY or CAPTUREBLT);
  finally
    ReleaseDC(0, screenDC);
  end;
end;

{*------------------------------------------------------------------------------
  Let the window repaint with the new skin and wait until it has settled.
-------------------------------------------------------------------------------}
procedure SettleWindow(AForm: TForm);
var
  i: Integer;
begin
  for i:= 1 to 3 do
  begin
    RedrawWindow(AForm.Handle, nil, 0,
        RDW_INVALIDATE or RDW_ALLCHILDREN or RDW_FRAME or RDW_UPDATENOW);
    Application.ProcessMessages;
    Sleep(150);
  end;
end;

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
  bmp: TBitmap;
  png: TPngImage;
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
      SkinManager.SetSkin(skinName);
      SettleWindow(AForm);
      bmp:= TBitmap.Create;
      png:= TPngImage.Create;
      try
        if CaptureClient(AForm, bmp) then
        begin
          png.Assign(bmp);
          png.SaveToFile(pngFile);
          Inc(made);
        end
        else begin
          Inc(failed);
        end;
      finally
        png.Free;
        bmp.Free;
      end;
    end;
  finally
    files.Free;
  end;
  Result:= Format('Pictures made: %d'#13#10'Skipped (already have one): %d'#13#10 +
      'Failed: %d', [made, skipped, failed]);
end;

var
  form: TPreviewForm;
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
  form:= TPreviewForm.CreateNew(Application);
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
