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
//  The Original Code is CE_BookmarkTree.pas.                                                            
//                                                                                            
//  The Initial Developer of the Original Code is Marko Savolainen (cubicreality@gmail.com).  
//  Portions created by Marko Savolainen Copyright (C) Marko Savolainen. All Rights Reserved. 
//                                                                                            
//******************************************************************************

unit CE_BookmarkTree;

interface

uses
  // CE Units
  CE_Bookmarks, CE_VistaFuncs, CE_SpTabBar, CE_Utils,
  // JVCL
  JvSimpleXml, JvAppStorage,
  // VSTools
  MPShellUtilities, MPCommonObjects, MPDataObject, MPCommonUtilities,
  // VT
  VirtualTrees, VirtualTrees.Types, VirtualTrees.BaseTree,
  // SpTBX
  SpTBXItem,
  // System Units
  Classes, SysUtils, Windows, Messages, ImgList, Controls, Contnrs,
  ActiveX, Graphics, Dialogs, System.UITypes;

type
  TCEBookmarkTree = class(TVirtualStringTree)
  private
    fDropNode: PVirtualNode;
    fAutoCollapse: Boolean;
    fAutoExpand: Boolean;
    fDragEnterMouseShiftState: TShiftState;
    fDropNodeAcceptsDrop: Boolean;
    fIndActive: Boolean;
    fIndMode: TDropMode;
    fIndNode: PVirtualNode;
    fOnBookmarksChange: TNotifyEvent;
  protected
    procedure ClearDropIndicator;
    procedure MoveSelectionTo(Pt: TPoint);
    function TargetInsideSelection(Node: PVirtualNode; const Nodes: TNodeArray): Boolean;
    procedure ClearDropNode;
    procedure DoDragDrop(Source: TObject; const DataObject: TVTDragDataObject; const Formats: TFormatArray; Shift: TShiftState; Pt: TPoint; var Effect: Integer; Mode:
        TDropMode); override;
    function DoDragOver(Source: TObject; Shift: TShiftState; State: TDragState; Pt:
        TPoint; Mode: TDropMode; var Effect: Integer): Boolean; override;
    procedure DoFreeNode(Node: PVirtualNode); override;
    function DoGetImageIndex(Node: PVirtualNode; Kind: TVTImageKind; Column:
        TColumnIndex; var Ghosted: Boolean; var Index: TImageIndex): TCustomImageList;
        override;
    procedure DoGetText(var pEventArgs: TVSTGetCellTextEventArgs); override;
    procedure GetTextLegacy(Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType; var Text: UnicodeString);
    function DoKeyAction(var CharCode: Word; var Shift: TShiftState): Boolean;
        override;
    procedure DoNewText(Node: PVirtualNode; Column: TColumnIndex; const Text: string); override;
    procedure DoPaintText(Node: PVirtualNode; const Canvas: TCanvas; Column:
        TColumnIndex; TextType: TVSTTextType); override;
    procedure HandleMouseDblClick(var Message: TWMMouse; const HitInfo: THitInfo);
        override;
    procedure HandleMouseDown(var Message: TWMMouse; var HitInfo: THitInfo);
        override;
    procedure HandleMouseUp(var Message: TWMMouse; const HitInfo: THitInfo);
        override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
        override;
    procedure PopulateTree(XmlDoc: TJvSimpleXml); virtual;
    procedure RefreshScrollHeight;
    function ResolveInternalDrop(var Node: PVirtualNode; Pt: TPoint): TDropMode;
    procedure ShowDropIndicator(Node: PVirtualNode; Mode: TDropMode);
  public
    constructor Create(AOwner: TComponent); override;
    procedure EditSelectedNode;
    function GetNodeComp(Node: PVirtualNode): TCECustomBookComp;
    function AddBookItem(ItemName: String; ParentNode: PVirtualNode): PVirtualNode;
    procedure BookmarksChange;
    procedure LoadFromXmlStream(S: TStream);
    procedure LoadFromXmlFile(AFilePath: WideString);
    procedure LoadFromXmlString(S: String);
    procedure PopulateXmlDoc(XmlDoc: TJvSimpleXml); virtual;
    procedure RefreshIcons;
    procedure SafeDeleteSelectedNodes;
    procedure SaveToXmlFile(AFilePath: WideString);
    procedure SaveToXmlStream(S: TStream);
    function SaveToXmlString: string;
    property AutoCollapse: Boolean read fAutoCollapse write fAutoCollapse;
    property AutoExpand: Boolean read fAutoExpand write fAutoExpand;
  published
    property OnBookmarksChange: TNotifyEvent read fOnBookmarksChange write
        fOnBookmarksChange;
  end;

implementation

uses
  CE_StdBookmarkComps, dCE_Actions, CE_LanguageEngine, Forms;

{*------------------------------------------------------------------------------
  Create an instance of TCEBookmarkTree object
-------------------------------------------------------------------------------}
constructor TCEBookmarkTree.Create(AOwner: TComponent);
begin
  inherited;
  Self.BevelInner:= bvNone;
  Self.BevelOuter:= bvNone;
  Self.BorderStyle:= bsNone;
  Self.DragMode:= dmAutomatic;
  // OLE drag: the mode Virtual Treeview's DoDragOver / DoDragDrop are made for.
  // With a Delphi (dtVCL) drag, Delphi cancelled every drop on mouse release
  // (dmDragLeave, dmDragCancel; CA-008) and DoDragDrop was never called.
  self.DragType:= dtOLE;
  Self.NodeDataSize:= SizeOf(TCEBookData);
  Self.TreeOptions.SelectionOptions:= [toRightClickSelect, toMultiSelect];
  Self.TreeOptions.AnimationOptions:= [];
  // The tree draws its own drop indicator (ShowDropIndicator), so that the line
  // always matches the place where the drop will really go.
  Self.TreeOptions.PaintOptions:= Self.TreeOptions.PaintOptions - [toShowDropmark];
  // toAutoDeleteMovedNodes is left out on purpose: moves inside the tree are done
  // with MoveTo, and Virtual Treeview must not delete the moved nodes afterwards.
  Self.TreeOptions.AutoOptions:= [toAutoDropExpand,toAutoScrollOnExpand,toAutoTristateTracking];
  Self.TreeOptions.MiscOptions:= [toAcceptOLEDrop,toEditable,toFullRepaintOnResize,toInitOnSave];
  Self.Header.Options:= [hoAutoResize,hoColumnResize];
  Self.ButtonFillMode:= fmShaded;
  Self.Images:= SmallSysImages;
  Self.IncrementalSearch:= isAll;
  Self.DefaultNodeHeight:= SmallShellIconSize + 1;
  LastBookmarkIconRefresh:= GetTickCount;
end;

{*------------------------------------------------------------------------------
  Get's called when Node is being freed.
-------------------------------------------------------------------------------}
procedure TCEBookmarkTree.DoFreeNode(Node: PVirtualNode);
var
  data: PCEBookData;
begin
  data:= GetNodeData(Node);
  try
    if assigned(data.BookComp) then
    data.BookComp.Free;
  finally
    inherited;
  end;
end;

{*------------------------------------------------------------------------------
  Populate tree from Xml document.
-------------------------------------------------------------------------------}
procedure TCEBookmarkTree.PopulateTree(XmlDoc: TJvSimpleXml);

  procedure EnumNode(XmlNode: TJvSimpleXmlElem; Node: PVirtualNode);
  var
    i: Integer;
    chNode: PVirtualNode;
    chXmlNode: TJvSimpleXmlElem;
    data: PCEBookData;
  begin
    for i:= 0 to XmlNode.Items.Count - 1 do
    begin
      chXmlNode:= XmlNode.Items.Item[i];
      chNode:= Self.AddChild(Node);
      data:= Self.GetNodeData(chNode);
      data.BookComp:= CEBookCompList.CreateNewComp(chXmlNode.Name);
      if not assigned(data.BookComp) then
      data.BookComp:= TCECustomBookComp.Create;
      data.BookComp.LoadFromXmlNode(chXmlNode);
      EnumNode(chXmlNode, chNode);
      Self.Expanded[chNode]:= data.BookComp.Expanded;
      if not data.BookComp.Enabled then
      Include(chNode.States, vsDisabled);
    end;
  end;

begin
  Self.BeginUpdate;
  Self.Clear;
  EnumNode(XmlDoc.Root, RootNode);
  Self.EndUpdate;
end;

{*------------------------------------------------------------------------------
  Populate Xml Document from tree.
-------------------------------------------------------------------------------}
procedure TCEBookmarkTree.PopulateXmlDoc(XmlDoc: TJvSimpleXml);

  procedure EnumNode(XmlNode: TJvSimpleXmlElem; Node: PVirtualNode);
  var
    chNode: PVirtualNode;
    chXmlNode: TJvSimpleXmlElem;
    data: PCEBookData;
  begin
    chNode:= Node.FirstChild;
    while chNode <> nil do
    begin
      data:= Self.GetNodeData(chNode);
      data.BookComp.Expanded:= Self.Expanded[chNode];
      chXmlNode:= XmlNode.Items.Add(CEBookCompList.GetCompName(data.BookComp));
      data.BookComp.SaveToXmlNode(chXmlNode);
      EnumNode(chXmlNode, chNode);
      chNode:= chNode.NextSibling;
    end;
  end;

var
  rootXmlNode: TJvSimpleXmlElem;
begin
  XmlDoc.Root.Name:= 'bookmarks';
  rootXmlNode:= XmlDoc.Root;
  EnumNode(rootXmlNode, RootNode);
end;

{*------------------------------------------------------------------------------
  Load tree from Xml stream
-------------------------------------------------------------------------------}
procedure TCEBookmarkTree.LoadFromXmlStream(S: TStream);
var
  XmlDoc: TJvSimpleXml;
begin
  try
    XmlDoc:= TJvSimpleXml.Create(nil);
    try
      XmlDoc.LoadFromStream(S);
      PopulateTree(XmlDoc);
    finally
      XmlDoc.Free;
      BookmarksChange;
    end;
  except
  end;
end;

{*------------------------------------------------------------------------------
  Load tree from Xml file
-------------------------------------------------------------------------------}
procedure TCEBookmarkTree.LoadFromXmlFile(AFilePath: WideString);
var
  S: TFileStream;
begin
  if FileExists(AFilePath) then
  begin
    s:= TFileStream.Create(AFilePath, fmOpenRead  or fmShareDenyNone);
    try
      LoadFromXmlStream(s);
    finally
      s.Free;
      BookmarksChange;
    end;
  end;
end;

{*------------------------------------------------------------------------------
  Load tree from Xml string
-------------------------------------------------------------------------------}
procedure TCEBookmarkTree.LoadFromXmlString(S: String);
var
  XmlDoc: TJvSimpleXml;
begin
  XmlDoc:= TJvSimpleXml.Create(nil);
  try
    XmlDoc.LoadFromString(S);
    PopulateTree(XmlDoc);
  finally
    XmlDoc.Free;
    BookmarksChange;
  end;
end;

{*------------------------------------------------------------------------------
  Save tree to Xml stream.
-------------------------------------------------------------------------------}
procedure TCEBookmarkTree.SaveToXmlStream(S: TStream);
var
  XmlDoc: TJvSimpleXml;
begin
  XmlDoc:= TJvSimpleXml.Create(nil);
  try
    PopulateXmlDoc(XmlDoc);
    XmlDoc.SaveToStream(S);
  finally
    XmlDoc.Free;
  end;
end;

{*------------------------------------------------------------------------------
  Save tree to Xml file.
-------------------------------------------------------------------------------}
procedure TCEBookmarkTree.SaveToXmlFile(AFilePath: WideString);
var
  S: TFileStream;
begin
  try
    s:= TFileStream.Create(AFilePath, fmCreate);
  except
    Exit;
  end;

  try
    SaveToXmlStream(s);
  finally
    s.Free;
  end;
end;

{*------------------------------------------------------------------------------
  Save tree to Xml string.
-------------------------------------------------------------------------------}
function TCEBookmarkTree.SaveToXmlString: string;
var
  XmlDoc: TJvSimpleXml;
begin
  XmlDoc:= TJvSimpleXml.Create(nil);
  try
    PopulateXmlDoc(XmlDoc);
  finally
    Result:= XmlDoc.SaveToString;
    XmlDoc.Free;
  end;
end;

{*------------------------------------------------------------------------------
  Call Bookmark change event
-------------------------------------------------------------------------------}
procedure TCEBookmarkTree.BookmarksChange;
begin
  if self.UpdateCount > 0 then Exit;
  if Assigned(fOnBookmarksChange) then fOnBookmarksChange(Self);
end;

{*------------------------------------------------------------------------------
  Get Node Comp
-------------------------------------------------------------------------------}
function TCEBookmarkTree.GetNodeComp(Node: PVirtualNode): TCECustomBookComp;
var
  data: PCEBookData;
begin
  data:= GetNodeData(Node);
  if assigned(data) then
  Result:= data.BookComp
  else
  Result:= nil;
end;

{*------------------------------------------------------------------------------
  Delete Selected Nodes
-------------------------------------------------------------------------------}
procedure TCEBookmarkTree.SafeDeleteSelectedNodes;
begin
  if (self.HasChildren[self.FocusedNode]) or (self.SelectedCount > 1) then
  begin
    if (TaskDialog(Application.MainFormHandle,
                   _('Confirm'),
                   _('Deleting multiple bookmarks!'),
                   _('Are you sure you want to delete selected bookmarks?'),
                   TD_ICON_QUESTION,
                   TD_BUTTON_YES + TD_BUTTON_NO) = TD_RESULT_YES) then
    begin
      self.DeleteSelectedNodes;
      BookmarksChange;
    end;
  end
  else
  begin
    self.DeleteSelectedNodes;
    BookmarksChange;
  end;
end;

{*------------------------------------------------------------------------------
  Get Node Text
-------------------------------------------------------------------------------}
procedure TCEBookmarkTree.DoGetText(var pEventArgs: TVSTGetCellTextEventArgs);
begin
  GetTextLegacy(pEventArgs.Node, pEventArgs.Column, ttNormal, pEventArgs.CellText);
end;

procedure TCEBookmarkTree.GetTextLegacy(Node: PVirtualNode; Column: TColumnIndex;
    TextType: TVSTTextType; var Text: UnicodeString);
var
  data: PCEBookData;
begin
  data:= GetNodeData(Node);
  if assigned(data.BookComp) then
  Text:= data.BookComp.Title;
end;

{*------------------------------------------------------------------------------
  Get's called when a new Text is assigned to a Node.
-------------------------------------------------------------------------------}
procedure TCEBookmarkTree.DoNewText(Node: PVirtualNode; Column: TColumnIndex;
    const Text: string);
var
  data: PCEBookData;
begin
  data:= GetNodeData(Node);
  if assigned(data.BookComp) then
  data.BookComp.Title:= Text;
  inherited;
  BookmarksChange;
end;

{*------------------------------------------------------------------------------
  Do PaintText
-------------------------------------------------------------------------------}
procedure TCEBookmarkTree.DoPaintText(Node: PVirtualNode; const Canvas:
    TCanvas; Column: TColumnIndex; TextType: TVSTTextType);
var
  data: PCEBookData;
begin
  data:= Self.GetNodeData(Node);
  if assigned(data.BookComp) then
  begin
    if data.BookComp.Ghosted and not Self.Selected[Node] then
    Canvas.Font.Color:= Colors.DisabledColor;
  end;
  inherited;
end;

{*------------------------------------------------------------------------------
  Get Image Index
-------------------------------------------------------------------------------}
function TCEBookmarkTree.DoGetImageIndex(Node: PVirtualNode; Kind:
    TVTImageKind; Column: TColumnIndex; var Ghosted: Boolean; var Index: TImageIndex): TCustomImageList;
var
  data: PCEBookData;
begin
  Result:= inherited DoGetImageIndex(Node, Kind, Column, Ghosted, Index);
  if (Column > 0) then
  begin
    Index:= -1;
    Exit;
  end;

  // CA-007: Virtual Treeview 8 asks for the state image too (ikState). The
  // bookmark icon was returned for it as well, so every entry showed its icon
  // twice. Only the normal/selected image and the overlay are wanted.
  if (Kind = ikState) then
  begin
    Index:= -1;
    Exit;
  end;

  data:= GetNodeData(Node);
  if assigned(data.BookComp) then
  begin
    Index:= data.BookComp.GetImageIndex(Expanded[Node], (Kind = ikOverlay));
    Ghosted:= data.BookComp.Ghosted;
    Result:= data.BookComp.ImageList;
  end;
end;

{*------------------------------------------------------------------------------
  Handle Mouse Dbl Click
-------------------------------------------------------------------------------}
procedure TCEBookmarkTree.HandleMouseDblClick(var Message: TWMMouse; const
    HitInfo: THitInfo);
begin
//  if not assigned(HitInfo.HitNode) then
//  Exit;
//  
//  if Self.Expanded[HitInfo.HitNode] then
//  begin
//    Self.ToggleNode(HitInfo.HitNode);
//    Exit;
//  end;
//
//  Self.BeginUpdate;
//  try
//    if fAutoCollapse then
//    Self.FullCollapse;
//
//    Self.ClearSelection;
//
//    Self.FullyVisible[HitInfo.HitNode]:= true;
//    Self.ToggleNode(HitInfo.HitNode);
//
//    Self.Selected[HitInfo.HitNode]:= true;
//    Self.FocusedNode:= HitInfo.HitNode;
//    Self.ScrollIntoView(HitInfo.HitNode,false,true);
//  finally
//    Self.EndUpdate;
//  end;
end;

{*------------------------------------------------------------------------------
  Handle Mouse Down.
-------------------------------------------------------------------------------}
procedure TCEBookmarkTree.HandleMouseDown(var Message: TWMMouse; var HitInfo:
    THitInfo);
begin
  if GetKeyState(VK_MENU) < 0 then
  Exit;
  
  inherited;

  Self.BeginUpdate;
  try
    if assigned(HitInfo.HitNode) and not (hiOnItemButton in HitInfo.HitPositions) then
    begin
      if fAutoCollapse then
      Self.FullCollapse;
      if fAutoExpand and not Self.Expanded[HitInfo.HitNode] then
      Self.ToggleNode(HitInfo.HitNode);
      Self.ScrollIntoView(HitInfo.HitNode,false,true);

      // Update scrollbar size (VT calculates wrong height if new items have been added.)
      RefreshScrollHeight;
    end
    else if (hiOnItemButton in HitInfo.HitPositions) then
    RefreshScrollHeight;
  finally
    Self.EndUpdate;
  end;
end;

{*------------------------------------------------------------------------------
  Handle Mouse Up.
-------------------------------------------------------------------------------}
procedure TCEBookmarkTree.HandleMouseUp(var Message: TWMMouse; const HitInfo:
    THitInfo);
begin
  inherited;
  self.DoStateChange([],[tsEditPending]);
end;

{*------------------------------------------------------------------------------
  Get's called on Mouse Down.
-------------------------------------------------------------------------------}
procedure TCEBookmarkTree.MouseDown(Button: TMouseButton; Shift: TShiftState;
    X, Y: Integer);
var
  data: PCEBookData;
  HitInfo: THitInfo;
begin
  Self.GetHitTestInfoAt(X,Y,true,HitInfo);

  if not assigned(HitInfo.HitNode) then
  Self.FocusedNode:= nil;

  if (hiOnItemButton in HitInfo.HitPositions) then
  begin
    inherited;
    Exit;
  end;

  if not (hiOnItemLabel in HitInfo.HitPositions) and not (hiOnNormalIcon in HitInfo.HitPositions) then
  begin
    Self.FocusedNode:= nil;
    Exit;
  end;

  if assigned(HitInfo.HitNode) then
  begin
    data:= GetNodeData(HitInfo.HitNode);
    if assigned(data.BookComp) then
    begin
      // A plain single click only selects; double-click / Alt / middle click act.
      if Shift <> [ssLeft] then
      data.BookComp.MouseClick(Shift,Button);
    end;
  end;

  inherited;
end;

{*------------------------------------------------------------------------------
  Get's called when a object is dropped.
-------------------------------------------------------------------------------}
procedure TCEBookmarkTree.DoDragDrop(Source: TObject; const DataObject: TVTDragDataObject; const Formats: TFormatArray; Shift: TShiftState; Pt: TPoint; var Effect: Integer;
    Mode: TDropMode);
var
 // data: PCEBookData;
  Attachmode: TVTNodeAttachMode;
  Nodes: TNodeArray;
  i: Integer;
  hd: TCommonShellIDList;
  data: PCEBookData;
  node: PVirtualNode;
begin

  // Get Attach mode
  case Mode of
    dmAbove:
      AttachMode := amInsertBefore;
    dmOnNode:
      AttachMode := amAddChildLast;
    dmBelow:
      AttachMode := amInsertAfter;
  else
    AttachMode := amNowhere;
  end;

  ClearDropIndicator;

  if Source = self then // Moving nodes inside self.
  begin
    MoveSelectionTo(Pt);
    // Tell the drag source that nothing is left to do (no copy, no delete).
    Effect:= DROPEFFECT_NONE;
  end
  else if assigned(DataObject) then// Dropping from outside self.
  begin
    Effect:= DROPEFFECT_LINK;
    hd:= TCommonShellIDList.Create;

    // Do custom drop action
    if fDropNodeAcceptsDrop and Assigned(fDropNode) and (Mode <> dmNowhere) then
    begin
      data:= Self.GetNodeData(fDropNode);
      if (Mode = dmOnNode) and data.BookComp.SupportsDragDrop then
      begin
        if Assigned(fDropNode) then
        begin
          try
            data:= Self.GetNodeData(fDropNode);
            Effect:= DROPEFFECT_COPY or DROPEFFECT_MOVE or DROPEFFECT_LINK;
            Shift:= Shift + fDragEnterMouseShiftState;
            data.BookComp.DoDragDrop(Self.DragManager.DataObject, Shift, Self.ClientToScreen(Pt), Effect);
            Exit; // ---> EXIT
          finally
            ClearDropNode;
          end;
        end;
      end;
    end;

    try
      Self.BeginUpdate;
      // Add new bookmark
      hd.LoadFromDataObject(DataObject);
      for i:= 0 to hd.PIDLCount-1 do
      begin
        if AttachMode = amNoWhere then
        AttachMode:= amInsertAfter;
        node:= InsertNode(Self.DropTargetNode, AttachMode);
        Self.ValidateNode(node, false);
        data:= GetNodeData(node);
        data.BookComp:= TCENormalItemComp.Create;
        TCENormalItemComp(data.BookComp).LoadFromPIDL(hd.AbsolutePIDL(i));
      end;

      // Update scrollbar size (VT doesn't do that automatically for some reason)
      RefreshScrollHeight;
    finally
      hd.Free;
      Self.EndUpdate;      
    end;
  end;
  inherited;
  Self.Invalidate;
  BookmarksChange;
end;

{*------------------------------------------------------------------------------
  Get's called when a object is dragged over.
-------------------------------------------------------------------------------}
function TCEBookmarkTree.DoDragOver(Source: TObject; Shift: TShiftState; State:
    TDragState; Pt: TPoint; Mode: TDropMode; var Effect: Integer): Boolean;
var
  Nodes: TNodeArray;
  i: Integer;
  tmpNode: PVirtualNode;
  dropNode: PVirtualNode;
  effMode: TDropMode;
  data: PCEBookData;
begin
  inherited DoDragOver(Source,Shift,State,Pt,Mode,Effect);
  Result:= false;

  if State = dsDragLeave then
  begin
    ClearDropIndicator;
  end;

  if Source = self then
  begin
    if State = dsDragLeave then
    begin
      Effect:= DROPEFFECT_NONE;
    end
    else if self.DropTargetNode = nil then
    begin
      // Empty area below the items: the nodes will be appended at the top level.
      Effect:= DROPEFFECT_MOVE;
      Result:= true;
      ShowDropIndicator(Self.GetLastVisible, dmBelow);
    end
    else // Internal move
    begin
      Nodes:= self.GetSortedSelection(True);
      dropNode:= self.DropTargetNode;
      effMode:= ResolveInternalDrop(dropNode, Pt);
      tmpNode:= dropNode;
      // Stop at the invisible root node: in Virtual Treeview its Parent field
      // points back at the tree object, not at a node, so walking past it read
      // garbage (access violation on every drag over the tree).
      while assigned(tmpNode) and (tmpNode <> Self.RootNode) do
      begin
        for i := 0 to High(Nodes) do
        begin
          if tmpNode = Nodes[i] then
          begin
            Effect:= DROPEFFECT_NONE;
            ClearDropIndicator;
            Exit;
          end;
        end;
        tmpNode:= tmpNode.Parent;
      end;

      // Copying (Ctrl) is not implemented, so a drag inside the tree always moves.
      Effect:= DROPEFFECT_MOVE;
      Result:= true;
      ShowDropIndicator(dropNode, effMode);
    end;
  end
  else if (source is TCESpTabToolbar) or (source is TSpTBXItemDragObject) then
  begin
    Effect:= DROPEFFECT_NONE;
    Result:= false;
  end
  else // Shell drop
  begin
    if (State <> dsDragLeave) and Assigned(Self.DropTargetNode) and (Mode <> dmNowhere) then
    begin
      ShowDropIndicator(Self.DropTargetNode, Mode);
    end
    else
    begin
      ClearDropIndicator;
    end;

    if State = dsDragLeave then
    begin
      ClearDropNode;
    end
    else if State = dsDragMove then
    begin
      if Assigned(Self.DropTargetNode) and (Mode <> dmNowhere) then
      begin
        data:= Self.GetNodeData(Self.DropTargetNode);
        if (Mode = dmOnNode) and data.BookComp.SupportsDragDrop then
        begin
          if fDropNode <> Self.DropTargetNode then
          begin
            ClearDropNode;
            fDropNode:= Self.DropTargetNode;
            if data.BookComp.DoDragEnter(Self.DragManager.DataObject, Shift, Self.ClientToScreen(Pt), Effect) then
            begin
              fDropNodeAcceptsDrop:= true;
              if ssLeft in Shift then
              fDragEnterMouseShiftState:= [ssLeft]
              else if ssRight in Shift then
              fDragEnterMouseShiftState:= [ssRight]
              else
              fDragEnterMouseShiftState:= [ssMiddle];
            end
            else
            begin
              Result:= True;
              Effect:= DROPEFFECT_LINK;
            end;
          end
          else if fDropNodeAcceptsDrop then
          begin
            Effect:= DROPEFFECT_COPY or DROPEFFECT_MOVE or DROPEFFECT_LINK;
            Result:= data.BookComp.DoDragOver(Shift, Self.ClientToScreen(Pt), Effect);
          end
          else
          begin
            Effect:= DROPEFFECT_LINK;
            Result:= true;
          end;
        end
        else
        begin
          ClearDropNode;
          Result:= True;
          Effect:= DROPEFFECT_LINK;
        end;
      end
      else
      begin
        ClearDropNode;
        Result:= True;
        Effect:= DROPEFFECT_LINK;
      end;
    end;
  end;
end;

{*------------------------------------------------------------------------------
  Get's called on Key Action.
-------------------------------------------------------------------------------}
function TCEBookmarkTree.DoKeyAction(var CharCode: Word; var Shift:
    TShiftState): Boolean;
var
  data: PCEBookData;
begin
  Result:= inherited DoKeyAction(CharCode, Shift);
  if CharCode = VK_DELETE then
  begin
    if Shift = [ssShift] then
    self.DeleteSelectedNodes
    else
    SafeDeleteSelectedNodes;
  end
  else
  begin
    data:= GetNodeData(Self.FocusedNode);
    if assigned(data) then
    begin
      data.BookComp.KeyAction(CharCode, Shift);
    end;
  end;
end;

{*------------------------------------------------------------------------------
  Edit selected node.
-------------------------------------------------------------------------------}
procedure TCEBookmarkTree.EditSelectedNode;
begin
  if IsEditing then Exit;
  if assigned(FocusedNode) then
  EditNode(FocusedNode,-1);
end;

{*------------------------------------------------------------------------------
  Add new bookmark item
-------------------------------------------------------------------------------}
function TCEBookmarkTree.AddBookItem(ItemName: String; ParentNode:
    PVirtualNode): PVirtualNode;
var
  data: PCEBookData;
begin
  Result:= Self.AddChild(ParentNode);
  data:= Self.GetNodeData(Result);
  data.BookComp:= CEBookCompList.CreateNewComp(ItemName);
  if not assigned(data.BookComp) then
  data.BookComp:= TCECustomBookComp.Create;
end;

{*------------------------------------------------------------------------------
  True when Node, or any of its ancestors, is one of Nodes. Dropping the
  selection there would move a node into itself or into its own descendant.
-------------------------------------------------------------------------------}
function TCEBookmarkTree.TargetInsideSelection(Node: PVirtualNode; const Nodes: TNodeArray): Boolean;
var
  i: Integer;
begin
  Result:= false;
  // Stop at the invisible root node: its Parent field points at the tree object.
  while Assigned(Node) and (Node <> Self.RootNode) do
  begin
    for i:= 0 to High(Nodes) do
    begin
      if (Node = Nodes[i]) then
      begin
        Result:= true;
        Exit;
      end;
    end;
    Node:= Node.Parent;
  end;
end;

{*------------------------------------------------------------------------------
  Move the selected nodes to the place under Pt (client coordinates), using the
  same rules as the drop indicator (see ResolveInternalDrop). Dropping on the
  empty area below the items appends the nodes at the top level. A drop onto the
  selection itself is ignored.
-------------------------------------------------------------------------------}
procedure TCEBookmarkTree.MoveSelectionTo(Pt: TPoint);
var
  Nodes: TNodeArray;
  target: PVirtualNode;
  effMode: TDropMode;
  i: Integer;
begin
  ClearDropIndicator;
  Nodes:= Self.GetSortedSelection(True);
  if (Length(Nodes) = 0) then
  begin
    Exit;
  end;

  target:= Self.GetNodeAt(Pt.X, Pt.Y);
  if (target = nil) then
  begin
    for i:= 0 to High(Nodes) do
    begin
      Self.MoveTo(Nodes[i], Self.RootNode, amAddChildLast, False);
    end;
  end
  else
  begin
    effMode:= ResolveInternalDrop(target, Pt);
    if TargetInsideSelection(target, Nodes) then
    begin
      Exit;
    end;
    case effMode of
      dmAbove:
        begin
          for i:= 0 to High(Nodes) do
          begin
            Self.MoveTo(Nodes[i], target, amInsertBefore, False);
          end;
        end;
      dmBelow:
        begin
          // each node goes right after the target, so go backwards to keep the order
          for i:= High(Nodes) downto 0 do
          begin
            Self.MoveTo(Nodes[i], target, amInsertAfter, False);
          end;
        end;
    else
      begin
        for i:= 0 to High(Nodes) do
        begin
          Self.MoveTo(Nodes[i], target, amAddChildLast, False);
        end;
      end;
    end;
  end;

  RefreshScrollHeight;
  Self.Invalidate;
  BookmarksChange;
end;

{*------------------------------------------------------------------------------
  Remove the drop indicator from the screen (if one is shown).
-------------------------------------------------------------------------------}
procedure TCEBookmarkTree.ClearDropIndicator;
begin
  if fIndActive then
  begin
    fIndActive:= false;
    fIndNode:= nil;
    Self.Invalidate;
    Self.Update;
  end;
end;

{*------------------------------------------------------------------------------
  Work out where a drag inside the tree would really drop, from the mouse
  position (Pt, client coordinates) over the target row.
  A category (or any node that already has children) can take items: the middle
  of its row means "inside", the top and bottom quarters mean "above" and
  "below". A plain bookmark cannot take items, so its row is only split in
  "above" (upper half) and "below" (lower half). "Below" an expanded node that
  has children means "first child", so Node is changed to that first child and
  the result is dmAbove; that is what the indicator line suggests visually.
  Likewise "below" a node that has a next sibling is reported as "above" that
  sibling (the same place), so only the last row of a level ever gets "below".
  Returns the drop mode; Node may be changed as described.
-------------------------------------------------------------------------------}
function TCEBookmarkTree.ResolveInternalDrop(var Node: PVirtualNode; Pt: TPoint): TDropMode;
var
  r: TRect;
  h: Integer;
  comp: TCECustomBookComp;
  isContainer: Boolean;
begin
  Result:= dmOnNode;
  if (Node = nil) then
  begin
    Exit;
  end;

  r:= Self.GetDisplayRect(Node, NoColumn, False);
  h:= r.Bottom - r.Top;
  if (h <= 0) then
  begin
    Exit;
  end;

  comp:= GetNodeComp(Node);
  isContainer:= (Node.ChildCount > 0) or (comp is TCECategoryComp);

  if isContainer then
  begin
    if (Pt.Y < r.Top + (h div 4)) then
    begin
      Result:= dmAbove;
    end
    else if (Pt.Y >= r.Bottom - (h div 4)) then
    begin
      Result:= dmBelow;
    end;
  end
  else if (Pt.Y < r.Top + (h div 2)) then
  begin
    Result:= dmAbove;
  end
  else
  begin
    Result:= dmBelow;
  end;

  if (Result = dmBelow) and (Node.ChildCount > 0) and Self.Expanded[Node] then
  begin
    Node:= Node.FirstChild;
    Result:= dmAbove;
  end;

  // "Below" a node and "above" its next sibling are the same place. Always
  // report the second one, so the indicator does not jump between the bottom of
  // one row and the top of the next while the mouse moves over the boundary.
  if (Result = dmBelow) and Assigned(Node.NextSibling) then
  begin
    Node:= Node.NextSibling;
    Result:= dmAbove;
  end;
end;

{*------------------------------------------------------------------------------
  Draw the drop indicator for Node: a line above or below the row, or a frame
  around the row for "inside". The previous indicator is erased first when it
  was somewhere else. The line is drawn straight onto the tree's canvas, which
  is how Virtual Treeview draws its own drop mark.
-------------------------------------------------------------------------------}
procedure TCEBookmarkTree.ShowDropIndicator(Node: PVirtualNode; Mode: TDropMode);
var
  r: TRect;
begin
  if fIndActive and ((Node <> fIndNode) or (Mode <> fIndMode)) then
  begin
    fIndActive:= false;
    Self.Invalidate;
    Self.Update;
  end;

  fIndNode:= Node;
  fIndMode:= Mode;
  fIndActive:= Assigned(Node) and (Mode <> dmNowhere);
  if not fIndActive then
  begin
    Exit;
  end;

  r:= Self.GetDisplayRect(Node, NoColumn, False);
  Canvas.Pen.Style:= psSolid;
  Canvas.Pen.Color:= clHighlight;
  Canvas.Pen.Width:= 2;
  case Mode of
    dmAbove:
      begin
        Canvas.MoveTo(r.Left, r.Top + 1);
        Canvas.LineTo(r.Right, r.Top + 1);
      end;
    dmBelow:
      begin
        Canvas.MoveTo(r.Left, r.Bottom - 1);
        Canvas.LineTo(r.Right, r.Bottom - 1);
      end;
    dmOnNode:
      begin
        Canvas.Brush.Style:= bsClear;
        Canvas.Rectangle(r.Left, r.Top, r.Right, r.Bottom);
      end;
  end;
end;

{-------------------------------------------------------------------------------
  Clear Drop Node
-------------------------------------------------------------------------------}
procedure TCEBookmarkTree.ClearDropNode;
var
  data: PCEBookData;
begin
  if fDropNodeAcceptsDrop and Assigned(fDropNode) then
  begin
    data:= Self.GetNodeData(fDropNode);
    if assigned(data.BookComp) then
    data.BookComp.DoDragLeave;
  end;
  fDropNode:= nil;
  fDropNodeAcceptsDrop:= false;
end;

{-------------------------------------------------------------------------------
  RefreshIcons
-------------------------------------------------------------------------------}
procedure TCEBookmarkTree.RefreshIcons;
begin
  LastBookmarkIconRefresh:= GetTickCount;
  Self.Refresh;
end;

{-------------------------------------------------------------------------------
  Refresh Scroll Height
-------------------------------------------------------------------------------}
procedure TCEBookmarkTree.RefreshScrollHeight;
var
  h: Integer;
  node: PVirtualNode;
begin
  h:= Self.RootNode.NodeHeight + Self.BottomSpace;
  node:= Self.GetFirstVisible;
  while assigned(node) do
  begin
    h:= h + node.NodeHeight;
    node:= Self.GetNextVisible(node);
  end;
  Self.RootNode.TotalHeight:= h;
end;


end.
