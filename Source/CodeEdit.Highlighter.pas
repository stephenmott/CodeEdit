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
    tkSymbol
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
    FUNCTION GetStyle(Kind: TCodeTokenKind): TCodeTextStyle;
    PROCEDURE SetStyle(Kind: TCodeTokenKind; CONST Value: TCodeTextStyle);
  PROTECTED
    PROCEDURE SetDefaultStyles; VIRTUAL;
  PUBLIC
    CONSTRUCTOR Create(AOwner: TComponent); OVERRIDE;
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

  TCustomWordCodeHighlighter = CLASS(TCustomCodeHighlighter)
  PRIVATE
    FKeywords: TDictionary<STRING, Boolean>;
    FMultiLineRanges: TList<TCodeMultiLineRange>;
  PROTECTED
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

  TDelphiCodeHighlighter = CLASS(TCustomWordCodeHighlighter)
  PROTECTED
    PROCEDURE BuildKeywords; OVERRIDE;
    PROCEDURE BuildMultiLineRanges; OVERRIDE;
    FUNCTION IsNumberStart(CONST ALine: STRING; Index: Integer): Boolean; OVERRIDE;
    FUNCTION ReadNumber(CONST ALine: STRING; Index: Integer): Integer; OVERRIDE;
    FUNCTION ReadString(CONST ALine: STRING; Index: Integer): Integer; OVERRIDE;
    PROCEDURE SetDefaultStyles; OVERRIDE;
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
  BuildKeywords;
  BuildMultiLineRanges;
END;

DESTRUCTOR TCustomWordCodeHighlighter.Destroy;
BEGIN
  FMultiLineRanges.Free;
  FKeywords.Free;
  INHERITED;
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

  PROCEDURE AddToken(AStart, ALength: Integer; AKind: TCodeTokenKind);
  BEGIN
    IF ALength > 0 THEN
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
  EndState := 0;
  Tokens := TList<TCodeToken>.Create;
  TRY
    I := 1;

    // A multi-line construct left open by the previous line consumes this line
    // until its end delimiter (or to the end of the line, keeping the state).
    IF (StartState >= 1) AND (StartState <= FMultiLineRanges.Count) THEN BEGIN
      Range := FMultiLineRanges[StartState - 1];
      CloseAt := PosEx(Range.EndDelimiter, ALine, 1);
      IF CloseAt = 0 THEN BEGIN
        AddToken(1, Length(ALine), Range.Kind);
        EndState := StartState;
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
      END ELSE IF TryRangeStart(I, RangeIndex) THEN BEGIN
        Range := FMultiLineRanges[RangeIndex];
        Start := I;
        CloseAt := PosEx(Range.EndDelimiter, ALine, I + Length(Range.StartDelimiter));
        IF CloseAt = 0 THEN BEGIN
          AddToken(Start, Length(ALine) - Start + 1, Range.Kind);
          EndState := RangeIndex + 1;
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

    Result := Tokens.ToArray;
  FINALLY
    Tokens.Free;
  END;
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

