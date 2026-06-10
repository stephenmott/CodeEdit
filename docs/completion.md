# Completion and Signature Help

`CodeEdit.Completion.pas` contains the provider classes. A provider is a
non-visual `TComponent`; assign it to `TCodeEditor.CompletionProvider` and
one provider serves both code completion and signature (parameter) help.

## Triggering

**Completion** opens when the user presses `Ctrl+Space`
(`TriggerCompletion` / `eccTriggerCompletion`), or automatically after
typing `.`, `(`, or `<`. While the popup is open, further typing re-queries
the provider with the updated prefix; `Up`/`Down` move the selection,
`Enter` or `Tab` accepts, `Esc` cancels. Accepting replaces the word around
the caret with the item's `InsertText`.

**Signature help** opens after typing `(` or `<`, or on `Ctrl+Shift+Space`
(`TriggerSignatureHelp`); typing `,` re-computes the active parameter. The
popup hides on `Esc`, focus loss, or scrolling.

## Writing a provider

For most hosts, drop a `TCustomCodeCompletionProvider` descendant — or use
the events directly:

```pascal
procedure TMainForm.ProviderGetCompletions(Sender: TObject;
  const Context: TCodeCompletionContext; Items: TCodeCompletionItems);
var
  Symbol: TMySymbol;
begin
  for Symbol in SymbolTable.Match(Context.Prefix) do
    Items.AddItem(Symbol.Name,                  // shown in the list
      Symbol.Name,                              // inserted text
      ckFunction,                               // kind
      Symbol.Signature);                        // detail column
end;

procedure TMainForm.ProviderGetSignatureHelp(Sender: TObject;
  const Context: TCodeSignatureHelpContext; Items: TCodeSignatureItems);
begin
  if SameText(Context.FunctionName, 'ShowMessage') then
    Items.AddItem('ShowMessage', ['Msg: string']);
end;
```

Returning no items closes the popup, so a provider can simply decline.

### TCodeCompletionContext

| Field | Meaning |
|---|---|
| `Line`, `Column` | Caret position (0-based). |
| `Prefix` | The identifier fragment to the left of the caret (letters, digits, `_`). |
| `TriggerChar` | The character that auto-triggered completion (`.`, `(`, `<`), or `#0` for explicit/typing re-query. |
| `LineText` | The full current line, for context-sensitive decisions. |
| `ExplicitRequest` | `True` when the user pressed Ctrl+Space. |

### TCodeSignatureHelpContext

| Field | Meaning |
|---|---|
| `FunctionName` | Identifier before the innermost unclosed `(`/`<` on the line. |
| `ActiveParameter` | 0-based parameter index derived from commas. |
| `TriggerChar` | `(`, `<`, `,`, or `#0` for explicit requests. |
| `Line`, `Column`, `LineText`, `ExplicitRequest` | As above. |

The first signature item returned is displayed; the active parameter is
rendered in `[brackets]` and the item's `Detail` appears on a second line.

## Item classes

- `TCodeCompletionItem` — `Caption` (list display), `InsertText` (what is
  inserted), `Detail` (right-hand column), and `Kind`
  (`TCodeCompletionItemKind`: `ckText`, `ckKeyword`, `ckFunction`,
  `ckProcedure`, `ckMethod`, `ckProperty`, `ckVariable`, `ckClass`,
  `ckTable`, `ckColumn`, `ckSnippet`, `ckParameter`).
- `TCodeCompletionItems` / `TCodeSignatureItems` — owning lists with
  `AddItem` convenience methods.
- `TCodeSignatureItem` — `Name`, `Parameters: TStrings`, `Detail`.

## TKeywordCompletionProvider

A ready-made provider that completes from a sorted, case-insensitive
`Keywords` string list (published, editable in the Object Inspector). It
filters with `StartsText` against `Context.Prefix`. Useful on its own for
keyword-only languages, or as a base class — override `GetCompletions`,
call `inherited` to get the keywords, then append symbols of your own.
