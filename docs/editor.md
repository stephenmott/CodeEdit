# TCodeEditor Reference

`TCodeEditor` (in `CodeEdit.Editor.pas`) is the editor control itself: an
owner-drawn `TCustomControl` with its own line storage, caret, selection,
undo stack, search panel, and gutter. It has no dependencies beyond the RTL
and VCL.

Related pages: [Highlighters](highlighters.md) ·
[Completion and signature help](completion.md) ·
[Breakpoints and line markers](breakpoints-markers.md)

## Coordinate conventions

Two conventions coexist; this is deliberate and worth memorising:

- **Caret/selection positions are 0-based.** `TCodePosition.Line` 0 is the
  first line, `Column` 0 is before the first character. `Caret`, `TopLine`,
  `LeftColumn`, `ShowLine`, `OnCaretChange`, and `OnSelectionChange` all use
  this convention.
- **Breakpoints, line markers, and `ExecutionLine` are 1-based**, matching
  the numbers painted in the gutter. Add 1 when feeding `Caret.Line` into the
  breakpoint API.

```pascal
CodeEditor1.Caret := TCodePosition.Create(12, 4); // line 13 in the gutter
CodeEditor1.ToggleBreakpoint(CodeEditor1.Caret.Line + 1);
```

## Published properties

| Property | Type | Default | Notes |
|---|---|---|---|
| `Lines` | `TStrings` | — | The document. Assigning replaces the text, clears undo, breakpoints, markers, and `Modified`. |
| `Highlighter` | `TCustomCodeHighlighter` | `nil` | Pluggable syntax highlighter; see [Highlighters](highlighters.md). Safe to free before the editor (free-notification handled). |
| `CompletionProvider` | `TCustomCodeCompletionProvider` | `nil` | Completion and signature help; see [Completion](completion.md). |
| `Options` | `TCodeEditorOptions` | — | Behaviour options; see below. |
| `Theme` | `TCodeEditorThemeColors` | system colors | Manual palette, used when `ThemeMode = ctmManual`. |
| `ThemeMode` | `TCodeEditorThemeMode` | `ctmVclStyle` | `ctmVclStyle` follows the active VCL style via `StyleServices`; `ctmManual` uses `Theme` as-is. |
| `ReadOnly` | `Boolean` | `False` | Blocks typing, paste, deletion, and editing methods such as `InsertText`. Copy still works. |
| `Modified` | `Boolean` | `False` | Set on any edit. Undo restores the flag to its pre-edit value; reset it to `False` after saving. |
| `MaxUndo` | `Integer` | `1024` | Maximum undo depth. Each entry snapshots the document, so lower this for very large files. |
| `ScrollBars` | `TScrollStyle` | `ssBoth` | Which axes scroll. |
| `StyledScrollBars` | `Boolean` | `True` | Theme-matched scrollbars painted in the client area; `False` falls back to native Windows scrollbars. |
| `Breakpoints` | `TCodeBreakpoints` | empty | Design-time editable collection; see [Breakpoints](breakpoints-markers.md). |
| `LineMarkers` | `TCodeLineMarkers` | empty | Design-time editable collection; see [Line markers](breakpoints-markers.md). |

Standard VCL properties (`Align`, `Anchors`, `Color`, `Font`, `PopupMenu`,
`TabOrder`, `TabStop`) and the usual key/mouse/focus events are also
published. The default font is Consolas 10pt; the editor assumes a
fixed-pitch font — caret math is one column per character cell.

### TCodeEditorOptions

| Option | Default | Meaning |
|---|---|---|
| `BracketMatching` | `True` | Outline the matching `()`, `[]`, `{}` pair around the caret. |
| `LineCommentPrefix` | `'//'` | Prefix used by `ToggleLineComment` / `CommentSelection` / `UncommentSelection`. Set per language (`'--'` for SQL, `'#'` for Python…). |
| `MaxPasteBytes` | 64 MB | Refuse larger text pastes (with a warning beep) before the VCL materialises the clipboard text. `0` disables the guard. |
| `ShowGutter` | `True` | Line-number gutter incl. breakpoint margin. |
| `ShowMinimap` | `False` | VS Code-style file map on the right; click or drag it to scroll. |
| `TabSize` | `2` | Number of spaces the Tab key inserts, and the indent unit for `IndentSelection` / `UnindentSelection`. |
| `ThemeSyntaxColors` | `True` | Re-map token colors to theme-appropriate palettes (separate dark/light sets) instead of using the highlighter's raw `Styles[]`. |

Tab characters already present in loaded text are *rendered* one cell wide so
caret arithmetic stays aligned; the Tab key itself always inserts spaces.

## Runtime properties (public, not published)

| Property | Notes |
|---|---|
| `Caret: TCodePosition` | Get/set the caret (0-based). Setting clears extra carets and scrolls into view. |
| `SelectedText: string` | Get the selection / replace it (undo-grouped). |
| `TopLine`, `LeftColumn: Integer` | Scroll position (0-based, clamped). |
| `ExecutionLine: Integer` | 1-based current-statement line; `-1` (or any value < 1) clears it. |
| `CanUndoAction`, `CanRedoAction: Boolean` | For enabling host UI actions. |

## Methods

**Editing** — `Clear`, `InsertText(Value, AddUndo = True)`, `SelectAll`,
`CommentSelection`, `UncommentSelection`, `ToggleLineComment`,
`IndentSelection`, `UnindentSelection`. All respect `ReadOnly` and create
undo entries.

**Undo** — `Undo`, `Redo`, `ClearUndo`. Plain typing coalesces into one undo
step; everything else (paste, delete, comment toggles, replace-all) is one
step per operation. Undo/redo also restore breakpoints, the execution line,
and the `Modified` flag.

**Search** — `ShowFind`, `ShowReplace` open the in-editor search panel,
seeding it from a single-line selection. Match results refresh live as the
document is edited. See the keyboard table below for panel keys.

**Multi-caret** — `AddNextSelectionOccurrence` (Ctrl+D),
`SelectAllSelectionOccurrences` (Ctrl+Shift+L), `ClearMultipleSelections`
(Esc). With multiple carets active, typing, Backspace/Delete, cut, and paste
apply at every caret.

**Completion** — `TriggerCompletion`, `TriggerSignatureHelp`; see
[Completion](completion.md).

**Navigation** — `ShowLine(Line)` (0-based, alias for `TopLine`).

**Commands** — `ExecuteCommand(Command: TCodeEditorCommand)` for host menus
and toolbars: `eccUndo`, `eccRedo`, `eccCut`, `eccCopy`, `eccPaste`,
`eccSelectAll`, `eccFind`, `eccReplace`, `eccToggleLineComment`,
`eccCommentSelection`, `eccUncommentSelection`, `eccTriggerCompletion`,
`eccTriggerSignatureHelp`.

**Breakpoints / markers** — see
[Breakpoints and line markers](breakpoints-markers.md).

## Events

| Event | Fires |
|---|---|
| `OnChange` | After any text change. |
| `OnCaretChange(Sender, Caret)` | Caret moved (0-based position supplied). |
| `OnSelectionChange(Sender, SelStart, SelEnd)` | Selection changed (normalised: start ≤ end). |
| `OnBreakpointsChanged` | User or code toggled breakpoints (not during streaming). |
| `OnResolveTheme(Sender, Colors)` | Each paint, after the base palette is resolved — override individual colors here. |

## Keyboard reference

| Keys | Action |
|---|---|
| Arrows | Move caret. Up/Down/PgUp/PgDn remember the "desired column" through short lines. |
| Ctrl+Left / Ctrl+Right | Previous / next word |
| Home / End | Line start / end |
| Ctrl+Home / Ctrl+End | Document start / end |
| Shift + any movement | Extend selection |
| Ctrl+A | Select all |
| Ctrl+C / Ctrl+X / Ctrl+V | Copy / cut / paste. Copy and cut are no-ops without a selection (clipboard untouched). |
| Ctrl+Z / Ctrl+Shift+Z / Ctrl+Y | Undo / redo / redo |
| Ctrl+F / Ctrl+H | Find / replace panel |
| Ctrl+Space | Trigger completion |
| Ctrl+Shift+Space | Trigger signature help |
| Ctrl+D | Add next occurrence of the selection as another caret |
| Ctrl+Shift+L | Select all occurrences |
| Tab | Insert `TabSize` spaces; with a multi-line selection, indent the selected lines |
| Shift+Tab | Unindent the current line / selected lines |
| F5 or F9 | Toggle breakpoint on the caret line |
| Esc | In order: clear extra carets → hide signature help → close the search panel |
| Backspace / Delete | Delete (multi-caret aware; joins lines at the edges) |

Inside the search panel: `Enter` next match, `Shift+Enter` previous,
`Enter` in the replace edit replaces the current match and advances,
`Esc` closes.

Mouse: double-click selects the word; drag selects; Shift+click extends;
clicking the breakpoint margin toggles a breakpoint; the minimap and styled
scrollbars support click-to-page and drag.

## Theming

With the default `ThemeMode = ctmVclStyle` the editor follows the active VCL
style. To bridge another theming system (e.g. DevExpress skins), override
colors in `OnResolveTheme` — the VCL-style palette is applied first, so you
only need to override what differs:

```pascal
procedure TMainForm.CodeEditorResolveTheme(Sender: TObject;
  Colors: TCodeEditorThemeColors);
begin
  Colors.Background := GetSkinEditorBackground;
  Colors.Text := GetSkinEditorText;
  Colors.GutterBackground := GetSkinPanelBackground;
  Colors.GutterText := GetSkinMutedText;
  Colors.GutterBorder := GetSkinBorder;
  Colors.SelectionBackground := GetSkinSelection;
  Colors.SelectionText := GetSkinSelectionText;
end;
```

`TCodeEditorThemeColors` carries `Background`, `Text`, `GutterBackground`,
`GutterText`, `GutterBorder`, `SelectionBackground`, and `SelectionText`.
Selected text is painted with `SelectionText` over `SelectionBackground`.
Whether the theme counts as *dark* (for syntax-color remapping, minimap and
scrollbar shading) is decided from the background's luminance.

## Limits worth knowing

- Line storage is an in-memory `TStringList`; undo snapshots the whole
  document per step. Fine for scripts and source files, not for log viewers —
  lower `MaxUndo` and consider `Options.MaxPasteBytes` for hostile input.
- The editor assumes a monospaced font.
- Word wrap is not implemented.
