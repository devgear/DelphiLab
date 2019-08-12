unit DBModule;

interface

uses
  System.SysUtils, System.Classes, FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param,
  FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt,
  FireDAC.UI.Intf, FireDAC.FMXUI.Wait, FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Phys, FireDAC.Phys.SQLite,
  FireDAC.Phys.SQLiteDef, FireDAC.Stan.ExprFuncs, Data.DB, FireDAC.Comp.Client, FireDAC.Comp.UI,
  FireDAC.Comp.DataSet, FMX.Dialogs,
  System.IOUtils;

type
  TDModule = class(TDataModule)
    FDQueryI: TFDQuery;
    FDGUIxWaitCursor1: TFDGUIxWaitCursor;
    FDCon: TFDConnection;
    procedure FDConBeforeConnect(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    function Select_Data(fieldName: String): TStringList;
  end;

var
  DModule: TDModule;

implementation

{%CLASSGROUP 'FMX.Controls.TControl'}

{$R *.dfm}

procedure TDModule.FDConBeforeConnect(Sender: TObject);
begin
  {$IF DEFINED(iOS) or DEFINED(ANDROID)}
  FDCon.Params.Values[ 'Database' ] := System.IOUtils.TPath.Combine( System.IOUtils.TPath.GetDocumentsPath(), 'SampleData.db');  // .\assets\internal
  {$ENDIF}

  {$IFDEF MSWINDOWS}
  FDCon.Params.Values[ 'Database' ] :=  '..\..\SampleData.db';
  {$ENDIF}
end;


function TDModule.Select_Data( fieldName : String ) : TStringList;
var
  sItem : TStringList;
  value : string;
begin
  sItem := TStringList.Create;

  FDCon.Open;
  try
    FDQueryI.Close;
    FDQueryI.SQL.Clear;
    FDQueryI.SQL.Add( 'Select * from table1' );
    FDQueryI.Open;
    FDQueryI.First;

    while Not FDQueryI.EOF do
    begin
      value := FDQueryI.FieldByName( fieldname ).AsString;
      if value <> '' then
         sItem.Add( value );
      FDQueryI.Next;
    end;

  except
    on e: Exception do begin
      ShowMessage( e.Message );
    end;
  end;
  FDCon.Close;

  result := sItem;
end;


end.
