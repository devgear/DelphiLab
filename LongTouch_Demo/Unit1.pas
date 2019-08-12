// *********************************************************************************************
// c2design's Cross Platform Projects.
// This Demo Source was developed by Sanghyun Oh (Embarcadero's MVP, Developer of Korea.)
// http://c2design5sh.blogspot.com
//**********************************************************************************************

unit Unit1;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Layouts, FMX.ListBox, FMX.StdCtrls;

type
  TForm1 = class(TForm)
    ToolBar1: TToolBar;
    Label1: TLabel;
    BListBox: TListBox;
    LongTouchTimer: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure LongTouchTimerTimer(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure BListBoxItem_MouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
    procedure BListBoxItem_MouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
    procedure BListBoxItem_MouseMove(Sender: TObject; Shift: TShiftState; X, Y: Single);
  end;

var
  Form1: TForm1;

implementation

{$R *.fmx}

var
  ClickInterval : Cardinal = 0;   // Long Touch Count
  DownY : single;                     //  Mouse Down Position
const
  LONG_TIME = 8;  // Long Touch Time : 0.8 sec  ~ Change this count, if you want to control Long Touch Time.

//*********************************************************************************************
procedure TForm1.FormCreate(Sender: TObject);
var
  i : integer;
  subItem : TListBoxItem;
begin
  BListBox.BeginUpdate();
  for i := 0 to 20 do
  begin
    subItem := TListBoxItem.Create( BListBox );
    subItem.Height := 50;
    subItem.Text := 'ListBoxItem No ' + i.ToString();

    // Dynamic generation of Event Handler procedure.
    subItem.OnMouseDown := Form1.BListBoxItem_MouseDown;
    subItem.OnMouseUp   := Form1.BListBoxItem_MouseUp;
    subItem.OnMouseMove := Form1.BListBoxItem_MouseMove;
    BListBox.AddObject( subItem );
  end;
  BListBox.EndUpdate();
end;


//-------------------------------------------------------------------------------------------------------------
procedure TForm1.BListBoxItem_MouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
var
  i : integer;
begin
  DownY := Y;

  ClickInterval := 0;
  LongTouchTimer.Enabled := TRUE;
  LongTouchTimer.TagString :=  ( Sender as TListBoxItem ).Text;
end;

//-------------------------------------------------------------------------------------------------------------
// Short Touch
procedure TForm1.BListBoxItem_MouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
begin
  if ClickInterval < LONG_TIME then  // Short Touch : less than 0.8sec
  begin
    LongTouchTimer.Enabled := FALSE;
    ClickInterval := 0;

    ShowMessage( 'Short Touch : ' + ( Sender as TListBoxItem ).Text );
  end;
end;

//-----------------------------------------------------------------------------------------------
// Long Touch
procedure TForm1.LongTouchTimerTimer(Sender: TObject);
begin
  ClickInterval := ClickInterval + 1;

  if ( ClickInterval = 8 ) then  //  Count Timer 8th :  0.8sec is a Long Touch.
  begin
    LongTouchTimer.Enabled := FALSE;
    ShowMessage( 'Long Touch : ' + LongTouchTimer.TagString );
  end
end;


//-----------------------------------------------------------------------------------------------
// This MouseMove event needs only on ListBox or ListView.
// Because Touch and Move scroll event is counted as Long Touch Interval.
// So, Scroll Event Time should be removed.
procedure TForm1.BListBoxItem_MouseMove(Sender: TObject; Shift: TShiftState; X, Y: Single);
var
  i : integer;
begin
   if ABS( DownY - Y ) > 10 then  // Real Scroll.
   begin
     for i := 0 to BListBox.Items.Count -1 do
        BListBox.ListItems[i].IsSelected := FALSE;

    LongTouchTimer.Enabled := FALSE;
    ClickInterval := 0;
   end;
end;


end.
