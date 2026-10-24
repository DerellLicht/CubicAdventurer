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
//  The Original Code is JvDockInfo.pas, released on 2003-12-31.                                                        
//                                                                                            
//  The Initial Developer of the Original Code is luxiaoban.  
//  Portions created by luxiaoban Copyright (C) 2002,2003 luxiaoban. All Rights Reserved. 
//                                                                                            
//******************************************************************************

unit CE_DockInfo;

interface

uses
  CE_Utils,

  Windows, IniFiles, Registry, Classes, Controls, Forms,

  JvAppStorage,
  JvDockControlForm, JvDockSupportClass, JvDockSupportProc, JvDockInfo,
  JvJVCLUtils,

  CEJvDockVSNetStyleTBX;

type
  TCEDockInfoTree = class;

  TCEDockInfoStyle = (isNone, isReadInfo, isWriteInfo);
  
  TCEDockInfoTree = class(TJvDockBaseTree)
  private

    FAppStorage: TJvCustomAppStorage;
    FAppStoragePath: string;
    FCEDockInfoStyle: TCEDockInfoStyle;
    FDataStream: TMemoryStream;
    fHandleMainForm: Boolean;
    function FindDockForm(const FormName: string): TCustomForm;
    function CreateHostControl(ATreeZone: TJvDockInfoZone): TWinControl;
  protected
    procedure ScanTreeZone(TreeZone: TJvDockBaseZone); override;
    procedure CreateZoneAndAddInfoFromAppStorage; virtual;
    procedure SetDockControlInfo(ATreeZone: TJvDockInfoZone); virtual;
  public
    constructor Create(TreeZone: TJvDockTreeZoneClass); override;
    destructor Destroy; override;

    procedure CreateZoneAndAddInfoFromApp(Control: TControl); virtual;

    procedure ReadInfoFromAppStorage;
    procedure WriteInfoToAppStorage;
    property AppStorage: TJvCustomAppStorage read FAppStorage write FAppStorage;
    property AppStoragePath: string read FAppStoragePath write FAppStoragePath;
    property HandleMainForm: Boolean read fHandleMainForm write fHandleMainForm;
  end;

implementation

uses
  SysUtils,
  JvDockGlobals, JvDockVSNetStyle, Main, fCE_DockHostForm;

//=== Local procedures =======================================================

function FindDockForm(const FormName: string): TCustomForm;
begin
  if Pos(RsDockJvDockInfoSplitter, FormName) > 0 then
    Result := nil
  else
    Result := JvDockFindDockFormWithName(FormName);
end;

function FindDockPanel(const ControlName: string): TWinControl;
var
  Index: Word;
  DockServer: TJvDockServer;
begin
  Result := nil;
  Index := Pos(RsDockJvDockInfoSplitter, ControlName);
  if Index = 0 then
    Exit;
  Result := FindDockForm(Copy(ControlName, 1, Index - 1));
  if Result <> nil then
  begin
    DockServer := FindDockServer(Result);
    if DockServer <> nil then
      with DockServer do
      begin
        if Pos('TopDockPanel', ControlName) > Index then
          Result := TopDockPanel
        else
        if Pos('LeftDockPanel', ControlName) > Index then
          Result := LeftDockPanel
        else
        if Pos('BottomDockPanel', ControlName) > Index then
          Result := BottomDockPanel
        else
        if Pos('RightDockPanel', ControlName) > Index then
          Result := RightDockPanel
        else
        if Pos('CustomDockPanel', ControlName) > Index then
          Result := CustomDockPanel;

        // Mantis 3603: No more AV, Result may not always be a TJvDockVSNETPanel
        if (Result is TJvDockVSNETPanel) and (Pos('PopupPanel', ControlName) > 20) then
          Result := (Result as TJvDockVSNETPanel).VSChannel.VSPopupPanel;
      end;
  end;
end;

function FindDockHost(const ControlName: string): TWinControl;
begin
  Result := FindDockForm(ControlName);
  if Result = nil then
    Result := FindDockPanel(ControlName);
end;

function GetChildControlCount(ATreeZone: TJvDockInfoZone): Integer; forward;

{ Name of a control, or 'nil' - for the debug log only }
function CtrlName(AControl: TControl): string;
begin
  if AControl = nil then
  begin
    Result:= 'nil';
  end
  else
  begin
    Result:= AControl.Name;
  end;
end;

{ One-line description of where a dock form currently sits - for the debug log only }
function DescribeDockState(const AFormName: string): string;
var
  f: TCustomForm;
begin
  f:= JvDockFindDockFormWithName(AFormName);
  if f = nil then
  begin
    Result:= AFormName + ' not found';
  end
  else
  begin
    Result:= Format('%s parent=%s hostsite=%s visible=%s',
      [AFormName, CtrlName(f.Parent), CtrlName(f.HostDockSite), BoolToStr(f.Visible, true)]);
  end;
end;

//=== { TCEDockInfoTree } ====================================================

constructor TCEDockInfoTree.Create(TreeZone: TJvDockTreeZoneClass);
begin
  inherited Create(TreeZone);
  FCEDockInfoStyle := isNone;
  FDataStream := TMemoryStream.Create;
end;

destructor TCEDockInfoTree.Destroy;
begin
  inherited Destroy;
  FreeAndNil(FDataStream);
end;

{ Create an TJvDockConjoinHostForm or  TJvDockTabHostForm when restoring a docking layout }
function TCEDockInfoTree.CreateHostControl(ATreeZone: TJvDockInfoZone): TWinControl;
var
  Form: TForm;
  ADockClient: TJvDockClient;
begin
  { The dockinfo data that is saved, contains names of the values of ChildZone.DockControl
    Thus on loading it can be that no form with that DockControl name can be found;
    then DockControl will be nil
  }
  Result := nil;
  case ATreeZone.DockFormStyle of
    dsConjoin:
      if Assigned(TJvDockInfoZone(ATreeZone.ChildZone).DockControl) then
      begin
        Form := TJvDockConjoinHostForm.Create(Application);
        // a form created in code defaults to poDefaultPosOnly, which lets Windows
        // choose the window position and ignores Left/Top when the form floats
        Form.Position := poDesigned;
        ADockClient := FindDockClient(TJvDockInfoZone(ATreeZone.ChildZone).DockControl);
        Result := ADockClient.CreateConjoinPanelClass(Form).Parent;
      end;
    dsTab:
      if Assigned(TJvDockInfoZone(ATreeZone.ChildZone).DockControl) then
      begin
        Form := TJvDockTabHostForm.Create(Application);
        // see the note above: keep the position we set ourselves
        Form.Position := poDesigned;
        Form.ManualDock(MainForm.DockHostForm.CenterPanel);
        ADockClient := FindDockClient(TJvDockInfoZone(ATreeZone.ChildZone).DockControl);
        Result := ADockClient.CreateTabDockClass(Form).Parent;
      end;
  end;
  if Result <> nil then
    Result.Name := ATreeZone.DockFormName;
end;

// CreateZoneAndAddInfoFromApp
//
// Control: TControl - note this is probably actually a TForm
//                    descendant, since this library only supports form docking.
//
// This is the most important function in this class, it basically
// puts the important information from the application form into this
// object.
//
// This is used to take a form that is docked somewhere and extract all the
// docking layout information contained inside it, and add it to this JvDockInfoTree
// object, which can then be iterated through, stored to disk, etc. }

procedure TCEDockInfoTree.CreateZoneAndAddInfoFromApp(Control: TControl);
var
  I: TJvDockPosition; {was TAlign}
  J: Integer;
  TreeZone: TJvDockInfoZone;
  DockBaseControl: TJvDockBaseControl;
  TmpDockPanel: TJvDockPanel;
begin
  TreeZone := TJvDockInfoZone(AddChildZone(CurrTreeZone, nil));
  with TreeZone do
  begin
    ParentName := TJvDockInfoZone(CurrTreeZone).DockFormName;
    SetDockInfoFromControlToNode(Control);
    if Control is TJvDockPanel then
      DockFormName := TJvDockInfoZone(CurrTreeZone).DockFormName +
        RsDockJvDockInfoSplitter + Control.Name
    else
      DockFormName := Control.Name;
    FDataStream.Clear;
    if Control is TJvDockTabHostForm then
      TJvDockTabHostForm(Control).PageControl.SaveToStream(FDataStream)
    else
    if Control is TJvDockConjoinHostForm then
      TJvDockConjoinHostForm(Control).Panel.DockManager.SaveToStream(FDataStream)
    else
    if Control is TJvDockPanel then
      TJvDockPanel(Control).DockManager.SaveToStream(FDataStream);
    DockClientData := JvDockStreamDataToString(FDataStream);
    DockBaseControl := FindDockBaseControl(Control);
    if DockBaseControl <> nil then
    begin
      SetDockInfoFromDockControlToNode(DockBaseControl);
      if Control is TJvDockTabHostForm then
        DockFormStyle := dsTab
      else
      if Control is TJvDockConjoinHostForm then
        DockFormStyle := dsConjoin
      else
        DockFormStyle := dsNormal;
      if DockBaseControl is TJvDockClient then
      begin
        if Control is TJvDockableForm then
          with TJvDockableForm(Control).DockableControl do
            for J := 0 to DockClientCount - 1 do
            begin
              CurrTreeZone := TreeZone;
              CreateZoneAndAddInfoFromApp(DockClients[J]);
              CurrTreeZone := TreeZone.GetParentZone;
            end;
      end
      else
      begin
        // Changed to persist ALL DockPanels, not just Top,Left,Right,Bottom.
        // This is a hardcoded assumption throughout the component that is
        // proving hard to overcome.
        for I := Low(TJvDockPosition) to High(TJvDockPosition) do // There are 5 TJvDockPositions now ! {NEW!}
        begin
          CurrTreeZone := TreeZone;
          TmpDockPanel := TJvDockServer(DockBaseControl).DockPanel[I];
          if Assigned(TmpDockPanel) then
          begin
            CreateZoneAndAddInfoFromApp(TmpDockPanel);
            if TmpDockPanel is TJvDockVSNETPanel then // JvDockVSNetStyle specific:
              CreateZoneAndAddInfoFromApp(TJvDockVSNETPanel(TmpDockPanel).VSChannel.VSPopupPanel);
          end;
          CurrTreeZone := TreeZone.GetParentZone;
        end;
      end;
    end;

    if Control is TJvDockPanel then
    begin
      DockFormStyle := dsDockPanel;
      if Control is TJvDockVSPopupPanel then
        with TJvDockVSPopupPanel(Control) do
          for J := 0 to DockClientCount - 1 do
          begin
            CurrTreeZone := TreeZone;
            CreateZoneAndAddInfoFromApp(TWinControl(DockClients[J]));
            CurrTreeZone := TreeZone.GetParentZone;
          end
      else
        with TJvDockPanel(Control) do
          for J := 0 to DockClientCount - 1 do
          begin
            CurrTreeZone := TreeZone;
            CreateZoneAndAddInfoFromApp(TWinControl(DockClients[J]));
            CurrTreeZone := TreeZone.GetParentZone;
          end;
    end;
  end;
end;


procedure TCEDockInfoTree.CreateZoneAndAddInfoFromAppStorage;
var
  FormList: TStringList;
  CP, CP1: PChar;
  S: string;
  I: Integer;
  OldPath: string;

  // CubicAdventurer: read an integer that will be cast to an enum type.
  // With range checking on, a value outside the enum range makes the cast
  // raise ERangeError (this killed startup when loading a layout.xml written
  // by the original CubicExplorer). An out-of-range value is reported to the
  // debugger event log (OutputDebugString) and replaced by 0 instead.
  function ReadEnumOrd(const Key: string; MaxValue: Integer): Integer;
  begin
    Result:= FAppStorage.ReadInteger(Key);
    if (Result < 0) or (Result > MaxValue) then begin
      OutputDebugString(PChar(Format('CE_DockInfo: %s %s = %d is out of range 0..%d, using 0',
        [FAppStorage.Path, Key, Result, MaxValue])));
      Result:= 0;
    end;
  end;

  procedure CreateZoneAndAddInfo(Index: Integer);
  var
    I: Integer;
    TreeZone: TJvDockInfoZone;
    r: TRect;
  begin
    if FAppStorage.PathExists(FormList[Index]) then
    begin
      TreeZone := TJvDockInfoZone(AddChildZone(CurrTreeZone, nil));
      with FAppStorage do
      begin
        { Move down into the folder of the form.. }
        Path := ConcatPaths([Path, FormList[Index]]);

        TreeZone.DockFormName := FormList[Index];
        TreeZone.ParentName := ReadString('ParentName');
        TreeZone.LastDockSiteName := ReadString('LastDockSiteName');
        
        TreeZone.DockRect:= StrToRect(ReadString('DockLoc', ' '),Rect(0,0,200,200));

        r:= StrToRect(ReadString('UnDockRect', ' '), Rect(0,0,200,200));
        TreeZone.UnDockLeft:= r.Left;
        TreeZone.UnDockTop:= r.Top;
        TreeZone.UnDockWidth:= r.Right;
        TreeZone.UnDockHeight:= r.Bottom;


        TreeZone.LRDockWidth := ReadInteger('LRDockWidth');
        TreeZone.TBDockHeight := ReadInteger('TBDockHeight');
        TreeZone.VSPaneWidth := ReadInteger('VSPaneWidth');
        
        TreeZone.Visible := ReadBoolean('Visible');
        // CubicAdventurer: range checking off for these assignments. JvDock stores
        // BorderStyle in a narrower type than TFormBorderStyle (layout.xml files from
        // the original CubicExplorer contain 5 = bsSizeToolWin), so with range checking
        // on (Debug builds) the assignment raised ERangeError at startup.
        {$IFOPT R+}{$R-}{$DEFINE CE_DOCKINFO_R_WAS_ON}{$ENDIF}
        TreeZone.BorderStyle:= TFormBorderStyle(ReadEnumOrd('BorderStyle', Ord(High(TFormBorderStyle))));
        TreeZone.FormStyle := TFormStyle(ReadEnumOrd('FormStyle', Ord(High(TFormStyle))));
        TreeZone.WindowState := TWindowState(ReadEnumOrd('WindowState', Ord(High(TWindowState))));
        TreeZone.DockFormStyle := TJvDockFormStyle(ReadEnumOrd('DockFormStyle', Ord(High(TJvDockFormStyle))));
        {$IFDEF CE_DOCKINFO_R_WAS_ON}{$R+}{$UNDEF CE_DOCKINFO_R_WAS_ON}{$ENDIF}
        TreeZone.CanDocked := ReadBoolean('CanDocked');
        TreeZone.EachOtherDocked := ReadBoolean('EachOtherDocked');


        TreeZone.LeftDocked := ReadBoolean('LeftDocked');
        TreeZone.TopDocked := ReadBoolean('TopDocked');
        TreeZone.RightDocked := ReadBoolean('RightDocked');
        TreeZone.BottomDocked := ReadBoolean('BottomDocked');
        TreeZone.CustomDocked := ReadBoolean('CustomDocked'); {NEW}
        TreeZone.DockClientData := ReadString('DockClientData');

        { ..and move up a level }
        Path := ConcatPaths([Path, '..']);
      end;
      for I := Index - 1 downto 0 do
      begin
        { Search for forms that have this form (FormList[I]) as parent }
        if FAppStorage.ReadString(FAppStorage.ConcatPaths([FormList[I], 'ParentName'])) = FormList[Index] then
        begin
          CurrTreeZone := TreeZone;
          CreateZoneAndAddInfo(I);
          CurrTreeZone := TreeZone.GetParentZone;
        end;
      end;
    end;
  end;

begin
  FormList := TStringList.Create;
  FCEDockInfoStyle := isReadInfo; // set mode for Scan.
  try
    { Normally, we wouldn't find duplicate names, but if so ignore them otherwise havoc }
    FormList.Duplicates := dupIgnore;
    OldPath := FAppStorage.Path;
    try
      FAppStorage.Path := FAppStorage.ConcatPaths([FAppStorage.Path, AppStoragePath, 'Forms']);
      if FAppStorage.ValueStored('FormNames') then
      begin
        S := FAppStorage.ReadString('FormNames');
        { UniqueString is used because we modify the contents of S after
          casting S to a PChar. S might point to an actual string in a storage,
          as is the case with TJvAppXMLFileStorage. Not using UniqueString would
          change the value in the storage too. }
        UniqueString(S);
        CP := PChar(S);
        CP1 := StrPos(CP, ';');
        while CP1 <> nil do
        begin
          CP1^ := #0;
          FormList.Add(string(CP));
          CP := CP1 + 1;
          CP1 := StrPos(CP, ';');
        end;
        for I := FormList.Count - 1 downto 0 do
          if FAppStorage.ReadString(FAppStorage.ConcatPaths([FormList[I], 'ParentName'])) = '' then
            CreateZoneAndAddInfo(I);
      end;
    finally
      FAppStorage.Path := OldPath;
    end;
  finally
    FormList.Free;
    FCEDockInfoStyle := isNone;
  end;
end;



function TCEDockInfoTree.FindDockForm(const FormName: string): TCustomForm;
begin
  if Pos(RsDockJvDockInfoSplitter, FormName) > 0 then
    Result := nil
  else
    Result := JvDockFindDockFormWithName(FormName);
end;


procedure TCEDockInfoTree.ReadInfoFromAppStorage;

  // A floating tab/conjoin host is a root zone of its own, so the normal scan
  // (children first, then siblings in order) can reach the dock panels before it
  // reaches the host. A panel's saved client list may name that host (it lists
  // it, marked as not inside, when the host was floating), and a name that cannot
  // be found when the list is loaded is dropped. Create such hosts up front so
  // every name already resolves when the panels load their lists.
  procedure CreateFloatingHosts;
  var
    Zone, Child: TJvDockBaseZone;
    InfoZone: TJvDockInfoZone;
  begin
    Zone:= TopTreeZone.ChildZone;
    while Zone <> nil do
    begin
      InfoZone:= TJvDockInfoZone(Zone);
      if (InfoZone.DockFormStyle in [dsTab, dsConjoin]) and (InfoZone.DockFormName <> '') and
         (FindDockHost(InfoZone.DockFormName) = nil) then
      begin
        // same lookup the scan does for a zone's children before it processes the zone
        Child:= InfoZone.ChildZone;
        while Child <> nil do
        begin
          TJvDockInfoZone(Child).DockControl:= FindDockForm(TJvDockInfoZone(Child).DockFormName);
          Child:= Child.NextSibling;
        end;
        if GetChildControlCount(InfoZone) > 1 then
        begin
          CreateHostControl(InfoZone);
        end;
      end;
      Zone:= Zone.NextSibling;
    end;
  end;

begin
  //AppStorage.BeginUpdate;
  try
    CreateZoneAndAddInfoFromAppStorage;
    DoFloatAllForm;
    // (rom) this is disputable
    Application.ProcessMessages;
    try
      FCEDockInfoStyle := isReadInfo;
      CreateFloatingHosts;
      MiddleScanTree(TopTreeZone);
    finally
      FCEDockInfoStyle := isNone;
    end;
  finally
    //AppStorage.EndUpdate;
  end;
end;




procedure TCEDockInfoTree.ScanTreeZone(TreeZone: TJvDockBaseZone);
var
  I: Integer;
  OldPath: string;
  s,s2,s3: string;
begin
  if FCEDockInfoStyle = isReadInfo then { JVCL Mode persistance : READ }
  begin
    for I := 0 to TreeZone.GetChildCount - 1 do
    begin
      with TJvDockInfoZone(TreeZone.GetChildZone(I)) do
      begin
        DockControl := FindDockForm(DockFormName);
//        if assigned(DockControl) then
//        begin
//          if (DockControl.ClassType <> TJvDockTabHostForm) and
//             (DockControl.ClassType <> TCEDockHostForm) then
//          begin
//            DockControl.Tag:= VSPaneWidth;
//          end;
//        end;
      end;
    end;
    SetDockControlInfo(TJvDockInfoZone(TreeZone));
  end
  else
  if FCEDockInfoStyle = isWriteInfo then { JVCL Mode persistance : WRITE }
  begin
    if TreeZone <> TopTreeZone then
    begin
      with TJvDockInfoZone(TreeZone), FAppStorage do
      begin
        OldPath := Path;
        try
          Path := ConcatPaths([Path, AppStoragePath, 'Forms']);
          s2:= Path;
          s:= DockFormName;
          s3:= ParentName;
          WriteString('FormNames', ReadString('FormNames') + DockFormName + ';');
          Path := ConcatPaths([Path, DockFormName]);
          WriteString('ParentName', ParentName);
          WriteString('LastDockSiteName', LastDockSiteName);
          WriteString('DockLoc', RectToStr(DockRect));
          WriteString('UnDockRect', RectToStr(Rect(UnDockLeft, UnDockTop, UnDockWidth, UnDockHeight)));
          WriteBoolean('Visible', Visible);


          if FindDockPanel(DockFormName) = nil then
          begin
            WriteInteger('LRDockWidth', LRDockWidth);
            WriteInteger('TBDockHeight', TBDockHeight);
            WriteInteger('VSPaneWidth', VSPaneWidth);

            WriteInteger('BorderStyle', Integer(BorderStyle));
            WriteInteger('FormStyle', Integer(FormStyle));
            WriteInteger('WindowState', Integer(WindowState));
            WriteInteger('DockFormStyle', Integer(DockFormStyle));
            WriteBoolean('CanDocked', CanDocked);
            WriteBoolean('EachOtherDocked', EachOtherDocked);
            WriteBoolean('LeftDocked', LeftDocked);
            WriteBoolean('TopDocked', TopDocked);
            WriteBoolean('RightDocked', RightDocked);
            WriteBoolean('BottomDocked', BottomDocked);
            WriteBoolean('CustomDocked', CustomDocked); {NEW!}
          end;
          
          WriteString('DockClientData', DockClientData);
        finally
          FAppStorage.Path := OldPath;
        end;
      end;
    end;
  end;
  inherited ScanTreeZone(TreeZone);
end;

{*------------------------------------------------------------------------------
  Float a host/panel that is parked in CenterPanel to its saved screen rect.

  LoadDockedForms first parks every dock form in DockHostForm.CenterPanel.
  For a floating zone (ParentName = '') JVCL then sets Control.BoundsRect to the
  saved rectangle, but a parked form reads it relative to CenterPanel, so the
  window is invisible until something floats it. ManualFloat takes screen
  coordinates, which is what the saved rectangle is.
  The rectangle is ignored when it is too small or no longer on any monitor
  (for example after a monitor was unplugged); the form then stays parked and
  LoadDockedForms floats it near the main window instead.
-------------------------------------------------------------------------------}
procedure FloatParkedFormToSavedRect(AForm: TCustomForm; const ASaved: TRect);
begin
  if (ASaved.Right - ASaved.Left < 100) or (ASaved.Bottom - ASaved.Top < 60) then
  begin
    Exit;
  end;
  if Screen.MonitorFromRect(ASaved, mdNull) = nil then
  begin
    Exit;
  end;
  if AForm is TForm then
  begin
    TForm(AForm).Position := poDesigned;
  end;
  AForm.ManualFloat(ASaved);
end;

function GetChildControlCount(ATreeZone: TJvDockInfoZone): Integer;
var
  Zone: TJvDockBaseZone;
begin
  Result := 0;
  if ATreeZone.ChildZone <> nil then
  begin
    Inc(Result);
    Zone := ATreeZone.ChildZone;
    while Zone.NextSibling <> nil do
    begin
      Zone := Zone.NextSibling;
      if TJvDockInfoZone(Zone).DockControl <> nil then
        Inc(Result);
    end;
  end;
end;

procedure TCEDockInfoTree.SetDockControlInfo(ATreeZone: TJvDockInfoZone);
var
  DockBaseControl: TJvDockBaseControl;
  Host: TWinControl;
begin
  with ATreeZone do
  begin
    if DockFormName = '' then
      Exit;
    Host := FindDockHost(DockFormName);
    // a host created earlier (CreateFloatingHosts) must be reused, not created twice
    if (Host = nil) and (Application.FindComponent(DockFormName) is TWinControl) then
    begin
      Host := TWinControl(Application.FindComponent(DockFormName));
    end;
    if (Host = nil) and (GetChildControlCount(ATreeZone) > 1) then
      Host := CreateHostControl(ATreeZone);
    if (Host <> nil) and (DockClientData <> '') and (FDataStream <> nil) then
    begin
      FDataStream.Clear;

      JvDockStringToStreamData(FDataStream, DockClientData);

      FDataStream.Position := 0;
      if Host is TJvDockTabHostForm then
      begin
        with TJvDockTabHostForm(Host).PageControl do
        begin
          DisableAlign;
          try
            LoadFromStream(FDataStream);
          finally
            EnableAlign;
          end;
        end;
      end
      else
      if Host is TJvDockConjoinHostForm then
      begin
        with TJvDockConjoinHostForm(Host).Panel do
        begin
          DisableAlign;
          try
            DockManager.LoadFromStream(FDataStream);
          finally
            EnableAlign;
          end;
        end;
      end
      else
      if Host is TJvDockPanel then
      begin
        with TJvDockPanel(Host) do
        begin
          DisableAlign;
          try
            DockManager.LoadFromStream(FDataStream);
          finally
            EnableAlign;
          end;
        end;
      end;
    end;
    if Host <> nil then
    begin
      if fHandleMainForm then
      SetDockInfoFromNodeToControl(Host)
      else if Host <> Application.MainForm then
      SetDockInfoFromNodeToControl(Host);

      // Floating zone whose form is parked in CenterPanel: put it at the saved
      // screen position (see FloatParkedFormToSavedRect).
      if (ParentName = '') and (Host is TCustomForm) and
         (Host.Parent = MainForm.DockHostForm.CenterPanel) then
      begin
        FloatParkedFormToSavedRect(TCustomForm(Host), DockRect);
      end;
      DockBaseControl := FindDockBaseControl(Host);
      if DockBaseControl <> nil then
      SetDockInfoFromNodeToDockControl(DockBaseControl);
    end;
  end;
end;


procedure TCEDockInfoTree.WriteInfoToAppStorage;
begin
  AppStorage.BeginUpdate;
  try
    AppStorage.DeleteSubTree(AppStorage.ConcatPaths([AppStoragePath, 'Forms']));
    try
      FCEDockInfoStyle := isWriteInfo;
      MiddleScanTree(TopTreeZone);
    finally
      FCEDockInfoStyle := isNone;
    end;
  finally
    AppStorage.EndUpdate;
  end;
end;


end.

