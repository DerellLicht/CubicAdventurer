inherited CE_OptionsPage_Display_FolderTree: TCE_OptionsPage_Display_FolderTree
  object check_autocollapse: TCheckBox
    Left = 16
    Top = 39
    Width = 401
    Height = 17
    Caption = 'Auto collapse tree'
    TabOrder = 0
    OnClick = HandleChange
  end
  object check_autoexpand: TCheckBox
    Left = 16
    Top = 16
    Width = 401
    Height = 17
    Caption = 'Auto expand tree'
    TabOrder = 1
    OnClick = HandleChange
  end
  object check_newtabdefault: TCheckBox
    Left = 16
    Top = 62
    Width = 401
    Height = 17
    Caption = 'Open in new tab by default'
    TabOrder = 2
    OnClick = HandleChange
  end
  object check_browse_zip: TCheckBox
    Left = 16
    Top = 85
    Width = 401
    Height = 17
    Caption = 'Show Zip files'
    TabOrder = 3
    OnClick = HandleChange
  end
end
