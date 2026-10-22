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
//  The Original Code is CE_Stacks.pas.                                                            
//                                                                                            
//  The Initial Developer of the Original Code is Marko Savolainen (cubicreality@gmail.com).  
//  Portions created by Marko Savolainen Copyright (C) Marko Savolainen. All Rights Reserved. 
//                                                                                            
//******************************************************************************

unit CE_Stacks;
{$WARN SYMBOL_PLATFORM OFF} // Windows-only application

interface

uses
  // VS Tools
  MPShellUtilities, MPCommonUtilities,
  // System Units
  SysUtils, Classes, Windows, Contnrs;


type
  TCEStackItem = class(TObject)
  private
    fStackName: WideString;
    fStackPath: WideString;
    function GetGroupCount: Integer;
    function GetGroupItems(Index: Integer): TStrings;
    function GetGroupName(Index: Integer): WideString;
    procedure SetGroupName(Index: Integer; const Value: WideString);
  protected
    fGroups: TStrings;
  public
    constructor Create; virtual;
    destructor Destroy; override;
    function AddGroup(AGroupName: WideString): Integer;
    procedure ClearGroups;
    procedure DeleteGroup(AIndex: Integer);
    procedure LoadFromFile(AFilePath: WideString);
    procedure LoadFromList(AStrings: TStrings);
    procedure SaveToFile(AFilePath: WideString);
    procedure SaveToList(AStrings: TStrings);
    property GroupCount: Integer read GetGroupCount;
    property GroupItems[Index: Integer]: TStrings read GetGroupItems;
    property GroupName[Index: Integer]: WideString read GetGroupName write
        SetGroupName;
    property StackName: WideString read fStackName write fStackName;
    property StackPath: WideString read fStackPath write fStackPath;
  published
  end;

  TCEStacks = class(TObject)
  private
    fStackDirPath: WideString;
    fStackPaths: TStrings;
    function GetCount: Integer;
    function GetItems(Index: Integer): TCEStackItem;
  protected
    fItems: TObjectList;
  public
    constructor Create; virtual;
    destructor Destroy; override;
    function AddStack(AName: WideString): TCEStackItem;
    procedure ClearStacks;
    function GetStackPaths(ADirPath: WideString = ''): Integer;
    procedure LoadFromDir(ADirPath: WideString);
    procedure SaveToDir(ADirPath: WideString);
    property Count: Integer read GetCount;
    property Items[Index: Integer]: TCEStackItem read GetItems;
    property StackDirPath: WideString read fStackDirPath write fStackDirPath;
    property StackPaths: TStrings read fStackPaths;
  end;

  function FindStacks(ADirPath: WideString; Results: TStrings): Integer;

var
  StackDirPath: WideString;

implementation

uses WideStrings;

{##############################################################################}

{-------------------------------------------------------------------------------
  FindStacks
-------------------------------------------------------------------------------}
function FindStacks(ADirPath: WideString; Results: TStrings): Integer;
var
  sr: TSearchRec;
begin
  Result:= 0;
  if not assigned(Results) then
  Exit;

  Results.Clear;
  ADirPath:= IncludeTrailingBackslash(ADirPath);
  if FindFirst(ADirPath + '*.stk', faAnyFile, sr) = 0 then
  begin
    repeat
      Results.Add(ADirPath + sr.Name);
    until FindNext(sr) <> 0;
    SysUtils.FindClose(sr);
    Result:= Results.Count;
  end;
end;

{##############################################################################}

{-------------------------------------------------------------------------------
  Create an instance of TCEStackItem
-------------------------------------------------------------------------------}
constructor TCEStackItem.Create;
begin
  inherited;
  fGroups:= TStringList.Create;
end;

{-------------------------------------------------------------------------------
  Destroy TCEStackItem
-------------------------------------------------------------------------------}
destructor TCEStackItem.Destroy;
begin
  ClearGroups;
  fGroups.Free;
  inherited;
end;

{-------------------------------------------------------------------------------
  Add Group
-------------------------------------------------------------------------------}
function TCEStackItem.AddGroup(AGroupName: WideString): Integer;
begin
  Result:= fGroups.AddObject(AGroupName, TStringList.Create);
end;

{-------------------------------------------------------------------------------
  Clear Groups
-------------------------------------------------------------------------------}
procedure TCEStackItem.ClearGroups;
var
  i: Integer;
begin
  for i:= 0 to fGroups.Count - 1 do
  fGroups.Objects[i].Free;
  fGroups.Clear;
end;

{-------------------------------------------------------------------------------
  Delete Group
-------------------------------------------------------------------------------}
procedure TCEStackItem.DeleteGroup(AIndex: Integer);
begin
  fGroups.Objects[AIndex].Free;
  fGroups.Delete(AIndex);
end;

{-------------------------------------------------------------------------------
  Get GroupCount
-------------------------------------------------------------------------------}
function TCEStackItem.GetGroupCount: Integer;
begin
  Result:= fGroups.Count;
end;

{-------------------------------------------------------------------------------
  Get GroupItems
-------------------------------------------------------------------------------}
function TCEStackItem.GetGroupItems(Index: Integer): TStrings;
begin
  Result:= TStrings(fGroups.Objects[Index]);
end;

{-------------------------------------------------------------------------------
  Get GroupName
-------------------------------------------------------------------------------}
function TCEStackItem.GetGroupName(Index: Integer): WideString;
begin
  Result:= fGroups.Strings[Index];
end;

{-------------------------------------------------------------------------------
  Load From File
-------------------------------------------------------------------------------}
procedure TCEStackItem.LoadFromFile(AFilePath: WideString);
var
  list: TStrings;
begin
  list:= TStringList.Create;
  try
    fStackPath:= AFilePath;
    list.LoadFromFile(AFilePath);
    LoadFromList(list);
  finally
    list.Free;
  end;
end;                            

{-------------------------------------------------------------------------------
  Load From List
-------------------------------------------------------------------------------}
procedure TCEStackItem.LoadFromList(AStrings: TStrings);
var
  i, c: Integer;
  ws: WideString;
  items: TStrings;
begin
  ClearGroups;
  items:= nil;
  for i:= 0 to AStrings.Count - 1 do
  begin
    ws:= Trim(AStrings.Strings[i]);
    c:= Length(ws);
    if c > 0 then
    begin
      if c > 2 then
      begin
        // group
        if (ws[1] = '[') and (ws[c] = ']') then
        begin
          items:= GroupItems[AddGroup(Copy(ws, 2, c-2))];
        end
        // file item
        else if assigned(items) then
        items.Add(ws);
      end
      // file item
      else if assigned(items) then
      items.Add(ws);
    end;
  end;
end;

{-------------------------------------------------------------------------------
  Save To File
-------------------------------------------------------------------------------}
procedure TCEStackItem.SaveToFile(AFilePath: WideString);
var
  list: TStrings;
begin
  list:= TStringList.Create;
  try
    SaveToList(list);
    list.SaveToFile(AFilePath);
  finally
    list.Free;
  end;
end;

{-------------------------------------------------------------------------------
  Save To List
-------------------------------------------------------------------------------}
procedure TCEStackItem.SaveToList(AStrings: TStrings);
var
  i, i2: Integer;
  list: TStrings;
begin
  if not assigned(AStrings) then
  Exit;

  AStrings.Clear;
  for i:= 0 to GroupCount - 1 do
  begin
    list:= GroupItems[i];
    AStrings.Add('[' + GroupName[i] + ']');
    for i2:= 0 to list.Count - 1 do
    begin
      AStrings.Add(list.Strings[i2]);
    end;
  end;
end;

{-------------------------------------------------------------------------------
  Set GroupName
-------------------------------------------------------------------------------}
procedure TCEStackItem.SetGroupName(Index: Integer; const Value: WideString);
begin
  fGroups.Strings[Index]:= Value;
end;

{##############################################################################}

{-------------------------------------------------------------------------------
  Create an instance of TCEStacks
-------------------------------------------------------------------------------}
constructor TCEStacks.Create;
begin
  inherited;
  fItems:= TObjectList.Create(true);
  fStackPaths:= TStringList.Create;
end;

{-------------------------------------------------------------------------------
  Destroy TCEStacks
-------------------------------------------------------------------------------}
destructor TCEStacks.Destroy;
begin
  fStackPaths.Free;
  fItems.Free;
  inherited;
end;

{-------------------------------------------------------------------------------
  Add Stack
-------------------------------------------------------------------------------}
function TCEStacks.AddStack(AName: WideString): TCEStackItem;
begin
  Result:= TCEStackItem.Create;
  Result.StackName:= AName;
  fItems.Add(Result);
end;

{-------------------------------------------------------------------------------
  Clear Stacks
-------------------------------------------------------------------------------}
procedure TCEStacks.ClearStacks;
begin
  fItems.Clear;
end;

{-------------------------------------------------------------------------------
  Get Count
-------------------------------------------------------------------------------}
function TCEStacks.GetCount: Integer;
begin
  Result:= fItems.Count;
end;

{-------------------------------------------------------------------------------
  Get Items
-------------------------------------------------------------------------------}
function TCEStacks.GetItems(Index: Integer): TCEStackItem;
begin
  Result:= TCEStackItem(fItems.Items[Index]);
end;

{-------------------------------------------------------------------------------
  Get Stack Paths (Return number of stack files found
-------------------------------------------------------------------------------}
function TCEStacks.GetStackPaths(ADirPath: WideString = ''): Integer;
var
  sr: TSearchRec;
begin
  Result:= -1;
  fStackPaths.Clear;
  if ADirPath = '' then
  ADirPath:= IncludeTrailingBackslash(StackDirPath)
  else
  ADirPath:= IncludeTrailingBackslash(ADirPath);
  if FindFirst(ADirPath + '*.stk', faAnyFile, sr) = 0 then
  begin
    repeat
      fStackPaths.Add(ADirPath + sr.Name);
    until FindNext(sr) <> 0;
    SysUtils.FindClose(sr);
    Result:= fStackPaths.Count;
  end;
end;

{-------------------------------------------------------------------------------
  Load From Dir
-------------------------------------------------------------------------------}
procedure TCEStacks.LoadFromDir(ADirPath: WideString);
var
  i: Integer;
  item: TCEStackItem;
  ws: WideString;
begin
  if GetStackPaths(ADirPath) > 0 then
  begin
    for i:= 0 to fStackPaths.Count - 1 do
    begin
      ws:= fStackPaths.Strings[i];
      item:= AddStack(ChangeFileExt(ExtractFileName(ws), ''));
      try
        item.LoadFromFile(ws);
      except
        // catch exceptions
      end;
    end;
  end;
end;

{-------------------------------------------------------------------------------
  Save To Dir
-------------------------------------------------------------------------------}
procedure TCEStacks.SaveToDir(ADirPath: WideString);
var
  item: TCEStackItem;
  i: Integer;
begin
  if ADirPath = '' then
  Exit;
  
  ADirPath:= IncludeTrailingPathDelimiter(ADirPath);

  // Create stack dir if it doesn't exist
  if not DirectoryExists(ADirPath) then
  CreateDir(ADirPath);

  for i:= 0 to Count - 1 do
  begin
    item:= Items[i];
    try
      item.SaveToFile(ADirPath + item.StackName + '.stk');
    except
      // catch exceptions
    end;
  end;
end;

{##############################################################################}

end.
