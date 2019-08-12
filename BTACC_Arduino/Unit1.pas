//***************************************************************************************
// 블루투스 아두이노 제어 프로젝트
//***************************************************************************************
// * 이 소스의 모든 권리는 최초 개발자인 c2deisgn@paran.com에 귀속 됩니다.
// * 이 소스는 델파이 개발자들의 스터디용으로 오픈 합니다.
// * 비상업적 용도로만 사용 가능합니다.
// * 개인 스터디 용도 이외에는 사용을 금함니다.
// * 소스 및 이미지의 무단 배포를 금합니다.
//***************************************************************************************

unit Unit1;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FMX.Layouts, FMX.ListBox, FMX.StdCtrls, FMX.Memo, FMX.Controls.Presentation,
  FMX.Edit, FMX.TabControl, FMX.ScrollBox, FMX.Objects, FMX.Ani, FMX.Effects, System.Actions, FMX.ActnList,
  BTConfig;  // Add for BlueTooth


type
  TForm1 = class(TForm)
    MyDevice_lb: TLabel;
    MTabControl: TTabControl;
    TabItem1: TTabItem;
    TabItem2: TTabItem;
    Services_cb: TComboBox;
    ServiceList_lb: TLabel;
    TopRectangle: TRectangle;
    BaseRectangle1: TRectangle;
    Line1: TLine;
    OnBar: TRectangle;
    GPanelRect1: TRectangle;
    OnGLayout: TLayout;
    OnSumLayout: TLayout;
    OnLeft_rbt: TRectangle;
    OnRight_rbt: TRectangle;
    Layout1: TLayout;
    Layout2: TLayout;
    Layout3: TLayout;
    OffSumLayout: TLayout;
    Layout5: TLayout;
    OffBar: TRectangle;
    GPanelRect2: TRectangle;
    OffLeft_rbt: TRectangle;
    OffRight_rbt: TRectangle;
    OnIntervalText: TText;
    OffIntervalText: TText;
    Text1: TText;
    OffTimeUnitTx: TText;
    OnTimeUnitTx: TText;
    Text4: TText;
    TimeSet_cb: TComboBox;
    Interval_btImg: TImage;
    Interval_BitAni: TBitmapAnimation;
    On_btImg: TImage;
    On_BitAni: TBitmapAnimation;
    Off_btImg: TImage;
    Off_BitAni: TBitmapAnimation;
    BaseRect2: TRectangle;
    PrListBox: TListBox;
    TitleRect: TRectangle;
    Text2: TText;
    ListBoxItem1: TListBoxItem;
    ToastLayout: TLayout;
    MessageRect: TRoundRect;
    ShadowEffect1: TShadowEffect;
    MsgText: TText;
    BServiceRect: TRectangle;
    Connect_btimg: TImage;
    Connect_BitAni: TBitmapAnimation;
    ActionList1: TActionList;
    ChangeTabAction1: TChangeTabAction;
    Panel_Quit: TPanel;
    QuitButton: TButton;
    TitleImg: TRectangle;
    TabItem3: TTabItem;
    AbaseRect: TRectangle;
    AboutImgRect: TRectangle;
    MoreApp_Img: TImage;
    About_Imgbt: TImage;
    About_BitAni: TBitmapAnimation;
    ArduinoDownText: TText;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure Services_cbChange(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure OnLeft_rbtMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
    procedure OnRight_rbtMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
    procedure GPanelRect1MouseMove(Sender: TObject; Shift: TShiftState; X, Y: Single);
    procedure OffLeft_rbtMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
    procedure OffRight_rbtMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
    procedure GPanelRect2MouseMove(Sender: TObject; Shift: TShiftState; X, Y: Single);
    procedure OnIntervalTextMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
    procedure TimeSet_cbChange(Sender: TObject);
    procedure OffIntervalTextMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
    procedure Interval_btImgClick(Sender: TObject);
    procedure Interval_BitAniFinish(Sender: TObject);
    procedure On_btImgClick(Sender: TObject);
    procedure On_BitAniFinish(Sender: TObject);
    procedure Off_BitAniFinish(Sender: TObject);
    procedure Off_btImgClick(Sender: TObject);
    procedure Connect_btimgClick(Sender: TObject);
    procedure Connect_BitAniFinish(Sender: TObject);
    procedure FormKeyUp(Sender: TObject; var Key: Word; var KeyChar: Char; Shift: TShiftState);
    procedure QuitButtonClick(Sender: TObject);
    procedure About_BitAniFinish(Sender: TObject);
    procedure About_ImgbtClick(Sender: TObject);
    procedure TitleImgClick(Sender: TObject);
  private
    { Private declarations }
    SListPairedDevices : TStringList;       // 페어링 디바이스 리스트 보관
    TargetPaireNo : integer;                // 현재 지정된 페어링 디바이스 No
    CurDeviceServices : DServiceListType;   // 현재 지정 디바이스의 BlueTooth 서비스 리스트 보관.
    OnTimeInterval, OffTimeInterval : integer;
    OnUnit, OffUnit : integer;              // 1초 기준 분,시 변환시 곱한다.  분:60, 시:3600
    procedure ServicesList_Add();
    procedure Time_To_SetBarWidth(sBar: TRectangle; valueTime: integer);
    procedure PairedDevices_AddListBox;
    procedure PrListItem_MouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
    procedure ToastMessage_On(msg: string);
    procedure ToastMessage_Off(msg: string);
    procedure Panel_Quit_Display_OnOFF(On_Off: boolean);
  public
    { Public declarations }
  end;

var
  Form1: TForm1;


implementation

{$IFDEF ANDROID}
Uses
  Androidapi.Helpers;
{$ENDIF}


var
  BTMethod : TBTMethod;

{$R *.fmx}



//******************************************************************
procedure TForm1.FormCreate(Sender: TObject);
begin
  BTMethod := TBTMethod.Create;     // BlueTooth Create

  OnTimeInterval  := 30;     OnUnit := 1;    // 최초 초단위
  OffTimeInterval := 30;    OffUnit := 1;

  TimeSet_cb.Visible := FALSE;
  ToastLayout.Opacity  := 0;
  MTabControl.TabPosition := TTabPosition.None;
  MTabControl.TabIndex := 0;  // 최초 BT Device 선택
end;

procedure TForm1.FormShow(Sender: TObject);
begin
  PairedDevices_AddListBox();
  MyDevice_lb.Text := BTMethod.MyDeviceName;
end;

//*********************************************************
procedure TForm1.FormResize(Sender: TObject);
begin
  OnBar.Position  := GPanelRect1.Position;
  OffBar.Position := GPanelRect2.Position;
  Time_To_SetBarWidth( OnBar, OnTimeInterval );
  Time_To_SetBarWidth( Offbar, OffTimeInterval );
end;


//---------------------------------------------------------
procedure TForm1.PairedDevices_AddListBox();
var
  i : integer;
  subI : TListBoxItem;
begin
  SListPairedDevices := BTMethod.PairedDevices;    // 시작시 페어링 디바이스 리스트 가져옴.

  PrListBox.Items.Clear();
  PrListBox.BeginUpdate();

  for i:= 0 to SListPairedDevices.Count - 1 do
  begin
    subI := TListBoxItem.Create( PrListBox );
    subI.Height := 50;
    subI.Font.Size := 20;
    subI.TextSettings.FontColor := $FFFFFFFF;
    subI.StyledSettings := [TStyledSetting.Family, TStyledSetting.Style];
    subI.Selectable := FALSE;
    subI.Text := #$20+#$20+#$20+ SListPairedDevices[i];
    subI.OnMouseUp := Form1.PrListItem_MouseUp;
    PrListBox.AddObject( subI );
  end;
  PrListBox.EndUpdate();
end;

procedure TForm1.PrListItem_MouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
begin
  PrListBox.ItemByIndex( TargetPaireNo ).TextSettings.FontColor := $FFFFFFFF;  // 이전선택 항목
  TargetPaireNo :=  PrListBox.ItemIndex;

  (Sender as TListBoxItem).TextSettings.FontColor := $FF4FFFFA;
  ToastMessage_On( (Sender as TListBoxItem).Text +   ' Service Searching...' );

  TThread.CreateAnonymousThread( procedure ()
  begin
     ServicesList_Add();    // 타겟 디바이스가 바뀌므로 서비스도 다시 검색해야 함.
     TThread.Synchronize( TThread.CurrentThread, procedure ()
     begin
        //
     end);
     ToastMessage_Off( 'Searching Completed.' );
   end).Start;
end;

//---------------------------------------------------
procedure TForm1.ToastMessage_On( msg : string );
begin
  PrListBox.HitTest := FALSE;
  ToastLayout.Width := Form1.ClientWidth;
  ToastLayout.Align := TAlignLayout.Center;
  MsgText.Text := msg;
  ToastLayout.Opacity := 1.0;
end;

procedure TForm1.ToastMessage_Off( msg: string );
begin
  MsgText.Text := msg;
  PrListBox.HitTest := TRUE;
  TAnimator.Create.AnimateFloatDelay( ToastLayout, 'Opacity', 0.0, 0.3, 0.5  );
end;


//-------------------------------------------
procedure TForm1.ServicesList_Add();
var
 i : Integer;
begin
  CurDeviceServices := BTMethod.Find_ServicesList( TargetPaireNo );  // 타겟 디바이스 전체 서비스 리스트 전달

  Services_cb.Clear;
  for i:= 0 to CurDeviceServices.DServiceName.Count - 1 do
      Services_cb.Items.Add( CurDeviceServices.DServiceName[i] );   // 화면표시는 ServiceName

  Services_cb.ItemIndex := 0;
end;

//*********************************************************
procedure TForm1.Services_cbChange(Sender: TObject);
begin
  if Services_cb.ItemIndex >= 0 then
  begin
    BTMethod.FServiceGUID := CurDeviceServices.DServiceGUID[ Services_cb.ItemIndex ];  // Service Setting
  end;
end;


//**************************************************
procedure TForm1.Connect_btimgClick(Sender: TObject);
begin
  Connect_BitAni.Enabled := TRUE;
end;

procedure TForm1.Connect_BitAniFinish(Sender: TObject);
begin
  Connect_BitAni.Enabled := FALSE;
  if BTMethod.SendData( TargetPaireNo, '1' + #$15 ) then
  begin
    ChangeTabAction1.Tab := MTabControl.Tabs[ 1 ];
    ChangeTabAction1.Direction := TTabTransitionDirection.Normal;
    ChangeTabAction1.ExecuteTarget(self);
    TabItem2.Tag := 1;  // 백버튼 제어
  end;
end;


//*******************************************************************************
procedure TForm1.Interval_btImgClick(Sender: TObject);
begin
  Interval_BitAni.Enabled := TRUE;

  // sec 단위 입력
  BTMethod.SendData( TargetPaireNo, ( OnTimeInterval * OnUnit).ToString() + #$13 +
                                    ( OffTimeInterval * OffUnit ).ToString() + #$14 );
end;

procedure TForm1.Interval_BitAniFinish(Sender: TObject);
begin
  Interval_BitAni.Enabled := FALSE;
end;

//*****************************************************
procedure TForm1.On_btImgClick(Sender: TObject);
begin
  On_BitAni.Enabled := TRUE;
  BTMethod.SendData( TargetPaireNo, '1' + #$15 );
end;

procedure TForm1.On_BitAniFinish(Sender: TObject);
begin
  On_BitAni.Enabled := FALSE;
end;


procedure TForm1.Off_btImgClick(Sender: TObject);
begin
  Off_BitAni.Enabled := TRUE;
  BTMethod.SendData( TargetPaireNo, '0' + #$15 );
end;

procedure TForm1.Off_BitAniFinish(Sender: TObject);
begin
  Off_BitAni.Enabled := FALSE;
end;


//---------------------------------------------------------------------------------
// valueTime : 2,4,6..60
procedure TForm1.Time_To_SetBarWidth( sBar: TRectangle; valueTime:integer );
begin
  if sBar.Name = 'OnBar' then
  begin
    sBar.Width :=  GPanelRect1.Width * valueTime / 60;
    OnTimeInterval := valueTime;
    OnIntervalText.Text := valueTime.ToString();
  end
  else if sBar.Name = 'OffBar' then
  begin
    sBar.Width :=  GPanelRect2.Width * valueTime / 60;
    OffTimeInterval := valueTime;
    OffIntervalText.Text := valueTime.ToString();
  end;
end;


//*********************************************************************************************************
procedure TForm1.OnLeft_rbtMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
begin
  if ( OnTimeInterval <= 2 ) then Exit;
  OnTimeInterval := OnTimeInterval - 2;
  Time_To_SetBarWidth( OnBar, OnTimeInterval );
end;

procedure TForm1.OnRight_rbtMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
begin
  if ( 60 <= OnTimeInterval ) then  Exit;
  OnTimeInterval := OnTimeInterval + 2;
  Time_To_SetBarWidth( OnBar, OnTimeInterval );
end;

procedure TForm1.OffLeft_rbtMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
begin
  if ( OffTimeInterval <= 2 ) then Exit;
  OffTimeInterval := OffTimeInterval - 2;
  Time_To_SetBarWidth( OffBar, OffTimeInterval );
end;

procedure TForm1.OffRight_rbtMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
begin
  if ( 60 <= OffTimeInterval ) then Exit;
  OffTimeInterval := OffTimeInterval + 2;
  Time_To_SetBarWidth( OffBar, OffTimeInterval );
end;


//**************************************************************************************************************
// 그래프 직접 터치시
procedure TForm1.GPanelRect1MouseMove(Sender: TObject; Shift: TShiftState; X, Y: Single);
var
  oneDim : single;
  nPos : integer;
begin
  oneDim := GPanelRect1.Width / 30;   // 한칸의 넓이
  nPos := Trunc( X / oneDim ) + 1 ;   // 몇번째 칸인지..

  OnBar.Width := oneDim * nPos;
  OnTimeInterval := nPos * 2;
  OnIntervalText.Text := OnTimeInterval.ToString();
end;

procedure TForm1.GPanelRect2MouseMove(Sender: TObject; Shift: TShiftState; X, Y: Single);
var
  oneDim : single;
  nPos : integer;
begin
  oneDim := GPanelRect2.Width / 30;   // 한칸의 넓이
  nPos := Trunc( X / oneDim ) + 1 ;   // 몇번째 칸인지..

  OffBar.Width := oneDim * nPos;
  OffTimeInterval := nPos * 2;
  OffIntervalText.Text := OffTimeInterval.ToString();
end;


//**************************************************************************************************************
// 시간 단위 변환시
procedure TForm1.OnIntervalTextMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
begin
  TimeSet_cb.ItemIndex := -1;
  TimeSet_cb.Tag := 1;
  TimeSet_cb.DropDown;
end;

procedure TForm1.OffIntervalTextMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
begin
  TimeSet_cb.ItemIndex := -1;
  TimeSet_cb.Tag := 0;
  TimeSet_cb.DropDown;
end;

procedure TForm1.TimeSet_cbChange(Sender: TObject);
begin
  case TimeSet_cb.Tag of
     1 : case TimeSet_cb.ItemIndex  of
            0 : begin OnTimeUnitTx.Text := 'Seconds';  OnUnit := 1;     end;
            1 : begin OnTimeUnitTx.Text := 'Minutes';  OnUnit := 60;    end;
            2 : begin OnTimeUnitTx.Text := 'Hours';    OnUnit := 3600;  end;
         end;
     0 : case TimeSet_cb.ItemIndex  of
            0 : begin OffTimeUnitTx.Text := 'Seconds';  OffUnit := 1;     end;
            1 : begin OffTimeUnitTx.Text := 'Minutes';  OffUnit := 60;    end;
            2 : begin OffTimeUnitTx.Text := 'Hours';    OffUnit := 3600;  end;
         end;
  end;
end;

//---------------------------------------------------------------
procedure TForm1.Panel_Quit_Display_OnOFF( On_Off : boolean );
begin
  if On_Off then // 열림
  begin
    Panel_Quit.Tag := 1;
    Panel_Quit.Width := Form1.ClientWidth;
    Panel_Quit.Position.X := 0;
    Panel_Quit.Position.Y := Form1.ClientHeight - Panel_Quit.Height;
    Panel_Quit.Visible := TRUE;
  end
  else
  begin
    Panel_Quit.Visible := FALSE;
    Panel_Quit.Tag := 0;
  end;
end;

procedure TForm1.QuitButtonClick(Sender: TObject);
begin
  {$IFDEF ANDROID}
   SharedActivity.finish;
  {$ENDIF}
end;


//************************************************************************************************
procedure TForm1.FormKeyUp(Sender: TObject; var Key: Word; var KeyChar: Char; Shift: TShiftState);
var
  iTagSum : integer;
begin
{$IFDEF ANDROID}
   iTagSum :=  TabItem2.Tag + TabItem3.Tag + Panel_Quit.Tag;

   if Key = vkHardwareBack Then
   begin
     Key :=  0;

     if iTagSum > 0 then
     begin
       if Panel_Quit.Tag = 1 then
          Panel_Quit_Display_OnOFF( FALSE )
       else if ( TabItem2.Tag = 1 ) and ( TabItem3.Tag = 0 ) then
       begin
         ChangeTabAction1.Tab := MTabControl.Tabs[ 0 ];
         ChangeTabAction1.Direction := TTabTransitionDirection.Normal;
         ChangeTabAction1.ExecuteTarget(self);
         TabItem2.Tag := 0;
       end
       else if TabItem3.Tag = 1 then
       begin
         ChangeTabAction1.Tab := MTabControl.Tabs[ iTagSum-1 ];
         ChangeTabAction1.Direction := TTabTransitionDirection.Normal;
         ChangeTabAction1.ExecuteTarget(self);
         TabItem3.Tag := 0;
       end;
     end

     else
       Panel_Quit_Display_OnOFF( TRUE );  // 종료 확인패널 열림
   end;
{$ENDIF}
end;

//*******************************************************
procedure TForm1.About_ImgbtClick(Sender: TObject);
begin
 About_BitAni.Enabled := TRUE;
end;


procedure TForm1.About_BitAniFinish(Sender: TObject);
begin
  About_BitAni.Enabled := FALSE;
  ChangeTabAction1.Tab := MTabControl.Tabs[ 2 ];
  ChangeTabAction1.Direction := TTabTransitionDirection.Normal;
  ChangeTabAction1.ExecuteTarget(self);
  TabItem3.Tag := 1;
end;

//********************************************************
// 데모용.
procedure TForm1.TitleImgClick(Sender: TObject);
begin
  TabItem2.Tag := 1;
  MTabControl.TabIndex := 1;
end;




end.
