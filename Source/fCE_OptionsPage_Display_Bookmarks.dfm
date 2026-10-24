inherited CE_OptionsPage_Display_Bookmarks: TCE_OptionsPage_Display_Bookmarks
  object check_autoexpand: TCheckBox
    Left = 16
    Top = 16
    Width = 409
    Height = 17
    Caption = 'Auto expand tree'
    TabOrder = 0
    OnClick = HandleChange
  end
  object check_autocollapse: TCheckBox
    Left = 16
    Top = 39
    Width = 409
    Height = 17
    Caption = 'Auto collapse tree'
    TabOrder = 1
    OnClick = HandleChange
  end
end
