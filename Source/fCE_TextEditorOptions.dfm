object CETextEditorOptionsForm: TCETextEditorOptionsForm
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'Editor Options'
  ClientHeight = 426
  ClientWidth = 401
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PopupMode = pmExplicit
  Position = poMainFormCenter
  OnClose = FormClose
  OnCreate = TntFormCreate
  DesignSize = (
    401
    426)
  PixelsPerInch = 96
  TextHeight = 13
  object PageControl: TPageControl
    Left = 8
    Top = 8
    Width = 385
    Height = 379
    ActivePage = sheet_options
    Anchors = [akLeft, akTop, akRight, akBottom]
    TabOrder = 0
    object sheet_display: TTabSheet
      Caption = 'Display'
      object TntLabel9: TLabel
        Left = 197
        Top = 287
        Width = 88
        Height = 13
        Caption = 'Background Color:'
      end
      object group_right_edge: TSpTBXGroupBox
        Left = 16
        Top = 15
        Width = 159
        Height = 122
        Caption = 'Right Edge'
        TabOrder = 0
        DesignSize = (
          159
          122)
        object TntLabel2: TLabel
          Left = 16
          Top = 24
          Width = 66
          Height = 13
          Caption = 'Edge Column:'
        end
        object TntLabel3: TLabel
          Left = 16
          Top = 70
          Width = 29
          Height = 13
          Caption = 'Color:'
        end
        object edit_right_edge: TEdit
          Left = 24
          Top = 43
          Width = 50
          Height = 21
          TabOrder = 0
        end
        object color_right_edge: TColorBox
          Left = 24
          Top = 89
          Width = 119
          Height = 22
          NoneColorColor = clNone
          Style = [cbStandardColors, cbExtendedColors, cbSystemColors, cbIncludeNone, cbIncludeDefault, cbCustomColor, cbPrettyNames]
          Anchors = [akLeft, akTop, akRight]
          ItemHeight = 16
          TabOrder = 1
        end
      end
      object group_spacing: TSpTBXGroupBox
        Left = 197
        Top = 15
        Width = 161
        Height = 122
        Caption = 'Spacing'
        TabOrder = 1
        object TntLabel4: TLabel
          Left = 16
          Top = 24
          Width = 57
          Height = 13
          Caption = 'Extra Lines:'
        end
        object TntLabel5: TLabel
          Left = 16
          Top = 70
          Width = 53
          Height = 13
          Caption = 'Tab Width:'
        end
        object edit_extra_lines: TEdit
          Left = 24
          Top = 43
          Width = 50
          Height = 21
          TabOrder = 0
        end
        object edit_tab_width: TEdit
          Left = 24
          Top = 89
          Width = 50
          Height = 21
          TabOrder = 1
        end
      end
      object TntGroupBox1: TSpTBXGroupBox
        Left = 16
        Top = 151
        Width = 159
        Height = 178
        Caption = 'Font'
        TabOrder = 2
        DesignSize = (
          159
          178)
        object TntLabel14: TLabel
          Left = 16
          Top = 118
          Width = 29
          Height = 13
          Caption = 'Color:'
        end
        object but_font: TButton
          Left = 16
          Top = 87
          Width = 127
          Height = 25
          Anchors = [akLeft, akTop, akRight]
          Caption = 'Font'
          TabOrder = 0
          WordWrap = True
          OnClick = but_fontClick
        end
        object color_font: TColorBox
          Left = 24
          Top = 137
          Width = 119
          Height = 22
          DefaultColorColor = clWindowText
          NoneColorColor = clNone
          Style = [cbStandardColors, cbExtendedColors, cbSystemColors, cbCustomColor, cbPrettyNames]
          Anchors = [akLeft, akTop, akRight]
          ItemHeight = 16
          TabOrder = 1
          OnChange = color_fontChange
        end
        object panel_font: TPanel
          Left = 8
          Top = 24
          Width = 143
          Height = 49
          Anchors = [akLeft, akTop, akRight]
          BevelOuter = bvNone
          Color = clWindow
          ParentBackground = False
          TabOrder = 2
        end
      end
      object group_caret: TSpTBXGroupBox
        Left = 197
        Top = 151
        Width = 161
        Height = 122
        Caption = 'Caret'
        TabOrder = 3
        DesignSize = (
          161
          122)
        object TntLabel7: TLabel
          Left = 16
          Top = 24
          Width = 63
          Height = 13
          Caption = 'Insert Caret:'
        end
        object TntLabel8: TLabel
          Left = 16
          Top = 72
          Width = 76
          Height = 13
          Caption = 'Override Caret:'
        end
        object combo_insert_caret: TComboBox
          Left = 24
          Top = 43
          Width = 121
          Height = 21
          Anchors = [akLeft, akTop, akRight]
          ItemHeight = 13
          TabOrder = 0
          Text = 'Vertical Line'
          Items.Strings = (
            'Vertical Line'
            'Horizontal Line'
            'Half Block'
            'Block')
        end
        object combo_override_caret: TComboBox
          Left = 24
          Top = 91
          Width = 121
          Height = 21
          Anchors = [akLeft, akTop, akRight]
          ItemHeight = 13
          ItemIndex = 3
          TabOrder = 1
          Text = 'Block'
          Items.Strings = (
            'Vertical Line'
            'Horizontal Line'
            'Half Block'
            'Block')
        end
      end
      object color_background: TColorBox
        Left = 205
        Top = 306
        Width = 151
        Height = 22
        DefaultColorColor = clWindow
        NoneColorColor = clNone
        Style = [cbStandardColors, cbExtendedColors, cbSystemColors, cbCustomColor, cbPrettyNames]
        ItemHeight = 16
        TabOrder = 4
        OnChange = color_fontChange
      end
    end
    object sheet_gutter: TTabSheet
      Caption = 'Gutter'
      DesignSize = (
        377
        351)
      object TntLabel1: TLabel
        Left = 16
        Top = 295
        Width = 88
        Height = 13
        Caption = 'Background Color:'
      end
      object check_gutter_visible: TCheckBox
        Left = 16
        Top = 16
        Width = 175
        Height = 17
        Anchors = [akLeft, akTop, akRight]
        Caption = 'Visible'
        TabOrder = 0
      end
      object check_gutter_line_numbers: TCheckBox
        Left = 16
        Top = 39
        Width = 175
        Height = 17
        Anchors = [akLeft, akTop, akRight]
        Caption = 'Show line numbers'
        TabOrder = 1
      end
      object check_gutter_start_at_zero: TCheckBox
        Left = 16
        Top = 62
        Width = 175
        Height = 17
        Anchors = [akLeft, akTop, akRight]
        Caption = 'Start at zero'
        TabOrder = 2
      end
      object check_gutter_show_leading_zeros: TCheckBox
        Left = 16
        Top = 85
        Width = 175
        Height = 17
        Anchors = [akLeft, akTop, akRight]
        Caption = 'Show leading zeros'
        TabOrder = 3
      end
      object color_gutter: TColorBox
        Left = 24
        Top = 314
        Width = 151
        Height = 22
        NoneColorColor = clNone
        Style = [cbStandardColors, cbExtendedColors, cbSystemColors, cbIncludeNone, cbIncludeDefault, cbCustomColor, cbPrettyNames]
        ItemHeight = 16
        TabOrder = 4
        OnChange = color_gutter_fontChange
      end
      object group_gutter_font: TSpTBXGroupBox
        Left = 16
        Top = 112
        Width = 159
        Height = 177
        Caption = 'Font'
        TabOrder = 5
        DesignSize = (
          159
          177)
        object TntLabel15: TLabel
          Left = 16
          Top = 124
          Width = 29
          Height = 13
          Caption = 'Color:'
        end
        object check_gutter_font: TCheckBox
          Left = 8
          Top = 23
          Width = 143
          Height = 17
          Anchors = [akLeft, akTop, akRight]
          Caption = 'Use custom font'
          TabOrder = 0
        end
        object but_gutter_font: TButton
          Left = 16
          Top = 93
          Width = 127
          Height = 25
          Anchors = [akLeft, akRight, akBottom]
          Caption = 'Font'
          TabOrder = 1
          OnClick = but_gutter_fontClick
        end
        object color_gutter_font: TColorBox
          Left = 24
          Top = 143
          Width = 119
          Height = 22
          NoneColorColor = clNone
          Style = [cbStandardColors, cbExtendedColors, cbSystemColors, cbIncludeNone, cbIncludeDefault, cbCustomColor, cbPrettyNames]
          ItemHeight = 16
          TabOrder = 2
          OnChange = color_gutter_fontChange
        end
        object panel_gutter_font: TPanel
          Left = 8
          Top = 46
          Width = 143
          Height = 41
          Anchors = [akLeft, akTop, akRight]
          BevelOuter = bvNone
          Color = clWindow
          ParentBackground = False
          TabOrder = 3
        end
      end
      object group_gutter_gradient: TSpTBXGroupBox
        Left = 197
        Top = 143
        Width = 163
        Height = 193
        Caption = 'Gradient'
        TabOrder = 6
        DesignSize = (
          163
          193)
        object TntLabel10: TLabel
          Left = 11
          Top = 93
          Width = 50
          Height = 13
          Caption = 'End Color:'
        end
        object TntLabel6: TLabel
          Left = 11
          Top = 46
          Width = 56
          Height = 13
          Caption = 'Start Color:'
        end
        object TntLabel11: TLabel
          Left = 11
          Top = 140
          Width = 27
          Height = 13
          Caption = 'Steps'
        end
        object color_gutter_gradient_end_color: TColorBox
          Left = 16
          Top = 112
          Width = 129
          Height = 22
          NoneColorColor = clNone
          Style = [cbStandardColors, cbExtendedColors, cbSystemColors, cbIncludeNone, cbIncludeDefault, cbCustomColor, cbPrettyNames]
          ItemHeight = 16
          TabOrder = 0
        end
        object color_gutter_gradient_start_color: TColorBox
          Left = 16
          Top = 65
          Width = 129
          Height = 22
          NoneColorColor = clNone
          Style = [cbStandardColors, cbExtendedColors, cbSystemColors, cbIncludeNone, cbIncludeDefault, cbCustomColor, cbPrettyNames]
          ItemHeight = 16
          TabOrder = 1
        end
        object check_gutter_gradient: TCheckBox
          Left = 11
          Top = 23
          Width = 149
          Height = 17
          Anchors = [akLeft, akTop, akRight]
          Caption = 'Gradient'
          TabOrder = 2
        end
        object edit_gutter_gradient_steps: TEdit
          Left = 16
          Top = 159
          Width = 50
          Height = 21
          TabOrder = 3
        end
      end
      object group_border: TSpTBXGroupBox
        Left = 197
        Top = 9
        Width = 163
        Height = 128
        Caption = 'Border'
        TabOrder = 7
        DesignSize = (
          163
          128)
        object TntLabel12: TLabel
          Left = 11
          Top = 24
          Width = 29
          Height = 13
          Caption = 'Color:'
        end
        object TntLabel13: TLabel
          Left = 11
          Top = 71
          Width = 63
          Height = 13
          Caption = 'Border Style:'
        end
        object color_gutter_border_color: TColorBox
          Left = 16
          Top = 43
          Width = 129
          Height = 22
          NoneColorColor = clNone
          Style = [cbStandardColors, cbExtendedColors, cbSystemColors, cbIncludeNone, cbIncludeDefault, cbCustomColor, cbPrettyNames]
          ItemHeight = 16
          TabOrder = 0
        end
        object combo_gutter_border_style: TComboBox
          Left = 19
          Top = 90
          Width = 121
          Height = 21
          Anchors = [akLeft, akTop, akRight]
          ItemHeight = 13
          TabOrder = 1
          Text = 'Middle'
          Items.Strings = (
            'None'
            'Middle'
            'Right')
        end
      end
    end
    object sheet_options: TTabSheet
      Caption = 'Options'
      DesignSize = (
        377
        351)
      object check_auto_indent: TCheckBox
        Left = 16
        Top = 16
        Width = 358
        Height = 17
        Anchors = [akLeft, akTop, akRight]
        Caption = 'Auto indent'
        TabOrder = 0
      end
      object check_enhance_home_key: TCheckBox
        Left = 16
        Top = 35
        Width = 358
        Height = 17
        Anchors = [akLeft, akTop, akRight]
        Caption = 'Enhance Home Key'
        TabOrder = 1
      end
      object check_enhance_end_key: TCheckBox
        Left = 16
        Top = 54
        Width = 358
        Height = 17
        Anchors = [akLeft, akTop, akRight]
        Caption = 'Enhance End Key'
        TabOrder = 2
      end
      object check_group_undo: TCheckBox
        Left = 16
        Top = 73
        Width = 358
        Height = 17
        Anchors = [akLeft, akTop, akRight]
        Caption = 'Group undo'
        TabOrder = 3
      end
      object check_half_page_scroll: TCheckBox
        Left = 16
        Top = 92
        Width = 358
        Height = 17
        Anchors = [akLeft, akTop, akRight]
        Caption = 'Half page scroll'
        TabOrder = 4
      end
      object check_right_mouse_moves_cursor: TCheckBox
        Left = 16
        Top = 111
        Width = 358
        Height = 17
        Anchors = [akLeft, akTop, akRight]
        Caption = 'Right mouse moves cursor'
        TabOrder = 5
      end
      object check_scroll_past_eol: TCheckBox
        Left = 16
        Top = 130
        Width = 358
        Height = 17
        Anchors = [akLeft, akTop, akRight]
        Caption = 'Scroll past end of line'
        TabOrder = 6
      end
      object check_scroll_past_eof: TCheckBox
        Left = 16
        Top = 149
        Width = 358
        Height = 17
        Anchors = [akLeft, akTop, akRight]
        Caption = 'Scroll past end of file'
        TabOrder = 7
      end
      object check_show_scroll_hint: TCheckBox
        Left = 16
        Top = 168
        Width = 358
        Height = 17
        Anchors = [akLeft, akTop, akRight]
        Caption = 'Show scroll hint'
        TabOrder = 8
      end
      object check_show_special_chars: TCheckBox
        Left = 16
        Top = 187
        Width = 358
        Height = 17
        Anchors = [akLeft, akTop, akRight]
        Caption = 'Show special characters'
        TabOrder = 9
      end
      object check_smart_tabs: TCheckBox
        Left = 16
        Top = 206
        Width = 358
        Height = 17
        Anchors = [akLeft, akTop, akRight]
        Caption = 'Smart tabs'
        TabOrder = 10
      end
      object check_smart_tab_delete: TCheckBox
        Left = 16
        Top = 225
        Width = 358
        Height = 17
        Anchors = [akLeft, akTop, akRight]
        Caption = 'Smart tab delete'
        TabOrder = 11
      end
      object check_tab_indent: TCheckBox
        Left = 16
        Top = 244
        Width = 358
        Height = 17
        Anchors = [akLeft, akTop, akRight]
        Caption = 'Tab indent'
        TabOrder = 12
      end
      object check_tabs_to_spaces: TCheckBox
        Left = 16
        Top = 263
        Width = 358
        Height = 17
        Anchors = [akLeft, akTop, akRight]
        Caption = 'Tabs to spaces'
        TabOrder = 13
      end
      object check_trim_trailing_spaces: TCheckBox
        Left = 16
        Top = 282
        Width = 358
        Height = 17
        Anchors = [akLeft, akTop, akRight]
        Caption = 'Trim trailing spaces'
        TabOrder = 14
      end
      object check_ctrl_activates_links: TCheckBox
        Left = 16
        Top = 301
        Width = 358
        Height = 17
        Anchors = [akLeft, akTop, akRight]
        Caption = 'Ctrl activates links'
        TabOrder = 15
      end
      object check_multi_highlighter_background: TCheckBox
        Left = 16
        Top = 320
        Width = 358
        Height = 17
        Anchors = [akLeft, akTop, akRight]
        Caption = 'Colorize multi highlighter sections'
        TabOrder = 16
      end
    end
    object sheet_export: TTabSheet
      Caption = 'Export'
      DesignSize = (
        377
        351)
      object TntLabel16: TLabel
        Left = 16
        Top = 80
        Width = 86
        Height = 13
        Caption = 'DIV wrapper class'
      end
      object check_inline_css_on_copy: TCheckBox
        Left = 16
        Top = 133
        Width = 358
        Height = 17
        Anchors = [akLeft, akTop, akRight]
        Caption = 'Use inline CSS on copy'
        TabOrder = 0
      end
      object check_inline_css_on_export: TCheckBox
        Left = 16
        Top = 156
        Width = 358
        Height = 17
        Anchors = [akLeft, akTop, akRight]
        Caption = 'Use inline CSS on export'
        TabOrder = 1
      end
      object check_export_use_background: TCheckBox
        Left = 16
        Top = 15
        Width = 358
        Height = 17
        Anchors = [akLeft, akTop, akRight]
        Caption = 'Background Color:'
        TabOrder = 2
      end
      object edit_export_wrapper_class: TEdit
        Left = 24
        Top = 99
        Width = 145
        Height = 21
        TabOrder = 3
      end
      object color_export_background_color: TColorBox
        Left = 24
        Top = 38
        Width = 151
        Height = 22
        NoneColorColor = clNone
        Style = [cbStandardColors, cbExtendedColors, cbSystemColors, cbIncludeNone, cbIncludeDefault, cbCustomColor, cbPrettyNames]
        ItemHeight = 16
        TabOrder = 4
        OnChange = color_gutter_fontChange
      end
      object check_export_tabs_to_spaces: TCheckBox
        Left = 16
        Top = 179
        Width = 358
        Height = 17
        Anchors = [akLeft, akTop, akRight]
        Caption = 'Convert Tabs to Spaces'
        TabOrder = 5
      end
    end
  end
  object but_apply: TButton
    Left = 318
    Top = 393
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'Apply'
    TabOrder = 1
    OnClick = but_applyClick
  end
  object but_cancel: TButton
    Left = 237
    Top = 393
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 2
  end
  object but_ok: TButton
    Left = 156
    Top = 393
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'OK'
    ModalResult = 1
    TabOrder = 3
    OnClick = but_applyClick
  end
  object FontDlg: TFontDialog
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    Options = [fdEffects, fdApplyButton]
    OnApply = FontDlgApply
    Left = 8
    Top = 400
  end
end
