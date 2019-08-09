program AudioService;

uses
  System.StartUpCopy,
  FMX.Forms,
  FWinDisp in 'FWinDisp.pas' {SMForm},
  MMDevAPI in 'MMDevAPI.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TSMForm, SMForm);
  Application.Run;
end.
