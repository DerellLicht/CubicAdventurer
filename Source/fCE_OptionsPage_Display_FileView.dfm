inherited CE_OptionsPage_Display_FileView: TCE_OptionsPage_Display_FileView
  object TabControl: TSpTBXTabControl
    Left = 0
    Top = 0
    Width = 441
    Height = 336
    Align = alClient
    ActiveTabIndex = 0
    HiddenItems = <>
    object tab_options: TSpTBXTabItem
      Caption = 'Options'
      Checked = True
    end
    object tab_display: TSpTBXTabItem
      Caption = 'Display'
    end
    object tab_colors: TSpTBXTabItem
      Caption = 'Colors'
    end
    object sheet_colors: TSpTBXTabSheet
      Left = 0
      Top = 25
      Width = 441
      Height = 311
      Caption = 'Colors'
      ImageIndex = -1
      TabItem = 'tab_colors'
      object label_hint: TLabel
        Left = 8
        Top = 272
        Width = 420
        Height = 13
        Caption = 'Use comma separated list of extensions. For example: txt,doc,rtf'
      end
      object label_exts: TLabel
        Left = 8
        Top = 182
        Width = 57
        Height = 13
        Caption = 'Extensions:'
      end
      object check_extcolors: TCheckBox
        Left = 8
        Top = 8
        Width = 270
        Height = 17
        Caption = 'Use extension colors'
        TabOrder = 0
        OnClick = HandleChange
      end
      object list_rules: TListBox
        Left = 8
        Top = 32
        Width = 270
        Height = 144
        ItemHeight = 13
        TabOrder = 1
        OnClick = HandleRuleSelect
      end
      object edit_exts: TEdit
        Left = 8
        Top = 198
        Width = 270
        Height = 21
        TabOrder = 2
        OnChange = HandleRuleChange
      end
      object but_add: TSpTBXButton
        Left = 8
        Top = 232
        Width = 100
        Height = 25
        Caption = 'Add'
        TabOrder = 3
        OnClick = HandleRuleAdd
      end
      object but_delete: TSpTBXButton
        Left = 178
        Top = 232
        Width = 100
        Height = 25
        Caption = 'Delete'
        TabOrder = 4
        OnClick = HandleRuleDelete
      end
      object check_bold: TCheckBox
        Left = 292
        Top = 32
        Width = 140
        Height = 17
        Caption = 'Bold'
        TabOrder = 5
        OnClick = HandleRuleChange
      end
      object check_italic: TCheckBox
        Left = 292
        Top = 55
        Width = 140
        Height = 17
        Caption = 'Italic'
        TabOrder = 6
        OnClick = HandleRuleChange
      end
      object check_underline: TCheckBox
        Left = 292
        Top = 78
        Width = 140
        Height = 17
        Caption = 'Underline'
        TabOrder = 7
        OnClick = HandleRuleChange
      end
      object combo_rulecolor: TColorBox
        Left = 292
        Top = 104
        Width = 135
        Height = 22
        DefaultColorColor = clDefault
        Style = [cbStandardColors, cbExtendedColors, cbSystemColors, cbIncludeDefault, cbCustomColor, cbPrettyNames]
        TabOrder = 8
        OnChange = HandleRuleChange
      end
    end
    object sheet_display: TSpTBXTabSheet
      Left = 0
      Top = 25
      Width = 441
      Height = 311
      Caption = 'Display'
      ImageIndex = -1
      TabItem = 'tab_display'
      object label_bgcolor: TLabel
        Left = 8
        Top = 176
        Width = 85
        Height = 13
        Caption = 'Background color:'
      end
      object label_sizeformat: TLabel
        Left = 215
        Top = 66
        Width = 76
        Height = 13
        Caption = 'File size format:'
      end
      object group_font: TGroupBox
        Left = 8
        Top = 8
        Width = 190
        Height = 160
        Caption = 'Font'
        TabOrder = 0
        object label_fontcolor: TLabel
          Left = 12
          Top = 112
          Width = 34
          Height = 13
          Caption = 'Color:'
        end
        object panel_preview: TPanel
          Left = 12
          Top = 20
          Width = 166
          Height = 56
          BevelOuter = bvLowered
          Caption = 'Preview'
          ParentBackground = False
          TabOrder = 0
        end
        object but_font: TSpTBXButton
          Left = 12
          Top = 82
          Width = 166
          Height = 25
          Caption = 'Font'
          TabOrder = 1
          OnClick = HandleFontButton
        end
        object combo_fontcolor: TColorBox
          Left = 12
          Top = 128
          Width = 166
          Height = 22
          Style = [cbStandardColors, cbExtendedColors, cbSystemColors, cbCustomColor, cbPrettyNames]
          TabOrder = 2
          OnChange = HandleColorChange
        end
      end
      object combo_bgcolor: TColorBox
        Left = 8
        Top = 192
        Width = 190
        Height = 22
        Style = [cbStandardColors, cbExtendedColors, cbSystemColors, cbCustomColor, cbPrettyNames]
        TabOrder = 1
        OnChange = HandleColorChange
      end
      object check_gridlines: TCheckBox
        Left = 215
        Top = 12
        Width = 215
        Height = 17
        Caption = 'Show gridlines'
        TabOrder = 2
        OnClick = HandleChange
      end
      object check_fullrowselect: TCheckBox
        Left = 215
        Top = 35
        Width = 215
        Height = 17
        Caption = 'Highlight row completely'
        TabOrder = 3
        OnClick = HandleChange
      end
      object combo_sizeformat: TComboBox
        Left = 215
        Top = 82
        Width = 145
        Height = 21
        Style = csDropDownList
        TabOrder = 4
        OnChange = HandleChange
      end
    end
    object sheet_options: TSpTBXTabSheet
      Left = 0
      Top = 25
      Width = 441
      Height = 311
      Caption = 'Options'
      ImageIndex = -1
      TabItem = 'tab_options'
      object check_selectprev: TCheckBox
        Left = 16
        Top = 12
        Width = 401
        Height = 17
        Caption = 'Select previous folder'
        TabOrder = 0
        OnClick = HandleChange
      end
      object check_autoselect: TCheckBox
        Left = 16
        Top = 35
        Width = 401
        Height = 17
        Caption = 'Select first item automatically'
        TabOrder = 1
        OnClick = HandleChange
      end
      object check_autosize_liststyle: TCheckBox
        Left = 16
        Top = 58
        Width = 401
        Height = 17
        Caption = 'Auto size cells in list view style.'
        TabOrder = 2
        OnClick = HandleChange
      end
      object check_sortfoldersfirst: TCheckBox
        Left = 16
        Top = 81
        Width = 401
        Height = 17
        Caption = 'Always sort folders first.'
        TabOrder = 3
        OnClick = HandleChange
      end
      object check_infotips: TCheckBox
        Left = 16
        Top = 104
        Width = 401
        Height = 17
        Caption = 'Show InfoTips'
        TabOrder = 4
        OnClick = HandleChange
      end
      object check_singleclick: TCheckBox
        Left = 16
        Top = 127
        Width = 401
        Height = 17
        Caption = 'Single click browsing'
        TabOrder = 5
        OnClick = HandleChange
      end
      object check_browsezip: TCheckBox
        Left = 16
        Top = 150
        Width = 401
        Height = 17
        Caption = 'Browse Zip Files'
        TabOrder = 6
        OnClick = HandleChange
      end
    end
  end
  object font_dialog: TFontDialog
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    Left = 392
    Top = 296
  end
end
