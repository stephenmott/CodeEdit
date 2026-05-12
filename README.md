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
- Search panel, minimap, bracket matching, current-line highlight
- IntelliSense-friendly APIs for diagnostics, completion, and symbol navigation
