inherited TCEOptionsPage_Hotkeys: TTCEOptionsPage_Hotkeys
  Width = 521
  Constraints.MaxWidth = 521
  Constraints.MinWidth = 521
  object TntBevel1: TBevel
    Left = 321
    Top = 12
    Width = 192
    Height = 25
    Shape = bsBottomLine
  end
  object TntLabel1: TLabel
    Left = 329
    Top = 48
    Width = 39
    Height = 13
    Caption = 'Hotkeys'
  end
  object HotkeyList: TVirtualStringTree
    Left = 8
    Top = 12
    Width = 301
    Height = 313
    Align = alCustom
    DragType = dtVCL
    Header.AutoSizeIndex = 0
    Header.DefaultHeight = 17
    Header.Font.Charset = DEFAULT_CHARSET
    Header.Font.Color = clWindowText
    Header.Font.Height = -11
    Header.Font.Name = 'Tahoma'
    Header.Font.Style = []
    Header.MaxHeight = 100
    Header.Options = [hoAutoResize, hoColumnResize, hoDrag, hoShowHint]
    ParentShowHint = False
    ShowHint = False
    TabOrder = 0
    TreeOptions.AutoOptions = [toAutoScrollOnExpand, toAutoTristateTracking, toAutoDeleteMovedNodes]
    TreeOptions.MiscOptions = [toFullRepaintOnResize, toInitOnSave, toToggleOnDblClick, toWheelPanning]
    TreeOptions.PaintOptions = [toHideFocusRect, toShowButtons, toThemeAware, toUseBlendedImages]
    TreeOptions.SelectionOptions = [toFullRowSelect]
    OnFocusChanged = HotkeyListFocusChanged
    OnGetText = HotkeyListGetText
    OnPaintText = HotkeyListPaintText
    OnKeyDown = HotkeyListKeyDown
    Columns = <
      item
        Position = 0
        Width = 170
        WideText = 'Name'
      end
      item
        Alignment = taRightJustify
        Position = 1
        Width = 110
        WideText = 'Shortcut'
      end>
  end
  object label_action_name: TSpTBXLabel
    Left = 321
    Top = 12
    Width = 192
    Height = 25
    AutoSize = False
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    Wrapping = twEndEllipsis
    Images = CE_Images.SmallIcons
  end
  object list_actionhotkeys: TListBox
    Left = 329
    Top = 63
    Width = 176
    Height = 76
    DragMode = dmAutomatic
    ItemHeight = 13
    TabOrder = 2
    OnClick = list_actionhotkeysClick
    OnDragDrop = list_actionhotkeysDragDrop
    OnDragOver = list_actionhotkeysDragOver
    OnMouseDown = list_actionhotkeysMouseDown
  end
  object label_status: TLabel
    Left = 329
    Top = 143
    Width = 176
    Height = 30
    AutoSize = False
    WordWrap = True
  end
  object TntGroupBox1: TSpTBXGroupBox
    Left = 329
    Top = 179
    Width = 176
    Height = 146
    Caption = 'Modify Hotkey'
    TabOrder = 3
    object edit_hotkey: TEdit
      Left = 12
      Top = 21
      Width = 153
      Height = 21
      AutoSelect = False
      TabOrder = 0
      OnKeyDown = edit_hotkeyKeyDown
      OnKeyPress = edit_hotkeyKeyPress
    end
    object but_add: TButton
      Left = 12
      Top = 48
      Width = 74
      Height = 25
      Caption = 'Add'
      Enabled = False
      TabOrder = 1
      OnClick = but_addClick
    end
    object but_replace: TButton
      Left = 92
      Top = 48
      Width = 73
      Height = 25
      Caption = 'Replace'
      Enabled = False
      TabOrder = 2
      OnClick = but_replaceClick
    end
    object but_delete: TButton
      Left = 12
      Top = 79
      Width = 153
      Height = 25
      Caption = 'Delete'
      Enabled = False
      TabOrder = 3
      OnClick = but_deleteClick
    end
    object but_reset: TButton
      Left = 12
      Top = 110
      Width = 153
      Height = 25
      Caption = 'Reset to default'
      Enabled = False
      TabOrder = 4
      OnClick = but_resetClick
    end
  end
end
