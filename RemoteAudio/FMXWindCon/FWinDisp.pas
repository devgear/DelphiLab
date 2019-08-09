unit FWinDisp;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  Activex, MMDevAPI, FMX.Controls.Presentation, FMX.StdCtrls, IdUDPServer, IdGlobal, IdSocketHandle, FMX.ScrollBox,
  FMX.Memo, IdBaseComponent, IdComponent, IdUDPBase, FMX.Objects, FMX.Layouts, RDuCircularProgress, RDuHorzProgress,
  RDuAngularGauge, RDuHorzSlideBar;

type
  TSMForm = class(TForm)
    IdUDPServer1: TIdUDPServer;
    ThisIPText: TText;
    RDAngularGauge1: TRDAngularGauge;
    RDHorzSlideBar1: TRDHorzSlideBar;
    procedure FormCreate(Sender: TObject);
    procedure IdUDPServer1UDPRead(AThread: TIdUDPListenerThread; const AData: TIdBytes; ABinding: TIdSocketHandle);
    procedure RDHorzSlideBar1Change(Sender: TObject);
  private
    { Private declarations }
    function Get_IP4Address() : string;
  public
    { Public declarations }
    EndpointVolume: IAudioEndpointVolume;

  end;

var
  SMForm: TSMForm;

implementation

Uses
  IdStack;  // IP Address


{$R *.fmx}

procedure TSMForm.FormCreate(Sender: TObject);
var
  deviceEnumerator: IMMDeviceEnumerator;
  defaultDevice: IMMDevice;
begin
  EndpointVolume:=nil;
  CoCreateInstance(CLASS_IMMDeviceEnumerator, nil, CLSCTX_INPROC_SERVER, IID_IMMDeviceEnumerator, deviceEnumerator);
  deviceEnumerator.GetDefaultAudioEndpoint(eRender, eConsole, defaultDevice);
  defaultDevice.Activate(IID_IAudioEndpointVolume, CLSCTX_INPROC_SERVER, nil, endpointVolume);

  ThisIPText.Text := Get_IP4Address();
end;

//----------------------------------------------------
function TSMForm.Get_IP4Address() : string;
var
  IPs: TStringList;
  IP: String;
  I: Integer;
  Err: Boolean;
begin
  IPs := TStringList.Create;
  try
    GStack.AddLocalAddressesToList(IPs);
    for I := 0 to IPs.Count-1 do
    begin
      IP := IPs[I];
      IPv4ToDWord(IP, Err);
      if not Err then
        Break;
      IP := '';
    end;
  finally
    IPs.Free;
  end;
  if IP <> '' then
  begin
    result := IP;
  end;
end;


procedure TSMForm.IdUDPServer1UDPRead(AThread: TIdUDPListenerThread; const AData: TIdBytes; ABinding: TIdSocketHandle);
var
  rStr : string;
begin
  rStr := BytesToString(AData);
  EndpointVolume.SetMasterVolumeLevelScalar( rStr.ToSingle , nil);  // 0.0 ~  1.0

  RDAngularGauge1.Value := rStr.ToSingle * 100;
  RDHorzSlideBar1.Value := rStr.ToSingle * 10 / 0.5;
end;



procedure TSMForm.RDHorzSlideBar1Change(Sender: TObject);
begin
  EndpointVolume.SetMasterVolumeLevelScalar( RDHorzSlideBar1.Value / 10 * 0.5, nil);  // 0.0 ~  1.0

  RDAngularGauge1.Value := RDHorzSlideBar1.Value * 10 * 0.5;

end;

end.
