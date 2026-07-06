UNIT CodeEdit.Register;

INTERFACE

PROCEDURE Register;

IMPLEMENTATION

{$R *.dcr}

USES
  System.Classes,
  DesignEditors,
  DesignIntf,
  CodeEdit.Completion,
  CodeEdit.Editor,
  CodeEdit.Highlighter,
  CodeEdit.TemplateEditorDlg,
  CodeEdit.Templates;

TYPE
  // Double-clicking a TCodeTemplateProvider (or its context menu verb) opens
  // the template editor dialog on the design-time component.
  TCodeTemplateProviderEditor = CLASS(TComponentEditor)
  PUBLIC
    PROCEDURE ExecuteVerb(Index: Integer); OVERRIDE;
    FUNCTION GetVerb(Index: Integer): STRING; OVERRIDE;
    FUNCTION GetVerbCount: Integer; OVERRIDE;
  END;

PROCEDURE TCodeTemplateProviderEditor.ExecuteVerb(Index: Integer);
BEGIN
  IF Index = 0 THEN
    IF TCodeTemplateEditorDialog.Execute(TCodeTemplateProvider(Component)) THEN
      Designer.Modified;
END;

FUNCTION TCodeTemplateProviderEditor.GetVerb(Index: Integer): STRING;
BEGIN
  Result := 'Edit Templates...';
END;

FUNCTION TCodeTemplateProviderEditor.GetVerbCount: Integer;
BEGIN
  Result := 1;
END;

PROCEDURE Register;
BEGIN
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
END;

END.

