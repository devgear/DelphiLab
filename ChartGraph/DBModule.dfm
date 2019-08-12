object DModule: TDModule
  OldCreateOrder = False
  Height = 291
  Width = 323
  object FDQueryI: TFDQuery
    Connection = FDCon
    Left = 210
    Top = 89
  end
  object FDGUIxWaitCursor1: TFDGUIxWaitCursor
    Provider = 'FMX'
    Left = 208
    Top = 176
  end
  object FDCon: TFDConnection
    Params.Strings = (
      'DriverID=SQLite')
    LoginPrompt = False
    BeforeConnect = FDConBeforeConnect
    Left = 104
    Top = 89
  end
end
