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

## Line markers

For compiler/debugger annotations beyond breakpoints — executable-line dots,
errors, warnings:

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
