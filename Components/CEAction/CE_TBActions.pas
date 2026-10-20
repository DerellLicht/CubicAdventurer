unit CE_TBActions;

interface

uses
  // TB2k, TBX, SpTBX
  TB2Item, SpTBXItem,
  // System Units
  ActnList, Classes;

type

  // revival: was TTntAction; plain TAction is Unicode-aware in current Delphi
  TCEToolbarAction = class(TAction)
  private
    fCanExecute: Boolean;
  public
    ItemClass: TTBCustomItemClass;
    constructor Create(AOwner: TComponent); override;
  published
    property CanExecute: Boolean read fCanExecute write fCanExecute default true;
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterActions('CubicExplorer', [TCEToolbarAction], nil);
end;

{##############################################################################}

{-------------------------------------------------------------------------------
  Create an instance of TCEToolbarAction
-------------------------------------------------------------------------------}
constructor TCEToolbarAction.Create(AOwner: TComponent);
begin
  inherited;
  fCanExecute:= true;
end;

end.
