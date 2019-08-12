object BeaconServiceDM: TBeaconServiceDM
  OldCreateOrder = False
  OnStartCommand = AndroidServiceStartCommand
  Height = 238
  Width = 324
  object Beacon1: TBeacon
    MonitorizedRegions = <
      item
        UUID = '{E2C56DB5-DFFB-48D2-B060-D0F5A71096E0}'
      end>
    BeaconDeathTime = 5
    SPC = 0.500000000000000000
    OnBeaconProximity = Beacon1BeaconProximity
    Left = 88
    Top = 40
  end
  object NotificationCenter1: TNotificationCenter
    Left = 168
    Top = 40
  end
end
