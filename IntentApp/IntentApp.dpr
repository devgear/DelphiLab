program IntentApp;

uses
  System.StartUpCopy,
  FMX.Forms,
  MUnit in 'MUnit.pas' {Form1};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
