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
//  The Original Code is fCE_OptionsCustomPage.pas.                                                            
//                                                                                            
//  The Initial Developer of the Original Code is Marko Savolainen (cubicreality@gmail.com).  
//  Portions created by Marko Savolainen Copyright (C) Marko Savolainen. All Rights Reserved. 
//                                                                                            
//******************************************************************************

unit fCE_OptionsCustomPage;

interface

uses
  // CE Units

  // System Units
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, 
  Dialogs;

type
  TCEOptionsCustomPageClass = class of TCEOptionsCustomPage;
  TCEOptionsCustomPage = class(TFrame)
    procedure HandleChange(Sender: TObject);
  private
    fOptionsDialog: TForm;
    fPageListPosition: Integer;
  protected
    fImageIndex: Integer;
    fPageName: WideString;
    fPagePath: WideString;
    fPageTitle: WideString;
  public
    class procedure GetPageInfo(out AName, ATitle, APath: WideString;
        out AImageIndex, APosition: Integer); virtual;
    procedure ApplySettings; virtual;
    procedure HandleHide; virtual;
    procedure HandleShow; virtual;
    procedure LoadPageInfo;
    procedure RefreshSettings; virtual;
    procedure SetModified;
    property ImageIndex: Integer read fImageIndex write fImageIndex;
    property OptionsDialog: TForm read fOptionsDialog write fOptionsDialog;
    property PageName: WideString read fPageName write fPageName;
    property PagePath: WideString read fPagePath write fPagePath;
    property PageTitle: WideString read fPageTitle write fPageTitle;
  published
    property PageListPosition: Integer read fPageListPosition write
        fPageListPosition;
  end;

implementation

{$R *.dfm}

uses
  fCE_OptionsDialog;

{-------------------------------------------------------------------------------
  Apply Settings
-------------------------------------------------------------------------------}
procedure TCEOptionsCustomPage.ApplySettings;
begin
  // Override from descendant
end;

{-------------------------------------------------------------------------------
  Handle Change
-------------------------------------------------------------------------------}
procedure TCEOptionsCustomPage.HandleChange(Sender: TObject);
begin
  SetModified;
end;

{-------------------------------------------------------------------------------
  Handle Hide
-------------------------------------------------------------------------------}
procedure TCEOptionsCustomPage.HandleHide;
begin
  // Override from descendant
end;

{-------------------------------------------------------------------------------
  Handle Show
-------------------------------------------------------------------------------}
procedure TCEOptionsCustomPage.HandleShow;
begin
  // Override from descendant
end;

{-------------------------------------------------------------------------------
  Refresh Settings
-------------------------------------------------------------------------------}
procedure TCEOptionsCustomPage.RefreshSettings;
begin
  // Override from descendant
end;

{-------------------------------------------------------------------------------
  SetModified
-------------------------------------------------------------------------------}
procedure TCEOptionsCustomPage.SetModified;
begin
  if assigned(fOptionsDialog) then
  TCEOptionsDialog(fOptionsDialog).Modified:= true;
end;

{-------------------------------------------------------------------------------
  Get PageInfo: descendants override this to give the name, title, path, icon and
  sort position of the page. It is a class procedure so the Options dialog can read
  it without creating the page (pages are built when first selected).
-------------------------------------------------------------------------------}
class procedure TCEOptionsCustomPage.GetPageInfo(out AName, ATitle, APath: WideString;
    out AImageIndex, APosition: Integer);
begin
  AName:= '';
  ATitle:= '';
  APath:= '';
  AImageIndex:= -1;
  APosition:= 0;
end;

{-------------------------------------------------------------------------------
  Load PageInfo: copy the values from GetPageInfo into this page's properties.
  Descendant constructors call this instead of assigning each value by hand.
-------------------------------------------------------------------------------}
procedure TCEOptionsCustomPage.LoadPageInfo;
var
  wsName, wsTitle, wsPath: WideString;
  iImage, iPosition: Integer;
begin
  GetPageInfo(wsName, wsTitle, wsPath, iImage, iPosition);
  fPageName:= wsName;
  fPageTitle:= wsTitle;
  fPagePath:= wsPath;
  fImageIndex:= iImage;
  fPageListPosition:= iPosition;
end;

end.
