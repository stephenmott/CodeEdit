UNIT CodeEdit.Settings;

{ TCodeEditorSettings: user-editable editor preferences for one TCodeEditor,
  persisted under HKEY_CURRENT_USER\<RegistryPath>, with an options dialog.

  Drop one on the form, point Editor at the editor and set RegistryPath
  (e.g. 'Software\MyApp\ScriptEditor'; each editor that needs its own
  preferences gets its own component and path, editors that share them get
  the same path). Call LoadSettings at startup, Execute from an "Editor
  options..." menu item (it applies and saves on OK), SaveSettings whenever
  you change things in code. VisibleItems trims the dialog to the settings
  that make sense for that editor - a log viewer hides the editing page.

  The dialog's Export/Import buttons (and ExportToFile / ImportFromFile)
  move the same values through an INI-format text file so users can carry
  their preferences between machines. The values record is public so hosts
  can read, tweak or apply a set without the registry. }

INTERFACE

USES
  System.Classes,
  System.SysUtils,
  System.UITypes,
  Vcl.Graphics,
  CodeEdit.Editor;

TYPE
  ECodeEditorSettings = CLASS(Exception);

  // The settings the dialog can show. VisibleItems hides whole pages when
  // none of their items are included.
  TCodeEditorSettingItem = (
    siTabSize, siBracketMatching, siLineCommentPrefix, siMaxPasteBytes,      // Editing
    siShowGutter, siStyledScrollBars, siScrollBars, siWordWrap, siWrapIndent, // Display
    siShowMinimap, siMinimapPreview, siMinimapStyle, siMinimapRowHeight,
    siThemeSyntaxColors, siZoom,
    siFont,                                                                   // Font
    siThemeMode, siColours);                                                  // Colours
  TCodeEditorSettingItems = SET OF TCodeEditorSettingItem;

  // Everything the component persists, as plain values.
  TCodeEditorSettingsValues = RECORD
    TabSize: Integer;
    BracketMatching: Boolean;
    LineCommentPrefix: STRING;
    MaxPasteBytes: Integer;
    ShowGutter: Boolean;
    StyledScrollBars: Boolean;
    ScrollBars: TScrollStyle;
    WordWrap: Boolean;
    WrapIndent: Boolean;
    ShowMinimap: Boolean;
    MinimapPreview: Boolean;
    MinimapStyle: TCodeMinimapStyle;
    MinimapRowHeight: Integer;
    ThemeSyntaxColors: Boolean;
    Zoom: Integer;
    FontName: STRING;
    FontSize: Integer;
    FontStyle: TFontStyles;
    ThemeMode: TCodeEditorThemeMode;
    Background: TColor;
    Text: TColor;
    GutterBackground: TColor;
    GutterText: TColor;
    GutterBorder: TColor;
    SelectionBackground: TColor;
    SelectionText: TColor;
    PROCEDURE ReadFrom(Editor: TCodeEditor);
    PROCEDURE ApplyTo(Editor: TCodeEditor);
  END;

  TCodeEditorSettings = CLASS(TComponent)
  PRIVATE
    FEditor: TCodeEditor;
    FRegistryPath: STRING;
    FVisibleItems: TCodeEditorSettingItems;
    FTitle: STRING;
    FOnApplied: TNotifyEvent;
    PROCEDURE SetEditor(Value: TCodeEditor);
    PROCEDURE RequireEditor(CONST Caller: STRING);
    PROCEDURE RequirePath(CONST Caller: STRING);
  PROTECTED
    PROCEDURE Notification(AComponent: TComponent; Operation: TOperation); OVERRIDE;
  PUBLIC
    CONSTRUCTOR Create(AOwner: TComponent); OVERRIDE;
    // Registry <-> Editor. LoadSettings returns False (and changes nothing)
    // when nothing has been saved under RegistryPath yet; values missing
    // from the key keep the editor's current ones. Both raise
    // ECodeEditorSettings when Editor or RegistryPath is not set.
    FUNCTION LoadSettings: Boolean;
    PROCEDURE SaveSettings;
    FUNCTION SettingsExist: Boolean;
    PROCEDURE DeleteSettings;
    // File <-> Editor (INI-format text, same value names as the registry).
    PROCEDURE ExportToFile(CONST FileName: STRING);
    PROCEDURE ImportFromFile(CONST FileName: STRING);
    // File <-> values, without touching the editor (the dialog uses these).
    PROCEDURE SaveValuesToFile(CONST FileName: STRING; CONST Values: TCodeEditorSettingsValues);
    PROCEDURE LoadValuesFromFile(CONST FileName: STRING; VAR Values: TCodeEditorSettingsValues);
    // Shows the options dialog for Editor. Returns True when the user
    // confirmed: the values are applied and, if RegistryPath is set, saved.
    FUNCTION Execute: Boolean;
    // The editor's current values / apply a set to it (fires OnApplied).
    FUNCTION CurrentValues: TCodeEditorSettingsValues;
    PROCEDURE ApplyValues(CONST Values: TCodeEditorSettingsValues);
  PUBLISHED
    PROPERTY Editor: TCodeEditor READ FEditor WRITE SetEditor;
    // Key under HKEY_CURRENT_USER, e.g. 'Software\MyApp\ScriptEditor'.
    PROPERTY RegistryPath: STRING READ FRegistryPath WRITE FRegistryPath;
    // Which settings the dialog offers; everything by default.
    PROPERTY VisibleItems: TCodeEditorSettingItems READ FVisibleItems WRITE FVisibleItems
      DEFAULT [Low(TCodeEditorSettingItem)..High(TCodeEditorSettingItem)];
    // Dialog caption.
    PROPERTY Title: STRING READ FTitle WRITE FTitle;
    // After ApplyValues (dialog OK/Apply, LoadSettings, ImportFromFile).
    PROPERTY OnApplied: TNotifyEvent READ FOnApplied WRITE FOnApplied;
  END;

CONST
  AllCodeEditorSettingItems = [Low(TCodeEditorSettingItem)..High(TCodeEditorSettingItem)];
  CodeEditorSettingsIniSection = 'CodeEditor';

IMPLEMENTATION

USES
  System.IniFiles,
  System.Win.Registry,
  Winapi.Windows,
  CodeEdit.SettingsDlg;

TYPE
  // One writer/reader pair shared by the registry and INI backends, so the
  // value names and types are defined in exactly one place (StoreValues /
  // FetchValues below).
  TCodeSettingsStore = CLASS
  PUBLIC
    PROCEDURE WriteInt(CONST Name: STRING; Value: Integer); VIRTUAL; ABSTRACT;
    PROCEDURE WriteBool(CONST Name: STRING; Value: Boolean); VIRTUAL; ABSTRACT;
    PROCEDURE WriteStr(CONST Name, Value: STRING); VIRTUAL; ABSTRACT;
    FUNCTION ReadInt(CONST Name: STRING; Default: Integer): Integer; VIRTUAL; ABSTRACT;
    FUNCTION ReadBool(CONST Name: STRING; Default: Boolean): Boolean; VIRTUAL; ABSTRACT;
    FUNCTION ReadStr(CONST Name, Default: STRING): STRING; VIRTUAL; ABSTRACT;
  END;

  TCodeRegistryStore = CLASS(TCodeSettingsStore)
  PRIVATE
    FReg: TRegistry;
  PUBLIC
    CONSTRUCTOR Create(AReg: TRegistry);
    PROCEDURE WriteInt(CONST Name: STRING; Value: Integer); OVERRIDE;
    PROCEDURE WriteBool(CONST Name: STRING; Value: Boolean); OVERRIDE;
    PROCEDURE WriteStr(CONST Name, Value: STRING); OVERRIDE;
    FUNCTION ReadInt(CONST Name: STRING; Default: Integer): Integer; OVERRIDE;
    FUNCTION ReadBool(CONST Name: STRING; Default: Boolean): Boolean; OVERRIDE;
    FUNCTION ReadStr(CONST Name, Default: STRING): STRING; OVERRIDE;
  END;

  TCodeIniStore = CLASS(TCodeSettingsStore)
  PRIVATE
    FIni: TCustomIniFile;
  PUBLIC
    CONSTRUCTOR Create(AIni: TCustomIniFile);
    PROCEDURE WriteInt(CONST Name: STRING; Value: Integer); OVERRIDE;
    PROCEDURE WriteBool(CONST Name: STRING; Value: Boolean); OVERRIDE;
    PROCEDURE WriteStr(CONST Name, Value: STRING); OVERRIDE;
    FUNCTION ReadInt(CONST Name: STRING; Default: Integer): Integer; OVERRIDE;
    FUNCTION ReadBool(CONST Name: STRING; Default: Boolean): Boolean; OVERRIDE;
    FUNCTION ReadStr(CONST Name, Default: STRING): STRING; OVERRIDE;
  END;

{ TCodeEditorSettingsValues }

PROCEDURE TCodeEditorSettingsValues.ReadFrom(Editor: TCodeEditor);
BEGIN
  TabSize := Editor.Options.TabSize;
  BracketMatching := Editor.Options.BracketMatching;
  LineCommentPrefix := Editor.Options.LineCommentPrefix;
  MaxPasteBytes := Editor.Options.MaxPasteBytes;
  ShowGutter := Editor.Options.ShowGutter;
  StyledScrollBars := Editor.StyledScrollBars;
  ScrollBars := Editor.ScrollBars;
  WordWrap := Editor.Options.WordWrap;
  WrapIndent := Editor.Options.WrapIndent;
  ShowMinimap := Editor.Options.ShowMinimap;
  MinimapPreview := Editor.Options.MinimapPreview;
  MinimapStyle := Editor.Options.MinimapStyle;
  MinimapRowHeight := Editor.Options.MinimapRowHeight;
  ThemeSyntaxColors := Editor.Options.ThemeSyntaxColors;
  Zoom := Editor.Zoom;
  FontName := Editor.Font.Name;
  FontSize := Editor.Font.Size;
  FontStyle := Editor.Font.Style;
  ThemeMode := Editor.ThemeMode;
  Background := Editor.Theme.Background;
  Text := Editor.Theme.Text;
  GutterBackground := Editor.Theme.GutterBackground;
  GutterText := Editor.Theme.GutterText;
  GutterBorder := Editor.Theme.GutterBorder;
  SelectionBackground := Editor.Theme.SelectionBackground;
  SelectionText := Editor.Theme.SelectionText;
END;

PROCEDURE TCodeEditorSettingsValues.ApplyTo(Editor: TCodeEditor);
BEGIN
  Editor.Options.TabSize := TabSize;
  Editor.Options.BracketMatching := BracketMatching;
  Editor.Options.LineCommentPrefix := LineCommentPrefix;
  Editor.Options.MaxPasteBytes := MaxPasteBytes;
  Editor.Options.ShowGutter := ShowGutter;
  Editor.StyledScrollBars := StyledScrollBars;
  Editor.ScrollBars := ScrollBars;
  Editor.Options.WordWrap := WordWrap;
  Editor.Options.WrapIndent := WrapIndent;
  Editor.Options.ShowMinimap := ShowMinimap;
  Editor.Options.MinimapPreview := MinimapPreview;
  Editor.Options.MinimapStyle := MinimapStyle;
  Editor.Options.MinimapRowHeight := MinimapRowHeight;
  Editor.Options.ThemeSyntaxColors := ThemeSyntaxColors;
  Editor.Zoom := Zoom;
  IF (Editor.Font.Name <> FontName) OR (Editor.Font.Size <> FontSize) OR
    (Editor.Font.Style <> FontStyle) THEN BEGIN
    Editor.Font.Name := FontName;
    Editor.Font.Size := FontSize;
    Editor.Font.Style := FontStyle;
  END;
  Editor.ThemeMode := ThemeMode;
  Editor.Theme.Background := Background;
  Editor.Theme.Text := Text;
  Editor.Theme.GutterBackground := GutterBackground;
  Editor.Theme.GutterText := GutterText;
  Editor.Theme.GutterBorder := GutterBorder;
  Editor.Theme.SelectionBackground := SelectionBackground;
  Editor.Theme.SelectionText := SelectionText;
END;

{ Value names: one place for both backends. }

PROCEDURE StoreValues(Store: TCodeSettingsStore; CONST V: TCodeEditorSettingsValues);
BEGIN
  Store.WriteInt('TabSize', V.TabSize);
  Store.WriteBool('BracketMatching', V.BracketMatching);
  Store.WriteStr('LineCommentPrefix', V.LineCommentPrefix);
  Store.WriteInt('MaxPasteBytes', V.MaxPasteBytes);
  Store.WriteBool('ShowGutter', V.ShowGutter);
  Store.WriteBool('StyledScrollBars', V.StyledScrollBars);
  Store.WriteInt('ScrollBars', Ord(V.ScrollBars));
  Store.WriteBool('WordWrap', V.WordWrap);
  Store.WriteBool('WrapIndent', V.WrapIndent);
  Store.WriteBool('ShowMinimap', V.ShowMinimap);
  Store.WriteBool('MinimapPreview', V.MinimapPreview);
  Store.WriteInt('MinimapStyle', Ord(V.MinimapStyle));
  Store.WriteInt('MinimapRowHeight', V.MinimapRowHeight);
  Store.WriteBool('ThemeSyntaxColors', V.ThemeSyntaxColors);
  Store.WriteInt('Zoom', V.Zoom);
  Store.WriteStr('Font.Name', V.FontName);
  Store.WriteInt('Font.Size', V.FontSize);
  Store.WriteBool('Font.Bold', fsBold IN V.FontStyle);
  Store.WriteBool('Font.Italic', fsItalic IN V.FontStyle);
  Store.WriteInt('ThemeMode', Ord(V.ThemeMode));
  Store.WriteInt('Colour.Background', V.Background);
  Store.WriteInt('Colour.Text', V.Text);
  Store.WriteInt('Colour.GutterBackground', V.GutterBackground);
  Store.WriteInt('Colour.GutterText', V.GutterText);
  Store.WriteInt('Colour.GutterBorder', V.GutterBorder);
  Store.WriteInt('Colour.SelectionBackground', V.SelectionBackground);
  Store.WriteInt('Colour.SelectionText', V.SelectionText);
END;

// Missing values keep what V already holds (the editor's current settings),
// so a key written by an older version still loads.
PROCEDURE FetchValues(Store: TCodeSettingsStore; VAR V: TCodeEditorSettingsValues);

  FUNCTION ClampOrd(Value, MaxOrd: Integer): Integer;
  BEGIN
    IF (Value < 0) OR (Value > MaxOrd) THEN
      Result := 0
    ELSE
      Result := Value;
  END;

BEGIN
  V.TabSize := Store.ReadInt('TabSize', V.TabSize);
  V.BracketMatching := Store.ReadBool('BracketMatching', V.BracketMatching);
  V.LineCommentPrefix := Store.ReadStr('LineCommentPrefix', V.LineCommentPrefix);
  V.MaxPasteBytes := Store.ReadInt('MaxPasteBytes', V.MaxPasteBytes);
  V.ShowGutter := Store.ReadBool('ShowGutter', V.ShowGutter);
  V.StyledScrollBars := Store.ReadBool('StyledScrollBars', V.StyledScrollBars);
  V.ScrollBars := TScrollStyle(ClampOrd(Store.ReadInt('ScrollBars', Ord(V.ScrollBars)),
    Ord(High(TScrollStyle))));
  V.WordWrap := Store.ReadBool('WordWrap', V.WordWrap);
  V.WrapIndent := Store.ReadBool('WrapIndent', V.WrapIndent);
  V.ShowMinimap := Store.ReadBool('ShowMinimap', V.ShowMinimap);
  V.MinimapPreview := Store.ReadBool('MinimapPreview', V.MinimapPreview);
  V.MinimapStyle := TCodeMinimapStyle(ClampOrd(Store.ReadInt('MinimapStyle', Ord(V.MinimapStyle)),
    Ord(High(TCodeMinimapStyle))));
  V.MinimapRowHeight := Store.ReadInt('MinimapRowHeight', V.MinimapRowHeight);
  V.ThemeSyntaxColors := Store.ReadBool('ThemeSyntaxColors', V.ThemeSyntaxColors);
  V.Zoom := Store.ReadInt('Zoom', V.Zoom);
  V.FontName := Store.ReadStr('Font.Name', V.FontName);
  V.FontSize := Store.ReadInt('Font.Size', V.FontSize);
  V.FontStyle := [];
  IF Store.ReadBool('Font.Bold', fsBold IN V.FontStyle) THEN
    Include(V.FontStyle, fsBold);
  IF Store.ReadBool('Font.Italic', fsItalic IN V.FontStyle) THEN
    Include(V.FontStyle, fsItalic);
  V.ThemeMode := TCodeEditorThemeMode(ClampOrd(Store.ReadInt('ThemeMode', Ord(V.ThemeMode)),
    Ord(High(TCodeEditorThemeMode))));
  V.Background := Store.ReadInt('Colour.Background', V.Background);
  V.Text := Store.ReadInt('Colour.Text', V.Text);
  V.GutterBackground := Store.ReadInt('Colour.GutterBackground', V.GutterBackground);
  V.GutterText := Store.ReadInt('Colour.GutterText', V.GutterText);
  V.GutterBorder := Store.ReadInt('Colour.GutterBorder', V.GutterBorder);
  V.SelectionBackground := Store.ReadInt('Colour.SelectionBackground', V.SelectionBackground);
  V.SelectionText := Store.ReadInt('Colour.SelectionText', V.SelectionText);
END;

{ TCodeRegistryStore }

CONSTRUCTOR TCodeRegistryStore.Create(AReg: TRegistry);
BEGIN
  INHERITED Create;
  FReg := AReg;
END;

PROCEDURE TCodeRegistryStore.WriteInt(CONST Name: STRING; Value: Integer);
BEGIN
  FReg.WriteInteger(Name, Value);
END;

PROCEDURE TCodeRegistryStore.WriteBool(CONST Name: STRING; Value: Boolean);
BEGIN
  FReg.WriteBool(Name, Value);
END;

PROCEDURE TCodeRegistryStore.WriteStr(CONST Name, Value: STRING);
BEGIN
  FReg.WriteString(Name, Value);
END;

FUNCTION TCodeRegistryStore.ReadInt(CONST Name: STRING; Default: Integer): Integer;
BEGIN
  Result := Default;
  IF FReg.ValueExists(Name) THEN
    TRY
      Result := FReg.ReadInteger(Name);
    EXCEPT
      ON ERegistryException DO
        Result := Default;              // wrong type: ignore the value
    END;
END;

FUNCTION TCodeRegistryStore.ReadBool(CONST Name: STRING; Default: Boolean): Boolean;
BEGIN
  Result := ReadInt(Name, Ord(Default)) <> 0;
END;

FUNCTION TCodeRegistryStore.ReadStr(CONST Name, Default: STRING): STRING;
BEGIN
  Result := Default;
  IF FReg.ValueExists(Name) THEN
    TRY
      Result := FReg.ReadString(Name);
    EXCEPT
      ON ERegistryException DO
        Result := Default;
    END;
END;

{ TCodeIniStore }

CONSTRUCTOR TCodeIniStore.Create(AIni: TCustomIniFile);
BEGIN
  INHERITED Create;
  FIni := AIni;
END;

PROCEDURE TCodeIniStore.WriteInt(CONST Name: STRING; Value: Integer);
BEGIN
  FIni.WriteInteger(CodeEditorSettingsIniSection, Name, Value);
END;

PROCEDURE TCodeIniStore.WriteBool(CONST Name: STRING; Value: Boolean);
BEGIN
  FIni.WriteBool(CodeEditorSettingsIniSection, Name, Value);
END;

PROCEDURE TCodeIniStore.WriteStr(CONST Name, Value: STRING);
BEGIN
  FIni.WriteString(CodeEditorSettingsIniSection, Name, Value);
END;

FUNCTION TCodeIniStore.ReadInt(CONST Name: STRING; Default: Integer): Integer;
BEGIN
  Result := FIni.ReadInteger(CodeEditorSettingsIniSection, Name, Default);
END;

FUNCTION TCodeIniStore.ReadBool(CONST Name: STRING; Default: Boolean): Boolean;
BEGIN
  Result := FIni.ReadBool(CodeEditorSettingsIniSection, Name, Default);
END;

FUNCTION TCodeIniStore.ReadStr(CONST Name, Default: STRING): STRING;
BEGIN
  Result := FIni.ReadString(CodeEditorSettingsIniSection, Name, Default);
END;

{ TCodeEditorSettings }

CONSTRUCTOR TCodeEditorSettings.Create(AOwner: TComponent);
BEGIN
  INHERITED Create(AOwner);
  FVisibleItems := AllCodeEditorSettingItems;
  FTitle := 'Editor Options';
END;

PROCEDURE TCodeEditorSettings.SetEditor(Value: TCodeEditor);
BEGIN
  IF FEditor <> Value THEN BEGIN
    IF Assigned(FEditor) THEN
      FEditor.RemoveFreeNotification(Self);
    FEditor := Value;
    IF Assigned(FEditor) THEN
      FEditor.FreeNotification(Self);
  END;
END;

PROCEDURE TCodeEditorSettings.Notification(AComponent: TComponent; Operation: TOperation);
BEGIN
  INHERITED;
  IF (Operation = opRemove) AND (AComponent = FEditor) THEN
    FEditor := NIL;
END;

PROCEDURE TCodeEditorSettings.RequireEditor(CONST Caller: STRING);
BEGIN
  IF NOT Assigned(FEditor) THEN
    RAISE ECodeEditorSettings.CreateFmt('%s.%s: Editor is not assigned', [Name, Caller]);
END;

PROCEDURE TCodeEditorSettings.RequirePath(CONST Caller: STRING);
BEGIN
  IF Trim(FRegistryPath) = '' THEN
    RAISE ECodeEditorSettings.CreateFmt('%s.%s: RegistryPath is not set', [Name, Caller]);
END;

FUNCTION TCodeEditorSettings.CurrentValues: TCodeEditorSettingsValues;
BEGIN
  RequireEditor('CurrentValues');
  Result.ReadFrom(FEditor);
END;

PROCEDURE TCodeEditorSettings.ApplyValues(CONST Values: TCodeEditorSettingsValues);
BEGIN
  RequireEditor('ApplyValues');
  Values.ApplyTo(FEditor);
  IF Assigned(FOnApplied) THEN
    FOnApplied(Self);
END;

FUNCTION TCodeEditorSettings.SettingsExist: Boolean;
VAR
  Reg               : TRegistry;
BEGIN
  IF Trim(FRegistryPath) = '' THEN
    Exit(False);
  Reg := TRegistry.Create(KEY_READ);
  TRY
    Reg.RootKey := HKEY_CURRENT_USER;
    Result := Reg.KeyExists(FRegistryPath);
  FINALLY
    Reg.Free;
  END;
END;

FUNCTION TCodeEditorSettings.LoadSettings: Boolean;
VAR
  Reg               : TRegistry;
  Store             : TCodeRegistryStore;
  V                 : TCodeEditorSettingsValues;
BEGIN
  RequireEditor('LoadSettings');
  RequirePath('LoadSettings');
  Result := False;
  Reg := TRegistry.Create(KEY_READ);
  TRY
    Reg.RootKey := HKEY_CURRENT_USER;
    IF NOT Reg.OpenKeyReadOnly(FRegistryPath) THEN
      Exit;
    V.ReadFrom(FEditor);
    Store := TCodeRegistryStore.Create(Reg);
    TRY
      FetchValues(Store, V);
    FINALLY
      Store.Free;
    END;
  FINALLY
    Reg.Free;
  END;
  ApplyValues(V);
  Result := True;
END;

PROCEDURE TCodeEditorSettings.SaveSettings;
VAR
  Reg               : TRegistry;
  Store             : TCodeRegistryStore;
  V                 : TCodeEditorSettingsValues;
BEGIN
  RequireEditor('SaveSettings');
  RequirePath('SaveSettings');
  V.ReadFrom(FEditor);
  Reg := TRegistry.Create(KEY_WRITE);
  TRY
    Reg.RootKey := HKEY_CURRENT_USER;
    IF NOT Reg.OpenKey(FRegistryPath, True) THEN
      RAISE ECodeEditorSettings.CreateFmt('%s.SaveSettings: cannot open HKCU\%s', [Name, FRegistryPath]);
    Store := TCodeRegistryStore.Create(Reg);
    TRY
      StoreValues(Store, V);
    FINALLY
      Store.Free;
    END;
  FINALLY
    Reg.Free;
  END;
END;

PROCEDURE TCodeEditorSettings.DeleteSettings;
VAR
  Reg               : TRegistry;
BEGIN
  RequirePath('DeleteSettings');
  Reg := TRegistry.Create(KEY_ALL_ACCESS);
  TRY
    Reg.RootKey := HKEY_CURRENT_USER;
    IF Reg.KeyExists(FRegistryPath) THEN
      Reg.DeleteKey(FRegistryPath);
  FINALLY
    Reg.Free;
  END;
END;

PROCEDURE TCodeEditorSettings.SaveValuesToFile(CONST FileName: STRING;
  CONST Values: TCodeEditorSettingsValues);
VAR
  Ini               : TMemIniFile;
  Store             : TCodeIniStore;
BEGIN
  Ini := TMemIniFile.Create(FileName);
  TRY
    Store := TCodeIniStore.Create(Ini);
    TRY
      StoreValues(Store, Values);
    FINALLY
      Store.Free;
    END;
    Ini.UpdateFile;
  FINALLY
    Ini.Free;
  END;
END;

PROCEDURE TCodeEditorSettings.LoadValuesFromFile(CONST FileName: STRING;
  VAR Values: TCodeEditorSettingsValues);
VAR
  Ini               : TMemIniFile;
  Store             : TCodeIniStore;
BEGIN
  IF NOT FileExists(FileName) THEN
    RAISE ECodeEditorSettings.CreateFmt('%s: settings file not found: %s', [Name, FileName]);
  Ini := TMemIniFile.Create(FileName);
  TRY
    IF NOT Ini.SectionExists(CodeEditorSettingsIniSection) THEN
      RAISE ECodeEditorSettings.CreateFmt('%s: not an editor settings file: %s', [Name, FileName]);
    Store := TCodeIniStore.Create(Ini);
    TRY
      FetchValues(Store, Values);
    FINALLY
      Store.Free;
    END;
  FINALLY
    Ini.Free;
  END;
END;

PROCEDURE TCodeEditorSettings.ExportToFile(CONST FileName: STRING);
BEGIN
  RequireEditor('ExportToFile');
  SaveValuesToFile(FileName, CurrentValues);
END;

PROCEDURE TCodeEditorSettings.ImportFromFile(CONST FileName: STRING);
VAR
  V                 : TCodeEditorSettingsValues;
BEGIN
  RequireEditor('ImportFromFile');
  V := CurrentValues;
  LoadValuesFromFile(FileName, V);
  ApplyValues(V);
END;

FUNCTION TCodeEditorSettings.Execute: Boolean;
BEGIN
  RequireEditor('Execute');
  Result := TCodeEditorSettingsDialog.Execute(Self);
END;

END.
