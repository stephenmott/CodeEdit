# Printing

`TCodeEditorPrinter` (unit `CodeEdit.Print`) prints a `TCodeEditor`'s text with
the highlighter's colours, line numbers and header/footer bands, shows the
standard print dialog, and has a built-in print preview. It is the CodeEdit
equivalent of eControl's `TecSyntPrinter`.

## Wiring up

Drop a `TCodeEditorPrinter` on the form (or create one in code), point it at
the editor, and call one of the three entry points:

```pascal
CodeEditorPrinter1.Editor := CodeEditor1;
CodeEditorPrinter1.Title := 'MyScript.pas';

CodeEditorPrinter1.Execute;   // standard print dialog, then print
CodeEditorPrinter1.Print;     // straight to the current printer, all pages
CodeEditorPrinter1.Preview;   // modal preview with paging, zoom and Print...
```

`Print(FromPage, ToPage)` prints a 1-based inclusive range. `PageCount` says
how many pages the document takes on the current printer. The usual
`TPrinterSetupDialog` works alongside: whatever printer, paper and
orientation it selects is what `Print` uses, unless `Orientation` overrides
it.

## Properties

| Property | Default | Meaning |
|---|---|---|
| `Editor` | | The editor whose text is printed. |
| `Title` | `''` | Print job name, and the `$TITLE` macro. |
| `Header` | `'$TITLE\|\|$DATE $TIME'` | Header band text (see macros). Empty = no band. |
| `Footer` | `'\|Page $PAGE of $PAGES\|'` | Footer band text. |
| `Margins` | 15 mm each | `Left`, `Top`, `Right`, `Bottom` in millimetres from the paper edge. |
| `Options` | all but `cpoSelectionOnly` | See below. |
| `Font` / `UseEditorFont` | editor font | Text font. With `UseEditorFont` (default) the editor's `Font` is used at its point size; the editor's zoom is ignored. |
| `HeaderFont` | Segoe UI 9 | Font of the header and footer bands. |
| `Copies` | 1 | Passed to the printer driver. |
| `Orientation` | `cprPrinterDefault` | `cprPortrait` / `cprLandscape` force the orientation; the default leaves the printer as set up. |

### Options

| Option | Meaning |
|---|---|
| `cpoLineNumbers` | Line-number column (grey, right-aligned) to the left of the text. |
| `cpoSyntaxColors` | Token colours from the highlighter's `Styles[]`. Off prints black; bold/italic are kept either way. |
| `cpoWordWrap` | Wrap long lines at the right margin, preferring to break after a space in the second half of the row. Continuation rows carry no line number. Off cuts the line at the margin. |
| `cpoHeader`, `cpoFooter` | Print the bands. |
| `cpoSelectionOnly` | Print only the lines the editor's selection covers (a selection ending at column 0 doesn't include that line). With no selection everything prints. The print dialog's *Selection* radio sets this for one job. |

Tabs are printed as a single cell, exactly as the editor draws them.

### Header and footer macros

`$TITLE`, `$PAGE` (1-based), `$PAGES`, `$DATE`, `$TIME`, case-insensitive.
Split the text with `|` into up to three sections placed left | centre |
right; text without a `|` is left-aligned. A thin rule separates each band
from the body. `ExpandMacros(S, PageIndex, PageCount)` is public for hosts
that render their own bands.

## Drawing pages yourself

Pagination and drawing are public, so a host can print into any device —
a report engine's canvas, a PDF printer driver, or its own preview:

```pascal
Layout := Printer1.Paginate(Canvas, PaperRect, PrintableRect, DpiX, DpiY);
for I := 0 to Layout.PageCount - 1 do
  Printer1.DrawPage(Canvas, Layout, I);
```

`Paginate` measures the fonts on `Canvas` (at the given DPI, keeping point
sizes), lays the margins out on `PaperRect` (the physical sheet) clipped to
`PrintableRect` (what the device can reach; pass the same rect for a bitmap),
and returns a `TCodePrintLayout` with the content/body rectangles, metrics
and the list of rows (`Line`, `StartCol`, `Length`, `First`). `DrawPage`
draws one 0-based page of that layout and clips the body to the margins; it
does not clear the page first.

## Preview

`Preview` shows `TCodePrintPreviewForm` modally: first/previous/next/last,
a *Page n of m* label, a zoom box (fit page, fit width, 50–200 %), and
*Print...* which runs `Execute`. PageUp/PageDown page through, Esc closes.
The page is rendered at the printer's resolution (capped at 300 dpi) on the
printer's paper and then scaled, so what you see paginates as it prints.
Without any installed printer the preview and `PageCount` use A4 at 300 dpi;
`Print` and `Execute` raise `EPrinter`.
