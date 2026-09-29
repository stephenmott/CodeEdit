program TestEditorNavigate;

// Regression test for programmatic caret jumps (Caret := ...): an off-screen
// target lands with context above it instead of on the top edge; a target
// already in view doesn't scroll.
// Build:  dcc32 -U..\Source -NSSystem;Vcl;Winapi;System.Win TestEditorNavigate.dpr
// (from an rsvars.bat shell).

{$APPTYPE CONSOLE}

uses
  System.SysUtils, Winapi.Windows, Vcl.Forms, Vcl.Controls,
  CodeEdit.Editor;

const
  LineCount = 400;

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

var
  I, T, Gap: Integer;
  Text: string;
begin
  Application.Initialize;
  Form := TForm.Create(nil);
  try
    Ed := TCodeEditor.Create(Form);
    Ed.Parent := Form;
    Ed.SetBounds(0, 0, 800, 600);   // ~33 rows at Consolas 10
    Form.HandleNeeded;
    Ed.HandleNeeded;

    Text := '';
    for I := 1 to LineCount do
      Text := Text + Format('line %d', [I]) + sLineBreak;
    Ed.Lines.Text := Text;
    Ed.Caret := TCodePosition.Create(0, 0);
    Check(Ed.TopLine = 0, 'starts at top');

    // 1. Jump far down: line lands a quarter of the way down, not on the top edge.
    Ed.Caret := TCodePosition.Create(200, 0);
    T := Ed.TopLine;
    Gap := 200 - T;
    Check(Ed.Caret.Line = 200, 'caret on the target line');
    Check((Gap >= 2) and (Gap <= 12), 'jump down leaves context above, gap=' + IntToStr(Gap));

    // 2. Jump far up: same placement.
    Ed.Caret := TCodePosition.Create(50, 0);
    Gap := 50 - Ed.TopLine;
    Check((Gap >= 2) and (Gap <= 12), 'jump up leaves context above, gap=' + IntToStr(Gap));

    // 3. Target already in view: no scroll at all.
    T := Ed.TopLine;
    Ed.Caret := TCodePosition.Create(T + 10, 0);
    Check(Ed.TopLine = T, 'in-view target does not scroll');

    // 4. Near the top of the file the view clamps to 0 (line 1 stays visible).
    Ed.Caret := TCodePosition.Create(300, 0);
    Ed.Caret := TCodePosition.Create(1, 0);
    Check(Ed.TopLine = 0, 'jump to line 1 shows the top of the file');

    // 5. Near the end the view clamps so the last line is at the bottom.
    Ed.Caret := TCodePosition.Create(LineCount - 1, 0);
    Check(Ed.TopLine > 0, 'jump to the last line scrolls down');
    Check(Ed.Caret.Line = LineCount - 1, 'caret on the last line');
    Check(Ed.TopLine <= LineCount - 1, 'top line never beyond the caret');

    // 6. GotoRoutineBody: skips var/const and a nested local routine.
    Ed.Lines.Text :=
      'procedure Alpha;' + sLineBreak +                //  0
      'var' + sLineBreak +                             //  1
      '  I: Integer;' + sLineBreak +                   //  2
      'const' + sLineBreak +                           //  3
      '  C = 1;' + sLineBreak +                        //  4
      '  function Inner: Integer;' + sLineBreak +      //  5
      '  begin' + sLineBreak +                         //  6
      '    Result := 1;' + sLineBreak +                //  7
      '  end;' + sLineBreak +                          //  8
      'begin' + sLineBreak +                           //  9
      '  I := C;' + sLineBreak +                       // 10
      'end;' + sLineBreak +                            // 11
      '' + sLineBreak +                                // 12
      'procedure Beta; forward;' + sLineBreak +        // 13
      '' + sLineBreak +                                // 14
      'procedure Gamma;' + sLineBreak +                // 15
      'BEGIN' + sLineBreak +                           // 16
      'end;';                                          // 17
    Check(Ed.FindRoutineBodyLine(0) = 9, 'body of Alpha is the begin at the header indent');
    I := Ed.GotoRoutineBody(0);
    Check(I = 10, 'GotoRoutineBody(Alpha) returns the first statement line: ' + IntToStr(I));
    Check((Ed.Caret.Line = 10) and (Ed.Caret.Column = 2), 'caret on the first statement, ' +
      'first non-blank column');
    Check(Ed.FindRoutineBodyLine(13) = 13, 'forward declaration: stops at the next header');
    Check(Ed.GotoRoutineBody(13) = 13, 'GotoRoutineBody on a forward stays on the header');
    Check(Ed.FindRoutineBodyLine(15) = 16, 'keyword match is case-insensitive');
    Check(Ed.GotoRoutineBody(15) = 17, 'Gamma: caret on the line after BEGIN');
    Check(Ed.FindRoutineBodyLine(99) = -1, 'invalid header line returns -1');
    Check(Ed.GotoRoutineBody(5) = 7, 'nested routine as the header: its own body');

    // 7. GotoRoutineBody keeps the header on screen past a long var section.
    Text := '';
    for I := 0 to 99 do
      Text := Text + 'filler ' + IntToStr(I) + sLineBreak;
    Text := Text + 'procedure Big;' + sLineBreak + 'var' + sLineBreak;    // header at 100
    for I := 1 to 20 do
      Text := Text + '  V' + IntToStr(I) + ': Integer;' + sLineBreak;   // 102..121
    Text := Text + 'begin' + sLineBreak + '  V1 := 0;' + sLineBreak + 'end;' + sLineBreak; // 122,123
    for I := 0 to 99 do
      Text := Text + 'filler ' + IntToStr(I) + sLineBreak;
    Ed.Lines.Text := Text;
    Ed.Caret := TCodePosition.Create(0, 0);
    I := Ed.GotoRoutineBody(100);
    Check(I = 123, 'Big: caret line after the begin: ' + IntToStr(I));
    Check(Ed.TopLine = 98, 'Big: header two rows below the top, TopLine=' + IntToStr(Ed.TopLine));

    // 8. ...unless the body is more than a screen below the header: caret wins.
    Text := '';
    Text := Text + 'procedure Huge;' + sLineBreak + 'var' + sLineBreak;   // header at 0
    for I := 1 to 60 do
      Text := Text + '  V' + IntToStr(I) + ': Integer;' + sLineBreak;   // 2..61
    Text := Text + 'begin' + sLineBreak + '  V1 := 0;' + sLineBreak + 'end;' + sLineBreak; // 62,63
    for I := 0 to 99 do
      Text := Text + 'filler ' + IntToStr(I) + sLineBreak;
    Ed.Lines.Text := Text;
    Ed.Caret := TCodePosition.Create(150, 0);
    I := Ed.GotoRoutineBody(0);
    Check(I = 63, 'Huge: caret line after the begin: ' + IntToStr(I));
    Check((Ed.TopLine > 0) and (63 - Ed.TopLine < 40), 'Huge: caret kept visible, TopLine=' +
      IntToStr(Ed.TopLine));
  finally
    Form.Free;
  end;
  if ExitCode = 0 then
    WriteLn('ALL PASS')
  else
    WriteLn('FAILURES');
end.
