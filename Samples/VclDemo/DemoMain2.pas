UNIT DemoMain2;

INTERFACE

USES
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ComCtrls, Vcl.StdCtrls, Vcl.ExtCtrls,

  CodeEdit.Editor, CodeEdit.Completion, CodeEdit.Highlighter, CodeEdit.Templates,
  CodeEdit.TemplateEditorDlg;

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

  cTungliDemoText   =
    '/* Tungli script - generate a scoring report */' + sLineBreak +
    '' + sLineBreak +
    'PROCEDURE BuildHeader {' + sLineBreak +
    '  header := "Report generated: " || _DATE || " " || _TIME ;' + sLineBreak +
    '  divider := "----------------------------------------" ;' + sLineBreak +
    '}' + sLineBreak +
    '' + sLineBreak +
    'PROCEDURE BuildBody {' + sLineBreak +
    '  body := "" ;' + sLineBreak +
    '  total := 0 ;' + sLineBreak +
    '  i := 1 ;' + sLineBreak +
    '  WHILE i <= 5 DO {' + sLineBreak +
    '    score := i * 10 ;' + sLineBreak +
    '    total := total + score ;' + sLineBreak +
    '    IF score >= 30 THEN {' + sLineBreak +
    '      label := "Pass" ;' + sLineBreak +
    '    } ELSE {' + sLineBreak +
    '      label := "Fail" ;' + sLineBreak +
    '    }' + sLineBreak +
    '    body := body || Prefix(2, "0", String(i)) || " score=" || String(score)' + sLineBreak +
    '                 || " " || label || _LF ;' + sLineBreak +
    '    i := i + 1 ;' + sLineBreak +
    '  }' + sLineBreak +
    '  average := total / 5 ;' + sLineBreak +
    '}' + sLineBreak +
    '' + sLineBreak +
    'EXEC BuildHeader ;' + sLineBreak +
    'EXEC BuildBody ;' + sLineBreak +
    '' + sLineBreak +
    'result := header || _LF || divider || _LF || body || _LF' + sLineBreak +
    '       || "Average: " || String(average) ;' + sLineBreak +
    '' + sLineBreak +
    'END.';

  cBatchDemoText    =
    '@echo off' + sLineBreak +
    ':: Build script - package the release binaries' + sLineBreak +
    '' + sLineBreak +
    'setlocal enabledelayedexpansion' + sLineBreak +
    '' + sLineBreak +
    'set ROOT=%~dp0' + sLineBreak +
    'set DIST=%ROOT%dist' + sLineBreak +
    'set VERSION=1.2.0' + sLineBreak +
    '' + sLineBreak +
    'if not exist "%DIST%" (' + sLineBreak +
    '    mkdir "%DIST%"' + sLineBreak +
    ')' + sLineBreak +
    '' + sLineBreak +
    'rem Build each target listed below' + sLineBreak +
    'for %%T in (win32 win64 linux) do (' + sLineBreak +
    '    echo Building %%T...' + sLineBreak +
    '    call :build %%T' + sLineBreak +
    '    if errorlevel 1 (' + sLineBreak +
    '        echo Build failed for %%T' + sLineBreak +
    '        exit /b 1' + sLineBreak +
    '    )' + sLineBreak +
    ')' + sLineBreak +
    '' + sLineBreak +
    'echo Done. Artifacts in "%DIST%"' + sLineBreak +
    'endlocal' + sLineBreak +
    'exit /b 0' + sLineBreak +
    '' + sLineBreak +
    ':build' + sLineBreak +
    'set TARGET=%~1' + sLineBreak +
    'echo   target=!TARGET! version=!VERSION!' + sLineBreak +
    'copy /Y bin\app-!TARGET!.exe "%DIST%\app-!VERSION!-!TARGET!.exe" >nul' + sLineBreak +
    'exit /b 0';

  cPowerShellDemoText =
    '<#' + sLineBreak +
    '.SYNOPSIS' + sLineBreak +
    '    Tail a log file and group entries by severity.' + sLineBreak +
    '#>' + sLineBreak +
    '' + sLineBreak +
    'param(' + sLineBreak +
    '    [Parameter(Mandatory = $true)]' + sLineBreak +
    '    [string]$Path,' + sLineBreak +
    '' + sLineBreak +
    '    [int]$Tail = 200' + sLineBreak +
    ')' + sLineBreak +
    '' + sLineBreak +
    '# Read the last $Tail lines of the file' + sLineBreak +
    '$lines = Get-Content -Path $Path -Tail $Tail' + sLineBreak +
    '' + sLineBreak +
    '$groups = @{' + sLineBreak +
    '    ''ERROR'' = 0' + sLineBreak +
    '    ''WARN''  = 0' + sLineBreak +
    '    ''INFO''  = 0' + sLineBreak +
    '}' + sLineBreak +
    '' + sLineBreak +
    'foreach ($line in $lines) {' + sLineBreak +
    '    if ($line -match ''^(?<level>ERROR|WARN|INFO)\s+(?<msg>.+)$'') {' + sLineBreak +
    '        $level = $matches[''level'']' + sLineBreak +
    '        $groups[$level]++' + sLineBreak +
    '    }' + sLineBreak +
    '}' + sLineBreak +
    '' + sLineBreak +
    '$total = ($groups.Values | Measure-Object -Sum).Sum' + sLineBreak +
    'Write-Host "Scanned $total entries from $Path" -ForegroundColor Cyan' + sLineBreak +
    '' + sLineBreak +
    'foreach ($key in $groups.Keys) {' + sLineBreak +
    '    $count = $groups[$key]' + sLineBreak +
    '    $pct = if ($total -gt 0) { [math]::Round(100 * $count / $total, 1) } else { 0 }' + sLineBreak
      +
    '    "{0,-6} {1,5}  {2,5}%" -f $key, $count, $pct' + sLineBreak +
    '}';

  cIniDemoText      =
    '; Application configuration' + sLineBreak +
    '; Lines starting with ; or # are comments' + sLineBreak +
    '' + sLineBreak +
    '[general]' + sLineBreak +
    'title = "CodeEdit Demo"' + sLineBreak +
    'version = 1.2.0' + sLineBreak +
    'locale = en-GB' + sLineBreak +
    'trace = false' + sLineBreak +
    '' + sLineBreak +
    '[window]' + sLineBreak +
    'x = 100' + sLineBreak +
    'y = 100' + sLineBreak +
    'width = 1024' + sLineBreak +
    'height = 768' + sLineBreak +
    'maximized = no' + sLineBreak +
    '' + sLineBreak +
    '[editor]' + sLineBreak +
    'font.name = "Cascadia Code"' + sLineBreak +
    'font.size = 11' + sLineBreak +
    'tab.size = 4' + sLineBreak +
    'expand.tabs = yes' + sLineBreak +
    'show.gutter = on' + sLineBreak +
    '' + sLineBreak +
    '[paths]' + sLineBreak +
    'projects = C:\Work\Projects' + sLineBreak +
    'backup   = D:\Backups\CodeEdit' + sLineBreak +
    '' + sLineBreak +
    '# trailing comment style is also valid';

  cYamlDemoText     =
    '# CI pipeline - build, test, publish' + sLineBreak +
    '' + sLineBreak +
    'name: build-and-publish' + sLineBreak +
    'on:' + sLineBreak +
    '  push:' + sLineBreak +
    '    branches: [main]' + sLineBreak +
    '  pull_request:' + sLineBreak +
    '    branches: [''*'']' + sLineBreak +
    '' + sLineBreak +
    'env:' + sLineBreak +
    '  CONFIG: Release' + sLineBreak +
    '  RETRIES: 3' + sLineBreak +
    '' + sLineBreak +
    'jobs:' + sLineBreak +
    '  build:' + sLineBreak +
    '    runs-on: windows-latest' + sLineBreak +
    '    steps:' + sLineBreak +
    '      - uses: actions/checkout@v4' + sLineBreak +
    '      - name: Restore packages' + sLineBreak +
    '        run: |' + sLineBreak +
    '          dotnet restore' + sLineBreak +
    '          dotnet --info' + sLineBreak +
    '      - name: Build' + sLineBreak +
    '        run: dotnet build --configuration ${{ env.CONFIG }} --no-restore' + sLineBreak +
    '        env:' + sLineBreak +
    '          NUGET_XMLDOC_MODE: skip' + sLineBreak +
    '      - name: Test' + sLineBreak +
    '        run: dotnet test --no-build --verbosity normal' + sLineBreak +
    '        continue-on-error: false' + sLineBreak +
    '      - name: Notify' + sLineBreak +
    '        if: failure()' + sLineBreak +
    '        run: echo "Build failed"';

  cPythonDemoText   =
    '"""Customer report - summarise spend per customer."""' + sLineBreak +
    '' + sLineBreak +
    'from dataclasses import dataclass' + sLineBreak +
    'from datetime import date' + sLineBreak +
    'from typing import Iterable' + sLineBreak +
    '' + sLineBreak +
    'THRESHOLD = 1_000.0' + sLineBreak +
    'LABELS = {True: "Active", False: "Dormant"}' + sLineBreak +
    '' + sLineBreak +
    '' + sLineBreak +
    '@dataclass(frozen=True)' + sLineBreak +
    'class Customer:' + sLineBreak +
    '    customer_id: int' + sLineBreak +
    '    name: str' + sLineBreak +
    '    total_spend: float' + sLineBreak +
    '    last_order: date' + sLineBreak +
    '' + sLineBreak +
    '' + sLineBreak +
    'def is_active(customer: Customer, today: date) -> bool:' + sLineBreak +
    '    delta_days = (today - customer.last_order).days' + sLineBreak +
    '    return delta_days <= 90 and customer.total_spend >= THRESHOLD' + sLineBreak +
    '' + sLineBreak +
    '' + sLineBreak +
    'def summarise(customers: Iterable[Customer], today: date | None = None) -> str:' + sLineBreak +
    '    today = today or date.today()' + sLineBreak +
    '    lines = ["id   name              spend       status"]' + sLineBreak +
    '    for c in customers:' + sLineBreak +
    '        status = LABELS[is_active(c, today)]' + sLineBreak +
    '        lines.append(f"{c.customer_id:>4} {c.name:<18}{c.total_spend:>10.2f}  {status}")' + sLineBreak
      +
    '    return "\n".join(lines)' + sLineBreak +
    '' + sLineBreak +
    '' + sLineBreak +
    'if __name__ == "__main__":' + sLineBreak +
    '    sample = [' + sLineBreak +
    '        Customer(1, "Ada Lovelace",     2450.00, date(2026, 4, 12)),' + sLineBreak +
    '        Customer(2, "Grace Hopper",      980.50, date(2025, 11, 30)),' + sLineBreak +
    '        Customer(3, "Alan Turing",      3100.75, date(2026, 5, 1)),' + sLineBreak +
    '    ]' + sLineBreak +
    '    print(summarise(sample))';

TYPE
  TForm2 = CLASS(TForm)
    CodeEditor1: TCodeEditor;
    StatusBar1: TStatusBar;
    DelphiCodeHighlighter1: TDelphiCodeHighlighter;
    JavaScriptCodeHighlighter1: TJavaScriptCodeHighlighter;
    SqlCodeHighlighter1: TSqlCodeHighlighter;
    Panel1: TPanel;
    ComboBox1: TComboBox;
    CheckBox1: TCheckBox;
    ButtonTemplates: TButton;
    KeywordCompletionProvider1: TKeywordCompletionProvider;
    PythonCodeHighlighter1: TPythonCodeHighlighter;
    YamlCodeHighlighter1: TYamlCodeHighlighter;
    IniCodeHighlighter1: TIniCodeHighlighter;
    PowerShellCodeHighlighter1: TPowerShellCodeHighlighter;
    BatchCodeHighlighter1: TBatchCodeHighlighter;
    TungliCodeHighlighter1: TTungliCodeHighlighter;
    PROCEDURE FormCreate(Sender: TObject);
    PROCEDURE ComboBox1Change(Sender: TObject);
    PROCEDURE CheckBox1Click(Sender: TObject);
    PROCEDURE ButtonTemplatesClick(Sender: TObject);
    PROCEDURE KeywordCompletionProvider1GetCompletions(Sender: TObject;
      CONST Context: TCodeCompletionContext; Items: TCodeCompletionItems);
    PROCEDURE KeywordCompletionProvider1GetSignatureHelp(Sender: TObject;
      CONST Context: TCodeSignatureHelpContext; Items: TCodeSignatureItems);
    PROCEDURE CodeEditor1QueryExecutableLine(Sender: TObject; Line: Integer;
      VAR Value: Boolean);
    PROCEDURE CodeEditor1GetHint(Sender: TObject; Line, Column: Integer;
      CONST AWord: STRING; VAR HintText: STRING);
  PRIVATE
    { Private declarations }
    FCompletionProvider: TCustomCodeCompletionProvider;
    FTemplateProvider: TCodeTemplateProvider;
    PROCEDURE GetCompletions(Sender: TObject; CONST Context: TCodeCompletionContext;
      Items: TCodeCompletionItems);
    PROCEDURE AddSampleTemplates;
  PUBLIC
    { Public declarations }
  END;

VAR
  Form2             : TForm2;

IMPLEMENTATION

{$R *.dfm}

PROCEDURE TForm2.CheckBox1Click(Sender: TObject);
BEGIN
  CodeEditor1.ReadOnly := CheckBox1.Checked;
  CodeEditor1.Enabled := CheckBox1.Checked;
END;

PROCEDURE TForm2.ButtonTemplatesClick(Sender: TObject);
BEGIN
  IF TCodeTemplateEditorDialog.Execute(FTemplateProvider) THEN
    CodeEditor1.SetFocus;
END;

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
    3: BEGIN
        CodeEditor1.Highlighter := TungliCodeHighlighter1;
        CodeEditor1.Lines.Text := cTungliDemoText;
      END;
    4: BEGIN
        CodeEditor1.Highlighter := BatchCodeHighlighter1;
        CodeEditor1.Lines.Text := cBatchDemoText;
      END;
    5: BEGIN
        CodeEditor1.Highlighter := PowerShellCodeHighlighter1;
        CodeEditor1.Lines.Text := cPowerShellDemoText;
      END;
    6: BEGIN
        CodeEditor1.Highlighter := IniCodeHighlighter1;
        CodeEditor1.Lines.Text := cIniDemoText;
      END;
    7: BEGIN
        CodeEditor1.Highlighter := YamlCodeHighlighter1;
        CodeEditor1.Lines.Text := cYamlDemoText;
      END;
    8: BEGIN
        CodeEditor1.Highlighter := PythonCodeHighlighter1;
        CodeEditor1.Lines.Text := cPythonDemoText;
      END;

  ELSE
    CodeEditor1.Highlighter := DelphiCodeHighlighter1;
    CodeEditor1.Lines.Text := cDelphi;
  END;
END;

PROCEDURE TForm2.AddSampleTemplates;
BEGIN
  WITH FTemplateProvider.Templates DO BEGIN
    // Delphi
    AddTemplate('begin', 'begin..end block', 'Delphi',
      'begin' + sLineBreak +
      '  |' + sLineBreak +
      'end;');
    AddTemplate('ifb', 'if..then begin..end', 'Delphi',
      'if | then' + sLineBreak +
      'begin' + sLineBreak +
      'end;');
    AddTemplate('ife', 'if..then..else', 'Delphi',
      'if | then' + sLineBreak +
      'begin' + sLineBreak +
      'end' + sLineBreak +
      'else' + sLineBreak +
      'begin' + sLineBreak +
      'end;');
    AddTemplate('forb', 'for loop with begin..end', 'Delphi',
      'for I := 0 to | do' + sLineBreak +
      'begin' + sLineBreak +
      'end;');
    AddTemplate('tryf', 'try..finally', 'Delphi',
      'try' + sLineBreak +
      '  |' + sLineBreak +
      'finally' + sLineBreak +
      'end;');
    AddTemplate('trye', 'try..except', 'Delphi',
      'try' + sLineBreak +
      '  |' + sLineBreak +
      'except' + sLineBreak +
      '  on E: Exception do' + sLineBreak +
      'end;');
    AddTemplate('proc', 'procedure skeleton', 'Delphi',
      'procedure |;' + sLineBreak +
      'begin' + sLineBreak +
      'end;');
    AddTemplate('func', 'function skeleton', 'Delphi',
      'function |: Integer;' + sLineBreak +
      'begin' + sLineBreak +
      'end;');
    AddTemplate('classd', 'class declaration', 'Delphi',
      'type' + sLineBreak +
      '  T| = class' + sLineBreak +
      '  private' + sLineBreak +
      '  public' + sLineBreak +
      '  end;');

    // JavaScript
    AddTemplate('fun', 'function', 'JavaScript',
      'function |() {' + sLineBreak +
      '}');
    AddTemplate('afun', 'async function', 'JavaScript',
      'async function |() {' + sLineBreak +
      '}');
    AddTemplate('for', 'for loop', 'JavaScript',
      'for (let i = 0; i < |; i++) {' + sLineBreak +
      '}');
    AddTemplate('tryc', 'try..catch', 'JavaScript',
      'try {' + sLineBreak +
      '  |' + sLineBreak +
      '} catch (error) {' + sLineBreak +
      '  console.error(error);' + sLineBreak +
      '}');

    // SQL
    AddTemplate('sel', 'select skeleton', 'SQL',
      'select |' + sLineBreak +
      'from ' + sLineBreak +
      'where ');
    AddTemplate('selj', 'select with join', 'SQL',
      'select |' + sLineBreak +
      'from t1' + sLineBreak +
      'join t2 on t2.Id = t1.Id' + sLineBreak +
      'where ');
    AddTemplate('upd', 'update statement', 'SQL',
      'update |' + sLineBreak +
      'set ' + sLineBreak +
      'where ');
    AddTemplate('ins', 'insert statement', 'SQL',
      'insert into | ()' + sLineBreak +
      'values ();');

    // Python
    AddTemplate('def', 'function definition', 'Python',
      'def |():' + sLineBreak +
      '    pass');
    AddTemplate('classd', 'class definition', 'Python',
      'class |:' + sLineBreak +
      '    def __init__(self):' + sLineBreak +
      '        pass');
    AddTemplate('main', 'main guard', 'Python',
      'if __name__ == "__main__":' + sLineBreak +
      '    |');

    // PowerShell
    AddTemplate('func', 'function skeleton', 'PowerShell',
      'function | {' + sLineBreak +
      '    param()' + sLineBreak +
      '}');
    AddTemplate('fore', 'foreach loop', 'PowerShell',
      'foreach ($item in $|) {' + sLineBreak +
      '}');
  END;
END;

PROCEDURE TForm2.FormCreate(Sender: TObject);
BEGIN

  Caption := 'CodeEdit Demo';

  FCompletionProvider := TCustomCodeCompletionProvider.Create(Self);
  FCompletionProvider.OnGetCompletions := GetCompletions;

  FTemplateProvider := TCodeTemplateProvider.Create(Self);
  AddSampleTemplates;
  // The user's own templates live next to the exe and layer on top of the
  // hard-coded set; the template dialog saves them back automatically.
  FTemplateProvider.UserFileName := ChangeFileExt(ParamStr(0), '.templates.json');
  FTemplateProvider.LoadUserTemplates;

  CodeEditor1.Highlighter := DelphiCodeHighlighter1;
  CodeEditor1.Lines.Text := cDelphi;
  CodeEditor1.CompletionProvider := FCompletionProvider;
  CodeEditor1.TemplateProvider := FTemplateProvider;
  CodeEditor1.StyledScrollBars := True;
  CodeEditor1.Options.ShowMinimap := True;
  CodeEditor1.AddLineMarker(10, lmkError);
  CodeEditor1.AddLineMarker(11, lmkExecutable);
  CodeEditor1.AddLineMarker(12, lmkWarning);
  CodeEditor1.AddLineMarker(13, lmkInfo);

  // Blue "executable line" dots: a debugger would ask its script engine here;
  // the demo just marks non-blank, non-comment lines.
  CodeEditor1.OnQueryExecutableLine := CodeEditor1QueryExecutableLine;
  // Hover-to-evaluate: a debugger returns the variable's live value here; the
  // demo just echoes the identifier under the mouse.
  CodeEditor1.OnGetHint := CodeEditor1GetHint;

  ComboBox1.ItemIndex := 0;
END;

PROCEDURE TForm2.CodeEditor1GetHint(Sender: TObject; Line, Column: Integer;
  CONST AWord: STRING; VAR HintText: STRING);
BEGIN
  HintText := Format('%s = <value>   (%d:%d)', [AWord, Line, Column]);
END;

PROCEDURE TForm2.CodeEditor1QueryExecutableLine(Sender: TObject; Line: Integer;
  VAR Value: Boolean);
VAR
  S                 : STRING;
BEGIN
  Value := False;
  IF (Line >= 1) AND (Line <= CodeEditor1.Lines.Count) THEN BEGIN
    S := Trim(CodeEditor1.Lines[Line - 1]);
    Value := (S <> '') AND (Copy(S, 1, 2) <> '//');
  END;
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

PROCEDURE TForm2.KeywordCompletionProvider1GetCompletions(Sender: TObject;
  CONST Context: TCodeCompletionContext; Items: TCodeCompletionItems);
BEGIN
  //Context.LineText
  Items.AddItem('ShowMessage', 'ShowMessage', ckFunction, 'procedure');
END;

PROCEDURE TForm2.KeywordCompletionProvider1GetSignatureHelp(Sender: TObject;
  CONST Context: TCodeSignatureHelpContext; Items: TCodeSignatureItems);
BEGIN
  IF SameText(Context.FunctionName, 'ShowMessage') THEN
    Items.AddItem('ShowMessage', ['Msg: string']);
END;

END.

