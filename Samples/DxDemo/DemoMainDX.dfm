object FormDX: TFormDX
  Left = 0
  Top = 0
  Caption = 'CodeEdit Demo - DevExpress skins'
  ClientHeight = 524
  ClientWidth = 647
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poScreenCenter
  OnCreate = FormCreate
  TextHeight = 15
  object CodeEditor1: TCodeEditor
    Left = 0
    Top = 73
    Width = 647
    Height = 432
    Align = alClient
    CompletionProvider = KeywordCompletionProvider1
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'Consolas'
    Font.Style = []
    Highlighter = DelphiCodeHighlighter1
    Lines.Strings = (
      '')
    LineMarkers = <>
    Modified = True
    Options.LineCommentPrefix = '//'
    TabOrder = 0
    Breakpoints = <
      item
        Line = 10
      end
      item
        Line = 15
      end>
  end
  object StatusBar1: TdxStatusBar
    Left = 0
    Top = 505
    Width = 647
    Height = 19
    Panels = <>
    SimplePanelStyle.Active = True
  end
  object Panel1: TcxGroupBox
    Left = 0
    Top = 0
    Align = alTop
    PanelStyle.Active = True
    TabOrder = 2
    Height = 73
    Width = 647
    object ComboBox1: TcxComboBox
      Left = 16
      Top = 11
      Properties.DropDownListStyle = lsFixedList
      Properties.Items.Strings = (
        'Delphi'
        'Javascript'
        'SQL'
        'Tungli'
        'Batch'
        'PowerShell'
        'Ini'
        'Yaml'
        'Python')
      Properties.OnChange = ComboBox1Change
      TabOrder = 0
      Width = 185
    end
    object CheckBox1: TcxCheckBox
      Left = 216
      Top = 13
      Caption = 'Read-Only'
      TabOrder = 1
      Transparent = True
      OnClick = CheckBox1Click
    end
    object ButtonTemplates: TcxButton
      Left = 328
      Top = 9
      Width = 120
      Height = 25
      Caption = 'Templates... (Ctrl+J)'
      OptionsImage.Spacing = 2
      TabOrder = 2
      OnClick = ButtonTemplatesClick
    end
    object ButtonOptions: TcxButton
      Left = 456
      Top = 9
      Width = 120
      Height = 25
      Caption = 'Editor Options...'
      OptionsImage.Spacing = 2
      TabOrder = 3
      OnClick = ButtonOptionsClick
    end
    object LabelSkin: TcxLabel
      Left = 16
      Top = 45
      Caption = 'DevExpress skin:'
      TabOrder = 5
      Transparent = True
    end
    object ComboSkin: TcxComboBox
      Left = 116
      Top = 43
      Properties.DropDownListStyle = lsFixedList
      Properties.OnChange = ComboSkinChange
      TabOrder = 4
      Width = 240
    end
  end
  object DelphiCodeHighlighter1: TDelphiCodeHighlighter
    Left = 188
    Top = 148
  end
  object JavaScriptCodeHighlighter1: TJavaScriptCodeHighlighter
    Left = 184
    Top = 216
  end
  object SqlCodeHighlighter1: TSqlCodeHighlighter
    Left = 184
    Top = 280
  end
  object KeywordCompletionProvider1: TKeywordCompletionProvider
    OnGetCompletions = KeywordCompletionProvider1GetCompletions
    OnGetSignatureHelp = KeywordCompletionProvider1GetSignatureHelp
    Left = 268
    Top = 64
  end
  object PythonCodeHighlighter1: TPythonCodeHighlighter
    Left = 180
    Top = 416
  end
  object YamlCodeHighlighter1: TYamlCodeHighlighter
    Left = 372
    Top = 288
  end
  object IniCodeHighlighter1: TIniCodeHighlighter
    Left = 372
    Top = 212
  end
  object PowerShellCodeHighlighter1: TPowerShellCodeHighlighter
    Left = 376
    Top = 136
  end
  object BatchCodeHighlighter1: TBatchCodeHighlighter
    Left = 372
    Top = 356
  end
  object TungliCodeHighlighter1: TTungliCodeHighlighter
    Left = 184
    Top = 348
  end
  object EditorSettings1: TCodeEditorSettings
    Editor = CodeEditor1
    RegistryPath = 'Software\CodeEdit\DemoDX'
    Title = 'CodeEdit DevExpress Demo - Editor Options'
    ThemeSource = 'DevExpress'
    OnApplied = EditorSettings1Applied
    Left = 268
    Top = 136
  end
  object dxSkinController1: TdxSkinController
    NativeStyle = False
    SkinName = 'Office2019Colorful'
    Left = 268
    Top = 208
  end
end
