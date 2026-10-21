UNIT CodeEdit.SettingsDlgDX;

{ The editor options dialog built from DevExpress controls, so it follows the
  application's skin controller like the rest of a DevExpress UI (the
  package's own CodeEdit.SettingsDlg uses plain VCL controls, which skins
  only partly paint). Deliberately NOT in the CodeEditVcl package - add the
  unit to applications that use DevExpress; its initialization section makes
  TCodeEditorSettings.Execute open this dialog instead of the VCL one.

  Behaviour mirrors CodeEdit.SettingsDlg: pages for Editing, Display, Font
  and Colours, a live preview, Import/Export, OK/Apply saving when
  RegistryPath is set, VisibleItems hiding items and pages, registered theme
  sources (e.g. "Follow the DevExpress skin") in the colour mode box. }

INTERFACE

USES
  System.Classes,
  Vcl.Controls,
  Vcl.Dialogs,
  Vcl.Forms,
  Vcl.Graphics,
  cxGraphics, cxControls, cxLookAndFeels, cxLookAndFeelPainters, cxContainer, cxEdit,
  cxTextEdit, cxMaskEdit, cxDropDownEdit, cxSpinEdit, cxCheckBox, cxColorComboBox,
  cxButtons, cxLabel, cxGroupBox, cxPC,
  CodeEdit.Editor,
  CodeEdit.Settings;

TYPE
  TCodeEditorSettingsDialogDX = CLASS(TForm)
    PageControl: TcxPageControl;
    TabEditing: TcxTabSheet;
    LabelTabSize: TcxLabel;
    SpinTabSize: TcxSpinEdit;
    CheckBracketMatching: TcxCheckBox;
    LabelCommentPrefix: TcxLabel;
    EditCommentPrefix: TcxTextEdit;
    LabelMaxPaste: TcxLabel;
    SpinMaxPaste: TcxSpinEdit;
    TabDisplay: TcxTabSheet;
    CheckShowGutter: TcxCheckBox;
    CheckStyledScrollBars: TcxCheckBox;
    LabelScrollBars: TcxLabel;
    ComboScrollBars: TcxComboBox;
    CheckWordWrap: TcxCheckBox;
    CheckWrapIndent: TcxCheckBox;
    CheckShowMinimap: TcxCheckBox;
    CheckMinimapPreview: TcxCheckBox;
    LabelMinimapStyle: TcxLabel;
    ComboMinimapStyle: TcxComboBox;
    LabelMinimapRowHeight: TcxLabel;
    SpinMinimapRowHeight: TcxSpinEdit;
    CheckThemeSyntaxColors: TcxCheckBox;
    LabelZoom: TcxLabel;
    SpinZoom: TcxSpinEdit;
    TabFont: TcxTabSheet;
    LabelFontCaption: TcxLabel;
    LabelFont: TcxLabel;
    ButtonFont: TcxButton;
    LabelFontNote: TcxLabel;
    TabColours: TcxTabSheet;
    LabelThemeMode: TcxLabel;
    ComboThemeMode: TcxComboBox;
    LabelBackground: TcxLabel;
    ColorBackground: TcxColorComboBox;
    LabelText: TcxLabel;
    ColorText: TcxColorComboBox;
    LabelGutterBackground: TcxLabel;
    ColorGutterBackground: TcxColorComboBox;
    LabelGutterText: TcxLabel;
    ColorGutterText: TcxColorComboBox;
    LabelGutterBorder: TcxLabel;
    ColorGutterBorder: TcxColorComboBox;
    LabelSelectionBackground: TcxLabel;
    ColorSelectionBackground: TcxColorComboBox;
    LabelSelectionText: TcxLabel;
    ColorSelectionText: TcxColorComboBox;
    LabelPreview: TcxLabel;
    PreviewEditor: TCodeEditor;
    PanelBottom: TcxGroupBox;
    ButtonImport: TcxButton;
    ButtonExport: TcxButton;
    ButtonOK: TcxButton;
    ButtonCancel: TcxButton;
    ButtonApply: TcxButton;
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

FUNCTION ExecuteDX(Settings: TCodeEditorSettings): Boolean;
BEGIN
  Result := TCodeEditorSettingsDialogDX.Execute(Settings);
END;

CLASS FUNCTION TCodeEditorSettingsDialogDX.Execute(ASettings: TCodeEditorSettings): Boolean;
VAR
  Dlg               : TCodeEditorSettingsDialogDX;
BEGIN
  Dlg := TCodeEditorSettingsDialogDX.Create(NIL);
  TRY
    Dlg.Prepare(ASettings);
    Result := Dlg.ShowModal = mrOk;
  FINALLY
    Dlg.Free;
  END;
END;

PROCEDURE TCodeEditorSettingsDialogDX.FormCreate(Sender: TObject);
BEGIN
  FFont := TFont.Create;
  PreviewEditor.ReadOnly := True;
END;

PROCEDURE TCodeEditorSettingsDialogDX.FormDestroy(Sender: TObject);
BEGIN
  FFont.Free;
END;

PROCEDURE TCodeEditorSettingsDialogDX.Prepare(ASettings: TCodeEditorSettings);
VAR
  I                 : Integer;
  Count             : Integer;
BEGIN
  FSettings := ASettings;
  IF FSettings.Title <> '' THEN
    Caption := FSettings.Title;

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

PROCEDURE TCodeEditorSettingsDialogDX.PopulateThemeModes;
VAR
  I                 : Integer;
BEGIN
  WHILE ComboThemeMode.Properties.Items.Count > 2 DO
    ComboThemeMode.Properties.Items.Delete(ComboThemeMode.Properties.Items.Count - 1);
  FOR I := 0 TO CodeEditorThemeSourceCount - 1 DO
    ComboThemeMode.Properties.Items.Add(CodeEditorThemeSources(I).Caption);
END;

PROCEDURE TCodeEditorSettingsDialogDX.ApplyVisibility;
VAR
  Items             : TCodeEditorSettingItems;

  PROCEDURE Show(Control: TControl; Item: TCodeEditorSettingItem);
  BEGIN
    Control.Visible := Item IN Items;
  END;

BEGIN
  Items := FSettings.VisibleItems;

  Show(LabelTabSize, siTabSize);
  Show(SpinTabSize, siTabSize);
  Show(CheckBracketMatching, siBracketMatching);
  Show(LabelCommentPrefix, siLineCommentPrefix);
  Show(EditCommentPrefix, siLineCommentPrefix);
  Show(LabelMaxPaste, siMaxPasteBytes);
  Show(SpinMaxPaste, siMaxPasteBytes);
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
  Show(SpinMinimapRowHeight, siMinimapRowHeight);
  Show(CheckThemeSyntaxColors, siThemeSyntaxColors);
  Show(LabelZoom, siZoom);
  Show(SpinZoom, siZoom);
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

// A colour the list doesn't know gets a custom entry so the box can show it.
PROCEDURE SetColorBox(Box: TcxColorComboBox; Value: TColor);
BEGIN
  IF Box.Properties.CustomColors.FindColorItem(Value) = NIL THEN
    Box.Properties.CustomColors.AddColor(Value, Format('$%.8x', [Value]));
  Box.ColorValue := Value;
END;

PROCEDURE TCodeEditorSettingsDialogDX.ValuesToControls(CONST V: TCodeEditorSettingsValues);
VAR
  I                 : Integer;
BEGIN
  FLoading := True;
  TRY
    SpinTabSize.Value := V.TabSize;
    CheckBracketMatching.Checked := V.BracketMatching;
    EditCommentPrefix.Text := V.LineCommentPrefix;
    SpinMaxPaste.Value := V.MaxPasteBytes DIV (1024 * 1024);

    CheckShowGutter.Checked := V.ShowGutter;
    CheckStyledScrollBars.Checked := V.StyledScrollBars;
    ComboScrollBars.ItemIndex := Ord(V.ScrollBars);
    CheckWordWrap.Checked := V.WordWrap;
    CheckWrapIndent.Checked := V.WrapIndent;
    CheckShowMinimap.Checked := V.ShowMinimap;
    CheckMinimapPreview.Checked := V.MinimapPreview;
    ComboMinimapStyle.ItemIndex := Ord(V.MinimapStyle);
    SpinMinimapRowHeight.Value := V.MinimapRowHeight;
    CheckThemeSyntaxColors.Checked := V.ThemeSyntaxColors;
    SpinZoom.Value := V.Zoom;

    FFont.Name := V.FontName;
    FFont.Size := V.FontSize;
    FFont.Style := V.FontStyle;
    UpdateFontLabel;

    ComboThemeMode.ItemIndex := Ord(V.ThemeMode);
    IF V.ThemeSource <> '' THEN
      FOR I := 0 TO CodeEditorThemeSourceCount - 1 DO
        IF SameText(CodeEditorThemeSources(I).Name, V.ThemeSource) THEN
          ComboThemeMode.ItemIndex := 2 + I;
    SetColorBox(ColorBackground, V.Background);
    SetColorBox(ColorText, V.Text);
    SetColorBox(ColorGutterBackground, V.GutterBackground);
    SetColorBox(ColorGutterText, V.GutterText);
    SetColorBox(ColorGutterBorder, V.GutterBorder);
    SetColorBox(ColorSelectionBackground, V.SelectionBackground);
    SetColorBox(ColorSelectionText, V.SelectionText);
    UpdateColourStates;
    UpdateDependentStates;
  FINALLY
    FLoading := False;
  END;
  UpdatePreview;
END;

FUNCTION TCodeEditorSettingsDialogDX.ControlsToValues: TCodeEditorSettingsValues;
VAR
  Items             : TCodeEditorSettingItems;

  FUNCTION Spin(Edit: TcxSpinEdit; Default: Integer): Integer;
  BEGIN
    Result := EnsureRange(StrToIntDef(Edit.Text, Default), Round(Edit.Properties.MinValue),
      Round(Edit.Properties.MaxValue));
  END;

BEGIN
  Result := FSettings.CurrentValues;
  Items := FSettings.VisibleItems;

  IF siTabSize IN Items THEN
    Result.TabSize := Spin(SpinTabSize, Result.TabSize);
  IF siBracketMatching IN Items THEN
    Result.BracketMatching := CheckBracketMatching.Checked;
  IF siLineCommentPrefix IN Items THEN
    Result.LineCommentPrefix := EditCommentPrefix.Text;
  IF siMaxPasteBytes IN Items THEN
    Result.MaxPasteBytes := Spin(SpinMaxPaste, Result.MaxPasteBytes DIV (1024 * 1024)) * 1024 * 1024;

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
    Result.MinimapRowHeight := Spin(SpinMinimapRowHeight, Result.MinimapRowHeight);
  IF siThemeSyntaxColors IN Items THEN
    Result.ThemeSyntaxColors := CheckThemeSyntaxColors.Checked;
  IF siZoom IN Items THEN
    Result.Zoom := Spin(SpinZoom, Result.Zoom);

  IF siFont IN Items THEN BEGIN
    Result.FontName := FFont.Name;
    Result.FontSize := FFont.Size;
    Result.FontStyle := FFont.Style;
  END;

  IF (siThemeMode IN Items) AND (ComboThemeMode.ItemIndex >= 0) THEN
    IF ComboThemeMode.ItemIndex >= 2 THEN BEGIN
      Result.ThemeSource := CodeEditorThemeSources(ComboThemeMode.ItemIndex - 2).Name;
      Result.ThemeMode := ctmManual;
    END ELSE BEGIN
      Result.ThemeSource := '';
      Result.ThemeMode := TCodeEditorThemeMode(ComboThemeMode.ItemIndex);
    END;
  IF siColours IN Items THEN BEGIN
    Result.Background := ColorBackground.ColorValue;
    Result.Text := ColorText.ColorValue;
    Result.GutterBackground := ColorGutterBackground.ColorValue;
    Result.GutterText := ColorGutterText.ColorValue;
    Result.GutterBorder := ColorGutterBorder.ColorValue;
    Result.SelectionBackground := ColorSelectionBackground.ColorValue;
    Result.SelectionText := ColorSelectionText.ColorValue;
  END;
END;

PROCEDURE TCodeEditorSettingsDialogDX.UpdateFontLabel;
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

PROCEDURE TCodeEditorSettingsDialogDX.UpdateColourStates;
VAR
  Manual            : Boolean;
BEGIN
  Manual := ComboThemeMode.ItemIndex = Ord(ctmManual);
  ColorBackground.Enabled := Manual;
  ColorText.Enabled := Manual;
  ColorGutterBackground.Enabled := Manual;
  ColorGutterText.Enabled := Manual;
  ColorGutterBorder.Enabled := Manual;
  ColorSelectionBackground.Enabled := Manual;
  ColorSelectionText.Enabled := Manual;
END;

PROCEDURE TCodeEditorSettingsDialogDX.UpdateDependentStates;
VAR
  Minimap           : Boolean;
BEGIN
  Minimap := CheckShowMinimap.Checked;
  CheckMinimapPreview.Enabled := Minimap;
  LabelMinimapStyle.Enabled := Minimap;
  ComboMinimapStyle.Enabled := Minimap;
  LabelMinimapRowHeight.Enabled := Minimap;
  SpinMinimapRowHeight.Enabled := Minimap;
  CheckWrapIndent.Enabled := CheckWordWrap.Checked;
END;

PROCEDURE TCodeEditorSettingsDialogDX.UpdatePreview;
BEGIN
  IF FLoading OR NOT Assigned(FSettings) THEN
    Exit;
  ControlsToValues.ApplyTo(PreviewEditor);
END;

PROCEDURE TCodeEditorSettingsDialogDX.ControlChanged(Sender: TObject);
BEGIN
  IF (Sender = CheckShowMinimap) OR (Sender = CheckWordWrap) THEN
    UpdateDependentStates;
  UpdatePreview;
END;

PROCEDURE TCodeEditorSettingsDialogDX.ComboThemeModeChange(Sender: TObject);
BEGIN
  UpdateColourStates;
  UpdatePreview;
END;

PROCEDURE TCodeEditorSettingsDialogDX.ButtonFontClick(Sender: TObject);
BEGIN
  FontDialog.Font.Assign(FFont);
  IF FontDialog.Execute(Handle) THEN BEGIN
    FFont.Assign(FontDialog.Font);
    UpdateFontLabel;
    UpdatePreview;
  END;
END;

PROCEDURE TCodeEditorSettingsDialogDX.ApplyToEditor;
BEGIN
  FSettings.ApplyValues(ControlsToValues);
  IF Trim(FSettings.RegistryPath) <> '' THEN
    FSettings.SaveSettings;
END;

PROCEDURE TCodeEditorSettingsDialogDX.ButtonOKClick(Sender: TObject);
BEGIN
  ApplyToEditor;
  ModalResult := mrOk;
END;

PROCEDURE TCodeEditorSettingsDialogDX.ButtonApplyClick(Sender: TObject);
BEGIN
  ApplyToEditor;
END;

PROCEDURE TCodeEditorSettingsDialogDX.ButtonImportClick(Sender: TObject);
VAR
  V                 : TCodeEditorSettingsValues;
BEGIN
  IF NOT OpenDialog.Execute(Handle) THEN
    Exit;
  V := ControlsToValues;
  FSettings.LoadValuesFromFile(OpenDialog.FileName, V);
  ValuesToControls(V);
END;

PROCEDURE TCodeEditorSettingsDialogDX.ButtonExportClick(Sender: TObject);
BEGIN
  IF NOT SaveDialog.Execute(Handle) THEN
    Exit;
  FSettings.SaveValuesToFile(SaveDialog.FileName, ControlsToValues);
END;

INITIALIZATION
  CodeEditorSettingsDialogProc := ExecuteDX;

FINALIZATION
  IF @CodeEditorSettingsDialogProc = @ExecuteDX THEN
    CodeEditorSettingsDialogProc := NIL;

END.
