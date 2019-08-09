unit RemoteMain;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, IdBaseComponent, IdComponent, IdUDPBase, IdUDPClient,
  FMX.Controls.Presentation, FMX.StdCtrls, FMX.Edit, FMX.Layouts, RDuRotaryKnob, RDuButtonSet, RDuToggleButtons,
  FMX.TabControl, RDuPopupDialog, FMX.Objects, RDuInputQueryBox, FMX.ListBox, RDuIconFlicker, FireDAC.Stan.Intf,
  FireDAC.Stan.Option, FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool,
  FireDAC.Stan.Async, FireDAC.Phys, FireDAC.Phys.SQLite, FireDAC.Phys.SQLiteDef, FireDAC.Stan.ExprFuncs,
  FireDAC.FMXUI.Wait, FireDAC.Stan.Param, FireDAC.DatS, FireDAC.DApt.Intf, FireDAC.DApt, Data.DB, FireDAC.Comp.DataSet,
  FireDAC.Comp.Client, RDuColorCheckBox, RDuToastMessage, RDuMovingCaption, RDuDigitalNumber;

type
  TMForm = class(TForm)
    IdUDPClient1: TIdUDPClient;
    RDRotaryKnob1: TRDRotaryKnob;
    RDToggleButtons1: TRDToggleButtons;
    MTabControl: TTabControl;
    TabItem1: TTabItem;
    TabItem2: TTabItem;
    Rectangle1: TRectangle;
    RDPopupDialog1: TRDPopupDialog;
    RDInputQueryBox1: TRDInputQueryBox;
    LBaseRect: TRectangle;
    SetListBox: TListBox;
    ListBoxItem1: TListBoxItem;
    RDIconFlicker1: TRDIconFlicker;
    FDCon: TFDConnection;
    FDQueryI: TFDQuery;
    RDColorCheckBox1: TRDColorCheckBox;
    RDToastMessage1: TRDToastMessage;
    SpeedButton1: TSpeedButton;
    Text1: TText;
    Rectangle2: TRectangle;
    RDDigitalNumber1: TRDDigitalNumber;
    RDDigitalNumber2: TRDDigitalNumber;
    Rectangle3: TRectangle;
    Layout1: TLayout;
    RDDigitalNumber3: TRDDigitalNumber;
    procedure RDToggleButtons1ButtonSetClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure RDRotaryKnob1DialChange(Sender: TObject);
    procedure RDIconFlicker1FlickerFinish(Sender: TObject);
    procedure RDInputQueryBox1ApplyButtonClick(Sender: TObject);
    procedure FDConBeforeConnect(Sender: TObject);
    procedure RDPopupDialog1RightTextButtonClick(Sender: TObject);
  private
    procedure Select_ListAll;
    procedure IsCheck_Update_Set(iSeq: integer);
    procedure IsCheck_Update_Zero;

    procedure DispText_Create(pPar: TFmxObject;  xpos, ypos: integer; fColor: Cardinal; isBald: Boolean);
    procedure RDCheckBox_Create(pPar: TFmxObject; isCheck: integer);
    procedure DelButton_Create(pPar: TListboxItem );
    procedure DeleteButton_Click(Sender: TObject);
    procedure DeleteItem(nNo: integer);
    function GetTarget_Connection: string;
    procedure ListItem_MouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
    procedure DigitalNumber_Write(rvalue: integer);

    { Private declarations }
  public
    { Public declarations }
  end;

var
  MForm: TMForm;
  BeforeV : single;
  SandBoxDir : string;

implementation

{$R *.fmx}

//**************************************************
procedure TMForm.FormCreate(Sender: TObject);
begin
  {$IF DEFINED(iOS) or DEFINED(ANDROID)}
   MForm.FullScreen := TRUE;
  {$ENDIF}

  {$IFDEF IOS}
  SandBoxDir := GetHomePath + PathDelim + 'Library' + PathDelim;    //  StartUp\Library
  {$ELSE}
  SandBoxDir := GetHomePath + PathDelim;                            // .\assets\internal
  {$ENDIF}


  MTabControl.TabPosition := TTabPosition.None;
  MTabControl.TabIndex := 0;
  RDToastMessage1.Visible := TRUE;

  Select_ListAll();

  IdUDPClient1.Host := GetTarget_Connection();
  IdUDPClient1.Port := 8888;

  // 타겟 미지정시 첫화면, 지정시 두번째 화면 전환.
  if IdUDPClient1.Host = '127.0.0.1' then
  begin
    MTabControl.TabIndex := 0;
    RDToggleButtons1.ClickIndex := 0;
  end
  else
  begin
    MTabControl.TabIndex := 1;
    RDToggleButtons1.ClickIndex := 1;
  end;


  BeforeV :=  RDRotaryKnob1.Value;
  DigitalNumber_Write( Round( RDRotaryKnob1.Value ) );
end;

procedure TMForm.FDConBeforeConnect(Sender: TObject);
begin
  {$IF DEFINED(iOS) or DEFINED(ANDROID)}
   FDCon.Params.Values[ 'Database' ] :=  SandBoxDir + 'iplist.db';
  {$ENDIF}
end;



// 화면전환
procedure TMForm.RDToggleButtons1ButtonSetClick(Sender: TObject);
begin
  MTabControl.TabIndex := RDToggleButtons1.ClickIndex;
end;


//*******************************************************
procedure TMForm.RDIconFlicker1FlickerFinish(Sender: TObject);
begin
  RDInputQueryBox1.ShowQueryBox( 'IP Address' );
end;

procedure TMForm.RDInputQueryBox1ApplyButtonClick(Sender: TObject);
begin
  IsCheck_Update_Zero();     // IsCheck 항목추가시 기본값 1

  FDCon.Open;
  try
    FDQueryI.Close;
    FDQueryI.SQL.Clear;
    FDQueryI.Sql.Add( 'insert into tb_iplist ( IPAddress ) ' );
    FDQueryI.Sql.Add( 'values( :p_1 ); ' );
    FDQueryI.ParamByName('p_1').Asstring  :=  RDInputQueryBox1.InputString;
    FDQueryI.ExecSQL();
  except
    on e: Exception do begin
      ShowMessage( e.Message );
    end;
  end;
  FDCon.Close;

  Select_ListAll();  // Refresh;
  IdUDPClient1.Host := GetTarget_Connection();
end;


//------------------------------------------------------------------------
procedure TMForm.Select_ListAll();
var
  subI : TListboxItem;
begin
  FDCon.Open;
  try
    FDQueryI.Close;
    FDQueryI.SQL.Clear;
    FDQueryI.SQL.Add( 'Select * from tb_iplist ' );
    FDQueryI.Open;
    FDQueryI.First;

    SetListBox.Items.Clear();
    SetListBox.BeginUpdate();

    while Not FDQueryI.EOF do
    begin
      subI := TListBoxItem.Create( SetListBox );
      subI.Height := 74;
      subI.Selectable := FALSE;
      subI.Tag := FDQueryI.FieldByName('seq').AsInteger;
      subI.TagString := FDQueryI.FieldByName('IPAddress').AsString;
      subI.OnMouseUp := ListItem_MouseUp;

      DispText_Create( subI, 80,20, $FFFFFFFF, TRUE );
      RDCheckBox_Create( subI, FDQueryI.FieldByName('isCheck').AsInteger );
      DelButton_Create( subI );

      SetListBox.AddObject( subI );
      FDQueryI.Next;
    end;
    SetListBox.EndUpdate();


  except
    on e: Exception do begin
      ShowMessage( e.Message );
    end;
  end;
  FDCon.Close;
end;

//------------------------------------------------------------------
procedure TMForm.IsCheck_Update_Zero;
begin
  FDCon.Open;
  try
    FDQueryI.Close;
    FDQueryI.SQL.Clear;
    FDQueryI.Sql.Add( 'update tb_iplist set isCheck = 0 ' );
    FDQueryI.Sql.Add( 'where isCheck = 1 ;' );
    FDQueryI.ExecSQL();

  except
    on e: Exception do begin
      ShowMessage( e.Message );
    end;
  end;
  FDCon.Close;
end;

procedure TMForm.IsCheck_Update_Set( iSeq : integer );
begin
  FDCon.Open;
  try
    FDQueryI.Close;
    FDQueryI.SQL.Clear;
    FDQueryI.Sql.Add( 'update tb_iplist set isCheck = 1 ' );
    FDQueryI.Sql.Add( 'where seq = :p_seq ;' );
    FDQueryI.ParamByName('p_seq').AsInteger  := iSeq;
    FDQueryI.ExecSQL();

  except
    on e: Exception do begin
      ShowMessage( e.Message );
    end;
  end;
  FDCon.Close;
end;

//---------------------------------------------------------------------------------------
function TMForm.GetTarget_Connection() : string;
begin
  result := '127.0.0.1';

  FDCon.Open;
  try
    FDQueryI.Close;
    FDQueryI.SQL.Clear;
    FDQueryI.SQL.Add( 'Select * from tb_iplist ' );
    FDQueryI.SQL.Add( 'where isCheck = 1 ' );
    FDQueryI.Open;
    FDQueryI.First;

    while Not FDQueryI.EOF do
    begin
      result := FDQueryI.FieldByName('IPAddress').AsString;
      FDQueryI.Next;
    end;

  except
    on e: Exception do begin
      ShowMessage( e.Message );
    end;
  end;
  FDCon.Close;
end;


//--------------------------------------------------------------------------------------------------------------------
procedure TMForm.DispText_Create( pPar:TFmxObject; xpos,ypos:integer; fColor:Cardinal; isBald:Boolean );
var
  DispText : TText;
begin
  DispText := TText.Create(pPar);
  DispText.Parent := pPar;
  DispText.AutoSize := TRUE;
  DispText.WordWrap := FALSE;
  DispText.HorzTextAlign := TTextAlign.Leading;
  DispText.VertTextAlign := TTextAlign.Center;
  DispText.HitTest := FALSE;
  DispText.Font.Size := 24;
  DispText.Color :=  fColor;   // $FF291a60;
  DispText.Text :=  pPar.TagString;
  DispText.Position.X := xpos;
  DispText.Position.Y := ypos;
  DispText.Height := 40;

  if isBald then
     DispText.Font.Style := [TFontStyle.fsBold];  // ms-help://embarcadero.rs_xe7/codeexamples/FMXTFont_(Delphi).html
end;


procedure TMForm.RDCheckBox_Create( pPar:TFmxObject; isCheck :integer );
var
  rdCkeck : TRDColorCheckBox;
begin
  rdCkeck := TRDColorCheckBox.Create( pPar );
  rdCkeck.Parent := pPar;
  rdCkeck.Align :=  TAlignLayout.MostLeft;
  rdCkeck.Margins.Left := 20;
  rdCkeck.Tag := pPar.Tag;
  rdCkeck.HitTest := FALSE;
  rdCkeck.IsChecked := isCheck.ToBoolean;
end;

procedure TMForm.ListItem_MouseUp (Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
begin
  IsCheck_Update_Zero();
  IsCheck_Update_Set( ( Sender as TListboxItem ).Tag );

  Select_ListAll();


  IdUDPClient1.Host := GetTarget_Connection();
  RDToastMessage1.ShowToastMessage( 'Connection target changed..', 1.5, 180 );
end;


//--------------------------------------------------------------------------------------
procedure TMForm.DelButton_Create( pPar:TListboxItem  );
var
  fdButton : TSpeedButton;
begin
  fdButton := TSpeedButton.Create(pPar);
  fdButton.Parent := pPar;
  fdButton.StyleLookup := 'cleareditbutton';   // arrowuptoolbutton
  fdButton.Align := TAlignLayout.MostRight;
  fdButton.Margins.Right := 16;
  fdButton.Height := 50;
  fdButton.Width := 50;
  fdButton.Tag := pPar.Tag;              // inc Filed Data 저장해둠.
  fdButton.TagString := pPar.TagString;  //  TagStrTitle;

  fdButton.OnClick := DeleteButton_Click;
end;

//---------------------------------------------------------
procedure TMForm.DeleteButton_Click( Sender : TObject );
begin
  RDPopupDialog1.ShowPopupDialog( 'Confirm', 'Do you want to delete connection '+ (Sender as TSpeedButton ).TagString + ' ?', 'Cancel','OK' );
  RDPopupDialog1.Tag := (Sender as TSpeedButton ).Tag;


//  MessageDlg( 'Do you want to delete connection '  + (Sender as TSpeedButton ).TagString + ' ?',
//               TMsgDlgType.mtConfirmation, [TMsgDlgBtn.mbYes, TMsgDlgBtn.mbNo], 0,
//     procedure(const AResult: TModalResult)
//     begin
//       case AResult of
//         mrYES :  DeleteItem( (Sender as TSpeedButton ).Tag );
//       end;
//     end)
end;

procedure TMForm.RDPopupDialog1RightTextButtonClick(Sender: TObject);
begin
  DeleteItem( (Sender as TRDPopupDialog ).Tag );
end;



//------------------------------------------------------------------------------
procedure TMForm.DeleteItem( nNo : integer );
begin
  FDCon.Open;
  try
    FDQueryI.Close;
    FDQueryI.SQL.Clear;
    FDQueryI.Sql.Add( 'delete from tb_iplist ' );
    FDQueryI.Sql.Add( 'where seq = :inc ' );
    FDQueryI.ParamByName('inc').AsInteger  := nNo;
    FDQueryI.ExecSQL();
  except
    on e: Exception do begin
      ShowMessage( e.Message );
    end;
  end;
  FDCon.Close;

  Select_ListAll();  // Refresh;
end;



//******************************************************************************************
procedure TMForm.RDRotaryKnob1DialChange(Sender: TObject);
var
  v  : single;
  sValue : string;
begin
  if ( BeforeV = 0 ) and  ( RDRotaryKnob1.Value > 60 ) then      // 0 -> 100  방지
  begin
    RDRotaryKnob1.Value := 0;
    exit;
  end;

  if ( BeforeV = 100 ) and  ( RDRotaryKnob1.Value < 50 )  then  // 100 -> 0 방지
  begin
    RDRotaryKnob1.Value := 100;
    Exit;
  end;

  v :=   RDRotaryKnob1.Value / 100 ;
  sValue:= Format( '%.2f', [v] );       // 0.1 ~ 1.0
  IdUDPClient1.Send( sValue );

  DigitalNumber_Write ( Round( RDRotaryKnob1.Value ) );
  BeforeV :=  RDRotaryKnob1.Value;     // 다이얼 이전값 기억
end;

procedure TMForm.DigitalNumber_Write( rvalue : integer );
var
  rStr : string;
begin
  if rValue = 100 then
  begin
    RDDigitalNumber3.Visible := TRUE;
    RDDigitalNumber1.Number := '0';
    RDDigitalNumber2.Number := '0';
  end
  else
  begin
    rStr := Format( '%.2d', [rValue]  );
    RDDigitalNumber3.Visible := FALSE;
    RDDigitalNumber1.Number := Copy( rStr, 1, 1 );
    RDDigitalNumber2.Number := Copy( rStr, 2, 1 );
  end;
end;



end.
