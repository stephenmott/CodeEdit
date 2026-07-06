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
  CodeEdit.Highlighter,
  CodeEdit.Templates;

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
    FBracketMatching: Boolean;
    FLineCommentPrefix: string;
    FShowMinimap: Boolean;
    FMaxPasteBytes: Integer;
    FThemeSyntaxColors: Boolean;
    FShowGutter: Boolean;
    FTabSize: Integer;
    FOnChange: TNotifyEvent;
    procedure SetBracketMatching(Value: Boolean);
    procedure SetLineCommentPrefix(const Value: string);
    procedure SetMaxPasteBytes(Value: Integer);
    procedure SetShowMinimap(Value: Boolean);
    procedure SetThemeSyntaxColors(Value: Boolean);
    procedure SetShowGutter(Value: Boolean);
    procedure SetTabSize(Value: Integer);
  protected
    procedure Changed;
  public
    constructor Create;
    procedure Assign(Source: TPersistent); override;
  published
    property BracketMatching: Boolean read FBracketMatching write SetBracketMatching default True;
    property LineCommentPrefix: string read FLineCommentPrefix write SetLineCommentPrefix;
    property MaxPasteBytes: Integer read FMaxPasteBytes write SetMaxPasteBytes default 67108864;
    property ShowGutter: Boolean read FShowGutter write SetShowGutter default True;
    property ShowMinimap: Boolean read FShowMinimap write SetShowMinimap default False;
    property TabSize: Integer read FTabSize write SetTabSize default 2;
    property ThemeSyntaxColors: Boolean read FThemeSyntaxColors write SetThemeSyntaxColors default True;
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
    BeforeModified: Boolean;
    BeforeCaret: TCodePosition;
    AfterCaret: TCodePosition;
    BeforeAnchor: TCodePosition;
    AfterAnchor: TCodePosition;
    BeforeBreakpoints: TArray<Integer>;
    AfterBreakpoints: TArray<Integer>;
    BeforeExecutionLine: Integer;
    AfterExecutionLine: Integer;
  end;

  TCodeUndoGroupKind = (ugNone, ugTyping);

  TCodeSearchMatch = record
    Line: Integer;
    Column: Integer;
    Length: Integer;
  end;

  TCodeSelectionRange = record
    Anchor: TCodePosition;
    Caret: TCodePosition;
  end;

  // Cached tokenization of one line. Entries are only trusted while both Text
  // and StartState still match, so the cache never needs precise invalidation.
  TCodeLineTokensEntry = record
    Text: string;
    StartState: Integer;
    EndState: Integer;
    Tokens: TCodeTokenArray;
  end;

  TCodeEditorCaretChangeEvent = procedure(Sender: TObject; const Caret: TCodePosition) of object;
  TCodeEditorSelectionChangeEvent = procedure(Sender: TObject; const SelectionStart,
    SelectionEnd: TCodePosition) of object;

  TCodeEditor = class;

  TCodeEditorCommand = (
    eccUndo,
    eccRedo,
    eccCut,
    eccCopy,
    eccPaste,
    eccSelectAll,
    eccFind,
    eccReplace,
    eccToggleLineComment,
    eccCommentSelection,
    eccUncommentSelection,
    eccTriggerCompletion,
    eccTriggerSignatureHelp,
    eccTriggerTemplates
  );

  TCodeLineMarkerKind = (lmkExecutable, lmkError, lmkWarning, lmkInfo);

  // Line is 1-based, matching the gutter line numbers.
  TCodeLineMarker = class(TCollectionItem)
  private
    FBackground: TColor;
    FForeground: TColor;
    FKind: TCodeLineMarkerKind;
    FLine: Integer;
    FText: string;
    procedure SetBackground(Value: TColor);
    procedure SetForeground(Value: TColor);
    procedure SetKind(Value: TCodeLineMarkerKind);
    procedure SetLine(Value: Integer);
    procedure SetText(const Value: string);
  protected
    function GetDisplayName: string; override;
  public
    constructor Create(Collection: TCollection); override;
    procedure Assign(Source: TPersistent); override;
  published
    property Background: TColor read FBackground write SetBackground default clNone;
    property Foreground: TColor read FForeground write SetForeground default clNone;
    property Kind: TCodeLineMarkerKind read FKind write SetKind default lmkInfo;
    property Line: Integer read FLine write SetLine default 1;
    property Text: string read FText write SetText;
  end;

  TCodeLineMarkers = class(TOwnedCollection)
  private
    function GetItem(Index: Integer): TCodeLineMarker;
    procedure SetItem(Index: Integer; Value: TCodeLineMarker);
  protected
    procedure Update(Item: TCollectionItem); override;
  public
    constructor Create(AOwner: TPersistent);
    function IndexOfLine(ALine: Integer; Kind: TCodeLineMarkerKind): Integer;
    function ContainsLine(ALine: Integer; Kind: TCodeLineMarkerKind): Boolean;
    function AddLine(ALine: Integer; Kind: TCodeLineMarkerKind): TCodeLineMarker;
    procedure RemoveLine(ALine: Integer; Kind: TCodeLineMarkerKind);
    property Items[Index: Integer]: TCodeLineMarker read GetItem write SetItem; default;
  end;

  // Line is 1-based, matching the gutter line numbers.
  TCodeBreakpoint = class(TCollectionItem)
  private
    FLine: Integer;
    procedure SetLine(Value: Integer);
  protected
    function GetDisplayName: string; override;
  public
    constructor Create(Collection: TCollection); override;
    procedure Assign(Source: TPersistent); override;
  published
    property Line: Integer read FLine write SetLine default 1;
  end;

  TCodeBreakpoints = class(TOwnedCollection)
  private
    function GetItem(Index: Integer): TCodeBreakpoint;
    procedure SetItem(Index: Integer; Value: TCodeBreakpoint);
  protected
    procedure Update(Item: TCollectionItem); override;
  public
    constructor Create(AOwner: TPersistent);
    function IndexOfLine(ALine: Integer): Integer;
    function ContainsLine(ALine: Integer): Boolean;
    function AddLine(ALine: Integer): TCodeBreakpoint;
    procedure RemoveLine(ALine: Integer);
    function SortedLines: TArray<Integer>;
    property Items[Index: Integer]: TCodeBreakpoint read GetItem write SetItem; default;
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
    FCompletionEnd: TCodePosition;
    FSignatureForm: TForm;
    FSignatureLabel: TLabel;
    FSignatureItems: TCodeSignatureItems;
    FSignatureContext: TCodeSignatureHelpContext;
    FTemplateProvider: TCodeTemplateProvider;
    FTemplateForm: TForm;
    FTemplateList: TListBox;
    FTemplateMatches: TList<TCodeTemplate>;
    FTemplateStart: TCodePosition;
    FTemplateEnd: TCodePosition;
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
    FSearchUpdating: Boolean;
    FStyledScrollBars: Boolean;
    FScrollBarDragging: Boolean;
    FHScrollBarDragging: Boolean;
    FMinimapDragging: Boolean;
    FScrollDragOffset: Integer;
    FSelections: TList<TCodeSelectionRange>;
    FSuppressKeyPress: Boolean;
    FApplyingUndo: Boolean;
    FActiveUndoItem: TCodeUndoItem;
    FActiveUndoGroup: TCodeUndoGroupKind;
    FMaxUndo: Integer;
    FModified: Boolean;
    FReadOnly: Boolean;
    FScrollBars: System.UITypes.TScrollStyle;
    FBreakpoints: TCodeBreakpoints;
    FLineMarkers: TCodeLineMarkers;
    FExecutionLine: Integer;
    FDesiredColumn: Integer;
    FZoom: Integer;
    FMaxLineLength: Integer;
    FMaxLineLengthValid: Boolean;
    FPaintTheme: TCodeEditorThemeColors;
    FLineTokenCache: TDictionary<Integer, TCodeLineTokensEntry>;
    FStateChainValid: Integer;
    FOnChange: TNotifyEvent;
    FOnCaretChange: TCodeEditorCaretChangeEvent;
    FOnResolveTheme: TCodeEditorResolveThemeEvent;
    FOnBreakpointsChanged: TNotifyEvent;
    FOnSelectionChange: TCodeEditorSelectionChangeEvent;
    FOnZoomChanged: TNotifyEvent;
    procedure LinesChanged(Sender: TObject);
    procedure OptionsChanged(Sender: TObject);
    procedure ThemeChanged(Sender: TObject);
    procedure SetHighlighter(Value: TCustomCodeHighlighter);
    procedure SetCompletionProvider(Value: TCustomCodeCompletionProvider);
    procedure SetLines(Value: TStrings);
    procedure SetOptions(Value: TCodeEditorOptions);
    procedure SetScrollBars(Value: System.UITypes.TScrollStyle);
    procedure SetStyledScrollBars(Value: Boolean);
    procedure SetCaret(Value: TCodePosition);
    procedure SetLeftColumn(Value: Integer);
    procedure SetModified(Value: Boolean);
    procedure SetReadOnly(Value: Boolean);
    procedure SetTheme(Value: TCodeEditorThemeColors);
    procedure SetThemeMode(Value: TCodeEditorThemeMode);
    procedure SetTopLine(Value: Integer);
    procedure ResolveTheme(Colors: TCodeEditorThemeColors);
    function ActiveTheme: TCodeEditorThemeColors;
    function GetLines: TStrings;
    function ClientTextRect: TRect;
    function MinimapVisible: Boolean;
    function MinimapRect: TRect;
    function MinimapContentHeight: Integer;
    function MinimapScrollOffset: Integer;
    function MinimapViewportRect: TRect;
    procedure ScrollMinimapTo(Y: Integer);
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
    function RangeStart(const Range: TCodeSelectionRange): TCodePosition;
    function RangeEnd(const Range: TCodeSelectionRange): TCodePosition;
    function HasMultipleSelections: Boolean;
    function ComparePositions(const A, B: TCodePosition): Integer;
    function SelectedLineStart: Integer;
    function SelectedLineEnd: Integer;
    function MatchingBracketPosition(out OpenPos, ClosePos: TCodePosition): Boolean;
    function GetSelectedText: string;
    function CompletionPrefix: string;
    function CompletionVisible: Boolean;
    function CompletionDisplayText(Item: TCodeCompletionItem): string;
    function SignatureVisible: Boolean;
    function SignatureFunctionName: string;
    function SignatureActiveParameter: Integer;
    function SearchVisible: Boolean;
    function IsWholeWordMatch(const LineText: string; Column, MatchLength: Integer): Boolean;
    function ClipboardTextBytes: UInt64;
    function CanPasteFromClipboard: Boolean;
    function CaptureUndoState: TCodeUndoItem;
    function CurrentTextSnapshot: string;
    procedure RestoreMarkers(const BreakpointLines: TArray<Integer>; ExecutionLine: Integer);
    function CanUndo: Boolean;
    function CanRedo: Boolean;
    procedure ClearUndoStack(Stack: TStack<TCodeUndoItem>);
    procedure PushUndoItem(Stack: TStack<TCodeUndoItem>; Item: TCodeUndoItem);
    procedure RestoreUndoState(const Text: string; const Caret, Anchor: TCodePosition;
      const BreakpointLines: TArray<Integer>; ExecutionLine: Integer);
    procedure CommitUndoState(Item: TCodeUndoItem);
    procedure FinishUndoGroup;
    procedure CancelUndoGroup;
    procedure DoCaretChange;
    procedure DoSelectionChange;
    procedure DoEditStateChanged;
    function CanContinueTypingUndo(const Value: string): Boolean;
    procedure InsertTypedText(const Value: string);
    procedure PasteFromClipboard;
    procedure CopyToClipboard;
    procedure CutToClipboard;
    procedure CreateCompletionPopup;
    procedure PopulateCompletionPopup;
    procedure ShowCompletion(TriggerChar: Char; ExplicitRequest: Boolean);
    procedure HideCompletion;
    procedure AcceptCompletion;
    procedure CompletionListClick(Sender: TObject);
    procedure CompletionListDblClick(Sender: TObject);
    procedure MoveCompletionSelection(Delta: Integer);
    procedure SetTemplateProvider(Value: TCodeTemplateProvider);
    function TemplatesVisible: Boolean;
    function TemplateDisplayText(Template: TCodeTemplate): string;
    procedure CreateTemplatePopup;
    procedure PopulateTemplatePopup;
    procedure ShowTemplates(ExplicitRequest: Boolean);
    procedure HideTemplates;
    procedure AcceptTemplate;
    procedure TemplateListDblClick(Sender: TObject);
    procedure MoveTemplateSelection(Delta: Integer);
    procedure InsertTemplateRange(Template: TCodeTemplate; const StartPos, EndPos: TCodePosition);
    procedure CreateSignaturePopup;
    procedure ShowSignatureHelp(TriggerChar: Char; ExplicitRequest: Boolean);
    procedure UpdateSignatureHelp(TriggerChar: Char);
    procedure HideSignatureHelp;
    procedure PopulateSignaturePopup;
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
    procedure ClearExtraSelections;
    procedure AddSelectionRange(const Anchor, Caret: TCodePosition);
    procedure SelectNextOccurrence;
    procedure SelectAllOccurrences;
    procedure InsertTextAtRange(const StartPos, EndPos: TCodePosition; const Value: string;
      out NewCaret: TCodePosition);
    function PositionBefore(const Position: TCodePosition): TCodePosition;
    function PositionAfter(const Position: TCodePosition): TCodePosition;
    function CollectSelectionRanges: TArray<TCodeSelectionRange>;
    procedure ApplyRangeEdits(var Ranges: TArray<TCodeSelectionRange>; const Value: string);
    procedure ReplaceAllSelections(const Value: string);
    procedure DeleteAllSelections(DeletePrevious: Boolean);
    procedure EnsureCaretVisible;
    procedure UpdateCaret;
    procedure UpdateMetrics;
    procedure UpdateGutterWidth;
    procedure SetZoom(Value: Integer);
    function ScaledFontSize: Integer;
    procedure UpdateScrollBars;
    procedure EnsureLineStates(UpToLine: Integer);
    function LineTokens(ALineIndex: Integer): TCodeTokenArray;
    function WindowInPopups(Wnd: HWND): Boolean;
    function MovePositionForKey(const Position: TCodePosition; Key: Word): TCodePosition;
    procedure MoveMultipleCarets(Key: Word; Shift: TShiftState);
    procedure MoveCaret(const Position: TCodePosition; Shift: TShiftState;
      PreserveDesiredColumn: Boolean = False);
    procedure MoveCaretVertically(DeltaLines: Integer; Shift: TShiftState);
    function PrevWordPosition(const Position: TCodePosition): TCodePosition;
    function NextWordPosition(const Position: TCodePosition): TCodePosition;
    procedure SelectWordAtCaret;
    function LineAtPoint(const Point: TPoint): Integer;
    procedure SetExecutionLine(Value: Integer);
    procedure SetBreakpoints(Value: TCodeBreakpoints);
    procedure SetLineMarkers(Value: TCodeLineMarkers);
    procedure BreakpointsChanged;
    procedure LineMarkersChanged;
    procedure ShiftBreakpoints(AfterLine, Delta: Integer);
    procedure ShiftLineMarkers(AfterLine, Delta: Integer);
    procedure PaintBreakpointGlyph(const CellRect: TRect; HasBp, IsExec: Boolean);
    procedure PaintLineMarkerGlyph(const CellRect: TRect; Marker: TCodeLineMarker);
    function FirstLineMarkerAny(Line: Integer): TCodeLineMarker;
    function MarkerBackgroundColor(Marker: TCodeLineMarker; const ThemeColors: TCodeEditorThemeColors): TColor;
    procedure PaintGutter;
    procedure PaintText;
    procedure PaintMinimap;
    procedure PaintStyledScrollBars;
    procedure PaintOccurrenceHighlightsLine(ALineIndex, Y: Integer; const LineText, Needle: string);
    procedure PaintSelectionLine(ALineIndex, Y: Integer; const LineText: string);
    procedure PaintMultipleCaretsLine(ALineIndex, Y: Integer);
    procedure PaintBracketMatchesLine(ALineIndex, Y: Integer; const OpenPos, ClosePos: TCodePosition);
    procedure PaintLineTokens(ALineIndex, X, Y: Integer; const LineText: string; ForcedColor: TColor);
    procedure PaintSelectedTextLine(ALineIndex, X, Y: Integer; const LineText: string);
    procedure CMFontChanged(var Message: TMessage); message CM_FONTCHANGED;
    procedure CMStyleChanged(var Message: TMessage); message CM_STYLECHANGED;
    procedure WMGetDlgCode(var Message: TWMGetDlgCode); message WM_GETDLGCODE;
    procedure WMHScroll(var Message: TWMHScroll); message WM_HSCROLL;
    procedure WMMouseWheel(var Message: TWMMouseWheel); message WM_MOUSEWHEEL;
    procedure WMPaste(var Message: TWMPaste); message WM_PASTE;
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
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
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
    procedure ExecuteCommand(Command: TCodeEditorCommand);
    procedure TriggerCompletion;
    procedure TriggerSignatureHelp;
    procedure TriggerTemplates;
    procedure InsertTemplate(Template: TCodeTemplate);
    function ActiveLanguageName: string;
    procedure ShowFind;
    procedure ShowReplace;
    procedure InsertText(const Value: string; AddUndo: Boolean = True);
    procedure CommentSelection;
    procedure UncommentSelection;
    procedure ToggleLineComment;
    procedure IndentSelection;
    procedure UnindentSelection;
    procedure ZoomIn;
    procedure ZoomOut;
    procedure ZoomReset;
    procedure AddNextSelectionOccurrence;
    procedure SelectAllSelectionOccurrences;
    procedure ClearMultipleSelections;
    procedure ToggleBreakpoint(Line: Integer);
    procedure AddBreakpoint(Line: Integer);
    procedure RemoveBreakpoint(Line: Integer);
    procedure ClearBreakpoints;
    function AddLineMarker(Line: Integer; Kind: TCodeLineMarkerKind): TCodeLineMarker;
    procedure RemoveLineMarker(Line: Integer; Kind: TCodeLineMarkerKind);
    procedure ClearLineMarkers;
    procedure ShowLine(Line: Integer);
    function HasBreakpoint(Line: Integer): Boolean;
    function BreakpointLines: TArray<Integer>;
    property CanUndoAction: Boolean read CanUndo;
    property CanRedoAction: Boolean read CanRedo;
    property Caret: TCodePosition read FCaret write SetCaret;
    property ExecutionLine: Integer read FExecutionLine write SetExecutionLine;
    property LeftColumn: Integer read FLeftColumn write SetLeftColumn;
    property SelectedText: string read GetSelectedText write SetSelectedText;
    property TopLine: Integer read FTopLine write SetTopLine;
  published
    property Align;
    property Anchors;
    property Color default clWindow;
    property CompletionProvider: TCustomCodeCompletionProvider read FCompletionProvider write SetCompletionProvider;
    property Font;
    property Highlighter: TCustomCodeHighlighter read FHighlighter write SetHighlighter;
    property Lines: TStrings read GetLines write SetLines;
    property LineMarkers: TCodeLineMarkers read FLineMarkers write SetLineMarkers;
    property Modified: Boolean read FModified write SetModified default False;
    property Options: TCodeEditorOptions read FOptions write SetOptions;
    property PopupMenu;
    property ReadOnly: Boolean read FReadOnly write SetReadOnly default False;
    property ScrollBars: System.UITypes.TScrollStyle read FScrollBars write SetScrollBars default ssBoth;
    property StyledScrollBars: Boolean read FStyledScrollBars write SetStyledScrollBars default True;
    property TemplateProvider: TCodeTemplateProvider read FTemplateProvider write SetTemplateProvider;
    property Theme: TCodeEditorThemeColors read FTheme write SetTheme;
    property ThemeMode: TCodeEditorThemeMode read FThemeMode write SetThemeMode default ctmVclStyle;
    property MaxUndo: Integer read FMaxUndo write FMaxUndo default 1024;
    property Zoom: Integer read FZoom write SetZoom default 100;
    property TabOrder;
    property TabStop default True;
    property OnCaretChange: TCodeEditorCaretChangeEvent read FOnCaretChange write FOnCaretChange;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
    property OnResolveTheme: TCodeEditorResolveThemeEvent read FOnResolveTheme write FOnResolveTheme;
    property Breakpoints: TCodeBreakpoints read FBreakpoints write SetBreakpoints;
    property OnBreakpointsChanged: TNotifyEvent read FOnBreakpointsChanged write FOnBreakpointsChanged;
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
    property OnSelectionChange: TCodeEditorSelectionChangeEvent read FOnSelectionChange write FOnSelectionChange;
    property OnZoomChanged: TNotifyEvent read FOnZoomChanged write FOnZoomChanged;
  end;

implementation

uses
  System.Character,
  System.Math,
  System.RegularExpressions,
  System.StrUtils,
  System.SysUtils,
  Vcl.Clipbrd,
  Vcl.Themes;

const
  MinGutterWidth = 42;
  BreakpointMarginWidth = 16;
  MinimapWidth = 192;
  MinimapGap = 4;
  MinimapLineHeight = 4;
  StyledScrollBarSize = 12;
  DefaultMaxPasteBytes = 64 * 1024 * 1024;
  MinZoomPercent = 25;
  MaxZoomPercent = 400;
  ZoomStepPercent = 10;

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
  FBracketMatching := True;
  FLineCommentPrefix := '//';
  FShowGutter := True;
  FShowMinimap := False;
  FMaxPasteBytes := DefaultMaxPasteBytes;
  FThemeSyntaxColors := True;
  FTabSize := 2;
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
    FBracketMatching := TCodeEditorOptions(Source).BracketMatching;
    FLineCommentPrefix := TCodeEditorOptions(Source).LineCommentPrefix;
    FShowGutter := TCodeEditorOptions(Source).ShowGutter;
    FShowMinimap := TCodeEditorOptions(Source).ShowMinimap;
    FMaxPasteBytes := TCodeEditorOptions(Source).MaxPasteBytes;
    FTabSize := TCodeEditorOptions(Source).TabSize;
    FThemeSyntaxColors := TCodeEditorOptions(Source).ThemeSyntaxColors;
    Changed;
  end
  else
    inherited;
end;

procedure TCodeEditorOptions.SetBracketMatching(Value: Boolean);
begin
  if FBracketMatching <> Value then
  begin
    FBracketMatching := Value;
    Changed;
  end;
end;

procedure TCodeEditorOptions.SetLineCommentPrefix(const Value: string);
begin
  if FLineCommentPrefix <> Value then
  begin
    FLineCommentPrefix := Value;
    Changed;
  end;
end;

procedure TCodeEditorOptions.SetShowGutter(Value: Boolean);
begin
  if FShowGutter <> Value then
  begin
    FShowGutter := Value;
    Changed;
  end;
end;

procedure TCodeEditorOptions.SetMaxPasteBytes(Value: Integer);
begin
  Value := Max(0, Value);
  if FMaxPasteBytes <> Value then
  begin
    FMaxPasteBytes := Value;
    Changed;
  end;
end;

procedure TCodeEditorOptions.SetShowMinimap(Value: Boolean);
begin
  if FShowMinimap <> Value then
  begin
    FShowMinimap := Value;
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

class function TCodePosition.Create(ALine, AColumn: Integer): TCodePosition;
begin
  Result.Line := ALine;
  Result.Column := AColumn;
end;

constructor TCodeLineMarker.Create(Collection: TCollection);
begin
  inherited Create(Collection);
  FLine := 1;
  FKind := lmkInfo;
  FBackground := clNone;
  FForeground := clNone;
end;

procedure TCodeLineMarker.SetBackground(Value: TColor);
begin
  if FBackground <> Value then
  begin
    FBackground := Value;
    Changed(False);
  end;
end;

procedure TCodeLineMarker.SetForeground(Value: TColor);
begin
  if FForeground <> Value then
  begin
    FForeground := Value;
    Changed(False);
  end;
end;

procedure TCodeLineMarker.SetKind(Value: TCodeLineMarkerKind);
begin
  if FKind <> Value then
  begin
    FKind := Value;
    Changed(False);
  end;
end;

procedure TCodeLineMarker.SetLine(Value: Integer);
begin
  if Value < 1 then
    Value := 1;
  if FLine <> Value then
  begin
    FLine := Value;
    Changed(False);
  end;
end;

procedure TCodeLineMarker.SetText(const Value: string);
begin
  if FText <> Value then
  begin
    FText := Value;
    Changed(False);
  end;
end;

function TCodeLineMarker.GetDisplayName: string;
begin
  Result := Format('Line %d', [FLine]);
end;

procedure TCodeLineMarker.Assign(Source: TPersistent);
begin
  if Source is TCodeLineMarker then
  begin
    Background := TCodeLineMarker(Source).Background;
    Foreground := TCodeLineMarker(Source).Foreground;
    Kind := TCodeLineMarker(Source).Kind;
    Line := TCodeLineMarker(Source).Line;
    Text := TCodeLineMarker(Source).Text;
  end
  else
    inherited;
end;

constructor TCodeLineMarkers.Create(AOwner: TPersistent);
begin
  inherited Create(AOwner, TCodeLineMarker);
end;

function TCodeLineMarkers.GetItem(Index: Integer): TCodeLineMarker;
begin
  Result := TCodeLineMarker(inherited Items[Index]);
end;

procedure TCodeLineMarkers.SetItem(Index: Integer; Value: TCodeLineMarker);
begin
  inherited Items[Index] := Value;
end;

procedure TCodeLineMarkers.Update(Item: TCollectionItem);
begin
  inherited;
  if GetOwner is TCodeEditor then
    TCodeEditor(GetOwner).LineMarkersChanged;
end;

function TCodeLineMarkers.IndexOfLine(ALine: Integer; Kind: TCodeLineMarkerKind): Integer;
var
  I: Integer;
begin
  for I := 0 to Count - 1 do
    if (Items[I].Line = ALine) and (Items[I].Kind = Kind) then
      Exit(I);
  Result := -1;
end;

function TCodeLineMarkers.ContainsLine(ALine: Integer; Kind: TCodeLineMarkerKind): Boolean;
begin
  Result := IndexOfLine(ALine, Kind) >= 0;
end;

function TCodeLineMarkers.AddLine(ALine: Integer; Kind: TCodeLineMarkerKind): TCodeLineMarker;
begin
  BeginUpdate;
  try
    Result := TCodeLineMarker(Add);
    Result.Line := ALine;
    Result.Kind := Kind;
  finally
    EndUpdate;
  end;
end;

procedure TCodeLineMarkers.RemoveLine(ALine: Integer; Kind: TCodeLineMarkerKind);
var
  Index: Integer;
begin
  Index := IndexOfLine(ALine, Kind);
  if Index >= 0 then
    Delete(Index);
end;

constructor TCodeBreakpoint.Create(Collection: TCollection);
begin
  inherited Create(Collection);
  FLine := 1;
end;

procedure TCodeBreakpoint.SetLine(Value: Integer);
begin
  if Value < 1 then
    Value := 1;
  if FLine <> Value then
  begin
    FLine := Value;
    Changed(False);
  end;
end;

function TCodeBreakpoint.GetDisplayName: string;
begin
  Result := Format('Line %d', [FLine]);
end;

procedure TCodeBreakpoint.Assign(Source: TPersistent);
begin
  if Source is TCodeBreakpoint then
    Line := TCodeBreakpoint(Source).Line
  else
    inherited;
end;

constructor TCodeBreakpoints.Create(AOwner: TPersistent);
begin
  inherited Create(AOwner, TCodeBreakpoint);
end;

function TCodeBreakpoints.GetItem(Index: Integer): TCodeBreakpoint;
begin
  Result := TCodeBreakpoint(inherited Items[Index]);
end;

procedure TCodeBreakpoints.SetItem(Index: Integer; Value: TCodeBreakpoint);
begin
  inherited Items[Index] := Value;
end;

procedure TCodeBreakpoints.Update(Item: TCollectionItem);
begin
  inherited;
  if GetOwner is TCodeEditor then
    TCodeEditor(GetOwner).BreakpointsChanged;
end;

function TCodeBreakpoints.IndexOfLine(ALine: Integer): Integer;
var
  I: Integer;
begin
  for I := 0 to Count - 1 do
    if Items[I].Line = ALine then
      Exit(I);
  Result := -1;
end;

function TCodeBreakpoints.ContainsLine(ALine: Integer): Boolean;
begin
  Result := IndexOfLine(ALine) >= 0;
end;

function TCodeBreakpoints.AddLine(ALine: Integer): TCodeBreakpoint;
begin
  BeginUpdate;
  try
    Result := TCodeBreakpoint(Add);
    Result.Line := ALine;
  finally
    EndUpdate;
  end;
end;

procedure TCodeBreakpoints.RemoveLine(ALine: Integer);
var
  Index: Integer;
begin
  Index := IndexOfLine(ALine);
  if Index >= 0 then
    Delete(Index);
end;

function TCodeBreakpoints.SortedLines: TArray<Integer>;

  function Contains(const Arr: TArray<Integer>; UpTo, Value: Integer): Boolean;
  var
    K: Integer;
  begin
    for K := 0 to UpTo - 1 do
      if Arr[K] = Value then
        Exit(True);
    Result := False;
  end;

var
  I, J, Tmp, N, Line: Integer;
begin
  SetLength(Result, Count);
  N := 0;
  for I := 0 to Count - 1 do
  begin
    Line := Items[I].Line;
    if Line < 1 then
      Continue;
    if Contains(Result, N, Line) then
      Continue;
    Result[N] := Line;
    Inc(N);
  end;
  SetLength(Result, N);

  // Insertion sort — breakpoint lists are small.
  for I := 1 to High(Result) do
  begin
    Tmp := Result[I];
    J := I - 1;
    while (J >= 0) and (Result[J] > Tmp) do
    begin
      Result[J + 1] := Result[J];
      Dec(J);
    end;
    Result[J + 1] := Tmp;
  end;
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
  FSelections := TList<TCodeSelectionRange>.Create;
  FSearchIndex := -1;
  FBreakpoints := TCodeBreakpoints.Create(Self);
  FLineMarkers := TCodeLineMarkers.Create(Self);
  FLineTokenCache := TDictionary<Integer, TCodeLineTokensEntry>.Create;
  FExecutionLine := -1;
  FDesiredColumn := -1;
  FZoom := 100;
  FMaxUndo := 1024;
  FModified := False;
  FReadOnly := False;
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
  // Cancel rather than finish: committing would touch FBreakpoints/FLineMarkers,
  // and there is no point keeping an undo entry during destruction.
  CancelUndoGroup;
  HideCompletion;
  HideSignatureHelp;
  HideTemplates;
  FCompletionForm.Free;
  FCompletionItems.Free;
  FSignatureItems.Free;
  FSignatureForm.Free;
  FTemplateForm.Free;
  FTemplateMatches.Free;
  FSearchMatches.Free;
  FSelections.Free;
  FBreakpoints.Free;
  FLineMarkers.Free;
  FLineTokenCache.Free;
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
  Info: TScrollInfo;
begin
  inherited;
  NewLeft := FLeftColumn;
  case Message.ScrollCode of
    SB_LINELEFT: Dec(NewLeft);
    SB_LINERIGHT: Inc(NewLeft);
    SB_PAGELEFT: Dec(NewLeft, VisibleColumnCount);
    SB_PAGERIGHT: Inc(NewLeft, VisibleColumnCount);
    SB_THUMBPOSITION, SB_THUMBTRACK:
      begin
        // Message.Pos is 16-bit; SIF_TRACKPOS gives the full 32-bit position.
        FillChar(Info, SizeOf(Info), 0);
        Info.cbSize := SizeOf(Info);
        Info.fMask := SIF_TRACKPOS;
        if GetScrollInfo(Handle, SB_HORZ, Info) then
          NewLeft := Info.nTrackPos
        else
          NewLeft := Message.Pos;
      end;
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

function TCodeEditor.WindowInPopups(Wnd: HWND): Boolean;

  function InForm(Form: TForm): Boolean;
  begin
    Result := Assigned(Form) and Form.HandleAllocated and
      ((Wnd = Form.Handle) or IsChild(Form.Handle, Wnd));
  end;

begin
  Result := InForm(FCompletionForm) or InForm(FSignatureForm) or InForm(FTemplateForm);
end;

procedure TCodeEditor.WMKillFocus(var Message: TWMKillFocus);
begin
  HideCaret(Handle);
  if not WindowInPopups(Message.FocusedWnd) then
  begin
    HideCompletion;
    HideSignatureHelp;
    HideTemplates;
  end;
  inherited;
end;

procedure TCodeEditor.WMPaste(var Message: TWMPaste);
begin
  HideCompletion;
  HideSignatureHelp;
  HideTemplates;
  PasteFromClipboard;
  Message.Result := 0;
end;

procedure TCodeEditor.WMMouseWheel(var Message: TWMMouseWheel);
var
  DeltaLines: Integer;
  NewTop: Integer;
begin
  HideCompletion;
  HideSignatureHelp;
  HideTemplates;
  if (Message.Keys and MK_CONTROL) <> 0 then
  begin
    if Message.WheelDelta > 0 then
      ZoomIn
    else
      ZoomOut;
    Exit;
  end;
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
  Info: TScrollInfo;
begin
  inherited;
  NewTop := FTopLine;
  case Message.ScrollCode of
    SB_LINEUP: Dec(NewTop);
    SB_LINEDOWN: Inc(NewTop);
    SB_PAGEUP: Dec(NewTop, VisibleLineCount);
    SB_PAGEDOWN: Inc(NewTop, VisibleLineCount);
    SB_THUMBPOSITION, SB_THUMBTRACK:
      begin
        // Message.Pos is 16-bit; SIF_TRACKPOS gives the full 32-bit position.
        FillChar(Info, SizeOf(Info), 0);
        Info.cbSize := SizeOf(Info);
        Info.fMask := SIF_TRACKPOS;
        if GetScrollInfo(Handle, SB_VERT, Info) then
          NewTop := Info.nTrackPos
        else
          NewTop := Message.Pos;
      end;
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
begin
  MeasureBitmap := Vcl.Graphics.TBitmap.Create;
  MeasureCanvas := MeasureBitmap.Canvas;
  try
    MeasureCanvas.Font.Assign(Font);
    MeasureCanvas.Font.Size := ScaledFontSize;
    FLineHeight := Max(1, MeasureCanvas.TextHeight('Wg') + 2);
    FCharWidth := Max(1, MeasureCanvas.TextWidth('M'));
  finally
    MeasureBitmap.Free;
  end;
  UpdateGutterWidth;
end;

function TCodeEditor.ScaledFontSize: Integer;
begin
  Result := Max(1, MulDiv(Font.Size, FZoom, 100));
end;

procedure TCodeEditor.SetZoom(Value: Integer);
begin
  Value := EnsureRange(Value, MinZoomPercent, MaxZoomPercent);
  if Value = FZoom then
    Exit;

  FZoom := Value;
  UpdateMetrics;
  UpdateScrollBars;
  UpdateCaret;
  EnsureCaretVisible;  // visible line/column counts changed with the metrics
  Invalidate;
  if Assigned(FOnZoomChanged) then
    FOnZoomChanged(Self);
end;

procedure TCodeEditor.ZoomIn;
begin
  Zoom := FZoom + ZoomStepPercent;
end;

procedure TCodeEditor.ZoomOut;
begin
  Zoom := FZoom - ZoomStepPercent;
end;

procedure TCodeEditor.ZoomReset;
begin
  Zoom := 100;
end;

procedure TCodeEditor.UpdateGutterWidth;
var
  LineCount: Integer;
  ShowGutter: Boolean;
begin
  LineCount := 1;
  if Assigned(FLines) then
    LineCount := Max(1, FLines.Count);
  ShowGutter := not Assigned(FOptions) or FOptions.ShowGutter;
  FGutterWidth := IfThen(ShowGutter,
    Max(MinGutterWidth, FCharWidth * Length(IntToStr(LineCount)) + 18) + BreakpointMarginWidth, 0);
end;

procedure TCodeEditor.UpdateScrollBars;
var
  Info: TScrollInfo;
begin
  if not HandleAllocated then
    Exit;

  if FStyledScrollBars then
  begin
    ShowScrollBar(Handle, SB_VERT, False);
    ShowScrollBar(Handle, SB_HORZ, False);
    Exit;
  end;

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
  if MinimapVisible then
    Dec(Result.Right, MinimapWidth + MinimapGap);
  if StyledVerticalVisible then
    Dec(Result.Right, StyledScrollBarSize);
  if StyledHorizontalVisible then
    Dec(Result.Bottom, StyledScrollBarSize);
end;

function TCodeEditor.MinimapVisible: Boolean;
begin
  Result := Assigned(FOptions) and FOptions.ShowMinimap and (ClientWidth >= MinimapWidth + 40);
end;

function TCodeEditor.MinimapRect: TRect;
var
  RightReserve: Integer;
  BottomReserve: Integer;
begin
  Result := Rect(0, 0, 0, 0);
  if not MinimapVisible then
    Exit;

  RightReserve := 0;
  if StyledVerticalVisible then
    RightReserve := StyledScrollBarSize;
  BottomReserve := 0;
  if StyledHorizontalVisible then
    BottomReserve := StyledScrollBarSize;

  Result := Rect(ClientWidth - RightReserve - MinimapWidth, 0,
    ClientWidth - RightReserve, ClientHeight - BottomReserve);
end;

function TCodeEditor.MinimapContentHeight: Integer;
begin
  Result := Max(1, FLines.Count) * MinimapLineHeight;
end;

function TCodeEditor.MinimapScrollOffset: Integer;
var
  R: TRect;
  MaxOffset: Integer;
  MaxTopLine: Integer;
begin
  R := MinimapRect;
  MaxOffset := Max(0, MinimapContentHeight - R.Height);
  if MaxOffset = 0 then
    Exit(0);

  MaxTopLine := Max(1, FLines.Count - VisibleLineCount);
  Result := MulDiv(EnsureRange(FTopLine, 0, MaxTopLine), MaxOffset, MaxTopLine);
end;

function TCodeEditor.MinimapViewportRect: TRect;
var
  R: TRect;
  ScrollOffset: Integer;
  ViewHeight: Integer;
begin
  R := MinimapRect;
  Result := R;
  if (R.Height <= 0) or (FLines.Count <= 0) then
    Exit;

  ScrollOffset := MinimapScrollOffset;
  ViewHeight := Max(8, VisibleLineCount * MinimapLineHeight);
  ViewHeight := Min(ViewHeight, R.Height);
  Result.Top := R.Top + FTopLine * MinimapLineHeight - ScrollOffset;
  Result.Top := EnsureRange(Result.Top, R.Top, Max(R.Top, R.Bottom - ViewHeight));
  Result.Bottom := Result.Top + ViewHeight;
end;

procedure TCodeEditor.ScrollMinimapTo(Y: Integer);
var
  R: TRect;
  ScrollOffset: Integer;
  TargetLine: Integer;
  MaxTopLine: Integer;
begin
  R := MinimapRect;
  if R.Height <= 0 then
    Exit;

  ScrollOffset := MinimapScrollOffset;
  TargetLine := (ScrollOffset + EnsureRange(Y - R.Top, 0, R.Height)) div MinimapLineHeight;
  FTopLine := TargetLine - VisibleLineCount div 2;
  MaxTopLine := Max(0, FLines.Count - VisibleLineCount);
  FTopLine := EnsureRange(FTopLine, 0, MaxTopLine);
  UpdateScrollBars;
  UpdateCaret;
  Invalidate;
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
  if not FMaxLineLengthValid then
  begin
    FMaxLineLength := 0;
    for Line in FLines do
      if Length(Line) > FMaxLineLength then
        FMaxLineLength := Length(Line);
    FMaxLineLengthValid := True;
  end;
  Result := FMaxLineLength;
end;

function TCodeEditor.StyledVerticalScrollRect: TRect;
var
  BottomReserve: Integer;
begin
  BottomReserve := 0;
  if StyledHorizontalVisible then
    BottomReserve := StyledScrollBarSize;
  Result := Rect(ClientWidth - StyledScrollBarSize, 0, ClientWidth, ClientHeight - BottomReserve);
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
    Inc(RightReserve, StyledScrollBarSize);
  if MinimapVisible then
    Inc(RightReserve, MinimapWidth + MinimapGap);
  Result := Rect(0, ClientHeight - StyledScrollBarSize, ClientWidth - RightReserve, ClientHeight);
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

procedure TCodeEditor.EnsureLineStates(UpToLine: Integer);
var
  I: Integer;
  State: Integer;
  Entry: TCodeLineTokensEntry;
begin
  if not Assigned(FHighlighter) then
    Exit;

  UpToLine := Min(UpToLine, FLines.Count - 1);
  if FStateChainValid > UpToLine then
    Exit;

  // Resume from the last verified line. Lines whose text and incoming state
  // are unchanged reuse their cached tokens, so revalidation after an edit
  // only re-tokenizes the changed lines plus any lines whose state flipped.
  State := 0;
  if (FStateChainValid > 0) and FLineTokenCache.TryGetValue(FStateChainValid - 1, Entry) then
    State := Entry.EndState;

  for I := FStateChainValid to UpToLine do
  begin
    if FLineTokenCache.TryGetValue(I, Entry) and (Entry.Text = FLines[I]) and
      (Entry.StartState = State) then
      State := Entry.EndState
    else
    begin
      Entry.Text := FLines[I];
      Entry.StartState := State;
      Entry.Tokens := FHighlighter.TokenizeLineState(Entry.Text, State, Entry.EndState);
      FLineTokenCache.AddOrSetValue(I, Entry);
      State := Entry.EndState;
    end;
  end;
  FStateChainValid := UpToLine + 1;
end;

function TCodeEditor.LineTokens(ALineIndex: Integer): TCodeTokenArray;
var
  Entry: TCodeLineTokensEntry;
begin
  if not Assigned(FHighlighter) or (ALineIndex < 0) or (ALineIndex >= FLines.Count) then
    Exit(nil);

  EnsureLineStates(ALineIndex);
  if FLineTokenCache.TryGetValue(ALineIndex, Entry) then
    Result := Entry.Tokens
  else
    Result := nil;
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

function IsWordChar(Ch: Char): Boolean;
begin
  Result := Ch.IsLetterOrDigit or (Ch = '_');
end;

// Maps a 1-based marker line through an insertion (Delta > 0) or deletion
// (Delta < 0) of Abs(Delta) lines after AfterLine. Lines inside a deleted
// region collapse onto AfterLine.
function RemapLineAfterEdit(L, AfterLine, Delta: Integer): Integer;
begin
  Result := L;
  if L <= AfterLine then
    Exit;
  if Delta >= 0 then
    Result := L + Delta
  else if L <= AfterLine - Delta then
    Result := AfterLine
  else
    Result := L + Delta;
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

function TCodeEditor.RangeStart(const Range: TCodeSelectionRange): TCodePosition;
begin
  if ComparePositions(Range.Caret, Range.Anchor) <= 0 then
    Result := Range.Caret
  else
    Result := Range.Anchor;
end;

function TCodeEditor.RangeEnd(const Range: TCodeSelectionRange): TCodePosition;
begin
  if ComparePositions(Range.Caret, Range.Anchor) >= 0 then
    Result := Range.Caret
  else
    Result := Range.Anchor;
end;

function TCodeEditor.HasMultipleSelections: Boolean;
begin
  Result := Assigned(FSelections) and (FSelections.Count > 0);
end;

function TCodeEditor.SelectedLineStart: Integer;
begin
  if HasSelection then
    Result := SelectionStart.Line
  else
    Result := FCaret.Line;
end;

function TCodeEditor.SelectedLineEnd: Integer;
begin
  if HasSelection then
  begin
    Result := SelectionEnd.Line;
    if (SelectionEnd.Column = 0) and (Result > SelectionStart.Line) then
      Dec(Result);
  end
  else
    Result := FCaret.Line;
end;

function TCodeEditor.MatchingBracketPosition(out OpenPos, ClosePos: TCodePosition): Boolean;
const
  // Angle brackets are deliberately excluded: matching them in ordinary code
  // pairs every < comparison operator with an unrelated >.
  OpenBrackets = '([{';
  CloseBrackets = ')]}';
var
  Probe: TCodePosition;
  Ch: Char;
  PairIndex: Integer;
  Direction: Integer;
  Depth: Integer;
  LineIndex: Integer;
  Col: Integer;
  LineText: string;
  OpenCh: Char;
  CloseCh: Char;
begin
  Result := False;
  if not FOptions.BracketMatching then
    Exit;

  Probe := NormalizePosition(FCaret);
  Ch := #0;
  if Probe.Column > 0 then
  begin
    Ch := FLines[Probe.Line][Probe.Column];
    Dec(Probe.Column);
  end;
  if Pos(Ch, OpenBrackets + CloseBrackets) = 0 then
  begin
    Probe := NormalizePosition(FCaret);
    if Probe.Column < Length(FLines[Probe.Line]) then
      Ch := FLines[Probe.Line][Probe.Column + 1]
    else
      Exit;
  end;

  PairIndex := Pos(Ch, OpenBrackets);
  if PairIndex > 0 then
  begin
    Direction := 1;
    OpenCh := OpenBrackets[PairIndex];
    CloseCh := CloseBrackets[PairIndex];
    OpenPos := Probe;
  end
  else
  begin
    PairIndex := Pos(Ch, CloseBrackets);
    if PairIndex = 0 then
      Exit;
    Direction := -1;
    OpenCh := OpenBrackets[PairIndex];
    CloseCh := CloseBrackets[PairIndex];
    ClosePos := Probe;
  end;

  Depth := 0;
  LineIndex := Probe.Line;
  Col := Probe.Column + Direction;
  while (LineIndex >= 0) and (LineIndex < FLines.Count) do
  begin
    LineText := FLines[LineIndex];
    while (Col >= 0) and (Col < Length(LineText)) do
    begin
      Ch := LineText[Col + 1];
      if Ch = OpenCh then
      begin
        if Direction < 0 then
        begin
          if Depth = 0 then
          begin
            OpenPos := TCodePosition.Create(LineIndex, Col);
            Exit(True);
          end;
          Dec(Depth);
        end
        else
          Inc(Depth);
      end
      else if Ch = CloseCh then
      begin
        if Direction > 0 then
        begin
          if Depth = 0 then
          begin
            ClosePos := TCodePosition.Create(LineIndex, Col);
            Exit(True);
          end;
          Dec(Depth);
        end
        else
          Inc(Depth);
      end;
      Inc(Col, Direction);
    end;

    Inc(LineIndex, Direction);
    if (LineIndex < 0) or (LineIndex >= FLines.Count) then
      Break;
    if Direction > 0 then
      Col := 0
    else
      Col := Length(FLines[LineIndex]) - 1;
  end;
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

function TCodeEditor.SignatureVisible: Boolean;
begin
  Result := Assigned(FSignatureForm) and FSignatureForm.Visible;
end;

function TCodeEditor.SignatureFunctionName: string;
var
  LineText: string;
  Index: Integer;
  Depth: Integer;
begin
  Result := '';
  if (FCaret.Line < 0) or (FCaret.Line >= FLines.Count) then
    Exit;

  LineText := FLines[FCaret.Line];
  Index := EnsureRange(FCaret.Column, 0, Length(LineText));
  Depth := 0;
  while Index > 0 do
  begin
    if CharInSet(LineText[Index], [')', '>']) then
      Inc(Depth)
    else if CharInSet(LineText[Index], ['(', '<']) then
    begin
      if Depth = 0 then
      begin
        Dec(Index);
        while (Index > 0) and (LineText[Index].IsWhiteSpace) do
          Dec(Index);
        while (Index > 0) and (LineText[Index].IsLetterOrDigit or (LineText[Index] = '_') or
          (LineText[Index] = '.')) do
        begin
          Result := LineText[Index] + Result;
          Dec(Index);
        end;
        Exit;
      end;
      Dec(Depth);
    end;
    Dec(Index);
  end;
end;

function TCodeEditor.SignatureActiveParameter: Integer;
var
  LineText: string;
  Index: Integer;
  Depth: Integer;
begin
  Result := 0;
  if (FCaret.Line < 0) or (FCaret.Line >= FLines.Count) then
    Exit;

  LineText := FLines[FCaret.Line];
  Index := EnsureRange(FCaret.Column, 0, Length(LineText));
  Depth := 0;
  while Index > 0 do
  begin
    if CharInSet(LineText[Index], [')', '>']) then
      Inc(Depth)
    else if CharInSet(LineText[Index], ['(', '<']) then
    begin
      if Depth = 0 then
        Exit;
      Dec(Depth);
    end
    else if (LineText[Index] = ',') and (Depth = 0) then
      Inc(Result);
    Dec(Index);
  end;
end;

function TCodeEditor.SearchVisible: Boolean;
begin
  Result := Assigned(FSearchPanel) and FSearchPanel.Visible;
end;

function TCodeEditor.IsWholeWordMatch(const LineText: string; Column, MatchLength: Integer): Boolean;
var
  BeforeChar: Char;
  AfterChar: Char;
begin
  BeforeChar := #0;
  AfterChar := #0;
  if Column > 0 then
    BeforeChar := LineText[Column];
  if Column + MatchLength + 1 <= Length(LineText) then
    AfterChar := LineText[Column + MatchLength + 1];

  Result := not IsWordChar(BeforeChar) and not IsWordChar(AfterChar);
end;

function TCodeEditor.ClipboardTextBytes: UInt64;
var
  Data: THandle;
begin
  Result := 0;
  Clipboard.Open;
  try
    if Clipboard.HasFormat(CF_UNICODETEXT) then
    begin
      Data := Clipboard.GetAsHandle(CF_UNICODETEXT);
      if Data <> 0 then
        Exit(GlobalSize(Data));
    end;

    if Clipboard.HasFormat(CF_TEXT) then
    begin
      Data := Clipboard.GetAsHandle(CF_TEXT);
      if Data <> 0 then
        Exit(GlobalSize(Data));
    end;
  finally
    Clipboard.Close;
  end;
end;

function TCodeEditor.CanPasteFromClipboard: Boolean;
var
  Size: UInt64;
begin
  Result := Clipboard.HasFormat(CF_UNICODETEXT) or Clipboard.HasFormat(CF_TEXT);
  if not Result then
    Exit;

  if FOptions.MaxPasteBytes <= 0 then
    Exit(True);

  Size := ClipboardTextBytes;
  Result := (Size = 0) or (Size <= UInt64(FOptions.MaxPasteBytes));
  if not Result then
    MessageBeep(MB_ICONWARNING);
end;

function TCodeEditor.CurrentTextSnapshot: string;
begin
  Result := FLines.Text;
end;

function TCodeEditor.CaptureUndoState: TCodeUndoItem;
begin
  Result := TCodeUndoItem.Create;
  Result.BeforeText := CurrentTextSnapshot;
  Result.BeforeModified := FModified;
  Result.BeforeCaret := FCaret;
  Result.BeforeAnchor := FAnchor;
  Result.BeforeBreakpoints := BreakpointLines;
  Result.BeforeExecutionLine := FExecutionLine;
end;

procedure TCodeEditor.RestoreMarkers(const BreakpointLines: TArray<Integer>; ExecutionLine: Integer);
var
  Line: Integer;
begin
  FBreakpoints.BeginUpdate;
  try
    FBreakpoints.Clear;
    for Line in BreakpointLines do
      if (Line >= 1) and (Line <= FLines.Count) and not FBreakpoints.ContainsLine(Line) then
        FBreakpoints.AddLine(Line);
  finally
    FBreakpoints.EndUpdate;
  end;

  if (ExecutionLine >= 1) and (ExecutionLine <= FLines.Count) then
    FExecutionLine := ExecutionLine
  else
    FExecutionLine := -1;
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

procedure TCodeEditor.RestoreUndoState(const Text: string; const Caret, Anchor: TCodePosition;
  const BreakpointLines: TArray<Integer>; ExecutionLine: Integer);
begin
  FApplyingUndo := True;
  try
    FLines.Text := Text;
    if FLines.Count = 0 then
      FLines.Add('');
    RestoreMarkers(BreakpointLines, ExecutionLine);
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
  Item.AfterBreakpoints := BreakpointLines;
  Item.AfterExecutionLine := FExecutionLine;

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

procedure TCodeEditor.DoCaretChange;
begin
  if Assigned(FOnCaretChange) then
    FOnCaretChange(Self, FCaret);
end;

procedure TCodeEditor.DoSelectionChange;
begin
  if Assigned(FOnSelectionChange) then
    FOnSelectionChange(Self, SelectionStart, SelectionEnd);
end;

procedure TCodeEditor.DoEditStateChanged;
begin
  FModified := True;
end;

function TCodeEditor.CanContinueTypingUndo(const Value: string): Boolean;
begin
  Result := Assigned(FActiveUndoItem) and
    (FActiveUndoGroup = ugTyping) and
    (Length(Value) = 1) and
    not HasMultipleSelections and
    not HasSelection and
    (FCaret.Line = FActiveUndoItem.AfterCaret.Line) and
    (FCaret.Column = FActiveUndoItem.AfterCaret.Column) and
    (FAnchor.Line = FCaret.Line) and
    (FAnchor.Column = FCaret.Column);
end;

procedure TCodeEditor.InsertTypedText(const Value: string);
begin
  if FReadOnly then
  begin
    MessageBeep(MB_ICONWARNING);
    Exit;
  end;

  if HasMultipleSelections then
  begin
    FinishUndoGroup;
    ReplaceAllSelections(Value);
    Exit;
  end;

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

procedure TCodeEditor.PasteFromClipboard;
var
  Text: string;
begin
  if FReadOnly then
  begin
    MessageBeep(MB_ICONWARNING);
    Exit;
  end;

  if not CanPasteFromClipboard then
    Exit;

  Text := Clipboard.AsText;
  if Text = '' then
    Exit;

  FinishUndoGroup;
  InsertText(Text);
end;

procedure TCodeEditor.CopyToClipboard;
begin
  // Don't clobber the clipboard when there is nothing selected.
  if HasSelection then
    Clipboard.AsText := SelectedText;
end;

procedure TCodeEditor.CutToClipboard;
var
  UndoItem: TCodeUndoItem;
begin
  if not HasSelection then
    Exit;

  Clipboard.AsText := SelectedText;
  if FReadOnly then
    Exit;

  if HasMultipleSelections then
  begin
    ReplaceAllSelections('');
    Exit;
  end;

  FinishUndoGroup;
  UndoItem := CaptureUndoState;
  DeleteSelection;
  LinesChanged(Self);
  CommitUndoState(UndoItem);
end;

procedure TCodeEditor.Undo;
var
  Item: TCodeUndoItem;
begin
  FinishUndoGroup;
  if not CanUndo then
    Exit;

  Item := FUndoStack.Pop;
  RestoreUndoState(Item.BeforeText, Item.BeforeCaret, Item.BeforeAnchor,
    Item.BeforeBreakpoints, Item.BeforeExecutionLine);
  // Undoing back to the pre-edit state restores the pre-edit Modified flag.
  FModified := Item.BeforeModified;
  Change;
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
  RestoreUndoState(Item.AfterText, Item.AfterCaret, Item.AfterAnchor,
    Item.AfterBreakpoints, Item.AfterExecutionLine);
  FModified := True;
  Change;
  PushUndoItem(FUndoStack, Item);
end;

procedure TCodeEditor.ClearUndo;
begin
  CancelUndoGroup;
  ClearUndoStack(FUndoStack);
  ClearUndoStack(FRedoStack);
end;

procedure TCodeEditor.ExecuteCommand(Command: TCodeEditorCommand);
begin
  case Command of
    eccUndo:
      Undo;
    eccRedo:
      Redo;
    eccCut:
      CutToClipboard;
    eccCopy:
      CopyToClipboard;
    eccPaste:
      PasteFromClipboard;
    eccSelectAll:
      SelectAll;
    eccFind:
      ShowFind;
    eccReplace:
      ShowReplace;
    eccToggleLineComment:
      ToggleLineComment;
    eccCommentSelection:
      CommentSelection;
    eccUncommentSelection:
      UncommentSelection;
    eccTriggerCompletion:
      TriggerCompletion;
    eccTriggerSignatureHelp:
      TriggerSignatureHelp;
    eccTriggerTemplates:
      TriggerTemplates;
  end;
end;

procedure TCodeEditor.CreateCompletionPopup;
begin
  if Assigned(FCompletionForm) then
    Exit;

  FCompletionForm := TForm.CreateNew(nil);
  FCompletionForm.BorderStyle := bsNone;
  FCompletionForm.BorderIcons := [];
  // pmExplicit keeps the popup above its owning form only, instead of the
  // process-wide topmost that fsStayOnTop would impose.
  FCompletionForm.PopupMode := pmExplicit;
  FCompletionForm.Position := poDesigned;
  FCompletionForm.Width := 560;
  FCompletionForm.Height := 320;

  FCompletionList := TListBox.Create(FCompletionForm);
  FCompletionList.Parent := FCompletionForm;
  FCompletionList.Align := alClient;
  FCompletionList.IntegralHeight := False;
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
  LineText: string;
  EndColumn: Integer;
begin
  if not Assigned(FCompletionProvider) then
    Exit;

  HideTemplates;

  Prefix := CompletionPrefix;
  FCompletionStart := FCaret;
  if TriggerChar = #0 then
    Dec(FCompletionStart.Column, Length(Prefix));
  FCompletionEnd := FCaret;

  if (FCaret.Line >= 0) and (FCaret.Line < FLines.Count) then
  begin
    LineText := FLines[FCaret.Line];
    EndColumn := EnsureRange(FCaret.Column, 0, Length(LineText));
    while (EndColumn < Length(LineText)) and
      (LineText[EndColumn + 1].IsLetterOrDigit or (LineText[EndColumn + 1] = '_')) do
      Inc(EndColumn);
    FCompletionEnd := TCodePosition.Create(FCaret.Line, EndColumn);
  end;

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
  FCompletionForm.PopupParent := GetParentForm(Self);
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
  LineText: string;
  StartPos: TCodePosition;
  EndPos: TCodePosition;
  UndoItem: TCodeUndoItem;
begin
  if not CompletionVisible or (FCompletionList.ItemIndex < 0) then
    Exit;

  Item := TCodeCompletionItem(FCompletionList.Items.Objects[FCompletionList.ItemIndex]);
  HideCompletion;

  StartPos := NormalizePosition(FCompletionStart);
  EndPos := NormalizePosition(FCompletionEnd);
  if (StartPos.Line <> EndPos.Line) or (StartPos.Line < 0) or (StartPos.Line >= FLines.Count) then
    Exit;

  FinishUndoGroup;
  UndoItem := CaptureUndoState;
  LineText := FLines[StartPos.Line];
  StartPos.Column := EnsureRange(StartPos.Column, 0, Length(LineText));
  EndPos.Column := EnsureRange(EndPos.Column, StartPos.Column, Length(LineText));
  FLines[StartPos.Line] := Copy(LineText, 1, StartPos.Column) + Item.InsertText +
    Copy(LineText, EndPos.Column + 1, MaxInt);
  FCaret := TCodePosition.Create(StartPos.Line, StartPos.Column + Length(Item.InsertText));
  FAnchor := FCaret;
  LinesChanged(Self);
  EnsureCaretVisible;
  CommitUndoState(UndoItem);
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

function TCodeEditor.ActiveLanguageName: string;
begin
  if Assigned(FHighlighter) then
    Result := FHighlighter.LanguageName
  else
    Result := '';
end;

function TCodeEditor.TemplatesVisible: Boolean;
begin
  Result := Assigned(FTemplateForm) and FTemplateForm.Visible;
end;

function TCodeEditor.TemplateDisplayText(Template: TCodeTemplate): string;
begin
  Result := Template.Name;
  if Template.Description <> '' then
    Result := Result + '    ' + Template.Description;
end;

procedure TCodeEditor.CreateTemplatePopup;
begin
  if Assigned(FTemplateForm) then
    Exit;

  FTemplateForm := TForm.CreateNew(nil);
  FTemplateForm.BorderStyle := bsNone;
  FTemplateForm.BorderIcons := [];
  // pmExplicit keeps the popup above its owning form only, instead of the
  // process-wide topmost that fsStayOnTop would impose.
  FTemplateForm.PopupMode := pmExplicit;
  FTemplateForm.Position := poDesigned;
  FTemplateForm.Width := 480;
  FTemplateForm.Height := 280;

  FTemplateList := TListBox.Create(FTemplateForm);
  FTemplateList.Parent := FTemplateForm;
  FTemplateList.Align := alClient;
  FTemplateList.IntegralHeight := False;
  FTemplateList.OnClick := CompletionListClick;
  FTemplateList.OnDblClick := TemplateListDblClick;
end;

procedure TCodeEditor.PopulateTemplatePopup;
var
  Template: TCodeTemplate;
begin
  FTemplateList.Items.BeginUpdate;
  try
    FTemplateList.Clear;
    for Template in FTemplateMatches do
      FTemplateList.Items.AddObject(TemplateDisplayText(Template), Template);
    if FTemplateList.Items.Count > 0 then
      FTemplateList.ItemIndex := 0;
  finally
    FTemplateList.Items.EndUpdate;
  end;
end;

procedure TCodeEditor.ShowTemplates(ExplicitRequest: Boolean);
var
  Prefix: string;
  P: TPoint;
  PopupHeight: Integer;
begin
  if FReadOnly or not Assigned(FTemplateProvider) then
    Exit;

  HideCompletion;
  HideSignatureHelp;

  Prefix := CompletionPrefix;
  FTemplateStart := FCaret;
  Dec(FTemplateStart.Column, Length(Prefix));
  FTemplateEnd := FCaret;

  if not Assigned(FTemplateMatches) then
    FTemplateMatches := TList<TCodeTemplate>.Create;
  FTemplateMatches.Clear;
  FTemplateProvider.GetTemplates(ActiveLanguageName, Prefix, FTemplateMatches);

  if (FTemplateMatches.Count = 0) and (Prefix <> '') and ExplicitRequest then
  begin
    // Nothing starts with the word at the caret: offer the full list and
    // leave the word alone.
    FTemplateStart := FCaret;
    FTemplateProvider.GetTemplates(ActiveLanguageName, '', FTemplateMatches);
  end;

  if FTemplateMatches.Count = 0 then
  begin
    HideTemplates;
    Exit;
  end;

  if ExplicitRequest and (Prefix <> '') and (FTemplateMatches.Count = 1) and
    (FTemplateStart.Column < FTemplateEnd.Column) then
  begin
    // Unique match for the typed word: expand it immediately, like the IDE.
    HideTemplates;
    InsertTemplateRange(FTemplateMatches[0], FTemplateStart, FTemplateEnd);
    Exit;
  end;

  CreateTemplatePopup;
  PopulateTemplatePopup;
  PopupHeight := FTemplateList.ItemHeight * Min(FTemplateMatches.Count, 12) + 8;
  FTemplateForm.PopupParent := GetParentForm(Self);
  P := ClientToScreen(CaretToPoint(FCaret));
  Inc(P.Y, FLineHeight);
  FTemplateForm.SetBounds(P.X, P.Y, FTemplateForm.Width, Max(PopupHeight, FTemplateList.ItemHeight + 8));
  FTemplateForm.Show;
  SetFocus;
end;

procedure TCodeEditor.HideTemplates;
begin
  if Assigned(FTemplateForm) then
    FTemplateForm.Hide;
end;

procedure TCodeEditor.AcceptTemplate;
var
  Template: TCodeTemplate;
begin
  if not TemplatesVisible or (FTemplateList.ItemIndex < 0) then
    Exit;

  Template := TCodeTemplate(FTemplateList.Items.Objects[FTemplateList.ItemIndex]);
  HideTemplates;
  InsertTemplateRange(Template, FTemplateStart, FTemplateEnd);
end;

procedure TCodeEditor.TemplateListDblClick(Sender: TObject);
begin
  AcceptTemplate;
end;

procedure TCodeEditor.MoveTemplateSelection(Delta: Integer);
var
  NewIndex: Integer;
begin
  if not TemplatesVisible or (FTemplateList.Items.Count = 0) then
    Exit;

  NewIndex := EnsureRange(FTemplateList.ItemIndex + Delta, 0, FTemplateList.Items.Count - 1);
  FTemplateList.ItemIndex := NewIndex;
end;

procedure TCodeEditor.InsertTemplateRange(Template: TCodeTemplate;
  const StartPos, EndPos: TCodePosition);
var
  UndoItem: TCodeUndoItem;
  SPos: TCodePosition;
  EPos: TCodePosition;
  LineText: string;
  Indent: string;
  Expanded: string;
  CaretLine: Integer;
  CaretColumn: Integer;
  HasCaret: Boolean;
  I: Integer;
begin
  if FReadOnly or not Assigned(Template) then
    Exit;

  SPos := NormalizePosition(StartPos);
  EPos := NormalizePosition(EndPos);

  FinishUndoGroup;
  UndoItem := CaptureUndoState;

  ClearExtraSelections;
  if ComparePositions(SPos, EPos) < 0 then
  begin
    // Consume the typed prefix the template was matched against.
    FAnchor := SPos;
    FCaret := EPos;
    DeleteSelection;
  end
  else
  begin
    FCaret := SPos;
    FAnchor := SPos;
  end;

  // Continuation lines inherit the current line's leading whitespace.
  LineText := FLines[FCaret.Line];
  Indent := '';
  I := 1;
  while (I <= Length(LineText)) and CharInSet(LineText[I], [' ', #9]) do
  begin
    Indent := Indent + LineText[I];
    Inc(I);
  end;

  Expanded := ExpandCodeTemplate(Template.Code.Text, Indent, CaretLine, CaretColumn, HasCaret);
  SPos := FCaret;
  InsertText(Expanded, False);

  if HasCaret then
  begin
    if CaretLine = 0 then
      FCaret := TCodePosition.Create(SPos.Line, SPos.Column + CaretColumn)
    else
      FCaret := TCodePosition.Create(SPos.Line + CaretLine, CaretColumn);
    FCaret := NormalizePosition(FCaret);
    FAnchor := FCaret;
    EnsureCaretVisible;
    Invalidate;
  end;

  CommitUndoState(UndoItem);
end;

procedure TCodeEditor.InsertTemplate(Template: TCodeTemplate);
begin
  if HasSelection then
    InsertTemplateRange(Template, SelectionStart, SelectionEnd)
  else
    InsertTemplateRange(Template, FCaret, FCaret);
end;

procedure TCodeEditor.TriggerTemplates;
begin
  FinishUndoGroup;
  ShowTemplates(True);
end;

procedure TCodeEditor.CreateSignaturePopup;
begin
  if Assigned(FSignatureForm) then
    Exit;

  FSignatureForm := TForm.CreateNew(nil);
  FSignatureForm.BorderStyle := bsNone;
  FSignatureForm.PopupMode := pmExplicit;
  FSignatureForm.Position := poDesigned;
  FSignatureForm.Width := 420;
  FSignatureForm.Height := 54;
  FSignatureForm.Color := $00303030;

  FSignatureLabel := TLabel.Create(FSignatureForm);
  FSignatureLabel.Parent := FSignatureForm;
  FSignatureLabel.Align := alClient;
  FSignatureLabel.AutoSize := False;
  FSignatureLabel.Layout := tlCenter;
  FSignatureLabel.WordWrap := True;
  FSignatureLabel.Font.Name := 'Segoe UI';
  FSignatureLabel.Font.Size := 10;
  FSignatureLabel.Font.Color := clWhite;
end;

procedure TCodeEditor.PopulateSignaturePopup;
var
  Item: TCodeSignatureItem;
  I: Integer;
  Text: string;
begin
  if not Assigned(FSignatureItems) or (FSignatureItems.Count = 0) then
    Exit;

  Item := FSignatureItems[0];
  Text := Item.Name + '(';
  for I := 0 to Item.Parameters.Count - 1 do
  begin
    if I > 0 then
      Text := Text + ', ';
    if I = FSignatureContext.ActiveParameter then
      Text := Text + '[' + Item.Parameters[I] + ']'
    else
      Text := Text + Item.Parameters[I];
  end;
  Text := Text + ')';
  if Item.Detail <> '' then
    Text := Text + sLineBreak + Item.Detail;
  FSignatureLabel.Caption := Text;
end;

procedure TCodeEditor.ShowSignatureHelp(TriggerChar: Char; ExplicitRequest: Boolean);
var
  P: TPoint;
begin
  if not Assigned(FCompletionProvider) then
    Exit;

  FreeAndNil(FSignatureItems);
  FSignatureItems := TCodeSignatureItems.Create(True);

  FSignatureContext.Line := FCaret.Line;
  FSignatureContext.Column := FCaret.Column;
  FSignatureContext.LineText := FLines[FCaret.Line];
  FSignatureContext.FunctionName := SignatureFunctionName;
  FSignatureContext.TriggerChar := TriggerChar;
  FSignatureContext.ActiveParameter := SignatureActiveParameter;
  FSignatureContext.ExplicitRequest := ExplicitRequest;

  if FSignatureContext.FunctionName = '' then
  begin
    HideSignatureHelp;
    Exit;
  end;

  FCompletionProvider.GetSignatureHelp(FSignatureContext, FSignatureItems);
  if FSignatureItems.Count = 0 then
  begin
    HideSignatureHelp;
    Exit;
  end;

  CreateSignaturePopup;
  PopulateSignaturePopup;
  FSignatureForm.PopupParent := GetParentForm(Self);
  P := ClientToScreen(CaretToPoint(FCaret));
  Inc(P.Y, FLineHeight + 4);
  FSignatureForm.SetBounds(P.X, P.Y, FSignatureForm.Width, FSignatureForm.Height);
  FSignatureForm.Show;
  SetFocus;
end;

procedure TCodeEditor.UpdateSignatureHelp(TriggerChar: Char);
begin
  if SignatureVisible then
    ShowSignatureHelp(TriggerChar, False);
end;

procedure TCodeEditor.HideSignatureHelp;
begin
  if Assigned(FSignatureForm) then
    FSignatureForm.Hide;
end;

procedure TCodeEditor.TriggerCompletion;
begin
  FinishUndoGroup;
  ShowCompletion(#0, True);
end;

procedure TCodeEditor.TriggerSignatureHelp;
begin
  ShowSignatureHelp(#0, True);
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
  BoundsRect: TRect;
  AvailableWidth: Integer;
begin
  if not Assigned(FSearchPanel) then
    Exit;

  BoundsRect := ClientTextRect;
  AvailableWidth := Max(260, BoundsRect.Right - BoundsRect.Left - 20);
  PanelWidth := EnsureRange(AvailableWidth, 420, 760);
  FSearchPanel.Width := PanelWidth;
  FSearchPanel.Height := IfThen(FSearchExpanded, 96, 54);
  FSearchPanel.Left := Max(BoundsRect.Left, BoundsRect.Right - FSearchPanel.Width - 10);
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
  Haystack: string;
  SearchText: string;
  Needle: string;
  MatchCase: Boolean;
  WholeWord: Boolean;
  FoundAt: Integer;
  Offset: Integer;
  Options: TRegExOptions;
  Matches: TMatchCollection;
  Match: TMatch;
  SearchMatch: TCodeSearchMatch;
begin
  if not Assigned(FSearchMatches) or FSearchUpdating then
    Exit;

  FSearchUpdating := True;
  try
    FSearchMatches.Clear;
    FSearchIndex := -1;
    SearchText := FSearchEdit.Text;
    if SearchText = '' then
    begin
      FSearchStatusLabel.Caption := 'No results';
      Invalidate;
      Exit;
    end;

    MatchCase := FSearchMatchCaseButton.Down;
    WholeWord := FSearchWholeWordButton.Down;
    if MatchCase then
      Needle := SearchText
    else
      Needle := LowerCase(SearchText);

    for LineIndex := 0 to FLines.Count - 1 do
    begin
      SourceLine := FLines[LineIndex];
      if FSearchRegexButton.Down then
      begin
        Options := [];
        if not MatchCase then
          Include(Options, roIgnoreCase);
        try
          Matches := TRegEx.Matches(SourceLine, SearchText, Options);
          for Match in Matches do
            if Match.Length > 0 then
            begin
              // TMatch.Index is 1-based; stored columns are 0-based.
              if WholeWord and not IsWholeWordMatch(SourceLine, Match.Index - 1, Match.Length) then
                Continue;
              SearchMatch.Line := LineIndex;
              SearchMatch.Column := Match.Index - 1;
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
        if MatchCase then
          Haystack := SourceLine
        else
          Haystack := LowerCase(SourceLine);
        Offset := 1;
        repeat
          FoundAt := PosEx(Needle, Haystack, Offset);
          if FoundAt = 0 then
            Break;
          if not WholeWord or IsWholeWordMatch(SourceLine, FoundAt - 1, Length(Needle)) then
          begin
            SearchMatch.Line := LineIndex;
            SearchMatch.Column := FoundAt - 1;
            SearchMatch.Length := Length(Needle);
            FSearchMatches.Add(SearchMatch);
          end;
          Offset := FoundAt + Length(Needle);
        until Offset > Length(Haystack);
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
  finally
    FSearchUpdating := False;
  end;
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
var
  I: Integer;
begin
  if FSearchMatches.Count = 0 then
    Exit;

  SelectSearchMatch(FSearchIndex);
  SelectedText := FReplaceEdit.Text;  // LinesChanged refreshes FSearchMatches

  // Continue from the next match after the replacement instead of match #1.
  for I := 0 to FSearchMatches.Count - 1 do
    if (FSearchMatches[I].Line > FCaret.Line) or
      ((FSearchMatches[I].Line = FCaret.Line) and (FSearchMatches[I].Column >= FCaret.Column)) then
    begin
      SelectSearchMatch(I);
      Exit;
    end;
  if FSearchMatches.Count > 0 then
    SelectSearchMatch(0);
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
  FLines.BeginUpdate;
  try
    for I := FSearchMatches.Count - 1 downto 0 do
    begin
      Match := FSearchMatches[I];
      LineText := FLines[Match.Line];
      Delete(LineText, Match.Column + 1, Match.Length);
      Insert(FReplaceEdit.Text, LineText, Match.Column + 1);
      FLines[Match.Line] := LineText;
    end;
  finally
    FLines.EndUpdate;  // fires LinesChanged once, which re-runs the search
  end;
  CommitUndoState(UndoItem);
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
  if FReadOnly then
    Exit;

  if HasMultipleSelections then
  begin
    ReplaceAllSelections(Value);
    Exit;
  end;

  FinishUndoGroup;
  UndoItem := CaptureUndoState;
  DeleteSelection;
  InsertText(Value, False);
  CommitUndoState(UndoItem);
end;

procedure TCodeEditor.ClearExtraSelections;
begin
  if Assigned(FSelections) then
    FSelections.Clear;
end;

procedure TCodeEditor.AddSelectionRange(const Anchor, Caret: TCodePosition);
var
  Range: TCodeSelectionRange;
begin
  Range.Anchor := NormalizePosition(Anchor);
  Range.Caret := NormalizePosition(Caret);
  if ComparePositions(Range.Anchor, Range.Caret) <> 0 then
    FSelections.Add(Range);
end;

procedure TCodeEditor.AddNextSelectionOccurrence;
begin
  SelectNextOccurrence;
end;

procedure TCodeEditor.SelectAllSelectionOccurrences;
begin
  SelectAllOccurrences;
end;

procedure TCodeEditor.ClearMultipleSelections;
begin
  ClearExtraSelections;
  Invalidate;
  DoSelectionChange;
end;

procedure TCodeEditor.SelectNextOccurrence;
var
  Needle: string;
  StartPos: TCodePosition;
  LineIndex: Integer;
  FoundAt: Integer;
  SearchStart: Integer;
  ExistingEnd: TCodePosition;
begin
  if not HasSelection then
    SelectWordAtCaret;
  if not HasSelection then
    Exit;

  Needle := GetSelectedText;
  if Needle = '' then
    Exit;

  ExistingEnd := SelectionEnd;
  if HasMultipleSelections then
    ExistingEnd := RangeEnd(FSelections[FSelections.Count - 1]);

  StartPos := ExistingEnd;
  for LineIndex := StartPos.Line to FLines.Count - 1 do
  begin
    if LineIndex = StartPos.Line then
      SearchStart := StartPos.Column + 1
    else
      SearchStart := 1;
    FoundAt := PosEx(Needle, FLines[LineIndex], SearchStart);
    if FoundAt > 0 then
    begin
      AddSelectionRange(TCodePosition.Create(LineIndex, FoundAt - 1),
        TCodePosition.Create(LineIndex, FoundAt - 1 + Length(Needle)));
      Invalidate;
      Exit;
    end;
  end;
end;

procedure TCodeEditor.SelectAllOccurrences;
var
  Needle: string;
  LineIndex: Integer;
  FoundAt: Integer;
  SearchStart: Integer;
begin
  if not HasSelection then
    SelectWordAtCaret;
  if not HasSelection then
    Exit;

  Needle := GetSelectedText;
  ClearExtraSelections;
  for LineIndex := 0 to FLines.Count - 1 do
  begin
    SearchStart := 1;
    repeat
      FoundAt := PosEx(Needle, FLines[LineIndex], SearchStart);
      if FoundAt = 0 then
        Break;
      if not ((LineIndex = SelectionStart.Line) and (FoundAt - 1 = SelectionStart.Column)) then
        AddSelectionRange(TCodePosition.Create(LineIndex, FoundAt - 1),
          TCodePosition.Create(LineIndex, FoundAt - 1 + Length(Needle)));
      SearchStart := FoundAt + Max(1, Length(Needle));
    until SearchStart > Length(FLines[LineIndex]);
  end;
  Invalidate;
end;

procedure TCodeEditor.SetHighlighter(Value: TCustomCodeHighlighter);
begin
  if FHighlighter <> Value then
  begin
    FHighlighter := Value;
    FLineTokenCache.Clear;
    FStateChainValid := 0;
    if Assigned(FHighlighter) then
      FHighlighter.FreeNotification(Self);
    Invalidate;
  end;
end;

procedure TCodeEditor.SetCompletionProvider(Value: TCustomCodeCompletionProvider);
begin
  if FCompletionProvider <> Value then
  begin
    HideCompletion;
    FCompletionProvider := Value;
    if Assigned(FCompletionProvider) then
      FCompletionProvider.FreeNotification(Self);
  end;
end;

procedure TCodeEditor.SetTemplateProvider(Value: TCodeTemplateProvider);
begin
  if FTemplateProvider <> Value then
  begin
    HideTemplates;
    FTemplateProvider := Value;
    if Assigned(FTemplateProvider) then
      FTemplateProvider.FreeNotification(Self);
  end;
end;

procedure TCodeEditor.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited;
  if Operation = opRemove then
  begin
    if AComponent = FHighlighter then
    begin
      FHighlighter := nil;
      Invalidate;
    end;
    if AComponent = FCompletionProvider then
    begin
      HideCompletion;
      HideSignatureHelp;
      FCompletionProvider := nil;
    end;
    if AComponent = FTemplateProvider then
    begin
      HideTemplates;
      FTemplateProvider := nil;
    end;
  end;
end;

procedure TCodeEditor.SetLines(Value: TStrings);
begin
  FinishUndoGroup;
  ClearExtraSelections;
  FLines.Assign(Value);
  if FLines.Count = 0 then
    FLines.Add('');
  FCaret := NormalizePosition(FCaret);
  FAnchor := FCaret;
  ClearUndo;
  ClearBreakpoints;
  ClearLineMarkers;
  FExecutionLine := -1;
  LinesChanged(Self);
  FModified := False;
  DoCaretChange;
  DoSelectionChange;
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

procedure TCodeEditor.SetTopLine(Value: Integer);
begin
  Value := EnsureRange(Value, 0, Max(0, FLines.Count - VisibleLineCount));
  if FTopLine = Value then
    Exit;
  FTopLine := Value;
  UpdateScrollBars;
  UpdateCaret;
  Invalidate;
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

procedure TCodeEditor.SetCaret(Value: TCodePosition);
begin
  FinishUndoGroup;
  FDesiredColumn := -1;
  ClearExtraSelections;
  FCaret := NormalizePosition(Value);
  FAnchor := FCaret;
  EnsureCaretVisible;
  Invalidate;
  DoCaretChange;
  DoSelectionChange;
end;

procedure TCodeEditor.SetLeftColumn(Value: Integer);
begin
  Value := EnsureRange(Value, 0, Max(0, MaxLineLength - VisibleColumnCount + 1));
  if FLeftColumn = Value then
    Exit;
  FLeftColumn := Value;
  UpdateScrollBars;
  UpdateCaret;
  Invalidate;
end;

procedure TCodeEditor.SetModified(Value: Boolean);
begin
  FModified := Value;
end;

procedure TCodeEditor.SetReadOnly(Value: Boolean);
begin
  if FReadOnly <> Value then
    FReadOnly := Value;
end;

procedure TCodeEditor.LinesChanged(Sender: TObject);
begin
  FMaxLineLengthValid := False;
  FDesiredColumn := -1;
  // We don't know which line changed, so restart state validation from the
  // top; EnsureLineStates reuses cached entries, so this is cheap.
  FStateChainValid := 0;
  UpdateGutterWidth;
  UpdateScrollBars;
  if not FApplyingUndo then
  begin
    DoEditStateChanged;
    Change;
  end;
  if SearchVisible then
    UpdateSearch;  // keep match positions in sync with edits
  DoCaretChange;
  DoSelectionChange;
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
  if FReadOnly then
    Exit;

  FinishUndoGroup;
  ClearUndo;
  ClearExtraSelections;
  FLines.Text := '';
  if FLines.Count = 0 then
    FLines.Add('');
  FCaret := TCodePosition.Create(0, 0);
  FAnchor := FCaret;
  ClearBreakpoints;
  ClearLineMarkers;
  FExecutionLine := -1;
  LinesChanged(Self);
end;

procedure TCodeEditor.SelectAll;
begin
  FinishUndoGroup;
  ClearExtraSelections;
  FAnchor := TCodePosition.Create(0, 0);
  FCaret := TCodePosition.Create(FLines.Count - 1, Length(FLines[FLines.Count - 1]));
  EnsureCaretVisible;
  Invalidate;
  DoCaretChange;
  DoSelectionChange;
end;

procedure TCodeEditor.ShowLine(Line: Integer);
begin
  SetTopLine(Line);
end;

procedure TCodeEditor.CommentSelection;
var
  I: Integer;
  Prefix: string;
  UndoItem: TCodeUndoItem;
begin
  if FReadOnly then
    Exit;

  Prefix := FOptions.LineCommentPrefix;
  if Prefix = '' then
    Exit;

  FinishUndoGroup;
  UndoItem := CaptureUndoState;
  FLines.BeginUpdate;
  try
    for I := SelectedLineStart to SelectedLineEnd do
      FLines[I] := Prefix + FLines[I];
  finally
    FLines.EndUpdate;  // fires LinesChanged once
  end;
  CommitUndoState(UndoItem);
end;

procedure TCodeEditor.UncommentSelection;
var
  I: Integer;
  Prefix: string;
  P: Integer;
  LineText: string;
  UndoItem: TCodeUndoItem;
begin
  if FReadOnly then
    Exit;

  Prefix := FOptions.LineCommentPrefix;
  if Prefix = '' then
    Exit;

  FinishUndoGroup;
  UndoItem := CaptureUndoState;
  FLines.BeginUpdate;
  try
    for I := SelectedLineStart to SelectedLineEnd do
    begin
      LineText := FLines[I];
      P := Pos(Prefix, LineText);
      if P = 1 then
        Delete(LineText, 1, Length(Prefix))
      else if (P > 1) and (Trim(Copy(LineText, 1, P - 1)) = '') then
        Delete(LineText, P, Length(Prefix));
      FLines[I] := LineText;
    end;
  finally
    FLines.EndUpdate;  // fires LinesChanged once
  end;
  CommitUndoState(UndoItem);
end;

procedure TCodeEditor.ToggleLineComment;
var
  I: Integer;
  Prefix: string;
  AllCommented: Boolean;
  P: Integer;
begin
  Prefix := FOptions.LineCommentPrefix;
  if Prefix = '' then
    Exit;

  AllCommented := True;
  for I := SelectedLineStart to SelectedLineEnd do
  begin
    P := Pos(Prefix, FLines[I]);
    if not ((P = 1) or ((P > 1) and (Trim(Copy(FLines[I], 1, P - 1)) = ''))) then
    begin
      AllCommented := False;
      Break;
    end;
  end;

  if AllCommented then
    UncommentSelection
  else
    CommentSelection;
end;

procedure TCodeEditor.IndentSelection;
var
  I: Integer;
  Spaces: string;
  UndoItem: TCodeUndoItem;
begin
  if FReadOnly then
    Exit;

  Spaces := StringOfChar(' ', FOptions.TabSize);
  FinishUndoGroup;
  UndoItem := CaptureUndoState;
  FLines.BeginUpdate;
  try
    for I := SelectedLineStart to SelectedLineEnd do
      FLines[I] := Spaces + FLines[I];
    if (FCaret.Line >= SelectedLineStart) and (FCaret.Line <= SelectedLineEnd) and (FCaret.Column > 0) then
      Inc(FCaret.Column, Length(Spaces));
    if (FAnchor.Line >= SelectedLineStart) and (FAnchor.Line <= SelectedLineEnd) and (FAnchor.Column > 0) then
      Inc(FAnchor.Column, Length(Spaces));
  finally
    FLines.EndUpdate;
  end;
  CommitUndoState(UndoItem);
end;

procedure TCodeEditor.UnindentSelection;
var
  I: Integer;
  LineText: string;
  Removed: Integer;
  UndoItem: TCodeUndoItem;

  function LeadingSpacesToRemove(const S: string): Integer;
  begin
    Result := 0;
    while (Result < FOptions.TabSize) and (Result < Length(S)) and (S[Result + 1] = ' ') do
      Inc(Result);
  end;

begin
  if FReadOnly then
    Exit;

  FinishUndoGroup;
  UndoItem := CaptureUndoState;
  FLines.BeginUpdate;
  try
    for I := SelectedLineStart to SelectedLineEnd do
    begin
      LineText := FLines[I];
      Removed := LeadingSpacesToRemove(LineText);
      if Removed = 0 then
        Continue;
      Delete(LineText, 1, Removed);
      FLines[I] := LineText;
      if (FCaret.Line = I) and (FCaret.Column > 0) then
        FCaret.Column := Max(0, FCaret.Column - Removed);
      if (FAnchor.Line = I) and (FAnchor.Column > 0) then
        FAnchor.Column := Max(0, FAnchor.Column - Removed);
    end;
    FCaret := NormalizePosition(FCaret);
    FAnchor := NormalizePosition(FAnchor);
  finally
    FLines.EndUpdate;
  end;
  CommitUndoState(UndoItem);
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
  if EndPos.Line > StartPos.Line then
  begin
    ShiftBreakpoints(StartPos.Line + 1, -(EndPos.Line - StartPos.Line));
    ShiftLineMarkers(StartPos.Line + 1, -(EndPos.Line - StartPos.Line));
  end;
end;

procedure TCodeEditor.InsertTextAtRange(const StartPos, EndPos: TCodePosition; const Value: string;
  out NewCaret: TCodePosition);
var
  OldCaret: TCodePosition;
  OldAnchor: TCodePosition;
begin
  OldCaret := FCaret;
  OldAnchor := FAnchor;
  try
    FAnchor := StartPos;
    FCaret := EndPos;
    DeleteSelection;
    InsertText(Value, False);
    NewCaret := FCaret;
  finally
    FCaret := OldCaret;
    FAnchor := OldAnchor;
  end;
end;

function TCodeEditor.PositionBefore(const Position: TCodePosition): TCodePosition;
begin
  Result := NormalizePosition(Position);
  if Result.Column > 0 then
    Dec(Result.Column)
  else if Result.Line > 0 then
  begin
    Dec(Result.Line);
    Result.Column := Length(FLines[Result.Line]);
  end;
end;

function TCodeEditor.PositionAfter(const Position: TCodePosition): TCodePosition;
begin
  Result := NormalizePosition(Position);
  if Result.Column < Length(FLines[Result.Line]) then
    Inc(Result.Column)
  else if Result.Line < FLines.Count - 1 then
  begin
    Inc(Result.Line);
    Result.Column := 0;
  end;
end;

function TCodeEditor.CollectSelectionRanges: TArray<TCodeSelectionRange>;
var
  I: Integer;
begin
  SetLength(Result, FSelections.Count + 1);
  Result[0].Anchor := FAnchor;
  Result[0].Caret := FCaret;
  for I := 0 to FSelections.Count - 1 do
    Result[I + 1] := FSelections[I];
end;

procedure TCodeEditor.ApplyRangeEdits(var Ranges: TArray<TCodeSelectionRange>; const Value: string);
var
  NewCarets: TArray<TCodePosition>;
  Count: Integer;
  I, J: Integer;
  Tmp: TCodeSelectionRange;
  UndoItem: TCodeUndoItem;
  StartPos: TCodePosition;
  EndPos: TCodePosition;
  NewCaret: TCodePosition;

  procedure AdjustSavedCarets(const AEndPos, ANewCaret: TCodePosition; SavedCount: Integer);
  var
    K: Integer;
    DeltaLines: Integer;
    DeltaColumns: Integer;
  begin
    DeltaLines := ANewCaret.Line - AEndPos.Line;
    DeltaColumns := ANewCaret.Column - AEndPos.Column;

    for K := 0 to SavedCount - 1 do
    begin
      if ComparePositions(NewCarets[K], AEndPos) < 0 then
        Continue;

      if DeltaLines = 0 then
      begin
        if NewCarets[K].Line = AEndPos.Line then
          Inc(NewCarets[K].Column, DeltaColumns);
      end
      else
      begin
        if NewCarets[K].Line = AEndPos.Line then
          NewCarets[K] := TCodePosition.Create(ANewCaret.Line,
            ANewCaret.Column + (NewCarets[K].Column - AEndPos.Column))
        else
          Inc(NewCarets[K].Line, DeltaLines);
      end;
    end;
  end;

begin
  Count := Length(Ranges);
  if Count = 0 then
    Exit;
  SetLength(NewCarets, Count);

  // Process ranges from the end of the document backwards so earlier edits
  // don't shift the positions of ranges still to be applied.
  for I := 1 to Count - 1 do
  begin
    Tmp := Ranges[I];
    J := I - 1;
    while (J >= 0) and (ComparePositions(RangeStart(Ranges[J]), RangeStart(Tmp)) < 0) do
    begin
      Ranges[J + 1] := Ranges[J];
      Dec(J);
    end;
    Ranges[J + 1] := Tmp;
  end;

  FinishUndoGroup;
  UndoItem := CaptureUndoState;
  for I := 0 to Count - 1 do
  begin
    StartPos := RangeStart(Ranges[I]);
    EndPos := RangeEnd(Ranges[I]);
    InsertTextAtRange(StartPos, EndPos, Value, NewCaret);
    AdjustSavedCarets(EndPos, NewCaret, I);
    NewCarets[I] := NewCaret;
  end;

  FCaret := NewCarets[Count - 1];
  FAnchor := FCaret;
  ClearExtraSelections;
  for I := 0 to Count - 2 do
  begin
    Tmp.Anchor := NewCarets[I];
    Tmp.Caret := NewCarets[I];
    FSelections.Add(Tmp);
  end;
  EnsureCaretVisible;
  LinesChanged(Self);
  CommitUndoState(UndoItem);
end;

procedure TCodeEditor.ReplaceAllSelections(const Value: string);
var
  Ranges: TArray<TCodeSelectionRange>;
begin
  if FReadOnly then
    Exit;

  if not HasMultipleSelections and not HasSelection then
    Exit;

  Ranges := CollectSelectionRanges;
  ApplyRangeEdits(Ranges, Value);
end;

procedure TCodeEditor.DeleteAllSelections(DeletePrevious: Boolean);
var
  Ranges: TArray<TCodeSelectionRange>;
  I: Integer;
begin
  if FReadOnly then
    Exit;

  if not HasMultipleSelections and not HasSelection then
    Exit;

  Ranges := CollectSelectionRanges;
  // Empty ranges (bare carets) delete one character to the side instead.
  for I := 0 to High(Ranges) do
    if ComparePositions(Ranges[I].Anchor, Ranges[I].Caret) = 0 then
    begin
      if DeletePrevious then
        Ranges[I].Anchor := PositionBefore(Ranges[I].Caret)
      else
        Ranges[I].Caret := PositionAfter(Ranges[I].Anchor);
    end;
  ApplyRangeEdits(Ranges, '');
end;

procedure TCodeEditor.InsertText(const Value: string; AddUndo: Boolean);
var
  Parts: TStringList;
  Current: string;
  Normalized: string;
  StartIndex: Integer;
  Index: Integer;
  Tail: string;
  I: Integer;
  UndoItem: TCodeUndoItem;
begin
  if FReadOnly and AddUndo then
    Exit;

  if Value = '' then
    Exit;

  if AddUndo and HasMultipleSelections then
  begin
    ReplaceAllSelections(Value);
    Exit;
  end;

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
    for Index := 1 to Length(Normalized) do
      if Normalized[Index] = #10 then
      begin
        Parts.Add(Copy(Normalized, StartIndex, Index - StartIndex));
        StartIndex := Index + 1;
      end;
    Parts.Add(Copy(Normalized, StartIndex, MaxInt));

    Current := FLines[FCaret.Line];
    Tail := Copy(Current, FCaret.Column + 1, MaxInt);
    FLines[FCaret.Line] := Copy(Current, 1, FCaret.Column) + Parts[0];
    FCaret.Column := Length(FLines[FCaret.Line]);

    if Parts.Count > 1 then
    begin
      ShiftBreakpoints(FCaret.Line + 1, Parts.Count - 1);
      ShiftLineMarkers(FCaret.Line + 1, Parts.Count - 1);
    end;

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

function TCodeEditor.MovePositionForKey(const Position: TCodePosition; Key: Word): TCodePosition;
begin
  Result := Position;
  case Key of
    VK_LEFT:
      if Result.Column > 0 then
        Dec(Result.Column)
      else if Result.Line > 0 then
      begin
        Dec(Result.Line);
        Result.Column := Length(FLines[Result.Line]);
      end;
    VK_RIGHT:
      if Result.Column < Length(FLines[Result.Line]) then
        Inc(Result.Column)
      else if Result.Line < FLines.Count - 1 then
      begin
        Inc(Result.Line);
        Result.Column := 0;
      end;
    VK_UP:
      Dec(Result.Line);
    VK_DOWN:
      Inc(Result.Line);
    VK_HOME:
      Result.Column := 0;
    VK_END:
      Result.Column := Length(FLines[Result.Line]);
    VK_PRIOR:
      Dec(Result.Line, VisibleLineCount);
    VK_NEXT:
      Inc(Result.Line, VisibleLineCount);
  end;
  Result := NormalizePosition(Result);
end;

procedure TCodeEditor.MoveMultipleCarets(Key: Word; Shift: TShiftState);
var
  I: Integer;
  Range: TCodeSelectionRange;
begin
  FinishUndoGroup;
  for I := 0 to FSelections.Count - 1 do
  begin
    Range := FSelections[I];
    Range.Caret := MovePositionForKey(Range.Caret, Key);
    if not (ssShift in Shift) then
      Range.Anchor := Range.Caret;
    FSelections[I] := Range;
  end;

  FCaret := MovePositionForKey(FCaret, Key);
  if not (ssShift in Shift) then
    FAnchor := FCaret;
  EnsureCaretVisible;
  Invalidate;
  DoCaretChange;
  DoSelectionChange;
end;

procedure TCodeEditor.MoveCaret(const Position: TCodePosition; Shift: TShiftState;
  PreserveDesiredColumn: Boolean);
begin
  FinishUndoGroup;
  if not PreserveDesiredColumn then
    FDesiredColumn := -1;
  if not (ssShift in Shift) then
    ClearExtraSelections;
  FCaret := NormalizePosition(Position);
  if not (ssShift in Shift) then
    FAnchor := FCaret;
  EnsureCaretVisible;
  Invalidate;
  DoCaretChange;
  DoSelectionChange;
end;

procedure TCodeEditor.MoveCaretVertically(DeltaLines: Integer; Shift: TShiftState);
var
  Target: TCodePosition;
begin
  // Remember the column the user is aiming for so that passing through short
  // lines doesn't permanently snap the caret to their length.
  if FDesiredColumn < 0 then
    FDesiredColumn := FCaret.Column;
  Target.Line := FCaret.Line + DeltaLines;
  Target.Column := FDesiredColumn;
  MoveCaret(Target, Shift, True);
end;

function TCodeEditor.PrevWordPosition(const Position: TCodePosition): TCodePosition;
var
  LineText: string;
begin
  Result := NormalizePosition(Position);
  if Result.Column = 0 then
  begin
    if Result.Line > 0 then
    begin
      Dec(Result.Line);
      Result.Column := Length(FLines[Result.Line]);
    end;
    Exit;
  end;

  LineText := FLines[Result.Line];
  while (Result.Column > 0) and LineText[Result.Column].IsWhiteSpace do
    Dec(Result.Column);
  if (Result.Column > 0) and IsWordChar(LineText[Result.Column]) then
    while (Result.Column > 0) and IsWordChar(LineText[Result.Column]) do
      Dec(Result.Column)
  else
    while (Result.Column > 0) and not (LineText[Result.Column].IsWhiteSpace or
      IsWordChar(LineText[Result.Column])) do
      Dec(Result.Column);
end;

function TCodeEditor.NextWordPosition(const Position: TCodePosition): TCodePosition;
var
  LineText: string;
begin
  Result := NormalizePosition(Position);
  LineText := FLines[Result.Line];
  if Result.Column >= Length(LineText) then
  begin
    if Result.Line < FLines.Count - 1 then
    begin
      Inc(Result.Line);
      Result.Column := 0;
    end;
    Exit;
  end;

  if IsWordChar(LineText[Result.Column + 1]) then
    while (Result.Column < Length(LineText)) and IsWordChar(LineText[Result.Column + 1]) do
      Inc(Result.Column)
  else if not LineText[Result.Column + 1].IsWhiteSpace then
    while (Result.Column < Length(LineText)) and not (LineText[Result.Column + 1].IsWhiteSpace or
      IsWordChar(LineText[Result.Column + 1])) do
      Inc(Result.Column);
  while (Result.Column < Length(LineText)) and LineText[Result.Column + 1].IsWhiteSpace do
    Inc(Result.Column);
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
          HideSignatureHelp;
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

  if TemplatesVisible then
  begin
    case Key of
      VK_ESCAPE:
        begin
          HideTemplates;
          Key := 0;
          Exit;
        end;
      VK_UP:
        begin
          MoveTemplateSelection(-1);
          Key := 0;
          Exit;
        end;
      VK_DOWN:
        begin
          MoveTemplateSelection(1);
          Key := 0;
          Exit;
        end;
      VK_RETURN, VK_TAB:
        begin
          AcceptTemplate;
          FSuppressKeyPress := True;
          Key := 0;
          Exit;
        end;
    end;
  end;

  if HasMultipleSelections and not (ssCtrl in Shift) and not (ssAlt in Shift) and
    (Key in [VK_LEFT, VK_RIGHT, VK_UP, VK_DOWN, VK_HOME, VK_END, VK_PRIOR, VK_NEXT]) then
  begin
    MoveMultipleCarets(Key, Shift);
    Key := 0;
    Exit;
  end;

  case Key of
    VK_LEFT:
      if ssCtrl in Shift then
        MoveCaret(PrevWordPosition(FCaret), Shift)
      else if FCaret.Column > 0 then
        MoveCaret(TCodePosition.Create(FCaret.Line, FCaret.Column - 1), Shift)
      else if FCaret.Line > 0 then
        MoveCaret(TCodePosition.Create(FCaret.Line - 1, Length(FLines[FCaret.Line - 1])), Shift);
    VK_RIGHT:
      if ssCtrl in Shift then
        MoveCaret(NextWordPosition(FCaret), Shift)
      else if FCaret.Column < Length(FLines[FCaret.Line]) then
        MoveCaret(TCodePosition.Create(FCaret.Line, FCaret.Column + 1), Shift)
      else if FCaret.Line < FLines.Count - 1 then
        MoveCaret(TCodePosition.Create(FCaret.Line + 1, 0), Shift);
    VK_UP:
      MoveCaretVertically(-1, Shift);
    VK_DOWN:
      MoveCaretVertically(1, Shift);
    VK_HOME:
      if ssCtrl in Shift then
        MoveCaret(TCodePosition.Create(0, 0), Shift)
      else
        MoveCaret(TCodePosition.Create(FCaret.Line, 0), Shift);
    VK_END:
      if ssCtrl in Shift then
        MoveCaret(TCodePosition.Create(FLines.Count - 1, Length(FLines[FLines.Count - 1])), Shift)
      else
        MoveCaret(TCodePosition.Create(FCaret.Line, Length(FLines[FCaret.Line])), Shift);
    VK_PRIOR:
      MoveCaretVertically(-VisibleLineCount, Shift);
    VK_NEXT:
      MoveCaretVertically(VisibleLineCount, Shift);
    VK_TAB:
      if ssShift in Shift then
      begin
        UnindentSelection;
        FSuppressKeyPress := True;
        Key := 0;
      end;
    VK_DELETE:
      begin
        if FReadOnly then
        begin
          MessageBeep(MB_ICONWARNING);
          Key := 0;
          Exit;
        end;
        HideCompletion;
        HideSignatureHelp;
        HideTemplates;
        if HasMultipleSelections then
        begin
          DeleteAllSelections(False);
          Key := 0;
          Exit;
        end;
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
          ShiftBreakpoints(FCaret.Line + 1, -1);
          ShiftLineMarkers(FCaret.Line + 1, -1);
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
        CopyToClipboard;
        Key := 0;
      end;
    Ord('D'):
      if ssCtrl in Shift then
      begin
        AddNextSelectionOccurrence;
        Key := 0;
      end;
    Ord('L'):
      if (ssCtrl in Shift) and (ssShift in Shift) then
      begin
        SelectAllSelectionOccurrences;
        Key := 0;
      end;
    Ord('X'):
      if ssCtrl in Shift then
      begin
        CutToClipboard;
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
    Ord('J'):
      if Shift = [ssCtrl] then
      begin
        TriggerTemplates;
        // Ctrl+J arrives in KeyPress as the #10 control character.
        FSuppressKeyPress := True;
        Key := 0;
      end;
    Ord('V'):
      if ssCtrl in Shift then
      begin
        HideCompletion;
        HideSignatureHelp;
        HideTemplates;
        PasteFromClipboard;
        FSuppressKeyPress := True;
        Key := 0;
      end;
    VK_SPACE:
      if ssCtrl in Shift then
      begin
        if ssShift in Shift then
          TriggerSignatureHelp
        else
          TriggerCompletion;
        FSuppressKeyPress := True;
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
    VK_OEM_PLUS, VK_ADD:
      if ssCtrl in Shift then
      begin
        ZoomIn;
        Key := 0;
      end;
    VK_OEM_MINUS, VK_SUBTRACT:
      if ssCtrl in Shift then
      begin
        ZoomOut;
        Key := 0;
      end;
    Ord('0'), VK_NUMPAD0:
      if ssCtrl in Shift then
      begin
        ZoomReset;
        Key := 0;
      end;
    VK_F5, VK_F9:
      begin
        ToggleBreakpoint(FCaret.Line + 1);
        Key := 0;
      end;
    VK_ESCAPE:
      if HasMultipleSelections then
      begin
        ClearMultipleSelections;
        Key := 0;
      end
      else if SignatureVisible then
      begin
        HideSignatureHelp;
        Key := 0;
      end
      else if SearchVisible then
      begin
        HideSearchPanel;
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
    #22:
      begin
        HideCompletion;
        HideSignatureHelp;
        HideTemplates;
        PasteFromClipboard;
        Key := #0;
      end;
    #8:
      begin
        if FReadOnly then
        begin
          MessageBeep(MB_ICONWARNING);
          Key := #0;
          Exit;
        end;
        HideCompletion;
        HideTemplates;
        if HasMultipleSelections then
        begin
          DeleteAllSelections(True);
          Key := #0;
          Exit;
        end;
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
          ShiftBreakpoints(FCaret.Line, -1);
          ShiftLineMarkers(FCaret.Line, -1);
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
        if FReadOnly then
        begin
          MessageBeep(MB_ICONWARNING);
          Key := #0;
          Exit;
        end;
        HideCompletion;
        HideTemplates;
        FinishUndoGroup;
        if HasSelection and (SelectionStart.Line <> SelectionEnd.Line) then
          IndentSelection
        else
          InsertText(StringOfChar(' ', FOptions.TabSize));
        Key := #0;
      end;
    #13:
      begin
        if FReadOnly then
        begin
          MessageBeep(MB_ICONWARNING);
          Key := #0;
          Exit;
        end;
        HideCompletion;
        HideSignatureHelp;
        HideTemplates;
        FinishUndoGroup;
        InsertText(sLineBreak);
        Key := #0;
      end;
  else
    // Accept any printable character, including Unicode above #255 (IME,
    // non-Western keyboard layouts).
    if Key >= #32 then
    begin
      InsertTypedText(Key);
      if TemplatesVisible then
        // Keep narrowing the template list while the user types.
        ShowTemplates(False)
      else
      begin
        if CharInSet(Key, ['.', '(', '<']) then
        begin
          ShowCompletion(Key, False)
        end
        else if CompletionVisible then
          ShowCompletion(#0, False);
        if CharInSet(Key, ['(', '<']) then
          ShowSignatureHelp(Key, False)
        else if Key = ',' then
          UpdateSignatureHelp(Key);
      end;
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
    HideTemplates;
    if MinimapVisible and PtInRect(MinimapRect, Point(X, Y)) then
    begin
      FMinimapDragging := True;
      ScrollMinimapTo(Y);
      Exit;
    end;
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
    if FOptions.ShowGutter and (FGutterWidth > 0) and (X < BreakpointMarginWidth) then
    begin
      NewPos := LineAtPoint(Point(X, Y));
      if NewPos >= 0 then
        ToggleBreakpoint(NewPos + 1);
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

  if FMinimapDragging then
  begin
    ScrollMinimapTo(Y);
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
  FMinimapDragging := False;
end;

procedure TCodeEditor.SelectWordAtCaret;
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
  DoCaretChange;
  DoSelectionChange;
end;

function TCodeEditor.LineAtPoint(const Point: TPoint): Integer;
begin
  Result := FTopLine + (Point.Y div FLineHeight);
  if (Result < 0) or (Result >= FLines.Count) then
    Result := -1;
end;

procedure TCodeEditor.BreakpointsChanged;
begin
  if csDestroying in ComponentState then
    Exit;
  Invalidate;
  if csDesigning in ComponentState then
    Update;  // the form designer doesn't always honor a plain Invalidate
  if Assigned(FOnBreakpointsChanged) and not (csLoading in ComponentState) then
    FOnBreakpointsChanged(Self);
end;

function TCodeEditor.HasBreakpoint(Line: Integer): Boolean;
begin
  Result := FBreakpoints.ContainsLine(Line);
end;

procedure TCodeEditor.AddBreakpoint(Line: Integer);
begin
  if (Line < 1) or (Line > FLines.Count) then
    Exit;
  if FBreakpoints.ContainsLine(Line) then
    Exit;
  FBreakpoints.AddLine(Line);
end;

procedure TCodeEditor.RemoveBreakpoint(Line: Integer);
begin
  FBreakpoints.RemoveLine(Line);
end;

procedure TCodeEditor.ToggleBreakpoint(Line: Integer);
begin
  if (Line < 1) or (Line > FLines.Count) then
    Exit;
  if FBreakpoints.ContainsLine(Line) then
    RemoveBreakpoint(Line)
  else
    AddBreakpoint(Line);
end;

procedure TCodeEditor.ClearBreakpoints;
begin
  if FBreakpoints.Count = 0 then
    Exit;
  FBreakpoints.Clear;
end;

function TCodeEditor.BreakpointLines: TArray<Integer>;
begin
  Result := FBreakpoints.SortedLines;
end;

function TCodeEditor.AddLineMarker(Line: Integer; Kind: TCodeLineMarkerKind): TCodeLineMarker;
begin
  Result := nil;
  if (Line < 1) or (Line > FLines.Count) then
    Exit;
  if FLineMarkers.ContainsLine(Line, Kind) then
    Exit(FLineMarkers[FLineMarkers.IndexOfLine(Line, Kind)]);
  Result := FLineMarkers.AddLine(Line, Kind);
end;

procedure TCodeEditor.RemoveLineMarker(Line: Integer; Kind: TCodeLineMarkerKind);
begin
  FLineMarkers.RemoveLine(Line, Kind);
end;

procedure TCodeEditor.ClearLineMarkers;
begin
  if FLineMarkers.Count = 0 then
    Exit;
  FLineMarkers.Clear;
end;

procedure TCodeEditor.SetBreakpoints(Value: TCodeBreakpoints);
begin
  FBreakpoints.Assign(Value);
end;

procedure TCodeEditor.SetLineMarkers(Value: TCodeLineMarkers);
begin
  FLineMarkers.Assign(Value);
end;

procedure TCodeEditor.LineMarkersChanged;
begin
  if csDestroying in ComponentState then
    Exit;
  Invalidate;
  if csDesigning in ComponentState then
    Update;
end;

procedure TCodeEditor.SetExecutionLine(Value: Integer);
var
  Idx: Integer;
begin
  if (Value < 1) or (Value > FLines.Count) then
    Value := -1;  // -1 (or any value < 1) means "no current line"
  if FExecutionLine = Value then
    Exit;
  FExecutionLine := Value;
  if FExecutionLine >= 1 then
  begin
    Idx := FExecutionLine - 1;
    if Idx < FTopLine then
      FTopLine := Idx
    else if Idx >= FTopLine + VisibleLineCount then
      FTopLine := Idx - VisibleLineCount + 1;
    FTopLine := EnsureRange(FTopLine, 0, Max(0, FLines.Count - VisibleLineCount));
    UpdateScrollBars;
  end;
  Invalidate;
end;

procedure TCodeEditor.ShiftBreakpoints(AfterLine, Delta: Integer);
var
  I: Integer;
  Affected: Boolean;
begin
  if Delta = 0 then
    Exit;

  Affected := (FExecutionLine > AfterLine);
  if not Affected then
    for I := 0 to FBreakpoints.Count - 1 do
      if RemapLineAfterEdit(FBreakpoints[I].Line, AfterLine, Delta) <> FBreakpoints[I].Line then
      begin
        Affected := True;
        Break;
      end;
  if not Affected then
    Exit;

  FBreakpoints.BeginUpdate;
  try
    for I := FBreakpoints.Count - 1 downto 0 do
      FBreakpoints[I].Line := RemapLineAfterEdit(FBreakpoints[I].Line, AfterLine, Delta);
    // Remapping can produce duplicates when lines are merged together.
    for I := FBreakpoints.Count - 1 downto 1 do
      if FBreakpoints.IndexOfLine(FBreakpoints[I].Line) < I then
        FBreakpoints.Delete(I);
  finally
    FBreakpoints.EndUpdate;
  end;

  if FExecutionLine > AfterLine then
  begin
    if (Delta < 0) and (FExecutionLine <= AfterLine - Delta) then
      FExecutionLine := -1
    else
      FExecutionLine := FExecutionLine + Delta;
  end;
end;

procedure TCodeEditor.ShiftLineMarkers(AfterLine, Delta: Integer);
var
  I: Integer;
begin
  if Delta = 0 then
    Exit;

  FLineMarkers.BeginUpdate;
  try
    for I := FLineMarkers.Count - 1 downto 0 do
      FLineMarkers[I].Line := EnsureRange(RemapLineAfterEdit(FLineMarkers[I].Line, AfterLine, Delta),
        1, Max(1, FLines.Count));
  finally
    FLineMarkers.EndUpdate;
  end;
end;

procedure TCodeEditor.PaintBreakpointGlyph(const CellRect: TRect; HasBp, IsExec: Boolean);
var
  Size: Integer;
  Dot: TRect;
  Cx, Cy: Integer;
  Arrow: array[0..2] of TPoint;
begin
  Size := Min(CellRect.Width, FLineHeight) - 4;
  if Size < 6 then
    Size := Min(CellRect.Width, FLineHeight);
  Cx := (CellRect.Left + CellRect.Right) div 2;
  Cy := (CellRect.Top + CellRect.Bottom) div 2;

  if HasBp then
  begin
    Dot := Rect(Cx - Size div 2, Cy - Size div 2, Cx - Size div 2 + Size, Cy - Size div 2 + Size);
    Canvas.Brush.Color := $003C3CE0;
    Canvas.Pen.Color := $002020A0;
    Canvas.Ellipse(Dot);
  end;

  if IsExec then
  begin
    Arrow[0] := Point(CellRect.Left + 2, Cy - Size div 3);
    Arrow[1] := Point(CellRect.Left + 2, Cy + Size div 3);
    Arrow[2] := Point(CellRect.Right - 2, Cy);
    if HasBp then
    begin
      Canvas.Brush.Color := $0020D0F0;
      Canvas.Pen.Color := $001090C0;
    end
    else
    begin
      Canvas.Brush.Color := $00E0A020;
      Canvas.Pen.Color := $00A07010;
    end;
    Canvas.Polygon(Arrow);
  end;
end;

function TCodeEditor.FirstLineMarkerAny(Line: Integer): TCodeLineMarker;
var
  I: Integer;
begin
  Result := nil;
  for I := 0 to FLineMarkers.Count - 1 do
    if FLineMarkers[I].Line = Line then
    begin
      if (Result = nil) or (Ord(FLineMarkers[I].Kind) < Ord(Result.Kind)) then
        Result := FLineMarkers[I];
    end;
end;

function TCodeEditor.MarkerBackgroundColor(Marker: TCodeLineMarker;
  const ThemeColors: TCodeEditorThemeColors): TColor;
begin
  Result := clNone;
  if not Assigned(Marker) then
    Exit;
  if Marker.Background <> clNone then
    Exit(Marker.Background);

  case Marker.Kind of
    lmkExecutable:
      if IsDarkTheme(ThemeColors) then
        Result := $00282020
      else
        Result := $00F4F4F4;
    lmkError:
      if IsDarkTheme(ThemeColors) then
        Result := $00202060
      else
        Result := $00E8E8FF;
    lmkWarning:
      if IsDarkTheme(ThemeColors) then
        Result := $00204060
      else
        Result := $00D8F4FF;
    lmkInfo:
      if IsDarkTheme(ThemeColors) then
        Result := ShiftBrightness(ThemeColors.Background, 18)
      else
        Result := ShiftBrightness(ThemeColors.Background, -12);
  end;
end;

procedure TCodeEditor.PaintLineMarkerGlyph(const CellRect: TRect; Marker: TCodeLineMarker);
var
  R: TRect;
  Cx, Cy: Integer;
  Size: Integer;
  Points: array[0..2] of TPoint;
  ForeColor: TColor;
begin
  if not Assigned(Marker) then
    Exit;

  if Marker.Foreground <> clNone then
    ForeColor := Marker.Foreground
  else
    case Marker.Kind of
      lmkExecutable: ForeColor := $00707070;
      lmkError: ForeColor := $002020D0;
      lmkWarning: ForeColor := $0000A0E0;
    else
      ForeColor := $00C08020;
    end;

  Size := Max(6, Min(CellRect.Width, FLineHeight) - 8);
  Cx := (CellRect.Left + CellRect.Right) div 2;
  Cy := (CellRect.Top + CellRect.Bottom) div 2;
  Canvas.Brush.Color := ForeColor;
  Canvas.Pen.Color := ForeColor;

  case Marker.Kind of
    lmkExecutable:
      begin
        R := Rect(Cx - Size div 2, Cy - Size div 2, Cx - Size div 2 + Size, Cy - Size div 2 + Size);
        Canvas.Rectangle(R);
      end;
    lmkError:
      begin
        Canvas.MoveTo(Cx - Size div 2, Cy - Size div 2);
        Canvas.LineTo(Cx + Size div 2, Cy + Size div 2);
        Canvas.MoveTo(Cx + Size div 2, Cy - Size div 2);
        Canvas.LineTo(Cx - Size div 2, Cy + Size div 2);
      end;
    lmkWarning:
      begin
        Points[0] := Point(Cx, Cy - Size div 2);
        Points[1] := Point(Cx - Size div 2, Cy + Size div 2);
        Points[2] := Point(Cx + Size div 2, Cy + Size div 2);
        Canvas.Polygon(Points);
      end;
  else
    R := Rect(Cx - Size div 2, Cy - Size div 2, Cx - Size div 2 + Size, Cy - Size div 2 + Size);
    Canvas.Ellipse(R);
  end;
end;

procedure TCodeEditor.Paint;
begin
  // Resolve the theme once per paint; the Paint* helpers all read FPaintTheme
  // instead of allocating their own copy per call (or worse, per line).
  FPaintTheme := ActiveTheme;
  try
    Canvas.Brush.Color := FPaintTheme.Background;
    Canvas.FillRect(ClientRect);
    Canvas.Font.Assign(Font);
    Canvas.Font.Size := ScaledFontSize;
    Canvas.Font.Color := FPaintTheme.Text;
    PaintGutter;
    PaintText;
    PaintMinimap;
    PaintStyledScrollBars;
  finally
    FreeAndNil(FPaintTheme);
  end;
end;

procedure TCodeEditor.PaintGutter;
var
  I: Integer;
  LineIndex: Integer;
  Y: Integer;
  Text: string;
  R: TRect;
  Cell: TRect;
  HasBp: Boolean;
  IsExec: Boolean;
  Marker: TCodeLineMarker;
  ThemeColors: TCodeEditorThemeColors;
begin
  if not FOptions.ShowGutter then
    Exit;

  ThemeColors := FPaintTheme;
  begin
    R := Rect(0, 0, FGutterWidth, ClientHeight);
    Canvas.Brush.Style := bsSolid;
    Canvas.Brush.Color := ThemeColors.GutterBackground;
    Canvas.FillRect(R);
    Canvas.Pen.Color := ThemeColors.GutterBorder;
    Canvas.MoveTo(FGutterWidth - 1, 0);
    Canvas.LineTo(FGutterWidth - 1, ClientHeight);

    for I := 0 to VisibleLineCount - 1 do
    begin
      LineIndex := FTopLine + I;
      if LineIndex >= FLines.Count then
        Break;

      Y := I * FLineHeight + 1;
      HasBp := HasBreakpoint(LineIndex + 1);
      IsExec := (LineIndex + 1) = FExecutionLine;
      Marker := FirstLineMarkerAny(LineIndex + 1);

      if HasBp or IsExec then
      begin
        Cell := Rect(0, Y - 1, BreakpointMarginWidth, Y - 1 + FLineHeight);
        PaintBreakpointGlyph(Cell, HasBp, IsExec);
        Canvas.Brush.Style := bsSolid;
        Canvas.Brush.Color := ThemeColors.GutterBackground;
      end;

      if Assigned(Marker) then
      begin
        Cell := Rect(BreakpointMarginWidth, Y - 1, BreakpointMarginWidth + 14, Y - 1 + FLineHeight);
        PaintLineMarkerGlyph(Cell, Marker);
        Canvas.Brush.Style := bsSolid;
        Canvas.Brush.Color := ThemeColors.GutterBackground;
      end;

      Canvas.Font.Color := ThemeColors.GutterText;
      Text := IntToStr(LineIndex + 1);
      Canvas.TextOut(FGutterWidth - Canvas.TextWidth(Text) - 8, Y, Text);
    end;
  end;
end;

procedure TCodeEditor.PaintText;
var
  I: Integer;
  LineIndex: Integer;
  Y: Integer;
  LineText: string;
  DrawText: string;
  R: TRect;
  Marker: TCodeLineMarker;
  MarkerColor: TColor;
  ThemeColors: TCodeEditorThemeColors;
  HaveBracketMatch: Boolean;
  BracketOpen: TCodePosition;
  BracketClose: TCodePosition;
  OccurrenceNeedle: string;
begin
  R := ClientTextRect;
  ThemeColors := FPaintTheme;

  // Per-paint work hoisted out of the per-line loop: the bracket scan can
  // touch the whole document, and the occurrence needle never changes mid-paint.
  HaveBracketMatch := MatchingBracketPosition(BracketOpen, BracketClose);
  OccurrenceNeedle := '';
  if HasSelection and (SelectionStart.Line = SelectionEnd.Line) then
    OccurrenceNeedle := GetSelectedText;

  Canvas.Brush.Color := ThemeColors.Background;
  for I := 0 to VisibleLineCount - 1 do
  begin
    LineIndex := FTopLine + I;
    if LineIndex >= FLines.Count then
      Break;

    Y := I * FLineHeight + 1;
    LineText := FLines[LineIndex];
    // Tabs are drawn as a single space cell so the glyphs line up with the
    // one-column-per-character caret arithmetic.
    if Pos(#9, LineText) > 0 then
      DrawText := StringReplace(LineText, #9, ' ', [rfReplaceAll])
    else
      DrawText := LineText;
    Marker := FirstLineMarkerAny(LineIndex + 1);
    MarkerColor := MarkerBackgroundColor(Marker, ThemeColors);
    if MarkerColor <> clNone then
    begin
      Canvas.Brush.Color := MarkerColor;
      Canvas.FillRect(Rect(R.Left, Y - 1, R.Right, Y - 1 + FLineHeight));
      Canvas.Brush.Color := ThemeColors.Background;
    end;
    if (LineIndex + 1) = FExecutionLine then
    begin
      if IsDarkTheme(ThemeColors) then
        Canvas.Brush.Color := ShiftBrightness(ThemeColors.Background, 28)
      else
        Canvas.Brush.Color := ShiftBrightness(ThemeColors.Background, -22);
      Canvas.FillRect(Rect(R.Left, Y - 1, R.Right, Y - 1 + FLineHeight));
      Canvas.Brush.Color := ThemeColors.Background;
    end;
    PaintSearchMatchesLine(LineIndex, Y, LineText);
    PaintOccurrenceHighlightsLine(LineIndex, Y, LineText, OccurrenceNeedle);
    PaintSelectionLine(LineIndex, Y, LineText);
    PaintLineTokens(LineIndex, R.Left, Y, DrawText, clNone);
    PaintSelectedTextLine(LineIndex, R.Left, Y, DrawText);
    if HaveBracketMatch then
      PaintBracketMatchesLine(LineIndex, Y, BracketOpen, BracketClose);
    PaintMultipleCaretsLine(LineIndex, Y);
  end;
end;

procedure TCodeEditor.PaintMinimap;
var
  R: TRect;
  ViewR: TRect;
  ThemeColors: TCodeEditorThemeColors;
  LineIndex: Integer;
  FirstLine: Integer;
  LastLine: Integer;
  ScrollOffset: Integer;
  Y: Integer;
  LineText: string;
  Trimmed: string;
  FirstNonSpace: Integer;
  X: Integer;
  SegmentWidth: Integer;
  LineColor: TColor;
  Tokens: TCodeTokenArray;
  Token: TCodeToken;
  Style: TCodeTextStyle;
  TokenX: Integer;
  TokenWidth: Integer;

  function MapColumn(Column: Integer): Integer;
  begin
    Result := R.Left + 4 + Min(R.Width - 8, MulDiv(Column, R.Width - 8, 120));
  end;

  procedure PaintPlainLine;
  begin
    Trimmed := TrimLeft(LineText);
    if Trimmed = '' then
      Exit;

    FirstNonSpace := Length(LineText) - Length(Trimmed);
    X := MapColumn(FirstNonSpace);
    SegmentWidth := Max(2, Min(R.Right - X - 3, MulDiv(Length(Trimmed), R.Width - 8, 120)));
    Canvas.Brush.Color := LineColor;
    Canvas.FillRect(Rect(X, Y, X + SegmentWidth, Min(Y + MinimapLineHeight - 1, R.Bottom)));
  end;

begin
  if not MinimapVisible then
    Exit;

  R := MinimapRect;
  if R.IsEmpty then
    Exit;

  ThemeColors := FPaintTheme;
  begin
    if IsDarkTheme(ThemeColors) then
      Canvas.Brush.Color := ShiftBrightness(ThemeColors.Background, 10)
    else
      Canvas.Brush.Color := ShiftBrightness(ThemeColors.Background, -6);
    Canvas.FillRect(R);
    Canvas.Pen.Color := ThemeColors.GutterBorder;
    Canvas.MoveTo(R.Left, R.Top);
    Canvas.LineTo(R.Left, R.Bottom);

    if IsDarkTheme(ThemeColors) then
      LineColor := ShiftBrightness(ThemeColors.Text, -55)
    else
      LineColor := ShiftBrightness(ThemeColors.Text, 90);

    ScrollOffset := MinimapScrollOffset;
    FirstLine := Max(0, ScrollOffset div MinimapLineHeight);
    LastLine := Min(FLines.Count - 1, (ScrollOffset + R.Height) div MinimapLineHeight + 1);
    for LineIndex := FirstLine to LastLine do
    begin
      if FLines.Count <= 0 then
        Break;
      Y := R.Top + LineIndex * MinimapLineHeight - ScrollOffset;
      if Y >= R.Bottom - 2 then
        Continue;
      LineText := FLines[LineIndex];

      if Assigned(FHighlighter) then
      begin
        Tokens := LineTokens(LineIndex);
        if Length(Tokens) = 0 then
          PaintPlainLine
        else
          for Token in Tokens do
          begin
            if Token.Kind = tkWhitespace then
              Continue;
            Style := TokenStyleForTheme(Token.Kind, FHighlighter.Styles[Token.Kind], ThemeColors);
            TokenX := MapColumn(Token.Start - 1);
            TokenWidth := Max(1, Min(R.Right - TokenX - 3, MulDiv(Token.Length, R.Width - 8, 120)));
            Canvas.Brush.Color := Style.Foreground;
            Canvas.FillRect(Rect(TokenX, Y, TokenX + TokenWidth,
              Min(Y + MinimapLineHeight - 1, R.Bottom)));
          end;
      end
      else
        PaintPlainLine;
    end;

    ViewR := MinimapViewportRect;
    Canvas.Brush.Style := bsClear;
    if IsDarkTheme(ThemeColors) then
      Canvas.Pen.Color := ShiftBrightness(ThemeColors.SelectionBackground, -20)
    else
      Canvas.Pen.Color := ShiftBrightness(ThemeColors.SelectionBackground, 20);
    Canvas.Rectangle(ViewR);
    Canvas.Brush.Style := bsSolid;
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

  ThemeColors := FPaintTheme;
  TrackColor := ThemeColors.GutterBackground;
  if IsDarkTheme(ThemeColors) then
    ThumbColor := ShiftBrightness(TrackColor, 40)
  else
    ThumbColor := ShiftBrightness(TrackColor, -50);

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
  Range: TCodeSelectionRange;
  StartCol: Integer;
  EndCol: Integer;
  X1: Integer;
  X2: Integer;
  R: TRect;
  ThemeColors: TCodeEditorThemeColors;

  procedure PaintRange(const AStart, AEnd: TCodePosition);
  begin
    if (ALineIndex < AStart.Line) or (ALineIndex > AEnd.Line) then
      Exit;

    StartCol := 0;
    EndCol := Length(LineText);
    if ALineIndex = AStart.Line then
      StartCol := AStart.Column;
    if ALineIndex = AEnd.Line then
      EndCol := AEnd.Column;

    R := ClientTextRect;
    X1 := R.Left + (StartCol - FLeftColumn) * FCharWidth;
    X2 := R.Left + (EndCol - FLeftColumn) * FCharWidth;
    if ComparePositions(AStart, AEnd) = 0 then
      Exit;

    Canvas.Brush.Color := ThemeColors.SelectionBackground;
    Canvas.FillRect(Rect(Max(R.Left, X1), Y - 1, Max(R.Left, X2), Y + FLineHeight - 1));
  end;

begin
  if not HasSelection and not HasMultipleSelections then
    Exit;

  ThemeColors := FPaintTheme;
  if HasSelection then
    PaintRange(SelectionStart, SelectionEnd);
  if HasMultipleSelections then
    for Range in FSelections do
      PaintRange(RangeStart(Range), RangeEnd(Range));
end;

procedure TCodeEditor.PaintMultipleCaretsLine(ALineIndex, Y: Integer);
var
  Range: TCodeSelectionRange;
  Position: TCodePosition;
  R: TRect;
  X: Integer;
  ThemeColors: TCodeEditorThemeColors;

  procedure PaintCaretAt(const CaretPosition: TCodePosition);
  begin
    if CaretPosition.Line <> ALineIndex then
      Exit;

    R := ClientTextRect;
    X := R.Left + (CaretPosition.Column - FLeftColumn) * FCharWidth;
    if (X < R.Left) or (X > R.Right) then
      Exit;

    Canvas.Pen.Color := ThemeColors.SelectionBackground;
    Canvas.MoveTo(X, Y);
    Canvas.LineTo(X, Y + FLineHeight - 1);
    Canvas.Pen.Color := ThemeColors.Text;
    Canvas.MoveTo(X + 1, Y);
    Canvas.LineTo(X + 1, Y + FLineHeight - 1);
  end;
begin
  if not HasMultipleSelections then
    Exit;

  ThemeColors := FPaintTheme;
  for Range in FSelections do
    if ComparePositions(Range.Anchor, Range.Caret) = 0 then
    begin
      Position := NormalizePosition(Range.Caret);
      PaintCaretAt(Position);
    end;
end;

procedure TCodeEditor.PaintBracketMatchesLine(ALineIndex, Y: Integer;
  const OpenPos, ClosePos: TCodePosition);
var
  R: TRect;
  X: Integer;
  Box: TRect;

  procedure PaintMatch(const Position: TCodePosition);
  begin
    if Position.Line <> ALineIndex then
      Exit;
    R := ClientTextRect;
    X := R.Left + (Position.Column - FLeftColumn) * FCharWidth;
    Box := Rect(X, Y - 1, X + FCharWidth, Y + FLineHeight - 1);
    if (Box.Right < R.Left) or (Box.Left > R.Right) then
      Exit;
    Canvas.Brush.Style := bsClear;
    Canvas.Pen.Color := FPaintTheme.SelectionBackground;
    Canvas.Rectangle(Box);
    Canvas.Brush.Style := bsSolid;
  end;

begin
  PaintMatch(OpenPos);
  PaintMatch(ClosePos);
end;

procedure TCodeEditor.PaintOccurrenceHighlightsLine(ALineIndex, Y: Integer;
  const LineText, Needle: string);
var
  SearchStart: Integer;
  FoundAt: Integer;
  R: TRect;
  X1: Integer;
  X2: Integer;
  FillColor: TColor;
  Range: TCodeSelectionRange;

  function SameRange(const AStart, AEnd, BStart, BEnd: TCodePosition): Boolean;
  begin
    Result := (ComparePositions(AStart, BStart) = 0) and (ComparePositions(AEnd, BEnd) = 0);
  end;

  function IsActiveSelection(const AStart, AEnd: TCodePosition): Boolean;
  var
    ActiveStart: TCodePosition;
    ActiveEnd: TCodePosition;
    ActiveRange: TCodeSelectionRange;
  begin
    ActiveStart := SelectionStart;
    ActiveEnd := SelectionEnd;
    Result := SameRange(AStart, AEnd, ActiveStart, ActiveEnd);
    if Result then
      Exit;

    for ActiveRange in FSelections do
    begin
      if ComparePositions(ActiveRange.Anchor, ActiveRange.Caret) = 0 then
        Continue;
      if SameRange(AStart, AEnd, RangeStart(ActiveRange), RangeEnd(ActiveRange)) then
        Exit(True);
    end;
  end;
begin
  if Needle = '' then
    Exit;

  if IsDarkTheme(FPaintTheme) then
    FillColor := ShiftBrightness(FPaintTheme.Background, 36)
  else
    FillColor := ShiftBrightness(FPaintTheme.Background, -24);

  R := ClientTextRect;
  SearchStart := 1;
  repeat
    FoundAt := PosEx(Needle, LineText, SearchStart);
    if FoundAt = 0 then
      Break;

    Range.Anchor := TCodePosition.Create(ALineIndex, FoundAt - 1);
    Range.Caret := TCodePosition.Create(ALineIndex, FoundAt - 1 + Length(Needle));
    if not IsActiveSelection(RangeStart(Range), RangeEnd(Range)) then
    begin
      X1 := R.Left + (RangeStart(Range).Column - FLeftColumn) * FCharWidth;
      X2 := R.Left + (RangeEnd(Range).Column - FLeftColumn) * FCharWidth;
      Canvas.Brush.Color := FillColor;
      Canvas.FillRect(Rect(Max(R.Left, X1), Y - 1, Max(R.Left, X2), Y + FLineHeight - 1));
    end;

    SearchStart := FoundAt + Max(1, Length(Needle));
  until SearchStart > Length(LineText);
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

procedure TCodeEditor.PaintLineTokens(ALineIndex, X, Y: Integer; const LineText: string;
  ForcedColor: TColor);
var
  Tokens: TCodeTokenArray;
  Token: TCodeToken;
  Style: TCodeTextStyle;
  Text: string;
  TokenX: Integer;
begin
  if not Assigned(FHighlighter) then
  begin
    if ForcedColor <> clNone then
      Canvas.Font.Color := ForcedColor
    else
      Canvas.Font.Color := FPaintTheme.Text;
    Canvas.Brush.Style := bsClear;
    Canvas.TextOut(X - FLeftColumn * FCharWidth, Y, LineText);
    Canvas.Brush.Style := bsSolid;
    Exit;
  end;

  Tokens := LineTokens(ALineIndex);
  for Token in Tokens do
  begin
    Text := Copy(LineText, Token.Start, Token.Length);
    TokenX := X + (Token.Start - 1 - FLeftColumn) * FCharWidth;
    Style := FHighlighter.Styles[Token.Kind];
    if FOptions.ThemeSyntaxColors then
      Style := TokenStyleForTheme(Token.Kind, Style, FPaintTheme);
    if ForcedColor <> clNone then
      Canvas.Font.Color := ForcedColor
    else
      Canvas.Font.Color := Style.Foreground;
    Canvas.Font.Style := Style.FontStyle;
    Canvas.Brush.Style := bsClear;
    Canvas.TextOut(TokenX, Y, Text);
  end;

  Canvas.Brush.Style := bsSolid;
  Canvas.Font.Style := Font.Style;
end;

procedure TCodeEditor.PaintSelectedTextLine(ALineIndex, X, Y: Integer; const LineText: string);
var
  R: TRect;
  Range: TCodeSelectionRange;

  // Redraws the selected slice of the line clipped to the selection rect,
  // using the theme's SelectionText color so selected text stays readable.
  procedure PaintRange(const AStart, AEnd: TCodePosition);
  var
    StartCol: Integer;
    EndCol: Integer;
    X1: Integer;
    X2: Integer;
    SaveIndex: Integer;
  begin
    if (ALineIndex < AStart.Line) or (ALineIndex > AEnd.Line) then
      Exit;
    if ComparePositions(AStart, AEnd) = 0 then
      Exit;

    StartCol := 0;
    EndCol := Length(LineText);
    if ALineIndex = AStart.Line then
      StartCol := AStart.Column;
    if ALineIndex = AEnd.Line then
      EndCol := Min(EndCol, AEnd.Column);
    if EndCol <= StartCol then
      Exit;

    X1 := Max(R.Left, R.Left + (StartCol - FLeftColumn) * FCharWidth);
    X2 := Max(R.Left, R.Left + (EndCol - FLeftColumn) * FCharWidth);
    if X2 <= X1 then
      Exit;

    SaveIndex := SaveDC(Canvas.Handle);
    try
      IntersectClipRect(Canvas.Handle, X1, Y - 1, X2, Y + FLineHeight - 1);
      PaintLineTokens(ALineIndex, X, Y, LineText, FPaintTheme.SelectionText);
    finally
      RestoreDC(Canvas.Handle, SaveIndex);
    end;
  end;

begin
  if not HasSelection and not HasMultipleSelections then
    Exit;

  R := ClientTextRect;
  if HasSelection then
    PaintRange(SelectionStart, SelectionEnd);
  if HasMultipleSelections then
    for Range in FSelections do
      PaintRange(RangeStart(Range), RangeEnd(Range));
end;

end.
