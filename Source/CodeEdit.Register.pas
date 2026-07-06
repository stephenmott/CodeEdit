unit CodeEdit.Register;

interface

procedure Register;

implementation

{$R *.dcr}

uses
  System.Classes,
  DesignEditors,
  DesignIntf,
  CodeEdit.Completion,
  CodeEdit.Editor,
  CodeEdit.Highlighter,
  CodeEdit.TemplateEditorDlg,
  CodeEdit.Templates;

type
  // Double-clicking a TCodeTemplateProvider (or its context menu verb) opens
  // the template editor dialog on the design-time component.
  TCodeTemplateProviderEditor = class(TComponentEditor)
  public
    procedure ExecuteVerb(Index: Integer); override;
    function GetVerb(Index: Integer): string; override;
    function GetVerbCount: Integer; override;
  end;

procedure TCodeTemplateProviderEditor.ExecuteVerb(Index: Integer);
begin
  if Index = 0 then
    if TCodeTemplateEditorDialog.Execute(TCodeTemplateProvider(Component)) then
      Designer.Modified;
end;

function TCodeTemplateProviderEditor.GetVerb(Index: Integer): string;
begin
  Result := 'Edit Templates...';
end;

function TCodeTemplateProviderEditor.GetVerbCount: Integer;
begin
  Result := 1;
end;

procedure Register;
begin
  RegisterComponents('CodeEdit', [
    TCodeEditor,
    TKeywordCompletionProvider,
    TCodeTemplateProvider,
    TDelphiCodeHighlighter,
    TJavaScriptCodeHighlighter,
    TSqlCodeHighlighter,
    TTungliCodeHighlighter,
    TBatchCodeHighlighter,
    TPowerShellCodeHighlighter,
    TIniCodeHighlighter,
    TYamlCodeHighlighter,
    TPythonCodeHighlighter
  ]);
  RegisterComponentEditor(TCodeTemplateProvider, TCodeTemplateProviderEditor);
end;

end.
