# CodeEdit

Native Delphi/VCL code editor component. No third-party dependencies — just
the RTL and VCL.

Released under the MIT License. If you use CodeEdit in your project,
attribution is appreciated.

## Features

- Owner-drawn editor with gutter, line numbers, and theme-aware painting
  (follows the active VCL style, with an `OnResolveTheme` hook for other
  skinning systems)
- Pluggable syntax highlighting with ten bundled languages and correct
  multi-line constructs (block comments, template literals, triple-quoted
  strings)
- Code completion and signature help driven by a provider component
- Find/replace panel with match-case, whole-word, and regex modes; results
  stay in sync while editing
- Multi-caret editing (Ctrl+D / Ctrl+Shift+L), word navigation,
  indent/unindent, line commenting
- Breakpoints, execution-line arrow, and error/warning line markers for
  debugger hosts — design-time editable, 1-based, edit-tracked
- Undo/redo with typing coalescing that also restores breakpoints,
  execution line, and the `Modified` flag
- Minimap, styled scrollbars, bracket matching, occurrence highlighting

## Documentation

- [TCodeEditor reference](docs/editor.md) — properties, methods, events,
  options, theming, full keyboard table
- [Highlighters](docs/highlighters.md) — bundled languages, token model,
  writing your own highlighter, the multi-line state contract
- [Completion and signature help](docs/completion.md) — provider API and
  context records
- [Breakpoints and line markers](docs/breakpoints-markers.md) — the
  debugger-host surface

## Units

- `Source\CodeEdit.Editor.pas` — `TCodeEditor`
- `Source\CodeEdit.Completion.pas` — completion/signature providers and a
  keyword provider
- `Source\CodeEdit.Highlighter.pas` — token model and highlighters for
  Delphi, JavaScript, SQL, Tungli, Batch (BAT/CMD), PowerShell, INI, YAML,
  and Python
- `Source\CodeEdit.Register.pas` — registers everything on the `CodeEdit`
  palette page
- `Packages\CodeEditVcl.dpk` — design-time package
- `Samples\VclDemo`, `Samples\ScrEdit` — demo applications
- `Tests\TestHighlighterState.dpr` — console regression test for the
  multi-line tokenizer state

## Quick start

Install `Packages\CodeEditVcl.dpk` (or just add `Source` to your library
path), then drop a `TCodeEditor` and a highlighter on a form:

```pascal
CodeEditor1.Highlighter := DelphiCodeHighlighter1;
CodeEditor1.Lines.LoadFromFile('Demo.pas');
```

Completion is one event away:

```pascal
CodeEditor1.CompletionProvider := KeywordCompletionProvider1;
KeywordCompletionProvider1.Keywords.CommaText := 'begin,end,procedure,function';
```

Caret and scroll positions are 0-based; breakpoints, line markers, and
`ExecutionLine` are 1-based to match the gutter. See the
[editor reference](docs/editor.md#coordinate-conventions) for the details.

## Host integration in five lines

```pascal
CodeEditor1.Options.LineCommentPrefix := '--';        // language-specific
CodeEditor1.OnCaretChange := UpdateStatusBar;          // 0-based position
CodeEditor1.OnBreakpointsChanged := SyncInterpreter;   // 1-based lines
CodeEditor1.ExecutionLine := Interpreter.CurrentLine;  // current statement
CodeEditor1.Modified := False;                         // after saving
```

Most settings are published properties, so form storage systems persist the
editor directly.

## Roadmap

- Per-breakpoint enabled state and conditions
- Diff-based undo storage and virtualized rendering for very large files
- IME composition-window positioning
- Word wrap
- Diagnostics API (squiggles) and symbol navigation hooks
- Possible Delphi 7 compatibility pass (the code currently uses unit
  namespaces, generics, character helpers, and VCL styles)

## Changelog

See [CHANGELOG.md](CHANGELOG.md).
