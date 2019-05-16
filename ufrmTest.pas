unit ufrmTest;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls;

type
  TfrmTest = class(TForm)
    btnShowmessage: TButton;
    btnMessageDlg: TButton;
    Button1: TButton;
    Button2: TButton;
    procedure btnMessageDlgClick(Sender: TObject);
    procedure btnShowmessageClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmTest: TfrmTest;

implementation

{$R *.dfm}

procedure TfrmTest.btnMessageDlgClick(Sender: TObject);
begin
  MessageDlg('MessageDlgClick', mtWarning, [mbOK], 0);
end;

procedure TfrmTest.btnShowmessageClick(Sender: TObject);
begin
  ShowMessage('ShowmessageClick');

end;

procedure TfrmTest.Button1Click(Sender: TObject);
begin
  MessageBoxW(Self.Handle, PChar('Text'),  PChar('Caption'), MB_OKCANCEL)
end;

procedure TfrmTest.Button2Click(Sender: TObject);
var
   aGetTime: TDateTime;
begin
  aGetTime := Now;
  ShowMessage(DateTimeToStr(aGetTime))
end;

end.
