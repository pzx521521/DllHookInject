program TestExe;

uses
  Forms,
  ufrmTest in 'ufrmTest.pas' {frmTest};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmTest, frmTest);
  Application.Run;
end.
