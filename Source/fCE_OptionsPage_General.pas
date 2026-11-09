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
//  The Original Code is fCE_OptionsPage_General.pas.                                                            
//                                                                                            
//  The Initial Developer of the Original Code is Marko Savolainen (cubicreality@gmail.com).  
//  Portions created by Marko Savolainen Copyright (C) Marko Savolainen. All Rights Reserved. 
//                                                                                            
//******************************************************************************

unit fCE_OptionsPage_General;

interface

uses
  // CE Units
  fCE_OptionsDialog, fCE_OptionsCustomPage, CE_LanguageEngine, dCE_Images,
  // System Units
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, SpTBXControls, SpTBXItem;

type
  TCEOptionsPage_General = class(TCEOptionsCustomPage)
    radio_default: TRadioButton;
    group_startup: TSpTBXGroupBox;
    radio_lasttime: TRadioButton;
    radio_session: TRadioButton;
    combo_sessions: TComboBox;
    check_tray_enable: TCheckBox;
    check_tray_minimize: TCheckBox;
    check_tray_close: TCheckBox;
    check_tray_start: TCheckBox;
    check_single: TCheckBox;
    group_dfm: TSpTBXGroupBox;
    but_dfm_register: TButton;
    but_dfm_unregister: TButton;
    check_dfm: TCheckBox;
    label_dfm_warning: TSpTBXLabel;
    TntGroupBox1: TSpTBXGroupBox;
    procedure HandleChange(Sender: TObject);
    procedure radioClick(Sender: TObject);
    procedure check_dfmClick(Sender: TObject);
    procedure but_dfm_registerClick(Sender: TObject);
    procedure but_dfm_unregisterClick(Sender: TObject);
  private
    { Private declarations }
    function OwnerWindow: HWND;
  public
    constructor Create(AOwner: TComponent); override;
    class procedure GetPageInfo(out AName, ATitle, APath: WideString;
        out AImageIndex, APosition: Integer); override;
    procedure ApplySettings; override;
    procedure RefreshSettings; override;
    { Public declarations }
  end;

implementation

{$R *.dfm}

uses
  Main, CE_Sessions, MPCommonUtilities, CE_FileUtils, CE_WideCompat;

{-------------------------------------------------------------------------------
  Create an instance of TCEOptionsPage_General
-------------------------------------------------------------------------------}
constructor TCEOptionsPage_General.Create(AOwner: TComponent);
begin
  inherited;
  LoadPageInfo;
end;

{-------------------------------------------------------------------------------
  Get PageInfo: name, title, path, icon and sort position of this page. The Options
  dialog calls this to build its page tree without creating the page.
-------------------------------------------------------------------------------}
class procedure TCEOptionsPage_General.GetPageInfo(out AName, ATitle, APath: WideString;
    out AImageIndex, APosition: Integer);
begin
  AName:= _('General');
  ATitle:= _('General Settings');
  APath:= 'General';
  AImageIndex:= 0;
  APosition:= 0;
end;

{-------------------------------------------------------------------------------
  Apply Settings
-------------------------------------------------------------------------------}
procedure TCEOptionsPage_General.ApplySettings;
begin
  // On Startup
  if radio_lasttime.Checked then
  MainForm.Settings.StartupType:= stLastSession
  else if radio_session.Checked then
  MainForm.Settings.StartupType:= stSession
  else
  MainForm.Settings.StartupType:= stNormal;

  if combo_sessions.ItemIndex > -1 then
  MainForm.Settings.AutoLoadSession:= combo_sessions.Items.Strings[combo_sessions.ItemIndex];
  // Tray Icon
  MainForm.Settings.ShowTray:= check_tray_enable.Checked;
  MainForm.Settings.MinimizeToTray:= check_tray_minimize.Checked;
  MainForm.Settings.CloseToTray:= check_tray_close.Checked;
  MainForm.Settings.StartInTray:= check_tray_start.Checked;
  // Single Instance Only
  MainForm.Settings.SingleInstance:= check_single.Checked;
end;

{-------------------------------------------------------------------------------
  On HandleChange
-------------------------------------------------------------------------------}
procedure TCEOptionsPage_General.HandleChange(Sender: TObject);
begin
  inherited;
  check_tray_minimize.Enabled:= check_tray_enable.Checked;
  check_tray_close.Enabled:= check_tray_enable.Checked;
  check_tray_start.Enabled:= check_tray_enable.Checked;
end;

{-------------------------------------------------------------------------------
  Refresh Settings
-------------------------------------------------------------------------------}
procedure TCEOptionsPage_General.RefreshSettings;
var
  i: Integer;
  ws: WideString;
begin
  // On Startup
  combo_sessions.Clear;
  for i:= 0 to GlobalSessions.Sessions.Count - 1 do
  begin
    combo_sessions.Items.Add(GlobalSessions.Sessions.Items[i].Name);
  end;

  case MainForm.Settings.StartupType of
    stNormal: radio_default.Checked:= true;
    stLastSession: radio_lasttime.Checked:= true;
    stSession: radio_session.Checked:= true;
  end;

  ws:= MainForm.Settings.AutoLoadSession;
  if ws <> '' then
  combo_sessions.ItemIndex:= combo_sessions.Items.IndexOf(ws);

  // Tray Icon
  check_tray_enable.Checked:= MainForm.Settings.ShowTray;
  check_tray_minimize.Checked:= MainForm.Settings.MinimizeToTray;
  check_tray_close.Checked:= MainForm.Settings.CloseToTray;
  check_tray_start.Checked:= MainForm.Settings.StartInTray;

  // Single Instance Only
  check_single.Checked:= MainForm.Settings.SingleInstance;

  // Default File Manager: the group is hidden every time the page is shown (this check box
  // is not a setting; it only guards the Register and Unregister buttons).
  check_dfm.Checked:= false;
  group_dfm.Visible:= false;

  check_tray_minimize.Enabled:= check_tray_enable.Checked;
  check_tray_close.Enabled:= check_tray_enable.Checked;
  check_tray_start.Enabled:= check_tray_enable.Checked;  
end;

{-------------------------------------------------------------------------------
  On Radio Click
-------------------------------------------------------------------------------}
procedure TCEOptionsPage_General.radioClick(Sender: TObject);
begin
  HandleChange(Sender);
  combo_sessions.Enabled:= radio_session.Checked;
end;

{-------------------------------------------------------------------------------
  Window that owns the message boxes
-------------------------------------------------------------------------------}
function TCEOptionsPage_General.OwnerWindow: HWND;
var
  f: TCustomForm;
begin
  f:= GetParentForm(Self);
  if assigned(f) then
  begin
    Result:= f.Handle;
  end
  else
  begin
    Result:= Application.Handle;
  end;
end;

{-------------------------------------------------------------------------------
  Show or hide the Default File Manager group.  Not a setting: the check box is never
  saved and does not enable Apply.
-------------------------------------------------------------------------------}
procedure TCEOptionsPage_General.check_dfmClick(Sender: TObject);
begin
  group_dfm.Visible:= check_dfm.Checked;
end;

{-------------------------------------------------------------------------------
  Register as Default File Manager (asks first, then reports the result)
-------------------------------------------------------------------------------}
procedure TCEOptionsPage_General.but_dfm_registerClick(Sender: TObject);
begin
  if WideMessageBox(OwnerWindow, _('Default File Manager'),
                    _('Make CubicAdventurer the default file manager? Windows will open folders with it. Only your own Windows account is changed, and Unregister restores the previous setting.'),
                    MB_ICONQUESTION or MB_YESNO) <> idYes then
  begin
    Exit; // -->
  end;

  if RegisterDefaultFileManager(CE_DefaultFileManagerName, 'Open in CubicAdventurer', ParamStr(0)) then
  begin
    WideMessageBox(OwnerWindow, _('Default File Manager'), _('Registered successfully!'), MB_ICONINFORMATION or MB_OK);
  end
  else
  begin
    WideMessageBox(OwnerWindow, _('Default File Manager'), _('Registration failed!'), MB_ICONERROR or MB_OK);
  end;
end;

{-------------------------------------------------------------------------------
  Unregister as Default File Manager (asks first, then reports the result)
-------------------------------------------------------------------------------}
procedure TCEOptionsPage_General.but_dfm_unregisterClick(Sender: TObject);
begin
  if WideMessageBox(OwnerWindow, _('Default File Manager'),
                    _('Stop using CubicAdventurer as the default file manager and restore the previous setting?'),
                    MB_ICONQUESTION or MB_YESNO) <> idYes then
  begin
    Exit; // -->
  end;

  if UnRegisterDefaultFileManager(CE_DefaultFileManagerName) then
  begin
    WideMessageBox(OwnerWindow, _('Default File Manager'), _('Unregistered successfully!'), MB_ICONINFORMATION or MB_OK);
  end
  else
  begin
    WideMessageBox(OwnerWindow, _('Default File Manager'), _('Unregistration failed!'), MB_ICONERROR or MB_OK);
  end;
end;

{##############################################################################}

initialization
  RegisterOptionsPageClass(TCEOptionsPage_General);

finalization

end.
