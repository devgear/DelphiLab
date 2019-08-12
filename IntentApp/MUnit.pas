unit MUnit;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Controls.Presentation, FMX.ScrollBox, FMX.Memo,
  {$IFDEF ANDROID}
  Androidapi.JNI.GraphicsContentViewText, Androidapi.JNI.Net, FMX.Helpers.Android, Androidapi.Helpers,
  {$ENDIF}
  FMX.Objects, Web.HttpApp, System.Rtti, System.NetEncoding, FMX.StdCtrls;

type
  TForm1 = class(TForm)
    Rectangle1: TRectangle;
    Text1: TText;
    Memo1: TMemo;
    Rectangle2: TRectangle;
    Button1: TButton;
    procedure FormCreate(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  private
    function Get_URL_String(url: string) : TStringList;
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation


{$R *.fmx}

procedure TForm1.FormCreate(Sender: TObject);
{$IFDEF ANDROID}
var
  intent: JIntent;
  uri: Jnet_Uri;
  uriStr: String;
  rValue : TStringList;
  i : integer;
{$ENDIF}

begin
  {$IFDEF ANDROID}
  intent := SharedActivity.getIntent;
  if intent <> nil then
  begin
    if TJIntent.JavaClass.ACTION_VIEW.equals(intent.getAction) then
    begin
      uri := intent.getData;
      uriStr := JStringToString(uri.toString);  // read uriStr

      rValue := Get_URL_String( uriStr );  // parsing value

      for i := 0 to rValue.Count-1 do
         Memo1.Lines.Add( rValue[i] );
    end;
  end;
  {$ENDIF}
end;


// Html File  ---------------- ---------------------------------------------------------------------
// <a href="delphiapp://callType1?title=This is a Type1&data1=1111&data2=2222">call Type1</a><BR>
// <a href="delphiapp://callType2?title=This is a Type2&data1=1111&data2=2222&data3=3333">call Type2</a><BR>
function TForm1.Get_URL_String( url : string ) : TStringList;
var
  p, q : integer;
  rValue : TStringList;
  htitle : string;
begin
  url := UTF8Decode( HTTPDecode( url ) );     // for UTF8 (ÇÑ±Û)

  rValue := TStringList.Create;

  if pos( 'callType1', url ) > 0 then
  begin
    p := Pos( 'title=', url ) + length( 'title=' );
    q := Pos( '&data1', url );
    rValue.Add ( Copy( url, p, q-p ) );

    p := Pos( 'data1=', url ) + length( 'data1=' );
    q := Pos( '&data2', url );
    rValue.Add( Copy( url, p, q-p ) );

    p := Pos( 'data2=', url ) + length( 'data2=' );
    rValue.Add( Copy( url, p, length( url ) ));
  end

  else if pos( 'callType2', url ) > 0 then
  begin
    p := Pos( 'title=', url ) + length( 'title=' );
    q := Pos( '&data1', url );
    rValue.Add( Copy( url, p, q-p ) );

    p := Pos( 'data1=', url ) + length( 'data1=' );
    q := Pos( '&data2', url );
    rValue.Add( Copy( url, p, q-p ) );

    p := Pos( 'data2=', url ) + length( 'data2=' );
    q := Pos( '&data3', url );
    rValue.Add( Copy( url, p, q-p ) );

    p := Pos( 'data3=', url ) + length( 'data3=' );
    rValue.Add( Copy( url, p, length( url ) ));
  end

  else
    rvalue.Add('Type do not exist.');

  result := rValue;
end;


procedure TForm1.Button1Click(Sender: TObject);
begin
  Close;
end;


end.
