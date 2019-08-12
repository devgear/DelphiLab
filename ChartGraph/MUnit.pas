unit MUnit;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, System.Math,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.StdCtrls, FMX.Objects,
  FMX.Controls.Presentation, FMX.Layouts, FMX.TabControl, FMX.Edit, Fr3DView;

type
  TForm1 = class(TForm)
    TabControl1: TTabControl;
    TabItem1: TTabItem;
    TabItem2: TTabItem;
    Layout_Top: TLayout;
    RectBaseFill: TRectangle;
    LineY: TLine;
    YMaxText: TText;
    Text3: TText;
    LineX: TLine;
    Rectangle_Top: TRectangle;
    Text1: TText;
    SBT_Info: TSpeedButton;
    BT_DrawGraph1: TButton;
    BT_DrawGraph2: TButton;
    BT_Clear: TSpeedButton;
    EditMax: TEdit;
    Label1: TLabel;
    CallFr3DGraph: TFr3DGraph;
    procedure BT_DrawGraph1Click(Sender: TObject);
    procedure BT_DrawGraph2Click(Sender: TObject);
    procedure BT_ClearClick(Sender: TObject);
  private
    GBLayout1, GBLayout2 : TLayout;
    procedure Draw_Line(pBase: TControl; gColor: Cardinal; x1, y1, x2, y2: single);
    procedure Graph_DrawKind( baseLayout:TLayout; sData:TStringList; gColor:cardinal );
    procedure Point_Circle(pBase: TLayout; gColor: Cardinal; x, y, value: single);
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

uses
 DBModule;

{$R *.fmx}


procedure TForm1.BT_DrawGraph1Click(Sender: TObject);
var
  sListData : TStringList;
begin
  if Assigned( GBLayout1 ) then
  begin
    GBLayout1.Release;
    GBLayout1 := nil;
  end;

  GBLayout1 := TLayout.Create( RectBaseFill );
  GBLayout1.Parent := RectBaseFill;
  GBLayout1.Align := TAlignLayout.Client;    // Client Layout으로 그래프공간이 자동 지정됨.

  sListData := DModule.Select_Data( 'Data1' );
  Graph_DrawKind( GBLayout1, sListData, $FFd01615 );

  // 3D ---------------------------------
  CallFr3DGraph.Draw1_3D( EditMax.Text );
end;

procedure TForm1.BT_DrawGraph2Click(Sender: TObject);
var
  sListData : TStringList;
begin
  if Assigned( GBLayout2 ) then
  begin
    GBLayout2.Release;
    GBLayout2 := nil;
  end;

  GBLayout2 := TLayout.Create( RectBaseFill );
  GBLayout2.Parent := RectBaseFill;
  GBLayout2.Align := TAlignLayout.Client;    // Client Layout으로 그래프공간이 자동 지정됨.

  sListData := DModule.Select_Data( 'Data2' );
  Graph_DrawKind( GBLayout2, sListData, $FF283593 );

  // 3D ----------------------------------
  CallFr3DGraph.Draw2_3D( EditMax.Text );
end;


procedure TForm1.BT_ClearClick(Sender: TObject);
begin
  if Assigned( GBLayout1 ) then
  begin
    GBLayout1.Release;
    GBLayout1 := nil;
  end;

  if Assigned( GBLayout2 ) then
  begin
    GBLayout2.Release;
    GBLayout2 := nil;
  end;

  // 3D -----------------------
  CallFr3DGraph.DeleteAll_3D();
end;


//-------------------------------------------------------------------------------------------
procedure TForm1.Graph_DrawKind( baseLayout:TLayout; sData:TStringList; gColor:cardinal);
var
  i : Integer;
  x, y, yMax, p1x,p1y, p2x,p2y : single;
  yArr : array of single;

begin
  SetLength( yArr, sData.Count );

  for i := 0 to sData.Count-1 do
      yArr[i] := sData[i].ToSingle;

  if EditMax.Text = '' then             // Max값 미입력시 데이터 중 최대값으로 자동지정
     yMax :=  MaxValue( yArr )
  else
     yMax := EditMax.Text.ToSingle;

  YMaxText.Text := Format( 'Max %.1f',  [yMax] );

  for i := 1 to sData.Count do
  begin
    x := baseLayout.Width * i / sData.Count;

    if yMax = 0 then  y := 0
    else              y := baseLayout.Height * yArr[i-1] / yMax;

    if i > 1 then // 1이 시작점이므로 2부터 선그림
    begin
      p2x := x;
      p2y := baseLayout.Height - y;   // 수학좌표 -> 화면좌표
      Draw_Line( baseLayout, gColor, p1x,p1y, p2x,p2y );
    end;

    Point_Circle( baseLayout, gColor, x,y, yArr[i-1] );
    p1x := x;
    p1y := baseLayout.Height - y;     // 수학좌표 -> 화면좌표
  end;
end;

// Y좌표 : 수학 좌표
procedure TForm1.Point_Circle( pBase:TLayout; gColor:Cardinal; x,y, value: single );
var
  cp : TCircle;
  vText : TText;
begin
  cp := TCIrcle.Create( pBase );
  cp.Parent := pBase;
  cp.Width  := 10;
  cp.Height := 10;
  cp.Position.X := x - cp.Width/2;
  cp.Position.Y := pBase.Height - y - cp.Height/2;
  cp.Fill.Color := gColor;
  cp.Stroke.Kind := TBrushKind.None;

  vText := TText.Create( cp );
  vText.Parent := cp;
  vText.Color := gColor;
  vText.AutoSize := TRUE;
  vText.Position.X := -5;
  vText.Position.Y := -20;
  vText.HorzTextAlign := TTextAlign.Center;
  vText.Text := Round( value ).ToString;
end;

// Y 좌표 : 화면좌표
procedure TForm1.Draw_Line( pBase:TControl; gColor:Cardinal; x1,y1, x2,y2 : single );
var
  LinePath : TPath;
  p1, p2 : TPointF;
begin
  LinePath := TPath.Create(pBase);
  LinePath.Parent := pBase;

  if ( x1 < x2 ) and ( y1 < y2 ) then
  begin
    p1.X := 0;     p1.Y := 0;        //  \   방향만 지정
    p2.X := 100;   p2.Y := 100;

    LinePath.Position.X := x1;
    LinePath.Position.Y := y1;
    LinePath.Width  := x2 - x1;
    LinePath.Height := y2 - y1;
  end
  else if y1 = y2 then
  begin
    p1.X := 0;    p1.Y := 0;        //  -
    p2.X := 100;  p2.Y := 0;

    LinePath.Position.X := x1;
    LinePath.Position.Y := y1;
    LinePath.Width  := x2 - x1;
    LinePath.Height := 100;  // 아무값
  end
  else if x1 = x2 then
  begin
    p1.X := 0;   p1.Y := 0;        //  |
    p2.X := 0;   p2.Y := 100;

    LinePath.Position.X := x1;
    LinePath.Position.Y := y1;
    LinePath.Width  := 100;  // 아무값
    LinePath.Height := y2- y1
  end
  else if ( x1 < x2 ) and ( y1 > y2 ) then
  begin
    p1.X := 100;  p1.Y := 0;        //  /
    p2.X := 0;    p2.Y := 100;

    LinePath.Width  := x2 - x1;
    LinePath.Height := y1 - y2;
    LinePath.Position.X := x1;
    LinePath.Position.Y := y1 - LinePath.Height;
  end;

  LinePath.Stroke.Thickness := 2;
  LinePath.Stroke.Color := gColor;
  LinePath.Data.MoveTo( p1 );
  LinePath.Data.LineTo( p2 );
end;


end.
