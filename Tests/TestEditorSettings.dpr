program TestEditorSettings;

// Regression test for TCodeEditorSettings: registry round trip under a test
// key, export/import through a file, error paths, and the options dialog
// (VisibleItems, controls reflecting the values, OK applying and saving).
// Build:  dcc32 -U..\Source -NSSystem;Vcl;Winapi;System.Win TestEditorSettings.dpr
// (from an rsvars.bat shell).

{$APPTYPE CONSOLE}

uses
  System.SysUtils, System.Classes, System.UITypes, Winapi.Windows, Vcl.Forms,
  Vcl.Controls, Vcl.Graphics, Vcl.StdCtrls,
  CodeEdit.Editor, CodeEdit.Settings, CodeEdit.SettingsDlg;

const
  TestKey = 'Software\CodeEdit\Tests\TestEditorSettings';

var
  Form: TForm;
  Ed, Ed2, Ed3: TCodeEditor;
  Settings: TCodeEditorSettings;
  Dlg: TCodeEditorSettingsDialog;
  TempFile: string;
  Raised: Boolean;
  Applied: Integer;

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

type
  THook = class
    procedure Applied(Sender: TObject);
  end;

procedure THook.Applied(Sender: TObject);
begin
  Inc(TestEditorSettings.Applied);
end;

procedure Customise(E: TCodeEditor);
begin
  E.Options.TabSize := 7;
  E.Options.BracketMatching := False;
  E.Options.LineCommentPrefix := '--';
  E.Options.MaxPasteBytes := 1024 * 1024;
  E.Options.ShowGutter := False;
  E.StyledScrollBars := False;
  E.ScrollBars := ssVertical;
  E.Options.WordWrap := True;
  E.Options.WrapIndent := False;
  E.Options.ShowMinimap := True;
  E.Options.MinimapPreview := False;
  E.Options.MinimapStyle := cmsBlocks;
  E.Options.MinimapRowHeight := 5;
  E.Options.ThemeSyntaxColors := False;
  E.Zoom := 150;
  E.Font.Name := 'Lucida Console';
  E.Font.Size := 12;
  E.Font.Style := [fsBold];
  E.ThemeMode := ctmManual;
  E.Theme.Background := $00112233;
  E.Theme.Text := $00445566;
  E.Theme.GutterBackground := $00778899;
  E.Theme.GutterText := $00AABBCC;
  E.Theme.GutterBorder := $00DDEEFF;
  E.Theme.SelectionBackground := $00123456;
  E.Theme.SelectionText := $00654321;
end;

function SameAsCustomised(E: TCodeEditor; const What: string): Boolean;
begin
  Result :=
    (E.Options.TabSize = 7) and (not E.Options.BracketMatching) and
    (E.Options.LineCommentPrefix = '--') and (E.Options.MaxPasteBytes = 1024 * 1024) and
    (not E.Options.ShowGutter) and (not E.StyledScrollBars) and (E.ScrollBars = ssVertical) and
    E.Options.WordWrap and (not E.Options.WrapIndent) and E.Options.ShowMinimap and
    (not E.Options.MinimapPreview) and (E.Options.MinimapStyle = cmsBlocks) and
    (E.Options.MinimapRowHeight = 5) and (not E.Options.ThemeSyntaxColors) and (E.Zoom = 150) and
    (E.Font.Name = 'Lucida Console') and (E.Font.Size = 12) and (E.Font.Style = [fsBold]) and
    (E.ThemeMode = ctmManual) and (E.Theme.Background = $00112233) and (E.Theme.Text = $00445566) and
    (E.Theme.GutterBackground = $00778899) and (E.Theme.GutterText = $00AABBCC) and
    (E.Theme.GutterBorder = $00DDEEFF) and (E.Theme.SelectionBackground = $00123456) and
    (E.Theme.SelectionText = $00654321);
  Check(Result, What);
end;

var
  Hook: THook;
  V: TCodeEditorSettingsValues;
begin
  Application.Initialize;
  Form := TForm.Create(nil);
  Hook := THook.Create;
  try
    Ed := TCodeEditor.Create(Form);
    Ed.Parent := Form;
    Ed2 := TCodeEditor.Create(Form);
    Ed2.Parent := Form;
    Ed3 := TCodeEditor.Create(Form);
    Ed3.Parent := Form;
    Settings := TCodeEditorSettings.Create(Form);
    Settings.Name := 'EditorSettings';
    Settings.OnApplied := Hook.Applied;

    // 1. Error paths: no editor, no path.
    Raised := False;
    try
      Settings.SaveSettings;
    except
      on ECodeEditorSettings do
        Raised := True;
    end;
    Check(Raised, 'SaveSettings without an editor raises ECodeEditorSettings');
    Settings.Editor := Ed;
    Raised := False;
    try
      Settings.LoadSettings;
    except
      on ECodeEditorSettings do
        Raised := True;
    end;
    Check(Raised, 'LoadSettings without a path raises ECodeEditorSettings');
    Check(not Settings.SettingsExist, 'SettingsExist is False with no path');

    // 2. Fresh key: nothing there, LoadSettings is a no-op returning False.
    Settings.RegistryPath := TestKey;
    Settings.DeleteSettings;
    Check(not Settings.SettingsExist, 'test key absent before the test');
    Check(not Settings.LoadSettings, 'LoadSettings on a missing key returns False');
    Check(Ed.Options.TabSize = 2, 'and changes nothing');
    Check(Applied = 0, 'OnApplied not fired for a missing key');

    // 3. Save customised settings, load them into a different editor.
    Customise(Ed);
    Settings.SaveSettings;
    Check(Settings.SettingsExist, 'SaveSettings created the key');
    Settings.Editor := Ed2;
    Check(Settings.LoadSettings, 'LoadSettings returns True when the key exists');
    SameAsCustomised(Ed2, 'registry round trip restores every value');
    Check(Applied = 1, 'OnApplied fired once by LoadSettings');

    // 4. Export to a file, import into a third editor.
    TempFile := IncludeTrailingPathDelimiter(GetEnvironmentVariable('TEMP')) + 'CodeEditSettingsTest.ini';
    System.SysUtils.DeleteFile(TempFile);
    Settings.ExportToFile(TempFile);
    Check(FileExists(TempFile), 'ExportToFile wrote the file');
    Settings.Editor := Ed3;
    Settings.ImportFromFile(TempFile);
    SameAsCustomised(Ed3, 'file round trip restores every value');
    Raised := False;
    try
      Settings.ImportFromFile(TempFile + '.missing');
    except
      on ECodeEditorSettings do
        Raised := True;
    end;
    Check(Raised, 'ImportFromFile on a missing file raises');

    // 5. Partial key: a value missing from the registry keeps the editor's own.
    Settings.Editor := Ed;
    V := Settings.CurrentValues;
    Check(V.Zoom = 150, 'CurrentValues reads the editor');
    V.Zoom := 80;
    Settings.ApplyValues(V);
    Check(Ed.Zoom = 80, 'ApplyValues writes the editor');

    // 6. Dialog: visibility, values in, OK applies and saves.
    Settings.Editor := Ed;
    Settings.VisibleItems := AllCodeEditorSettingItems - [siFont, siThemeMode, siColours, siTabSize];
    Dlg := TCodeEditorSettingsDialog.Create(nil);
    try
      Dlg.Prepare(Settings);
      Check(not Dlg.TabFont.TabVisible, 'font page hidden');
      Check(not Dlg.TabColours.TabVisible, 'colours page hidden');
      Check(Dlg.TabEditing.TabVisible and Dlg.TabDisplay.TabVisible, 'editing and display pages shown');
      Check(not Dlg.EditTabSize.Visible and not Dlg.LabelTabSize.Visible, 'tab size control hidden');
      Check(Dlg.CheckBracketMatching.Visible, 'bracket matching control shown');
      Check(Dlg.CheckWordWrap.Checked, 'word wrap checkbox reflects the editor');
      Check(not Dlg.CheckWrapIndent.Checked, 'wrap indent checkbox reflects the editor');
      Check(Dlg.EditZoom.Text = '80', 'zoom edit reflects the editor: ' + Dlg.EditZoom.Text);
      Check(Dlg.ComboScrollBars.ItemIndex = Ord(ssVertical), 'scrollbars combo reflects the editor');
      Check(Dlg.PreviewEditor.Options.WordWrap, 'preview follows the controls');
      Check(Dlg.PreviewEditor.Lines.Count > 0, 'preview has text');

      Dlg.CheckWordWrap.Checked := False;
      Dlg.EditZoom.Text := '110';
      Dlg.EditCommentPrefix.Text := '#';
      Check(not Dlg.PreviewEditor.Options.WordWrap, 'preview updates live');
      Applied := 0;
      Dlg.ButtonOKClick(nil);
      Check(Dlg.ModalResult = mrOk, 'OK sets mrOk');
      Check((not Ed.Options.WordWrap) and (Ed.Zoom = 110) and (Ed.Options.LineCommentPrefix = '#'),
        'OK applied the changes to the editor');
      Check(Ed.Options.TabSize = 7, 'hidden tab size untouched');
      Check(Ed.Font.Name = 'Lucida Console', 'hidden font untouched');
      Check(Applied = 1, 'OnApplied fired by OK');
    finally
      Dlg.Free;
    end;
    Settings.Editor := Ed2;
    Settings.LoadSettings;
    Check((not Ed2.Options.WordWrap) and (Ed2.Zoom = 110) and (Ed2.Options.LineCommentPrefix = '#'),
      'OK saved the changes to the registry');

    // 7. Dialog with an empty path: OK applies without saving or raising.
    Settings.Editor := Ed3;
    Settings.RegistryPath := '';
    Settings.VisibleItems := AllCodeEditorSettingItems;
    Dlg := TCodeEditorSettingsDialog.Create(nil);
    try
      Dlg.Prepare(Settings);
      Check(Dlg.TabFont.TabVisible and Dlg.TabColours.TabVisible, 'all pages shown by default');
      Check(Dlg.ColorBackground.Selected = $00112233, 'colour box reflects the theme');
      Check(Dlg.ColorBackground.Enabled, 'colour boxes enabled in custom mode');
      Dlg.ComboThemeMode.ItemIndex := Ord(ctmVclStyle);
      Dlg.ComboThemeModeChange(nil);
      Check(not Dlg.ColorBackground.Enabled, 'colour boxes disabled when following the VCL style');
      Check(Dlg.LabelFont.Caption = 'Lucida Console, 12pt, bold', 'font label: ' + Dlg.LabelFont.Caption);
      Dlg.EditTabSize.Text := '4';
      Dlg.ButtonOKClick(nil);
      Check((Ed3.Options.TabSize = 4) and (Ed3.ThemeMode = ctmVclStyle), 'OK with no path still applies');
    finally
      Dlg.Free;
    end;

    // 8. Clean up.
    Settings.RegistryPath := TestKey;
    Settings.DeleteSettings;
    Check(not Settings.SettingsExist, 'DeleteSettings removed the key');
    System.SysUtils.DeleteFile(TempFile);
  finally
    Hook.Free;
    Form.Free;
  end;
  if ExitCode = 0 then
    WriteLn('ALL PASS')
  else
    WriteLn('FAILURES');
end.
