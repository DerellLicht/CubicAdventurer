inherited CEWorkspacePanel: TCEWorkspacePanel
  Caption = 'Workspace'
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  inherited TopDock: TSpTBXDock
    Height = 27
    ExplicitHeight = 27
    object WorkspaceToolbar: TCEToolbar
      Left = 0
      Top = 0
      BorderStyle = bsNone
      DragHandleStyle = dhNone
      Images = CE_Images.SmallIcons
      Stretch = True
      TabOrder = 0
      Caption = 'Workspace'
      object item_path_combo: TTBControlItem
        Control = combo_path
      end
      object CEToolbarStretcherItem1: TCEToolbarStretcherItem
        CustomHeight = 16
        CustomWidth = 0
      end
      object combo_path: TVirtualExplorerCombobox
        Left = 0
        Top = 0
        Width = 421
        Options = [vcboThreadedImages, vcboThemeAware, vcboSelectPathOnDropDown]
        TabOrder = 0
        Path = 'combo_path'
        PopupExplorerOptions.ComboBoxStyle = cbsVETEnhanced
        PopupExplorerOptions.Indent = 16
        PopupExplorerOptions.Options = [poAnimated, poEnabled, poPersistentSizing, poSizeable, poRespectSysAnimationFlag, poThemeAware]
        TextType = ecbtFullPath
        OnPathChange = combo_pathPathChange
      end
    end
  end
  object BackgroundCMItems_up: TPopupMenu
    OnPopup = BackgroundCMItems_upPopup
    Left = 64
    Top = 104
    object View1: TMenuItem
      Caption = 'View'
      object item_large_icons: TMenuItem
        Tag = 100
        Caption = 'Large Icons'
        RadioItem = True
        OnClick = ContextMenuClick
      end
      object item_small_icons: TMenuItem
        Tag = 101
        Caption = 'Small Icons'
        RadioItem = True
        OnClick = ContextMenuClick
      end
      object item_list: TMenuItem
        Tag = 102
        Caption = 'List'
        RadioItem = True
        OnClick = ContextMenuClick
      end
      object item_details: TMenuItem
        Tag = 103
        Caption = 'Details'
        RadioItem = True
        OnClick = ContextMenuClick
      end
      object item_tiles: TMenuItem
        Tag = 105
        Caption = 'Tiles'
        RadioItem = True
        OnClick = ContextMenuClick
      end
      object item_thumbnails: TMenuItem
        Tag = 104
        Caption = 'Thumbnails'
        RadioItem = True
        OnClick = ContextMenuClick
      end
      object item_filmstrip: TMenuItem
        Tag = 107
        Caption = 'Filmstrip'
        RadioItem = True
        OnClick = ContextMenuClick
      end
      object N3: TMenuItem
        Caption = '-'
      end
      object item_per_folder: TMenuItem
        Tag = 110
        Caption = 'Use per folder settings'
        OnClick = ContextMenuClick
      end
    end
    object N1: TMenuItem
      Caption = '-'
    end
    object MenuItem_ArragneBy: TMenuItem
      Caption = 'Arrange By'
    end
    object MenuItem_GroupBy: TMenuItem
      Caption = 'Group By'
    end
    object item_refresh: TMenuItem
      Tag = 606
      Caption = 'Refresh'
      OnClick = ContextMenuClick
    end
    object N2: TMenuItem
      Caption = '-'
    end
    object Paste1: TMenuItem
      Action = CEActions.act_edit_paste
    end
    object PasteShortcut1: TMenuItem
      Action = CEActions.act_edit_paste_shortcut
    end
    object CopyPath1: TMenuItem
      Action = CEActions.act_edit_copypath
    end
    object N4: TMenuItem
      Caption = '-'
    end
    object CreateSymbolicLink1: TMenuItem
      Action = CEActions.act_edit_create_symlink
    end
    object N5: TMenuItem
      Caption = '-'
    end
  end
end
