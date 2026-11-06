program TestEditorConditional;

// Editor-level check for conditional compilation highlighting: tokens the
// editor caches reflect the highlighter's Defines, and changing the defines
// (or the prefix) re-tokenizes without the text changing.
// Build:  dcc32 -U..\Source -NSSystem;Vcl;Winapi;System.Win TestEditorConditional.dpr
// (from an rsvars.bat shell).

{$APPTYPE CONSOLE}

uses
  System.SysUtils, Winapi.Windows, Vcl.Forms, Vcl.Controls,
  CodeEdit.Editor, CodeEdit.Highlighter;

var
  Form: TForm;
  Ed: TCodeEditor;
  HL: TDelphiCodeHighlighter;

procedure Check(Cond: Boolean; const Msg: string);
begin
  if Cond then
    WriteLn('PASS  ', Msg)
  else
  begin
    WriteLn('FAIL  ', Msg);
    ExitCode := 1;
  end;
end;

function KindAt(Line, Col: Integer): TCodeTokenKind;
var
  T: TCodeToken;
begin
  Result := tkText;
  for T in Ed.LineTokens(Line) do
    if (Col >= T.Start) and (Col < T.Start + T.Length) then
      Exit(T.Kind);
end;

begin
  Application.Initialize;
  Form := TForm.Create(nil);
  try
    HL := TDelphiCodeHighlighter.Create(Form);
    Ed := TCodeEditor.Create(Form);
    Ed.Parent := Form;
    Ed.SetBounds(0, 0, 800, 600);
    Ed.Highlighter := HL;
    Ed.Lines.Text :=
      '{#ifdef DEBUG}' + sLineBreak +      // 0
      '  Log(''debug'');' + sLineBreak +   // 1
      '{#else}' + sLineBreak +             // 2
      '  Quiet;' + sLineBreak +            // 3
      '{#endif}' + sLineBreak +            // 4
      'Run;';                              // 5

    // Nothing defined: the ifdef branch is out, the else branch is in.
    Check(KindAt(0, 1) = tkDirective, 'directive line is tkDirective');
    Check(KindAt(1, 3) = tkInactive, 'undefined branch inactive');
    Check(KindAt(3, 3) = tkIdentifier, 'else branch live');
    Check(KindAt(5, 1) = tkIdentifier, 'after endif live');

    // Define it: the editor's cache must be dropped and the branches swap.
    HL.Defines.Add('DEBUG');
    Check(KindAt(1, 3) = tkIdentifier, 'after defining DEBUG the ifdef branch is live');
    Check(KindAt(3, 3) = tkInactive, 'and the else branch is inactive');

    // Undefine through Assign (as a settings dialog or host would).
    HL.Defines.Text := '';
    Check(KindAt(1, 3) = tkInactive, 'clearing Defines re-tokenizes: ifdef branch inactive again');

    // A {#define} typed into the script itself flows down to the ifdef, and
    // editing it above re-flows the lines below.
    Ed.Lines.Insert(0, '{#define DEBUG}');
    Check(KindAt(2, 3) = tkIdentifier, 'a {#define} in the text makes the branch live');
    Check(KindAt(4, 3) = tkInactive, 'and the else branch inactive');
    Ed.Lines[0] := '{#define OTHER}';
    Check(KindAt(2, 3) = tkInactive, 'editing the define line re-flows the branches below');
    Ed.Lines.Delete(0);

    // Switching the prefix turns the {# lines into ordinary comments.
    HL.ConditionalPrefix := '{$';
    Check(KindAt(0, 1) = tkComment, 'with a {$ prefix the {# line is a comment');
    Check(KindAt(3, 3) = tkIdentifier, 'and nothing is inactive');

    // Detaching the highlighter stops notifications reaching the editor.
    Ed.Highlighter := nil;
    HL.Defines.Add('X');
    Check(Length(Ed.LineTokens(1)) = 0, 'no tokens without a highlighter');
  finally
    Form.Free;
  end;
  if ExitCode = 0 then
    WriteLn('ALL PASS')
  else
    WriteLn('FAILURES');
end.
