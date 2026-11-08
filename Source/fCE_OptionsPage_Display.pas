//******************************************************************************
//  CubicExplorer                                                                             
//  Version: 0.90                                                                             
//                                                                                            
//  The contents of this file are subject to the Mozilla Public License                       
//  Version 1.1 (the "License"); you may not use this file except in                          
//  compliance with the License. You may obtain a copy of the License at                      
//  http://www.mozilla.org/MPL/                                                               
//                                                                                            
//  Software distributed under the License is distributed on an "AS IS"
//  basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
//  License for the specific language governing rights and limitations                        
//  under the License.                                                                        
//                                                                                            
//  The Original Code is fCE_OptionsPage_Display.pas.                                                            
//                                                                                            
//  The Initial Developer of the Original Code is Marko Savolainen (cubicreality@gmail.com).  
//  Portions created by Marko Savolainen Copyright (C) Marko Savolainen. All Rights Reserved. 
//                                                                                            
//******************************************************************************

unit fCE_OptionsPage_Display;

interface

uses
  // CE Units
  fCE_OptionsDialog, fCE_OptionsCustomPage, CE_LanguageEngine, dCE_Actions,
  // SpTBX
  SpTBXSkins,
  // System Units
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, pngimage;

type
  TCEOptionsPage_Display = class(TCEOptionsCustomPage)
    TntLabel1: TLabel;
    combo_theme: TComboBox;
    check_path_in_title: TCheckBox;
    TntButton1: TButton;
    image_preview: TImage;
    procedure combo_themeChange(Sender: TObject);
  private
    procedure UpdateThemePreview;
    procedure CreateMissingPreviews;
    { Private declarations }
  public
    constructor Create(AOwner: TComponent); override;
    class procedure GetPageInfo(out AName, ATitle, APath: WideString;
        out AImageIndex, APosition: Integer); override;
    procedure ApplySettings; override;
    procedure RefreshSettings; override;
    { Public declarations }
  end;

var
  CEOptionsPage_Display: TCEOptionsPage_Display;

implementation

uses
  Main, CE_SkinPreview;

{$R *.dfm}

var
  // themes that were offered a preview picture during this run (made, cancelled
  // or failed), so the question is not repeated each time the page is shown
  gTriedSkins: TStringList = nil;

{-------------------------------------------------------------------------------
  Create an instance of TCEOptionsPage_Display
-------------------------------------------------------------------------------}
constructor TCEOptionsPage_Display.Create(AOwner: TComponent);
var
  i: Integer;
  skins: TStringList;
begin
  inherited;
  LoadPageInfo;
  // Fill themes combo
  skins:= TStringList.Create;
  try
    SkinManager.GetSkinsAndDelphiStyles(skins, True);
    skins.Sort;
    I:= skins.IndexOf('Default');
    if I > -1 then
    begin
      skins.Move(I, 0);
    end;
    combo_theme.Items.Assign(skins);
  finally
    skins.Free;
  end;
end;

{-------------------------------------------------------------------------------
  Theme combo changed: mark the page modified and show the theme's preview.
-------------------------------------------------------------------------------}
procedure TCEOptionsPage_Display.combo_themeChange(Sender: TObject);
begin
  HandleChange(Sender);
  UpdateThemePreview;
end;

{-------------------------------------------------------------------------------
  Make the preview pictures that are missing. A theme has a picture when a .png
  with the skin file's name sits next to the skin file. For each theme that has a
  skin file but no picture, CreateSkinPreviews (CE_SkinPreview.pas) shows a
  window explaining what is going on and makes the pictures. Nothing is shown
  when no picture is missing, which is the normal case.
-------------------------------------------------------------------------------}
procedure TCEOptionsPage_Display.CreateMissingPreviews;
var
  i: Integer;
  names, files: TStringList;
  skinName, skinFile, picFile: string;
begin
  if gTriedSkins = nil then
  begin
    gTriedSkins:= TStringList.Create;
    gTriedSkins.CaseSensitive:= false;
  end;
  names:= TStringList.Create;
  files:= TStringList.Create;
  try
    for i:= 0 to combo_theme.Items.Count - 1 do
    begin
      skinName:= combo_theme.Items[i];
      skinFile:= MainForm.GetSkinFileName(skinName);
      if (skinFile <> '') and FileExists(skinFile) and
          (gTriedSkins.IndexOf(skinName) < 0) then
      begin
        picFile:= ChangeFileExt(skinFile, '.png');
        if not FileExists(picFile) then
        begin
          gTriedSkins.Add(skinName);
          names.Add(skinName);
          files.Add(picFile);
        end;
      end;
    end;
    if names.Count > 0 then
    begin
      CreateSkinPreviews(names, files);
    end;
  finally
    files.Free;
    names.Free;
  end;
end;

{-------------------------------------------------------------------------------
  Show the preview picture of the theme selected in the combo box.
  The picture is optional: it is the skin file's name with a .png extension, in the
  same folder. If it does not exist (or cannot be loaded) the preview stays empty.
  The picture is scaled down (never up) to fit the image area, using HALFTONE
  stretching, because the default TImage stretching looks coarse for small text.
-------------------------------------------------------------------------------}
procedure TCEOptionsPage_Display.UpdateThemePreview;
var
  skinFile, picFile: string;
  png: TPngImage;
  src, dst: TBitmap;
  scale: Double;
  w, h: Integer;
begin
  image_preview.Picture.Assign(nil);
  skinFile:= MainForm.GetSkinFileName(combo_theme.Text);
  if skinFile = '' then
  begin
    Exit;
  end;
  picFile:= ChangeFileExt(skinFile, '.png');
  if not FileExists(picFile) then
  begin
    Exit;
  end;
  png:= TPngImage.Create;
  src:= TBitmap.Create;
  dst:= TBitmap.Create;
  try
    try
      png.LoadFromFile(picFile);
      src.Assign(png);
      scale:= 1.0;
      if src.Width * image_preview.Height > src.Height * image_preview.Width then
      begin
        scale:= image_preview.Width / src.Width;
      end
      else begin
        scale:= image_preview.Height / src.Height;
      end;
      if scale > 1.0 then
      begin
        scale:= 1.0;
      end;
      w:= Round(src.Width * scale);
      h:= Round(src.Height * scale);
      dst.PixelFormat:= pf24bit;
      dst.SetSize(w, h);
      SetStretchBltMode(dst.Canvas.Handle, HALFTONE);
      SetBrushOrgEx(dst.Canvas.Handle, 0, 0, nil);
      StretchBlt(dst.Canvas.Handle, 0, 0, w, h, src.Canvas.Handle, 0, 0,
          src.Width, src.Height, SRCCOPY);
      image_preview.Picture.Bitmap.Assign(dst);
    except
      // a bad picture is not worth an error message; leave the preview empty
      image_preview.Picture.Assign(nil);
    end;
  finally
    dst.Free;
    src.Free;
    png.Free;
  end;
end;

{-------------------------------------------------------------------------------
  Get PageInfo: name, title, path, icon and sort position of this page. The Options
  dialog calls this to build its page tree without creating the page.
-------------------------------------------------------------------------------}
class procedure TCEOptionsPage_Display.GetPageInfo(out AName, ATitle, APath: WideString;
    out AImageIndex, APosition: Integer);
begin
  AName:= _('Display');
  ATitle:= _('Display Settings');
  APath:= 'Display';
  AImageIndex:= 2;
  APosition:= 2;
end;

{-------------------------------------------------------------------------------
  Apply Settings
-------------------------------------------------------------------------------}
procedure TCEOptionsPage_Display.ApplySettings;
begin
  // theme
  if MainForm.Settings.Skin <> combo_theme.Text then
  MainForm.Settings.Skin:= combo_theme.Text;
  MainForm.Settings.PathInTitle:= check_path_in_title.Checked;
end;

{-------------------------------------------------------------------------------
  Refresh Settings
-------------------------------------------------------------------------------}
procedure TCEOptionsPage_Display.RefreshSettings;
var
  ws: WideString;
begin
  // Skin
  ws:= MainForm.Settings.Skin;
  combo_theme.ItemIndex:= combo_theme.Items.IndexOf(ws);
  CreateMissingPreviews;
  UpdateThemePreview;
  check_path_in_title.Checked:= MainForm.Settings.PathInTitle;
end;

{##############################################################################}

initialization
  RegisterOptionsPageClass(TCEOptionsPage_Display);

finalization
  gTriedSkins.Free;

end.
