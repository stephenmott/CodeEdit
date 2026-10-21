program ScrEditDemo;

{ Dummy host for the ScrEdit sample: opens the script editor form (frmEditor)
  through its EditScript entry point with a small Pascal script, no database
  and no script data module, so the editor UI - CodeEdit editors, the Editor
  Options dialogs, printing, templates - can be exercised on its own.

  It needs the host application's library units (lzProduct.inc, TOPS.inc,
  frmEval, frmProcList, scrCTL, uCalcul, ...) plus DevExpress, JVCL,
  FastScript and NexusDB on the library path. The project defines
  REMOVE_MITEC like the real applications do.

  Status: does not build yet. frmEditor uses scrCTL and utlSYS, both of
  which use utlFIL, and utlFIL (line ~3788) still uses uMitec10, which no
  longer compiles under Delphi 13 - that dependency is being purged from
  the library; once utlFIL drops uMitec10 this project should link. }

uses
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.Themes,
  Vcl.Styles,
  frmEditor in 'frmEditor.pas' {Form1};

{$R *.res}

const
  SampleScript =
    'program Sample;'#13#10 +
    ''#13#10 +
    'var'#13#10 +
    '  I: Integer;'#13#10 +
    '  Total: Integer;'#13#10 +
    ''#13#10 +
    'procedure Report(const Caption: string; Value: Integer);'#13#10 +
    'begin'#13#10 +
    '  ShowMessage(Caption + '' = '' + IntToStr(Value));'#13#10 +
    'end;'#13#10 +
    ''#13#10 +
    'begin'#13#10 +
    '  Total := 0;'#13#10 +
    '  for I := 1 to 10 do'#13#10 +
    '    Total := Total + I * I;'#13#10 +
    '  Report(''Sum of squares'', Total);'#13#10 +
    'end.';

var
  Notes: string;
  Script: string;
begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Notes := 'Notes for the script go in the output pane.';
  Script := EditScript(nil, SampleScript, '', Notes, 'Pascal script', 'ScrEdit sample');
  if Script <> SampleScript then
    ShowMessage('Script was changed and accepted:'#13#10#13#10 + Script);
end.
