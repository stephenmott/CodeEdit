object Form2: TForm2
  Left = 0
  Top = 0
  Margins.Left = 6
  Margins.Top = 6
  Margins.Right = 6
  Margins.Bottom = 6
  Caption = 'Form2'
  ClientHeight = 1085
  ClientWidth = 1299
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
    Width = 1299
    Height = 965
    Margins.Left = 6
    Margins.Top = 6
    Margins.Right = 6
    Margins.Bottom = 6
    Align = alClient
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -32
    Font.Name = 'Consolas'
    Font.Style = []
    Highlighter = DelphiCodeHighlighter1
    Lines.Strings = (
      '')
    TabOrder = 0
  end
  object StatusBar1: TStatusBar
    Left = 0
    Top = 1047
    Width = 1299
    Height = 38
    Margins.Left = 6
    Margins.Top = 6
    Margins.Right = 6
    Margins.Bottom = 6
    Panels = <>
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 1299
    Height = 82
    Margins.Left = 6
    Margins.Top = 6
    Margins.Right = 6
    Margins.Bottom = 6
    Align = alTop
    TabOrder = 2
    object ComboBox1: TComboBox
      Left = 32
      Top = 22
      Width = 369
      Height = 40
      Margins.Left = 6
      Margins.Top = 6
      Margins.Right = 6
      Margins.Bottom = 6
      Style = csDropDownList
      ItemIndex = 0
      TabOrder = 0
      Text = 'Delphi'
      OnChange = ComboBox1Change
      Items.Strings = (
        'Delphi'
        'Javascript'
        'SQL')
    end
  end
  object DelphiCodeHighlighter1: TDelphiCodeHighlighter
    Left = 160
    Top = 192
  end
  object JavaScriptCodeHighlighter1: TJavaScriptCodeHighlighter
    Left = 160
    Top = 320
  end
  object SqlCodeHighlighter1: TSqlCodeHighlighter
    Left = 160
    Top = 448
  end
end
