unit CodeEdit.Register;

interface

procedure Register;

implementation

uses
  System.Classes,
  CodeEdit.Completion,
  CodeEdit.Editor,
  CodeEdit.Highlighter;

procedure Register;
begin
  RegisterComponents('CodeEdit', [
    TCodeEditor,
    TKeywordCompletionProvider,
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
end;

end.
