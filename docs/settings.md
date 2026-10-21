# Editor settings and the options dialog

`CodeEdit.Settings` provides `TCodeEditorSettings`, a component that keeps
one editor's user preferences under `HKEY_CURRENT_USER` and shows an
options dialog for them. `CodeEdit.SettingsDlg` holds the dialog form
itself (a regular designed form; open the DFM in the IDE to restyle it).

## Setup

Drop a `TCodeEditorSettings` on the form next to the editor and set:

| Property | Meaning |
|---|---|
| `Editor` | The `TCodeEditor` whose settings this component manages. One component per editor that needs its own preferences; editors that should share them use the same `RegistryPath`. |
| `RegistryPath` | Key under `HKEY_CURRENT_USER`, e.g. `Software\MyApp\ScriptEditor`. Required for `LoadSettings` / `SaveSettings`, which raise `ECodeEditorSettings` when it is empty. |
| `VisibleItems` | Which settings the dialog offers (all by default). Pages with nothing visible are hidden. A log viewer might use `[siWordWrap, siWrapIndent, siFont, siZoom, siThemeMode, siColours]`. |
| `Title` | Dialog caption, default `Editor Options`. |
| `OnApplied` | Fired after a set of values has been applied to the editor (dialog OK/Apply, `LoadSettings`, `ImportFromFile`). |

```pascal
procedure TMainForm.FormCreate(Sender: TObject);
begin
  EditorSettings.LoadSettings;        // False (and no change) on first run
end;

procedure TMainForm.actEditorOptionsExecute(Sender: TObject);
begin
  EditorSettings.Execute;             // applies and saves on OK
end;
```

## Methods

| Method | Notes |
|---|---|
| `LoadSettings: Boolean` | Registry → editor. Returns False, changing nothing, when the key does not exist yet. Values missing from the key keep the editor's current ones, so keys written by older versions still load. |
| `SaveSettings` | Editor → registry. |
| `SettingsExist: Boolean` | Whether the key exists. |
| `DeleteSettings` | Removes the key. |
| `Execute: Boolean` | Shows the dialog. True when the user confirmed; the values are applied and, if `RegistryPath` is set, saved. With an empty path the dialog still works, it just applies. |
| `ExportToFile(FileName)` / `ImportFromFile(FileName)` | Editor ↔ an INI-format text file (section `[CodeEditor]`, the same value names as the registry). The dialog's Export and Import buttons do the same with the values currently shown. |
| `CurrentValues` / `ApplyValues(Values)` | The editor's settings as a `TCodeEditorSettingsValues` record, and apply such a record. Use these to script preferences without the registry. |
| `SaveValuesToFile` / `LoadValuesFromFile` | File ↔ a values record, without touching the editor. |

## What is stored

Everything in `Options` (tab size, bracket matching, line comment prefix,
paste size guard, gutter, minimap and its style and row height, word wrap
and wrap indent, themed syntax colours), the `Font` name, size, bold and
italic, `Zoom`, `StyledScrollBars`, `ScrollBars`, `ThemeMode` and the seven
`Theme` colours. Each is a separate registry value (`TabSize`, `WordWrap`,
`Font.Name`, `Colour.Background`, ...), so they can also be read or
pre-seeded by installers.

## The dialog

Four pages, Editing, Display, Font and Colours, a live preview below them
(the editor's own text and highlighter, or a stock sample when it is empty),
and Import, Export, OK, Cancel and Apply. OK and Apply push the values to
the editor and save them; Cancel discards changes not yet applied. The
minimap and word-wrap sub-options are enabled only while their parent
option is on. The colour boxes are enabled only when the colour mode is
*Custom*; *Follow the VCL style* takes the palette from the active style
instead.

## Theme sources (DevExpress skins and the like)

The core package cannot depend on DevExpress, so other palettes plug in:

```pascal
RegisterCodeEditorThemeSource('DevExpress', 'Follow the DevExpress skin',
  ApplyDevExpressThemeToEditor);
```

`CodeEdit.DevExpressTheme` does exactly this in its initialization section,
so any application that links that unit gets *Follow the DevExpress skin*
as a third entry in the colour mode box. The chosen source's name is stored
with the other values (`ThemeSource`) and re-applied by `LoadSettings`; the
component's `ThemeSource` property holds the choice in force and can be
preset at design time. A saved name that is no longer registered is kept
but ignored. A source applies once per apply; pair it with
`TCodeEditorDevExpressTheme` to follow skin changes made afterwards.
