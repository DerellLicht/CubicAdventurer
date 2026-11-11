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
    // True once the item is known to be in sessions.xml (loaded from it or
    // written to it). An item that is missing from the file later was deleted
    // by another window (see TCESessions.SyncFromDisk).
    OnDisk: Boolean;
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
    function EntryKey(ANode: TDOMNode; ANamed: Boolean): string;
    function EnsureRootNode: TDOMNode;
    function FindByKey(const AKey: string; ANamed: Boolean): TCESessionItem;
    procedure FillItemFromNode(AItem: TCESessionItem; ANode: TDOMElement);
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
    procedure MarkAllOnDisk;
    function MergeFromDisk(ADiskRoot: TDOMNode; ANamed: Boolean; AActive, AKeep:
        TCESessionItem): Boolean;
    procedure MoveSession(CurIndex: Integer; NewIndex: Integer);
    procedure ReorderNodes;
    procedure SaveSession(ASession: TCESessionItem);
    function SaveSessionIfChanged(ASession: TCESessionItem): Boolean;
    procedure SortByTime;
    function TabsChanged(ASession: TCESessionItem): Boolean;
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
    fBaselineSet: Boolean;
    fBaselineSig: AnsiString;
    fDialogBlock: Integer;
    fDiskStamp: TDateTime;
    fDiskStampValid: Boolean;
    fKeepItem: TCESessionItem;
    fLastActiveName: string;
    fLastSyncTick: Cardinal;
    fSessionHistory: TCESessionList;
    fSessions: TCESessionList;
    function GetActiveSessionIndex: Integer;
    function GetPlainTabSetActive: Boolean;
    procedure ActiveChanged;
    procedure RebuildSessionsToolbar;
    procedure ForgetDeletedActive;
    procedure NormalizeLastTimeFlag;
    procedure SnapshotPlainTabs;
    procedure StoreActiveName;
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
    procedure DetachSession;
    procedure Flush;
    procedure LoadAutoSession;
    function LoadFromFile(AFilePath: WideString): Boolean; override;
    procedure LoadLastTimeSession;
    procedure LoadLatestHistorySession;
    procedure MarkTabsBaseline;
    procedure SaveActiveSession;
    procedure SaveSessionDlg;
    procedure SaveToFile(AFilePath: WideString); override;
    procedure ShowSessionManager;
    procedure SyncFromDisk(AKeep: TCESessionItem = nil; AMinInterval: Cardinal =
        0);
    function TabsUnchangedSinceLoad: Boolean;
    procedure UpdateActiveSession;
    property ActiveSession: TCESessionItem read fActiveSession write
        SetActiveSession;
    property ActiveSessionIndex: Integer read GetActiveSessionIndex;
    property ActiveSessionIsHistory: Boolean read fActiveSessionIsHistory;
    // Name of the saved session that was active when sessions.xml was last written
    // ('' if none). Read at start-up by LoadLastTimeSession.
    property LastActiveSessionName: string read fLastActiveName;
    // True when no saved session is active: the tabs are a plain (unnamed) set.
    property PlainTabSetActive: Boolean read GetPlainTabSetActive;
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
  fCE_TabPage, WideSupport, XMLRead, XMLWrite, Main, CE_SpTabBar,
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
  fHistoryCount:= 30;
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
  SyncFromDisk;
  // Delete/clear previous LastTimeSession
  // (counting down: deleting an entry must not shift the ones still to be visited)
  for i:= SessionHistory.Count - 1 downto 0 do
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
  ForgetDeletedActive;
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
    SyncFromDisk;
    SessionHistory.ClearSessions;
    ForgetDeletedActive;
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
    if Sessions.TabsChanged(fActiveSession) then
    begin
      // another window may have saved sessions.xml since we last looked
      SyncFromDisk;
      if Sessions.SaveSessionIfChanged(fActiveSession) then
      begin
        Flush;
      end;
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
  active session if that has the automatic-save flag; a plain tab set is copied
  to History), then all tabs are closed and no session is active.
  Returns false if a tab refused to close; the caller then opens nothing.
-------------------------------------------------------------------------------}
function TCESessions.CloseTabsForNewSession: Boolean;
begin
  SyncFromDisk;
  Inc(fAutoSaveBlock);
  try
    if assigned(fActiveSession) and not fActiveSessionIsHistory and fActiveSession.AutoSave then
    begin
      SaveActiveSession;
    end;
    SnapshotPlainTabs;
    Result:= MainForm.TabSet.CloseAllTabs;
    if Result then
    begin
      // Not through SetActiveSession: that would save the (now empty) tab set.
      fActiveSession:= nil;
      fActiveSessionIsHistory:= false;
      ActiveChanged;
      Flush;
    end;
  finally
    Dec(fAutoSaveBlock);
  end;
end;

{-------------------------------------------------------------------------------
  Update Active Session

  One-time update: saves the open tabs into the active saved session and
  writes sessions.xml, whatever the session's automatic-save flag says. Does
  nothing when no saved session is active.
-------------------------------------------------------------------------------}
procedure TCESessions.UpdateActiveSession;
begin
  SyncFromDisk;
  if PlainTabSetActive then
  begin
    Exit;
  end;
  Sessions.SaveSession(fActiveSession);
  Flush;
end;

{-------------------------------------------------------------------------------
  Detach Session

  Leaves the active saved session but keeps the open tabs, which become a
  plain (unnamed) tab set. If the session has the automatic-save flag it is
  brought up to date first; otherwise it keeps what was saved. Does nothing
  when no saved session is active.
-------------------------------------------------------------------------------}
procedure TCESessions.DetachSession;
begin
  SyncFromDisk;
  if PlainTabSetActive then
  begin
    Exit;
  end;
  if fActiveSession.AutoSave then
  begin
    SaveActiveSession;
  end;
  fActiveSession:= nil;
  fActiveSessionIsHistory:= false;
  ActiveChanged;
  Flush;
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
  Load From File (also reads the name of the session that was active last time)
-------------------------------------------------------------------------------}
function TCESessions.LoadFromFile(AFilePath: WideString): Boolean;
var
  node: TDOMNode;
begin
  Result:= inherited LoadFromFile(AFilePath);
  fLastActiveName:= '';
  fDiskStampValid:= Result and FileAge(AFilePath, fDiskStamp);
  if Result and assigned(XML.DocumentElement) then
  begin
    node:= XML.DocumentElement.FirstChild;
    while assigned(node) do
    begin
      if node.NodeName = 'ActiveSession' then
      begin
        fLastActiveName:= TDOMElement(node).AttribStrings['name'];
        break;
      end;
      node:= node.NextSibling;
    end;
  end;
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
  Get PlainTabSetActive
-------------------------------------------------------------------------------}
function TCESessions.GetPlainTabSetActive: Boolean;
begin
  Result:= not assigned(fActiveSession) or fActiveSessionIsHistory;
end;

{-------------------------------------------------------------------------------
  Forget Deleted Active

  History entries are deleted when the history is cleared, shrunk or full. If
  the active session was one of them, the pointer would dangle; clear it.
  (Compares pointers only, never uses the possibly freed object.)
-------------------------------------------------------------------------------}
procedure TCESessions.ForgetDeletedActive;
begin
  if assigned(fActiveSession) then
  begin
    if (Sessions.fItems.IndexOf(fActiveSession) = -1) and
       (SessionHistory.fItems.IndexOf(fActiveSession) = -1) then
    begin
      fActiveSession:= nil;
      fActiveSessionIsHistory:= false;
    end;
  end;
end;

{-------------------------------------------------------------------------------
  Snapshot Plain Tabs

  Called just before the plain (unnamed) tab set is replaced by a session or
  by New Session: keeps a copy of the open tabs in History so they can be
  brought back. Does nothing when a saved session is active, when no tab is
  open (start-up), or when the active History entry is unchanged (no
  duplicate). Whatever fActiveSession points to may be deleted by this
  (History keeps a limited number of entries), so callers must not use it
  afterwards.
-------------------------------------------------------------------------------}
procedure TCESessions.SnapshotPlainTabs;
var
  tabsNode: TDOMElement;
  unchanged: Boolean;
begin
  if not PlainTabSetActive then
  begin
    Exit;
  end;
  if not assigned(MainForm) or (MainForm.TabSet.TabCount = 0) then
  begin
    Exit;
  end;
  unchanged:= false;
  if assigned(fActiveSession) then
  begin
    tabsNode:= SessionHistory.CreateTabsNode;
    try
      unchanged:= SessionHistory.NodeToSig(tabsNode) = fActiveSession.LastSig;
    finally
      tabsNode.Free;
    end;
  end;
  if not unchanged then
  begin
    AddHistorySession;
  end;
end;

{-------------------------------------------------------------------------------
  Store Active Name

  Writes the name of the active saved session (or '' if none) into sessions.xml
  as <ActiveSession name="..."/>, so the next start can return to it. Older
  program versions ignore the element, and a file without it means "none".
-------------------------------------------------------------------------------}
procedure TCESessions.StoreActiveName;
var
  node: TDOMNode;
  elem: TDOMElement;
  name: WideString;
begin
  name:= '';
  if assigned(fActiveSession) and (Sessions.fItems.IndexOf(fActiveSession) > -1) then
  begin
    name:= fActiveSession.Name;
  end;
  elem:= nil;
  node:= XML.DocumentElement.FirstChild;
  while assigned(node) do
  begin
    if node.NodeName = 'ActiveSession' then
    begin
      elem:= TDOMElement(node);
      break;
    end;
    node:= node.NextSibling;
  end;
  if not assigned(elem) then
  begin
    elem:= XML.CreateElement('ActiveSession');
    XML.DocumentElement.AppendChild(elem);
  end;
  elem.AttribStrings['name']:= name;
end;

{-------------------------------------------------------------------------------
  Load Last Time Session

  Start-up for "Continue from last time": if a saved session was active when
  the program last ran and still exists, it is loaded as saved (so a session
  without automatic save returns to its saved folders). Otherwise the newest
  History snapshot is restored.
-------------------------------------------------------------------------------}
procedure TCESessions.LoadLastTimeSession;
var
  session: TCESessionItem;
begin
  session:= nil;
  if fLastActiveName <> '' then
  begin
    session:= Sessions.FindSession(fLastActiveName);
  end;
  if assigned(session) then
  begin
    ActiveSession:= session;
  end
  else
  begin
    LoadLatestHistorySession;
  end;
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
  automatic-save check box shows that session's current setting; for a new
  name it is cleared.
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
  end
  else
  begin
    // a new name means a new session, which starts with the option off
    dlg.OptionChecked:= false;
  end;
end;

{-------------------------------------------------------------------------------
  Save Session Dlg
-------------------------------------------------------------------------------}
procedure TCESessions.SaveSessionDlg;
var
  dlg: TCEItemSelectSaveDlg;
  session: TCESessionItem;
  res: Integer;
begin
  // the name list in the dialog should include sessions saved by other windows
  SyncFromDisk;
  dlg:= CreateSaveSessionDlg;
  try
    dlg.ShowOption(_('Save changes to this session automatically'), false);
    SaveDlgNameChange(dlg);
    dlg.OnNameChange:= SaveDlgNameChange;
    Inc(fDialogBlock);
    try
      res:= dlg.ShowModal;
    finally
      Dec(fDialogBlock);
    end;
    if res = mrOK then
    begin
      // pick up what other windows saved while the dialog was open
      SyncFromDisk;
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
      ActiveChanged;
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
    StoreActiveName;
    WriteXML(XML.DocumentElement, FileStream);
  finally
    FileStream.Free;
  end;
  // Remember what we wrote, so SyncFromDisk can tell when another window has
  // written the file since.
  Sessions.MarkAllOnDisk;
  SessionHistory.MarkAllOnDisk;
  if FileAge(AFilePath, fDiskStamp) then
  begin
    fDiskStampValid:= true;
  end;
end;

{-------------------------------------------------------------------------------
  Active Session
-------------------------------------------------------------------------------}
procedure TCESessions.SetActiveSession(const Value: TCESessionItem);
begin
  // The session about to be loaded may have been saved by another window since
  // we last read sessions.xml: refresh it (it is kept even if it is gone).
  SyncFromDisk(Value);
  fKeepItem:= Value;
  // AutoSave Previous session
  if assigned(ActiveSession) then
  begin
    if ActiveSession.AutoSave then
    SaveActiveSession;
  end;
  // Leaving a plain tab set for a session: keep a copy of it in History
  if assigned(Value) then
  begin
    SnapshotPlainTabs;
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
  fKeepItem:= nil;
  ActiveChanged;
  // record which session is active, so the next start can return to it
  Flush;
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
  ForgetDeletedActive;
end;

{-------------------------------------------------------------------------------
  Show Session Manager
-------------------------------------------------------------------------------}
procedure TCESessions.ShowSessionManager;
var
  manager: TCESessionManager;
begin
  // show the sessions of all windows, not just this window's copy
  SyncFromDisk;
  manager:= TCESessionManager.Create(nil);
  Inc(fDialogBlock);
  try
    manager.PopupParent:= MainForm;
    manager.ShowModal;
  finally
    Dec(fDialogBlock);
    manager.Free;
    ActiveChanged;
    // names, order, deletions and the automatic-save flags changed in the dialog
    Flush;
  end;
end;

{-------------------------------------------------------------------------------
  Rebuild Sessions Toolbar (queued, see SyncFromDisk)
-------------------------------------------------------------------------------}
procedure TCESessions.RebuildSessionsToolbar;
begin
  if assigned(MainForm) and assigned(MainForm.SessionsToolbar) then
  begin
    MainForm.SessionsToolbar.Recreate;
  end;
end;

{-------------------------------------------------------------------------------
  Active Changed

  Called whenever the active session (or its name) changes: rebuilds the
  Sessions toolbar and puts the session name into the window title.
-------------------------------------------------------------------------------}
procedure TCESessions.ActiveChanged;
begin
  MainForm.SessionsToolbar.Recreate;
  MainForm.UpdateTitle;
end;

{-------------------------------------------------------------------------------
  Normalize Last Time Flag

  Several windows can each mark a History entry as "last time". Keeps the flag
  on the newest of them only.
-------------------------------------------------------------------------------}
procedure TCESessions.NormalizeLastTimeFlag;
var
  i: Integer;
  newest: TCESessionItem;
begin
  newest:= nil;
  for i:= 0 to SessionHistory.Count - 1 do
  begin
    if SessionHistory.Items[i].IsLastTimeSession then
    begin
      if not assigned(newest) or (SessionHistory.Items[i].Time > newest.Time) then
      begin
        newest:= SessionHistory.Items[i];
      end;
    end;
  end;
  for i:= 0 to SessionHistory.Count - 1 do
  begin
    if SessionHistory.Items[i].IsLastTimeSession and (SessionHistory.Items[i] <> newest) then
    begin
      SessionHistory.Items[i].IsLastTimeSession:= false;
    end;
  end;
end;

{-------------------------------------------------------------------------------
  Sync From Disk

  Several windows can run at once, each holding its own copy of sessions.xml.
  Every write sends the whole copy, so a window that saved its session would
  silently drop what another window had saved before. To prevent that, this is
  called before anything that changes sessions or History (and before the
  final write at exit). When the file on disk is newer than our last read or
  write, it is merged into the copy in memory:
    - sessions and History entries that exist only on disk are added,
    - saved sessions that changed on disk are refreshed,
    - entries we knew to be in the file that are gone were deleted by another
      window, so they are dropped here too.
  The active session is never touched (it is this window's own working copy).
  AKeep is an entry the caller is about to use: it is refreshed but never
  deleted. Nothing is merged while the Save or Manage dialog is open, because
  they hold on to entries. AMinInterval (milliseconds) limits how often the
  file is even looked at; 0 means on every call. A file that cannot be read
  (for instance while another window is writing it) is skipped, and the next
  call tries again.
-------------------------------------------------------------------------------}
procedure TCESessions.SyncFromDisk(AKeep: TCESessionItem; AMinInterval: Cardinal);
var
  path: WideString;
  stamp: TDateTime;
  doc: TXMLDocument;
  node, sessNode, histNode: TDOMNode;
  tick: Cardinal;
  listChanged, histChanged: Boolean;
begin
  if (fDialogBlock > 0) or ReadOnlySettings or (SettingsDirPath = '') then
  begin
    Exit;
  end;
  // while a session is being switched, the one being loaded must survive
  if not assigned(AKeep) then
  begin
    AKeep:= fKeepItem;
  end;
  if AMinInterval > 0 then
  begin
    tick:= GetTickCount;
    if (tick >= fLastSyncTick) and (tick - fLastSyncTick < AMinInterval) then
    begin
      Exit;
    end;
    fLastSyncTick:= tick;
  end;
  path:= SettingsDirPath + 'sessions.xml';
  if not FileAge(path, stamp) then
  begin
    Exit;
  end;
  if fDiskStampValid and (stamp = fDiskStamp) then
  begin
    Exit;
  end;
  doc:= nil;
  try
    try
      ReadXMLFile(doc, path);
    except
      on E: Exception do
      begin
        OutputDebugString(PChar('CA sessions: cannot read ' + path + ': ' + E.Message));
        Exit;
      end;
    end;
    if not assigned(doc) or not assigned(doc.DocumentElement) then
    begin
      Exit;
    end;
    sessNode:= nil;
    histNode:= nil;
    node:= doc.DocumentElement.FirstChild;
    while assigned(node) do
    begin
      if node.NodeName = 'Sessions' then
      begin
        sessNode:= node;
      end
      else if node.NodeName = 'SessionHistory' then
      begin
        histNode:= node;
      end;
      node:= node.NextSibling;
    end;
    listChanged:= Sessions.MergeFromDisk(sessNode, true, fActiveSession, AKeep);
    histChanged:= SessionHistory.MergeFromDisk(histNode, false, fActiveSession, AKeep);
    if histChanged then
    begin
      NormalizeLastTimeFlag;
      SessionHistory.SortByTime;
      SessionHistory.ReorderNodes;
    end;
    if assigned(fAutoLoadSession) and (Sessions.fItems.IndexOf(fAutoLoadSession) = -1) then
    begin
      fAutoLoadSession:= nil;
    end;
    fDiskStamp:= stamp;
    fDiskStampValid:= true;
    if listChanged and assigned(MainForm) and assigned(MainForm.SessionsToolbar) then
    begin
      // not now: we may be inside a menu being opened or a button being clicked
      TThread.Queue(nil, RebuildSessionsToolbar);
    end;
  finally
    doc.Free;
  end;
end;

{-------------------------------------------------------------------------------
  Mark Tabs Baseline

  Remembers the open tabs as they are right now (called once after start-up has
  opened them), so that at exit a plain tab set that was not changed since can
  be recognised (see TabsUnchangedSinceLoad).
-------------------------------------------------------------------------------}
procedure TCESessions.MarkTabsBaseline;
var
  tabsNode: TDOMElement;
begin
  if not assigned(MainForm) or (MainForm.TabSet.TabCount = 0) then
  begin
    Exit;
  end;
  tabsNode:= SessionHistory.CreateTabsNode;
  try
    fBaselineSig:= SessionHistory.NodeToSig(tabsNode);
  finally
    tabsNode.Free;
  end;
  fBaselineSet:= true;
end;

{-------------------------------------------------------------------------------
  Tabs Unchanged Since Load

  True when the open tabs are a plain tab set that has not changed since it was
  loaded, so exiting needs no new History entry:
    - loaded from a History entry: it must still be the newest entry (otherwise
      "Continue from last time" would come back with different tabs) and the
      tabs must match it;
    - not from History: the tabs must match what start-up opened.
  Returns false whenever in doubt, which just means an entry is added as before.
-------------------------------------------------------------------------------}
function TCESessions.TabsUnchangedSinceLoad: Boolean;
var
  tabsNode: TDOMElement;
  sig: AnsiString;
begin
  Result:= false;
  if not PlainTabSetActive or not assigned(MainForm) or (MainForm.TabSet.TabCount = 0) then
  begin
    Exit;
  end;
  tabsNode:= SessionHistory.CreateTabsNode;
  try
    sig:= SessionHistory.NodeToSig(tabsNode);
  finally
    tabsNode.Free;
  end;
  if assigned(fActiveSession) then
  begin
    Result:= (fActiveSession = SessionHistory.GetNewestSession) and (sig = fActiveSession.LastSig);
  end
  else
  begin
    Result:= fBaselineSet and (sig = fBaselineSig);
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
  chNode: TDOMNode;
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
      FillItemFromNode(item, TDOMElement(chNode));
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
  Tabs Changed

  True when the open tabs differ from what ASession last saved or loaded.
-------------------------------------------------------------------------------}
function TCESessionList.TabsChanged(ASession: TCESessionItem): Boolean;
var
  newNode: TDOMElement;
begin
  Result:= false;
  if assigned(ASession) then
  begin
    newNode:= CreateTabsNode;
    try
      Result:= NodeToSig(newNode) <> ASession.LastSig;
    finally
      newNode.Free;
    end;
  end;
end;

{-------------------------------------------------------------------------------
  Mark All On Disk (sessions.xml has just been written or read)
-------------------------------------------------------------------------------}
procedure TCESessionList.MarkAllOnDisk;
var
  i: Integer;
begin
  for i:= 0 to fItems.Count - 1 do
  begin
    TCESessionItem(fItems.Items[i]).OnDisk:= true;
  end;
end;

{-------------------------------------------------------------------------------
  Reorder Nodes

  Puts the XML nodes into the same order as the items (after a sort).
-------------------------------------------------------------------------------}
procedure TCESessionList.ReorderNodes;
var
  i: Integer;
begin
  if assigned(ARootNode) then
  begin
    for i:= 0 to fItems.Count - 1 do
    begin
      ARootNode.AppendChild(TCESessionItem(fItems.Items[i]).Node);
    end;
  end;
end;

{-------------------------------------------------------------------------------
  Ensure Root Node (creates the Sessions / SessionHistory element if missing)
-------------------------------------------------------------------------------}
function TCESessionList.EnsureRootNode: TDOMNode;
begin
  if not assigned(ARootNode) then
  begin
    ARootNode:= AStorage.XML.CreateElement(RootNodeName);
    AStorage.XML.DocumentElement.AppendChild(ARootNode);
  end;
  Result:= ARootNode;
end;

{-------------------------------------------------------------------------------
  Entry Key

  Text that identifies an entry when comparing our copy with the file. A saved
  session is known by its name. A History entry has no name: its time, the
  number of tabs and the active tab are used.
-------------------------------------------------------------------------------}
function TCESessionList.EntryKey(ANode: TDOMNode; ANamed: Boolean): string;
var
  ch, tab: TDOMNode;
  n: Integer;
begin
  Result:= TDOMElement(ANode).AttribStrings['name'];
  if not ANamed then
  begin
    Result:= TDOMElement(ANode).AttribStrings['time'] + '|';
    ch:= ANode.FirstChild;
    while assigned(ch) do
    begin
      if ch.NodeName = 'Tabs' then
      begin
        n:= 0;
        tab:= ch.FirstChild;
        while assigned(tab) do
        begin
          Inc(n);
          tab:= tab.NextSibling;
        end;
        Result:= Result + IntToStr(n) + '|' + TDOMElement(ch).AttribStrings['active'];
        Break;
      end;
      ch:= ch.NextSibling;
    end;
  end;
end;

{-------------------------------------------------------------------------------
  Find By Key (see EntryKey)
-------------------------------------------------------------------------------}
function TCESessionList.FindByKey(const AKey: string; ANamed: Boolean): TCESessionItem;
var
  i: Integer;
begin
  Result:= nil;
  for i:= 0 to fItems.Count - 1 do
  begin
    if EntryKey(TCESessionItem(fItems.Items[i]).Node, ANamed) = AKey then
    begin
      Result:= TCESessionItem(fItems.Items[i]);
      Break;
    end;
  end;
end;

{-------------------------------------------------------------------------------
  Fill Item From Node

  Sets an item's fields from a Session element and makes that element the
  item's node. Used when loading sessions.xml and when merging changes made by
  another window.
-------------------------------------------------------------------------------}
procedure TCESessionList.FillItemFromNode(AItem: TCESessionItem; ANode: TDOMElement);
var
  chNode2: TDOMNode;
  sli: TCESessionSaveLoadItems;
begin
  // The item's old node may already be destroyed (ReplaceChild frees it), and the
  // property setters below would write into it. Detach it first.
  AItem.Node:= nil;
  AItem.fName:= ANode.AttribStrings['name'];
  AItem.TimeStr:= ANode.AttribStrings['time'];
  AItem.fAutoSave:= StrToBoolDef(ANode.AttribStrings['autosave'], false);
  AItem.fIsLastTimeSession:= StrToBoolDef(ANode.AttribStrings['last'], false);

  sli:= [];
  chNode2:= ANode.FirstChild;
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
  AItem.SaveLoadItems:= sli;

  AItem.Node:= ANode;
  AItem.OnDisk:= true;
end;

{-------------------------------------------------------------------------------
  Merge From Disk

  Merges the entries of this list as found in sessions.xml (ADiskRoot, the
  Sessions or SessionHistory element of a freshly read copy; may be nil) into
  the entries held in memory. See TCESessions.SyncFromDisk for the reasoning.
  ANamed: entries are saved sessions known by name (true) or History entries
  (false). AActive is never refreshed or deleted; AKeep is never deleted.
  Returns true if entries were added, replaced or removed.
-------------------------------------------------------------------------------}
function TCESessionList.MergeFromDisk(ADiskRoot: TDOMNode; ANamed: Boolean;
    AActive, AKeep: TCESessionItem): Boolean;
var
  node: TDOMNode;
  dnode, imp: TDOMElement;
  item: TCESessionItem;
  keys: TStringList;
  key: string;
  i: Integer;
begin
  Result:= false;
  keys:= TStringList.Create;
  try
    keys.CaseSensitive:= true;
    // 1. entries on disk: add the ones we lack, refresh saved sessions that changed
    if assigned(ADiskRoot) then
    begin
      node:= ADiskRoot.FirstChild;
      while assigned(node) do
      begin
        if node.NodeName = 'Session' then
        begin
          dnode:= TDOMElement(node);
          key:= EntryKey(dnode, ANamed);
          keys.Add(key);
          item:= FindByKey(key, ANamed);
          if not assigned(item) then
          begin
            EnsureRootNode;
            imp:= TDOMElement(dnode.CloneNode(true, AStorage.XML)); // ImportNode is not implemented in fcl-xml
            ARootNode.AppendChild(imp);
            item:= TCESessionItem.Create;
            FillItemFromNode(item, imp);
            fItems.Add(item);
            Result:= true;
          end
          else
          begin
            item.OnDisk:= true;
            if ANamed and (item <> AActive) and (NodeToSig(dnode) <> NodeToSig(item.Node)) then
            begin
              imp:= TDOMElement(dnode.CloneNode(true, AStorage.XML)); // ImportNode is not implemented in fcl-xml
              ARootNode.ReplaceChild(imp, item.Node);
              FillItemFromNode(item, imp);
              item.LastSig:= '';
              Result:= true;
            end;
          end;
        end;
        node:= node.NextSibling;
      end;
    end;
    // 2. entries that were in the file when we last looked but are not any more
    //    were deleted by another window
    for i:= fItems.Count - 1 downto 0 do
    begin
      item:= TCESessionItem(fItems.Items[i]);
      if item.OnDisk and (item <> AActive) and (item <> AKeep) then
      begin
        if keys.IndexOf(EntryKey(item.Node, ANamed)) = -1 then
        begin
          DeleteSession(i);
          Result:= true;
        end;
      end;
    end;
  finally
    keys.Free;
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
  GlobalSessions.SyncFromDisk(nil, 1000);
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
    item.Caption:= _('Tabs saved at') + ' ' + session.TimeStr;
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
  GlobalSessions.SyncFromDisk(nil, 1000);
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
