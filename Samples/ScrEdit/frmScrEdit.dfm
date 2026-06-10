object formScrEdit: TformScrEdit
  Left = 351
  Top = 132
  Margins.Left = 6
  Margins.Top = 6
  Margins.Right = 6
  Margins.Bottom = 6
  Caption = 'formScrEdit'
  ClientHeight = 1061
  ClientWidth = 2068
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -22
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  Position = poScreenCenter
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnShow = FormShow
  PixelsPerInch = 192
  TextHeight = 26
  object dxRibbon1: TdxRibbon
    Left = 0
    Top = 0
    Width = 2068
    Height = 24
    Margins.Left = 6
    Margins.Top = 6
    Margins.Right = 6
    Margins.Bottom = 6
    BarManager = dxBarManager1
    ColorSchemeName = 'Blue'
    ShowTabGroups = False
    ShowTabHeaders = False
    SupportNonClientDrawing = True
    Contexts = <>
    TabOrder = 1
    TabStop = False
    ExplicitLeft = -160
    ExplicitTop = -96
    ExplicitWidth = 2244
    object dxRibbon1Tab1: TdxRibbonTab
      Active = True
      Caption = 'dxRibbon1Tab1'
      Groups = <>
      Index = 0
    end
  end
  object dxRibbonStatusBar1: TdxRibbonStatusBar
    Left = 0
    Top = 1015
    Width = 2068
    Height = 46
    Margins.Left = 6
    Margins.Top = 6
    Margins.Right = 6
    Margins.Bottom = 6
    Color = clBtnFace
    Panels = <
      item
        PanelStyleClassName = 'TdxStatusBarTextPanelStyle'
      end>
    Ribbon = dxRibbon1
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clDefault
    Font.Height = -24
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    ExplicitLeft = -8
    ExplicitTop = 1789
    ExplicitWidth = 2785
  end
  object cxGroupBox2: TcxGroupBox
    Left = 0
    Top = 629
    Margins.Left = 6
    Margins.Top = 6
    Margins.Right = 6
    Margins.Bottom = 6
    Align = alBottom
    PanelStyle.Active = True
    PanelStyle.CaptionIndent = 4
    Style.BorderStyle = ebsNone
    TabOrder = 3
    ExplicitLeft = -160
    ExplicitTop = 1012
    ExplicitWidth = 2244
    Height = 386
    Width = 2068
    object cxGroupBox5: TcxGroupBox
      Left = 1266
      Top = 2
      Margins.Left = 6
      Margins.Top = 6
      Margins.Right = 6
      Margins.Bottom = 6
      Align = alRight
      PanelStyle.Active = True
      PanelStyle.CaptionIndent = 4
      TabOrder = 0
      ExplicitLeft = 1442
      Height = 382
      Width = 800
      object cxPageControl2: TcxPageControl
        Left = 2
        Top = 2
        Width = 796
        Height = 378
        Margins.Left = 6
        Margins.Top = 6
        Margins.Right = 6
        Margins.Bottom = 6
        Align = alClient
        TabOrder = 0
        Properties.ActivePage = cxTabSheet3
        Properties.CustomButtons.Buttons = <>
        ClientRectBottom = 374
        ClientRectLeft = 4
        ClientRectRight = 792
        ClientRectTop = 42
        object cxTabSheet6: TcxTabSheet
          Margins.Left = 6
          Margins.Top = 6
          Margins.Right = 6
          Margins.Bottom = 6
          Caption = 'Log Output'
          ImageIndex = 2
          object SyntaxMemoOutput: TSyntaxMemo
            Left = 0
            Top = 48
            Width = 788
            Height = 284
            Margins.Left = 6
            Margins.Top = 6
            Margins.Right = 6
            Margins.Bottom = 6
            TabList.AsString = '4'
            NonPrinted.Font.Charset = DEFAULT_CHARSET
            NonPrinted.Font.Color = clSilver
            NonPrinted.Font.Height = -11
            NonPrinted.Font.Name = 'MS Sans Serif'
            NonPrinted.Font.Style = []
            LineNumbers.UnderColor = clInactiveCaption
            LineNumbers.Alignment = taLeftJustify
            LineNumbers.Font.Charset = DEFAULT_CHARSET
            LineNumbers.Font.Color = clWindowText
            LineNumbers.Font.Height = -9
            LineNumbers.Font.Name = 'Courier New'
            LineNumbers.Font.Style = []
            LineNumbers.Band = 0
            Gutter.Width = 40
            Gutter.Images = imglGutterGlyphs
            Gutter.ExpandButtons.Data = {
              66020000424D66020000000000003600000028000000120000000A0000000100
              1800000000003002000000000000000000000000000000000000004184004184
              0041840041840041840041840041840041840041840041840041840041840041
              8400418400418400418400418400418400000000000000000000000000000000
              0000000000000000000000000000000000000000000000000000000000000000
              00000000000000000000000000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
              FFFF000000000000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF000000
              0000000000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF000000000000
              FFFFFFFFFFFFFFFFFF000000FFFFFFFFFFFFFFFFFF0000000000000000FFFFFF
              FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF000000000000FFFFFFFFFFFFFFFF
              FF000000FFFFFFFFFFFFFFFFFF0000000000000000FFFFFF0000000000000000
              00000000000000FFFFFF000000000000FFFFFF00000000000000000000000000
              0000FFFFFF0000000000000000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
              FFFF000000000000FFFFFFFFFFFFFFFFFF000000FFFFFFFFFFFFFFFFFF000000
              0000000000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF000000000000
              FFFFFFFFFFFFFFFFFF000000FFFFFFFFFFFFFFFFFF0000000000000000FFFFFF
              FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF000000000000FFFFFFFFFFFFFFFF
              FFFFFFFFFFFFFFFFFFFFFFFFFF00000000000000000000000000000000000000
              0000000000000000000000000000000000000000000000000000000000000000
              00000000000000000000}
            Gutter.Bands = <
              item
                Width = 10
              end
              item
                Width = 15
                RightBound = clWindow
              end
              item
                Width = 15
                Color = clWindow
                LeftBound = clInactiveCaption
              end>
            Gutter.Objects = <>
            Gutter.ExpBtnBand = -1
            Gutter.ShowSeparator = False
            Gutter.CollapsePen.Color = clGray
            Gutter.AutoSize = False
            HintProps.Font.Charset = DEFAULT_CHARSET
            HintProps.Font.Color = clWindowText
            HintProps.Font.Height = -11
            HintProps.Font.Name = 'MS Sans Serif'
            HintProps.Font.Style = []
            HintProps.Color = 13041663
            HintProps.ShowHints = [shScroll, shCollapsed, shGutter, shTokens]
            KeyMapping = SyntKeyMapping1
            UserRanges = <>
            UndoLimit = 0
            StaplePen.Color = clGray
            DefaultStyles.SelectioMark.Font.Charset = DEFAULT_CHARSET
            DefaultStyles.SelectioMark.Font.Color = clHighlightText
            DefaultStyles.SelectioMark.Font.Height = -13
            DefaultStyles.SelectioMark.Font.Name = 'Courier New'
            DefaultStyles.SelectioMark.Font.Style = []
            DefaultStyles.SelectioMark.BgColor = clHighlight
            DefaultStyles.SelectioMark.FormatType = ftColor
            DefaultStyles.SearchMark.Font.Charset = DEFAULT_CHARSET
            DefaultStyles.SearchMark.Font.Color = clWhite
            DefaultStyles.SearchMark.Font.Height = -13
            DefaultStyles.SearchMark.Font.Name = 'Courier New'
            DefaultStyles.SearchMark.Font.Style = []
            DefaultStyles.SearchMark.BgColor = clBlack
            DefaultStyles.SearchMark.FormatType = ftColor
            DefaultStyles.CurrentLine.Enabled = False
            DefaultStyles.CurrentLine.Font.Charset = DEFAULT_CHARSET
            DefaultStyles.CurrentLine.Font.Color = clWindowText
            DefaultStyles.CurrentLine.Font.Height = -13
            DefaultStyles.CurrentLine.Font.Name = 'Courier New'
            DefaultStyles.CurrentLine.Font.Style = []
            DefaultStyles.CurrentLine.FormatType = ftBackGround
            DefaultStyles.CollapseMark.Font.Charset = DEFAULT_CHARSET
            DefaultStyles.CollapseMark.Font.Color = clSilver
            DefaultStyles.CollapseMark.Font.Height = -13
            DefaultStyles.CollapseMark.Font.Name = 'Courier New'
            DefaultStyles.CollapseMark.Font.Style = []
            DefaultStyles.CollapseMark.FormatType = ftColor
            DefaultStyles.CollapseMark.BorderTypeLeft = blSolid
            DefaultStyles.CollapseMark.BorderColorLeft = clSilver
            DefaultStyles.CollapseMark.BorderTypeTop = blSolid
            DefaultStyles.CollapseMark.BorderColorTop = clSilver
            DefaultStyles.CollapseMark.BorderTypeRight = blSolid
            DefaultStyles.CollapseMark.BorderColorRight = clSilver
            DefaultStyles.CollapseMark.BorderTypeBottom = blSolid
            DefaultStyles.CollapseMark.BorderColorBottom = clSilver
            SyncEditing.SyncRangeStyle.Font.Charset = DEFAULT_CHARSET
            SyncEditing.SyncRangeStyle.Font.Color = clWindowText
            SyncEditing.SyncRangeStyle.Font.Height = -13
            SyncEditing.SyncRangeStyle.Font.Name = 'Courier New'
            SyncEditing.SyncRangeStyle.Font.Style = []
            SyncEditing.SyncRangeStyle.BgColor = 14745568
            SyncEditing.SyncRangeStyle.FormatType = ftBackGround
            SyncEditing.ActiveWordsStyle.Font.Charset = DEFAULT_CHARSET
            SyncEditing.ActiveWordsStyle.Font.Color = clWindowText
            SyncEditing.ActiveWordsStyle.Font.Height = -13
            SyncEditing.ActiveWordsStyle.Font.Name = 'Courier New'
            SyncEditing.ActiveWordsStyle.Font.Style = []
            SyncEditing.ActiveWordsStyle.FormatType = ftBackGround
            SyncEditing.ActiveWordsStyle.BorderTypeLeft = blSolid
            SyncEditing.ActiveWordsStyle.BorderColorLeft = clBlue
            SyncEditing.ActiveWordsStyle.BorderTypeTop = blSolid
            SyncEditing.ActiveWordsStyle.BorderColorTop = clBlue
            SyncEditing.ActiveWordsStyle.BorderTypeRight = blSolid
            SyncEditing.ActiveWordsStyle.BorderColorRight = clBlue
            SyncEditing.ActiveWordsStyle.BorderTypeBottom = blSolid
            SyncEditing.ActiveWordsStyle.BorderColorBottom = clBlue
            SyncEditing.InactiveWordsStyle.Font.Charset = DEFAULT_CHARSET
            SyncEditing.InactiveWordsStyle.Font.Color = clWindowText
            SyncEditing.InactiveWordsStyle.Font.Height = -13
            SyncEditing.InactiveWordsStyle.Font.Name = 'Courier New'
            SyncEditing.InactiveWordsStyle.Font.Style = []
            SyncEditing.InactiveWordsStyle.FormatType = ftBackGround
            SyncEditing.InactiveWordsStyle.BorderTypeBottom = blSolid
            SyncEditing.InactiveWordsStyle.BorderColorBottom = clBtnFace
            Options = [soOverwriteBlocks, soEnableBlockSel, soHideSelection, soHideDynamic, soAutoIndentMode, soBackUnindent, soGroupUndo, soDragText, soScrollLastLine, soSmartCaret]
            HorzRuler.Font.Charset = DEFAULT_CHARSET
            HorzRuler.Font.Color = clWindowText
            HorzRuler.Font.Height = -11
            HorzRuler.Font.Name = 'MS Sans Serif'
            HorzRuler.Font.Style = []
            TextMargins = <
              item
                Pen.Color = clSilver
                RulerMark = False
              end>
            Caret.Insert.Width = -2
            Caret.Overwrite.Width = 100
            Caret.ReadOnly.Width = -1
            Caret.Custom.Width = -2
            Transparent = False
            Alignment = taLeftJustify
            Align = alClient
            Ctl3D = True
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -24
            Font.Name = 'Courier New'
            Font.Style = []
            ParentColor = False
            ParentCtl3D = False
            ParentFont = False
            TabOrder = 0
          end
          object cxGroupBox8: TcxGroupBox
            Left = 0
            Top = 0
            Margins.Left = 6
            Margins.Top = 6
            Margins.Right = 6
            Margins.Bottom = 6
            Align = alTop
            PanelStyle.Active = True
            PanelStyle.CaptionIndent = 4
            TabOrder = 1
            Height = 48
            Width = 788
            object chkPreserveLog: TcxCheckBox
              Left = 10
              Top = 2
              Margins.Left = 6
              Margins.Top = 6
              Margins.Right = 6
              Margins.Bottom = 6
              Caption = 'Preserve Log'
              TabOrder = 0
            end
          end
        end
        object cxTabSheet3: TcxTabSheet
          Margins.Left = 6
          Margins.Top = 6
          Margins.Right = 6
          Margins.Bottom = 6
          Caption = 'Notes'
          ImageIndex = 1
          object SyntaxMemoNotes: TSyntaxMemo
            Left = 0
            Top = 0
            Width = 788
            Height = 332
            Margins.Left = 6
            Margins.Top = 6
            Margins.Right = 6
            Margins.Bottom = 6
            TabList.AsString = '4'
            NonPrinted.Font.Charset = DEFAULT_CHARSET
            NonPrinted.Font.Color = clSilver
            NonPrinted.Font.Height = -11
            NonPrinted.Font.Name = 'MS Sans Serif'
            NonPrinted.Font.Style = []
            LineNumbers.UnderColor = clInactiveCaption
            LineNumbers.Alignment = taLeftJustify
            LineNumbers.Font.Charset = DEFAULT_CHARSET
            LineNumbers.Font.Color = clWindowText
            LineNumbers.Font.Height = -9
            LineNumbers.Font.Name = 'Courier New'
            LineNumbers.Font.Style = []
            LineNumbers.Band = 0
            Gutter.Width = 40
            Gutter.Images = imglGutterGlyphs
            Gutter.ExpandButtons.Data = {
              66020000424D66020000000000003600000028000000120000000A0000000100
              1800000000003002000000000000000000000000000000000000004184004184
              0041840041840041840041840041840041840041840041840041840041840041
              8400418400418400418400418400418400000000000000000000000000000000
              0000000000000000000000000000000000000000000000000000000000000000
              00000000000000000000000000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
              FFFF000000000000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF000000
              0000000000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF000000000000
              FFFFFFFFFFFFFFFFFF000000FFFFFFFFFFFFFFFFFF0000000000000000FFFFFF
              FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF000000000000FFFFFFFFFFFFFFFF
              FF000000FFFFFFFFFFFFFFFFFF0000000000000000FFFFFF0000000000000000
              00000000000000FFFFFF000000000000FFFFFF00000000000000000000000000
              0000FFFFFF0000000000000000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
              FFFF000000000000FFFFFFFFFFFFFFFFFF000000FFFFFFFFFFFFFFFFFF000000
              0000000000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF000000000000
              FFFFFFFFFFFFFFFFFF000000FFFFFFFFFFFFFFFFFF0000000000000000FFFFFF
              FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF000000000000FFFFFFFFFFFFFFFF
              FFFFFFFFFFFFFFFFFFFFFFFFFF00000000000000000000000000000000000000
              0000000000000000000000000000000000000000000000000000000000000000
              00000000000000000000}
            Gutter.Bands = <
              item
                Width = 10
              end
              item
                Width = 15
                RightBound = clWindow
              end
              item
                Width = 15
                Color = clWindow
                LeftBound = clInactiveCaption
              end>
            Gutter.Objects = <>
            Gutter.ExpBtnBand = -1
            Gutter.ShowSeparator = False
            Gutter.CollapsePen.Color = clGray
            Gutter.AutoSize = False
            HintProps.Font.Charset = DEFAULT_CHARSET
            HintProps.Font.Color = clWindowText
            HintProps.Font.Height = -11
            HintProps.Font.Name = 'MS Sans Serif'
            HintProps.Font.Style = []
            HintProps.Color = 13041663
            HintProps.ShowHints = [shScroll, shCollapsed, shGutter, shTokens]
            KeyMapping = SyntKeyMapping1
            UserRanges = <>
            UndoLimit = 0
            StaplePen.Color = clGray
            DefaultStyles.SelectioMark.Font.Charset = DEFAULT_CHARSET
            DefaultStyles.SelectioMark.Font.Color = clHighlightText
            DefaultStyles.SelectioMark.Font.Height = -13
            DefaultStyles.SelectioMark.Font.Name = 'Courier New'
            DefaultStyles.SelectioMark.Font.Style = []
            DefaultStyles.SelectioMark.BgColor = clHighlight
            DefaultStyles.SelectioMark.FormatType = ftColor
            DefaultStyles.SearchMark.Font.Charset = DEFAULT_CHARSET
            DefaultStyles.SearchMark.Font.Color = clWhite
            DefaultStyles.SearchMark.Font.Height = -13
            DefaultStyles.SearchMark.Font.Name = 'Courier New'
            DefaultStyles.SearchMark.Font.Style = []
            DefaultStyles.SearchMark.BgColor = clBlack
            DefaultStyles.SearchMark.FormatType = ftColor
            DefaultStyles.CurrentLine.Enabled = False
            DefaultStyles.CurrentLine.Font.Charset = DEFAULT_CHARSET
            DefaultStyles.CurrentLine.Font.Color = clWindowText
            DefaultStyles.CurrentLine.Font.Height = -13
            DefaultStyles.CurrentLine.Font.Name = 'Courier New'
            DefaultStyles.CurrentLine.Font.Style = []
            DefaultStyles.CurrentLine.FormatType = ftBackGround
            DefaultStyles.CollapseMark.Font.Charset = DEFAULT_CHARSET
            DefaultStyles.CollapseMark.Font.Color = clSilver
            DefaultStyles.CollapseMark.Font.Height = -13
            DefaultStyles.CollapseMark.Font.Name = 'Courier New'
            DefaultStyles.CollapseMark.Font.Style = []
            DefaultStyles.CollapseMark.FormatType = ftColor
            DefaultStyles.CollapseMark.BorderTypeLeft = blSolid
            DefaultStyles.CollapseMark.BorderColorLeft = clSilver
            DefaultStyles.CollapseMark.BorderTypeTop = blSolid
            DefaultStyles.CollapseMark.BorderColorTop = clSilver
            DefaultStyles.CollapseMark.BorderTypeRight = blSolid
            DefaultStyles.CollapseMark.BorderColorRight = clSilver
            DefaultStyles.CollapseMark.BorderTypeBottom = blSolid
            DefaultStyles.CollapseMark.BorderColorBottom = clSilver
            SyncEditing.SyncRangeStyle.Font.Charset = DEFAULT_CHARSET
            SyncEditing.SyncRangeStyle.Font.Color = clWindowText
            SyncEditing.SyncRangeStyle.Font.Height = -13
            SyncEditing.SyncRangeStyle.Font.Name = 'Courier New'
            SyncEditing.SyncRangeStyle.Font.Style = []
            SyncEditing.SyncRangeStyle.BgColor = 14745568
            SyncEditing.SyncRangeStyle.FormatType = ftBackGround
            SyncEditing.ActiveWordsStyle.Font.Charset = DEFAULT_CHARSET
            SyncEditing.ActiveWordsStyle.Font.Color = clWindowText
            SyncEditing.ActiveWordsStyle.Font.Height = -13
            SyncEditing.ActiveWordsStyle.Font.Name = 'Courier New'
            SyncEditing.ActiveWordsStyle.Font.Style = []
            SyncEditing.ActiveWordsStyle.FormatType = ftBackGround
            SyncEditing.ActiveWordsStyle.BorderTypeLeft = blSolid
            SyncEditing.ActiveWordsStyle.BorderColorLeft = clBlue
            SyncEditing.ActiveWordsStyle.BorderTypeTop = blSolid
            SyncEditing.ActiveWordsStyle.BorderColorTop = clBlue
            SyncEditing.ActiveWordsStyle.BorderTypeRight = blSolid
            SyncEditing.ActiveWordsStyle.BorderColorRight = clBlue
            SyncEditing.ActiveWordsStyle.BorderTypeBottom = blSolid
            SyncEditing.ActiveWordsStyle.BorderColorBottom = clBlue
            SyncEditing.InactiveWordsStyle.Font.Charset = DEFAULT_CHARSET
            SyncEditing.InactiveWordsStyle.Font.Color = clWindowText
            SyncEditing.InactiveWordsStyle.Font.Height = -13
            SyncEditing.InactiveWordsStyle.Font.Name = 'Courier New'
            SyncEditing.InactiveWordsStyle.Font.Style = []
            SyncEditing.InactiveWordsStyle.FormatType = ftBackGround
            SyncEditing.InactiveWordsStyle.BorderTypeBottom = blSolid
            SyncEditing.InactiveWordsStyle.BorderColorBottom = clBtnFace
            Options = [soOverwriteBlocks, soEnableBlockSel, soHideSelection, soHideDynamic, soAutoIndentMode, soBackUnindent, soGroupUndo, soDragText, soScrollLastLine, soSmartCaret]
            HorzRuler.Font.Charset = DEFAULT_CHARSET
            HorzRuler.Font.Color = clWindowText
            HorzRuler.Font.Height = -11
            HorzRuler.Font.Name = 'MS Sans Serif'
            HorzRuler.Font.Style = []
            TextMargins = <
              item
                Pen.Color = clSilver
                RulerMark = False
              end>
            Caret.Insert.Width = -2
            Caret.Overwrite.Width = 100
            Caret.ReadOnly.Width = -1
            Caret.Custom.Width = -2
            Transparent = False
            Alignment = taLeftJustify
            Align = alClient
            Ctl3D = True
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -24
            Font.Name = 'Courier New'
            Font.Style = []
            ParentColor = False
            ParentCtl3D = False
            ParentFont = False
            TabOrder = 0
          end
        end
      end
    end
    object cxGroupBox6: TcxGroupBox
      Left = 2
      Top = 2
      Margins.Left = 6
      Margins.Top = 6
      Margins.Right = 6
      Margins.Bottom = 6
      Align = alClient
      PanelStyle.Active = True
      PanelStyle.CaptionIndent = 4
      TabOrder = 1
      ExplicitWidth = 1424
      Height = 382
      Width = 1248
      object cxPageControl1: TcxPageControl
        Left = 2
        Top = 2
        Width = 1244
        Height = 378
        Margins.Left = 6
        Margins.Top = 6
        Margins.Right = 6
        Margins.Bottom = 6
        Align = alClient
        TabOrder = 0
        Properties.ActivePage = cxTabSheet2
        Properties.CustomButtons.Buttons = <>
        ExplicitWidth = 1420
        ClientRectBottom = 374
        ClientRectLeft = 4
        ClientRectRight = 1240
        ClientRectTop = 42
        object cxTabSheet1: TcxTabSheet
          Margins.Left = 6
          Margins.Top = 6
          Margins.Right = 6
          Margins.Bottom = 6
          Caption = 'Info'
          ImageIndex = 0
          ExplicitWidth = 1412
          object cxTreeWatch: TcxTreeList
            Left = 0
            Top = 0
            Width = 1236
            Height = 332
            Margins.Left = 6
            Margins.Top = 6
            Margins.Right = 6
            Margins.Bottom = 6
            Align = alClient
            Bands = <
              item
                MinWidth = 40
              end>
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -24
            Font.Name = 'MS Sans Serif'
            Font.Style = []
            Images = cxImageList2
            OptionsBehavior.CellHints = True
            OptionsView.ColumnAutoWidth = True
            OptionsView.FixedSeparatorWidth = 4
            OptionsView.IndicatorWidth = 24
            OptionsView.NavigatorOffset = 100
            ParentFont = False
            Preview.LeftIndent = 10
            Preview.RightIndent = 10
            ScrollbarAnnotations.CustomAnnotations = <>
            TabOrder = 0
            ExplicitWidth = 1412
            object cxTreeWatchColumn1: TcxTreeListColumn
              PropertiesClassName = 'TcxTextEditProperties'
              Caption.Text = 'Variable'
              MinWidth = 40
              Options.Editing = False
              Width = 282
              Position.ColIndex = 0
              Position.RowIndex = 0
              Position.BandIndex = 0
              SortOrder = soAscending
              SortIndex = 0
              Summary.FooterSummaryItems = <>
              Summary.GroupFooterSummaryItems = <>
            end
            object cxTreeWatchColumn2: TcxTreeListColumn
              PropertiesClassName = 'TcxTextEditProperties'
              Caption.Text = 'Value'
              MinWidth = 40
              Options.Editing = False
              Width = 1408
              Position.ColIndex = 1
              Position.RowIndex = 0
              Position.BandIndex = 0
              Summary.FooterSummaryItems = <>
              Summary.GroupFooterSummaryItems = <>
            end
            object cxTreeWatchColumn3: TcxTreeListColumn
              Visible = False
              Caption.Text = 'Path'
              MinWidth = 40
              Width = 200
              Position.ColIndex = 2
              Position.RowIndex = 0
              Position.BandIndex = 0
              Summary.FooterSummaryItems = <>
              Summary.GroupFooterSummaryItems = <>
            end
          end
        end
        object cxTabSheet2: TcxTabSheet
          Margins.Left = 6
          Margins.Top = 6
          Margins.Right = 6
          Margins.Bottom = 6
          Caption = 'Watch List'
          ImageIndex = 1
          ExplicitWidth = 1412
          object cxTreeWatches: TcxTreeList
            Left = 0
            Top = 0
            Width = 1236
            Height = 266
            Margins.Left = 6
            Margins.Top = 6
            Margins.Right = 6
            Margins.Bottom = 6
            Align = alClient
            Bands = <
              item
                MinWidth = 40
              end>
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -24
            Font.Name = 'MS Sans Serif'
            Font.Style = []
            Images = cxImageList2
            OptionsBehavior.CellHints = True
            OptionsView.ColumnAutoWidth = True
            OptionsView.FixedSeparatorWidth = 4
            OptionsView.IndicatorWidth = 24
            OptionsView.NavigatorOffset = 100
            ParentFont = False
            Preview.LeftIndent = 10
            Preview.RightIndent = 10
            ScrollbarAnnotations.CustomAnnotations = <>
            TabOrder = 0
            ExplicitWidth = 1412
            object cxTreeListColumn1: TcxTreeListColumn
              PropertiesClassName = 'TcxTextEditProperties'
              Styles.Content = cxStyle1
              Caption.Text = 'Variable'
              MinWidth = 40
              Options.Editing = False
              Width = 382
              Position.ColIndex = 0
              Position.RowIndex = 0
              Position.BandIndex = 0
              SortOrder = soAscending
              SortIndex = 0
              Summary.FooterSummaryItems = <>
              Summary.GroupFooterSummaryItems = <>
            end
            object cxTreeListColumn2: TcxTreeListColumn
              PropertiesClassName = 'TcxTextEditProperties'
              Caption.Text = 'Value'
              MinWidth = 40
              Options.Editing = False
              Width = 1308
              Position.ColIndex = 1
              Position.RowIndex = 0
              Position.BandIndex = 0
              Summary.FooterSummaryItems = <>
              Summary.GroupFooterSummaryItems = <>
            end
            object cxTreeListColumn3: TcxTreeListColumn
              Visible = False
              Caption.Text = 'Path'
              MinWidth = 40
              Width = 200
              Position.ColIndex = 2
              Position.RowIndex = 0
              Position.BandIndex = 0
              Summary.FooterSummaryItems = <>
              Summary.GroupFooterSummaryItems = <>
            end
          end
          object cxGroupBox4: TcxGroupBox
            Left = 0
            Top = 266
            Margins.Left = 6
            Margins.Top = 6
            Margins.Right = 6
            Margins.Bottom = 6
            Align = alBottom
            PanelStyle.Active = True
            PanelStyle.CaptionIndent = 4
            TabOrder = 1
            ExplicitWidth = 1412
            Height = 66
            Width = 1236
            object cxButton1: TcxButton
              Left = 8
              Top = 8
              Width = 180
              Height = 50
              Margins.Left = 6
              Margins.Top = 6
              Margins.Right = 6
              Margins.Bottom = 6
              Action = actAddWatch
              OptionsImage.Spacing = 8
              TabOrder = 0
            end
            object cxButton2: TcxButton
              Left = 192
              Top = 8
              Width = 180
              Height = 50
              Margins.Left = 6
              Margins.Top = 6
              Margins.Right = 6
              Margins.Bottom = 6
              Action = actDelWatch
              OptionsImage.Spacing = 8
              TabOrder = 1
            end
          end
        end
      end
    end
    object cxSplitter2: TcxSplitter
      Left = 1250
      Top = 2
      Width = 16
      Height = 382
      Margins.Left = 6
      Margins.Top = 6
      Margins.Right = 6
      Margins.Bottom = 6
      AlignSplitter = salRight
      DragThreshold = 6
      PositionAfterOpen = 60
      MinSize = 60
      Control = cxGroupBox5
      ExplicitLeft = 1426
    end
  end
  object cxSplitter1: TcxSplitter
    Left = 0
    Top = 613
    Width = 2068
    Height = 16
    Margins.Left = 6
    Margins.Top = 6
    Margins.Right = 6
    Margins.Bottom = 6
    HotZoneClassName = 'TcxXPTaskBarStyle'
    AlignSplitter = salBottom
    DragThreshold = 6
    PositionAfterOpen = 60
    MinSize = 60
    Control = cxGroupBox2
    ExplicitTop = 1404
    ExplicitWidth = 2785
  end
  object cxGroupBox7: TcxGroupBox
    Left = 0
    Top = 72
    Margins.Left = 6
    Margins.Top = 6
    Margins.Right = 6
    Margins.Bottom = 6
    Align = alClient
    PanelStyle.Active = True
    PanelStyle.CaptionIndent = 4
    TabOrder = 8
    ExplicitWidth = 2785
    ExplicitHeight = 1285
    Height = 541
    Width = 2068
    object cxGroupBox1: TcxGroupBox
      Left = 2
      Top = 2
      Margins.Left = 6
      Margins.Top = 6
      Margins.Right = 6
      Margins.Bottom = 6
      Align = alClient
      PanelStyle.Active = True
      PanelStyle.CaptionIndent = 4
      TabOrder = 0
      ExplicitWidth = 1722
      ExplicitHeight = 1016
      Height = 537
      Width = 1546
      object SyntaxMemoProduction: TSyntaxMemo
        Left = 2
        Top = 2
        Width = 1542
        Height = 533
        Margins.Left = 6
        Margins.Top = 6
        Margins.Right = 6
        Margins.Bottom = 6
        Lines.Strings = (
          'program Test;'
          ''
          'procedure TestProc;'
          'BEGIN'
          '  DoNothing;'
          'end;'
          ''
          'var'
          '  i: integer;'
          'begin'
          '  while TRUE do'
          '    TestProc;'
          'end.')
        TabList.AsString = '4'
        NonPrinted.Font.Charset = DEFAULT_CHARSET
        NonPrinted.Font.Color = clSilver
        NonPrinted.Font.Height = -11
        NonPrinted.Font.Name = 'MS Sans Serif'
        NonPrinted.Font.Style = []
        LineNumbers.UnderColor = clInactiveCaption
        LineNumbers.Alignment = taLeftJustify
        LineNumbers.Font.Charset = DEFAULT_CHARSET
        LineNumbers.Font.Color = clWindowText
        LineNumbers.Font.Height = -9
        LineNumbers.Font.Name = 'Courier New'
        LineNumbers.Font.Style = []
        LineNumbers.Band = 0
        Gutter.Width = 40
        Gutter.Images = imglGutterGlyphs
        Gutter.ExpandButtons.Data = {
          66020000424D66020000000000003600000028000000120000000A0000000100
          1800000000003002000000000000000000000000000000000000004184004184
          0041840041840041840041840041840041840041840041840041840041840041
          8400418400418400418400418400418400000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          00000000000000000000000000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
          FFFF000000000000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF000000
          0000000000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF000000000000
          FFFFFFFFFFFFFFFFFF000000FFFFFFFFFFFFFFFFFF0000000000000000FFFFFF
          FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF000000000000FFFFFFFFFFFFFFFF
          FF000000FFFFFFFFFFFFFFFFFF0000000000000000FFFFFF0000000000000000
          00000000000000FFFFFF000000000000FFFFFF00000000000000000000000000
          0000FFFFFF0000000000000000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
          FFFF000000000000FFFFFFFFFFFFFFFFFF000000FFFFFFFFFFFFFFFFFF000000
          0000000000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF000000000000
          FFFFFFFFFFFFFFFFFF000000FFFFFFFFFFFFFFFFFF0000000000000000FFFFFF
          FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF000000000000FFFFFFFFFFFFFFFF
          FFFFFFFFFFFFFFFFFFFFFFFFFF00000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          00000000000000000000}
        Gutter.Bands = <
          item
            Width = 10
          end
          item
            Width = 15
            RightBound = clWindow
          end
          item
            Width = 15
            Color = clWindow
            LeftBound = clInactiveCaption
          end>
        Gutter.Objects = <
          item
            ImageIndex = 0
            Band = 1
            Tag = 0
          end
          item
            ImageIndex = 1
            Band = 1
            ForeColor = clWhite
            BgColor = clTeal
            SelInvertColors = True
            Tag = 0
          end
          item
            ImageIndex = 2
            Band = 1
            ForeColor = clWhite
            BgColor = clRed
            SelInvertColors = True
            Tag = 0
          end
          item
            ImageIndex = 4
            Band = 1
            BgColor = clSilver
            Tag = 0
          end
          item
            ImageIndex = 3
            Band = 1
            ForeColor = clWhite
            BgColor = clRed
            SelInvertColors = True
            Tag = 0
          end>
        Gutter.ExpBtnBand = -1
        Gutter.ShowSeparator = False
        Gutter.CollapsePen.Color = clGray
        Gutter.AutoSize = False
        HintProps.Font.Charset = DEFAULT_CHARSET
        HintProps.Font.Color = clWindowText
        HintProps.Font.Height = -11
        HintProps.Font.Name = 'MS Sans Serif'
        HintProps.Font.Style = []
        HintProps.Color = 13041663
        HintProps.ShowHints = [shScroll, shCollapsed, shGutter, shTokens]
        KeyMapping = SyntKeyMapping1
        UserRanges = <>
        UndoLimit = 0
        StaplePen.Color = clGray
        DefaultStyles.SelectioMark.Font.Charset = DEFAULT_CHARSET
        DefaultStyles.SelectioMark.Font.Color = clHighlightText
        DefaultStyles.SelectioMark.Font.Height = -13
        DefaultStyles.SelectioMark.Font.Name = 'Courier New'
        DefaultStyles.SelectioMark.Font.Style = []
        DefaultStyles.SelectioMark.BgColor = clHighlight
        DefaultStyles.SelectioMark.FormatType = ftColor
        DefaultStyles.SearchMark.Font.Charset = DEFAULT_CHARSET
        DefaultStyles.SearchMark.Font.Color = clWhite
        DefaultStyles.SearchMark.Font.Height = -13
        DefaultStyles.SearchMark.Font.Name = 'Courier New'
        DefaultStyles.SearchMark.Font.Style = []
        DefaultStyles.SearchMark.BgColor = clBlack
        DefaultStyles.SearchMark.FormatType = ftColor
        DefaultStyles.CurrentLine.Enabled = False
        DefaultStyles.CurrentLine.Font.Charset = DEFAULT_CHARSET
        DefaultStyles.CurrentLine.Font.Color = clWindowText
        DefaultStyles.CurrentLine.Font.Height = -13
        DefaultStyles.CurrentLine.Font.Name = 'Courier New'
        DefaultStyles.CurrentLine.Font.Style = []
        DefaultStyles.CurrentLine.FormatType = ftBackGround
        DefaultStyles.CollapseMark.Font.Charset = DEFAULT_CHARSET
        DefaultStyles.CollapseMark.Font.Color = clSilver
        DefaultStyles.CollapseMark.Font.Height = -13
        DefaultStyles.CollapseMark.Font.Name = 'Courier New'
        DefaultStyles.CollapseMark.Font.Style = []
        DefaultStyles.CollapseMark.FormatType = ftColor
        DefaultStyles.CollapseMark.BorderTypeLeft = blSolid
        DefaultStyles.CollapseMark.BorderColorLeft = clSilver
        DefaultStyles.CollapseMark.BorderTypeTop = blSolid
        DefaultStyles.CollapseMark.BorderColorTop = clSilver
        DefaultStyles.CollapseMark.BorderTypeRight = blSolid
        DefaultStyles.CollapseMark.BorderColorRight = clSilver
        DefaultStyles.CollapseMark.BorderTypeBottom = blSolid
        DefaultStyles.CollapseMark.BorderColorBottom = clSilver
        SyncEditing.SyncRangeStyle.Font.Charset = DEFAULT_CHARSET
        SyncEditing.SyncRangeStyle.Font.Color = clWindowText
        SyncEditing.SyncRangeStyle.Font.Height = -13
        SyncEditing.SyncRangeStyle.Font.Name = 'Courier New'
        SyncEditing.SyncRangeStyle.Font.Style = []
        SyncEditing.SyncRangeStyle.BgColor = 14745568
        SyncEditing.SyncRangeStyle.FormatType = ftBackGround
        SyncEditing.ActiveWordsStyle.Font.Charset = DEFAULT_CHARSET
        SyncEditing.ActiveWordsStyle.Font.Color = clWindowText
        SyncEditing.ActiveWordsStyle.Font.Height = -13
        SyncEditing.ActiveWordsStyle.Font.Name = 'Courier New'
        SyncEditing.ActiveWordsStyle.Font.Style = []
        SyncEditing.ActiveWordsStyle.FormatType = ftBackGround
        SyncEditing.ActiveWordsStyle.BorderTypeLeft = blSolid
        SyncEditing.ActiveWordsStyle.BorderColorLeft = clBlue
        SyncEditing.ActiveWordsStyle.BorderTypeTop = blSolid
        SyncEditing.ActiveWordsStyle.BorderColorTop = clBlue
        SyncEditing.ActiveWordsStyle.BorderTypeRight = blSolid
        SyncEditing.ActiveWordsStyle.BorderColorRight = clBlue
        SyncEditing.ActiveWordsStyle.BorderTypeBottom = blSolid
        SyncEditing.ActiveWordsStyle.BorderColorBottom = clBlue
        SyncEditing.InactiveWordsStyle.Font.Charset = DEFAULT_CHARSET
        SyncEditing.InactiveWordsStyle.Font.Color = clWindowText
        SyncEditing.InactiveWordsStyle.Font.Height = -13
        SyncEditing.InactiveWordsStyle.Font.Name = 'Courier New'
        SyncEditing.InactiveWordsStyle.Font.Style = []
        SyncEditing.InactiveWordsStyle.FormatType = ftBackGround
        SyncEditing.InactiveWordsStyle.BorderTypeBottom = blSolid
        SyncEditing.InactiveWordsStyle.BorderColorBottom = clBtnFace
        Options = [soOverwriteBlocks, soEnableBlockSel, soHideSelection, soHideDynamic, soAutoIndentMode, soBackUnindent, soGroupUndo, soDragText, soScrollLastLine, soSmartCaret]
        HorzRuler.Font.Charset = DEFAULT_CHARSET
        HorzRuler.Font.Color = clWindowText
        HorzRuler.Font.Height = -11
        HorzRuler.Font.Name = 'MS Sans Serif'
        HorzRuler.Font.Style = []
        TextMargins = <
          item
            Pen.Color = clSilver
            RulerMark = False
          end>
        Caret.Insert.Width = -2
        Caret.Overwrite.Width = 100
        Caret.ReadOnly.Width = -1
        Caret.Custom.Width = -2
        Transparent = False
        Alignment = taLeftJustify
        Align = alClient
        Ctl3D = True
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -24
        Font.Name = 'Courier New'
        Font.Style = []
        ParentColor = False
        ParentCtl3D = False
        ParentFont = False
        TabOrder = 0
        OnCaretPosChanged = SyntaxMemoProductionCaretPosChanged
        OnGutterClick = SyntaxMemoProductionGutterClick
        OnGetTokenHint = SyntaxMemoProductionGetTokenHint
        OnChange = SyntaxMemoProductionChange
        OnIncSearchChange = SyntaxMemoProductionIncSearchChange
        OnTextChanged = SyntaxMemoProductionTextChanged
        OnSelectionChanged = SyntaxMemoProductionSelectionChanged
        OnDblClick = SyntaxMemoProductionDblClick
        OnEnter = SyntaxMemoProductionEnter
        ExplicitLeft = 8
        ExplicitWidth = 2259
        ExplicitHeight = 1025
      end
    end
    object cxGroupBox3: TcxGroupBox
      Left = 1564
      Top = 2
      Margins.Left = 6
      Margins.Top = 6
      Margins.Right = 6
      Margins.Bottom = 6
      Align = alRight
      PanelStyle.Active = True
      PanelStyle.CaptionIndent = 4
      TabOrder = 1
      ExplicitLeft = 1740
      ExplicitHeight = 1016
      Height = 537
      Width = 502
      object cxTreeListVariables: TcxTreeList
        Left = 2
        Top = 2
        Width = 498
        Height = 533
        Margins.Left = 6
        Margins.Top = 6
        Margins.Right = 6
        Margins.Bottom = 6
        Align = alClient
        Bands = <
          item
            MinWidth = 40
          end>
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -24
        Font.Name = 'MS Sans Serif'
        Font.Style = []
        OptionsView.ColumnAutoWidth = True
        OptionsView.FixedSeparatorWidth = 4
        OptionsView.IndicatorWidth = 24
        OptionsView.NavigatorOffset = 100
        OptionsView.ShowRoot = False
        OptionsView.TreeLineStyle = tllsNone
        ParentFont = False
        Preview.LeftIndent = 10
        Preview.RightIndent = 10
        ScrollbarAnnotations.CustomAnnotations = <>
        TabOrder = 0
        ExplicitHeight = 1012
        object cxCol1: TcxTreeListColumn
          PropertiesClassName = 'TcxTextEditProperties'
          Properties.ReadOnly = True
          Caption.Text = 'Variables'
          MinWidth = 40
          Width = 200
          Position.ColIndex = 0
          Position.RowIndex = 0
          Position.BandIndex = 0
          SortOrder = soAscending
          SortIndex = 0
          Summary.FooterSummaryItems = <>
          Summary.GroupFooterSummaryItems = <>
        end
        object cxCol2: TcxTreeListColumn
          PropertiesClassName = 'TcxTextEditProperties'
          Caption.Text = 'Values'
          MinWidth = 40
          Width = 200
          Position.ColIndex = 1
          Position.RowIndex = 0
          Position.BandIndex = 0
          Summary.FooterSummaryItems = <>
          Summary.GroupFooterSummaryItems = <>
        end
        object cxCol3: TcxTreeListColumn
          PropertiesClassName = 'TcxTextEditProperties'
          Caption.Text = 'Field Value'
          MinWidth = 40
          Width = 200
          Position.ColIndex = 2
          Position.RowIndex = 0
          Position.BandIndex = 0
          Summary.FooterSummaryItems = <>
          Summary.GroupFooterSummaryItems = <>
        end
      end
    end
    object cxSplitter3: TcxSplitter
      Left = 1548
      Top = 2
      Width = 16
      Height = 537
      Margins.Left = 6
      Margins.Top = 6
      Margins.Right = 6
      Margins.Bottom = 6
      HotZoneClassName = 'TcxXPTaskBarStyle'
      AlignSplitter = salRight
      DragThreshold = 6
      PositionAfterOpen = 60
      MinSize = 60
      Control = cxGroupBox3
      ExplicitLeft = 1724
      ExplicitHeight = 1016
    end
  end
  object SyntFindDialog1: TSyntFindDialog
    Flags = []
    NoSearchMsg = 'Search string '#39'%s'#39' not found.'
    Left = 800
    Top = 1100
  end
  object SyntReplaceDialog1: TSyntReplaceDialog
    Flags = []
    NoSearchMsg = 'Search string '#39'%s'#39' not found.'
    ReplacePrompt = 'Replace this occurence of '#39'%s'#39'?'
    Left = 684
    Top = 834
  end
  object PrinterSetupDialog1: TPrinterSetupDialog
    Left = 1808
    Top = 916
  end
  object SyntAutoReplace1: TSyntAutoReplace
    CaseConsistancy = False
    Left = 208
    Top = 608
  end
  object AutoCompleteFSScript: TAutoCompletePopup
    Styles = SyntStyles2
    StartString = '.'
    SortType = asDisplayItems
    OnGetAutoCompleteList = AutoCompleteFSScriptGetAutoCompleteList
    OnBeforeComplete = AutoCompleteFSScriptBeforeComplete
    OnAfterComplete = AutoCompleteFSScriptAfterComplete
    OnFilter = AutoCompleteFSScriptFilter
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    IntegralHeight = True
    ItemHeight = 16
    BgColor = clWindow
    Width = 600
    Height = 200
    ToolHint.Left = 0
    ToolHint.Top = 0
    ToolHint.Width = 600
    ToolHint.Height = 0
    ToolHint.MinMaxWidth = 600
    ToolHint.Text = ''
    Controls = <>
    Left = 208
    Top = 72
  end
  object ecSyntPrinter1: TecSyntPrinter
    MarginLeft = 0.250000000000000000
    MarginRight = 0.256666666666666700
    MarginTop = 0.250000000000000000
    MarginBottom = 0.201666666666666700
    Orientation = poPortrait
    FontHeader.Charset = DEFAULT_CHARSET
    FontHeader.Color = clWindowText
    FontHeader.Height = -13
    FontHeader.Name = 'Courier New'
    FontHeader.Style = []
    FontFooter.Charset = DEFAULT_CHARSET
    FontFooter.Color = clWindowText
    FontFooter.Height = -13
    FontFooter.Name = 'Courier New'
    FontFooter.Style = []
    Copies = 1
    Options = [mpWordWrap, mpBlockHighlight, mpBackColor]
    FontLineNumders.Charset = DEFAULT_CHARSET
    FontLineNumders.Color = clWindowText
    FontLineNumders.Height = -11
    FontLineNumders.Name = 'Courier New'
    FontLineNumders.Style = []
    LineNumbersPos = lnpNone
    PrintSelection = False
    Left = 1516
    Top = 576
  end
  object SyntStyles1: TSyntStyles
    Styles = <>
    Left = 420
    Top = 770
  end
  object SyntStyles2: TSyntStyles
    Styles = <
      item
        DisplayName = 'Bold'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clBlack
        Font.Height = -13
        Font.Name = 'Courier New'
        Font.Style = [fsBold]
      end
      item
        DisplayName = 'function'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clNavy
        Font.Height = -13
        Font.Name = 'Courier New'
        Font.Style = []
        FormatType = ftColor
      end
      item
        DisplayName = 'procedure'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clTeal
        Font.Height = -13
        Font.Name = 'Courier New'
        Font.Style = []
        FormatType = ftColor
      end>
    Left = 412
    Top = 894
  end
  object SyntKeyMapping1: TSyntKeyMapping
    Items = <
      item
        Command = 1
        KeyStrokes = <
          item
            KeyDefs = <
              item
                ShortCut = 37
              end>
          end>
        Caption = '&Left'
        Category = 'Navigation, no select'
        DisplayName = 'Move cursor left one char'
      end
      item
        Command = 2
        KeyStrokes = <
          item
            KeyDefs = <
              item
                ShortCut = 39
              end>
          end>
        Caption = '&Right'
        Category = 'Navigation, no select'
        DisplayName = 'Move cursor right one char'
      end
      item
        Command = 3
        KeyStrokes = <
          item
            KeyDefs = <
              item
                ShortCut = 38
              end>
          end>
        Caption = '&Up'
        Category = 'Navigation, no select'
        DisplayName = 'Move cursor up one line'
      end
      item
        Command = 4
        KeyStrokes = <
          item
            KeyDefs = <
              item
                ShortCut = 40
              end>
          end>
        Caption = '&Down'
        Category = 'Navigation, no select'
        DisplayName = 'Move cursor down one line'
      end
      item
        Command = 5
        KeyStrokes = <
          item
            KeyDefs = <
              item
                ShortCut = 16421
              end>
          end>
        Caption = 'Word Left'
        Category = 'Navigation, no select'
        DisplayName = 'Move cursor left one word'
      end
      item
        Command = 6
        KeyStrokes = <
          item
            KeyDefs = <
              item
                ShortCut = 16423
              end>
          end>
        Caption = 'Word Right'
        Category = 'Navigation, no select'
        DisplayName = 'Move cursor right one word'
      end
      item
        Command = 7
        KeyStrokes = <>
        Caption = 'Begin of Line'
        Category = 'Navigation, no select'
        DisplayName = 'Move cursor to beginning of line'
      end
      item
        Command = 8
        KeyStrokes = <>
        Caption = 'End of Line'
        Category = 'Navigation, no select'
        DisplayName = 'Move cursor to end of line'
      end
      item
        Command = 9
        KeyStrokes = <
          item
            KeyDefs = <
              item
                ShortCut = 33
              end>
          end>
        Caption = 'Page Up'
        Category = 'Navigation, no select'
        DisplayName = 'Move cursor up one page'
      end
      item
        Command = 10
        KeyStrokes = <
          item
            KeyDefs = <
              item
                ShortCut = 34
              end>
          end>
        Caption = 'Page Down'
        Category = 'Navigation, no select'
        DisplayName = 'Move cursor down one page'
      end
      item
        Command = 11
        KeyStrokes = <>
        Caption = 'Page Left'
        Category = 'Navigation, no select'
        DisplayName = 'Move cursor right one page'
      end
      item
        Command = 12
        KeyStrokes = <>
        Caption = 'Page Right'
        Category = 'Navigation, no select'
        DisplayName = 'Move cursor left one page'
      end
      item
        Command = 13
        KeyStrokes = <
          item
            KeyDefs = <
              item
                ShortCut = 16417
              end>
          end>
        Caption = 'Top of Page'
        Category = 'Navigation, no select'
        DisplayName = 'Move cursor to top of page'
      end
      item
        Command = 14
        KeyStrokes = <
          item
            KeyDefs = <
              item
                ShortCut = 16418
              end>
          end>
        Caption = 'Bottom of Page'
        Category = 'Navigation, no select'
        DisplayName = 'Move cursor to bottom of page'
      end
      item
        Command = 15
        KeyStrokes = <
          item
            KeyDefs = <
              item
                ShortCut = 16420
              end>
          end>
        Caption = 'Begin of Text'
        Category = 'Navigation, no select'
        DisplayName = 'Move cursor to absolute beginning'
      end
      item
        Command = 16
        KeyStrokes = <
          item
            KeyDefs = <
              item
                ShortCut = 16419
              end>
          end>
        Caption = 'End of Text'
        Category = 'Navigation, no select'
        DisplayName = 'Move cursor to absolute end'
      end
      item
        Command = 18
        KeyStrokes = <
          item
            KeyDefs = <
              item
                ShortCut = 36
              end>
          end>
        Caption = 'First Char'
        Category = 'Navigation, no select'
        DisplayName = 'Move cursor to first char of line'
      end
      item
        Command = 19
        KeyStrokes = <
          item
            KeyDefs = <
              item
                ShortCut = 35
              end>
          end>
        Caption = 'Last Char'
        Category = 'Navigation, no select'
        DisplayName = 'Move cursor to last char of line'
      end
      item
        Command = 20
        KeyStrokes = <>
        Caption = 'Left-up'
        Category = 'Navigation, no select'
        DisplayName = 'Move cursor left and up at line start'
      end
      item
        Command = 17
        KeyStrokes = <>
        Customizable = False
        Category = 'Navigation, no select'
        DisplayName = 'Move cursor to specified position'
      end
      item
        Command = 101
        KeyStrokes = <
          item
            KeyDefs = <
              item
                ShortCut = 8229
              end>
          end>
        Category = 'Navigation, normal select'
        DisplayName = 'Move cursor and select left one char'
      end
      item
        Command = 102
        KeyStrokes = <
          item
            KeyDefs = <
              item
                ShortCut = 8231
              end>
          end>
        Category = 'Navigation, normal select'
        DisplayName = 'Move cursor and select right one char'
      end
      item
        Command = 103
        KeyStrokes = <
          item
            KeyDefs = <
              item
                ShortCut = 8230
              end>
          end>
        Category = 'Navigation, normal select'
        DisplayName = 'Move cursor and select up one line'
      end
      item
        Command = 104
        KeyStrokes = <
          item
            KeyDefs = <
              item
                ShortCut = 8232
              end>
          end>
        Category = 'Navigation, normal select'
        DisplayName = 'Move cursor and select down one line'
      end
      item
        Command = 105
        KeyStrokes = <
          item
            KeyDefs = <
              item
                ShortCut = 24613
              end>
          end>
        Category = 'Navigation, normal select'
        DisplayName = 'Move cursor and select left one word'
      end
      item
        Command = 106
        KeyStrokes = <
          item
            KeyDefs = <
              item
                ShortCut = 24615
              end>
          end>
        Category = 'Navigation, normal select'
        DisplayName = 'Move cursor and select right one word'
      end
      item
        Command = 107
        KeyStrokes = <>
        Category = 'Navigation, normal select'
        DisplayName = 'Move cursor and select to beginning of line'
      end
      item
        Command = 108
        KeyStrokes = <>
        Category = 'Navigation, normal select'
        DisplayName = 'Move cursor and select to end of line'
      end
      item
        Command = 109
        KeyStrokes = <
          item
            KeyDefs = <
              item
                ShortCut = 8225
              end>
          end>
        Category = 'Navigation, normal select'
        DisplayName = 'Move cursor and select up one page'
      end
      item
        Command = 110
        KeyStrokes = <
          item
            KeyDefs = <
              item
                ShortCut = 8226
              end>
          end>
        Category = 'Navigation, normal select'
        DisplayName = 'Move cursor and select down one page'
      end
      item
        Command = 111
        KeyStrokes = <>
        Category = 'Navigation, normal select'
        DisplayName = 'Move cursor and select right one page'
      end
      item
        Command = 112
        KeyStrokes = <>
        Category = 'Navigation, normal select'
        DisplayName = 'Move cursor and select left one page'
      end
      item
        Command = 113
        KeyStrokes = <
          item
            KeyDefs = <
              item
                ShortCut = 24609
              end>
          end>
        Category = 'Navigation, normal select'
        DisplayName = 'Move cursor and select to top of page'
      end
      item
        Command = 114
        KeyStrokes = <
          item
            KeyDefs = <
              item
                ShortCut = 24610
              end>
          end>
        Category = 'Navigation, normal select'
        DisplayName = 'Move cursor and select to bottom of page'
      end
      item
        Command = 115
        KeyStrokes = <
          item
            KeyDefs = <
              item
                ShortCut = 24612
              end>
          end>
        Category = 'Navigation, normal select'
        DisplayName = 'Move cursor and select to absolute beginning'
      end
      item
        Command = 116
        KeyStrokes = <
          item
            KeyDefs = <
              item
                ShortCut = 24611
              end>
          end>
        Category = 'Navigation, normal select'
        DisplayName = 'Move cursor and select to absolute end'
      end
      item
        Command = 118
        KeyStrokes = <
          item
            KeyDefs = <
              item
                ShortCut = 8228
              end>
          end>
        Category = 'Navigation, normal select'
        DisplayName = 'Move cursor and select to first char of line'
      end
      item
        Command = 119
        KeyStrokes = <
          item
            KeyDefs = <
              item
                ShortCut = 8227
              end>
          end>
        Category = 'Navigation, normal select'
        DisplayName = 'Move cursor and select to last char of line'
      end
      item
        Command = 120
        KeyStrokes = <>
        Category = 'Navigation, normal select'
        DisplayName = 'Move cursor and select left and up at line start'
      end
      item
        Command = 117
        KeyStrokes = <>
        Customizable = False
        Category = 'Navigation, normal select'
        DisplayName = 'Move cursor to specified position and select'
      end
      item
        Command = 201
        KeyStrokes = <
          item
            KeyDefs = <
              item
                ShortCut = 40997
              end>
          end>
        Category = 'Navigation, columnar select'
        DisplayName = 'Move cursor and column select left one char'
      end
      item
        Command = 202
        KeyStrokes = <
          item
            KeyDefs = <
              item
                ShortCut = 40999
              end>
          end>
        Category = 'Navigation, columnar select'
        DisplayName = 'Move cursor and column select right one char'
      end
      item
        Command = 203
        KeyStrokes = <
          item
            KeyDefs = <
              item
                ShortCut = 40998
              end>
          end>
        Category = 'Navigation, columnar select'
        DisplayName = 'Move cursor and column select up one line'
      end
      item
        Command = 204
        KeyStrokes = <
          item
            KeyDefs = <
              item
                ShortCut = 41000
              end>
          end>
        Category = 'Navigation, columnar select'
        DisplayName = 'Move cursor and column select down one line'
      end
      item
        Command = 205
        KeyStrokes = <
          item
            KeyDefs = <
              item
                ShortCut = 57381
              end>
          end>
        Category = 'Navigation, columnar select'
        DisplayName = 'Move cursor and column select left one word'
      end
      item
        Command = 206
        KeyStrokes = <
          item
            KeyDefs = <
              item
                ShortCut = 57383
              end>
          end>
        Category = 'Navigation, columnar select'
        DisplayName = 'Move cursor and column select right one word'
      end
      item
        Command = 207
        KeyStrokes = <>
        Category = 'Navigation, columnar select'
        DisplayName = 'Move cursor and column select to beginning of line'
      end
      item
        Command = 208
        KeyStrokes = <>
        Category = 'Navigation, columnar select'
        DisplayName = 'Move cursor and column select to end of line'
      end
      item
        Command = 209
        KeyStrokes = <
          item
            KeyDefs = <
              item
                ShortCut = 40993
              end>
          end>
        Category = 'Navigation, columnar select'
        DisplayName = 'Move cursor and column select up one page'
      end
      item
        Command = 210
        KeyStrokes = <
          item
            KeyDefs = <
              item
                ShortCut = 40994
              end>
          end>
        Category = 'Navigation, columnar select'
        DisplayName = 'Move cursor and column select down one page'
      end
      item
        Command = 211
        KeyStrokes = <>
        Category = 'Navigation, columnar select'
        DisplayName = 'Move cursor and column select right one page'
      end
      item
        Command = 212
        KeyStrokes = <>
        Category = 'Navigation, columnar select'
        DisplayName = 'Move cursor and column select left one page'
      end
      item
        Command = 213
        KeyStrokes = <
          item
            KeyDefs = <
              item
                ShortCut = 57377
              end>
          end>
        Category = 'Navigation, columnar select'
        DisplayName = 'Move cursor and column select to top of page'
      end
      item
        Command = 214
        KeyStrokes = <
          item
            KeyDefs = <
              item
                ShortCut = 57378
              end>
          end>
        Category = 'Navigation, columnar select'
        DisplayName = 'Move cursor and column select to bottom of page'
      end
      item
        Command = 215
        KeyStrokes = <
          item
            KeyDefs = <
              item
                ShortCut = 57380
              end>
          end>
        Category = 'Navigation, columnar select'
        DisplayName = 'Move cursor and column select to absolute beginning'
      end
      item
        Command = 216
        KeyStrokes = <
          item
            KeyDefs = <
              item
                ShortCut = 57379
              end>
          end>
        Category = 'Navigation, columnar select'
        DisplayName = 'Move cursor and column select to absolute end'
      end
      item
        Command = 218
        KeyStrokes = <>
        Category = 'Navigation, columnar select'
        DisplayName = 'Move cursor and column select to first char of line'
      end
      item
        Command = 219
        KeyStrokes = <
          item
            KeyDefs = <
              item
                ShortCut = 40995
              end>
          end>
        Category = 'Navigation, columnar select'
        DisplayName = 'Move cursor and column select to last char of line'
      end
      item
        Command = 220
        KeyStrokes = <>
        Category = 'Navigation, columnar select'
        DisplayName = 'Move cursor and column select left and up at line start'
      end
      item
        Command = 217
        KeyStrokes = <>
        Customizable = False
        Category = 'Navigation, columnar select'
        DisplayName = 'Move cursor to specified position and column select'
      end
      item
        Command = 311
        KeyStrokes = <
          item
            KeyDefs = <
              item
                ShortCut = 16422
              end>
          end>
        Caption = 'Scroll Up'
        Category = 'Scrolling'
        DisplayName = 'Scroll up one line leaving cursor position unchanged'
      end
      item
        Command = 312
        KeyStrokes = <
          item
            KeyDefs = <
              item
                ShortCut = 16424
              end>
          end>
        Caption = 'Scroll Down'
        Category = 'Scrolling'
        DisplayName = 'Scroll down one line leaving cursor position unchanged'
      end
      item
        Command = 313
        KeyStrokes = <>
        Caption = 'Scroll Left'
        Category = 'Scrolling'
        DisplayName = 'Scroll left one char leaving cursor position unchanged'
      end
      item
        Command = 314
        KeyStrokes = <>
        Caption = 'Scroll Right'
        Category = 'Scrolling'
        DisplayName = 'Scroll right one char leaving cursor position unchanged'
      end
      item
        Command = 315
        KeyStrokes = <>
        Caption = 'Scroll Page Up'
        Category = 'Scrolling'
        DisplayName = 'Scroll up one page leaving cursor position unchanged'
      end
      item
        Command = 316
        KeyStrokes = <>
        Caption = 'Scroll Page Down'
        Category = 'Scrolling'
        DisplayName = 'Scroll down one page leaving cursor position unchanged'
      end
      item
        Command = 317
        KeyStrokes = <>
        Caption = 'Scroll Page Left'
        Category = 'Scrolling'
        DisplayName = 'Scroll left one screen leaving cursor position unchanged'
      end
      item
        Command = 318
        KeyStrokes = <>
        Caption = 'Scroll Page Right'
        Category = 'Scrolling'
        DisplayName = 'Scroll right one screen leaving cursor position unchanged'
      end
      item
        Command = 319
        KeyStrokes = <>
        Caption = 'Scroll to begin'
        Category = 'Scrolling'
        DisplayName = 'Scroll to absolute beginning leaving cursor position unchanged'
      end
      item
        Command = 320
        KeyStrokes = <>
        Caption = 'Scroll to end'
        Category = 'Scrolling'
        DisplayName = 'Scroll to absolute end leaving cursor position unchanged'
      end
      item
        Command = 321
        KeyStrokes = <>
        Caption = 'Scroll to left'
        Category = 'Scrolling'
        DisplayName = 'Scroll to absolute left leaving cursor position unchanged'
      end
      item
        Command = 322
        KeyStrokes = <>
        Caption = 'Scroll to right'
        Category = 'Scrolling'
        DisplayName = 'Scroll to absolute right leaving cursor position unchanged'
      end
      item
        Command = 301
        KeyStrokes = <
          item
            KeyDefs = <
              item
                ShortCut = 16451
              end>
          end
          item
            KeyDefs = <
              item
                ShortCut = 16429
              end>
          end>
        Caption = '&Copy'
        Category = 'Standard actions'
        DisplayName = 'Copy selection to clipboard'
      end
      item
        Command = 302
        KeyStrokes = <
          item
            KeyDefs = <
              item
                ShortCut = 16472
              end>
          end
          item
            KeyDefs = <
              item
                ShortCut = 8238
              end>
          end>
        Caption = 'Cu&t'
        Category = 'Standard actions'
        DisplayName = 'Cut selection to clipboard'
      end
      item
        Command = 303
        KeyStrokes = <
          item
            KeyDefs = <
              item
                ShortCut = 16470
              end>
          end
          item
            KeyDefs = <
              item
                ShortCut = 8237
              end>
          end>
        Caption = '&Paste'
        Category = 'Standard actions'
        DisplayName = 'Paste clipboard to current position'
      end
      item
        Command = 304
        KeyStrokes = <
          item
            KeyDefs = <
              item
                ShortCut = 16474
              end>
          end
          item
            KeyDefs = <
              item
                ShortCut = 32776
              end>
          end>
        Caption = '&Undo'
        Category = 'Standard actions'
        DisplayName = 'Perform undo if available'
      end
      item
        Command = 305
        KeyStrokes = <
          item
            KeyDefs = <
              item
                ShortCut = 24666
              end>
          end>
        Caption = '&Redo'
        Category = 'Standard actions'
        DisplayName = 'Perform redo if available'
      end
      item
        Command = 306
        KeyStrokes = <
          item
            KeyDefs = <
              item
                ShortCut = 16449
              end>
          end>
        Caption = 'Select &All'
        Category = 'Standard actions'
        DisplayName = 'Select entire contents of editor, cursor to end'
      end
      item
        Command = 307
        KeyStrokes = <
          item
            KeyDefs = <
              item
                ShortCut = 16430
              end>
          end>
        Caption = '&Delete'
        Category = 'Standard actions'
        DisplayName = 'Delete current selection'
      end
      item
        Command = 308
        KeyStrokes = <>
        Caption = 'Copy As RTF'
        Category = 'Standard actions'
        DisplayName = 'Copy to clipboard in RTF format'
      end
      item
        Command = 331
        KeyStrokes = <
          item
            KeyDefs = <
              item
                ShortCut = 8
              end>
          end>
        Caption = 'Back Delete Char'
        Category = 'Deleting text'
        DisplayName = 'Delete last char (i.e. backspace key)'
      end
      item
        Command = 332
        KeyStrokes = <
          item
            KeyDefs = <
              item
                ShortCut = 46
              end>
          end>
        Caption = 'Delete Char'
        Category = 'Deleting text'
        DisplayName = 'Delete char at cursor (i.e. delete key)'
      end
      item
        Command = 333
        KeyStrokes = <
          item
            KeyDefs = <
              item
                ShortCut = 16468
              end>
          end>
        Caption = 'Delete Word'
        Category = 'Deleting text'
        DisplayName = 'Delete from cursor to next word'
      end
      item
        Command = 334
        KeyStrokes = <
          item
            KeyDefs = <
              item
                ShortCut = 16392
              end>
          end>
        Caption = 'Back Delete Word'
        Category = 'Deleting text'
        DisplayName = 'Delete from cursor to start of word'
      end
      item
        Command = 335
        KeyStrokes = <
          item
            KeyDefs = <
              item
                ShortCut = 16450
              end>
          end>
        Caption = 'Delete to Line Begin'
        Category = 'Deleting text'
        DisplayName = 'Delete from cursor to beginning of line'
      end
      item
        Command = 336
        KeyStrokes = <>
        Caption = 'Delete to Line End'
        Category = 'Deleting text'
        DisplayName = 'Delete from cursor to end of line'
      end
      item
        Command = 337
        KeyStrokes = <
          item
            KeyDefs = <
              item
                ShortCut = 16473
              end>
          end>
        Caption = 'Delete Line'
        Category = 'Deleting text'
        DisplayName = 'Delete current line'
      end
      item
        Command = 338
        KeyStrokes = <>
        Caption = 'Clear all'
        Category = 'Deleting text'
        DisplayName = 'Delete everything'
      end
      item
        Command = 339
        KeyStrokes = <
          item
            KeyDefs = <
              item
                ShortCut = 13
              end>
          end>
        Caption = 'New Line'
        Category = 'Inserting text'
        DisplayName = 'Break line at current position, move caret to new line'
      end
      item
        Command = 340
        KeyStrokes = <
          item
            KeyDefs = <
              item
                ShortCut = 16462
              end>
          end>
        Category = 'Inserting text'
        DisplayName = 'Break line at current position, leave caret'
      end
      item
        Command = 341
        KeyStrokes = <>
        Customizable = False
        Category = 'Inserting text'
        DisplayName = 'Insert a character at current position (Data = PChar)'
      end
      item
        Command = 342
        KeyStrokes = <>
        Customizable = False
        Category = 'Inserting text'
        DisplayName = 'Insert a whole string (Data = PChar)'
      end
      item
        Command = 350
        KeyStrokes = <
          item
            KeyDefs = <
              item
                ShortCut = 16393
              end>
          end>
        Caption = '&Indent'
        Category = 'Indents and Tabs'
        DisplayName = 'Indent selection'
      end
      item
        Command = 351
        KeyStrokes = <
          item
            KeyDefs = <
              item
                ShortCut = 8201
              end>
          end>
        Caption = '&Unindent'
        Category = 'Indents and Tabs'
        DisplayName = 'Unindent selection'
      end
      item
        Command = 352
        KeyStrokes = <
          item
            KeyDefs = <
              item
                ShortCut = 9
              end>
          end>
        Category = 'Indents and Tabs'
        DisplayName = 'Tab key'
      end
      item
        Command = 353
        KeyStrokes = <
          item
            KeyDefs = <
              item
                ShortCut = 16457
              end>
          end>
        Category = 'Indents and Tabs'
        DisplayName = 'Insert Tab char'
      end
      item
        Command = 371
        KeyStrokes = <>
        Caption = 'Insert Mode'
        Category = 'Selection modes'
        DisplayName = 'Set insert mode'
      end
      item
        Command = 372
        KeyStrokes = <>
        Caption = 'Overwrite Mode'
        Category = 'Selection modes'
        DisplayName = 'Set overwrite mode'
      end
      item
        Command = 373
        KeyStrokes = <
          item
            KeyDefs = <
              item
                ShortCut = 45
              end>
          end>
        Caption = 'Toggle Insert Mode'
        Category = 'Selection modes'
        DisplayName = 'Toggle insert/overwrite mode'
      end
      item
        Command = 374
        KeyStrokes = <
          item
            KeyDefs = <
              item
                ShortCut = 16463
              end
              item
                ShortCut = 75
              end>
          end>
        Caption = 'Normal Selection'
        Category = 'Selection modes'
        DisplayName = 'Normal selection mode'
      end
      item
        Command = 375
        KeyStrokes = <
          item
            KeyDefs = <
              item
                ShortCut = 16463
              end
              item
                ShortCut = 67
              end>
          end>
        Caption = 'Column Selection'
        Category = 'Selection modes'
        DisplayName = 'Column selection mode'
      end
      item
        Command = 376
        KeyStrokes = <
          item
            KeyDefs = <
              item
                ShortCut = 16463
              end
              item
                ShortCut = 76
              end>
          end>
        Caption = 'Line Selection'
        Category = 'Selection modes'
        DisplayName = 'Line selection mode'
      end
      item
        Command = 377
        KeyStrokes = <
          item
            KeyDefs = <
              item
                ShortCut = 16459
              end
              item
                ShortCut = 66
              end>
          end>
        Caption = 'Mark Selection Start'
        Category = 'Selection modes'
        DisplayName = 'Marks the beginning of a block'
      end
      item
        Command = 378
        KeyStrokes = <
          item
            KeyDefs = <
              item
                ShortCut = 16459
              end
              item
                ShortCut = 75
              end>
          end>
        Caption = 'Mark Selection End'
        Category = 'Selection modes'
        DisplayName = 'Marks the end of a block'
      end
      item
        Command = 379
        KeyStrokes = <
          item
            KeyDefs = <
              item
                ShortCut = 27
              end>
          end>
        Caption = 'Reset selection'
        Category = 'Selection modes'
        DisplayName = 'Reset selection'
      end
      item
        Command = 360
        KeyStrokes = <>
        Caption = 'Word Upper Case'
        Category = 'Change case'
        DisplayName = 'Upper case to current or previous word'
      end
      item
        Command = 361
        KeyStrokes = <>
        Caption = 'Word Lower Case'
        Category = 'Change case'
        DisplayName = 'Lower case to current or previous word'
      end
      item
        Command = 362
        KeyStrokes = <>
        Caption = 'Word Toggle Case'
        Category = 'Change case'
        DisplayName = 'Toggle case to current or previous word'
      end
      item
        Command = 363
        KeyStrokes = <>
        Caption = 'Word Title Case'
        Category = 'Change case'
        DisplayName = 'Title case to current or previous word'
      end
      item
        Command = 365
        KeyStrokes = <
          item
            KeyDefs = <
              item
                ShortCut = 16459
              end
              item
                ShortCut = 78
              end>
          end>
        Caption = 'Selection Upper Case'
        Category = 'Change case'
        DisplayName = 'Upper case to current selection or current char'
      end
      item
        Command = 366
        KeyStrokes = <
          item
            KeyDefs = <
              item
                ShortCut = 16459
              end
              item
                ShortCut = 79
              end>
          end>
        Caption = 'Selection Lower Case'
        Category = 'Change case'
        DisplayName = 'Lower case to current selection or current char'
      end
      item
        Command = 367
        KeyStrokes = <>
        Caption = 'Selection Toggle Case'
        Category = 'Change case'
        DisplayName = 'Toggle case to current selection or current char'
      end
      item
        Command = 368
        KeyStrokes = <>
        Caption = 'Selection Title Case'
        Category = 'Change case'
        DisplayName = 'Title case to current selection'
      end
      item
        Command = 520
        KeyStrokes = <>
        Caption = 'Toggle Collapse'
        Category = 'Text folding'
        DisplayName = 'Collapse/expand block at current line'
      end
      item
        Command = 521
        KeyStrokes = <>
        Caption = 'Collapse'
        Category = 'Text folding'
        DisplayName = 'Collapse block at current line'
      end
      item
        Command = 522
        KeyStrokes = <>
        Caption = 'Expand'
        Category = 'Text folding'
        DisplayName = 'Expand block at current line'
      end
      item
        Command = 523
        KeyStrokes = <>
        Caption = 'Full Collapse'
        Category = 'Text folding'
        DisplayName = 'Collapse all blocks in the text'
      end
      item
        Command = 524
        KeyStrokes = <>
        Caption = 'Full Expand'
        Category = 'Text folding'
        DisplayName = 'Expand all collapsed blocks in the text'
      end
      item
        Command = 525
        KeyStrokes = <>
        Caption = 'Collapse Selection'
        Category = 'Text folding'
        DisplayName = 'Collapse selected block'
      end
      item
        Command = 526
        KeyStrokes = <
          item
            KeyDefs = <
              item
                ShortCut = 16571
              end>
          end>
        Caption = 'Toggle Collapse Nearest'
        Category = 'Text folding'
        DisplayName = 'Collapse/expand nearest block'
      end
      item
        Command = 527
        KeyStrokes = <>
        Caption = 'Collapse in selection'
        Category = 'Text folding'
        DisplayName = 'Collapse ranges in selection'
      end
      item
        Command = 528
        KeyStrokes = <>
        Caption = 'Expand in selection'
        Category = 'Text folding'
        DisplayName = 'Expand ranges in selection'
      end
      item
        Command = 532
        KeyStrokes = <>
        Caption = 'Toggle Folding'
        Category = 'Text folding'
        DisplayName = 'Toggle Folding'
      end
      item
        Command = 401
        KeyStrokes = <
          item
            KeyDefs = <
              item
                ShortCut = 16432
              end>
          end>
        Caption = 'Goto Bookmark 0'
        Category = 'Bookmarks'
        DisplayName = 'Goto Bookmark 0'
      end
      item
        Command = 402
        KeyStrokes = <
          item
            KeyDefs = <
              item
                ShortCut = 16433
              end>
          end>
        Caption = 'Goto Bookmark 1'
        Category = 'Bookmarks'
        DisplayName = 'Goto Bookmark 1'
      end
      item
        Command = 403
        KeyStrokes = <
          item
            KeyDefs = <
              item
                ShortCut = 16434
              end>
          end>
        Caption = 'Goto Bookmark 2'
        Category = 'Bookmarks'
        DisplayName = 'Goto Bookmark 2'
      end
      item
        Command = 404
        KeyStrokes = <
          item
            KeyDefs = <
              item
                ShortCut = 16435
              end>
          end>
        Caption = 'Goto Bookmark 3'
        Category = 'Bookmarks'
        DisplayName = 'Goto Bookmark 3'
      end
      item
        Command = 405
        KeyStrokes = <
          item
            KeyDefs = <
              item
                ShortCut = 16436
              end>
          end>
        Caption = 'Goto Bookmark 4'
        Category = 'Bookmarks'
        DisplayName = 'Goto Bookmark 4'
      end
      item
        Command = 406
        KeyStrokes = <
          item
            KeyDefs = <
              item
                ShortCut = 16437
              end>
          end>
        Caption = 'Goto Bookmark 5'
        Category = 'Bookmarks'
        DisplayName = 'Goto Bookmark 5'
      end
      item
        Command = 407
        KeyStrokes = <
          item
            KeyDefs = <
              item
                ShortCut = 16438
              end>
          end>
        Caption = 'Goto Bookmark 6'
        Category = 'Bookmarks'
        DisplayName = 'Goto Bookmark 6'
      end
      item
        Command = 408
        KeyStrokes = <
          item
            KeyDefs = <
              item
                ShortCut = 16439
              end>
          end>
        Caption = 'Goto Bookmark 7'
        Category = 'Bookmarks'
        DisplayName = 'Goto Bookmark 7'
      end
      item
        Command = 409
        KeyStrokes = <
          item
            KeyDefs = <
              item
                ShortCut = 16440
              end>
          end>
        Caption = 'Goto Bookmark 8'
        Category = 'Bookmarks'
        DisplayName = 'Goto Bookmark 8'
      end
      item
        Command = 410
        KeyStrokes = <
          item
            KeyDefs = <
              item
                ShortCut = 16441
              end>
          end>
        Caption = 'Goto Bookmark 9'
        Category = 'Bookmarks'
        DisplayName = 'Goto Bookmark 9'
      end
      item
        Command = 411
        KeyStrokes = <
          item
            KeyDefs = <
              item
                ShortCut = 24624
              end>
          end>
        Caption = 'Toggle Bookmark 0'
        Category = 'Bookmarks'
        DisplayName = 'Toggle Bookmark 0'
      end
      item
        Command = 412
        KeyStrokes = <
          item
            KeyDefs = <
              item
                ShortCut = 24625
              end>
          end>
        Caption = 'Toggle Bookmark 1'
        Category = 'Bookmarks'
        DisplayName = 'Toggle Bookmark 1'
      end
      item
        Command = 413
        KeyStrokes = <
          item
            KeyDefs = <
              item
                ShortCut = 24626
              end>
          end>
        Caption = 'Toggle Bookmark 2'
        Category = 'Bookmarks'
        DisplayName = 'Toggle Bookmark 2'
      end
      item
        Command = 414
        KeyStrokes = <
          item
            KeyDefs = <
              item
                ShortCut = 24627
              end>
          end>
        Caption = 'Toggle Bookmark 3'
        Category = 'Bookmarks'
        DisplayName = 'Toggle Bookmark 3'
      end
      item
        Command = 415
        KeyStrokes = <
          item
            KeyDefs = <
              item
                ShortCut = 24628
              end>
          end>
        Caption = 'Toggle Bookmark 4'
        Category = 'Bookmarks'
        DisplayName = 'Toggle Bookmark 4'
      end
      item
        Command = 416
        KeyStrokes = <
          item
            KeyDefs = <
              item
                ShortCut = 24629
              end>
          end>
        Caption = 'Toggle Bookmark 5'
        Category = 'Bookmarks'
        DisplayName = 'Toggle Bookmark 5'
      end
      item
        Command = 417
        KeyStrokes = <
          item
            KeyDefs = <
              item
                ShortCut = 24630
              end>
          end>
        Caption = 'Toggle Bookmark 6'
        Category = 'Bookmarks'
        DisplayName = 'Toggle Bookmark 6'
      end
      item
        Command = 418
        KeyStrokes = <
          item
            KeyDefs = <
              item
                ShortCut = 24631
              end>
          end>
        Caption = 'Toggle Bookmark 7'
        Category = 'Bookmarks'
        DisplayName = 'Toggle Bookmark 7'
      end
      item
        Command = 419
        KeyStrokes = <
          item
            KeyDefs = <
              item
                ShortCut = 24632
              end>
          end>
        Caption = 'Toggle Bookmark 8'
        Category = 'Bookmarks'
        DisplayName = 'Toggle Bookmark 8'
      end
      item
        Command = 420
        KeyStrokes = <
          item
            KeyDefs = <
              item
                ShortCut = 24633
              end>
          end>
        Caption = 'Toggle Bookmark 9'
        Category = 'Bookmarks'
        DisplayName = 'Toggle Bookmark 9'
      end
      item
        Command = 430
        KeyStrokes = <
          item
            KeyDefs = <
              item
                ShortCut = 32804
              end>
          end>
        Caption = 'Drop marker'
        Category = 'Markers'
        DisplayName = 'Drops marker to the current position'
      end
      item
        Command = 431
        KeyStrokes = <
          item
            KeyDefs = <
              item
                ShortCut = 32803
              end>
          end>
        Caption = 'Collect marker'
        Category = 'Markers'
        DisplayName = 'Collect marker (jump back)'
      end
      item
        Command = 432
        KeyStrokes = <
          item
            KeyDefs = <
              item
                ShortCut = 40996
              end>
          end>
        Caption = 'Swap marker'
        Category = 'Markers'
        DisplayName = 'Swap marker (keep position, jump back)'
      end
      item
        Command = 433
        KeyStrokes = <
          item
            KeyDefs = <
              item
                ShortCut = 16603
              end>
          end>
        Caption = 'Jump to matching bracket'
        Category = 'Markers'
        DisplayName = 'Jump to matching bracket (change range side)'
      end
      item
        Command = 573
        KeyStrokes = <>
        Caption = 'Play macro'
        Category = 'Macros'
        DisplayName = 'Play macro'
      end
      item
        Command = 570
        KeyStrokes = <>
        Caption = 'Start macro recording'
        Category = 'Macros'
        DisplayName = 'Start macro recording'
      end
      item
        Command = 571
        KeyStrokes = <>
        Caption = 'Stop macro recording'
        Category = 'Macros'
        DisplayName = 'Stop macro recording'
      end
      item
        Command = 572
        KeyStrokes = <>
        Caption = 'Cancel macro recording'
        Category = 'Macros'
        DisplayName = 'Cancel macro recording'
      end
      item
        Command = 530
        KeyStrokes = <>
        Caption = 'Show Non Printed'
        Category = 'Miscellaneous'
        DisplayName = 'Show/Hide non printed text/characters'
      end
      item
        Command = 531
        KeyStrokes = <>
        Caption = 'Toggle Word Wrap'
        Category = 'Miscellaneous'
        DisplayName = 'Toggle Word Wrap'
      end
      item
        Command = 533
        KeyStrokes = <>
        Caption = 'Show line numbers'
        Category = 'Miscellaneous'
        DisplayName = 'Show/Hide line numbers'
      end
      item
        Command = 560
        KeyStrokes = <>
        Caption = 'Comment lines'
        Category = 'Miscellaneous'
        DisplayName = 'Comment selected lines'
      end
      item
        Command = 561
        KeyStrokes = <>
        Caption = 'Uncomment lines'
        Category = 'Miscellaneous'
        DisplayName = 'Uncomment selected lines'
      end
      item
        Command = 562
        KeyStrokes = <>
        Caption = 'Ascending sort'
        Category = 'Miscellaneous'
        DisplayName = 'Ascending sort of selected lines'
      end
      item
        Command = 563
        KeyStrokes = <>
        Caption = 'Descending sort'
        Category = 'Miscellaneous'
        DisplayName = 'Descending sort of selected lines'
      end
      item
        Command = 565
        KeyStrokes = <>
        Caption = 'Aligns tokens'
        Category = 'Miscellaneous'
        DisplayName = 'Aligns tokens in selected lines'
      end
      item
        Command = 630
        KeyStrokes = <>
        Caption = 'Print all text'
        Category = 'Miscellaneous'
        DisplayName = 'Print all text'
      end
      item
        Command = 631
        KeyStrokes = <>
        Caption = 'Print selected text'
        Category = 'Miscellaneous'
        DisplayName = 'Print selected text'
      end
      item
        Command = 632
        KeyStrokes = <>
        Caption = 'Print preview'
        Category = 'Miscellaneous'
        DisplayName = 'Print preview'
      end
      item
        Command = 633
        KeyStrokes = <>
        Caption = 'Page Setup...'
        Category = 'Miscellaneous'
        DisplayName = 'Page Setup dialog'
      end
      item
        Command = 600
        KeyStrokes = <
          item
            KeyDefs = <
              item
                ShortCut = 16454
              end>
          end>
        Caption = 'Find Dialog'
        Category = 'Search & Replace'
        DisplayName = 'Find Dialog'
      end
      item
        Command = 601
        KeyStrokes = <>
        Caption = 'Find Next'
        Category = 'Search & Replace'
        DisplayName = 'Find Next'
      end
      item
        Command = 602
        KeyStrokes = <>
        Caption = 'Find Previous'
        Category = 'Search & Replace'
        DisplayName = 'Find Previous'
      end
      item
        Command = 603
        KeyStrokes = <>
        Caption = 'Find All'
        Category = 'Search & Replace'
        DisplayName = 'Find All'
      end
      item
        Command = 604
        KeyStrokes = <>
        Caption = 'Find First'
        Category = 'Search & Replace'
        DisplayName = 'Find First'
      end
      item
        Command = 605
        KeyStrokes = <>
        Caption = 'Find Last'
        Category = 'Search & Replace'
        DisplayName = 'Find Last'
      end
      item
        Command = 606
        KeyStrokes = <
          item
            KeyDefs = <
              item
                ShortCut = 114
              end>
          end>
        Caption = 'Search Again'
        Category = 'Search & Replace'
        DisplayName = 'Search Again'
      end
      item
        Command = 607
        KeyStrokes = <
          item
            KeyDefs = <
              item
                ShortCut = 24616
              end>
          end>
        Caption = 'Find Current Word Next'
        Category = 'Search & Replace'
        DisplayName = 'Find Current Word Next'
      end
      item
        Command = 608
        KeyStrokes = <
          item
            KeyDefs = <
              item
                ShortCut = 24614
              end>
          end>
        Caption = 'Find Current Word Prior'
        Category = 'Search & Replace'
        DisplayName = 'Find Current Word Prior'
      end
      item
        Command = 550
        KeyStrokes = <
          item
            KeyDefs = <
              item
                ShortCut = 16453
              end>
          end>
        Caption = 'Incremental Search'
        Category = 'Search & Replace'
        DisplayName = 'Incremental Search'
      end
      item
        Command = 564
        KeyStrokes = <
          item
            KeyDefs = <
              item
                ShortCut = 32839
              end>
          end>
        Caption = 'Go to line number'
        Category = 'Search & Replace'
        DisplayName = 'Go to line number'
      end
      item
        Command = 610
        KeyStrokes = <
          item
            KeyDefs = <
              item
                ShortCut = 16466
              end>
          end>
        Caption = 'Replace Dialog'
        Category = 'Search & Replace'
        DisplayName = 'Replace Dialog'
      end
      item
        Command = 611
        KeyStrokes = <>
        Caption = 'Replace Next'
        Category = 'Search & Replace'
        DisplayName = 'Replace Next'
      end
      item
        Command = 612
        KeyStrokes = <>
        Caption = 'Replace Previous'
        Category = 'Search & Replace'
        DisplayName = 'Replace Previous'
      end
      item
        Command = 613
        KeyStrokes = <>
        Caption = 'Replace All'
        Category = 'Search & Replace'
        DisplayName = 'Replace All'
      end
      item
        Command = 614
        KeyStrokes = <>
        Caption = 'Replace First'
        Category = 'Search & Replace'
        DisplayName = 'Replace First'
      end
      item
        Command = 615
        KeyStrokes = <>
        Caption = 'Replace Last'
        Category = 'Search & Replace'
        DisplayName = 'Replace Last'
      end
      item
        Command = 616
        KeyStrokes = <>
        Caption = 'Replace Again'
        Category = 'Search & Replace'
        DisplayName = 'Replace Again'
      end
      item
        Command = 620
        KeyStrokes = <>
        Category = 'Block operations'
        DisplayName = 'Block Copy & Paste end of file'
      end
      item
        Command = 621
        KeyStrokes = <>
        Category = 'Block operations'
        DisplayName = 'Block Copy & Paste start of file'
      end
      item
        Command = 622
        KeyStrokes = <>
        Category = 'Block operations'
        DisplayName = 'Block Cut & Paste end of file'
      end
      item
        Command = 623
        KeyStrokes = <>
        Category = 'Block operations'
        DisplayName = 'Block Cut & Paste start of file'
      end
      item
        Command = 624
        KeyStrokes = <>
        Category = 'Block operations'
        DisplayName = 'Block Copy & Paste above selected block'
      end
      item
        Command = 625
        KeyStrokes = <>
        Category = 'Block operations'
        DisplayName = 'Block Copy & Paste below top of file'
      end
      item
        Command = 700
        KeyStrokes = <
          item
            KeyDefs = <
              item
                ShortCut = 16416
              end>
          end>
        Caption = 'Auto completion'
        Category = 'Tools'
        DisplayName = 'Auto completion popup'
      end
      item
        Command = 701
        KeyStrokes = <>
        Customizable = False
        Caption = 'Code templates'
        Category = 'Tools'
        DisplayName = 'Code templates popup'
      end
      item
        Command = 702
        KeyStrokes = <
          item
            KeyDefs = <
              item
                ShortCut = 24608
              end>
          end>
        Caption = 'Code parameters'
        Category = 'Tools'
        DisplayName = 'Code parameters tooltip'
      end
      item
        Command = 703
        KeyStrokes = <
          item
            KeyDefs = <
              item
                ShortCut = 16574
              end>
          end>
        Caption = 'Select character'
        Category = 'Tools'
        DisplayName = 'Select character popup'
      end
      item
        Command = 704
        KeyStrokes = <>
        Caption = 'Auto correct current word'
        Category = 'Tools'
        DisplayName = 'Auto correct current word'
      end
      item
        Command = 705
        KeyStrokes = <>
        Caption = 'Auto correct all words'
        Category = 'Tools'
        DisplayName = 'Auto correct all words'
      end>
    Left = 2892
    Top = 810
  end
  object PrintDialog1: TPrintDialog
    Left = 1144
    Top = 792
  end
  object ImageList1: TImageList
    Left = 1516
    Top = 408
    Bitmap = {
      494C01012A002C00040010001000FFFFFFFFFF10FFFFFFFFFFFFFFFF424D3600
      000000000000360000002800000040000000B0000000010020000000000000B0
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000840000008400000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000084000000840000008400000084000000840000008400
      0000840000008400000084000000840000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000008400
      0000000000000000000084000000000000000000000084000000840000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000084000000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00840000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000008400
      0000000000000000000084000000000000008400000000000000000000008400
      0000000000000000000000000000000000000000000084848400008484008484
      8400008484008484840084000000FFFFFF008400000084000000840000008400
      00008400000084000000FFFFFF00840000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000008400
      0000000000000000000084000000000000008400000000000000000000008400
      0000000000000000000000000000000000000000000000848400848484000084
      8400848484000084840084000000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00840000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000840000008400000084000000000000008400000000000000000000008400
      0000000000000000000000000000000000000000000084848400008484008484
      8400008484008484840084000000FFFFFF00840000008400000084000000FFFF
      FF00840000008400000084000000840000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000084000000000000008400000084000000840000000000
      0000000000000000000000000000000000000000000000848400848484000084
      8400848484000084840084000000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF0084000000FFFFFF0084000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000084000000000000008400000000000000000000000000
      0000000000000000000000000000000000000000000084848400008484008484
      8400008484008484840084000000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00840000008400000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000848400848484000084
      8400848484000084840084000000840000008400000084000000840000008400
      0000840000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000084848400008484008484
      8400008484008484840000848400848484000084840084848400008484008484
      8400008484000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000848400848484000000
      0000000000000000000000000000000000000000000000000000000000008484
      8400848484000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000084848400848484000000
      0000C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600000000008484
      8400008484000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000848400848484000084
      84000000000000FFFF00000000000000000000FFFF0000000000848484000084
      8400848484000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000FFFF0000FFFF000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000042B5E700107BAD00107BAD00107BAD00107BAD00107B
      AD00107BAD00107BAD00107BAD00000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000948C8C00948C8C00000000000000000000000000000000000000
      000000000000000000000000000018A5D600107BAD00107BAD00107BAD00107B
      AD00107BAD00107BAD00107BAD00000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000042B5E700FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00EFEFEF00EFEFE700107BAD00000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000948C8C00E7DECE00948C8C0000000000000000000000000000000000BD5A
      1000AD4A0000AD4A0000AD4A000042B5E700FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00F7F7F700EFEFE700107BAD00000000000000000000000000000000000000
      0000000000000000000084000000840000008400000084000000840000008400
      0000840000008400000084000000000000000000000000000000000000000000
      0000000000000000000042B5E700FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00F7F7F700107BAD00000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000000000948C
      8C00E7DECE00E7DECE00948C8C0000000000000000000000000000000000CE6B
      000000000000000000000000000042B5E70042B5E70042B5E70042B5E70042B5
      E70042B5E70042B5E70018A5D600000000000000000000000000000000000000
      0000000000000000000084000000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF0084000000000000000000000000000000000000000000
      0000000000000000000042B5E70042B5E70042B5E70042B5E70042B5E70042B5
      E70042B5E70042B5E70042B5E700000000000000000000000000000000000000
      000000000000A5A59C00948C8C00948C8C00948C8C00948C8C00948C8C00EFE7
      D600EFE7D600A5A59C000000000000000000000000000000000000000000CE6B
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000084000000FFFFFF000000000000000000000000000000
      000000000000FFFFFF0084000000000000000000000000000000000000000000
      0000000000000000000000000000AD4A00000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000000000A5A5
      9C00948C8C00CEC6BD00E7DECE00E7E7CE00EFE7D600EFE7D600EFE7D600EFE7
      D600EFE7D600948C8C000000000000000000000000000000000000000000CE6B
      000000000000000000000000000018A5D600107BAD00107BAD00107BAD00107B
      AD00107BAD00107BAD00107BAD00000000000000000000000000000000000000
      0000000000000000000084000000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00840000000000000042B5E700107BAD00107BAD00107B
      AD00107BAD0000000000CE6B0000FF840000AD4A000000000000000000000000
      0000000000000000000000000000000000000000000000000000A5A59C00CEC6
      BD00E7DECE00E7DECE00E7E7CE00EFE7D600EFE7D600EFE7D600EFE7D600EFE7
      D600EFE7D600948C8C000000000000000000000000000000000000000000BD5A
      1000AD4A0000AD4A0000AD4A000042B5E700FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00F7F7F700EFEFE700107BAD000000000000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF0084000000FFFFFF000000000000000000000000000000
      000000000000FFFFFF00840000000000000042B5E700FFFFFF00FFFFFF00FFFF
      FF00107BAD000000000000000000CE6B00000000000000000000000000000000
      00000000000000000000000000000000000000000000A5A59C00E7DECE00E7DE
      CE00E7DECE00E7DECE007B7B7B004A4A42007B7B7B004A4A4200EFE7D600EFE7
      D600EFE7D600EFE7D600948C8C0000000000000000000000000000000000CE6B
      000000000000000000000000000042B5E70042B5E70042B5E70042B5E70042B5
      E70042B5E70042B5E70018A5D6000000000000000000FFFFFF00000000000000
      0000000000000000000084000000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00840000000000000042B5E700FFFFFF00FFFFFF00FFFF
      FF00107BAD00CE6B0000CE6B0000CE6B00000000000000000000000000000000
      000000000000000000000000000000000000B5B5AD00CEC6BD00E7DECE00E7DE
      CE00E7DECE00E7E7D600EFE7D600EFE7D600EFE7D600EFE7D600EFE7DE00EFEF
      DE00EFEFDE00EFEFDE00EFE7D600948C8C00000000000000000000000000CE6B
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF0084000000FFFFFF000000000000000000FFFFFF008400
      00008400000084000000840000000000000042B5E70042B5E70042B5E70042B5
      E70042B5E7000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000A5A59C00E7DECE00E7DECE00E7DE
      CE004A4A42004A4A42007B7B7B004A4A42004A4A42007B7B7B007B7B7B004A4A
      42007B7B7B00F7EFE700EFEFDE00948C8C00000000000000000000000000CE6B
      000000000000000000000000000018A5D600107BAD00107BAD00107BAD00107B
      AD00107BAD00107BAD00107BAD000000000000000000FFFFFF00000000000000
      0000000000000000000084000000FFFFFF00FFFFFF00FFFFFF00FFFFFF008400
      0000FFFFFF008400000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000A5A59C00E7DECE00E7DECE00E7DE
      CE00E7DECE00EFE7D600EFE7D600EFE7D600EFE7D600EFEFDE00F7EFE700F7EF
      E700F7EFE700F7EFE700EFE7D600A5A59C00000000000000000000000000BD5A
      1000AD4A0000AD4A0000AD4A000042B5E700FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00F7F7F700EFEFE700107BAD000000000000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF0084000000FFFFFF00FFFFFF00FFFFFF00FFFFFF008400
      000084000000000000000000000000000000000000000000000010A529000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000010A529000000000000000000B5B5AD00CEC6BD00E7DECE00E7DE
      CE00E7DECE007B7B7B004A4A42004A4A42007B7B7B004A4A42007B7B7B004A4A
      4200F7F7EF00EFE7D600A5A59C0000000000000000000000000000000000CE6B
      000000000000000000000000000042B5E70042B5E70042B5E70042B5E70042B5
      E70042B5E70042B5E70018A5D6000000000000000000FFFFFF00000000000000
      0000FFFFFF000000000084000000840000008400000084000000840000008400
      0000000000000000000000000000000000000000000010A52900FFFFFF0010A5
      2900000000000000000000000000000000000000000000000000000000000000
      000010A52900FFFFFF0010A529000000000000000000A5A59C00CEC6BD00E7DE
      CE00E7DECE00EFE7D600EFE7D600EFE7D600EFE7D600EFEFDE00F7EFE700F7EF
      E700EFE7D600A5A59C000000000000000000000000000000000000000000CE6B
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF0000000000FFFFFF00000000000000000000000000000000000000
      00000000000000000000000000000000000010B52900FFFFFF00FFFFFF00FFFF
      FF0010A5290010A5290010A5290010A5290010A5290010A5290010A5290010A5
      2900FFFFFF00FFFFFF00FFFFFF0010A529000000000000000000B5B5AD00A5A5
      9C00CEC6BD00EFE7D600EFE7D600EFE7D600EFE7D600EFE7DE00EFE7D600A5A5
      9C00A5A59C000000000000000000000000000000000018A5D600107BAD00107B
      AD00107BAD00107BAD00107BAD00107BAD00107BAD0000000000000000000000
      00000000000000000000000000000000000000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000010B5290010B5290010B5290010B5
      290010B5290010B5290010B5290010B5290010B5290010B5290010B5290010B5
      290010B5290010B5290010B5290010A529000000000000000000000000000000
      0000A5A59C00A5A59C00A5A59C00A5A59C00A5A59C00A5A59C00BDBDB5000000
      0000000000000000000000000000000000000000000042B5E700FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00EFEFE700107BAD0000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000042B5E70042B5E70042B5
      E70042B5E70042B5E70042B5E70042B5E70018A5D60000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000002173B500636B73000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000B59C8400946B39008452180084521800946B3900B59C84000000
      0000000000000000000000000000000000002173B500218CEF002173B500636B
      7300000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000021738C00317B94004A94
      AD005A9CAD0063ADBD0063ADBD005A9CAD005A94A500397B8C0021637B002973
      84000000000000000000000000000000000000000000948C8C00948C8C000000
      00000000000000000000000000000031E7000000000000000000000000000000
      000000000000000000000031E70000000000000000000000000000000000B59C
      84007B4A08008C4A0000945200009C5A08009C5A1000945208008C4A0000844A
      0800BDA5840000000000000000000000000031A5FF0052BDFF00218CEF002173
      B500636B73000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000398494003994AD007BBDCE004A94
      AD0073BDCE009CCEDE00D6EFF700BDD6DE0094BDC6006BA5B500428C9C001863
      7B00005A7B0000000000000000000000000000000000948C8C00E7DECE00948C
      8C00000000000000000000000000000000000031E70000000000000000000000
      0000000000000031E700000000000000000000000000000000009C845A00844A
      000094520800AD6B2900BD7B4200BD7B4A00BD7B4A00BD7B4200AD7331009C5A
      1000844A0000A5845A0000000000000000000000000031A5FF0052BDFF00218C
      EF002173B500636B730000000000000000000000000000000000000000000000
      000000000000000000000000000000000000186B7B00429CBD0084C6D6004A94
      A50073B5CE009CCEDE00D6EFF700C6DEDE009CC6CE0073A5B5004A8C9C00216B
      840010526B0000000000000000000000000000000000948C8C00E7DECE00E7DE
      CE00948C8C00000000000000000000000000184AFF000031E700000000000000
      00000031E700184AFF00000000000000000000000000B59C8400844A00009C5A
      1000BD7B4200BD844A00C6844A00C6844A00C6844A00BD844A00BD7B4A00B57B
      4200A56318008C4A0000BDA5840000000000000000000000000031A5FF0052BD
      FF00218CEF002173B500636B7300000000000000000000000000000000000000
      000000000000000000000000000000000000186B7B00429CBD0084C6D6004A94
      A500292929005A524A00D6EFF700C6DEDE009CC6CE0073A5B5004A8C9C00216B
      840010526B000000000000000000000000000000000000000000A5A59C00EFE7
      D600EFE7D600948C8C00948C8C00948C8C00948C8C00184AFF000031E7000031
      E700184AFF0000000000000000000000000000000000844A080094520000B57B
      4200BD844A00CE9C6B00CE9C6B00CE9C6B00CE9C6B00CE9C6B00CE9C6B00BD84
      4A00B57B42009C5A1000844A08000000000000000000000000000000000031A5
      FF0052BDFF00218CEF005A6B730000000000D6BDB500D6ADA500D6ADA500D6AD
      A500D6BDB500000000000000000000000000186B7B00187B9C00428CA5004A94
      AD005A524A00424242005263630084B5C6006B9CAD004A8C9C00317384001863
      7B0010526B000000000000000000000000000000000000000000948C8C00EFE7
      D600EFE7D600EFE7D600EFE7D600EFE7D600E7E7CE00E7DECE000031E7000031
      E700A5A59C00000000000000000000000000BDA584008C4A0000AD6B2900BD84
      4A00C6845200FFFFFF00FFFFFF00CE9C6B00FFFFFF00FFFFFF00CE9C6B00BD84
      4A00BD7B4A00AD7339008C4A0000BDA584000000000000000000000000000000
      000031A5FF0031A5FF004A423900B59C8C00F7E7C600FFEFCE00FFF7CE00FFF7
      CE00EFDEC600D6ADA5000000000000000000005A7B004294AD0084C6D6004A94
      A50073B5CE0052737B00189CC60018526B00425A940073A5B5004A8C9C001863
      730000425A000000000000000000000000000000000000000000948C8C00EFE7
      D600EFE7D600EFE7D600EFE7D600EFE7D600EFE7D6000031E700184AFF00184A
      FF000031E700A5A59C0000000000000000009C73390094520000B57B4200C684
      5200C6845200FFFFFF00FFFFFF00CE9C6B00FFFFFF00FFFFFF00CE9C6B00C684
      5200BD844A00B57B4A00945208009C7339000000000000000000000000000000
      00000000000000000000BD9C8C00F7E7B500FFF7D600FFF7CE00FFF7CE00FFFF
      D600FFF7D600F7E7C600D6ADA50000000000186B7B00429CBD0084C6D6004A94
      A50073B5CE0052737B00297B9C00947B7300189CC600425A94004A8C9C00216B
      840010526B0000000000000000000000000000000000948C8C00EFE7D600EFE7
      D600EFE7D600EFE7D6004A4A42007B7B7B000031E700184AFF00E7DECE00E7DE
      CE00184AFF000031E700A5A59C00000000008C5A18009C520800BD7B4A00C684
      5200C68C5200FFFFFF00FFFFFF00CE9C6B00FFFFFF00FFFFFF00CE9C6B00C684
      5200BD844A00B57B4A009C5A1000945A18000000000000000000000000000000
      000000000000D6BDB500EFE7B500FFEFBD00FFF7C600FFF7C600FFF7C600B55A
      1800FFFFC600FFFFD600D6ADA50000000000186B7B00429CBD0084C6D6004A94
      A50073B5CE009CCEDE00189CC60021D6FF0000BDEF00189CC600425A9400216B
      840010526B00000000000000000000000000948C8C00EFE7D600EFEFDE00EFEF
      DE00EFEFDE00EFE7DE00EFE7D6000031E700184AFF00EFE7D600E7E7D600E7DE
      CE00E7DECE00184AFF000031E700B5B5AD008C5A18009C5A0800BD7B4A00C684
      5200C68C5200FFFFFF00FFFFFF00CE9C6B00FFFFFF00FFFFFF00CE9C6B00C684
      5200BD844A00B57B4A009C5A1000945A18000000000000000000000000000000
      000000000000D6ADA500EFE7B500FFEFBD00EFE7B500EFE7B500EFE7B500EF8C
      4200B55A1800FFFFC600EFE7BD00D6ADA500186B7B00218CA500529CB5004A94
      A5006BADC6008CC6D600189CC600ADEFFF0021D6FF0000BDEF00189CC600425A
      940010526B00000000000000000000000000948C8C00EFEFDE00F7EFE7007B7B
      7B004A4A42007B7B7B007B7B7B004A4A42004A4A42007B7B7B004A4A42004A4A
      4200E7DECE00E7DECE00E7DECE00A5A59C009C73390094520800B57B4200BD84
      5200C6845200FFFFFF00FFFFFF00CE9C6B00FFFFFF00FFFFFF00CE9C6B00C684
      5200BD844A00B57B4A009C5A1000A57339000000000000000000000000000000
      000000000000D6ADA500EFE7B500F7EFBD00EF8C4200EF8C4200EF8C4200EF8C
      4200EF8C4200B55A1800F7EFC600CEAD9C00005A7B00398CA50073B5CE004A94
      A5006BB5CE0094CEDE00C6E7EF00189CC600ADEFFF0021D6FF0000BDEF00189C
      C600425A9400000000000000000000000000A5A59C00EFE7D600F7EFE700F7EF
      E700F7EFE700F7EFE700EFEFDE00EFE7D600EFE7D600EFE7D600EFE7D600E7DE
      CE00E7DECE00E7DECE00E7DECE00A5A59C00BDA57B0094520000AD733900BD84
      4A00C6845200FFFFFF00FFFFFF00CE9C6B00FFFFFF00FFFFFF00CE9C6B00BD84
      5200BD7B4A00AD73420094520800C6A57B000000000000000000000000000000
      000000000000D6ADA500EFDEB500F7E7BD00FFF7D600FFF7D600FFEFC600EFA5
      6B00B55A1800FFF7C600EFE7BD00D6B5A500186B7B00429CBD0084C6D6004A94
      A50073B5CE009CCEDE00D6EFF700C6DEDE00189CC600ADEFFF0021D6FF0000BD
      EF00189CC600425A9400000000000000000000000000A5A59C00EFE7D600F7F7
      EF004A4A42007B7B7B004A4A42007B7B7B004A4A42004A4A42007B7B7B00E7DE
      CE00E7DECE00E7DECE00CEC6BD00B5B5AD00000000008C520800A5632100B57B
      4A00BD845200FFFFFF00FFFFFF00CE9C6B00FFFFFF00FFFFFF00CE9C6B00BD7B
      4A00B57B4A00A56B310094520800000000000000000000000000000000000000
      000000000000D6BDB500E7DEB500EFE7B500F7E7BD00FFEFC600FFEFBD00B55A
      1800FFEFBD00F7EFBD00D6ADA50000000000186B7B00429CBD0084C6D6004A94
      A50073B5CE009CCEDE00D6EFF700C6DEDE009CC6CE00189CC600ADEFFF0021D6
      FF0031ADF70021299C0010087300000000000000000000000000A5A59C00EFE7
      D600F7EFE700F7EFE700EFEFDE00EFE7D600EFE7D600EFE7D600EFE7D600E7DE
      CE00E7DECE00CEC6BD00A5A59C000000000000000000C6A57B0094520800B57B
      4A00BD845200BD844A00BD845200BD845200BD845200BD845200BD7B4A00B57B
      4A00BD84520094520800C6A57B00000000000000000000000000000000000000
      00000000000000000000D6ADA500EFDEBD00EFE7B500F7E7B500F7E7B500F7E7
      B500EFE7B500F7E7BD00D6BDB50000000000186B7B00429CBD0073A5B5004A8C
      9C0029849C0029849C0029849C0029849C00397B8C00397B8C00189CC6004A9C
      EF000018C600425AC60021299C0010087300000000000000000000000000A5A5
      9C00A5A59C00EFE7D600EFE7DE00EFE7D600EFE7D600EFE7D600EFE7D600CEC6
      BD00A5A59C00B5B5AD0000000000000000000000000000000000AD8C52009C5A
      1000CE946300CE9C6B00BD845200BD7B4A00B57B4A00BD845200CE946B00CE9C
      6B009C631800B58C520000000000000000000000000000000000000000000000
      0000000000000000000000000000D6ADA500E7D6B500EFDEB500EFDEB500EFDE
      B500D6ADA500D6BDB5000000000000000000397B940029849C004A94A50073B5
      CE0063ADBD009CC6CE00C6DEDE009CC6CE0073B5CE004A94A500216B7B000018
      C6008C9CE7008C94DE000018C600000000000000000000000000000000000000
      000000000000BDBDB500A5A59C00A5A59C00A5A59C00A5A59C00A5A59C00A5A5
      9C0000000000000000000000000000000000000000000000000000000000C6A5
      7B00945A0800BD844200DEB58C00EFCEA500EFCEA500E7BD9400BD8C5200945A
      1000C6A57B000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000D6BDB500D6ADA500D6ADA500DEB5
      A500000000000000000000000000000000000000000018738C00186B84003984
      9C00398CA5005A9CAD005A9CAD00398CA50042849C0031738400185A7300398C
      9C000018C6000018C60000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000C6A57B00A57B39009C6321009C632100A57B3900C6A57B000000
      0000000000000000000000000000000000000000000000000000ADADAD009C9C
      9C009C9C9C009C9C9C009C9C9C009C9C9C009C9C9C009C9C9C009C9C9C009C9C
      9C009C9C9C009C9C9C009C9C9C0000000000000000002173B500636B73000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000636B7300F7F7
      F700F7F7F700F7F7F700EFEFEF00EFEFEF00EFEFEF00EFEFEF00E7E7E700DEDE
      DE00D6D6D600D6D6D6009C9CA500000000002173B500218CEF002173B500636B
      7300000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000C6E70000C6E70000C6E70000C6
      E70000C6E70000C6E70000C6E70000C6E70000C6E70000C6E70000C6E70000C6
      E70000C6E70000C6E70000C6E7000000000000000000636B73003173AD00636B
      7300F7F7F700F7F7F700F7F7F700EFEFEF00EFEFEF00EFEFEF00EFEFEF00E7E7
      E700DEDEDE00D6D6D6009C9CA5000000000031A5FF0052BDFF00218CEF002173
      B500636B73000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000C6E70000C6E70000C6
      E70000C6E70000C6E70000C6E70000C6E70000C6E70000C6E70000C6E70000C6
      E70000C6E70000C6E70000000000000000000000000031A5FF005ABDFF002973
      B500636B7300F7F7F700F7F7F700F7F7F700EFEFEF00EFEFEF00EFEFEF00EFEF
      EF00E7E7E700DEDEDE009C9CA500000000000000000031A5FF0052BDFF00218C
      EF002173B500636B730000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000C6E70000C6
      E70000C6E70000C6E70000C6E70000C6E70000C6E70000C6E70000C6E70000C6
      E70000C6E700000000000000000000000000000000000000000031A5FF005ABD
      FF002973B500F7F7F700F7F7F700F7F7F700F7F7F700EFEFEF00EFEFEF00EFEF
      EF00EFEFEF00E7E7E7009C9CA50000000000000000000000000031A5FF0052BD
      FF00218CEF002173B500636B7300000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000000000000000000000C6
      E70000C6E70000C6E70000C6E70000C6E70000C6E70000C6E70000C6E70000C6
      E700000000000000000000000000000000000000000000000000ADADAD0031A5
      FF004A423900E7DED600DEC6B500CEA59C00D6B5A500DEC6BD00E7DED600EFEF
      EF00EFEFEF00EFEFEF009C9CA5000000000000000000000000000000000031A5
      FF0052BDFF00218CEF005A6B730000000000D6BDB500D6ADA500D6ADA500D6AD
      A500D6BDB5000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000C6E70000C6E70000C6E70000C6E70000C6E70000C6E70000C6E7000000
      0000000000000000000000000000000000000000000000000000ADADAD00FFFF
      FF00E7DED600AD948400E7D6AD00FFEFB500F7E7B500E7D6AD00CEA59C00EFEF
      EF00EFEFEF00EFEFEF009C9CA500000000000000000000000000000000000000
      000031A5FF0031A5FF004A423900B59C8C00F7E7C600FFEFCE00FFF7CE00FFF7
      CE00EFDEC600D6ADA50000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000C6E70000C6E70000C6E70000C6E70000C6E700000000000000
      0000000000000000000000000000000000000000000000000000ADADAD00FFFF
      FF00D6BDB500EFDEAD00FFEFB500FFEFBD00FFF7BD00FFF7BD00EFDEAD00D6BD
      B500F7F7F700EFEFEF009C9CA500000000000000000000000000000000000000
      00000000000000000000BD9C8C00F7E7B500FFF7D600FFF7CE00FFF7CE00FFFF
      D600FFF7D600F7E7C600D6ADA500000000000000000000000000000000000000
      000000000000000000000000000000C6E7000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000C6E70000C6E70000C6E70000000000000000000000
      0000000000000000000000000000000000000000000000000000ADADAD00FFFF
      FF00CEA59C00EFDEAD00FFEFB500FFEFBD00FFF7BD00FFF7BD00FFEFB500CEA5
      9C00F7F7F700F7F7F7009C9CA500000000000000000000000000000000000000
      000000000000D6BDB500CE8C5200FFEFBD00EFCE9C00CE8C5200CE8C5200EFD6
      9C00EFD69C00CE8C5200EFE7BD00000000000000000000000000000000000000
      0000000000000000000000C6E70000C6E70000C6E70000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000C6E7000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000ADADAD00FFFF
      FF00D6BDB500E7D6A500F7E7B500FFEFCE00FFEFBD00FFEFBD00F7E7B500D6BD
      B500F7F7F700EFEFEF009C9CA500000000000000000000000000000000000000
      000000000000D6ADA500DE945200CE844200CE733100BD6B2900E7BD8C00D69C
      6300CE8C5200FFF7C600FFF7CE00D6ADA5000000000000000000000000000000
      00000000000000C6E70000C6E70000C6E70000C6E70000C6E700000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000ADADAD00FFFF
      FF00E7D6D600DECEAD00EFE7BD00F7EFC600F7E7B500EFDEAD00D6BD9C00DECE
      C600E7E7E700DEDEDE009C9CA500000000000000000000000000000000000000
      000000000000D6ADA500CE8C5200FFF7CE00CE8C5200E7A56B00F7D6A500D69C
      6300CE8C5200FFF7C600FFF7CE00CEAD9C000000000000000000000000000000
      000000C6E70000C6E70000C6E70000C6E70000C6E70000C6E70000C6E7000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000ADADAD00FFFF
      FF00FFFFFF00CEA59C00DEC6AD00DECEA500DECEA500DEBDA500D6B5AD00EFEF
      EF009C9CA5009C9CA5009C9CA500000000000000000000000000000000000000
      000000000000D6ADA500E7DEB500CE8C5200F7E7BD00F7BD8C00E79C6300EFCE
      9C00F7D6A500CE8C5200E7CEAD00D6B5A50000000000000000000000000000C6
      E70000C6E70000C6E70000C6E70000C6E70000C6E70000C6E70000C6E70000C6
      E700000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000ADADAD00FFFF
      FF00FFFFFF00FFFFFF00E7D6D600D6BDB500D6BDB500DECEC600FFFFFF00ADAD
      AD00FFFFFF00E7E7E7009C9CA500000000000000000000000000000000000000
      000000000000D6BDB500E7DEB500EFE7B500F7E7BD00FFEFC600FFEFBD00FFEF
      BD00FFEFBD00F7EFBD00D6ADA50000000000000000000000000000C6E70000C6
      E70000C6E70000C6E70000C6E70000C6E70000C6E70000C6E70000C6E70000C6
      E70000C6E7000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000ADADAD00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00ADAD
      AD00E7E7E7009C9C9C0000000000000000000000000000000000000000000000
      00000000000000000000D6ADA500EFDEBD00EFE7B500F7E7B500F7E7B500F7E7
      B500EFE7B500F7E7BD00D6BDB500000000000000000000C6E70000C6E70000C6
      E70000C6E70000C6E70000C6E70000C6E70000C6E70000C6E70000C6E70000C6
      E70000C6E70000C6E70000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000ADADAD00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00ADAD
      AD009C9C9C000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000D6ADA500E7D6B500EFDEB500EFDEB500EFDE
      B500D6ADA500D6BDB500000000000000000000C6E70000C6E70000C6E70000C6
      E70000C6E70000C6E70000C6E70000C6E70000C6E70000C6E70000C6E70000C6
      E70000C6E70000C6E70000C6E700000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000ADADAD009C9C
      9C009C9C9C009C9C9C009C9C9C009C9C9C009C9C9C009C9C9C009C9C9C009C9C
      A500000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000D6BDB500D6ADA500D6ADA500DEB5
      A500000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000636B7300000000000000000000000000000000000000
      0000CECECE00ADADAD00ADADAD00ADADAD00ADADAD00ADADAD00ADADAD00ADAD
      AD00000000000000000000000000000000000000000000000000000000000000
      0000CECECE00ADADAD00ADADAD00ADADAD00ADADAD00ADADAD00ADADAD00ADAD
      AD00000000000000000000000000000000000000000000000000ADADAD009C9C
      9C009C9C9C009C9C9C009C9C9C009C9C9C009C9C9C009C9C9C009C9C9C009C9C
      9C009C9C9C009C9C9C009C9C9C000000000010B5290008942100089421000894
      210008942100000000000000000000000000000000000000000010B529000894
      210008942100636B73003173AD00636B73000000000000000000000000000000
      0000CECECE00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00ADAD
      AD00000000000000000000000000000000000000000000000000000000000000
      0000CECECE00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00ADAD
      AD00000000000000000000000000000000000000000000000000ADADAD00F7F7
      F700F7F7F700F7F7F700EFEFEF00EFEFEF00EFEFEF00EFEFEF00E7E7E700DEDE
      DE00D6D6D600D6D6D6009C9CA5000000000010B5290042CE840010B5290031BD
      730008942100000000000000000000000000000000000000000010B5290042CE
      8400636B73002973B5005ABDFF0031A5FF000000000000000000000000008C6B
      7300CECECE00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00ADAD
      AD008C6B73000000000000000000000000000000000000000000000000008C6B
      7300CECECE00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00ADAD
      AD008C6B73000000000000000000000000000000000000000000ADADAD00FFFF
      FF00F7F7F700D6A58400F7F7F700EFEFEF00EFEFEF00EFEFEF00EFEFEF00E7E7
      E700DEDEDE00D6D6D6009C9CA5000000000010B5290042CE840010B5290010B5
      290008942100000000000000000000000000000000000000000010B5290042CE
      84002973B5005ABDFF0031A5FF000000000000000000000000008C6B73006B4A
      5200CECECE00FFFFFF00ADADAD00ADADAD00ADADAD00ADADAD00FFFFFF00ADAD
      AD006B4A52008C6B7300000000000000000000000000000000008C6B73006B4A
      5200CECECE00FFFFFF00ADADAD00ADADAD00ADADAD00ADADAD00FFFFFF00ADAD
      AD006B4A52008C6B730000000000000000000000000000000000ADADAD00FFFF
      FF00D6A584009C8473009C847300F7F7F700EFEFEF00EFEFEF00EFEFEF00EFEF
      EF00E7E7E700DEDEDE009C9CA5000000000010B5290042CE840042CE840042CE
      8400089421000000000000000000AD948400AD948400AD948400AD9484003173
      AD004A42390031A5FF000894210000000000000000008C6B73009C7B84006B4A
      5200CECECE00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00BDB5
      B5006B4A52007B636B008C6B730000000000000000008C6B73009C7B84006B4A
      5200CECECE00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00BDB5
      B5006B4A52007B636B008C6B7300000000000000000000000000ADADAD00FFFF
      FF00FFFFFF009C847300BDBDBD0084848400BDBDBD0084848400BDBDBD00EFEF
      EF00EFEFEF00E7E7E7009C9CA5000000000010B5290010B5290010B5290010B5
      290010B5290000000000AD948400E7D6AD00F7E7B500FFEFB50042CE8400AD94
      840010B5290010B5290010B5290000000000000000008C6B7300AD949C00734A
      520073525A00DECECE007B5A63007B5A63007B5A63007B5A6300DECECE007352
      5A00734A520084636B008C6B730000000000000000008C6B7300AD949C00734A
      520073525A00DECECE007B5A63007B5A63007B5A63007B5A6300DECECE007352
      5A00734A520084636B008C6B7300000000000000000000000000ADADAD00FFFF
      FF00FFFFFF009C847300FFFFFF0084848400F7F7F70084848400EFEFEF00EFEF
      EF00EFEFEF00EFEFEF009C9CA500000000000000000000000000CE6B00000000
      000000000000AD948400EFDEAD00FFF7BD00FFF7BD00FFEFBD00FFEFB500EFDE
      AD00AD948400000000000000000000000000000000008C6B7300AD949C007B5A
      63006B4A52006B4A52006B4A52006B4A52006B4A52006B4A52006B4A52006B4A
      52007B5A63008C6B73008C6B730000000000000000008C6B7300AD949C007B5A
      63006B4A52006B4A52006B4A52006B4A52006B4A52006B4A52006B4A52006B4A
      52007B5A63008C6B73008C6B7300000000000000000000000000ADADAD00FFFF
      FF00FFFFFF009C847300BDBDBD0084848400BDBDBD0084848400F7F7F700EFEF
      EF00EFEFEF00EFEFEF009C9CA500000000000000000000000000BD5A1000AD4A
      0000AD4A0000AD948400D6BD9C00D6BD9C00D6BD9C00D6BD9C00D6BD9C00EFDE
      AD00AD948400000000000000000000000000000000008C6B7300AD949C009C7B
      840094737B0094737B0094737B0094737B0094737B0094737B0094737B009473
      7B007B8C6B00399442008C6B730000000000000000008C6B7300AD949C009C7B
      840094737B0094737B0094737B0094737B0094737B0094737B0094737B009473
      7B007B8C6B00399442008C6B7300000000000000000000000000ADADAD00FFFF
      FF00FFFFFF009C847300FFFFFF00FFFFFF00FFFFFF00FFFFFF00F7F7F700F7F7
      F700F7F7F700EFEFEF009C9CA500000000000000000000000000000000000000
      000000000000AD948400F7E7B500D6BD9C00FFEFCE00FFEFBD00F7E7B500E7D6
      A500AD948400000000000000000000000000000000008C6B7300CEBDC600A584
      8C00A5848C00A57B8C00A57B8400A57B8400A57B8400A57B84009C7B84009C7B
      840094948C0008D621008C6B730000000000000000008C6B7300CEBDC600A584
      8C00A5848C00A57B8C00A57B8400A57B8400A57B8400A57B84009C7B84009C7B
      840094948C0008D621008C6B7300000000000000000000000000ADADAD00FFFF
      FF00D6A584009C8473009C847300FFFFFF00FFFFFF00FFFFFF00FFFFFF00F7F7
      F700F7F7F700F7F7F7009C9CA500000000000000000000000000000000000000
      000000000000AD948400D6BD9C005273FF00F7E7B500F7EFC600EFE7BD00DECE
      AD00AD948400000000000000000000000000000000008C6B7300E7DEDE00CEBD
      C6009C5A6B009C5A6B009C5A6B009C5A6B009C5A6B009C5A6B009C5A6B009C5A
      6B00CEBDBD00E7DEDE008C6B730000000000000000008C6B7300E7DEDE00CEBD
      C6009C5A6B009C5A6B009C5A6B009C5A6B009C5A6B009C5A6B009C5A6B009C5A
      6B00CEBDBD00E7DEDE008C6B7300000000000000000000000000ADADAD00FFFF
      FF00FFFFFF00D6A58400FFFFFF00FFFFFF00949494009C9C9C00FFFFFF00FFFF
      FF00F7F7F700F7F7F7009C9CA500000000000000000000000000000000000000
      00000000000000000000AD9484005273FF005273FF00DECEA500DEC6AD00AD94
      840000000000000000000000000000000000000000008C6B73008C6B73005A39
      39008C6B73008C6B73008C6B73008C6B73008C6B73008C6B73008C6B73008C6B
      73005A3939008C6B73008C6B730000000000000000008C6B73008C6B73005A39
      39008C6B73008C6B73008C6B73008C6B73008C6B73008C6B7300845218008452
      1800845218008452180084521800000000000000000000000000ADADAD00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF009494940084848400FFFFFF00FFFF
      FF00F7F7F700F7F7F7009C9CA500000000000000000000000000000000000000
      0000000000000021BD001042FF00AD948400AD948400AD948400AD9484000000
      0000000000000000000000000000000000000000000000000000000000005A39
      3900CECECE00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00F7F7F700ADAD
      AD005A3939000000000000000000000000000000000000000000000000005A39
      3900CECECE00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF0084521800FFFF
      FF0021A5210021A5210084521800000000000000000000000000ADADAD00FFFF
      FF00FFFFFF009C847300FFFFFF00FFFFFF00A5A5A5008C8C8C00FFFFFF009C84
      7300FFFFFF00F7F7F7009C9CA500000000000000000000000000000000000000
      00000021BD005273FF00395AFF00395AFF00395AFF001042FF000021BD000000
      0000000000000000000000000000000000000000000000000000000000005A39
      3900CECECE00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00ADAD
      AD005A3939000000000000000000000000000000000000000000000000005A39
      3900CECECE00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF008452180021A5
      210021B5210021B5210084521800000000000000000000000000ADADAD00FFFF
      FF00D6A584009C8473009C8473009C8473009C8473009C8473009C8473009C84
      73009C847300FFFFFF009C9CA500000000000000000000000000000000000000
      0000000000000021BD005273FF00395AFF001042FF000021BD00000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000CECECE00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00ADAD
      AD00000000000000000000000000000000000000000000000000000000000000
      0000CECECE00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF008452180021B5
      2100FFFFFF0021B5210021A52100000000000000000000000000ADADAD00FFFF
      FF00FFFFFF00D6A58400FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00D6A5
      8400FFFFFF00FFFFFF009C9CA500000000000000000000000000000000000000
      000000000000000000000021BD005273FF000021BD0000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000CECECE00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00ADAD
      AD00000000000000000000000000000000000000000000000000000000000000
      0000CECECE00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00845218008452
      1800845218008452180021B5210021A521000000000000000000ADADAD00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF009C9CA500000000000000000000000000000000000000
      00000000000000000000000000000021BD000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000CECECE00ADADAD00ADADAD00ADADAD00ADADAD00ADADAD00ADADAD00ADAD
      AD00000000000000000000000000000000000000000000000000000000000000
      0000CECECE00ADADAD00ADADAD00ADADAD00ADADAD00ADADAD00ADADAD00ADAD
      AD0000000000000000000000000021B521000000000000000000ADADAD009C9C
      9C009C9C9C009C9C9C009C9C9C009C9C9C009C9C9C009C9C9C009C9C9C009C9C
      A5009C9CA5009C9CA5009C9CA50000000000000000002173B500636B73000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000ADADAD009C9C9C009C9C9C009C9C9C009C9C9C009C9C9C009C9C
      9C009C9C9C009C9C9C009C9C9C00000000000000000000000000000000000000
      000000000000ADADAD009C9C9C009C9C9C009C9C9C009C9C9C009C9C9C009C9C
      9C009C9C9C009C9C9C009C9C9C00000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000002173B500218CEF002173B500636B
      7300000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000087BCE00086BB500086B
      B500086BB500ADADAD00FFFFFF00FFFFFF00FFFFF700F7F7F700EFEFEF00EFEF
      EF00DEDEDE00D6D6D6009C9C9C00000000000000000000000000000000000000
      000000000000ADADAD00FFFFFF00FFFFFF00FFFFF700F7F7F700EFEFEF00EFEF
      EF00DEDEDE00D6D6D6009C9C9C00000000000000000000000000000000000000
      0000000000000863BD000863BD000000000000000000000000000863BD000863
      BD000000000000000000000000000000000031A5FF0052BDFF00218CEF002173
      B500636B73000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000088CDE0039B5EF0039B5
      EF0039B5EF00ADADAD00FFFFFF00FFFFFF00FFFFFF00FFFFFF00F7F7F700F7F7
      F700EFEFEF00EFEFE7009C9C9C00000000000000000000000000000000000000
      000000000000ADADAD00FFFFFF00F7F7F700F7F7F700F7F7F700F7F7F700F7F7
      F700EFEFEF00EFEFE7009C9C9C00000000000000000000000000000000000000
      0000006BDE00006BDE00006BDE000863BD00000000000863BD00006BDE00006B
      DE00006BDE000000000000000000000000000000000031A5FF0052BDFF00218C
      EF002173B500636B730000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000088CDE0039B5EF0039B5
      EF0021B5EF00ADADAD00FFFFFF00DEDEDE00CECECE00CECECE00CECECE00CECE
      CE00CECECE00EFEFEF009C9C9C00000000000000000000000000000000000000
      000000000000ADADAD00FFFFFF00CECECE00CECECE00CECECE00CECECE00CECE
      CE00CECECE00EFEFEF009C9C9C00000000000000000000000000000000000000
      0000006BDE0000000000000000000863BD00000000000863BD00000000000000
      0000006BDE00000000000000000000000000000000000000000031A5FF0052BD
      FF00218CEF002173B500636B7300000000000000000000000000000000000000
      00000000000000000000000000000000000000000000088CDE0039BDF70039B5
      EF0021B5EF00ADADAD00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00F7F7F700F7F7F7009C9C9C000000000000000000ADADAD009C9C9C009C9C
      9C009C9C9C00ADADAD00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00F7F7F7009C9C9C00000000000000000000000000000000000000
      0000006BDE003194EF00000000000863BD00000000000863BD00000000003194
      EF00006BDE0000000000000000000000000000000000000000000000000031A5
      FF0052BDFF00218CEF005A6B730000000000D6BDB500D6ADA500D6ADA500D6AD
      A500D6BDB50000000000000000000000000000000000088CDE0039BDF70039BD
      F70021B5EF00ADADAD00FFFFFF00DEDEDE00CECECE00CECECE00CECECE00CECE
      CE00CECECE00F7F7F7009C9C9C000000000000000000ADADAD00FFFFFF00FFFF
      FF00FFFFF700ADADAD00FFFFFF00F7F7F700F7F7F700F7F7F700F7F7F700F7F7
      F700F7F7F700F7F7F7009C9C9C00000000000000000000000000000000000000
      00004A7BCE00006BDE00006BDE000863BD00A59484000863BD00006BDE00006B
      DE004A7BCE000000000000000000000000000000000000000000000000000000
      000031A5FF0031A5FF004A423900B59C8C00F7E7C600FFEFCE00FFF7CE00FFF7
      CE00EFDEC600D6ADA500000000000000000000000000088CDE0042BDF70039BD
      F70021B5EF00ADADAD00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF009C9C9C000000000000000000ADADAD00FFFFFF00F7F7
      F700F7F7F700ADADAD00FFFFFF00CECECE00CECECE00CECECE00CECECE00CECE
      CE00CECECE00FFFFFF009C9C9C00000000000000000000000000000000000000
      0000000000004A7BCE004A7BCE000863BD008C634A000863BD004A7BCE004A7B
      CE00000000000000000000000000000000000000000000000000000000000000
      00000000000000000000BD9C8C00F7E7B500FFF7D600FFF7CE00FFF7CE00FFFF
      D600FFF7D600F7E7C600D6ADA5000000000000000000088CDE0042BDF70042BD
      F70021B5EF00ADADAD00FFFFFF00DEDEDE00CECECE00CECECE00CECECE00FFFF
      FF00FFFFFF00FFFFFF009C9C9C000000000000000000ADADAD00FFFFFF00CECE
      CE00CECECE00ADADAD00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF009C9C9C00000000000000000000000000000000000000
      000000000000000000000000000084848400E7DED60084848400000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000D6BDB500EFE7B500FFEFBD00FFF7C600FFF7C600FFF7C600FFF7
      C600FFFFC600FFFFD600D6ADA5000000000000000000088CDE0042C6F70042BD
      F70021B5EF00ADADAD00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF009C9C9C009C9C9C009C9C9C000000000000000000ADADAD00FFFFFF00FFFF
      FF00FFFFFF00ADADAD00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF009C9C9C00000000000000000000000000000000000000
      0000000000000000000084848400EFEFEF0084848400EFEFEF00848484000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000D6ADA500EFE7B500FFEFBD00FFEFBD00FFF7C600FFF7C600FFF7
      C600FFF7C600FFFFC600EFE7BD00D6ADA50000000000088CDE0042C6FF0042C6
      F70021B5EF00ADADAD00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF009C9C9C00FFFFFF009C9C9C000000000000000000ADADAD00FFFFFF00F7F7
      F700F7F7F700ADADAD00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00ADAD
      AD009C9C9C009C9C9C009C9C9C00000000000000000000000000000000000000
      00000000000000000000A5A5A500EFEFEF00A5A5A500EFEFEF00A5A5A5000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000D6ADA500EFE7B500F7EFBD00FFF7D600FFF7CE00FFF7C600FFF7
      C600FFF7C600FFF7C600F7EFC600CEAD9C0000000000088CDE0042C6FF0042C6
      FF0021B5EF00ADADAD00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF009C9C9C009C9C9C00000000000000000000000000ADADAD00FFFFFF00CECE
      CE00CECECE00ADADAD00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00ADAD
      AD00FFFFFF009C9C9C0000000000000000000000000000000000000000000000
      000000000000A5A5A500EFEFEF00A5A5A50000000000A5A5A500EFEFEF00A5A5
      A500000000000000000000000000000000000000000000000000000000000000
      000000000000D6ADA500EFDEB500F7E7BD00FFF7D600FFF7D600FFEFC600FFEF
      C600FFF7C600FFF7C600EFE7BD00D6B5A50000000000088CDE004AC6FF0042C6
      FF0042C6FF00ADADAD009C9C9C009C9C9C009C9C9C009C9C9C009C9C9C009C9C
      9C009C9C9C0000000000000000000000000000000000ADADAD00FFFFFF00FFFF
      FF00FFFFFF00ADADAD009C9C9C009C9C9C009C9C9C009C9C9C009C9C9C009C9C
      9C009C9C9C000000000000000000000000000000000000000000000000000000
      00000000000084848400A5A5A500000000000000000000000000A5A5A5008484
      8400000000000000000000000000000000000000000000000000000000000000
      000000000000D6BDB500E7DEB500EFE7B500F7E7BD00FFEFC600FFEFBD00FFEF
      BD00FFEFBD00F7EFBD00D6ADA5000000000000000000088CDE004ACEFF004AC6
      FF0021B5EF0021B5EF0021B5EF0021B5EF0021B5EF0021B5EF0039BDF70039BD
      EF000873B50000000000000000000000000000000000ADADAD00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF009C9C9C000000
      0000000000000000000000000000000000000000000000000000000000000000
      000084848400EFEFEF00B5B5B500000000000000000000000000B5B5B500EFEF
      EF00848484000000000000000000000000000000000000000000000000000000
      00000000000000000000D6ADA500EFDEBD00EFE7B500F7E7B500F7E7B500F7E7
      B500EFE7B500F7E7BD00D6BDB50000000000000000000884D6004ACEFF0021B5
      EF009CA5A5009CA5A5009CA5A5009CA5A5009CA5A5009CA5A50021B5EF0039BD
      F700087BC60000000000000000000000000000000000ADADAD00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00ADADAD009C9C9C009C9C9C009C9C9C000000
      0000000000000000000000000000000000000000000000000000000000000000
      000084848400A5A5A5000000000000000000000000000000000000000000A5A5
      A500848484000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000D6ADA500E7D6B500EFDEB500EFDEB500EFDE
      B500D6ADA500D6BDB500000000000000000000000000000000000884D6000884
      D6009CA5A500FFFFFF00E7E7E700E7E7E700B5B5BD009CA5A5000873B500087B
      C6000000000000000000000000000000000000000000ADADAD00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00ADADAD00FFFFFF009C9C9C00000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000A5A5A5000000000000000000000000000000000000000000000000000000
      0000A5A5A5000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000D6BDB500D6ADA500D6ADA500DEB5
      A500000000000000000000000000000000000000000000000000000000000000
      0000000000009CA5A5009CA5A5009CA5A5009CA5A50000000000000000000000
      00000000000000000000000000000000000000000000ADADAD009C9C9C009C9C
      9C009C9C9C009C9C9C009C9C9C009C9C9C009C9C9C0000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000021212100000000000000
      0000212121000000000000000000212121000000000000000000212121000000
      0000000000002121210000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000002173B500636B73000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000021212100000000002121
      2100000000002121210000000000212121000000000021212100000000002121
      21000000000021212100000000000000000000000000000000005A5A5A005252
      5200B5B5B500B5B5B500B5B5B500B5B5B500B5B5B500B5B5B500B5B5B5005A5A
      5A005A5A5A006363630000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000002173B500218CEF002173B500636B
      7300000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000021212100000000000000
      000021212100000000000000000021212100000000000000000021212100299C
      42000000000021212100000000000000000000000000525252006B6B6B005A5A
      5A00B5B5B500636363007373730052525200CECECE00D6D6D600DEDEDE005252
      5200525252005A5A5A0039393900000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000031A5FF0052BDFF00218CEF002173
      B500636B73000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000ADADAD009C9C9C009C9C
      9C009C9C9C009C9C9C009C9C9C009C9C9C009C9C9C009C9C9C009C9C9C004ACE
      7300187B31000000000000000000000000000000000052525200737373005A5A
      5A00B5B5B500525252006363630052525200C6C6C600CECECE00D6D6D6004A4A
      4A004A4A4A005252520042424200000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000031A5FF0052BDFF00218C
      EF002173B500636B730000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000ADADAD00FFFFFF00FFFF
      FF00FFFFF700F7F7F700EFEFEF00EFEFEF00DEDEDE00299C42004ACE730031A5
      4A00299C4200187B310000000000000000000000000052525200737373005A5A
      5A00B5B5B5004A4A4A005252520052525200BDBDBD00C6C6C600CECECE004242
      4200424242005252520042424200000000000000000000000000000000000000
      0000000000000000FF0000FF00000000FF000000FF000000FF00000000000000
      000000000000000000000000000000000000000000000000000031A5FF0052BD
      FF00218CEF002173B500636B7300000000000000000000000000000000000000
      00000000000000000000000000000000000000000000ADADAD00FFFFFF00F7F7
      F700F7F7F700F7F7F700F7F7F700F7F7F700299C4200299C4200299C42004ACE
      730031A54A00218C3100218C310000000000000000004A4A4A007B7B7B006363
      6300B5B5B500B5B5B500B5B5B500B5B5B500BDBDBD00BDBDBD00C6C6C6003939
      390039393900525252004A4A4A00000000000000000000000000000000000000
      00000000FF0000FF000000FF000000FF00000000FF000000FF000000FF000000
      00000000000000000000000000000000000000000000000000000000000031A5
      FF0052BDFF00218CEF005A6B730000000000D6BDB500D6ADA500D6ADA500D6AD
      A500D6BDB50000000000000000000000000000000000ADADAD00FFFFFF00CECE
      CE00ADADAD00ADADAD00ADADAD00ADADAD00CECECE00EFEFEF0039C663004ACE
      73000000000000000000000000000000000000000000525252007B7B7B006363
      6300636363005A5A5A005A5A5A005A5A5A005A5A5A005A5A5A005A5A5A005252
      520052525200525252004A4A4A00000000000000000000000000000000000000
      000000FF000000FF00000000FF0000FF00000000FF000000FF000000FF000000
      0000000000000000000000000000000000000000000000000000000000000000
      000031A5FF0031A5FF004A423900B55A1800E7C69C00E7BD8C00C66B2900D68C
      5A00EFDEC600D6ADA500000000000000000000000000ADADAD00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00F7F7F70039C66300187B
      310000000000000000000000000000000000000000004A4A4A009C9C9C00BDBD
      BD00BDBDBD00BDBDBD00BDBDBD00BDBDBD00BDBDBD00BDBDBD00BDBDBD00BDBD
      BD00BDBDBD00BDBDBD0052525200000000000000000000000000000000000000
      00000000FF000000FF000000FF0000FF000000FF00000000FF000000FF000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000BD9C8C00EF945200B55A1800EF945200EF8C4A00DE84
      3900DEB58400F7E7C600D6ADA5000000000000000000ADADAD00FFFFFF00F7F7
      F700F7F7F700F7F7F700F7F7F700F7F7F700F7F7F7009CD6AD004ACE7300299C
      4200000000000000000000000000000000000000000052525200ADADAD00F7F7
      F700F7F7F700FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF0052525200000000000000000000000000000000000000
      00000000FF000000FF000000FF000000FF0000FF00000000FF000000FF000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000D6BDB500EFE7B500EF945200EFA56B00B55A1800EFD69C00FFDE
      B500EF945200EFBD9400D6ADA5000000000000000000ADADAD00FFFFFF00CECE
      CE00ADADAD00ADADAD00ADADAD00ADADAD009CD6AD0039C66300299C42000000
      0000000000000000000000000000000000000000000052525200B5B5B500F7F7
      F700D6D6D600BDBDBD00BDBDBD00BDBDBD00BDBDBD00BDBDBD00BDBDBD00BDBD
      BD00EFEFEF00FFFFFF0052525200000000000000000000000000000000000000
      00000000FF000000FF000000FF000000FF0000FF000000FF00000000FF000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000D6ADA500EFE7B500EF945200EF945200EF945200B55A1800EFD6
      9C00FFEFB500EF945200EFE7BD00D6ADA50000000000ADADAD00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF0039C66300299C42009CD6AD000000
      000000000000000000000000000000000000000000005A5A5A00BDBDBD00F7F7
      F700F7F7F700F7F7F700F7F7F700F7F7F700FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF005A5A5A00000000000000000000000000000000000000
      0000000000000000FF000000FF000000FF000000FF0000FF0000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000D6ADA500EFE7B500F7DEAD00FFF7D600FFDEAD00E7BD8C00E7BD
      8C00E7C68C00F7E7B500F7EFC600CEAD9C0000000000ADADAD00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF009C9C9C000000
      000000000000000000000000000000000000000000005A5A5A00BDBDBD00F7F7
      F700D6D6D600BDBDBD00BDBDBD00BDBDBD00BDBDBD00BDBDBD00BDBDBD00BDBD
      BD00EFEFEF00FFFFFF005A5A5A00000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000FF000000FF00000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000D6ADA500EFDEB500EF945200FFF7D600F7DEB500EF945200B55A
      1800B55A1800FFF7C600EFE7BD00D6B5A50000000000ADADAD00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00ADADAD009C9C9C009C9C9C009C9C9C000000
      0000000000000000000000000000000000000000000063636300C6C6C600F7F7
      F700F7F7F700F7F7F700F7F7F700F7F7F700F7F7F700F7F7F700F7F7F700F7F7
      F700F7F7F700FFFFFF0063636300000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000D6BDB500E7DEB500EFBD8400EF945200E7B58400E7AD7300EF94
      5200B55A1800F7EFBD00D6ADA5000000000000000000ADADAD00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00ADADAD00FFFFFF009C9C9C00000000000000
      0000000000000000000000000000000000000000000063636300CECECE00F7F7
      F700F7F7F700F7F7F700F7F7F700F7F7F700F7F7F700F7F7F700F7F7F700F7F7
      F700FFFFFF00EFEFEF0063636300000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000D6ADA500EFDEBD00E7AD7300EF945200EF945200DEA5
      6B00EF945200F7E7BD00D6BDB5000000000000000000ADADAD009C9C9C009C9C
      9C009C9C9C009C9C9C009C9C9C009C9C9C009C9C9C0000000000000000000000
      000000000000000000000000000000000000000000000000000063636300EF94
      3100E78C2900E7842100DE7B2100D67B1800D6731800CE731000CE6B1000C66B
      1000C66308006363630000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000D6ADA500E7D6B500EFBD8400EFBD8400EFDE
      B500EF945200D6BDB50000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000D6BDB500D6ADA500D6ADA500DEB5
      A500000000000000000000000000000000000000000000000000000000000000
      000000000000B59C8400946B39008452180084521800946B3900B59C84000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000B59C8400946B39008452180084521800946B3900B59C84000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000B59C8400946B39008452180084521800946B3900B59C84000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000B59C8400946B39008452180084521800946B3900B59C84000000
      000000000000000000000000000000000000000000000000000000000000B59C
      84007B4A08008C4A0000945200009C5A08009C5A1000945208008C4A0000844A
      0800BDA58400000000000000000000000000000000000000000000000000B59C
      84007B4A08008C4A0000945200009C5A08009C5A1000945208008C4A0000844A
      0800BDA58400000000000000000000000000000000000000000000000000B59C
      84007B4A08008C4A0000945200009C5A08009C5A1000945208008C4A0000844A
      0800BDA58400000000000000000000000000000000000000000000000000B59C
      84007B4A08008C4A0000945200009C5A08009C5A1000945208008C4A0000844A
      0800BDA5840000000000000000000000000000000000000000009C845A00844A
      000094520800AD6B2900BD7B4200BD7B4A00BD7B4A00BD7B4200AD7331009C5A
      1000844A0000A5845A00000000000000000000000000000000009C845A00844A
      000094520800AD6B2900BD7B4200BD7B4A00BD7B4A00BD7B4200AD7331009C5A
      1000844A0000A5845A00000000000000000000000000000000009C845A00844A
      000094520800AD6B2900BD7B4200BD7B4A00BD7B4A00BD7B4200AD7331009C5A
      1000844A0000A5845A00000000000000000000000000000000009C845A00844A
      000094520800AD6B2900BD7B4200BD7B4A00BD7B4A00BD7B4200AD7331009C5A
      1000844A0000A5845A00000000000000000000000000B59C8400844A00009C5A
      1000BD7B4200BD844A00C6844A00C6844A00C6844A00BD844A00BD7B4A00B57B
      4200A56318008C4A0000BDA584000000000000000000B59C8400844A00009C5A
      1000BD7B4200BD844A00C6844A00C6844A00C6844A00BD844A00BD7B4A00B57B
      4200A56318008C4A0000BDA584000000000000000000B59C8400844A00009C5A
      1000BD7B4200BD844A00C6844A00C6844A00C6844A00BD844A00BD7B4A00B57B
      4200A56318008C4A0000BDA584000000000000000000B59C8400844A00009C5A
      1000BD7B4200BD844A00E7CEB500FFFFFF00EFE7D600CE946B00BD7B4A00B57B
      4200A56318008C4A0000BDA584000000000000000000844A080094520000B57B
      4200BD844A00C6845200C6845200FFFFFF00EFBDA500C6845200C6844A00BD84
      4A00B57B42009C5A1000844A08000000000000000000844A080094520000B57B
      4200BD844A00C6845200C6845200C6845200C6845200C6845200C6844A00BD84
      4A00B57B42009C5A1000844A08000000000000000000844A080094520000B57B
      4200BD844A00C6845200C6845200C6845200C6845200C6845200C6844A00BD84
      4A00B57B42009C5A1000844A08000000000000000000844A080094520000B57B
      4200BD844A00C6845200EFD6BD00FFFFFF00E7C6AD00F7E7DE00C68C5A00BD84
      4A00B57B42009C5A1000844A080000000000BDA584008C4A0000AD6B2900BD84
      4A00C6845200C68C5200CE8C5200FFFFFF00FFFFFF00EFBDA500C6845200BD84
      4A00BD7B4A00AD7339008C4A0000BDA58400BDA584008C4A0000AD6B2900BD84
      4A00C6845200C68C5200FFFFFF00DEB58C00CE8C5200C68C5200C6845200BD84
      4A00BD7B4A00AD7339008C4A0000BDA58400BDA584008C4A0000AD6B2900BD84
      4A00C6845200FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00BD84
      4A00BD7B4A00AD7339008C4A0000BDA58400BDA584008C4A0000AD6B2900BD84
      4A00C6845200C68C5200D6AD8400FFFFFF00F7E7D600C68C5200C6845200BD84
      4A00BD7B4A00AD7339008C4A0000BDA584009C73390094520000B57B4200C684
      5200FFFFFF00FFFFFF00FFFFFF00FFFFFF00CE8C5A00FFFFFF00EFBDA500C684
      5200BD844A00B57B4A00945208009C7339009C73390094520000B57B4200C684
      5200C6845200CE8C5200FFFFFF00FFFFFF00FFFFFF00DEB58C00C68C5200C684
      5200BD844A00B57B4A00945208009C7339009C73390094520000B57B4200C684
      5200C6845200FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00C684
      5200BD844A00B57B4A00945208009C7339009C73390094520000B57B4200C684
      5200C6845200CE8C5200CE8C5A00FFF7F700FFFFFF00CE945A00C68C5200C684
      5200BD844A00B57B4A00945208009C7339008C5A18009C520800BD7B4A00C684
      5200FFFFFF00CE8C5200CE8C5A00CE8C5A00CE8C5A00CE8C5A00FFFFFF00EFBD
      A500BD844A00B57B4A009C5A1000945A18008C5A18009C520800BD7B4A00C684
      5200C68C5200CE8C5200FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00DEB5
      8C00BD844A00B57B4A009C5A1000945A18008C5A18009C520800BD7B4A00C684
      5200C68C5200FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00C684
      5200BD844A00B57B4A009C5A1000945A18008C5A18009C520800BD7B4A00C684
      5200C68C5200CE8C5200CE8C5A00EFD6BD00FFFFFF00DEB59400C68C5200C684
      5200BD844A00B57B4A009C5A1000945A18008C5A18009C5A0800BD7B4A00C684
      5200FFFFFF00CE8C5200CE8C5A00CE8C5A00CE8C5A00CE8C5A00C68C5200FFFF
      FF00EFBDA500B57B4A009C5A1000945A18008C5A18009C5A0800BD7B4A00C684
      5200C68C5200CE8C5200FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00DEB58C00B57B4A009C5A1000945A18008C5A18009C5A0800BD7B4A00C684
      5200C68C5200FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00C684
      5200BD844A00B57B4A009C5A1000945A18008C5A18009C5A0800BD7B4A00C684
      5200C68C5200CE8C5200CE8C5A00DEAD8400FFFFFF00EFDEC600C68C5200C684
      5200BD844A00B57B4A009C5A1000945A18009C73390094520800B57B4200BD84
      5200FFFFFF00C68C5200CE8C5A00CE8C5A00CE8C5A00CE8C5200FFFFFF00EFBD
      A500BD844A00B57B4A009C5A1000A57339009C73390094520800B57B4200BD84
      5200C6845200C68C5200FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00DEB5
      8C00BD844A00B57B4A009C5A1000A57339009C73390094520800B57B4200BD84
      5200C6845200FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00C684
      5200BD844A00B57B4A009C5A1000A57339009C73390094520800B57B4200BD84
      5200C6845200C68C5200CE8C5A00FFFFFF00FFFFFF00FFFFF700C68C5A00C684
      5200BD844A00B57B4A009C5A1000A5733900BDA57B0094520000AD733900BD84
      4A00FFFFFF00FFFFFF00FFFFFF00FFFFFF00C68C5200FFFFFF00EFBDA500BD84
      5200BD7B4A00AD73420094520800C6A57B00BDA57B0094520000AD733900BD84
      4A00C6845200C68C5200FFFFFF00FFFFFF00FFFFFF00DEB58C00C6845200BD84
      5200BD7B4A00AD73420094520800C6A57B00BDA57B0094520000AD733900BD84
      4A00C6845200FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00BD84
      5200BD7B4A00AD73420094520800C6A57B00BDA57B0094520000AD733900BD84
      4A00C6845200C68C5200C68C5200C68C5200C68C5200C68C5200C6845200BD84
      5200BD7B4A00AD73420094520800C6A57B00000000008C520800A5632100B57B
      4A00BD845200BD845200C6845200FFFFFF00FFFFFF00EFBDA500BD845200BD7B
      4A00B57B4A00A56B31009452080000000000000000008C520800A5632100B57B
      4A00BD845200BD845200FFFFFF00DEB58C00C6845200C6845200BD845200BD7B
      4A00B57B4A00A56B31009452080000000000000000008C520800A5632100B57B
      4A00BD845200BD845200C6845200C6845200C6845200C6845200BD845200BD7B
      4A00B57B4A00A56B31009452080000000000000000008C520800A5632100B57B
      4A00BD845200BD845200C6845200C6845200C6845200C6845200BD845200BD7B
      4A00B57B4A00A56B3100945208000000000000000000C6A57B0094520800B57B
      4A00BD845200BD844A00BD845200FFFFFF00EFBDA500BD845200BD7B4A00B57B
      4A00BD84520094520800C6A57B000000000000000000C6A57B0094520800B57B
      4A00BD845200BD844A00BD845200BD845200BD845200BD845200BD7B4A00B57B
      4A00BD84520094520800C6A57B000000000000000000C6A57B0094520800B57B
      4A00BD845200BD844A00BD845200BD845200BD845200BD845200BD7B4A00B57B
      4A00BD84520094520800C6A57B000000000000000000C6A57B0094520800B57B
      4A00BD845200BD844A00BD845200BD845200F7EFDE00F7E7DE00BD7B4A00B57B
      4A00BD84520094520800C6A57B00000000000000000000000000AD8C52009C5A
      1000CE946300CE9C6B00BD845200BD7B4A00B57B4A00BD845200CE946B00CE9C
      6B009C631800B58C520000000000000000000000000000000000AD8C52009C5A
      1000CE946300CE9C6B00BD845200BD7B4A00B57B4A00BD845200CE946B00CE9C
      6B009C631800B58C520000000000000000000000000000000000AD8C52009C5A
      1000CE946300CE9C6B00BD845200BD7B4A00B57B4A00BD845200CE946B00CE9C
      6B009C631800B58C520000000000000000000000000000000000AD8C52009C5A
      1000CE946300CE9C6B00BD845200BD7B4A00F7E7DE00F7E7DE00CE946B00CE9C
      6B009C631800B58C52000000000000000000000000000000000000000000C6A5
      7B00945A0800BD844200DEB58C00EFCEA500EFCEA500E7BD9400BD8C5200945A
      1000C6A57B00000000000000000000000000000000000000000000000000C6A5
      7B00945A0800BD844200DEB58C00EFCEA500EFCEA500E7BD9400BD8C5200945A
      1000C6A57B00000000000000000000000000000000000000000000000000C6A5
      7B00945A0800BD844200DEB58C00EFCEA500EFCEA500E7BD9400BD8C5200945A
      1000C6A57B00000000000000000000000000000000000000000000000000C6A5
      7B00945A0800BD844200DEB58C00EFCEA500EFCEA500E7BD9400BD8C5200945A
      1000C6A57B000000000000000000000000000000000000000000000000000000
      000000000000C6A57B00A57B39009C6321009C632100A57B3900C6A57B000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000C6A57B00A57B39009C6321009C632100A57B3900C6A57B000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000C6A57B00A57B39009C6321009C632100A57B3900C6A57B000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000C6A57B00A57B39009C6321009C632100A57B3900C6A57B000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000CE732900A54A2100A54A
      2100A54A2100A54A2100A54A2100A54A2100A54A2100A54A2100A54A2100A54A
      2100A54A2100A54A2100A54A210000000000CE732900A54A2100A54A2100A54A
      2100A54A2100A54A2100A54A2100A54A2100A54A2100A54A2100A54A2100A54A
      2100A54A2100A54A2100A54A210000000000CE732900A54A2100A54A2100A54A
      2100A54A2100A54A2100A54A2100A54A2100A54A2100A54A2100A54A2100A54A
      2100A54A2100A54A2100A54A210000000000CE732900A54A2100A54A2100A54A
      21009C4A21009C4A21009C4A2100A54A2100A54A2100A54A2100A54A2100A54A
      2100A54A2100A54A2100A54A21000000000000000000CE732900FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00F7F7F700F7F7F700EFEFEF00EFEFEF00EFEF
      E700DEDEDE00D6D6D600A54A210000000000CE732900FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFF700F7F7F700F7F7F700EFEFEF00EFEFEF00EFEF
      E700DEDEDE00D6D6D600A54A210000000000CE732900FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFF700F7F7F700F7F7F700EFEFEF00EFEFEF00EFEF
      E700DEDEDE00D6D6D600A54A210000000000CE732900FFFFFF00FFFFFF00FFFF
      FF00E7E7DE00BDBDBD00C6C6C600E7E7DE00EFEFEF00EFEFEF00EFEFEF00EFEF
      E700DEDEDE00D6D6D600A54A21000000000000000000CE732900FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00F7F7F700F7F7F700EFEFEF00EFEF
      EF00EFEFE700DEDEDE00A54A210000000000CE732900FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFF700F7F7F700F7F7F700EFEFEF00EFEF
      EF00EFEFE700DEDEDE00A54A210000000000CE732900FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFF700F7F7F700F7F7F700EFEFEF00EFEF
      EF00EFEFE700DEDEDE00A54A210000000000CE732900FFFFFF00FFFFFF00FFFF
      F700292929005A524A009C9C9C00BDBDBD00DEDEDE00E7E7E700EFEFEF00EFEF
      EF00EFEFE700DEDEDE00A54A21000000000000000000CE732900FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00F7F7F700F7F7F700EFEF
      EF00EFEFEF00EFEFE700A54A210000000000CE732900FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFF700F7F7F700F7F7F700EFEF
      EF00EFEFEF00EFEFE700A54A210000000000CE732900FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFF700F7F7F700F7F7F700EFEF
      EF00EFEFEF00EFEFE700A54A210000000000CE732900FFFFFF00FFFFFF00FFFF
      FF005A524A00424242005263630094949400ADADAD00BDBDBD00DEDEDE00EFEF
      EF00EFEFEF00EFEFE700A54A21000000000000000000CE732900FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00F7F7F700F7F7
      F700EFEFEF00EFEFEF00A54A210000000000CE732900FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFF700F7F7F700F7F7
      F700EFEFEF00EFEFEF00A54A210000000000CE732900FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFF700F7F7F700F7F7
      F700EFEFEF00EFEFEF00A54A210000000000CE732900FFFFFF00FFFFFF00FFFF
      FF00F7F7F70052737B00189CC60018526B00425A940094949400BDBDBD00DEDE
      DE00EFEFEF00EFEFEF00A54A21000000000000000000CE732900FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00F7F7
      F700F7F7F700EFEFEF00A54A210000000000CE732900FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFF700F7F7
      F700F7F7F700EFEFEF00A54A210000000000CE732900FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFF700F7F7
      F700F7F7F700EFEFEF00A54A210000000000CE732900FFFFFF00FFFFFF00FFFF
      FF00FFFFFF0052737B00297B9C00947B7300189CC600425A940094949400BDBD
      BD00DEDEDE00EFEFEF00A54A21000000000000000000CE732900FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00F7F7F700F7F7F700A54A210000000000CE732900FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      F700F7F7F700F7F7F700A54A210000000000CE732900FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      F700F7F7F700F7F7F700A54A210000000000CE732900FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00F7F7F7009CBDD60021D6FF0000BDEF00189CC600425A94009494
      9400BDBDBD00DEDEDE00A54A21000000000000000000CE732900FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00A54A210000000000CE732900FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00F7F7
      F700F7F7F700F7F7F700A54A210000000000CE732900FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00F7F7F700A54A210000000000CE732900FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF009CBDD600ADEFFF0021D6FF0000BDEF00189CC600425A
      940094949400BDBDBD00944A18000000000000000000CE732900FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00A54A210000000000CE732900FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF002184
      39002184390021843900A54A210000000000CE732900FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00A54A210000000000CE732900FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF009CBDD600ADEFFF0021D6FF0000BDEF00189C
      C600425A9400949494007B3918000000000000000000CE732900FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00A54A210000000000CE732900FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF002184
      390031B55A0021843900A54A210000000000CE732900FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00A54A210000000000CE732900FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF009CBDD600ADEFFF0021D6FF0000BD
      EF00189CC600425A9400632910000000000000000000CE732900FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00A54A210000000000CE732900FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF0021843900218439002184
      390039C67300218439002184390021843900CE732900FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF0000189400001894000018
      940000189400001894000018940000189400CE732900FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF009CBDD600ADEFFF0021D6
      FF0031ADF70021299C00100873000000000000000000CE732900D66B0000D66B
      0000D66B0000D66B0000D66B0000D66B0000D66B0000D66B0000D66B0000D66B
      0000D66B0000D66B0000A54A210000000000CE732900D66B0000D66B0000D66B
      0000D66B0000D66B0000D66B0000D66B0000D66B0000218439007BE79C0039C6
      730039C6730039C6730031B55A0021843900CE732900D66B0000D66B0000D66B
      0000D66B0000D66B0000D66B0000D66B0000D66B0000001894008C9CF700738C
      EF00738CEF00738CEF002952E70000189400CE732900D66B0000D66B0000D66B
      0000D66B0000D66B0000D66B0000D66B0000D66B0000CE6B00009CBDD6004A9C
      EF00425AC600425AC60021299C001008730000000000CE630000EF943100EF94
      3100EF943100EF943100EF943100EF943100F7CE9C00EF943100F7CE9C00EF94
      3100316BFF007B738C00CE63000000000000CE630000EF943100EF943100EF94
      3100EF943100EF943100EF943100EF943100F7CE9C0021843900218439002184
      390039C67300218439002184390021843900CE630000EF943100EF943100EF94
      3100EF943100EF943100EF943100EF943100F7CE9C0000189400001894000018
      940000189400001894000018940000189400CE630000EF943100EF943100EF94
      3100EF943100EF943100EF943100EF943100F7CE9C00EF943100F7C69400425A
      C6008C9CE7008C94DE00425AC600000000000000000000000000DE7B0800DE7B
      0800DE7B0800DE7B0800DE7B0800DE7B0800DE7B0800DE7B0800DE7B0800DE7B
      0800DE7B0800DE7B0800000000000000000000000000DE7B0800DE7B0800DE7B
      0800DE7B0800DE7B0800DE7B0800DE7B0800DE7B0800DE7B0800DE7B08002184
      390031B55A0021843900000000000000000000000000DE7B0800DE7B0800DE7B
      0800DE7B0800DE7B0800DE7B0800DE7B0800DE7B0800DE7B0800DE7B0800DE7B
      0800DE7B0800DE7B0800000000000000000000000000DE7B0800DE7B0800DE7B
      0800DE7B0800DE7B0800DE7B0800DE7B0800DE7B0800DE7B0800DE7B0800D67B
      0800425AC600425AC60000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000002184
      3900218439002184390000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000292929005A524A0000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000398C310029942900398C3100398C
      31005A524A004242420052636300398C31001884180010841000398C3100398C
      310000000000000000000000000000000000398C310029942900398C3100398C
      3100398C3100398C3100398C3100398C31001884180010841000398C3100398C
      310000000000000000000000000000000000CE732900A54A2100A54A2100A54A
      2100A54A2100A54A2100A54A2100A54A2100A54A2100A54A2100A54A2100A54A
      2100A54A2100A54A2100A54A21000000000000000000CE732900A54A2100A54A
      2100A54A2100A54A2100A54A2100A54A2100A54A2100A54A2100A54A2100A54A
      2100A54A2100A54A2100A54A2100A54A2100398C310031B5310039B5390039B5
      39004ABD4A0052737B00189CC60018526B00425A940031B53100189418000884
      0800398C3100000000000000000000000000398C310031B5310039B5390039B5
      39004ABD4A007BD673004AA54A005AAD520073C66B0031B53100189418000884
      0800398C3100000000000000000000000000CE7329002121210094949400BDBD
      BD00D6D6D600E7E7E700E7E7E700EFEFEF00F7EFEF00D6D6D600A5A5A500A59C
      9400F7EFE700D6D6D600A54A21000000000000000000CE732900FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFF700F7F7F700F7F7F700EFEFEF00EFEF
      EF00EFEFE700DEDEDE00D6D6D600A54A210000000000398C310039B5390052C6
      52006BCE6B0052737B00297B9C00947B7300189CC600425A940031AD3100188C
      1800299C290000000000000000000000000000000000398C310039B5390052C6
      52006BCE6B0084CE7300D6F7CE0052A54A009CDE8C0052C6520031AD3100188C
      1800299C2900000000000000000000000000CE73290073737300A5A5AD005263
      84005A637B006B6B84007B7B9400A5A5AD00BDB5AD0084949C007B848C00BDBD
      BD00EFEFE700DEDEDE00A54A21000000000000000000CE732900FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFF700F7F7F700F7F7F700EFEF
      EF00EFEFEF00EFEFE700DEDEDE00A54A210000000000299C290039B5390063CE
      63007BCE730052A54A00189CC60021D6FF0000BDEF00189CC600425A9400299C
      29000000000000000000000000000000000000000000299C290039B5390063CE
      63007BCE730052A54A00FFFFFF0052A54A009CDE8C0063CE630039AD3900299C
      290000000000000000000000000000000000CE732900ADADAD00B5BDCE006384
      BD006B8CBD005A73A5004A639400314A840042527B00429CB5007BA5B500EFEF
      EF00EFEFEF00EFEFE700A54A21000000000000000000CE732900FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFF700F7F7F700F7F7
      F700EFEFEF00EFEFEF00EFEFE700A54A21000000000000000000299C2900398C
      31004A8C4200D6F7CE00189CC600ADEFFF0021D6FF0000BDEF00189CC600425A
      9400000000000000000000000000000000000000000000000000299C2900398C
      31004A8C4200D6F7CE00FFF7EF00ADBD9C004A8C4200398C3100299C29000000
      000000000000000000000000000000000000CE732900ADADAD00BDC6D6007BA5
      D6007B9CCE006384BD005A6BA5004A6BA5004A73A5004A7BA5008494AD00F7F7
      F700EFEFEF00EFEFEF00A54A21000000000000000000CE732900FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFF700F7F7
      F700F7F7F700EFEFEF00EFEFEF00A54A21000000000000000000000000000000
      0000298CA500318CCE00298CCE00189CC600ADEFFF0021D6FF0000BDEF00189C
      C600425A94000000000000000000000000000000000000000000000000000000
      0000298CA500318CCE00298CCE003184A5000000000000000000000000000000
      000000000000000000000000000000000000CE732900C6C6C600C6D6DE008CBD
      E7006384BD0031427B004A5A730052ADC6004A84A5006384B500A5BDD600F7F7
      F700F7F7F700EFEFEF00A54A21000000000000000000CE732900FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      F700F7F7F700F7F7F700EFEFEF00A54A21000000000000000000000000004A9C
      D60042ADEF0042A5EF0039A5E7002994D600189CC600ADEFFF0021D6FF0000BD
      EF00189CC600425A940000000000000000000000000000000000000000004A9C
      D60042ADEF0042A5EF0039A5E7002994D6002984AD0000000000000000000000
      000000000000000000000000000000000000CE732900FFFFFF00FFFFFF00CEE7
      F7007394BD004252730052A5BD006BADCE005A7BAD007BADD600D6E7F700FFFF
      F700F7F7F700F7F7F700A54A21000000000000000000CE732900FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFF700F7F7F700F7F7F700A54A21000000000000000000000000004A9C
      D6004AB5F7004AB5EF0042A5EF00399CE7004A9CD600189CC600ADEFFF0021D6
      FF0031ADF70021299C0010087300000000000000000000000000000000004A9C
      D6004AB5F7004AB5EF0042A5EF00399CE7004A9CD60000000000000000000000
      000000000000000000000000000000000000CE732900FFFFFF00FFFFFF00FFFF
      FF0094A5B50052B5CE0073BDD6007BA5C6007BADD600FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00F7F7F700A54A21000000000000000000CE732900FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00F7F7F700A54A210000000000000000004294CE0052BD
      F70052BDF7004AB5F70042ADEF0039A5E7002994DE00107BB500189CC6004A9C
      EF000018C600425AC60021299C001008730000000000000000004294CE0052BD
      F70052BDF7004AB5F70042ADEF0039A5E7002994DE00107BB500000000000000
      000000000000000000000000000000000000CE732900FFFFFF00FFFFFF00DEDE
      DE0073BDD60084C6DE00C6D6E700D6E7F700DEEFF700FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00A54A21000000000000000000CE732900FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00A54A210000000000000000001873AD0052BD
      F70052BDFF0052B5F70042ADEF0042A5E7003194D600397BA500000000000018
      C6008C9CE7008C94DE000018C6000000000000000000000000001873AD0052BD
      F70052BDFF0052B5F70042ADEF0042A5E7003194D600397BA500845218008452
      180084521800845218008452180000000000CE732900FFFFFF00BDBDDE006B73
      AD008CADBD00DEE7EF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00A54A21000000000000000000CE732900FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00A54A2100000000000000000031739C00398C
      C6004AA5D600429CD6003994CE00318CC600298CCE0039738C00000000000000
      00000018C6000018C6000000000000000000000000000000000031739C00398C
      C6004AA5D600429CD6003994CE00318CC600298CCE0039738C0084521800FFFF
      FF0021A5210021A521008452180000000000CE732900FFFFFF00948CAD00636B
      B500C6BDCE00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00A54A21000000000000000000CE732900FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00A54A210000000000000000004284A5004284
      A5004284A500397B9C00296B940018638C0039738C0000000000000000000000
      00000000000000000000000000000000000000000000000000004284A5004284
      A5004284A500397B9C00296B940018638C0039738C00000000008452180021A5
      210021B5210021B521008452180000000000CE732900D66B0000D66B0000D66B
      0000D66B0000D66B0000D66B0000D66B0000D66B0000D66B0000D66B0000D66B
      0000D66B0000D66B0000A54A21000000000000000000CE732900D66B0000D66B
      0000D66B0000D66B0000D66B0000D66B0000D66B0000D66B0000D66B0000D66B
      0000D66B0000D66B0000D66B0000A54A2100000000000000000000000000397B
      A5004A8CAD00397BA5002973940021638C00397BA50000000000000000000000
      000000000000000000000000000000000000000000000000000000000000397B
      A5004A8CAD00397BA5002973940021638C00397BA500000000008452180021B5
      2100FFFFFF0021B5210021A5210000000000CE630000EF943100EF943100EF94
      3100EF943100EF943100EF943100EF943100F7CE9C00EF943100F7CE9C00EF94
      3100316BFF007B738C00CE6300000000000000000000CE630000EF943100EF94
      3100EF943100EF943100EF943100EF943100EF943100F7CE9C00EF943100F7CE
      9C00EF943100316BFF007B738C00CE6300000000000000000000000000000000
      0000397BA500397BA50029739400397BA5000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000397BA500397BA50029739400397BA5000000000000000000845218008452
      1800845218008452180021B5210021A5210000000000DE7B0800DE7B0800DE7B
      0800DE7B0800DE7B0800DE7B0800DE7B0800DE7B0800DE7B0800DE7B0800DE7B
      0800DE7B0800DE7B080000000000000000000000000000000000DE7B0800DE7B
      0800DE7B0800DE7B0800DE7B0800DE7B0800DE7B0800DE7B0800DE7B0800DE7B
      0800DE7B0800DE7B0800DE7B0800000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000021B521000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000086BB500086BB50008639C0000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000001084C6001094E70000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000086BB500086BB500107BBD00107BBD0008639C0000000000000000000000
      000000000000000000000000000000000000398C310029942900398C3100398C
      3100398C3100398C31001084C60063D6FF0031ADF7001094E700398C3100398C
      310000000000000000000000000000000000398C310029942900398C3100398C
      3100398C3100398C3100398C3100398C31001884180010841000398C3100398C
      310000000000000000000000000000000000398C310029942900398C3100398C
      3100398C3100398C3100398C3100398C31001884180010841000398C3100398C
      3100000000000000000000000000000000000000000000000000086BB500086B
      B5001084BD00107BBD00107BBD00107BBD0008639C00394A6B00394A6B00394A
      6B00394A6B00394A6B00394A6B0000000000398C310031B5310039B5390039B5
      39004ABD4A007BD67300086BAD0042B5E7005ACEF70042B5F7001094E7000884
      0800398C3100000000000000000000000000398C310031B5310039B5390039B5
      39004ABD4A007BD673004AA54A005AAD520073C66B0031B53100189418000884
      0800398C3100000000000000000000000000398C310031B5310039B5390039B5
      39004ABD4A007BD673004AA54A005AAD520073C66B0031B53100189418000884
      0800398C31000000000000000000000000000000000000000000086BB5001884
      C6001084C6001084BD00107BBD00107BBD0008639C00395A8400085A8C00085A
      8C00085A8C00085A8C00394A6B000000000000000000398C310039B5390052C6
      52006BCE6B0084CE7300D6F7CE00086BAD0052C6EF005ACEF70031ADF7001094
      E7001884BD001073B5001094E7000000000000000000398C310039B5390052C6
      52006BCE6B0084CE7300D6F7CE0052A54A009CDE8C0052C6520031AD3100188C
      1800299C290000000000000000000000000000000000398C310039B5390052C6
      52006BCE6B0084CE7300D6F7CE0052A54A009CDE8C0052C6520031AD3100188C
      1800299C29000000000000000000000000000000000000000000086BB500188C
      C6001884C6001084C6001084BD00107BBD0008639C00084A3100084231000842
      31000842310010423100394A6B000000000000000000299C290039B5390063CE
      63007BCE730052A54A00FFFFFF0052A54A00086BAD0042B5E70052CEF70042BD
      F70052D6FF0052D6FF0042BDF7001094E70000000000299C290039B5390063CE
      63007BCE730052A54A00FFFFFF0052A54A009CDE8C0063CE630039AD3900299C
      29000000000000000000000000000000000000000000299C290039B5390063CE
      63007BCE730052A54A00FFFFFF0052A54A009CDE8C0063CE630039AD3900299C
      2900000000000000000000000000000000000000000000000000086BB500188C
      CE00188CC6001884C6001084C6001084C60008639C00104A3900104A3100104A
      31001042310010423100394A6B00000000000000000000000000299C2900398C
      31004A8C4200D6F7CE00FFF7EF00ADBD9C004A8C4200086BAD005ADEF7007BFF
      FF0084FFFF0084FFFF007BF7FF001094E7000000000000000000299C2900398C
      31004A8C4200D6F7CE00FFF7EF00ADBD9C004A8C4200398C3100299C29000000
      0000000000000000000000000000000000000000000000000000299C2900398C
      31004A8C4200D6F7CE00FFF7EF00ADBD9C004A8C4200398C3100299C29000000
      0000000000000000000000000000000000000000000000000000086BB5001894
      CE00188CCE00188CC6001884C6001084C60008639C00187B5A00187B5A00187B
      6300187B5A0018735200394A6B00000000000000000000000000000000000000
      0000298CA500318CCE00298CCE003184A50000000000086BAD007BFFFF008CFF
      FF0094FFFF007BE7FF009CFFFF001094E7000000000000000000000000000000
      0000298CA500318CCE00298CCE003184A5000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000298CA500318CCE00298CCE003184A5000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000086BB5001894
      CE001894CE0021A5E70021A5DE00188CC60008639C0018846300187B5A00186B
      4A0018634200215A4200394A6B00000000000000000000000000000000004A9C
      D60042ADEF0042A5EF0039A5E7002994D6002984AD00086BAD007BFFFF0094FF
      FF0073E7F70039ADF700A5E7F7001094E7000000000000000000000000004A9C
      D60042ADEF0042A5EF0039A5E7002994D6002984AD0000000000000000000000
      0000000000000000000000000000000000000000000000000000000000004A9C
      D60042ADEF0042A5EF0039A5E7002994D6002984AD0000000000000000000000
      0000000000000000000000000000000000000000000000000000086BB5001894
      D6001894CE0021A5E700FFFFFF00188CCE0008639C005A7363007B8473009494
      8400AD9C8C00BD9C8400394A6B00000000000000000000000000000000004A9C
      D6004AB5F7004AB5EF0042A5EF00399CE7004A9CD6001084CE0063DEEF0094FF
      FF009CFFFF00A5E7F70094EFFF001094E7000000000000000000000000004A9C
      D6004AB5F7004AB5EF0042A5EF00399CE7004A9CD60000000000000000000000
      0000000000000000000000000000000000000000000000000000000000004A9C
      D6004AB5F7004AB5EF0042A5EF00399CE7004A9CD60000000000000000000000
      0000000000000000000000000000000000000000000000000000086BB500189C
      D6001894D6001894CE001894CE00188CCE0008639C00F7BDA500F7B59400F7BD
      AD00F7BDAD00F7BDAD00394A6B000000000000000000000000004294CE0052BD
      F70052BDF7004AB5F70042ADEF0039A5E7002994DE00107BB5001084CE001094
      E7001094E7001094E7001094E7000000000000000000000000004294CE0052BD
      F70052BDF7004AB5F70042ADEF0039A5E7002994DE00107BB500000000000873
      18000873180008731800000000000000000000000000000000004294CE0052BD
      F70052BDF7004AB5F70042ADEF0039A5E7002994DE00107BB500000000000000
      0000000000000000000000000000000000000000000000000000086BB500189C
      DE00189CD6001894D6001894D6001894CE0008639C00F7B59C00F7BDAD00F7E7
      D600F7C6AD00F7A58400394A6B000000000000000000000000001873AD0052BD
      F70052BDFF0052B5F70042ADEF0042A5E7003194D600397BA500000000000000
      00000000000000000000000000000000000000000000000000001873AD0052BD
      F70052BDFF0052B5F70042ADEF0042A5E7003194D600397BA500000000000873
      180010A5290008731800000000000000000000000000000000001873AD0052BD
      F70052BDFF0052B5F70042ADEF0042A5E7003194D600397BA500000000000000
      0000000000000000000000000000000000000000000000000000086BB50021A5
      DE00189CDE00189CD600189CD6001894D60008639C00EF7B4200F7A57B00F7AD
      8400EF7B4200F78C5200394A6B0000000000000000000000000031739C00398C
      C6004AA5D600429CD6003994CE00318CC600298CCE0039738C00000000000000
      000000000000000000000000000000000000000000000000000031739C00398C
      C6004AA5D600429CD6003994CE00318CC600298CCE0008731800087318000873
      180018AD4200087318000873180008731800000000000000000031739C00398C
      C6004AA5D600429CD6003994CE00318CC6000829A5000829A5000829A5000829
      A5000829A5000829A5000829A5000829A5000000000000000000086BB50021A5
      E70021A5DE00189CDE00189CDE00189CD60008639C00EF733900EF6B3100EF6B
      3100EF6B3100EF845200394A6B000000000000000000000000004284A5004284
      A5004284A500397B9C00296B940018638C0039738C0000000000000000000000
      00000000000000000000000000000000000000000000000000004284A5004284
      A5004284A500397B9C00296B940018638C0039738C000873180029C6630010A5
      290010A5290018AD420018AD42000873180000000000000000004284A5004284
      A5004284A500397B9C00296B940018638C000829A500637BE7000839EF000029
      C6000029C6000029C6000029C6000829A5000000000000000000086BB500086B
      B50021A5E70021A5DE0021A5DE00189CDE0008639C00EF6B3900E75A2100E763
      3100EF9C7B00EF946B00394A6B0000000000000000000000000000000000397B
      A5004A8CAD00397BA5002973940021638C00397BA50000000000000000000000
      000000000000000000000000000000000000000000000000000000000000397B
      A5004A8CAD00397BA5002973940021638C00397BA50008731800087318000873
      180010A52900087318000873180008731800000000000000000000000000397B
      A5004A8CAD00397BA5002973940021638C000829A5000829A5000829A5000829
      A5000829A5000829A5000829A5000829A5000000000000000000000000000000
      0000086BB500086BB50021A5E70021A5DE0008639C00394A6B00394A6B00394A
      6B00394A6B00394A6B00394A6B00000000000000000000000000000000000000
      0000397BA500397BA50029739400397BA5000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000397BA500397BA50029739400397BA5000000000000000000000000000873
      180010A529000873180000000000000000000000000000000000000000000000
      0000397BA500397BA50029739400397BA5000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000086BB500086BB50008639C0000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000873
      1800087318000873180000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000424D3E000000000000003E000000
      2800000040000000B00000000100010000000000800500000000000000000000
      000000000000000000000000FFFFFF00FFFFFFFF00000000F3FFFC0000000000
      ED9F800000000000ED6F000000000000ED6F000000000000F16F000000000000
      FD1F000100000000FC7F000300000000FEFF000300000000FC7F000300000000
      FD7F000300000000F93F000300000000FBBF000300000000FBBF800700000000
      FBBFF87F00000000FFFFFFFF00000000FFFFFFFFFFFFFFFFFC01FFF9FE01FFFF
      FC01FFF1E001FC01FC01FFE1EE01FC01FC01F803EFFFFC01FEFFE003EE010001
      047FC003E001000106FF8001EE01000100FF0000EFFF000107FF0000EE010003
      FFFF0000E0010007DFFB0001EE01000F8FF18003EFFF00FF0000C007807F01FF
      0000F01F807F03FFFFFFFFFF807FFFFF9FFFFFFFFFFFF81F0FFF800F9EFDE007
      07FF00078F7BC00383FF000787338001C1FF0007C0078001E1070007C0070000
      F0030007C0030000FC01000780010000F801000700000000F800000700000000
      F800000700000000F800000380008001F8010001C0018001FC010000E003C003
      FE030001F80FE007FF0F8003FFFFF81FC0019FFFFFFFFFFFC0010FFFF11F0001
      800107FFFB6F8003800183FFFB6FC007C001C1FFFB6FE00FC001E107F11FF01F
      C001F003FFFFF83FC001FC01FEFFFC7FC001F801FC7FFEFFC001F800F83FFFFF
      C001F800F01FF11FC001F800E00FFB6FC001F801C007FB6FC003FC018003FB6F
      C007FE030001F11FC00FFF0FFFFFFFFFFFFDF00FF00FC00107C0F00FF00FC001
      07C0E007E007C00107C1C003C003C001060180018001C001040180018001C001
      D80780018001C001C00780018001C001F80780018001C001F80780018001C001
      FC0F80018001C001F81FE007E001C001F01FE007E001C001F83FF00FF001C001
      FC7FF00FF000C001FEFFF00FF00EC0019FFFF801F801FFFF0FFF8001F801F9CF
      07FF8001F801F08783FF8001F801F6B7C1FF80018001F2A7E10780018001F007
      F00380018001F80FFC0180018001FE3FF80180018001FC1FF80080018001FC1F
      F80080038003F88FF80080078007F9CFF8018007801FF1C7FC018007801FF3E7
      FE03C00F803FF7F7FF0FF87F807FFFFFB6DBFFFFFFFF9FFFAAABC003FFFF0FFF
      B6CB8001FFFF07FF80078001F83F83FF80038001F01FC1FF80018001E00FE107
      800F8001E00FF003800F8001E00FFC01800F8001E00FF801801F8001E00FF800
      801F8001F01FF800801F8001F80FF800801F8001FF9FF801803F8001FFFFFC01
      807FC003FFFFFE03FFFFFFFFFFFFFF0FF81FF81FF81FF81FE007E007E007E007
      C003C003C003C003800180018001800180018001800180010000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000080018001800180018001800180018001C003C003C003C003
      E007E007E007E007F81FF81FF81FF81FFFFFFFFFFFFFFFFF8001000100010001
      8001000100010001800100010001000180010001000100018001000100010001
      8001000100010001800100010001000180010001000100018001000100010001
      8001000100010001800100000000000180010000000000008001000000000001
      C003800380038003FFFFFFE3FFFFFFFFF3FFFFFFFFFFFFFF000F000F00018000
      00070007000180008007800700018000800F800F00018000C00FC01F00018000
      F007F0FF00018000E003E07F00018000E001E07F00018000C000C03F00018000
      C021C00100018000C033C00100018000C07FC04100018000E07FE04100018000
      F0FFF0C08003C001FFFFFFFEFFFFFFFFFC7FFE7FFFFFFFFFF07F000F000F000F
      C001000700070007C001800180078007C0018000800F800FC001C000C01FC01F
      C001F080F0FFF0FFC001E000E07FE07FC001E000E07FE07FC001C001C023C03F
      C001C03FC023C03FC001C03FC000C000C001C07FC000C000C001E07FE000E000
      F001F0FFF0E3F0FFFC7FFFFFFFE3FFFF00000000000000000000000000000000
      000000000000}
  end
  object imglGutterGlyphs: TImageList
    Height = 14
    Width = 11
    Left = 1416
    Top = 152
    Bitmap = {
      494C01010600090004000B000E00FFFFFFFFFF10FFFFFFFFFFFFFFFF424D3600
      00000000000036000000280000002C0000001C00000001002000000000004013
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000FF000000FF000000FF000000FF000000
      FF0000000000000000000000000000000000000000000000000084848400C6C6
      C60084848400C6C6C60084848400000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000000000000000FF0000FF
      FF000000FF000000FF000000FF0000FFFF000000FF0000000000000000000000
      00000000000084848400C6C6C60084848400C6C6C60084848400C6C6C6008484
      8400000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000FF0000FFFF0000FFFF000000FF0000FFFF0000FF
      FF000000FF0000000000000000000000000000000000C6C6C60084848400C6C6
      C60084848400C6C6C60084848400C6C6C6000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000000000000000FF000000
      FF0000FFFF0000FFFF0000FFFF000000FF000000FF0000000000000000000000
      00000000000084848400C6C6C60084848400C6C6C60084848400C6C6C6008484
      8400000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000FF0000FFFF0000FFFF000000FF0000FFFF0000FF
      FF000000FF0000000000000000000000000000000000C6C6C60084848400C6C6
      C60084848400C6C6C60084848400C6C6C6000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000000000000000FF0000FF
      FF000000FF000000FF000000FF0000FFFF000000FF0000000000000000000000
      00000000000084848400C6C6C60084848400C6C6C60084848400C6C6C6008484
      8400000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000FF000000FF000000FF000000FF000000
      FF0000000000000000000000000000000000000000000000000084848400C6C6
      C60084848400C6C6C60084848400000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000008400
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000084000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000840000008400000000000000000000000000
      0000000000000000000000000000000000000000000084848400840000008400
      0000848484008484840000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000008400
      0000FF0000008400000000000000000000000000000000000000000000000000
      0000848484000000FF0084000000FF000000840000000000FF00848484000000
      0000000000000000000000000000000000000000FF0000FF00000000FF000000
      FF000000FF000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000084000000840000008400000084000000FF000000FF000000840000000000
      000000000000000000000000000084000000840000008400000084000000FF00
      0000FF000000840000000000FF00848484000000000000000000000000000000
      FF0000FF000000FF000000FF00000000FF000000FF000000FF00000000000000
      0000000000000000000000000000000000000000000084000000840000000000
      00000000000000000000000000000000000084000000FF000000FF000000FF00
      0000FF000000FF000000FF000000840000000000000000000000000000008400
      0000FF000000FF000000FF000000FF000000FF000000FF000000840000008484
      840000000000000000000000000000FF000000FF00000000FF0000FF00000000
      FF000000FF000000FF0000000000000000000000000000000000000000000000
      000084000000FF000000FF000000840000000000000000000000000000000000
      000084000000FF000000FF000000FF000000FF000000FF000000FF000000FF00
      000084000000000000000000000084000000FF000000FF000000FF000000FF00
      0000FF000000FF000000FF000000840000000000000000000000000000000000
      FF000000FF000000FF0000FF000000FF00000000FF000000FF00000000000000
      000000000000000000000000000000000000FFFF0000FF000000FF0000008400
      0000000000000000000000000000000000008400000084840000FFFF00008484
      0000FFFF0000FF000000FF000000840000000000000000000000000000008400
      000084840000FFFF000084840000FFFF0000FF000000FF000000840000008484
      84000000000000000000000000000000FF000000FF000000FF000000FF0000FF
      00000000FF000000FF0000000000000000000000000000000000000000000000
      000000000000FFFF000084000000000000000000000000000000000000000000
      00008400000084000000840000008400000084840000FFFF0000840000000000
      0000000000000000000000000000840000008400000084000000840000008484
      0000FFFF0000840000000000FF00848484000000000000000000000000000000
      FF000000FF000000FF000000FF0000FF000000FF00000000FF00000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000008400
      0000FFFF00008400000000000000000000000000000000000000000000000000
      0000848484000000FF0084000000FFFF0000840000000000FF00848484000000
      0000000000000000000000000000000000000000FF000000FF000000FF000000
      FF0000FF00000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000840000008400000000000000000000000000
      0000000000000000000000000000000000000000000084848400840000008400
      0000848484008484840000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000FF000000FF0000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000008400
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000084000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000424D3E000000000000003E000000
      280000002C0000001C0000000100010000000000E00000000000000000000000
      000000000000000000000000FFFFFF00FFFFFC0000000000FFFFFC0000000000
      E0FC1C0000000000C0780C000000000080300400000000008030040000000000
      803004000000000080300400000000008030040000000000C0780C0000000000
      E0FC1C0000000000FFFFFC0000000000FFFFFC0000000000FFFFFC0000000000
      FFFFFFFFFFF00000FFFEFFDFFFF00000FFFE7F83F0700000FFFE3F01E0300000
      FFF01E00C0100000F9F00E00C0100000F0F00600C0100000F0F00E00C0100000
      F9F01E00C0100000FFFE3F01E0300000FFFE7F83F0100000FFFEFFDFFF300000
      FFFFFFFFFFF00000FFFFFFFFFFF0000000000000000000000000000000000000
      000000000000}
  end
  object ActionList1: TActionList
    Images = ImageList1
    Left = 1284
    Top = 360
    object actTestScript: TAction
      Category = 'Compiler'
      Caption = 'Run Script'
      Hint = 'Run Script'
      ImageIndex = 13
      ShortCut = 120
      OnExecute = actExecute
    end
    object actFormat: TAction
      Category = 'Compiler'
      Caption = 'Format'
      Hint = 'Format'
      ShortCut = 16452
      OnExecute = actExecute
    end
    object actStepScript: TAction
      Category = 'Compiler'
      Caption = 'Step Script'
      Hint = 'Step Script'
      ImageIndex = 12
      ShortCut = 119
      OnExecute = actExecute
    end
    object actStopScript: TAction
      Category = 'Compiler'
      Caption = 'Stop Script'
      Hint = 'Stop Script'
      ImageIndex = 14
      ShortCut = 16497
      OnExecute = actExecute
    end
    object actEvalScript: TAction
      Category = 'Compiler'
      Caption = 'Evaluate Script'
      Hint = 'Evaluate Script'
      ImageIndex = 15
      ShortCut = 16502
      OnExecute = actExecute
    end
    object actCompile: TAction
      Category = 'Compiler'
      Caption = 'Compile'
      Hint = 'Compile'
      ImageIndex = 24
      ShortCut = 16504
      OnExecute = actExecute
    end
    object actToggleBreak: TAction
      Category = 'Compiler'
      Caption = 'Toggle Breakpoint'
      Hint = 'Toggle Breakpoint'
      ImageIndex = 18
      ShortCut = 116
      OnExecute = actExecute
    end
    object actReplace: TAction
      Category = 'Edit'
      Caption = 'Replace'
      Hint = 'Replace Text'
      ImageIndex = 19
      ShortCut = 16466
      OnExecute = actExecute
    end
    object actFind: TAction
      Category = 'Edit'
      Caption = '&Find'
      Hint = 'Find Text'
      ImageIndex = 20
      ShortCut = 16454
      OnExecute = actExecute
    end
    object ecPrintAction1: TecPrintAction
      Category = 'File'
      Caption = '&Print'
      Hint = 'Print|Print document'
      ImageIndex = 25
      ShortCut = 16464
      Command = 630
      SyntPrinter = ecSyntPrinter1
      PrintDialog = PrintDialog1
    end
    object ecPreviewAction1: TecPreviewAction
      Category = 'File'
      Caption = 'Preview...'
      Hint = 'Preview...'
      ImageIndex = 28
      Command = 632
      SyntPrinter = ecSyntPrinter1
    end
    object ecPageSetupAction1: TecPageSetupAction
      Category = 'File'
      Caption = 'Print preview'
      Hint = 'Print preview|Print preview'
      ImageIndex = 27
      Command = 632
      SyntPrinter = ecSyntPrinter1
    end
    object actPrintSetup: TAction
      Category = 'File'
      Caption = 'Printer Setup'
      ImageIndex = 26
      OnExecute = actExecute
    end
    object ecIncrementalSearch1: TecIncrementalSearch
      Category = 'Edit'
      Caption = 'Incremental Search'
      Hint = 'Incremental Search|Incremental Search'
      ImageIndex = 29
      ShortCut = 16453
    end
    object ecSearchAgain1: TecSearchAgain
      Category = 'Edit'
      Caption = 'Search Again'
      Hint = 'Search Again|Repeats the last find'
      ImageIndex = 32
      ShortCut = 114
      Dialog = SyntFindDialog1
    end
    object actViewOutput: TAction
      Category = 'View'
      Caption = 'Script Output'
      Hint = 'View Output Script'
      OnExecute = actExecute
    end
    object actViewProduction: TAction
      Category = 'View'
      Caption = 'Production Script'
      Hint = 'View Production Script'
      OnExecute = actExecute
    end
    object actViewTest: TAction
      Category = 'View'
      Caption = 'Test Script'
      Hint = 'View Test Script'
      OnExecute = actExecute
    end
    object actComment: TAction
      Category = 'Edit'
      Caption = 'Comment Text'
      Hint = 'Comment Text'
      ImageIndex = 37
      ShortCut = 49342
      OnExecute = actExecute
    end
    object actUnComment: TAction
      Category = 'Edit'
      Caption = 'Uncomment Text'
      Hint = 'Uncomment Text'
      ImageIndex = 34
      ShortCut = 49340
      OnExecute = actExecute
    end
    object actFunction: TAction
      Category = 'Compiler'
      Caption = 'View Functions'
      HelpKeyword = 'View Full Function List'
      ImageIndex = 38
      ShortCut = 16457
      OnExecute = actExecute
    end
    object actClose: TAction
      Category = 'File'
      Caption = 'Save and Close'
      ImageIndex = 17
      ShortCut = 16467
      OnExecute = actExecute
    end
    object actMatchDelim: TecCommandAction
      Category = 'EC Editor'
      Caption = 'Jump to matching bracket'
      Hint = 
        'Jump to matching bracket|Jump to matching bracket (change range ' +
        'side)'
      ImageIndex = 36
      ShortCut = 16603
      Command = 433
    end
    object ecCopy1: TecCopy
      Category = 'EC Editor'
      Caption = '&Copy'
      Hint = 'Copy|Copy selection to clipboard'
      ImageIndex = 22
      ShortCut = 16451
    end
    object ecCut1: TecCut
      Category = 'EC Editor'
      Caption = 'Cu&t'
      Hint = 'Cut|Cut selection to clipboard'
      ImageIndex = 23
      ShortCut = 16472
    end
    object ecPaste1: TecPaste
      Category = 'EC Editor'
      Caption = '&Paste'
      Hint = 'Paste|Paste clipboard to current position'
      ImageIndex = 21
      ShortCut = 16470
    end
    object actProcList: TAction
      Category = 'Compiler'
      Caption = 'Procedure List'
      ImageIndex = 31
      ShortCut = 16455
      OnExecute = actExecute
    end
    object actTemplatePopup: TAction
      Caption = 'Template Popup'
      Hint = 'Template Popup'
      ShortCut = 16458
      OnExecute = actExecute
    end
    object actAddWatch: TAction
      Category = 'Watch'
      Caption = 'Add Watch'
      ImageIndex = 9
      OnExecute = actExecute
    end
    object actDelWatch: TAction
      Category = 'Watch'
      Caption = 'Del Watch'
      ImageIndex = 10
      OnExecute = actExecute
    end
    object actFontDown: TAction
      Category = 'View'
      Caption = 'DecreaseFont'
      ShortCut = 16573
      OnExecute = actExecute
    end
    object actFontUp: TAction
      Category = 'View'
      Caption = 'Increase Font'
      ShortCut = 16571
      OnExecute = actExecute
    end
    object ecCustomizeEditorOptionsAction1: TecCustomizeEditorOptionsAction
      Category = 'EC Configuration'
      Caption = '&Editor Options'
      Hint = 'Customize Editor Options'
      OnExecuteOK = ecCustomizeEditorOptionsAction1ExecuteOK
    end
    object actResetSizes: TAction
      Category = 'Edit'
      Caption = 'Reset Sizes'
      OnExecute = actExecute
    end
  end
  object dxBarManager1: TdxBarManager
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -24
    Font.Name = 'Segoe UI'
    Font.Style = []
    Categories.Strings = (
      'Default'
      'File'
      'Edit'
      'Run'
      'View')
    Categories.ItemsVisibles = (
      2
      2
      2
      2
      2)
    Categories.Visibles = (
      True
      True
      True
      True
      True)
    ImageOptions.Images = ImageList1
    PopupMenuLinks = <>
    UseSystemFont = True
    Left = 2880
    Top = 360
    PixelsPerInch = 192
    DockControlHeights = (
      0
      0
      48
      0)
    object dxBarManager1Bar1: TdxBar
      Caption = 'Menu'
      CaptionButtons = <>
      DockedDockingStyle = dsTop
      DockedLeft = 0
      DockedTop = 0
      DockingStyle = dsTop
      FloatLeft = 276
      FloatTop = 213
      FloatClientWidth = 23
      FloatClientHeight = 22
      IsMainMenu = True
      ItemLinks = <
        item
          Visible = True
          ItemName = 'dxFile'
        end
        item
          Visible = True
          ItemName = 'dxEdit'
        end
        item
          Visible = True
          ItemName = 'dxView'
        end
        item
          Visible = True
          ItemName = 'dxRun'
        end>
      MultiLine = True
      OldName = 'Menu'
      OneOnRow = False
      Row = 0
      UseOwnFont = False
      Visible = True
      WholeRow = False
    end
    object dxBarManager1Bar2: TdxBar
      Caption = 'Toolbar'
      CaptionButtons = <>
      DockedDockingStyle = dsTop
      DockedLeft = 324
      DockedTop = 0
      DockingStyle = dsTop
      FloatLeft = 276
      FloatTop = 213
      FloatClientWidth = 23
      FloatClientHeight = 22
      ItemLinks = <
        item
          Visible = True
          ItemName = 'dxExit'
        end
        item
          BeginGroup = True
          Visible = True
          ItemName = 'dxPrintPreview'
        end
        item
          Visible = True
          ItemName = 'dxPrint'
        end
        item
          BeginGroup = True
          Visible = True
          ItemName = 'dxCut'
        end
        item
          Visible = True
          ItemName = 'dxCopy'
        end
        item
          Visible = True
          ItemName = 'dxPaste'
        end
        item
          BeginGroup = True
          Visible = True
          ItemName = 'dxFind'
        end
        item
          Visible = True
          ItemName = 'dxReplace'
        end
        item
          BeginGroup = True
          Visible = True
          ItemName = 'dxCompile'
        end
        item
          Visible = True
          ItemName = 'dxToggleBreakpoint'
        end
        item
          BeginGroup = True
          Visible = True
          ItemName = 'dxRunScript'
        end
        item
          Visible = True
          ItemName = 'dxStepScript'
        end
        item
          Visible = True
          ItemName = 'dxStopScript'
        end
        item
          BeginGroup = True
          Visible = True
          ItemName = 'dxEvaluateScript'
        end>
      OldName = 'Toolbar'
      OneOnRow = False
      Row = 0
      UseOwnFont = False
      Visible = True
      WholeRow = False
    end
    object dxFile: TdxBarSubItem
      Caption = '&File'
      Category = 0
      Visible = ivAlways
      ItemLinks = <
        item
          Visible = True
          ItemName = 'dxPageSetup'
        end
        item
          Visible = True
          ItemName = 'dxPrintPreview'
        end
        item
          Visible = True
          ItemName = 'dxPrinterSetup'
        end
        item
          Visible = True
          ItemName = 'dxPrint'
        end
        item
          BeginGroup = True
          Visible = True
          ItemName = 'dxExit'
        end>
    end
    object dxEdit: TdxBarSubItem
      Caption = '&Edit'
      Category = 0
      Visible = ivAlways
      ItemLinks = <
        item
          Visible = True
          ItemName = 'dxCut'
        end
        item
          Visible = True
          ItemName = 'dxCopy'
        end
        item
          Visible = True
          ItemName = 'dxPaste'
        end
        item
          BeginGroup = True
          Visible = True
          ItemName = 'dxFind'
        end
        item
          Visible = True
          ItemName = 'dxReplace'
        end
        item
          Visible = True
          ItemName = 'dxSearchAgain'
        end
        item
          Visible = True
          ItemName = 'dxIncrementalSearch'
        end
        item
          BeginGroup = True
          Visible = True
          ItemName = 'dxComment'
        end
        item
          Visible = True
          ItemName = 'dxUncomment'
        end
        item
          Visible = True
          ItemName = 'dxMatchDelimiter'
        end
        item
          BeginGroup = True
          Visible = True
          ItemName = 'dxBarLargeButton3'
        end
        item
          Visible = True
          ItemName = 'dxBarLargeButton4'
        end>
    end
    object dxRun: TdxBarSubItem
      Caption = 'Run'
      Category = 0
      Visible = ivAlways
      ItemLinks = <
        item
          Visible = True
          ItemName = 'dxCompile'
        end
        item
          BeginGroup = True
          Visible = True
          ItemName = 'dxToggleBreakpoint'
        end
        item
          BeginGroup = True
          Visible = True
          ItemName = 'dxRunScript'
        end
        item
          Visible = True
          ItemName = 'dxStepScript'
        end
        item
          Visible = True
          ItemName = 'dxStopScript'
        end
        item
          BeginGroup = True
          Visible = True
          ItemName = 'dxEvaluateScript'
        end
        item
          BeginGroup = True
          Visible = True
          ItemName = 'dxFunctions'
        end
        item
          Visible = True
          ItemName = 'dxBarButton1'
        end>
    end
    object dxView: TdxBarSubItem
      Caption = '&View'
      Category = 0
      Visible = ivAlways
      ItemLinks = <
        item
          Visible = True
          ItemName = 'dxViewProduction'
        end
        item
          Visible = True
          ItemName = 'dxViewOutput'
        end
        item
          Visible = True
          ItemName = 'dxBarLargeButton1'
        end
        item
          Visible = True
          ItemName = 'dxBarLargeButton2'
        end>
    end
    object dxEditTables: TdxBarSubItem
      Caption = '&Edit Tables'
      Category = 0
      Visible = ivAlways
      ItemLinks = <>
    end
    object dxImport: TdxBarSubItem
      Caption = 'Import'
      Category = 0
      Visible = ivAlways
      ItemLinks = <>
    end
    object dxBarLargeButton1: TdxBarLargeButton
      Action = actFontDown
      Category = 0
    end
    object dxBarLargeButton2: TdxBarLargeButton
      Action = actFontUp
      Category = 0
    end
    object dxBarSeparator1: TdxBarSeparator
      Category = 0
      Visible = ivAlways
    end
    object dxBarLargeButton3: TdxBarLargeButton
      Action = ecCustomizeEditorOptionsAction1
      Category = 0
    end
    object dxBarLargeButton4: TdxBarLargeButton
      Action = actResetSizes
      Category = 0
    end
    object dxSave: TdxBarButton
      Caption = 'Save'
      Category = 1
      Hint = 'Save'
      Visible = ivAlways
      ImageIndex = 17
      ShortCut = 16467
      OnClick = actExecute
    end
    object dxPageSetup: TdxBarButton
      Action = ecPageSetupAction1
      Category = 1
    end
    object dxPrintPreview: TdxBarButton
      Action = ecPreviewAction1
      Category = 1
    end
    object dxPrinterSetup: TdxBarButton
      Action = actPrintSetup
      Category = 1
    end
    object dxPrint: TdxBarButton
      Action = ecPrintAction1
      Category = 1
    end
    object dxExit: TdxBarButton
      Action = actClose
      Category = 1
      PaintStyle = psCaptionGlyph
    end
    object dxCut: TdxBarButton
      Action = ecCut1
      Category = 2
    end
    object dxCopy: TdxBarButton
      Action = ecCopy1
      Category = 2
    end
    object dxPaste: TdxBarButton
      Action = ecPaste1
      Category = 2
    end
    object dxFind: TdxBarButton
      Action = actFind
      Category = 2
    end
    object dxReplace: TdxBarButton
      Action = actReplace
      Category = 2
    end
    object dxSearchAgain: TdxBarButton
      Action = ecSearchAgain1
      Category = 2
    end
    object dxIncrementalSearch: TdxBarButton
      Action = ecIncrementalSearch1
      Category = 2
    end
    object dxFontName: TdxBarFontNameCombo
      Caption = 'Font Name'
      Category = 2
      Hint = 'Font Name'
      Visible = ivAlways
      Glyph.SourceDPI = 96
      Glyph.Data = {
        424D360400000000000036000000280000001000000010000000010020000000
        000000000000871D0000871D00000000000000000000C0C0C0FFC0C0C0FFC0C0
        C0FFC0C0C0FFC0C0C0FFC0C0C0FFC0C0C0FFC0C0C0FFC0C0C0FFC0C0C0FFC0C0
        C0FFC0C0C0FFC0C0C0FFC0C0C0FFC0C0C0FFC0C0C0FFC0C0C0FFC0C0C0FFC0C0
        C0FFC0C0C0FFC0C0C0FFC0C0C0FFC0C0C0FFC0C0C0FFC0C0C0FFC0C0C0FFC0C0
        C0FFC0C0C0FFC0C0C0FFC0C0C0FFC0C0C0FFC0C0C0FFC0C0C0FFC0C0C0FFC0C0
        C0FFC0C0C0FFC0C0C0FFC0C0C0FFC0C0C0FFC0C0C0FFC0C0C0FFC0C0C0FFC0C0
        C0FFC0C0C0FFC0C0C0FFC0C0C0FFC0C0C0FFC0C0C0FFC0C0C0FF800000FF8000
        00FF800000FF800000FFC0C0C0FFC0C0C0FFC0C0C0FF800000FF800000FF8000
        00FF800000FF800000FF800000FFC0C0C0FFC0C0C0FFC0C0C0FFC0C0C0FF8080
        80FF800000FFC0C0C0FFC0C0C0FFC0C0C0FFC0C0C0FFC0C0C0FF808080FF8000
        00FF800000FF808080FFC0C0C0FFC0C0C0FFC0C0C0FFC0C0C0FFC0C0C0FFC0C0
        C0FF800000FF800000FFC0C0C0FFC0C0C0FFC0C0C0FFC0C0C0FF808080FF8000
        00FF800000FFC0C0C0FFC0C0C0FFC0C0C0FFC0C0C0FFC0C0C0FFC0C0C0FFC0C0
        C0FF808080FF800000FFC0C0C0FFC0C0C0FFC0C0C0FFC0C0C0FF800000FF8000
        00FF808080FFC0C0C0FFC0C0C0FFC0C0C0FFC0C0C0FFC0C0C0FFC0C0C0FFC0C0
        C0FFC0C0C0FF800000FF800000FF800000FF800000FF800000FF800000FF8000
        00FFC0C0C0FFC0C0C0FFC0C0C0FFC0C0C0FFC0C0C0FFC0C0C0FFC0C0C0FFC0C0
        C0FFC0C0C0FF808080FF800000FFC0C0C0FFC0C0C0FF800000FF800000FF8080
        80FFC0C0C0FFC0C0C0FFC0C0C0FFC0C0C0FFC0C0C0FFC0C0C0FFC0C0C0FFC0C0
        C0FFC0C0C0FFC0C0C0FF800000FF800000FFC0C0C0FF800000FF800000FFC0C0
        C0FFC0C0C0FFC0C0C0FFC0C0C0FFC0C0C0FFC0C0C0FFC0C0C0FFC0C0C0FFC0C0
        C0FFC0C0C0FFC0C0C0FF808080FF800000FF800000FF800000FF808080FFC0C0
        C0FFC0C0C0FFC0C0C0FFC0C0C0FFC0C0C0FFC0C0C0FFC0C0C0FFC0C0C0FFC0C0
        C0FFC0C0C0FFC0C0C0FFC0C0C0FF800000FF800000FF800000FFC0C0C0FFC0C0
        C0FFC0C0C0FFC0C0C0FFC0C0C0FFC0C0C0FFC0C0C0FFC0C0C0FFC0C0C0FFC0C0
        C0FFC0C0C0FFC0C0C0FFC0C0C0FF808080FF800000FF808080FFC0C0C0FFC0C0
        C0FFC0C0C0FFC0C0C0FFC0C0C0FFC0C0C0FFC0C0C0FFC0C0C0FFC0C0C0FFC0C0
        C0FFC0C0C0FFC0C0C0FFC0C0C0FFC0C0C0FF800000FFC0C0C0FFC0C0C0FFC0C0
        C0FFC0C0C0FFC0C0C0FFC0C0C0FFC0C0C0FFC0C0C0FFC0C0C0FFC0C0C0FFC0C0
        C0FFC0C0C0FFC0C0C0FFC0C0C0FFC0C0C0FFC0C0C0FFC0C0C0FFC0C0C0FFC0C0
        C0FFC0C0C0FFC0C0C0FFC0C0C0FFC0C0C0FFC0C0C0FFC0C0C0FFC0C0C0FFC0C0
        C0FFC0C0C0FFC0C0C0FFC0C0C0FFC0C0C0FFC0C0C0FFC0C0C0FFC0C0C0FFC0C0
        C0FFC0C0C0FFC0C0C0FFC0C0C0FFC0C0C0FFC0C0C0FF}
      Width = 320
      DropDownCount = 12
    end
    object dxFontSize: TdxBarCombo
      Caption = 'Font Size'
      Category = 2
      Hint = 'Font Size'
      Visible = ivAlways
      Width = 200
      Items.Strings = (
        '8'
        '9'
        '10'
        '11'
        '12'
        '14'
        '16'
        '18'
        '20'
        '22'
        '24'
        '26'
        '28'
        '36'
        '48'
        '72')
      ItemIndex = -1
    end
    object dxComment: TdxBarButton
      Action = actComment
      Category = 2
    end
    object dxUncomment: TdxBarButton
      Action = actUnComment
      Category = 2
    end
    object dxMatchDelimiter: TdxBarButton
      Action = actMatchDelim
      Category = 2
    end
    object dxCompile: TdxBarButton
      Action = actCompile
      Category = 3
    end
    object dxToggleBreakpoint: TdxBarButton
      Action = actToggleBreak
      Category = 3
    end
    object dxStepScript: TdxBarButton
      Action = actStepScript
      Category = 3
    end
    object dxRunScript: TdxBarButton
      Action = actTestScript
      Category = 3
    end
    object dxStopScript: TdxBarButton
      Action = actStopScript
      Category = 3
    end
    object dxEvaluateScript: TdxBarButton
      Action = actEvalScript
      Category = 3
    end
    object dxFunctions: TdxBarButton
      Action = actFunction
      Category = 3
    end
    object dxBarButton1: TdxBarButton
      Action = actProcList
      Category = 3
    end
    object dxViewProduction: TdxBarButton
      Action = actViewProduction
      Category = 4
      AllowAllUp = True
      ButtonStyle = bsChecked
      UnclickAfterDoing = False
    end
    object dxViewOutput: TdxBarButton
      Action = actViewOutput
      Category = 4
      AllowAllUp = True
      ButtonStyle = bsChecked
      UnclickAfterDoing = False
    end
  end
  object JvAppRegistryStorage1: TJvAppRegistryStorage
    StorageOptions.BooleanStringTrueValues = 'TRUE, YES, Y'
    StorageOptions.BooleanStringFalseValues = 'FALSE, NO, N'
    Root = 'Software\Lambton\Process\Settings'
    SubStorages = <>
    Left = 1300
    Top = 806
  end
  object JvFormStorage1: TJvFormStorage
    AppStorage = JvAppRegistryStorage1
    AppStoragePath = 'formScrEdit\'
    StoredProps.Strings = (
      'cxGroupBox2.Height'
      'cxGroupBox3.Width'
      'cxGroupBox5.Width'
      'cxPageControl1.ActivePage'
      'cxPageControl2.ActivePage'
      'SyntFindDialog1.History'
      'SyntReplaceDialog1.History'
      'chkPreserveLog.Checked')
    StoredValues = <>
    Left = 1572
    Top = 852
  end
  object ParamCompletionFSScript: TParamCompletion
    Color = clInfoBk
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    OnGetParams = ParamCompletionFSScriptGetParams
    UpDownWidth = 17
    UpDownOrientation = udVertical
    FmtImages = cxImageList1
    ToolHint.Left = 0
    ToolHint.Top = 0
    ToolHint.Width = 0
    ToolHint.Height = 0
    ToolHint.Text = ''
    Controls = <>
    Left = 732
    Top = 72
  end
  object HyperlinkHighlighter1: THyperlinkHighlighter
    Rules = <
      item
        DisplayName = 'http & ftp'
        Expression = 
          '(http|ftp)://[\w\d\-]+(\.[\w\d\-]+)+(:\d\d?\d?\d?\d?)?(((/[%+\w\' +
          'd\-\\\.]*)+)*)(\?[^\s=&"]+=[^\s=&"]+(&[^\s=&"]+=[^\s=&"]+)*)?(\#' +
          '[\w\d\-%+]+)?'
        ShellCommand = '\0'
      end
      item
        DisplayName = 'http (www)'
        Expression = 
          'www(\.[\w\d\-]+)+(:\d\d?\d?\d?\d?)?(((/[%+\w\d\-\\\.]*)+)*)(\?[^' +
          '\s=&"]+=[^\s=&"]+(&[^\s=&"]+=[^\s=&"]+)*)?(\#[\w\d\-%+]+)?'
        ShellCommand = 'http://\0'
      end
      item
        DisplayName = 'e-mail (mailto)'
        Expression = 'mailto:\s*[_a-z\d\-\.]+@[_a-z\d\-]+(\.[_a-z\d\-]+)+'
        ShellCommand = '\0'
      end
      item
        DisplayName = 'e-mail'
        Expression = '[_a-z\d\-\.]+@[_a-z\d\-]+(\.[_a-z\d\-]+)+'
        ShellCommand = 'mailto:\0'
      end>
    Style.Font.Charset = DEFAULT_CHARSET
    Style.Font.Color = clBlue
    Style.Font.Height = -13
    Style.Font.Name = 'Courier New'
    Style.Font.Style = [fsUnderline]
    Left = 2896
    Top = 112
  end
  object cxStyleRepository1: TcxStyleRepository
    Left = 1760
    Top = 144
    PixelsPerInch = 192
    object cxStyle1: TcxStyle
    end
  end
  object cxImageList1: TcxImageList
    SourceDPI = 96
    FormatVersion = 1
    DesignInfo = 26740464
    ImageInfo = <
      item
        Image.Data = {
          36040000424D3604000000000000360000002800000010000000100000000100
          200000000000000400000000000000000000000000000000000000000000211F
          1C27B4A28FE0D0BEAAFDD0BDA8FED0BCA7FECFBBA6FECEBAA5FECDB9A3FECDB9
          A2FECCB8A1FECBB7A0FECBB69FFEB39F89E52D28233A00000000000000005A51
          4870F5ECE0FEF8EFE3FEF6EDE0FEF5EBDEFED8C7B3FED0BDA8FECFBBA6FECFBB
          A5FECEBAA3FECDB9A3FEE1D3BFFEE4D6C1FE594F45730000000000000000675C
          537FFCF6EEFEEFE4D7FEE2D3C3FEECE1D3FED7C9BCFEFDFDFDFEFDFDFDFEFDFD
          FDFEFDFDFDFEFDFDFDFECFBCA6FEE9DDCAFE63584D7F0000000000000000675D
          537FFCF6EEFEF5EDE2FEEFE4D7FEF3EADEFECBB8A6FED7C9BCFED7C9BCFED7C9
          BCFED7C9BCFED7C9BCFED6C5B0FEEADFCCFE63584E7F0000000000000000675D
          547FFDF8F1FEFDF6EEFEFCF5ECFEFCF4EAFEE0D3C3FEE2D4C5FEE1D3C4FEE0D2
          C3FEDFD1C1FEDED0C0FEE5D8C6FEECE1CFFE64594E7F0000000000000000675D
          547FFDF8F2FEEADED2FED7C6B4FEE9DDCFFED3C4B5FEF1ECE8FEF0ECE7FEF0EC
          E7FEF1ECE8FEF0ECE7FED3C2ADFEEDE3D1FE64594F7F0000000000000000685E
          557FFDF9F4FEFDF9F1FEFDF7F0FEFDF7EEFED6C6B7FEE4D9CFFEE4D9CFFEE4D9
          CEFEE3D9CEFEE3D8CDFEDDCDBBFEF0E5D5FE645A507F0000000000000000675E
          557FFDFAF5FEFDF9F3FEFDF8F2FEFDF7F0FED5C3B2FECBB5A1FECAB5A0FECAB4
          A0FEC9B49EFEC9B39EFEE8DCCCFEF1E7D8FE655A507F0000000000000000675D
          547FFCFAF5FEF0E9E0FEE4D8CBFEF0E8DEFED7C9BCFEFDFDFDFEFDFDFDFEFDFD
          FDFEFDFDFDFEFDFDFDFED4C2AFFEF3E9DCFE655B517F0000000000000000665C
          537FFBF8F3FEF6F2EBFEF1E9E0FEF6F0E9FECCB9A8FED7C9BCFED7C9BCFED7C9
          BCFED7C9BCFED7C9BCFEDCCCBCFEF4EADEFE665C527F0000000000000000665C
          527FF8F3ECFEF5F0E9FEF1EAE1FEF1E9E1FEF1E9E0FEF1E8DEFEF1E7DDFEF0E6
          DCFEF0E6DAFEF0E5D8FEF4EBE0FEF6EDE1FE665C537F0000000000000000665B
          517FF2EBE1FEECE5DBFEE3D8CDFEE3D8CDFEE4D9CDFEE4D8CBFEE3D8CAFEE3D7
          CAFEE4D6C8FEE3D5C8FEEFE5D8FEF7EEE3FE665D537F0000000000000000423C
          3652BAA48EF5D2C2B1FED2C3B4FEE2D6CAFEFDFAF6FEFDFAF5FEFDF9F4FEFDF9
          F3FEFDF8F1FEFDF7F0FEFDF6EEFEF9F0E6FE675D547F00000000000000000807
          070976695C97DACDBEF4F0EAE1FEE2D7CBFEFCF9F5FEFDFAF6FEFDF9F5FEFDF9
          F4FEFDF9F2FEFDF8F1FEFDF7EFFEF9F1E8FE675E547F00000000000000000000
          00000908080A50473E68CAB8A5F2DED0BFFEF9F4EEFEFBF8F4FEFDFAF7FEFDFB
          F6FEFDFAF5FEFDF9F4FEFDF8F2FEF9F2E9FE635A517900000000000000000000
          00000000000008070709665A4D86B7A18BEDD3C2B0FED5C5B6FED6C8B9FED7C8
          B9FED7C8B9FED7C8B9FED7C8B8FEC7B7A7EF3E39334C00000000}
      end
      item
        Image.Data = {
          36040000424D3604000000000000360000002800000010000000100000000100
          2000000000000004000000000000000000000000000000000000000000000000
          00000000000000000000000000000000000007120B1732794DAE204A2F6D060D
          0911000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000C1F132842A567D04DB373E52350
          3475000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000D21142A43AA6AD46AEF9AFE6ADA
          92FE29573A7B08100B1400000000000000000000000000000000000000000000
          0000000000000000000000000000000000000D21142A43AA6AD46BF09BFE7BF2
          A6FE66C087E92C5C3E7F000000000000000000000000000000001348276D2C9E
          56F52CAB5BFE2FAF5EFE36B566FE3CB96AFE45BF72FE52D782FE6BF09BFE7BF3
          A7FE90F5B6FE8AE2AAFE336044830A130D16000000000000000014542C7E1BAE
          52FE15BF53FE1CC75BFE2AD468FE36DC73FE48E681FE55EB8CFE6BF09BFE7BF3
          A7FE91F6B6FEA0F6C0FE80C89BEB37634786000000000000000014542C7E1AAE
          52FE15BF53FE1CC75BFE2AD469FE36DC73FE48E681FE55EB8BFE6BF09BFE7BF3
          A7FE91F6B6FEA0F7C0FEB0F8CCFEA6E8BEFE396247870B120D1615542C7E1AAE
          52FE15BF53FE1CC75BFE2AD468FE36DC73FE48E681FE55EB8CFE6BF09BFE7BF3
          A7FE92F6B7FEA1F7C0FEB1F8CBFEBAF8D2FE73AE89DA1A2D213E14542C7E1BAE
          52FE15BF53FE1CC75BFE2AD368FE36DC73FE48E681FE55EB8CFE6BF09CFE7BF3
          A7FE92F6B7FEA0F7C0FEADF5C8FE90D3A9F32B4F386C0609070B14542C7E1AAE
          52FE15BF53FE1CC75BFE2AD468FE36DC73FE48E681FE55EB8CFE6BF09CFE7BF3
          A7FE92F6B6FEA0F7C0FE89D3A5F43C6D4E940509070B000000000F3F215E2189
          48CE20944BD424984FD42B9E56D432A35BD43DAC65DB4FD17FF76BF09BFE7BF4
          A7FE8EF2B3FE7BCF9AF3274D35690509060A0000000000000000020B050F071C
          0F27081F112A091F112A0A20122A0B21132A1539224B43A969D76AF09BFE7BF3
          A7FE6FCD92F3356948910409060A000000000000000000000000000000000000
          0000000000000000000000000000000000000C20132841A565CF68EC98FE60C8
          87F221462F630408050900000000000000000000000000000000000000000000
          0000000000000000000000000000000000000C1F132841A465CF54C47EF12C61
          408B030704080000000000000000000000000000000000000000000000000000
          000000000000000000000000000000000000060E09122C6742901B3E285B0206
          0407000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000102010209140D1A020503060000
          0000000000000000000000000000000000000000000000000000}
      end
      item
        Image.Data = {
          36040000424D3604000000000000360000002800000010000000100000000100
          2000000000000004000000000000000000000000000000000000000000000000
          00000000000000000000000000000202020331302D64423732E6403530E6302F
          2D64010101020000000000000000000000000000000000000000000000000000
          00000000000000000000000000002222213D8C7062EECEAC9DFFCBAC9DFF896D
          5FEE21201F3C0000000000000000000000000000000000000000000000000000
          0000000000000000000000000000353837708E7063FFCBAB9CFFCAAD9FFF8E70
          62FF3235346C0000000000000000000000000000000000000000000000000000
          000000000000000000000204040545494780897166FFC0AFA4FFBFB0A7FF8972
          66FF4247457D0204040500000000000000000000000000000000000000000000
          000000000000080E0F115271777758AAC0DC54C2DBFF73E0F1FF73E1F2FF59C3
          DBFF59AAC0DC52717777080E0F11000000000000000000000000000000000000
          0000050A0B0C40585C5E3CB6E2E325CCFBFD37D9FEFF3CDEFFFF3EDFFFFF40DD
          FEFF30D0FBFD3EB7E2E340585C5E050A0B0C0000000000000000000000000000
          00002C3D4141459FC8C903BAFDFE03BEFFFF01C4FFFF00C9FFFF00CAFFFF01C6
          FFFF05C1FFFF04BDFDFE459FC8C92C3D41410000000000000000000000000102
          02024F7079791FA9ECED00B7FFFF00C2FFFF02CAFFFF06CDFFFF06CDFFFF02CB
          FFFF00C3FFFF00B9FFFF1FAAECED4F707979010202020000000000000000070C
          0D0D588E9FA005ADFBFC04C6FFFF18D3FFFF34DDFFFF41E1FFFF41E1FFFF34DD
          FFFF18D3FFFF04C6FFFF05ADFBFC588E9FA0060C0D0D0000000000000000070D
          0F0F5893A5A600B7FFFF1DD5FFFF47E4FFFF6CF0FFFF7AF5FFFF7AF5FFFF6CF0
          FFFF47E4FFFF1DD5FFFF00B7FFFF5893A5A6070D0F0F00000000000000000305
          06065086959606C0FCFD47E3FFFF7DF5FFFFABFEFFFFBDFFFFFFBDFFFFFFABFE
          FFFF7DF5FFFF47E3FFFF06C0FCFD508695960305060600000000000000000000
          00003A616B6B16C0F0F157E9FFFF9CFBFFFFD5FFFFFFEBFFFFFFEBFFFFFFD5FF
          FFFF9CFBFFFF57E9FFFF16C0F0F13A616B6B0000000000000000000000000000
          00000E1A1D1D3496AFB048E3FFFFA3FBFFFFF2FFFFFFFFFFFFFFFFFFFFFFF2FF
          FFFFA3FBFFFF48E3FFFF3496AFB00E1A1D1D0000000000000000000000000000
          0000010202021D2F333330BAD8D970EFFFFFDBFFFFFFFAFFFFFFFAFFFFFFDBFF
          FFFF70EFFFFF30BAD8D91D303333010202020000000000000000000000000000
          00000000000000000000111C1E1E30717E7E4CB6C8C978CFD9DA78CFD9DA4CB6
          C8C930717E7E121C1E1E00000000000000000000000000000000000000000000
          000000000000000000000000000002030303111D1F1F182C3030182C3030101D
          1F1F020303030000000000000000000000000000000000000000}
      end>
  end
  object TemplatePopup1: TTemplatePopup
    Templates = <>
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    BgColor = clWindow
    ToolHint.Left = 0
    ToolHint.Top = 0
    ToolHint.Width = 0
    ToolHint.Height = 0
    ToolHint.Text = ''
    Controls = <>
    Left = 720
    Top = 660
  end
  object cxImageList2: TcxImageList
    SourceDPI = 96
    FormatVersion = 1
    DesignInfo = 42469120
    ImageInfo = <
      item
        Image.Data = {
          36040000424D3604000000000000360000002800000010000000100000000100
          2000000000000004000000000000000000000000000000000000000000002E56
          6A964E93B4FF4E93B4FF4E93B4FF4E93B4FF4E93B4FF4E93B4FF4E93B4FF4E93
          B4FF4E93B4FF4E93B4FF4E93B4FF4E93B4FF2E566A9600000000000000005698
          B7FFA6EAFFFF33CEFFFF32CDFFFF31CCFFFF2FCBFFFF2FCAFFFF2EC7FFFF2EC6
          FFFF2CC6FFFF2CC4FFFF2BC3FFFF2AC2FFFF4E93B4FF00000000000000005698
          B8FFAFEEFFFF37D3FFFF36D3FFFF35D1FFFF34D0FFFF33CFFFFF32CDFFFF31CD
          FFFF30CBFFFF30C9FFFF2EC9FFFF2EC7FFFF4E93B4FF00000000000000005799
          B8FFBDF2FFFF3DD8FFFF3CD8FFFF3AD7FFFF39D5FFFF38D4FFFF37D3FFFF36D2
          FFFF34D0FFFF33CFFFFF32CEFFFF32CDFFFF4E93B4FF00000000000000005799
          B8FFCEF6FFFF44DEFFFF42DDFFFF41DBFFFF3FDAFFFF3EDAFFFF3DD8FFFF3BD7
          FFFF3AD6FFFF38D5FFFF37D3FFFF36D2FFFF4E93B4FF00000000000000005899
          B8FFE0FAFFFF4CE2FFFF4AE1FFFF48E0FFFF47DFFFFF45DEFFFF44DDFFFF42DC
          FFFF40DAFFFF3FDAFFFF3DD9FFFF3CD8FFFF4E93B4FF00000000000000005899
          B8FFEBFCFFFF56E5FFFF53E4FFFF51E3FFFF4FE3FFFF4DE1FFFF4BE1FFFF49E0
          FFFF47DFFFFF46DEFFFF44DDFFFF43DDFFFF4E93B4FF00000000000000005899
          B8FFF2FDFFFF62E9FFFF60E8FFFF5DE6FFFF5AE6FFFF57E5FFFF55E4FFFF53E4
          FFFF50E3FFFF4EE2FFFF4CE1FFFF4AE0FFFF4E93B4FF00000000000000005899
          B8FFF6FEFFFF70ECFFFF6EEBFFFF6AEAFFFF67EAFFFF64E9FFFF61E9FFFF5EE7
          FFFF5CE6FFFF58E6FFFF56E5FFFF53E4FFFF4E93B4FF00000000000000005899
          B8FFF8FEFFFF7FEFFFFF7CEFFFFF79EDFFFF75EDFFFF72ECFFFF6FEBFFFF6CEB
          FFFF69EAFFFF65E9FFFF63E9FFFF60E8FFFF4E93B4FF00000000000000005899
          B8FFF9FEFFFF8FF2FFFF8BF1FFFF88F1FFFF85F0FFFF81F0FFFF7DEFFFFF7BEE
          FFFF77EEFFFF73EDFFFF71EBFFFF6DEBFFFF4E93B4FF00000000000000005899
          B8FFF9FEFFFF9DF4FFFF9AF4FFFF96F3FFFF93F3FFFF90F3FFFF8DF2FFFF89F1
          FFFF86F0FFFF83F0FFFF7FEFFFFF7CEEFFFF4E93B4FF00000000000000005899
          B8FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFF
          FFFFFAFEFFFFF1FDFFFFE4FCFFFFD3FAFFFF4E93B4FF00000000000000002E56
          6A964DB9D8FF39C0F1FF269EE2FF29A4E5FF2BA9E8FF2EAFEBFF2FB3EEFF31B6
          F1FF31BAF4FF32BDF7FF41D4FDFF4CC2E1FF2F586B990000000000000000060A
          0D125197B7FF72D7F3FF0E73D0FF127AD4FF1684D9FF1A8CDFFF1D94E3FF1F9A
          E8FF21A0ECFF22A6F0FF7CE9FEFF59A5C2FF0F1C223000000000000000000000
          0000274A5B814887A4EA4E93B4FF4E93B4FF4E93B4FF4E93B4FF4E93B4FF4E93
          B4FF4E93B4FF4E93B4FF4E93B4FF2E566A960000000000000000}
      end
      item
        Image.Data = {
          36040000424D3604000000000000360000002800000010000000100000000100
          2000000000000004000000000000000000000000000000000000000000002E56
          6A964E93B4FF4E93B4FF4E93B4FF4E93B4FF4E93B4FF4E93B4FF4E93B4FF4E93
          B4FF4E93B4FF4E93B4FF4E93B4FF4E93B4FF2E566A9600000000000000005698
          B7FFA6EAFFFF33CEFFFF32CDFFFF31CCFFFF2FCBFFFF2FCAFFFF2EC7FFFF2EC6
          FFFF2CC6FFFF2CC4FFFF2BC3FFFF2AC2FFFF4E93B4FF00000000000000005698
          B8FFAFEEFFFF37D3FFFF36D3FFFF35D1FFFF34D0FFFF228AAAFF2DB6E3FF31CD
          FFFF30CBFFFF30C9FFFF2EC9FFFF2EC7FFFF4E93B4FF00000000000000005799
          B8FFBDF2FFFF3DD8FFFF3CD8FFFF3AD7FFFF2CA6C7FF000000FF195E72FF36D2
          FFFF34D0FFFF33CFFFFF32CEFFFF32CDFFFF4E93B4FF00000000000000005799
          B8FFCEF6FFFF44DEFFFF42DDFFFF41DBFFFF3FDAFFFF3EDAFFFF3DD8FFFF3BD7
          FFFF3AD6FFFF38D5FFFF37D3FFFF36D2FFFF4E93B4FF00000000000000005899
          B8FFE0FAFFFF4CE2FFFF4AE1FFFF48E0FFFF47DFFFFF08191DFF2D93AAFF42DC
          FFFF40DAFFFF3FDAFFFF3DD9FFFF3CD8FFFF4E93B4FF00000000000000005899
          B8FFEBFCFFFF56E5FFFF53E4FFFF51E3FFFF4FE3FFFF1A4B55FF000000FF184B
          55FF47DFFFFF46DEFFFF44DDFFFF43DDFFFF4E93B4FF00000000000000005899
          B8FFF2FDFFFF62E9FFFF60E8FFFF49B3C7FF5AE6FFFF57E5FFFF4CCBE3FF0000
          00FF3597AAFF4EE2FFFF4CE1FFFF4AE0FFFF4E93B4FF00000000000000005899
          B8FFF6FEFFFF70ECFFFF6EEBFFFF000000FF39828EFF64E9FFFF419BAAFF0000
          00FF3D99AAFF58E6FFFF56E5FFFF53E4FFFF4E93B4FF00000000000000005899
          B8FFF8FEFFFF7FEFFFFF7CEFFFFF366A72FF000000FF000000FF000000FF244E
          55FF69EAFFFF65E9FFFF63E9FFFF60E8FFFF4E93B4FF00000000000000005899
          B8FFF9FEFFFF8FF2FFFF8BF1FFFF88F1FFFF76D6E3FF56A0AAFF62BBC7FF7BEE
          FFFF77EEFFFF73EDFFFF71EBFFFF6DEBFFFF4E93B4FF00000000000000005899
          B8FFF9FEFFFF9DF4FFFF9AF4FFFF96F3FFFF93F3FFFF90F3FFFF8DF2FFFF89F1
          FFFF86F0FFFF83F0FFFF7FEFFFFF7CEEFFFF4E93B4FF00000000000000005899
          B8FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFF
          FFFFFAFEFFFFF1FDFFFFE4FCFFFFD3FAFFFF4E93B4FF00000000000000002E56
          6A964DB9D8FF39C0F1FF269EE2FF29A4E5FF2BA9E8FF2EAFEBFF2FB3EEFF31B6
          F1FF31BAF4FF32BDF7FF41D4FDFF4CC2E1FF2F586B990000000000000000060A
          0D125197B7FF72D7F3FF0E73D0FF127AD4FF1684D9FF1A8CDFFF1D94E3FF1F9A
          E8FF21A0ECFF22A6F0FF7CE9FEFF59A5C2FF0F1C223000000000000000000000
          0000274A5B814887A4EA4E93B4FF4E93B4FF4E93B4FF4E93B4FF4E93B4FF4E93
          B4FF4E93B4FF4E93B4FF4E93B4FF2E566A960000000000000000}
      end
      item
        Image.Data = {
          36040000424D3604000000000000360000002800000010000000100000000100
          2000000000000004000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          00000000001C000000FF00000000000000000000000000000000000000000000
          0000000000000000000000000000000000FF0000001C00000000000000000000
          0000000000C60000008D000000000000000000000071000000AA000000710000
          0071000000AA00000038000000000000008D000000C600000000000000000000
          001C000000FF000000380000000000000055000000C600000055000000710000
          00E20000008D0000001C0000000000000038000000FF0000001C000000000000
          0055000000FF0000000000000000000000000000008D000000C6000000AA0000
          00E200000055000000000000000000000000000000FF00000055000000000000
          0055000000FF0000000000000000000000000000000000000000000000000000
          00AA00000055000000000000000000000000000000FF00000055000000000000
          001C000000FF000000380000000000000000000000C6000000FF000000FF0000
          00C600000000000000000000000000000038000000FF0000001C000000000000
          0000000000C60000008D00000000000000000000000000000000000000000000
          00000000000000000000000000000000008D000000C600000000000000000000
          00000000001C000000FF00000000000000000000000000000000000000000000
          0000000000000000000000000000000000FF0000003800000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000}
      end
      item
        Image.Data = {
          36040000424D3604000000000000360000002800000010000000100000000100
          2000000000000004000000000000000000000000000000000000000000000000
          00000000000000000000000000000506142413174C691920688A192067891217
          49650405121F0000000000000000000000000000000000000000000000000000
          00000000000005071623212A88B42E40C5FE2D49D2FF2C51DBFF2C50DAFF2D49
          D1FF2E3FC4FD202882AC0406121D000000000000000000000000000000000000
          00000B0E2C3F2C39B8F02F4AD9FF2D5CEEFF276AF7FF2471FBFF2470FBFF2869
          F7FF2D5BEEFF2F4AD7FF2B38B5EB090C25350000000000000000000000000507
          16232D39BAF0324BDFFF2F5CF3FF2B67FCFF286FFEFF2772FEFF2772FEFF296D
          FEFF2C66FBFF305AF2FF324ADEFF2C38B4E90405101A0000000000000000212A
          8AB42E3DC1FF000000FF335EFCFF3468FEFF346EFFFF3370FFFF3370FFFF356D
          FFFF3667FEFF345CFCFF3551EFFF000000FF1B226FAE0000000005061424323F
          CBFE0C1033FF19256FFF3E5FFEFF4168FFFF243D8EFF152555FF233D8EFF243C
          8EFF162355FF3149C6FF3951F8FF192066FF0B0E2DFE03040D1713174C692E3B
          BEFF000000FF3140C5FF4860FFFF3245AAFF111839FF3147AAFF293B8EFF080C
          1DFF222E72FF4055E3FF3F51FCFF2C38B8FF000000FF101440591920698A232D
          91FF000000FF4353FEFF4E5FFFFF5265FFFF242E72FF121739FF1B2255FF090C
          1DFF3743AAFF4E5EFFFF4252FEFF3A49EFFF000000FF161C5D7A19206889242D
          91FF000000FF4353FEFF4F5FFFFF5564FFFF5665FFFF5665FFFF5665FFFF1D22
          55FF3943AAFF4F5EFFFF4252FEFF3A49EFFF000000FF161C5C79121749653E49
          C0FF000000FF3F4BC5FF5967FFFF5C6AFFFF141739FF000000FF000000FF1417
          39FF5C6AFFFF5967FFFF515FFCFF3D47BAFF000000FF0F133D550405121F404C
          CDFD141734FF2D336FFF737FFEFF7F8AFFFF848FFFFF8791FFFF8791FFFF848F
          FFFF7E89FFFF727EFEFF6571F8FF282E68FF0E112DFE03030B1300000000222A
          84AC515CC7FF000000FF747FFBFF7F8AFEFF8791FFFF8B95FFFF8B95FFFF8791
          FFFF7F89FEFF737FFBFF6974F0FF000000FF181D5EB200000000000000000406
          121D3B46BBEB6C76E4FF7781F1FF7F89F9FF8690FDFF8A94FEFF8A94FEFF8690
          FDFF7F89F9FF7680F1FF6B75E4FF3741B4E303040D1400000000000000000000
          0000090B25353E48BAE9737DE3FF828BEEFF8992F3FF8C95F6FF8C95F5FF8891
          F3FF818AEDFF717BE2FF3A45B5E307091E2B0000000000000000000000000000
          0000000000000405101A21297EA4565FD0FB7780E1FF8A92E8FF8991E8FF757E
          E0FF535DCDF91F27779C03040D14000000000000000000000000000000000000
          000000000000000000000000000003040D1710144059161C5C7A161C5C790F13
          3D5503030B130000000000000000000000000000000000000000}
      end
      item
        Image.Data = {
          36040000424D3604000000000000360000002800000010000000100000000100
          2000000000000004000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          000000000000000000000606060C868686FF8C8C8CFF0B0B0B15000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000002B2B2B54888888FFBBBBBBFF3C3C3C7500000000000000000000
          0000000000000000000000000000000000000403020600000000000000000000
          00003737376C8B8B8BFFDFDFDFFF919191FF0F0F0F1E00000000000000000000
          00000000000000000000221A1236644B369FA37A57FF503C2B7E000000003C3C
          3C758E8E8EFFEAEAEAFFB8B8B8FF3939396F0000000000000000000000000000
          00000000000000000000644B369FCB7E53FFE28A5DFFB3815CFF75604DC69191
          91FFEFEFEFFFE6E6E6FF838383FF030303060000000000000000000000000000
          00000000000006040309A37A57FFE68B5CFFEC976CFFEEA37BFFC3906CFFBFA7
          91FFEAE2DBFF9A9A9AFF32323263000000000000000000000000000000000000
          00000000000000000000816246CCB5825CFFEA9F78FFF4AF88FFF7B995FFD8A7
          85FFA47D5AFF6C5D50BC00000000000000000000000000000000000000000000
          000000000000261D143CA87A56FFC18159FFAB805DFFE4AB87FFF9C19EFFFAC8
          A8FFE8BE9DFFAC8562FF42322469000000000000000000000000000000000000
          000000000000684F38A5CE8156FFEB966AFFD3966FFFA37C59FFD6A987FFFBCF
          B0FFFBD5B7FFEBCAACFF856448D20000000000000000000000002A2017426C52
          3AAB906D4EE6AA7B56FFEA9164FFF0A279FFF5B28DFFE8B28FFFC59A78FFC29B
          7AFFF8D7B9FFD2B191FF57412F8A0000000000000000000000006C523AABCF81
          54FFE08F63FFAF815DFFC38A63FFF4AE87FFF8BB98FFFAC7A6FFD6AD8CFF8364
          47D0A6805DFF5843308D15100B21000000000000000000000000A37A57FFE38E
          62FFEE9E75FFF0AB84FFC0916EFFC3936FFFE8B594FFDBB08FFF684F38A51C16
          0F2D0907050F0000000000000000000000000000000000000000503C2B7EA97E
          5AFFE1A07AFFF6B894FFF9C2A0FFD6AB89FFA37C59FFA27B58FF261D143C0000
          0000000000000000000000000000000000000000000000000000000000003B2C
          205DA37B58FFD3A27FFFFACAA9FFFBD2B3FFE4C0A1FF836247CF000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          000019130D275F483396C19977FFF8D5B7FFD8B798FF624B359C000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          000000000000000000005843308DA88260FF624B359C20181133000000000000
          0000000000000000000000000000000000000000000000000000}
      end
      item
        Image.Data = {
          36040000424D3604000000000000360000002800000010000000100000000100
          2000000000000004000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000002828284E5D5D5DB72828284E0000000000000000000000000000
          0000000000000000000000000000000000000304070C00000000000000000000
          00002828284E858585FFDCDCDCFF979797FF1515152A00000000000000000000
          0000000000000000000000000000262D5690424E9CFF2D3567AB111428422828
          284E858585FFDCDCDCFFDADADAFF5C5C5CB40000000000000000000000000000
          000000000000000000000F1222393D4BA5FF3046D4FF3F51C7FF43509DFF696E
          8EFFDCDCDCFFFBFBFBFF949494FF2626264B0000000000000000000000000000
          00000000000000000000242C558D3748BAFF3B50DBFF495DE2FF5567DDFF4955
          A6FF99A0C8FFBDBDBDFF4848488D000000000000000000000000000000000000
          000000000000000000001013253E434F9BFF4556C4FF5568E8FF6476EFFF7081
          F1FF5764B9FF5E6591FF10121C31000000000000000000000000000000000000
          00000000000000000000262D56904050B4FF4756B7FF4F5DBAFF6E7EF0FF7D8C
          F6FF8A98F8FF727ECEFF45519BFF181C365A0000000000000000000000000000
          00000000000014172D4B414EA2FF475BDFFF5B6DEAFF5664C1FF4E5BACFF7F8E
          EDFF95A2FAFFA3AEFAFF96A0E3FF44509AFF0101020300000000000000000E11
          2036232A5087323B71BD4153C9FF5466E7FF6778F0FF7988F6FF6976CBFF4955
          A0FF8592DFFFADB7FAFFAFB9F2FF49559EFF0304070C0000000022284D813D4C
          A5FF3D4DBAFF43509CFF4858C4FF6072EDFF7282F4FF8492F8FF96A2FAFF7C88
          D1FF45519BFF7580C3FF5C67ACFF22284D810000000000000000424F9AFF3449
          D2FF4357E0FF5264DBFF4855A5FF5564C2FF7D8CF7FF8F9CF9FF949FECFF4D59
          A2FF1D22416D1D22436F0D101F33000000000000000000000000262D56904152
          BFFF5064E6FF6274EEFF7181F0FF5663B6FF5F6CC0FF8996E7FF525EA7FF1E23
          44720000000000000000000000000000000000000000000000000A0C1727272E
          59964D5BB7FF6D7EF0FF7E8DF7FF8E9BF9FF727ECBFF44509AFF232A50870000
          0000000000000000000000000000000000000000000000000000000000000000
          0000242C558D4D5AABFF818EEDFF9AA6FAFFAAB4FAFF7E89CAFF22284D810000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000001F2446754955A0FF8994DDFFB1BBF8FF5F6AAFFF0F1222390000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000014172D4B2F386BB44C57A0FF262D5690000000000000
          0000000000000000000000000000000000000000000000000000}
      end
      item
        Image.Data = {
          36040000424D3604000000000000360000002800000010000000100000000100
          2000000000000004000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          000000000055000000AA0000001C000000000000000000000000000000000000
          0000000000000000008D0000008D000000000000000000000000000000000000
          001C000000E2000000FF00000038000000000000000000000000000000000000
          000000000002040404E53B3B3BFF787878E71C1C1C4200000000000000000000
          008D000000FF000000C600000000000000000404040A0808081706060612090A
          0A103434346A5E5E5EEA989898FF545454F403030316000000000000001C0000
          00FF000000FF0000003800000000070707103631326E5F4E4DC04E4240A43E3C
          3E907C7C7BE8B5B5B5FE939393FD1C1C1CFF00000074000000000000008D0000
          00FF000000C6000000000000000019171834715755D8C38060FEB07E66FC957F
          75FBBAB4AEFFC0BFBEFD595959D3050505FF000000E200000000000000C60000
          00FF0000008D00000000000000002622224B8C685AF0D68E66FFE39F78FFD7A6
          86FFCDB099FF90847EEA1F1E1D7F000000FF000000FF0000001C000000FF0000
          00FF000000550000000002020207332D2E70956D5CF6C88C66FFD9A07BFFEAB4
          92FFDDB191FF9F8576F538333786000000FF000000FF00000055000000FF0000
          00FF000000551C1A1A3A343033846A5552D7C68564FFDB976FFFD29E7AFFDAAC
          8AFFEBC2A3FFCDAC92FE52484FBF010100FF000000FF00000055000000FF0000
          00FF000000556C5859CD94695CF6AB7B5FFED2916AFFEEAA84FFE5B08DFFC59D
          80FEBB987EFC9A8277ED433D4087000000FF000000FF00000055000000AA0000
          00FF000000AA9B735FF7D78E67FFDC9C75FFD29B76FFD8A380FFC9A086FE8672
          6DE1554B4B992D2A2D5E0B0B0B69000000FF000000FF00000000000000710000
          00FF000000E2524341B1B2846BF9E1A783FFE8B694FFCFA685FF937969F23D37
          367E0C0B0B15030303030000008D000000FF000000C600000000000000000000
          00E2000000FF080808854E4340939D7F73EFD8B093FFDDBA9DFF7A6965E01A19
          1945000000000000001C000000FF000000FF0000003800000000000000000000
          0071000000FF000000E2070707112E2C2F65786461E49E8273F7564D4EA30807
          0717000000000000008D000000FF000000C60000000000000000000000000000
          0000000000C6000000FF00000055000000000000000000000000000000000000
          000000000000000000FF000000FF0000001C0000000000000000000000000000
          00000000001C0000005500000000000000000000000000000000000000000000
          0000000000000000003800000038000000000000000000000000}
      end
      item
        Image.Data = {
          36040000424D3604000000000000360000002800000010000000100000000100
          2000000000000004000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          000000000055000000AA0000001C000000000000000000000000000000000000
          0000000000000000008D0000008D000000000000000000000000000000000000
          001C000000E2000000FF00000038000000000000000000000000000000000000
          000000000000000000E2000000FF000000550000000000000000000000000000
          008D000000FF000000C600000000000000000404040407070708050505050909
          090A3636364D373737CD000000FF010101E300000000000000000000001C0000
          00FF000000FF000000380000000007070707292B333D363B587B3134445B3C3D
          4362848485C6AFAFAFEF0A0A0AF1000000FF00000071000000000000008D0000
          00FF000000C600000000000000001616181A2F3767973949B4F3404EA6E76970
          9AE6B8BAC6F8858688C91B1B1B93000000FF000000E200000000000000C60000
          00FF0000008D00000000000000001E1E21252D3879B84254C8FE5466DBFE6776
          D2FE8189BCFE494C5B8A0F0F0F49000000FF000000FF0000001C000000FF0000
          00FF0000005500000000020202022829303A36418ACC4B5BC4FE5B6BD3FE7381
          E5FE7B86D8FE535B8CC22D2E3C4C000000FF000000FF00000055000000FF0000
          00FF000000551717191C2C2E3B4B394069964858C4F75C6DDFFE6574D3FE6F7C
          D1FE8995E3FE7D88CAF733395A85000000FF000000FF00000055000000FF0000
          00FF000000553C426892334092D0414EA6EB5363CFFE6F7FEDFE7D89E7FE636F
          B8F25964A1DB525A8ABB32354255000000FF000000FF00000055000000AA0000
          00FF000000AA323D83C94457CFFE5466D5FE5D6BCCFE6F7CD9FE717DCDF54E54
          80AF393B4B6026282F380A0A0B60000000FF000000FF00000000000000710000
          00FF000000E22429405E445095C86271D9FA7B88E7FE737FD0FE4F588BC12E30
          38430A0A0B0B030303030000008D000000FF000000C600000000000000000000
          00E2000000FF0606077833353F4C4B538DC07F8BDDFE8B96DEFE4B5179A41717
          1A1E000000000000001C000000FF000000FF0000003800000000000000000000
          0071000000FF000000E2070707072A2B333D384173AF4D5793D73D3F52690606
          0606000000000000008D000000FF000000C60000000000000000000000000000
          0000000000C6000000FF00000055000000000000000000000000000000000000
          000000000000000000FF000000FF0000001C0000000000000000000000000000
          00000000001C0000005500000000000000000000000000000000000000000000
          0000000000000000003800000038000000000000000000000000}
      end>
  end
  object AutoCompleteSQL: TAutoCompletePopup
    Styles = SyntStyles2
    StartString = '.'
    SortType = asDisplayItems
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    IntegralHeight = True
    ItemHeight = 16
    BgColor = clWindow
    Width = 600
    Height = 200
    ToolHint.Left = 0
    ToolHint.Top = 0
    ToolHint.Width = 600
    ToolHint.Height = 0
    ToolHint.MinMaxWidth = 600
    ToolHint.Text = ''
    Controls = <>
    Left = 224
    Top = 332
  end
  object AutoCompleteJS: TAutoCompletePopup
    Styles = SyntStyles2
    StartString = '.'
    SortType = asDisplayItems
    AutoSize = True
    OnGetAutoCompleteList = AutoCompleteJSGetAutoCompleteList
    OnBeforeComplete = AutoCompleteJSBeforeComplete
    OnAfterComplete = AutoCompleteJSAfterComplete
    OnFilter = AutoCompleteJSFilter
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    IntegralHeight = True
    ItemHeight = 16
    OnlyDblClick = True
    AutoSelect = False
    BgColor = clWindow
    Width = 600
    Height = 200
    ToolHint.Left = 0
    ToolHint.Top = 0
    ToolHint.Width = 600
    ToolHint.Height = 0
    ToolHint.MinMaxWidth = 600
    ToolHint.Text = ''
    Controls = <>
    OnCanShow = AutoCompleteJSCanShow
    Left = 224
    Top = 456
  end
  object AutoCompleteCalc: TAutoCompletePopup
    Styles = SyntStyles2
    StartString = '.'
    SortType = asDisplayItems
    OnGetAutoCompleteList = AutoCompleteCalcGetAutoCompleteList
    OnBeforeComplete = AutoCompleteCalcBeforeComplete
    OnAfterComplete = AutoCompleteCalcAfterComplete
    OnFilter = AutoCompleteCalcFilter
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    IntegralHeight = True
    ItemHeight = 16
    BgColor = clWindow
    Width = 600
    Height = 200
    ToolHint.Left = 0
    ToolHint.Top = 0
    ToolHint.Width = 600
    ToolHint.Height = 0
    ToolHint.MinMaxWidth = 600
    ToolHint.Text = ''
    Controls = <>
    Left = 224
    Top = 192
  end
  object ParamCompletionCalc: TParamCompletion
    Color = clInfoBk
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    OnGetParams = ParamCompletionCalcGetParams
    ToolHint.Left = 0
    ToolHint.Top = 0
    ToolHint.Width = 0
    ToolHint.Height = 0
    ToolHint.Text = ''
    Controls = <>
    Left = 748
    Top = 192
  end
  object ParamCompletionSQL: TParamCompletion
    Color = clInfoBk
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ToolHint.Left = 0
    ToolHint.Top = 0
    ToolHint.Width = 0
    ToolHint.Height = 0
    ToolHint.Text = ''
    Controls = <>
    Left = 748
    Top = 344
  end
  object ParamCompletionJS: TParamCompletion
    Color = clInfoBk
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    OnGetParams = ParamCompletionJSGetParams
    ToolHint.Left = 0
    ToolHint.Top = 0
    ToolHint.Width = 0
    ToolHint.Height = 0
    ToolHint.Text = ''
    Controls = <>
    Left = 732
    Top = 484
  end
  object PropsManager1: TPropsManager
    Template = SyntaxMemoProduction
    Properties.Strings = (
      'LineNumbers.NumberingStyle'
      'Color'
      'ReplaceMode'
      'UndoLimit'
      'TabMode'
      'ShowRightMargin'
      'RightMarginColor'
      'RightMargin'
      'BlockIndent'
      'CollapseLevel'
      'Options'
      'Gutter.Color'
      'Gutter.Visible'
      'Gutter.Width'
      'TabList.AsString'
      'LineNumbers.Visible'
      'Font'
      'LineNumbers.NumberingStyle'
      'LineNumbers.Font'
      'Zoom'
      ''
      '')
    Left = 1432
    Top = 1096
  end
end
