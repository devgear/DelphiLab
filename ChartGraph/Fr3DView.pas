unit Fr3DView;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, System.Math,
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls, System.Math.Vectors,
  FMX.Objects3D, FMX.Controls3D, FMX.Viewport3D, FMX.MaterialSources, FMX.Layers3D;

type
  TFr3DGraph = class(TFrame)
    MViewport3D: TViewport3D;
    Grid3D1: TGrid3D;
    ColorMaterialSource1: TColorMaterialSource;
    ColorMaterialSource2: TColorMaterialSource;
    procedure MViewport3DMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
    procedure MViewport3DMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Single);
    procedure MViewport3DMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
  private
    CameraDummyX, CameraDummyY : TDummy;
    Camera1 : TCamera;
    CLight   : TLight;
    isMouse : Boolean;
    DownPoint : TPointF;
    GBLayout1, GBLayout2 : TLayout3D;
    constructor Create(AOwner: TComponent) ; override;
    destructor Destroy; override;
    procedure CameraView_Init;
    procedure Point_Circle(pBase: TLayout3D; cSource:TColorMaterialSource; x,y, value: single);
    procedure Graph3D_DrawKind(baseLayout: TLayout3D; sData: TStringList; cSource:TColorMaterialSource; max : string);
//    procedure Draw_Line(pBase: TLayout3D; x1, y1, x2, y2: single);
  public
    procedure DeleteAll_3D;
    procedure Draw1_3D( max : string );
    procedure Draw2_3D( max : string );
  end;

implementation

Uses
  DBModule;



{$R *.fmx}

constructor TFr3DGraph.Create(AOwner : TComponent);
begin
  inherited;

  CameraView_Init();
end;

//------------------------------------------
destructor TFr3DGraph.Destroy;
begin
  //........
  inherited;
end;

procedure TFr3DGraph.DeleteAll_3D();
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
end;


//---------------------------------------------
procedure TFr3DGraph.Draw1_3D( max : string );
var
  sListData : TStringList;
begin
  if Assigned( GBLayout1 ) then
  begin
    GBLayout1.Release;
    GBLayout1 := nil;
  end;

  GBLayout1 := TLayout3D.Create( MViewport3D );
  GBLayout1.Parent := MViewport3D;
  GBLayout1.Position.Vector := Vector3D( 0,-8, 2 );
  GBLayout1.Width  := 16;
  GBLayout1.Height := 16;
  GBLayout1.HitTest := FALSE;

  sListData := DModule.Select_Data( 'Data1' );
  Graph3D_DrawKind( GBLayout1, sListData, ColorMaterialSource1, max );
end;

//---------------------------------------------
procedure TFr3DGraph.Draw2_3D( max : string );
var
  sListData : TStringList;
begin
  if Assigned( GBLayout2 ) then
  begin
    GBLayout2.Release;
    GBLayout2 := nil;
  end;

  GBLayout2 := TLayout3D.Create( MViewport3D );
  GBLayout2.Parent := MViewport3D;
  GBLayout2.Position.Vector := Vector3D( 0,-8,-2 );
  GBLayout2.Width  := 16;
  GBLayout2.Height := 16;
  GBLayout2.HitTest := FALSE;

  sListData := DModule.Select_Data( 'Data2' );
  Graph3D_DrawKind( GBLayout2, sListData, ColorMaterialSource2, max );
end;


procedure TFr3DGraph.Graph3D_DrawKind( baseLayout:TLayout3D; sData:TStringList; cSource:TColorMaterialSource; max:string );
var
  i : Integer;
  x, y, yMax : single;
  yArr : array of single;

begin
  SetLength( yArr, sData.Count );

  for i := 0 to sData.Count-1 do
      yArr[i] := sData[i].ToSingle;

  if max = '' then             // Max값 미입력시 데이터 중 최대값으로 자동지정
     yMax :=  MaxValue( yArr )
  else
     yMax := max.ToSingle;

  for i := 1 to sData.Count do
  begin
    x := baseLayout.Width * i / sData.Count;

    if yMax = 0 then  y := 0
    else              y := baseLayout.Height * yArr[i-1] / yMax;

    Point_Circle( baseLayout, cSource, x,y, yArr[i-1] );
  end;
end;



// Y좌표 : 수학 좌표
procedure TFr3DGraph.Point_Circle( pBase:TLayout3D; cSource:TColorMaterialSource; x,y, value: single );
var
  cp : TSphere;
  cYBar : TCylinder;
begin
// Data Point -------------------------
//  cp := TSphere.Create( pBase );
//  cp.Parent := pBase;
//  cp.HitTest := FALSE;
//  cp.MaterialSource := cSource;
//  cp.Width  := 0.2;
//  cp.Height := 0.2;
//  cp.Depth  := 0.2;
//  cp.Position.X := x - cp.Width/2;
//  cp.Position.Y := pBase.Height - y - cp.Height/2;
//  cp.Position.Z := 0;

  cYBar := TCylinder.Create( pBase );
  cYBar.Parent := pBase;
  cYBar.HitTest := FALSE;
  cYBar.MaterialSource :=  cSource;
  cYBar.Width := 0.3;
  cYBar.Depth := 0.3;
  cYBar.Height     := y;
  cYBar.Position.X := x - cYBar.Width/2;
  cYBar.Position.Y :=  pBase.Height - y/2;
end;



//-----------------------------------------------------------
procedure TFr3DGraph.CameraView_Init;
begin
  CameraDummyY := TDummy.Create(nil);
  CameraDummyY.Parent := MViewport3D;

  CameraDummyX := TDummy.Create(nil);
  CameraDummyX.Parent := CameraDummyY;
  CameraDummyX.RotationAngle.X := -20;
  CameraDummyX.RotationAngle.Y := 0;
  CameraDummyX.RotationAngle.Z := 0;
  CameraDummyX.Position.Y := -8;      // 화면 상하 위치 조절

  Camera1 := TCamera.Create(nil);
  Camera1.Parent := CameraDummyX;
  Camera1.Target := CameraDummyX;
  Camera1.Position.Z := -30;           // 적절한 거리값.

  MViewport3D.Camera := Camera1;
  MViewport3D.UsingDesignCamera := False;

  CLight := TLight.Create(nil);
  CLight.Parent := MViewport3D;
  CLight.Position.Vector := Vector3D( 0,0,-30 );
  CLight.RotationAngle.Vector := Vector3D( -20, 0,0 );
end;


procedure TFr3DGraph.MViewport3DMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X,Y: Single);
begin
  isMouse := True;
  DownPoint := PointF(X,Y);

  MViewport3D.Camera := Camera1;
end;

procedure TFr3DGraph.MViewport3DMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Single);
begin
  if (ssLeft in Shift) and isMouse then
  begin
    CameraDummyX.RotationAngle.X := CameraDummyX.RotationAngle.X - (Y - DownPoint.Y)* 0.7;
    CameraDummyY.RotationAngle.Y := CameraDummyY.RotationAngle.Y + (X - DownPoint.X)* 0.7;

    DownPoint.X := X;
    DownPoint.Y := Y;
  end;
end;

procedure TFr3DGraph.MViewport3DMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X,Y: Single);
begin
  isMouse := False;
end;



end.
