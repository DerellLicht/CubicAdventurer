inherited CEOptionsPage_Display: TCEOptionsPage_Display
  Width = 521
  Constraints.MaxWidth = 0
  object TntLabel1: TLabel
    Left = 16
    Top = 16
    Width = 32
    Height = 13
    Caption = 'Theme'
  end
  object combo_theme: TComboBox
    Left = 16
    Top = 35
    Width = 145
    Height = 21
    ItemHeight = 13
    TabOrder = 0
    OnChange = combo_themeChange
  end
  object check_path_in_title: TCheckBox
    Left = 16
    Top = 71
    Width = 153
    Height = 17
    Caption = 'Show Path in Title bar'
    TabOrder = 1
    OnClick = HandleChange
  end
  object TntButton1: TButton
    Left = 16
    Top = 288
    Width = 145
    Height = 33
    Action = CEActions.act_help_restore_layout
    TabOrder = 2
  end
  object image_preview: TImage
    Left = 176
    Top = 3
    Width = 335
    Height = 330
    Center = True
  end
end
