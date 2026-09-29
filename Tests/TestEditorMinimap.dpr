program TestEditorMinimap;

// Regression test for the minimap: click-to-line, drag-scrolls-only, and the
// hover preview window (Options.MinimapPreview).
// Build:  dcc32 -U..\Source -NSSystem;Vcl;Winapi;System.Win TestEditorMinimap.dpr
// (from an rsvars.bat shell) - the editor unit and its dependencies are picked
// up from ..\Source through the -U search path.

{$APPTYPE CONSOLE}

uses
  System.SysUtils, System.Classes, Winapi.Windows, Winapi.Messages, Vcl.Forms,
  Vcl.Controls, CodeEdit.Editor;

type
  TCracker = class(TCodeEditor);

const
  PreviewClass = 'TCodeMinimapPreviewWindow';
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

function PreviewVisible: Boolean;
var
  Wnd: HWND;
begin
  Wnd := FindWindow(PreviewClass, nil);
  Result := (Wnd <> 0) and IsWindowVisible(Wnd);
end;

// Pump messages for a while so TTimer's WM_TIMER gets delivered.
procedure Pump(Ms: Integer);
var
  Deadline: Cardinal;
begin
  Deadline := GetTickCount + Cardinal(Ms);
  repeat
    Application.ProcessMessages;
    Sleep(10);
  until GetTickCount >= Deadline;
end;

// The minimap sits at the right edge; X in the middle of it.
function MapX: Integer;
begin
  Result := Ed.ClientWidth - 100;
end;

// Minimap row of a document line while TopLine = 0 (map not scrolled):
// 4 px per line, so the middle of line L is at 4*L + 2.
function MapY(Line: Integer): Integer;
begin
  Result := Line * 4 + 2;
end;

var
  I: Integer;
  Text: string;
  L1, L2: Integer;
begin
  Application.Initialize;
  Form := TForm.Create(nil);
  try
    // MouseDown focuses the editor, which needs a visible form; park it off
    // screen so the test doesn't flash a window at the user.
    Form.Position := poDesigned;
    Form.SetBounds(-4000, -4000, 900, 700);
    Ed := TCodeEditor.Create(Form);
    Ed.Parent := Form;
    Ed.SetBounds(0, 0, 800, 600);
    Ed.Options.ShowMinimap := True;
    Form.Show;
    Ed.HandleNeeded;

    Text := '';
    for I := 1 to LineCount do
      Text := Text + Format('line %d := %d;', [I, I]) + sLineBreak;
    Ed.Lines.Text := Text;
    Ed.Caret := TCodePosition.Create(0, 0);
    Check(Ed.TopLine = 0, 'starts at top');

    // 1. Click on the minimap goes to that line (and scrolls it into view).
    TCracker(Ed).MouseDown(mbLeft, [ssLeft], MapX, MapY(60));
    TCracker(Ed).MouseUp(mbLeft, [], MapX, MapY(60));
    Check(Ed.Caret.Line = 60, 'click on map row 60 puts caret on line 60: ' +
      IntToStr(Ed.Caret.Line));
    Check(Ed.Caret.Column = 0, 'click puts caret at column 0');
    Check((Ed.TopLine <= 60) and (60 < Ed.TopLine + 40), 'clicked line is visible, TopLine=' +
      IntToStr(Ed.TopLine));

    // 2. A drag scrolls but leaves the caret alone.
    L1 := Ed.Caret.Line;
    TCracker(Ed).MouseDown(mbLeft, [ssLeft], MapX, 100);
    TCracker(Ed).MouseMove([ssLeft], MapX, 300);
    TCracker(Ed).MouseUp(mbLeft, [], MapX, 300);
    Check(Ed.Caret.Line = L1, 'drag does not move the caret');
    Check(Ed.TopLine > 0, 'drag scrolled the view, TopLine=' + IntToStr(Ed.TopLine));

    // 3. Hovering the minimap shows the preview after the dwell; it tracks
    //    the mouse and hides when the mouse leaves the map.
    Ed.TopLine := 0;
    Check(not PreviewVisible, 'no preview before hovering');
    TCracker(Ed).MouseMove([], MapX, MapY(30));
    Check(not PreviewVisible, 'preview waits for the dwell');
    Pump(400);
    Check(PreviewVisible, 'preview appears after hovering the map');
    TCracker(Ed).MouseMove([], MapX, MapY(90));
    Check(PreviewVisible, 'preview stays up while moving along the map');
    TCracker(Ed).MouseMove([], 200, 200);
    Check(not PreviewVisible, 'preview hides when the mouse leaves the map');

    // 4. Hovering below the last mapped row shows nothing.
    Ed.Lines.Text := 'one' + sLineBreak + 'two' + sLineBreak + 'three';
    TCracker(Ed).MouseMove([], MapX, 300);
    Pump(400);
    Check(not PreviewVisible, 'no preview below the last line of a short file');
    TCracker(Ed).MouseMove([], MapX, MapY(1));
    Pump(400);
    Check(PreviewVisible, 'preview for a short file');
    TCracker(Ed).MouseMove([], 200, 200);

    // 5. Option off: nothing pops up; the click still goes to the line.
    Ed.Lines.Text := Text;
    Ed.Options.MinimapPreview := False;
    TCracker(Ed).MouseMove([], MapX, MapY(30));
    Pump(400);
    Check(not PreviewVisible, 'MinimapPreview=False shows no preview');
    TCracker(Ed).MouseDown(mbLeft, [ssLeft], MapX, MapY(30));
    TCracker(Ed).MouseUp(mbLeft, [], MapX, MapY(30));
    Check(Ed.Caret.Line = 30, 'click still jumps with the preview off: ' +
      IntToStr(Ed.Caret.Line));

    // 6. Clicking below the map of a short file goes to the last line.
    Ed.Lines.Text := 'one' + sLineBreak + 'two' + sLineBreak + 'three';
    Ed.Caret := TCodePosition.Create(0, 0);
    TCracker(Ed).MouseDown(mbLeft, [ssLeft], MapX, 300);
    TCracker(Ed).MouseUp(mbLeft, [], MapX, 300);
    L2 := Ed.Caret.Line;
    Check(L2 = 2, 'click below the map goes to the last line: ' + IntToStr(L2));
  finally
    Form.Free;
  end;
  if ExitCode = 0 then
    WriteLn('ALL PASS')
  else
    WriteLn('FAILURES');
end.
