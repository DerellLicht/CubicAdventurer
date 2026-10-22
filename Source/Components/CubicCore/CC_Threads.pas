//******************************************************************************
//  CubicCore
//  Version: 0.1
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
//  The Original Code is CC_Threads.pas.                                                            
//                                                                                            
//  The Initial Developer of the Original Code is Marko Savolainen (cubicreality@gmail.com).  
//  Portions created by Marko Savolainen Copyright (C) Marko Savolainen. All Rights Reserved. 
//                                                                                            
//******************************************************************************

unit CC_Threads;

{$WARN PUBLISHED OFF} // published sections on non-TPersistent classes are intentional (RTTI)
interface

uses Classes, Windows;

type
  TCCBaseThread = class;
  
  TOnExecuteEvent = procedure(Sender: TCCBaseThread) of object;
  TOnMsgEvent = procedure(Sender: TCCBaseThread; Msg: TObject) of object;

  TCCBaseThread = class(TThread)
  private
    fData: TObject;
    fFreeDataOnDestroy: Boolean;
    fMsg: TObject;
    fName: string;
    fOnExecute: TOnExecuteEvent;
    fOnSyncedMessage: TOnMsgEvent;
  protected
    procedure DoSyncedMessage; virtual;
    procedure Execute; override;
    procedure SetName;
  public
    constructor Create(CreateSuspended: Boolean);
    destructor Destroy; override;
    procedure SendSyncedMessage(Msg: TObject); virtual;
    property Data: TObject read fData write fData;
    property FreeDataOnDestroy: Boolean read fFreeDataOnDestroy write
        fFreeDataOnDestroy;
    property Name: string read fName write fName;
    property Terminated;
  published
    property OnExecute: TOnExecuteEvent read fOnExecute write fOnExecute;
    property OnSyncedMessage: TOnMsgEvent read fOnSyncedMessage write
        fOnSyncedMessage;
  end;

implementation

{-------------------------------------------------------------------------------
  Create an instance of TCCBaseThread
-------------------------------------------------------------------------------}
constructor TCCBaseThread.Create(CreateSuspended: Boolean);
begin
  inherited;
  fFreeDataOnDestroy:= false;
end;

{-------------------------------------------------------------------------------
  Destroy TCCBaseThread
-------------------------------------------------------------------------------}
destructor TCCBaseThread.Destroy;
begin
  if FreeDataOnDestroy and assigned(Data) then
  Data.Free;
  inherited;
end;

{-------------------------------------------------------------------------------
  DoSyncedMessage
-------------------------------------------------------------------------------}
procedure TCCBaseThread.DoSyncedMessage;
begin
  if assigned(fOnSyncedMessage) then
  fOnSyncedMessage(Self, fMsg);
end;

{-------------------------------------------------------------------------------
  Execute
-------------------------------------------------------------------------------}
procedure TCCBaseThread.Execute;
begin
  SetName;
  if Assigned(fOnExecute) then fOnExecute(Self);
end;

{-------------------------------------------------------------------------------
  Send SyncedMessage
-------------------------------------------------------------------------------}
procedure TCCBaseThread.SendSyncedMessage(Msg: TObject);
begin
  fMsg:= Msg;
  Self.Synchronize(DoSyncedMessage);
end;

{-------------------------------------------------------------------------------
  Set Name (name thread in debugger)
-------------------------------------------------------------------------------}
procedure TCCBaseThread.SetName;
begin
  if fName <> '' then
  begin
    // Standard RTL API replaces the manual RaiseException($406D1388) trick
    TThread.NameThreadForDebugging(AnsiString(fName), ThreadID);
  end;
end;

end.
