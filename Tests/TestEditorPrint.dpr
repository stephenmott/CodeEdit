program TestEditorPrint;

// Regression test for TCodeEditorPrinter: pagination (wrap, line numbers,
// header/footer bands, selection-only), macro expansion and page drawing on
// a bitmap device. Printer-independent: paginates an A4 sheet at 96 dpi.
// Also writes page1.png next to the exe for a visual check.
// Build:  dcc32 -U..\Source -NSSystem;Vcl;Winapi;System.Win;Vcl.Imaging TestEditorPrint.dpr
// (from an rsvars.bat shell).

{$APPTYPE CONSOLE}

uses
  System.SysUtils, System.Types, System.Classes, System.Math, Winapi.Windows, Vcl.Forms,
  Vcl.Controls, Vcl.Graphics, Vcl.Imaging.pngimage,
  CodeEdit.Editor, CodeEdit.Highlighter, CodeEdit.Print;

type
  TCracker = class(TCodeEditor);

const
  A4W = 794;    // 210 mm at 96 dpi
  A4H = 1123;   // 297 mm at 96 dpi
  LongLineIndex = 20;

var
  Form: TForm;
  Ed: TCodeEditor;
  HL: TDelphiCodeHighlighter;
  Prn: TCodeEditorPrinter;
  Bmp: Vcl.Graphics.TBitmap;

procedure Check(Cond: Boolean; const Msg: string);
begin
  if Cond then
    WriteLn('PASS  ', Msg)
  else
  begin
    WriteLn('FAIL  ', Msg);
    ExitCode := 1;
  end;
end;

function RowsForLine(const L: TCodePrintLayout; Line: Integer): Integer;
var
  R: TCodePrintRow;
begin
  Result := 0;
  for R in L.Rows do
    if R.Line = Line then
      Inc(Result);
end;

function Paginate: TCodePrintLayout;
begin
  Result := Prn.Paginate(Bmp.Canvas, Rect(0, 0, A4W, A4H), Rect(0, 0, A4W, A4H), 96, 96);
end;

// Any non-white pixel inside R?
function HasInk(const R: TRect): Boolean;
var
  X, Y: Integer;
begin
  for Y := R.Top to R.Bottom - 1 do
    for X := R.Left to R.Right - 1 do
      if Bmp.Canvas.Pixels[X, Y] <> clWhite then
        Exit(True);
  Result := False;
end;

var
  I: Integer;
  Key: Word;
  Text: string;
  L, L2: TCodePrintLayout;
  Png: TPngImage;
  R: TCodePrintRow;
  MinLine, MaxLine: Integer;
  Dir: string;
begin
  Application.Initialize;
  Form := TForm.Create(nil);
  Bmp := Vcl.Graphics.TBitmap.Create;
  try
    Bmp.PixelFormat := pf24bit;
    Bmp.SetSize(A4W, A4H);
    HL := TDelphiCodeHighlighter.Create(Form);
    Ed := TCodeEditor.Create(Form);
    Ed.Parent := Form;
    Ed.SetBounds(0, 0, 800, 600);
    Ed.Highlighter := HL;
    Form.HandleNeeded;
    Ed.HandleNeeded;

    Text := '';
    for I := 0 to 119 do
      if I = LongLineIndex then
        Text := Text + '  // ' + StringOfChar('x', 60) + ' ' + StringOfChar('y', 60) + ' ' +
          StringOfChar('z', 120) + sLineBreak
      else
        Text := Text + Format('  Value%d := Value%d + 1; // comment ''str'' %d', [I, I, I]) +
          sLineBreak;
    Ed.Lines.Text := Text;

    Prn := TCodeEditorPrinter.Create(Form);
    Prn.Editor := Ed;
    Prn.Title := 'Test';

    // 1. Default options: numbers, wrap, header, footer.
    L := Paginate;
    Check(L.PageCount >= 2, 'multi-page document, pages=' + IntToStr(L.PageCount));
    Check((L.RowsPerPage >= 35) and (L.RowsPerPage <= 70), 'plausible rows per page: ' +
      IntToStr(L.RowsPerPage));
    Check(L.GutterWidth > 0, 'line-number gutter present');
    Check(L.HeaderHeight > 0, 'header band present');
    Check(L.FooterHeight > 0, 'footer band present');
    Check(L.Body.Top > L.Content.Top, 'body starts below the header band');
    Check(L.Content.Left = Round(15 * 96 / 25.4), 'left margin is 15 mm, px=' +
      IntToStr(L.Content.Left));
    Check(RowsForLine(L, LongLineIndex) >= 3, 'long line wraps to several rows: ' +
      IntToStr(RowsForLine(L, LongLineIndex)));
    Check(RowsForLine(L, 0) = 1, 'short line is one row');
    I := 0;
    for R in L.Rows do
      if (R.Line = LongLineIndex) and R.First then
        Inc(I);
    Check(I = 1, 'exactly one first slice per wrapped line');
    for R in L.Rows do
      if R.Line = LongLineIndex then
        Check(R.Length <= L.Columns, 'wrapped slice fits the columns');
    Check(Length(L.Rows) = 119 + RowsForLine(L, LongLineIndex), 'row count = lines + extra wraps');

    // 2. Draw page 1: ink in the header, gutter and body; none in the margins.
    Bmp.Canvas.Brush.Color := clWhite;
    Bmp.Canvas.FillRect(Rect(0, 0, A4W, A4H));
    Prn.DrawPage(Bmp.Canvas, L, 0);
    Check(HasInk(Rect(L.Content.Left, L.Content.Top, L.Content.Right, L.Body.Top)),
      'header band drawn');
    Check(HasInk(Rect(L.Body.Left, L.Body.Top, L.Body.Left + L.GutterWidth, L.Body.Top +
      L.LineHeight)), 'line number drawn');
    Check(HasInk(Rect(L.Body.Left + L.GutterWidth, L.Body.Top, L.Body.Right, L.Body.Top +
      L.LineHeight)), 'first text row drawn');
    Check(HasInk(Rect(L.Content.Left, L.Body.Bottom, L.Content.Right, L.Content.Bottom)),
      'footer band drawn');
    Check(not HasInk(Rect(0, 0, A4W, L.Content.Top - 1)), 'top margin blank');
    Check(not HasInk(Rect(0, 0, L.Content.Left - 1, A4H)), 'left margin blank');
    Check(not HasInk(Rect(0, L.Content.Bottom + 1, A4W, A4H)), 'bottom margin blank');

    Dir := ExtractFilePath(ParamStr(0));
    Png := TPngImage.Create;
    try
      Png.Assign(Bmp);
      Png.SaveToFile(Dir + 'page1.png');
    finally
      Png.Free;
    end;

    // 3. Last page draws without error and has fewer rows.
    Bmp.Canvas.FillRect(Rect(0, 0, A4W, A4H));
    Prn.DrawPage(Bmp.Canvas, L, L.PageCount - 1);
    Check(HasInk(Rect(L.Body.Left, L.Body.Top, L.Body.Right, L.Body.Top + L.LineHeight)),
      'last page has its first row');
    Check(not HasInk(Rect(L.Body.Left, L.Body.Bottom - L.LineHeight, L.Body.Right,
      L.Body.Bottom)), 'last page bottom row empty');
    Prn.DrawPage(Bmp.Canvas, L, L.PageCount);   // out of range: no-op, no exception
    Check(True, 'out-of-range page is a no-op');

    // 4. No wrap: the long line is one (cut) row.
    Prn.Options := Prn.Options - [cpoWordWrap];
    L2 := Paginate;
    Check(RowsForLine(L2, LongLineIndex) = 1, 'no-wrap: long line is one row');
    Check(Length(L2.Rows) = 120, 'no-wrap: one row per line');
    Prn.Options := Prn.Options + [cpoWordWrap];

    // 5. Line numbers / header / footer off.
    Prn.Options := Prn.Options - [cpoLineNumbers, cpoHeader, cpoFooter];
    L2 := Paginate;
    Check(L2.GutterWidth = 0, 'no gutter when line numbers are off');
    Check((L2.HeaderHeight = 0) and (L2.Body.Top = L2.Content.Top), 'no header band');
    Check((L2.FooterHeight = 0) and (L2.Body.Bottom = L2.Content.Bottom), 'no footer band');
    Check(L2.Columns > L.Columns, 'more columns without the gutter');
    Prn.Options := Prn.Options + [cpoLineNumbers, cpoHeader, cpoFooter];

    // 6. Selection only: rows cover just the selected lines. Shift+Down five
    //    times from (10,0) selects (10,0)..(15,0) = lines 10..14.
    Ed.Lines.Text := Text;
    Ed.Caret := TCodePosition.Create(10, 0);
    Prn.Options := Prn.Options + [cpoSelectionOnly];
    L2 := Paginate;
    Check(Length(L2.Rows) = Length(L.Rows), 'selection-only with no selection prints everything');
    for I := 1 to 5 do
    begin
      Key := VK_DOWN;
      TCracker(Ed).KeyDown(Key, [ssShift]);
    end;
    Check(Ed.HasSelection and (Ed.SelectionStart.Line = 10) and (Ed.SelectionEnd.Line = 15) and
      (Ed.SelectionEnd.Column = 0), 'selection (10,0)..(15,0) made');
    L2 := Paginate;
    MinLine := MaxInt;
    MaxLine := -1;
    for R in L2.Rows do
    begin
      MinLine := Min(MinLine, R.Line);
      MaxLine := Max(MaxLine, R.Line);
    end;
    Check((Length(L2.Rows) = 5) and (MinLine = 10) and (MaxLine = 14),
      Format('selection-only prints lines 10..14: %d rows, %d..%d', [Length(L2.Rows), MinLine,
      MaxLine]));
    Ed.SelectAll;
    L2 := Paginate;
    Check(Length(L2.Rows) = Length(L.Rows), 'select-all prints everything');
    Prn.Options := Prn.Options - [cpoSelectionOnly];
    Ed.Caret := TCodePosition.Create(0, 0);

    // 7. Macros.
    Check(Prn.ExpandMacros('$PAGE/$PAGES $TITLE', 1, 5) = '2/5 Test', 'macro expansion: ' +
      Prn.ExpandMacros('$PAGE/$PAGES $TITLE', 1, 5));
    Check(Pos('$', Prn.ExpandMacros('$DATE $TIME', 0, 1)) = 0, 'date/time macros expand');

    // 8. Margins change the content rect; mono colours still draw.
    Prn.Margins.Left := 30;
    L2 := Paginate;
    Check(L2.Content.Left = Round(30 * 96 / 25.4), '30 mm left margin');
    Check(L2.Columns < L.Columns, 'wider margin, fewer columns');
    Prn.Margins.Left := 15;
    Prn.Options := Prn.Options - [cpoSyntaxColors];
    Bmp.Canvas.FillRect(Rect(0, 0, A4W, A4H));
    Prn.DrawPage(Bmp.Canvas, Paginate, 0);
    Check(HasInk(Rect(L.Body.Left + L.GutterWidth, L.Body.Top, L.Body.Right, L.Body.Top +
      L.LineHeight)), 'monochrome page draws');
    Prn.Options := Prn.Options + [cpoSyntaxColors];

    // 9. Empty document and no editor.
    Ed.Lines.Text := '';
    L2 := Paginate;
    Check((L2.PageCount = 1) and (Length(L2.Rows) = 1), 'empty document is one blank page');
    Prn.Editor := nil;
    L2 := Paginate;
    Check(L2.PageCount = 0, 'no editor: no pages');
    Check(Prn.PageCount = 0, 'PageCount without an editor is 0');
    Prn.Editor := Ed;
    Ed.Lines.Text := Text;
    Check(Prn.PageCount >= 1, 'PageCount on the printer (or A4 fallback): ' +
      IntToStr(Prn.PageCount));

    // 10. Rows of the whole layout are in document order with no gaps.
    MinLine := MaxInt;
    MaxLine := -1;
    for R in L.Rows do
    begin
      MinLine := Min(MinLine, R.Line);
      MaxLine := Max(MaxLine, R.Line);
    end;
    Check((MinLine = 0) and (MaxLine = 119), 'rows span the whole document');
  finally
    Bmp.Free;
    Form.Free;
  end;
  if ExitCode = 0 then
    WriteLn('ALL PASS')
  else
    WriteLn('FAILURES');
end.
