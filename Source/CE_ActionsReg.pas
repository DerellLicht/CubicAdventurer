unit CE_ActionsReg;

// CubicAdventurer: design-time registration of TCEToolbarAction.
//
// The old Register procedure lived in CE_TBActions.pas (runtime unit). It was
// removed from there because it must not be part of the runtime build. It now
// lives here, and this unit is only compiled into the design package
// CE_Design.dpk, never into CubicAdventurer.exe.

interface

procedure Register;

implementation

uses
  System.Actions, CE_TBActions;

{-------------------------------------------------------------------------------
  Register TCEToolbarAction so the IDE can load forms that use it
  (RegisterActions lives in System.Actions in current Delphi versions).
-------------------------------------------------------------------------------}
procedure Register;
begin
  RegisterActions('CubicExplorer', [TCEToolbarAction], nil);
end;

end.
