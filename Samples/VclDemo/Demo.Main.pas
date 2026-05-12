UNIT Demo.Main;

INTERFACE

USES
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs,

  CodeEdit.Editor,
  CodeEdit.Completion,
  CodeEdit.Highlighter;

TYPE
  TMainForm = CLASS(TForm)
    PROCEDURE FormCreate(Sender: TObject);
  PRIVATE
    { Private declarations }
    FEditor: TCodeEditor;
    FHighlighter: TDelphiCodeHighlighter;
    FCompletionProvider: TCustomCodeCompletionProvider;
    PROCEDURE GetCompletions(Sender: TObject; CONST Context: TCodeCompletionContext;
      Items: TCodeCompletionItems);
  PUBLIC
    { Public declarations }
  END;

VAR
  MainForm          : TMainForm;

IMPLEMENTATION

{$R *.dfm}

PROCEDURE TMainForm.FormCreate(Sender: TObject);
BEGIN
  Caption := 'CodeEdit Demo';
  Width := 900;
  Height := 640;

  FHighlighter := TDelphiCodeHighlighter.Create(Self);
  FCompletionProvider := TCustomCodeCompletionProvider.Create(Self);
  FCompletionProvider.OnGetCompletions := GetCompletions;

  FEditor := TCodeEditor.Create(Self);
  FEditor.Parent := Self;
  FEditor.Align := alClient;
  FEditor.Highlighter := FHighlighter;
  FEditor.CompletionProvider := FCompletionProvider;
  FEditor.Lines.Text :=
    'unit Example;' + sLineBreak +
    '' + sLineBreak +
    'interface' + sLineBreak +
    '' + sLineBreak +
    'type' + sLineBreak +
    '  TExample = class' + sLineBreak +
    '  public' + sLineBreak +
    '    procedure Run;' + sLineBreak +
    '  end;' + sLineBreak +
    '' + sLineBreak +
    'implementation' + sLineBreak +
    '' + sLineBreak +
    'procedure TExample.Run;' + sLineBreak +
    'begin' + sLineBreak +
    '  // Start typing here.' + sLineBreak +
    'end;' + sLineBreak +
    '' + sLineBreak +
    'end.';

END;

PROCEDURE TMainForm.GetCompletions(Sender: TObject; CONST Context: TCodeCompletionContext;
  Items: TCodeCompletionItems);
CONST
  DelphiKeywords: ARRAY[0..15] OF STRING = (
    'begin', 'case', 'class', 'const', 'constructor', 'destructor', 'else',
    'end', 'for', 'function', 'if', 'implementation', 'interface',
    'procedure', 'try', 'var'
  );
VAR
  Keyword: STRING;
BEGIN
  IF Context.TriggerChar = '(' THEN
  BEGIN
    Items.AddItem('Sender: TObject', 'Sender: TObject', ckParameter, 'parameter');
    Items.AddItem('const Value: string', 'const Value: string', ckParameter, 'parameter');
    Items.AddItem('AOwner: TComponent', 'AOwner: TComponent', ckParameter, 'parameter');
    EXIT;
  END;

  IF Context.TriggerChar = '<' THEN
  BEGIN
    Items.AddItem('TObject', 'TObject', ckClass, 'generic type');
    Items.AddItem('TComponent', 'TComponent', ckClass, 'generic type');
    Items.AddItem('string', 'string', ckKeyword, 'type');
    EXIT;
  END;

  FOR Keyword IN DelphiKeywords DO
    IF (Context.Prefix = '') OR SameText(Copy(Keyword, 1, Length(Context.Prefix)), Context.Prefix) THEN
      Items.AddItem(Keyword, Keyword, ckKeyword, 'keyword');
END;

END.

