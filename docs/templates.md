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

// Edit the end-user layer — this is what apps normally want (see below).
TCodeTemplateEditorDialog.Execute(TemplateProvider1);
```

The dialog lists templates with a per-language filter, supports Add /
Duplicate / Delete, and edits the template body in a `TCodeEditor` with the
matching highlighter. It works on a copy — nothing is written back unless the
user clicks OK (`Execute` returns True).

It has two overloads:

- `Execute(AProvider: TCodeTemplateProvider)` — edits the provider's **user
  layer** and auto-saves it (covered in the next section). This is what the
  design-time component editor uses too.
- `Execute(ATemplates: TCodeTemplates)` — edits a single collection in-place,
  for apps that manage one flat set themselves. The caller decides when to
  persist it (e.g. `TemplateProvider1.SaveToFile(...)`).

At design time the dialog is registered as the component editor for
`TCodeTemplateProvider`: double-click the component (or choose
"Edit Templates...") and the changes stream into the DFM.

## User templates on top of built-in ones

The provider holds two layers:

- `Templates` — the application's built-in set (hard-coded or streamed from
  the DFM). Ships with the app; updated by the app.
- `UserTemplates` — the end user's own additions, persisted as JSON in
  `UserFileName`.

`GetTemplates` (and therefore the Ctrl+J popup) merges both. A user template
with the same name **hides** the built-in one, so users can customise shipped
templates too. Typical wiring:

```pascal
AddHardCodedTemplates(TemplateProvider1);                       // built-in layer
TemplateProvider1.UserFileName := AppDataDir + 'templates.json';
TemplateProvider1.LoadUserTemplates;   // quiet no-op when the file is missing
```

`TCodeTemplateEditorDialog.Execute(AProvider)` edits the user layer: built-in
templates are listed read-only for reference, Duplicate turns one into an
editable user copy (keeping its name, i.e. an override), and on OK the user
layer is written back — and saved to `UserFileName` automatically when it is
set. Nothing else is needed in the app.

`Execute(ATemplates: TCodeTemplates)` still edits a single collection
in-place, for apps that want to manage one flat set themselves.

## Persistence

Both `TCodeTemplates` and the provider save and load a simple JSON document
(the provider-level methods operate on the built-in `Templates` layer;
`LoadUserTemplates` / `SaveUserTemplates` handle the user layer):

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

`LoadFromStream` / `SaveToStream` are available for other storage.
