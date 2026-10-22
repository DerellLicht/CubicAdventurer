unit CE_FileViewColors;

// Folder text color and attribute background colors for the file view.
// (CubicAdventurer addition; modeled on the ndir32 lister.)
//
//   * Folders get their own text (foreground) color.
//   * Files with the System, Read-only or Hidden attribute get a background
//     color; a file with more than one of those attributes set gets the
//     "combined" background color.
//
// Every color uses clDefault (or clNone) to mean "off": that item is drawn
// exactly as before. All colors default to "off".
//
// The backgrounds are painted by small TEasyViewItem descendants. They are
// swapped in for the library's standard item views from
// TCECustomFileView.DoItemCustomView, and they paint in PaintBefore, which the
// library calls before the selection rectangle, icon and text are drawn, so
// selection highlighting and text stay on top of the background.

interface

uses
  Windows, Classes, Graphics,
  EasyListview, VirtualExplorerEasyListview, MPShellUtilities;

type
  TCEFileViewColors = record
    FolderTextColor: TColor;
    SystemBgColor: TColor;
    ReadOnlyBgColor: TColor;
    HiddenBgColor: TColor;
    CombinedBgColor: TColor;
  end;

  // One descendant per standard view that shows a one-row-per-item layout.
  // (Icon, Thumbnail, Tile and Filmstrip views are left alone.)
  TCEViewSmallIconItem = class(TEasyViewSmallIconItem)
  public
    procedure PaintBefore(Item: TEasyItem; Column: TEasyColumn; const Caption:
        string; ACanvas: TCanvas; RectArray: TEasyRectArrayObject; var Handled:
        Boolean); override;
  end;

  TCEViewListItem = class(TEasyViewListItem)
  public
    procedure PaintBefore(Item: TEasyItem; Column: TEasyColumn; const Caption:
        string; ACanvas: TCanvas; RectArray: TEasyRectArrayObject; var Handled:
        Boolean); override;
  end;

  TCEViewReportItem = class(TEasyViewReportItem)
  public
    procedure PaintBefore(Item: TEasyItem; Column: TEasyColumn; const Caption:
        string; ACanvas: TCanvas; RectArray: TEasyRectArrayObject; var Handled:
        Boolean); override;
  end;

  TCEViewReportThumbItem = class(TEasyViewReportThumbItem)
  public
    procedure PaintBefore(Item: TEasyItem; Column: TEasyColumn; const Caption:
        string; ACanvas: TCanvas; RectArray: TEasyRectArrayObject; var Handled:
        Boolean); override;
  end;

var
  // Current colors. Written by TCEFileViewSettings.AssignSettingsTo, read while
  // painting. (The settings are global, so one set serves every file view.)
  CEFileViewColors: TCEFileViewColors = (
    FolderTextColor: clDefault;
    SystemBgColor: clDefault;
    ReadOnlyBgColor: clDefault;
    HiddenBgColor: clDefault;
    CombinedBgColor: clDefault);

// True if AColor is an actual color, i.e. not clDefault / clNone.
function CE_IsColorSet(AColor: TColor): Boolean;

// True (and the color in AColor) if Item is a real directory and a folder text
// color is configured.
function CE_GetFolderTextColor(Item: TEasyItem; out AColor: TColor): Boolean;

// True (and the color in AColor) if Item has the System, Read-only and/or
// Hidden attribute and a matching background color is configured.
function CE_GetAttrBackgroundColor(Item: TEasyItem; out AColor: TColor): Boolean;

// Replaces View with the matching colorizing view class when ViewStyle is one
// of the views listed above and no other custom view has been chosen.
procedure CE_ColorizeItemView(ViewStyle: TEasyListStyle; var View:
    TEasyViewItemClass);

implementation

{*------------------------------------------------------------------------------
  Returns the namespace of Item, or nil if it has none.
-------------------------------------------------------------------------------}
function ItemNamespace(Item: TEasyItem): TNamespace;
begin
  Result:= nil;
  if Item is TExplorerItem then
  begin
    Result:= TExplorerItem(Item).Namespace;
  end;
end;

{*------------------------------------------------------------------------------
  True if AColor is a usable color.
-------------------------------------------------------------------------------}
function CE_IsColorSet(AColor: TColor): Boolean;
begin
  Result:= (AColor <> clDefault) and (AColor <> clNone);
end;

{*------------------------------------------------------------------------------
  Folder text color. Uses the real directory attribute (cached WIN32_FIND_DATA
  of the namespace), so zip files and shortcuts are not treated as folders.
-------------------------------------------------------------------------------}
function CE_GetFolderTextColor(Item: TEasyItem; out AColor: TColor): Boolean;
var
  ns: TNamespace;
begin
  Result:= false;
  AColor:= clDefault;
  if not CE_IsColorSet(CEFileViewColors.FolderTextColor) then
  begin
    Exit;
  end;
  ns:= ItemNamespace(Item);
  if Assigned(ns) and ns.Directory then
  begin
    AColor:= CEFileViewColors.FolderTextColor;
    Result:= true;
  end;
end;

{*------------------------------------------------------------------------------
  Attribute background color.
  The attributes come from the namespace's cached WIN32_FIND_DATA, so no extra
  disk access happens while painting.
  One attribute set    -> that attribute's color.
  Two or three set     -> the combined color (nothing if it is "off").
-------------------------------------------------------------------------------}
function CE_GetAttrBackgroundColor(Item: TEasyItem; out AColor: TColor): Boolean;
var
  ns: TNamespace;
  isSystem, isReadOnly, isHidden: Boolean;
  count: Integer;
begin
  Result:= false;
  AColor:= clDefault;
  ns:= ItemNamespace(Item);
  if (not Assigned(ns)) or (not ns.FileSystem) then
  begin
    Exit;
  end;

  isSystem:= ns.SystemFile;
  isReadOnly:= ns.ReadOnlyFile;
  isHidden:= ns.Hidden;

  count:= 0;
  if isSystem then
  begin
    Inc(count);
  end;
  if isReadOnly then
  begin
    Inc(count);
  end;
  if isHidden then
  begin
    Inc(count);
  end;

  if count = 0 then
  begin
    Exit;
  end;

  if count > 1 then
  begin
    AColor:= CEFileViewColors.CombinedBgColor;
  end
  else if isSystem then
  begin
    AColor:= CEFileViewColors.SystemBgColor;
  end
  else if isReadOnly then
  begin
    AColor:= CEFileViewColors.ReadOnlyBgColor;
  end
  else
  begin
    AColor:= CEFileViewColors.HiddenBgColor;
  end;

  Result:= CE_IsColorSet(AColor);
end;

{*------------------------------------------------------------------------------
  Fills the background of Item's cell.
  Report views: the whole cell, so the colored row is continuous across the
  columns. Other views: icon plus text only (the cell itself can be much wider
  than the name).
-------------------------------------------------------------------------------}
procedure PaintAttrBackground(Item: TEasyItem; ACanvas: TCanvas; const
    RectArray: TEasyRectArrayObject; FullCell: Boolean);
var
  color: TColor;
  r: TRect;
begin
  if not CE_GetAttrBackgroundColor(Item, color) then
  begin
    Exit;
  end;

  if FullCell then
  begin
    r:= RectArray.BoundsRect;
  end
  else
  begin
    UnionRect(r, RectArray.IconRect, RectArray.TextRect);
    r.Top:= RectArray.BoundsRect.Top;
    r.Bottom:= RectArray.BoundsRect.Bottom;
  end;

  if IsRectEmpty(r) then
  begin
    Exit;
  end;

  // The library saves and restores the canvas state around each item paint.
  ACanvas.Brush.Style:= bsSolid;
  ACanvas.Brush.Color:= color;
  ACanvas.FillRect(r);
end;

{ TCEViewSmallIconItem }

procedure TCEViewSmallIconItem.PaintBefore(Item: TEasyItem; Column:
    TEasyColumn; const Caption: string; ACanvas: TCanvas; RectArray:
    TEasyRectArrayObject; var Handled: Boolean);
begin
  inherited PaintBefore(Item, Column, Caption, ACanvas, RectArray, Handled);
  PaintAttrBackground(Item, ACanvas, RectArray, false);
end;

{ TCEViewListItem }

procedure TCEViewListItem.PaintBefore(Item: TEasyItem; Column: TEasyColumn;
    const Caption: string; ACanvas: TCanvas; RectArray: TEasyRectArrayObject;
    var Handled: Boolean);
begin
  inherited PaintBefore(Item, Column, Caption, ACanvas, RectArray, Handled);
  PaintAttrBackground(Item, ACanvas, RectArray, false);
end;

{ TCEViewReportItem }

procedure TCEViewReportItem.PaintBefore(Item: TEasyItem; Column: TEasyColumn;
    const Caption: string; ACanvas: TCanvas; RectArray: TEasyRectArrayObject;
    var Handled: Boolean);
begin
  inherited PaintBefore(Item, Column, Caption, ACanvas, RectArray, Handled);
  PaintAttrBackground(Item, ACanvas, RectArray, true);
end;

{ TCEViewReportThumbItem }

procedure TCEViewReportThumbItem.PaintBefore(Item: TEasyItem; Column:
    TEasyColumn; const Caption: string; ACanvas: TCanvas; RectArray:
    TEasyRectArrayObject; var Handled: Boolean);
begin
  inherited PaintBefore(Item, Column, Caption, ACanvas, RectArray, Handled);
  PaintAttrBackground(Item, ACanvas, RectArray, true);
end;

{*------------------------------------------------------------------------------
  Swap the library's standard item view for the colorizing one.
  Only done when nobody else chose a custom view (View is nil or the stock
  class), so the library's own choices (thumbnail captions) are untouched.
-------------------------------------------------------------------------------}
procedure CE_ColorizeItemView(ViewStyle: TEasyListStyle; var View:
    TEasyViewItemClass);
begin
  case ViewStyle of
    elsSmallIcon: begin
      if (View = nil) or (View = TEasyViewSmallIconItem) then
      begin
        View:= TCEViewSmallIconItem;
      end;
    end;
    elsList: begin
      if (View = nil) or (View = TEasyViewListItem) then
      begin
        View:= TCEViewListItem;
      end;
    end;
    elsReport: begin
      if (View = nil) or (View = TEasyViewReportItem) then
      begin
        View:= TCEViewReportItem;
      end;
    end;
    elsReportThumb: begin
      if (View = nil) or (View = TEasyViewReportThumbItem) then
      begin
        View:= TCEViewReportThumbItem;
      end;
    end;
  end;
end;

end.
