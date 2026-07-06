unit CodeEdit.Highlighter;

interface

uses
  System.Classes,
  System.Generics.Collections,
  Vcl.Graphics;

type
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

  TCodeToken = record
    Start: Integer;
    Length: Integer;
    Kind: TCodeTokenKind;
  end;

  TCodeTokenArray = TArray<TCodeToken>;

  TCodeTextStyle = record
    Foreground: TColor;
    Background: TColor;
    FontStyle: TFontStyles;
  end;

  TCustomCodeHighlighter = class(TComponent)
  private
    FStyles: array[TCodeTokenKind] of TCodeTextStyle;
    function GetStyle(Kind: TCodeTokenKind): TCodeTextStyle;
    procedure SetStyle(Kind: TCodeTokenKind; const Value: TCodeTextStyle);
  protected
    procedure SetDefaultStyles; virtual;
  public
    constructor Create(AOwner: TComponent); override;
    // Human-readable language identifier, used to group code templates and
    // similar per-language data. Defaults to the class name without the 'T'
    // prefix and 'CodeHighlighter' suffix, e.g. TDelphiCodeHighlighter ->
    // 'Delphi'. Override for casing the derivation cannot produce ('SQL').
    class function LanguageName: string; virtual;
    function TokenizeLine(const ALine: string; ALineIndex: Integer): TCodeTokenArray; virtual;
    // Stateful tokenization for constructs that span lines (block comments,
    // multi-line strings). StartState is the state the previous line ended in;
    // 0 means "nothing open". Stateless highlighters ignore it.
    function TokenizeLineState(const ALine: string; StartState: Integer;
      out EndState: Integer): TCodeTokenArray; virtual;
    property Styles[Kind: TCodeTokenKind]: TCodeTextStyle read GetStyle write SetStyle;
  end;

  TCodeHighlighterClass = class of TCustomCodeHighlighter;

  // A construct that may span lines, e.g. '(*' .. '*)' or '"""' .. '"""'.
  // Its 1-based index in the registration order is the line state value used
  // by TokenizeLineState while the construct is open.
  TCodeMultiLineRange = record
    StartDelimiter: string;
    EndDelimiter: string;
    Kind: TCodeTokenKind;
  end;

  TCustomWordCodeHighlighter = class(TCustomCodeHighlighter)
  private
    FKeywords: TDictionary<string, Boolean>;
    FMultiLineRanges: TList<TCodeMultiLineRange>;
  protected
    procedure AddKeyword(const Value: string);
    procedure AddKeywords(const Values: array of string);
    procedure AddMultiLineRange(const AStartDelimiter, AEndDelimiter: string;
      AKind: TCodeTokenKind = tkComment);
    procedure BuildKeywords; virtual;
    procedure BuildMultiLineRanges; virtual;
    function CaseSensitive: Boolean; virtual;
    function KeywordKey(const Value: string): string;
    function IsKeyword(const Value: string): Boolean; virtual;
    function IsIdentifierStart(Ch: Char): Boolean; virtual;
    function IsIdentifierChar(Ch: Char): Boolean; virtual;
    function IsLineComment(const ALine: string; Index: Integer): Boolean; virtual;
    function IsNumberStart(const ALine: string; Index: Integer): Boolean; virtual;
    function IsStringStart(Ch: Char): Boolean; virtual;
    function ReadIdentifier(const ALine: string; Index: Integer): Integer; virtual;
    function ReadNumber(const ALine: string; Index: Integer): Integer; virtual;
    function ReadString(const ALine: string; Index: Integer): Integer; virtual;
    function TokenKindForIdentifier(const Value: string): TCodeTokenKind; virtual;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function TokenizeLine(const ALine: string; ALineIndex: Integer): TCodeTokenArray; override;
    function TokenizeLineState(const ALine: string; StartState: Integer;
      out EndState: Integer): TCodeTokenArray; override;
  end;

  TDelphiCodeHighlighter = class(TCustomWordCodeHighlighter)
  protected
    procedure BuildKeywords; override;
    procedure BuildMultiLineRanges; override;
    function IsNumberStart(const ALine: string; Index: Integer): Boolean; override;
    function ReadNumber(const ALine: string; Index: Integer): Integer; override;
    function ReadString(const ALine: string; Index: Integer): Integer; override;
    procedure SetDefaultStyles; override;
  end;

  TJavaScriptCodeHighlighter = class(TCustomWordCodeHighlighter)
  protected
    procedure BuildKeywords; override;
    procedure BuildMultiLineRanges; override;
    function CaseSensitive: Boolean; override;
    function IsStringStart(Ch: Char): Boolean; override;
    function ReadNumber(const ALine: string; Index: Integer): Integer; override;
    function ReadString(const ALine: string; Index: Integer): Integer; override;
  end;

  TSqlCodeHighlighter = class(TCustomWordCodeHighlighter)
  protected
    procedure BuildKeywords; override;
    procedure BuildMultiLineRanges; override;
    function IsLineComment(const ALine: string; Index: Integer): Boolean; override;
    function IsStringStart(Ch: Char): Boolean; override;
    function ReadString(const ALine: string; Index: Integer): Integer; override;
  public
    class function LanguageName: string; override;
  end;

  TTungliCodeHighlighter = class(TCustomWordCodeHighlighter)
  protected
    procedure BuildKeywords; override;
    procedure BuildMultiLineRanges; override;
    function IsLineComment(const ALine: string; Index: Integer): Boolean; override;
    function IsStringStart(Ch: Char): Boolean; override;
    function ReadString(const ALine: string; Index: Integer): Integer; override;
  end;

  TBatchCodeHighlighter = class(TCustomWordCodeHighlighter)
  protected
    procedure BuildKeywords; override;
    function IsLineComment(const ALine: string; Index: Integer): Boolean; override;
    function IsStringStart(Ch: Char): Boolean; override;
    function ReadString(const ALine: string; Index: Integer): Integer; override;
  end;

  TPowerShellCodeHighlighter = class(TCustomWordCodeHighlighter)
  protected
    procedure BuildKeywords; override;
    procedure BuildMultiLineRanges; override;
    function IsLineComment(const ALine: string; Index: Integer): Boolean; override;
    function IsStringStart(Ch: Char): Boolean; override;
    function ReadString(const ALine: string; Index: Integer): Integer; override;
  end;

  TIniCodeHighlighter = class(TCustomWordCodeHighlighter)
  protected
    procedure BuildKeywords; override;
    function IsLineComment(const ALine: string; Index: Integer): Boolean; override;
    function IsStringStart(Ch: Char): Boolean; override;
    function ReadString(const ALine: string; Index: Integer): Integer; override;
  public
    class function LanguageName: string; override;
  end;

  TYamlCodeHighlighter = class(TCustomWordCodeHighlighter)
  protected
    procedure BuildKeywords; override;
    function IsLineComment(const ALine: string; Index: Integer): Boolean; override;
    function IsStringStart(Ch: Char): Boolean; override;
    function ReadString(const ALine: string; Index: Integer): Integer; override;
  public
    class function LanguageName: string; override;
  end;

  TPythonCodeHighlighter = class(TCustomWordCodeHighlighter)
  protected
    procedure BuildKeywords; override;
    procedure BuildMultiLineRanges; override;
    function CaseSensitive: Boolean; override;
    function IsLineComment(const ALine: string; Index: Integer): Boolean; override;
    function IsStringStart(Ch: Char): Boolean; override;
    function ReadNumber(const ALine: string; Index: Integer): Integer; override;
    function ReadString(const ALine: string; Index: Integer): Integer; override;
  end;

implementation

uses
  System.Character,
  System.StrUtils,
  System.SysUtils;

function MakeToken(AStart, ALength: Integer; AKind: TCodeTokenKind): TCodeToken;
begin
  Result.Start := AStart;
  Result.Length := ALength;
  Result.Kind := AKind;
end;

function TokenArrayOf(const Token: TCodeToken): TCodeTokenArray;
begin
  SetLength(Result, 1);
  Result[0] := Token;
end;

function StartsTextAt(const ALine: string; Index: Integer; const Value: string;
  CaseSensitive: Boolean): Boolean;
begin
  if Value = '' then
    Exit(False);

  if Index + Length(Value) - 1 > Length(ALine) then
    Exit(False);

  if CaseSensitive then
    Result := Copy(ALine, Index, Length(Value)) = Value
  else
    Result := SameText(Copy(ALine, Index, Length(Value)), Value);
end;

constructor TCustomCodeHighlighter.Create(AOwner: TComponent);
begin
  inherited;
  SetDefaultStyles;
end;

class function TCustomCodeHighlighter.LanguageName: string;
const
  Suffixes: array[0..1] of string = ('CodeHighlighter', 'Highlighter');
var
  Suffix: string;
begin
  Result := ClassName;
  if (Result <> '') and (Result[1] = 'T') then
    Delete(Result, 1, 1);
  for Suffix in Suffixes do
    if EndsText(Suffix, Result) and (Length(Result) > Length(Suffix)) then
    begin
      SetLength(Result, Length(Result) - Length(Suffix));
      Break;
    end;
end;

procedure TCustomCodeHighlighter.SetDefaultStyles;
var
  Kind: TCodeTokenKind;
begin
  for Kind := Low(TCodeTokenKind) to High(TCodeTokenKind) do
  begin
    FStyles[Kind].Foreground := clWindowText;
    FStyles[Kind].Background := clNone;
    FStyles[Kind].FontStyle := [];
  end;

  FStyles[tkComment].Foreground := $00808080;
  FStyles[tkString].Foreground := $00008000;
  FStyles[tkNumber].Foreground := $00A00000;
  FStyles[tkKeyword].Foreground := $00C04000;
  FStyles[tkKeyword].FontStyle := [fsBold];
  FStyles[tkSymbol].Foreground := $00606060;
end;

function TCustomCodeHighlighter.TokenizeLine(const ALine: string; ALineIndex: Integer): TCodeTokenArray;
begin
  Result := TokenArrayOf(MakeToken(1, Length(ALine), tkText));
end;

function TCustomCodeHighlighter.TokenizeLineState(const ALine: string; StartState: Integer;
  out EndState: Integer): TCodeTokenArray;
begin
  // Stateless default: highlighters that only override TokenizeLine keep working.
  EndState := 0;
  Result := TokenizeLine(ALine, 0);
end;

function TCustomCodeHighlighter.GetStyle(Kind: TCodeTokenKind): TCodeTextStyle;
begin
  Result := FStyles[Kind];
end;

procedure TCustomCodeHighlighter.SetStyle(Kind: TCodeTokenKind; const Value: TCodeTextStyle);
begin
  FStyles[Kind] := Value;
end;

constructor TCustomWordCodeHighlighter.Create(AOwner: TComponent);
begin
  inherited;
  FKeywords := TDictionary<string, Boolean>.Create;
  FMultiLineRanges := TList<TCodeMultiLineRange>.Create;
  BuildKeywords;
  BuildMultiLineRanges;
end;

destructor TCustomWordCodeHighlighter.Destroy;
begin
  FMultiLineRanges.Free;
  FKeywords.Free;
  inherited;
end;

procedure TCustomWordCodeHighlighter.AddMultiLineRange(const AStartDelimiter, AEndDelimiter: string;
  AKind: TCodeTokenKind);
var
  Range: TCodeMultiLineRange;
begin
  Range.StartDelimiter := AStartDelimiter;
  Range.EndDelimiter := AEndDelimiter;
  Range.Kind := AKind;
  FMultiLineRanges.Add(Range);
end;

procedure TCustomWordCodeHighlighter.BuildMultiLineRanges;
begin
end;

procedure TCustomWordCodeHighlighter.AddKeyword(const Value: string);
begin
  FKeywords.AddOrSetValue(KeywordKey(Value), True);
end;

procedure TCustomWordCodeHighlighter.AddKeywords(const Values: array of string);
var
  Value: string;
begin
  for Value in Values do
    AddKeyword(Value);
end;

procedure TCustomWordCodeHighlighter.BuildKeywords;
begin
end;

function TCustomWordCodeHighlighter.CaseSensitive: Boolean;
begin
  Result := False;
end;

function TCustomWordCodeHighlighter.KeywordKey(const Value: string): string;
begin
  if CaseSensitive then
    Result := Value
  else
    Result := LowerCase(Value);
end;

function TCustomWordCodeHighlighter.IsKeyword(const Value: string): Boolean;
begin
  Result := FKeywords.ContainsKey(KeywordKey(Value));
end;

function TCustomWordCodeHighlighter.IsIdentifierStart(Ch: Char): Boolean;
begin
  Result := Ch.IsLetter or (Ch = '_');
end;

function TCustomWordCodeHighlighter.IsIdentifierChar(Ch: Char): Boolean;
begin
  Result := Ch.IsLetterOrDigit or (Ch = '_');
end;

function TCustomWordCodeHighlighter.IsLineComment(const ALine: string; Index: Integer): Boolean;
begin
  Result := StartsTextAt(ALine, Index, '//', True);
end;

function TCustomWordCodeHighlighter.IsNumberStart(const ALine: string; Index: Integer): Boolean;
begin
  Result := ALine[Index].IsDigit;
end;

function TCustomWordCodeHighlighter.IsStringStart(Ch: Char): Boolean;
begin
  Result := Ch = '''';
end;

function TCustomWordCodeHighlighter.ReadIdentifier(const ALine: string; Index: Integer): Integer;
begin
  Result := Index;
  repeat
    Inc(Result);
  until (Result > Length(ALine)) or not IsIdentifierChar(ALine[Result]);
end;

function TCustomWordCodeHighlighter.ReadNumber(const ALine: string; Index: Integer): Integer;
begin
  Result := Index;
  repeat
    Inc(Result);
  until (Result > Length(ALine)) or not (ALine[Result].IsLetterOrDigit or (ALine[Result] = '.') or
    (ALine[Result] = '_'));
end;

function TCustomWordCodeHighlighter.ReadString(const ALine: string; Index: Integer): Integer;
var
  Quote: Char;
begin
  Quote := ALine[Index];
  Result := Index + 1;
  while Result <= Length(ALine) do
  begin
    if ALine[Result] = Quote then
    begin
      Inc(Result);
      if (Result <= Length(ALine)) and (ALine[Result] = Quote) then
        Inc(Result)
      else
        Break;
    end
    else
      Inc(Result);
  end;
end;

function TCustomWordCodeHighlighter.TokenKindForIdentifier(const Value: string): TCodeTokenKind;
begin
  if IsKeyword(Value) then
    Result := tkKeyword
  else
    Result := tkIdentifier;
end;

function TCustomWordCodeHighlighter.TokenizeLine(const ALine: string; ALineIndex: Integer): TCodeTokenArray;
var
  EndState: Integer;
begin
  Result := TokenizeLineState(ALine, 0, EndState);
end;

function TCustomWordCodeHighlighter.TokenizeLineState(const ALine: string; StartState: Integer;
  out EndState: Integer): TCodeTokenArray;
var
  Tokens: TList<TCodeToken>;
  I: Integer;
  Start: Integer;
  Text: string;
  RangeIndex: Integer;
  CloseAt: Integer;
  Range: TCodeMultiLineRange;

  procedure AddToken(AStart, ALength: Integer; AKind: TCodeTokenKind);
  begin
    if ALength > 0 then
      Tokens.Add(MakeToken(AStart, ALength, AKind));
  end;

  function TryRangeStart(Index: Integer; out FoundRange: Integer): Boolean;
  var
    R: Integer;
  begin
    for R := 0 to FMultiLineRanges.Count - 1 do
      if StartsTextAt(ALine, Index, FMultiLineRanges[R].StartDelimiter, True) then
      begin
        FoundRange := R;
        Exit(True);
      end;
    FoundRange := -1;
    Result := False;
  end;

begin
  EndState := 0;
  Tokens := TList<TCodeToken>.Create;
  try
    I := 1;

    // A multi-line construct left open by the previous line consumes this line
    // until its end delimiter (or to the end of the line, keeping the state).
    if (StartState >= 1) and (StartState <= FMultiLineRanges.Count) then
    begin
      Range := FMultiLineRanges[StartState - 1];
      CloseAt := PosEx(Range.EndDelimiter, ALine, 1);
      if CloseAt = 0 then
      begin
        AddToken(1, Length(ALine), Range.Kind);
        EndState := StartState;
        I := Length(ALine) + 1;
      end
      else
      begin
        I := CloseAt + Length(Range.EndDelimiter);
        AddToken(1, I - 1, Range.Kind);
      end;
    end;

    while I <= Length(ALine) do
    begin
      if ALine[I].IsWhiteSpace then
      begin
        Start := I;
        repeat
          Inc(I);
        until (I > Length(ALine)) or not ALine[I].IsWhiteSpace;
        AddToken(Start, I - Start, tkWhitespace);
      end
      else if IsLineComment(ALine, I) then
      begin
        AddToken(I, Length(ALine) - I + 1, tkComment);
        Break;
      end
      else if TryRangeStart(I, RangeIndex) then
      begin
        Range := FMultiLineRanges[RangeIndex];
        Start := I;
        CloseAt := PosEx(Range.EndDelimiter, ALine, I + Length(Range.StartDelimiter));
        if CloseAt = 0 then
        begin
          AddToken(Start, Length(ALine) - Start + 1, Range.Kind);
          EndState := RangeIndex + 1;
          Break;
        end;
        I := CloseAt + Length(Range.EndDelimiter);
        AddToken(Start, I - Start, Range.Kind);
      end
      else if IsStringStart(ALine[I]) then
      begin
        Start := I;
        I := ReadString(ALine, I);
        AddToken(Start, I - Start, tkString);
      end
      else if IsNumberStart(ALine, I) then
      begin
        Start := I;
        I := ReadNumber(ALine, I);
        AddToken(Start, I - Start, tkNumber);
      end
      else if IsIdentifierStart(ALine[I]) then
      begin
        Start := I;
        I := ReadIdentifier(ALine, I);
        Text := Copy(ALine, Start, I - Start);
        AddToken(Start, I - Start, TokenKindForIdentifier(Text));
      end
      else
      begin
        AddToken(I, 1, tkSymbol);
        Inc(I);
      end;
    end;

    Result := Tokens.ToArray;
  finally
    Tokens.Free;
  end;
end;

procedure TDelphiCodeHighlighter.BuildKeywords;
begin
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
end;

procedure TDelphiCodeHighlighter.BuildMultiLineRanges;
begin
  AddMultiLineRange('(*', '*)');
  AddMultiLineRange('{', '}');
end;

function TDelphiCodeHighlighter.IsNumberStart(const ALine: string; Index: Integer): Boolean;
begin
  Result := inherited IsNumberStart(ALine, Index) or (ALine[Index] = '$');
end;

function TDelphiCodeHighlighter.ReadNumber(const ALine: string; Index: Integer): Integer;
begin
  Result := Index;
  if ALine[Index] = '$' then
  begin
    repeat
      Inc(Result);
    until (Result > Length(ALine)) or not (ALine[Result].IsDigit or CharInSet(UpCase(ALine[Result]), ['A'..'F']));
  end
  else
    Result := inherited ReadNumber(ALine, Index);
end;

function TDelphiCodeHighlighter.ReadString(const ALine: string; Index: Integer): Integer;
begin
  Result := inherited ReadString(ALine, Index);
end;

procedure TDelphiCodeHighlighter.SetDefaultStyles;
var
  Style: TCodeTextStyle;
begin
  inherited;
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
end;

procedure TJavaScriptCodeHighlighter.BuildKeywords;
begin
  AddKeywords([
    'await', 'async', 'break', 'case', 'catch', 'class', 'const', 'continue',
    'debugger', 'default', 'delete', 'do', 'else', 'export', 'extends',
    'false', 'finally', 'for', 'from', 'function', 'get', 'if', 'import',
    'in', 'instanceof', 'let', 'new', 'null', 'of', 'return', 'set',
    'static', 'super', 'switch', 'this', 'throw', 'true', 'try', 'typeof',
    'undefined', 'var', 'void', 'while', 'with', 'yield'
  ]);
end;

function TJavaScriptCodeHighlighter.CaseSensitive: Boolean;
begin
  Result := True;
end;

procedure TJavaScriptCodeHighlighter.BuildMultiLineRanges;
begin
  AddMultiLineRange('/*', '*/');
  // Template literals may span lines.
  AddMultiLineRange('`', '`', tkString);
end;

function TJavaScriptCodeHighlighter.IsStringStart(Ch: Char): Boolean;
begin
  Result := CharInSet(Ch, ['''', '"']);
end;

function TJavaScriptCodeHighlighter.ReadNumber(const ALine: string; Index: Integer): Integer;
begin
  Result := Index;
  repeat
    Inc(Result);
  until (Result > Length(ALine)) or not (ALine[Result].IsLetterOrDigit or
    CharInSet(ALine[Result], ['.', '_', 'x', 'X', 'b', 'B', 'o', 'O']));
end;

function TJavaScriptCodeHighlighter.ReadString(const ALine: string; Index: Integer): Integer;
var
  Quote: Char;
  Escaped: Boolean;
begin
  Quote := ALine[Index];
  Escaped := False;
  Result := Index + 1;
  while Result <= Length(ALine) do
  begin
    if Escaped then
      Escaped := False
    else if ALine[Result] = '\' then
      Escaped := True
    else if ALine[Result] = Quote then
    begin
      Inc(Result);
      Break;
    end;
    Inc(Result);
  end;
end;

procedure TSqlCodeHighlighter.BuildKeywords;
begin
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
end;

procedure TSqlCodeHighlighter.BuildMultiLineRanges;
begin
  AddMultiLineRange('/*', '*/');
end;

function TSqlCodeHighlighter.IsLineComment(const ALine: string; Index: Integer): Boolean;
begin
  Result := StartsTextAt(ALine, Index, '--', True);
end;

function TSqlCodeHighlighter.IsStringStart(Ch: Char): Boolean;
begin
  Result := CharInSet(Ch, ['''', '"', '[']);
end;

function TSqlCodeHighlighter.ReadString(const ALine: string; Index: Integer): Integer;
var
  Quote: Char;
begin
  if ALine[Index] = '[' then
  begin
    Result := Index + 1;
    while (Result <= Length(ALine)) and (ALine[Result] <> ']') do
      Inc(Result);
    if Result <= Length(ALine) then
      Inc(Result);
    Exit;
  end;

  Quote := ALine[Index];
  Result := Index + 1;
  while Result <= Length(ALine) do
  begin
    if ALine[Result] = Quote then
    begin
      Inc(Result);
      if (Result <= Length(ALine)) and (ALine[Result] = Quote) then
        Inc(Result)
      else
        Break;
    end
    else
      Inc(Result);
  end;
end;

procedure TTungliCodeHighlighter.BuildKeywords;
begin
  AddKeywords([
    'if', 'then', 'else', 'while', 'do', 'procedure', 'exec', 'break',
    'continue', 'exit', 'beep', 'end', 'and', 'or', 'not', 'div', 'mod',
    'in', 'like', 'wildcard',
    '_now', '_date', '_time', '_lf', '_tb', '_pi'
  ]);
end;

procedure TTungliCodeHighlighter.BuildMultiLineRanges;
begin
  AddMultiLineRange('/*', '*/');
end;

function TTungliCodeHighlighter.IsLineComment(const ALine: string; Index: Integer): Boolean;
begin
  Result := False;
end;

function TTungliCodeHighlighter.IsStringStart(Ch: Char): Boolean;
begin
  Result := Ch = '"';
end;

function TTungliCodeHighlighter.ReadString(const ALine: string; Index: Integer): Integer;
var
  Quote: Char;
begin
  Quote := ALine[Index];
  Result := Index + 1;
  while (Result <= Length(ALine)) and (ALine[Result] <> Quote) do
    Inc(Result);
  if Result <= Length(ALine) then
    Inc(Result);
end;

procedure TBatchCodeHighlighter.BuildKeywords;
begin
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
end;

function TBatchCodeHighlighter.IsLineComment(const ALine: string; Index: Integer): Boolean;
var
  J: Integer;
begin
  if StartsTextAt(ALine, Index, '::', True) then
    Exit(True);

  if not StartsTextAt(ALine, Index, 'rem', False) then
    Exit(False);

  J := Index + 3;
  if (J <= Length(ALine)) and IsIdentifierChar(ALine[J]) then
    Exit(False);

  for J := 1 to Index - 1 do
    if not ALine[J].IsWhiteSpace then
      Exit(False);

  Result := True;
end;

function TBatchCodeHighlighter.IsStringStart(Ch: Char): Boolean;
begin
  Result := Ch = '"';
end;

function TBatchCodeHighlighter.ReadString(const ALine: string; Index: Integer): Integer;
begin
  Result := Index + 1;
  while (Result <= Length(ALine)) and (ALine[Result] <> '"') do
    Inc(Result);
  if Result <= Length(ALine) then
    Inc(Result);
end;

procedure TPowerShellCodeHighlighter.BuildKeywords;
begin
  AddKeywords([
    'begin', 'break', 'catch', 'class', 'continue', 'data', 'define', 'do',
    'dynamicparam', 'else', 'elseif', 'end', 'enum', 'exit', 'filter',
    'finally', 'for', 'foreach', 'from', 'function', 'hidden', 'if', 'in',
    'inlinescript', 'parallel', 'param', 'process', 'return', 'sequence',
    'static', 'switch', 'throw', 'trap', 'try', 'until', 'using', 'var',
    'while', 'workflow',
    'true', 'false', 'null'
  ]);
end;

procedure TPowerShellCodeHighlighter.BuildMultiLineRanges;
begin
  AddMultiLineRange('<#', '#>');
end;

function TPowerShellCodeHighlighter.IsLineComment(const ALine: string; Index: Integer): Boolean;
begin
  Result := StartsTextAt(ALine, Index, '#', True);
end;

function TPowerShellCodeHighlighter.IsStringStart(Ch: Char): Boolean;
begin
  Result := CharInSet(Ch, ['''', '"']);
end;

function TPowerShellCodeHighlighter.ReadString(const ALine: string; Index: Integer): Integer;
var
  Quote: Char;
  Escaped: Boolean;
begin
  Quote := ALine[Index];
  Result := Index + 1;
  if Quote = '"' then
  begin
    Escaped := False;
    while Result <= Length(ALine) do
    begin
      if Escaped then
        Escaped := False
      else if ALine[Result] = '`' then
        Escaped := True
      else if ALine[Result] = Quote then
      begin
        Inc(Result);
        Break;
      end;
      Inc(Result);
    end;
  end
  else
  begin
    while Result <= Length(ALine) do
    begin
      if ALine[Result] = Quote then
      begin
        Inc(Result);
        if (Result <= Length(ALine)) and (ALine[Result] = Quote) then
          Inc(Result)
        else
          Break;
      end
      else
        Inc(Result);
    end;
  end;
end;

procedure TIniCodeHighlighter.BuildKeywords;
begin
  AddKeywords([
    'true', 'false', 'yes', 'no', 'on', 'off', 'null'
  ]);
end;

function TIniCodeHighlighter.IsLineComment(const ALine: string; Index: Integer): Boolean;
begin
  Result := StartsTextAt(ALine, Index, ';', True) or
            StartsTextAt(ALine, Index, '#', True);
end;

function TIniCodeHighlighter.IsStringStart(Ch: Char): Boolean;
begin
  Result := CharInSet(Ch, ['''', '"', '[']);
end;

function TIniCodeHighlighter.ReadString(const ALine: string; Index: Integer): Integer;
var
  Quote: Char;
begin
  if ALine[Index] = '[' then
  begin
    Result := Index + 1;
    while (Result <= Length(ALine)) and (ALine[Result] <> ']') do
      Inc(Result);
    if Result <= Length(ALine) then
      Inc(Result);
    Exit;
  end;

  Quote := ALine[Index];
  Result := Index + 1;
  while (Result <= Length(ALine)) and (ALine[Result] <> Quote) do
    Inc(Result);
  if Result <= Length(ALine) then
    Inc(Result);
end;

procedure TYamlCodeHighlighter.BuildKeywords;
begin
  AddKeywords([
    'true', 'false', 'yes', 'no', 'on', 'off', 'null'
  ]);
end;

function TYamlCodeHighlighter.IsLineComment(const ALine: string; Index: Integer): Boolean;
begin
  Result := StartsTextAt(ALine, Index, '#', True);
end;

function TYamlCodeHighlighter.IsStringStart(Ch: Char): Boolean;
begin
  Result := CharInSet(Ch, ['''', '"']);
end;

function TYamlCodeHighlighter.ReadString(const ALine: string; Index: Integer): Integer;
var
  Quote: Char;
  Escaped: Boolean;
begin
  Quote := ALine[Index];
  Result := Index + 1;
  if Quote = '"' then
  begin
    Escaped := False;
    while Result <= Length(ALine) do
    begin
      if Escaped then
        Escaped := False
      else if ALine[Result] = '\' then
        Escaped := True
      else if ALine[Result] = Quote then
      begin
        Inc(Result);
        Break;
      end;
      Inc(Result);
    end;
  end
  else
  begin
    while Result <= Length(ALine) do
    begin
      if ALine[Result] = Quote then
      begin
        Inc(Result);
        if (Result <= Length(ALine)) and (ALine[Result] = Quote) then
          Inc(Result)
        else
          Break;
      end
      else
        Inc(Result);
    end;
  end;
end;

procedure TPythonCodeHighlighter.BuildKeywords;
begin
  AddKeywords([
    'False', 'None', 'True', 'and', 'as', 'assert', 'async', 'await',
    'break', 'class', 'continue', 'def', 'del', 'elif', 'else', 'except',
    'finally', 'for', 'from', 'global', 'if', 'import', 'in', 'is',
    'lambda', 'nonlocal', 'not', 'or', 'pass', 'raise', 'return', 'try',
    'while', 'with', 'yield', 'match', 'case'
  ]);
end;

procedure TPythonCodeHighlighter.BuildMultiLineRanges;
begin
  AddMultiLineRange('"""', '"""', tkString);
  AddMultiLineRange('''''''', '''''''', tkString);
end;

function TPythonCodeHighlighter.CaseSensitive: Boolean;
begin
  Result := True;
end;

function TPythonCodeHighlighter.IsLineComment(const ALine: string; Index: Integer): Boolean;
begin
  Result := StartsTextAt(ALine, Index, '#', True);
end;

function TPythonCodeHighlighter.IsStringStart(Ch: Char): Boolean;
begin
  Result := CharInSet(Ch, ['''', '"']);
end;

function TPythonCodeHighlighter.ReadNumber(const ALine: string; Index: Integer): Integer;
begin
  Result := Index;
  repeat
    Inc(Result);
  until (Result > Length(ALine)) or not (ALine[Result].IsLetterOrDigit or
    CharInSet(ALine[Result], ['.', '_']));
end;

function TPythonCodeHighlighter.ReadString(const ALine: string; Index: Integer): Integer;
var
  Quote: Char;
  Escaped: Boolean;
begin
  // Triple-quoted strings are handled by the multi-line ranges; this only
  // sees single-quoted forms.
  Quote := ALine[Index];
  Escaped := False;
  Result := Index + 1;
  while Result <= Length(ALine) do
  begin
    if Escaped then
      Escaped := False
    else if ALine[Result] = '\' then
      Escaped := True
    else if ALine[Result] = Quote then
    begin
      Inc(Result);
      Break;
    end;
    Inc(Result);
  end;
end;

class function TSqlCodeHighlighter.LanguageName: string;
begin
  Result := 'SQL';
end;

class function TIniCodeHighlighter.LanguageName: string;
begin
  Result := 'INI';
end;

class function TYamlCodeHighlighter.LanguageName: string;
begin
  Result := 'YAML';
end;

end.
