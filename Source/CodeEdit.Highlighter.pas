UNIT CodeEdit.Highlighter;

INTERFACE

USES
  System.Classes,
  System.Generics.Collections,
  Vcl.Graphics;

TYPE
  TCodeTokenKind = (
    tkText,
    tkWhitespace,
    tkComment,
    tkString,
    tkNumber,
    tkKeyword,
    tkIdentifier,
    tkSymbol,
    tkDirective,                        // a conditional-compilation directive, e.g. {#ifdef X}
    tkInactive                          // code inside a conditional branch that is compiled out
    );

  TCodeToken = RECORD
    Start: Integer;
    Length: Integer;
    Kind: TCodeTokenKind;
  END;

  TCodeTokenArray = TArray<TCodeToken>;

  TCodeTextStyle = RECORD
    Foreground: TColor;
    Background: TColor;
    FontStyle: TFontStyles;
  END;

  TCustomCodeHighlighter = CLASS(TComponent)
  PRIVATE
    FStyles: ARRAY[TCodeTokenKind] OF TCodeTextStyle;
    FListeners: TList<TNotifyEvent>;
    FUNCTION GetStyle(Kind: TCodeTokenKind): TCodeTextStyle;
    PROCEDURE SetStyle(Kind: TCodeTokenKind; CONST Value: TCodeTextStyle);
  PROTECTED
    PROCEDURE SetDefaultStyles; VIRTUAL;
    // Tells attached editors their cached tokens are stale (something that
    // changes tokenization without changing the text: defined symbols, a
    // directive prefix, ...). Editors register through AddChangeListener.
    PROCEDURE Changed;
  PUBLIC
    CONSTRUCTOR Create(AOwner: TComponent); OVERRIDE;
    DESTRUCTOR Destroy; OVERRIDE;
    PROCEDURE AddChangeListener(CONST Listener: TNotifyEvent);
    PROCEDURE RemoveChangeListener(CONST Listener: TNotifyEvent);
    // Human-readable language identifier, used to group code templates and
    // similar per-language data. Defaults to the class name without the 'T'
    // prefix and 'CodeHighlighter' suffix, e.g. TDelphiCodeHighlighter ->
    // 'Delphi'. Override for casing the derivation cannot produce ('SQL').
    CLASS FUNCTION LanguageName: STRING; VIRTUAL;
    FUNCTION TokenizeLine(CONST ALine: STRING; ALineIndex: Integer): TCodeTokenArray; VIRTUAL;
    // Stateful tokenization for constructs that span lines (block comments,
    // multi-line strings). StartState is the state the previous line ended in;
    // 0 means "nothing open". Stateless highlighters ignore it.
    FUNCTION TokenizeLineState(CONST ALine: STRING; StartState: Integer;
      OUT EndState: Integer): TCodeTokenArray; VIRTUAL;
    PROPERTY Styles[Kind: TCodeTokenKind]: TCodeTextStyle READ GetStyle WRITE SetStyle;
  END;

  TCodeHighlighterClass = CLASS OF TCustomCodeHighlighter;

  // A construct that may span lines, e.g. '(*' .. '*)' or '"""' .. '"""'.
  // Its 1-based index in the registration order is the line state value used
  // by TokenizeLineState while the construct is open.
  TCodeMultiLineRange = RECORD
    StartDelimiter: STRING;
    EndDelimiter: STRING;
    Kind: TCodeTokenKind;
  END;

  { What a line of a TCustomWordCodeHighlighter language leaves open for the
    next line. The editor only sees an Integer: the highlighter interns each
    distinct record in a table and hands out its index, so equal states get
    equal numbers (which is all the editor's cache relies on) and 0 stays
    "nothing open". Conditional-compilation bookkeeping lives here so that a
    define directive in the text reaches the ifdef directives further down. }
  TCodeLineState = RECORD
    Range: Integer;                     // open multi-line range, 1-based registration index, 0 = none
    Levels: STRING;                     // one char per open conditional branch: '0'..'3' = taken*2 + active
    Defined: STRING;                    // ';'-separated lower-case symbols defined by the text so far
    Undefined: STRING;                  // same, undefined by the text (overrides the host's list)
  END;

  TCustomWordCodeHighlighter = CLASS(TCustomCodeHighlighter)
  PRIVATE
    FKeywords: TDictionary<STRING, Boolean>;
    FMultiLineRanges: TList<TCodeMultiLineRange>;
    FStateKeys: TDictionary<STRING, Integer>;
    FStates: TList<TCodeLineState>;
    FUNCTION StateFor(Handle: Integer): TCodeLineState;
    FUNCTION InternState(CONST State: TCodeLineState): Integer;
  PROTECTED
    { Conditional branches: text is inactive while any open level is inactive.
      A branch opened inside an inactive one is inactive and counts as taken,
      so its else stays inactive too. }
    CLASS FUNCTION CondActive(CONST Levels: STRING): Boolean; STATIC;
    CLASS PROCEDURE CondPush(VAR Levels: STRING; Active, Taken: Boolean); STATIC;
    // else = ElseIf(True). The branch goes live only when nothing in the
    // chain has been taken yet and Condition holds; otherwise it stays
    // inactive, remembering whether a branch was taken for the next one.
    CLASS PROCEDURE CondElseIf(VAR Levels: STRING; Condition: Boolean); STATIC;
    CLASS PROCEDURE CondElse(VAR Levels: STRING); STATIC;
    CLASS PROCEDURE CondPop(VAR Levels: STRING); STATIC;
    { The ';'-separated symbol lists in TCodeLineState. }
    CLASS FUNCTION SymbolListHas(CONST List, Symbol: STRING): Boolean; STATIC;
    CLASS PROCEDURE SymbolListAdd(VAR List: STRING; CONST Symbol: STRING); STATIC;
    CLASS PROCEDURE SymbolListRemove(VAR List: STRING; CONST Symbol: STRING); STATIC;
    // A directive at ALine[Index]? Return its length, updating State's
    // conditional fields (Range is the caller's). Default: no directives.
    FUNCTION TryDirective(CONST ALine: STRING; Index: Integer; VAR State: TCodeLineState;
      OUT TokenLength: Integer): Boolean; VIRTUAL;
    PROCEDURE AddKeyword(CONST Value: STRING);
    PROCEDURE AddKeywords(CONST Values: ARRAY OF STRING);
    PROCEDURE AddMultiLineRange(CONST AStartDelimiter, AEndDelimiter: STRING;
      AKind: TCodeTokenKind = tkComment);
    PROCEDURE BuildKeywords; VIRTUAL;
    PROCEDURE BuildMultiLineRanges; VIRTUAL;
    FUNCTION CaseSensitive: Boolean; VIRTUAL;
    FUNCTION KeywordKey(CONST Value: STRING): STRING;
    FUNCTION IsKeyword(CONST Value: STRING): Boolean; VIRTUAL;
    FUNCTION IsIdentifierStart(Ch: Char): Boolean; VIRTUAL;
    FUNCTION IsIdentifierChar(Ch: Char): Boolean; VIRTUAL;
    FUNCTION IsLineComment(CONST ALine: STRING; Index: Integer): Boolean; VIRTUAL;
    FUNCTION IsNumberStart(CONST ALine: STRING; Index: Integer): Boolean; VIRTUAL;
    FUNCTION IsStringStart(Ch: Char): Boolean; VIRTUAL;
    FUNCTION ReadIdentifier(CONST ALine: STRING; Index: Integer): Integer; VIRTUAL;
    FUNCTION ReadNumber(CONST ALine: STRING; Index: Integer): Integer; VIRTUAL;
    FUNCTION ReadString(CONST ALine: STRING; Index: Integer): Integer; VIRTUAL;
    FUNCTION TokenKindForIdentifier(CONST Value: STRING): TCodeTokenKind; VIRTUAL;
  PUBLIC
    CONSTRUCTOR Create(AOwner: TComponent); OVERRIDE;
    DESTRUCTOR Destroy; OVERRIDE;
    FUNCTION TokenizeLine(CONST ALine: STRING; ALineIndex: Integer): TCodeTokenArray; OVERRIDE;
    FUNCTION TokenizeLineState(CONST ALine: STRING; StartState: Integer;
      OUT EndState: Integer): TCodeTokenArray; OVERRIDE;
  END;

  // Asked for each {#ifdef X} / {#ifndef X} after the Defines list has been
  // consulted; set Defined to override.
  TCodeIsDefinedEvent = PROCEDURE(Sender: TObject; CONST Symbol: STRING; VAR Defined: Boolean)
    OF OBJECT;

  // Answers "is this symbol defined?" for EvaluateConditionalExpression.
  TCodeIsDefinedFunc = REFERENCE TO FUNCTION(CONST Symbol: STRING): Boolean;

// Evaluates the expression of an "if" / "elseif" conditional directive:
//   defined(X)   not   and   or   ( )   true   false
// with Delphi's precedence (not, then and, then or), case-insensitive.
// Valid comes back False for anything else - an empty expression, a bare
// symbol without defined(), an unbalanced bracket, a stray word - and the
// result is then False. The highlighter treats an invalid expression as True
// so a typo never hides code; a preprocessor should report it instead. Both
// sides are meant to call this one function so they can never disagree
// about which branch is live.
FUNCTION EvaluateConditionalExpression(CONST Expr: STRING; CONST IsDefined: TCodeIsDefinedFunc;
  OUT Valid: Boolean): Boolean;

TYPE
  TDelphiCodeHighlighter = CLASS(TCustomWordCodeHighlighter)
  PRIVATE
    FDefines: TStringList;
    FConditionalPrefix: STRING;
    FOnIsDefined: TCodeIsDefinedEvent;
    PROCEDURE DefinesChanged(Sender: TObject);
    FUNCTION GetDefines: TStrings;
    PROCEDURE SetDefines(Value: TStrings);
    PROCEDURE SetConditionalPrefix(CONST Value: STRING);
  PROTECTED
    PROCEDURE BuildKeywords; OVERRIDE;
    PROCEDURE BuildMultiLineRanges; OVERRIDE;
    FUNCTION IsNumberStart(CONST ALine: STRING; Index: Integer): Boolean; OVERRIDE;
    FUNCTION ReadNumber(CONST ALine: STRING; Index: Integer): Integer; OVERRIDE;
    FUNCTION ReadString(CONST ALine: STRING; Index: Integer): Integer; OVERRIDE;
    PROCEDURE SetDefaultStyles; OVERRIDE;
    // {#define X} {#undef X} {#ifdef X} {#ifndef X} {#if expr} {#elseif expr}
    // {#else} {#endif} / {#ifend} (prefix per ConditionalPrefix, closing brace
    // on the same line). Any other {#word ...} is coloured as a directive but
    // changes nothing.
    FUNCTION TryDirective(CONST ALine: STRING; Index: Integer; VAR State: TCodeLineState;
      OUT TokenLength: Integer): Boolean; OVERRIDE;
    // The text's own {#define}/{#undef} so far, then Defines, then OnIsDefined.
    FUNCTION IsDefinedAt(CONST Symbol: STRING; CONST State: TCodeLineState): Boolean; VIRTUAL;
    // EvaluateConditionalExpression against IsDefinedAt; True when invalid.
    FUNCTION EvaluateAt(CONST Expr: STRING; CONST State: TCodeLineState): Boolean;
  PUBLIC
    CONSTRUCTOR Create(AOwner: TComponent); OVERRIDE;
    DESTRUCTOR Destroy; OVERRIDE;
    // The host's view: Defines, then OnIsDefined. Case-insensitive. Text
    // directives are layered on top of this per line (IsDefinedAt).
    FUNCTION IsDefined(CONST Symbol: STRING): Boolean; VIRTUAL;
  PUBLISHED
    // Symbols that count as defined for {#ifdef} / {#ifndef}; changing the
    // list re-highlights attached editors.
    PROPERTY Defines: TStrings READ GetDefines WRITE SetDefines;
    // Start of a conditional directive. '{#' by default; '{$' for real Delphi.
    PROPERTY ConditionalPrefix: STRING READ FConditionalPrefix WRITE SetConditionalPrefix;
    PROPERTY OnIsDefined: TCodeIsDefinedEvent READ FOnIsDefined WRITE FOnIsDefined;
  END;

  TJavaScriptCodeHighlighter = CLASS(TCustomWordCodeHighlighter)
  PROTECTED
    PROCEDURE BuildKeywords; OVERRIDE;
    PROCEDURE BuildMultiLineRanges; OVERRIDE;
    FUNCTION CaseSensitive: Boolean; OVERRIDE;
    FUNCTION IsStringStart(Ch: Char): Boolean; OVERRIDE;
    FUNCTION ReadNumber(CONST ALine: STRING; Index: Integer): Integer; OVERRIDE;
    FUNCTION ReadString(CONST ALine: STRING; Index: Integer): Integer; OVERRIDE;
  END;

  TSqlCodeHighlighter = CLASS(TCustomWordCodeHighlighter)
  PROTECTED
    PROCEDURE BuildKeywords; OVERRIDE;
    PROCEDURE BuildMultiLineRanges; OVERRIDE;
    FUNCTION IsLineComment(CONST ALine: STRING; Index: Integer): Boolean; OVERRIDE;
    FUNCTION IsStringStart(Ch: Char): Boolean; OVERRIDE;
    FUNCTION ReadString(CONST ALine: STRING; Index: Integer): Integer; OVERRIDE;
  PUBLIC
    CLASS FUNCTION LanguageName: STRING; OVERRIDE;
  END;

  TTungliCodeHighlighter = CLASS(TCustomWordCodeHighlighter)
  PROTECTED
    PROCEDURE BuildKeywords; OVERRIDE;
    PROCEDURE BuildMultiLineRanges; OVERRIDE;
    FUNCTION IsLineComment(CONST ALine: STRING; Index: Integer): Boolean; OVERRIDE;
    FUNCTION IsStringStart(Ch: Char): Boolean; OVERRIDE;
    FUNCTION ReadString(CONST ALine: STRING; Index: Integer): Integer; OVERRIDE;
  END;

  TBatchCodeHighlighter = CLASS(TCustomWordCodeHighlighter)
  PROTECTED
    PROCEDURE BuildKeywords; OVERRIDE;
    FUNCTION IsLineComment(CONST ALine: STRING; Index: Integer): Boolean; OVERRIDE;
    FUNCTION IsStringStart(Ch: Char): Boolean; OVERRIDE;
    FUNCTION ReadString(CONST ALine: STRING; Index: Integer): Integer; OVERRIDE;
  END;

  TPowerShellCodeHighlighter = CLASS(TCustomWordCodeHighlighter)
  PROTECTED
    PROCEDURE BuildKeywords; OVERRIDE;
    PROCEDURE BuildMultiLineRanges; OVERRIDE;
    FUNCTION IsLineComment(CONST ALine: STRING; Index: Integer): Boolean; OVERRIDE;
    FUNCTION IsStringStart(Ch: Char): Boolean; OVERRIDE;
    FUNCTION ReadString(CONST ALine: STRING; Index: Integer): Integer; OVERRIDE;
  END;

  TIniCodeHighlighter = CLASS(TCustomWordCodeHighlighter)
  PROTECTED
    PROCEDURE BuildKeywords; OVERRIDE;
    FUNCTION IsLineComment(CONST ALine: STRING; Index: Integer): Boolean; OVERRIDE;
    FUNCTION IsStringStart(Ch: Char): Boolean; OVERRIDE;
    FUNCTION ReadString(CONST ALine: STRING; Index: Integer): Integer; OVERRIDE;
  PUBLIC
    CLASS FUNCTION LanguageName: STRING; OVERRIDE;
  END;

  TYamlCodeHighlighter = CLASS(TCustomWordCodeHighlighter)
  PROTECTED
    PROCEDURE BuildKeywords; OVERRIDE;
    FUNCTION IsLineComment(CONST ALine: STRING; Index: Integer): Boolean; OVERRIDE;
    FUNCTION IsStringStart(Ch: Char): Boolean; OVERRIDE;
    FUNCTION ReadString(CONST ALine: STRING; Index: Integer): Integer; OVERRIDE;
  PUBLIC
    CLASS FUNCTION LanguageName: STRING; OVERRIDE;
  END;

  TPythonCodeHighlighter = CLASS(TCustomWordCodeHighlighter)
  PROTECTED
    PROCEDURE BuildKeywords; OVERRIDE;
    PROCEDURE BuildMultiLineRanges; OVERRIDE;
    FUNCTION CaseSensitive: Boolean; OVERRIDE;
    FUNCTION IsLineComment(CONST ALine: STRING; Index: Integer): Boolean; OVERRIDE;
    FUNCTION IsStringStart(Ch: Char): Boolean; OVERRIDE;
    FUNCTION ReadNumber(CONST ALine: STRING; Index: Integer): Integer; OVERRIDE;
    FUNCTION ReadString(CONST ALine: STRING; Index: Integer): Integer; OVERRIDE;
  END;

IMPLEMENTATION

USES
  System.Character,
  System.Math,
  System.StrUtils,
  System.SysUtils;

FUNCTION MakeToken(AStart, ALength: Integer; AKind: TCodeTokenKind): TCodeToken;
BEGIN
  Result.Start := AStart;
  Result.Length := ALength;
  Result.Kind := AKind;
END;

FUNCTION TokenArrayOf(CONST Token: TCodeToken): TCodeTokenArray;
BEGIN
  SetLength(Result, 1);
  Result[0] := Token;
END;

FUNCTION StartsTextAt(CONST ALine: STRING; Index: Integer; CONST Value: STRING;
  CaseSensitive: Boolean): Boolean;
BEGIN
  IF Value = '' THEN
    Exit(False);

  IF Index + Length(Value) - 1 > Length(ALine) THEN
    Exit(False);

  IF CaseSensitive THEN
    Result := Copy(ALine, Index, Length(Value)) = Value
  ELSE
    Result := SameText(Copy(ALine, Index, Length(Value)), Value);
END;

CONSTRUCTOR TCustomCodeHighlighter.Create(AOwner: TComponent);
BEGIN
  INHERITED;
  SetDefaultStyles;
END;

CLASS FUNCTION TCustomCodeHighlighter.LanguageName: STRING;
CONST
  Suffixes          : ARRAY[0..1] OF STRING = ('CodeHighlighter', 'Highlighter');
VAR
  Suffix            : STRING;
BEGIN
  Result := ClassName;
  IF (Result <> '') AND (Result[1] = 'T') THEN
    Delete(Result, 1, 1);
  FOR Suffix IN Suffixes DO
    IF EndsText(Suffix, Result) AND (Length(Result) > Length(Suffix)) THEN BEGIN
      SetLength(Result, Length(Result) - Length(Suffix));
      Break;
    END;
END;

PROCEDURE TCustomCodeHighlighter.SetDefaultStyles;
VAR
  Kind              : TCodeTokenKind;
BEGIN
  FOR Kind := Low(TCodeTokenKind) TO High(TCodeTokenKind) DO BEGIN
    FStyles[Kind].Foreground := clWindowText;
    FStyles[Kind].Background := clNone;
    FStyles[Kind].FontStyle := [];
  END;

  FStyles[tkComment].Foreground := $00808080;
  FStyles[tkString].Foreground := $00008000;
  FStyles[tkNumber].Foreground := $00A00000;
  FStyles[tkKeyword].Foreground := $00C04000;
  FStyles[tkKeyword].FontStyle := [fsBold];
  FStyles[tkSymbol].Foreground := $00606060;
  FStyles[tkDirective].Foreground := $00DB00AF;
  FStyles[tkInactive].Foreground := $00A8A8A8;
END;

DESTRUCTOR TCustomCodeHighlighter.Destroy;
BEGIN
  FListeners.Free;
  INHERITED;
END;

PROCEDURE TCustomCodeHighlighter.AddChangeListener(CONST Listener: TNotifyEvent);
BEGIN
  IF FListeners = NIL THEN
    FListeners := TList<TNotifyEvent>.Create;
  IF NOT FListeners.Contains(Listener) THEN
    FListeners.Add(Listener);
END;

PROCEDURE TCustomCodeHighlighter.RemoveChangeListener(CONST Listener: TNotifyEvent);
BEGIN
  IF Assigned(FListeners) THEN
    FListeners.Remove(Listener);
END;

PROCEDURE TCustomCodeHighlighter.Changed;
VAR
  I                 : Integer;
BEGIN
  IF (FListeners = NIL) OR (csDestroying IN ComponentState) THEN
    Exit;
  FOR I := FListeners.Count - 1 DOWNTO 0 DO
    FListeners[I](Self);
END;

FUNCTION TCustomCodeHighlighter.TokenizeLine(CONST ALine: STRING; ALineIndex: Integer):
  TCodeTokenArray;
BEGIN
  Result := TokenArrayOf(MakeToken(1, Length(ALine), tkText));
END;

FUNCTION TCustomCodeHighlighter.TokenizeLineState(CONST ALine: STRING; StartState: Integer;
  OUT EndState: Integer): TCodeTokenArray;
BEGIN
  // Stateless default: highlighters that only override TokenizeLine keep working.
  EndState := 0;
  Result := TokenizeLine(ALine, 0);
END;

FUNCTION TCustomCodeHighlighter.GetStyle(Kind: TCodeTokenKind): TCodeTextStyle;
BEGIN
  Result := FStyles[Kind];
END;

PROCEDURE TCustomCodeHighlighter.SetStyle(Kind: TCodeTokenKind; CONST Value: TCodeTextStyle);
BEGIN
  FStyles[Kind] := Value;
END;

CONSTRUCTOR TCustomWordCodeHighlighter.Create(AOwner: TComponent);
BEGIN
  INHERITED;
  FKeywords := TDictionary<STRING, Boolean>.Create;
  FMultiLineRanges := TList<TCodeMultiLineRange>.Create;
  FStateKeys := TDictionary<STRING, Integer>.Create;
  FStates := TList<TCodeLineState>.Create;
  BuildKeywords;
  BuildMultiLineRanges;
END;

DESTRUCTOR TCustomWordCodeHighlighter.Destroy;
BEGIN
  FStates.Free;
  FStateKeys.Free;
  FMultiLineRanges.Free;
  FKeywords.Free;
  INHERITED;
END;

{ State interning. Handle 0 is the empty state; others index FStates + 1.
  The table only grows (editors hold handles for as long as they like) but
  holds one entry per distinct combination, which stays small in practice. }

FUNCTION StateKey(CONST State: TCodeLineState): STRING;
BEGIN
  Result := IntToStr(State.Range) + '|' + State.Levels + '|' + State.Defined + '|' +
    State.Undefined;
END;

FUNCTION TCustomWordCodeHighlighter.StateFor(Handle: Integer): TCodeLineState;
BEGIN
  IF (Handle >= 1) AND (Handle <= FStates.Count) THEN
    Result := FStates[Handle - 1]
  ELSE BEGIN
    // 0, or a handle from another highlighter: nothing open.
    Result.Range := 0;
    Result.Levels := '';
    Result.Defined := '';
    Result.Undefined := '';
  END;
END;

FUNCTION TCustomWordCodeHighlighter.InternState(CONST State: TCodeLineState): Integer;
VAR
  Key               : STRING;
BEGIN
  IF (State.Range = 0) AND (State.Levels = '') AND (State.Defined = '') AND
    (State.Undefined = '') THEN
    Exit(0);
  Key := StateKey(State);
  IF NOT FStateKeys.TryGetValue(Key, Result) THEN BEGIN
    FStates.Add(State);
    Result := FStates.Count;
    FStateKeys.Add(Key, Result);
  END;
END;

PROCEDURE TCustomWordCodeHighlighter.AddMultiLineRange(CONST AStartDelimiter, AEndDelimiter: STRING;
  AKind: TCodeTokenKind);
VAR
  Range             : TCodeMultiLineRange;
BEGIN
  Range.StartDelimiter := AStartDelimiter;
  Range.EndDelimiter := AEndDelimiter;
  Range.Kind := AKind;
  FMultiLineRanges.Add(Range);
END;

PROCEDURE TCustomWordCodeHighlighter.BuildMultiLineRanges;
BEGIN
END;

PROCEDURE TCustomWordCodeHighlighter.AddKeyword(CONST Value: STRING);
BEGIN
  FKeywords.AddOrSetValue(KeywordKey(Value), True);
END;

PROCEDURE TCustomWordCodeHighlighter.AddKeywords(CONST Values: ARRAY OF STRING);
VAR
  Value             : STRING;
BEGIN
  FOR Value IN Values DO
    AddKeyword(Value);
END;

PROCEDURE TCustomWordCodeHighlighter.BuildKeywords;
BEGIN
END;

FUNCTION TCustomWordCodeHighlighter.CaseSensitive: Boolean;
BEGIN
  Result := False;
END;

FUNCTION TCustomWordCodeHighlighter.KeywordKey(CONST Value: STRING): STRING;
BEGIN
  IF CaseSensitive THEN
    Result := Value
  ELSE
    Result := LowerCase(Value);
END;

FUNCTION TCustomWordCodeHighlighter.IsKeyword(CONST Value: STRING): Boolean;
BEGIN
  Result := FKeywords.ContainsKey(KeywordKey(Value));
END;

FUNCTION TCustomWordCodeHighlighter.IsIdentifierStart(Ch: Char): Boolean;
BEGIN
  Result := Ch.IsLetter OR (Ch = '_');
END;

FUNCTION TCustomWordCodeHighlighter.IsIdentifierChar(Ch: Char): Boolean;
BEGIN
  Result := Ch.IsLetterOrDigit OR (Ch = '_');
END;

FUNCTION TCustomWordCodeHighlighter.IsLineComment(CONST ALine: STRING; Index: Integer): Boolean;
BEGIN
  Result := StartsTextAt(ALine, Index, '//', True);
END;

FUNCTION TCustomWordCodeHighlighter.IsNumberStart(CONST ALine: STRING; Index: Integer): Boolean;
BEGIN
  Result := ALine[Index].IsDigit;
END;

FUNCTION TCustomWordCodeHighlighter.IsStringStart(Ch: Char): Boolean;
BEGIN
  Result := Ch = '''';
END;

FUNCTION TCustomWordCodeHighlighter.ReadIdentifier(CONST ALine: STRING; Index: Integer): Integer;
BEGIN
  Result := Index;
  REPEAT
    Inc(Result);
  UNTIL (Result > Length(ALine)) OR NOT IsIdentifierChar(ALine[Result]);
END;

FUNCTION TCustomWordCodeHighlighter.ReadNumber(CONST ALine: STRING; Index: Integer): Integer;
BEGIN
  Result := Index;
  REPEAT
    Inc(Result);
  UNTIL (Result > Length(ALine)) OR NOT (ALine[Result].IsLetterOrDigit OR (ALine[Result] = '.') OR
    (ALine[Result] = '_'));
END;

FUNCTION TCustomWordCodeHighlighter.ReadString(CONST ALine: STRING; Index: Integer): Integer;
VAR
  Quote             : Char;
BEGIN
  Quote := ALine[Index];
  Result := Index + 1;
  WHILE Result <= Length(ALine) DO BEGIN
    IF ALine[Result] = Quote THEN BEGIN
      Inc(Result);
      IF (Result <= Length(ALine)) AND (ALine[Result] = Quote) THEN
        Inc(Result)
      ELSE
        Break;
    END ELSE
      Inc(Result);
  END;
END;

FUNCTION TCustomWordCodeHighlighter.TokenKindForIdentifier(CONST Value: STRING): TCodeTokenKind;
BEGIN
  IF IsKeyword(Value) THEN
    Result := tkKeyword
  ELSE
    Result := tkIdentifier;
END;

{ Conditional branches. Each open level is one character of Levels:
  '0' inactive, '1' active, '2' inactive but a branch was taken, '3' active
  and taken. }

CONST
  CondActiveBit     = 1;
  CondTakenBit      = 2;

CLASS FUNCTION TCustomWordCodeHighlighter.CondActive(CONST Levels: STRING): Boolean;
VAR
  I                 : Integer;
BEGIN
  FOR I := 1 TO Length(Levels) DO
    IF (Ord(Levels[I]) - Ord('0')) AND CondActiveBit = 0 THEN
      Exit(False);
  Result := True;
END;

CLASS PROCEDURE TCustomWordCodeHighlighter.CondPush(VAR Levels: STRING; Active, Taken: Boolean);
VAR
  Bits              : Integer;
BEGIN
  Bits := 0;
  IF Active THEN
    Bits := Bits OR CondActiveBit;
  IF Taken THEN
    Bits := Bits OR CondTakenBit;
  Levels := Levels + Chr(Ord('0') + Bits);
END;

CLASS PROCEDURE TCustomWordCodeHighlighter.CondElseIf(VAR Levels: STRING; Condition: Boolean);
VAR
  Bits              : Integer;
  Taken             : Boolean;
BEGIN
  IF Levels = '' THEN
    Exit;                               // stray else / elseif
  Bits := Ord(Levels[Length(Levels)]) - Ord('0');
  Taken := Bits AND CondTakenBit <> 0;
  // Live iff everything above is live, no branch of this chain was yet, and
  // the condition holds. A false condition leaves the chain still open for
  // a later elseif/else; a true one closes it.
  IF CondActive(Copy(Levels, 1, Length(Levels) - 1)) AND NOT Taken AND Condition THEN
    Bits := CondActiveBit OR CondTakenBit
  ELSE IF Taken THEN
    Bits := CondTakenBit
  ELSE
    Bits := 0;
  Levels[Length(Levels)] := Chr(Ord('0') + Bits);
END;

CLASS PROCEDURE TCustomWordCodeHighlighter.CondElse(VAR Levels: STRING);
BEGIN
  CondElseIf(Levels, True);
END;

CLASS PROCEDURE TCustomWordCodeHighlighter.CondPop(VAR Levels: STRING);
BEGIN
  IF Levels <> '' THEN
    Delete(Levels, Length(Levels), 1);  // a stray endif is ignored
END;

{ ';'-separated, lower-case, sorted symbol lists. }

CLASS FUNCTION TCustomWordCodeHighlighter.SymbolListHas(CONST List, Symbol: STRING): Boolean;
BEGIN
  Result := (Symbol <> '') AND (Pos(';' + LowerCase(Symbol) + ';', ';' + List + ';') > 0);
END;

CLASS PROCEDURE TCustomWordCodeHighlighter.SymbolListAdd(VAR List: STRING; CONST Symbol: STRING);
VAR
  Items             : TStringList;
BEGIN
  IF (Symbol = '') OR SymbolListHas(List, Symbol) THEN
    Exit;
  // Kept sorted so the order of {#define}s doesn't create distinct states.
  Items := TStringList.Create;
  TRY
    Items.Delimiter := ';';
    Items.StrictDelimiter := True;
    Items.DelimitedText := List;
    Items.Add(LowerCase(Symbol));
    Items.Sort;
    List := Items.DelimitedText;
  FINALLY
    Items.Free;
  END;
END;

CLASS PROCEDURE TCustomWordCodeHighlighter.SymbolListRemove(VAR List: STRING;
  CONST Symbol: STRING);
VAR
  Items             : TStringList;
  I                 : Integer;
BEGIN
  IF NOT SymbolListHas(List, Symbol) THEN
    Exit;
  Items := TStringList.Create;
  TRY
    Items.Delimiter := ';';
    Items.StrictDelimiter := True;
    Items.DelimitedText := List;
    I := Items.IndexOf(LowerCase(Symbol));
    IF I >= 0 THEN
      Items.Delete(I);
    List := Items.DelimitedText;
  FINALLY
    Items.Free;
  END;
END;

FUNCTION TCustomWordCodeHighlighter.TryDirective(CONST ALine: STRING; Index: Integer;
  VAR State: TCodeLineState; OUT TokenLength: Integer): Boolean;
BEGIN
  TokenLength := 0;
  Result := False;
END;

// Conditional expressions: a recursive-descent evaluator over
//   or-expr  := and-expr ( 'or' and-expr )*
//   and-expr := factor ( 'and' factor )*
//   factor   := 'not' factor | '(' or-expr ')' | 'defined' '(' symbol ')' | 'true' | 'false'
// Both operands are always parsed (no short-circuit) so syntax errors are
// found wherever they are.

FUNCTION EvaluateConditionalExpression(CONST Expr: STRING; CONST IsDefined: TCodeIsDefinedFunc;
  OUT Valid: Boolean): Boolean;
VAR
  P                 : Integer;
  Tok               : STRING;           // lower-cased word, '(' , ')', '?' for junk, '' at the end

  PROCEDURE Next;
  VAR
    Start           : Integer;
  BEGIN
    WHILE (P <= Length(Expr)) AND Expr[P].IsWhiteSpace DO
      Inc(P);
    IF P > Length(Expr) THEN
      Tok := ''
    ELSE IF Expr[P].IsLetter OR (Expr[P] = '_') THEN BEGIN
      Start := P;
      WHILE (P <= Length(Expr)) AND (Expr[P].IsLetterOrDigit OR (Expr[P] = '_')) DO
        Inc(P);
      Tok := LowerCase(Copy(Expr, Start, P - Start));
    END ELSE IF CharInSet(Expr[P], ['(', ')']) THEN BEGIN
      Tok := Expr[P];
      Inc(P);
    END ELSE BEGIN
      Tok := '?';
      Inc(P);
    END;
  END;

  FUNCTION IsWord: Boolean;
  BEGIN
    Result := (Tok <> '') AND (Tok <> '(') AND (Tok <> ')') AND (Tok <> '?');
  END;

  FUNCTION ParseOr: Boolean; FORWARD;

  FUNCTION ParseFactor: Boolean;
  VAR
    Symbol          : STRING;
  BEGIN
    IF Tok = 'not' THEN BEGIN
      Next;
      Result := NOT ParseFactor;
    END ELSE IF Tok = '(' THEN BEGIN
      Next;
      Result := ParseOr;
      IF Tok = ')' THEN
        Next
      ELSE
        Valid := False;
    END ELSE IF Tok = 'true' THEN BEGIN
      Next;
      Result := True;
    END ELSE IF Tok = 'false' THEN BEGIN
      Next;
      Result := False;
    END ELSE IF Tok = 'defined' THEN BEGIN
      Next;
      Result := False;
      IF Tok <> '(' THEN
        Valid := False
      ELSE BEGIN
        Next;
        IF NOT IsWord THEN
          Valid := False
        ELSE BEGIN
          Symbol := Tok;
          Next;
          IF Tok <> ')' THEN
            Valid := False
          ELSE BEGIN
            Next;
            Result := Assigned(IsDefined) AND IsDefined(Symbol);
          END;
        END;
      END;
    END ELSE BEGIN
      // A bare symbol, junk or nothing where an operand is required.
      Valid := False;
      Result := False;
      IF Tok <> '' THEN
        Next;
    END;
  END;

  FUNCTION ParseAnd: Boolean;
  VAR
    Right           : Boolean;
  BEGIN
    Result := ParseFactor;
    WHILE Valid AND (Tok = 'and') DO BEGIN
      Next;
      Right := ParseFactor;
      Result := Result AND Right;
    END;
  END;

  FUNCTION ParseOr: Boolean;
  VAR
    Right           : Boolean;
  BEGIN
    Result := ParseAnd;
    WHILE Valid AND (Tok = 'or') DO BEGIN
      Next;
      Right := ParseAnd;
      Result := Result OR Right;
    END;
  END;

BEGIN
  Valid := True;
  P := 1;
  Next;
  IF Tok = '' THEN
    Valid := False;                     // nothing to evaluate
  Result := Valid AND ParseOr;
  IF Tok <> '' THEN
    Valid := False;                     // trailing junk, or an operand where an operator should be
  IF NOT Valid THEN
    Result := False;
END;

FUNCTION TCustomWordCodeHighlighter.TokenizeLine(CONST ALine: STRING; ALineIndex: Integer):
  TCodeTokenArray;
VAR
  EndState          : Integer;
BEGIN
  Result := TokenizeLineState(ALine, 0, EndState);
END;

FUNCTION TCustomWordCodeHighlighter.TokenizeLineState(CONST ALine: STRING; StartState: Integer;
  OUT EndState: Integer): TCodeTokenArray;
VAR
  Tokens            : TList<TCodeToken>;
  I                 : Integer;
  Start             : Integer;
  Text              : STRING;
  RangeIndex        : Integer;
  CloseAt           : Integer;
  Range             : TCodeMultiLineRange;
  State             : TCodeLineState;
  DirectiveLength   : Integer;

  PROCEDURE AddToken(AStart, ALength: Integer; AKind: TCodeTokenKind);
  BEGIN
    IF ALength <= 0 THEN
      Exit;
    // Everything inside a compiled-out branch is dimmed, directives and
    // blanks aside, so the reader sees at a glance what the compiler skips.
    IF (AKind <> tkDirective) AND (AKind <> tkWhitespace) AND NOT CondActive(State.Levels) THEN
      AKind := tkInactive;
    Tokens.Add(MakeToken(AStart, ALength, AKind));
  END;

  FUNCTION TryRangeStart(Index: Integer; OUT FoundRange: Integer): Boolean;
  VAR
    R               : Integer;
  BEGIN
    FOR R := 0 TO FMultiLineRanges.Count - 1 DO
      IF StartsTextAt(ALine, Index, FMultiLineRanges[R].StartDelimiter, True) THEN BEGIN
        FoundRange := R;
        Exit(True);
      END;
    FoundRange := -1;
    Result := False;
  END;

BEGIN
  State := StateFor(StartState);
  RangeIndex := State.Range;
  State.Range := 0;
  Tokens := TList<TCodeToken>.Create;
  TRY
    I := 1;

    // A multi-line construct left open by the previous line consumes this line
    // until its end delimiter (or to the end of the line, keeping the state).
    IF (RangeIndex >= 1) AND (RangeIndex <= FMultiLineRanges.Count) THEN BEGIN
      Range := FMultiLineRanges[RangeIndex - 1];
      CloseAt := PosEx(Range.EndDelimiter, ALine, 1);
      IF CloseAt = 0 THEN BEGIN
        AddToken(1, Length(ALine), Range.Kind);
        State.Range := RangeIndex;
        I := Length(ALine) + 1;
      END ELSE BEGIN
        I := CloseAt + Length(Range.EndDelimiter);
        AddToken(1, I - 1, Range.Kind);
      END;
    END;

    WHILE I <= Length(ALine) DO BEGIN
      IF ALine[I].IsWhiteSpace THEN BEGIN
        Start := I;
        REPEAT
          Inc(I);
        UNTIL (I > Length(ALine)) OR NOT ALine[I].IsWhiteSpace;
        AddToken(Start, I - Start, tkWhitespace);
      END ELSE IF IsLineComment(ALine, I) THEN BEGIN
        AddToken(I, Length(ALine) - I + 1, tkComment);
        Break;
      END ELSE IF TryDirective(ALine, I, State, DirectiveLength) THEN BEGIN
        // Before the ranges: '{#ifdef' would otherwise open a '{' comment.
        AddToken(I, DirectiveLength, tkDirective);
        Inc(I, DirectiveLength);
      END ELSE IF TryRangeStart(I, RangeIndex) THEN BEGIN
        Range := FMultiLineRanges[RangeIndex];
        Start := I;
        CloseAt := PosEx(Range.EndDelimiter, ALine, I + Length(Range.StartDelimiter));
        IF CloseAt = 0 THEN BEGIN
          AddToken(Start, Length(ALine) - Start + 1, Range.Kind);
          State.Range := RangeIndex + 1;
          Break;
        END;
        I := CloseAt + Length(Range.EndDelimiter);
        AddToken(Start, I - Start, Range.Kind);
      END ELSE IF IsStringStart(ALine[I]) THEN BEGIN
        Start := I;
        I := ReadString(ALine, I);
        AddToken(Start, I - Start, tkString);
      END ELSE IF IsNumberStart(ALine, I) THEN BEGIN
        Start := I;
        I := ReadNumber(ALine, I);
        AddToken(Start, I - Start, tkNumber);
      END ELSE IF IsIdentifierStart(ALine[I]) THEN BEGIN
        Start := I;
        I := ReadIdentifier(ALine, I);
        Text := Copy(ALine, Start, I - Start);
        AddToken(Start, I - Start, TokenKindForIdentifier(Text));
      END ELSE BEGIN
        AddToken(I, 1, tkSymbol);
        Inc(I);
      END;
    END;

    EndState := InternState(State);
    Result := Tokens.ToArray;
  FINALLY
    Tokens.Free;
  END;
END;

CONSTRUCTOR TDelphiCodeHighlighter.Create(AOwner: TComponent);
BEGIN
  INHERITED;
  FDefines := TStringList.Create;
  FDefines.CaseSensitive := False;
  FDefines.Duplicates := dupIgnore;
  FDefines.OnChange := DefinesChanged;
  FConditionalPrefix := '{#';
END;

DESTRUCTOR TDelphiCodeHighlighter.Destroy;
BEGIN
  FDefines.Free;
  INHERITED;
END;

PROCEDURE TDelphiCodeHighlighter.DefinesChanged(Sender: TObject);
BEGIN
  Changed;
END;

FUNCTION TDelphiCodeHighlighter.GetDefines: TStrings;
BEGIN
  Result := FDefines;
END;

PROCEDURE TDelphiCodeHighlighter.SetDefines(Value: TStrings);
BEGIN
  FDefines.Assign(Value);                // fires DefinesChanged
END;

PROCEDURE TDelphiCodeHighlighter.SetConditionalPrefix(CONST Value: STRING);
BEGIN
  IF FConditionalPrefix <> Value THEN BEGIN
    FConditionalPrefix := Value;
    Changed;
  END;
END;

FUNCTION TDelphiCodeHighlighter.IsDefined(CONST Symbol: STRING): Boolean;
BEGIN
  Result := FDefines.IndexOf(Symbol) >= 0;
  IF Assigned(FOnIsDefined) THEN
    FOnIsDefined(Self, Symbol, Result);
END;

FUNCTION TDelphiCodeHighlighter.IsDefinedAt(CONST Symbol: STRING;
  CONST State: TCodeLineState): Boolean;
BEGIN
  // A {#define} in the text wins over everything; a {#undef} in the text
  // cancels a host define; otherwise the host decides.
  IF SymbolListHas(State.Defined, Symbol) THEN
    Result := True
  ELSE IF SymbolListHas(State.Undefined, Symbol) THEN
    Result := False
  ELSE
    Result := IsDefined(Symbol);
END;

FUNCTION TDelphiCodeHighlighter.EvaluateAt(CONST Expr: STRING;
  CONST State: TCodeLineState): Boolean;
VAR
  Snapshot          : TCodeLineState;
  Valid             : Boolean;
BEGIN
  Snapshot := State;                    // a VAR/CONST parameter can't be captured, a local can
  Result := EvaluateConditionalExpression(Expr,
    FUNCTION(CONST Symbol: STRING): Boolean
    BEGIN
      Result := IsDefinedAt(Symbol, Snapshot);
    END, Valid);
  // A typo in the expression must not hide code: show the branch.
  IF NOT Valid THEN
    Result := True;
END;

FUNCTION TDelphiCodeHighlighter.TryDirective(CONST ALine: STRING; Index: Integer;
  VAR State: TCodeLineState; OUT TokenLength: Integer): Boolean;
VAR
  CloseAt           : Integer;
  Body              : STRING;
  SpaceAt           : Integer;
  Word              : STRING;
  Arg               : STRING;
  ParentActive      : Boolean;
  Active            : Boolean;
BEGIN
  TokenLength := 0;
  Result := (FConditionalPrefix <> '') AND StartsTextAt(ALine, Index, FConditionalPrefix, True);
  IF NOT Result THEN
    Exit;
  // The whole directive must sit on this line; otherwise it is an ordinary
  // (unterminated) comment and the range handling takes it.
  CloseAt := PosEx('}', ALine, Index + Length(FConditionalPrefix));
  IF CloseAt = 0 THEN
    Exit(False);
  TokenLength := CloseAt - Index + 1;

  Body := Trim(Copy(ALine, Index + Length(FConditionalPrefix),
    CloseAt - Index - Length(FConditionalPrefix)));
  SpaceAt := Pos(' ', Body);
  IF SpaceAt = 0 THEN BEGIN
    Word := LowerCase(Body);
    Arg := '';
  END ELSE BEGIN
    Word := LowerCase(Copy(Body, 1, SpaceAt - 1));
    Arg := Trim(Copy(Body, SpaceAt + 1, MaxInt));
  END;

  // A branch nested inside an inactive one is never active, and counts as
  // "taken" so its else stays inactive too.
  ParentActive := CondActive(State.Levels);
  IF Word = 'ifdef' THEN BEGIN
    Active := ParentActive AND IsDefinedAt(Arg, State);
    CondPush(State.Levels, Active, Active OR NOT ParentActive);
  END ELSE IF Word = 'ifndef' THEN BEGIN
    Active := ParentActive AND NOT IsDefinedAt(Arg, State);
    CondPush(State.Levels, Active, Active OR NOT ParentActive);
  END ELSE IF Word = 'if' THEN BEGIN
    Active := ParentActive AND EvaluateAt(Arg, State);
    CondPush(State.Levels, Active, Active OR NOT ParentActive);
  END ELSE IF (Word = 'elseif') OR (Word = 'elif') THEN
    // Evaluated only if it could matter: a chain already taken stays taken.
    CondElseIf(State.Levels, ParentActive OR EvaluateAt(Arg, State))
  ELSE IF Word = 'else' THEN
    CondElse(State.Levels)
  ELSE IF (Word = 'endif') OR (Word = 'ifend') THEN
    CondPop(State.Levels)
  // {#define} / {#undef} written by the script author take effect from here
  // down - but not when the compiler would skip them.
  ELSE IF (Word = 'define') AND ParentActive AND (Arg <> '') THEN BEGIN
    SymbolListAdd(State.Defined, Arg);
    SymbolListRemove(State.Undefined, Arg);
  END ELSE IF (Word = 'undef') AND ParentActive AND (Arg <> '') THEN BEGIN
    SymbolListRemove(State.Defined, Arg);
    SymbolListAdd(State.Undefined, Arg);
  END;
  // Any other {#...} is still shown as a directive.
END;

PROCEDURE TDelphiCodeHighlighter.BuildKeywords;
BEGIN
  AddKeywords([
      'absolute', 'abstract', 'and', 'array', 'as', 'asm', 'begin', 'case',
      'class', 'const', 'constructor', 'destructor', 'dispinterface', 'div',
      'do', 'downto', 'else', 'end', 'except', 'exports', 'file', 'final',
      'finalization', 'finally', 'for', 'function', 'goto', 'if',
      'implementation', 'in', 'inherited', 'initialization', 'inline',
      'interface', 'is', 'label', 'library', 'mod', 'nil', 'not', 'object',
      'of', 'or', 'out', 'overload', 'override', 'packed', 'private',
      'procedure', 'program', 'property', 'protected', 'public', 'published',
      'raise', 'record', 'repeat', 'resourcestring', 'sealed', 'set', 'shl',
      'shr', 'static', 'strict', 'string', 'then', 'threadvar', 'to', 'try',
      'type', 'unit', 'unsafe', 'until', 'uses', 'var', 'virtual', 'while',
      'with', 'xor', 'read', 'write', 'default', 'stored'
      ]);
END;

PROCEDURE TDelphiCodeHighlighter.BuildMultiLineRanges;
BEGIN
  AddMultiLineRange('(*', '*)');
  AddMultiLineRange('{', '}');
END;

FUNCTION TDelphiCodeHighlighter.IsNumberStart(CONST ALine: STRING; Index: Integer): Boolean;
BEGIN
  Result := INHERITED IsNumberStart(ALine, Index) OR (ALine[Index] = '$');
END;

FUNCTION TDelphiCodeHighlighter.ReadNumber(CONST ALine: STRING; Index: Integer): Integer;
BEGIN
  Result := Index;
  IF ALine[Index] = '$' THEN BEGIN
    REPEAT
      Inc(Result);
    UNTIL (Result > Length(ALine)) OR NOT (ALine[Result].IsDigit OR CharInSet(UpCase(ALine[Result]),
      ['A'..'F']));
  END ELSE
    Result := INHERITED ReadNumber(ALine, Index);
END;

FUNCTION TDelphiCodeHighlighter.ReadString(CONST ALine: STRING; Index: Integer): Integer;
BEGIN
  Result := INHERITED ReadString(ALine, Index);
END;

PROCEDURE TDelphiCodeHighlighter.SetDefaultStyles;
VAR
  Style             : TCodeTextStyle;
BEGIN
  INHERITED;
  Style := Styles[tkKeyword];
  Style.Foreground := $00B06000;
  Styles[tkKeyword] := Style;

  Style := Styles[tkString];
  Style.Foreground := $00008000;
  Styles[tkString] := Style;

  Style := Styles[tkComment];
  Style.Foreground := $00808080;
  Style.FontStyle := [fsItalic];
  Styles[tkComment] := Style;

  Style := Styles[tkNumber];
  Style.Foreground := $00800080;
  Styles[tkNumber] := Style;

  Style := Styles[tkInactive];
  Style.Foreground := $00A8A8A8;
  Style.FontStyle := [];
  Styles[tkInactive] := Style;
END;

PROCEDURE TJavaScriptCodeHighlighter.BuildKeywords;
BEGIN
  AddKeywords([
      'await', 'async', 'break', 'case', 'catch', 'class', 'const', 'continue',
      'debugger', 'default', 'delete', 'do', 'else', 'export', 'extends',
      'false', 'finally', 'for', 'from', 'function', 'get', 'if', 'import',
      'in', 'instanceof', 'let', 'new', 'null', 'of', 'return', 'set',
      'static', 'super', 'switch', 'this', 'throw', 'true', 'try', 'typeof',
      'undefined', 'var', 'void', 'while', 'with', 'yield'
      ]);
END;

FUNCTION TJavaScriptCodeHighlighter.CaseSensitive: Boolean;
BEGIN
  Result := True;
END;

PROCEDURE TJavaScriptCodeHighlighter.BuildMultiLineRanges;
BEGIN
  AddMultiLineRange('/*', '*/');
  // Template literals may span lines.
  AddMultiLineRange('`', '`', tkString);
END;

FUNCTION TJavaScriptCodeHighlighter.IsStringStart(Ch: Char): Boolean;
BEGIN
  Result := CharInSet(Ch, ['''', '"']);
END;

FUNCTION TJavaScriptCodeHighlighter.ReadNumber(CONST ALine: STRING; Index: Integer): Integer;
BEGIN
  Result := Index;
  REPEAT
    Inc(Result);
  UNTIL (Result > Length(ALine)) OR NOT (ALine[Result].IsLetterOrDigit OR
    CharInSet(ALine[Result], ['.', '_', 'x', 'X', 'b', 'B', 'o', 'O']));
END;

FUNCTION TJavaScriptCodeHighlighter.ReadString(CONST ALine: STRING; Index: Integer): Integer;
VAR
  Quote             : Char;
  Escaped           : Boolean;
BEGIN
  Quote := ALine[Index];
  Escaped := False;
  Result := Index + 1;
  WHILE Result <= Length(ALine) DO BEGIN
    IF Escaped THEN
      Escaped := False
    ELSE IF ALine[Result] = '\' THEN
      Escaped := True
    ELSE IF ALine[Result] = Quote THEN BEGIN
      Inc(Result);
      Break;
    END;
    Inc(Result);
  END;
END;

PROCEDURE TSqlCodeHighlighter.BuildKeywords;
BEGIN
  AddKeywords([
      'add', 'alter', 'and', 'as', 'asc', 'begin', 'between', 'by', 'case',
      'cast', 'check', 'column', 'commit', 'constraint', 'create', 'cross',
      'database', 'default', 'delete', 'desc', 'distinct', 'drop', 'else',
      'end', 'except', 'exists', 'foreign', 'from', 'full', 'group', 'having',
      'in', 'index', 'inner', 'insert', 'intersect', 'into', 'is', 'join',
      'key', 'left', 'like', 'not', 'null', 'on', 'or', 'order', 'outer',
      'primary', 'procedure', 'references', 'right', 'rollback', 'select',
      'set', 'table', 'then', 'top', 'transaction', 'trigger', 'union',
      'unique', 'update', 'values', 'view', 'when', 'where', 'with'
      ]);
END;

PROCEDURE TSqlCodeHighlighter.BuildMultiLineRanges;
BEGIN
  AddMultiLineRange('/*', '*/');
END;

FUNCTION TSqlCodeHighlighter.IsLineComment(CONST ALine: STRING; Index: Integer): Boolean;
BEGIN
  Result := StartsTextAt(ALine, Index, '--', True);
END;

FUNCTION TSqlCodeHighlighter.IsStringStart(Ch: Char): Boolean;
BEGIN
  Result := CharInSet(Ch, ['''', '"', '[']);
END;

FUNCTION TSqlCodeHighlighter.ReadString(CONST ALine: STRING; Index: Integer): Integer;
VAR
  Quote             : Char;
BEGIN
  IF ALine[Index] = '[' THEN BEGIN
    Result := Index + 1;
    WHILE (Result <= Length(ALine)) AND (ALine[Result] <> ']') DO
      Inc(Result);
    IF Result <= Length(ALine) THEN
      Inc(Result);
    Exit;
  END;

  Quote := ALine[Index];
  Result := Index + 1;
  WHILE Result <= Length(ALine) DO BEGIN
    IF ALine[Result] = Quote THEN BEGIN
      Inc(Result);
      IF (Result <= Length(ALine)) AND (ALine[Result] = Quote) THEN
        Inc(Result)
      ELSE
        Break;
    END ELSE
      Inc(Result);
  END;
END;

PROCEDURE TTungliCodeHighlighter.BuildKeywords;
BEGIN
  AddKeywords([
      'if', 'then', 'else', 'while', 'do', 'procedure', 'exec', 'break',
      'continue', 'exit', 'beep', 'end', 'and', 'or', 'not', 'div', 'mod',
      'in', 'like', 'wildcard',
      '_now', '_date', '_time', '_lf', '_tb', '_pi'
      ]);
END;

PROCEDURE TTungliCodeHighlighter.BuildMultiLineRanges;
BEGIN
  AddMultiLineRange('/*', '*/');
END;

FUNCTION TTungliCodeHighlighter.IsLineComment(CONST ALine: STRING; Index: Integer): Boolean;
BEGIN
  Result := False;
END;

FUNCTION TTungliCodeHighlighter.IsStringStart(Ch: Char): Boolean;
BEGIN
  Result := Ch = '"';
END;

FUNCTION TTungliCodeHighlighter.ReadString(CONST ALine: STRING; Index: Integer): Integer;
VAR
  Quote             : Char;
BEGIN
  Quote := ALine[Index];
  Result := Index + 1;
  WHILE (Result <= Length(ALine)) AND (ALine[Result] <> Quote) DO
    Inc(Result);
  IF Result <= Length(ALine) THEN
    Inc(Result);
END;

PROCEDURE TBatchCodeHighlighter.BuildKeywords;
BEGIN
  AddKeywords([
      'if', 'else', 'for', 'in', 'do', 'goto', 'call', 'exit', 'exist', 'not',
      'defined', 'errorlevel', 'equ', 'neq', 'lss', 'leq', 'gtr', 'geq',
      'echo', 'set', 'setlocal', 'endlocal', 'pause', 'start', 'shift',
      'choice', 'rem', 'cls', 'title', 'color', 'prompt', 'pushd', 'popd',
      'cd', 'chdir', 'md', 'mkdir', 'rd', 'rmdir', 'del', 'erase', 'copy',
      'xcopy', 'move', 'ren', 'rename', 'type', 'find', 'findstr', 'sort',
      'more', 'attrib', 'date', 'time', 'ver', 'vol', 'chcp', 'tasklist',
      'taskkill', 'where', 'verify', 'assoc', 'ftype', 'enableextensions',
      'enabledelayedexpansion', 'disableextensions', 'disabledelayedexpansion'
      ]);
END;

FUNCTION TBatchCodeHighlighter.IsLineComment(CONST ALine: STRING; Index: Integer): Boolean;
VAR
  J                 : Integer;
BEGIN
  IF StartsTextAt(ALine, Index, '::', True) THEN
    Exit(True);

  IF NOT StartsTextAt(ALine, Index, 'rem', False) THEN
    Exit(False);

  J := Index + 3;
  IF (J <= Length(ALine)) AND IsIdentifierChar(ALine[J]) THEN
    Exit(False);

  FOR J := 1 TO Index - 1 DO
    IF NOT ALine[J].IsWhiteSpace THEN
      Exit(False);

  Result := True;
END;

FUNCTION TBatchCodeHighlighter.IsStringStart(Ch: Char): Boolean;
BEGIN
  Result := Ch = '"';
END;

FUNCTION TBatchCodeHighlighter.ReadString(CONST ALine: STRING; Index: Integer): Integer;
BEGIN
  Result := Index + 1;
  WHILE (Result <= Length(ALine)) AND (ALine[Result] <> '"') DO
    Inc(Result);
  IF Result <= Length(ALine) THEN
    Inc(Result);
END;

PROCEDURE TPowerShellCodeHighlighter.BuildKeywords;
BEGIN
  AddKeywords([
      'begin', 'break', 'catch', 'class', 'continue', 'data', 'define', 'do',
      'dynamicparam', 'else', 'elseif', 'end', 'enum', 'exit', 'filter',
      'finally', 'for', 'foreach', 'from', 'function', 'hidden', 'if', 'in',
      'inlinescript', 'parallel', 'param', 'process', 'return', 'sequence',
      'static', 'switch', 'throw', 'trap', 'try', 'until', 'using', 'var',
      'while', 'workflow',
      'true', 'false', 'null'
      ]);
END;

PROCEDURE TPowerShellCodeHighlighter.BuildMultiLineRanges;
BEGIN
  AddMultiLineRange('<#', '#>');
END;

FUNCTION TPowerShellCodeHighlighter.IsLineComment(CONST ALine: STRING; Index: Integer): Boolean;
BEGIN
  Result := StartsTextAt(ALine, Index, '#', True);
END;

FUNCTION TPowerShellCodeHighlighter.IsStringStart(Ch: Char): Boolean;
BEGIN
  Result := CharInSet(Ch, ['''', '"']);
END;

FUNCTION TPowerShellCodeHighlighter.ReadString(CONST ALine: STRING; Index: Integer): Integer;
VAR
  Quote             : Char;
  Escaped           : Boolean;
BEGIN
  Quote := ALine[Index];
  Result := Index + 1;
  IF Quote = '"' THEN BEGIN
    Escaped := False;
    WHILE Result <= Length(ALine) DO BEGIN
      IF Escaped THEN
        Escaped := False
      ELSE IF ALine[Result] = '`' THEN
        Escaped := True
      ELSE IF ALine[Result] = Quote THEN BEGIN
        Inc(Result);
        Break;
      END;
      Inc(Result);
    END;
  END ELSE BEGIN
    WHILE Result <= Length(ALine) DO BEGIN
      IF ALine[Result] = Quote THEN BEGIN
        Inc(Result);
        IF (Result <= Length(ALine)) AND (ALine[Result] = Quote) THEN
          Inc(Result)
        ELSE
          Break;
      END ELSE
        Inc(Result);
    END;
  END;
END;

PROCEDURE TIniCodeHighlighter.BuildKeywords;
BEGIN
  AddKeywords([
      'true', 'false', 'yes', 'no', 'on', 'off', 'null'
      ]);
END;

FUNCTION TIniCodeHighlighter.IsLineComment(CONST ALine: STRING; Index: Integer): Boolean;
BEGIN
  Result := StartsTextAt(ALine, Index, ';', True) OR
    StartsTextAt(ALine, Index, '#', True);
END;

FUNCTION TIniCodeHighlighter.IsStringStart(Ch: Char): Boolean;
BEGIN
  Result := CharInSet(Ch, ['''', '"', '[']);
END;

FUNCTION TIniCodeHighlighter.ReadString(CONST ALine: STRING; Index: Integer): Integer;
VAR
  Quote             : Char;
BEGIN
  IF ALine[Index] = '[' THEN BEGIN
    Result := Index + 1;
    WHILE (Result <= Length(ALine)) AND (ALine[Result] <> ']') DO
      Inc(Result);
    IF Result <= Length(ALine) THEN
      Inc(Result);
    Exit;
  END;

  Quote := ALine[Index];
  Result := Index + 1;
  WHILE (Result <= Length(ALine)) AND (ALine[Result] <> Quote) DO
    Inc(Result);
  IF Result <= Length(ALine) THEN
    Inc(Result);
END;

PROCEDURE TYamlCodeHighlighter.BuildKeywords;
BEGIN
  AddKeywords([
      'true', 'false', 'yes', 'no', 'on', 'off', 'null'
      ]);
END;

FUNCTION TYamlCodeHighlighter.IsLineComment(CONST ALine: STRING; Index: Integer): Boolean;
BEGIN
  Result := StartsTextAt(ALine, Index, '#', True);
END;

FUNCTION TYamlCodeHighlighter.IsStringStart(Ch: Char): Boolean;
BEGIN
  Result := CharInSet(Ch, ['''', '"']);
END;

FUNCTION TYamlCodeHighlighter.ReadString(CONST ALine: STRING; Index: Integer): Integer;
VAR
  Quote             : Char;
  Escaped           : Boolean;
BEGIN
  Quote := ALine[Index];
  Result := Index + 1;
  IF Quote = '"' THEN BEGIN
    Escaped := False;
    WHILE Result <= Length(ALine) DO BEGIN
      IF Escaped THEN
        Escaped := False
      ELSE IF ALine[Result] = '\' THEN
        Escaped := True
      ELSE IF ALine[Result] = Quote THEN BEGIN
        Inc(Result);
        Break;
      END;
      Inc(Result);
    END;
  END ELSE BEGIN
    WHILE Result <= Length(ALine) DO BEGIN
      IF ALine[Result] = Quote THEN BEGIN
        Inc(Result);
        IF (Result <= Length(ALine)) AND (ALine[Result] = Quote) THEN
          Inc(Result)
        ELSE
          Break;
      END ELSE
        Inc(Result);
    END;
  END;
END;

PROCEDURE TPythonCodeHighlighter.BuildKeywords;
BEGIN
  AddKeywords([
      'False', 'None', 'True', 'and', 'as', 'assert', 'async', 'await',
      'break', 'class', 'continue', 'def', 'del', 'elif', 'else', 'except',
      'finally', 'for', 'from', 'global', 'if', 'import', 'in', 'is',
      'lambda', 'nonlocal', 'not', 'or', 'pass', 'raise', 'return', 'try',
      'while', 'with', 'yield', 'match', 'case'
      ]);
END;

PROCEDURE TPythonCodeHighlighter.BuildMultiLineRanges;
BEGIN
  AddMultiLineRange('"""', '"""', tkString);
  AddMultiLineRange('''''''', '''''''', tkString);
END;

FUNCTION TPythonCodeHighlighter.CaseSensitive: Boolean;
BEGIN
  Result := True;
END;

FUNCTION TPythonCodeHighlighter.IsLineComment(CONST ALine: STRING; Index: Integer): Boolean;
BEGIN
  Result := StartsTextAt(ALine, Index, '#', True);
END;

FUNCTION TPythonCodeHighlighter.IsStringStart(Ch: Char): Boolean;
BEGIN
  Result := CharInSet(Ch, ['''', '"']);
END;

FUNCTION TPythonCodeHighlighter.ReadNumber(CONST ALine: STRING; Index: Integer): Integer;
BEGIN
  Result := Index;
  REPEAT
    Inc(Result);
  UNTIL (Result > Length(ALine)) OR NOT (ALine[Result].IsLetterOrDigit OR
    CharInSet(ALine[Result], ['.', '_']));
END;

FUNCTION TPythonCodeHighlighter.ReadString(CONST ALine: STRING; Index: Integer): Integer;
VAR
  Quote             : Char;
  Escaped           : Boolean;
BEGIN
  // Triple-quoted strings are handled by the multi-line ranges; this only
  // sees single-quoted forms.
  Quote := ALine[Index];
  Escaped := False;
  Result := Index + 1;
  WHILE Result <= Length(ALine) DO BEGIN
    IF Escaped THEN
      Escaped := False
    ELSE IF ALine[Result] = '\' THEN
      Escaped := True
    ELSE IF ALine[Result] = Quote THEN BEGIN
      Inc(Result);
      Break;
    END;
    Inc(Result);
  END;
END;

CLASS FUNCTION TSqlCodeHighlighter.LanguageName: STRING;
BEGIN
  Result := 'SQL';
END;

CLASS FUNCTION TIniCodeHighlighter.LanguageName: STRING;
BEGIN
  Result := 'INI';
END;

CLASS FUNCTION TYamlCodeHighlighter.LanguageName: STRING;
BEGIN
  Result := 'YAML';
END;

END.

