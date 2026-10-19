inherited CE_OptionsPage_Display_Stack: TCE_OptionsPage_Display_Stack
  object check_autoexpand: TCheckBox
    Left = 16
    Top = 152
    Width = 401
    Height = 17
    Caption = 'Auto expand tree'
    TabOrder = 0
    OnClick = HandleChange
  end
  object check_autocollapse: TCheckBox
    Left = 16
    Top = 175
    Width = 401
    Height = 17
    Caption = 'Auto collapse tree'
    TabOrder = 1
    OnClick = HandleChange
  end
  object check_fullexpand: TCheckBox
    Left = 16
    Top = 198
    Width = 401
    Height = 17
    Caption = 'Full expand on stack load'
    TabOrder = 2
    OnClick = HandleChange
  end
  object group_startup: TGroupBox
    Left = 16
    Top = 12
    Width = 409
    Height = 129
    Caption = 'On Startup'
    TabOrder = 3
    object radio_empty: TRadioButton
      Left = 11
      Top = 24
      Width = 386
      Height = 17
      Caption = 'Empty Stack'
      TabOrder = 0
      OnClick = radioClick
    end
    object radio_lastused: TRadioButton
      Tag = 1
      Left = 11
      Top = 47
      Width = 386
      Height = 17
      Caption = 'Open last used'
      TabOrder = 1
      OnClick = radioClick
    end
    object radio_selected: TRadioButton
      Tag = 2
      Left = 11
      Top = 70
      Width = 386
      Height = 17
      Caption = 'Open selected'
      TabOrder = 2
      OnClick = radioClick
    end
    object combo_stacks: TComboBox
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
end
