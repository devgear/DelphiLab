program ChartGraph;

uses
  System.StartUpCopy,
  FMX.Forms,
  MUnit in 'MUnit.pas' {Form1},
  DBModule in 'DBModule.pas' {DModule: TDataModule},
  Fr3DView in 'Fr3DView.pas' {Fr3DGraph: TFrame};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.CreateForm(TDModule, DModule);
  Application.Run;
end.
