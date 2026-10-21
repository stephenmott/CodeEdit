UNIT CodeEdit.SettingsDlg;

INTERFACE

USES
  System.Classes,
  Vcl.ComCtrls,
  Vcl.Controls,
  Vcl.Dialogs,
  Vcl.ExtCtrls,
  Vcl.Forms,
  Vcl.Graphics,
  Vcl.StdCtrls,
  CodeEdit.Editor,
  CodeEdit.Settings;

TYPE
  // The editor options dialog shown by TCodeEditorSettings.Execute. A regular
  // designed form (open the DFM in the IDE to restyle it). The pages edit a
  // working copy of the values and show them live in the preview editor; OK
  // and Apply push them to the real editor (and save when RegistryPath is
  // set), Import/Export move them through an INI-format file.
  TCodeEditorSettingsDialog = CLASS(TForm)
    PageControl: TPageControl;
    TabEditing: TTabSheet;
    LabelTabSize: TLabel;
    EditTabSize: TEdit;
    UpDownTabSize: TUpDown;
    CheckBracketMatching: TCheckBox;
    LabelCommentPrefix: TLabel;
    EditCommentPrefix: TEdit;
    LabelMaxPaste: TLabel;
    EditMaxPaste: TEdit;
    UpDownMaxPaste: TUpDown;
    TabDisplay: TTabSheet;
    CheckShowGutter: TCheckBox;
    CheckStyledScrollBars: TCheckBox;
    LabelScrollBars: TLabel;
    ComboScrollBars: TComboBox;
    CheckWordWrap: TCheckBox;
    CheckWrapIndent: TCheckBox;
    CheckShowMinimap: TCheckBox;
    CheckMinimapPreview: TCheckBox;
    LabelMinimapStyle: TLabel;
    ComboMinimapStyle: TComboBox;
    LabelMinimapRowHeight: TLabel;
    EditMinimapRowHeight: TEdit;
    UpDownMinimapRowHeight: TUpDown;
    CheckThemeSyntaxColors: TCheckBox;
    LabelZoom: TLabel;
    EditZoom: TEdit;
    UpDownZoom: TUpDown;
    TabFont: TTabSheet;
    LabelFontCaption: TLabel;
    LabelFont: TLabel;
    ButtonFont: TButton;
    LabelFontNote: TLabel;
    TabColours: TTabSheet;
    LabelThemeMode: TLabel;
    ComboThemeMode: TComboBox;
    LabelBackground: TLabel;
    ColorBackground: TColorBox;
    LabelText: TLabel;
    ColorText: TColorBox;
    LabelGutterBackground: TLabel;
    ColorGutterBackground: TColorBox;
    LabelGutterText: TLabel;
    ColorGutterText: TColorBox;
    LabelGutterBorder: TLabel;
    ColorGutterBorder: TColorBox;
    LabelSelectionBackground: TLabel;
    ColorSelectionBackground: TColorBox;
    LabelSelectionText: TLabel;
    ColorSelectionText: TColorBox;
    LabelPreview: TLabel;
    PreviewEditor: TCodeEditor;
    PanelBottom: TPanel;
    ButtonImport: TButton;
    ButtonExport: TButton;
    ButtonOK: TButton;
    ButtonCancel: TButton;
    ButtonApply: TButton;
    FontDialog: TFontDialog;
    OpenDialog: TOpenDialog;
    SaveDialog: TSaveDialog;
    PROCEDURE FormCreate(Sender: TObject);
    PROCEDURE FormDestroy(Sender: TObject);
    PROCEDURE ControlChanged(Sender: TObject);
    PROCEDURE ComboThemeModeChange(Sender: TObject);
    PROCEDURE ButtonFontClick(Sender: TObject);
    PROCEDURE ButtonOKClick(Sender: TObject);
    PROCEDURE ButtonApplyClick(Sender: TObject);
    PROCEDURE ButtonImportClick(Sender: TObject);
    PROCEDURE ButtonExportClick(Sender: TObject);
  PRIVATE
    FSettings: TCodeEditorSettings;
    FFont: TFont;
    FLoading: Boolean;
    PROCEDURE ValuesToControls(CONST V: TCodeEditorSettingsValues);
    FUNCTION ControlsToValues: TCodeEditorSettingsValues;
    PROCEDURE ApplyVisibility;
    PROCEDURE PopulateThemeModes;
    PROCEDURE UpdateFontLabel;
    PROCEDURE UpdateColourStates;
    PROCEDURE UpdateDependentStates;
    PROCEDURE UpdatePreview;
    PROCEDURE ApplyToEditor;
  PUBLIC
    // Binds the dialog to a settings component and fills the controls from
    // its editor. Execute does this and then shows the dialog modally.
    PROCEDURE Prepare(ASettings: TCodeEditorSettings);
    CLASS FUNCTION Execute(ASettings: TCodeEditorSettings): Boolean;
  END;

IMPLEMENTATION

USES
  System.Math,
  System.SysUtils,
  System.UITypes;

{$R *.dfm}

CONST
  PreviewSample =
    '// Preview'#13#10 +
    'procedure Example(const Name: string);'#13#10 +
    'var'#13#10 +
    '  I: Integer;'#13#10 +
    'begin'#13#10 +
    '  for I := 1 to 3 do'#13#10 +
    '    WriteLn(''Hello, '' + Name + '' #'' + IntToStr(I)); // a longer line that may wrap in a narrow preview'#13#10 +
    'end;';

CLASS FUNCTION TCodeEditorSettingsDialog.Execute(ASettings: TCodeEditorSettings): Boolean;
VAR
  Dlg               : TCodeEditorSettingsDialog;
BEGIN
  Dlg := TCodeEditorSettingsDialog.Create(NIL);
  TRY
    Dlg.Prepare(ASettings);
    Result := Dlg.ShowModal = mrOk;
  FINALLY
    Dlg.Free;
  END;
END;

PROCEDURE TCodeEditorSettingsDialog.FormCreate(Sender: TObject);
BEGIN
  FFont := TFont.Create;
  PreviewEditor.ReadOnly := True;
END;

PROCEDURE TCodeEditorSettingsDialog.FormDestroy(Sender: TObject);
BEGIN
  FFont.Free;
END;

PROCEDURE TCodeEditorSettingsDialog.Prepare(ASettings: TCodeEditorSettings);
VAR
  I                 : Integer;
  Count             : Integer;
BEGIN
  FSettings := ASettings;
  IF FSettings.Title <> '' THEN
    Caption := FSettings.Title;

  // The preview shows the host's own text (a screenful of it) with its
  // highlighter, or a stock sample when the editor is empty.
  PreviewEditor.Highlighter := FSettings.Editor.Highlighter;
  PreviewEditor.Lines.BeginUpdate;
  TRY
    PreviewEditor.Lines.Clear;
    Count := Min(FSettings.Editor.Lines.Count, 40);
    FOR I := 0 TO Count - 1 DO
      PreviewEditor.Lines.Add(FSettings.Editor.Lines[I]);
    IF Trim(PreviewEditor.Lines.Text) = '' THEN
      PreviewEditor.Lines.Text := PreviewSample;
  FINALLY
    PreviewEditor.Lines.EndUpdate;
  END;

  ApplyVisibility;
  PopulateThemeModes;
  ValuesToControls(FSettings.CurrentValues);
END;

// "Custom" and "Follow the VCL style" from the DFM, then whatever theme
// sources the host registered (the DevExpress skin bridge, for one).
PROCEDURE TCodeEditorSettingsDialog.PopulateThemeModes;
VAR
  I                 : Integer;
BEGIN
  WHILE ComboThemeMode.Items.Count > 2 DO
    ComboThemeMode.Items.Delete(ComboThemeMode.Items.Count - 1);
  FOR I := 0 TO CodeEditorThemeSourceCount - 1 DO
    ComboThemeMode.Items.Add(CodeEditorThemeSources(I).Caption);
END;

// Sub-options only mean something while their parent is on.
PROCEDURE TCodeEditorSettingsDialog.UpdateDependentStates;
VAR
  Minimap           : Boolean;
BEGIN
  Minimap := CheckShowMinimap.Checked;
  CheckMinimapPreview.Enabled := Minimap;
  LabelMinimapStyle.Enabled := Minimap;
  ComboMinimapStyle.Enabled := Minimap;
  LabelMinimapRowHeight.Enabled := Minimap;
  EditMinimapRowHeight.Enabled := Minimap;
  UpDownMinimapRowHeight.Enabled := Minimap;
  CheckWrapIndent.Enabled := CheckWordWrap.Checked;
END;

PROCEDURE TCodeEditorSettingsDialog.ApplyVisibility;
VAR
  Items             : TCodeEditorSettingItems;

  PROCEDURE Show(Control: TControl; Item: TCodeEditorSettingItem);
  BEGIN
    Control.Visible := Item IN Items;
  END;

BEGIN
  Items := FSettings.VisibleItems;

  Show(LabelTabSize, siTabSize);
  Show(EditTabSize, siTabSize);
  Show(UpDownTabSize, siTabSize);
  Show(CheckBracketMatching, siBracketMatching);
  Show(LabelCommentPrefix, siLineCommentPrefix);
  Show(EditCommentPrefix, siLineCommentPrefix);
  Show(LabelMaxPaste, siMaxPasteBytes);
  Show(EditMaxPaste, siMaxPasteBytes);
  Show(UpDownMaxPaste, siMaxPasteBytes);
  TabEditing.TabVisible := Items * [siTabSize, siBracketMatching, siLineCommentPrefix,
    siMaxPasteBytes] <> [];

  Show(CheckShowGutter, siShowGutter);
  Show(CheckStyledScrollBars, siStyledScrollBars);
  Show(LabelScrollBars, siScrollBars);
  Show(ComboScrollBars, siScrollBars);
  Show(CheckWordWrap, siWordWrap);
  Show(CheckWrapIndent, siWrapIndent);
  Show(CheckShowMinimap, siShowMinimap);
  Show(CheckMinimapPreview, siMinimapPreview);
  Show(LabelMinimapStyle, siMinimapStyle);
  Show(ComboMinimapStyle, siMinimapStyle);
  Show(LabelMinimapRowHeight, siMinimapRowHeight);
  Show(EditMinimapRowHeight, siMinimapRowHeight);
  Show(UpDownMinimapRowHeight, siMinimapRowHeight);
  Show(CheckThemeSyntaxColors, siThemeSyntaxColors);
  Show(LabelZoom, siZoom);
  Show(EditZoom, siZoom);
  Show(UpDownZoom, siZoom);
  TabDisplay.TabVisible := Items * [siShowGutter, siStyledScrollBars, siScrollBars, siWordWrap,
    siWrapIndent, siShowMinimap, siMinimapPreview, siMinimapStyle, siMinimapRowHeight,
    siThemeSyntaxColors, siZoom] <> [];

  TabFont.TabVisible := siFont IN Items;

  Show(LabelThemeMode, siThemeMode);
  Show(ComboThemeMode, siThemeMode);
  Show(LabelBackground, siColours);
  Show(ColorBackground, siColours);
  Show(LabelText, siColours);
  Show(ColorText, siColours);
  Show(LabelGutterBackground, siColours);
  Show(ColorGutterBackground, siColours);
  Show(LabelGutterText, siColours);
  Show(ColorGutterText, siColours);
  Show(LabelGutterBorder, siColours);
  Show(ColorGutterBorder, siColours);
  Show(LabelSelectionBackground, siColours);
  Show(ColorSelectionBackground, siColours);
  Show(LabelSelectionText, siColours);
  Show(ColorSelectionText, siColours);
  TabColours.TabVisible := Items * [siThemeMode, siColours] <> [];

  IF NOT PageControl.ActivePage.TabVisible THEN
    PageControl.SelectNextPage(True, True);
END;

PROCEDURE TCodeEditorSettingsDialog.ValuesToControls(CONST V: TCodeEditorSettingsValues);
VAR
  I                 : Integer;

  // A TUpDown only pushes its position into the buddy edit once it has a
  // window handle, and Prepare runs before the dialog is shown - so set
  // the text as well.
  PROCEDURE SetSpin(UpDown: TUpDown; Edit: TEdit; Value: Integer);
  BEGIN
    Value := EnsureRange(Value, UpDown.Min, UpDown.Max);
    UpDown.Position := Value;
    Edit.Text := IntToStr(Value);
  END;

BEGIN
  FLoading := True;
  TRY
    SetSpin(UpDownTabSize, EditTabSize, V.TabSize);
    CheckBracketMatching.Checked := V.BracketMatching;
    EditCommentPrefix.Text := V.LineCommentPrefix;
    SetSpin(UpDownMaxPaste, EditMaxPaste, V.MaxPasteBytes DIV (1024 * 1024));

    CheckShowGutter.Checked := V.ShowGutter;
    CheckStyledScrollBars.Checked := V.StyledScrollBars;
    ComboScrollBars.ItemIndex := Ord(V.ScrollBars);
    CheckWordWrap.Checked := V.WordWrap;
    CheckWrapIndent.Checked := V.WrapIndent;
    CheckShowMinimap.Checked := V.ShowMinimap;
    CheckMinimapPreview.Checked := V.MinimapPreview;
    ComboMinimapStyle.ItemIndex := Ord(V.MinimapStyle);
    SetSpin(UpDownMinimapRowHeight, EditMinimapRowHeight, V.MinimapRowHeight);
    CheckThemeSyntaxColors.Checked := V.ThemeSyntaxColors;
    SetSpin(UpDownZoom, EditZoom, V.Zoom);

    FFont.Name := V.FontName;
    FFont.Size := V.FontSize;
    FFont.Style := V.FontStyle;
    UpdateFontLabel;

    ComboThemeMode.ItemIndex := Ord(V.ThemeMode);
    IF V.ThemeSource <> '' THEN
      FOR I := 0 TO CodeEditorThemeSourceCount - 1 DO
        IF SameText(CodeEditorThemeSources(I).Name, V.ThemeSource) THEN
          ComboThemeMode.ItemIndex := 2 + I;
    ColorBackground.Selected := V.Background;
    ColorText.Selected := V.Text;
    ColorGutterBackground.Selected := V.GutterBackground;
    ColorGutterText.Selected := V.GutterText;
    ColorGutterBorder.Selected := V.GutterBorder;
    ColorSelectionBackground.Selected := V.SelectionBackground;
    ColorSelectionText.Selected := V.SelectionText;
    UpdateColourStates;
    UpdateDependentStates;
  FINALLY
    FLoading := False;
  END;
  UpdatePreview;
END;

FUNCTION TCodeEditorSettingsDialog.ControlsToValues: TCodeEditorSettingsValues;
VAR
  Items             : TCodeEditorSettingItems;

  FUNCTION Spin(UpDown: TUpDown; Edit: TEdit; Default: Integer): Integer;
  BEGIN
    Result := EnsureRange(StrToIntDef(Edit.Text, Default), UpDown.Min, UpDown.Max);
  END;

BEGIN
  // Start from the editor's values and only read the controls the dialog
  // shows, so a setting hidden through VisibleItems is carried through
  // untouched (not even clamped to the control's range).
  Result := FSettings.CurrentValues;
  Items := FSettings.VisibleItems;

  IF siTabSize IN Items THEN
    Result.TabSize := Spin(UpDownTabSize, EditTabSize, Result.TabSize);
  IF siBracketMatching IN Items THEN
    Result.BracketMatching := CheckBracketMatching.Checked;
  IF siLineCommentPrefix IN Items THEN
    Result.LineCommentPrefix := EditCommentPrefix.Text;
  IF siMaxPasteBytes IN Items THEN
    Result.MaxPasteBytes := Spin(UpDownMaxPaste, EditMaxPaste, Result.MaxPasteBytes DIV
      (1024 * 1024)) * 1024 * 1024;

  IF siShowGutter IN Items THEN
    Result.ShowGutter := CheckShowGutter.Checked;
  IF siStyledScrollBars IN Items THEN
    Result.StyledScrollBars := CheckStyledScrollBars.Checked;
  IF (siScrollBars IN Items) AND (ComboScrollBars.ItemIndex >= 0) THEN
    Result.ScrollBars := TScrollStyle(ComboScrollBars.ItemIndex);
  IF siWordWrap IN Items THEN
    Result.WordWrap := CheckWordWrap.Checked;
  IF siWrapIndent IN Items THEN
    Result.WrapIndent := CheckWrapIndent.Checked;
  IF siShowMinimap IN Items THEN
    Result.ShowMinimap := CheckShowMinimap.Checked;
  IF siMinimapPreview IN Items THEN
    Result.MinimapPreview := CheckMinimapPreview.Checked;
  IF (siMinimapStyle IN Items) AND (ComboMinimapStyle.ItemIndex >= 0) THEN
    Result.MinimapStyle := TCodeMinimapStyle(ComboMinimapStyle.ItemIndex);
  IF siMinimapRowHeight IN Items THEN
    Result.MinimapRowHeight := Spin(UpDownMinimapRowHeight, EditMinimapRowHeight,
      Result.MinimapRowHeight);
  IF siThemeSyntaxColors IN Items THEN
    Result.ThemeSyntaxColors := CheckThemeSyntaxColors.Checked;
  IF siZoom IN Items THEN
    Result.Zoom := Spin(UpDownZoom, EditZoom, Result.Zoom);

  IF siFont IN Items THEN BEGIN
    Result.FontName := FFont.Name;
    Result.FontSize := FFont.Size;
    Result.FontStyle := FFont.Style;
  END;

  IF (siThemeMode IN Items) AND (ComboThemeMode.ItemIndex >= 0) THEN
    IF ComboThemeMode.ItemIndex >= 2 THEN BEGIN
      // A registered theme source: it colours the editor itself (manual
      // mode, see TCodeEditorSettingsValues.ApplyTo).
      Result.ThemeSource := CodeEditorThemeSources(ComboThemeMode.ItemIndex - 2).Name;
      Result.ThemeMode := ctmManual;
    END ELSE BEGIN
      Result.ThemeSource := '';
      Result.ThemeMode := TCodeEditorThemeMode(ComboThemeMode.ItemIndex);
    END;
  IF siColours IN Items THEN BEGIN
    Result.Background := ColorBackground.Selected;
    Result.Text := ColorText.Selected;
    Result.GutterBackground := ColorGutterBackground.Selected;
    Result.GutterText := ColorGutterText.Selected;
    Result.GutterBorder := ColorGutterBorder.Selected;
    Result.SelectionBackground := ColorSelectionBackground.Selected;
    Result.SelectionText := ColorSelectionText.Selected;
  END;
END;

PROCEDURE TCodeEditorSettingsDialog.UpdateFontLabel;
VAR
  S                 : STRING;
BEGIN
  S := Format('%s, %dpt', [FFont.Name, FFont.Size]);
  IF fsBold IN FFont.Style THEN
    S := S + ', bold';
  IF fsItalic IN FFont.Style THEN
    S := S + ', italic';
  LabelFont.Caption := S;
END;

PROCEDURE TCodeEditorSettingsDialog.UpdateColourStates;
VAR
  Manual            : Boolean;
BEGIN
  // The colour boxes only apply to "Custom"; the VCL style and any
  // registered theme source bring their own palette.
  Manual := ComboThemeMode.ItemIndex = Ord(ctmManual);
  ColorBackground.Enabled := Manual;
  ColorText.Enabled := Manual;
  ColorGutterBackground.Enabled := Manual;
  ColorGutterText.Enabled := Manual;
  ColorGutterBorder.Enabled := Manual;
  ColorSelectionBackground.Enabled := Manual;
  ColorSelectionText.Enabled := Manual;
END;

PROCEDURE TCodeEditorSettingsDialog.UpdatePreview;
BEGIN
  IF FLoading OR NOT Assigned(FSettings) THEN
    Exit;
  ControlsToValues.ApplyTo(PreviewEditor);
END;

PROCEDURE TCodeEditorSettingsDialog.ControlChanged(Sender: TObject);
BEGIN
  IF (Sender = CheckShowMinimap) OR (Sender = CheckWordWrap) THEN
    UpdateDependentStates;
  UpdatePreview;
END;

PROCEDURE TCodeEditorSettingsDialog.ComboThemeModeChange(Sender: TObject);
BEGIN
  UpdateColourStates;
  UpdatePreview;
END;

PROCEDURE TCodeEditorSettingsDialog.ButtonFontClick(Sender: TObject);
BEGIN
  FontDialog.Font.Assign(FFont);
  IF FontDialog.Execute(Handle) THEN BEGIN
    FFont.Assign(FontDialog.Font);
    UpdateFontLabel;
    UpdatePreview;
  END;
END;

PROCEDURE TCodeEditorSettingsDialog.ApplyToEditor;
BEGIN
  FSettings.ApplyValues(ControlsToValues);
  IF Trim(FSettings.RegistryPath) <> '' THEN
    FSettings.SaveSettings;
END;

PROCEDURE TCodeEditorSettingsDialog.ButtonOKClick(Sender: TObject);
BEGIN
  ApplyToEditor;
  ModalResult := mrOk;
END;

PROCEDURE TCodeEditorSettingsDialog.ButtonApplyClick(Sender: TObject);
BEGIN
  ApplyToEditor;
END;

PROCEDURE TCodeEditorSettingsDialog.ButtonImportClick(Sender: TObject);
VAR
  V                 : TCodeEditorSettingsValues;
BEGIN
  IF NOT OpenDialog.Execute(Handle) THEN
    Exit;
  V := ControlsToValues;
  FSettings.LoadValuesFromFile(OpenDialog.FileName, V);
  ValuesToControls(V);
END;

PROCEDURE TCodeEditorSettingsDialog.ButtonExportClick(Sender: TObject);
BEGIN
  IF NOT SaveDialog.Execute(Handle) THEN
    Exit;
  FSettings.SaveValuesToFile(SaveDialog.FileName, ControlsToValues);
END;

END.
