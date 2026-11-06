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

type
  // Method-pointer targets for the listener and the define event.
  TChangeCounter = class
    class procedure Bump(Sender: TObject);
    class procedure SayDefined(Sender: TObject; const Symbol: string; var Defined: Boolean);
  end;

var
  ChangeCount: Integer = 0;

class procedure TChangeCounter.Bump(Sender: TObject);
begin
  Inc(ChangeCount);
end;

class procedure TChangeCounter.SayDefined(Sender: TObject; const Symbol: string; var Defined: Boolean);
begin
  Defined := True;
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

  // Conditional compilation: {#ifdef X} .. {#else} .. {#endif} with Defines.
  DL := TDelphiCodeHighlighter.Create(nil);
  try
    DL.AddChangeListener(TChangeCounter.Bump);
    ChangeCount := 0;
    DL.Defines.Add('DEBUG');
    Check(ChangeCount = 1, 'Cond: adding a define notifies listeners');

    Tokens := DL.TokenizeLineState('{#ifdef DEBUG}', 0, S1);
    Check(KindAt(Tokens, 1) = tkDirective, 'Cond: {#ifdef} is a directive');
    Check(S1 <> 0, 'Cond: ifdef leaves a non-zero state');
    Tokens := DL.TokenizeLineState('x := 1;', S1, S2);
    Check(KindAt(Tokens, 1) = tkIdentifier, 'Cond: defined branch is live code');
    Tokens := DL.TokenizeLineState('{#else}', S2, S2);
    Tokens := DL.TokenizeLineState('y := 2; // c', S2, S3);
    Check(KindAt(Tokens, 1) = tkInactive, 'Cond: else branch of a defined symbol is inactive');
    Check(KindAt(Tokens, 9) = tkInactive, 'Cond: comment in an inactive branch is inactive too');
    Check(KindAt(Tokens, 2) = tkWhitespace, 'Cond: blanks stay whitespace');
    Tokens := DL.TokenizeLineState('{#endif}', S3, S1);
    Check(S1 = 0, 'Cond: endif returns to state 0');
    Tokens := DL.TokenizeLineState('z := 3;', S1, S2);
    Check((KindAt(Tokens, 1) = tkIdentifier) and (S2 = 0), 'Cond: code after endif is live');

    Tokens := DL.TokenizeLineState('{#ifdef RELEASE} a {#else} b {#endif} c', 0, S1);
    Check(KindAt(Tokens, 18) = tkInactive, 'Cond: same-line undefined branch inactive (a)');
    Check(KindAt(Tokens, 28) = tkIdentifier, 'Cond: same-line else branch live (b)');
    Check(KindAt(Tokens, 39) = tkIdentifier, 'Cond: after endif live (c)');
    Check(S1 = 0, 'Cond: balanced line ends in state 0');

    Tokens := DL.TokenizeLineState('{#ifndef DEBUG} a {#else} b {#endif}', 0, S1);
    Check((KindAt(Tokens, 17) = tkInactive) and (KindAt(Tokens, 27) = tkIdentifier),
      'Cond: ifndef of a defined symbol');

    // Nested: inside an inactive branch everything is inactive, even a
    // branch whose symbol is defined; the else of that inner branch too.
    Tokens := DL.TokenizeLineState('{#ifdef RELEASE} {#ifdef DEBUG} q {#else} r {#endif} s {#endif} t', 0, S1);
    Check(KindAt(Tokens, 33) = tkInactive, 'Cond: nested defined branch inside inactive is inactive (q)');
    Check(KindAt(Tokens, 43) = tkInactive, 'Cond: nested else inside inactive is inactive (r)');
    Check(KindAt(Tokens, 54) = tkInactive, 'Cond: outer branch still inactive after inner endif (s)');
    Check((KindAt(Tokens, 65) = tkIdentifier) and (S1 = 0), 'Cond: live again after outer endif (t)');

    // Nested the other way: live outer, undefined inner.
    Tokens := DL.TokenizeLineState('{#ifdef DEBUG} {#ifdef RELEASE} q {#else} r {#endif} s {#endif}', 0, S1);
    Check((KindAt(Tokens, 33) = tkInactive) and (KindAt(Tokens, 43) = tkIdentifier) and
      (KindAt(Tokens, 54) = tkIdentifier), 'Cond: live outer, undefined inner: q off, r and s on');

    // A comment spanning lines inside an inactive branch stays inactive and
    // the comment state survives alongside the conditional state.
    Tokens := DL.TokenizeLineState('{#ifdef RELEASE}', 0, S1);
    Tokens := DL.TokenizeLineState('{ open comment', S1, S2);
    Check((KindAt(Tokens, 3) = tkInactive) and (S2 <> S1), 'Cond: open comment in inactive branch');
    Tokens := DL.TokenizeLineState('still } code', S2, S3);
    Check((KindAt(Tokens, 2) = tkInactive) and (KindAt(Tokens, 9) = tkInactive), 'Cond: comment closes, still inactive');
    Tokens := DL.TokenizeLineState('{#endif} back', S3, S1);
    Check((KindAt(Tokens, 10) = tkIdentifier) and (S1 = 0), 'Cond: endif after the comment restores live code');

    // {#define} / {#undef} in the text, flowing down through the state.
    Tokens := DL.TokenizeLineState('{#define FOO}', 0, S1);
    Check((KindAt(Tokens, 1) = tkDirective) and (S1 <> 0), 'Cond: {#define} is a directive that changes the state');
    Tokens := DL.TokenizeLineState('{#ifdef foo} a {#endif}', S1, S2);
    Check(KindAt(Tokens, 14) = tkIdentifier, 'Cond: text define makes ifdef live (case-insensitive)');
    Check(S2 = S1, 'Cond: a balanced ifdef leaves the define state as it was');
    Tokens := DL.TokenizeLineState('{#undef FOO} {#ifdef FOO} a {#endif}', S2, S3);
    Check(KindAt(Tokens, 27) = tkInactive, 'Cond: text undef makes ifdef inactive');
    Tokens := DL.TokenizeLineState('{#undef DEBUG} {#ifdef DEBUG} a {#endif}', 0, S1);
    Check(KindAt(Tokens, 31) = tkInactive, 'Cond: text undef overrides a host define');
    Tokens := DL.TokenizeLineState('{#define DEBUG} {#ifdef DEBUG} a {#endif}', S1, S2);
    Check(KindAt(Tokens, 32) = tkIdentifier, 'Cond: text define restores it');
    Tokens := DL.TokenizeLineState('{#ifdef RELEASE} {#define SKIPPED} {#endif} {#ifdef SKIPPED} a {#endif}', 0, S1);
    Check((KindAt(Tokens, 62) = tkInactive) and (S1 = 0), 'Cond: a define inside a dead branch does not count');
    Tokens := DL.TokenizeLineState('{#define A} {#define B}', 0, S1);
    Tokens := DL.TokenizeLineState('{#define B} {#define A}', 0, S2);
    Check(S1 = S2, 'Cond: define order does not create distinct states');
    Tokens := DL.TokenizeLineState('{#define A}', 0, S1);
    Tokens := DL.TokenizeLineState('{#define A}', S1, S2);
    Check(S1 = S2, 'Cond: redefining is idempotent');
    Tokens := DL.TokenizeLineState('{#ifdef DEBUG', 0, S1);
    Check((KindAt(Tokens, 1) = tkComment) and (S1 <> 0), 'Cond: unterminated directive is a comment');

    // Deep nesting is unlimited now that the state is a table entry.
    S1 := 0;
    for S2 := 1 to 20 do
      Tokens := DL.TokenizeLineState('{#ifdef DEBUG}', S1, S1);
    Tokens := DL.TokenizeLineState('deep', S1, S2);
    Check(KindAt(Tokens, 1) = tkIdentifier, 'Cond: 20 live levels deep still live');
    Tokens := DL.TokenizeLineState('{#ifdef NOPE} x', S2, S3);
    Check(KindAt(Tokens, 15) = tkInactive, 'Cond: 21st level inactive');
    for S2 := 1 to 21 do
      Tokens := DL.TokenizeLineState('{#endif}', S3, S3);
    Check(S3 = 0, 'Cond: 21 endifs return to state 0');

    // Stray else/endif are harmless; the event can override the list.
    Tokens := DL.TokenizeLineState('{#endif} {#else} a', 0, S1);
    Check((KindAt(Tokens, 18) = tkIdentifier) and (S1 = 0), 'Cond: stray endif/else ignored');
    DL.OnIsDefined := TChangeCounter.SayDefined;
    Tokens := DL.TokenizeLineState('{#ifdef ANYTHING} a {#endif}', 0, S1);
    Check(KindAt(Tokens, 19) = tkIdentifier, 'Cond: OnIsDefined can define a symbol');
    DL.OnIsDefined := nil;

    // '{$' prefix for real Delphi sources.
    DL.ConditionalPrefix := '{$';
    Check(ChangeCount = 2, 'Cond: changing the prefix notifies listeners');
    Tokens := DL.TokenizeLineState('{$ifdef DEBUG} a {$else} b {$endif}', 0, S1);
    Check((KindAt(Tokens, 1) = tkDirective) and (KindAt(Tokens, 16) = tkIdentifier) and
      (KindAt(Tokens, 26) = tkInactive), 'Cond: {$ prefix');
    Tokens := DL.TokenizeLineState('{#ifdef DEBUG} a', 0, S1);
    Check((KindAt(Tokens, 1) = tkComment) and (S1 = 0), 'Cond: {# is a plain comment once the prefix is {$');
    DL.RemoveChangeListener(TChangeCounter.Bump);
    DL.Defines.Clear;
    Check(ChangeCount = 2, 'Cond: removed listener is not called');
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
