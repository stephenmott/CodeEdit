program TestEditorWrap;

// Regression test for Options.WordWrap / WrapIndent: row counts (via the
// vertical scrollbar range), Up/Down by visual row, continuation indent,
// Home/End on the whole line, mouse hit-testing on a wrapped row, TopLine
// semantics, editing while wrapped, and toggling wrap off again.
// Build:  dcc32 -U..\Source -NSSystem;Vcl;Winapi;System.Win TestEditorWrap.dpr
// (from an rsvars.bat shell).

{$APPTYPE CONSOLE}

uses
  System.SysUtils, System.Classes, System.Types, Winapi.Windows, Winapi.Messages,
  Vcl.Forms, Vcl.Controls, CodeEdit.Editor;

type
  TCracker = class(TCodeEditor);

var
  Form: TForm;
  Ed: TCodeEditor;

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

procedure Key(VK: Word; Shift: TShiftState = []);
var
  K: Word;
begin
  K := VK;
  TCracker(Ed).KeyDown(K, Shift);
end;

procedure TypeText(const S: string);
var
  C, K: Char;
begin
  for C in S do
  begin
    K := C;
    TCracker(Ed).KeyPress(K);
  end;
end;

function Pos2(L, C: Integer): string;
begin
  Result := Format('(%d,%d)', [L, C]);
end;

function CaretStr: string;
begin
  Result := Pos2(Ed.Caret.Line, Ed.Caret.Column);
end;

// The editor runs with Windows scrollbars here, so the vertical range is the
// row count and the horizontal range shows whether sideways scrolling exists.
function ScrollMax(Bar: Integer): Integer;
var
  Info: TScrollInfo;
begin
  FillChar(Info, SizeOf(Info), 0);
  Info.cbSize := SizeOf(Info);
  Info.fMask := SIF_RANGE;
  GetScrollInfo(Ed.Handle, Bar, Info);
  Result := Info.nMax;
end;

function ScrollPos: Integer;
var
  Info: TScrollInfo;
begin
  FillChar(Info, SizeOf(Info), 0);
  Info.cbSize := SizeOf(Info);
  Info.fMask := SIF_POS;
  GetScrollInfo(Ed.Handle, SB_VERT, Info);
  Result := Info.nPos;
end;

function RowCount: Integer;
begin
  Result := ScrollMax(SB_VERT) + 1;
end;

function CaretPt: TPoint;
begin
  GetCaretPos(Result);
end;

function Rep(const S: string; N: Integer): string;
var
  I: Integer;
begin
  Result := '';
  for I := 1 to N do
    Result := Result + S;
end;

var
  Words, Spiky, Indented, Filler: string;
  W2, Wc, S2, R, R0, Rows, I, CW, N: Integer;
  P, P0, P1, PA, PB: TPoint;
  L: Integer;
begin
  Application.Initialize;
  Form := TForm.Create(nil);
  try
    // Shown (GetCaretPos and SetFocus need it) but parked off the right edge.
    Form.Position := poDesigned;
    Form.SetBounds(20000, 100, 900, 700);
    Ed := TCodeEditor.Create(Form);
    Ed.Parent := Form;
    Ed.SetBounds(0, 0, 800, 600);
    Ed.StyledScrollBars := False;
    Ed.Options.ShowMinimap := False;
    Form.Show;
    Ed.HandleNeeded;
    Ed.SetFocus;

    Words := Rep('word ', 60);                     // 300 chars, breakable
    Spiky := Rep('x', 250);                        // no blanks: hard cuts
    Indented := Rep(' ', 8) + Rep('word ', 60);    // 308 chars, leading indent
    // 60 filler lines keep the document taller than the view, so it can
    // scroll and the (Windows) vertical scrollbar stays put - it auto-hides
    // when everything fits, which would change the wrap width mid-test.
    Filler := '';
    for I := 1 to 60 do
      Filler := Filler + sLineBreak + 'filler ' + IntToStr(I);
    Ed.Lines.Text := Words + sLineBreak + 'short' + sLineBreak + Spiky + sLineBreak + Indented + Filler;
    Ed.Caret := TCodePosition.Create(0, 0);
    Check(Ed.Lines.Count = 64, 'sixty-four lines');
    Check(RowCount = 64, 'wrap off: one row per line, rows=' + IntToStr(RowCount));
    Check(ScrollMax(SB_HORZ) > 0, 'wrap off: horizontal range present');

    // 1. Wrap on: more rows than lines, no horizontal range.
    Ed.Options.WordWrap := True;
    R := RowCount;
    Check(R > 64, 'wrap on: rows exceed lines, rows=' + IntToStr(R));
    Check(ScrollMax(SB_HORZ) = 0, 'wrap on: no horizontal range');
    Check(Ed.LeftColumn = 0, 'wrap on: LeftColumn 0');

    // 2. Down moves by visual row inside line 0 and breaks after a blank.
    Ed.Caret := TCodePosition.Create(0, 0);
    Key(VK_DOWN);
    W2 := Ed.Caret.Column;
    Check(Ed.Caret.Line = 0, 'Down stays on line 0: ' + CaretStr);
    Check((W2 >= 10) and (W2 < 300), 'second row starts at ' + IntToStr(W2));
    Check((Words[W2 + 1] = 'w') and (Words[W2] = ' '), 'row 2 starts on a word after a blank');

    // 3. Count line 0's rows by walking Down until the line changes (the
    //    caret is already on row 2).
    R0 := 2;
    while (Ed.Caret.Line = 0) and (R0 < 50) do
    begin
      Key(VK_DOWN);
      if Ed.Caret.Line = 0 then
        Inc(R0);
    end;
    Check(Ed.Caret.Line = 1, 'Down leaves line 0 onto line 1: ' + CaretStr);
    Check(R0 = (300 + W2 - 1) div W2, Format('line 0 has %d rows for width %d', [R0, W2]));

    // 4. A line with no blanks is cut at the wrap width.
    Ed.Caret := TCodePosition.Create(2, 0);
    Key(VK_DOWN);
    Wc := Ed.Caret.Column;
    Check((Ed.Caret.Line = 2) and (Wc >= W2) and (Wc - W2 < 5),
      Format('hard cut at %d (word break was %d)', [Wc, W2]));

    // 5. The total row count matches walking Down through the whole document.
    Ed.Caret := TCodePosition.Create(0, 0);
    Rows := 1;
    repeat
      P := Point(Ed.Caret.Line, Ed.Caret.Column);
      Key(VK_DOWN);
      if (Ed.Caret.Line <> P.X) or (Ed.Caret.Column <> P.Y) then
        Inc(Rows);
    until ((Ed.Caret.Line = P.X) and (Ed.Caret.Column = P.Y)) or (Rows > 300);
    Check(Rows = R, Format('walked %d rows, scrollbar says %d', [Rows, R]));
    Check(Ed.Caret.Line = Ed.Lines.Count - 1, 'ends on the last line: ' + CaretStr);

    // 6. WrapIndent: continuation rows of line 3 sit under its first word.
    Ed.Options.WrapIndent := True;
    Ed.Caret := TCodePosition.Create(3, 8);
    PA := CaretPt;
    Key(VK_DOWN);
    S2 := Ed.Caret.Column;
    PB := CaretPt;
    Check(Ed.Caret.Line = 3, 'indented line: Down stays on it: ' + CaretStr);
    Check((Indented[S2 + 1] = 'w') and ((S2 - 8) mod 5 = 0), 'row 2 of the indented line starts on a word, col ' +
      IntToStr(S2));
    Check(S2 <= Wc, 'first row of the indented line is not wider than the width');
    Check((PB.X = PA.X) and (PB.Y > PA.Y), Format('caret drawn under the first word: (%d,%d) -> (%d,%d)',
      [PA.X, PA.Y, PB.X, PB.Y]));
    Key(VK_DOWN);
    Check((Ed.Caret.Line = 3) and (Ed.Caret.Column - S2 <= Wc - 8) and (Ed.Caret.Column - S2 > Wc - 8 - 5),
      'continuation rows hold width minus indent: ' + CaretStr);

    // 7. WrapIndent off: same row starts, caret keeps its drawn column.
    Ed.Options.WrapIndent := False;
    Ed.Caret := TCodePosition.Create(3, 8);
    Key(VK_DOWN);
    Check((Ed.Caret.Line = 3) and (Ed.Caret.Column = S2 + 8), 'no indent: Down keeps column 8 of the row: ' +
      CaretStr);
    Check(RowCount >= R, 'no indent: rows=' + IntToStr(RowCount));

    // 8. Home / End work on the whole line.
    Ed.Caret := TCodePosition.Create(0, W2 + 3);
    Key(VK_END);
    Check(Ed.Caret.Column = 300, 'End goes to the end of the line: ' + CaretStr);
    Key(VK_HOME);
    Check(Ed.Caret.Column = 0, 'Home goes to column 0: ' + CaretStr);

    // 9. Mouse: a click on the second row lands in the second row.
    Ed.Caret := TCodePosition.Create(0, 0);
    P0 := CaretPt;
    Ed.Caret := TCodePosition.Create(0, 1);
    P1 := CaretPt;
    CW := P1.X - P0.X;
    Check(CW > 0, 'char width ' + IntToStr(CW));
    Ed.Caret := TCodePosition.Create(0, W2);
    P := CaretPt;
    Check(P.Y > P0.Y, 'row 2 is drawn below row 1');
    TCracker(Ed).MouseDown(mbLeft, [ssLeft], P.X + 3 * CW + 1, P.Y + 3);
    TCracker(Ed).MouseUp(mbLeft, [], P.X + 3 * CW + 1, P.Y + 3);
    Check((Ed.Caret.Line = 0) and (Ed.Caret.Column = W2 + 3), 'click on row 2 col 3: ' + CaretStr);

    // 10. TopLine: scrolling one row inside line 0 leaves TopLine at 0;
    //     setting TopLine scrolls to that line's first row.
    Ed.Caret := TCodePosition.Create(0, 0);
    Ed.TopLine := 0;
    Ed.Perform(WM_VSCROLL, SB_LINEDOWN, 0);
    Check((Ed.TopLine = 0) and (ScrollPos = 1), 'one row down: TopLine still 0, row 1 at the top');
    Ed.TopLine := 1;
    Check((Ed.TopLine = 1) and (ScrollPos = R0), 'TopLine := 1 scrolls to the first row of line 1');

    // 11. Editing while wrapped: type past the end, split, undo.
    Ed.Caret := TCodePosition.Create(0, 300);
    TypeText(' plus some more words');
    Check(Ed.Lines[0] = Words + ' plus some more words', 'typing at the end of a wrapped line');
    Check(Ed.Caret.Column = 321, 'caret after typing: ' + CaretStr);
    Check(RowCount >= R, 'rows after typing=' + IntToStr(RowCount));
    for I := 1 to 21 do
      TypeText(#8);
    Check(Ed.Lines[0] = Words, 'backspace removes it again');
    Ed.Caret := TCodePosition.Create(0, 150);
    TypeText(#13);
    Check((Ed.Lines.Count = 65) and (Ed.Caret.Line = 1) and (Ed.Caret.Column = 0), 'Enter splits the wrapped line: ' +
      CaretStr);
    Ed.Undo;
    Check((Ed.Lines.Count = 64) and (Ed.Lines[0] = Words), 'undo rejoins it');

    // 12. Selection across a wrap break paints without error.
    Ed.Caret := TCodePosition.Create(0, W2 - 2);
    for I := 1 to 4 do
      Key(VK_RIGHT, [ssShift]);
    Check(Length(Ed.SelectedText) = 4, 'selection across the break has 4 chars');
    Ed.Repaint;
    Ed.SelectAll;
    Ed.Repaint;
    Check(True, 'repaint with selections across breaks');

    // 13. PageDown moves by rows inside one very long line, caret stays visible.
    Ed.Lines.Text := Rep('y', 5000);
    Ed.Caret := TCodePosition.Create(0, 0);
    Check(RowCount = (5000 + Wc - 1) div Wc, Format('5000-char line wraps to %d rows', [RowCount]));
    Key(VK_NEXT);
    Check((Ed.Caret.Line = 0) and (Ed.Caret.Column > Wc), 'PageDown moves down the wrapped line: ' + CaretStr);
    Ed.Caret := TCodePosition.Create(0, 4999);
    P := CaretPt;
    Check((P.Y >= 0) and (P.Y < Ed.ClientHeight), 'caret at the end of the long line is in view, y=' +
      IntToStr(P.Y));
    Check(ScrollPos > 0, 'view scrolled down the long line');

    // 14. Narrower editor: more rows, caret still in view.
    N := RowCount;
    Ed.Width := 400;
    Check(RowCount > N, Format('narrower: %d -> %d rows', [N, RowCount]));
    P := CaretPt;
    Check((P.Y >= 0) and (P.Y < Ed.ClientHeight), 'caret still in view after the resize');
    Ed.Width := 800;

    // 15. Empty document and tiny content never fault. (No row count probe
    //     here: Windows resets an auto-hidden scrollbar's range to 0..100.)
    Ed.Lines.Text := '';
    Check((Ed.Lines.Count = 1) and (Ed.Lines[0] = ''), 'empty document is one empty line');
    Check((ScrollPos = 0) and (Ed.TopLine = 0), 'empty document: scrolled to the top');
    Key(VK_DOWN);
    Key(VK_UP);
    Key(VK_NEXT);
    Ed.Repaint;
    Check(CaretStr = Pos2(0, 0), 'empty document: caret at origin');

    // 16. Wrap off again: rows are lines, caret preserved.
    Ed.Lines.Text := Words + sLineBreak + Spiky;
    Ed.Caret := TCodePosition.Create(1, 200);
    L := Ed.Caret.Column;
    Ed.Options.WordWrap := False;
    Check(RowCount = 2, 'wrap off: rows = lines');
    Check(Ed.Caret.Column = L, 'wrap off: caret column kept');
    Check(ScrollMax(SB_HORZ) > 0, 'wrap off: horizontal range back');
    Key(VK_DOWN);
    Check(Ed.Caret.Line = 1, 'wrap off: Down from the last line stays put');
  finally
    Form.Free;
  end;
  if ExitCode = 0 then
    WriteLn('ALL PASS')
  else
    WriteLn('FAILURES');
end.
