# Code templates

Templates are named blocks of code inserted with **Ctrl+J** — the same idea as
the classic Delphi IDE code templates. Each template has a `Name` (what the
user types to pick it), a `Description`, an optional `Language` tying it to a
highlighter, and the `Code` to insert.

## Wiring up

Drop a `TCodeTemplateProvider` on the form (or create one in code), fill its
`Templates` collection, and assign it to the editor:

```pascal
TemplateProvider1.Templates.AddTemplate('tryf', 'try..finally', 'Delphi',
  'try' + sLineBreak +
  '  |' + sLineBreak +
  'finally' + sLineBreak +
  'end;');
CodeEditor1.TemplateProvider := TemplateProvider1;
```

`AddTemplate(Name, Description, Language, Code)` is a convenience; the
collection is a regular published `TOwnedCollection`, so templates can also be
edited in the Object Inspector or streamed from the DFM.

## Ctrl+J behaviour

- **Ctrl+J with a word before the caret** — the word is used as a name prefix.
  If exactly one template matches, it is expanded immediately and the word is
  consumed (type `tryf`, press Ctrl+J, get the block). Several matches show
  the filtered popup; no matches show the full list and leave the word alone.
- **Ctrl+J elsewhere** — pops up every template for the current language.
- In the popup: type to narrow the list, Up/Down to select, Enter/Tab or
  double-click to insert, Esc to dismiss.
- One undo step reverts an entire expansion.

`TriggerTemplates` invokes the same logic from code (menus, toolbars), and
`ExecuteCommand(eccTriggerTemplates)` is the command-enum equivalent.
`InsertTemplate(Template)` inserts a specific template at the caret without
showing the popup.

## Placeholder and indentation rules

- `|` marks where the caret lands after insertion; the marker itself is
  removed. Only the first unescaped `|` counts.
- `||` inserts a literal `|`.
- Every line after the template's first line is prefixed with the leading
  whitespace of the line the template is inserted into, so blocks land at the
  surrounding indentation level.

## Languages

A template whose `Language` is empty is offered in every editor. Otherwise it
is offered when it matches the editor highlighter's language name
(case-insensitive). Each bundled highlighter reports its name via the
`TCustomCodeHighlighter.LanguageName` class function:

`Delphi`, `JavaScript`, `SQL`, `Tungli`, `Batch`, `PowerShell`, `INI`,
`YAML`, `Python`.

Custom highlighters inherit a name derived from their class name
(`TFooCodeHighlighter` → `Foo`) and can override `LanguageName`. An editor
with no highlighter shows all templates.

## The template editor dialog

`CodeEdit.TemplateEditorDlg` provides a ready-made maintenance UI:

```pascal
uses CodeEdit.TemplateEditorDlg;

if TCodeTemplateEditorDialog.Execute(TemplateProvider1) then
  TemplateProvider1.SaveToFile(TemplatesFileName);
```

The dialog lists templates with a per-language filter, supports Add /
Duplicate / Delete, and edits the template body in a `TCodeEditor` with the
matching highlighter. It works on a copy — the provider is only modified when
the user clicks OK (`Execute` returns True).

At design time the same dialog is registered as the component editor for
`TCodeTemplateProvider`: double-click the component (or choose
"Edit Templates...") and the changes stream into the DFM.

## Persistence

`TCodeTemplateProvider` saves and loads a simple JSON document:

```pascal
TemplateProvider1.LoadFromFile(AppDataDir + 'templates.json');
TemplateProvider1.SaveToFile(AppDataDir + 'templates.json');
```

```json
{
  "templates": [
    {
      "name": "tryf",
      "description": "try..finally",
      "language": "Delphi",
      "code": "try\r\n  |\r\nfinally\r\nend;\r\n"
    }
  ]
}
```

`LoadFromStream` / `SaveToStream` are available for other storage. Templates
declared in the DFM and a user file can be combined by loading the file into a
second provider and `Assign`-ing, or simply by treating the file as the single
source of truth.
