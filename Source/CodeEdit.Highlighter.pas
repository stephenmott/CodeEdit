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
    function TokenizeLine(const ALine: string; ALineIndex: Integer): TCodeTokenArray; virtual;
    property Styles[Kind: TCodeTokenKind]: TCodeTextStyle read GetStyle write SetStyle;
  end;

  TCustomWordCodeHighlighter = class(TCustomCodeHighlighter)
  private
    FKeywords: TDictionary<string, Boolean>;
  protected
    procedure AddKeyword(const Value: string);
    procedure AddKeywords(const Values: array of string);
    procedure BuildKeywords; virtual;
    function CaseSensitive: Boolean; virtual;
    function KeywordKey(const Value: string): string;
    function IsKeyword(const Value: string): Boolean; virtual;
    function IsIdentifierStart(Ch: Char): Boolean; virtual;
    function IsIdentifierChar(Ch: Char): Boolean; virtual;
    function IsLineComment(const ALine: string; Index: Integer): Boolean; virtual;
    function IsBlockCommentStart(const ALine: string; Index: Integer; out EndDelimiter: string): Boolean; virtual;
    function IsNumberStart(const ALine: string; Index: Integer): Boolean; virtual;
    function IsStringStart(Ch: Char): Boolean; virtual;
    function ReadBlockComment(const ALine: string; Index: Integer; const EndDelimiter: string): Integer; virtual;
    function ReadIdentifier(const ALine: string; Index: Integer): Integer; virtual;
    function ReadNumber(const ALine: string; Index: Integer): Integer; virtual;
    function ReadString(const ALine: string; Index: Integer): Integer; virtual;
    function TokenKindForIdentifier(const Value: string): TCodeTokenKind; virtual;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function TokenizeLine(const ALine: string; ALineIndex: Integer): TCodeTokenArray; override;
  end;

  TDelphiCodeHighlighter = class(TCustomWordCodeHighlighter)
  protected
    procedure BuildKeywords; override;
    function IsBlockCommentStart(const ALine: string; Index: Integer; out EndDelimiter: string): Boolean; override;
    function IsNumberStart(const ALine: string; Index: Integer): Boolean; override;
    function ReadNumber(const ALine: string; Index: Integer): Integer; override;
    function ReadString(const ALine: string; Index: Integer): Integer; override;
    procedure SetDefaultStyles; override;
  end;

  TJavaScriptCodeHighlighter = class(TCustomWordCodeHighlighter)
  protected
    procedure BuildKeywords; override;
    function CaseSensitive: Boolean; override;
    function IsBlockCommentStart(const ALine: string; Index: Integer; out EndDelimiter: string): Boolean; override;
    function IsStringStart(Ch: Char): Boolean; override;
    function ReadNumber(const ALine: string; Index: Integer): Integer; override;
    function ReadString(const ALine: string; Index: Integer): Integer; override;
  end;

  TSqlCodeHighlighter = class(TCustomWordCodeHighlighter)
  protected
    procedure BuildKeywords; override;
    function IsBlockCommentStart(const ALine: string; Index: Integer; out EndDelimiter: string): Boolean; override;
    function IsLineComment(const ALine: string; Index: Integer): Boolean; override;
    function IsStringStart(Ch: Char): Boolean; override;
    function ReadString(const ALine: string; Index: Integer): Integer; override;
  end;

implementation

uses
  System.Character,
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
  BuildKeywords;
end;

destructor TCustomWordCodeHighlighter.Destroy;
begin
  FKeywords.Free;
  inherited;
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

function TCustomWordCodeHighlighter.IsBlockCommentStart(const ALine: string; Index: Integer;
  out EndDelimiter: string): Boolean;
begin
  EndDelimiter := '';
  Result := False;
end;

function TCustomWordCodeHighlighter.IsNumberStart(const ALine: string; Index: Integer): Boolean;
begin
  Result := ALine[Index].IsDigit;
end;

function TCustomWordCodeHighlighter.IsStringStart(Ch: Char): Boolean;
begin
  Result := Ch = '''';
end;

function TCustomWordCodeHighlighter.ReadBlockComment(const ALine: string; Index: Integer;
  const EndDelimiter: string): Integer;
begin
  Result := Index + Length(EndDelimiter);
  while (Result <= Length(ALine)) and
    not StartsTextAt(ALine, Result, EndDelimiter, True) do
    Inc(Result);

  if Result <= Length(ALine) then
    Inc(Result, Length(EndDelimiter));
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
  Tokens: TList<TCodeToken>;
  I: Integer;
  Start: Integer;
  EndDelimiter: string;
  Text: string;

  procedure AddToken(AStart, ALength: Integer; AKind: TCodeTokenKind);
  begin
    if ALength > 0 then
      Tokens.Add(MakeToken(AStart, ALength, AKind));
  end;

begin
  Tokens := TList<TCodeToken>.Create;
  try
    I := 1;
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
      else if IsBlockCommentStart(ALine, I, EndDelimiter) then
      begin
        Start := I;
        I := ReadBlockComment(ALine, I, EndDelimiter);
        AddToken(Start, I - Start, tkComment);
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

function TDelphiCodeHighlighter.IsBlockCommentStart(const ALine: string; Index: Integer;
  out EndDelimiter: string): Boolean;
begin
  if StartsTextAt(ALine, Index, '(*', True) then
  begin
    EndDelimiter := '*)';
    Exit(True);
  end;

  if StartsTextAt(ALine, Index, '{', True) then
  begin
    EndDelimiter := '}';
    Exit(True);
  end;

  EndDelimiter := '';
  Result := False;
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

function TJavaScriptCodeHighlighter.IsBlockCommentStart(const ALine: string; Index: Integer;
  out EndDelimiter: string): Boolean;
begin
  if StartsTextAt(ALine, Index, '/*', True) then
  begin
    EndDelimiter := '*/';
    Exit(True);
  end;

  EndDelimiter := '';
  Result := False;
end;

function TJavaScriptCodeHighlighter.IsStringStart(Ch: Char): Boolean;
begin
  Result := CharInSet(Ch, ['''', '"', '`']);
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

function TSqlCodeHighlighter.IsBlockCommentStart(const ALine: string; Index: Integer;
  out EndDelimiter: string): Boolean;
begin
  if StartsTextAt(ALine, Index, '/*', True) then
  begin
    EndDelimiter := '*/';
    Exit(True);
  end;

  EndDelimiter := '';
  Result := False;
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

end.
