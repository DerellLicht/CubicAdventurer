{*------------------------------------------------------------------------------
  CE_SkinPreview - makes the preview picture of a skin (theme).

  A small sample window (title bar, menu bar, toolbar, tabs, buttons, editors,
  list, trackbar, progress bar, status bar) is shown with a skin applied and the
  client area of that window is saved as a PNG next to the skin file.

  Used by CubicAdventurer (Options > Display makes the pictures that are still
  missing, see CreateSkinPreviews) and by tools\SkinPreview (batch generator).

  The picture is taken from the screen, so the sample window must be visible and
  must not be covered while it is photographed. Pictures made on a display with
  100% scaling have the usual size (340 x 372).

  This unit must not use any other CubicAdventurer unit, because the SkinPreview
  tool compiles it on its own.
-------------------------------------------------------------------------------}
unit CE_SkinPreview;

interface

uses
  Windows, SysUtils, Classes, Graphics, Controls, Forms, StdCtrls, ExtCtrls,
  ComCtrls, pngimage,
  TB2Dock, TB2Item, TB2Toolbar,
  SpTBXSkins, SpTBXItem, SpTBXControls, SpTBXEditors, SpTBXTabs;

type
  // The window that is photographed. All controls are made in code (no .dfm).
  TCESkinSampleForm = class(TForm)
  private
    fTitleBar: TSpTBXTitleBar;
    procedure BuildToolbars;
    procedure BuildTabsAndPanel;
    procedure BuildStatusBar;
    procedure AddButtonRow(AParent: TWinControl; ATop: Integer;
        const ACaption: string; AChecked, AEnabled: Boolean);
  public
    constructor CreateNew(AOwner: TComponent; Dummy: Integer = 0); override;
  end;

{*------------------------------------------------------------------------------
  Apply skin ASkinName to the (visible) sample window, wait until it has been
  repainted, and save a picture of it as APngFile. Returns false if the picture
  could not be saved. The skin stays applied; the caller restores the old skin.
-------------------------------------------------------------------------------}
function MakeSkinPicture(ASample: TForm; const ASkinName, APngFile: string): Boolean;

{*------------------------------------------------------------------------------
  Show the explanation window and make a picture for each skin: ANames[i] is the
  skin name and AFiles[i] the .png file to write. The skin that was current is
  restored afterwards. Returns the number of pictures that were made.
-------------------------------------------------------------------------------}
function CreateSkinPreviews(ANames, AFiles: TStrings): Integer;

implementation

const
  // BitBlt flag to include layered windows; not declared in Delphi's Windows unit
  CAPTUREBLT = $40000000;

type
  // The window that tells the user what is going on. It is modal; a timer makes
  // one picture per tick so the window stays alive and the Cancel button works.
  TCESkinPreviewNotice = class(TForm)
  private
    fNames: TStrings;
    fFiles: TStrings;
    fSample: TCESkinSampleForm;
    fTimer: TTimer;
    fInfo: TLabel;
    fStatus: TLabel;
    fProgress: TProgressBar;
    fButton: TButton;
    fSavedSkin: string;
    fIndex: Integer;
    fMade: Integer;
    fFailed: Integer;
    fCancelled: Boolean;
    fDone: Boolean;
    procedure PositionWindows;
    procedure LayoutControls;
    function WrappedTextHeight(const AText: string; AWidth: Integer): Integer;
    procedure ShowStatus;
    procedure Finish;
    procedure ButtonClick(Sender: TObject);
    procedure TimerTick(Sender: TObject);
    procedure NoticeShow(Sender: TObject);
    procedure NoticeCloseQuery(Sender: TObject; var CanClose: Boolean);
  public
    constructor CreateNotice(ANames, AFiles: TStrings);
    procedure RestoreSkin;
    property Made: Integer read fMade;
  end;

{*------------------------------------------------------------------------------
  Create the sample window.
-------------------------------------------------------------------------------}
constructor TCESkinSampleForm.CreateNew(AOwner: TComponent; Dummy: Integer);
begin
  inherited CreateNew(AOwner, Dummy);
  Caption:= 'Skin Preview';
  Position:= poScreenCenter;
  ClientWidth:= 340;
  ClientHeight:= 372;
  fTitleBar:= TSpTBXTitleBar.Create(Self);
  fTitleBar.Parent:= Self;
  fTitleBar.Align:= alClient;
  fTitleBar.Caption:= Caption;
  BuildToolbars;
  BuildStatusBar;
  BuildTabsAndPanel;
end;

{*------------------------------------------------------------------------------
  Menu bar (one submenu item) and a toolbar (one normal and one disabled item).
-------------------------------------------------------------------------------}
procedure TCESkinSampleForm.BuildToolbars;
var
  dock: TSpTBXDock;
  menuBar, toolBar: TSpTBXToolbar;
  sub: TSpTBXSubmenuItem;
  item: TSpTBXItem;
begin
  dock:= TSpTBXDock.Create(Self);
  dock.Parent:= fTitleBar;
  dock.Position:= dpTop;

  menuBar:= TSpTBXToolbar.Create(Self);
  menuBar.CurrentDock:= dock;
  menuBar.MenuBar:= true;
  menuBar.FullSize:= true;
  sub:= TSpTBXSubmenuItem.Create(Self);
  sub.Caption:= 'MenuBar Item';
  menuBar.Items.Add(sub);
  item:= TSpTBXItem.Create(Self);
  item.Caption:= 'Item';
  sub.Add(item);
  item:= TSpTBXItem.Create(Self);
  item.Caption:= 'Checked Item';
  item.Checked:= true;
  sub.Add(item);
  item:= TSpTBXItem.Create(Self);
  item.Caption:= 'Radio Item';
  item.GroupIndex:= 1;
  item.Checked:= true;
  sub.Add(item);

  toolBar:= TSpTBXToolbar.Create(Self);
  toolBar.CurrentDock:= dock;
  toolBar.DockRow:= 1;
  item:= TSpTBXItem.Create(Self);
  item.Caption:= 'Toolbar Item';
  toolBar.Items.Add(item);
  item:= TSpTBXItem.Create(Self);
  item.Caption:= 'Disabled Item';
  item.Enabled:= false;
  toolBar.Items.Add(item);
end;

{*------------------------------------------------------------------------------
  Status bar with one normal and one disabled panel.
-------------------------------------------------------------------------------}
procedure TCESkinSampleForm.BuildStatusBar;
var
  status: TSpTBXStatusBar;
  lbl: TSpTBXLabelItem;
begin
  status:= TSpTBXStatusBar.Create(Self);
  status.Parent:= fTitleBar;
  status.Align:= alBottom;
  lbl:= TSpTBXLabelItem.Create(Self);
  lbl.Caption:= 'Status Panel';
  status.Items.Add(lbl);
  status.Items.Add(TSpTBXSeparatorItem.Create(Self));
  lbl:= TSpTBXLabelItem.Create(Self);
  lbl.Caption:= 'Disabled Status Panel';
  lbl.Enabled:= false;
  status.Items.Add(lbl);
end;

{*------------------------------------------------------------------------------
  One row of the Buttons group: a button, a check box and a radio button.
-------------------------------------------------------------------------------}
procedure TCESkinSampleForm.AddButtonRow(AParent: TWinControl; ATop: Integer;
    const ACaption: string; AChecked, AEnabled: Boolean);
var
  btn: TSpTBXButton;
  chk: TSpTBXCheckBox;
  rad: TSpTBXRadioButton;
begin
  btn:= TSpTBXButton.Create(Self);
  btn.Parent:= AParent;
  btn.SetBounds(10, ATop, 80, 24);
  btn.Caption:= ACaption;
  btn.Enabled:= AEnabled;

  chk:= TSpTBXCheckBox.Create(Self);
  chk.Parent:= AParent;
  chk.SetBounds(110, ATop + 3, 90, 18);
  chk.Caption:= ACaption;
  chk.Checked:= AChecked;
  chk.Enabled:= AEnabled;

  rad:= TSpTBXRadioButton.Create(Self);
  rad.Parent:= AParent;
  rad.SetBounds(215, ATop + 3, 90, 18);
  rad.Caption:= ACaption;
  rad.Checked:= AChecked;
  rad.Enabled:= AEnabled;
end;

{*------------------------------------------------------------------------------
  Tab strip, and below it a panel holding the Buttons, Editors and Misc groups.
-------------------------------------------------------------------------------}
procedure TCESkinSampleForm.BuildTabsAndPanel;
var
  tabs: TSpTBXTabSet;
  panel: TSpTBXPanel;
  buttons, editors, misc: TSpTBXGroupBox;
  edit: TSpTBXEdit;
  combo: TSpTBXComboBox;
  list: TSpTBXListBox;
  track: TSpTBXTrackBar;
  progress: TSpTBXProgressBar;
begin
  tabs:= TSpTBXTabSet.Create(Self);
  tabs.Parent:= fTitleBar;
  // aligned, so the tabs always sit below the toolbars whatever their height is
  tabs.Align:= alTop;
  tabs.Height:= 24;
  tabs.Add('Controls');
  tabs.Add('Panels');
  tabs.ActiveTabIndex:= 0;

  panel:= TSpTBXPanel.Create(Self);
  panel.Parent:= fTitleBar;
  panel.Align:= alClient;

  buttons:= TSpTBXGroupBox.Create(Self);
  buttons.Parent:= panel;
  buttons.Caption:= 'Buttons';
  buttons.SetBounds(6, 4, 312, 104);
  AddButtonRow(buttons, 18, 'Normal', false, true);
  AddButtonRow(buttons, 46, 'Checked', true, true);
  AddButtonRow(buttons, 74, 'Disabled', false, false);

  editors:= TSpTBXGroupBox.Create(Self);
  editors.Parent:= panel;
  editors.Caption:= 'Editors';
  editors.SetBounds(6, 112, 150, 126);
  edit:= TSpTBXEdit.Create(Self);
  edit.Parent:= editors;
  edit.SetBounds(8, 20, 132, 21);
  edit.Text:= 'Edit';
  combo:= TSpTBXComboBox.Create(Self);
  combo.Parent:= editors;
  combo.SetBounds(8, 48, 132, 21);
  combo.Items.Add('ComboBox');
  combo.ItemIndex:= 0;
  list:= TSpTBXListBox.Create(Self);
  list.Parent:= editors;
  list.SetBounds(8, 76, 132, 42);
  list.Items.Add('List Item 1');
  list.Items.Add('List Item 2');
  list.ItemIndex:= 0;

  misc:= TSpTBXGroupBox.Create(Self);
  misc.Parent:= panel;
  misc.Caption:= 'Misc controls';
  misc.SetBounds(162, 112, 156, 126);
  track:= TSpTBXTrackBar.Create(Self);
  track.Parent:= misc;
  track.SetBounds(8, 24, 140, 30);
  track.Max:= 10;
  track.Position:= 4;
  progress:= TSpTBXProgressBar.Create(Self);
  progress.Parent:= misc;
  progress.SetBounds(8, 70, 140, 20);
  progress.Position:= 30;
end;

{*------------------------------------------------------------------------------
  Copy the client area of AForm from the screen into ABitmap. The skinned title
  bar fills the whole client area, so this is the skinned window without the frame
  Windows (or a desktop theme program such as WindowBlinds) draws around it.
-------------------------------------------------------------------------------}
function CaptureClient(AForm: TForm; ABitmap: TBitmap): Boolean;
var
  topLeft: TPoint;
  screenDC: HDC;
begin
  topLeft:= AForm.ClientToScreen(Point(0, 0));
  ABitmap.PixelFormat:= pf24bit;
  ABitmap.SetSize(AForm.ClientWidth, AForm.ClientHeight);
  screenDC:= GetDC(0);
  try
    Result:= BitBlt(ABitmap.Canvas.Handle, 0, 0, ABitmap.Width, ABitmap.Height,
        screenDC, topLeft.X, topLeft.Y, SRCCOPY or CAPTUREBLT);
  finally
    ReleaseDC(0, screenDC);
  end;
end;

{*------------------------------------------------------------------------------
  Let the window repaint with the new skin and wait until it has settled.
-------------------------------------------------------------------------------}
procedure SettleWindow(AForm: TForm);
var
  i: Integer;
begin
  for i:= 1 to 3 do
  begin
    RedrawWindow(AForm.Handle, nil, 0,
        RDW_INVALIDATE or RDW_ALLCHILDREN or RDW_FRAME or RDW_UPDATENOW);
    Application.ProcessMessages;
    Sleep(150);
  end;
end;

{*------------------------------------------------------------------------------
  Apply the skin, photograph the sample window and save the picture. The picture
  is written to a temporary file first, so a failed save never leaves a broken
  .png behind that would be taken for a real preview.
-------------------------------------------------------------------------------}
function MakeSkinPicture(ASample: TForm; const ASkinName, APngFile: string): Boolean;
var
  bmp: TBitmap;
  png: TPngImage;
  tmpFile: string;
begin
  Result:= false;
  tmpFile:= APngFile + '.tmp';
  SkinManager.SetSkin(ASkinName);
  SettleWindow(ASample);
  bmp:= TBitmap.Create;
  png:= TPngImage.Create;
  try
    try
      if CaptureClient(ASample, bmp) then
      begin
        png.Assign(bmp);
        png.SaveToFile(tmpFile);
        Result:= MoveFileEx(PChar(tmpFile), PChar(APngFile), MOVEFILE_REPLACE_EXISTING);
      end;
    except
      Result:= false;
    end;
  finally
    if not Result then
    begin
      SysUtils.DeleteFile(tmpFile);
    end;
    png.Free;
    bmp.Free;
  end;
end;

{*------------------------------------------------------------------------------
  Create the explanation window (not shown yet) and the sample window it owns.
-------------------------------------------------------------------------------}
constructor TCESkinPreviewNotice.CreateNotice(ANames, AFiles: TStrings);
begin
  inherited CreateNew(Application);
  fNames:= ANames;
  fFiles:= AFiles;
  fSavedSkin:= SkinManager.CurrentSkinName;
  Caption:= 'Creating theme preview pictures';
  BorderStyle:= bsDialog;
  Position:= poDesigned;
  ClientWidth:= 440;
  ClientHeight:= 190;
  Font.Assign(Screen.MessageFont);
  OnShow:= NoticeShow;
  OnCloseQuery:= NoticeCloseQuery;

  fInfo:= TLabel.Create(Self);
  fInfo.Parent:= Self;
  fInfo.AutoSize:= false;
  fInfo.WordWrap:= true;
  fInfo.ShowAccelChar:= false;
  fInfo.Caption:= 'Some themes do not have a preview picture yet. CubicAdventurer ' +
      'is making one for each of them, so Options > Display can show it. The ' +
      'window next to this one is only a sample that is photographed, and the ' +
      'program will look different for a moment while each theme is applied. ' +
      'This is done once for each new theme.';

  fStatus:= TLabel.Create(Self);
  fStatus.Parent:= Self;
  fStatus.AutoSize:= false;
  fStatus.WordWrap:= true;
  fStatus.ShowAccelChar:= false;
  // one line is reserved until the first real status text
  fStatus.Caption:= ' ';

  fProgress:= TProgressBar.Create(Self);
  fProgress.Parent:= Self;
  fProgress.Max:= fNames.Count;

  fButton:= TButton.Create(Self);
  fButton.Parent:= Self;
  fButton.Caption:= 'Cancel';
  fButton.OnClick:= ButtonClick;

  fTimer:= TTimer.Create(Self);
  fTimer.Enabled:= false;
  fTimer.Interval:= 300;
  fTimer.OnTimer:= TimerTick;

  fSample:= TCESkinSampleForm.CreateNew(Self);
  // owned by this window (no taskbar button) and above everything, so nothing
  // can cover it while it is photographed
  fSample.PopupMode:= pmExplicit;
  fSample.PopupParent:= Self;
  fSample.FormStyle:= fsStayOnTop;
  fSample.Position:= poDesigned;
  LayoutControls;
  PositionWindows;
end;

{*------------------------------------------------------------------------------
  Height in pixels that AText needs when it is word wrapped to AWidth pixels, in
  the window's font (which comes from the Windows message font, so it can be large).
-------------------------------------------------------------------------------}
function TCESkinPreviewNotice.WrappedTextHeight(const AText: string;
    AWidth: Integer): Integer;
var
  r: TRect;
begin
  Canvas.Font.Assign(Font);
  r:= Rect(0, 0, AWidth, 0);
  DrawText(Canvas.Handle, PChar(AText), Length(AText), r,
      DT_CALCRECT or DT_WORDBREAK or DT_NOPREFIX);
  Result:= r.Bottom - r.Top;
  if Result < Canvas.TextHeight('Wg') then
  begin
    Result:= Canvas.TextHeight('Wg');
  end;
end;

{*------------------------------------------------------------------------------
  Place the controls one below the other, sized from the text they hold, and make
  the window as high as needed. Called again when the status text changes, since
  it can wrap to more lines (a long theme name, or the final report).
-------------------------------------------------------------------------------}
procedure TCESkinPreviewNotice.LayoutControls;
const
  MARGIN = 16;
  SPACE = 10;
var
  y, h, w, bw, bh: Integer;
begin
  Canvas.Font.Assign(Font);
  w:= ClientWidth - 2 * MARGIN;
  y:= MARGIN;
  h:= WrappedTextHeight(fInfo.Caption, w);
  fInfo.SetBounds(MARGIN, y, w, h);
  Inc(y, h + SPACE);
  h:= WrappedTextHeight(fStatus.Caption, w);
  fStatus.SetBounds(MARGIN, y, w, h);
  Inc(y, h + SPACE);
  fProgress.SetBounds(MARGIN, y, w, 16);
  Inc(y, 16 + SPACE + SPACE);
  // button wide and high enough for either caption in this font
  bw:= Canvas.TextWidth('Cancel');
  if Canvas.TextWidth('Okay') > bw then
  begin
    bw:= Canvas.TextWidth('Okay');
  end;
  bw:= bw + 32;
  if bw < 80 then
  begin
    bw:= 80;
  end;
  bh:= Canvas.TextHeight('Wg') + 12;
  if bh < 26 then
  begin
    bh:= 26;
  end;
  fButton.SetBounds(ClientWidth - MARGIN - bw, y, bw, bh);
  ClientHeight:= y + bh + MARGIN;
end;

{*------------------------------------------------------------------------------
  Put the sample window and this window side by side, centered on the work area
  of the monitor the mouse is on.
-------------------------------------------------------------------------------}
procedure TCESkinPreviewNotice.PositionWindows;
const
  GAP = 16;
var
  work: TRect;
  x, y: Integer;
begin
  work:= Screen.MonitorFromPoint(Mouse.CursorPos).WorkareaRect;
  x:= work.Left + (work.Right - work.Left - (fSample.Width + GAP + Width)) div 2;
  if x < work.Left then
  begin
    x:= work.Left;
  end;
  y:= work.Top + (work.Bottom - work.Top - fSample.Height) div 2;
  if y < work.Top then
  begin
    y:= work.Top;
  end;
  fSample.Left:= x;
  fSample.Top:= y;
  Left:= x + fSample.Width + GAP;
  Top:= y;
end;

{*------------------------------------------------------------------------------
  Window is shown: show the sample next to it, move the mouse pointer onto the
  button (so it is not over the sample, where it would change the look of the
  controls in the picture) and start the timer.
-------------------------------------------------------------------------------}
procedure TCESkinPreviewNotice.NoticeShow(Sender: TObject);
var
  pt: TPoint;
begin
  fSample.Show;
  pt:= fButton.ClientToScreen(Point(fButton.Width div 2, fButton.Height div 2));
  SetCursorPos(pt.X, pt.Y);
  ShowStatus;
  fTimer.Enabled:= true;
end;

{*------------------------------------------------------------------------------
  Show which picture is being made.
-------------------------------------------------------------------------------}
procedure TCESkinPreviewNotice.ShowStatus;
begin
  if fIndex < fNames.Count then
  begin
    fStatus.Caption:= Format('Creating picture %d of %d: %s',
        [fIndex + 1, fNames.Count, fNames[fIndex]]);
    LayoutControls;
  end;
end;

{*------------------------------------------------------------------------------
  Timer: make one picture, then come back. When all are made (or Cancel was
  pressed) finish up. Errors in one picture only count as a failure.
-------------------------------------------------------------------------------}
procedure TCESkinPreviewNotice.TimerTick(Sender: TObject);
begin
  fTimer.Enabled:= false;
  if fCancelled or (fIndex >= fNames.Count) then
  begin
    Finish;
    Exit;
  end;
  ShowStatus;
  Application.ProcessMessages;
  try
    if MakeSkinPicture(fSample, fNames[fIndex], fFiles[fIndex]) then
    begin
      Inc(fMade);
    end
    else begin
      Inc(fFailed);
    end;
  except
    Inc(fFailed);
  end;
  Inc(fIndex);
  fProgress.Position:= fIndex;
  fTimer.Enabled:= true;
end;

{*------------------------------------------------------------------------------
  Put the program's own skin back.
-------------------------------------------------------------------------------}
procedure TCESkinPreviewNotice.RestoreSkin;
begin
  if (fSavedSkin <> '') and (SkinManager.CurrentSkinName <> fSavedSkin) then
  begin
    SkinManager.SetSkin(fSavedSkin);
  end;
end;

{*------------------------------------------------------------------------------
  All done or cancelled: remove the sample, restore the skin, report, and turn
  the Cancel button into Okay.
-------------------------------------------------------------------------------}
procedure TCESkinPreviewNotice.Finish;
var
  text: string;
begin
  fDone:= true;
  fSample.Free;
  fSample:= nil;
  RestoreSkin;
  if fCancelled then
  begin
    text:= Format('Stopped. %d picture(s) made.', [fMade]);
  end
  else begin
    text:= Format('Done. %d picture(s) made.', [fMade]);
  end;
  if fFailed > 0 then
  begin
    text:= text + Format(' %d could not be saved (is the Skins folder write protected?)',
        [fFailed]);
  end;
  fStatus.Caption:= text;
  LayoutControls;
  fProgress.Position:= fProgress.Max;
  fButton.Caption:= 'Okay';
  fButton.Enabled:= true;
  fButton.SetFocus;
end;

{*------------------------------------------------------------------------------
  Button: Cancel while the pictures are being made (the one in progress is
  finished first), Okay when done.
-------------------------------------------------------------------------------}
procedure TCESkinPreviewNotice.ButtonClick(Sender: TObject);
begin
  if fDone then
  begin
    ModalResult:= mrOk;
  end
  else begin
    fCancelled:= true;
    fButton.Enabled:= false;
  end;
end;

{*------------------------------------------------------------------------------
  The window can only be closed when it is done; closing it earlier means Cancel.
-------------------------------------------------------------------------------}
procedure TCESkinPreviewNotice.NoticeCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  CanClose:= fDone;
  if not fDone then
  begin
    fCancelled:= true;
    fButton.Enabled:= false;
  end;
end;

{*------------------------------------------------------------------------------
  See the interface section.
-------------------------------------------------------------------------------}
function CreateSkinPreviews(ANames, AFiles: TStrings): Integer;
var
  notice: TCESkinPreviewNotice;
begin
  Result:= 0;
  if (ANames = nil) or (AFiles = nil) or (ANames.Count = 0) or
      (ANames.Count <> AFiles.Count) then
  begin
    Exit;
  end;
  notice:= TCESkinPreviewNotice.CreateNotice(ANames, AFiles);
  try
    notice.ShowModal;
    Result:= notice.Made;
  finally
    notice.RestoreSkin;
    notice.Free;
  end;
end;

end.
