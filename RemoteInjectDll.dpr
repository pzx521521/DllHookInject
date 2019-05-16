program RemoteInjectDll;

uses
  Forms,
  ufrmHookMsg in 'ufrmHookMsg.pas' {frmHookMsg},
  unitHook in 'unitHook.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmHookMsg, frmHookMsg);
  Application.Run;
end.
