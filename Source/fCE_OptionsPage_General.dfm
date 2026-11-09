inherited CEOptionsPage_General: TCEOptionsPage_General
  object group_startup: TSpTBXGroupBox
    Left = 16
    Top = 12
    Width = 201
    Height = 129
    Caption = 'On Startup'
    TabOrder = 1
    DesignSize = (
      201
      129)
    object radio_default: TRadioButton
      Left = 11
      Top = 24
      Width = 187
      Height = 17
      Anchors = [akLeft, akTop, akRight]
      Caption = 'Open default tab'
      TabOrder = 0
      OnClick = radioClick
    end
    object radio_lasttime: TRadioButton
      Left = 11
      Top = 47
      Width = 187
      Height = 17
      Anchors = [akLeft, akTop, akRight]
      Caption = 'Continue from last time'
      TabOrder = 1
      OnClick = radioClick
    end
    object radio_session: TRadioButton
      Left = 11
      Top = 70
      Width = 187
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
  object TntGroupBox1: TSpTBXGroupBox
    Left = 16
    Top = 152
    Width = 201
    Height = 121
    Caption = 'Tray Icon'
    TabOrder = 2
    DesignSize = (
      201
      121)
    object check_tray_enable: TCheckBox
      Left = 11
      Top = 22
      Width = 187
      Height = 17
      Anchors = [akLeft, akTop, akRight]
      Caption = 'Show'
      TabOrder = 0
      OnClick = HandleChange
    end
    object check_tray_minimize: TCheckBox
      Left = 27
      Top = 45
      Width = 171
      Height = 17
      Anchors = [akLeft, akTop, akRight]
      Caption = 'Minimize to tray'
      TabOrder = 1
      OnClick = HandleChange
    end
    object check_tray_close: TCheckBox
      Left = 27
      Top = 68
      Width = 171
      Height = 17
      Anchors = [akLeft, akTop, akRight]
      Caption = 'Close to tray'
      TabOrder = 2
      OnClick = HandleChange
    end
    object check_tray_start: TCheckBox
      Left = 27
      Top = 91
      Width = 171
      Height = 17
      Anchors = [akLeft, akTop, akRight]
      Caption = 'Start minimized to tray'
      TabOrder = 3
      OnClick = HandleChange
    end
  end
  object group_dfm: TSpTBXGroupBox
    Left = 233
    Top = 12
    Width = 192
    Height = 129
    Caption = 'Default File Manager'
    TabOrder = 5
    Visible = False
    object but_dfm_register: TButton
      Left = 16
      Top = 30
      Width = 160
      Height = 25
      Caption = 'Register'
      TabOrder = 0
      OnClick = but_dfm_registerClick
    end
    object but_dfm_unregister: TButton
      Left = 16
      Top = 70
      Width = 160
      Height = 25
      Caption = 'Unregister'
      TabOrder = 1
      OnClick = but_dfm_unregisterClick
    end
  end
  object check_dfm: TCheckBox
    Left = 233
    Top = 152
    Width = 192
    Height = 17
    Caption = 'Show Default File Manager'
    TabOrder = 4
    OnClick = check_dfmClick
  end
  object label_dfm_warning: TSpTBXLabel
    Left = 233
    Top = 175
    Width = 192
    Height = 121
    AutoSize = False
    Caption = 
      'Experimental. Register makes CubicAdventurer the program Windows ' +
      'opens folders with. Only your own Windows account is changed. ' +
      'Unregister, or uninstalling the program, restores the old setting. ' +
      'See the warnings about registry changes in the Tips and Tricks guide.'
    Wrapping = twWrap
  end
  object check_single: TCheckBox
    Left = 16
    Top = 303
    Width = 409
    Height = 17
    Caption = 'Single Instance Only'
    TabOrder = 3
    OnClick = HandleChange
  end
end
