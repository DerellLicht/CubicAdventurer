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

// revival: the design-time Register procedure (RegisterActions) was removed from
// this runtime unit because it no longer compiles here. It belongs in a separate
// design-time package unit; see the revival checklist.
// procedure Register;
// begin
//   RegisterActions('CubicExplorer', [TCEToolbarAction], nil);
// end;

implementation

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
