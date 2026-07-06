unit CodeEdit.DevExpressTheme;

// Optional bridge between the DevExpress VCL skin library and TCodeEditor
// theming. This unit is deliberately NOT part of the CodeEditVcl package so
// the core library keeps its no-third-party-dependencies promise; add the
// unit directly to applications that use DevExpress skins.
//
// One-shot:
//   ApplyDevExpressThemeToEditor(CodeEditor1);
//
// Or self-updating (follows runtime skin changes automatically):
//   FSkinTheme := TCodeEditorDevExpressTheme.Create(Self);
//   FSkinTheme.AttachEditor(CodeEditor1);

interface

uses
  System.Classes,
  System.Generics.Collections,
  cxLookAndFeels,
  CodeEdit.Editor;

type
  // Keeps attached editors' Theme in sync with the active DevExpress skin,
  // including skin changes at runtime (listens to RootLookAndFeel, which the
  // TdxSkinController updates).
  TCodeEditorDevExpressTheme = class(TComponent, IcxLookAndFeelNotificationListener)
  private
    FEditors: TList<TCodeEditor>;
    FLookAndFeel: TcxLookAndFeel;
    // IcxLookAndFeelNotificationListener
    function GetObject: TObject;
    procedure MasterLookAndFeelChanged(Sender: TcxLookAndFeel;
      AChangedValues: TcxLookAndFeelValues);
    procedure MasterLookAndFeelDestroying(Sender: TcxLookAndFeel);
  protected
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    // Applies the current skin immediately and keeps the editor updated.
    procedure AttachEditor(Editor: TCodeEditor);
    procedure DetachEditor(Editor: TCodeEditor);
    procedure ApplyToAll;
  end;

// Maps the active DevExpress skin palette onto the editor's Theme colors and
// switches it to manual theming. Call again after a skin change, or use
// TCodeEditorDevExpressTheme to have that done automatically.
procedure ApplyDevExpressThemeToEditor(Editor: TCodeEditor);

implementation

uses
  System.UITypes,
  Vcl.Graphics,
  cxLookAndFeelPainters;

procedure ApplyDevExpressThemeToEditor(Editor: TCodeEditor);
var
  Painter: TcxCustomLookAndFeelPainter;

  function Pick(AColor, AFallback: TColor): TColor;
  begin
    if (AColor = clDefault) or (AColor = clNone) then
      Result := AFallback
    else
      Result := AColor;
  end;

begin
  if not Assigned(Editor) then
    Exit;

  Painter := RootLookAndFeel.Painter;
  Editor.Theme.Background := Pick(Painter.DefaultEditorBackgroundColor(False), clWindow);
  Editor.Theme.Text := Pick(Painter.DefaultEditorTextColor(False), clWindowText);
  Editor.Theme.GutterBackground := Pick(Painter.DefaultHeaderColor, clBtnFace);
  Editor.Theme.GutterText := Pick(Painter.DefaultHeaderTextColor, clGrayText);
  Editor.Theme.GutterBorder := Pick(Painter.DefaultGridLineColor, clBtnShadow);
  Editor.Theme.SelectionBackground := Pick(Painter.DefaultSelectionColor, clHighlight);
  Editor.Theme.SelectionText := Pick(Painter.DefaultSelectionTextColor, clHighlightText);
  // Manual mode keeps the mapped skin palette authoritative; the editor's
  // dark-theme detection still adapts token colors to it automatically.
  Editor.ThemeMode := ctmManual;
end;

{ TCodeEditorDevExpressTheme }

constructor TCodeEditorDevExpressTheme.Create(AOwner: TComponent);
begin
  inherited;
  FEditors := TList<TCodeEditor>.Create;
  if not (csDesigning in ComponentState) then
  begin
    FLookAndFeel := RootLookAndFeel;
    FLookAndFeel.AddChangeListener(Self);
  end;
end;

destructor TCodeEditorDevExpressTheme.Destroy;
begin
  if Assigned(FLookAndFeel) then
    FLookAndFeel.RemoveChangeListener(Self);
  FEditors.Free;
  inherited;
end;

function TCodeEditorDevExpressTheme.GetObject: TObject;
begin
  Result := Self;
end;

procedure TCodeEditorDevExpressTheme.MasterLookAndFeelChanged(Sender: TcxLookAndFeel;
  AChangedValues: TcxLookAndFeelValues);
begin
  ApplyToAll;
end;

procedure TCodeEditorDevExpressTheme.MasterLookAndFeelDestroying(Sender: TcxLookAndFeel);
begin
  FLookAndFeel := nil;
end;

procedure TCodeEditorDevExpressTheme.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited;
  if (Operation = opRemove) and (AComponent is TCodeEditor) then
    FEditors.Remove(TCodeEditor(AComponent));
end;

procedure TCodeEditorDevExpressTheme.AttachEditor(Editor: TCodeEditor);
begin
  if not Assigned(Editor) or (FEditors.IndexOf(Editor) >= 0) then
    Exit;
  FEditors.Add(Editor);
  Editor.FreeNotification(Self);
  ApplyDevExpressThemeToEditor(Editor);
end;

procedure TCodeEditorDevExpressTheme.DetachEditor(Editor: TCodeEditor);
begin
  FEditors.Remove(Editor);
end;

procedure TCodeEditorDevExpressTheme.ApplyToAll;
var
  Editor: TCodeEditor;
begin
  for Editor in FEditors do
    ApplyDevExpressThemeToEditor(Editor);
end;

end.
