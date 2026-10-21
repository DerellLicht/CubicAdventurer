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
//  The Original Code is fCE_OptionsPage_Display_FileView.pas.                                                            
//                                                                                            
//  The Initial Developer of the Original Code is Marko Savolainen (cubicreality@gmail.com).  
//  Portions created by Marko Savolainen Copyright (C) Marko Savolainen. All Rights Reserved. 
//                                                                                            
//******************************************************************************

unit fCE_OptionsPage_Display_FileView;

interface

uses
  // CE Units
  fCE_OptionsDialog, fCE_OptionsCustomPage, CE_LanguageEngine, CE_ExtColors,
  // System Units
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, SpTBXItem, SpTBXControls, SpTBXEditors, SpTBXTabs,
  TB2Item;

type
  TCE_OptionsPage_Display_FileView = class(TCEOptionsCustomPage)
    TabControl: TSpTBXTabControl;
    tab_options: TSpTBXTabItem;
    tab_display: TSpTBXTabItem;
    tab_colors: TSpTBXTabItem;
    sheet_options: TSpTBXTabSheet;
    sheet_display: TSpTBXTabSheet;
    sheet_colors: TSpTBXTabSheet;
    // Options tab
    check_selectprev: TCheckBox;
    check_autoselect: TCheckBox;
    check_autosize_liststyle: TCheckBox;
    check_sortfoldersfirst: TCheckBox;
    check_infotips: TCheckBox;
    check_singleclick: TCheckBox;
    check_browsezip: TCheckBox;
    // Display tab
    group_font: TGroupBox;
    panel_preview: TPanel;
    but_font: TSpTBXButton;
    label_fontcolor: TLabel;
    combo_fontcolor: TColorBox;
    label_bgcolor: TLabel;
    combo_bgcolor: TColorBox;
    check_gridlines: TCheckBox;
    check_fullrowselect: TCheckBox;
    label_sizeformat: TLabel;
    combo_sizeformat: TComboBox;
    font_dialog: TFontDialog;
    // Colors tab
    check_extcolors: TCheckBox;
    list_rules: TListBox;
    label_exts: TLabel;
    edit_exts: TEdit;
    but_add: TSpTBXButton;
    but_delete: TSpTBXButton;
    check_bold: TCheckBox;
    check_italic: TCheckBox;
    check_underline: TCheckBox;
    combo_rulecolor: TColorBox;
    label_hint: TLabel;
    procedure HandleChange(Sender: TObject);
    procedure HandleColorChange(Sender: TObject);
    procedure HandleFontButton(Sender: TObject);
    procedure HandleRuleAdd(Sender: TObject);
    procedure HandleRuleChange(Sender: TObject);
    procedure HandleRuleDelete(Sender: TObject);
    procedure HandleRuleSelect(Sender: TObject);
  private
    fFontName: string;
    fFontSize: Integer;
    fLoading: Boolean;
    fRules: TCEExtColorRules;
    procedure LoadRuleControls;
    procedure UpdatePreview;
    procedure UpdateRuleEnabled;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure ApplySettings; override;
    procedure RefreshSettings; override;
  end;

var
  CE_OptionsPage_Display_FileView: TCE_OptionsPage_Display_FileView;

implementation

uses
  fCE_FileView, VirtualExplorerEasyListview;

{$R *.dfm}

{-------------------------------------------------------------------------------
  Create an instance of TCEOptionsPage_Display
-------------------------------------------------------------------------------}
constructor TCE_OptionsPage_Display_FileView.Create(AOwner: TComponent);
begin
  inherited;
  PageName:= _('Fileview');
  PageTitle:= _('Fileview Settings');
  PagePath:= 'Display/Fileview';
  ImageIndex:= 5;
  fRules:= TCEExtColorRules.Create;
  combo_sizeformat.Items.Add(_('Default'));
  combo_sizeformat.Items.Add(_('Explorer'));
  combo_sizeformat.Items.Add(_('Actual'));
  combo_sizeformat.Items.Add(_('Disk Usage'));
  combo_sizeformat.Items.Add(_('Text'));
end;

destructor TCE_OptionsPage_Display_FileView.Destroy;
begin
  fRules.Free;
  inherited;
end;

{-------------------------------------------------------------------------------
  Apply Settings
-------------------------------------------------------------------------------}
procedure TCE_OptionsPage_Display_FileView.ApplySettings;
begin
  GlobalFileViewSettings.BeginUpdate;
  try
    // Options tab
    GlobalFileViewSettings.SelectPreviousFolder:= check_selectprev.Checked;
    GlobalFileViewSettings.AutoSelectFirstItem:= check_autoselect.Checked;
    GlobalFileViewSettings.AutosizeListViewStyle:= check_autosize_liststyle.Checked;
    GlobalFileViewSettings.SortFolderFirstAlways:= check_sortfoldersfirst.Checked;
    GlobalFileViewSettings.ShowInfoTips:= check_infotips.Checked;
    GlobalFileViewSettings.SingleClickBrowse:= check_singleclick.Checked;
    GlobalFileViewSettings.BrowseZipFolders:= check_browsezip.Checked;
    // Display tab
    GlobalFileViewSettings.FontName:= fFontName;
    GlobalFileViewSettings.FontSize:= fFontSize;
    GlobalFileViewSettings.FontColor:= combo_fontcolor.Selected;
    GlobalFileViewSettings.BackgroundColor:= combo_bgcolor.Selected;
    GlobalFileViewSettings.ShowGridLines:= check_gridlines.Checked;
    GlobalFileViewSettings.FullRowSelect:= check_fullrowselect.Checked;
    GlobalFileViewSettings.FileSizeFormat:= TVirtualFileSizeFormat(combo_sizeformat.ItemIndex);
    // Colors tab
    GlobalFileViewSettings.ExtColorsEnabled:= check_extcolors.Checked;
    GlobalFileViewSettings.ExtColorRules:= fRules.Serialize;
  finally
    GlobalFileViewSettings.EndUpdate(true);
  end;
end;

{-------------------------------------------------------------------------------
  Refresh Settings
-------------------------------------------------------------------------------}
procedure TCE_OptionsPage_Display_FileView.RefreshSettings;
var
  i: Integer;
begin
  fLoading:= true;
  try
    // Options tab
    check_selectprev.Checked:= GlobalFileViewSettings.SelectPreviousFolder;
    check_autoselect.Checked:= GlobalFileViewSettings.AutoSelectFirstItem;
    check_autosize_liststyle.Checked:= GlobalFileViewSettings.AutosizeListViewStyle;
    check_sortfoldersfirst.Checked:= GlobalFileViewSettings.SortFolderFirstAlways;
    check_infotips.Checked:= GlobalFileViewSettings.ShowInfoTips;
    check_singleclick.Checked:= GlobalFileViewSettings.SingleClickBrowse;
    check_browsezip.Checked:= GlobalFileViewSettings.BrowseZipFolders;
    // Display tab
    fFontName:= GlobalFileViewSettings.FontName;
    fFontSize:= GlobalFileViewSettings.FontSize;
    combo_fontcolor.Selected:= GlobalFileViewSettings.FontColor;
    combo_bgcolor.Selected:= GlobalFileViewSettings.BackgroundColor;
    check_gridlines.Checked:= GlobalFileViewSettings.ShowGridLines;
    check_fullrowselect.Checked:= GlobalFileViewSettings.FullRowSelect;
    combo_sizeformat.ItemIndex:= Ord(GlobalFileViewSettings.FileSizeFormat);
    UpdatePreview;
    // Colors tab: work on a copy of the rules, written back on Apply
    check_extcolors.Checked:= GlobalFileViewSettings.ExtColorsEnabled;
    fRules.Deserialize(GlobalFileViewSettings.ExtColors.Serialize);
    list_rules.Items.BeginUpdate;
    try
      list_rules.Items.Clear;
      for i:= 0 to fRules.Count - 1 do begin
        list_rules.Items.Add(fRules[i].Extensions);
      end;
    finally
      list_rules.Items.EndUpdate;
    end;
    if list_rules.Count > 0 then begin
      list_rules.ItemIndex:= 0;
    end;
  finally
    fLoading:= false;
  end;
  LoadRuleControls;
end;

procedure TCE_OptionsPage_Display_FileView.HandleChange(Sender: TObject);
begin
  inherited;
end;

{-------------------------------------------------------------------------------
  Font / background color changed: refresh the preview and flag the change
-------------------------------------------------------------------------------}
procedure TCE_OptionsPage_Display_FileView.HandleColorChange(Sender: TObject);
begin
  if fLoading then begin
    Exit;
  end;
  UpdatePreview;
  SetModified;
end;

{-------------------------------------------------------------------------------
  Show the font dialog for the file list font (name and size are kept)
-------------------------------------------------------------------------------}
procedure TCE_OptionsPage_Display_FileView.HandleFontButton(Sender: TObject);
begin
  font_dialog.Font.Name:= panel_preview.Font.Name;
  font_dialog.Font.Size:= panel_preview.Font.Size;
  if font_dialog.Execute then begin
    fFontName:= font_dialog.Font.Name;
    fFontSize:= font_dialog.Font.Size;
    UpdatePreview;
    SetModified;
  end;
end;

{-------------------------------------------------------------------------------
  Add a new, empty rule at the end of the list and start editing it
-------------------------------------------------------------------------------}
procedure TCE_OptionsPage_Display_FileView.HandleRuleAdd(Sender: TObject);
var
  r: TCEExtColorRule;
  idx: Integer;
begin
  r.Extensions:= '';
  r.Bold:= false;
  r.Italic:= false;
  r.Underline:= false;
  r.Color:= clDefault;
  idx:= fRules.Add(r);
  list_rules.Items.Add('');
  list_rules.ItemIndex:= idx;
  LoadRuleControls;
  edit_exts.SetFocus;
  SetModified;
end;

{-------------------------------------------------------------------------------
  A control of the selected rule changed: copy all of them into the rule
-------------------------------------------------------------------------------}
procedure TCE_OptionsPage_Display_FileView.HandleRuleChange(Sender: TObject);
var
  r: TCEExtColorRule;
  idx: Integer;
begin
  if fLoading then begin
    Exit;
  end;
  idx:= list_rules.ItemIndex;
  if idx < 0 then begin
    Exit;
  end;
  r.Extensions:= edit_exts.Text;
  r.Bold:= check_bold.Checked;
  r.Italic:= check_italic.Checked;
  r.Underline:= check_underline.Checked;
  r.Color:= combo_rulecolor.Selected;
  fRules.Update(idx, r);
  list_rules.Items[idx]:= fRules[idx].Extensions;
  SetModified;
end;

{-------------------------------------------------------------------------------
  Delete the selected rule and select its neighbour
-------------------------------------------------------------------------------}
procedure TCE_OptionsPage_Display_FileView.HandleRuleDelete(Sender: TObject);
var
  idx: Integer;
begin
  idx:= list_rules.ItemIndex;
  if idx < 0 then begin
    Exit;
  end;
  fRules.Delete(idx);
  list_rules.Items.Delete(idx);
  if idx >= list_rules.Count then begin
    idx:= list_rules.Count - 1;
  end;
  list_rules.ItemIndex:= idx;
  LoadRuleControls;
  SetModified;
end;

procedure TCE_OptionsPage_Display_FileView.HandleRuleSelect(Sender: TObject);
begin
  LoadRuleControls;
end;

{-------------------------------------------------------------------------------
  Show the selected rule in the controls on the right (no change is flagged)
-------------------------------------------------------------------------------}
procedure TCE_OptionsPage_Display_FileView.LoadRuleControls;
var
  r: TCEExtColorRule;
begin
  fLoading:= true;
  try
    if list_rules.ItemIndex >= 0 then begin
      r:= fRules[list_rules.ItemIndex];
      edit_exts.Text:= r.Extensions;
      check_bold.Checked:= r.Bold;
      check_italic.Checked:= r.Italic;
      check_underline.Checked:= r.Underline;
      combo_rulecolor.Selected:= r.Color;
    end
    else begin
      edit_exts.Text:= '';
      check_bold.Checked:= false;
      check_italic.Checked:= false;
      check_underline.Checked:= false;
      combo_rulecolor.Selected:= clDefault;
    end;
  finally
    fLoading:= false;
  end;
  UpdateRuleEnabled;
end;

{-------------------------------------------------------------------------------
  Preview panel: chosen font name/size/color on the chosen background
-------------------------------------------------------------------------------}
procedure TCE_OptionsPage_Display_FileView.UpdatePreview;
var
  fontName: string;
  size: Integer;
begin
  fontName:= fFontName;
  if fontName = '' then begin
    fontName:= Screen.IconFont.Name;
  end;
  size:= fFontSize;
  if size <= 0 then begin
    size:= Screen.IconFont.Size;
  end;
  panel_preview.Font.Name:= fontName;
  panel_preview.Font.Size:= size;
  panel_preview.Font.Color:= combo_fontcolor.Selected;
  panel_preview.Color:= combo_bgcolor.Selected;
  panel_preview.Caption:= Format('%s %dpt', [fontName, size]);
end;

procedure TCE_OptionsPage_Display_FileView.UpdateRuleEnabled;
var
  en: Boolean;
begin
  en:= list_rules.ItemIndex >= 0;
  edit_exts.Enabled:= en;
  check_bold.Enabled:= en;
  check_italic.Enabled:= en;
  check_underline.Enabled:= en;
  combo_rulecolor.Enabled:= en;
  but_delete.Enabled:= en;
end;

{##############################################################################}

initialization
  RegisterOptionsPageClass(TCE_OptionsPage_Display_FileView);

finalization

end.
