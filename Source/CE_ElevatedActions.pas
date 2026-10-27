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
//  The Original Code is CE_ElevatedActions.pas.                                                            
//                                                                                            
//  The Initial Developer of the Original Code is Marko Savolainen (cubicreality@gmail.com).  
//  Portions created by Marko Savolainen Copyright (C) Marko Savolainen. All Rights Reserved. 
//                                                                                            
//******************************************************************************

unit CE_ElevatedActions;

interface

uses
  // CE Units
  CE_FileUtils,
  // System Units
  Windows, SysUtils, ShellAPI, Forms;

function HandleElevatedCommands: Boolean;

function Elevated_CreateJunction(ALink: WideString; ATarget: WideString;
    ParentHWND: HWND): Boolean;

function RunElevatedCommand(AParentHWND: HWND; const AParams: WideString):
    Boolean;

implementation

uses
  dCE_Input, dCE_Actions, Main, CE_Utils;

{-------------------------------------------------------------------------------
  Handle Elevated Commands
-------------------------------------------------------------------------------}
function HandleElevatedCommands: Boolean;
var
  index, count: Integer;
  doAdmin: Boolean;
  doUpdate: Boolean;
  action: String;
  param1, param2: WideString;
begin
  Result:= false;
  doAdmin:= false;
  doUpdate:= false;
  index:= 1;
  count:= ParamCount;
  // Loop through cmd params.
  while index <= count do
  begin
    // Do Admin actions
    if doAdmin then
    begin
      action:= ParamStr(index);

      // Create Junction
      if action = 'create_symlink' then
      begin
        if index + 2 <= count then // make sure we have all needed params present
        begin
          param1:= ParamStr(index + 1);
          param2:= ParamStr(index + 2);
          index:= index + 2;

          CreateJunction(param1, param2);
        end;
      end;

      index:= index + 1;

      doAdmin:= false;
    end
    // Do Update
    else if doUpdate then
    begin
      if index + 1 < count then
      begin
        param1:= ParamStr(index); // zip path
        param2:= ParamStr(index + 1); // dest folder
        index:= index + 2;
        if index <= count then
        begin
          // Handle to old app: consumed and ignored (updater was removed)
          index:= index + 1;
        end;

        // '/update' (self-update from zip) was removed together with the auto-updater (revival); arguments are consumed and ignored.
        doUpdate:= false;
      end
      else
      index:= index + 1;
    end
    else
    begin
      doAdmin:= (ParamStr(index) = '/admin') and (index < ParamCount); // Check if /admin switch is present
      if doAdmin then
      Result:= true
      else
      begin
        doUpdate:= (ParamStr(index) = '/update') and (index < count);
        if doUpdate then
        Result:= true;
      end;
      index:= index + 1;
    end;
  end;
end;

{-------------------------------------------------------------------------------
  Run Elevated Command
-------------------------------------------------------------------------------}
function RunElevatedCommand(AParentHWND: HWND; const AParams: WideString): Boolean;
var
  op: WideString;
begin
  Result:= true; // TODO: add proper result value

  if ((Win32Platform = VER_PLATFORM_WIN32_NT) and (Win32MajorVersion >= 6)) or not IsWindowsAdmin then
  op:= 'runas'
  else
  op:= 'open';

  ShellExecuteW(AParentHWND,
                    PWideChar(op),
                    PWideChar(ParamStr(0)),
                    PWideChar(AParams),
                    '',
                    SW_HIDE);
end;

{-------------------------------------------------------------------------------
  CreateJunction (Elevated)
-------------------------------------------------------------------------------}
function Elevated_CreateJunction(ALink: WideString; ATarget: WideString;
    ParentHWND: HWND): Boolean;
var
  ws: WideString;
begin
  ws:= '/admin create_symlink "' + ALink + '" "' + ATarget + '"';
  Result:= RunElevatedCommand(ParentHWND, ws);
end;


end.
