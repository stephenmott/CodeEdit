object CodeEditorSettingsDialog: TCodeEditorSettingsDialog
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
  object LabelPreview: TLabel
    Left = 8
    Top = 320
    Width = 46
    Height = 15
    Caption = 'Preview:'
  end
  object PageControl: TPageControl
    Left = 8
    Top = 8
    Width = 544
    Height = 304
    ActivePage = TabEditing
    TabOrder = 0
    object TabEditing: TTabSheet
      Caption = 'Editing'
      object LabelTabSize: TLabel
        Left = 16
        Top = 19
        Width = 46
        Height = 15
        Caption = 'Tab size:'
      end
      object LabelCommentPrefix: TLabel
        Left = 16
        Top = 83
        Width = 112
        Height = 15
        Caption = 'Line comment prefix:'
      end
      object LabelMaxPaste: TLabel
        Left = 16
        Top = 115
        Width = 236
        Height = 15
        Caption = 'Refuse pastes larger than (MB, 0 = no limit):'
      end
      object EditTabSize: TEdit
        Left = 140
        Top = 16
        Width = 44
        Height = 23
        TabOrder = 0
        Text = '2'
        OnChange = ControlChanged
      end
      object UpDownTabSize: TUpDown
        Left = 184
        Top = 16
        Width = 16
        Height = 23
        Associate = EditTabSize
        Min = 1
        Max = 16
        Position = 2
        TabOrder = 1
      end
      object CheckBracketMatching: TCheckBox
        Left = 16
        Top = 50
        Width = 260
        Height = 17
        Caption = 'Highlight matching brackets'
        TabOrder = 2
        OnClick = ControlChanged
      end
      object EditCommentPrefix: TEdit
        Left = 140
        Top = 80
        Width = 80
        Height = 23
        TabOrder = 3
        Text = '//'
        OnChange = ControlChanged
      end
      object EditMaxPaste: TEdit
        Left = 264
        Top = 112
        Width = 52
        Height = 23
        TabOrder = 4
        Text = '64'
        OnChange = ControlChanged
      end
      object UpDownMaxPaste: TUpDown
        Left = 316
        Top = 112
        Width = 16
        Height = 23
        Associate = EditMaxPaste
        Max = 1024
        Position = 64
        TabOrder = 5
      end
    end
    object TabDisplay: TTabSheet
      Caption = 'Display'
      object LabelScrollBars: TLabel
        Left = 16
        Top = 67
        Width = 56
        Height = 15
        Caption = 'Scrollbars:'
      end
      object LabelMinimapStyle: TLabel
        Left = 280
        Top = 99
        Width = 76
        Height = 15
        Caption = 'Minimap style:'
      end
      object LabelMinimapRowHeight: TLabel
        Left = 280
        Top = 131
        Width = 108
        Height = 15
        Caption = 'Minimap row height:'
      end
      object LabelZoom: TLabel
        Left = 280
        Top = 163
        Width = 46
        Height = 15
        Caption = 'Zoom %:'
      end
      object CheckShowGutter: TCheckBox
        Left = 16
        Top = 16
        Width = 240
        Height = 17
        Caption = 'Show line numbers (gutter)'
        TabOrder = 0
        OnClick = ControlChanged
      end
      object CheckStyledScrollBars: TCheckBox
        Left = 16
        Top = 40
        Width = 240
        Height = 17
        Caption = 'Styled scrollbars'
        TabOrder = 1
        OnClick = ControlChanged
      end
      object ComboScrollBars: TComboBox
        Left = 120
        Top = 64
        Width = 120
        Height = 23
        Style = csDropDownList
        TabOrder = 2
        OnChange = ControlChanged
        Items.Strings = (
          'None'
          'Horizontal'
          'Vertical'
          'Both')
      end
      object CheckWordWrap: TCheckBox
        Left = 280
        Top = 16
        Width = 240
        Height = 17
        Caption = 'Word wrap'
        TabOrder = 3
        OnClick = ControlChanged
      end
      object CheckWrapIndent: TCheckBox
        Left = 300
        Top = 40
        Width = 220
        Height = 17
        Caption = 'Indent wrapped rows'
        TabOrder = 4
        OnClick = ControlChanged
      end
      object CheckShowMinimap: TCheckBox
        Left = 16
        Top = 99
        Width = 240
        Height = 17
        Caption = 'Show minimap'
        TabOrder = 5
        OnClick = ControlChanged
      end
      object CheckMinimapPreview: TCheckBox
        Left = 36
        Top = 123
        Width = 220
        Height = 17
        Caption = 'Minimap hover preview'
        TabOrder = 6
        OnClick = ControlChanged
      end
      object ComboMinimapStyle: TComboBox
        Left = 400
        Top = 96
        Width = 110
        Height = 23
        Style = csDropDownList
        TabOrder = 7
        OnChange = ControlChanged
        Items.Strings = (
          'Text'
          'Blocks')
      end
      object EditMinimapRowHeight: TEdit
        Left = 400
        Top = 128
        Width = 44
        Height = 23
        TabOrder = 8
        Text = '3'
        OnChange = ControlChanged
      end
      object UpDownMinimapRowHeight: TUpDown
        Left = 444
        Top = 128
        Width = 16
        Height = 23
        Associate = EditMinimapRowHeight
        Min = 2
        Max = 8
        Position = 3
        TabOrder = 9
      end
      object CheckThemeSyntaxColors: TCheckBox
        Left = 16
        Top = 163
        Width = 250
        Height = 17
        Caption = 'Adapt syntax colours to the theme'
        TabOrder = 10
        OnClick = ControlChanged
      end
      object EditZoom: TEdit
        Left = 400
        Top = 160
        Width = 44
        Height = 23
        TabOrder = 11
        Text = '100'
        OnChange = ControlChanged
      end
      object UpDownZoom: TUpDown
        Left = 444
        Top = 160
        Width = 16
        Height = 23
        Associate = EditZoom
        Min = 25
        Max = 400
        Increment = 10
        Position = 100
        TabOrder = 12
      end
    end
    object TabFont: TTabSheet
      Caption = 'Font'
      object LabelFontCaption: TLabel
        Left = 16
        Top = 20
        Width = 28
        Height = 15
        Caption = 'Font:'
      end
      object LabelFont: TLabel
        Left = 64
        Top = 20
        Width = 300
        Height = 15
        AutoSize = False
        Caption = 'Consolas, 10pt'
      end
      object LabelFontNote: TLabel
        Left = 16
        Top = 56
        Width = 400
        Height = 15
        Caption = 'The editor assumes a fixed-pitch font (Consolas, Cascadia Mono, Courier New...).'
      end
      object ButtonFont: TButton
        Left = 420
        Top = 15
        Width = 100
        Height = 25
        Caption = 'Change...'
        TabOrder = 0
        OnClick = ButtonFontClick
      end
    end
    object TabColours: TTabSheet
      Caption = 'Colours'
      object LabelThemeMode: TLabel
        Left = 16
        Top = 19
        Width = 44
        Height = 15
        Caption = 'Colours:'
      end
      object LabelBackground: TLabel
        Left = 16
        Top = 54
        Width = 66
        Height = 15
        Caption = 'Background'
      end
      object LabelText: TLabel
        Left = 16
        Top = 82
        Width = 22
        Height = 15
        Caption = 'Text'
      end
      object LabelGutterBackground: TLabel
        Left = 16
        Top = 110
        Width = 103
        Height = 15
        Caption = 'Gutter background'
      end
      object LabelGutterText: TLabel
        Left = 16
        Top = 138
        Width = 59
        Height = 15
        Caption = 'Gutter text'
      end
      object LabelGutterBorder: TLabel
        Left = 16
        Top = 166
        Width = 72
        Height = 15
        Caption = 'Gutter border'
      end
      object LabelSelectionBackground: TLabel
        Left = 16
        Top = 194
        Width = 116
        Height = 15
        Caption = 'Selection background'
      end
      object LabelSelectionText: TLabel
        Left = 16
        Top = 222
        Width = 72
        Height = 15
        Caption = 'Selection text'
      end
      object ComboThemeMode: TComboBox
        Left = 160
        Top = 16
        Width = 200
        Height = 23
        Style = csDropDownList
        TabOrder = 0
        OnChange = ComboThemeModeChange
        Items.Strings = (
          'Custom (below)'
          'Follow the VCL style')
      end
      object ColorBackground: TColorBox
        Left = 160
        Top = 50
        Width = 200
        Height = 22
        Style = [cbStandardColors, cbExtendedColors, cbSystemColors, cbCustomColor, cbPrettyNames]
        TabOrder = 1
        OnChange = ControlChanged
      end
      object ColorText: TColorBox
        Left = 160
        Top = 78
        Width = 200
        Height = 22
        Style = [cbStandardColors, cbExtendedColors, cbSystemColors, cbCustomColor, cbPrettyNames]
        TabOrder = 2
        OnChange = ControlChanged
      end
      object ColorGutterBackground: TColorBox
        Left = 160
        Top = 106
        Width = 200
        Height = 22
        Style = [cbStandardColors, cbExtendedColors, cbSystemColors, cbCustomColor, cbPrettyNames]
        TabOrder = 3
        OnChange = ControlChanged
      end
      object ColorGutterText: TColorBox
        Left = 160
        Top = 134
        Width = 200
        Height = 22
        Style = [cbStandardColors, cbExtendedColors, cbSystemColors, cbCustomColor, cbPrettyNames]
        TabOrder = 4
        OnChange = ControlChanged
      end
      object ColorGutterBorder: TColorBox
        Left = 160
        Top = 162
        Width = 200
        Height = 22
        Style = [cbStandardColors, cbExtendedColors, cbSystemColors, cbCustomColor, cbPrettyNames]
        TabOrder = 5
        OnChange = ControlChanged
      end
      object ColorSelectionBackground: TColorBox
        Left = 160
        Top = 190
        Width = 200
        Height = 22
        Style = [cbStandardColors, cbExtendedColors, cbSystemColors, cbCustomColor, cbPrettyNames]
        TabOrder = 6
        OnChange = ControlChanged
      end
      object ColorSelectionText: TColorBox
        Left = 160
        Top = 218
        Width = 200
        Height = 22
        Style = [cbStandardColors, cbExtendedColors, cbSystemColors, cbCustomColor, cbPrettyNames]
        TabOrder = 7
        OnChange = ControlChanged
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
  object PanelBottom: TPanel
    Left = 0
    Top = 480
    Width = 560
    Height = 48
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 2
    object ButtonImport: TButton
      Left = 8
      Top = 12
      Width = 85
      Height = 25
      Caption = 'Import...'
      TabOrder = 0
      OnClick = ButtonImportClick
    end
    object ButtonExport: TButton
      Left = 99
      Top = 12
      Width = 85
      Height = 25
      Caption = 'Export...'
      TabOrder = 1
      OnClick = ButtonExportClick
    end
    object ButtonOK: TButton
      Left = 296
      Top = 12
      Width = 80
      Height = 25
      Caption = 'OK'
      Default = True
      TabOrder = 2
      OnClick = ButtonOKClick
    end
    object ButtonCancel: TButton
      Left = 382
      Top = 12
      Width = 80
      Height = 25
      Cancel = True
      Caption = 'Cancel'
      ModalResult = 2
      TabOrder = 3
    end
    object ButtonApply: TButton
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
