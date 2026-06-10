program TestHighlighterState;

{$APPTYPE CONSOLE}

uses
  System.SysUtils,
  CodeEdit.Highlighter in '..\Source\CodeEdit.Highlighter.pas';

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

function KindAt(const Tokens: TCodeTokenArray; Col: Integer): TCodeTokenKind;
var
  T: TCodeToken;
begin
  Result := tkText;
  for T in Tokens do
    if (Col >= T.Start) and (Col < T.Start + T.Length) then
      Exit(T.Kind);
end;

var
  DL: TDelphiCodeHighlighter;
  PY: TPythonCodeHighlighter;
  JS: TJavaScriptCodeHighlighter;
  PS: TPowerShellCodeHighlighter;
  Tokens: TCodeTokenArray;
  S1, S2, S3: Integer;
begin
  DL := TDelphiCodeHighlighter.Create(nil);
  try
    Tokens := DL.TokenizeLineState('x := 1; { comment', 0, S1);
    Check(S1 <> 0, 'Delphi: open { leaves non-zero state');
    Check(KindAt(Tokens, 1) = tkIdentifier, 'Delphi: x is identifier');
    Check(KindAt(Tokens, 6) = tkNumber, 'Delphi: 1 is number');
    Check(KindAt(Tokens, 11) = tkComment, 'Delphi: { opens comment');
    Tokens := DL.TokenizeLineState('middle line', S1, S2);
    Check(S2 = S1, 'Delphi: state persists across middle line');
    Check(KindAt(Tokens, 3) = tkComment, 'Delphi: middle line painted as comment');
    Tokens := DL.TokenizeLineState('done } y := 2;', S2, S3);
    Check(S3 = 0, 'Delphi: } closes comment state');
    Check(KindAt(Tokens, 2) = tkComment, 'Delphi: text before } is comment');
    Check(KindAt(Tokens, 8) = tkIdentifier, 'Delphi: y after } is code again');
    Tokens := DL.TokenizeLineState('{ a } b', 0, S1);
    Check(S1 = 0, 'Delphi: same-line { } closes');
    Check(KindAt(Tokens, 7) = tkIdentifier, 'Delphi: b after closed comment is code');
    Tokens := DL.TokenizeLineState('(* multi', 0, S1);
    Check(S1 <> 0, 'Delphi: (* opens state');
    Tokens := DL.TokenizeLineState('end *) begin', S1, S2);
    Check((S2 = 0) and (KindAt(Tokens, 8) = tkKeyword), 'Delphi: *) closes, begin is keyword');
  finally
    DL.Free;
  end;

  PY := TPythonCodeHighlighter.Create(nil);
  try
    Tokens := PY.TokenizeLineState('s = """abc', 0, S1);
    Check(S1 <> 0, 'Python: """ opens string state');
    Check(KindAt(Tokens, 6) = tkString, 'Python: """ tokenized as string');
    Tokens := PY.TokenizeLineState('middle', S1, S2);
    Check((S2 = S1) and (KindAt(Tokens, 2) = tkString), 'Python: middle line stays string');
    Tokens := PY.TokenizeLineState('xyz""" + 1', S2, S3);
    Check(S3 = 0, 'Python: closing """ resets state');
    Check(KindAt(Tokens, 10) = tkNumber, 'Python: code resumes after close');
    Tokens := PY.TokenizeLineState('s = ''ab'' + 1', 0, S1);
    Check(S1 = 0, 'Python: ordinary string does not open state');
    Tokens := PY.TokenizeLineState('s = """x""" + 1', 0, S1);
    Check((S1 = 0) and (KindAt(Tokens, 15) = tkNumber), 'Python: same-line """x""" closes');
  finally
    PY.Free;
  end;

  JS := TJavaScriptCodeHighlighter.Create(nil);
  try
    Tokens := JS.TokenizeLineState('const s = `foo', 0, S1);
    Check(S1 <> 0, 'JS: template literal opens state');
    Tokens := JS.TokenizeLineState('bar` + x', S1, S2);
    Check(S2 = 0, 'JS: template literal closes');
    Check(KindAt(Tokens, 2) = tkString, 'JS: bar is string');
    Check(KindAt(Tokens, 8) = tkIdentifier, 'JS: x after close is identifier');
    Tokens := JS.TokenizeLineState('a /* c */ b', 0, S1);
    Check((S1 = 0) and (KindAt(Tokens, 5) = tkComment) and (KindAt(Tokens, 11) = tkIdentifier),
      'JS: inline /* */ comment');
    Tokens := JS.TokenizeLineState('a /* open', 0, S1);
    Check(S1 <> 0, 'JS: /* opens state');
  finally
    JS.Free;
  end;

  PS := TPowerShellCodeHighlighter.Create(nil);
  try
    Tokens := PS.TokenizeLineState('<# block', 0, S1);
    Check(S1 <> 0, 'PowerShell: <# opens state');
    Tokens := PS.TokenizeLineState('end #> $x', S1, S2);
    Check(S2 = 0, 'PowerShell: #> closes state');
    Check(KindAt(Tokens, 3) = tkComment, 'PowerShell: text before #> is comment');
  finally
    PS.Free;
  end;

  if ExitCode = 0 then
    WriteLn('ALL TESTS PASSED')
  else
    WriteLn('TESTS FAILED');
end.
