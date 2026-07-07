# Breakpoints, Execution Line, and Line Markers

This is the surface a debugger or interpreter host integrates against. All
line numbers on this page are **1-based** — the same numbers shown in the
gutter. (`TCodeEditor.Caret.Line` is 0-based; add 1 when crossing over.)

## Breakpoints

### Toggling

- Click the breakpoint margin — the 16 px strip at the left edge of the
  gutter (constant `BreakpointMarginWidth`).
- Or press `F9` (or `F5`) with the caret on the line.

A breakpoint draws a red dot in the margin.

### API

```pascal
CodeEditor1.ToggleBreakpoint(Line);
CodeEditor1.AddBreakpoint(Line);
CodeEditor1.RemoveBreakpoint(Line);
CodeEditor1.ClearBreakpoints;
if CodeEditor1.HasBreakpoint(Line) then ...
Lines := CodeEditor1.BreakpointLines;   // TArray<Integer>, sorted, de-duplicated
CodeEditor1.OnBreakpointsChanged := HandleBreakpointsChanged;
```

Out-of-range lines are ignored by `Add`/`Toggle`. The breakpoints are also a
published `Breakpoints` collection (`TCodeBreakpoints` of `TCodeBreakpoint`,
each with a 1-based `Line`), so they appear in the Object Inspector and can
be pre-seeded at design time; design-time edits repaint the gutter
immediately.

### Driving it from an interpreter

```pascal
// Push the user's breakpoints into the interpreter:
for var L in CodeEditor1.BreakpointLines do
  Interpreter.SetBreakpoint(L);

// When the interpreter stops, show the current statement
// (set to -1 — or any value < 1 — to clear):
CodeEditor1.ExecutionLine := Interpreter.CurrentLine;
```

## Execution line

`ExecutionLine` (public, runtime-only, 1-based, `-1` = none) draws an arrow
in the margin plus a highlight band across the line, and scrolls the line
into view. The arrow is amber for a plain current statement, and cyan over
the red dot when execution stops on a line that also has a breakpoint
(Delphi-style).

## Executable-line dots

A script debugger typically shows a small dot next to every line that
generates code (the Delphi IDE's "blue dots") — the lines a breakpoint can
land on. Because that is a *per-line predicate* over potentially hundreds of
lines, it is driven by a pull event rather than a marker collection:

```pascal
CodeEditor1.OnQueryExecutableLine := EditorQueryExecutableLine;

procedure TForm1.EditorQueryExecutableLine(Sender: TObject; Line: Integer;
  var Value: Boolean);
begin
  Value := Interpreter.IsExecutableLine(Line);   // Line is 1-based
end;
```

The editor calls the handler for each visible line while painting the gutter
and draws a blue dot (in the same margin as breakpoints/the execution arrow)
when `Value` comes back True. Because it is evaluated lazily per visible line,
it stays cheap no matter how large the file is — keep the handler itself
quick. When the executable set changes (e.g. the script recompiles), call
`CodeEditor1.Invalidate` to force a repaint.

This replaces the pull-based per-line gutter callbacks (`OnCheckLine`) that
eControl's `TSyntaxMemo` used. For a *single* highlighted statement, prefer
`ExecutionLine` or an `lmkExecutable` line marker below.

## Hover-to-evaluate (`OnGetHint`)

While paused at a breakpoint, debuggers show a variable's live value when you
hover over it. The editor fires `OnGetHint` after the mouse rests over an
identifier; return the value in `HintText` and it pops a tooltip:

```pascal
CodeEditor1.OnGetHint := EditorGetHint;

procedure TForm1.EditorGetHint(Sender: TObject; Line, Column: Integer;
  const AWord: string; var HintText: string);
begin
  if Debugging then
    HintText := Interpreter.Evaluate(AWord);   // '' = no tooltip
end;
```

`Line` / `Column` are 1-based. `AWord` is the identifier under the mouse, with
a leading dotted member chain folded in (hovering `total` in `order.total`
gives `order.total`), so it drops straight into an expression evaluator. The
hint is dismissed automatically on mouse move, scroll, key press, or focus
loss. Assigning the event turns on mouse tracking; leave it `nil` to disable.
This is the CodeEdit equivalent of eControl's `OnGetTokenHint`.

## Line markers

For compiler/debugger annotations beyond breakpoints — errors, warnings, a
one-off highlighted statement:

```pascal
CodeEditor1.AddLineMarker(12, lmkExecutable);
CodeEditor1.AddLineMarker(18, lmkError);
CodeEditor1.RemoveLineMarker(18, lmkError);
CodeEditor1.ClearLineMarkers;
```

Kinds are `lmkExecutable`, `lmkError`, `lmkWarning`, `lmkInfo`. Each marker
paints a gutter glyph (square / cross / triangle / dot) and a tinted
background band across the line; the defaults adapt to dark and light
themes. Markers live in the published `LineMarkers` collection
(`TCodeLineMarkers` of `TCodeLineMarker`) with per-marker `Line`, `Kind`,
and optional `Background`, `Foreground`, and `Text` overrides, editable in
the Object Inspector. One line can carry several markers; the most severe
kind supplies the gutter glyph. `AddLineMarker` returns the existing marker
rather than adding a duplicate for the same line and kind.

## Edit tracking and lifetime

Breakpoints, markers, and the execution line are tracked by line index and
shift to follow insertions and deletions (Enter, joining lines with
Backspace/Delete, deleting a multi-line selection). Specifics:

- A breakpoint on a line merged into another collapses onto the surviving
  line; duplicates created by a merge are removed.
- The execution line is cleared if its line is deleted.
- All three are cleared when `Lines` is replaced wholesale or `Clear` is
  called.
- Undo/redo restore breakpoints and the execution line along with the text.

## Current limitations

- Breakpoints are plain line indices — no per-breakpoint enabled/disabled
  state or condition expression yet.
- The breakpoint margin width is a fixed constant (16 px), not a property.
- To rebind the toggle key, handle `OnKeyDown` in the host and call
  `ToggleBreakpoint(CodeEditor1.Caret.Line + 1)`.
