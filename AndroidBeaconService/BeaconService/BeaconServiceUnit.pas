unit BeaconServiceUnit;

interface

uses
  System.SysUtils,
  System.Classes,
  System.Android.Service,
  AndroidApi.JNI.GraphicsContentViewText,
  Androidapi.JNI.Os, System.Beacon, System.Notification, System.Beacon.Components;


type
  TBeaconServiceDM = class(TAndroidService)
    Beacon1: TBeacon;
    NotificationCenter1: TNotificationCenter;
    procedure Beacon1BeaconProximity(const Sender: TObject; const ABeacon: IBeacon; Proximity: TBeaconProximity);
    function AndroidServiceStartCommand(const Sender: TObject; const Intent: JIntent; Flags, StartId: Integer): Integer;
  private
    { Private declarations }
    procedure NotifyBeaconProximity(const BeaconName: string);
    function Get_MyDevice_PhoneNumber: string;
  public
    { Public declarations }
  end;

var
  BeaconServiceDM: TBeaconServiceDM;

implementation

{%CLASSGROUP 'FMX.Controls.TControl'}

{$R *.dfm}

uses
  Androidapi.JNI.App,
  Androidapi.Helpers, Androidapi.JNI.JavaTypes, Androidapi.JNI.Telephony, Androidapi.JNIBridge; // for Tell No

function TBeaconServiceDM.AndroidServiceStartCommand(const Sender: TObject; const Intent: JIntent; Flags,
  StartId: Integer): Integer;
begin
  Beacon1.Enabled := True;

  Result := TJService.JavaClass.START_STICKY;
end;

procedure TBeaconServiceDM.Beacon1BeaconProximity(const Sender: TObject; const ABeacon: IBeacon; Proximity: TBeaconProximity);
begin
  if Proximity = TBeaconProximity.Immediate then
  begin
     NotifyBeaconProximity(ABeacon.GUID.ToString + ':' + ABeacon.Major.ToString + ',' + ABeacon.Minor.ToString);
  end;
end;


procedure TBeaconServiceDM.NotifyBeaconProximity(const BeaconName: string);
var
  MyNotification: TNotification;
begin
  MyNotification := NotificationCenter1.CreateNotification;
  try
    MyNotification.Name := 'BeaconProximityNotification';
//  MyNotification.AlertBody := 'Proximity: '+  BeaconName;
    MyNotification.AlertBody := '접근: '+ Get_MyDevice_PhoneNumber() + FormatDateTime( ' hh:mm:ss ', now );
    NotificationCenter1.PresentNotification(MyNotification);
  finally
    MyNotification.Free;
  end;
end;

//*********************************************************************
function TBeaconServiceDM.Get_MyDevice_PhoneNumber() : string;
var
  Service: JObject;             // Androidapi.JNI.JavaTypes
  Manager: JTelephonyManager;   // Androidapi.JNI.Telephony
  getNo : string;
begin
//  Service := SharedActivityContext.getSystemService( TJContext.JavaClass.TELEPHONY_SERVICE);
  Service := TAndroidHelper.Context.getSystemService( TJContext.JavaClass.TELEPHONY_SERVICE);

  if  Assigned(Service) then // if Service <> nil then
  begin
    Manager := TJTelephonyManager.Wrap((Service as ILocalObject).GetObjectID);   // Androidapi.JNIBridge
    getNo := JStringToString(Manager.getLine1Number);  // 전화번호
//  getDNo := JStringToString(Manager.getDeviceId);

    if Copy( getNo, 1, 3 ) = '+82' then
       getNo := '0'+ Copy( getNo, 4, length(getNo)-3 );    //  getNo := '+821011112222';

    result := getNo;
  end;
end;


end.
