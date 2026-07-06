unit CodeEdit.TemplateEditorDlg;

interface

uses
  System.Classes,
  Vcl.Controls,
  Vcl.ExtCtrls,
  Vcl.Forms,
  Vcl.StdCtrls,
  CodeEdit.Editor,
  CodeEdit.Highlighter,
  CodeEdit.Templates;

type
  // Dialog for creating and editing code templates. A regular designed form
  // (open the DFM in the IDE to restyle it), usable at runtime for end users
  // maintaining their own templates and at design time as the
  // TCodeTemplateProvider component editor. It edits a working copy; the
  // source collection is only updated when the user confirms with OK.
  TCodeTemplateEditorDialog = class(TForm)
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
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FilterComboChange(Sender: TObject);
    procedure ListTemplatesClick(Sender: TObject);
    procedure EditNameChange(Sender: TObject);
    procedure EditDescriptionChange(Sender: TObject);
    procedure ComboLanguageChange(Sender: TObject);
    procedure CodeEditorChange(Sender: TObject);
    procedure ButtonAddClick(Sender: TObject);
    procedure ButtonDuplicateClick(Sender: TObject);
    procedure ButtonDeleteClick(Sender: TObject);
  private
    FTemplates: TCodeTemplates;
    FHighlighters: TStringList;
    FLoading: Boolean;
    procedure RefreshLanguageLists;
    procedure RefreshList(SelectTemplate: TCodeTemplate);
    function SelectedTemplate: TCodeTemplate;
    function FilterLanguage: string;
    function ListCaption(Template: TCodeTemplate): string;
    procedure UpdateHighlighter;
    procedure LoadSelection;
    procedure UpdateControlStates;
  public
    // Shows the dialog for ATemplates; returns True (and applies the changes)
    // when the user confirms with OK.
    class function Execute(ATemplates: TCodeTemplates): Boolean; overload;
    class function Execute(AProvider: TCodeTemplateProvider): Boolean; overload;
  end;

implementation

uses
  System.SysUtils;

{$R *.dfm}

const
  // Highlighters offered in the language picker and used for preview
  // highlighting inside the dialog.
  KnownHighlighters: array[0..8] of TCodeHighlighterClass = (
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

procedure TCodeTemplateEditorDialog.FormCreate(Sender: TObject);
begin
  FTemplates := TCodeTemplates.Create(Self);
  FHighlighters := TStringList.Create;
  FHighlighters.CaseSensitive := False;
end;

procedure TCodeTemplateEditorDialog.FormDestroy(Sender: TObject);
begin
  FHighlighters.Free;
end;

class function TCodeTemplateEditorDialog.Execute(ATemplates: TCodeTemplates): Boolean;
var
  Dialog: TCodeTemplateEditorDialog;
begin
  Dialog := TCodeTemplateEditorDialog.Create(Application);
  try
    Dialog.FTemplates.Assign(ATemplates);
    Dialog.RefreshLanguageLists;
    Dialog.RefreshList(nil);
    Result := Dialog.ShowModal = mrOk;
    if Result then
      ATemplates.Assign(Dialog.FTemplates);
  finally
    Dialog.Free;
  end;
end;

class function TCodeTemplateEditorDialog.Execute(AProvider: TCodeTemplateProvider): Boolean;
begin
  Result := Execute(AProvider.Templates);
end;

procedure TCodeTemplateEditorDialog.RefreshLanguageLists;
var
  Languages: TStringList;
  HighlighterClass: TCodeHighlighterClass;
  Filter: string;
  I: Integer;
begin
  Languages := TStringList.Create;
  try
    Languages.CaseSensitive := False;
    Languages.Sorted := True;
    Languages.Duplicates := dupIgnore;
    for HighlighterClass in KnownHighlighters do
      Languages.Add(HighlighterClass.LanguageName);
    for I := 0 to FTemplates.Count - 1 do
      if FTemplates[I].Language <> '' then
        Languages.Add(FTemplates[I].Language);

    Filter := FilterCombo.Text;
    FilterCombo.Items.BeginUpdate;
    try
      FilterCombo.Items.Clear;
      FilterCombo.Items.Add(AllLanguagesCaption);
      FilterCombo.Items.AddStrings(Languages);
      I := FilterCombo.Items.IndexOf(Filter);
      if I < 0 then
        I := 0;
      FilterCombo.ItemIndex := I;
    finally
      FilterCombo.Items.EndUpdate;
    end;

    ComboLanguage.Items.BeginUpdate;
    try
      ComboLanguage.Items.Clear;
      ComboLanguage.Items.Add(AnyLanguageCaption);
      ComboLanguage.Items.AddStrings(Languages);
    finally
      ComboLanguage.Items.EndUpdate;
    end;
  finally
    Languages.Free;
  end;
end;

function TCodeTemplateEditorDialog.FilterLanguage: string;
begin
  if FilterCombo.ItemIndex <= 0 then
    Result := ''
  else
    Result := FilterCombo.Items[FilterCombo.ItemIndex];
end;

function TCodeTemplateEditorDialog.ListCaption(Template: TCodeTemplate): string;
begin
  Result := Template.Name;
  if Result = '' then
    Result := '(unnamed)';
  if Template.Language <> '' then
    Result := Result + '  [' + Template.Language + ']';
  if Template.Description <> '' then
    Result := Result + '  - ' + Template.Description;
end;

procedure TCodeTemplateEditorDialog.RefreshList(SelectTemplate: TCodeTemplate);
var
  I: Integer;
  Filter: string;
  Template: TCodeTemplate;
begin
  Filter := FilterLanguage;
  ListTemplates.Items.BeginUpdate;
  try
    ListTemplates.Items.Clear;
    for I := 0 to FTemplates.Count - 1 do
    begin
      Template := FTemplates[I];
      if (Filter = '') or SameText(Template.Language, Filter) then
        ListTemplates.Items.AddObject(ListCaption(Template), Template);
    end;
  finally
    ListTemplates.Items.EndUpdate;
  end;

  if ListTemplates.Items.Count > 0 then
  begin
    ListTemplates.ItemIndex := 0;
    if Assigned(SelectTemplate) then
    begin
      I := ListTemplates.Items.IndexOfObject(SelectTemplate);
      if I >= 0 then
        ListTemplates.ItemIndex := I;
    end;
  end;
  LoadSelection;
end;

function TCodeTemplateEditorDialog.SelectedTemplate: TCodeTemplate;
begin
  if ListTemplates.ItemIndex >= 0 then
    Result := TCodeTemplate(ListTemplates.Items.Objects[ListTemplates.ItemIndex])
  else
    Result := nil;
end;

procedure TCodeTemplateEditorDialog.UpdateHighlighter;
var
  Template: TCodeTemplate;
  HighlighterClass: TCodeHighlighterClass;
  I: Integer;
begin
  Template := SelectedTemplate;
  CodeEditor.Highlighter := nil;
  if not Assigned(Template) or (Template.Language = '') then
    Exit;

  I := FHighlighters.IndexOf(Template.Language);
  if I >= 0 then
  begin
    CodeEditor.Highlighter := TCustomCodeHighlighter(FHighlighters.Objects[I]);
    Exit;
  end;

  for HighlighterClass in KnownHighlighters do
    if SameText(HighlighterClass.LanguageName, Template.Language) then
    begin
      CodeEditor.Highlighter := HighlighterClass.Create(Self);
      FHighlighters.AddObject(Template.Language, CodeEditor.Highlighter);
      Exit;
    end;
end;

procedure TCodeTemplateEditorDialog.LoadSelection;
var
  Template: TCodeTemplate;
begin
  FLoading := True;
  try
    Template := SelectedTemplate;
    if Assigned(Template) then
    begin
      EditName.Text := Template.Name;
      EditDescription.Text := Template.Description;
      if Template.Language = '' then
        ComboLanguage.Text := AnyLanguageCaption
      else
        ComboLanguage.Text := Template.Language;
      CodeEditor.Lines.Assign(Template.Code);
    end
    else
    begin
      EditName.Text := '';
      EditDescription.Text := '';
      ComboLanguage.Text := '';
      CodeEditor.Lines.Clear;
    end;
    UpdateHighlighter;
  finally
    FLoading := False;
  end;
  UpdateControlStates;
end;

procedure TCodeTemplateEditorDialog.UpdateControlStates;
var
  HasSelection: Boolean;
begin
  HasSelection := SelectedTemplate <> nil;
  EditName.Enabled := HasSelection;
  EditDescription.Enabled := HasSelection;
  ComboLanguage.Enabled := HasSelection;
  CodeEditor.Enabled := HasSelection;
  CodeEditor.ReadOnly := not HasSelection;
  ButtonDuplicate.Enabled := HasSelection;
  ButtonDelete.Enabled := HasSelection;
end;

procedure TCodeTemplateEditorDialog.ListTemplatesClick(Sender: TObject);
begin
  LoadSelection;
end;

procedure TCodeTemplateEditorDialog.FilterComboChange(Sender: TObject);
begin
  RefreshList(SelectedTemplate);
end;

procedure TCodeTemplateEditorDialog.EditNameChange(Sender: TObject);
var
  Template: TCodeTemplate;
begin
  Template := SelectedTemplate;
  if FLoading or not Assigned(Template) then
    Exit;
  Template.Name := EditName.Text;
  ListTemplates.Items[ListTemplates.ItemIndex] := ListCaption(Template);
end;

procedure TCodeTemplateEditorDialog.EditDescriptionChange(Sender: TObject);
var
  Template: TCodeTemplate;
begin
  Template := SelectedTemplate;
  if FLoading or not Assigned(Template) then
    Exit;
  Template.Description := EditDescription.Text;
  ListTemplates.Items[ListTemplates.ItemIndex] := ListCaption(Template);
end;

procedure TCodeTemplateEditorDialog.ComboLanguageChange(Sender: TObject);
var
  Template: TCodeTemplate;
begin
  Template := SelectedTemplate;
  if FLoading or not Assigned(Template) then
    Exit;
  if (ComboLanguage.Text = AnyLanguageCaption) or (ComboLanguage.Text = '') then
    Template.Language := ''
  else
    Template.Language := ComboLanguage.Text;
  ListTemplates.Items[ListTemplates.ItemIndex] := ListCaption(Template);
  UpdateHighlighter;
end;

procedure TCodeTemplateEditorDialog.CodeEditorChange(Sender: TObject);
var
  Template: TCodeTemplate;
begin
  Template := SelectedTemplate;
  if FLoading or not Assigned(Template) then
    Exit;
  Template.Code.Assign(CodeEditor.Lines);
end;

procedure TCodeTemplateEditorDialog.ButtonAddClick(Sender: TObject);
var
  Template: TCodeTemplate;
begin
  Template := FTemplates.Add;
  Template.Language := FilterLanguage;
  RefreshLanguageLists;
  RefreshList(Template);
  EditName.SetFocus;
end;

procedure TCodeTemplateEditorDialog.ButtonDuplicateClick(Sender: TObject);
var
  Source: TCodeTemplate;
  Template: TCodeTemplate;
begin
  Source := SelectedTemplate;
  if not Assigned(Source) then
    Exit;
  Template := FTemplates.Add;
  Template.Assign(Source);
  Template.Name := Source.Name + ' copy';
  RefreshList(Template);
  EditName.SetFocus;
end;

procedure TCodeTemplateEditorDialog.ButtonDeleteClick(Sender: TObject);
var
  Template: TCodeTemplate;
begin
  Template := SelectedTemplate;
  if not Assigned(Template) then
    Exit;
  Template.Free;
  RefreshList(nil);
end;

end.
