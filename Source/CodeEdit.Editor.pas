unit CodeEdit.Editor;

interface

uses
  System.Classes,
  System.Generics.Collections,
  System.Types,
  System.UITypes,
  Vcl.Buttons,
  Vcl.Controls,
  Vcl.ExtCtrls,
  Vcl.Forms,
  Vcl.Graphics,
  Vcl.StdCtrls,
  Winapi.Messages,
  Winapi.Windows,
  CodeEdit.Completion,
  CodeEdit.Highlighter;

type
  TCodeEditorThemeMode = (ctmManual, ctmVclStyle);

  TCodeEditorThemeColors = class(TPersistent)
  private
    FBackground: TColor;
    FGutterBackground: TColor;
    FGutterBorder: TColor;
    FGutterText: TColor;
    FSelectionBackground: TColor;
    FSelectionText: TColor;
    FText: TColor;
    FOnChange: TNotifyEvent;
    procedure SetBackground(Value: TColor);
    procedure SetGutterBackground(Value: TColor);
    procedure SetGutterBorder(Value: TColor);
    procedure SetGutterText(Value: TColor);
    procedure SetSelectionBackground(Value: TColor);
    procedure SetSelectionText(Value: TColor);
    procedure SetText(Value: TColor);
  protected
    procedure Changed;
  public
    constructor Create;
    procedure Assign(Source: TPersistent); override;
    procedure SetDefaults;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
  published
    property Background: TColor read FBackground write SetBackground default clWindow;
    property Text: TColor read FText write SetText default clWindowText;
    property GutterBackground: TColor read FGutterBackground write SetGutterBackground default clBtnFace;
    property GutterText: TColor read FGutterText write SetGutterText default clGrayText;
    property GutterBorder: TColor read FGutterBorder write SetGutterBorder default clBtnShadow;
    property SelectionBackground: TColor read FSelectionBackground write SetSelectionBackground default clHighlight;
    property SelectionText: TColor read FSelectionText write SetSelectionText default clHighlightText;
  end;

  TCodeEditorResolveThemeEvent = procedure(Sender: TObject; Colors: TCodeEditorThemeColors) of object;

  TCodeEditorOptions = class(TPersistent)
  private
    FThemeSyntaxColors: Boolean;
    FShowGutter: Boolean;
    FTabSize: Integer;
    FWordWrap: Boolean;
    FOnChange: TNotifyEvent;
    procedure SetThemeSyntaxColors(Value: Boolean);
    procedure SetShowGutter(Value: Boolean);
    procedure SetTabSize(Value: Integer);
    procedure SetWordWrap(Value: Boolean);
  protected
    procedure Changed;
  public
    constructor Create;
    procedure Assign(Source: TPersistent); override;
  published
    property ShowGutter: Boolean read FShowGutter write SetShowGutter default True;
    property TabSize: Integer read FTabSize write SetTabSize default 2;
    property ThemeSyntaxColors: Boolean read FThemeSyntaxColors write SetThemeSyntaxColors default True;
    property WordWrap: Boolean read FWordWrap write SetWordWrap default False;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
  end;

  TCodePosition = record
    Line: Integer;
    Column: Integer;
    class function Create(ALine, AColumn: Integer): TCodePosition; static;
  end;

  TCodeUndoItem = class
  public
    BeforeText: string;
    AfterText: string;
    BeforeCaret: TCodePosition;
    AfterCaret: TCodePosition;
    BeforeAnchor: TCodePosition;
    AfterAnchor: TCodePosition;
  end;

  TCodeUndoGroupKind = (ugNone, ugTyping);

  TCodeSearchMatch = record
    Line: Integer;
    Column: Integer;
    Length: Integer;
  end;

  TCodeEditor = class(TCustomControl)
  private
    FLines: TStringList;
    FOptions: TCodeEditorOptions;
    FHighlighter: TCustomCodeHighlighter;
    FTheme: TCodeEditorThemeColors;
    FThemeMode: TCodeEditorThemeMode;
    FCaret: TCodePosition;
    FAnchor: TCodePosition;
    FTopLine: Integer;
    FLeftColumn: Integer;
    FLineHeight: Integer;
    FCharWidth: Integer;
    FGutterWidth: Integer;
    FUndoStack: TStack<TCodeUndoItem>;
    FRedoStack: TStack<TCodeUndoItem>;
    FCompletionProvider: TCustomCodeCompletionProvider;
    FCompletionForm: TForm;
    FCompletionList: TListBox;
    FCompletionItems: TCodeCompletionItems;
    FCompletionStart: TCodePosition;
    FSearchPanel: TPanel;
    FSearchExpandButton: TSpeedButton;
    FSearchEdit: TEdit;
    FReplaceEdit: TEdit;
    FSearchStatusLabel: TLabel;
    FSearchPrevButton: TSpeedButton;
    FSearchNextButton: TSpeedButton;
    FSearchCloseButton: TSpeedButton;
    FSearchReplaceButton: TSpeedButton;
    FSearchReplaceAllButton: TSpeedButton;
    FSearchMatchCaseButton: TSpeedButton;
    FSearchWholeWordButton: TSpeedButton;
    FSearchRegexButton: TSpeedButton;
    FSearchMatches: TList<TCodeSearchMatch>;
    FSearchIndex: Integer;
    FSearchExpanded: Boolean;
    FStyledScrollBars: Boolean;
    FScrollBarDragging: Boolean;
    FHScrollBarDragging: Boolean;
    FScrollDragOffset: Integer;
    FSuppressKeyPress: Boolean;
    FApplyingUndo: Boolean;
    FActiveUndoItem: TCodeUndoItem;
    FActiveUndoGroup: TCodeUndoGroupKind;
    FMaxUndo: Integer;
    FScrollBars: System.UITypes.TScrollStyle;
    FOnChange: TNotifyEvent;
    FOnResolveTheme: TCodeEditorResolveThemeEvent;
    procedure LinesChanged(Sender: TObject);
    procedure OptionsChanged(Sender: TObject);
    procedure ThemeChanged(Sender: TObject);
    procedure SetHighlighter(Value: TCustomCodeHighlighter);
    procedure SetCompletionProvider(Value: TCustomCodeCompletionProvider);
    procedure SetLines(Value: TStrings);
    procedure SetOptions(Value: TCodeEditorOptions);
    procedure SetScrollBars(Value: System.UITypes.TScrollStyle);
    procedure SetStyledScrollBars(Value: Boolean);
    procedure SetTheme(Value: TCodeEditorThemeColors);
    procedure SetThemeMode(Value: TCodeEditorThemeMode);
    procedure ResolveTheme(Colors: TCodeEditorThemeColors);
    function ActiveTheme: TCodeEditorThemeColors;
    function GetLines: TStrings;
    function ClientTextRect: TRect;
    function StyledVerticalScrollRect: TRect;
    function StyledVerticalThumbRect: TRect;
    function StyledHorizontalScrollRect: TRect;
    function StyledHorizontalThumbRect: TRect;
    function MaxLineLength: Integer;
    function StyledHorizontalVisible: Boolean;
    function StyledVerticalVisible: Boolean;
    function VisibleLineCount: Integer;
    function VisibleColumnCount: Integer;
    function CaretToPoint(const Position: TCodePosition): TPoint;
    function PointToCaret(const Point: TPoint): TCodePosition;
    function NormalizePosition(const Position: TCodePosition): TCodePosition;
    function IsDarkTheme(const Colors: TCodeEditorThemeColors): Boolean;
    function TokenStyleForTheme(Kind: TCodeTokenKind; const BaseStyle: TCodeTextStyle;
      const Colors: TCodeEditorThemeColors): TCodeTextStyle;
    function HasSelection: Boolean;
    function SelectionStart: TCodePosition;
    function SelectionEnd: TCodePosition;
    function ComparePositions(const A, B: TCodePosition): Integer;
    function GetSelectedText: string;
    function CompletionPrefix: string;
    function CompletionVisible: Boolean;
    function CompletionDisplayText(Item: TCodeCompletionItem): string;
    function SearchVisible: Boolean;
    function IsWholeWordMatch(const LineText: string; Column, MatchLength: Integer): Boolean;
    function CaptureUndoState: TCodeUndoItem;
    function CurrentTextSnapshot: string;
    function CanUndo: Boolean;
    function CanRedo: Boolean;
    procedure ClearUndoStack(Stack: TStack<TCodeUndoItem>);
    procedure PushUndoItem(Stack: TStack<TCodeUndoItem>; Item: TCodeUndoItem);
    procedure RestoreUndoState(const Text: string; const Caret, Anchor: TCodePosition);
    procedure CommitUndoState(Item: TCodeUndoItem);
    procedure FinishUndoGroup;
    procedure CancelUndoGroup;
    function CanContinueTypingUndo(const Value: string): Boolean;
    procedure InsertTypedText(const Value: string);
    procedure CreateCompletionPopup;
    procedure PopulateCompletionPopup;
    procedure ShowCompletion(TriggerChar: Char; ExplicitRequest: Boolean);
    procedure HideCompletion;
    procedure AcceptCompletion;
    procedure CompletionListClick(Sender: TObject);
    procedure CompletionListDblClick(Sender: TObject);
    procedure MoveCompletionSelection(Delta: Integer);
    procedure CreateSearchPanel;
    procedure SetSearchButtonGlyph(Button: TSpeedButton; const Kind: string);
    procedure StyleSearchEdit(Edit: TEdit);
    procedure StyleSearchButton(Button: TSpeedButton);
    procedure LayoutSearchPanel;
    procedure UpdateSearch;
    procedure SelectSearchMatch(Index: Integer);
    procedure FindNextMatch;
    procedure FindPreviousMatch;
    procedure ReplaceCurrentMatch;
    procedure ReplaceAllMatches;
    procedure HideSearchPanel;
    procedure SeedSearchFromSelection;
    procedure SearchTextChanged(Sender: TObject);
    procedure SearchEditKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure SearchEditKeyPress(Sender: TObject; var Key: Char);
    procedure SearchButtonClick(Sender: TObject);
    procedure SearchExpandClick(Sender: TObject);
    procedure PaintSearchMatchesLine(ALineIndex, Y: Integer; const LineText: string);
    procedure SetSelectedText(const Value: string);
    procedure DeleteSelection;
    procedure EnsureCaretVisible;
    procedure UpdateCaret;
    procedure UpdateMetrics;
    procedure UpdateScrollBars;
    procedure MoveCaret(const Position: TCodePosition; Shift: TShiftState);
    procedure SelectWordAtCaret;
    procedure InsertText(const Value: string; AddUndo: Boolean = True);
    procedure PaintGutter;
    procedure PaintText;
    procedure PaintStyledScrollBars;
    procedure PaintSelectionLine(ALineIndex, Y: Integer; const LineText: string);
    procedure PaintTokenText(const LineText: string; X, Y: Integer; ALineIndex: Integer);
    procedure CMFontChanged(var Message: TMessage); message CM_FONTCHANGED;
    procedure CMStyleChanged(var Message: TMessage); message CM_STYLECHANGED;
    procedure WMGetDlgCode(var Message: TWMGetDlgCode); message WM_GETDLGCODE;
    procedure WMHScroll(var Message: TWMHScroll); message WM_HSCROLL;
    procedure WMMouseWheel(var Message: TWMMouseWheel); message WM_MOUSEWHEEL;
    procedure WMSetFocus(var Message: TWMSetFocus); message WM_SETFOCUS;
    procedure WMKillFocus(var Message: TWMKillFocus); message WM_KILLFOCUS;
    procedure WMSize(var Message: TWMSize); message WM_SIZE;
    procedure WMVScroll(var Message: TWMVScroll); message WM_VSCROLL;
  protected
    procedure CreateParams(var Params: TCreateParams); override;
    procedure CreateWnd; override;
    procedure DestroyWnd; override;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure KeyPress(var Key: Char); override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure Paint; override;
    procedure Resize; override;
    procedure Change; virtual;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Clear;
    procedure SelectAll;
    procedure Undo;
    procedure Redo;
    procedure ClearUndo;
    procedure TriggerCompletion;
    procedure ShowFind;
    procedure ShowReplace;
    property CanUndoAction: Boolean read CanUndo;
    property CanRedoAction: Boolean read CanRedo;
    property Caret: TCodePosition read FCaret;
    property SelectedText: string read GetSelectedText write SetSelectedText;
  published
    property Align;
    property Anchors;
    property Color default clWindow;
    property CompletionProvider: TCustomCodeCompletionProvider read FCompletionProvider write SetCompletionProvider;
    property Font;
    property Highlighter: TCustomCodeHighlighter read FHighlighter write SetHighlighter;
    property Lines: TStrings read GetLines write SetLines;
    property Options: TCodeEditorOptions read FOptions write SetOptions;
    property PopupMenu;
    property ScrollBars: System.UITypes.TScrollStyle read FScrollBars write SetScrollBars default ssBoth;
    property StyledScrollBars: Boolean read FStyledScrollBars write SetStyledScrollBars default True;
    property Theme: TCodeEditorThemeColors read FTheme write SetTheme;
    property ThemeMode: TCodeEditorThemeMode read FThemeMode write SetThemeMode default ctmVclStyle;
    property MaxUndo: Integer read FMaxUndo write FMaxUndo default 1024;
    property TabOrder;
    property TabStop default True;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
    property OnResolveTheme: TCodeEditorResolveThemeEvent read FOnResolveTheme write FOnResolveTheme;
    property OnClick;
    property OnDblClick;
    property OnEnter;
    property OnExit;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
  end;

implementation

uses
  System.Character,
  System.Math,
  System.RegularExpressions,
  System.SysUtils,
  Vcl.Clipbrd,
  Vcl.Themes;

const
  MinGutterWidth = 42;

constructor TCodeEditorThemeColors.Create;
begin
  inherited Create;
  SetDefaults;
end;

procedure TCodeEditorThemeColors.SetDefaults;
begin
  FBackground := clWindow;
  FText := clWindowText;
  FGutterBackground := clBtnFace;
  FGutterText := clGrayText;
  FGutterBorder := clBtnShadow;
  FSelectionBackground := clHighlight;
  FSelectionText := clHighlightText;
end;

procedure TCodeEditorThemeColors.Assign(Source: TPersistent);
begin
  if Source is TCodeEditorThemeColors then
  begin
    FBackground := TCodeEditorThemeColors(Source).Background;
    FText := TCodeEditorThemeColors(Source).Text;
    FGutterBackground := TCodeEditorThemeColors(Source).GutterBackground;
    FGutterText := TCodeEditorThemeColors(Source).GutterText;
    FGutterBorder := TCodeEditorThemeColors(Source).GutterBorder;
    FSelectionBackground := TCodeEditorThemeColors(Source).SelectionBackground;
    FSelectionText := TCodeEditorThemeColors(Source).SelectionText;
    Changed;
  end
  else
    inherited;
end;

procedure TCodeEditorThemeColors.Changed;
begin
  if Assigned(FOnChange) then
    FOnChange(Self);
end;

procedure TCodeEditorThemeColors.SetBackground(Value: TColor);
begin
  if FBackground <> Value then
  begin
    FBackground := Value;
    Changed;
  end;
end;

procedure TCodeEditorThemeColors.SetText(Value: TColor);
begin
  if FText <> Value then
  begin
    FText := Value;
    Changed;
  end;
end;

procedure TCodeEditorThemeColors.SetGutterBackground(Value: TColor);
begin
  if FGutterBackground <> Value then
  begin
    FGutterBackground := Value;
    Changed;
  end;
end;

procedure TCodeEditorThemeColors.SetGutterText(Value: TColor);
begin
  if FGutterText <> Value then
  begin
    FGutterText := Value;
    Changed;
  end;
end;

procedure TCodeEditorThemeColors.SetGutterBorder(Value: TColor);
begin
  if FGutterBorder <> Value then
  begin
    FGutterBorder := Value;
    Changed;
  end;
end;

procedure TCodeEditorThemeColors.SetSelectionBackground(Value: TColor);
begin
  if FSelectionBackground <> Value then
  begin
    FSelectionBackground := Value;
    Changed;
  end;
end;

procedure TCodeEditorThemeColors.SetSelectionText(Value: TColor);
begin
  if FSelectionText <> Value then
  begin
    FSelectionText := Value;
    Changed;
  end;
end;

constructor TCodeEditorOptions.Create;
begin
  inherited Create;
  FShowGutter := True;
  FThemeSyntaxColors := True;
  FTabSize := 2;
  FWordWrap := False;
end;

procedure TCodeEditorOptions.Changed;
begin
  if Assigned(FOnChange) then
    FOnChange(Self);
end;

procedure TCodeEditorOptions.Assign(Source: TPersistent);
begin
  if Source is TCodeEditorOptions then
  begin
    FShowGutter := TCodeEditorOptions(Source).ShowGutter;
    FTabSize := TCodeEditorOptions(Source).TabSize;
    FThemeSyntaxColors := TCodeEditorOptions(Source).ThemeSyntaxColors;
    FWordWrap := TCodeEditorOptions(Source).WordWrap;
    Changed;
  end
  else
    inherited;
end;

procedure TCodeEditorOptions.SetShowGutter(Value: Boolean);
begin
  if FShowGutter <> Value then
  begin
    FShowGutter := Value;
    Changed;
  end;
end;

procedure TCodeEditorOptions.SetThemeSyntaxColors(Value: Boolean);
begin
  if FThemeSyntaxColors <> Value then
  begin
    FThemeSyntaxColors := Value;
    Changed;
  end;
end;

procedure TCodeEditorOptions.SetTabSize(Value: Integer);
begin
  Value := Max(1, Value);
  if FTabSize <> Value then
  begin
    FTabSize := Value;
    Changed;
  end;
end;

procedure TCodeEditorOptions.SetWordWrap(Value: Boolean);
begin
  if FWordWrap <> Value then
  begin
    FWordWrap := Value;
    Changed;
  end;
end;

class function TCodePosition.Create(ALine, AColumn: Integer): TCodePosition;
begin
  Result.Line := ALine;
  Result.Column := AColumn;
end;

constructor TCodeEditor.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := ControlStyle + [csOpaque, csCaptureMouse, csClickEvents, csDoubleClicks];
  DoubleBuffered := True;
  Width := 640;
  Height := 420;
  Color := clWindow;
  TabStop := True;

  FOptions := TCodeEditorOptions.Create;
  FOptions.OnChange := OptionsChanged;

  FTheme := TCodeEditorThemeColors.Create;
  FTheme.OnChange := ThemeChanged;
  FThemeMode := ctmVclStyle;

  FLines := TStringList.Create;
  FLines.OnChange := LinesChanged;
  FLines.Add('');

  FScrollBars := ssBoth;
  FStyledScrollBars := True;
  FUndoStack := TStack<TCodeUndoItem>.Create;
  FRedoStack := TStack<TCodeUndoItem>.Create;
  FSearchMatches := TList<TCodeSearchMatch>.Create;
  FSearchIndex := -1;
  FMaxUndo := 1024;
  FCaret := TCodePosition.Create(0, 0);
  FAnchor := FCaret;
  FTopLine := 0;
  FLeftColumn := 0;

  Font.Name := 'Consolas';
  Font.Size := 10;
  UpdateMetrics;
end;

destructor TCodeEditor.Destroy;
begin
  HideCompletion;
  FCompletionItems.Free;
  FSearchMatches.Free;
  FinishUndoGroup;
  ClearUndo;
  FRedoStack.Free;
  FUndoStack.Free;
  FTheme.Free;
  FOptions.Free;
  FLines.Free;
  inherited;
end;

procedure TCodeEditor.CreateParams(var Params: TCreateParams);
begin
  inherited;
  Params.Style := Params.Style or WS_TABSTOP or WS_CLIPCHILDREN;
  if (not FStyledScrollBars) and (FScrollBars in [ssHorizontal, ssBoth]) then
    Params.Style := Params.Style or WS_HSCROLL;
  if (not FStyledScrollBars) and (FScrollBars in [ssVertical, ssBoth]) then
    Params.Style := Params.Style or WS_VSCROLL;
end;

procedure TCodeEditor.CreateWnd;
begin
  inherited;
  UpdateScrollBars;
  UpdateCaret;
end;

procedure TCodeEditor.DestroyWnd;
begin
  HideCaret(Handle);
  DestroyCaret;
  inherited;
end;

procedure TCodeEditor.CMFontChanged(var Message: TMessage);
begin
  inherited;
  UpdateMetrics;
  UpdateScrollBars;
  UpdateCaret;
  Invalidate;
end;

procedure TCodeEditor.CMStyleChanged(var Message: TMessage);
begin
  inherited;
  if FThemeMode = ctmVclStyle then
    Invalidate;
end;

procedure TCodeEditor.WMGetDlgCode(var Message: TWMGetDlgCode);
begin
  inherited;
  Message.Result := Message.Result or DLGC_WANTALLKEYS or DLGC_WANTARROWS or DLGC_WANTCHARS or DLGC_WANTTAB;
end;

procedure TCodeEditor.WMHScroll(var Message: TWMHScroll);
var
  NewLeft: Integer;
begin
  inherited;
  NewLeft := FLeftColumn;
  case Message.ScrollCode of
    SB_LINELEFT: Dec(NewLeft);
    SB_LINERIGHT: Inc(NewLeft);
    SB_PAGELEFT: Dec(NewLeft, VisibleColumnCount);
    SB_PAGERIGHT: Inc(NewLeft, VisibleColumnCount);
    SB_THUMBPOSITION, SB_THUMBTRACK: NewLeft := Message.Pos;
  end;

  NewLeft := EnsureRange(NewLeft, 0, Max(0, MaxLineLength - VisibleColumnCount + 1));
  if NewLeft = FLeftColumn then
    Exit;
  FLeftColumn := NewLeft;
  UpdateScrollBars;
  UpdateCaret;
  Invalidate;
end;

procedure TCodeEditor.Resize;
begin
  inherited;
  LayoutSearchPanel;
  UpdateScrollBars;
  EnsureCaretVisible;
end;

procedure TCodeEditor.WMSize(var Message: TWMSize);
begin
  inherited;
  UpdateScrollBars;
end;

procedure TCodeEditor.WMSetFocus(var Message: TWMSetFocus);
begin
  inherited;
  UpdateCaret;
end;

procedure TCodeEditor.WMKillFocus(var Message: TWMKillFocus);
begin
  HideCaret(Handle);
  inherited;
end;

procedure TCodeEditor.WMMouseWheel(var Message: TWMMouseWheel);
var
  DeltaLines: Integer;
  NewTop: Integer;
begin
  DeltaLines := Mouse.WheelScrollLines * -Sign(Message.WheelDelta);
  NewTop := EnsureRange(FTopLine + DeltaLines, 0, Max(0, FLines.Count - VisibleLineCount));
  if NewTop = FTopLine then
    Exit;
  FTopLine := NewTop;
  UpdateScrollBars;
  Invalidate;
end;

procedure TCodeEditor.WMVScroll(var Message: TWMVScroll);
var
  NewTop: Integer;
begin
  inherited;
  NewTop := FTopLine;
  case Message.ScrollCode of
    SB_LINEUP: Dec(NewTop);
    SB_LINEDOWN: Inc(NewTop);
    SB_PAGEUP: Dec(NewTop, VisibleLineCount);
    SB_PAGEDOWN: Inc(NewTop, VisibleLineCount);
    SB_THUMBPOSITION, SB_THUMBTRACK: NewTop := Message.Pos;
  end;

  NewTop := EnsureRange(NewTop, 0, Max(0, FLines.Count - VisibleLineCount));
  if NewTop = FTopLine then
    Exit;
  FTopLine := NewTop;
  UpdateScrollBars;
  UpdateCaret;
  Invalidate;
end;

procedure TCodeEditor.UpdateMetrics;
var
  MeasureBitmap: Vcl.Graphics.TBitmap;
  MeasureCanvas: TCanvas;
  LineCount: Integer;
  ShowGutter: Boolean;
begin
  LineCount := 1;
  if Assigned(FLines) then
    LineCount := Max(1, FLines.Count);
  ShowGutter := not Assigned(FOptions) or FOptions.ShowGutter;

  MeasureBitmap := Vcl.Graphics.TBitmap.Create;
  MeasureCanvas := MeasureBitmap.Canvas;

  try
    MeasureCanvas.Font.Assign(Font);
    FLineHeight := Max(1, MeasureCanvas.TextHeight('Wg') + 2);
    FCharWidth := Max(1, MeasureCanvas.TextWidth('M'));
    FGutterWidth := IfThen(ShowGutter,
      Max(MinGutterWidth, MeasureCanvas.TextWidth(IntToStr(LineCount)) + 18), 0);
  finally
    MeasureBitmap.Free;
  end;
end;

procedure TCodeEditor.UpdateScrollBars;
var
  Info: TScrollInfo;
  MaxLineLength: Integer;
  Line: string;
begin
  if not HandleAllocated then
    Exit;

  if FStyledScrollBars then
  begin
    ShowScrollBar(Handle, SB_VERT, False);
    ShowScrollBar(Handle, SB_HORZ, False);
    Exit;
  end;

  MaxLineLength := 0;
  for Line in FLines do
    MaxLineLength := Max(MaxLineLength, Length(Line));

  FillChar(Info, SizeOf(Info), 0);
  Info.cbSize := SizeOf(Info);
  Info.fMask := SIF_RANGE or SIF_PAGE or SIF_POS;
  Info.nMin := 0;

  if FScrollBars in [ssVertical, ssBoth] then
  begin
    Info.nMax := Max(0, FLines.Count - 1);
    Info.nPage := VisibleLineCount;
    Info.nPos := FTopLine;
    SetScrollInfo(Handle, SB_VERT, Info, True);
  end;

  if FScrollBars in [ssHorizontal, ssBoth] then
  begin
    Info.nMax := Max(0, MaxLineLength);
    Info.nPage := VisibleColumnCount;
    Info.nPos := FLeftColumn;
    SetScrollInfo(Handle, SB_HORZ, Info, True);
  end;
end;

procedure TCodeEditor.UpdateCaret;
var
  P: TPoint;
begin
  if not HandleAllocated or not Focused then
    Exit;

  CreateCaret(Handle, 0, 2, FLineHeight);
  P := CaretToPoint(FCaret);
  SetCaretPos(P.X, P.Y);
  ShowCaret(Handle);
end;

function TCodeEditor.ClientTextRect: TRect;
begin
  Result := ClientRect;
  Inc(Result.Left, FGutterWidth + 4);
  if StyledVerticalVisible then
    Dec(Result.Right, 12);
  if StyledHorizontalVisible then
    Dec(Result.Bottom, 12);
end;

function TCodeEditor.StyledVerticalVisible: Boolean;
begin
  Result := FStyledScrollBars and (FScrollBars in [ssVertical, ssBoth]);
end;

function TCodeEditor.StyledHorizontalVisible: Boolean;
begin
  Result := FStyledScrollBars and (FScrollBars in [ssHorizontal, ssBoth]);
end;

function TCodeEditor.MaxLineLength: Integer;
var
  Line: string;
begin
  Result := 0;
  for Line in FLines do
    if Length(Line) > Result then
      Result := Length(Line);
end;

function TCodeEditor.StyledVerticalScrollRect: TRect;
var
  BottomReserve: Integer;
begin
  BottomReserve := 0;
  if StyledHorizontalVisible then
    BottomReserve := 12;
  Result := Rect(ClientWidth - 12, 0, ClientWidth, ClientHeight - BottomReserve);
end;

function TCodeEditor.StyledVerticalThumbRect: TRect;
var
  Track: TRect;
  ThumbHeight: Integer;
  MaxTopLine: Integer;
  Travel: Integer;
begin
  Track := StyledVerticalScrollRect;
  if FLines.Count <= VisibleLineCount then
    Exit(Rect(Track.Left, Track.Top, Track.Right, Track.Top));

  ThumbHeight := Max(24, MulDiv(Track.Height, VisibleLineCount, FLines.Count));
  MaxTopLine := Max(1, FLines.Count - VisibleLineCount);
  Travel := Max(1, Track.Height - ThumbHeight);
  Result.Top := Track.Top + MulDiv(FTopLine, Travel, MaxTopLine);
  Result.Bottom := Result.Top + ThumbHeight;
  Result.Left := Track.Left;
  Result.Right := Track.Right;
end;

function TCodeEditor.StyledHorizontalScrollRect: TRect;
var
  RightReserve: Integer;
begin
  RightReserve := 0;
  if StyledVerticalVisible then
    RightReserve := 12;
  Result := Rect(0, ClientHeight - 12, ClientWidth - RightReserve, ClientHeight);
end;

function TCodeEditor.StyledHorizontalThumbRect: TRect;
var
  Track: TRect;
  ThumbWidth: Integer;
  MaxLeftCol: Integer;
  Travel: Integer;
  TotalCols: Integer;
begin
  Track := StyledHorizontalScrollRect;
  TotalCols := MaxLineLength;
  if TotalCols <= VisibleColumnCount then
    Exit(Rect(Track.Left, Track.Top, Track.Left, Track.Bottom));

  ThumbWidth := Max(24, MulDiv(Track.Width, VisibleColumnCount, TotalCols));
  MaxLeftCol := Max(1, TotalCols - VisibleColumnCount);
  Travel := Max(1, Track.Width - ThumbWidth);
  Result.Left := Track.Left + MulDiv(FLeftColumn, Travel, MaxLeftCol);
  Result.Right := Result.Left + ThumbWidth;
  Result.Top := Track.Top;
  Result.Bottom := Track.Bottom;
end;

function TCodeEditor.VisibleLineCount: Integer;
begin
  Result := Max(1, ClientTextRect.Height div FLineHeight);
end;

function TCodeEditor.VisibleColumnCount: Integer;
begin
  Result := Max(1, ClientTextRect.Width div FCharWidth);
end;

function TCodeEditor.CaretToPoint(const Position: TCodePosition): TPoint;
var
  R: TRect;
begin
  R := ClientTextRect;
  Result.X := R.Left + (Position.Column - FLeftColumn) * FCharWidth;
  Result.Y := (Position.Line - FTopLine) * FLineHeight;
end;

function TCodeEditor.PointToCaret(const Point: TPoint): TCodePosition;
var
  R: TRect;
begin
  R := ClientTextRect;
  Result.Line := FTopLine + EnsureRange(Point.Y div FLineHeight, 0, Max(0, FLines.Count - 1));
  Result.Column := FLeftColumn + Max(0, (Point.X - R.Left + FCharWidth div 2) div FCharWidth);
  Result := NormalizePosition(Result);
end;

function TCodeEditor.NormalizePosition(const Position: TCodePosition): TCodePosition;
begin
  Result.Line := EnsureRange(Position.Line, 0, Max(0, FLines.Count - 1));
  Result.Column := EnsureRange(Position.Column, 0, Length(FLines[Result.Line]));
end;

function ColorLuminance(Color: TColor): Integer;
var
  RGBColor: TColorRef;
begin
  RGBColor := ColorToRGB(Color);
  Result := (GetRValue(RGBColor) * 299 + GetGValue(RGBColor) * 587 + GetBValue(RGBColor) * 114) div 1000;
end;

function ShiftBrightness(Color: TColor; Delta: Integer): TColor;
var
  RGBColor: TColorRef;
  R, G, B: Integer;
begin
  RGBColor := ColorToRGB(Color);
  R := EnsureRange(GetRValue(RGBColor) + Delta, 0, 255);
  G := EnsureRange(GetGValue(RGBColor) + Delta, 0, 255);
  B := EnsureRange(GetBValue(RGBColor) + Delta, 0, 255);
  Result := TColor(RGB(R, G, B));
end;

function TCodeEditor.IsDarkTheme(const Colors: TCodeEditorThemeColors): Boolean;
begin
  Result := ColorLuminance(Colors.Background) < 128;
end;

function TCodeEditor.TokenStyleForTheme(Kind: TCodeTokenKind; const BaseStyle: TCodeTextStyle;
  const Colors: TCodeEditorThemeColors): TCodeTextStyle;
var
  Dark: Boolean;
begin
  Result := BaseStyle;
  Dark := IsDarkTheme(Colors);

  case Kind of
    tkText,
    tkWhitespace,
    tkIdentifier:
      Result.Foreground := Colors.Text;
    tkComment:
      if Dark then
        Result.Foreground := $0086C691
      else
        Result.Foreground := $00808080;
    tkString:
      if Dark then
        Result.Foreground := $0078D7FF
      else
        Result.Foreground := $00008000;
    tkNumber:
      if Dark then
        Result.Foreground := $00B5CEA8
      else
        Result.Foreground := $00800080;
    tkKeyword:
      if Dark then
        Result.Foreground := $00F18C6D
      else
        Result.Foreground := $00B06000;
    tkSymbol:
      if Dark then
        Result.Foreground := $00D4D4D4
      else
        Result.Foreground := $00606060;
  end;
end;

function TCodeEditor.ComparePositions(const A, B: TCodePosition): Integer;
begin
  Result := A.Line - B.Line;
  if Result = 0 then
    Result := A.Column - B.Column;
end;

function TCodeEditor.HasSelection: Boolean;
begin
  Result := ComparePositions(FCaret, FAnchor) <> 0;
end;

function TCodeEditor.SelectionStart: TCodePosition;
begin
  if ComparePositions(FCaret, FAnchor) <= 0 then
    Result := FCaret
  else
    Result := FAnchor;
end;

function TCodeEditor.SelectionEnd: TCodePosition;
begin
  if ComparePositions(FCaret, FAnchor) >= 0 then
    Result := FCaret
  else
    Result := FAnchor;
end;

function TCodeEditor.GetSelectedText: string;
var
  StartPos: TCodePosition;
  EndPos: TCodePosition;
  I: Integer;
begin
  Result := '';
  if not HasSelection then
    Exit;

  StartPos := SelectionStart;
  EndPos := SelectionEnd;
  if StartPos.Line = EndPos.Line then
    Exit(Copy(FLines[StartPos.Line], StartPos.Column + 1, EndPos.Column - StartPos.Column));

  Result := Copy(FLines[StartPos.Line], StartPos.Column + 1, MaxInt) + sLineBreak;
  for I := StartPos.Line + 1 to EndPos.Line - 1 do
    Result := Result + FLines[I] + sLineBreak;
  Result := Result + Copy(FLines[EndPos.Line], 1, EndPos.Column);
end;

function TCodeEditor.CompletionPrefix: string;
var
  LineText: string;
  Index: Integer;
begin
  Result := '';
  if (FCaret.Line < 0) or (FCaret.Line >= FLines.Count) then
    Exit;

  LineText := FLines[FCaret.Line];
  Index := EnsureRange(FCaret.Column, 0, Length(LineText));
  while (Index > 0) and (LineText[Index].IsLetterOrDigit or (LineText[Index] = '_')) do
    Dec(Index);

  Result := Copy(LineText, Index + 1, FCaret.Column - Index);
end;

function TCodeEditor.CompletionVisible: Boolean;
begin
  Result := Assigned(FCompletionForm) and FCompletionForm.Visible;
end;

function TCodeEditor.CompletionDisplayText(Item: TCodeCompletionItem): string;
begin
  Result := Item.Caption;
  if Item.Detail <> '' then
    Result := Result + '    ' + Item.Detail;
end;

function TCodeEditor.SearchVisible: Boolean;
begin
  Result := Assigned(FSearchPanel) and FSearchPanel.Visible;
end;

function TCodeEditor.IsWholeWordMatch(const LineText: string; Column, MatchLength: Integer): Boolean;
var
  BeforeChar: Char;
  AfterChar: Char;

  function IsWordChar(Ch: Char): Boolean;
  begin
    Result := Ch.IsLetterOrDigit or (Ch = '_');
  end;

begin
  BeforeChar := #0;
  AfterChar := #0;
  if Column > 0 then
    BeforeChar := LineText[Column];
  if Column + MatchLength + 1 <= Length(LineText) then
    AfterChar := LineText[Column + MatchLength + 1];

  Result := not IsWordChar(BeforeChar) and not IsWordChar(AfterChar);
end;

function TCodeEditor.CurrentTextSnapshot: string;
begin
  Result := FLines.Text;
end;

function TCodeEditor.CaptureUndoState: TCodeUndoItem;
begin
  Result := TCodeUndoItem.Create;
  Result.BeforeText := CurrentTextSnapshot;
  Result.BeforeCaret := FCaret;
  Result.BeforeAnchor := FAnchor;
end;

function TCodeEditor.CanUndo: Boolean;
begin
  Result := Assigned(FUndoStack) and (FUndoStack.Count > 0);
end;

function TCodeEditor.CanRedo: Boolean;
begin
  Result := Assigned(FRedoStack) and (FRedoStack.Count > 0);
end;

procedure TCodeEditor.ClearUndoStack(Stack: TStack<TCodeUndoItem>);
var
  Item: TCodeUndoItem;
begin
  if not Assigned(Stack) then
    Exit;

  while Stack.Count > 0 do
  begin
    Item := Stack.Pop;
    Item.Free;
  end;
end;

procedure TCodeEditor.PushUndoItem(Stack: TStack<TCodeUndoItem>; Item: TCodeUndoItem);
var
  DropCount: Integer;
  Items: TArray<TCodeUndoItem>;
  I: Integer;
begin
  if not Assigned(Item) then
    Exit;

  if FMaxUndo <= 0 then
  begin
    Item.Free;
    Exit;
  end;

  Stack.Push(Item);
  DropCount := Stack.Count - FMaxUndo;
  if DropCount <= 0 then
    Exit;

  Items := Stack.ToArray;
  Stack.Clear;
  for I := High(Items) downto 0 do
  begin
    if I >= FMaxUndo then
      Items[I].Free
    else
      Stack.Push(Items[I]);
  end;
end;

procedure TCodeEditor.RestoreUndoState(const Text: string; const Caret, Anchor: TCodePosition);
begin
  FApplyingUndo := True;
  try
    FLines.Text := Text;
    if FLines.Count = 0 then
      FLines.Add('');
    FCaret := NormalizePosition(Caret);
    FAnchor := NormalizePosition(Anchor);
  finally
    FApplyingUndo := False;
  end;

  EnsureCaretVisible;
  LinesChanged(Self);
  Invalidate;
end;

procedure TCodeEditor.CommitUndoState(Item: TCodeUndoItem);
begin
  if not Assigned(Item) then
    Exit;

  Item.AfterText := CurrentTextSnapshot;
  Item.AfterCaret := FCaret;
  Item.AfterAnchor := FAnchor;

  if Item.BeforeText = Item.AfterText then
  begin
    Item.Free;
    Exit;
  end;

  PushUndoItem(FUndoStack, Item);
  ClearUndoStack(FRedoStack);
end;

procedure TCodeEditor.FinishUndoGroup;
begin
  if not Assigned(FActiveUndoItem) then
    Exit;

  CommitUndoState(FActiveUndoItem);
  FActiveUndoItem := nil;
  FActiveUndoGroup := ugNone;
end;

procedure TCodeEditor.CancelUndoGroup;
begin
  FreeAndNil(FActiveUndoItem);
  FActiveUndoGroup := ugNone;
end;

function TCodeEditor.CanContinueTypingUndo(const Value: string): Boolean;
begin
  Result := Assigned(FActiveUndoItem) and
    (FActiveUndoGroup = ugTyping) and
    (Length(Value) = 1) and
    not HasSelection and
    (FCaret.Line = FActiveUndoItem.AfterCaret.Line) and
    (FCaret.Column = FActiveUndoItem.AfterCaret.Column) and
    (FAnchor.Line = FCaret.Line) and
    (FAnchor.Column = FCaret.Column);
end;

procedure TCodeEditor.InsertTypedText(const Value: string);
begin
  if not CanContinueTypingUndo(Value) then
  begin
    FinishUndoGroup;
    FActiveUndoItem := CaptureUndoState;
    FActiveUndoGroup := ugTyping;
  end;

  InsertText(Value, False);

  FActiveUndoItem.AfterText := CurrentTextSnapshot;
  FActiveUndoItem.AfterCaret := FCaret;
  FActiveUndoItem.AfterAnchor := FAnchor;
  ClearUndoStack(FRedoStack);
end;

procedure TCodeEditor.Undo;
var
  Item: TCodeUndoItem;
begin
  FinishUndoGroup;
  if not CanUndo then
    Exit;

  Item := FUndoStack.Pop;
  RestoreUndoState(Item.BeforeText, Item.BeforeCaret, Item.BeforeAnchor);
  PushUndoItem(FRedoStack, Item);
end;

procedure TCodeEditor.Redo;
var
  Item: TCodeUndoItem;
begin
  FinishUndoGroup;
  if not CanRedo then
    Exit;

  Item := FRedoStack.Pop;
  RestoreUndoState(Item.AfterText, Item.AfterCaret, Item.AfterAnchor);
  PushUndoItem(FUndoStack, Item);
end;

procedure TCodeEditor.ClearUndo;
begin
  CancelUndoGroup;
  ClearUndoStack(FUndoStack);
  ClearUndoStack(FRedoStack);
end;

procedure TCodeEditor.CreateCompletionPopup;
begin
  if Assigned(FCompletionForm) then
    Exit;

  FCompletionForm := TForm.CreateNew(nil);
  FCompletionForm.BorderStyle := bsNone;
  FCompletionForm.FormStyle := fsStayOnTop;
  FCompletionForm.Position := poDesigned;
  FCompletionForm.Width := 280;
  FCompletionForm.Height := 180;

  FCompletionList := TListBox.Create(FCompletionForm);
  FCompletionList.Parent := FCompletionForm;
  FCompletionList.Align := alClient;
  FCompletionList.IntegralHeight := True;
  FCompletionList.OnClick := CompletionListClick;
  FCompletionList.OnDblClick := CompletionListDblClick;
end;

procedure TCodeEditor.PopulateCompletionPopup;
var
  Item: TCodeCompletionItem;
begin
  FCompletionList.Items.BeginUpdate;
  try
    FCompletionList.Clear;
    for Item in FCompletionItems do
      FCompletionList.Items.AddObject(CompletionDisplayText(Item), Item);
    if FCompletionList.Items.Count > 0 then
      FCompletionList.ItemIndex := 0;
  finally
    FCompletionList.Items.EndUpdate;
  end;
end;

procedure TCodeEditor.ShowCompletion(TriggerChar: Char; ExplicitRequest: Boolean);
var
  Context: TCodeCompletionContext;
  Prefix: string;
  P: TPoint;
begin
  if not Assigned(FCompletionProvider) then
    Exit;

  Prefix := CompletionPrefix;
  FCompletionStart := FCaret;
  if TriggerChar = #0 then
    Dec(FCompletionStart.Column, Length(Prefix));

  FreeAndNil(FCompletionItems);
  FCompletionItems := TCodeCompletionItems.Create(True);

  Context.Line := FCaret.Line;
  Context.Column := FCaret.Column;
  Context.Prefix := Prefix;
  Context.TriggerChar := TriggerChar;
  Context.LineText := FLines[FCaret.Line];
  Context.ExplicitRequest := ExplicitRequest;
  FCompletionProvider.GetCompletions(Context, FCompletionItems);

  if FCompletionItems.Count = 0 then
  begin
    HideCompletion;
    Exit;
  end;

  CreateCompletionPopup;
  PopulateCompletionPopup;
  P := ClientToScreen(CaretToPoint(FCaret));
  Inc(P.Y, FLineHeight);
  FCompletionForm.SetBounds(P.X, P.Y, FCompletionForm.Width, FCompletionForm.Height);
  FCompletionForm.Show;
  SetFocus;
end;

procedure TCodeEditor.HideCompletion;
begin
  if Assigned(FCompletionForm) then
    FCompletionForm.Hide;
end;

procedure TCodeEditor.AcceptCompletion;
var
  Item: TCodeCompletionItem;
begin
  if not CompletionVisible or (FCompletionList.ItemIndex < 0) then
    Exit;

  Item := TCodeCompletionItem(FCompletionList.Items.Objects[FCompletionList.ItemIndex]);
  HideCompletion;
  FAnchor := FCompletionStart;
  InsertText(Item.InsertText);
end;

procedure TCodeEditor.CompletionListClick(Sender: TObject);
begin
  SetFocus;
end;

procedure TCodeEditor.CompletionListDblClick(Sender: TObject);
begin
  AcceptCompletion;
end;

procedure TCodeEditor.MoveCompletionSelection(Delta: Integer);
var
  NewIndex: Integer;
begin
  if not CompletionVisible or (FCompletionList.Items.Count = 0) then
    Exit;

  NewIndex := EnsureRange(FCompletionList.ItemIndex + Delta, 0, FCompletionList.Items.Count - 1);
  FCompletionList.ItemIndex := NewIndex;
end;

procedure TCodeEditor.TriggerCompletion;
begin
  FinishUndoGroup;
  ShowCompletion(#0, True);
end;

procedure TCodeEditor.CreateSearchPanel;

  function NewButton(const CaptionText, HintText: string; WidthValue: Integer): TSpeedButton;
  begin
    Result := TSpeedButton.Create(FSearchPanel);
    Result.Parent := FSearchPanel;
    Result.Caption := CaptionText;
    Result.Hint := HintText;
    Result.ShowHint := True;
    Result.Width := WidthValue;
    Result.Height := 28;
    Result.Flat := True;
    StyleSearchButton(Result);
    Result.OnClick := SearchButtonClick;
  end;

begin
  if Assigned(FSearchPanel) then
    Exit;

  FSearchPanel := TPanel.Create(Self);
  FSearchPanel.Parent := Self;
  FSearchPanel.BevelOuter := bvRaised;
  FSearchPanel.ParentBackground := False;
  FSearchPanel.Color := $00303030;
  FSearchPanel.StyleElements := [];
  FSearchPanel.Visible := False;
  FSearchPanel.Width := 760;
  FSearchPanel.Height := 36;

  FSearchExpandButton := NewButton('>', 'Show replace', 28);
  FSearchExpandButton.OnClick := SearchExpandClick;
  SetSearchButtonGlyph(FSearchExpandButton, 'expand');

  FSearchEdit := TEdit.Create(FSearchPanel);
  FSearchEdit.Parent := FSearchPanel;
  StyleSearchEdit(FSearchEdit);
  FSearchEdit.TextHint := 'Find';
  FSearchEdit.OnChange := SearchTextChanged;
  FSearchEdit.OnKeyDown := SearchEditKeyDown;
  FSearchEdit.OnKeyPress := SearchEditKeyPress;

  FReplaceEdit := TEdit.Create(FSearchPanel);
  FReplaceEdit.Parent := FSearchPanel;
  StyleSearchEdit(FReplaceEdit);
  FReplaceEdit.TextHint := 'Replace';
  FReplaceEdit.Visible := False;
  FReplaceEdit.OnKeyDown := SearchEditKeyDown;
  FReplaceEdit.OnKeyPress := SearchEditKeyPress;

  FSearchMatchCaseButton := NewButton('Aa', 'Match case', 34);
  FSearchMatchCaseButton.GroupIndex := 10;
  FSearchMatchCaseButton.AllowAllUp := True;

  FSearchWholeWordButton := NewButton('ab', 'Match whole word', 34);
  FSearchWholeWordButton.GroupIndex := 11;
  FSearchWholeWordButton.AllowAllUp := True;

  FSearchRegexButton := NewButton('.*', 'Use regular expression', 34);
  FSearchRegexButton.GroupIndex := 12;
  FSearchRegexButton.AllowAllUp := True;

  FSearchStatusLabel := TLabel.Create(FSearchPanel);
  FSearchStatusLabel.Parent := FSearchPanel;
  FSearchStatusLabel.AutoSize := False;
  FSearchStatusLabel.Alignment := taCenter;
  FSearchStatusLabel.Layout := tlCenter;
  FSearchStatusLabel.Font.Color := clWhite;
  FSearchStatusLabel.Font.Name := 'Segoe UI';
  FSearchStatusLabel.Font.Size := 11;
  FSearchStatusLabel.StyleElements := [];
  FSearchStatusLabel.Caption := 'No results';

  FSearchPrevButton := NewButton('', 'Previous match', 30);
  SetSearchButtonGlyph(FSearchPrevButton, 'prev');
  FSearchNextButton := NewButton('', 'Next match', 30);
  SetSearchButtonGlyph(FSearchNextButton, 'next');
  FSearchReplaceButton := NewButton('AB', 'Replace', 34);
  FSearchReplaceButton.Visible := False;
  FSearchReplaceAllButton := NewButton('All', 'Replace all', 42);
  FSearchReplaceAllButton.Visible := False;
  FSearchCloseButton := NewButton('', 'Close', 30);
  SetSearchButtonGlyph(FSearchCloseButton, 'close');

  LayoutSearchPanel;
end;

procedure TCodeEditor.SetSearchButtonGlyph(Button: TSpeedButton; const Kind: string);
var
  Bmp: Vcl.Graphics.TBitmap;
begin
  Bmp := Vcl.Graphics.TBitmap.Create;
  try
    Bmp.SetSize(16, 16);
    Bmp.Canvas.Brush.Color := clFuchsia;
    Bmp.Canvas.FillRect(Rect(0, 0, 16, 16));
    Bmp.Transparent := True;
    Bmp.TransparentColor := clFuchsia;
    Bmp.Canvas.Pen.Color := clWhite;
    Bmp.Canvas.Pen.Width := 2;

    if Kind = 'expand' then
    begin
      Bmp.Canvas.MoveTo(4, 6);
      Bmp.Canvas.LineTo(8, 10);
      Bmp.Canvas.LineTo(12, 6);
    end
    else if Kind = 'collapse' then
    begin
      Bmp.Canvas.MoveTo(4, 10);
      Bmp.Canvas.LineTo(8, 6);
      Bmp.Canvas.LineTo(12, 10);
    end
    else if Kind = 'prev' then
    begin
      Bmp.Canvas.MoveTo(8, 3);
      Bmp.Canvas.LineTo(8, 13);
      Bmp.Canvas.MoveTo(4, 7);
      Bmp.Canvas.LineTo(8, 3);
      Bmp.Canvas.LineTo(12, 7);
    end
    else if Kind = 'next' then
    begin
      Bmp.Canvas.MoveTo(8, 3);
      Bmp.Canvas.LineTo(8, 13);
      Bmp.Canvas.MoveTo(4, 9);
      Bmp.Canvas.LineTo(8, 13);
      Bmp.Canvas.LineTo(12, 9);
    end
    else if Kind = 'close' then
    begin
      Bmp.Canvas.MoveTo(4, 4);
      Bmp.Canvas.LineTo(12, 12);
      Bmp.Canvas.MoveTo(12, 4);
      Bmp.Canvas.LineTo(4, 12);
    end;

    Button.Caption := '';
    Button.Glyph.Assign(Bmp);
    Button.NumGlyphs := 1;
    StyleSearchButton(Button);
  finally
    Bmp.Free;
  end;
end;

procedure TCodeEditor.StyleSearchEdit(Edit: TEdit);
begin
  Edit.AutoSize := False;
  Edit.ParentColor := False;
  Edit.Color := $00252525;
  Edit.StyleElements := [];
  Edit.Font.Name := 'Segoe UI';
  Edit.Font.Size := 11;
  Edit.Font.Color := clWhite;
  Edit.BorderStyle := bsSingle;
  Edit.Ctl3D := False;
end;

procedure TCodeEditor.StyleSearchButton(Button: TSpeedButton);
begin
  Button.Flat := True;
  Button.Transparent := False;
  Button.StyleElements := [];
  Button.Font.Name := 'Segoe UI';
  Button.Font.Size := 11;
  Button.Font.Color := clWhite;
end;

procedure TCodeEditor.LayoutSearchPanel;
var
  X: Integer;
  TopOffset: Integer;
  PanelWidth: Integer;
  EditWidth: Integer;
  ButtonTop: Integer;
begin
  if not Assigned(FSearchPanel) then
    Exit;

  PanelWidth := EnsureRange(ClientWidth - 28, 520, 760);
  FSearchPanel.Width := PanelWidth;
  FSearchPanel.Height := IfThen(FSearchExpanded, 96, 54);
  FSearchPanel.Left := Max(4, ClientWidth - FSearchPanel.Width - 14);
  FSearchPanel.Top := 8;

  TopOffset := 10;
  ButtonTop := TopOffset;
  X := 8;
  FSearchExpandButton.SetBounds(X, ButtonTop, 34, 34);
  FSearchExpandButton.Caption := '';
  Inc(X, 40);

  EditWidth := Max(180, PanelWidth - 450);
  FSearchEdit.SetBounds(X, TopOffset, EditWidth, 34);
  FReplaceEdit.SetBounds(X, TopOffset + 42, EditWidth, 34);
  Inc(X, EditWidth + 10);

  FSearchMatchCaseButton.SetBounds(X, ButtonTop, 40, 34);
  Inc(X, 38);
  FSearchWholeWordButton.SetBounds(X, ButtonTop, 40, 34);
  Inc(X, 38);
  FSearchRegexButton.SetBounds(X, ButtonTop, 40, 34);
  Inc(X, 44);

  FSearchStatusLabel.SetBounds(X, TopOffset, 128, 34);
  Inc(X, 124);
  FSearchPrevButton.SetBounds(X, ButtonTop, 36, 34);
  FSearchPrevButton.Caption := '';
  Inc(X, 34);
  FSearchNextButton.SetBounds(X, ButtonTop, 36, 34);
  FSearchNextButton.Caption := '';
  Inc(X, 38);
  FSearchCloseButton.SetBounds(X, ButtonTop, 36, 34);
  FSearchCloseButton.Caption := '';

  FSearchReplaceButton.SetBounds(FReplaceEdit.Left + FReplaceEdit.Width + 10, TopOffset + 42, 44, 34);
  FSearchReplaceAllButton.SetBounds(FSearchReplaceButton.Left + 48, TopOffset + 42, 62, 34);

  FReplaceEdit.Visible := FSearchExpanded;
  FSearchReplaceButton.Visible := FSearchExpanded;
  FSearchReplaceAllButton.Visible := FSearchExpanded;
  if FSearchExpanded then
  begin
    SetSearchButtonGlyph(FSearchExpandButton, 'collapse');
  end
  else
  begin
    SetSearchButtonGlyph(FSearchExpandButton, 'expand');
  end;
end;

procedure TCodeEditor.UpdateSearch;
var
  LineIndex: Integer;
  SourceLine: string;
  SearchText: string;
  FoundAt: Integer;
  Offset: Integer;
  Options: TRegExOptions;
  Matches: TMatchCollection;
  Match: TMatch;
  SearchMatch: TCodeSearchMatch;
begin
  if not Assigned(FSearchMatches) then
    Exit;

  FSearchMatches.Clear;
  FSearchIndex := -1;
  SearchText := FSearchEdit.Text;
  if SearchText = '' then
  begin
    FSearchStatusLabel.Caption := 'No results';
    Invalidate;
    Exit;
  end;

  for LineIndex := 0 to FLines.Count - 1 do
  begin
    SourceLine := FLines[LineIndex];
    if FSearchRegexButton.Down then
    begin
      Options := [];
      if not FSearchMatchCaseButton.Down then
        Include(Options, roIgnoreCase);
      try
        Matches := TRegEx.Matches(SourceLine, SearchText, Options);
        for Match in Matches do
          if Match.Length > 0 then
          begin
            if FSearchWholeWordButton.Down and not IsWholeWordMatch(SourceLine, Match.Index, Match.Length) then
              Continue;
            SearchMatch.Line := LineIndex;
            SearchMatch.Column := Match.Index;
            SearchMatch.Length := Match.Length;
            FSearchMatches.Add(SearchMatch);
          end;
      except
        FSearchStatusLabel.Caption := 'Invalid regex';
        Invalidate;
        Exit;
      end;
    end
    else
    begin
      Offset := 1;
      repeat
        if FSearchMatchCaseButton.Down then
          FoundAt := Pos(SearchText, Copy(SourceLine, Offset, MaxInt))
        else
          FoundAt := Pos(LowerCase(SearchText), LowerCase(Copy(SourceLine, Offset, MaxInt)));
        if FoundAt = 0 then
          Break;
        Inc(FoundAt, Offset - 1);
        if not FSearchWholeWordButton.Down or IsWholeWordMatch(SourceLine, FoundAt - 1, Length(SearchText)) then
        begin
          SearchMatch.Line := LineIndex;
          SearchMatch.Column := FoundAt - 1;
          SearchMatch.Length := Length(SearchText);
          FSearchMatches.Add(SearchMatch);
        end;
        Offset := FoundAt + Max(1, Length(SearchText));
      until Offset > Length(SourceLine);
    end;
  end;

  if FSearchMatches.Count = 0 then
    FSearchStatusLabel.Caption := 'No results'
  else
  begin
    FSearchIndex := 0;
    FSearchStatusLabel.Caption := Format('%d of %d', [FSearchIndex + 1, FSearchMatches.Count]);
  end;
  Invalidate;
end;

procedure TCodeEditor.SelectSearchMatch(Index: Integer);
var
  Match: TCodeSearchMatch;
begin
  if (Index < 0) or (Index >= FSearchMatches.Count) then
    Exit;

  FSearchIndex := Index;
  Match := FSearchMatches[FSearchIndex];
  FAnchor := TCodePosition.Create(Match.Line, Match.Column);
  FCaret := TCodePosition.Create(Match.Line, Match.Column + Match.Length);
  EnsureCaretVisible;
  FSearchStatusLabel.Caption := Format('%d of %d', [FSearchIndex + 1, FSearchMatches.Count]);
  Invalidate;
end;

procedure TCodeEditor.FindNextMatch;
begin
  if FSearchMatches.Count = 0 then
    Exit;
  SelectSearchMatch((FSearchIndex + 1) mod FSearchMatches.Count);
end;

procedure TCodeEditor.FindPreviousMatch;
begin
  if FSearchMatches.Count = 0 then
    Exit;
  SelectSearchMatch((FSearchIndex + FSearchMatches.Count - 1) mod FSearchMatches.Count);
end;

procedure TCodeEditor.ReplaceCurrentMatch;
begin
  if FSearchMatches.Count = 0 then
    Exit;

  SelectSearchMatch(FSearchIndex);
  SelectedText := FReplaceEdit.Text;
  UpdateSearch;
end;

procedure TCodeEditor.ReplaceAllMatches;
var
  UndoItem: TCodeUndoItem;
  I: Integer;
  Match: TCodeSearchMatch;
  LineText: string;
begin
  if FSearchMatches.Count = 0 then
    Exit;

  FinishUndoGroup;
  UndoItem := CaptureUndoState;
  for I := FSearchMatches.Count - 1 downto 0 do
  begin
    Match := FSearchMatches[I];
    LineText := FLines[Match.Line];
    Delete(LineText, Match.Column + 1, Match.Length);
    Insert(FReplaceEdit.Text, LineText, Match.Column + 1);
    FLines[Match.Line] := LineText;
  end;
  CommitUndoState(UndoItem);
  UpdateSearch;
  LinesChanged(Self);
end;

procedure TCodeEditor.HideSearchPanel;
begin
  if Assigned(FSearchPanel) then
    FSearchPanel.Hide;
  if Assigned(FSearchMatches) then
    FSearchMatches.Clear;
  FSearchIndex := -1;
  Invalidate;
  SetFocus;
end;

procedure TCodeEditor.SearchTextChanged(Sender: TObject);
begin
  UpdateSearch;
end;

procedure TCodeEditor.SearchEditKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  case Key of
    VK_ESCAPE:
      begin
        HideSearchPanel;
        Key := 0;
      end;
    VK_RETURN:
      begin
        if Sender = FReplaceEdit then
          ReplaceCurrentMatch
        else if ssShift in Shift then
          FindPreviousMatch
        else
          FindNextMatch;
        Key := 0;
      end;
  end;
end;

procedure TCodeEditor.SearchEditKeyPress(Sender: TObject; var Key: Char);
begin
  if (Key = #13) or (Key = #27) then
    Key := #0;
end;

procedure TCodeEditor.SearchButtonClick(Sender: TObject);
begin
  if Sender = FSearchPrevButton then
    FindPreviousMatch
  else if Sender = FSearchNextButton then
    FindNextMatch
  else if Sender = FSearchCloseButton then
    HideSearchPanel
  else if Sender = FSearchReplaceButton then
    ReplaceCurrentMatch
  else if Sender = FSearchReplaceAllButton then
    ReplaceAllMatches
  else
    UpdateSearch;
end;

procedure TCodeEditor.SearchExpandClick(Sender: TObject);
begin
  FSearchExpanded := not FSearchExpanded;
  LayoutSearchPanel;
end;

procedure TCodeEditor.SeedSearchFromSelection;
var
  Seed: string;
begin
  if HasSelection and (SelectionStart.Line = SelectionEnd.Line) then
  begin
    Seed := GetSelectedText;
    if (Seed <> '') and (FSearchEdit.Text <> Seed) then
      FSearchEdit.Text := Seed;
  end;
end;

procedure TCodeEditor.ShowFind;
begin
  CreateSearchPanel;
  FSearchExpanded := False;
  LayoutSearchPanel;
  FSearchPanel.Show;
  FSearchPanel.BringToFront;
  SeedSearchFromSelection;
  UpdateSearch;
  FSearchEdit.SetFocus;
  FSearchEdit.SelectAll;
end;

procedure TCodeEditor.ShowReplace;
begin
  CreateSearchPanel;
  FSearchExpanded := True;
  LayoutSearchPanel;
  FSearchPanel.Show;
  FSearchPanel.BringToFront;
  SeedSearchFromSelection;
  UpdateSearch;
  FSearchEdit.SetFocus;
  FSearchEdit.SelectAll;
end;

procedure TCodeEditor.SetSelectedText(const Value: string);
var
  UndoItem: TCodeUndoItem;
begin
  FinishUndoGroup;
  UndoItem := CaptureUndoState;
  DeleteSelection;
  InsertText(Value, False);
  CommitUndoState(UndoItem);
end;

procedure TCodeEditor.SetHighlighter(Value: TCustomCodeHighlighter);
begin
  if FHighlighter <> Value then
  begin
    FHighlighter := Value;
    Invalidate;
  end;
end;

procedure TCodeEditor.SetCompletionProvider(Value: TCustomCodeCompletionProvider);
begin
  if FCompletionProvider <> Value then
  begin
    HideCompletion;
    FCompletionProvider := Value;
  end;
end;

procedure TCodeEditor.SetLines(Value: TStrings);
begin
  FinishUndoGroup;
  FLines.Assign(Value);
  if FLines.Count = 0 then
    FLines.Add('');
  FCaret := NormalizePosition(FCaret);
  FAnchor := FCaret;
  ClearUndo;
  LinesChanged(Self);
end;

procedure TCodeEditor.SetOptions(Value: TCodeEditorOptions);
begin
  FOptions.Assign(Value);
end;

procedure TCodeEditor.SetTheme(Value: TCodeEditorThemeColors);
begin
  FTheme.Assign(Value);
end;

procedure TCodeEditor.SetThemeMode(Value: TCodeEditorThemeMode);
begin
  if FThemeMode <> Value then
  begin
    FThemeMode := Value;
    Invalidate;
  end;
end;

function TCodeEditor.GetLines: TStrings;
begin
  Result := FLines;
end;

procedure TCodeEditor.SetScrollBars(Value: System.UITypes.TScrollStyle);
begin
  if FScrollBars <> Value then
  begin
    FScrollBars := Value;
    RecreateWnd;
  end;
end;

procedure TCodeEditor.SetStyledScrollBars(Value: Boolean);
begin
  if FStyledScrollBars <> Value then
  begin
    FStyledScrollBars := Value;
    RecreateWnd;
    Invalidate;
  end;
end;

procedure TCodeEditor.LinesChanged(Sender: TObject);
begin
  UpdateMetrics;
  UpdateScrollBars;
  if not FApplyingUndo then
    Change;
  Invalidate;
end;

procedure TCodeEditor.OptionsChanged(Sender: TObject);
begin
  UpdateMetrics;
  UpdateScrollBars;
  Invalidate;
end;

procedure TCodeEditor.ThemeChanged(Sender: TObject);
begin
  Invalidate;
end;

procedure TCodeEditor.ResolveTheme(Colors: TCodeEditorThemeColors);
begin
  Colors.Assign(FTheme);

  if FThemeMode = ctmVclStyle then
  begin
    Colors.FBackground := StyleServices.GetSystemColor(clWindow);
    Colors.FText := StyleServices.GetSystemColor(clWindowText);
    Colors.FGutterBackground := StyleServices.GetSystemColor(clBtnFace);
    Colors.FGutterText := StyleServices.GetSystemColor(clGrayText);
    Colors.FGutterBorder := StyleServices.GetSystemColor(clBtnShadow);
    Colors.FSelectionBackground := StyleServices.GetSystemColor(clHighlight);
    Colors.FSelectionText := StyleServices.GetSystemColor(clHighlightText);
  end;

  if Assigned(FOnResolveTheme) then
    FOnResolveTheme(Self, Colors);
end;

function TCodeEditor.ActiveTheme: TCodeEditorThemeColors;
begin
  Result := TCodeEditorThemeColors.Create;
  ResolveTheme(Result);
end;

procedure TCodeEditor.Change;
begin
  if Assigned(FOnChange) then
    FOnChange(Self);
end;

procedure TCodeEditor.Clear;
begin
  FinishUndoGroup;
  ClearUndo;
  FLines.Text := '';
  if FLines.Count = 0 then
    FLines.Add('');
  FCaret := TCodePosition.Create(0, 0);
  FAnchor := FCaret;
  LinesChanged(Self);
end;

procedure TCodeEditor.SelectAll;
begin
  FinishUndoGroup;
  FAnchor := TCodePosition.Create(0, 0);
  FCaret := TCodePosition.Create(FLines.Count - 1, Length(FLines[FLines.Count - 1]));
  EnsureCaretVisible;
  Invalidate;
end;

procedure TCodeEditor.DeleteSelection;
var
  StartPos: TCodePosition;
  EndPos: TCodePosition;
  Prefix: string;
  Suffix: string;
  I: Integer;
begin
  if not HasSelection then
    Exit;

  StartPos := SelectionStart;
  EndPos := SelectionEnd;
  Prefix := Copy(FLines[StartPos.Line], 1, StartPos.Column);
  Suffix := Copy(FLines[EndPos.Line], EndPos.Column + 1, MaxInt);

  FLines.BeginUpdate;
  try
    FLines[StartPos.Line] := Prefix + Suffix;
    for I := EndPos.Line downto StartPos.Line + 1 do
      FLines.Delete(I);
    FCaret := StartPos;
    FAnchor := FCaret;
  finally
    FLines.EndUpdate;
  end;
end;

procedure TCodeEditor.InsertText(const Value: string; AddUndo: Boolean);
var
  Parts: TStringList;
  Current: string;
  Normalized: string;
  StartIndex: Integer;
  BreakIndex: Integer;
  Tail: string;
  I: Integer;
  UndoItem: TCodeUndoItem;
begin
  if Value = '' then
    Exit;

  UndoItem := nil;
  if AddUndo then
  begin
    FinishUndoGroup;
    UndoItem := CaptureUndoState;
  end;

  if HasSelection then
    DeleteSelection;

  Parts := TStringList.Create;
  try
    Normalized := StringReplace(Value, #13#10, #10, [rfReplaceAll]);
    Normalized := StringReplace(Normalized, #13, #10, [rfReplaceAll]);

    StartIndex := 1;
    repeat
      BreakIndex := Pos(#10, Copy(Normalized, StartIndex, MaxInt));
      if BreakIndex = 0 then
      begin
        Parts.Add(Copy(Normalized, StartIndex, MaxInt));
        Break;
      end;

      Parts.Add(Copy(Normalized, StartIndex, BreakIndex - 1));
      Inc(StartIndex, BreakIndex);
    until False;

    Current := FLines[FCaret.Line];
    Tail := Copy(Current, FCaret.Column + 1, MaxInt);
    FLines[FCaret.Line] := Copy(Current, 1, FCaret.Column) + Parts[0];
    FCaret.Column := Length(FLines[FCaret.Line]);

    for I := 1 to Parts.Count - 1 do
    begin
      FLines.Insert(FCaret.Line + 1, Parts[I]);
      Inc(FCaret.Line);
      FCaret.Column := Length(Parts[I]);
    end;

    FLines[FCaret.Line] := FLines[FCaret.Line] + Tail;
    FAnchor := FCaret;
  finally
    Parts.Free;
  end;

  EnsureCaretVisible;
  LinesChanged(Self);
  UpdateCaret;
  CommitUndoState(UndoItem);
end;

procedure TCodeEditor.EnsureCaretVisible;
begin
  FTopLine := EnsureRange(FTopLine, 0, Max(0, FLines.Count - VisibleLineCount));
  if FCaret.Line < FTopLine then
    FTopLine := FCaret.Line
  else if FCaret.Line >= FTopLine + VisibleLineCount then
    FTopLine := FCaret.Line - VisibleLineCount + 1;

  if FCaret.Column < FLeftColumn then
    FLeftColumn := FCaret.Column
  else if FCaret.Column >= FLeftColumn + VisibleColumnCount then
    FLeftColumn := FCaret.Column - VisibleColumnCount + 1;

  UpdateScrollBars;
  UpdateCaret;
end;

procedure TCodeEditor.MoveCaret(const Position: TCodePosition; Shift: TShiftState);
begin
  FinishUndoGroup;
  FCaret := NormalizePosition(Position);
  if not (ssShift in Shift) then
    FAnchor := FCaret;
  EnsureCaretVisible;
  Invalidate;
end;

procedure TCodeEditor.KeyDown(var Key: Word; Shift: TShiftState);
var
  UndoItem: TCodeUndoItem;
begin
  inherited;

  if CompletionVisible then
  begin
    case Key of
      VK_ESCAPE:
        begin
          HideCompletion;
          Key := 0;
          Exit;
        end;
      VK_UP:
        begin
          MoveCompletionSelection(-1);
          Key := 0;
          Exit;
        end;
      VK_DOWN:
        begin
          MoveCompletionSelection(1);
          Key := 0;
          Exit;
        end;
      VK_RETURN, VK_TAB:
        begin
          AcceptCompletion;
          FSuppressKeyPress := True;
          Key := 0;
          Exit;
        end;
    end;
  end;

  case Key of
    VK_LEFT:
      if FCaret.Column > 0 then
        MoveCaret(TCodePosition.Create(FCaret.Line, FCaret.Column - 1), Shift)
      else if FCaret.Line > 0 then
        MoveCaret(TCodePosition.Create(FCaret.Line - 1, Length(FLines[FCaret.Line - 1])), Shift);
    VK_RIGHT:
      if FCaret.Column < Length(FLines[FCaret.Line]) then
        MoveCaret(TCodePosition.Create(FCaret.Line, FCaret.Column + 1), Shift)
      else if FCaret.Line < FLines.Count - 1 then
        MoveCaret(TCodePosition.Create(FCaret.Line + 1, 0), Shift);
    VK_UP:
      MoveCaret(TCodePosition.Create(FCaret.Line - 1, FCaret.Column), Shift);
    VK_DOWN:
      MoveCaret(TCodePosition.Create(FCaret.Line + 1, FCaret.Column), Shift);
    VK_HOME:
      MoveCaret(TCodePosition.Create(FCaret.Line, 0), Shift);
    VK_END:
      MoveCaret(TCodePosition.Create(FCaret.Line, Length(FLines[FCaret.Line])), Shift);
    VK_PRIOR:
      MoveCaret(TCodePosition.Create(FCaret.Line - VisibleLineCount, FCaret.Column), Shift);
    VK_NEXT:
      MoveCaret(TCodePosition.Create(FCaret.Line + VisibleLineCount, FCaret.Column), Shift);
    VK_DELETE:
      begin
        HideCompletion;
        FinishUndoGroup;
        UndoItem := CaptureUndoState;
        if HasSelection then
          DeleteSelection
        else if FCaret.Column < Length(FLines[FCaret.Line]) then
        begin
          FLines[FCaret.Line] := Copy(FLines[FCaret.Line], 1, FCaret.Column) +
            Copy(FLines[FCaret.Line], FCaret.Column + 2, MaxInt);
        end
        else if FCaret.Line < FLines.Count - 1 then
        begin
          FLines[FCaret.Line] := FLines[FCaret.Line] + FLines[FCaret.Line + 1];
          FLines.Delete(FCaret.Line + 1);
        end;
        LinesChanged(Self);
        CommitUndoState(UndoItem);
        Key := 0;
      end;
    Ord('A'):
      if ssCtrl in Shift then
      begin
        SelectAll;
        Key := 0;
      end;
    Ord('C'):
      if ssCtrl in Shift then
      begin
        Clipboard.AsText := SelectedText;
        Key := 0;
      end;
    Ord('X'):
      if ssCtrl in Shift then
      begin
        FinishUndoGroup;
        Clipboard.AsText := SelectedText;
        UndoItem := CaptureUndoState;
        DeleteSelection;
        LinesChanged(Self);
        CommitUndoState(UndoItem);
        Key := 0;
      end;
    Ord('F'):
      if ssCtrl in Shift then
      begin
        ShowFind;
        Key := 0;
      end;
    Ord('H'):
      if ssCtrl in Shift then
      begin
        ShowReplace;
        Key := 0;
      end;
    Ord('V'):
      if ssCtrl in Shift then
      begin
        HideCompletion;
        FinishUndoGroup;
        InsertText(Clipboard.AsText);
        Key := 0;
      end;
    VK_SPACE:
      if ssCtrl in Shift then
      begin
        TriggerCompletion;
        Key := 0;
      end;
    Ord('Y'):
      if ssCtrl in Shift then
      begin
        Redo;
        Key := 0;
      end;
    Ord('Z'):
      if ssCtrl in Shift then
      begin
        if ssShift in Shift then
          Redo
        else
          Undo;
        Key := 0;
      end;
  end;
end;

procedure TCodeEditor.KeyPress(var Key: Char);
var
  Line: string;
  UndoItem: TCodeUndoItem;
begin
  inherited;

  if FSuppressKeyPress then
  begin
    FSuppressKeyPress := False;
    Key := #0;
    Exit;
  end;

  case Key of
    #8:
      begin
        HideCompletion;
        FinishUndoGroup;
        UndoItem := CaptureUndoState;
        if HasSelection then
          DeleteSelection
        else if FCaret.Column > 0 then
        begin
          Line := FLines[FCaret.Line];
          Delete(Line, FCaret.Column, 1);
          FLines[FCaret.Line] := Line;
          Dec(FCaret.Column);
          FAnchor := FCaret;
        end
        else if FCaret.Line > 0 then
        begin
          FCaret.Column := Length(FLines[FCaret.Line - 1]);
          FLines[FCaret.Line - 1] := FLines[FCaret.Line - 1] + FLines[FCaret.Line];
          FLines.Delete(FCaret.Line);
          Dec(FCaret.Line);
          FAnchor := FCaret;
        end;
        LinesChanged(Self);
        EnsureCaretVisible;
        CommitUndoState(UndoItem);
        Key := #0;
      end;
    #9:
      begin
        HideCompletion;
        FinishUndoGroup;
        InsertText(StringOfChar(' ', FOptions.TabSize));
        Key := #0;
      end;
    #13:
      begin
        HideCompletion;
        FinishUndoGroup;
        InsertText(sLineBreak);
        Key := #0;
      end;
    #32..#255:
      begin
        InsertTypedText(Key);
        if CharInSet(Key, ['.', '(', '<']) then
          ShowCompletion(Key, False)
        else if CompletionVisible then
          ShowCompletion(#0, False);
        Key := #0;
      end;
  end;
end;

procedure TCodeEditor.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  Thumb: TRect;
  NewPos: Integer;
begin
  inherited;
  if Button = mbLeft then
  begin
    SetFocus;
    HideCompletion;
    if StyledVerticalVisible and PtInRect(StyledVerticalScrollRect, Point(X, Y)) then
    begin
      Thumb := StyledVerticalThumbRect;
      if PtInRect(Thumb, Point(X, Y)) then
      begin
        FScrollBarDragging := True;
        FScrollDragOffset := Y - Thumb.Top;
      end
      else
      begin
        if Y < Thumb.Top then
          NewPos := FTopLine - VisibleLineCount
        else
          NewPos := FTopLine + VisibleLineCount;
        NewPos := EnsureRange(NewPos, 0, Max(0, FLines.Count - VisibleLineCount));
        if NewPos <> FTopLine then
        begin
          FTopLine := NewPos;
          UpdateScrollBars;
          Invalidate;
        end;
      end;
      Exit;
    end;
    if StyledHorizontalVisible and PtInRect(StyledHorizontalScrollRect, Point(X, Y)) then
    begin
      Thumb := StyledHorizontalThumbRect;
      if PtInRect(Thumb, Point(X, Y)) then
      begin
        FHScrollBarDragging := True;
        FScrollDragOffset := X - Thumb.Left;
      end
      else
      begin
        if X < Thumb.Left then
          NewPos := FLeftColumn - VisibleColumnCount
        else
          NewPos := FLeftColumn + VisibleColumnCount;
        NewPos := EnsureRange(NewPos, 0, Max(0, MaxLineLength - VisibleColumnCount + 1));
        if NewPos <> FLeftColumn then
        begin
          FLeftColumn := NewPos;
          UpdateScrollBars;
          Invalidate;
        end;
      end;
      Exit;
    end;
    MoveCaret(PointToCaret(Point(X, Y)), Shift);
    if ssDouble in Shift then
      SelectWordAtCaret;
  end;
end;

procedure TCodeEditor.MouseMove(Shift: TShiftState; X, Y: Integer);
var
  Track: TRect;
  Thumb: TRect;
  ThumbExtent: Integer;
  Travel: Integer;
  MaxTopLine: Integer;
  MaxLeftCol: Integer;
  NewPos: Integer;
begin
  inherited;
  if FScrollBarDragging then
  begin
    Track := StyledVerticalScrollRect;
    Thumb := StyledVerticalThumbRect;
    ThumbExtent := Thumb.Height;
    Travel := Max(1, Track.Height - ThumbExtent);
    MaxTopLine := Max(0, FLines.Count - VisibleLineCount);
    NewPos := EnsureRange(Y - FScrollDragOffset - Track.Top, 0, Travel);
    if MaxTopLine > 0 then
      NewPos := MulDiv(NewPos, MaxTopLine, Travel)
    else
      NewPos := 0;
    if NewPos <> FTopLine then
    begin
      FTopLine := NewPos;
      UpdateScrollBars;
      UpdateCaret;
      Invalidate;
    end;
    Exit;
  end;

  if FHScrollBarDragging then
  begin
    Track := StyledHorizontalScrollRect;
    Thumb := StyledHorizontalThumbRect;
    ThumbExtent := Thumb.Width;
    Travel := Max(1, Track.Width - ThumbExtent);
    MaxLeftCol := Max(0, MaxLineLength - VisibleColumnCount + 1);
    NewPos := EnsureRange(X - FScrollDragOffset - Track.Left, 0, Travel);
    if MaxLeftCol > 0 then
      NewPos := MulDiv(NewPos, MaxLeftCol, Travel)
    else
      NewPos := 0;
    if NewPos <> FLeftColumn then
    begin
      FLeftColumn := NewPos;
      UpdateScrollBars;
      UpdateCaret;
      Invalidate;
    end;
    Exit;
  end;

  if ssLeft in Shift then
    MoveCaret(PointToCaret(Point(X, Y)), Shift + [ssShift]);
end;

procedure TCodeEditor.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  inherited;
  FScrollBarDragging := False;
  FHScrollBarDragging := False;
end;

procedure TCodeEditor.SelectWordAtCaret;

  function IsWordChar(Ch: Char): Boolean;
  begin
    Result := Ch.IsLetterOrDigit or (Ch = '_');
  end;

var
  LineText: string;
  StartCol: Integer;
  EndCol: Integer;
begin
  if (FCaret.Line < 0) or (FCaret.Line >= FLines.Count) then
    Exit;

  LineText := FLines[FCaret.Line];
  StartCol := FCaret.Column;
  EndCol := FCaret.Column;

  if not ((StartCol < Length(LineText)) and IsWordChar(LineText[StartCol + 1])) then
  begin
    if (StartCol > 0) and IsWordChar(LineText[StartCol]) then
    begin
      Dec(StartCol);
      Dec(EndCol);
    end
    else
      Exit;
  end;

  while (StartCol > 0) and IsWordChar(LineText[StartCol]) do
    Dec(StartCol);
  while (EndCol < Length(LineText)) and IsWordChar(LineText[EndCol + 1]) do
    Inc(EndCol);

  FAnchor := TCodePosition.Create(FCaret.Line, StartCol);
  FCaret := TCodePosition.Create(FCaret.Line, EndCol);
  EnsureCaretVisible;
  Invalidate;
end;

procedure TCodeEditor.Paint;
var
  ThemeColors: TCodeEditorThemeColors;
begin
  ThemeColors := ActiveTheme;
  try
    Canvas.Brush.Color := ThemeColors.Background;
    Canvas.FillRect(ClientRect);
    Canvas.Font.Assign(Font);
    Canvas.Font.Color := ThemeColors.Text;
    PaintGutter;
    PaintText;
    PaintStyledScrollBars;
  finally
    ThemeColors.Free;
  end;
end;

procedure TCodeEditor.PaintGutter;
var
  I: Integer;
  LineIndex: Integer;
  Y: Integer;
  Text: string;
  R: TRect;
  ThemeColors: TCodeEditorThemeColors;
begin
  if not FOptions.ShowGutter then
    Exit;

  ThemeColors := ActiveTheme;
  try
    R := Rect(0, 0, FGutterWidth, ClientHeight);
    Canvas.Brush.Color := ThemeColors.GutterBackground;
    Canvas.FillRect(R);
    Canvas.Pen.Color := ThemeColors.GutterBorder;
    Canvas.MoveTo(FGutterWidth - 1, 0);
    Canvas.LineTo(FGutterWidth - 1, ClientHeight);

    Canvas.Font.Color := ThemeColors.GutterText;
    for I := 0 to VisibleLineCount - 1 do
    begin
      LineIndex := FTopLine + I;
      if LineIndex >= FLines.Count then
        Break;

      Y := I * FLineHeight + 1;
      Text := IntToStr(LineIndex + 1);
      Canvas.TextOut(FGutterWidth - Canvas.TextWidth(Text) - 8, Y, Text);
    end;
  finally
    ThemeColors.Free;
  end;
end;

procedure TCodeEditor.PaintText;
var
  I: Integer;
  LineIndex: Integer;
  Y: Integer;
  LineText: string;
  R: TRect;
  ThemeColors: TCodeEditorThemeColors;
begin
  R := ClientTextRect;
  ThemeColors := ActiveTheme;
  try
    Canvas.Brush.Color := ThemeColors.Background;
    for I := 0 to VisibleLineCount - 1 do
    begin
      LineIndex := FTopLine + I;
      if LineIndex >= FLines.Count then
        Break;

      Y := I * FLineHeight + 1;
      LineText := FLines[LineIndex];
      PaintSearchMatchesLine(LineIndex, Y, LineText);
      PaintSelectionLine(LineIndex, Y, LineText);
      PaintTokenText(LineText, R.Left, Y, LineIndex);
    end;
  finally
    ThemeColors.Free;
  end;
end;

procedure TCodeEditor.PaintStyledScrollBars;
var
  Track: TRect;
  Thumb: TRect;
  ThemeColors: TCodeEditorThemeColors;
  TrackColor: TColor;
  ThumbColor: TColor;
begin
  if not FStyledScrollBars then
    Exit;

  ThemeColors := ActiveTheme;
  try
    TrackColor := ThemeColors.GutterBackground;
    if IsDarkTheme(ThemeColors) then
      ThumbColor := ShiftBrightness(TrackColor, 40)
    else
      ThumbColor := ShiftBrightness(TrackColor, -50);
  finally
    ThemeColors.Free;
  end;

  if StyledVerticalVisible then
  begin
    Track := StyledVerticalScrollRect;
    Canvas.Brush.Color := TrackColor;
    Canvas.FillRect(Track);

    Thumb := StyledVerticalThumbRect;
    if Thumb.Height > 0 then
    begin
      InflateRect(Thumb, -2, -2);
      Canvas.Brush.Color := ThumbColor;
      Canvas.FillRect(Thumb);
    end;
  end;

  if StyledHorizontalVisible then
  begin
    Track := StyledHorizontalScrollRect;
    Canvas.Brush.Color := TrackColor;
    Canvas.FillRect(Track);

    Thumb := StyledHorizontalThumbRect;
    if Thumb.Width > 0 then
    begin
      InflateRect(Thumb, -2, -2);
      Canvas.Brush.Color := ThumbColor;
      Canvas.FillRect(Thumb);
    end;
  end;
end;

procedure TCodeEditor.PaintSelectionLine(ALineIndex, Y: Integer; const LineText: string);
var
  StartPos: TCodePosition;
  EndPos: TCodePosition;
  StartCol: Integer;
  EndCol: Integer;
  X1: Integer;
  X2: Integer;
  R: TRect;
  ThemeColors: TCodeEditorThemeColors;
begin
  if not HasSelection then
    Exit;

  StartPos := SelectionStart;
  EndPos := SelectionEnd;
  if (ALineIndex < StartPos.Line) or (ALineIndex > EndPos.Line) then
    Exit;

  StartCol := 0;
  EndCol := Length(LineText);
  if ALineIndex = StartPos.Line then
    StartCol := StartPos.Column;
  if ALineIndex = EndPos.Line then
    EndCol := EndPos.Column;

  R := ClientTextRect;
  X1 := R.Left + (StartCol - FLeftColumn) * FCharWidth;
  X2 := R.Left + (EndCol - FLeftColumn) * FCharWidth;
  ThemeColors := ActiveTheme;
  try
    Canvas.Brush.Color := ThemeColors.SelectionBackground;
    Canvas.FillRect(Rect(Max(R.Left, X1), Y - 1, Max(R.Left, X2), Y + FLineHeight - 1));
  finally
    ThemeColors.Free;
  end;
end;

procedure TCodeEditor.PaintSearchMatchesLine(ALineIndex, Y: Integer; const LineText: string);
var
  I: Integer;
  Match: TCodeSearchMatch;
  R: TRect;
  X1: Integer;
  X2: Integer;
  FillColor: TColor;
begin
  if not SearchVisible or not Assigned(FSearchMatches) then
    Exit;

  R := ClientTextRect;
  for I := 0 to FSearchMatches.Count - 1 do
  begin
    Match := FSearchMatches[I];
    if Match.Line <> ALineIndex then
      Continue;

    X1 := R.Left + (Match.Column - FLeftColumn) * FCharWidth;
    X2 := R.Left + (Match.Column + Match.Length - FLeftColumn) * FCharWidth;
    if I = FSearchIndex then
      FillColor := $00606000
    else
      FillColor := $00404040;

    Canvas.Brush.Color := FillColor;
    Canvas.FillRect(Rect(Max(R.Left, X1), Y - 1, Max(R.Left, X2), Y + FLineHeight - 1));
  end;
end;

procedure TCodeEditor.PaintTokenText(const LineText: string; X, Y: Integer; ALineIndex: Integer);
var
  Tokens: TCodeTokenArray;
  Token: TCodeToken;
  Style: TCodeTextStyle;
  Text: string;
  TokenX: Integer;
  ThemeColors: TCodeEditorThemeColors;
begin
  if Assigned(FHighlighter) then
    Tokens := FHighlighter.TokenizeLine(LineText, ALineIndex)
  else
    SetLength(Tokens, 0);

  if not Assigned(FHighlighter) then
  begin
    ThemeColors := ActiveTheme;
    try
      Canvas.Font.Color := ThemeColors.Text;
      Canvas.TextOut(X - FLeftColumn * FCharWidth, Y, LineText);
    finally
      ThemeColors.Free;
    end;
    Exit;
  end;

  ThemeColors := ActiveTheme;
  try
    for Token in Tokens do
    begin
      Text := Copy(LineText, Token.Start, Token.Length);
      TokenX := X + (Token.Start - 1 - FLeftColumn) * FCharWidth;
      Style := FHighlighter.Styles[Token.Kind];
      if FOptions.ThemeSyntaxColors then
        Style := TokenStyleForTheme(Token.Kind, Style, ThemeColors);
      Canvas.Font.Color := Style.Foreground;
      Canvas.Font.Style := Style.FontStyle;
      Canvas.Brush.Style := bsClear;
      Canvas.TextOut(TokenX, Y, Text);
    end;
  finally
    ThemeColors.Free;
  end;

  Canvas.Brush.Style := bsSolid;
  Canvas.Font.Style := Font.Style;
end;

end.
