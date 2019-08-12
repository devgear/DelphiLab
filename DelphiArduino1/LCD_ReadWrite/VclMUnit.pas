unit VclMUnit;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, CPort, Vcl.Imaging.pngimage, Vcl.ExtCtrls;

type
  TForm1 = class(TForm)
    ComPort1: TComPort;
    OpenCLose_Bt: TButton;
    OneByteSend_bt: TButton;
    ComboBox1: TComboBox;
    Edit1: TEdit;
    SendText_bt: TButton;
    TempLabel: TLabel;
    Image1: TImage;
    StaticText1: TStaticText;
    Image2: TImage;
    procedure OpenCLose_BtClick(Sender: TObject);
    procedure ComPort1AfterOpen(Sender: TObject);
    procedure ComPort1AfterClose(Sender: TObject);
    procedure OneByteSend_btClick(Sender: TObject);
    procedure SendText_btClick(Sender: TObject);
    procedure ComPort1RxChar(Sender: TObject; Count: Integer);
  private
    { Private declarations }
  public
    { Public declarations }
    GStr : string;
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

//************************************************
procedure TForm1.OpenCLose_BtClick(Sender: TObject);
begin
  if ComPort1.Connected then
    ComPort1.Close
  else
    ComPort1.Open;
end;

//************************************************
procedure TForm1.ComPort1AfterOpen(Sender: TObject);
begin
  OpenCLose_Bt.Caption := 'Close';
end;

procedure TForm1.ComPort1AfterClose(Sender: TObject);
begin
  OpenCLose_Bt.Caption := 'Open';
end;


//************************************************
procedure TForm1.OneByteSend_btClick(Sender: TObject);
var
  iStr : string;
begin
  iStr := ComboBox1.Text;
  ComPort1.WriteStr( iStr );
end;

procedure TForm1.SendText_btClick(Sender: TObject);
begin
  ComPort1.WriteStr( Edit1.Text );
end;

//****************************************************************
// Message 종료 문자 : $13
procedure TForm1.ComPort1RxChar(Sender: TObject; Count: Integer);
var
  i : integer;
  rStr : string;
begin
  ComPort1.ReadStr( rStr, Count );     // Count: 날라온 문자수
  GStr := GStr + rStr;

  for i := 0 to length( GStr )-1 do
  begin
     if GStr[i] = #$13  then   // 종료 문자열 체크  '$13'
     begin
       TempLabel.Caption := Copy( GStr, 1, i-1 ) + ' C';  // (i-1)로 $13제외됨
       GStr := Copy( GStr, i+1,  length( GStr ) );        // 종료문자 다음부터 다시 시작.
     end;
  end;

end;


end.
