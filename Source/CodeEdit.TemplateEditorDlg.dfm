object CodeTemplateEditorDialog: TCodeTemplateEditorDialog
  Left = 0
  Top = 0
  ActiveControl = ListTemplates
  BorderIcons = [biSystemMenu, biMaximize]
  Caption = 'Code Templates'
  ClientHeight = 580
  ClientWidth = 920
  Color = clBtnFace
  Constraints.MinHeight = 520
  Constraints.MinWidth = 800
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poScreenCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  TextHeight = 15
  object SplitterMain: TSplitter
    Left = 330
    Top = 0
    Width = 6
    Height = 532
    ResizeStyle = rsUpdate
  end
  object PanelLeft: TPanel
    AlignWithMargins = True
    Left = 10
    Top = 10
    Width = 320
    Height = 522
    Margins.Left = 10
    Margins.Top = 10
    Margins.Right = 0
    Margins.Bottom = 0
    Align = alLeft
    BevelOuter = bvNone
    ShowCaption = False
    TabOrder = 0
    object FilterCombo: TComboBox
      Left = 0
      Top = 0
      Width = 320
      Height = 23
      Align = alTop
      Style = csDropDownList
      TabOrder = 0
      OnChange = FilterComboChange
    end
    object ListTemplates: TListBox
      AlignWithMargins = True
      Left = 0
      Top = 31
      Width = 320
      Height = 454
      Margins.Left = 0
      Margins.Top = 8
      Margins.Right = 0
      Margins.Bottom = 0
      Align = alClient
      ItemHeight = 15
      TabOrder = 1
      OnClick = ListTemplatesClick
    end
    object PanelListButtons: TPanel
      Left = 0
      Top = 485
      Width = 320
      Height = 37
      Align = alBottom
      BevelOuter = bvNone
      ShowCaption = False
      TabOrder = 2
      object ButtonAdd: TButton
        Left = 0
        Top = 8
        Width = 98
        Height = 27
        Caption = 'Add'
        TabOrder = 0
        OnClick = ButtonAddClick
      end
      object ButtonDuplicate: TButton
        Left = 106
        Top = 8
        Width = 98
        Height = 27
        Caption = 'Duplicate'
        TabOrder = 1
        OnClick = ButtonDuplicateClick
      end
      object ButtonDelete: TButton
        Left = 212
        Top = 8
        Width = 98
        Height = 27
        Caption = 'Delete'
        TabOrder = 2
        OnClick = ButtonDeleteClick
      end
    end
  end
  object PanelRight: TPanel
    Left = 336
    Top = 0
    Width = 584
    Height = 532
    Align = alClient
    BevelOuter = bvNone
    ShowCaption = False
    TabOrder = 1
    object PanelDetail: TPanel
      Left = 0
      Top = 0
      Width = 584
      Height = 108
      Align = alTop
      BevelOuter = bvNone
      ShowCaption = False
      TabOrder = 0
      object LabelName: TLabel
        Left = 14
        Top = 15
        Width = 35
        Height = 15
        Caption = 'Name:'
      end
      object LabelLanguage: TLabel
        Left = 324
        Top = 15
        Width = 57
        Height = 15
        Caption = 'Language:'
      end
      object LabelDescription: TLabel
        Left = 14
        Top = 49
        Width = 66
        Height = 15
        Caption = 'Description:'
      end
      object LabelCode: TLabel
        Left = 14
        Top = 84
        Width = 31
        Height = 15
        Caption = 'Code:'
      end
      object EditName: TEdit
        Left = 94
        Top = 12
        Width = 210
        Height = 23
        TabOrder = 0
        OnChange = EditNameChange
      end
      object ComboLanguage: TComboBox
        Left = 394
        Top = 12
        Width = 170
        Height = 23
        TabOrder = 1
        OnChange = ComboLanguageChange
      end
      object EditDescription: TEdit
        Left = 94
        Top = 46
        Width = 476
        Height = 23
        Anchors = [akLeft, akTop, akRight]
        TabOrder = 2
        OnChange = EditDescriptionChange
      end
    end
    object CodeEditor: TCodeEditor
      AlignWithMargins = True
      Left = 10
      Top = 108
      Width = 564
      Height = 424
      Margins.Left = 10
      Margins.Top = 0
      Margins.Right = 10
      Margins.Bottom = 0
      Align = alClient
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Consolas'
      Font.Style = []
      Lines.Strings = (
        '')
      LineMarkers = <>
      Options.ShowMinimap = False
      TabOrder = 1
      Breakpoints = <>
      OnChange = CodeEditorChange
    end
  end
  object PanelBottom: TPanel
    Left = 0
    Top = 532
    Width = 920
    Height = 48
    Align = alBottom
    BevelOuter = bvNone
    ShowCaption = False
    TabOrder = 2
    object LabelHint: TLabel
      Left = 12
      Top = 16
      Width = 690
      Height = 15
      Anchors = [akLeft, akRight, akBottom]
      AutoSize = False
      Caption =
        'Use | in the code to mark where the caret lands after insertion' +
        '; || gives a literal |.'
    end
    object ButtonOK: TButton
      Left = 730
      Top = 11
      Width = 86
      Height = 27
      Anchors = [akRight, akBottom]
      Caption = 'OK'
      ModalResult = 1
      TabOrder = 0
    end
    object ButtonCancel: TButton
      Left = 824
      Top = 11
      Width = 86
      Height = 27
      Anchors = [akRight, akBottom]
      Cancel = True
      Caption = 'Cancel'
      ModalResult = 2
      TabOrder = 1
    end
  end
end
