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
  // CubicCore
  ccClasses, ccStrings,
  // CE Units
  fCE_OptionsDialog, fCE_OptionsCustomPage, CE_LanguageEngine,
  // Virtual Trees
  VirtualTrees,
  // SpTBX
  SpTBXControls,
  // System Units
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, ExtCtrls;

type
  PExtListData = ^AExtListData;
  AExtListData = record
    fExtensions: WideString;
    fBold: Boolean;
    fItalic: Boolean;
    fUnderline: Boolean;
    fColor: TColor;
    fBgEnabled: Boolean;
    fBgColor: TColor;
  end;

  TCE_OptionsPage_Display_FileView = class(TCEOptionsCustomPage)
    check_selectprev: TCheckBox;
    check_autoselect: TCheckBox;
    check_autosize_liststyle: TCheckBox;
    check_sortfoldersfirst: TCheckBox;
    check_infotips: TCheckBox;
    check_singleclick: TCheckBox;
    check_perfolder: TCheckBox;
    TntPageControl1: TPageControl;
    sheet_options: TTabSheet;
    sheet_colors: TTabSheet;
    check_browse_zip: TCheckBox;
    list_exts: TVirtualStringTree;
    but_add: TButton;
    but_delete: TButton;
    check_ext_bold: TCheckBox;
    check_ext_italic: TCheckBox;
    check_ext_underline: TCheckBox;
    color_extension: TColorBox;
    check_extension_colors: TCheckBox;
    TntLabel2: TLabel;
    sheet_display: TTabSheet;
    TntLabel1: TLabel;
    combo_sizeformat: TComboBox;
    color_background: TColorBox;
    TntLabel3: TLabel;
    TntGroupBox1: TSpTBXGroupBox;
    TntLabel14: TLabel;
    but_font: TButton;
    color_font: TColorBox;
    panel_font: TPanel;
    FontDlg: TFontDialog;
    check_gridlines: TCheckBox;
    check_fullrowselect: TCheckBox;
    check_remember_thumbs: TCheckBox;
    check_hiddenfiles: TCheckBox;
    check_showext: TCheckBox;
    sheet_attrs: TTabSheet;
    label_attr_hint: TLabel;
    label_folder_color: TLabel;
    color_folder: TColorBox;
    label_system_bg: TLabel;
    color_attr_system: TColorBox;
    label_readonly_bg: TLabel;
    color_attr_readonly: TColorBox;
    label_hidden_bg: TLabel;
    color_attr_hidden: TColorBox;
    label_combined_bg: TLabel;
    color_attr_combined: TColorBox;
    label_attr_note: TLabel;
    check_ext_bg: TCheckBox;
    color_extension_bg: TColorBox;
    procedure HandleChange(Sender: TObject);
    procedure list_extsGetText(Sender: TBaseVirtualTree; Node: PVirtualNode;
      Column: TColumnIndex; TextType: TVSTTextType; var CellText: string);
    procedure list_extsNewText(Sender: TBaseVirtualTree; Node: PVirtualNode;
      Column: TColumnIndex; NewText: string);
    procedure list_extsFreeNode(Sender: TBaseVirtualTree; Node: PVirtualNode);
    procedure but_addClick(Sender: TObject);
    procedure list_extsFocusChanged(Sender: TBaseVirtualTree;
      Node: PVirtualNode; Column: TColumnIndex);
    procedure HandleExtColorChange(Sender: TObject);
    procedure but_deleteClick(Sender: TObject);
    procedure list_extsEdited(Sender: TBaseVirtualTree; Node: PVirtualNode;
      Column: TColumnIndex);
    procedure list_extsEditCancelled(Sender: TBaseVirtualTree;
      Column: TColumnIndex);
    procedure FontDlgApply(Sender: TObject; Wnd: HWND);
    procedure color_fontSelect(Sender: TObject);
    procedure but_fontClick(Sender: TObject);
    procedure color_backgroundSelect(Sender: TObject);
  private
    procedure UpdateExtBgControls(AHasNode: Boolean);
  protected
    fExtValuesChanging: Boolean;
  public
    constructor Create(AOwner: TComponent); override;
    class procedure GetPageInfo(out AName, ATitle, APath: WideString;
        out AImageIndex, APosition: Integer); override;
    procedure ApplySettings; override;
    procedure RefreshSettings; override;
    { Public declarations }
  end;

var
  CE_OptionsPage_Display_FileView: TCE_OptionsPage_Display_FileView;

implementation

uses
  VirtualTrees.BaseTree, VirtualTrees.Types,
  fCE_FileView, VirtualExplorerEasyListview;

{$R *.dfm}

{-------------------------------------------------------------------------------
  Create an instance of TCEOptionsPage_Display
-------------------------------------------------------------------------------}
constructor TCE_OptionsPage_Display_FileView.Create(AOwner: TComponent);
begin
  inherited;
  LoadPageInfo;
  combo_sizeformat.Items.Add(_('Default'));
  combo_sizeformat.Items.Add(_('Explorer'));
  combo_sizeformat.Items.Add(_('Actual'));
  combo_sizeformat.Items.Add(_('Disk Usage'));
  combo_sizeformat.Items.Add(_('Text'));

  list_exts.NodeDataSize:= SizeOf(AExtListData);

  fExtValuesChanging:= false;
end;

{-------------------------------------------------------------------------------
  Get PageInfo: name, title, path, icon and sort position of this page. The Options
  dialog calls this to build its page tree without creating the page.
-------------------------------------------------------------------------------}
class procedure TCE_OptionsPage_Display_FileView.GetPageInfo(out AName, ATitle, APath: WideString;
    out AImageIndex, APosition: Integer);
begin
  AName:= _('Fileview');
  ATitle:= _('Fileview Settings');
  APath:= 'Display/Fileview';
  AImageIndex:= 5;
  APosition:= 0;
end;

{-------------------------------------------------------------------------------
  On FontDlg.Apply
-------------------------------------------------------------------------------}
procedure TCE_OptionsPage_Display_FileView.FontDlgApply(Sender: TObject;
  Wnd: HWND);
begin
  panel_font.Font.Assign(FontDlg.Font);
  panel_font.Caption:= FontDlg.Font.Name + ' ' + IntToStr(FontDlg.Font.Size) + 'pt';
  ApplySettings;
end;

{-------------------------------------------------------------------------------
  Apply Settings
-------------------------------------------------------------------------------}
procedure TCE_OptionsPage_Display_FileView.ApplySettings;

  procedure WriteExtensionColors;
  var
    node: PVirtualNode;
    data: PExtListData;
    value: WideString;
  begin
    node:= list_exts.GetFirst;
    value:= '';
    while assigned(node) do
    begin
      data:= list_exts.GetNodeData(node);
      if value <> '' then
      value:= value + '|';
      
      value:= value + WideReplaceChar(',', ';', data.fExtensions) + ',' +  // exts
              IntToStr(data.fColor) + ',' +                        // color
              BoolToStr(data.fBold) + ',' +                        // bold
              BoolToStr(data.fItalic) + ',' +                      // italic
              BoolToStr(data.fUnderline) + ',' +                   // underline
              BoolToStr(data.fBgEnabled) + ',' +                   // background enabled
              IntToStr(data.fBgColor);                             // background color

      node:= list_exts.GetNext(node);
    end;
    GlobalFileViewSettings.ExtensionColors:= value;
  end;

begin
  GlobalFileViewSettings.BeginUpdate;
  try
    // options
    GlobalFileViewSettings.FullRowSelect:= check_fullrowselect.Checked;
    GlobalFileViewSettings.SelectPreviousFolder:= check_selectprev.Checked;
    GlobalFileViewSettings.AutoSelectFirstItem:= check_autoselect.Checked;
    GlobalFileViewSettings.AutosizeListViewStyle:= check_autosize_liststyle.Checked;
    GlobalFileViewSettings.SortFolderFirstAlways:= check_sortfoldersfirst.Checked;
    GlobalFileViewSettings.ShowInfoTips:= check_infotips.Checked;
    GlobalFileViewSettings.SingleClickBrowse:= check_singleclick.Checked;
    GlobalFileViewSettings.PerFolderSettings:= check_perfolder.Checked;
    GlobalFileViewSettings.ShowGridLines:= check_gridlines.Checked;
    GlobalFileViewSettings.BrowseZipFolders:= check_browse_zip.Checked;
    GlobalFileViewSettings.FileSizeFormat:= TVirtualFileSizeFormat(combo_sizeformat.ItemIndex);
    GlobalFileViewSettings.Thumbnails.UseStorage:= check_remember_thumbs.Checked;
    // these two used to live only on the View menu; the setters refresh
    // the file views and the folder tree when EndUpdate sends the changes
    GlobalFileViewSettings.HiddenFiles:= check_hiddenfiles.Checked;
    GlobalFileViewSettings.ShowExtensions:= check_showext.Checked;

    // display
    GlobalFileViewSettings.BackgroundColor:= color_background.Selected;
    GlobalFileViewSettings.Font.Assign(panel_font.Font);

    // colors
    GlobalFileViewSettings.ExtensionColorsEnabled:= check_extension_colors.Checked;
    WriteExtensionColors;

    // folder text color and attribute background colors
    GlobalFileViewSettings.FolderTextColor:= color_folder.Selected;
    GlobalFileViewSettings.SystemBgColor:= color_attr_system.Selected;
    GlobalFileViewSettings.ReadOnlyBgColor:= color_attr_readonly.Selected;
    GlobalFileViewSettings.HiddenBgColor:= color_attr_hidden.Selected;
    GlobalFileViewSettings.CombinedBgColor:= color_attr_combined.Selected;
  finally
    GlobalFileViewSettings.EndUpdate(true);
  end;
end;

{-------------------------------------------------------------------------------
  Handle Change
-------------------------------------------------------------------------------}
procedure TCE_OptionsPage_Display_FileView.HandleChange(Sender: TObject);
begin
  // enables the Apply button.
  inherited;
end;

{-------------------------------------------------------------------------------
  Enables the background controls of the extension list: the check box needs a
  focused list entry, the color box also needs the check box to be checked.
-------------------------------------------------------------------------------}
procedure TCE_OptionsPage_Display_FileView.UpdateExtBgControls(AHasNode: Boolean);
begin
  check_ext_bg.Enabled:= AHasNode;
  color_extension_bg.Enabled:= AHasNode and check_ext_bg.Checked;
end;

{-------------------------------------------------------------------------------
  HandleExtColorChange
-------------------------------------------------------------------------------}
procedure TCE_OptionsPage_Display_FileView.HandleExtColorChange(
  Sender: TObject);
var
  data: PExtListData;
begin
  if fExtValuesChanging then
  Exit;
  
  if Assigned(list_exts.FocusedNode) then
  begin
    data:= list_exts.GetNodeData(list_exts.FocusedNode);
    data.fBold:= check_ext_bold.Checked;
    data.fItalic:= check_ext_italic.Checked;
    data.fUnderline:= check_ext_underline.Checked;
    data.fColor:= color_extension.Selected;
    data.fBgEnabled:= check_ext_bg.Checked;
    data.fBgColor:= color_extension_bg.Selected;
    UpdateExtBgControls(true);
  end;
  HandleChange(Sender);
end;

{-------------------------------------------------------------------------------
  On but_add.Click
-------------------------------------------------------------------------------}
procedure TCE_OptionsPage_Display_FileView.but_addClick(Sender: TObject);
var
  node: PVirtualNode;
  data: PExtListData;
begin
  node:= list_exts.AddChild(nil);
  data:= list_exts.GetNodeData(node);
  data.fBgColor:= clDefault;  // a zeroed record would mean a black background
  list_exts.Selected[node]:= true;
  list_exts.FocusedNode:= node;
  list_exts.EditNode(node, 0);
end;

{-------------------------------------------------------------------------------
  On but_delete.Click
-------------------------------------------------------------------------------}
procedure TCE_OptionsPage_Display_FileView.but_deleteClick(Sender: TObject);
begin
  list_exts.DeleteSelectedNodes;
  HandleChange(Sender);
end;

{-------------------------------------------------------------------------------
  On but_font.Click
-------------------------------------------------------------------------------}
procedure TCE_OptionsPage_Display_FileView.but_fontClick(Sender: TObject);
begin
  FontDlg.Font.Assign(panel_font.Font);
  if FontDlg.Execute then
  begin
    panel_font.Font.Assign(FontDlg.Font);
    panel_font.Caption:= FontDlg.Font.Name + ' ' + IntToStr(FontDlg.Font.Size) + 'pt';
  end;
end;

{-------------------------------------------------------------------------------
  On color_font.Select
-------------------------------------------------------------------------------}
procedure TCE_OptionsPage_Display_FileView.color_fontSelect(Sender: TObject);
begin
  panel_font.Font.Color:= color_font.Selected;
  color_extension.DefaultColorColor:= panel_font.Font.Color;
  HandleChange(Sender);
end;

{-------------------------------------------------------------------------------
  On color_background.Select
-------------------------------------------------------------------------------}
procedure TCE_OptionsPage_Display_FileView.color_backgroundSelect(
  Sender: TObject);
begin
  panel_font.Color:= color_background.Selected;
  if color_background.Selected = clDefault then
  begin
    color_extension_bg.DefaultColorColor:= clWindow;
  end
  else
  begin
    color_extension_bg.DefaultColorColor:= color_background.Selected;
  end;
  HandleChange(Sender);
end;

{-------------------------------------------------------------------------------
  On list_exts.FreeNode
-------------------------------------------------------------------------------}
procedure TCE_OptionsPage_Display_FileView.list_extsFreeNode(
  Sender: TBaseVirtualTree; Node: PVirtualNode);
var
  data: PExtListData;
begin
  data:= Sender.GetNodeData(Node);
  data.fExtensions:= '';
end;

{-------------------------------------------------------------------------------
  On list_exts.EditCancelled
-------------------------------------------------------------------------------}
procedure TCE_OptionsPage_Display_FileView.list_extsEditCancelled(
  Sender: TBaseVirtualTree; Column: TColumnIndex);
var
  data: PExtListData;
begin
  if assigned(Sender.FocusedNode) then
  begin
    data:= Sender.GetNodeData(Sender.FocusedNode);
    if data.fExtensions = '' then
    Sender.DeleteNode(Sender.FocusedNode);
  end;
end;

{-------------------------------------------------------------------------------
  On list_exts.Edited
-------------------------------------------------------------------------------}
procedure TCE_OptionsPage_Display_FileView.list_extsEdited(
  Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex);
var
  data: PExtListData;
begin
  data:= Sender.GetNodeData(Node);
  if data.fExtensions = '' then
  Sender.DeleteNode(Node);
end;

{-------------------------------------------------------------------------------
  On list_exts.FocusChanged
-------------------------------------------------------------------------------}
procedure TCE_OptionsPage_Display_FileView.list_extsFocusChanged(
  Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex);
var
  data: PExtListData;
begin
  if assigned(Node) then
  begin
    data:= Sender.GetNodeData(Node);
    fExtValuesChanging:= true;
    try
      check_ext_bold.Checked:= data.fBold;
      check_ext_italic.Checked:= data.fItalic;
      check_ext_underline.Checked:= data.fUnderline;
      color_extension.Selected:= data.fColor;
      check_ext_bg.Checked:= data.fBgEnabled;
      color_extension_bg.Selected:= data.fBgColor;
    finally
      fExtValuesChanging:= false;
    end;
  end;
  UpdateExtBgControls(assigned(Node));

  but_delete.Enabled:= assigned(Node);
  check_ext_bold.Enabled:= but_delete.Enabled;
  check_ext_italic.Enabled:= but_delete.Enabled;
  check_ext_underline.Enabled:= but_delete.Enabled;
  color_extension.Enabled:= but_delete.Enabled;
end;

{-------------------------------------------------------------------------------
  On list_exts.GetText
-------------------------------------------------------------------------------}
procedure TCE_OptionsPage_Display_FileView.list_extsGetText(
  Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex;
  TextType: TVSTTextType; var CellText: string);
var
  data: PExtListData;
begin
  data:= Sender.GetNodeData(Node);
  CellText:= data.fExtensions;
end;

{-------------------------------------------------------------------------------
  On list_exts.NewText
-------------------------------------------------------------------------------}
procedure TCE_OptionsPage_Display_FileView.list_extsNewText(
  Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex;
  NewText: string);
var
  data: PExtListData;
begin
  if NewText <> '' then
  begin
    data:= Sender.GetNodeData(Node);
    data.fExtensions:= WideReplaceChar(' ', '', NewText);
  end
  else
  begin
    list_exts.DeleteNode(Node);
  end;
  HandleChange(Sender);
end;

{-------------------------------------------------------------------------------
  Refresh Settings
-------------------------------------------------------------------------------}
procedure TCE_OptionsPage_Display_FileView.RefreshSettings;
var
  tq0, tq, tfreq: Int64;
  tlog: string;

  // TEMPORARY timing code (not compiled): log ms since previous mark
  procedure TMark(const AName: string);
  var
    now: Int64;
  begin
    QueryPerformanceCounter(now);
    tlog:= tlog + ' ' + AName + '=' + IntToStr((now - tq) * 10000 div tfreq) + 'e-1ms;';
    tq:= now;
  end;

  procedure ReadExtensionColors;
  var
    list: TCCStringList;
    i: Integer;
    ws, value: WideString;
    data: PExtListData;
    node: PVirtualNode;
  begin
    list_exts.Clear;
    list:= TCCStringList.Create;
    try
      list.Delimiter:= '|';
      list.DelimitedText:= GlobalFileViewSettings.ExtensionColors;
      for i:= 0 to list.Count - 1 do
      begin
        ws:= list.Strings[i];
        value:= WideGetNextItem(ws, ',');
        value:= WideReplaceChar(';', ',', value);
        if value <> '' then
        begin
          node:= list_exts.AddChild(nil);
          data:= list_exts.GetNodeData(node);

          data.fExtensions:= value;
          data.fColor:= StrToIntDef(WideGetNextItem(ws, ','), clWindowText); // color
          data.fBold:= StrToBoolDef(WideGetNextItem(ws, ','), false);  // bold
          data.fItalic:= StrToBoolDef(WideGetNextItem(ws, ','), false);  // italic
          data.fUnderline:= StrToBoolDef(WideGetNextItem(ws, ','), false);  // underline
          // optional, missing in older settings.xml files
          data.fBgEnabled:= StrToBoolDef(WideGetNextItem(ws, ','), false);  // background enabled
          data.fBgColor:= StrToIntDef(WideGetNextItem(ws, ','), clDefault);  // background color
        end;
      end;
    finally
      list.Free;
    end;
    UpdateExtBgControls(false);
  end;

begin
  QueryPerformanceFrequency(tfreq);
  QueryPerformanceCounter(tq0);
  tq:= tq0;
  tlog:= '';
  // options
  check_fullrowselect.Checked:= GlobalFileViewSettings.FullRowSelect;
  check_selectprev.Checked:= GlobalFileViewSettings.SelectPreviousFolder;
  check_autoselect.Checked:= GlobalFileViewSettings.AutoSelectFirstItem;
  check_autosize_liststyle.Checked:= GlobalFileViewSettings.AutosizeListViewStyle;
  check_sortfoldersfirst.Checked:= GlobalFileViewSettings.SortFolderFirstAlways;
  check_infotips.Checked:= GlobalFileViewSettings.ShowInfoTips;
  check_singleclick.Checked:= GlobalFileViewSettings.SingleClickBrowse;
  check_perfolder.Checked:= GlobalFileViewSettings.PerFolderSettings;
  check_gridlines.Checked:= GlobalFileViewSettings.ShowGridLines;
  check_browse_zip.Checked:= GlobalFileViewSettings.BrowseZipFolders;
  combo_sizeformat.ItemIndex:= Ord(GlobalFileViewSettings.FileSizeFormat);
  check_remember_thumbs.Checked:= GlobalFileViewSettings.Thumbnails.UseStorage;
  check_hiddenfiles.Checked:= GlobalFileViewSettings.HiddenFiles;
  check_showext.Checked:= GlobalFileViewSettings.ShowExtensions;

  TMark('options');
  // display
  color_background.Handle; // <-- hack around bug in TColorBox (http://qc.embarcadero.com/wc/qcmain.aspx?d=85895).
  TMark('bg.handle');
  color_background.Selected:= GlobalFileViewSettings.BackgroundColor;
  TMark('bg.selected');
  panel_font.Color:= GlobalFileViewSettings.BackgroundColor;
  panel_font.Font.Assign(GlobalFileViewSettings.Font);
  panel_font.Caption:= GlobalFileViewSettings.Font.Name + ' ' + IntToStr(GlobalFileViewSettings.Font.Size) + 'pt';
  TMark('font+panel');
  color_font.Handle;
  TMark('font.handle');
  color_font.Selected:= panel_font.Font.Color;
  TMark('font.selected');
  color_extension.DefaultColorColor:= color_font.Selected;
  if color_background.Selected = clDefault then
  begin
    color_extension_bg.DefaultColorColor:= clWindow;
  end
  else
  begin
    color_extension_bg.DefaultColorColor:= color_background.Selected;
  end;

  // colors
  check_extension_colors.Checked:= GlobalFileViewSettings.ExtensionColorsEnabled;
  TMark('ext-check');
  ReadExtensionColors;
  TMark('ReadExtColors');

  // folder text color and attribute background colors
  // (the .Handle lines work around the TColorBox bug mentioned above)
  color_folder.Handle;
  TMark('folder.handle');
  color_folder.Selected:= GlobalFileViewSettings.FolderTextColor;
  TMark('folder.selected');
  color_attr_system.Handle;
  TMark('system.handle');
  color_attr_system.Selected:= GlobalFileViewSettings.SystemBgColor;
  TMark('system.selected');
  color_attr_readonly.Handle;
  TMark('readonly.handle');
  color_attr_readonly.Selected:= GlobalFileViewSettings.ReadOnlyBgColor;
  TMark('readonly.selected');
  color_attr_hidden.Handle;
  TMark('hidden.handle');
  color_attr_hidden.Selected:= GlobalFileViewSettings.HiddenBgColor;
  TMark('hidden.selected');
  color_attr_combined.Handle;
  TMark('combined.handle');
  color_attr_combined.Selected:= GlobalFileViewSettings.CombinedBgColor;
  TMark('combined.selected');
  OutputDebugString(PChar('CA options: Fileview refresh total=' + IntToStr((tq - tq0) * 10000 div tfreq) + 'e-1ms;' + tlog));
end;

{##############################################################################}

initialization
  RegisterOptionsPageClass(TCE_OptionsPage_Display_FileView);

finalization

end.
