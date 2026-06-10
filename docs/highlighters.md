# Highlighters

`CodeEdit.Highlighter.pas` contains the token model and the highlighter
class hierarchy. A highlighter is a non-visual `TComponent` you drop on the
form (or create in code) and assign to `TCodeEditor.Highlighter`. One
highlighter instance can serve any number of editors.

## Built-in highlighters

| Component | Language | Multi-line constructs |
|---|---|---|
| `TDelphiCodeHighlighter` | Delphi / Object Pascal | `{ }` and `(* *)` comments |
| `TJavaScriptCodeHighlighter` | JavaScript | `/* */` comments, `` ` `` template literals |
| `TSqlCodeHighlighter` | SQL | `/* */` comments |
| `TTungliCodeHighlighter` | Tungli script (`.tgl`) | `/* */` comments |
| `TBatchCodeHighlighter` | BAT / CMD | — |
| `TPowerShellCodeHighlighter` | PowerShell | `<# #>` comments |
| `TIniCodeHighlighter` | INI / CFG | — |
| `TYamlCodeHighlighter` | YAML | — |
| `TPythonCodeHighlighter` | Python | `"""` and `'''` triple-quoted strings |

All multi-line constructs highlight correctly across line boundaries: typing
`{` in a Delphi file repaints the following lines as comment until the
matching `}` appears.

## Token model

`TokenizeLine`/`TokenizeLineState` return a `TCodeTokenArray`; each
`TCodeToken` has a 1-based `Start` column, a `Length`, and a `Kind`:

```pascal
TCodeTokenKind = (tkText, tkWhitespace, tkComment, tkString, tkNumber,
  tkKeyword, tkIdentifier, tkSymbol);
```

Per-kind colors come from the highlighter's `Styles[Kind]` property
(`TCodeTextStyle`: `Foreground`, `Background`, `FontStyle`). When the
editor's `Options.ThemeSyntaxColors` is `True` (the default), the editor
substitutes theme-appropriate dark/light palettes for the token foregrounds
instead, so a highlighter normally doesn't need to care about themes.

## Class hierarchy

### TCustomCodeHighlighter

The abstract base. Two virtual entry points:

```pascal
function TokenizeLine(const ALine: string; ALineIndex: Integer): TCodeTokenArray; virtual;
function TokenizeLineState(const ALine: string; StartState: Integer;
  out EndState: Integer): TCodeTokenArray; virtual;
```

The editor always calls `TokenizeLineState`. The base implementation is a
stateless fallback that delegates to `TokenizeLine`, so a minimal custom
highlighter only has to override `TokenizeLine`.

**The state contract**: `StartState` is the state the previous line ended
in; `0` means "nothing open". A highlighter that recognises multi-line
constructs returns a non-zero `EndState` when a construct is still open at
the end of the line, and must resume that construct when it later receives
the same value as `StartState`. The values are opaque to the editor — it
only stores and compares them. The editor maintains the chain lazily and
re-tokenizes only lines whose text or incoming state changed.

### TCustomWordCodeHighlighter

The workhorse base class — a generic word/keyword lexer driven by small
virtual methods. The bundled highlighters are all thin subclasses. Scanning
order per character position: whitespace → line comment → multi-line range
start → string → number → identifier/keyword → symbol.

What to override:

| Member | Purpose | Default |
|---|---|---|
| `BuildKeywords` | Call `AddKeyword` / `AddKeywords` with the language's keywords. | none |
| `BuildMultiLineRanges` | Call `AddMultiLineRange(StartDelim, EndDelim, Kind)` for each construct that may span lines (block comments, multi-line strings). | none |
| `CaseSensitive` | Keyword case sensitivity. | `False` |
| `IsLineComment(Line, Index)` | Does a to-end-of-line comment start here? | `'//'` |
| `IsStringStart(Ch)` | Does a (single-line) string start with this char? | `''''` |
| `ReadString(Line, Index)` | Scan past a string; return the index after it. | quote-doubling rule |
| `IsNumberStart` / `ReadNumber` | Number recognition. | digits |
| `IsIdentifierStart` / `IsIdentifierChar` / `ReadIdentifier` | Identifier rules. | letters, digits, `_` |
| `TokenKindForIdentifier(Value)` | Classify a scanned identifier. | keyword lookup |

Multi-line ranges registered with `AddMultiLineRange` are matched before
single-line strings, so Python can register `"""…"""` while `IsStringStart`
still handles plain `"…"`. The 1-based registration index of a range is the
state value reported while that range is open — `BuildMultiLineRanges` is
called once from the constructor and the order must stay stable.

### A complete example

```pascal
type
  TLuaCodeHighlighter = class(TCustomWordCodeHighlighter)
  protected
    procedure BuildKeywords; override;
    procedure BuildMultiLineRanges; override;
    function CaseSensitive: Boolean; override;
    function IsLineComment(const ALine: string; Index: Integer): Boolean; override;
    function IsStringStart(Ch: Char): Boolean; override;
  end;

procedure TLuaCodeHighlighter.BuildKeywords;
begin
  AddKeywords(['and', 'break', 'do', 'else', 'elseif', 'end', 'false', 'for',
    'function', 'goto', 'if', 'in', 'local', 'nil', 'not', 'or', 'repeat',
    'return', 'then', 'true', 'until', 'while']);
end;

procedure TLuaCodeHighlighter.BuildMultiLineRanges;
begin
  AddMultiLineRange('--[[', ']]');           // block comment
  AddMultiLineRange('[[', ']]', tkString);   // long string
end;

function TLuaCodeHighlighter.CaseSensitive: Boolean;
begin
  Result := True;
end;

function TLuaCodeHighlighter.IsLineComment(const ALine: string; Index: Integer): Boolean;
begin
  // '--' starts a line comment, unless it is really '--[[' (a block comment).
  Result := (Copy(ALine, Index, 2) = '--') and (Copy(ALine, Index + 2, 2) <> '[[');
end;

function TLuaCodeHighlighter.IsStringStart(Ch: Char): Boolean;
begin
  Result := CharInSet(Ch, ['''', '"']);
end;
```

Two ordering rules to keep in mind:

- Line comments are tested **before** multi-line ranges. When a line-comment
  prefix is also the start of a range delimiter (Lua's `--` vs `--[[`),
  exclude the longer form in `IsLineComment`, as above.
- Ranges are tested in registration order at each position, so when one
  range's start delimiter is a prefix of another's, register the longer one
  first.

## Testing

`Tests/TestHighlighterState.dpr` is a small console program asserting the
multi-line state transitions for the bundled highlighters. Compile and run
it after touching tokenizer code:

```
dcc32 -Q -E. Tests\TestHighlighterState.dpr && TestHighlighterState.exe
```
