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
//  The Original Code is CE_FolderTree.pas.                                                            
//                                                                                            
//  The Initial Developer of the Original Code is Marko Savolainen (cubicreality@gmail.com).  
//  Portions created by Marko Savolainen Copyright (C) Marko Savolainen. All Rights Reserved. 
//                                                                                            
//******************************************************************************

unit CE_FolderTree;

interface

uses
  // CE Units
  CE_Utils,
  // VSTools, VT
  VirtualTrees, VirtualTrees.Types, VirtualTrees.BaseTree, VirtualTrees.EditLink, VirtualExplorerTree, MPShellUtilities, VirtualShellNotifier,
  MPCommonObjects, MPThreadManager,
  // System Units
  Classes, Windows, Messages, SysUtils, Graphics, Forms, Controls, ExtCtrls;

type
  TCEFolderTreeSelectedChangeEvent = procedure(Node: PVirtualNode) of object;

  TCEFolderTree = class(TVirtualExplorerTreeview)
  private
    fAutoCollapse: Boolean;
    fAutoExpand: Boolean;
    fBrowseZipFolders: Boolean;
    fCenterOnBrowse: Boolean;
    fCenterOnExpand: Boolean;
    fHiddenFiles: Boolean;
    fOnSelectedChange: TCEFolderTreeSelectedChangeEvent;
    fFixedLineHeight: Boolean;
    fSelectionTimer: TTimer;
    fViewFontSize: Integer;
    procedure SetBrowseZipFolders(const Value: Boolean);
    procedure SetHiddenFiles(const Value: Boolean);
    procedure WMKeyDown(var Message: TWMKeyDown); message WM_KEYDOWN;
  protected
    procedure HandleContextMenuCmd(Sender: TCustomVirtualExplorerTree; Namespace:
        TNamespace; Verb: string; MenuItemID: Integer; var Handled: Boolean);
    procedure HandleContextMenuShow(Sender: TCustomVirtualExplorerTree; Namespace:
        TNamespace; Menu: hMenu; var Allow: Boolean);
    procedure DoBeforeCellPaint(Canvas: TCanvas; Node: PVirtualNode; Column:
        TColumnIndex; CellPaintMode: TVTCellPaintMode; CellRect: TRect; var
        ContentRect: TRect); override;
    function DoCreateEditor(Node: PVirtualNode; Column: TColumnIndex): IVTEditLink;
        override;
    procedure DoEnumFolder(const Namespace: TNamespace; var AllowAsChild: Boolean);
        override;
    function DoKeyAction(var CharCode: Word; var Shift: TShiftState): Boolean;
        override;
    procedure DoPaintText(Node: PVirtualNode; const Canvas: TCanvas; Column:
        TColumnIndex; TextType: TVSTTextType); override;
    procedure DoSelectedChange(Node: PVirtualNode);
    procedure DoShellNotify(ShellEvent: TVirtualShellEvent); override;
    procedure HandleEnumFolder(Sender: TCustomVirtualExplorerTree; Namespace:
        TNamespace; var AllowAsChild: Boolean);
    procedure HandleMouseDblClick(var Message: TWMMouse; const HitInfo: THitInfo);
        override;
    procedure HandleMouseDown(var Message: TWMMouse; var HitInfo: THitInfo);
        override;
    procedure SelectionTimer(Sender: TObject);
    procedure WMKILLFOCUS(var Message: TMessage); message WM_KILLFOCUS;
  public
    constructor Create(AOwner: TComponent); override;
    procedure ApplyViewBackground(AColor: TColor);
    procedure ApplyRowHeight(AHeight: Integer);
    procedure ApplyViewFontSize(ASize: Integer);
    function AutoRowHeight: Integer;
    procedure UpdateAutoRowHeight;
    function PasteShortcutFromClipboard: Boolean;
    function Refresh: Boolean;
    procedure ScrollToView(ANode: PVirtualNode; AVertical: Boolean = true;
        AHorizontal: Boolean = true);
    procedure SelectedFilesDelete(ShiftKeyState: TExecuteVerbShift = evsCurrent);
        override;
    property AutoCollapse: Boolean read fAutoCollapse write fAutoCollapse;
    property AutoExpand: Boolean read fAutoExpand write fAutoExpand;
    property BrowseZipFolders: Boolean read fBrowseZipFolders write
        SetBrowseZipFolders;
    property FixedLineHeight: Boolean read fFixedLineHeight write fFixedLineHeight;
    property HiddenFiles: Boolean read fHiddenFiles write SetHiddenFiles;
    property ViewFontSize: Integer read fViewFontSize;
  published
    property CenterOnBrowse: Boolean read fCenterOnBrowse write fCenterOnBrowse;
    property CenterOnExpand: Boolean read fCenterOnExpand write fCenterOnExpand;
    property OnSelectedChange: TCEFolderTreeSelectedChangeEvent read
        fOnSelectedChange write fOnSelectedChange;
  end;

  TCE_VTEdit = class(TVTEdit)
  private
  protected
    procedure WMKillFocus(var Message: TMessage); message WM_KILLFOCUS;
  end;

  TCE_StringEditLink = class(TStringEditLink)
  public
    constructor Create; reintroduce;
  end;

implementation

uses
  dCE_Actions, MPCommonUtilities, CE_FileViewColors, CE_FontFallback;

{*------------------------------------------------------------------------------
  Create an instance of TCEFolderTree
-------------------------------------------------------------------------------}
constructor TCEFolderTree.Create(AOwner: TComponent);
begin
  inherited;
  Self.BorderStyle:= bsNone;
  Self.TreeOptions.AutoOptions:= [toAutoDropExpand,toAutoScrollOnExpand,toAutoTristateTracking,toAutoDeleteMovedNodes];
  Self.TreeOptions.MiscOptions:= [toAcceptOLEDrop,toEditable,toFullRepaintOnResize,toInitOnSave,toToggleOnDblClick];
  Self.TreeOptions.PaintOptions:= [toShowButtons,toShowTreeLines,toUseBlendedImages,toGhostedIfUnfocused];
  Self.TreeOptions.VETImageOptions:= [toImages,toMarkCutAndCopy];
  Self.TreeOptions.VETMiscOptions:= [toBrowseExecuteFolder, toRemoveContextMenuShortCut,toBrowseExecuteFolderShortcut,toChangeNotifierThread,toTrackChangesInMappedDrives,toExecuteOnDblClk, toNoRebuildIconListOnAssocChange];
  Self.TreeOptions.VETShellOptions:= [toRightAlignSizeColumn,toContextMenus,toDragDrop];
  //Self.TreeOptions.SelectionOptions:= [toMultiSelect,toRightClickSelect,toSiblingSelectConstraint,toCenterScrollIntoView];
  Self.VETColors.FileTextColor:= clWindowText;
  Self.VETColors.FolderTextColor:= clWindowText;
  Self.VETColors.CompressedTextColor:= clWindowText;
  Self.VETColors.EncryptedTextColor:= clWindowText;
  Self.OnEnumFolder:= HandleEnumFolder;
  // TODO(revival): VirtualExplorerTree's DoContextMenuCmd/Show are no longer virtual, so use its events
  Self.OnContextMenuCmd:= HandleContextMenuCmd;
  Self.OnContextMenuShow:= HandleContextMenuShow;
  HiddenFiles:= false;

  fSelectionTimer:= TTimer.Create(Self);
  fSelectionTimer.Enabled:= false;
  fSelectionTimer.Interval:= 500;
  fSelectionTimer.OnTimer:= SelectionTimer;
  Self.DefaultNodeHeight:= SmallShellIconSize + 1;
end;

{*------------------------------------------------------------------------------
  Gives the tree the file view's background color (CA-053), so the folder text
  and attribute colors, which are chosen for that background, stay readable.
  clDefault / clNone mean the system window color (same rule as the file view).
  Called from TCEFileViewSettings.SendChanges whenever the file view settings
  change; repaints the tree so the other color settings show up too.

  The expand/collapse button draws its + / - sign in the tree's Font.Color (the
  default is black) and fills the box with the background color. On a dark
  background the sign would vanish, so a dark background uses the tree-line
  color for the sign (the box border already uses it). VT only reads these
  colors while preparing its button bitmaps, so a change of ButtonFillMode
  (to the other value and back) forces them to be redrawn.
-------------------------------------------------------------------------------}
procedure TCEFolderTree.ApplyViewBackground(AColor: TColor);
var
  rgb: Integer;
  glyph: TColor;
  dark: Boolean;
begin
  if (AColor = clDefault) or (AColor = clNone) then
  begin
    AColor:= clWindow;
  end;

  rgb:= ColorToRGB(AColor);
  dark:= ((GetRValue(rgb) * 299 + GetGValue(rgb) * 587 + GetBValue(rgb) * 114) div 1000) < 128;
  if dark then
  begin
    glyph:= Self.Colors.TreeLineColor;
  end
  else
  begin
    glyph:= clWindowText;
  end;

  if (Self.Color <> AColor) or (Self.Font.Color <> glyph) then
  begin
    Self.Color:= AColor;
    Self.Font.Color:= glyph;
    Self.ButtonFillMode:= fmWindowColor;
    Self.ButtonFillMode:= fmTreeColor;
  end;
  Self.Invalidate;
end;

{*------------------------------------------------------------------------------
  Gives the tree the file view's font size (CA-059), so folder names in the
  Folders panel are the same size as the names in the file list. Only the size
  is taken over: the face and the color are left alone (the color is managed
  by ApplyViewBackground).

  The size is remembered in fViewFontSize (ViewFontSize), because setting
  TCEFolderPanelSettings.FontSize to -1 puts the desktop icon font back on the
  tree and has to ask for this size again. A size of 0 or less is ignored.
  Called from TCEFileViewSettings (first view at startup and every settings
  change).
-------------------------------------------------------------------------------}
procedure TCEFolderTree.ApplyViewFontSize(ASize: Integer);
begin
  if ASize > 0 then
  begin
    fViewFontSize:= ASize;
    if Self.Font.Size <> ASize then
    begin
      Self.Font.Size:= ASize;
    end;
  end;
  // the row height depends on the font (descenders were cut off by the next row)
  UpdateAutoRowHeight;
end;

{*------------------------------------------------------------------------------
  Row height that fits the tree's current font (CA-059): the text height of a
  string with ascenders and descenders plus 2 pixels, but never less than the
  small shell icon plus 1 pixel (the old fixed row height). The text is
  measured on a temporary bitmap so no window handle has to exist yet.
-------------------------------------------------------------------------------}
function TCEFolderTree.AutoRowHeight: Integer;
var
  bmp: TBitmap;
  textHeight: Integer;
begin
  bmp:= TBitmap.Create;
  try
    bmp.Canvas.Font.Assign(Self.Font);
    textHeight:= bmp.Canvas.TextHeight('Ag|jpqy') + 2;
  finally
    bmp.Free;
  end;
  Result:= SmallShellIconSize + 1;
  if textHeight > Result then
  begin
    Result:= textHeight;
  end;
end;

{*------------------------------------------------------------------------------
  Sets the row height and resizes the nodes that already exist (VT keeps a
  height per initialized node, so changing DefaultNodeHeight alone would only
  affect nodes created later). Does nothing when the height is unchanged.
-------------------------------------------------------------------------------}
procedure TCEFolderTree.ApplyRowHeight(AHeight: Integer);
var
  c: Integer; // same type as VT's DefaultNodeHeight (avoids signed/unsigned W1023)
  node: PVirtualNode;
begin
  c:= Self.DefaultNodeHeight;
  Self.DefaultNodeHeight:= AHeight;
  if c <> Self.DefaultNodeHeight then
  begin
    Self.BeginUpdate;
    try
      node:= Self.GetFirstInitialized;
      while assigned(node) do
      begin
        Self.NodeHeight[node]:= Self.DefaultNodeHeight;
        node:= Self.GetNextInitialized(node);
      end;
    finally
      Self.EndUpdate;
    end;
  end;
end;

{*------------------------------------------------------------------------------
  Fits the row height to the font, unless the user fixed the row height with
  FolderPanel LineHeight in settings.xml (FixedLineHeight).
-------------------------------------------------------------------------------}
procedure TCEFolderTree.UpdateAutoRowHeight;
begin
  if not fFixedLineHeight then
  begin
    ApplyRowHeight(AutoRowHeight);
  end;
end;

{*------------------------------------------------------------------------------
  Paints the attribute background color (System / Read-only / Hidden) behind a
  folder's icon-less label, using the same colors as the file view (CA-053).
  Only the main column is handled, and only when painting (not when VT is just
  asking for the content margin). The background covers the label text plus the
  tree's text margin on each side, like the selection rectangle does.
-------------------------------------------------------------------------------}
procedure TCEFolderTree.DoBeforeCellPaint(Canvas: TCanvas; Node: PVirtualNode;
    Column: TColumnIndex; CellPaintMode: TVTCellPaintMode; CellRect: TRect; var
    ContentRect: TRect);
var
  NS: TNamespace;
  clr: TColor;
  oldColor: TColor;
  txt: string;
  r: TRect;
  w: Integer;
begin
  inherited;
  if (CellPaintMode <> cpmPaint) or (Column > 0) then
  begin
    Exit;
  end;
  if not ValidateNamespace(Node, NS) then
  begin
    Exit;
  end;
  if not CE_GetNamespaceAttrBackgroundColor(NS, clr) then
  begin
    Exit;
  end;

  // measure the label with the same font DoPaintText will choose
  txt:= NS.NameInFolder;
  Canvas.Font.Assign(Self.Font);
  CE_ApplyFontFallback(Canvas, txt);
  w:= Canvas.TextWidth(txt) + 2 * Integer(TextMargin);
  Canvas.Font.Assign(Self.Font);

  r:= ContentRect;
  if r.Left + w < r.Right then
  begin
    r.Right:= r.Left + w;
  end;
  if IsRectEmpty(r) then
  begin
    Exit;
  end;

  oldColor:= Canvas.Brush.Color;
  Canvas.Brush.Color:= clr;
  Canvas.FillRect(r);
  Canvas.Brush.Color:= oldColor;
end;

{*------------------------------------------------------------------------------
  Sets the folder text color and the glyph fallback font for a node's label,
  using the same settings as the file view (CA-053). Runs after the inherited
  handler, so it wins over the VETColors folder color set in the constructor.
-------------------------------------------------------------------------------}
procedure TCEFolderTree.DoPaintText(Node: PVirtualNode; const Canvas: TCanvas;
    Column: TColumnIndex; TextType: TVSTTextType);
var
  NS: TNamespace;
  clr: TColor;
begin
  inherited;
  if Column > 0 then
  begin
    Exit;
  end;
  if ValidateNamespace(Node, NS) then
  begin
    CE_ApplyFontFallback(Canvas, NS.NameInFolder);
    if CE_GetNamespaceFolderTextColor(NS, clr) then
    begin
      Canvas.Font.Color:= clr;
    end;
  end;
end;

{-------------------------------------------------------------------------------
  Handle ContextMenuCmd (OnContextMenuCmd event)
-------------------------------------------------------------------------------}
procedure TCEFolderTree.HandleContextMenuCmd(Sender: TCustomVirtualExplorerTree;
    Namespace: TNamespace; Verb: string; MenuItemID: Integer; var Handled: Boolean);
begin
  if not Handled then
  DoGlobalContextMenuCmd(Self, Namespace, Verb, MenuItemID, Handled);
end;

{-------------------------------------------------------------------------------
  Handle ContextMenuShow (OnContextMenuShow event)
-------------------------------------------------------------------------------}
procedure TCEFolderTree.HandleContextMenuShow(Sender: TCustomVirtualExplorerTree;
    Namespace: TNamespace; Menu: hMenu; var Allow: Boolean);
begin
  if Allow then
  begin
    DoGlobalContextMenuShow(Self, Namespace, Menu, Allow);
  end;
end;

{*------------------------------------------------------------------------------
  Create custom editor
-------------------------------------------------------------------------------}
function TCEFolderTree.DoCreateEditor(Node: PVirtualNode; Column:
    TColumnIndex): IVTEditLink;
begin
  Result:= TCE_StringEditLink.Create;
end;

{-------------------------------------------------------------------------------
  Do EnumFolder
-------------------------------------------------------------------------------}
procedure TCEFolderTree.DoEnumFolder(const Namespace: TNamespace; var
    AllowAsChild: Boolean);
begin
  inherited;

  if fBrowseZipFolders then
  AllowAsChild:= Namespace.Folder
  else
  AllowAsChild:= Namespace.Folder and (StrIComp(PWideChar(Namespace.Extension), '.zip') <> 0);
end;

{*------------------------------------------------------------------------------
  Handle Key Actions
-------------------------------------------------------------------------------}
function TCEFolderTree.DoKeyAction(var CharCode: Word; var Shift: TShiftState):
    Boolean;
begin
  Result:= true;
  case CharCode of
    VK_F2,
    VK_F5,
    VK_DELETE:
    begin
      if Shift = [] then
      Result:= false;
    end;
    Ord('C'), Ord('c'):
    begin
      if ssCtrl in Shift then
      Result:= false;
    end;
    Ord('X'), Ord('x'):
    begin
      if ssCtrl in Shift then
      Result:= false;
    end;
    Ord('V'), Ord('v'):
    begin
      if ssCtrl in Shift then
      Result:= false;
    end;
    Ord('A'), Ord('a'):
    begin
      if (Shift = [ssShift,ssCtrl]) or (Shift = [ssCtrl]) then
      Result:= false;
    end;
    VK_LEFT, VK_RIGHT:
    begin
      if Shift = [ssAlt] then
      Result:= false
      else
      begin
        fSelectionTimer.Enabled:= false;
        fSelectionTimer.Enabled:= true;
      end;
    end;
    VK_DOWN, VK_UP:
    begin
      fSelectionTimer.Enabled:= false;
      fSelectionTimer.Enabled:= true;
    end;
    VK_INSERT:
    begin
      if (ssShift in Shift) or (ssCtrl in Shift) then
      Result:= false;
    end;
    VK_RETURN, VK_SPACE:
    begin
      SelectionTimer(self);
      Result:= false;
    end;
  end;

  if Result then
  inherited DoKeyAction(CharCode, Shift);
end;

{-------------------------------------------------------------------------------
  Do Selected Change
-------------------------------------------------------------------------------}
procedure TCEFolderTree.DoSelectedChange(Node: PVirtualNode);
begin
  if Assigned(fOnSelectedChange) then fOnSelectedChange(Node);
end;

{-------------------------------------------------------------------------------
  Do Shell Notify
-------------------------------------------------------------------------------}
procedure TCEFolderTree.DoShellNotify(ShellEvent: TVirtualShellEvent);
begin
  inherited;
  if not ShellEvent.Handled then
  begin
    if ShellEvent.ShellNotifyEvent = vsneAssoccChanged then
    begin
//      RebuildTree;
//      Refresh;
      ShellEvent.Handled:= true;
    end;
  end;
end;

{-------------------------------------------------------------------------------
  Handle Enum Folder
-------------------------------------------------------------------------------}
procedure TCEFolderTree.HandleEnumFolder(Sender: TCustomVirtualExplorerTree;
    Namespace: TNamespace; var AllowAsChild: Boolean);
begin
  if fBrowseZipFolders then
  AllowAsChild:= Namespace.Folder
  else
  AllowAsChild:= Namespace.Folder and (StrIComp(PWideChar(Namespace.Extension), '.zip') <> 0);
end;

{*------------------------------------------------------------------------------
  Handle Mouse Down
-------------------------------------------------------------------------------}
procedure TCEFolderTree.HandleMouseDown(var Message: TWMMouse; var HitInfo:
    THitInfo);
var
  ShiftState: TShiftState;
begin
  if Self.IsEditing then
  begin
    Self.EndEditNode;
    Exit;
  end;

  if not assigned(HitInfo.HitNode) then
  begin
    inherited;
  end
  else if (hiOnItemButton in HitInfo.HitPositions) then
  begin
    if HitInfo.HitNode <> self.FocusedNode then
    begin
      if Self.Expanded[HitInfo.HitNode] and Self.HasAsParent(Self.FocusedNode, HitInfo.HitNode) then
      begin
        Self.Expanded[HitInfo.HitNode]:= false;
        DoSelectedChange(HitInfo.HitNode);
      end
      else
      begin
        Self.ToggleNode(HitInfo.HitNode);
      end;
    end
    else
    Self.ToggleNode(HitInfo.HitNode);

    if CenterOnExpand and (vsExpanded in HitInfo.HitNode.States) then
    begin
      ScrollToView(HitInfo.HitNode, false, true);
    end;
  end
  else if HitInfo.HitNode = self.FocusedNode then
  begin
    inherited;
  end
  else
  begin
    Self.BeginUpdate;
    try
      if fAutoCollapse then
      Self.FullCollapse;

      Self.ClearSelection;

      Self.FullyVisible[HitInfo.HitNode]:= true;
      if fAutoExpand and not Self.Expanded[HitInfo.HitNode] then
      Self.ToggleNode(HitInfo.HitNode);

      Self.Selected[HitInfo.HitNode]:= true;
      Self.FocusedNode:= HitInfo.HitNode;
      Self.ScrollIntoView(HitInfo.HitNode,false,false);
    finally
      Self.EndUpdate;
    end;
    
    ShiftState := KeysToShiftState(Message.Keys) * [ssShift, ssCtrl, ssAlt];
    if ShiftState = [] then
    DoSelectedChange(Self.FocusedNode);
  end;
end;

{*------------------------------------------------------------------------------
  Handle Mouse Dbl Click
-------------------------------------------------------------------------------}
procedure TCEFolderTree.HandleMouseDblClick(var Message: TWMMouse; const HitInfo:
    THitInfo);
begin
  if not assigned(HitInfo.HitNode) then
  begin
    inherited;
    Exit;
  end;

  if Self.Expanded[HitInfo.HitNode] then
  begin
    Self.ToggleNode(HitInfo.HitNode);
    Exit;
  end;

  Self.BeginUpdate;
  try
    if fAutoCollapse then
    Self.FullCollapse;
    
    Self.ClearSelection;
    Self.FullyVisible[HitInfo.HitNode]:= true;
    Self.ToggleNode(HitInfo.HitNode);
    Self.Selected[HitInfo.HitNode]:= true;
    Self.FocusedNode:= HitInfo.HitNode;
    Self.ScrollIntoView(HitInfo.HitNode,false,true);
  finally
    Self.EndUpdate;
  end;
end;

{*------------------------------------------------------------------------------
  Paste Shortcut From Clipboard
-------------------------------------------------------------------------------}
function TCEFolderTree.PasteShortcutFromClipboard: Boolean;
var
  NS: TNamespace;
  NSA: TNamespaceArray;
  Handled: Boolean;
begin
  if not (toVETReadOnly in TreeOptions.VETMiscOptions) then
  begin
    WaitCursor(True);
    try
      Handled := False;
      DoClipboardPaste(Handled);
      if not Handled then
      begin
        Result := False;
        if SelectedCount = 1 then
        begin
          SetLength(NSA, 1);
          if ValidateNamespace(GetFirstSelected, NS) then
          begin
            NSA[0] := NS;
            NS.Paste(Self, NSA, true);
            Result := True
          end
        end
      end else
        Result := True
    finally
      WaitCursor(False)
    end
  end else
    Result := False
end;


procedure TCEFolderTree.WMKILLFOCUS(var Message: TMessage);
begin
  inherited;
  //if Self.IsEditing then
  //Self.EndEditNode;
end;

{-------------------------------------------------------------------------------
  Refresh
-------------------------------------------------------------------------------}
function TCEFolderTree.Refresh: Boolean;
begin
  Result:= RefreshTree(true);
end;

{-------------------------------------------------------------------------------
  Scroll To View
-------------------------------------------------------------------------------}
procedure TCEFolderTree.ScrollToView(ANode: PVirtualNode; AVertical: Boolean =
    true; AHorizontal: Boolean = true);
var
  indentW, level: Integer;
  r: TRect;
begin
  if not assigned(ANode) then
  Exit;
  // Vertically
  if AVertical then
  ScrollIntoView(ANode, true);
  // Horizontally
  if AHorizontal then
  begin
    // GetNodeLevel returns a Cardinal; for a top level node (level 0) the "-1"
    // wrapped around and raised EIntOverflow. Do the math in Integer and clamp.
    level:= Integer(GetNodeLevel(ANode)) - 1;
    if level < 0 then
    begin
      level:= 0;
    end;
    indentW:= Integer(Indent) * level;
    r:= GetDisplayRect(ANode, NoColumn, false, true);
    if ((r.Right - r.Left) + indentW) > Self.ClientWidth then
    OffsetX:= -indentW;
  end;
end;

procedure TCEFolderTree.SelectedFilesDelete(ShiftKeyState: TExecuteVerbShift =
    evsCurrent);
var
  Node: PVirtualNode;
  NS: TNamespace;
begin
  if not (toVETReadOnly in TreeOptions.VETMiscOptions) then
  begin
    WaitCursor(True);
    try
      Node:= GetFirstSelected;
      if Assigned(Node) then
      begin
        if ValidateNamespace(Node, NS) then
        begin
          if NS.Delete(Self, SelectedToNamespaceArray, ShiftKeyState) then
          begin
            ReReadAndRefreshNode(node, false);
            DoSelectedChange(GetFirstSelected);
          end;
        end;
      end;
    finally
      WaitCursor(False)
    end
  end
end;

{-------------------------------------------------------------------------------
  Handle Selection Timer Event
-------------------------------------------------------------------------------}
procedure TCEFolderTree.SelectionTimer(Sender: TObject);
begin
  fSelectionTimer.Enabled:= false;
  DoSelectedChange(FocusedNode);
end;

{-------------------------------------------------------------------------------
  Set BrowseZipFolders
-------------------------------------------------------------------------------}
procedure TCEFolderTree.SetBrowseZipFolders(const Value: Boolean);
var
  opts: TVETMiscOptions;
  obj: TFileObjects;
begin
  fBrowseZipFolders:= Value;
  opts:= Self.TreeOptions.VETMiscOptions;
  if fBrowseZipFolders then
  Include(opts, toBrowseExecuteZipFolder)
  else
  Exclude(opts, toBrowseExecuteZipFolder);
  Self.TreeOptions.VETMiscOptions:= opts;

  obj:= FileObjects;
  if fBrowseZipFolders then
  Include(obj, foNonFolders)
  else
  Exclude(obj, foNonFolders);
  FileObjects:= obj;

end;

{-------------------------------------------------------------------------------
  Set Hidden Files
-------------------------------------------------------------------------------}
procedure TCEFolderTree.SetHiddenFiles(const Value: Boolean);
var
  obj: TFileObjects;
begin
  fHiddenFiles:= Value;
  obj:= FileObjects;
  if fHiddenFiles then Include(obj, foHidden) else Exclude(obj, foHidden);
  FileObjects:= obj;
end;

{-------------------------------------------------------------------------------
  Handle WM_KeyDown message
-------------------------------------------------------------------------------}
procedure TCEFolderTree.WMKeyDown(var Message: TWMKeyDown);
var
  Shift: TShiftState;
begin
  inherited;
  if CenterOnExpand and assigned(Self.FocusedNode) then
  begin
    if Message.CharCode = VK_RIGHT then
    begin
      Shift:= KeyDataToShiftState(Message.KeyData);
      if Shift = [] then
      begin
        if Self.Expanded[Self.FocusedNode] then
        begin
          ScrollToView(Self.FocusedNode, false, true);
        end;
      end;
    end;
  end;
end;

{##############################################################################}

{*------------------------------------------------------------------------------
  Handle WM_KillFocus message
-------------------------------------------------------------------------------}
procedure TCE_VTEdit.WMKillFocus(var Message: TMessage);
begin
  Self.Perform(CM_Exit,0,0);
  inherited;
end;

{##############################################################################}

{*------------------------------------------------------------------------------
  Create instance of TCE_StringEditLink
-------------------------------------------------------------------------------}
constructor TCE_StringEditLink.Create;
begin
  inherited Create;
  // Replace the default TVTEdit with our own subclass
  FEdit.Free;
  FEdit := TCE_VTEdit.Create(Self);
  Edit.Visible := False;
  Edit.BorderStyle := bsSingle;
  Edit.AutoSize := False;
end;



end.
