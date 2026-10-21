object CodeEditorSettingsDialogDX: TCodeEditorSettingsDialogDX
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  Caption = 'Editor Options'
  ClientHeight = 528
  ClientWidth = 560
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poMainFormCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  TextHeight = 15
  object LabelPreview: TcxLabel
    Left = 8
    Top = 318
    Caption = 'Preview:'
    Transparent = True
  end
  object PageControl: TcxPageControl
    Left = 8
    Top = 8
    Width = 544
    Height = 304
    TabOrder = 0
    Properties.ActivePage = TabEditing
    Properties.CustomButtons.Buttons = <>
    object TabEditing: TcxTabSheet
      Caption = 'Editing'
      ImageIndex = -1
      object LabelTabSize: TcxLabel
        Left = 16
        Top = 17
        Caption = 'Tab size:'
        Transparent = True
      end
      object SpinTabSize: TcxSpinEdit
        Left = 140
        Top = 16
        Properties.MaxValue = 16.000000000000000000
        Properties.MinValue = 1.000000000000000000
        Properties.OnChange = ControlChanged
        TabOrder = 1
        Value = 2
        Width = 64
      end
      object CheckBracketMatching: TcxCheckBox
        Left = 16
        Top = 50
        Caption = 'Highlight matching brackets'
        Properties.OnChange = ControlChanged
        TabOrder = 2
        Transparent = True
        Width = 260
      end
      object LabelCommentPrefix: TcxLabel
        Left = 16
        Top = 81
        Caption = 'Line comment prefix:'
        Transparent = True
      end
      object EditCommentPrefix: TcxTextEdit
        Left = 140
        Top = 80
        Properties.OnChange = ControlChanged
        TabOrder = 4
        Text = '//'
        Width = 80
      end
      object LabelMaxPaste: TcxLabel
        Left = 16
        Top = 113
        Caption = 'Refuse pastes larger than (MB, 0 = no limit):'
        Transparent = True
      end
      object SpinMaxPaste: TcxSpinEdit
        Left = 264
        Top = 112
        Properties.MaxValue = 1024.000000000000000000
        Properties.OnChange = ControlChanged
        TabOrder = 6
        Value = 64
        Width = 72
      end
    end
    object TabDisplay: TcxTabSheet
      Caption = 'Display'
      ImageIndex = -1
      object CheckShowGutter: TcxCheckBox
        Left = 16
        Top = 16
        Caption = 'Show line numbers (gutter)'
        Properties.OnChange = ControlChanged
        TabOrder = 0
        Transparent = True
        Width = 240
      end
      object CheckStyledScrollBars: TcxCheckBox
        Left = 16
        Top = 40
        Caption = 'Styled scrollbars'
        Properties.OnChange = ControlChanged
        TabOrder = 1
        Transparent = True
        Width = 240
      end
      object LabelScrollBars: TcxLabel
        Left = 16
        Top = 65
        Caption = 'Scrollbars:'
        Transparent = True
      end
      object ComboScrollBars: TcxComboBox
        Left = 120
        Top = 64
        Properties.DropDownListStyle = lsFixedList
        Properties.Items.Strings = (
          'None'
          'Horizontal'
          'Vertical'
          'Both')
        Properties.OnChange = ControlChanged
        TabOrder = 3
        Width = 120
      end
      object CheckWordWrap: TcxCheckBox
        Left = 280
        Top = 16
        Caption = 'Word wrap'
        Properties.OnChange = ControlChanged
        TabOrder = 4
        Transparent = True
        Width = 240
      end
      object CheckWrapIndent: TcxCheckBox
        Left = 300
        Top = 40
        Caption = 'Indent wrapped rows'
        Properties.OnChange = ControlChanged
        TabOrder = 5
        Transparent = True
        Width = 220
      end
      object CheckShowMinimap: TcxCheckBox
        Left = 16
        Top = 99
        Caption = 'Show minimap'
        Properties.OnChange = ControlChanged
        TabOrder = 6
        Transparent = True
        Width = 240
      end
      object CheckMinimapPreview: TcxCheckBox
        Left = 36
        Top = 123
        Caption = 'Minimap hover preview'
        Properties.OnChange = ControlChanged
        TabOrder = 7
        Transparent = True
        Width = 220
      end
      object LabelMinimapStyle: TcxLabel
        Left = 280
        Top = 97
        Caption = 'Minimap style:'
        Transparent = True
      end
      object ComboMinimapStyle: TcxComboBox
        Left = 400
        Top = 96
        Properties.DropDownListStyle = lsFixedList
        Properties.Items.Strings = (
          'Text'
          'Blocks')
        Properties.OnChange = ControlChanged
        TabOrder = 9
        Width = 110
      end
      object LabelMinimapRowHeight: TcxLabel
        Left = 280
        Top = 129
        Caption = 'Minimap row height:'
        Transparent = True
      end
      object SpinMinimapRowHeight: TcxSpinEdit
        Left = 400
        Top = 128
        Properties.MaxValue = 8.000000000000000000
        Properties.MinValue = 2.000000000000000000
        Properties.OnChange = ControlChanged
        TabOrder = 11
        Value = 3
        Width = 64
      end
      object CheckThemeSyntaxColors: TcxCheckBox
        Left = 16
        Top = 163
        Caption = 'Adapt syntax colours to the theme'
        Properties.OnChange = ControlChanged
        TabOrder = 12
        Transparent = True
        Width = 250
      end
      object LabelZoom: TcxLabel
        Left = 280
        Top = 161
        Caption = 'Zoom %:'
        Transparent = True
      end
      object SpinZoom: TcxSpinEdit
        Left = 400
        Top = 160
        Properties.Increment = 10.000000000000000000
        Properties.MaxValue = 400.000000000000000000
        Properties.MinValue = 25.000000000000000000
        Properties.OnChange = ControlChanged
        TabOrder = 14
        Value = 100
        Width = 64
      end
    end
    object TabFont: TcxTabSheet
      Caption = 'Font'
      ImageIndex = -1
      object LabelFontCaption: TcxLabel
        Left = 16
        Top = 18
        Caption = 'Font:'
        Transparent = True
      end
      object LabelFont: TcxLabel
        Left = 64
        Top = 18
        Caption = 'Consolas, 10pt'
        Transparent = True
      end
      object LabelFontNote: TcxLabel
        Left = 16
        Top = 54
        Caption = 'The editor assumes a fixed-pitch font (Consolas, Cascadia Mono, Courier New...).'
        Transparent = True
      end
      object ButtonFont: TcxButton
        Left = 420
        Top = 15
        Width = 100
        Height = 25
        Caption = 'Change...'
        TabOrder = 3
        OnClick = ButtonFontClick
      end
    end
    object TabColours: TcxTabSheet
      Caption = 'Colours'
      ImageIndex = -1
      object LabelThemeMode: TcxLabel
        Left = 16
        Top = 17
        Caption = 'Colours:'
        Transparent = True
      end
      object ComboThemeMode: TcxComboBox
        Left = 160
        Top = 16
        Properties.DropDownListStyle = lsFixedList
        Properties.Items.Strings = (
          'Custom (below)'
          'Follow the VCL style')
        Properties.OnChange = ComboThemeModeChange
        TabOrder = 1
        Width = 200
      end
      object LabelBackground: TcxLabel
        Left = 16
        Top = 52
        Caption = 'Background'
        Transparent = True
      end
      object ColorBackground: TcxColorComboBox
        Left = 160
        Top = 50
        Properties.AllowSelectColor = True
        Properties.CustomColors = <>
        Properties.OnChange = ControlChanged
        TabOrder = 3
        Width = 200
      end
      object LabelText: TcxLabel
        Left = 16
        Top = 80
        Caption = 'Text'
        Transparent = True
      end
      object ColorText: TcxColorComboBox
        Left = 160
        Top = 78
        Properties.AllowSelectColor = True
        Properties.CustomColors = <>
        Properties.OnChange = ControlChanged
        TabOrder = 5
        Width = 200
      end
      object LabelGutterBackground: TcxLabel
        Left = 16
        Top = 108
        Caption = 'Gutter background'
        Transparent = True
      end
      object ColorGutterBackground: TcxColorComboBox
        Left = 160
        Top = 106
        Properties.AllowSelectColor = True
        Properties.CustomColors = <>
        Properties.OnChange = ControlChanged
        TabOrder = 7
        Width = 200
      end
      object LabelGutterText: TcxLabel
        Left = 16
        Top = 136
        Caption = 'Gutter text'
        Transparent = True
      end
      object ColorGutterText: TcxColorComboBox
        Left = 160
        Top = 134
        Properties.AllowSelectColor = True
        Properties.CustomColors = <>
        Properties.OnChange = ControlChanged
        TabOrder = 9
        Width = 200
      end
      object LabelGutterBorder: TcxLabel
        Left = 16
        Top = 164
        Caption = 'Gutter border'
        Transparent = True
      end
      object ColorGutterBorder: TcxColorComboBox
        Left = 160
        Top = 162
        Properties.AllowSelectColor = True
        Properties.CustomColors = <>
        Properties.OnChange = ControlChanged
        TabOrder = 11
        Width = 200
      end
      object LabelSelectionBackground: TcxLabel
        Left = 16
        Top = 192
        Caption = 'Selection background'
        Transparent = True
      end
      object ColorSelectionBackground: TcxColorComboBox
        Left = 160
        Top = 190
        Properties.AllowSelectColor = True
        Properties.CustomColors = <>
        Properties.OnChange = ControlChanged
        TabOrder = 13
        Width = 200
      end
      object LabelSelectionText: TcxLabel
        Left = 16
        Top = 220
        Caption = 'Selection text'
        Transparent = True
      end
      object ColorSelectionText: TcxColorComboBox
        Left = 160
        Top = 218
        Properties.AllowSelectColor = True
        Properties.CustomColors = <>
        Properties.OnChange = ControlChanged
        TabOrder = 15
        Width = 200
      end
    end
  end
  object PreviewEditor: TCodeEditor
    Left = 8
    Top = 338
    Width = 544
    Height = 136
    TabOrder = 1
    TabStop = False
  end
  object PanelBottom: TcxGroupBox
    Left = 0
    Top = 480
    Align = alBottom
    PanelStyle.Active = True
    TabOrder = 2
    Height = 48
    Width = 560
    object ButtonImport: TcxButton
      Left = 8
      Top = 12
      Width = 85
      Height = 25
      Caption = 'Import...'
      TabOrder = 0
      OnClick = ButtonImportClick
    end
    object ButtonExport: TcxButton
      Left = 99
      Top = 12
      Width = 85
      Height = 25
      Caption = 'Export...'
      TabOrder = 1
      OnClick = ButtonExportClick
    end
    object ButtonOK: TcxButton
      Left = 296
      Top = 12
      Width = 80
      Height = 25
      Caption = 'OK'
      Default = True
      TabOrder = 2
      OnClick = ButtonOKClick
    end
    object ButtonCancel: TcxButton
      Left = 382
      Top = 12
      Width = 80
      Height = 25
      Cancel = True
      Caption = 'Cancel'
      ModalResult = 2
      TabOrder = 3
    end
    object ButtonApply: TcxButton
      Left = 468
      Top = 12
      Width = 80
      Height = 25
      Caption = 'Apply'
      TabOrder = 4
      OnClick = ButtonApplyClick
    end
  end
  object FontDialog: TFontDialog
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Consolas'
    Font.Style = []
    Options = [fdFixedPitchOnly, fdForceFontExist]
    Left = 480
    Top = 320
  end
  object OpenDialog: TOpenDialog
    DefaultExt = 'ini'
    Filter = 'Editor settings (*.ini)|*.ini|All files (*.*)|*.*'
    Options = [ofHideReadOnly, ofFileMustExist, ofEnableSizing]
    Title = 'Import editor settings'
    Left = 512
    Top = 320
  end
  object SaveDialog: TSaveDialog
    DefaultExt = 'ini'
    Filter = 'Editor settings (*.ini)|*.ini|All files (*.*)|*.*'
    Options = [ofOverwritePrompt, ofHideReadOnly, ofEnableSizing]
    Title = 'Export editor settings'
    Left = 448
    Top = 320
  end
end
