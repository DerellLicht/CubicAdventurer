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
//  The Original Code is CE_Sessions.pas.                                                            
//                                                                                            
//  The Initial Developer of the Original Code is Marko Savolainen (cubicreality@gmail.com).  
//  Portions created by Marko Savolainen Copyright (C) Marko Savolainen. All Rights Reserved. 
//                                                                                            
//******************************************************************************

unit CE_Sessions;

interface

uses
  // CE Units
  CE_AppSettings, CE_Toolbar, fCE_ItemSelectSaveDlg,
  // fcl-xml
  DOM,
  // SpTBX
  SpTBXItem, TB2Item,
  // System Units
  Classes, SysUtils, StrUtils, Windows, Contnrs, Math, Controls, Dialogs, ExtCtrls;

type
  TCESessionSaveLoadItem = (sliTabs, sliBookmarks, sliLayout);
  TCESessionSaveLoadItems = set of TCESessionSaveLoadItem;

  TCESessionItem = class(TPersistent)
  private
    fAutoSave: Boolean;
    fIsLastTimeSession: Boolean;
    fName: WideString;
    fSaveLoadItems: TCESessionSaveLoadItems;
    fTime: TDateTime;
    function GetTimeStr: string;
    procedure SetAutoSave(const Value: Boolean);
    procedure SetIsLastTimeSession(const Value: Boolean);
    procedure SetTimeStr(const Value: string);
    procedure SetName(const Value: WideString);
    procedure SetSaveLoadItems(const Value: TCESessionSaveLoadItems);
    procedure SetTime(const Value: TDateTime);
  public
    fNode: TDOMElement;
    // Serialized form of the Tabs node as last saved or loaded; used to detect
    // whether the open tabs have changed since (see SaveSessionIfChanged).
    LastSig: AnsiString;
    property Node: TDOMElement read fNode write fNode;
  published
    property AutoSave: Boolean read fAutoSave write SetAutoSave;
    property IsLastTimeSession: Boolean read fIsLastTimeSession write
        SetIsLastTimeSession;
    property TimeStr: string read GetTimeStr write SetTimeStr;
    property Name: WideString read fName write SetName;
    property SaveLoadItems: TCESessionSaveLoadItems read fSaveLoadItems write
        SetSaveLoadItems;
    property Time: TDateTime read fTime write SetTime;
  end;

  TCESessionList = class(TCECustomSettingStorage)
  private
    fRootNodeName: WideString;
    function GetCount: Integer;
    function GetItems(Index: Integer): TCESessionItem;
  protected
    ARootNode: TDOMNode;
    AStorage: TCEAppSettings;
    fItems: TObjectList;
    function CreateTabsNode: TDOMElement;
    function NodeToSig(ANode: TDOMNode): AnsiString;
  public
    constructor Create;
    destructor Destroy; override;
    function AddSession: TCESessionItem;
    procedure ClearSessions;
    function DeleteOldestSession: Boolean;
    function DeleteSession(AIndex: Integer): Boolean;
    function FindSession(AName: WideString): TCESessionItem;
    function GetNewestSession: TCESessionItem;
    function GetSession(AIndex: Integer): TCESessionItem;
    function IndexOf(ASessionName: WideString): Integer; overload;
    function IndexOf(ASession: TCESessionItem): Integer; overload;
    procedure Load(AAppStorage: TCEAppSettings; ANode: TDOMNode); override;
    procedure LoadSession(ASession: TCESessionItem);
    procedure MoveSession(CurIndex: Integer; NewIndex: Integer);
    procedure SaveSession(ASession: TCESessionItem);
    function SaveSessionIfChanged(ASession: TCESessionItem): Boolean;
    procedure SortByTime;
    property Items[Index: Integer]: TCESessionItem read GetItems;
    property RootNodeName: WideString read fRootNodeName write fRootNodeName;
  published
    property Count: Integer read GetCount;
  end;

  TCESessions = class(TCEAppSettings)
  private
    fActiveSession: TCESessionItem;
    fActiveSessionIsHistory: Boolean;
    fAutoLoadSession: TCESessionItem;
    fAutoSaveBlock: Integer;
    fAutoSaveHistory: Boolean;
    fAutoSaveTimer: TTimer;
    fHistoryCount: Integer;
    fSessionHistory: TCESessionList;
    fSessions: TCESessionList;
    function GetActiveSessionIndex: Integer;
    procedure AutoSaveTimerTick(Sender: TObject);
    procedure SaveDlgNameChange(Sender: TObject);
    procedure SetActiveSession(const Value: TCESessionItem);
    procedure SetHistoryCount(const Value: Integer);
  public
    constructor Create;
    destructor Destroy; override;
    procedure AddHistorySession(AIsLastTimeSession: Boolean = false);
    procedure ClearHistory;
    function CloseTabsForNewSession: Boolean;
    procedure Flush;
    procedure LoadAutoSession;
    function LoadFromFile(AFilePath: WideString): Boolean; override;
    procedure LoadLatestHistorySession;
    procedure SaveActiveSession;
    procedure SaveSessionDlg;
    procedure SaveToFile(AFilePath: WideString); override;
    procedure ShowSessionManager;
    property ActiveSession: TCESessionItem read fActiveSession write
        SetActiveSession;
    property ActiveSessionIndex: Integer read GetActiveSessionIndex;
    property ActiveSessionIsHistory: Boolean read fActiveSessionIsHistory;
    property AutoLoadSession: TCESessionItem read fAutoLoadSession write
        fAutoLoadSession;
    property SessionHistory: TCESessionList read fSessionHistory write
        fSessionHistory;
    property Sessions: TCESessionList read fSessions write fSessions;
  published
    property AutoSaveHistory: Boolean read fAutoSaveHistory write fAutoSaveHistory;
    property HistoryCount: Integer read fHistoryCount write SetHistoryCount;
  end;

  TDOMElementHack = class(TDOMElement);

type
  TCESessionsMenuItem = class(TTBGroupItem)
  protected
    procedure FillList; virtual;
  public
    constructor Create(AOwner: TComponent); override;
    procedure InitiateAction; override;
    procedure OnSessionClick(Sender: TObject);
    procedure Recreate; virtual;
  end;

  TCESessionHistoryMenuItem = class(TTBGroupItem)
  protected
    procedure FillList; virtual;
  public
    constructor Create(AOwner: TComponent); override;
    procedure InitiateAction; override;
    procedure OnSessionClick(Sender: TObject);
    procedure Recreate; virtual;
  end;

  TCESessionsToolbar = class(TCEToolbar)
  private
  protected
    procedure OnSessionClick(Sender: TObject); virtual;
    procedure Populate; virtual;
  public
    constructor Create(AOwner: TComponent); override;
    procedure Recreate;
  end;

function CompareSessionTime(Item1, Item2: Pointer): Integer;

function GetSessionNames(AResults: TStrings): Integer;

function CreateSaveSessionDlg(SelectActiveSession: Boolean = true):
    TCEItemSelectSaveDlg;

function GlobalSessions: TCESessions;



implementation

uses
  fCE_TabPage, WideSupport, XMLWrite, Main, CE_SpTabBar,
  fCE_SessionManager, CE_LanguageEngine, dCE_Images, fCE_FileView,
  CE_VistaFuncs, CE_Utils, Forms;

var
  fGlobalSessions: TCESessions;  

{-------------------------------------------------------------------------------
  CompareSessionTime
-------------------------------------------------------------------------------}
function CompareSessionTime(Item1, Item2: Pointer): Integer;
begin
  if TCESessionItem(Item1).Time < TCESessionItem(Item2).Time then
  Result:= -1
  else if TCESessionItem(Item1).Time > TCESessionItem(Item2).Time then
  Result:= 1
  else
  Result:= 0;
end;

{-------------------------------------------------------------------------------
  Get Session Names
-------------------------------------------------------------------------------}
function GetSessionNames(AResults: TStrings): Integer;
var
  i: Integer;
  session: TCESessionItem;
begin
  Result:= -1;
  if assigned(AResults) then
  begin
    AResults.Clear;
    for i:= 0 to GlobalSessions.Sessions.Count - 1 do
    begin
      session:= GlobalSessions.Sessions.Items[i];
      AResults.Add(session.Name);
    end;
  end;
end;

{-------------------------------------------------------------------------------
  Create Save Session Dlg
-------------------------------------------------------------------------------}
function CreateSaveSessionDlg(SelectActiveSession: Boolean = true):
    TCEItemSelectSaveDlg;
var
  i: Integer;
  session: TCESessionItem;
begin
  Result:= TCEItemSelectSaveDlg.Create(nil);
  Result.Caption:= _('Save Session');
  Result.but_ok.Caption:= _('Save');
  Result.label_combotitle.Caption:= _('Session Name');
  Result.ShowExistsWarning:= true;
  Result.ExistsWarningTitle:= _('Confirm');
  Result.ExistsWarningDescription:= _('Override existing session?');
  Result.ExistsWarningContent:= _('Do you want to override existing session?');

  for i:= 0 to GlobalSessions.Sessions.Count - 1 do
  begin
    session:= GlobalSessions.Sessions.Items[i];
    Result.combo.Items.Add(session.Name);
  end;

  if SelectActiveSession and (GlobalSessions.ActiveSessionIndex > -1) then
  begin
    Result.combo.ItemIndex:= GlobalSessions.ActiveSessionIndex;
  end;
  Result.AllowEmptyText:= false;
end;

{-------------------------------------------------------------------------------
  GlobalSessions
-------------------------------------------------------------------------------}
function GlobalSessions: TCESessions;
begin
  if not assigned(fGlobalSessions) then
  begin
    fGlobalSessions:= TCESessions.Create;
    GlobalAppSettings.AddItem('Sessions', fGlobalSessions);
  end;
  Result:= fGlobalSessions;
end;

{##############################################################################}

{-------------------------------------------------------------------------------
  Create an instance of TCESessions
-------------------------------------------------------------------------------}
constructor TCESessions.Create;
begin
  inherited;
  fSessions:= TCESessionList.Create;
  fSessions.RootNodeName:= 'Sessions';
  AddItem('Sessions', fSessions, true);
  fSessions.AStorage:= Self;

  fSessionHistory:= TCESessionList.Create;
  fSessionHistory.RootNodeName:= 'SessionHistory';
  AddItem('SessionHistory', fSessionHistory);
  fSessionHistory.AStorage:= Self;

  fAutoSaveHistory:= false;
  fHistoryCount:= 10;
  fActiveSessionIsHistory:= false;
  fActiveSession:= nil;

  // Timer that writes the active session when its tabs have changed
  // (only for sessions with the "save changes automatically" flag).
  fAutoSaveBlock:= 0;
  fAutoSaveTimer:= TTimer.Create(nil);
  fAutoSaveTimer.Interval:= 3000;
  fAutoSaveTimer.OnTimer:= AutoSaveTimerTick;
  fAutoSaveTimer.Enabled:= true;
end;

{-------------------------------------------------------------------------------
  Destroy TCESessions
-------------------------------------------------------------------------------}
destructor TCESessions.Destroy;
begin
  fAutoSaveTimer.Free;
  fSessions.Free;
  fSessionHistory.Free;
  inherited;
end;

{-------------------------------------------------------------------------------
  Add History Session
-------------------------------------------------------------------------------}
procedure TCESessions.AddHistorySession(AIsLastTimeSession: Boolean = false);
var
  session: TCESessionItem;
  i, c: Integer;
begin
  // Delete/clear previous LastTimeSession
  for i:= 0 to SessionHistory.Count - 1 do
  begin
    if SessionHistory.Items[i].IsLastTimeSession then
    begin
      if AIsLastTimeSession then
      SessionHistory.DeleteSession(i)
      else
      SessionHistory.Items[i].IsLastTimeSession:= false;
    end;
  end;

  // Delete oldest sessions
  c:= fSessionHistory.Count;
  while (c > fHistoryCount-1) and (c > 0) do
  begin
    if not SessionHistory.DeleteOldestSession then
    break;
    c:= fSessionHistory.Count;
  end;

  // Add new session
  session:= SessionHistory.AddSession;
  if AIsLastTimeSession then
  session.IsLastTimeSession:= true;
  
  // Save session
  SessionHistory.SaveSession(session);
end;

{-------------------------------------------------------------------------------
  Clear History
-------------------------------------------------------------------------------}
procedure TCESessions.ClearHistory;
begin
  if (TaskDialog(Application.MainFormHandle,
                 _('Confirm'),
                 _('Clear session history?'),
                 _('Are you sure you want to clear session history?'),
                 TD_ICON_QUESTION,
                 TD_BUTTON_YES + TD_BUTTON_NO) = TD_RESULT_YES) then
  begin
    SessionHistory.ClearSessions;
  end;
end;

{-------------------------------------------------------------------------------
  Auto Save Timer Tick

  Runs every few seconds. If the active session is one of the user's saved
  sessions and has "Save changes automatically" set, and its tabs differ from
  what was last saved, the session is updated and sessions.xml is written.
  Does nothing while a session is being loaded or closed, during start-up and
  shutdown, or when no tab is open (an empty tab set must never overwrite a
  session).
-------------------------------------------------------------------------------}
procedure TCESessions.AutoSaveTimerTick(Sender: TObject);
begin
  if fAutoSaveBlock > 0 then
  begin
    Exit;
  end;
  if not assigned(fActiveSession) or fActiveSessionIsHistory or not fActiveSession.AutoSave then
  begin
    Exit;
  end;
  if not assigned(MainForm) or not MainForm.IsReady or MainForm.CEIsClosing then
  begin
    Exit;
  end;
  if MainForm.TabSet.TabCount = 0 then
  begin
    Exit;
  end;
  try
    if Sessions.SaveSessionIfChanged(fActiveSession) then
    begin
      Flush;
    end;
  except
    on E: Exception do
    begin
      OutputDebugString(PChar('CA sessions: automatic save failed: ' + E.Message));
    end;
  end;
end;

{-------------------------------------------------------------------------------
  Close Tabs For New Session

  Prepares "New Session": the current tabs are kept first (updated into the
  active session if that has the automatic-save flag, and added to History if
  Auto Save History is on), then all tabs are closed and no session is active.
  Returns false if a tab refused to close; the caller then opens nothing.
-------------------------------------------------------------------------------}
function TCESessions.CloseTabsForNewSession: Boolean;
begin
  Inc(fAutoSaveBlock);
  try
    if assigned(fActiveSession) and not fActiveSessionIsHistory and fActiveSession.AutoSave then
    begin
      SaveActiveSession;
    end;
    if AutoSaveHistory then
    begin
      AddHistorySession;
    end;
    Result:= MainForm.TabSet.CloseAllTabs;
    if Result then
    begin
      // Not through SetActiveSession: that would save the (now empty) tab set.
      fActiveSession:= nil;
      fActiveSessionIsHistory:= false;
      MainForm.SessionsToolbar.Recreate;
      Flush;
    end;
  finally
    Dec(fAutoSaveBlock);
  end;
end;

{-------------------------------------------------------------------------------
  Flush

  Writes sessions.xml to the settings folder now, instead of waiting for the
  program to exit. Does nothing when settings are read-only.
-------------------------------------------------------------------------------}
procedure TCESessions.Flush;
begin
  if ReadOnlySettings or (SettingsDirPath = '') then
  begin
    Exit;
  end;
  SaveToFile(SettingsDirPath + 'sessions.xml');
end;

{-------------------------------------------------------------------------------
  Load From File (adds a diagnostic line to the Event Log)
-------------------------------------------------------------------------------}
function TCESessions.LoadFromFile(AFilePath: WideString): Boolean;
begin
  Result:= inherited LoadFromFile(AFilePath);
  OutputDebugString(PChar(Format('CA sessions: load %s from %s: %d sessions, %d history entries',
    [BoolToStr(Result, true), AFilePath, Sessions.Count, SessionHistory.Count])));
end;

{-------------------------------------------------------------------------------
  Get Active Session Index
-------------------------------------------------------------------------------}
function TCESessions.GetActiveSessionIndex: Integer;
begin
  if ActiveSessionIsHistory then
  Result:= SessionHistory.fItems.IndexOf(ActiveSession)
  else
  Result:= Sessions.fItems.IndexOf(ActiveSession);
end;

{-------------------------------------------------------------------------------
  Load Auto Session
-------------------------------------------------------------------------------}
procedure TCESessions.LoadAutoSession;
begin
  ActiveSession:= AutoLoadSession;
end;

{-------------------------------------------------------------------------------
  Load Latest History Session
-------------------------------------------------------------------------------}
procedure TCESessions.LoadLatestHistorySession;
begin
  ActiveSession:= SessionHistory.GetNewestSession;
end;

{-------------------------------------------------------------------------------
  Save Active Session
-------------------------------------------------------------------------------}
procedure TCESessions.SaveActiveSession;
begin
  if assigned(ActiveSession) then
  begin
    if Sessions.fItems.IndexOf(ActiveSession) > -1 then
    Sessions.SaveSession(ActiveSession)
    else if SessionHistory.fItems.IndexOf(ActiveSession) > -1 then
    SessionHistory.SaveSession(ActiveSession);
  end;
end;

{-------------------------------------------------------------------------------
  Save Dlg Name Change

  When the name in the Save Session dialog matches an existing session, the
  automatic-save check box shows that session's current setting.
-------------------------------------------------------------------------------}
procedure TCESessions.SaveDlgNameChange(Sender: TObject);
var
  dlg: TCEItemSelectSaveDlg;
  session: TCESessionItem;
begin
  dlg:= TCEItemSelectSaveDlg(Sender);
  session:= Sessions.FindSession(dlg.combo.Text);
  if assigned(session) then
  begin
    dlg.OptionChecked:= session.AutoSave;
  end;
end;

{-------------------------------------------------------------------------------
  Save Session Dlg
-------------------------------------------------------------------------------}
procedure TCESessions.SaveSessionDlg;
var
  dlg: TCEItemSelectSaveDlg;
  session: TCESessionItem;
begin
  dlg:= CreateSaveSessionDlg;
  try
    dlg.ShowOption(_('Save changes to this session automatically'), false);
    SaveDlgNameChange(dlg);
    dlg.OnNameChange:= SaveDlgNameChange;
    if dlg.ShowModal = mrOK then
    begin
      session:= Sessions.FindSession(dlg.combo.Text);
      if not assigned(session) then
      begin
        session:= Sessions.AddSession;
        session.Name:= dlg.combo.Text;
      end;
      session.AutoSave:= dlg.OptionChecked;
      Sessions.SaveSession(session);
      // The session just saved becomes the active one (so its automatic-save
      // flag applies from now on), and sessions.xml is written immediately.
      fActiveSession:= session;
      fActiveSessionIsHistory:= false;
      Flush;
      MainForm.SessionsToolbar.Recreate;
    end;
  finally
    dlg.Free;
  end;
end;

{-------------------------------------------------------------------------------
  Save To File
-------------------------------------------------------------------------------}
procedure TCESessions.SaveToFile(AFilePath: WideString);
var
  FileStream: TStream;
begin
  try
    FileStream:= TWideFileStream.Create(AFilePath, fmCreate);
  except
    on E: Exception do
    begin
      OutputDebugString(PChar('CA sessions: cannot write ' + AFilePath + ': ' + E.Message));
      Exit;
    end;
  end;
  
  try
    if not assigned(XML.DocumentElement) then
    XML.AppendChild(XML.CreateElement('CubicExplorer'));
    WriteXML(XML.DocumentElement, FileStream);
  finally
    FileStream.Free;
  end;
  OutputDebugString(PChar(Format('CA sessions: saved %d sessions, %d history entries to %s',
    [Sessions.Count, SessionHistory.Count, AFilePath])));
end;

{-------------------------------------------------------------------------------
  Active Session
-------------------------------------------------------------------------------}
procedure TCESessions.SetActiveSession(const Value: TCESessionItem);
begin
  // AutoSave Previous session
  if assigned(ActiveSession) then
  begin
    if ActiveSession.AutoSave then
    SaveActiveSession;
  end;
  // Load session (the automatic-save timer must not run meanwhile)
  Inc(fAutoSaveBlock);
  try
    fActiveSession:= Value;
    if assigned(fActiveSession) then
    begin
      if Sessions.fItems.IndexOf(fActiveSession) > -1 then
      begin
        Sessions.LoadSession(fActiveSession);
        fActiveSessionIsHistory:= false;
      end
      else if SessionHistory.fItems.IndexOf(fActiveSession) > -1 then
      begin
        SessionHistory.LoadSession(fActiveSession);
        fActiveSessionIsHistory:= true;
      end
      else
      begin
        fActiveSessionIsHistory:= false;
        fActiveSession:= nil;
      end;
    end;
  finally
    Dec(fAutoSaveBlock);
  end;
  MainForm.SessionsToolbar.Recreate;
end;

{-------------------------------------------------------------------------------
  Set History Count
-------------------------------------------------------------------------------}
procedure TCESessions.SetHistoryCount(const Value: Integer);
begin
  fHistoryCount:= Max(Value, 0);
  while (fSessionHistory.Count > fHistoryCount) and (fSessionHistory.Count > 0) do
  begin
    SessionHistory.DeleteOldestSession;
  end;
end;

{-------------------------------------------------------------------------------
  Show Session Manager
-------------------------------------------------------------------------------}
procedure TCESessions.ShowSessionManager;
var
  manager: TCESessionManager;
begin
  manager:= TCESessionManager.Create(nil);
  try
    manager.PopupParent:= MainForm;
    manager.ShowModal;
  finally
    manager.Free;
    MainForm.SessionsToolbar.Recreate;
    // names, order, deletions and the automatic-save flags changed in the dialog
    Flush;
  end;
end;

{##############################################################################}

{-------------------------------------------------------------------------------
  Create an instance of TCESessionList
-------------------------------------------------------------------------------}
constructor TCESessionList.Create;
begin
  inherited;
  fItems:= TObjectList.Create(true);
end;

{-------------------------------------------------------------------------------
  Destroy TCESessionList
-------------------------------------------------------------------------------}
destructor TCESessionList.Destroy;
begin
  fItems.Free;
  inherited;
end;

{-------------------------------------------------------------------------------
  Add Session
-------------------------------------------------------------------------------}
function TCESessionList.AddSession: TCESessionItem;
begin
  Result:= TCESessionItem.Create;
  fItems.Add(Result);
  Result.Node:= AStorage.XML.CreateElement('Session');
  if not assigned(ARootNode) then
  begin
    ARootNode:= AStorage.XML.CreateElement(RootNodeName);
    AStorage.XML.DocumentElement.AppendChild(ARootNode);
  end;
  ARootNode.AppendChild(Result.Node);
end;

{-------------------------------------------------------------------------------
  Clear Sessions
-------------------------------------------------------------------------------}
procedure TCESessionList.ClearSessions;
var
  i: Integer;
  session: TCESessionItem;
begin
  for i:= 0 to fItems.Count - 1 do
  begin
    session:= TCESessionItem(fItems.Items[i]);
    if assigned(session.Node) then
    begin
      if assigned(ARootNode) then
      ARootNode.RemoveChild(session.Node);
    end;
  end;
  fItems.Clear;
end;

{-------------------------------------------------------------------------------
  Delete Oldest Session
-------------------------------------------------------------------------------}
function TCESessionList.DeleteOldestSession: Boolean;
var
  i, index: Integer;
  d: TDateTime;
begin
  d:= 0;
  index:= -1;
  for i:= 0 to fItems.Count - 1 do
  begin
    if (TCESessionItem(fItems.Items[i]).Time < d) or (i = 0) then
    begin
      d:= TCESessionItem(fItems.Items[i]).Time;
      index:= i;
    end;
  end;
  Result:= index > -1;
  if Result then
  DeleteSession(index);
end;

{-------------------------------------------------------------------------------
  Delete Session
-------------------------------------------------------------------------------}
function TCESessionList.DeleteSession(AIndex: Integer): Boolean;
var
  session: TCESessionItem;
begin
  Result:= (AIndex > -1) and (AIndex < fItems.Count);
  if Result then
  begin
    session:= TCESessionItem(fItems.Items[AIndex]);
    if assigned(session.Node) then
    begin
      if assigned(ARootNode) then
      ARootNode.RemoveChild(session.Node);
    end;
    fItems.Delete(AIndex);
  end;
end;

{-------------------------------------------------------------------------------
  Find Session
-------------------------------------------------------------------------------}
function TCESessionList.FindSession(AName: WideString): TCESessionItem;
var
  i: Integer;
  session: TCESessionItem;
begin
  Result:= nil;
  for i:= 0 to fItems.Count - 1 do
  begin
    session:= TCESessionItem(fItems.Items[i]);
    if session.Name = AName then
    begin
      Result:= session;
      break;
    end;
  end;
end;

{-------------------------------------------------------------------------------
  Get Count
-------------------------------------------------------------------------------}
function TCESessionList.GetCount: Integer;
begin
  Result:= fItems.Count;
end;

{-------------------------------------------------------------------------------
  Get Items
-------------------------------------------------------------------------------}
function TCESessionList.GetItems(Index: Integer): TCESessionItem;
begin
  Result:= TCESessionItem(fItems.Items[Index]);
end;

{-------------------------------------------------------------------------------
  Get Newest Session
-------------------------------------------------------------------------------}
function TCESessionList.GetNewestSession: TCESessionItem;
var
  i: Integer;
  d: TDateTime;
begin
  Result:= nil;
  d:= 0;
  for i:= 0 to fItems.Count - 1 do
  begin
    if (TCESessionItem(fItems.Items[i]).Time > d) or (i = 0) then
    begin
      d:= TCESessionItem(fItems.Items[i]).Time;
      Result:= TCESessionItem(fItems.Items[i]);
    end;
  end;
end;

{-------------------------------------------------------------------------------
  Get Session
-------------------------------------------------------------------------------}
function TCESessionList.GetSession(AIndex: Integer): TCESessionItem;
begin
  Result:= TCESessionItem(fItems.Items[AIndex]);
end;

{-------------------------------------------------------------------------------
  Index Of
-------------------------------------------------------------------------------}
function TCESessionList.IndexOf(ASessionName: WideString): Integer;
var
  i: Integer;
begin
  Result:= -1;
  for i:= 0 to fItems.Count - 1 do
  begin
    if TCESessionItem(fItems.Items[i]).Name = ASessionName then
    begin
      Result:= i;
      Break;
    end;
  end;
end;

{-------------------------------------------------------------------------------
  Index Of
-------------------------------------------------------------------------------}
function TCESessionList.IndexOf(ASession: TCESessionItem): Integer;
begin
  Result:= fItems.IndexOf(ASession);
end;

{-------------------------------------------------------------------------------
  Load
-------------------------------------------------------------------------------}
procedure TCESessionList.Load(AAppStorage: TCEAppSettings; ANode: TDOMNode);
var
  item: TCESessionItem;
  chNode, chNode2: TDOMNode;
  sli: TCESessionSaveLoadItems;
begin
  AStorage:= AAppStorage;
  ARootNode:= ANode;
  fItems.Clear;
  chNode:= ANode.FirstChild;
  while assigned(chNode) do
  begin
    if chNode.NodeName = 'Session' then
    begin
      item:= TCESessionItem.Create;
      item.fName:= TDOMElement(chNode).AttribStrings['name'];
      item.TimeStr:= TDOMElement(chNode).AttribStrings['time'];
      item.fAutoSave:= StrToBoolDef(TDOMElement(chNode).AttribStrings['autosave'], false);
      item.fIsLastTimeSession:= StrToBoolDef(TDOMElement(chNode).AttribStrings['last'], false);

      sli:= [];
      chNode2:= chNode.FirstChild;
      while assigned(chNode2) do
      begin
        if chNode2.NodeName = 'Tabs' then
        Include(sli, sliTabs)
        else if chNode2.NodeName = 'Bookmarks' then
        Include(sli, sliBookmarks)
        else if chNode2.NodeName = 'Layout' then
        Include(sli, sliLayout);
        chNode2:= chNode2.NextSibling;
      end;
      item.SaveLoadItems:= sli;

      item.Node:= TDOMElement(chNode);
      fItems.Add(item);
    end;
    chNode:= chNode.NextSibling;
  end;
end;

{-------------------------------------------------------------------------------
  Load Session
-------------------------------------------------------------------------------}
procedure TCESessionList.LoadSession(ASession: TCESessionItem);

  procedure LoadTabs(ATabsNode: TDOMNode);
  var
    chNode: TDOMNode;
    pageClass: TCECustomTabPageClass;
    page: TCECustomTabPage;
  begin
    chNode:= ATabsNode.FirstChild;
    while assigned(chNode) do
    begin
      pageClass:= TabPageClassList.GetClass(chNode.NodeName);
      if pageClass <> nil then
      begin
        page:= MainForm.TabSet.AddTab(pageClass, false, false).Page;

        AStorage.LoadObjectProperties(page.Settings, chNode);

        page.Active:= true;
        page.UpdateCaption;
      end;
      chNode:= chNode.NextSibling;
    end;
    MainForm.TabSet.CEActiveTabIndex:= StrToIntDef(TDOMElement(ATabsNode).AttribStrings['active'], 0);
    MainForm.TabSet.MakeSureTabIsSelected;
  end;

var
  chNode: TDOMNode;
  tabsNode: TDOMElement;
begin
  if assigned(ASession) then
  begin
    MainForm.BeginUIUpdate;
    try
      MainForm.TabSet.CloseAllTabs;
      chNode:= ASession.Node.FirstChild;
      while assigned(chNode) do
      begin
        if chNode.NodeName = 'Tabs' then
        begin
          LoadTabs(chNode);
        end;
        chNode:= chNode.NextSibling;
      end;
      tabsNode:= CreateTabsNode;
      try
        ASession.LastSig:= NodeToSig(tabsNode);
      finally
        tabsNode.Free;
      end;
    finally
      MainForm.EndUIUpdate;
    end;
  end;
end;

{-------------------------------------------------------------------------------
  Move Session
-------------------------------------------------------------------------------}
procedure TCESessionList.MoveSession(CurIndex: Integer; NewIndex: Integer);
var
  session, session2: TCESessionItem;
begin
  if CurIndex = NewIndex then
  Exit;
  
  session:= GetSession(CurIndex);
  if CurIndex > NewIndex then
  session2:= GetSession(NewIndex)
  else if (NewIndex + 1) < fItems.Count then
  session2:= GetSession(NewIndex+1)
  else
  session2:= nil;

  if assigned(session2) then
  ARootNode.InsertBefore(session.Node, session2.Node)
  else
  ARootNode.AppendChild(session.Node);
  fItems.Move(CurIndex, NewIndex);
end;

{-------------------------------------------------------------------------------
  Create Tabs Node

  Builds a new, unattached 'Tabs' element describing the tabs that are open
  now (one child per tab, plus the 'active' attribute). The caller attaches it
  to a session node or frees it.
-------------------------------------------------------------------------------}
function TCESessionList.CreateTabsNode: TDOMElement;
var
  chNode: TDOMNode;
  tab: TCESpTabItem;
  i: Integer;
  s: String;
begin
  Result:= AStorage.XML.CreateElement('Tabs');
  for i:= 0 to MainForm.TabSet.Items.Count - 1 do
  begin
    if MainForm.TabSet.Items.Items[i] is TCESpTabItem then
    begin
      tab:= TCESpTabItem(MainForm.TabSet.Items.Items[i]);
      if assigned(tab.Page) then
      begin
        s:= TabPageClassList.GetName(TCECustomTabPageClass(tab.Page.ClassType));
        if s <> '' then
        begin
          chNode:= AStorage.XML.CreateElement(s);
          Result.AppendChild(chNode);
          AStorage.SaveObjectProperties(tab.Page.Settings, chNode);
        end;
      end;
    end;
  end;
  Result.AttribStrings['active']:= IntToStr(MainForm.TabSet.CEActiveTabIndex);
end;

{-------------------------------------------------------------------------------
  Node To Sig (serialize a node to a string, for comparing two states)
-------------------------------------------------------------------------------}
function TCESessionList.NodeToSig(ANode: TDOMNode): AnsiString;
var
  ms: TMemoryStream;
begin
  ms:= TMemoryStream.Create;
  try
    WriteXML(ANode, ms);
    SetString(Result, PAnsiChar(ms.Memory), ms.Size);
  finally
    ms.Free;
  end;
end;

{-------------------------------------------------------------------------------
  Save Session
-------------------------------------------------------------------------------}
procedure TCESessionList.SaveSession(ASession: TCESessionItem);
var
  chNode: TDOMElement;
begin
  if assigned(ASession) then
  begin
    TDOMElementHack(ASession.Node).FreeChildren;
    // TODO: Session SaveLoadItems
    // Tabs
    chNode:= CreateTabsNode;
    ASession.Node.AppendChild(chNode);
    ASession.LastSig:= NodeToSig(chNode);
    // Time
    ASession.Time:= Now;
  end;
end;

{-------------------------------------------------------------------------------
  Save Session If Changed

  Saves the open tabs into ASession only when they differ from what the
  session holds (compared as serialized text). Returns true if the session
  was changed, so the caller knows sessions.xml has to be written.
-------------------------------------------------------------------------------}
function TCESessionList.SaveSessionIfChanged(ASession: TCESessionItem): Boolean;
var
  newNode: TDOMElement;
  sig: AnsiString;
begin
  Result:= false;
  if assigned(ASession) then
  begin
    newNode:= CreateTabsNode;
    sig:= NodeToSig(newNode);
    if sig = ASession.LastSig then
    begin
      newNode.Free;
    end
    else
    begin
      TDOMElementHack(ASession.Node).FreeChildren;
      ASession.Node.AppendChild(newNode);
      ASession.LastSig:= sig;
      ASession.Time:= Now;
      Result:= true;
    end;
  end;
end;

{-------------------------------------------------------------------------------
  Sort By Time
-------------------------------------------------------------------------------}
procedure TCESessionList.SortByTime;
begin
  fItems.Sort(@CompareSessionTime);
end;

{##############################################################################}

{-------------------------------------------------------------------------------
  Set Name
-------------------------------------------------------------------------------}
procedure TCESessionItem.SetName(const Value: WideString);
begin
  fName:= Value;
  if assigned(fNode) then
  fNode.AttribStrings['name']:= Value;
end;

{-------------------------------------------------------------------------------
  Get/Set TimeStr
-------------------------------------------------------------------------------}
function TCESessionItem.GetTimeStr: string;
var
  fs: TFormatSettings;
begin
  fs.DateSeparator:= '/';
  fs.TimeSeparator:= ':';
  fs.LongTimeFormat:= 'hh:nn:ss';
  fs.ShortDateFormat:= 'dd/mm/yyyy';
  Result:= DateTimeToStr(Self.Time, fs);
end;
procedure TCESessionItem.SetTimeStr(const Value: string);
var
  fs: TFormatSettings;
begin
  fs.DateSeparator:= '/';
  fs.TimeSeparator:= ':';
  fs.LongTimeFormat:= 'hh:nn:ss';
  fs.ShortDateFormat:= 'dd/mm/yyyy';
  try
    Self.Time:= StrToDateTime(Value, fs);
  except

  end;
end;

{-------------------------------------------------------------------------------
  Set AutoSave
-------------------------------------------------------------------------------}
procedure TCESessionItem.SetAutoSave(const Value: Boolean);
begin
  fAutoSave:= Value;
  if assigned(fNode) then
  fNode.AttribStrings['autosave']:= BoolToStr(fAutoSave, true);
end;

{-------------------------------------------------------------------------------
  Set IsLastTimeSession
-------------------------------------------------------------------------------}
procedure TCESessionItem.SetIsLastTimeSession(const Value: Boolean);
begin
  fIsLastTimeSession:= Value;
  if assigned(fNode) then
  begin
    if Value then
    fNode.AttribStrings['last']:= BoolToStr(Value, true)
    else
    fNode.Attributes.RemoveNamedItem('last');
  end;
end;

{-------------------------------------------------------------------------------
  Set SaveLoadItems
-------------------------------------------------------------------------------}
procedure TCESessionItem.SetSaveLoadItems(const Value: TCESessionSaveLoadItems);
begin
  // TODO: Session SaveLoadItems
  fSaveLoadItems:= Value;
  if assigned(fNode) then
  begin

  end;
end;

{-------------------------------------------------------------------------------
  Set Time
-------------------------------------------------------------------------------}
procedure TCESessionItem.SetTime(const Value: TDateTime);
var
  fs: TFormatSettings;
begin
  fs.DateSeparator:= '/';
  fs.TimeSeparator:= ':';
  fs.LongTimeFormat:= 'hh:nn:ss';
  fs.ShortDateFormat:= 'dd/mm/yyyy';
  fTime:= Value;
  if assigned(fNode) then
  begin
    fNode.AttribStrings['time']:= DateTimeToStr(Self.Time, fs);
  end;
end;

{##############################################################################}

{-------------------------------------------------------------------------------
  Create an instance of TCESessionsMenuItem
-------------------------------------------------------------------------------}
constructor TCESessionsMenuItem.Create(AOwner: TComponent);
begin
  inherited;
end;

{-------------------------------------------------------------------------------
  Fill List
-------------------------------------------------------------------------------}
procedure TCESessionsMenuItem.FillList;
var
  item: TSpTBXItem;
  i: Integer;
  session: TCESessionItem;
begin
  for i:= 0 to GlobalSessions.Sessions.Count - 1 do
  begin
    session:= GlobalSessions.Sessions.Items[i];
    item:= TSpTBXItem.Create(self);
    item.Caption:= session.Name;
    item.Tag:= i;
    item.Images:= CE_Images.SmallIcons;
    item.ImageIndex:= 41;
    item.OnClick:= OnSessionClick;
    if not GlobalSessions.ActiveSessionIsHistory then
    item.Checked:= GlobalSessions.ActiveSession = session;
    Add(item);
  end;
end;

{-------------------------------------------------------------------------------
  Initiate Action (update checked states)
-------------------------------------------------------------------------------}
procedure TCESessionsMenuItem.InitiateAction;
begin
  inherited;
  Recreate;
end;

{-------------------------------------------------------------------------------
  OnSessionClick (change active session)
-------------------------------------------------------------------------------}
procedure TCESessionsMenuItem.OnSessionClick(Sender: TObject);
var
  item: TSpTBXItem;
  session: TCESessionItem;
begin
  item:= TSpTBXItem(Sender);
  if (item.Tag > -1) and (item.Tag < GlobalSessions.Sessions.Count) then
  begin
    session:= GlobalSessions.Sessions.Items[item.Tag];
    GlobalSessions.ActiveSession:= session;
  end;
end;

{-------------------------------------------------------------------------------
  Recreate
-------------------------------------------------------------------------------}
procedure TCESessionsMenuItem.Recreate;
begin
  Clear;
  FillList;
end;

{##############################################################################}

{-------------------------------------------------------------------------------
  Create an instance of TCESessionHistoryMenuItem
-------------------------------------------------------------------------------}
constructor TCESessionHistoryMenuItem.Create(AOwner: TComponent);
begin
  inherited;
end;

{-------------------------------------------------------------------------------
  Fill List
-------------------------------------------------------------------------------}
procedure TCESessionHistoryMenuItem.FillList;
var
  item: TSpTBXItem;
  i: Integer;
  session: TCESessionItem;
begin
  for i:= GlobalSessions.SessionHistory.Count - 1 downto 0 do
  begin
    session:= GlobalSessions.SessionHistory.Items[i];
    item:= TSpTBXItem.Create(self);
    item.Caption:= _('Session at') + ' ' + session.TimeStr;
    item.Tag:= i;
    item.Images:= CE_Images.SmallIcons;
    item.ImageIndex:= 41;
    item.OnClick:= OnSessionClick;
    if GlobalSessions.ActiveSessionIsHistory then
    item.Checked:= GlobalSessions.ActiveSession = session;
    Add(item);
  end;
end;

{-------------------------------------------------------------------------------
  Initiate Action (update checked states)
-------------------------------------------------------------------------------}
procedure TCESessionHistoryMenuItem.InitiateAction;
begin
  inherited;
  Recreate;
end;

{-------------------------------------------------------------------------------
  OnSessionClick (change active session)
-------------------------------------------------------------------------------}
procedure TCESessionHistoryMenuItem.OnSessionClick(Sender: TObject);
var
  item: TSpTBXItem;
  session: TCESessionItem;
begin
  item:= TSpTBXItem(Sender);
  if (item.Tag > -1) and (item.Tag < GlobalSessions.SessionHistory.Count) then
  begin
    session:= GlobalSessions.SessionHistory.Items[item.Tag];
    GlobalSessions.ActiveSession:= session;
  end;
end;

{-------------------------------------------------------------------------------
  Recreate
-------------------------------------------------------------------------------}
procedure TCESessionHistoryMenuItem.Recreate;
begin
  Clear;
  FillList;
end;

{##############################################################################}

{*------------------------------------------------------------------------------
  Create an instance of TCESessionsToolbar
-------------------------------------------------------------------------------}
constructor TCESessionsToolbar.Create(AOwner: TComponent);
begin
  inherited;
  Self.Customizable:= false;
end;

{-------------------------------------------------------------------------------
  On Session Click
-------------------------------------------------------------------------------}
procedure TCESessionsToolbar.OnSessionClick(Sender: TObject);
begin
  GlobalSessions.ActiveSession:= GlobalSessions.Sessions.GetSession(TSpTBXItem(Sender).Tag);
end;

{-------------------------------------------------------------------------------
  Populate
-------------------------------------------------------------------------------}
procedure TCESessionsToolbar.Populate;
var
  item: TSpTBXItem;
  i: Integer;
  session: TCESessionItem;
begin
  for i:= 0 to GlobalSessions.Sessions.Count - 1 do
  begin
    session:= GlobalSessions.Sessions.Items[i];
    item:= TSpTBXItem.Create(self);
    item.Caption:= session.Name;
    item.Tag:= i;
    item.Checked:= GlobalSessions.ActiveSession = session;
    item.OnClick:= OnSessionClick;
    Items.Add(item);
  end;
end;

{-------------------------------------------------------------------------------
  Recreate
-------------------------------------------------------------------------------}
procedure TCESessionsToolbar.Recreate;
begin
  Self.BeginUpdate;
  try
    Items.Clear;
    Populate;
  finally
    Self.EndUpdate;
  end;
end;


{##############################################################################}

initialization

finalization
  if assigned(fGlobalSessions) then
  FreeAndNil(fGlobalSessions);
  
end.
