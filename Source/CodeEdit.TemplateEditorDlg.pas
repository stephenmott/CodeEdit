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
  // Dialog for creating and editing code templates, built entirely in code so
  // it works the same at runtime (end users maintaining their own templates)
  // and at design time (component editor). It edits a working copy; the
  // source collection is only updated when the user confirms with OK.
  TCodeTemplateEditorDialog = class(TForm)
  private
    FTemplates: TCodeTemplates;
    FHighlighters: TStringList;
    FFilterCombo: TComboBox;
    FList: TListBox;
    FAddButton: TButton;
    FDuplicateButton: TButton;
    FDeleteButton: TButton;
    FNameEdit: TEdit;
    FDescriptionEdit: TEdit;
    FLanguageCombo: TComboBox;
    FCodeEditor: TCodeEditor;
    FOkButton: TButton;
    FCancelButton: TButton;
    FLoading: Boolean;
    procedure BuildLayout;
    procedure RefreshLanguageLists;
    procedure RefreshList(SelectTemplate: TCodeTemplate);
    function SelectedTemplate: TCodeTemplate;
    function FilterLanguage: string;
    function ListCaption(Template: TCodeTemplate): string;
    procedure UpdateHighlighter;
    procedure LoadSelection;
    procedure UpdateControlStates;
    procedure ListClick(Sender: TObject);
    procedure FilterChanged(Sender: TObject);
    procedure NameChanged(Sender: TObject);
    procedure DescriptionChanged(Sender: TObject);
    procedure LanguageChanged(Sender: TObject);
    procedure CodeChanged(Sender: TObject);
    procedure AddClick(Sender: TObject);
    procedure DuplicateClick(Sender: TObject);
    procedure DeleteClick(Sender: TObject);
  public
    constructor CreateNew(AOwner: TComponent; Dummy: Integer = 0); override;
    destructor Destroy; override;
    // Shows the dialog for ATemplates; returns True (and applies the changes)
    // when the user confirms with OK.
    class function Execute(ATemplates: TCodeTemplates): Boolean; overload;
    class function Execute(AProvider: TCodeTemplateProvider): Boolean; overload;
  end;

implementation

uses
  System.SysUtils;

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

constructor TCodeTemplateEditorDialog.CreateNew(AOwner: TComponent; Dummy: Integer);
begin
  inherited;
  FTemplates := TCodeTemplates.Create(Self);
  FHighlighters := TStringList.Create;
  FHighlighters.CaseSensitive := False;
  BuildLayout;
end;

destructor TCodeTemplateEditorDialog.Destroy;
begin
  FHighlighters.Free;
  inherited;
end;

procedure TCodeTemplateEditorDialog.BuildLayout;
var
  LeftPanel: TPanel;
  ListButtons: TPanel;
  RightPanel: TPanel;
  DetailPanel: TPanel;
  BottomPanel: TPanel;
  HintLabel: TLabel;

  function NewLabel(Parent: TWinControl; const Caption: string; ALeft, ATop: Integer): TLabel;
  begin
    Result := TLabel.Create(Self);
    Result.Parent := Parent;
    Result.Caption := Caption;
    Result.SetBounds(ALeft, ATop, Result.Width, Result.Height);
  end;

  function NewButton(Parent: TWinControl; const Caption: string; OnClickHandler: TNotifyEvent): TButton;
  begin
    Result := TButton.Create(Self);
    Result.Parent := Parent;
    Result.Caption := Caption;
    Result.OnClick := OnClickHandler;
  end;

begin
  Caption := 'Code Templates';
  BorderStyle := bsSizeable;
  BorderIcons := [biSystemMenu, biMaximize];
  Position := poScreenCenter;
  Font.Name := 'Segoe UI';
  Font.Size := 9;
  ClientWidth := 820;
  ClientHeight := 540;
  Constraints.MinWidth := 640;
  Constraints.MinHeight := 420;

  // Bottom bar: hint on the left, OK/Cancel on the right.
  BottomPanel := TPanel.Create(Self);
  BottomPanel.Parent := Self;
  BottomPanel.Align := alBottom;
  BottomPanel.Height := 44;
  BottomPanel.BevelOuter := bvNone;

  FOkButton := NewButton(BottomPanel, 'OK', nil);
  FOkButton.ModalResult := mrOk;
  FOkButton.SetBounds(BottomPanel.Width - 176, 10, 80, 26);
  FOkButton.Anchors := [akRight, akBottom];

  FCancelButton := NewButton(BottomPanel, 'Cancel', nil);
  FCancelButton.ModalResult := mrCancel;
  FCancelButton.Cancel := True;
  FCancelButton.SetBounds(BottomPanel.Width - 88, 10, 80, 26);
  FCancelButton.Anchors := [akRight, akBottom];

  HintLabel := NewLabel(BottomPanel, 'Use | in the code to mark where the caret lands after insertion; use || for a literal |.', 12, 14);
  HintLabel.Anchors := [akLeft, akBottom];

  // Left side: language filter, template list, list-management buttons.
  LeftPanel := TPanel.Create(Self);
  LeftPanel.Parent := Self;
  LeftPanel.Align := alLeft;
  LeftPanel.Width := 280;
  LeftPanel.BevelOuter := bvNone;
  LeftPanel.AlignWithMargins := True;
  LeftPanel.Margins.SetBounds(8, 8, 0, 0);

  FFilterCombo := TComboBox.Create(Self);
  FFilterCombo.Parent := LeftPanel;
  FFilterCombo.Align := alTop;
  FFilterCombo.Style := csDropDownList;
  FFilterCombo.OnChange := FilterChanged;

  ListButtons := TPanel.Create(Self);
  ListButtons.Parent := LeftPanel;
  ListButtons.Align := alBottom;
  ListButtons.Height := 34;
  ListButtons.BevelOuter := bvNone;

  FAddButton := NewButton(ListButtons, 'Add', AddClick);
  FAddButton.SetBounds(0, 6, 86, 26);
  FDuplicateButton := NewButton(ListButtons, 'Duplicate', DuplicateClick);
  FDuplicateButton.SetBounds(94, 6, 86, 26);
  FDeleteButton := NewButton(ListButtons, 'Delete', DeleteClick);
  FDeleteButton.SetBounds(188, 6, 86, 26);

  FList := TListBox.Create(Self);
  FList.Parent := LeftPanel;
  FList.Align := alClient;
  FList.AlignWithMargins := True;
  FList.Margins.SetBounds(0, 6, 0, 0);
  FList.OnClick := ListClick;

  // Right side: template properties above the code. A container keeps the
  // alTop detail panel from spanning across the alLeft list column.
  RightPanel := TPanel.Create(Self);
  RightPanel.Parent := Self;
  RightPanel.Align := alClient;
  RightPanel.BevelOuter := bvNone;

  DetailPanel := TPanel.Create(Self);
  DetailPanel.Parent := RightPanel;
  DetailPanel.Align := alTop;
  DetailPanel.Height := 92;
  DetailPanel.BevelOuter := bvNone;

  NewLabel(DetailPanel, 'Name:', 12, 12);
  FNameEdit := TEdit.Create(Self);
  FNameEdit.Parent := DetailPanel;
  FNameEdit.SetBounds(90, 8, 200, FNameEdit.Height);
  FNameEdit.OnChange := NameChanged;

  NewLabel(DetailPanel, 'Language:', 306, 12);
  FLanguageCombo := TComboBox.Create(Self);
  FLanguageCombo.Parent := DetailPanel;
  FLanguageCombo.SetBounds(370, 8, 160, FLanguageCombo.Height);
  FLanguageCombo.Style := csDropDown;
  FLanguageCombo.OnChange := LanguageChanged;

  NewLabel(DetailPanel, 'Description:', 12, 44);
  FDescriptionEdit := TEdit.Create(Self);
  FDescriptionEdit.Parent := DetailPanel;
  FDescriptionEdit.SetBounds(90, 40, 440, FDescriptionEdit.Height);
  FDescriptionEdit.Anchors := [akLeft, akTop, akRight];
  FDescriptionEdit.OnChange := DescriptionChanged;

  NewLabel(DetailPanel, 'Code:', 12, 72);

  FCodeEditor := TCodeEditor.Create(Self);
  FCodeEditor.Parent := RightPanel;
  FCodeEditor.Align := alClient;
  FCodeEditor.AlignWithMargins := True;
  FCodeEditor.Margins.SetBounds(8, 0, 8, 0);
  FCodeEditor.Options.ShowMinimap := False;
  FCodeEditor.OnChange := CodeChanged;

  ActiveControl := FList;
end;

class function TCodeTemplateEditorDialog.Execute(ATemplates: TCodeTemplates): Boolean;
var
  Dialog: TCodeTemplateEditorDialog;
begin
  Dialog := TCodeTemplateEditorDialog.CreateNew(Application);
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

    Filter := FFilterCombo.Text;
    FFilterCombo.Items.BeginUpdate;
    try
      FFilterCombo.Items.Clear;
      FFilterCombo.Items.Add(AllLanguagesCaption);
      FFilterCombo.Items.AddStrings(Languages);
      I := FFilterCombo.Items.IndexOf(Filter);
      if I < 0 then
        I := 0;
      FFilterCombo.ItemIndex := I;
    finally
      FFilterCombo.Items.EndUpdate;
    end;

    FLanguageCombo.Items.BeginUpdate;
    try
      FLanguageCombo.Items.Clear;
      FLanguageCombo.Items.Add(AnyLanguageCaption);
      FLanguageCombo.Items.AddStrings(Languages);
    finally
      FLanguageCombo.Items.EndUpdate;
    end;
  finally
    Languages.Free;
  end;
end;

function TCodeTemplateEditorDialog.FilterLanguage: string;
begin
  if FFilterCombo.ItemIndex <= 0 then
    Result := ''
  else
    Result := FFilterCombo.Items[FFilterCombo.ItemIndex];
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
  FList.Items.BeginUpdate;
  try
    FList.Items.Clear;
    for I := 0 to FTemplates.Count - 1 do
    begin
      Template := FTemplates[I];
      if (Filter = '') or SameText(Template.Language, Filter) then
        FList.Items.AddObject(ListCaption(Template), Template);
    end;
  finally
    FList.Items.EndUpdate;
  end;

  if FList.Items.Count > 0 then
  begin
    FList.ItemIndex := 0;
    if Assigned(SelectTemplate) then
    begin
      I := FList.Items.IndexOfObject(SelectTemplate);
      if I >= 0 then
        FList.ItemIndex := I;
    end;
  end;
  LoadSelection;
end;

function TCodeTemplateEditorDialog.SelectedTemplate: TCodeTemplate;
begin
  if FList.ItemIndex >= 0 then
    Result := TCodeTemplate(FList.Items.Objects[FList.ItemIndex])
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
  FCodeEditor.Highlighter := nil;
  if not Assigned(Template) or (Template.Language = '') then
    Exit;

  I := FHighlighters.IndexOf(Template.Language);
  if I >= 0 then
  begin
    FCodeEditor.Highlighter := TCustomCodeHighlighter(FHighlighters.Objects[I]);
    Exit;
  end;

  for HighlighterClass in KnownHighlighters do
    if SameText(HighlighterClass.LanguageName, Template.Language) then
    begin
      FCodeEditor.Highlighter := HighlighterClass.Create(Self);
      FHighlighters.AddObject(Template.Language, FCodeEditor.Highlighter);
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
      FNameEdit.Text := Template.Name;
      FDescriptionEdit.Text := Template.Description;
      if Template.Language = '' then
        FLanguageCombo.Text := AnyLanguageCaption
      else
        FLanguageCombo.Text := Template.Language;
      FCodeEditor.Lines.Assign(Template.Code);
    end
    else
    begin
      FNameEdit.Text := '';
      FDescriptionEdit.Text := '';
      FLanguageCombo.Text := '';
      FCodeEditor.Lines.Clear;
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
  FNameEdit.Enabled := HasSelection;
  FDescriptionEdit.Enabled := HasSelection;
  FLanguageCombo.Enabled := HasSelection;
  FCodeEditor.Enabled := HasSelection;
  FCodeEditor.ReadOnly := not HasSelection;
  FDuplicateButton.Enabled := HasSelection;
  FDeleteButton.Enabled := HasSelection;
end;

procedure TCodeTemplateEditorDialog.ListClick(Sender: TObject);
begin
  LoadSelection;
end;

procedure TCodeTemplateEditorDialog.FilterChanged(Sender: TObject);
begin
  RefreshList(SelectedTemplate);
end;

procedure TCodeTemplateEditorDialog.NameChanged(Sender: TObject);
var
  Template: TCodeTemplate;
begin
  Template := SelectedTemplate;
  if FLoading or not Assigned(Template) then
    Exit;
  Template.Name := FNameEdit.Text;
  FList.Items[FList.ItemIndex] := ListCaption(Template);
end;

procedure TCodeTemplateEditorDialog.DescriptionChanged(Sender: TObject);
var
  Template: TCodeTemplate;
begin
  Template := SelectedTemplate;
  if FLoading or not Assigned(Template) then
    Exit;
  Template.Description := FDescriptionEdit.Text;
  FList.Items[FList.ItemIndex] := ListCaption(Template);
end;

procedure TCodeTemplateEditorDialog.LanguageChanged(Sender: TObject);
var
  Template: TCodeTemplate;
begin
  Template := SelectedTemplate;
  if FLoading or not Assigned(Template) then
    Exit;
  if (FLanguageCombo.Text = AnyLanguageCaption) or (FLanguageCombo.Text = '') then
    Template.Language := ''
  else
    Template.Language := FLanguageCombo.Text;
  FList.Items[FList.ItemIndex] := ListCaption(Template);
  UpdateHighlighter;
end;

procedure TCodeTemplateEditorDialog.CodeChanged(Sender: TObject);
var
  Template: TCodeTemplate;
begin
  Template := SelectedTemplate;
  if FLoading or not Assigned(Template) then
    Exit;
  Template.Code.Assign(FCodeEditor.Lines);
end;

procedure TCodeTemplateEditorDialog.AddClick(Sender: TObject);
var
  Template: TCodeTemplate;
begin
  Template := FTemplates.Add;
  Template.Language := FilterLanguage;
  RefreshLanguageLists;
  RefreshList(Template);
  FNameEdit.SetFocus;
end;

procedure TCodeTemplateEditorDialog.DuplicateClick(Sender: TObject);
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
  FNameEdit.SetFocus;
end;

procedure TCodeTemplateEditorDialog.DeleteClick(Sender: TObject);
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
