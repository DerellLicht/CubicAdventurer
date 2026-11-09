unit CE_FileViewColors;

// Folder text color, attribute background colors and extension background
// colors for the file view.
// (CubicAdventurer addition; modeled on the ndir32 lister.)
//
//   * Folders get their own text (foreground) color.
//   * Files with the System, Read-only or Hidden attribute get a background
//     color; a file with more than one of those attributes set gets the
//     "combined" background color.
//
//   * Files whose extension is listed in Options > Display > Fileview > Colors
//     with "Enable background color" checked get that entry's background color.
//     The attribute colors win over it: a System, Read-only or Hidden file
//     always shows its attribute color, never hidden by an extension color.
//
// Every color uses clDefault (or clNone) to mean "off": that item is drawn
// exactly as before. All colors default to "off".
//
// Report, List and Small Icon views color a row (or icon plus text); Icon,
// Thumbnail and Tile views color the whole item "card" behind the picture and
// caption. Filmstrip is left alone.
//
// The backgrounds are painted by small TEasyViewItem descendants. They are
// swapped in for the library's standard item views from
// TCECustomFileView.DoItemCustomView, and they paint in PaintBefore, which the
// library calls before the selection rectangle, icon and text are drawn, so
// selection highlighting and text stay on top of the background.

interface

uses
  Windows, SysUtils, Classes, Graphics, Generics.Collections,
  EasyListview, VirtualExplorerEasyListview, MPShellUtilities;

type
  TCEFileViewColors = record
    FolderTextColor: TColor;
    SystemBgColor: TColor;
    ReadOnlyBgColor: TColor;
    HiddenBgColor: TColor;
    CombinedBgColor: TColor;
  end;

  // One descendant per standard item view that gets a background color.
  // (The Filmstrip view is left alone.)
  TCEViewSmallIconItem = class(TEasyViewSmallIconItem)
  public
    procedure PaintBefore(Item: TEasyItem; Column: TEasyColumn; const Caption:
        string; ACanvas: TCanvas; RectArray: TEasyRectArrayObject; var Handled:
        Boolean); override;
    procedure PaintCheckBox(Item: TEasyItem; Column: TEasyColumn; RectArray:
        TEasyRectArrayObject; ACanvas: TCanvas); override;
  end;

  TCEViewListItem = class(TEasyViewListItem)
  public
    procedure PaintBefore(Item: TEasyItem; Column: TEasyColumn; const Caption:
        string; ACanvas: TCanvas; RectArray: TEasyRectArrayObject; var Handled:
        Boolean); override;
    procedure PaintCheckBox(Item: TEasyItem; Column: TEasyColumn; RectArray:
        TEasyRectArrayObject; ACanvas: TCanvas); override;
  end;

  TCEViewReportItem = class(TEasyViewReportItem)
  public
    procedure PaintBefore(Item: TEasyItem; Column: TEasyColumn; const Caption:
        string; ACanvas: TCanvas; RectArray: TEasyRectArrayObject; var Handled:
        Boolean); override;
    procedure PaintCheckBox(Item: TEasyItem; Column: TEasyColumn; RectArray:
        TEasyRectArrayObject; ACanvas: TCanvas); override;
  end;

  TCEViewReportThumbItem = class(TEasyViewReportThumbItem)
  public
    procedure PaintBefore(Item: TEasyItem; Column: TEasyColumn; const Caption:
        string; ACanvas: TCanvas; RectArray: TEasyRectArrayObject; var Handled:
        Boolean); override;
    procedure PaintCheckBox(Item: TEasyItem; Column: TEasyColumn; RectArray:
        TEasyRectArrayObject; ACanvas: TCanvas); override;
  end;

  TCEViewIconItem = class(TEasyViewIconItem)
  public
    procedure PaintBefore(Item: TEasyItem; Column: TEasyColumn; const Caption:
        string; ACanvas: TCanvas; RectArray: TEasyRectArrayObject; var Handled:
        Boolean); override;
    procedure PaintCheckBox(Item: TEasyItem; Column: TEasyColumn; RectArray:
        TEasyRectArrayObject; ACanvas: TCanvas); override;
  end;

  TCEViewThumbnailItem = class(TEasyViewThumbnailItem)
  public
    procedure PaintBefore(Item: TEasyItem; Column: TEasyColumn; const Caption:
        string; ACanvas: TCanvas; RectArray: TEasyRectArrayObject; var Handled:
        Boolean); override;
    procedure PaintCheckBox(Item: TEasyItem; Column: TEasyColumn; RectArray:
        TEasyRectArrayObject; ACanvas: TCanvas); override;
  end;

  TCEViewTileItem = class(TEasyViewTileItem)
  public
    procedure PaintBefore(Item: TEasyItem; Column: TEasyColumn; const Caption:
        string; ACanvas: TCanvas; RectArray: TEasyRectArrayObject; var Handled:
        Boolean); override;
    procedure PaintCheckBox(Item: TEasyItem; Column: TEasyColumn; RectArray:
        TEasyRectArrayObject; ACanvas: TCanvas); override;
  end;

  // Group header band (Group By): themed check box and caption color.
  TCEViewGroup = class(TEasyViewGroup)
  public
    procedure LoadTextFont(Group: TEasyGroup; ACanvas: TCanvas); override;
    procedure PaintCheckBox(Group: TEasyGroup; ACanvas: TCanvas; RectArray:
        TEasyRectArrayObject); override;
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

// Same two lookups for a bare namespace (used by the Folders tree, which has no
// TEasyItem).
function CE_GetNamespaceFolderTextColor(ns: TNamespace; out AColor: TColor): Boolean;
function CE_GetNamespaceAttrBackgroundColor(ns: TNamespace; out AColor: TColor): Boolean;

// Loads the extension background colors from the stored ExtensionColors string
// (entries 'exts,color,bold,italic,underline,bgEnabled,bgColor' separated by
// '|'; the last two fields are optional). AEnabled is the "Use extension
// colors" master switch; when it is false no extension gets a background.
procedure CE_SetExtensionBgColors(AEnabled: Boolean; const AColors: WideString);

// True (and the color in AColor) if Item is a file whose extension has a
// background color configured.
function CE_GetExtBackgroundColor(Item: TEasyItem; out AColor: TColor): Boolean;

// Replaces View with the matching colorizing view class when ViewStyle is one
// of the views listed above and no other custom view has been chosen.
procedure CE_ColorizeItemView(ViewStyle: TEasyListStyle; var View:
    TEasyViewItemClass);

// Replaces the standard group view with the themed one (see TCEViewGroup).
procedure CE_ColorizeGroupView(var View: TEasyViewGroupClass);

implementation

uses
  Controls, StdCtrls, SpTBXSkins;

type
  // Gives this unit access to the protected check-box properties of TEasyItem.
  TCEItemCracker = class(TEasyItem);
  TCEGroupCracker = class(TEasyGroup);

// True when the active theme comes from a skin file or a Delphi style, i.e. when
// the library would draw plain Windows controls on it.
function ThemeNeedsOwnDrawing(AListview: TControl): Boolean;
begin
  Result:= SkinManager.GetSkinType(AListview) in [sknSkin, sknDelphiStyle];
end;

// Draws one themed check box glyph (the same routine SpTBXLib uses for its own
// check boxes).
procedure DrawThemedCheckGlyph(AListview: TControl; ACanvas: TCanvas; ARect:
    TRect; AEnabled, AChecked, AHovering, APending: Boolean);
var
  state: TCheckBoxState;
begin
  if AChecked then
  begin
    state:= cbChecked;
  end
  else
  begin
    state:= cbUnchecked;
  end;
  InflateRect(ARect, -1, -1);
  SpDrawXPCheckBoxGlyph(AListview, ACanvas, ARect, AEnabled, state, AHovering,
      APending, AListview.CurrentPPI);
end;

{*------------------------------------------------------------------------------
  Draws the item check box with the active SpTBX theme.
  The library can do this itself only when it is compiled with its SpTBX
  switch, which the installed copy is not, so without this the check boxes are
  always plain Windows ones (white box on a dark theme).
  Returns true if the box was drawn here. Returns false when the library should
  draw it: Windows or no theme, radio buttons, and columns after the first.
-------------------------------------------------------------------------------}
function PaintThemedCheckBox(AListview: TControl; Item: TEasyItem; Column:
    TEasyColumn; const RectArray: TEasyRectArrayObject; ACanvas: TCanvas): Boolean;
var
  crack: TCEItemCracker;
begin
  Result:= false;
  if not ThemeNeedsOwnDrawing(AListview) then
  begin
    Exit;
  end;
  crack:= TCEItemCracker(Item);
  if crack.CheckType <> ectBox then
  begin
    Exit;
  end;
  if Assigned(Column) and (Column.Index > 0) then
  begin
    Exit;
  end;
  DrawThemedCheckGlyph(AListview, ACanvas, RectArray.CheckRect, crack.Enabled,
      crack.Checked, crack.CheckHovering, crack.CheckPending);
  Result:= true;
end;

var
  // Lower case extension (no dot) -> background color. See CE_SetExtensionBgColors.
  ExtBgColors: TDictionary<string, TColor>;

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
function CE_GetNamespaceFolderTextColor(ns: TNamespace; out AColor: TColor): Boolean;
begin
  Result:= false;
  AColor:= clDefault;
  if not CE_IsColorSet(CEFileViewColors.FolderTextColor) then
  begin
    Exit;
  end;
  if Assigned(ns) and ns.Directory then
  begin
    AColor:= CEFileViewColors.FolderTextColor;
    Result:= true;
  end;
end;

function CE_GetFolderTextColor(Item: TEasyItem; out AColor: TColor): Boolean;
begin
  Result:= CE_GetNamespaceFolderTextColor(ItemNamespace(Item), AColor);
end;

{*------------------------------------------------------------------------------
  Attribute background color.
  The attributes come from the namespace's cached WIN32_FIND_DATA, so no extra
  disk access happens while painting.
  One attribute set    -> that attribute's color.
  Two or three set     -> the combined color (nothing if it is "off").
-------------------------------------------------------------------------------}
function CE_GetNamespaceAttrBackgroundColor(ns: TNamespace; out AColor: TColor): Boolean;
var
  isSystem, isReadOnly, isHidden: Boolean;
  count: Integer;
begin
  Result:= false;
  AColor:= clDefault;
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

function CE_GetAttrBackgroundColor(Item: TEasyItem; out AColor: TColor): Boolean;
begin
  Result:= CE_GetNamespaceAttrBackgroundColor(ItemNamespace(Item), AColor);
end;

{*------------------------------------------------------------------------------
  Parses the stored extension color list and keeps the entries that have a
  background color enabled. An extension listed twice keeps its first color.
  Entries without the two optional trailing fields (settings written before
  background colors existed) simply have no background.
-------------------------------------------------------------------------------}
procedure CE_SetExtensionBgColors(AEnabled: Boolean; const AColors: WideString);
var
  stored, entry, ext, key: string;
  fields, exts: TArray<string>;
  color: TColor;
begin
  ExtBgColors.Clear;
  if (not AEnabled) or (AColors = '') then
  begin
    Exit;
  end;

  stored:= AColors;
  for entry in stored.Split(['|']) do
  begin
    fields:= entry.Split([',']);
    // 0 extensions, 1 color, 2 bold, 3 italic, 4 underline, 5 bg enabled, 6 bg color
    if Length(fields) < 7 then
    begin
      Continue;
    end;
    if not StrToBoolDef(Trim(fields[5]), false) then
    begin
      Continue;
    end;
    color:= StrToIntDef(Trim(fields[6]), clDefault);
    if not CE_IsColorSet(color) then
    begin
      Continue;
    end;

    // the extensions field is stored with ';' as separator; also accept ':'
    exts:= fields[0].Replace(':', ';').Split([';']);
    for ext in exts do
    begin
      // strip blanks and any '*' / '.' prefix, keep the bare lower case extension
      key:= LowerCase(Trim(ext));
      while (key <> '') and ((key[1] = '*') or (key[1] = '.')) do
      begin
        Delete(key, 1, 1);
      end;
      if (key <> '') and (not ExtBgColors.ContainsKey(key)) then
      begin
        ExtBgColors.Add(key, color);
      end;
    end;
  end;
end;

{*------------------------------------------------------------------------------
  Extension background color of a file (never for folders).
-------------------------------------------------------------------------------}
function CE_GetExtBackgroundColor(Item: TEasyItem; out AColor: TColor): Boolean;
var
  ns: TNamespace;
  ext: string;
begin
  Result:= false;
  AColor:= clDefault;
  if ExtBgColors.Count = 0 then
  begin
    Exit;
  end;
  ns:= ItemNamespace(Item);
  if (not Assigned(ns)) or (not ns.FileSystem) or ns.Directory then
  begin
    Exit;
  end;
  ext:= LowerCase(ns.Extension);
  if (ext <> '') and (ext[1] = '.') then
  begin
    Delete(ext, 1, 1);
  end;
  if ext = '' then
  begin
    Exit;
  end;
  Result:= ExtBgColors.TryGetValue(ext, AColor) and CE_IsColorSet(AColor);
end;

{*------------------------------------------------------------------------------
  Fills the background of Item's cell with the attribute background color or,
  if the file has no attribute color, the extension background color.
  FullCell = true: the whole cell. Used by the Report views (the colored row is
  continuous across the columns) and by the Icon, Thumbnail and Tile views (the
  cell is a card holding the picture and caption).
  FullCell = false: icon plus text only (Small Icon and List views, where the
  cell itself can be much wider than the name).
-------------------------------------------------------------------------------}
procedure PaintAttrBackground(Item: TEasyItem; ACanvas: TCanvas; const
    RectArray: TEasyRectArrayObject; FullCell: Boolean);
var
  color: TColor;
  r: TRect;
begin
  if (not CE_GetAttrBackgroundColor(Item, color)) and
      (not CE_GetExtBackgroundColor(Item, color)) then
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

procedure TCEViewSmallIconItem.PaintCheckBox(Item: TEasyItem; Column: TEasyColumn;
    RectArray: TEasyRectArrayObject; ACanvas: TCanvas);
begin
  if not PaintThemedCheckBox(OwnerListview, Item, Column, RectArray, ACanvas) then
  begin
    inherited PaintCheckBox(Item, Column, RectArray, ACanvas);
  end;
end;

procedure TCEViewSmallIconItem.PaintBefore(Item: TEasyItem; Column:
    TEasyColumn; const Caption: string; ACanvas: TCanvas; RectArray:
    TEasyRectArrayObject; var Handled: Boolean);
begin
  inherited PaintBefore(Item, Column, Caption, ACanvas, RectArray, Handled);
  PaintAttrBackground(Item, ACanvas, RectArray, false);
end;

{ TCEViewListItem }

procedure TCEViewListItem.PaintCheckBox(Item: TEasyItem; Column: TEasyColumn;
    RectArray: TEasyRectArrayObject; ACanvas: TCanvas);
begin
  if not PaintThemedCheckBox(OwnerListview, Item, Column, RectArray, ACanvas) then
  begin
    inherited PaintCheckBox(Item, Column, RectArray, ACanvas);
  end;
end;

procedure TCEViewListItem.PaintBefore(Item: TEasyItem; Column: TEasyColumn;
    const Caption: string; ACanvas: TCanvas; RectArray: TEasyRectArrayObject;
    var Handled: Boolean);
begin
  inherited PaintBefore(Item, Column, Caption, ACanvas, RectArray, Handled);
  PaintAttrBackground(Item, ACanvas, RectArray, false);
end;

{ TCEViewReportItem }

procedure TCEViewReportItem.PaintCheckBox(Item: TEasyItem; Column: TEasyColumn;
    RectArray: TEasyRectArrayObject; ACanvas: TCanvas);
begin
  if not PaintThemedCheckBox(OwnerListview, Item, Column, RectArray, ACanvas) then
  begin
    inherited PaintCheckBox(Item, Column, RectArray, ACanvas);
  end;
end;

procedure TCEViewReportItem.PaintBefore(Item: TEasyItem; Column: TEasyColumn;
    const Caption: string; ACanvas: TCanvas; RectArray: TEasyRectArrayObject;
    var Handled: Boolean);
begin
  inherited PaintBefore(Item, Column, Caption, ACanvas, RectArray, Handled);
  PaintAttrBackground(Item, ACanvas, RectArray, true);
end;

{ TCEViewReportThumbItem }

procedure TCEViewReportThumbItem.PaintCheckBox(Item: TEasyItem; Column: TEasyColumn;
    RectArray: TEasyRectArrayObject; ACanvas: TCanvas);
begin
  if not PaintThemedCheckBox(OwnerListview, Item, Column, RectArray, ACanvas) then
  begin
    inherited PaintCheckBox(Item, Column, RectArray, ACanvas);
  end;
end;

procedure TCEViewReportThumbItem.PaintBefore(Item: TEasyItem; Column:
    TEasyColumn; const Caption: string; ACanvas: TCanvas; RectArray:
    TEasyRectArrayObject; var Handled: Boolean);
begin
  inherited PaintBefore(Item, Column, Caption, ACanvas, RectArray, Handled);
  PaintAttrBackground(Item, ACanvas, RectArray, true);
end;

{ TCEViewIconItem }

procedure TCEViewIconItem.PaintCheckBox(Item: TEasyItem; Column: TEasyColumn;
    RectArray: TEasyRectArrayObject; ACanvas: TCanvas);
begin
  if not PaintThemedCheckBox(OwnerListview, Item, Column, RectArray, ACanvas) then
  begin
    inherited PaintCheckBox(Item, Column, RectArray, ACanvas);
  end;
end;

procedure TCEViewIconItem.PaintBefore(Item: TEasyItem; Column: TEasyColumn;
    const Caption: string; ACanvas: TCanvas; RectArray: TEasyRectArrayObject;
    var Handled: Boolean);
begin
  inherited PaintBefore(Item, Column, Caption, ACanvas, RectArray, Handled);
  PaintAttrBackground(Item, ACanvas, RectArray, true);
end;

{ TCEViewThumbnailItem }

procedure TCEViewThumbnailItem.PaintCheckBox(Item: TEasyItem; Column: TEasyColumn;
    RectArray: TEasyRectArrayObject; ACanvas: TCanvas);
begin
  if not PaintThemedCheckBox(OwnerListview, Item, Column, RectArray, ACanvas) then
  begin
    inherited PaintCheckBox(Item, Column, RectArray, ACanvas);
  end;
end;

procedure TCEViewThumbnailItem.PaintBefore(Item: TEasyItem; Column:
    TEasyColumn; const Caption: string; ACanvas: TCanvas; RectArray:
    TEasyRectArrayObject; var Handled: Boolean);
begin
  inherited PaintBefore(Item, Column, Caption, ACanvas, RectArray, Handled);
  PaintAttrBackground(Item, ACanvas, RectArray, true);
end;

{ TCEViewTileItem }

procedure TCEViewTileItem.PaintCheckBox(Item: TEasyItem; Column: TEasyColumn;
    RectArray: TEasyRectArrayObject; ACanvas: TCanvas);
begin
  if not PaintThemedCheckBox(OwnerListview, Item, Column, RectArray, ACanvas) then
  begin
    inherited PaintCheckBox(Item, Column, RectArray, ACanvas);
  end;
end;

procedure TCEViewTileItem.PaintBefore(Item: TEasyItem; Column: TEasyColumn;
    const Caption: string; ACanvas: TCanvas; RectArray: TEasyRectArrayObject;
    var Handled: Boolean);
begin
  inherited PaintBefore(Item, Column, Caption, ACanvas, RectArray, Handled);
  PaintAttrBackground(Item, ACanvas, RectArray, true);
end;

{ TCEViewGroup }

{*------------------------------------------------------------------------------
  Caption of a group header band. The library takes the group font color from
  the system colors, which is unreadable on a dark theme. With a skin-file or
  Delphi-style theme the caption uses the theme's list item text color.
  A focused group keeps the library's highlight text color.
-------------------------------------------------------------------------------}
procedure TCEViewGroup.LoadTextFont(Group: TEasyGroup; ACanvas: TCanvas);
begin
  inherited LoadTextFont(Group, ACanvas);
  if Assigned(ACanvas) and ThemeNeedsOwnDrawing(OwnerListview) and
      not TCEGroupCracker(Group).Focused then
  begin
    ACanvas.Font.Color:= SkinManager.CurrentSkin.GetTextColor(OwnerListview,
        skncListItem, sknsNormal);
  end;
end;

{*------------------------------------------------------------------------------
  Check box of a group header band (shown when CheckBoxSelection is on).
-------------------------------------------------------------------------------}
procedure TCEViewGroup.PaintCheckBox(Group: TEasyGroup; ACanvas: TCanvas;
    RectArray: TEasyRectArrayObject);
var
  crack: TCEGroupCracker;
begin
  crack:= TCEGroupCracker(Group);
  if ThemeNeedsOwnDrawing(OwnerListview) and (crack.CheckType = ectBox) then
  begin
    DrawThemedCheckGlyph(OwnerListview, ACanvas, RectArray.CheckRect,
        crack.Enabled, crack.Checked, crack.CheckHovering, crack.CheckPending);
  end
  else
  begin
    inherited PaintCheckBox(Group, ACanvas, RectArray);
  end;
end;

{*------------------------------------------------------------------------------
  Swap the library's standard group view for the themed one.
-------------------------------------------------------------------------------}
procedure CE_ColorizeGroupView(var View: TEasyViewGroupClass);
begin
  if (View = nil) or (View = TEasyViewGroup) then
  begin
    View:= TCEViewGroup;
  end;
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
    elsIcon: begin
      if (View = nil) or (View = TEasyViewIconItem) then
      begin
        View:= TCEViewIconItem;
      end;
    end;
    elsThumbnail: begin
      if (View = nil) or (View = TEasyViewThumbnailItem) then
      begin
        View:= TCEViewThumbnailItem;
      end;
    end;
    elsTile: begin
      if (View = nil) or (View = TEasyViewTileItem) then
      begin
        View:= TCEViewTileItem;
      end;
    end;
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

initialization
  ExtBgColors:= TDictionary<string, TColor>.Create;

finalization
  FreeAndNil(ExtBgColors);

end.
