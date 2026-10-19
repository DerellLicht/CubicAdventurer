inherited CEOptionsPage_General: TCEOptionsPage_General
  object check_singleinstance: TCheckBox
    Left = 16
    Top = 296
    Width = 401
    Height = 17
    Caption = 'Single Instance Only'
    TabOrder = 0
    OnClick = HandleChange
  end
  object group_startup: TGroupBox
    Left = 16
    Top = 12
    Width = 241
    Height = 129
    Caption = 'On Startup'
    TabOrder = 1
    DesignSize = (
      241
      129)
    object radio_default: TRadioButton
      Left = 11
      Top = 24
      Width = 227
      Height = 17
      Anchors = [akLeft, akTop, akRight]
      Caption = 'Open default tab'
      TabOrder = 0
      OnClick = radioClick
    end
    object radio_lasttime: TRadioButton
      Left = 11
      Top = 47
      Width = 227
      Height = 17
      Anchors = [akLeft, akTop, akRight]
      Caption = 'Continue from last time'
      TabOrder = 1
      OnClick = radioClick
    end
    object radio_session: TRadioButton
      Left = 11
      Top = 70
      Width = 227
      Height = 17
      Anchors = [akLeft, akTop, akRight]
      Caption = 'Load session'
      TabOrder = 2
      OnClick = radioClick
    end
    object combo_sessions: TComboBox
      Left = 27
      Top = 93
      Width = 162
      Height = 21
      Style = csDropDownList
      ItemHeight = 13
      TabOrder = 3
      OnChange = HandleChange
    end
  end
  object TntGroupBox1: TGroupBox
    Left = 16
    Top = 152
    Width = 409
    Height = 121
    Caption = 'Tray Icon'
    TabOrder = 2
    DesignSize = (
      409
      121)
    object check_tray_enable: TCheckBox
      Left = 11
      Top = 22
      Width = 395
      Height = 17
      Anchors = [akLeft, akTop, akRight]
      Caption = 'Show'
      TabOrder = 0
      OnClick = HandleChange
    end
    object check_tray_minimize: TCheckBox
      Left = 27
      Top = 45
      Width = 379
      Height = 17
      Anchors = [akLeft, akTop, akRight]
      Caption = 'Minimize to tray'
      TabOrder = 1
      OnClick = HandleChange
    end
    object check_tray_close: TCheckBox
      Left = 27
      Top = 68
      Width = 379
      Height = 17
      Anchors = [akLeft, akTop, akRight]
      Caption = 'Close to tray'
      TabOrder = 2
      OnClick = HandleChange
    end
    object check_tray_start: TCheckBox
      Left = 27
      Top = 91
      Width = 379
      Height = 17
      Anchors = [akLeft, akTop, akRight]
      Caption = 'Start minimized to tray'
      TabOrder = 3
      OnClick = HandleChange
    end
  end
  object TntGroupBox2: TGroupBox
    Left = 272
    Top = 12
    Width = 153
    Height = 129
    Caption = 'Default File Manager'
    TabOrder = 3
    DesignSize = (
      153
      129)
    object but_register: TSpTBXButton
      Left = 16
      Top = 24
      Width = 121
      Height = 33
      Caption = 'Register'
      Anchors = [akLeft, akTop, akRight]
      TabOrder = 0
      OnClick = but_registerClick
      Images = CE_Images.MiscImages
      ImageIndex = 6
      SkinType = sknWindows
    end
    object but_unregister: TSpTBXButton
      Left = 16
      Top = 71
      Width = 121
      Height = 34
      Caption = 'Unregister'
      Anchors = [akLeft, akTop, akRight]
      TabOrder = 1
      OnClick = but_unregisterClick
      Images = CE_Images.MiscImages
      ImageIndex = 6
      SkinType = sknWindows
    end
  end
end
