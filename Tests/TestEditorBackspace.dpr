program TestEditorBackspace;

// Regression test for caret placement after Backspace / Delete / undo and for
// external Lines.Text replacement leaving a stale selection.
// Build:  dcc32 -U..\Source -NSSystem;Vcl;Winapi;System.Win TestEditorBackspace.dpr
// (from an rsvars.bat shell) - the editor unit and its dependencies are picked
// up from ..\Source through the -U search path.

{$APPTYPE CONSOLE}

uses
  System.SysUtils, Winapi.Windows, Vcl.Forms, Vcl.Controls,
  CodeEdit.Editor;

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

procedure Backspace;
var
  Key: Char;
begin
  Key := #8;
  TCracker(Ed).KeyPress(Key);
end;

procedure DelKey;
var
  Key: Word;
begin
  Key := VK_DELETE;
  TCracker(Ed).KeyDown(Key, []);
end;

procedure TypeText(const S: string);
var
  C, Key: Char;
begin
  for C in S do
  begin
    Key := C;
    TCracker(Ed).KeyPress(Key);
  end;
end;

function Pos(L, C: Integer): string;
begin
  Result := Format('(%d,%d)', [L, C]);
end;

function CaretStr: string;
begin
  Result := Pos(Ed.Caret.Line, Ed.Caret.Column);
end;

begin
  Application.Initialize;
  Form := TForm.Create(nil);
  try
    Ed := TCodeEditor.Create(Form);
    Ed.Parent := Form;
    Ed.SetBounds(0, 0, 400, 300);
    Form.HandleNeeded;
    Ed.HandleNeeded;

    // 1. Typed text then Backspace: caret must land right after the remaining text.
    Ed.Lines.Text := '';
    Ed.Caret := TCodePosition.Create(0, 0);
    TypeText('hellod');
    Check(Ed.Lines[0] = 'hellod', 'typed hellod: ' + Ed.Lines[0]);
    Check(CaretStr = Pos(0, 6), 'caret after typing at (0,6): ' + CaretStr);
    Backspace;
    Check(Ed.Lines[0] = 'hello', 'backspace text = hello: ' + Ed.Lines[0]);
    Check(CaretStr = Pos(0, 5), 'backspace caret at (0,5): ' + CaretStr);
    TypeText('!');
    Check(Ed.Lines[0] = 'hello!', 'typing after backspace appends: ' + Ed.Lines[0]);

    // 2. Backspace in the middle of a line.
    Ed.Lines.Text := 'abcdef';
    Ed.Caret := TCodePosition.Create(0, 3);
    Backspace;
    Check(Ed.Lines[0] = 'abdef', 'mid-line backspace text: ' + Ed.Lines[0]);
    Check(CaretStr = Pos(0, 2), 'mid-line backspace caret (0,2): ' + CaretStr);

    // 3. Backspace at column 0 joins with the previous (shorter/longer) line - 2 lines.
    Ed.Lines.Text := 'abc' + sLineBreak + 'de';
    Ed.Caret := TCodePosition.Create(1, 0);
    Backspace;
    Check(Ed.Lines.Count = 1, 'join: one line left');
    Check(Ed.Lines[0] = 'abcde', 'join text: ' + Ed.Lines[0]);
    Check(CaretStr = Pos(0, 3), 'join caret (0,3): ' + CaretStr);

    // 4. Join in the middle of a 3-line document.
    Ed.Lines.Text := 'abc' + sLineBreak + 'de' + sLineBreak + 'fgh';
    Ed.Caret := TCodePosition.Create(1, 0);
    Backspace;
    Check(Ed.Lines.Count = 2, '3-line join: two lines left');
    Check((Ed.Lines[0] = 'abcde') and (Ed.Lines[1] = 'fgh'), '3-line join text');
    Check(CaretStr = Pos(0, 3), '3-line join caret (0,3): ' + CaretStr);

    // 5. Join where the previous line is longer than the current one.
    Ed.Lines.Text := 'abcdefgh' + sLineBreak + 'x';
    Ed.Caret := TCodePosition.Create(1, 0);
    Backspace;
    Check(Ed.Lines[0] = 'abcdefghx', 'long-prev join text: ' + Ed.Lines[0]);
    Check(CaretStr = Pos(0, 8), 'long-prev join caret (0,8): ' + CaretStr);

    // 6. Backspace at (0,0) is a no-op.
    Ed.Lines.Text := 'abc';
    Ed.Caret := TCodePosition.Create(0, 0);
    Backspace;
    Check((Ed.Lines[0] = 'abc') and (CaretStr = Pos(0, 0)), 'backspace at origin no-op');

    // 7. Backspace with a selection deletes the selection.
    Ed.Lines.Text := 'hello world';
    Ed.SelectAll;
    Backspace;
    Check((Ed.Lines.Count = 1) and (Ed.Lines[0] = ''), 'selection backspace empties');
    Check(CaretStr = Pos(0, 0), 'selection backspace caret (0,0): ' + CaretStr);

    // 8. Delete key forward join keeps the caret.
    Ed.Lines.Text := 'abc' + sLineBreak + 'de';
    Ed.Caret := TCodePosition.Create(0, 3);
    DelKey;
    Check((Ed.Lines.Count = 1) and (Ed.Lines[0] = 'abcde'), 'delete-key join text');
    Check(CaretStr = Pos(0, 3), 'delete-key join caret (0,3): ' + CaretStr);

    // 9. Regression for the LinesChanged clamp: stale selection after external Lines.Text.
    Ed.Lines.Text := 'a much longer line of text' + sLineBreak + 'second line';
    Ed.SelectAll;
    Ed.Lines.Text := 'x';
    try
      Check(Ed.SelectedText <> '?', 'SelectedText after external shrink does not raise');
      Check(Ed.Caret.Line = 0, 'caret clamped to line 0 after external shrink: ' + CaretStr);
      Check(Ed.Caret.Column <= 1, 'caret clamped to line length after external shrink');
    except
      on E: Exception do
        Check(False, 'exception after external shrink: ' + E.Message);
    end;

    // 10. Undo restores the backspaced character.
    Ed.Lines.Text := 'hellod';
    Ed.Caret := TCodePosition.Create(0, 6);
    Backspace;
    Ed.Undo;
    Check(Ed.Lines[0] = 'hellod', 'undo restores text: ' + Ed.Lines[0]);
    Check(CaretStr = Pos(0, 6), 'undo restores caret (0,6): ' + CaretStr);
  finally
    Form.Free;
  end;
  if ExitCode = 0 then
    WriteLn('ALL PASS')
  else
    WriteLn('FAILURES');
end.
