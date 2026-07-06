UNIT CodeEdit.TemplateEditorDlg;

INTERFACE

USES
  System.Classes,
  Vcl.Controls,
  Vcl.ExtCtrls,
  Vcl.Forms,
  Vcl.StdCtrls,
  CodeEdit.Editor,
  CodeEdit.Highlighter,
  CodeEdit.Templates;

TYPE
  // Dialog for creating and editing code templates. A regular designed form
  // (open the DFM in the IDE to restyle it), usable at runtime for end users
  // maintaining their own templates and at design time as the
  // TCodeTemplateProvider component editor. It edits a working copy; the
  // source collection is only updated when the user confirms with OK.
  TCodeTemplateEditorDialog = CLASS(TForm)
    PanelLeft: TPanel;
    FilterCombo: TComboBox;
    ListTemplates: TListBox;
    PanelListButtons: TPanel;
    ButtonAdd: TButton;
    ButtonDuplicate: TButton;
    ButtonDelete: TButton;
    SplitterMain: TSplitter;
    PanelRight: TPanel;
    PanelDetail: TPanel;
    LabelName: TLabel;
    EditName: TEdit;
    LabelLanguage: TLabel;
    ComboLanguage: TComboBox;
    LabelDescription: TLabel;
    EditDescription: TEdit;
    LabelCode: TLabel;
    CodeEditor: TCodeEditor;
    PanelBottom: TPanel;
    LabelHint: TLabel;
    ButtonOK: TButton;
    ButtonCancel: TButton;
    PROCEDURE FormCreate(Sender: TObject);
    PROCEDURE FormDestroy(Sender: TObject);
    PROCEDURE FilterComboChange(Sender: TObject);
    PROCEDURE ListTemplatesClick(Sender: TObject);
    PROCEDURE EditNameChange(Sender: TObject);
    PROCEDURE EditDescriptionChange(Sender: TObject);
    PROCEDURE ComboLanguageChange(Sender: TObject);
    PROCEDURE CodeEditorChange(Sender: TObject);
    PROCEDURE ButtonAddClick(Sender: TObject);
    PROCEDURE ButtonDuplicateClick(Sender: TObject);
    PROCEDURE ButtonDeleteClick(Sender: TObject);
  PRIVATE
    FTemplates: TCodeTemplates;
    FBuiltIn: TCodeTemplates;
    FHighlighters: TStringList;
    FLoading: Boolean;
    PROCEDURE RefreshLanguageLists;
    PROCEDURE RefreshList(SelectTemplate: TCodeTemplate);
    FUNCTION SelectedTemplate: TCodeTemplate;
    FUNCTION IsBuiltIn(Template: TCodeTemplate): Boolean;
    FUNCTION FilterLanguage: STRING;
    FUNCTION ListCaption(Template: TCodeTemplate): STRING;
    PROCEDURE UpdateHighlighter;
    PROCEDURE LoadSelection;
    PROCEDURE UpdateControlStates;
  PUBLIC
    // Shows the dialog for ATemplates; returns True (and applies the changes)
    // when the user confirms with OK.
    CLASS FUNCTION Execute(ATemplates: TCodeTemplates): Boolean; OVERLOAD;
    // Edits the provider's user template layer. The built-in Templates are
    // shown read-only for reference; Duplicate turns one into an editable
    // user template (same name = overrides the built-in). On OK the user
    // layer is written back and, when UserFileName is set, saved to disk.
    CLASS FUNCTION Execute(AProvider: TCodeTemplateProvider): Boolean; OVERLOAD;
  END;

IMPLEMENTATION

USES
  System.SysUtils;

{$R *.dfm}

CONST
  // Highlighters offered in the language picker and used for preview
  // highlighting inside the dialog.
  KnownHighlighters : ARRAY[0..8] OF TCodeHighlighterClass = (
    TDelphiCodeHighlighter,
    TJavaScriptCodeHighlighter,
    TSqlCodeHighlighter,
    TTungliCodeHighlighter,
    TBatchCodeHighlighter,
    TPowerShellCodeHighlighter,
    TIniCodeHighlighter,
    TYamlCodeHighlighter,
    TPythonCodeHighlighter
    );

  AllLanguagesCaption = '(all languages)';
  AnyLanguageCaption = '(any)';

  { TCodeTemplateEditorDialog }

PROCEDURE TCodeTemplateEditorDialog.FormCreate(Sender: TObject);
BEGIN
  FTemplates := TCodeTemplates.Create(Self);
  FBuiltIn := TCodeTemplates.Create(Self);
  FHighlighters := TStringList.Create;
  FHighlighters.CaseSensitive := False;
END;

PROCEDURE TCodeTemplateEditorDialog.FormDestroy(Sender: TObject);
BEGIN
  FHighlighters.Free;
END;

CLASS FUNCTION TCodeTemplateEditorDialog.Execute(ATemplates: TCodeTemplates): Boolean;
VAR
  Dialog            : TCodeTemplateEditorDialog;
BEGIN
  Dialog := TCodeTemplateEditorDialog.Create(Application);
  TRY
    Dialog.FTemplates.Assign(ATemplates);
    Dialog.RefreshLanguageLists;
    Dialog.RefreshList(NIL);
    Result := Dialog.ShowModal = mrOk;
    IF Result THEN
      ATemplates.Assign(Dialog.FTemplates);
  FINALLY
    Dialog.Free;
  END;
END;

CLASS FUNCTION TCodeTemplateEditorDialog.Execute(AProvider: TCodeTemplateProvider): Boolean;
VAR
  Dialog            : TCodeTemplateEditorDialog;
BEGIN
  Dialog := TCodeTemplateEditorDialog.Create(Application);
  TRY
    Dialog.FBuiltIn.Assign(AProvider.Templates);
    Dialog.FTemplates.Assign(AProvider.UserTemplates);
    Dialog.RefreshLanguageLists;
    Dialog.RefreshList(NIL);
    Result := Dialog.ShowModal = mrOk;
    IF Result THEN BEGIN
      AProvider.UserTemplates.Assign(Dialog.FTemplates);
      IF AProvider.UserFileName <> '' THEN
        AProvider.SaveUserTemplates;
    END;
  FINALLY
    Dialog.Free;
  END;
END;

PROCEDURE TCodeTemplateEditorDialog.RefreshLanguageLists;
VAR
  Languages         : TStringList;
  HighlighterClass  : TCodeHighlighterClass;
  Filter            : STRING;
  I                 : Integer;
BEGIN
  Languages := TStringList.Create;
  TRY
    Languages.CaseSensitive := False;
    Languages.Sorted := True;
    Languages.Duplicates := dupIgnore;
    FOR HighlighterClass IN KnownHighlighters DO
      Languages.Add(HighlighterClass.LanguageName);
    FOR I := 0 TO FTemplates.Count - 1 DO
      IF FTemplates[I].Language <> '' THEN
        Languages.Add(FTemplates[I].Language);
    FOR I := 0 TO FBuiltIn.Count - 1 DO
      IF FBuiltIn[I].Language <> '' THEN
        Languages.Add(FBuiltIn[I].Language);

    Filter := FilterCombo.Text;
    FilterCombo.Items.BeginUpdate;
    TRY
      FilterCombo.Items.Clear;
      FilterCombo.Items.Add(AllLanguagesCaption);
      FilterCombo.Items.AddStrings(Languages);
      I := FilterCombo.Items.IndexOf(Filter);
      IF I < 0 THEN
        I := 0;
      FilterCombo.ItemIndex := I;
    FINALLY
      FilterCombo.Items.EndUpdate;
    END;

    ComboLanguage.Items.BeginUpdate;
    TRY
      ComboLanguage.Items.Clear;
      ComboLanguage.Items.Add(AnyLanguageCaption);
      ComboLanguage.Items.AddStrings(Languages);
    FINALLY
      ComboLanguage.Items.EndUpdate;
    END;
  FINALLY
    Languages.Free;
  END;
END;

FUNCTION TCodeTemplateEditorDialog.FilterLanguage: STRING;
BEGIN
  IF FilterCombo.ItemIndex <= 0 THEN
    Result := ''
  ELSE
    Result := FilterCombo.Items[FilterCombo.ItemIndex];
END;

FUNCTION TCodeTemplateEditorDialog.ListCaption(Template: TCodeTemplate): STRING;
BEGIN
  Result := Template.Name;
  IF Result = '' THEN
    Result := '(unnamed)';
  IF Template.Language <> '' THEN
    Result := Result + '  [' + Template.Language + ']';
  IF Template.Description <> '' THEN
    Result := Result + '  - ' + Template.Description;
  IF IsBuiltIn(Template) THEN
    Result := Result + '  (built-in)';
END;

PROCEDURE TCodeTemplateEditorDialog.RefreshList(SelectTemplate: TCodeTemplate);
VAR
  I                 : Integer;
  Filter            : STRING;
  Template          : TCodeTemplate;
BEGIN
  Filter := FilterLanguage;
  ListTemplates.Items.BeginUpdate;
  TRY
    ListTemplates.Items.Clear;
    FOR I := 0 TO FTemplates.Count - 1 DO BEGIN
      Template := FTemplates[I];
      IF (Filter = '') OR SameText(Template.Language, Filter) THEN
        ListTemplates.Items.AddObject(ListCaption(Template), Template);
    END;
    FOR I := 0 TO FBuiltIn.Count - 1 DO BEGIN
      Template := FBuiltIn[I];
      IF (Filter = '') OR SameText(Template.Language, Filter) THEN
        ListTemplates.Items.AddObject(ListCaption(Template), Template);
    END;
  FINALLY
    ListTemplates.Items.EndUpdate;
  END;

  IF ListTemplates.Items.Count > 0 THEN BEGIN
    ListTemplates.ItemIndex := 0;
    IF Assigned(SelectTemplate) THEN BEGIN
      I := ListTemplates.Items.IndexOfObject(SelectTemplate);
      IF I >= 0 THEN
        ListTemplates.ItemIndex := I;
    END;
  END;
  LoadSelection;
END;

FUNCTION TCodeTemplateEditorDialog.SelectedTemplate: TCodeTemplate;
BEGIN
  IF ListTemplates.ItemIndex >= 0 THEN
    Result := TCodeTemplate(ListTemplates.Items.Objects[ListTemplates.ItemIndex])
  ELSE
    Result := NIL;
END;

FUNCTION TCodeTemplateEditorDialog.IsBuiltIn(Template: TCodeTemplate): Boolean;
BEGIN
  Result := Assigned(Template) AND (Template.Collection = FBuiltIn);
END;

PROCEDURE TCodeTemplateEditorDialog.UpdateHighlighter;
VAR
  Template          : TCodeTemplate;
  HighlighterClass  : TCodeHighlighterClass;
  I                 : Integer;
BEGIN
  Template := SelectedTemplate;
  CodeEditor.Highlighter := NIL;
  IF NOT Assigned(Template) OR (Template.Language = '') THEN
    Exit;

  I := FHighlighters.IndexOf(Template.Language);
  IF I >= 0 THEN BEGIN
    CodeEditor.Highlighter := TCustomCodeHighlighter(FHighlighters.Objects[I]);
    Exit;
  END;

  FOR HighlighterClass IN KnownHighlighters DO
    IF SameText(HighlighterClass.LanguageName, Template.Language) THEN BEGIN
      CodeEditor.Highlighter := HighlighterClass.Create(Self);
      FHighlighters.AddObject(Template.Language, CodeEditor.Highlighter);
      Exit;
    END;
END;

PROCEDURE TCodeTemplateEditorDialog.LoadSelection;
VAR
  Template          : TCodeTemplate;
BEGIN
  FLoading := True;
  TRY
    Template := SelectedTemplate;
    IF Assigned(Template) THEN BEGIN
      EditName.Text := Template.Name;
      EditDescription.Text := Template.Description;
      IF Template.Language = '' THEN
        ComboLanguage.Text := AnyLanguageCaption
      ELSE
        ComboLanguage.Text := Template.Language;
      CodeEditor.Lines.Assign(Template.Code);
    END ELSE BEGIN
      EditName.Text := '';
      EditDescription.Text := '';
      ComboLanguage.Text := '';
      CodeEditor.Lines.Clear;
    END;
    UpdateHighlighter;
  FINALLY
    FLoading := False;
  END;
  UpdateControlStates;
END;

PROCEDURE TCodeTemplateEditorDialog.UpdateControlStates;
VAR
  Template          : TCodeTemplate;
  Editable          : Boolean;
BEGIN
  Template := SelectedTemplate;
  // Built-in templates are reference-only: read them, duplicate them into
  // the user layer, but never edit or delete them here.
  Editable := Assigned(Template) AND NOT IsBuiltIn(Template);
  EditName.Enabled := Editable;
  EditDescription.Enabled := Editable;
  ComboLanguage.Enabled := Editable;
  CodeEditor.Enabled := Assigned(Template);
  CodeEditor.ReadOnly := NOT Editable;
  ButtonDuplicate.Enabled := Assigned(Template);
  ButtonDelete.Enabled := Editable;
END;

PROCEDURE TCodeTemplateEditorDialog.ListTemplatesClick(Sender: TObject);
BEGIN
  LoadSelection;
END;

PROCEDURE TCodeTemplateEditorDialog.FilterComboChange(Sender: TObject);
BEGIN
  RefreshList(SelectedTemplate);
END;

PROCEDURE TCodeTemplateEditorDialog.EditNameChange(Sender: TObject);
VAR
  Template          : TCodeTemplate;
BEGIN
  Template := SelectedTemplate;
  IF FLoading OR NOT Assigned(Template) OR IsBuiltIn(Template) THEN
    Exit;
  Template.Name := EditName.Text;
  ListTemplates.Items[ListTemplates.ItemIndex] := ListCaption(Template);
END;

PROCEDURE TCodeTemplateEditorDialog.EditDescriptionChange(Sender: TObject);
VAR
  Template          : TCodeTemplate;
BEGIN
  Template := SelectedTemplate;
  IF FLoading OR NOT Assigned(Template) OR IsBuiltIn(Template) THEN
    Exit;
  Template.Description := EditDescription.Text;
  ListTemplates.Items[ListTemplates.ItemIndex] := ListCaption(Template);
END;

PROCEDURE TCodeTemplateEditorDialog.ComboLanguageChange(Sender: TObject);
VAR
  Template          : TCodeTemplate;
BEGIN
  Template := SelectedTemplate;
  IF FLoading OR NOT Assigned(Template) OR IsBuiltIn(Template) THEN
    Exit;
  IF (ComboLanguage.Text = AnyLanguageCaption) OR (ComboLanguage.Text = '') THEN
    Template.Language := ''
  ELSE
    Template.Language := ComboLanguage.Text;
  ListTemplates.Items[ListTemplates.ItemIndex] := ListCaption(Template);
  UpdateHighlighter;
END;

PROCEDURE TCodeTemplateEditorDialog.CodeEditorChange(Sender: TObject);
VAR
  Template          : TCodeTemplate;
BEGIN
  Template := SelectedTemplate;
  IF FLoading OR NOT Assigned(Template) OR IsBuiltIn(Template) THEN
    Exit;
  Template.Code.Assign(CodeEditor.Lines);
END;

PROCEDURE TCodeTemplateEditorDialog.ButtonAddClick(Sender: TObject);
VAR
  Template          : TCodeTemplate;
BEGIN
  Template := FTemplates.Add;
  Template.Language := FilterLanguage;
  RefreshLanguageLists;
  RefreshList(Template);
  EditName.SetFocus;
END;

PROCEDURE TCodeTemplateEditorDialog.ButtonDuplicateClick(Sender: TObject);
VAR
  Source            : TCodeTemplate;
  Template          : TCodeTemplate;
BEGIN
  Source := SelectedTemplate;
  IF NOT Assigned(Source) THEN
    Exit;
  Template := FTemplates.Add;
  Template.Assign(Source);
  // Duplicating a built-in keeps its name: the user copy overrides it. A
  // user-template duplicate needs a fresh name to avoid clashing.
  IF NOT IsBuiltIn(Source) THEN
    Template.Name := Source.Name + ' copy';
  RefreshList(Template);
  EditName.SetFocus;
END;

PROCEDURE TCodeTemplateEditorDialog.ButtonDeleteClick(Sender: TObject);
VAR
  Template          : TCodeTemplate;
BEGIN
  Template := SelectedTemplate;
  IF NOT Assigned(Template) OR IsBuiltIn(Template) THEN
    Exit;
  Template.Free;
  RefreshList(NIL);
END;

END.

