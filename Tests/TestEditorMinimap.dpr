program TestEditorMinimap;

// Regression test for the minimap: click-to-line, drag-scrolls-only, and the
// hover preview window (Options.MinimapPreview).
// Build:  dcc32 -U..\Source -NSSystem;Vcl;Winapi;System.Win TestEditorMinimap.dpr
// (from an rsvars.bat shell) - the editor unit and its dependencies are picked
// up from ..\Source through the -U search path.

{$APPTYPE CONSOLE}

uses
  System.SysUtils, System.Classes, Winapi.Windows, Winapi.Messages, Vcl.Forms,
  Vcl.Controls, Vcl.Graphics, CodeEdit.Editor;

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

// Paints the editor into a bitmap and returns the minimap strip (the right
// 200 px) as a fresh bitmap.
function PaintMap: TBitmap;
var
  Full: TBitmap;
begin
  Full := TBitmap.Create;
  try
    Full.PixelFormat := pf24bit;
    Full.SetSize(Ed.Width, Ed.Height);
    Ed.PaintTo(Full.Canvas, 0, 0);
    Result := TBitmap.Create;
    Result.PixelFormat := pf24bit;
    Result.SetSize(200, Ed.Height);
    BitBlt(Result.Canvas.Handle, 0, 0, 200, Ed.Height, Full.Canvas.Handle, Ed.Width - 200, 0,
      SRCCOPY);
  finally
    Full.Free;
  end;
end;

function SameBitmap(A, B: TBitmap): Boolean;
var
  Y, X, Bad, FirstY: Integer;
  RA, RB: PByte;
begin
  Result := (A.Width = B.Width) and (A.Height = B.Height);
  if not Result then
    Exit;
  Bad := 0;
  FirstY := -1;
  for Y := 0 to A.Height - 1 do
    if not CompareMem(A.ScanLine[Y], B.ScanLine[Y], A.Width * 3) then
    begin
      Inc(Bad);
      if FirstY < 0 then
      begin
        FirstY := Y;
        RA := A.ScanLine[Y];
        RB := B.ScanLine[Y];
        for X := 0 to A.Width * 3 - 1 do
          if RA[X] <> RB[X] then
          begin
            WriteLn(Format('      first diff at y=%d x=%d (%d vs %d)', [Y, X div 3, RA[X], RB[X]]));
            Break;
          end;
      end;
    end;
  if Bad > 0 then
    WriteLn(Format('      %d differing rows, first at y=%d', [Bad, FirstY]));
  Result := Bad = 0;
end;

// The map as painted after the pending incremental update, compared with the
// same map after the cache is thrown away and rebuilt from scratch.
function MapMatchesFullRender: Boolean;
var
  Incremental, Full: TBitmap;
begin
  Incremental := PaintMap;
  try
    Ed.Options.MinimapStyle := cmsBlocks;   // OptionsChanged invalidates the cache
    Ed.Options.MinimapStyle := cmsText;
    Full := PaintMap;
    try
      Result := SameBitmap(Incremental, Full);
    finally
      Full.Free;
    end;
  finally
    Incremental.Free;
  end;
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
    // screen so the test doesn't flash a window at the user. Off the right
    // edge, not top-left: the preview clamps itself to the monitor's work
    // area and would collapse to nothing at negative coordinates.
    Form.Position := poDesigned;
    Form.SetBounds(20000, 100, 900, 700);
    Ed := TCodeEditor.Create(Form);
    Ed.Parent := Form;
    Ed.SetBounds(0, 0, 800, 600);
    Ed.Options.ShowMinimap := True;
    Check(Ed.Options.MinimapRowHeight = 3, 'default minimap row height is 3');
    Check(Ed.Options.MinimapStyle = cmsText, 'default minimap style is text');
    Ed.Options.MinimapRowHeight := 4;   // MapY below assumes 4 px rows
    Ed.Options.MinimapRowHeight := 1;   // clamps to 2
    Check(Ed.Options.MinimapRowHeight = 2, 'row height clamps to 2');
    Ed.Options.MinimapRowHeight := 4;
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
    Check(Ed.TopLine = 58, 'clicked line sits two rows below the top, TopLine=' +
      IntToStr(Ed.TopLine));

    // 1b. Clicking near the top of the file can't leave two rows above it.
    Ed.TopLine := 0;   // MapY assumes an unscrolled map
    TCracker(Ed).MouseDown(mbLeft, [ssLeft], MapX, MapY(1));
    TCracker(Ed).MouseUp(mbLeft, [], MapX, MapY(1));
    Check((Ed.Caret.Line = 1) and (Ed.TopLine = 0), 'click on line 1 clamps TopLine to 0');

    // 2. A drag scrolls but leaves the caret alone; the press itself doesn't scroll.
    L1 := Ed.Caret.Line;
    TCracker(Ed).MouseDown(mbLeft, [ssLeft], MapX, 100);
    Check(Ed.TopLine = 0, 'press alone does not scroll');
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

    // 5b. Row height drives the click mapping: at 2 px rows, Y=MapY(60)=242
    //     is line 121. Both renderers paint without error.
    Ed.Lines.Text := Text;
    Ed.TopLine := 0;
    Ed.Options.MinimapRowHeight := 2;
    Ed.Repaint;
    TCracker(Ed).MouseDown(mbLeft, [ssLeft], MapX, MapY(60));
    TCracker(Ed).MouseUp(mbLeft, [], MapX, MapY(60));
    Check(Ed.Caret.Line = 121, '2 px rows: same Y maps to line 121: ' + IntToStr(Ed.Caret.Line));
    Ed.Options.MinimapStyle := cmsBlocks;
    Ed.Repaint;
    Ed.Options.MinimapStyle := cmsText;
    Ed.Options.MinimapRowHeight := 4;
    Ed.TopLine := 0;
    Ed.Repaint;
    Ed.TopLine := 50;
    Ed.Repaint;      // scrolled: exercises the cache shift + band render
    Ed.Lines.Text := Text + 'more';
    Ed.Repaint;      // text change: full re-render
    Check(True, 'text and block renderers paint after scroll and edit');

    // 5c. Incremental cache updates must produce the same pixels as a full
    //     render, for edits, inserts and deletes in and above the visible map.
    Ed.Lines.Text := Text;
    Ed.TopLine := 100;
    Ed.Options.MinimapRowHeight := 3;
    PaintMap.Free;                              // establish the cache
    Ed.Lines[150] := Ed.Lines[150] + ' // edited';
    Check(MapMatchesFullRender, 'incremental: edit of a visible line');
    Ed.Lines.Insert(140, 'procedure Inserted;');
    Check(MapMatchesFullRender, 'incremental: line inserted in view');
    Ed.Lines.Delete(145);
    Check(MapMatchesFullRender, 'incremental: line deleted in view');
    Ed.Lines[5] := 'changed above the map';
    Check(MapMatchesFullRender, 'incremental: edit above the map');
    Ed.Lines.Insert(2, 'inserted above the map');
    Check(MapMatchesFullRender, 'incremental: insert above the map (shift)');
    Ed.Lines.Delete(3);
    Check(MapMatchesFullRender, 'incremental: delete above the map (shift)');
    Ed.Lines.Insert(Ed.Lines.Count, 'appended at the end');
    Check(MapMatchesFullRender, 'incremental: append below the map');
    Ed.Lines.Insert(130, '');
    Ed.Lines.Insert(130, 'two');
    Ed.Lines.Insert(130, 'three');
    Check(MapMatchesFullRender, 'incremental: three lines inserted at once');
    Ed.Lines.Delete(130);
    Ed.Lines.Delete(130);
    Ed.Lines[131] := 'x';
    Check(MapMatchesFullRender, 'incremental: deletes plus an edit');
    Ed.Options.MinimapRowHeight := 4;

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
