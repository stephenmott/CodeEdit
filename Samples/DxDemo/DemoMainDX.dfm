object FormDX: TFormDX
  Left = 0
  Top = 0
  Margins.Left = 6
  Margins.Top = 6
  Margins.Right = 6
  Margins.Bottom = 6
  Caption = 'CodeEdit Demo - DevExpress skins'
  ClientHeight = 1047
  ClientWidth = 1293
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -24
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poScreenCenter
  OnCreate = FormCreate
  PixelsPerInch = 192
  TextHeight = 32
  object CodeEditor1: TCodeEditor
    Left = 0
    Top = 146
    Width = 1293
    Height = 863
    Margins.Left = 6
    Margins.Top = 6
    Margins.Right = 6
    Margins.Bottom = 6
    Align = alClient
    CompletionProvider = KeywordCompletionProvider1
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -32
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
    ExplicitLeft = 216
  end
  object StatusBar1: TdxStatusBar
    Left = 0
    Top = 1009
    Width = 1293
    Height = 38
    Margins.Left = 6
    Margins.Top = 6
    Margins.Right = 6
    Margins.Bottom = 6
    Panels = <>
    PaintStyle = stpsUseLookAndFeel
    SimplePanelStyle.Active = True
  end
  object Panel1: TcxGroupBox
    Left = 0
    Top = 0
    Margins.Left = 6
    Margins.Top = 6
    Margins.Right = 6
    Margins.Bottom = 6
    Align = alTop
    PanelStyle.Active = True
    TabOrder = 2
    Height = 146
    Width = 1293
    object ComboBox1: TcxComboBox
      Left = 32
      Top = 22
      Margins.Left = 6
      Margins.Top = 6
      Margins.Right = 6
      Margins.Bottom = 6
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
      Width = 370
    end
    object CheckBox1: TcxCheckBox
      Left = 432
      Top = 26
      Margins.Left = 6
      Margins.Top = 6
      Margins.Right = 6
      Margins.Bottom = 6
      Caption = 'Read-Only'
      TabOrder = 1
      Transparent = True
      OnClick = CheckBox1Click
      Width = 194
    end
    object ButtonTemplates: TcxButton
      Left = 656
      Top = 18
      Width = 240
      Height = 50
      Margins.Left = 6
      Margins.Top = 6
      Margins.Right = 6
      Margins.Bottom = 6
      Caption = 'Templates... (Ctrl+J)'
      TabOrder = 2
      OnClick = ButtonTemplatesClick
    end
    object ButtonOptions: TcxButton
      Left = 912
      Top = 18
      Width = 240
      Height = 50
      Margins.Left = 6
      Margins.Top = 6
      Margins.Right = 6
      Margins.Bottom = 6
      Caption = 'Editor Options...'
      TabOrder = 3
      OnClick = ButtonOptionsClick
    end
    object LabelSkin: TcxLabel
      Left = 32
      Top = 90
      Margins.Left = 6
      Margins.Top = 6
      Margins.Right = 6
      Margins.Bottom = 6
      Caption = 'DevExpress skin:'
      Transparent = True
    end
    object ComboSkin: TcxComboBox
      Left = 232
      Top = 86
      Margins.Left = 6
      Margins.Top = 6
      Margins.Right = 6
      Margins.Bottom = 6
      Properties.DropDownListStyle = lsFixedList
      Properties.OnChange = ComboSkinChange
      TabOrder = 4
      Width = 480
    end
  end
  object DelphiCodeHighlighter1: TDelphiCodeHighlighter
    Left = 376
    Top = 296
  end
  object JavaScriptCodeHighlighter1: TJavaScriptCodeHighlighter
    Left = 368
    Top = 432
  end
  object SqlCodeHighlighter1: TSqlCodeHighlighter
    Left = 368
    Top = 560
  end
  object KeywordCompletionProvider1: TKeywordCompletionProvider
    OnGetCompletions = KeywordCompletionProvider1GetCompletions
    OnGetSignatureHelp = KeywordCompletionProvider1GetSignatureHelp
    Left = 536
    Top = 128
  end
  object PythonCodeHighlighter1: TPythonCodeHighlighter
    Left = 360
    Top = 832
  end
  object YamlCodeHighlighter1: TYamlCodeHighlighter
    Left = 744
    Top = 576
  end
  object IniCodeHighlighter1: TIniCodeHighlighter
    Left = 744
    Top = 424
  end
  object PowerShellCodeHighlighter1: TPowerShellCodeHighlighter
    Left = 752
    Top = 272
  end
  object BatchCodeHighlighter1: TBatchCodeHighlighter
    Left = 744
    Top = 712
  end
  object TungliCodeHighlighter1: TTungliCodeHighlighter
    Left = 368
    Top = 696
  end
  object EditorSettings1: TCodeEditorSettings
    Editor = CodeEditor1
    RegistryPath = 'Software\CodeEdit\DemoDX'
    Title = 'CodeEdit DevExpress Demo - Editor Options'
    ThemeSource = 'DevExpress'
    OnApplied = EditorSettings1Applied
    Left = 536
    Top = 272
  end
  object dxSkinController1: TdxSkinController
    NativeStyle = False
    SkinName = 'Office2019Colorful'
    Left = 536
    Top = 416
  end
end
