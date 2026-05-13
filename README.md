# CodeEdit

Native Delphi/VCL code editor component.

Released under the MIT License. If you use CodeEdit in your project,
attribution is appreciated.

This is the first foundation version: a dependency-free custom control with editable
line storage, gutter, caret movement, selection, clipboard editing, scrolling, and a
pluggable line highlighter. It is intentionally small enough to install, test, and
iterate on.

## Units

- `Source\CodeEdit.Editor.pas` contains `TCodeEditor`.
- `Source\CodeEdit.Completion.pas` contains completion item/provider classes and a keyword provider.
- `Source\CodeEdit.Highlighter.pas` contains the token model and extensible lexer/highlighter classes for Delphi, JavaScript, and SQL.
- `Source\CodeEdit.Register.pas` registers the components on the `CodeEdit` palette page.
- `Packages\CodeEditVcl.dpk` is the package shell.
- `Samples\VclDemo` contains a small runtime demo.

## First Use

Add the `Source` directory to your Delphi library path or package search path, then
drop `TCodeEditor` and one highlighter component on a VCL form:

```pascal
CodeEditor1.Highlighter := DelphiCodeHighlighter1;
CodeEditor1.Lines.Text := 'unit Demo;' + sLineBreak + 'interface' + sLineBreak + 'implementation' + sLineBreak + 'end.';
```

Available highlighters:

- `TDelphiCodeHighlighter`
- `TJavaScriptCodeHighlighter`
- `TSqlCodeHighlighter`

Completion starts with `TCustomCodeCompletionProvider` and
`TKeywordCompletionProvider`. Assign `CodeEditor1.CompletionProvider`, handle
`OnGetCompletions` for callback-driven lists, and call
`CodeEditor1.TriggerCompletion` or press `Ctrl+Space`.

Create more languages by deriving from `TCustomWordCodeHighlighter` and overriding
keyword, comment, string, identifier, and number parsing methods.

## Find and Replace

Call `CodeEditor1.ShowFind` to open the find bar, or `CodeEditor1.ShowReplace`
for find-and-replace. The current selection (when it sits on a single line) is
used as the initial search term, so highlighting a word and opening find gives
the expected result without retyping. Inside the find edit:

- `Enter` jumps to the next match (`Shift+Enter` for previous).
- `Esc` closes the panel.
- Toggles are available for match case, whole word, and regular expressions.

## Mouse and Selection

- Double-click selects the word at the click position.
- Drag selects a range; `Shift+Click` extends the existing selection.
- Mouse wheel scrolls vertically; styled scrollbars accept click-to-page and
  drag-to-scroll.

## Scrollbars

`StyledScrollBars` defaults to `True` and paints theme-matched scrollbars
inside the client area. The track uses `GutterBackground` and the thumb is
brightness-shifted from the track so it stays visible on both light and dark
themes. Set `StyledScrollBars := False` to fall back to native Windows
scrollbars.

## Breakpoints

### Toggling a breakpoint

- Click the breakpoint margin — the 16px strip at the left of the gutter
  (the constant `BreakpointMarginWidth`).
- Or press `F5` with the caret on the line. (`F5` matches the Delphi IDE; if your
  host app needs `F5` for "run", remap it — see the note below.)

### What you see

- A breakpoint draws a red dot in the margin.
- Setting `ExecutionLine` draws an arrow in the margin plus a highlight band
  across that line, and scrolls the line into view. The arrow is amber when it's
  just the current statement, and cyan over the red dot when execution is stopped
  on a line that also has a breakpoint (Delphi-style).

### Driving it from your interpreter

All breakpoint line numbers and `ExecutionLine` are **1-based** — the same number
shown in the gutter, in the Object Inspector, and returned by `BreakpointLines`.
(`TCodeEditor.Caret.Line` is 0-based; that's a separate, pre-existing convention,
so add 1 when feeding it to the breakpoint API.)

```pascal
// Host / debugger side — push the user's breakpoints into your interpreter:
for var L in CodeEditor1.BreakpointLines do   // TArray<Integer>, 1-based
  Interpreter.SetBreakpoint(L);

// When the interpreter stops, show the current statement
// (set to -1 — or any value < 1 — to clear it):
CodeEditor1.ExecutionLine := Interpreter.CurrentLine;

// React to the user toggling breakpoints in the editor:
CodeEditor1.OnBreakpointsChanged := HandleBreakpointsChanged;
```

API: `ToggleBreakpoint(Line)`, `AddBreakpoint(Line)`, `RemoveBreakpoint(Line)`,
`ClearBreakpoints`, `HasBreakpoint(Line): Boolean`,
`BreakpointLines: TArray<Integer>`, the `ExecutionLine` property, and the
`OnBreakpointsChanged` event — all 1-based.

The breakpoints are also a published `Breakpoints` collection
(`TCodeBreakpoints` of `TCodeBreakpoint`, each with a 1-based `Line`), so they
appear in the Object Inspector and can be edited or pre-seeded at design time
with the standard collection editor; design-time changes repaint the gutter
immediately. `BreakpointLines` returns the same set as a sorted, de-duplicated
array; the runtime `Add/Remove/Toggle` helpers keep it in sync.
(`ExecutionLine` is runtime-only and is not published.)

### Edit tracking and lifetime

Breakpoints and the execution line are tracked by line index and shift to follow
line insertions and deletions (typing `Enter`, joining lines with
backspace/delete, deleting a multi-line selection). They are cleared when `Lines`
is replaced wholesale or `Clear` is called. A breakpoint on a line that gets
merged into another collapses onto the surviving line; the execution line is
cleared if its line is deleted.

### Notes / current limitations

- Breakpoints are plain line indices — there is no per-breakpoint enabled/disabled
  state or condition expression yet.
- The breakpoint margin width is the fixed constant `BreakpointMarginWidth` (16px);
  it is not a published property.
- `F5` is hard-wired as the toggle key. If you need a different key, handle it in
  the host (`OnKeyDown`) and call `ToggleBreakpoint(CodeEditor1.Caret.Line + 1)`.

## Styling

`TCodeEditor.ThemeMode` defaults to `ctmVclStyle`, so the editor background,
gutter, text, and selection colors follow the active Delphi VCL style through
`StyleServices`.

For DevExpress themes, keep the core package free of DevExpress dependencies and
bridge the active look-and-feel colors from the host application:

```pascal
procedure TMainForm.CodeEditorResolveTheme(Sender: TObject; Colors: TCodeEditorThemeColors);
begin
  // Assign these from your active DevExpress look-and-feel painter/controller.
  Colors.Background := GetDevExpressEditorBackground;
  Colors.Text := GetDevExpressEditorText;
  Colors.GutterBackground := GetDevExpressPanelBackground;
  Colors.GutterText := GetDevExpressMutedText;
  Colors.GutterBorder := GetDevExpressBorder;
  Colors.SelectionBackground := clHighlight;
  Colors.SelectionText := clHighlightText;
end;
```

If a project uses both VCL styles and DevExpress skins, `ctmVclStyle` supplies
the base palette first and `OnResolveTheme` can override whichever colors should
come from DevExpress.

## Next Milestones

- Smarter undo grouping for paste, auto-indent, and formatter operations
- IME and Unicode edge-case handling
- Multi-line lexer state for block comments, template strings, and conditional compiler sections
- Virtualized rendering for very large files
- Minimap, bracket matching, current-line highlight
- IntelliSense-friendly APIs for diagnostics, completion, and symbol navigation

## Changelog

See [CHANGELOG.md](CHANGELOG.md).
