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
  finally
    Form.Free;
  end;
  if ExitCode = 0 then
    WriteLn('ALL PASS')
  else
    WriteLn('FAILURES');
end.
