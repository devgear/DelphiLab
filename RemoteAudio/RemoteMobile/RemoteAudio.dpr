program RemoteAudio;

uses
  System.StartUpCopy,
  FMX.Forms,
  RemoteMain in 'RemoteMain.pas' {MForm};

{$R *.res}

begin
  Application.Initialize;
  Application.FormFactor.Orientations := [TFormOrientation.Portrait];
  Application.CreateForm(TMForm, MForm);
  Application.Run;
end.
