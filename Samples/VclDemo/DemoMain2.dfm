object Form2: TForm2
  Left = 0
  Top = 0
  Margins.Left = 6
  Margins.Top = 6
  Margins.Right = 6
  Margins.Bottom = 6
  Caption = 'Form2'
  ClientHeight = 1139
  ClientWidth = 1613
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
    Top = 82
    Width = 1613
    Height = 1019
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
    OnKeyDown = CodeEditor1KeyDown
    ExplicitTop = 74
    ExplicitWidth = 1661
    ExplicitHeight = 1158
  end
  object StatusBar1: TStatusBar
    Left = 0
    Top = 1101
    Width = 1613
    Height = 38
    Margins.Left = 6
    Margins.Top = 6
    Margins.Right = 6
    Margins.Bottom = 6
    Panels = <>
    ExplicitTop = 2089
    ExplicitWidth = 2414
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 1613
    Height = 82
    Margins.Left = 6
    Margins.Top = 6
    Margins.Right = 6
    Margins.Bottom = 6
    Align = alTop
    TabOrder = 2
    ExplicitWidth = 2414
    object ComboBox1: TComboBox
      Left = 32
      Top = 22
      Width = 370
      Height = 40
      Margins.Left = 6
      Margins.Top = 6
      Margins.Right = 6
      Margins.Bottom = 6
      Style = csDropDownList
      TabOrder = 0
      OnChange = ComboBox1Change
      Items.Strings = (
        'Delphi'
        'Javascript'
        'SQL'
        'Tungli'
        'Batch'
        'PowerShell'
        'Ini'
        'Yaml'
        'Python')
    end
    object CheckBox1: TCheckBox
      Left = 432
      Top = 26
      Width = 194
      Height = 34
      Margins.Left = 6
      Margins.Top = 6
      Margins.Right = 6
      Margins.Bottom = 6
      Caption = 'Read-Only'
      TabOrder = 1
      OnClick = CheckBox1Click
    end
  end
  object DelphiCodeHighlighter1: TDelphiCodeHighlighter
    Left = 192
    Top = 272
  end
  object JavaScriptCodeHighlighter1: TJavaScriptCodeHighlighter
    Left = 192
    Top = 432
  end
  object SqlCodeHighlighter1: TSqlCodeHighlighter
    Left = 176
    Top = 608
  end
  object KeywordCompletionProvider1: TKeywordCompletionProvider
    OnGetCompletions = KeywordCompletionProvider1GetCompletions
    OnGetSignatureHelp = KeywordCompletionProvider1GetSignatureHelp
    Left = 464
    Top = 128
  end
  object PythonCodeHighlighter1: TPythonCodeHighlighter
    Left = 192
    Top = 944
  end
  object YamlCodeHighlighter1: TYamlCodeHighlighter
    Left = 592
    Top = 576
  end
  object IniCodeHighlighter1: TIniCodeHighlighter
    Left = 608
    Top = 416
  end
  object PowerShellCodeHighlighter1: TPowerShellCodeHighlighter
    Left = 592
    Top = 272
  end
  object BatchCodeHighlighter1: TBatchCodeHighlighter
    Left = 592
    Top = 720
  end
  object TungliCodeHighlighter1: TTungliCodeHighlighter
    Left = 176
    Top = 784
  end
end
