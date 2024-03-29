unit Unit1;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, System.Notification, FMX.ScrollBox, FMX.Memo,
  FMX.StdCtrls, FMX.Controls.Presentation;

type
  TForm1 = class(TForm)
    Label1: TLabel;
    Panel1: TPanel;
    Button1: TButton;
    Panel3: TPanel;
    Memo1: TMemo;
    Label2: TLabel;
    NotificationCenter1: TNotificationCenter;
    procedure Button1Click(Sender: TObject);
    procedure NotificationCenter1ReceiveLocalNotification(Sender: TObject; ANotification: TNotification);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.fmx}

uses
  System.Android.Service;

procedure TForm1.Button1Click(Sender: TObject);
begin
  TLocalServiceConnection.StartService('BeaconService');
end;

procedure TForm1.NotificationCenter1ReceiveLocalNotification(Sender: TObject; ANotification: TNotification);
begin
  Memo1.Lines.Add(ANotification.AlertBody);
end;

end.
