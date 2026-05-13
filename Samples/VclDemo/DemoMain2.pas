UNIT DemoMain2;

INTERFACE

USES
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ComCtrls, Vcl.StdCtrls, Vcl.ExtCtrls,

  CodeEdit.Editor, CodeEdit.Completion, CodeEdit.Highlighter;

CONST
  cDelphi           =
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

  cJavaScriptDemoText =
    'import { format } from "./utils.js";' + sLineBreak +
    '' + sLineBreak +
    'const users = [' + sLineBreak +
    '  { id: 1, name: "Ada", active: true },' + sLineBreak +
    '  { id: 2, name: "Grace", active: false }' + sLineBreak +
    '];' + sLineBreak +
    '' + sLineBreak +
    'async function loadUser(id) {' + sLineBreak +
    '  try {' + sLineBreak +
    '    const response = await fetch(`/api/users/${id}`);' + sLineBreak +
    '    if (!response.ok) {' + sLineBreak +
    '      throw new Error("Unable to load user");' + sLineBreak +
    '    }' + sLineBreak +
    '' + sLineBreak +
    '    const user = await response.json();' + sLineBreak +
    '    console.log(format(user.name));' + sLineBreak +
    '    return user;' + sLineBreak +
    '  } catch (error) {' + sLineBreak +
    '    console.error(error);' + sLineBreak +
    '    return null;' + sLineBreak +
    '  }' + sLineBreak +
    '}' + sLineBreak;

  cSqlDemoText      =
    'select' + sLineBreak +
    '  c.CustomerId,' + sLineBreak +
    '  c.CompanyName,' + sLineBreak +
    '  count(o.OrderId) as OrderCount,' + sLineBreak +
    '  sum(o.TotalAmount) as TotalSpend' + sLineBreak +
    'from Customers c' + sLineBreak +
    'left join Orders o on o.CustomerId = c.CustomerId' + sLineBreak +
    'where c.IsActive = 1' + sLineBreak +
    '  and o.OrderDate >= ''2026-01-01''' + sLineBreak +
    'group by c.CustomerId, c.CompanyName' + sLineBreak +
    'having sum(o.TotalAmount) > 1000' + sLineBreak +
    'order by TotalSpend desc;' + sLineBreak +
    '' + sLineBreak +
    '-- Update stale customers' + sLineBreak +
    'update Customers' + sLineBreak +
    'set Status = ''Review''' + sLineBreak +
    'where LastOrderDate < ''2025-01-01'';' + sLineBreak;

TYPE
  TForm2 = CLASS(TForm)
    CodeEditor1: TCodeEditor;
    StatusBar1: TStatusBar;
    DelphiCodeHighlighter1: TDelphiCodeHighlighter;
    JavaScriptCodeHighlighter1: TJavaScriptCodeHighlighter;
    SqlCodeHighlighter1: TSqlCodeHighlighter;
    Panel1: TPanel;
    ComboBox1: TComboBox;
    PROCEDURE FormCreate(Sender: TObject);
    PROCEDURE ComboBox1Change(Sender: TObject);
  PRIVATE
    { Private declarations }
    FCompletionProvider: TCustomCodeCompletionProvider;
    PROCEDURE GetCompletions(Sender: TObject; CONST Context: TCodeCompletionContext;
      Items: TCodeCompletionItems);
  PUBLIC
    { Public declarations }
  END;

VAR
  Form2             : TForm2;

IMPLEMENTATION

{$R *.dfm}

PROCEDURE TForm2.ComboBox1Change(Sender: TObject);
BEGIN
  CASE ComboBox1.ItemIndex OF
    0: BEGIN
        CodeEditor1.Highlighter := DelphiCodeHighlighter1;
        CodeEditor1.Lines.Text := cDelphi;
      END;
    1: BEGIN
        CodeEditor1.Highlighter := JavaScriptCodeHighlighter1;
        CodeEditor1.Lines.Text := cJavaScriptDemoText;
      END;
    2: BEGIN
        CodeEditor1.Highlighter := SqlCodeHighlighter1;
        CodeEditor1.Lines.Text := cSqlDemoText;
      END;
  ELSE
    CodeEditor1.Highlighter := DelphiCodeHighlighter1;
    CodeEditor1.Lines.Text := cDelphi;
  END;
END;

PROCEDURE TForm2.FormCreate(Sender: TObject);
BEGIN

  Caption := 'CodeEdit Demo';

  FCompletionProvider := TCustomCodeCompletionProvider.Create(Self);
  FCompletionProvider.OnGetCompletions := GetCompletions;

  CodeEditor1.Highlighter := DelphiCodeHighlighter1;
  CodeEditor1.Lines.Text := cDelphi;
  CodeEditor1.CompletionProvider := FCompletionProvider;
  CodeEditor1.StyledScrollBars := True;

END;

PROCEDURE TForm2.GetCompletions(Sender: TObject;
  CONST Context: TCodeCompletionContext; Items: TCodeCompletionItems);
CONST
  DelphiKeywords    : ARRAY[0..15] OF STRING = (
    'begin', 'case', 'class', 'const', 'constructor', 'destructor', 'else',
    'end', 'for', 'function', 'if', 'implementation', 'interface',
    'procedure', 'try', 'var'
    );
VAR
  Keyword           : STRING;
BEGIN
  IF Context.TriggerChar = '(' THEN BEGIN
    Items.AddItem('Sender: TObject', 'Sender: TObject', ckParameter, 'parameter');
    Items.AddItem('const Value: string', 'const Value: string', ckParameter, 'parameter');
    Items.AddItem('AOwner: TComponent', 'AOwner: TComponent', ckParameter, 'parameter');
    EXIT;
  END;

  IF Context.TriggerChar = '<' THEN BEGIN
    Items.AddItem('TObject', 'TObject', ckClass, 'generic type');
    Items.AddItem('TComponent', 'TComponent', ckClass, 'generic type');
    Items.AddItem('string', 'string', ckKeyword, 'type');
    EXIT;
  END;

  FOR Keyword IN DelphiKeywords DO
    IF (Context.Prefix = '') OR SameText(Copy(Keyword, 1, Length(Context.Prefix)), Context.Prefix)
      THEN
      Items.AddItem(Keyword, Keyword, ckKeyword, 'keyword');
END;

END.

