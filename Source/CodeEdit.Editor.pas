UNIT CodeEdit.Editor;

INTERFACE

USES
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

TYPE
  TCodeEditorThemeMode = (ctmManual, ctmVclStyle);

  TCodeEditorThemeColors = CLASS(TPersistent)
  PRIVATE
    FBackground: TColor;
    FGutterBackground: TColor;
    FGutterBorder: TColor;
    FGutterText: TColor;
    FSelectionBackground: TColor;
    FSelectionText: TColor;
    FText: TColor;
    FOnChange: TNotifyEvent;
    PROCEDURE SetBackground(Value: TColor);
    PROCEDURE SetGutterBackground(Value: TColor);
    PROCEDURE SetGutterBorder(Value: TColor);
    PROCEDURE SetGutterText(Value: TColor);
    PROCEDURE SetSelectionBackground(Value: TColor);
    PROCEDURE SetSelectionText(Value: TColor);
    PROCEDURE SetText(Value: TColor);
  PROTECTED
    PROCEDURE Changed;
  PUBLIC
    CONSTRUCTOR Create;
    PROCEDURE Assign(Source: TPersistent); OVERRIDE;
    PROCEDURE SetDefaults;
    PROPERTY OnChange: TNotifyEvent READ FOnChange WRITE FOnChange;
  PUBLISHED
    PROPERTY Background: TColor READ FBackground WRITE SetBackground DEFAULT clWindow;
    PROPERTY Text: TColor READ FText WRITE SetText DEFAULT clWindowText;
    PROPERTY GutterBackground: TColor READ FGutterBackground WRITE SetGutterBackground DEFAULT
      clBtnFace;
    PROPERTY GutterText: TColor READ FGutterText WRITE SetGutterText DEFAULT clGrayText;
    PROPERTY GutterBorder: TColor READ FGutterBorder WRITE SetGutterBorder DEFAULT clBtnShadow;
    PROPERTY SelectionBackground: TColor READ FSelectionBackground WRITE SetSelectionBackground
      DEFAULT clHighlight;
    PROPERTY SelectionText: TColor READ FSelectionText WRITE SetSelectionText DEFAULT
      clHighlightText;
  END;

  TCodeEditorResolveThemeEvent = PROCEDURE(Sender: TObject; Colors: TCodeEditorThemeColors) OF
    OBJECT;

  TCodeEditorOptions = CLASS(TPersistent)
  PRIVATE
    FBracketMatching: Boolean;
    FLineCommentPrefix: STRING;
    FShowMinimap: Boolean;
    FMaxPasteBytes: Integer;
    FThemeSyntaxColors: Boolean;
    FShowGutter: Boolean;
    FTabSize: Integer;
    FOnChange: TNotifyEvent;
    PROCEDURE SetBracketMatching(Value: Boolean);
    PROCEDURE SetLineCommentPrefix(CONST Value: STRING);
    PROCEDURE SetMaxPasteBytes(Value: Integer);
    PROCEDURE SetShowMinimap(Value: Boolean);
    PROCEDURE SetThemeSyntaxColors(Value: Boolean);
    PROCEDURE SetShowGutter(Value: Boolean);
    PROCEDURE SetTabSize(Value: Integer);
  PROTECTED
    PROCEDURE Changed;
  PUBLIC
    CONSTRUCTOR Create;
    PROCEDURE Assign(Source: TPersistent); OVERRIDE;
  PUBLISHED
    PROPERTY BracketMatching: Boolean READ FBracketMatching WRITE SetBracketMatching DEFAULT True;
    PROPERTY LineCommentPrefix: STRING READ FLineCommentPrefix WRITE SetLineCommentPrefix;
    PROPERTY MaxPasteBytes: Integer READ FMaxPasteBytes WRITE SetMaxPasteBytes DEFAULT 67108864;
    PROPERTY ShowGutter: Boolean READ FShowGutter WRITE SetShowGutter DEFAULT True;
    PROPERTY ShowMinimap: Boolean READ FShowMinimap WRITE SetShowMinimap DEFAULT False;
    PROPERTY TabSize: Integer READ FTabSize WRITE SetTabSize DEFAULT 2;
    PROPERTY ThemeSyntaxColors: Boolean READ FThemeSyntaxColors WRITE SetThemeSyntaxColors DEFAULT
      True;
    PROPERTY OnChange: TNotifyEvent READ FOnChange WRITE FOnChange;
  END;

  TCodePosition = RECORD
    Line: Integer;
    Column: Integer;
    CLASS FUNCTION Create(ALine, AColumn: Integer): TCodePosition; STATIC;
  END;

  TCodeUndoItem = CLASS
  PUBLIC
    BeforeText: STRING;
    AfterText: STRING;
    BeforeModified: Boolean;
    BeforeCaret: TCodePosition;
    AfterCaret: TCodePosition;
    BeforeAnchor: TCodePosition;
    AfterAnchor: TCodePosition;
    BeforeBreakpoints: TArray<Integer>;
    AfterBreakpoints: TArray<Integer>;
    BeforeExecutionLine: Integer;
    AfterExecutionLine: Integer;
  END;

  TCodeUndoGroupKind = (ugNone, ugTyping);

  TCodeSearchMatch = RECORD
    Line: Integer;
    Column: Integer;
    Length: Integer;
  END;

  TCodeSelectionRange = RECORD
    Anchor: TCodePosition;
    Caret: TCodePosition;
  END;

  // Cached tokenization of one line. Entries are only trusted while both Text
  // and StartState still match, so the cache never needs precise invalidation.
  TCodeLineTokensEntry = RECORD
    Text: STRING;
    StartState: Integer;
    EndState: Integer;
    Tokens: TCodeTokenArray;
  END;

  TCodeEditorCaretChangeEvent = PROCEDURE(Sender: TObject; CONST Caret: TCodePosition) OF OBJECT;
  TCodeEditorSelectionChangeEvent = PROCEDURE(Sender: TObject; CONST SelectionStart,
    SelectionEnd: TCodePosition) OF OBJECT;
  // Pull-based per-line gutter query, called while painting each visible line.
  // Line is 1-based (matching the gutter). Used for the executable-line dots
  // ("blue dots") a script debugger shows next to lines that generate code.
  TCodeEditorQueryLineEvent = PROCEDURE(Sender: TObject; Line: Integer;
    VAR Value: Boolean) OF OBJECT;
  // Fired when the mouse hovers over an identifier. Line/Column are 1-based;
  // AWord is the identifier under the cursor (dotted member chains like
  // 'a.b' are returned whole). Set HintText to show a tooltip — e.g. a
  // debugger's live value for the variable; leave it empty for no hint.
  TCodeEditorHintEvent = PROCEDURE(Sender: TObject; Line, Column: Integer;
    CONST AWord: STRING; VAR HintText: STRING) OF OBJECT;

  TCodeEditor = CLASS;

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
  TCodeLineMarker = CLASS(TCollectionItem)
  PRIVATE
    FBackground: TColor;
    FForeground: TColor;
    FKind: TCodeLineMarkerKind;
    FLine: Integer;
    FText: STRING;
    PROCEDURE SetBackground(Value: TColor);
    PROCEDURE SetForeground(Value: TColor);
    PROCEDURE SetKind(Value: TCodeLineMarkerKind);
    PROCEDURE SetLine(Value: Integer);
    PROCEDURE SetText(CONST Value: STRING);
  PROTECTED
    FUNCTION GetDisplayName: STRING; OVERRIDE;
  PUBLIC
    CONSTRUCTOR Create(Collection: TCollection); OVERRIDE;
    PROCEDURE Assign(Source: TPersistent); OVERRIDE;
  PUBLISHED
    PROPERTY Background: TColor READ FBackground WRITE SetBackground DEFAULT clNone;
    PROPERTY Foreground: TColor READ FForeground WRITE SetForeground DEFAULT clNone;
    PROPERTY Kind: TCodeLineMarkerKind READ FKind WRITE SetKind DEFAULT lmkInfo;
    PROPERTY Line: Integer READ FLine WRITE SetLine DEFAULT 1;
    PROPERTY Text: STRING READ FText WRITE SetText;
  END;

  TCodeLineMarkers = CLASS(TOwnedCollection)
  PRIVATE
    FUNCTION GetItem(Index: Integer): TCodeLineMarker;
    PROCEDURE SetItem(Index: Integer; Value: TCodeLineMarker);
  PROTECTED
    PROCEDURE Update(Item: TCollectionItem); OVERRIDE;
  PUBLIC
    CONSTRUCTOR Create(AOwner: TPersistent);
    FUNCTION IndexOfLine(ALine: Integer; Kind: TCodeLineMarkerKind): Integer;
    FUNCTION ContainsLine(ALine: Integer; Kind: TCodeLineMarkerKind): Boolean;
    FUNCTION AddLine(ALine: Integer; Kind: TCodeLineMarkerKind): TCodeLineMarker;
    PROCEDURE RemoveLine(ALine: Integer; Kind: TCodeLineMarkerKind);
    PROPERTY Items[Index: Integer]: TCodeLineMarker READ GetItem WRITE SetItem; DEFAULT;
  END;

  // Line is 1-based, matching the gutter line numbers.
  TCodeBreakpoint = CLASS(TCollectionItem)
  PRIVATE
    FLine: Integer;
    PROCEDURE SetLine(Value: Integer);
  PROTECTED
    FUNCTION GetDisplayName: STRING; OVERRIDE;
  PUBLIC
    CONSTRUCTOR Create(Collection: TCollection); OVERRIDE;
    PROCEDURE Assign(Source: TPersistent); OVERRIDE;
  PUBLISHED
    PROPERTY Line: Integer READ FLine WRITE SetLine DEFAULT 1;
  END;

  TCodeBreakpoints = CLASS(TOwnedCollection)
  PRIVATE
    FUNCTION GetItem(Index: Integer): TCodeBreakpoint;
    PROCEDURE SetItem(Index: Integer; Value: TCodeBreakpoint);
  PROTECTED
    PROCEDURE Update(Item: TCollectionItem); OVERRIDE;
  PUBLIC
    CONSTRUCTOR Create(AOwner: TPersistent);
    FUNCTION IndexOfLine(ALine: Integer): Integer;
    FUNCTION ContainsLine(ALine: Integer): Boolean;
    FUNCTION AddLine(ALine: Integer): TCodeBreakpoint;
    PROCEDURE RemoveLine(ALine: Integer);
    FUNCTION SortedLines: TArray<Integer>;
    PROPERTY Items[Index: Integer]: TCodeBreakpoint READ GetItem WRITE SetItem; DEFAULT;
  END;

  TCodeEditor = CLASS(TCustomControl)
  PRIVATE
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
    FSuppressSysChar: Boolean;
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
    FOnQueryExecutableLine: TCodeEditorQueryLineEvent;
    FOnGetHint: TCodeEditorHintEvent;
    FHoverTimer: TTimer;
    FHintWindow: THintWindow;
    FHoverMouse: TPoint;
    FHintVisible: Boolean;
    PROCEDURE LinesChanged(Sender: TObject);
    PROCEDURE OptionsChanged(Sender: TObject);
    PROCEDURE ThemeChanged(Sender: TObject);
    PROCEDURE SetHighlighter(Value: TCustomCodeHighlighter);
    PROCEDURE SetCompletionProvider(Value: TCustomCodeCompletionProvider);
    PROCEDURE SetLines(Value: TStrings);
    PROCEDURE SetOptions(Value: TCodeEditorOptions);
    PROCEDURE SetScrollBars(Value: System.UITypes.TScrollStyle);
    PROCEDURE SetStyledScrollBars(Value: Boolean);
    PROCEDURE SetCaret(Value: TCodePosition);
    PROCEDURE SetLeftColumn(Value: Integer);
    PROCEDURE SetModified(Value: Boolean);
    PROCEDURE SetReadOnly(Value: Boolean);
    PROCEDURE SetTheme(Value: TCodeEditorThemeColors);
    PROCEDURE SetThemeMode(Value: TCodeEditorThemeMode);
    PROCEDURE SetTopLine(Value: Integer);
    PROCEDURE ResolveTheme(Colors: TCodeEditorThemeColors);
    FUNCTION ActiveTheme: TCodeEditorThemeColors;
    FUNCTION GetLines: TStrings;
    FUNCTION ClientTextRect: TRect;
    FUNCTION MinimapVisible: Boolean;
    FUNCTION MinimapRect: TRect;
    FUNCTION MinimapContentHeight: Integer;
    FUNCTION MinimapScrollOffset: Integer;
    FUNCTION MinimapViewportRect: TRect;
    PROCEDURE ScrollMinimapTo(Y: Integer);
    FUNCTION StyledVerticalScrollRect: TRect;
    FUNCTION StyledVerticalThumbRect: TRect;
    FUNCTION StyledHorizontalScrollRect: TRect;
    FUNCTION StyledHorizontalThumbRect: TRect;
    FUNCTION MaxLineLength: Integer;
    FUNCTION StyledHorizontalVisible: Boolean;
    FUNCTION StyledVerticalVisible: Boolean;
    FUNCTION VisibleLineCount: Integer;
    FUNCTION VisibleColumnCount: Integer;
    FUNCTION CaretToPoint(CONST Position: TCodePosition): TPoint;
    FUNCTION PointToCaret(CONST Point: TPoint): TCodePosition;
    FUNCTION NormalizePosition(CONST Position: TCodePosition): TCodePosition;
    FUNCTION IsDarkTheme(CONST Colors: TCodeEditorThemeColors): Boolean;
    FUNCTION TokenStyleForTheme(Kind: TCodeTokenKind; CONST BaseStyle: TCodeTextStyle;
      CONST Colors: TCodeEditorThemeColors): TCodeTextStyle;
    FUNCTION HasSelection: Boolean;
    FUNCTION SelectionStart: TCodePosition;
    FUNCTION SelectionEnd: TCodePosition;
    FUNCTION RangeStart(CONST Range: TCodeSelectionRange): TCodePosition;
    FUNCTION RangeEnd(CONST Range: TCodeSelectionRange): TCodePosition;
    FUNCTION OccurrenceAlreadySelected(CONST APos: TCodePosition): Boolean;
    FUNCTION HasMultipleSelections: Boolean;
    FUNCTION ComparePositions(CONST A, B: TCodePosition): Integer;
    FUNCTION SelectedLineStart: Integer;
    FUNCTION SelectedLineEnd: Integer;
    FUNCTION MatchingBracketPosition(OUT OpenPos, ClosePos: TCodePosition): Boolean;
    FUNCTION GetSelectedText: STRING;
    FUNCTION CompletionPrefix: STRING;
    FUNCTION CompletionVisible: Boolean;
    FUNCTION CompletionDisplayText(Item: TCodeCompletionItem): STRING;
    FUNCTION SignatureVisible: Boolean;
    FUNCTION SignatureFunctionName: STRING;
    FUNCTION SignatureActiveParameter: Integer;
    FUNCTION SearchVisible: Boolean;
    FUNCTION IsWholeWordMatch(CONST LineText: STRING; Column, MatchLength: Integer): Boolean;
    FUNCTION ClipboardTextBytes: UInt64;
    FUNCTION CanPasteFromClipboard: Boolean;
    FUNCTION CaptureUndoState: TCodeUndoItem;
    FUNCTION CurrentTextSnapshot: STRING;
    PROCEDURE RestoreMarkers(CONST BreakpointLines: TArray<Integer>; ExecutionLine: Integer);
    FUNCTION CanUndo: Boolean;
    FUNCTION CanRedo: Boolean;
    PROCEDURE ClearUndoStack(Stack: TStack<TCodeUndoItem>);
    PROCEDURE PushUndoItem(Stack: TStack<TCodeUndoItem>; Item: TCodeUndoItem);
    PROCEDURE RestoreUndoState(CONST Text: STRING; CONST Caret, Anchor: TCodePosition;
      CONST BreakpointLines: TArray<Integer>; ExecutionLine: Integer);
    PROCEDURE CommitUndoState(Item: TCodeUndoItem);
    PROCEDURE FinishUndoGroup;
    PROCEDURE CancelUndoGroup;
    PROCEDURE DoCaretChange;
    PROCEDURE DoSelectionChange;
    PROCEDURE DoEditStateChanged;
    FUNCTION CanContinueTypingUndo(CONST Value: STRING): Boolean;
    PROCEDURE InsertTypedText(CONST Value: STRING);
    PROCEDURE PasteFromClipboard;
    PROCEDURE CopyToClipboard;
    PROCEDURE CutToClipboard;
    PROCEDURE CreateCompletionPopup;
    PROCEDURE PopulateCompletionPopup;
    PROCEDURE ShowCompletion(TriggerChar: Char; ExplicitRequest: Boolean);
    PROCEDURE HideCompletion;
    PROCEDURE AcceptCompletion;
    PROCEDURE CompletionListClick(Sender: TObject);
    PROCEDURE CompletionListDblClick(Sender: TObject);
    PROCEDURE MoveCompletionSelection(Delta: Integer);
    PROCEDURE SetTemplateProvider(Value: TCodeTemplateProvider);
    FUNCTION TemplatesVisible: Boolean;
    FUNCTION TemplateDisplayText(Template: TCodeTemplate): STRING;
    PROCEDURE CreateTemplatePopup;
    PROCEDURE PopulateTemplatePopup;
    PROCEDURE ShowTemplates(ExplicitRequest: Boolean);
    PROCEDURE HideTemplates;
    PROCEDURE AcceptTemplate;
    PROCEDURE TemplateListDblClick(Sender: TObject);
    PROCEDURE MoveTemplateSelection(Delta: Integer);
    PROCEDURE InsertTemplateRange(Template: TCodeTemplate; CONST StartPos, EndPos: TCodePosition);
    PROCEDURE CreateSignaturePopup;
    PROCEDURE ShowSignatureHelp(TriggerChar: Char; ExplicitRequest: Boolean);
    PROCEDURE UpdateSignatureHelp(TriggerChar: Char);
    PROCEDURE HideSignatureHelp;
    PROCEDURE PopulateSignaturePopup;
    PROCEDURE CreateSearchPanel;
    PROCEDURE SetSearchButtonGlyph(Button: TSpeedButton; CONST Kind: STRING);
    PROCEDURE StyleSearchEdit(Edit: TEdit);
    PROCEDURE StyleSearchButton(Button: TSpeedButton);
    PROCEDURE RestyleSearchPanel;
    PROCEDURE LayoutSearchPanel;
    PROCEDURE UpdateSearch;
    PROCEDURE SelectSearchMatch(Index: Integer);
    PROCEDURE FindNextMatch;
    PROCEDURE FindPreviousMatch;
    PROCEDURE ReplaceCurrentMatch;
    PROCEDURE ReplaceAllMatches;
    PROCEDURE HideSearchPanel;
    PROCEDURE SeedSearchFromSelection;
    PROCEDURE SearchTextChanged(Sender: TObject);
    PROCEDURE SearchEditKeyDown(Sender: TObject; VAR Key: Word; Shift: TShiftState);
    PROCEDURE SearchEditKeyPress(Sender: TObject; VAR Key: Char);
    PROCEDURE SearchButtonClick(Sender: TObject);
    PROCEDURE SearchExpandClick(Sender: TObject);
    PROCEDURE PaintSearchMatchesLine(ALineIndex, Y: Integer; CONST LineText: STRING);
    PROCEDURE SetSelectedText(CONST Value: STRING);
    PROCEDURE DeleteSelection;
    PROCEDURE ClearExtraSelections;
    PROCEDURE AddSelectionRange(CONST Anchor, Caret: TCodePosition);
    PROCEDURE SelectNextOccurrence;
    PROCEDURE SelectAllOccurrences;
    PROCEDURE InsertTextAtRange(CONST StartPos, EndPos: TCodePosition; CONST Value: STRING;
      OUT NewCaret: TCodePosition);
    FUNCTION PositionBefore(CONST Position: TCodePosition): TCodePosition;
    FUNCTION PositionAfter(CONST Position: TCodePosition): TCodePosition;
    FUNCTION CollectSelectionRanges: TArray<TCodeSelectionRange>;
    PROCEDURE ApplyRangeEdits(VAR Ranges: TArray<TCodeSelectionRange>; CONST Value: STRING);
    PROCEDURE ReplaceAllSelections(CONST Value: STRING);
    PROCEDURE DeleteAllSelections(DeletePrevious: Boolean);
    PROCEDURE EnsureCaretVisible;
    PROCEDURE UpdateCaret;
    PROCEDURE InvalidateTextArea;
    PROCEDURE InvalidateTextLines(FirstLine, LastLine: Integer);
    PROCEDURE ScrollViewport(OldTopLine: Integer);
    FUNCTION OccurrenceNeedle: STRING;
    PROCEDURE UpdateMetrics;
    PROCEDURE UpdateGutterWidth;
    PROCEDURE SetZoom(Value: Integer);
    FUNCTION ScaledFontSize: Integer;
    PROCEDURE UpdateScrollBars;
    PROCEDURE EnsureLineStates(UpToLine: Integer);
    FUNCTION LineTokens(ALineIndex: Integer): TCodeTokenArray;
    FUNCTION WindowInPopups(Wnd: HWND): Boolean;
    FUNCTION MovePositionForKey(CONST Position: TCodePosition; Key: Word): TCodePosition;
    PROCEDURE MoveMultipleCarets(Key: Word; Shift: TShiftState);
    PROCEDURE MoveCaret(CONST Position: TCodePosition; Shift: TShiftState;
      PreserveDesiredColumn: Boolean = False);
    PROCEDURE MoveCaretVertically(DeltaLines: Integer; Shift: TShiftState);
    FUNCTION PrevWordPosition(CONST Position: TCodePosition): TCodePosition;
    FUNCTION NextWordPosition(CONST Position: TCodePosition): TCodePosition;
    PROCEDURE SelectWordAtCaret;
    FUNCTION LineAtPoint(CONST Point: TPoint): Integer;
    PROCEDURE SetExecutionLine(Value: Integer);
    PROCEDURE SetBreakpoints(Value: TCodeBreakpoints);
    PROCEDURE SetLineMarkers(Value: TCodeLineMarkers);
    PROCEDURE BreakpointsChanged;
    PROCEDURE LineMarkersChanged;
    PROCEDURE ShiftBreakpoints(AfterLine, Delta: Integer);
    PROCEDURE ShiftLineMarkers(AfterLine, Delta: Integer);
    PROCEDURE PaintBreakpointGlyph(CONST CellRect: TRect; HasBp, IsExec: Boolean);
    PROCEDURE PaintExecutableDot(CONST CellRect: TRect);
    FUNCTION QueryExecutableLine(Line: Integer): Boolean;
    FUNCTION WordAtPoint(CONST P: TPoint; OUT WordPos: TCodePosition): STRING;
    PROCEDURE HoverTimerFired(Sender: TObject);
    PROCEDURE ShowHoverHint(CONST P: TPoint; CONST HintText: STRING);
    PROCEDURE HideHoverHint;
    PROCEDURE PaintLineMarkerGlyph(CONST CellRect: TRect; Marker: TCodeLineMarker);
    FUNCTION FirstLineMarkerAny(Line: Integer): TCodeLineMarker;
    FUNCTION MarkerBackgroundColor(Marker: TCodeLineMarker; CONST ThemeColors:
      TCodeEditorThemeColors): TColor;
    PROCEDURE PaintGutter;
    PROCEDURE PaintText;
    PROCEDURE PaintMinimap;
    PROCEDURE PaintStyledScrollBars;
    PROCEDURE PaintOccurrenceHighlightsLine(ALineIndex, Y: Integer; CONST LineText, Needle: STRING);
    PROCEDURE PaintSelectionLine(ALineIndex, Y: Integer; CONST LineText: STRING);
    PROCEDURE PaintMultipleCaretsLine(ALineIndex, Y: Integer);
    PROCEDURE PaintBracketMatchesLine(ALineIndex, Y: Integer; CONST OpenPos, ClosePos:
      TCodePosition);
    PROCEDURE PaintLineTokens(ALineIndex, X, Y: Integer; CONST LineText: STRING; ForcedColor:
      TColor);
    PROCEDURE PaintSelectedTextLine(ALineIndex, X, Y: Integer; CONST LineText: STRING);
    PROCEDURE CMFontChanged(VAR Message: TMessage); MESSAGE CM_FONTCHANGED;
    PROCEDURE CMStyleChanged(VAR Message: TMessage); MESSAGE CM_STYLECHANGED;
    PROCEDURE CMMouseLeave(VAR Message: TMessage); MESSAGE CM_MOUSELEAVE;
    PROCEDURE WMGetDlgCode(VAR Message: TWMGetDlgCode); MESSAGE WM_GETDLGCODE;
    PROCEDURE WMSysChar(VAR Message: TWMSysChar); MESSAGE WM_SYSCHAR;
    PROCEDURE WMHScroll(VAR Message: TWMHScroll); MESSAGE WM_HSCROLL;
    PROCEDURE WMMouseWheel(VAR Message: TWMMouseWheel); MESSAGE WM_MOUSEWHEEL;
    PROCEDURE WMPaste(VAR Message: TWMPaste); MESSAGE WM_PASTE;
    PROCEDURE WMSetFocus(VAR Message: TWMSetFocus); MESSAGE WM_SETFOCUS;
    PROCEDURE WMKillFocus(VAR Message: TWMKillFocus); MESSAGE WM_KILLFOCUS;
    PROCEDURE WMSize(VAR Message: TWMSize); MESSAGE WM_SIZE;
    PROCEDURE WMVScroll(VAR Message: TWMVScroll); MESSAGE WM_VSCROLL;
  PROTECTED
    PROCEDURE CreateParams(VAR Params: TCreateParams); OVERRIDE;
    PROCEDURE CreateWnd; OVERRIDE;
    PROCEDURE DestroyWnd; OVERRIDE;
    PROCEDURE KeyDown(VAR Key: Word; Shift: TShiftState); OVERRIDE;
    PROCEDURE KeyPress(VAR Key: Char); OVERRIDE;
    PROCEDURE MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); OVERRIDE;
    PROCEDURE MouseMove(Shift: TShiftState; X, Y: Integer); OVERRIDE;
    PROCEDURE MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); OVERRIDE;
    PROCEDURE Notification(AComponent: TComponent; Operation: TOperation); OVERRIDE;
    PROCEDURE Paint; OVERRIDE;
    PROCEDURE Resize; OVERRIDE;
    PROCEDURE Change; VIRTUAL;
  PUBLIC
    CONSTRUCTOR Create(AOwner: TComponent); OVERRIDE;
    DESTRUCTOR Destroy; OVERRIDE;
    PROCEDURE Clear;
    PROCEDURE SelectAll;
    PROCEDURE Undo;
    PROCEDURE Redo;
    PROCEDURE ClearUndo;
    PROCEDURE ExecuteCommand(Command: TCodeEditorCommand);
    PROCEDURE TriggerCompletion;
    PROCEDURE TriggerSignatureHelp;
    PROCEDURE TriggerTemplates;
    PROCEDURE InsertTemplate(Template: TCodeTemplate);
    FUNCTION ActiveLanguageName: STRING;
    PROCEDURE ShowFind;
    PROCEDURE ShowReplace;
    PROCEDURE InsertText(CONST Value: STRING; AddUndo: Boolean = True);
    PROCEDURE CommentSelection;
    PROCEDURE UncommentSelection;
    PROCEDURE ToggleLineComment;
    PROCEDURE IndentSelection;
    PROCEDURE UnindentSelection;
    PROCEDURE ZoomIn;
    PROCEDURE ZoomOut;
    PROCEDURE ZoomReset;
    PROCEDURE AddNextSelectionOccurrence;
    PROCEDURE SelectAllSelectionOccurrences;
    PROCEDURE ClearMultipleSelections;
    PROCEDURE ToggleBreakpoint(Line: Integer);
    PROCEDURE AddBreakpoint(Line: Integer);
    PROCEDURE RemoveBreakpoint(Line: Integer);
    PROCEDURE ClearBreakpoints;
    FUNCTION AddLineMarker(Line: Integer; Kind: TCodeLineMarkerKind): TCodeLineMarker;
    PROCEDURE RemoveLineMarker(Line: Integer; Kind: TCodeLineMarkerKind);
    PROCEDURE ClearLineMarkers;
    PROCEDURE ShowLine(Line: Integer);
    FUNCTION HasBreakpoint(Line: Integer): Boolean;
    FUNCTION BreakpointLines: TArray<Integer>;
    PROPERTY CanUndoAction: Boolean READ CanUndo;
    PROPERTY CanRedoAction: Boolean READ CanRedo;
    PROPERTY Caret: TCodePosition READ FCaret WRITE SetCaret;
    PROPERTY ExecutionLine: Integer READ FExecutionLine WRITE SetExecutionLine;
    PROPERTY LeftColumn: Integer READ FLeftColumn WRITE SetLeftColumn;
    PROPERTY SelectedText: STRING READ GetSelectedText WRITE SetSelectedText;
    PROPERTY TopLine: Integer READ FTopLine WRITE SetTopLine;
  PUBLISHED
    PROPERTY Align;
    PROPERTY Anchors;
    PROPERTY Color DEFAULT clWindow;
    PROPERTY CompletionProvider: TCustomCodeCompletionProvider READ FCompletionProvider WRITE
      SetCompletionProvider;
    PROPERTY Font;
    PROPERTY Highlighter: TCustomCodeHighlighter READ FHighlighter WRITE SetHighlighter;
    PROPERTY Lines: TStrings READ GetLines WRITE SetLines;
    PROPERTY LineMarkers: TCodeLineMarkers READ FLineMarkers WRITE SetLineMarkers;
    PROPERTY Modified: Boolean READ FModified WRITE SetModified DEFAULT False;
    PROPERTY Options: TCodeEditorOptions READ FOptions WRITE SetOptions;
    PROPERTY PopupMenu;
    PROPERTY ReadOnly: Boolean READ FReadOnly WRITE SetReadOnly DEFAULT False;
    PROPERTY ScrollBars: System.UITypes.TScrollStyle READ FScrollBars WRITE SetScrollBars DEFAULT
      ssBoth;
    PROPERTY StyledScrollBars: Boolean READ FStyledScrollBars WRITE SetStyledScrollBars DEFAULT
      True;
    PROPERTY TemplateProvider: TCodeTemplateProvider READ FTemplateProvider WRITE
      SetTemplateProvider;
    PROPERTY Theme: TCodeEditorThemeColors READ FTheme WRITE SetTheme;
    PROPERTY ThemeMode: TCodeEditorThemeMode READ FThemeMode WRITE SetThemeMode DEFAULT ctmVclStyle;
    PROPERTY MaxUndo: Integer READ FMaxUndo WRITE FMaxUndo DEFAULT 1024;
    PROPERTY Zoom: Integer READ FZoom WRITE SetZoom DEFAULT 100;
    PROPERTY TabOrder;
    PROPERTY TabStop DEFAULT True;
    PROPERTY OnCaretChange: TCodeEditorCaretChangeEvent READ FOnCaretChange WRITE FOnCaretChange;
    PROPERTY OnChange: TNotifyEvent READ FOnChange WRITE FOnChange;
    PROPERTY OnResolveTheme: TCodeEditorResolveThemeEvent READ FOnResolveTheme WRITE
      FOnResolveTheme;
    PROPERTY Breakpoints: TCodeBreakpoints READ FBreakpoints WRITE SetBreakpoints;
    PROPERTY OnBreakpointsChanged: TNotifyEvent READ FOnBreakpointsChanged WRITE
      FOnBreakpointsChanged;
    PROPERTY OnClick;
    PROPERTY OnDblClick;
    PROPERTY OnEnter;
    PROPERTY OnExit;
    PROPERTY OnKeyDown;
    PROPERTY OnKeyPress;
    PROPERTY OnKeyUp;
    PROPERTY OnMouseDown;
    PROPERTY OnMouseMove;
    PROPERTY OnMouseUp;
    PROPERTY OnSelectionChange: TCodeEditorSelectionChangeEvent READ FOnSelectionChange WRITE
      FOnSelectionChange;
    PROPERTY OnZoomChanged: TNotifyEvent READ FOnZoomChanged WRITE FOnZoomChanged;
    // Return True in Value to show an executable-line dot in the gutter for
    // the given 1-based Line. Called per visible line while painting, so keep
    // it cheap; call Invalidate after the executable set changes (e.g. after
    // the script recompiles) to force a repaint.
    PROPERTY OnQueryExecutableLine: TCodeEditorQueryLineEvent READ FOnQueryExecutableLine
      WRITE FOnQueryExecutableLine;
    // Hover-to-evaluate: fired after the mouse rests over an identifier. Set
    // HintText to pop a tooltip (e.g. a debugger's live variable value). The
    // hint clears automatically when the mouse moves, scrolls, or a key is
    // pressed. Assigning this enables mouse tracking; leave it nil to disable.
    PROPERTY OnGetHint: TCodeEditorHintEvent READ FOnGetHint WRITE FOnGetHint;
  END;

IMPLEMENTATION

USES
  System.Character,
  System.Math,
  System.RegularExpressions,
  System.StrUtils,
  System.SysUtils,
  Vcl.Clipbrd,
  Vcl.Themes;

CONST
  MinGutterWidth    = 42;
  BreakpointMarginWidth = 16;
  MinimapWidth      = 192;
  MinimapGap        = 4;
  MinimapLineHeight = 4;
  StyledScrollBarSize = 12;
  DefaultMaxPasteBytes = 64 * 1024 * 1024;
  MinZoomPercent    = 25;
  MaxZoomPercent    = 400;
  ZoomStepPercent   = 10;

CONSTRUCTOR TCodeEditorThemeColors.Create;
BEGIN
  INHERITED Create;
  SetDefaults;
END;

PROCEDURE TCodeEditorThemeColors.SetDefaults;
BEGIN
  FBackground := clWindow;
  FText := clWindowText;
  FGutterBackground := clBtnFace;
  FGutterText := clGrayText;
  FGutterBorder := clBtnShadow;
  FSelectionBackground := clHighlight;
  FSelectionText := clHighlightText;
END;

PROCEDURE TCodeEditorThemeColors.Assign(Source: TPersistent);
BEGIN
  IF Source IS TCodeEditorThemeColors THEN BEGIN
    FBackground := TCodeEditorThemeColors(Source).Background;
    FText := TCodeEditorThemeColors(Source).Text;
    FGutterBackground := TCodeEditorThemeColors(Source).GutterBackground;
    FGutterText := TCodeEditorThemeColors(Source).GutterText;
    FGutterBorder := TCodeEditorThemeColors(Source).GutterBorder;
    FSelectionBackground := TCodeEditorThemeColors(Source).SelectionBackground;
    FSelectionText := TCodeEditorThemeColors(Source).SelectionText;
    Changed;
  END ELSE
    INHERITED;
END;

PROCEDURE TCodeEditorThemeColors.Changed;
BEGIN
  IF Assigned(FOnChange) THEN
    FOnChange(Self);
END;

PROCEDURE TCodeEditorThemeColors.SetBackground(Value: TColor);
BEGIN
  IF FBackground <> Value THEN BEGIN
    FBackground := Value;
    Changed;
  END;
END;

PROCEDURE TCodeEditorThemeColors.SetText(Value: TColor);
BEGIN
  IF FText <> Value THEN BEGIN
    FText := Value;
    Changed;
  END;
END;

PROCEDURE TCodeEditorThemeColors.SetGutterBackground(Value: TColor);
BEGIN
  IF FGutterBackground <> Value THEN BEGIN
    FGutterBackground := Value;
    Changed;
  END;
END;

PROCEDURE TCodeEditorThemeColors.SetGutterText(Value: TColor);
BEGIN
  IF FGutterText <> Value THEN BEGIN
    FGutterText := Value;
    Changed;
  END;
END;

PROCEDURE TCodeEditorThemeColors.SetGutterBorder(Value: TColor);
BEGIN
  IF FGutterBorder <> Value THEN BEGIN
    FGutterBorder := Value;
    Changed;
  END;
END;

PROCEDURE TCodeEditorThemeColors.SetSelectionBackground(Value: TColor);
BEGIN
  IF FSelectionBackground <> Value THEN BEGIN
    FSelectionBackground := Value;
    Changed;
  END;
END;

PROCEDURE TCodeEditorThemeColors.SetSelectionText(Value: TColor);
BEGIN
  IF FSelectionText <> Value THEN BEGIN
    FSelectionText := Value;
    Changed;
  END;
END;

CONSTRUCTOR TCodeEditorOptions.Create;
BEGIN
  INHERITED Create;
  FBracketMatching := True;
  FLineCommentPrefix := '//';
  FShowGutter := True;
  FShowMinimap := False;
  FMaxPasteBytes := DefaultMaxPasteBytes;
  FThemeSyntaxColors := True;
  FTabSize := 2;
END;

PROCEDURE TCodeEditorOptions.Changed;
BEGIN
  IF Assigned(FOnChange) THEN
    FOnChange(Self);
END;

PROCEDURE TCodeEditorOptions.Assign(Source: TPersistent);
BEGIN
  IF Source IS TCodeEditorOptions THEN BEGIN
    FBracketMatching := TCodeEditorOptions(Source).BracketMatching;
    FLineCommentPrefix := TCodeEditorOptions(Source).LineCommentPrefix;
    FShowGutter := TCodeEditorOptions(Source).ShowGutter;
    FShowMinimap := TCodeEditorOptions(Source).ShowMinimap;
    FMaxPasteBytes := TCodeEditorOptions(Source).MaxPasteBytes;
    FTabSize := TCodeEditorOptions(Source).TabSize;
    FThemeSyntaxColors := TCodeEditorOptions(Source).ThemeSyntaxColors;
    Changed;
  END ELSE
    INHERITED;
END;

PROCEDURE TCodeEditorOptions.SetBracketMatching(Value: Boolean);
BEGIN
  IF FBracketMatching <> Value THEN BEGIN
    FBracketMatching := Value;
    Changed;
  END;
END;

PROCEDURE TCodeEditorOptions.SetLineCommentPrefix(CONST Value: STRING);
BEGIN
  IF FLineCommentPrefix <> Value THEN BEGIN
    FLineCommentPrefix := Value;
    Changed;
  END;
END;

PROCEDURE TCodeEditorOptions.SetShowGutter(Value: Boolean);
BEGIN
  IF FShowGutter <> Value THEN BEGIN
    FShowGutter := Value;
    Changed;
  END;
END;

PROCEDURE TCodeEditorOptions.SetMaxPasteBytes(Value: Integer);
BEGIN
  Value := Max(0, Value);
  IF FMaxPasteBytes <> Value THEN BEGIN
    FMaxPasteBytes := Value;
    Changed;
  END;
END;

PROCEDURE TCodeEditorOptions.SetShowMinimap(Value: Boolean);
BEGIN
  IF FShowMinimap <> Value THEN BEGIN
    FShowMinimap := Value;
    Changed;
  END;
END;

PROCEDURE TCodeEditorOptions.SetThemeSyntaxColors(Value: Boolean);
BEGIN
  IF FThemeSyntaxColors <> Value THEN BEGIN
    FThemeSyntaxColors := Value;
    Changed;
  END;
END;

PROCEDURE TCodeEditorOptions.SetTabSize(Value: Integer);
BEGIN
  Value := Max(1, Value);
  IF FTabSize <> Value THEN BEGIN
    FTabSize := Value;
    Changed;
  END;
END;

CLASS FUNCTION TCodePosition.Create(ALine, AColumn: Integer): TCodePosition;
BEGIN
  Result.Line := ALine;
  Result.Column := AColumn;
END;

CONSTRUCTOR TCodeLineMarker.Create(Collection: TCollection);
BEGIN
  INHERITED Create(Collection);
  FLine := 1;
  FKind := lmkInfo;
  FBackground := clNone;
  FForeground := clNone;
END;

PROCEDURE TCodeLineMarker.SetBackground(Value: TColor);
BEGIN
  IF FBackground <> Value THEN BEGIN
    FBackground := Value;
    Changed(False);
  END;
END;

PROCEDURE TCodeLineMarker.SetForeground(Value: TColor);
BEGIN
  IF FForeground <> Value THEN BEGIN
    FForeground := Value;
    Changed(False);
  END;
END;

PROCEDURE TCodeLineMarker.SetKind(Value: TCodeLineMarkerKind);
BEGIN
  IF FKind <> Value THEN BEGIN
    FKind := Value;
    Changed(False);
  END;
END;

PROCEDURE TCodeLineMarker.SetLine(Value: Integer);
BEGIN
  IF Value < 1 THEN
    Value := 1;
  IF FLine <> Value THEN BEGIN
    FLine := Value;
    Changed(False);
  END;
END;

PROCEDURE TCodeLineMarker.SetText(CONST Value: STRING);
BEGIN
  IF FText <> Value THEN BEGIN
    FText := Value;
    Changed(False);
  END;
END;

FUNCTION TCodeLineMarker.GetDisplayName: STRING;
BEGIN
  Result := Format('Line %d', [FLine]);
END;

PROCEDURE TCodeLineMarker.Assign(Source: TPersistent);
BEGIN
  IF Source IS TCodeLineMarker THEN BEGIN
    Background := TCodeLineMarker(Source).Background;
    Foreground := TCodeLineMarker(Source).Foreground;
    Kind := TCodeLineMarker(Source).Kind;
    Line := TCodeLineMarker(Source).Line;
    Text := TCodeLineMarker(Source).Text;
  END ELSE
    INHERITED;
END;

CONSTRUCTOR TCodeLineMarkers.Create(AOwner: TPersistent);
BEGIN
  INHERITED Create(AOwner, TCodeLineMarker);
END;

FUNCTION TCodeLineMarkers.GetItem(Index: Integer): TCodeLineMarker;
BEGIN
  Result := TCodeLineMarker(INHERITED Items[Index]);
END;

PROCEDURE TCodeLineMarkers.SetItem(Index: Integer; Value: TCodeLineMarker);
BEGIN
  INHERITED Items[Index] := Value;
END;

PROCEDURE TCodeLineMarkers.Update(Item: TCollectionItem);
BEGIN
  INHERITED;
  IF GetOwner IS TCodeEditor THEN
    TCodeEditor(GetOwner).LineMarkersChanged;
END;

FUNCTION TCodeLineMarkers.IndexOfLine(ALine: Integer; Kind: TCodeLineMarkerKind): Integer;
VAR
  I                 : Integer;
BEGIN
  FOR I := 0 TO Count - 1 DO
    IF (Items[I].Line = ALine) AND (Items[I].Kind = Kind) THEN
      Exit(I);
  Result := -1;
END;

FUNCTION TCodeLineMarkers.ContainsLine(ALine: Integer; Kind: TCodeLineMarkerKind): Boolean;
BEGIN
  Result := IndexOfLine(ALine, Kind) >= 0;
END;

FUNCTION TCodeLineMarkers.AddLine(ALine: Integer; Kind: TCodeLineMarkerKind): TCodeLineMarker;
BEGIN
  BeginUpdate;
  TRY
    Result := TCodeLineMarker(Add);
    Result.Line := ALine;
    Result.Kind := Kind;
  FINALLY
    EndUpdate;
  END;
END;

PROCEDURE TCodeLineMarkers.RemoveLine(ALine: Integer; Kind: TCodeLineMarkerKind);
VAR
  Index             : Integer;
BEGIN
  Index := IndexOfLine(ALine, Kind);
  IF Index >= 0 THEN
    Delete(Index);
END;

CONSTRUCTOR TCodeBreakpoint.Create(Collection: TCollection);
BEGIN
  INHERITED Create(Collection);
  FLine := 1;
END;

PROCEDURE TCodeBreakpoint.SetLine(Value: Integer);
BEGIN
  IF Value < 1 THEN
    Value := 1;
  IF FLine <> Value THEN BEGIN
    FLine := Value;
    Changed(False);
  END;
END;

FUNCTION TCodeBreakpoint.GetDisplayName: STRING;
BEGIN
  Result := Format('Line %d', [FLine]);
END;

PROCEDURE TCodeBreakpoint.Assign(Source: TPersistent);
BEGIN
  IF Source IS TCodeBreakpoint THEN
    Line := TCodeBreakpoint(Source).Line
  ELSE
    INHERITED;
END;

CONSTRUCTOR TCodeBreakpoints.Create(AOwner: TPersistent);
BEGIN
  INHERITED Create(AOwner, TCodeBreakpoint);
END;

FUNCTION TCodeBreakpoints.GetItem(Index: Integer): TCodeBreakpoint;
BEGIN
  Result := TCodeBreakpoint(INHERITED Items[Index]);
END;

PROCEDURE TCodeBreakpoints.SetItem(Index: Integer; Value: TCodeBreakpoint);
BEGIN
  INHERITED Items[Index] := Value;
END;

PROCEDURE TCodeBreakpoints.Update(Item: TCollectionItem);
BEGIN
  INHERITED;
  IF GetOwner IS TCodeEditor THEN
    TCodeEditor(GetOwner).BreakpointsChanged;
END;

FUNCTION TCodeBreakpoints.IndexOfLine(ALine: Integer): Integer;
VAR
  I                 : Integer;
BEGIN
  FOR I := 0 TO Count - 1 DO
    IF Items[I].Line = ALine THEN
      Exit(I);
  Result := -1;
END;

FUNCTION TCodeBreakpoints.ContainsLine(ALine: Integer): Boolean;
BEGIN
  Result := IndexOfLine(ALine) >= 0;
END;

FUNCTION TCodeBreakpoints.AddLine(ALine: Integer): TCodeBreakpoint;
BEGIN
  BeginUpdate;
  TRY
    Result := TCodeBreakpoint(Add);
    Result.Line := ALine;
  FINALLY
    EndUpdate;
  END;
END;

PROCEDURE TCodeBreakpoints.RemoveLine(ALine: Integer);
VAR
  Index             : Integer;
BEGIN
  Index := IndexOfLine(ALine);
  IF Index >= 0 THEN
    Delete(Index);
END;

FUNCTION TCodeBreakpoints.SortedLines: TArray<Integer>;

  FUNCTION Contains(CONST Arr: TArray<Integer>; UpTo, Value: Integer): Boolean;
  VAR
    K               : Integer;
  BEGIN
    FOR K := 0 TO UpTo - 1 DO
      IF Arr[K] = Value THEN
        Exit(True);
    Result := False;
  END;

VAR
  I, J, Tmp, N, Line: Integer;
BEGIN
  SetLength(Result, Count);
  N := 0;
  FOR I := 0 TO Count - 1 DO BEGIN
    Line := Items[I].Line;
    IF Line < 1 THEN
      Continue;
  IF CONTAINS(Result, N, Line) THEN
  Continue;
Result[N] := Line;
Inc(N);
END;
SetLength(Result, N);

// Insertion sort — breakpoint lists are small.
FOR I := 1 TO High(Result) DO BEGIN
  Tmp := Result[I];
  J := I - 1;
  WHILE (J >= 0) AND (Result[J] > Tmp) DO BEGIN
    Result[J + 1] := Result[J];
    Dec(J);
  END;
  Result[J + 1] := Tmp;
END;
END;

CONSTRUCTOR TCodeEditor.Create(AOwner: TComponent);
BEGIN
  INHERITED Create(AOwner);
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

  FHoverMouse := Point(-1, -1);
  FHoverTimer := TTimer.Create(Self);
  FHoverTimer.Enabled := False;
  FHoverTimer.Interval := 450;
  FHoverTimer.OnTimer := HoverTimerFired;

  Font.Name := 'Consolas';
  Font.Size := 10;
  UpdateMetrics;
END;

DESTRUCTOR TCodeEditor.Destroy;
BEGIN
  // Cancel rather than finish: committing would touch FBreakpoints/FLineMarkers,
  // and there is no point keeping an undo entry during destruction.
  CancelUndoGroup;
  HideCompletion;
  HideSignatureHelp;
  HideTemplates;
  HideHoverHint;
  FHintWindow.Free;
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
  INHERITED;
END;

PROCEDURE TCodeEditor.CreateParams(VAR Params: TCreateParams);
BEGIN
  INHERITED;
  Params.Style := Params.Style OR WS_TABSTOP OR WS_CLIPCHILDREN;
  IF (NOT FStyledScrollBars) AND (FScrollBars IN [ssHorizontal, ssBoth]) THEN
    Params.Style := Params.Style OR WS_HSCROLL;
  IF (NOT FStyledScrollBars) AND (FScrollBars IN [ssVertical, ssBoth]) THEN
    Params.Style := Params.Style OR WS_VSCROLL;
END;

PROCEDURE TCodeEditor.CreateWnd;
BEGIN
  INHERITED;
  UpdateScrollBars;
  UpdateCaret;
END;

PROCEDURE TCodeEditor.DestroyWnd;
BEGIN
  HideCaret(Handle);
  DestroyCaret;
  INHERITED;
END;

PROCEDURE TCodeEditor.CMFontChanged(VAR Message: TMessage);
BEGIN
  INHERITED;
  UpdateMetrics;
  UpdateScrollBars;
  UpdateCaret;
  Invalidate;
END;

PROCEDURE TCodeEditor.CMStyleChanged(VAR Message: TMessage);
BEGIN
  INHERITED;
  IF FThemeMode = ctmVclStyle THEN
    Invalidate;
END;

PROCEDURE TCodeEditor.WMGetDlgCode(VAR Message: TWMGetDlgCode);
BEGIN
  INHERITED;
  Message.Result := Message.Result OR DLGC_WANTALLKEYS OR DLGC_WANTARROWS OR DLGC_WANTCHARS OR
    DLGC_WANTTAB;
END;

PROCEDURE TCodeEditor.WMSysChar(VAR Message: TWMSysChar);
BEGIN
  // The WM_SYSCHAR is already posted by TranslateMessage before KeyDown sees the
  // Alt combo, so a handled Alt shortcut must eat it here or Windows attempts
  // menu activation (audible beep, focus shift to the menu bar).
  IF FSuppressSysChar THEN BEGIN
    FSuppressSysChar := False;
    Message.Result := 1;
  END ELSE
    INHERITED;
END;

PROCEDURE TCodeEditor.WMHScroll(VAR Message: TWMHScroll);
VAR
  NewLeft           : Integer;
  Info              : TScrollInfo;
BEGIN
  INHERITED;
  NewLeft := FLeftColumn;
  CASE Message.ScrollCode OF
    SB_LINELEFT: Dec(NewLeft);
    SB_LINERIGHT: Inc(NewLeft);
    SB_PAGELEFT: Dec(NewLeft, VisibleColumnCount);
    SB_PAGERIGHT: Inc(NewLeft, VisibleColumnCount);
    SB_THUMBPOSITION, SB_THUMBTRACK: BEGIN
        // Message.Pos is 16-bit; SIF_TRACKPOS gives the full 32-bit position.
        FillChar(Info, SizeOf(Info), 0);
        Info.cbSize := SizeOf(Info);
        Info.fMask := SIF_TRACKPOS;
        IF GetScrollInfo(Handle, SB_HORZ, Info) THEN
          NewLeft := Info.nTrackPos
        ELSE
          NewLeft := Message.Pos;
      END;
  END;

  NewLeft := EnsureRange(NewLeft, 0, Max(0, MaxLineLength - VisibleColumnCount + 1));
  IF NewLeft = FLeftColumn THEN
    Exit;
  FLeftColumn := NewLeft;
  UpdateScrollBars;
  UpdateCaret;
  Invalidate;
END;

PROCEDURE TCodeEditor.Resize;
BEGIN
  INHERITED;
  LayoutSearchPanel;
  UpdateScrollBars;
  EnsureCaretVisible;
END;

PROCEDURE TCodeEditor.WMSize(VAR Message: TWMSize);
BEGIN
  INHERITED;
  UpdateScrollBars;
END;

PROCEDURE TCodeEditor.WMSetFocus(VAR Message: TWMSetFocus);
BEGIN
  INHERITED;
  UpdateCaret;
END;

FUNCTION TCodeEditor.WindowInPopups(Wnd: HWND): Boolean;

  FUNCTION InForm(Form: TForm): Boolean;
  BEGIN
    Result := Assigned(Form) AND Form.HandleAllocated AND
      ((Wnd = Form.Handle) OR IsChild(Form.Handle, Wnd));
  END;

BEGIN
  Result := InForm(FCompletionForm) OR InForm(FSignatureForm) OR InForm(FTemplateForm);
END;

PROCEDURE TCodeEditor.WMKillFocus(VAR Message: TWMKillFocus);
BEGIN
  HideCaret(Handle);
  HideHoverHint;
  // Don't hide the popups when focus merely bounces back to the editor itself (which happens
  // during the popup Show + SetFocus sequence) or moves onto one of the popup windows.
  IF (Message.FocusedWnd <> Handle) AND (NOT WindowInPopups(Message.FocusedWnd)) THEN BEGIN
    HideCompletion;
    HideSignatureHelp;
    HideTemplates;
  END;
  INHERITED;
END;

PROCEDURE TCodeEditor.WMPaste(VAR Message: TWMPaste);
BEGIN
  HideCompletion;
  HideSignatureHelp;
  HideTemplates;
  PasteFromClipboard;
  Message.Result := 0;
END;

PROCEDURE TCodeEditor.WMMouseWheel(VAR Message: TWMMouseWheel);
VAR
  DeltaLines        : Integer;
  NewTop            : Integer;
  OldTop            : Integer;
BEGIN
  HideCompletion;
  HideSignatureHelp;
  HideTemplates;
  HideHoverHint;
  IF (Message.Keys AND MK_CONTROL) <> 0 THEN BEGIN
    IF Message.WheelDelta > 0 THEN
      ZoomIn
    ELSE
      ZoomOut;
    Exit;
  END;
  DeltaLines := Mouse.WheelScrollLines * -Sign(Message.WheelDelta);
  NewTop := EnsureRange(FTopLine + DeltaLines, 0, Max(0, FLines.Count - VisibleLineCount));
  IF NewTop = FTopLine THEN
    Exit;
  OldTop := FTopLine;
  FTopLine := NewTop;
  UpdateScrollBars;
  ScrollViewport(OldTop);
END;

PROCEDURE TCodeEditor.WMVScroll(VAR Message: TWMVScroll);
VAR
  NewTop            : Integer;
  OldTop            : Integer;
  Info              : TScrollInfo;
BEGIN
  INHERITED;
  NewTop := FTopLine;
  CASE Message.ScrollCode OF
    SB_LINEUP: Dec(NewTop);
    SB_LINEDOWN: Inc(NewTop);
    SB_PAGEUP: Dec(NewTop, VisibleLineCount);
    SB_PAGEDOWN: Inc(NewTop, VisibleLineCount);
    SB_THUMBPOSITION, SB_THUMBTRACK: BEGIN
        // Message.Pos is 16-bit; SIF_TRACKPOS gives the full 32-bit position.
        FillChar(Info, SizeOf(Info), 0);
        Info.cbSize := SizeOf(Info);
        Info.fMask := SIF_TRACKPOS;
        IF GetScrollInfo(Handle, SB_VERT, Info) THEN
          NewTop := Info.nTrackPos
        ELSE
          NewTop := Message.Pos;
      END;
  END;

  NewTop := EnsureRange(NewTop, 0, Max(0, FLines.Count - VisibleLineCount));
  IF NewTop = FTopLine THEN
    Exit;
  OldTop := FTopLine;
  FTopLine := NewTop;
  UpdateScrollBars;
  UpdateCaret;
  ScrollViewport(OldTop);
END;

PROCEDURE TCodeEditor.UpdateMetrics;
VAR
  MeasureBitmap     : Vcl.Graphics.TBitmap;
  MeasureCanvas     : TCanvas;
BEGIN
  MeasureBitmap := Vcl.Graphics.TBitmap.Create;
  MeasureCanvas := MeasureBitmap.Canvas;
  TRY
    MeasureCanvas.Font.Assign(Font);
    MeasureCanvas.Font.Size := ScaledFontSize;
    FLineHeight := Max(1, MeasureCanvas.TextHeight('Wg') + 2);
    FCharWidth := Max(1, MeasureCanvas.TextWidth('M'));
  FINALLY
    MeasureBitmap.Free;
  END;
  UpdateGutterWidth;
END;

FUNCTION TCodeEditor.ScaledFontSize: Integer;
BEGIN
  Result := Max(1, MulDiv(Font.Size, FZoom, 100));
END;

PROCEDURE TCodeEditor.SetZoom(Value: Integer);
BEGIN
  Value := EnsureRange(Value, MinZoomPercent, MaxZoomPercent);
  IF Value = FZoom THEN
    Exit;

  FZoom := Value;
  UpdateMetrics;
  UpdateScrollBars;
  UpdateCaret;
  EnsureCaretVisible;                   // visible line/column counts changed with the metrics
  Invalidate;
  IF Assigned(FOnZoomChanged) THEN
    FOnZoomChanged(Self);
END;

PROCEDURE TCodeEditor.ZoomIn;
BEGIN
  Zoom := FZoom + ZoomStepPercent;
END;

PROCEDURE TCodeEditor.ZoomOut;
BEGIN
  Zoom := FZoom - ZoomStepPercent;
END;

PROCEDURE TCodeEditor.ZoomReset;
BEGIN
  Zoom := 100;
END;

PROCEDURE TCodeEditor.UpdateGutterWidth;
VAR
  LineCount         : Integer;
  ShowGutter        : Boolean;
BEGIN
  LineCount := 1;
  IF Assigned(FLines) THEN
    LineCount := Max(1, FLines.Count);
  ShowGutter := NOT Assigned(FOptions) OR FOptions.ShowGutter;
  FGutterWidth := IfThen(ShowGutter,
    Max(MinGutterWidth, FCharWidth * Length(IntToStr(LineCount)) + 18) + BreakpointMarginWidth, 0);
END;

PROCEDURE TCodeEditor.UpdateScrollBars;
VAR
  Info              : TScrollInfo;
BEGIN
  IF NOT HandleAllocated THEN
    Exit;

  IF FStyledScrollBars THEN BEGIN
    ShowScrollBar(Handle, SB_VERT, False);
    ShowScrollBar(Handle, SB_HORZ, False);
    Exit;
  END;

  FillChar(Info, SizeOf(Info), 0);
  Info.cbSize := SizeOf(Info);
  Info.fMask := SIF_RANGE OR SIF_PAGE OR SIF_POS;
  Info.nMin := 0;

  IF FScrollBars IN [ssVertical, ssBoth] THEN BEGIN
    Info.nMax := Max(0, FLines.Count - 1);
    Info.nPage := VisibleLineCount;
    Info.nPos := FTopLine;
    SetScrollInfo(Handle, SB_VERT, Info, True);
  END;

  IF FScrollBars IN [ssHorizontal, ssBoth] THEN BEGIN
    Info.nMax := Max(0, MaxLineLength);
    Info.nPage := VisibleColumnCount;
    Info.nPos := FLeftColumn;
    SetScrollInfo(Handle, SB_HORZ, Info, True);
  END;
END;

PROCEDURE TCodeEditor.UpdateCaret;
VAR
  P                 : TPoint;
BEGIN
  IF NOT HandleAllocated OR NOT Focused THEN
    Exit;

  CreateCaret(Handle, 0, 2, FLineHeight);
  P := CaretToPoint(FCaret);
  SetCaretPos(P.X, P.Y);
  ShowCaret(Handle);
END;

PROCEDURE TCodeEditor.InvalidateTextArea;
VAR
  R                 : TRect;
BEGIN
  // The text strip only - gutter, minimap and styled scrollbars are unaffected
  // by caret/selection changes, and excluding them keeps repaints cheap over RDP.
  IF NOT HandleAllocated THEN
    Exit;
  R := ClientTextRect;
  Winapi.Windows.InvalidateRect(Handle, @R, False);
END;

PROCEDURE TCodeEditor.InvalidateTextLines(FirstLine, LastLine: Integer);
VAR
  R                 : TRect;
BEGIN
  IF NOT HandleAllocated THEN
    Exit;
  // Clamp the absolute line range to the viewport; each visible row I occupies
  // the pixel band [I*FLineHeight, (I+1)*FLineHeight] (PaintText draws at I*LH+1).
  FirstLine := Max(FirstLine, FTopLine);
  LastLine := Min(LastLine, FTopLine + VisibleLineCount);
  IF LastLine < FirstLine THEN
    Exit;
  R := ClientTextRect;
  R.Top := Max(R.Top, (FirstLine - FTopLine) * FLineHeight);
  R.Bottom := Min(R.Bottom, (LastLine - FTopLine + 1) * FLineHeight + 1);
  IF R.Bottom > R.Top THEN
    Winapi.Windows.InvalidateRect(Handle, @R, False);
END;

FUNCTION TCodeEditor.OccurrenceNeedle: STRING;
BEGIN
  // Mirrors PaintText: a single-line selection highlights its other occurrences.
  Result := '';
  IF HasSelection AND (SelectionStart.Line = SelectionEnd.Line) THEN
    Result := GetSelectedText;
END;

FUNCTION TCodeEditor.ClientTextRect: TRect;
BEGIN
  Result := ClientRect;
  Inc(Result.Left, FGutterWidth + 4);
  IF MinimapVisible THEN
    Dec(Result.Right, MinimapWidth + MinimapGap);
  IF StyledVerticalVisible THEN
    Dec(Result.Right, StyledScrollBarSize);
  IF StyledHorizontalVisible THEN
    Dec(Result.Bottom, StyledScrollBarSize);
END;

FUNCTION TCodeEditor.MinimapVisible: Boolean;
BEGIN
  Result := Assigned(FOptions) AND FOptions.ShowMinimap AND (ClientWidth >= MinimapWidth + 40);
END;

FUNCTION TCodeEditor.MinimapRect: TRect;
VAR
  RightReserve      : Integer;
  BottomReserve     : Integer;
BEGIN
  Result := Rect(0, 0, 0, 0);
  IF NOT MinimapVisible THEN
    Exit;

  RightReserve := 0;
  IF StyledVerticalVisible THEN
    RightReserve := StyledScrollBarSize;
  BottomReserve := 0;
  IF StyledHorizontalVisible THEN
    BottomReserve := StyledScrollBarSize;

  Result := Rect(ClientWidth - RightReserve - MinimapWidth, 0,
    ClientWidth - RightReserve, ClientHeight - BottomReserve);
END;

FUNCTION TCodeEditor.MinimapContentHeight: Integer;
BEGIN
  Result := Max(1, FLines.Count) * MinimapLineHeight;
END;

FUNCTION TCodeEditor.MinimapScrollOffset: Integer;
VAR
  R                 : TRect;
  MaxOffset         : Integer;
  MaxTopLine        : Integer;
BEGIN
  R := MinimapRect;
  MaxOffset := Max(0, MinimapContentHeight - R.Height);
  IF MaxOffset = 0 THEN
    Exit(0);

  MaxTopLine := Max(1, FLines.Count - VisibleLineCount);
  Result := MulDiv(EnsureRange(FTopLine, 0, MaxTopLine), MaxOffset, MaxTopLine);
END;

FUNCTION TCodeEditor.MinimapViewportRect: TRect;
VAR
  R                 : TRect;
  ScrollOffset      : Integer;
  ViewHeight        : Integer;
BEGIN
  R := MinimapRect;
  Result := R;
  IF (R.Height <= 0) OR (FLines.Count <= 0) THEN
    Exit;

  ScrollOffset := MinimapScrollOffset;
  ViewHeight := Max(8, VisibleLineCount * MinimapLineHeight);
  ViewHeight := Min(ViewHeight, R.Height);
  Result.Top := R.Top + FTopLine * MinimapLineHeight - ScrollOffset;
  Result.Top := EnsureRange(Result.Top, R.Top, Max(R.Top, R.Bottom - ViewHeight));
  Result.Bottom := Result.Top + ViewHeight;
END;

PROCEDURE TCodeEditor.ScrollMinimapTo(Y: Integer);
VAR
  R                 : TRect;
  ScrollOffset      : Integer;
  TargetLine        : Integer;
  OldTop            : Integer;
BEGIN
  R := MinimapRect;
  IF R.Height <= 0 THEN
    Exit;

  ScrollOffset := MinimapScrollOffset;
  TargetLine := (ScrollOffset + EnsureRange(Y - R.Top, 0, R.Height)) DIV MinimapLineHeight;
  OldTop := FTopLine;
  FTopLine := TargetLine - VisibleLineCount DIV 2;
  FTopLine := EnsureRange(FTopLine, 0, Max(0, FLines.Count - VisibleLineCount));
  UpdateScrollBars;
  UpdateCaret;
  ScrollViewport(OldTop);
END;

PROCEDURE TCodeEditor.ScrollViewport(OldTopLine: Integer);
VAR
  Delta             : Integer;
  ScrollR           : TRect;
  R                 : TRect;
  SaveTop           : Integer;
  OldOffset         : Integer;
  OldViewport       : TRect;
BEGIN
  Delta := FTopLine - OldTopLine;
  IF Delta = 0 THEN
    Exit;
  IF NOT HandleAllocated OR (Abs(Delta) >= VisibleLineCount) THEN BEGIN
    Invalidate;
    Exit;
  END;

  // Gutter and text shift together by whole lines. ScrollWindowEx becomes a
  // screen-to-screen copy (an RDP scroll order - nearly free remotely) and
  // SW_INVALIDATE queues only the newly exposed strip for painting.
  ScrollR := ClientTextRect;
  ScrollR.Left := 0;
  Winapi.Windows.ScrollWindowEx(Handle, 0, -Delta * FLineHeight, @ScrollR, @ScrollR, 0, NIL,
    SW_INVALIDATE);

  // Minimap state as it was before the move: when the map content itself is not
  // scrolled (short files, or offset unchanged at this delta) only the viewport
  // box moves, so repaint just its old and new bands instead of the whole map.
  SaveTop := FTopLine;
  FTopLine := OldTopLine;
  OldOffset := MinimapScrollOffset;
  OldViewport := MinimapViewportRect;
  FTopLine := SaveTop;

  IF MinimapVisible THEN BEGIN
    IF MinimapScrollOffset = OldOffset THEN BEGIN
      R := OldViewport;
      InflateRect(R, 0, 2);
      Winapi.Windows.InvalidateRect(Handle, @R, False);
      R := MinimapViewportRect;
      InflateRect(R, 0, 2);
      Winapi.Windows.InvalidateRect(Handle, @R, False);
    END ELSE BEGIN
      R := MinimapRect;
      Winapi.Windows.InvalidateRect(Handle, @R, False);
    END;
  END;

  IF StyledVerticalVisible THEN BEGIN
    R := StyledVerticalScrollRect;
    Winapi.Windows.InvalidateRect(Handle, @R, False);
  END;
END;

FUNCTION TCodeEditor.StyledVerticalVisible: Boolean;
BEGIN
  Result := FStyledScrollBars AND (FScrollBars IN [ssVertical, ssBoth]);
END;

FUNCTION TCodeEditor.StyledHorizontalVisible: Boolean;
BEGIN
  Result := FStyledScrollBars AND (FScrollBars IN [ssHorizontal, ssBoth]);
END;

FUNCTION TCodeEditor.MaxLineLength: Integer;
VAR
  Line              : STRING;
BEGIN
  IF NOT FMaxLineLengthValid THEN BEGIN
    FMaxLineLength := 0;
    FOR Line IN FLines DO
      IF Length(Line) > FMaxLineLength THEN
        FMaxLineLength := Length(Line);
    FMaxLineLengthValid := True;
  END;
  Result := FMaxLineLength;
END;

FUNCTION TCodeEditor.StyledVerticalScrollRect: TRect;
VAR
  BottomReserve     : Integer;
BEGIN
  BottomReserve := 0;
  IF StyledHorizontalVisible THEN
    BottomReserve := StyledScrollBarSize;
  Result := Rect(ClientWidth - StyledScrollBarSize, 0, ClientWidth, ClientHeight - BottomReserve);
END;

FUNCTION TCodeEditor.StyledVerticalThumbRect: TRect;
VAR
  Track             : TRect;
  ThumbHeight       : Integer;
  MaxTopLine        : Integer;
  Travel            : Integer;
BEGIN
  Track := StyledVerticalScrollRect;
  IF FLines.Count <= VisibleLineCount THEN
    Exit(Rect(Track.Left, Track.Top, Track.Right, Track.Top));

  ThumbHeight := Max(24, MulDiv(Track.Height, VisibleLineCount, FLines.Count));
  MaxTopLine := Max(1, FLines.Count - VisibleLineCount);
  Travel := Max(1, Track.Height - ThumbHeight);
  Result.Top := Track.Top + MulDiv(FTopLine, Travel, MaxTopLine);
  Result.Bottom := Result.Top + ThumbHeight;
  Result.Left := Track.Left;
  Result.Right := Track.Right;
END;

FUNCTION TCodeEditor.StyledHorizontalScrollRect: TRect;
VAR
  RightReserve      : Integer;
BEGIN
  RightReserve := 0;
  IF StyledVerticalVisible THEN
    Inc(RightReserve, StyledScrollBarSize);
  IF MinimapVisible THEN
    Inc(RightReserve, MinimapWidth + MinimapGap);
  Result := Rect(0, ClientHeight - StyledScrollBarSize, ClientWidth - RightReserve, ClientHeight);
END;

FUNCTION TCodeEditor.StyledHorizontalThumbRect: TRect;
VAR
  Track             : TRect;
  ThumbWidth        : Integer;
  MaxLeftCol        : Integer;
  Travel            : Integer;
  TotalCols         : Integer;
BEGIN
  Track := StyledHorizontalScrollRect;
  TotalCols := MaxLineLength;
  IF TotalCols <= VisibleColumnCount THEN
    Exit(Rect(Track.Left, Track.Top, Track.Left, Track.Bottom));

  ThumbWidth := Max(24, MulDiv(Track.Width, VisibleColumnCount, TotalCols));
  MaxLeftCol := Max(1, TotalCols - VisibleColumnCount);
  Travel := Max(1, Track.Width - ThumbWidth);
  Result.Left := Track.Left + MulDiv(FLeftColumn, Travel, MaxLeftCol);
  Result.Right := Result.Left + ThumbWidth;
  Result.Top := Track.Top;
  Result.Bottom := Track.Bottom;
END;

PROCEDURE TCodeEditor.EnsureLineStates(UpToLine: Integer);
VAR
  I                 : Integer;
  State             : Integer;
  Entry             : TCodeLineTokensEntry;
BEGIN
  IF NOT Assigned(FHighlighter) THEN
    Exit;

  UpToLine := Min(UpToLine, FLines.Count - 1);
  IF FStateChainValid > UpToLine THEN
    Exit;

  // Resume from the last verified line. Lines whose text and incoming state
  // are unchanged reuse their cached tokens, so revalidation after an edit
  // only re-tokenizes the changed lines plus any lines whose state flipped.
  State := 0;
  IF (FStateChainValid > 0) AND FLineTokenCache.TryGetValue(FStateChainValid - 1, Entry) THEN
    State := Entry.EndState;

  FOR I := FStateChainValid TO UpToLine DO BEGIN
    IF FLineTokenCache.TryGetValue(I, Entry) AND (Entry.Text = FLines[I]) AND
      (Entry.StartState = State) THEN
      State := Entry.EndState
    ELSE BEGIN
      Entry.Text := FLines[I];
      Entry.StartState := State;
      Entry.Tokens := FHighlighter.TokenizeLineState(Entry.Text, State, Entry.EndState);
      FLineTokenCache.AddOrSetValue(I, Entry);
      State := Entry.EndState;
    END;
  END;
  FStateChainValid := UpToLine + 1;
END;

FUNCTION TCodeEditor.LineTokens(ALineIndex: Integer): TCodeTokenArray;
VAR
  Entry             : TCodeLineTokensEntry;
BEGIN
  IF NOT Assigned(FHighlighter) OR (ALineIndex < 0) OR (ALineIndex >= FLines.Count) THEN
    Exit(NIL);

  EnsureLineStates(ALineIndex);
  IF FLineTokenCache.TryGetValue(ALineIndex, Entry) THEN
    Result := Entry.Tokens
  ELSE
    Result := NIL;
END;

FUNCTION TCodeEditor.VisibleLineCount: Integer;
BEGIN
  Result := Max(1, ClientTextRect.Height DIV FLineHeight);
END;

FUNCTION TCodeEditor.VisibleColumnCount: Integer;
BEGIN
  Result := Max(1, ClientTextRect.Width DIV FCharWidth);
END;

FUNCTION TCodeEditor.CaretToPoint(CONST Position: TCodePosition): TPoint;
VAR
  R                 : TRect;
BEGIN
  R := ClientTextRect;
  Result.X := R.Left + (Position.Column - FLeftColumn) * FCharWidth;
  Result.Y := (Position.Line - FTopLine) * FLineHeight;
END;

FUNCTION TCodeEditor.PointToCaret(CONST Point: TPoint): TCodePosition;
VAR
  R                 : TRect;
BEGIN
  R := ClientTextRect;
  Result.Line := FTopLine + EnsureRange(Point.Y DIV FLineHeight, 0, Max(0, FLines.Count - 1));
  Result.Column := FLeftColumn + Max(0, (Point.X - R.Left + FCharWidth DIV 2) DIV FCharWidth);
  Result := NormalizePosition(Result);
END;

FUNCTION TCodeEditor.NormalizePosition(CONST Position: TCodePosition): TCodePosition;
BEGIN
  // An empty control has zero lines, so FLines[0] would raise EStringListError
  // ('TStringList is empty'). Any caret/selection/ExecutionLine set routes through
  // here, so clamp to the origin when there's no text.
  IF FLines.Count = 0 THEN BEGIN
    Result.Line := 0;
    Result.Column := 0;
    Exit;
  END;
  Result.Line := EnsureRange(Position.Line, 0, FLines.Count - 1);
  Result.Column := EnsureRange(Position.Column, 0, Length(FLines[Result.Line]));
END;

FUNCTION IsWordChar(Ch: Char): Boolean;
BEGIN
  Result := Ch.IsLetterOrDigit OR (Ch = '_');
END;

// Maps a 1-based marker line through an insertion (Delta > 0) or deletion
// (Delta < 0) of Abs(Delta) lines after AfterLine. Lines inside a deleted
// region collapse onto AfterLine.
FUNCTION RemapLineAfterEdit(L, AfterLine, Delta: Integer): Integer;
BEGIN
  Result := L;
  IF L <= AfterLine THEN
    Exit;
  IF Delta >= 0 THEN
    Result := L + Delta
  ELSE IF L <= AfterLine - Delta THEN
    Result := AfterLine
  ELSE
    Result := L + Delta;
END;

FUNCTION ColorLuminance(Color: TColor): Integer;
VAR
  RGBColor          : TColorRef;
BEGIN
  RGBColor := ColorToRGB(Color);
  Result := (GetRValue(RGBColor) * 299 + GetGValue(RGBColor) * 587 + GetBValue(RGBColor) * 114) DIV
    1000;
END;

FUNCTION ShiftBrightness(Color: TColor; Delta: Integer): TColor;
VAR
  RGBColor          : TColorRef;
  R, G, B           : Integer;
BEGIN
  RGBColor := ColorToRGB(Color);
  R := EnsureRange(GetRValue(RGBColor) + Delta, 0, 255);
  G := EnsureRange(GetGValue(RGBColor) + Delta, 0, 255);
  B := EnsureRange(GetBValue(RGBColor) + Delta, 0, 255);
  Result := TColor(RGB(R, G, B));
END;

FUNCTION TCodeEditor.IsDarkTheme(CONST Colors: TCodeEditorThemeColors): Boolean;
BEGIN
  Result := ColorLuminance(Colors.Background) < 128;
END;

FUNCTION TCodeEditor.TokenStyleForTheme(Kind: TCodeTokenKind; CONST BaseStyle: TCodeTextStyle;
  CONST Colors: TCodeEditorThemeColors): TCodeTextStyle;
VAR
  Dark              : Boolean;
BEGIN
  Result := BaseStyle;
  Dark := IsDarkTheme(Colors);

  CASE Kind OF
    tkText,
      tkWhitespace,
      tkIdentifier:
      Result.Foreground := Colors.Text;
    tkComment:
      IF Dark THEN
        Result.Foreground := $0086C691
      ELSE
        Result.Foreground := $00808080;
    tkString:
      IF Dark THEN
        Result.Foreground := $0078D7FF
      ELSE
        Result.Foreground := $00008000;
    tkNumber:
      IF Dark THEN
        Result.Foreground := $00B5CEA8
      ELSE
        Result.Foreground := $00800080;
    tkKeyword:
      IF Dark THEN
        Result.Foreground := $00F18C6D
      ELSE
        Result.Foreground := $00B06000;
    tkSymbol:
      IF Dark THEN
        Result.Foreground := $00D4D4D4
      ELSE
        Result.Foreground := $00606060;
  END;
END;

FUNCTION TCodeEditor.ComparePositions(CONST A, B: TCodePosition): Integer;
BEGIN
  Result := A.Line - B.Line;
  IF Result = 0 THEN
    Result := A.Column - B.Column;
END;

FUNCTION TCodeEditor.HasSelection: Boolean;
BEGIN
  Result := ComparePositions(FCaret, FAnchor) <> 0;
END;

FUNCTION TCodeEditor.SelectionStart: TCodePosition;
BEGIN
  IF ComparePositions(FCaret, FAnchor) <= 0 THEN
    Result := FCaret
  ELSE
    Result := FAnchor;
END;

FUNCTION TCodeEditor.SelectionEnd: TCodePosition;
BEGIN
  IF ComparePositions(FCaret, FAnchor) >= 0 THEN
    Result := FCaret
  ELSE
    Result := FAnchor;
END;

FUNCTION TCodeEditor.RangeStart(CONST Range: TCodeSelectionRange): TCodePosition;
BEGIN
  IF ComparePositions(Range.Caret, Range.Anchor) <= 0 THEN
    Result := Range.Caret
  ELSE
    Result := Range.Anchor;
END;

FUNCTION TCodeEditor.RangeEnd(CONST Range: TCodeSelectionRange): TCodePosition;
BEGIN
  IF ComparePositions(Range.Caret, Range.Anchor) >= 0 THEN
    Result := Range.Caret
  ELSE
    Result := Range.Anchor;
END;

FUNCTION TCodeEditor.HasMultipleSelections: Boolean;
BEGIN
  Result := Assigned(FSelections) AND (FSelections.Count > 0);
END;

FUNCTION TCodeEditor.SelectedLineStart: Integer;
BEGIN
  IF HasSelection THEN
    Result := SelectionStart.Line
  ELSE
    Result := FCaret.Line;
END;

FUNCTION TCodeEditor.SelectedLineEnd: Integer;
BEGIN
  IF HasSelection THEN BEGIN
    Result := SelectionEnd.Line;
    IF (SelectionEnd.Column = 0) AND (Result > SelectionStart.Line) THEN
      Dec(Result);
  END ELSE
    Result := FCaret.Line;
END;

FUNCTION TCodeEditor.MatchingBracketPosition(OUT OpenPos, ClosePos: TCodePosition): Boolean;
CONST
  // Angle brackets are deliberately excluded: matching them in ordinary code
  // pairs every < comparison operator with an unrelated >.
  OpenBrackets      = '([{';
  CloseBrackets     = ')]}';
VAR
  Probe             : TCodePosition;
  Ch                : Char;
  PairIndex         : Integer;
  Direction         : Integer;
  Depth             : Integer;
  LineIndex         : Integer;
  Col               : Integer;
  LineText          : STRING;
  OpenCh            : Char;
  CloseCh           : Char;
BEGIN
  Result := False;
  IF NOT FOptions.BracketMatching THEN
    Exit;
  // An empty control has no lines at all — NormalizePosition still yields line 0,
  // but FLines[0] would raise EStringListError. No text means no bracket to match.
  IF FLines.Count = 0 THEN
    Exit;

  Probe := NormalizePosition(FCaret);
  Ch := #0;
  IF Probe.Column > 0 THEN BEGIN
    Ch := FLines[Probe.Line][Probe.Column];
    Dec(Probe.Column);
  END;
  IF Pos(Ch, OpenBrackets + CloseBrackets) = 0 THEN BEGIN
    Probe := NormalizePosition(FCaret);
    IF Probe.Column < Length(FLines[Probe.Line]) THEN
      Ch := FLines[Probe.Line][Probe.Column + 1]
    ELSE
      Exit;
  END;

  PairIndex := Pos(Ch, OpenBrackets);
  IF PairIndex > 0 THEN BEGIN
    Direction := 1;
    OpenCh := OpenBrackets[PairIndex];
    CloseCh := CloseBrackets[PairIndex];
    OpenPos := Probe;
  END ELSE BEGIN
    PairIndex := Pos(Ch, CloseBrackets);
    IF PairIndex = 0 THEN
      Exit;
    Direction := -1;
    OpenCh := OpenBrackets[PairIndex];
    CloseCh := CloseBrackets[PairIndex];
    ClosePos := Probe;
  END;

  Depth := 0;
  LineIndex := Probe.Line;
  Col := Probe.Column + Direction;
  WHILE (LineIndex >= 0) AND (LineIndex < FLines.Count) DO BEGIN
    LineText := FLines[LineIndex];
    WHILE (Col >= 0) AND (Col < Length(LineText)) DO BEGIN
      Ch := LineText[Col + 1];
      IF Ch = OpenCh THEN BEGIN
        IF Direction < 0 THEN BEGIN
          IF Depth = 0 THEN BEGIN
            OpenPos := TCodePosition.Create(LineIndex, Col);
            Exit(True);
          END;
          Dec(Depth);
        END ELSE
          Inc(Depth);
      END ELSE IF Ch = CloseCh THEN BEGIN
        IF Direction > 0 THEN BEGIN
          IF Depth = 0 THEN BEGIN
            ClosePos := TCodePosition.Create(LineIndex, Col);
            Exit(True);
          END;
          Dec(Depth);
        END ELSE
          Inc(Depth);
      END;
      Inc(Col, Direction);
    END;

    Inc(LineIndex, Direction);
    IF (LineIndex < 0) OR (LineIndex >= FLines.Count) THEN
      Break;
    IF Direction > 0 THEN
      Col := 0
    ELSE
      Col := Length(FLines[LineIndex]) - 1;
  END;
END;

FUNCTION TCodeEditor.GetSelectedText: STRING;
VAR
  StartPos          : TCodePosition;
  EndPos            : TCodePosition;
  I                 : Integer;
BEGIN
  Result := '';
  IF NOT HasSelection THEN
    Exit;

  StartPos := SelectionStart;
  EndPos := SelectionEnd;
  IF StartPos.Line = EndPos.Line THEN
    Exit(Copy(FLines[StartPos.Line], StartPos.Column + 1, EndPos.Column - StartPos.Column));

  Result := Copy(FLines[StartPos.Line], StartPos.Column + 1, MaxInt) + sLineBreak;
  FOR I := StartPos.Line + 1 TO EndPos.Line - 1 DO
    Result := Result + FLines[I] + sLineBreak;
  Result := Result + Copy(FLines[EndPos.Line], 1, EndPos.Column);
END;

FUNCTION TCodeEditor.CompletionPrefix: STRING;
VAR
  LineText          : STRING;
  Index             : Integer;
BEGIN
  Result := '';
  IF (FCaret.Line < 0) OR (FCaret.Line >= FLines.Count) THEN
    Exit;

  LineText := FLines[FCaret.Line];
  Index := EnsureRange(FCaret.Column, 0, Length(LineText));
  WHILE (Index > 0) AND (LineText[Index].IsLetterOrDigit OR (LineText[Index] = '_')) DO
    Dec(Index);

  Result := Copy(LineText, Index + 1, FCaret.Column - Index);
END;

FUNCTION TCodeEditor.CompletionVisible: Boolean;
BEGIN
  Result := Assigned(FCompletionForm) AND FCompletionForm.Visible;
END;

FUNCTION TCodeEditor.CompletionDisplayText(Item: TCodeCompletionItem): STRING;
BEGIN
  Result := Item.Caption;
  IF Item.Detail <> '' THEN
    Result := Result + '    ' + Item.Detail;
END;

FUNCTION TCodeEditor.SignatureVisible: Boolean;
BEGIN
  Result := Assigned(FSignatureForm) AND FSignatureForm.Visible;
END;

FUNCTION TCodeEditor.SignatureFunctionName: STRING;
VAR
  LineText          : STRING;
  Index             : Integer;
  Depth             : Integer;
BEGIN
  Result := '';
  IF (FCaret.Line < 0) OR (FCaret.Line >= FLines.Count) THEN
    Exit;

  LineText := FLines[FCaret.Line];
  Index := EnsureRange(FCaret.Column, 0, Length(LineText));
  Depth := 0;
  WHILE Index > 0 DO BEGIN
    IF CharInSet(LineText[Index], [')', '>']) THEN
      Inc(Depth)
    ELSE IF CharInSet(LineText[Index], ['(', '<']) THEN BEGIN
      IF Depth = 0 THEN BEGIN
        Dec(Index);
        WHILE (Index > 0) AND (LineText[Index].IsWhiteSpace) DO
          Dec(Index);
        WHILE (Index > 0) AND (LineText[Index].IsLetterOrDigit OR (LineText[Index] = '_') OR
          (LineText[Index] = '.')) DO BEGIN
          Result := LineText[Index] + Result;
          Dec(Index);
        END;
        Exit;
      END;
      Dec(Depth);
    END;
    Dec(Index);
  END;
END;

FUNCTION TCodeEditor.SignatureActiveParameter: Integer;
VAR
  LineText          : STRING;
  Index             : Integer;
  Depth             : Integer;
BEGIN
  Result := 0;
  IF (FCaret.Line < 0) OR (FCaret.Line >= FLines.Count) THEN
    Exit;

  LineText := FLines[FCaret.Line];
  Index := EnsureRange(FCaret.Column, 0, Length(LineText));
  Depth := 0;
  WHILE Index > 0 DO BEGIN
    IF CharInSet(LineText[Index], [')', '>']) THEN
      Inc(Depth)
    ELSE IF CharInSet(LineText[Index], ['(', '<']) THEN BEGIN
      IF Depth = 0 THEN
        Exit;
      Dec(Depth);
    END ELSE IF (LineText[Index] = ',') AND (Depth = 0) THEN
      Inc(Result);
    Dec(Index);
  END;
END;

FUNCTION TCodeEditor.SearchVisible: Boolean;
BEGIN
  Result := Assigned(FSearchPanel) AND FSearchPanel.Visible;
END;

FUNCTION TCodeEditor.IsWholeWordMatch(CONST LineText: STRING; Column, MatchLength: Integer):
  Boolean;
VAR
  BeforeChar        : Char;
  AfterChar         : Char;
BEGIN
  BeforeChar := #0;
  AfterChar := #0;
  IF Column > 0 THEN
    BeforeChar := LineText[Column];
  IF Column + MatchLength + 1 <= Length(LineText) THEN
    AfterChar := LineText[Column + MatchLength + 1];

  Result := NOT IsWordChar(BeforeChar) AND NOT IsWordChar(AfterChar);
END;

FUNCTION TCodeEditor.ClipboardTextBytes: UInt64;
VAR
  Data              : THandle;
BEGIN
  Result := 0;
  Clipboard.Open;
  TRY
    IF Clipboard.HasFormat(CF_UNICODETEXT) THEN BEGIN
      Data := Clipboard.GetAsHandle(CF_UNICODETEXT);
      IF Data <> 0 THEN
        Exit(GlobalSize(Data));
    END;

    IF Clipboard.HasFormat(CF_TEXT) THEN BEGIN
      Data := Clipboard.GetAsHandle(CF_TEXT);
      IF Data <> 0 THEN
        Exit(GlobalSize(Data));
    END;
  FINALLY
    Clipboard.Close;
  END;
END;

FUNCTION TCodeEditor.CanPasteFromClipboard: Boolean;
VAR
  Size              : UInt64;
BEGIN
  Result := Clipboard.HasFormat(CF_UNICODETEXT) OR Clipboard.HasFormat(CF_TEXT);
  IF NOT Result THEN
    Exit;

  IF FOptions.MaxPasteBytes <= 0 THEN
    Exit(True);

  Size := ClipboardTextBytes;
  Result := (Size = 0) OR (Size <= UInt64(FOptions.MaxPasteBytes));
  IF NOT Result THEN
    MessageBeep(MB_ICONWARNING);
END;

FUNCTION TCodeEditor.CurrentTextSnapshot: STRING;
BEGIN
  Result := FLines.Text;
END;

FUNCTION TCodeEditor.CaptureUndoState: TCodeUndoItem;
BEGIN
  Result := TCodeUndoItem.Create;
  Result.BeforeText := CurrentTextSnapshot;
  Result.BeforeModified := FModified;
  Result.BeforeCaret := FCaret;
  Result.BeforeAnchor := FAnchor;
  Result.BeforeBreakpoints := BreakpointLines;
  Result.BeforeExecutionLine := FExecutionLine;
END;

PROCEDURE TCodeEditor.RestoreMarkers(CONST BreakpointLines: TArray<Integer>; ExecutionLine:
  Integer);
VAR
  Line              : Integer;
BEGIN
  FBreakpoints.BeginUpdate;
  TRY
    FBreakpoints.Clear;
    FOR Line IN BreakpointLines DO
      IF (Line >= 1) AND (Line <= FLines.Count) AND NOT FBreakpoints.ContainsLine(Line) THEN
        FBreakpoints.AddLine(Line);
  FINALLY
    FBreakpoints.EndUpdate;
  END;

  IF (ExecutionLine >= 1) AND (ExecutionLine <= FLines.Count) THEN
    FExecutionLine := ExecutionLine
  ELSE
    FExecutionLine := -1;
END;

FUNCTION TCodeEditor.CanUndo: Boolean;
BEGIN
  Result := Assigned(FUndoStack) AND (FUndoStack.Count > 0);
END;

FUNCTION TCodeEditor.CanRedo: Boolean;
BEGIN
  Result := Assigned(FRedoStack) AND (FRedoStack.Count > 0);
END;

PROCEDURE TCodeEditor.ClearUndoStack(Stack: TStack<TCodeUndoItem>);
VAR
  Item              : TCodeUndoItem;
BEGIN
  IF NOT Assigned(Stack) THEN
    Exit;

  WHILE Stack.Count > 0 DO BEGIN
    Item := Stack.Pop;
    Item.Free;
  END;
END;

PROCEDURE TCodeEditor.PushUndoItem(Stack: TStack<TCodeUndoItem>; Item: TCodeUndoItem);
VAR
  DropCount         : Integer;
  Items             : TArray<TCodeUndoItem>;
  I                 : Integer;
BEGIN
  IF NOT Assigned(Item) THEN
    Exit;

  IF FMaxUndo <= 0 THEN BEGIN
    Item.Free;
    Exit;
  END;

  Stack.Push(Item);
  DropCount := Stack.Count - FMaxUndo;
  IF DropCount <= 0 THEN
    Exit;

  Items := Stack.ToArray;
  Stack.Clear;
  FOR I := High(Items) DOWNTO 0 DO BEGIN
    IF I >= FMaxUndo THEN
      Items[I].Free
    ELSE
      Stack.Push(Items[I]);
  END;
END;

PROCEDURE TCodeEditor.RestoreUndoState(CONST Text: STRING; CONST Caret, Anchor: TCodePosition;
  CONST BreakpointLines: TArray<Integer>; ExecutionLine: Integer);
BEGIN
  FApplyingUndo := True;
  TRY
    FLines.Text := Text;
    IF FLines.Count = 0 THEN
      FLines.Add('');
    RestoreMarkers(BreakpointLines, ExecutionLine);
    FCaret := NormalizePosition(Caret);
    FAnchor := NormalizePosition(Anchor);
  FINALLY
    FApplyingUndo := False;
  END;

  EnsureCaretVisible;
  LinesChanged(Self);
  Invalidate;
END;

PROCEDURE TCodeEditor.CommitUndoState(Item: TCodeUndoItem);
BEGIN
  IF NOT Assigned(Item) THEN
    Exit;

  Item.AfterText := CurrentTextSnapshot;
  Item.AfterCaret := FCaret;
  Item.AfterAnchor := FAnchor;
  Item.AfterBreakpoints := BreakpointLines;
  Item.AfterExecutionLine := FExecutionLine;

  IF Item.BeforeText = Item.AfterText THEN BEGIN
    Item.Free;
    Exit;
  END;

  PushUndoItem(FUndoStack, Item);
  ClearUndoStack(FRedoStack);
END;

PROCEDURE TCodeEditor.FinishUndoGroup;
BEGIN
  IF NOT Assigned(FActiveUndoItem) THEN
    Exit;

  CommitUndoState(FActiveUndoItem);
  FActiveUndoItem := NIL;
  FActiveUndoGroup := ugNone;
END;

PROCEDURE TCodeEditor.CancelUndoGroup;
BEGIN
  FreeAndNil(FActiveUndoItem);
  FActiveUndoGroup := ugNone;
END;

PROCEDURE TCodeEditor.DoCaretChange;
BEGIN
  IF Assigned(FOnCaretChange) THEN
    FOnCaretChange(Self, FCaret);
END;

PROCEDURE TCodeEditor.DoSelectionChange;
BEGIN
  IF Assigned(FOnSelectionChange) THEN
    FOnSelectionChange(Self, SelectionStart, SelectionEnd);
END;

PROCEDURE TCodeEditor.DoEditStateChanged;
BEGIN
  FModified := True;
END;

FUNCTION TCodeEditor.CanContinueTypingUndo(CONST Value: STRING): Boolean;
BEGIN
  Result := Assigned(FActiveUndoItem) AND
    (FActiveUndoGroup = ugTyping) AND
    (Length(Value) = 1) AND
    NOT HasMultipleSelections AND
    NOT HasSelection AND
    (FCaret.Line = FActiveUndoItem.AfterCaret.Line) AND
    (FCaret.Column = FActiveUndoItem.AfterCaret.Column) AND
    (FAnchor.Line = FCaret.Line) AND
    (FAnchor.Column = FCaret.Column);
END;

PROCEDURE TCodeEditor.InsertTypedText(CONST Value: STRING);
BEGIN
  IF FReadOnly THEN BEGIN
    MessageBeep(MB_ICONWARNING);
    Exit;
  END;

  IF HasMultipleSelections THEN BEGIN
    FinishUndoGroup;
    ReplaceAllSelections(Value);
    Exit;
  END;

  IF NOT CanContinueTypingUndo(Value) THEN BEGIN
    FinishUndoGroup;
    FActiveUndoItem := CaptureUndoState;
    FActiveUndoGroup := ugTyping;
  END;

  InsertText(Value, False);

  FActiveUndoItem.AfterText := CurrentTextSnapshot;
  FActiveUndoItem.AfterCaret := FCaret;
  FActiveUndoItem.AfterAnchor := FAnchor;
  ClearUndoStack(FRedoStack);
END;

PROCEDURE TCodeEditor.PasteFromClipboard;
VAR
  Text              : STRING;
BEGIN
  IF FReadOnly THEN BEGIN
    MessageBeep(MB_ICONWARNING);
    Exit;
  END;

  IF NOT CanPasteFromClipboard THEN
    Exit;

  Text := Clipboard.AsText;
  IF Text = '' THEN
    Exit;

  FinishUndoGroup;
  InsertText(Text);
END;

PROCEDURE TCodeEditor.CopyToClipboard;
BEGIN
  // Don't clobber the clipboard when there is nothing selected.
  IF HasSelection THEN
    Clipboard.AsText := SelectedText;
END;

PROCEDURE TCodeEditor.CutToClipboard;
VAR
  UndoItem          : TCodeUndoItem;
BEGIN
  IF NOT HasSelection THEN
    Exit;

  Clipboard.AsText := SelectedText;
  IF FReadOnly THEN
    Exit;

  IF HasMultipleSelections THEN BEGIN
    ReplaceAllSelections('');
    Exit;
  END;

  FinishUndoGroup;
  UndoItem := CaptureUndoState;
  DeleteSelection;
  LinesChanged(Self);
  CommitUndoState(UndoItem);
END;

PROCEDURE TCodeEditor.Undo;
VAR
  Item              : TCodeUndoItem;
BEGIN
  FinishUndoGroup;
  IF NOT CanUndo THEN
    Exit;

  Item := FUndoStack.Pop;
  RestoreUndoState(Item.BeforeText, Item.BeforeCaret, Item.BeforeAnchor,
    Item.BeforeBreakpoints, Item.BeforeExecutionLine);
  // Undoing back to the pre-edit state restores the pre-edit Modified flag.
  FModified := Item.BeforeModified;
  Change;
  PushUndoItem(FRedoStack, Item);
END;

PROCEDURE TCodeEditor.Redo;
VAR
  Item              : TCodeUndoItem;
BEGIN
  FinishUndoGroup;
  IF NOT CanRedo THEN
    Exit;

  Item := FRedoStack.Pop;
  RestoreUndoState(Item.AfterText, Item.AfterCaret, Item.AfterAnchor,
    Item.AfterBreakpoints, Item.AfterExecutionLine);
  FModified := True;
  Change;
  PushUndoItem(FUndoStack, Item);
END;

PROCEDURE TCodeEditor.ClearUndo;
BEGIN
  CancelUndoGroup;
  ClearUndoStack(FUndoStack);
  ClearUndoStack(FRedoStack);
END;

PROCEDURE TCodeEditor.ExecuteCommand(Command: TCodeEditorCommand);
BEGIN
  CASE Command OF
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
  END;
END;

PROCEDURE TCodeEditor.CreateCompletionPopup;
BEGIN
  IF Assigned(FCompletionForm) THEN
    Exit;

  FCompletionForm := TForm.CreateNew(NIL);
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
END;

PROCEDURE TCodeEditor.PopulateCompletionPopup;
VAR
  Item              : TCodeCompletionItem;
BEGIN
  FCompletionList.Items.BeginUpdate;
  TRY
    FCompletionList.Clear;
    FOR Item IN FCompletionItems DO
      FCompletionList.Items.AddObject(CompletionDisplayText(Item), Item);
    IF FCompletionList.Items.Count > 0 THEN
      FCompletionList.ItemIndex := 0;
  FINALLY
    FCompletionList.Items.EndUpdate;
  END;
END;

PROCEDURE TCodeEditor.ShowCompletion(TriggerChar: Char; ExplicitRequest: Boolean);
VAR
  Context           : TCodeCompletionContext;
  Prefix            : STRING;
  P                 : TPoint;
  LineText          : STRING;
  EndColumn         : Integer;
BEGIN
  IF NOT Assigned(FCompletionProvider) THEN
    Exit;

  HideTemplates;

  Prefix := CompletionPrefix;
  FCompletionStart := FCaret;
  IF TriggerChar = #0 THEN
    Dec(FCompletionStart.Column, Length(Prefix));
  FCompletionEnd := FCaret;

  IF (FCaret.Line >= 0) AND (FCaret.Line < FLines.Count) THEN BEGIN
    LineText := FLines[FCaret.Line];
    EndColumn := EnsureRange(FCaret.Column, 0, Length(LineText));
    WHILE (EndColumn < Length(LineText)) AND
      (LineText[EndColumn + 1].IsLetterOrDigit OR (LineText[EndColumn + 1] = '_')) DO
      Inc(EndColumn);
    FCompletionEnd := TCodePosition.Create(FCaret.Line, EndColumn);
  END;

  FreeAndNil(FCompletionItems);
  FCompletionItems := TCodeCompletionItems.Create(True);

  Context.Line := FCaret.Line;
  Context.Column := FCaret.Column;
  Context.Prefix := Prefix;
  Context.TriggerChar := TriggerChar;
  Context.LineText := FLines[FCaret.Line];
  Context.ExplicitRequest := ExplicitRequest;
  FCompletionProvider.GetCompletions(Context, FCompletionItems);

  IF FCompletionItems.Count = 0 THEN BEGIN
    HideCompletion;
    Exit;
  END;

  CreateCompletionPopup;
  PopulateCompletionPopup;
  FCompletionForm.PopupParent := GetParentForm(Self);
  P := ClientToScreen(CaretToPoint(FCaret));
  Inc(P.Y, FLineHeight);
  FCompletionForm.SetBounds(P.X, P.Y, FCompletionForm.Width, FCompletionForm.Height);
  FCompletionForm.Show;
  SetFocus;
END;

PROCEDURE TCodeEditor.HideCompletion;
BEGIN
  IF Assigned(FCompletionForm) THEN
    FCompletionForm.Hide;
END;

PROCEDURE TCodeEditor.AcceptCompletion;
VAR
  Item              : TCodeCompletionItem;
  LineText          : STRING;
  StartPos          : TCodePosition;
  EndPos            : TCodePosition;
  UndoItem          : TCodeUndoItem;
BEGIN
  IF NOT CompletionVisible OR (FCompletionList.ItemIndex < 0) THEN
    Exit;

  Item := TCodeCompletionItem(FCompletionList.Items.Objects[FCompletionList.ItemIndex]);
  HideCompletion;

  StartPos := NormalizePosition(FCompletionStart);
  EndPos := NormalizePosition(FCompletionEnd);
  IF (StartPos.Line <> EndPos.Line) OR (StartPos.Line < 0) OR (StartPos.Line >= FLines.Count) THEN
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
END;

PROCEDURE TCodeEditor.CompletionListClick(Sender: TObject);
BEGIN
  SetFocus;
END;

PROCEDURE TCodeEditor.CompletionListDblClick(Sender: TObject);
BEGIN
  AcceptCompletion;
END;

PROCEDURE TCodeEditor.MoveCompletionSelection(Delta: Integer);
VAR
  NewIndex          : Integer;
BEGIN
  IF NOT CompletionVisible OR (FCompletionList.Items.Count = 0) THEN
    Exit;

  NewIndex := EnsureRange(FCompletionList.ItemIndex + Delta, 0, FCompletionList.Items.Count - 1);
  FCompletionList.ItemIndex := NewIndex;
END;

FUNCTION TCodeEditor.ActiveLanguageName: STRING;
BEGIN
  IF Assigned(FHighlighter) THEN
    Result := FHighlighter.LanguageName
  ELSE
    Result := '';
END;

FUNCTION TCodeEditor.TemplatesVisible: Boolean;
BEGIN
  Result := Assigned(FTemplateForm) AND FTemplateForm.Visible;
END;

FUNCTION TCodeEditor.TemplateDisplayText(Template: TCodeTemplate): STRING;
BEGIN
  Result := Template.Name;
  IF Template.Description <> '' THEN
    Result := Result + '    ' + Template.Description;
END;

PROCEDURE TCodeEditor.CreateTemplatePopup;
BEGIN
  IF Assigned(FTemplateForm) THEN
    Exit;

  FTemplateForm := TForm.CreateNew(NIL);
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
END;

PROCEDURE TCodeEditor.PopulateTemplatePopup;
VAR
  Template          : TCodeTemplate;
BEGIN
  FTemplateList.Items.BeginUpdate;
  TRY
    FTemplateList.Clear;
    FOR Template IN FTemplateMatches DO
      FTemplateList.Items.AddObject(TemplateDisplayText(Template), Template);
    IF FTemplateList.Items.Count > 0 THEN
      FTemplateList.ItemIndex := 0;
  FINALLY
    FTemplateList.Items.EndUpdate;
  END;
END;

PROCEDURE TCodeEditor.ShowTemplates(ExplicitRequest: Boolean);
VAR
  Prefix            : STRING;
  P                 : TPoint;
  PopupHeight       : Integer;
BEGIN
  IF FReadOnly OR NOT Assigned(FTemplateProvider) THEN
    Exit;

  HideCompletion;
  HideSignatureHelp;

  Prefix := CompletionPrefix;
  FTemplateStart := FCaret;
  Dec(FTemplateStart.Column, Length(Prefix));
  FTemplateEnd := FCaret;

  IF NOT Assigned(FTemplateMatches) THEN
    FTemplateMatches := TList<TCodeTemplate>.Create;
  FTemplateMatches.Clear;
  FTemplateProvider.GetTemplates(ActiveLanguageName, Prefix, FTemplateMatches);

  IF (FTemplateMatches.Count = 0) AND (Prefix <> '') AND ExplicitRequest THEN BEGIN
    // Nothing starts with the word at the caret: offer the full list and
    // leave the word alone.
    FTemplateStart := FCaret;
    FTemplateProvider.GetTemplates(ActiveLanguageName, '', FTemplateMatches);
  END;

  IF FTemplateMatches.Count = 0 THEN BEGIN
    HideTemplates;
    Exit;
  END;

  IF ExplicitRequest AND (Prefix <> '') AND (FTemplateMatches.Count = 1) AND
    (FTemplateStart.Column < FTemplateEnd.Column) THEN BEGIN
    // Unique match for the typed word: expand it immediately, like the IDE.
    HideTemplates;
    InsertTemplateRange(FTemplateMatches[0], FTemplateStart, FTemplateEnd);
    Exit;
  END;

  CreateTemplatePopup;
  PopulateTemplatePopup;
  PopupHeight := FTemplateList.ItemHeight * Min(FTemplateMatches.Count, 12) + 8;
  FTemplateForm.PopupParent := GetParentForm(Self);
  P := ClientToScreen(CaretToPoint(FCaret));
  Inc(P.Y, FLineHeight);
  FTemplateForm.SetBounds(P.X, P.Y, FTemplateForm.Width, Max(PopupHeight, FTemplateList.ItemHeight +
    8));
  FTemplateForm.Show;
  SetFocus;
END;

PROCEDURE TCodeEditor.HideTemplates;
BEGIN
  IF Assigned(FTemplateForm) THEN
    FTemplateForm.Hide;
END;

PROCEDURE TCodeEditor.AcceptTemplate;
VAR
  Template          : TCodeTemplate;
BEGIN
  IF NOT TemplatesVisible OR (FTemplateList.ItemIndex < 0) THEN
    Exit;

  Template := TCodeTemplate(FTemplateList.Items.Objects[FTemplateList.ItemIndex]);
  HideTemplates;
  InsertTemplateRange(Template, FTemplateStart, FTemplateEnd);
END;

PROCEDURE TCodeEditor.TemplateListDblClick(Sender: TObject);
BEGIN
  AcceptTemplate;
END;

PROCEDURE TCodeEditor.MoveTemplateSelection(Delta: Integer);
VAR
  NewIndex          : Integer;
BEGIN
  IF NOT TemplatesVisible OR (FTemplateList.Items.Count = 0) THEN
    Exit;

  NewIndex := EnsureRange(FTemplateList.ItemIndex + Delta, 0, FTemplateList.Items.Count - 1);
  FTemplateList.ItemIndex := NewIndex;
END;

PROCEDURE TCodeEditor.InsertTemplateRange(Template: TCodeTemplate;
  CONST StartPos, EndPos: TCodePosition);
VAR
  UndoItem          : TCodeUndoItem;
  SPos              : TCodePosition;
  EPos              : TCodePosition;
  LineText          : STRING;
  Indent            : STRING;
  Expanded          : STRING;
  CaretLine         : Integer;
  CaretColumn       : Integer;
  HasCaret          : Boolean;
  I                 : Integer;
BEGIN
  IF FReadOnly OR NOT Assigned(Template) THEN
    Exit;

  SPos := NormalizePosition(StartPos);
  EPos := NormalizePosition(EndPos);

  FinishUndoGroup;
  UndoItem := CaptureUndoState;

  ClearExtraSelections;
  IF ComparePositions(SPos, EPos) < 0 THEN BEGIN
    // Consume the typed prefix the template was matched against.
    FAnchor := SPos;
    FCaret := EPos;
    DeleteSelection;
  END ELSE BEGIN
    FCaret := SPos;
    FAnchor := SPos;
  END;

  // Continuation lines inherit the current line's leading whitespace.
  LineText := FLines[FCaret.Line];
  Indent := '';
  I := 1;
  WHILE (I <= Length(LineText)) AND CharInSet(LineText[I], [' ', #9]) DO BEGIN
    Indent := Indent + LineText[I];
    Inc(I);
  END;

  Expanded := ExpandCodeTemplate(Template.Code.Text, Indent, CaretLine, CaretColumn, HasCaret);
  SPos := FCaret;
  InsertText(Expanded, False);

  IF HasCaret THEN BEGIN
    IF CaretLine = 0 THEN
      FCaret := TCodePosition.Create(SPos.Line, SPos.Column + CaretColumn)
    ELSE
      FCaret := TCodePosition.Create(SPos.Line + CaretLine, CaretColumn);
    FCaret := NormalizePosition(FCaret);
    FAnchor := FCaret;
    EnsureCaretVisible;
    Invalidate;
  END;

  CommitUndoState(UndoItem);
END;

PROCEDURE TCodeEditor.InsertTemplate(Template: TCodeTemplate);
BEGIN
  IF HasSelection THEN
    InsertTemplateRange(Template, SelectionStart, SelectionEnd)
  ELSE
    InsertTemplateRange(Template, FCaret, FCaret);
END;

PROCEDURE TCodeEditor.TriggerTemplates;
BEGIN
  FinishUndoGroup;
  ShowTemplates(True);
END;

PROCEDURE TCodeEditor.CreateSignaturePopup;
BEGIN
  IF Assigned(FSignatureForm) THEN
    Exit;

  FSignatureForm := TForm.CreateNew(NIL);
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
END;

PROCEDURE TCodeEditor.PopulateSignaturePopup;
VAR
  Item              : TCodeSignatureItem;
  I                 : Integer;
  Text              : STRING;
BEGIN
  IF NOT Assigned(FSignatureItems) OR (FSignatureItems.Count = 0) THEN
    Exit;

  Item := FSignatureItems[0];
  Text := Item.Name + '(';
  FOR I := 0 TO Item.Parameters.Count - 1 DO BEGIN
    IF I > 0 THEN
      Text := Text + ', ';
    IF I = FSignatureContext.ActiveParameter THEN
      Text := Text + '[' + Item.Parameters[I] + ']'
    ELSE
      Text := Text + Item.Parameters[I];
  END;
  Text := Text + ')';
  IF Item.Detail <> '' THEN
    Text := Text + sLineBreak + Item.Detail;
  FSignatureLabel.Caption := Text;
END;

PROCEDURE TCodeEditor.ShowSignatureHelp(TriggerChar: Char; ExplicitRequest: Boolean);
VAR
  P                 : TPoint;
BEGIN
  IF NOT Assigned(FCompletionProvider) THEN
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

  IF FSignatureContext.FunctionName = '' THEN BEGIN
    HideSignatureHelp;
    Exit;
  END;

  FCompletionProvider.GetSignatureHelp(FSignatureContext, FSignatureItems);
  IF FSignatureItems.Count = 0 THEN BEGIN
    HideSignatureHelp;
    Exit;
  END;

  CreateSignaturePopup;
  PopulateSignaturePopup;
  FSignatureForm.PopupParent := GetParentForm(Self);
  P := ClientToScreen(CaretToPoint(FCaret));
  Inc(P.Y, FLineHeight + 4);
  FSignatureForm.SetBounds(P.X, P.Y, FSignatureForm.Width, FSignatureForm.Height);
  FSignatureForm.Show;
  SetFocus;
END;

PROCEDURE TCodeEditor.UpdateSignatureHelp(TriggerChar: Char);
BEGIN
  IF SignatureVisible THEN
    ShowSignatureHelp(TriggerChar, False);
END;

PROCEDURE TCodeEditor.HideSignatureHelp;
BEGIN
  IF Assigned(FSignatureForm) THEN
    FSignatureForm.Hide;
END;

PROCEDURE TCodeEditor.TriggerCompletion;
BEGIN
  FinishUndoGroup;
  ShowCompletion(#0, True);
END;

PROCEDURE TCodeEditor.TriggerSignatureHelp;
BEGIN
  ShowSignatureHelp(#0, True);
END;

PROCEDURE TCodeEditor.CreateSearchPanel;

  FUNCTION NewButton(CONST CaptionText, HintText: STRING; WidthValue: Integer): TSpeedButton;
  BEGIN
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
  END;

BEGIN
  IF Assigned(FSearchPanel) THEN
    Exit;

  FSearchPanel := TPanel.Create(Self);
  FSearchPanel.Parent := Self;
  FSearchPanel.BevelOuter := bvRaised;
  FSearchPanel.ParentBackground := False;
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
  FSearchStatusLabel.Transparent := True;
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

  RestyleSearchPanel;
  LayoutSearchPanel;
END;

PROCEDURE TCodeEditor.SetSearchButtonGlyph(Button: TSpeedButton; CONST Kind: STRING);
VAR
  Bmp               : Vcl.Graphics.TBitmap;
  Theme             : TCodeEditorThemeColors;
  GlyphColor        : TColor;
BEGIN
  // Glyphs follow the theme's text colour; hardcoded white vanished on light skins.
  Theme := ActiveTheme;
  TRY
    GlyphColor := Theme.Text;
  FINALLY
    Theme.Free;
  END;
  Bmp := Vcl.Graphics.TBitmap.Create;
  TRY
    Bmp.SetSize(16, 16);
    Bmp.Canvas.Brush.Color := clFuchsia;
    Bmp.Canvas.FillRect(Rect(0, 0, 16, 16));
    Bmp.Transparent := True;
    Bmp.TransparentColor := clFuchsia;
    Bmp.Canvas.Pen.Color := GlyphColor;
    Bmp.Canvas.Pen.Width := 2;

    IF Kind = 'expand' THEN BEGIN
      Bmp.Canvas.MoveTo(4, 6);
      Bmp.Canvas.LineTo(8, 10);
      Bmp.Canvas.LineTo(12, 6);
    END ELSE IF Kind = 'collapse' THEN BEGIN
      Bmp.Canvas.MoveTo(4, 10);
      Bmp.Canvas.LineTo(8, 6);
      Bmp.Canvas.LineTo(12, 10);
    END ELSE IF Kind = 'prev' THEN BEGIN
      Bmp.Canvas.MoveTo(8, 3);
      Bmp.Canvas.LineTo(8, 13);
      Bmp.Canvas.MoveTo(4, 7);
      Bmp.Canvas.LineTo(8, 3);
      Bmp.Canvas.LineTo(12, 7);
    END ELSE IF Kind = 'next' THEN BEGIN
      Bmp.Canvas.MoveTo(8, 3);
      Bmp.Canvas.LineTo(8, 13);
      Bmp.Canvas.MoveTo(4, 9);
      Bmp.Canvas.LineTo(8, 13);
      Bmp.Canvas.LineTo(12, 9);
    END ELSE IF Kind = 'close' THEN BEGIN
      Bmp.Canvas.MoveTo(4, 4);
      Bmp.Canvas.LineTo(12, 12);
      Bmp.Canvas.MoveTo(12, 4);
      Bmp.Canvas.LineTo(4, 12);
    END;

    Button.Caption := '';
    Button.Glyph.Assign(Bmp);
    Button.NumGlyphs := 1;
    StyleSearchButton(Button);
  FINALLY
    Bmp.Free;
  END;
END;

PROCEDURE TCodeEditor.StyleSearchEdit(Edit: TEdit);
BEGIN
  // AutoSize keeps the edit at text height; LayoutSearchPanel centres it in its
  // row so the text sits on the row's vertical middle instead of hanging at the
  // top of an oversized box.
  Edit.AutoSize := True;
  Edit.ParentColor := False;
  Edit.StyleElements := [];
  Edit.Font.Name := 'Segoe UI';
  Edit.Font.Size := 11;
  Edit.BorderStyle := bsSingle;
  Edit.Ctl3D := False;
END;

PROCEDURE TCodeEditor.StyleSearchButton(Button: TSpeedButton);
BEGIN
  Button.Flat := True;
  Button.Transparent := True;
  Button.StyleElements := [];
  Button.Font.Name := 'Segoe UI';
  Button.Font.Size := 11;
END;

PROCEDURE TCodeEditor.RestyleSearchPanel;
VAR
  Theme             : TCodeEditorThemeColors;
  PanelColor        : TColor;
  EditColor         : TColor;

  PROCEDURE StyleEditColors(Edit: TEdit);
  BEGIN
    Edit.Color := EditColor;
    Edit.Font.Color := Theme.Text;
  END;

BEGIN
  // Follow the editor's active theme (which itself follows the DevExpress skin)
  // instead of the original hardcoded VS Code dark colours.
  IF NOT Assigned(FSearchPanel) THEN
    Exit;
  Theme := ActiveTheme;
  TRY
    IF IsDarkTheme(Theme) THEN BEGIN
      PanelColor := ShiftBrightness(Theme.Background, 18);
      EditColor := ShiftBrightness(Theme.Background, -8);
    END ELSE BEGIN
      PanelColor := ShiftBrightness(Theme.Background, -14);
      EditColor := Theme.Background;
    END;
    FSearchPanel.Color := PanelColor;
    StyleEditColors(FSearchEdit);
    StyleEditColors(FReplaceEdit);
    FSearchStatusLabel.Font.Color := Theme.Text;
    FSearchExpandButton.Font.Color := Theme.Text;
    FSearchMatchCaseButton.Font.Color := Theme.Text;
    FSearchWholeWordButton.Font.Color := Theme.Text;
    FSearchRegexButton.Font.Color := Theme.Text;
    FSearchPrevButton.Font.Color := Theme.Text;
    FSearchNextButton.Font.Color := Theme.Text;
    FSearchReplaceButton.Font.Color := Theme.Text;
    FSearchReplaceAllButton.Font.Color := Theme.Text;
    FSearchCloseButton.Font.Color := Theme.Text;
    // Redraw the glyph buttons with the theme's pen colour.
    IF FSearchExpanded THEN
      SetSearchButtonGlyph(FSearchExpandButton, 'collapse')
    ELSE
      SetSearchButtonGlyph(FSearchExpandButton, 'expand');
    SetSearchButtonGlyph(FSearchPrevButton, 'prev');
    SetSearchButtonGlyph(FSearchNextButton, 'next');
    SetSearchButtonGlyph(FSearchCloseButton, 'close');
  FINALLY
    Theme.Free;
  END;
END;

PROCEDURE TCodeEditor.LayoutSearchPanel;
VAR
  X                 : Integer;
  TopOffset         : Integer;
  PanelWidth        : Integer;
  EditWidth         : Integer;
  ButtonTop         : Integer;
  BoundsRect        : TRect;
  AvailableWidth    : Integer;
BEGIN
  IF NOT Assigned(FSearchPanel) THEN
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
  // The edits are AutoSize (text height); centre them on the 34px button row so
  // the text sits on the row's vertical middle.
  FSearchEdit.SetBounds(X, TopOffset + Max(0, (34 - FSearchEdit.Height) DIV 2),
    EditWidth, FSearchEdit.Height);
  FReplaceEdit.SetBounds(X, TopOffset + 42 + Max(0, (34 - FReplaceEdit.Height) DIV 2),
    EditWidth, FReplaceEdit.Height);
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

  FSearchReplaceButton.SetBounds(FReplaceEdit.Left + FReplaceEdit.Width + 10, TopOffset + 42, 44,
    34);
  FSearchReplaceAllButton.SetBounds(FSearchReplaceButton.Left + 48, TopOffset + 42, 62, 34);

  FReplaceEdit.Visible := FSearchExpanded;
  FSearchReplaceButton.Visible := FSearchExpanded;
  FSearchReplaceAllButton.Visible := FSearchExpanded;
  IF FSearchExpanded THEN BEGIN
    SetSearchButtonGlyph(FSearchExpandButton, 'collapse');
  END ELSE BEGIN
    SetSearchButtonGlyph(FSearchExpandButton, 'expand');
  END;
END;

PROCEDURE TCodeEditor.UpdateSearch;
VAR
  LineIndex         : Integer;
  SourceLine        : STRING;
  Haystack          : STRING;
  SearchText        : STRING;
  Needle            : STRING;
  MatchCase         : Boolean;
  WholeWord         : Boolean;
  FoundAt           : Integer;
  Offset            : Integer;
  Options           : TRegExOptions;
  Matches           : TMatchCollection;
  Match             : TMatch;
  SearchMatch       : TCodeSearchMatch;
BEGIN
  IF NOT Assigned(FSearchMatches) OR FSearchUpdating THEN
    Exit;

  FSearchUpdating := True;
  TRY
    FSearchMatches.Clear;
    FSearchIndex := -1;
    SearchText := FSearchEdit.Text;
    IF SearchText = '' THEN BEGIN
      FSearchStatusLabel.Caption := 'No results';
      Invalidate;
      Exit;
    END;

    MatchCase := FSearchMatchCaseButton.Down;
    WholeWord := FSearchWholeWordButton.Down;
    IF MatchCase THEN
      Needle := SearchText
    ELSE
      Needle := LowerCase(SearchText);

    FOR LineIndex := 0 TO FLines.Count - 1 DO BEGIN
      SourceLine := FLines[LineIndex];
      IF FSearchRegexButton.Down THEN BEGIN
        Options := [];
        IF NOT MatchCase THEN
          Include(Options, roIgnoreCase);
        TRY
          Matches := TRegEx.Matches(SourceLine, SearchText, Options);
          FOR Match IN Matches DO
            IF Match.Length > 0 THEN BEGIN
              // TMatch.Index is 1-based; stored columns are 0-based.
              IF WholeWord AND NOT IsWholeWordMatch(SourceLine, Match.Index - 1, Match.Length) THEN
                Continue;
              SearchMatch.Line := LineIndex;
              SearchMatch.Column := Match.Index - 1;
              SearchMatch.Length := Match.Length;
              FSearchMatches.Add(SearchMatch);
            END;
        EXCEPT
          FSearchStatusLabel.Caption := 'Invalid regex';
          Invalidate;
          Exit;
        END;
      END ELSE BEGIN
        IF MatchCase THEN
          Haystack := SourceLine
        ELSE
          Haystack := LowerCase(SourceLine);
        Offset := 1;
        REPEAT
          FoundAt := PosEx(Needle, Haystack, Offset);
          IF FoundAt = 0 THEN
            Break;
          IF NOT WholeWord OR IsWholeWordMatch(SourceLine, FoundAt - 1, Length(Needle)) THEN BEGIN
            SearchMatch.Line := LineIndex;
            SearchMatch.Column := FoundAt - 1;
            SearchMatch.Length := Length(Needle);
            FSearchMatches.Add(SearchMatch);
          END;
          Offset := FoundAt + Length(Needle);
        UNTIL Offset > Length(Haystack);
      END;
    END;

    IF FSearchMatches.Count = 0 THEN
      FSearchStatusLabel.Caption := 'No results'
    ELSE BEGIN
      FSearchIndex := 0;
      FSearchStatusLabel.Caption := Format('%d of %d', [FSearchIndex + 1, FSearchMatches.Count]);
    END;
    Invalidate;
  FINALLY
    FSearchUpdating := False;
  END;
END;

PROCEDURE TCodeEditor.SelectSearchMatch(Index: Integer);
VAR
  Match             : TCodeSearchMatch;
BEGIN
  IF (Index < 0) OR (Index >= FSearchMatches.Count) THEN
    Exit;

  FSearchIndex := Index;
  Match := FSearchMatches[FSearchIndex];
  FAnchor := TCodePosition.Create(Match.Line, Match.Column);
  FCaret := TCodePosition.Create(Match.Line, Match.Column + Match.Length);
  EnsureCaretVisible;
  FSearchStatusLabel.Caption := Format('%d of %d', [FSearchIndex + 1, FSearchMatches.Count]);
  Invalidate;
END;

PROCEDURE TCodeEditor.FindNextMatch;
BEGIN
  IF FSearchMatches.Count = 0 THEN
    Exit;
  SelectSearchMatch((FSearchIndex + 1) MOD FSearchMatches.Count);
END;

PROCEDURE TCodeEditor.FindPreviousMatch;
BEGIN
  IF FSearchMatches.Count = 0 THEN
    Exit;
  SelectSearchMatch((FSearchIndex + FSearchMatches.Count - 1) MOD FSearchMatches.Count);
END;

PROCEDURE TCodeEditor.ReplaceCurrentMatch;
VAR
  I                 : Integer;
BEGIN
  IF FSearchMatches.Count = 0 THEN
    Exit;

  SelectSearchMatch(FSearchIndex);
  SelectedText := FReplaceEdit.Text;    // LinesChanged refreshes FSearchMatches

  // Continue from the next match after the replacement instead of match #1.
  FOR I := 0 TO FSearchMatches.Count - 1 DO
    IF (FSearchMatches[I].Line > FCaret.Line) OR
      ((FSearchMatches[I].Line = FCaret.Line) AND (FSearchMatches[I].Column >= FCaret.Column)) THEN
        BEGIN
      SelectSearchMatch(I);
      Exit;
    END;
  IF FSearchMatches.Count > 0 THEN
    SelectSearchMatch(0);
END;

PROCEDURE TCodeEditor.ReplaceAllMatches;
VAR
  UndoItem          : TCodeUndoItem;
  I                 : Integer;
  Match             : TCodeSearchMatch;
  LineText          : STRING;
BEGIN
  IF FSearchMatches.Count = 0 THEN
    Exit;

  FinishUndoGroup;
  UndoItem := CaptureUndoState;
  FLines.BeginUpdate;
  TRY
    FOR I := FSearchMatches.Count - 1 DOWNTO 0 DO BEGIN
      Match := FSearchMatches[I];
      LineText := FLines[Match.Line];
      Delete(LineText, Match.Column + 1, Match.Length);
      Insert(FReplaceEdit.Text, LineText, Match.Column + 1);
      FLines[Match.Line] := LineText;
    END;
  FINALLY
    FLines.EndUpdate;                   // fires LinesChanged once, which re-runs the search
  END;
  CommitUndoState(UndoItem);
END;

PROCEDURE TCodeEditor.HideSearchPanel;
BEGIN
  IF Assigned(FSearchPanel) THEN
    FSearchPanel.Hide;
  IF Assigned(FSearchMatches) THEN
    FSearchMatches.Clear;
  FSearchIndex := -1;
  Invalidate;
  SetFocus;
END;

PROCEDURE TCodeEditor.SearchTextChanged(Sender: TObject);
BEGIN
  UpdateSearch;
END;

PROCEDURE TCodeEditor.SearchEditKeyDown(Sender: TObject; VAR Key: Word; Shift: TShiftState);
BEGIN
  CASE Key OF
    VK_ESCAPE: BEGIN
        HideSearchPanel;
        Key := 0;
      END;
    VK_RETURN: BEGIN
        IF Sender = FReplaceEdit THEN
          ReplaceCurrentMatch
        ELSE IF ssShift IN Shift THEN
          FindPreviousMatch
        ELSE
          FindNextMatch;
        Key := 0;
      END;
  END;
END;

PROCEDURE TCodeEditor.SearchEditKeyPress(Sender: TObject; VAR Key: Char);
BEGIN
  IF (Key = #13) OR (Key = #27) THEN
    Key := #0;
END;

PROCEDURE TCodeEditor.SearchButtonClick(Sender: TObject);
BEGIN
  IF Sender = FSearchPrevButton THEN
    FindPreviousMatch
  ELSE IF Sender = FSearchNextButton THEN
    FindNextMatch
  ELSE IF Sender = FSearchCloseButton THEN
    HideSearchPanel
  ELSE IF Sender = FSearchReplaceButton THEN
    ReplaceCurrentMatch
  ELSE IF Sender = FSearchReplaceAllButton THEN
    ReplaceAllMatches
  ELSE
    UpdateSearch;
END;

PROCEDURE TCodeEditor.SearchExpandClick(Sender: TObject);
BEGIN
  FSearchExpanded := NOT FSearchExpanded;
  LayoutSearchPanel;
END;

PROCEDURE TCodeEditor.SeedSearchFromSelection;
VAR
  Seed              : STRING;
BEGIN
  IF HasSelection AND (SelectionStart.Line = SelectionEnd.Line) THEN BEGIN
    Seed := GetSelectedText;
    IF (Seed <> '') AND (FSearchEdit.Text <> Seed) THEN
      FSearchEdit.Text := Seed;
  END;
END;

PROCEDURE TCodeEditor.ShowFind;
BEGIN
  CreateSearchPanel;
  FSearchExpanded := False;
  RestyleSearchPanel; // pick up any skin change since the panel was created
  LayoutSearchPanel;
  FSearchPanel.Show;
  FSearchPanel.BringToFront;
  SeedSearchFromSelection;
  UpdateSearch;
  FSearchEdit.SetFocus;
  FSearchEdit.SelectAll;
END;

PROCEDURE TCodeEditor.ShowReplace;
BEGIN
  CreateSearchPanel;
  FSearchExpanded := True;
  RestyleSearchPanel;
  LayoutSearchPanel;
  FSearchPanel.Show;
  FSearchPanel.BringToFront;
  SeedSearchFromSelection;
  UpdateSearch;
  FSearchEdit.SetFocus;
  FSearchEdit.SelectAll;
END;

PROCEDURE TCodeEditor.SetSelectedText(CONST Value: STRING);
VAR
  UndoItem          : TCodeUndoItem;
BEGIN
  IF FReadOnly THEN
    Exit;

  IF HasMultipleSelections THEN BEGIN
    ReplaceAllSelections(Value);
    Exit;
  END;

  FinishUndoGroup;
  UndoItem := CaptureUndoState;
  DeleteSelection;
  InsertText(Value, False);
  CommitUndoState(UndoItem);
END;

PROCEDURE TCodeEditor.ClearExtraSelections;
BEGIN
  IF Assigned(FSelections) THEN
    FSelections.Clear;
END;

PROCEDURE TCodeEditor.AddSelectionRange(CONST Anchor, Caret: TCodePosition);
VAR
  Range             : TCodeSelectionRange;
BEGIN
  Range.Anchor := NormalizePosition(Anchor);
  Range.Caret := NormalizePosition(Caret);
  IF ComparePositions(Range.Anchor, Range.Caret) <> 0 THEN
    FSelections.Add(Range);
END;

PROCEDURE TCodeEditor.AddNextSelectionOccurrence;
BEGIN
  SelectNextOccurrence;
END;

PROCEDURE TCodeEditor.SelectAllSelectionOccurrences;
BEGIN
  SelectAllOccurrences;
END;

PROCEDURE TCodeEditor.ClearMultipleSelections;
BEGIN
  ClearExtraSelections;
  Invalidate;
  DoSelectionChange;
END;

PROCEDURE TCodeEditor.SelectNextOccurrence;
VAR
  Needle            : STRING;
  StartPos          : TCodePosition;
  LineIndex         : Integer;
  FoundAt           : Integer;
  SearchStart       : Integer;
  ExistingEnd       : TCodePosition;
  ScannedLines      : Integer;
  TotalLines        : Integer;
BEGIN
  IF NOT HasSelection THEN
    SelectWordAtCaret;
  IF NOT HasSelection THEN
    Exit;

  Needle := GetSelectedText;
  IF Needle = '' THEN
    Exit;

  ExistingEnd := SelectionEnd;
  IF HasMultipleSelections THEN
    ExistingEnd := RangeEnd(FSelections[FSelections.Count - 1]);

  // Scan forward from the last selection and wrap past end-of-file back to the
  // top, skipping occurrences that are already selected; the scan gives up once
  // every line has been visited (i.e. all occurrences are selected).
  StartPos := ExistingEnd;
  TotalLines := FLines.Count;
  LineIndex := StartPos.Line;
  SearchStart := StartPos.Column + 1;
  ScannedLines := 0;
  WHILE ScannedLines <= TotalLines DO BEGIN
    REPEAT
      FoundAt := PosEx(Needle, FLines[LineIndex], SearchStart);
      IF FoundAt > 0 THEN BEGIN
        IF NOT OccurrenceAlreadySelected(TCodePosition.Create(LineIndex, FoundAt - 1)) THEN BEGIN
          AddSelectionRange(TCodePosition.Create(LineIndex, FoundAt - 1),
            TCodePosition.Create(LineIndex, FoundAt - 1 + Length(Needle)));
          Invalidate;
          Exit;
        END;
        SearchStart := FoundAt + 1;
      END;
    UNTIL FoundAt = 0;
    Inc(ScannedLines);
    Inc(LineIndex);
    IF LineIndex >= TotalLines THEN
      LineIndex := 0;
    SearchStart := 1;
  END;
END;

FUNCTION TCodeEditor.OccurrenceAlreadySelected(CONST APos: TCodePosition): Boolean;
VAR
  I                 : Integer;
  RS                : TCodePosition;
BEGIN
  Result := (SelectionStart.Line = APos.Line) AND (SelectionStart.Column = APos.Column);
  IF NOT Result AND Assigned(FSelections) THEN
    FOR I := 0 TO FSelections.Count - 1 DO BEGIN
      RS := RangeStart(FSelections[I]);
      IF (RS.Line = APos.Line) AND (RS.Column = APos.Column) THEN BEGIN
        Result := True;
        Break;
      END;
    END;
END;

PROCEDURE TCodeEditor.SelectAllOccurrences;
VAR
  Needle            : STRING;
  LineIndex         : Integer;
  FoundAt           : Integer;
  SearchStart       : Integer;
BEGIN
  IF NOT HasSelection THEN
    SelectWordAtCaret;
  IF NOT HasSelection THEN
    Exit;

  Needle := GetSelectedText;
  ClearExtraSelections;
  FOR LineIndex := 0 TO FLines.Count - 1 DO BEGIN
    SearchStart := 1;
    REPEAT
      FoundAt := PosEx(Needle, FLines[LineIndex], SearchStart);
      IF FoundAt = 0 THEN
        Break;
      IF NOT ((LineIndex = SelectionStart.Line) AND (FoundAt - 1 = SelectionStart.Column)) THEN
        AddSelectionRange(TCodePosition.Create(LineIndex, FoundAt - 1),
          TCodePosition.Create(LineIndex, FoundAt - 1 + Length(Needle)));
      SearchStart := FoundAt + Max(1, Length(Needle));
    UNTIL SearchStart > Length(FLines[LineIndex]);
  END;
  Invalidate;
END;

PROCEDURE TCodeEditor.SetHighlighter(Value: TCustomCodeHighlighter);
BEGIN
  IF FHighlighter <> Value THEN BEGIN
    FHighlighter := Value;
    FLineTokenCache.Clear;
    FStateChainValid := 0;
    IF Assigned(FHighlighter) THEN
      FHighlighter.FreeNotification(Self);
    Invalidate;
  END;
END;

PROCEDURE TCodeEditor.SetCompletionProvider(Value: TCustomCodeCompletionProvider);
BEGIN
  IF FCompletionProvider <> Value THEN BEGIN
    HideCompletion;
    FCompletionProvider := Value;
    IF Assigned(FCompletionProvider) THEN
      FCompletionProvider.FreeNotification(Self);
  END;
END;

PROCEDURE TCodeEditor.SetTemplateProvider(Value: TCodeTemplateProvider);
BEGIN
  IF FTemplateProvider <> Value THEN BEGIN
    HideTemplates;
    FTemplateProvider := Value;
    IF Assigned(FTemplateProvider) THEN
      FTemplateProvider.FreeNotification(Self);
  END;
END;

PROCEDURE TCodeEditor.Notification(AComponent: TComponent; Operation: TOperation);
BEGIN
  INHERITED;
  IF Operation = opRemove THEN BEGIN
    IF AComponent = FHighlighter THEN BEGIN
      FHighlighter := NIL;
      Invalidate;
    END;
    IF AComponent = FCompletionProvider THEN BEGIN
      HideCompletion;
      HideSignatureHelp;
      FCompletionProvider := NIL;
    END;
    IF AComponent = FTemplateProvider THEN BEGIN
      HideTemplates;
      FTemplateProvider := NIL;
    END;
  END;
END;

PROCEDURE TCodeEditor.SetLines(Value: TStrings);
BEGIN
  FinishUndoGroup;
  ClearExtraSelections;
  FLines.Assign(Value);
  IF FLines.Count = 0 THEN
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
END;

PROCEDURE TCodeEditor.SetOptions(Value: TCodeEditorOptions);
BEGIN
  FOptions.Assign(Value);
END;

PROCEDURE TCodeEditor.SetTheme(Value: TCodeEditorThemeColors);
BEGIN
  FTheme.Assign(Value);
END;

PROCEDURE TCodeEditor.SetThemeMode(Value: TCodeEditorThemeMode);
BEGIN
  IF FThemeMode <> Value THEN BEGIN
    FThemeMode := Value;
    Invalidate;
  END;
END;

PROCEDURE TCodeEditor.SetTopLine(Value: Integer);
VAR
  OldTop            : Integer;
BEGIN
  Value := EnsureRange(Value, 0, Max(0, FLines.Count - VisibleLineCount));
  IF FTopLine = Value THEN
    Exit;
  OldTop := FTopLine;
  FTopLine := Value;
  UpdateScrollBars;
  UpdateCaret;
  ScrollViewport(OldTop);
END;

FUNCTION TCodeEditor.GetLines: TStrings;
BEGIN
  Result := FLines;
END;

PROCEDURE TCodeEditor.SetScrollBars(Value: System.UITypes.TScrollStyle);
BEGIN
  IF FScrollBars <> Value THEN BEGIN
    FScrollBars := Value;
    RecreateWnd;
  END;
END;

PROCEDURE TCodeEditor.SetStyledScrollBars(Value: Boolean);
BEGIN
  IF FStyledScrollBars <> Value THEN BEGIN
    FStyledScrollBars := Value;
    RecreateWnd;
    Invalidate;
  END;
END;

PROCEDURE TCodeEditor.SetCaret(Value: TCodePosition);
BEGIN
  FinishUndoGroup;
  FDesiredColumn := -1;
  ClearExtraSelections;
  FCaret := NormalizePosition(Value);
  FAnchor := FCaret;
  EnsureCaretVisible;
  Invalidate;
  DoCaretChange;
  DoSelectionChange;
END;

PROCEDURE TCodeEditor.SetLeftColumn(Value: Integer);
BEGIN
  Value := EnsureRange(Value, 0, Max(0, MaxLineLength - VisibleColumnCount + 1));
  IF FLeftColumn = Value THEN
    Exit;
  FLeftColumn := Value;
  UpdateScrollBars;
  UpdateCaret;
  Invalidate;
END;

PROCEDURE TCodeEditor.SetModified(Value: Boolean);
BEGIN
  FModified := Value;
END;

PROCEDURE TCodeEditor.SetReadOnly(Value: Boolean);
BEGIN
  IF FReadOnly <> Value THEN
    FReadOnly := Value;
END;

PROCEDURE TCodeEditor.LinesChanged(Sender: TObject);
BEGIN
  // The Lines getter exposes the raw TStringList, so external code can empty
  // it (Lines.Clear / Lines.Text := '') bypassing SetLines' guard. The editor
  // requires at least one line (InsertText etc. index FLines[FCaret.Line]).
  // Reset the caret first, then re-add: Add fires OnChange re-entrantly and
  // that pass runs the body below with a consistent one-line state.
  IF FLines.Count = 0 THEN BEGIN
    FCaret := TCodePosition.Create(0, 0);
    FAnchor := FCaret;
    FLines.Add('');
    Exit;
  END;

  FMaxLineLengthValid := False;
  FDesiredColumn := -1;
  // We don't know which line changed, so restart state validation from the
  // top; EnsureLineStates reuses cached entries, so this is cheap.
  FStateChainValid := 0;
  UpdateGutterWidth;
  UpdateScrollBars;
  IF NOT FApplyingUndo THEN BEGIN
    DoEditStateChanged;
    Change;
  END;
  IF SearchVisible THEN
    UpdateSearch;                       // keep match positions in sync with edits
  DoCaretChange;
  DoSelectionChange;
  Invalidate;
END;

PROCEDURE TCodeEditor.OptionsChanged(Sender: TObject);
BEGIN
  UpdateMetrics;
  UpdateScrollBars;
  Invalidate;
END;

PROCEDURE TCodeEditor.ThemeChanged(Sender: TObject);
BEGIN
  Invalidate;
END;

PROCEDURE TCodeEditor.ResolveTheme(Colors: TCodeEditorThemeColors);
BEGIN
  Colors.Assign(FTheme);

  IF FThemeMode = ctmVclStyle THEN BEGIN
    Colors.FBackground := StyleServices.GetSystemColor(clWindow);
    Colors.FText := StyleServices.GetSystemColor(clWindowText);
    Colors.FGutterBackground := StyleServices.GetSystemColor(clBtnFace);
    Colors.FGutterText := StyleServices.GetSystemColor(clGrayText);
    Colors.FGutterBorder := StyleServices.GetSystemColor(clBtnShadow);
    Colors.FSelectionBackground := StyleServices.GetSystemColor(clHighlight);
    Colors.FSelectionText := StyleServices.GetSystemColor(clHighlightText);
  END;

  IF Assigned(FOnResolveTheme) THEN
    FOnResolveTheme(Self, Colors);
END;

FUNCTION TCodeEditor.ActiveTheme: TCodeEditorThemeColors;
BEGIN
  Result := TCodeEditorThemeColors.Create;
  ResolveTheme(Result);
END;

PROCEDURE TCodeEditor.Change;
BEGIN
  IF Assigned(FOnChange) THEN
    FOnChange(Self);
END;

PROCEDURE TCodeEditor.Clear;
BEGIN
  IF FReadOnly THEN
    Exit;

  FinishUndoGroup;
  ClearUndo;
  ClearExtraSelections;
  FLines.Text := '';
  IF FLines.Count = 0 THEN
    FLines.Add('');
  FCaret := TCodePosition.Create(0, 0);
  FAnchor := FCaret;
  ClearBreakpoints;
  ClearLineMarkers;
  FExecutionLine := -1;
  LinesChanged(Self);
END;

PROCEDURE TCodeEditor.SelectAll;
BEGIN
  FinishUndoGroup;
  ClearExtraSelections;
  FAnchor := TCodePosition.Create(0, 0);
  FCaret := TCodePosition.Create(FLines.Count - 1, Length(FLines[FLines.Count - 1]));
  EnsureCaretVisible;
  Invalidate;
  DoCaretChange;
  DoSelectionChange;
END;

PROCEDURE TCodeEditor.ShowLine(Line: Integer);
BEGIN
  SetTopLine(Line);
END;

PROCEDURE TCodeEditor.CommentSelection;
VAR
  I                 : Integer;
  Prefix            : STRING;
  UndoItem          : TCodeUndoItem;
BEGIN
  IF FReadOnly THEN
    Exit;

  Prefix := FOptions.LineCommentPrefix;
  IF Prefix = '' THEN
    Exit;

  FinishUndoGroup;
  UndoItem := CaptureUndoState;
  FLines.BeginUpdate;
  TRY
    FOR I := SelectedLineStart TO SelectedLineEnd DO
      FLines[I] := Prefix + FLines[I];
  FINALLY
    FLines.EndUpdate;                   // fires LinesChanged once
  END;
  CommitUndoState(UndoItem);
END;

PROCEDURE TCodeEditor.UncommentSelection;
VAR
  I                 : Integer;
  Prefix            : STRING;
  P                 : Integer;
  LineText          : STRING;
  UndoItem          : TCodeUndoItem;
BEGIN
  IF FReadOnly THEN
    Exit;

  Prefix := FOptions.LineCommentPrefix;
  IF Prefix = '' THEN
    Exit;

  FinishUndoGroup;
  UndoItem := CaptureUndoState;
  FLines.BeginUpdate;
  TRY
    FOR I := SelectedLineStart TO SelectedLineEnd DO BEGIN
      LineText := FLines[I];
      P := Pos(Prefix, LineText);
      IF P = 1 THEN
        Delete(LineText, 1, Length(Prefix))
      ELSE IF (P > 1) AND (Trim(Copy(LineText, 1, P - 1)) = '') THEN
        Delete(LineText, P, Length(Prefix));
      FLines[I] := LineText;
    END;
  FINALLY
    FLines.EndUpdate;                   // fires LinesChanged once
  END;
  CommitUndoState(UndoItem);
END;

PROCEDURE TCodeEditor.ToggleLineComment;
VAR
  I                 : Integer;
  Prefix            : STRING;
  AllCommented      : Boolean;
  P                 : Integer;
BEGIN
  Prefix := FOptions.LineCommentPrefix;
  IF Prefix = '' THEN
    Exit;

  AllCommented := True;
  FOR I := SelectedLineStart TO SelectedLineEnd DO BEGIN
    P := Pos(Prefix, FLines[I]);
    IF NOT ((P = 1) OR ((P > 1) AND (Trim(Copy(FLines[I], 1, P - 1)) = ''))) THEN BEGIN
      AllCommented := False;
      Break;
    END;
  END;

  IF AllCommented THEN
    UncommentSelection
  ELSE
    CommentSelection;
END;

PROCEDURE TCodeEditor.IndentSelection;
VAR
  I                 : Integer;
  Spaces            : STRING;
  UndoItem          : TCodeUndoItem;
BEGIN
  IF FReadOnly THEN
    Exit;

  Spaces := StringOfChar(' ', FOptions.TabSize);
  FinishUndoGroup;
  UndoItem := CaptureUndoState;
  FLines.BeginUpdate;
  TRY
    FOR I := SelectedLineStart TO SelectedLineEnd DO
      FLines[I] := Spaces + FLines[I];
    IF (FCaret.Line >= SelectedLineStart) AND (FCaret.Line <= SelectedLineEnd) AND (FCaret.Column >
      0) THEN
      Inc(FCaret.Column, Length(Spaces));
    IF (FAnchor.Line >= SelectedLineStart) AND (FAnchor.Line <= SelectedLineEnd) AND (FAnchor.Column
      > 0) THEN
      Inc(FAnchor.Column, Length(Spaces));
  FINALLY
    FLines.EndUpdate;
  END;
  CommitUndoState(UndoItem);
END;

PROCEDURE TCodeEditor.UnindentSelection;
VAR
  I                 : Integer;
  LineText          : STRING;
  Removed           : Integer;
  UndoItem          : TCodeUndoItem;

  FUNCTION LeadingSpacesToRemove(CONST S: STRING): Integer;
  BEGIN
    Result := 0;
    WHILE (Result < FOptions.TabSize) AND (Result < Length(S)) AND (S[Result + 1] = ' ') DO
      Inc(Result);
  END;

BEGIN
  IF FReadOnly THEN
    Exit;

  FinishUndoGroup;
  UndoItem := CaptureUndoState;
  FLines.BeginUpdate;
  TRY
    FOR I := SelectedLineStart TO SelectedLineEnd DO BEGIN
      LineText := FLines[I];
      Removed := LeadingSpacesToRemove(LineText);
      IF Removed = 0 THEN
        Continue;
      Delete(LineText, 1, Removed);
      FLines[I] := LineText;
      IF (FCaret.Line = I) AND (FCaret.Column > 0) THEN
        FCaret.Column := Max(0, FCaret.Column - Removed);
      IF (FAnchor.Line = I) AND (FAnchor.Column > 0) THEN
        FAnchor.Column := Max(0, FAnchor.Column - Removed);
    END;
    FCaret := NormalizePosition(FCaret);
    FAnchor := NormalizePosition(FAnchor);
  FINALLY
    FLines.EndUpdate;
  END;
  CommitUndoState(UndoItem);
END;

PROCEDURE TCodeEditor.DeleteSelection;
VAR
  StartPos          : TCodePosition;
  EndPos            : TCodePosition;
  Prefix            : STRING;
  Suffix            : STRING;
  I                 : Integer;
BEGIN
  IF NOT HasSelection THEN
    Exit;

  StartPos := SelectionStart;
  EndPos := SelectionEnd;
  Prefix := Copy(FLines[StartPos.Line], 1, StartPos.Column);
  Suffix := Copy(FLines[EndPos.Line], EndPos.Column + 1, MaxInt);

  FLines.BeginUpdate;
  TRY
    FLines[StartPos.Line] := Prefix + Suffix;
    FOR I := EndPos.Line DOWNTO StartPos.Line + 1 DO
      FLines.Delete(I);
    FCaret := StartPos;
    FAnchor := FCaret;
  FINALLY
    FLines.EndUpdate;
  END;
  IF EndPos.Line > StartPos.Line THEN BEGIN
    ShiftBreakpoints(StartPos.Line + 1, -(EndPos.Line - StartPos.Line));
    ShiftLineMarkers(StartPos.Line + 1, -(EndPos.Line - StartPos.Line));
  END;
END;

PROCEDURE TCodeEditor.InsertTextAtRange(CONST StartPos, EndPos: TCodePosition; CONST Value: STRING;
  OUT NewCaret: TCodePosition);
VAR
  OldCaret          : TCodePosition;
  OldAnchor         : TCodePosition;
BEGIN
  OldCaret := FCaret;
  OldAnchor := FAnchor;
  TRY
    FAnchor := StartPos;
    FCaret := EndPos;
    DeleteSelection;
    InsertText(Value, False);
    NewCaret := FCaret;
  FINALLY
    FCaret := OldCaret;
    FAnchor := OldAnchor;
  END;
END;

FUNCTION TCodeEditor.PositionBefore(CONST Position: TCodePosition): TCodePosition;
BEGIN
  Result := NormalizePosition(Position);
  IF Result.Column > 0 THEN
    Dec(Result.Column)
  ELSE IF Result.Line > 0 THEN BEGIN
    Dec(Result.Line);
    Result.Column := Length(FLines[Result.Line]);
  END;
END;

FUNCTION TCodeEditor.PositionAfter(CONST Position: TCodePosition): TCodePosition;
BEGIN
  Result := NormalizePosition(Position);
  IF Result.Column < Length(FLines[Result.Line]) THEN
    Inc(Result.Column)
  ELSE IF Result.Line < FLines.Count - 1 THEN BEGIN
    Inc(Result.Line);
    Result.Column := 0;
  END;
END;

FUNCTION TCodeEditor.CollectSelectionRanges: TArray<TCodeSelectionRange>;
VAR
  I                 : Integer;
BEGIN
  SetLength(Result, FSelections.Count + 1);
  Result[0].Anchor := FAnchor;
  Result[0].Caret := FCaret;
  FOR I := 0 TO FSelections.Count - 1 DO
    Result[I + 1] := FSelections[I];
END;

PROCEDURE TCodeEditor.ApplyRangeEdits(VAR Ranges: TArray<TCodeSelectionRange>; CONST Value: STRING);
VAR
  NewCarets         : TArray<TCodePosition>;
  Count             : Integer;
  I, J              : Integer;
  Tmp               : TCodeSelectionRange;
  UndoItem          : TCodeUndoItem;
  StartPos          : TCodePosition;
  EndPos            : TCodePosition;
  NewCaret          : TCodePosition;

  PROCEDURE AdjustSavedCarets(CONST AEndPos, ANewCaret: TCodePosition; SavedCount: Integer);
  VAR
    K               : Integer;
    DeltaLines      : Integer;
    DeltaColumns    : Integer;
  BEGIN
    DeltaLines := ANewCaret.Line - AEndPos.Line;
    DeltaColumns := ANewCaret.Column - AEndPos.Column;

    FOR K := 0 TO SavedCount - 1 DO BEGIN
      IF ComparePositions(NewCarets[K], AEndPos) < 0 THEN
        Continue;

      IF DeltaLines = 0 THEN BEGIN
        IF NewCarets[K].Line = AEndPos.Line THEN
          Inc(NewCarets[K].Column, DeltaColumns);
      END ELSE BEGIN
        IF NewCarets[K].Line = AEndPos.Line THEN
          NewCarets[K] := TCodePosition.Create(ANewCaret.Line,
            ANewCaret.Column + (NewCarets[K].Column - AEndPos.Column))
        ELSE
          Inc(NewCarets[K].Line, DeltaLines);
      END;
    END;
  END;

BEGIN
  Count := Length(Ranges);
  IF Count = 0 THEN
    Exit;
  SetLength(NewCarets, Count);

  // Process ranges from the end of the document backwards so earlier edits
  // don't shift the positions of ranges still to be applied.
  FOR I := 1 TO Count - 1 DO BEGIN
    Tmp := Ranges[I];
    J := I - 1;
    WHILE (J >= 0) AND (ComparePositions(RangeStart(Ranges[J]), RangeStart(Tmp)) < 0) DO BEGIN
      Ranges[J + 1] := Ranges[J];
      Dec(J);
    END;
    Ranges[J + 1] := Tmp;
  END;

  FinishUndoGroup;
  UndoItem := CaptureUndoState;
  FOR I := 0 TO Count - 1 DO BEGIN
    StartPos := RangeStart(Ranges[I]);
    EndPos := RangeEnd(Ranges[I]);
    InsertTextAtRange(StartPos, EndPos, Value, NewCaret);
    AdjustSavedCarets(EndPos, NewCaret, I);
    NewCarets[I] := NewCaret;
  END;

  FCaret := NewCarets[Count - 1];
  FAnchor := FCaret;
  ClearExtraSelections;
  FOR I := 0 TO Count - 2 DO BEGIN
    Tmp.Anchor := NewCarets[I];
    Tmp.Caret := NewCarets[I];
    FSelections.Add(Tmp);
  END;
  EnsureCaretVisible;
  LinesChanged(Self);
  CommitUndoState(UndoItem);
END;

PROCEDURE TCodeEditor.ReplaceAllSelections(CONST Value: STRING);
VAR
  Ranges            : TArray<TCodeSelectionRange>;
BEGIN
  IF FReadOnly THEN
    Exit;

  IF NOT HasMultipleSelections AND NOT HasSelection THEN
    Exit;

  Ranges := CollectSelectionRanges;
  ApplyRangeEdits(Ranges, Value);
END;

PROCEDURE TCodeEditor.DeleteAllSelections(DeletePrevious: Boolean);
VAR
  Ranges            : TArray<TCodeSelectionRange>;
  I                 : Integer;
BEGIN
  IF FReadOnly THEN
    Exit;

  IF NOT HasMultipleSelections AND NOT HasSelection THEN
    Exit;

  Ranges := CollectSelectionRanges;
  // Empty ranges (bare carets) delete one character to the side instead.
  FOR I := 0 TO High(Ranges) DO
    IF ComparePositions(Ranges[I].Anchor, Ranges[I].Caret) = 0 THEN BEGIN
      IF DeletePrevious THEN
        Ranges[I].Anchor := PositionBefore(Ranges[I].Caret)
      ELSE
        Ranges[I].Caret := PositionAfter(Ranges[I].Anchor);
    END;
  ApplyRangeEdits(Ranges, '');
END;

PROCEDURE TCodeEditor.InsertText(CONST Value: STRING; AddUndo: Boolean);
VAR
  Parts             : TStringList;
  Current           : STRING;
  Normalized        : STRING;
  StartIndex        : Integer;
  Index             : Integer;
  Tail              : STRING;
  I                 : Integer;
  UndoItem          : TCodeUndoItem;
BEGIN
  IF FReadOnly AND AddUndo THEN
    Exit;

  IF Value = '' THEN
    Exit;

  IF AddUndo AND HasMultipleSelections THEN BEGIN
    ReplaceAllSelections(Value);
    Exit;
  END;

  UndoItem := NIL;
  IF AddUndo THEN BEGIN
    FinishUndoGroup;
    UndoItem := CaptureUndoState;
  END;

  IF HasSelection THEN
    DeleteSelection;

  Parts := TStringList.Create;
  TRY
    Normalized := StringReplace(Value, #13#10, #10, [rfReplaceAll]);
    Normalized := StringReplace(Normalized, #13, #10, [rfReplaceAll]);

    StartIndex := 1;
    FOR Index := 1 TO Length(Normalized) DO
      IF Normalized[Index] = #10 THEN BEGIN
        Parts.Add(Copy(Normalized, StartIndex, Index - StartIndex));
        StartIndex := Index + 1;
      END;
    Parts.Add(Copy(Normalized, StartIndex, MaxInt));

    // Batch the per-line inserts: without BeginUpdate every Insert fires the
    // full OnChange pipeline (gutter/scrollbars/search/repaint), making a
    // multi-thousand-line paste take seconds. EndUpdate fires it once.
    FLines.BeginUpdate;
    TRY
      Current := FLines[FCaret.Line];
      Tail := Copy(Current, FCaret.Column + 1, MaxInt);
      FLines[FCaret.Line] := Copy(Current, 1, FCaret.Column) + Parts[0];
      FCaret.Column := Length(FLines[FCaret.Line]);

      IF Parts.Count > 1 THEN BEGIN
        ShiftBreakpoints(FCaret.Line + 1, Parts.Count - 1);
        ShiftLineMarkers(FCaret.Line + 1, Parts.Count - 1);
      END;

      FOR I := 1 TO Parts.Count - 1 DO BEGIN
        FLines.Insert(FCaret.Line + 1, Parts[I]);
        Inc(FCaret.Line);
        FCaret.Column := Length(Parts[I]);
      END;

      FLines[FCaret.Line] := FLines[FCaret.Line] + Tail;
      FAnchor := FCaret;
    FINALLY
      FLines.EndUpdate;
    END;
  FINALLY
    Parts.Free;
  END;

  EnsureCaretVisible;
  LinesChanged(Self);
  UpdateCaret;
  CommitUndoState(UndoItem);
END;

PROCEDURE TCodeEditor.EnsureCaretVisible;
BEGIN
  FTopLine := EnsureRange(FTopLine, 0, Max(0, FLines.Count - VisibleLineCount));
  IF FCaret.Line < FTopLine THEN
    FTopLine := FCaret.Line
  ELSE IF FCaret.Line >= FTopLine + VisibleLineCount THEN
    FTopLine := FCaret.Line - VisibleLineCount + 1;

  IF FCaret.Column < FLeftColumn THEN
    FLeftColumn := FCaret.Column
  ELSE IF FCaret.Column >= FLeftColumn + VisibleColumnCount THEN
    FLeftColumn := FCaret.Column - VisibleColumnCount + 1;

  UpdateScrollBars;
  UpdateCaret;
END;

FUNCTION TCodeEditor.MovePositionForKey(CONST Position: TCodePosition; Key: Word): TCodePosition;
BEGIN
  Result := Position;
  CASE Key OF
    VK_LEFT:
      IF Result.Column > 0 THEN
        Dec(Result.Column)
      ELSE IF Result.Line > 0 THEN BEGIN
        Dec(Result.Line);
        Result.Column := Length(FLines[Result.Line]);
      END;
    VK_RIGHT:
      IF Result.Column < Length(FLines[Result.Line]) THEN
        Inc(Result.Column)
      ELSE IF Result.Line < FLines.Count - 1 THEN BEGIN
        Inc(Result.Line);
        Result.Column := 0;
      END;
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
  END;
  Result := NormalizePosition(Result);
END;

PROCEDURE TCodeEditor.MoveMultipleCarets(Key: Word; Shift: TShiftState);
VAR
  I                 : Integer;
  Range             : TCodeSelectionRange;
BEGIN
  FinishUndoGroup;
  FOR I := 0 TO FSelections.Count - 1 DO BEGIN
    Range := FSelections[I];
    Range.Caret := MovePositionForKey(Range.Caret, Key);
    IF NOT (ssShift IN Shift) THEN
      Range.Anchor := Range.Caret;
    FSelections[I] := Range;
  END;

  FCaret := MovePositionForKey(FCaret, Key);
  IF NOT (ssShift IN Shift) THEN
    FAnchor := FCaret;
  EnsureCaretVisible;
  Invalidate;
  DoCaretChange;
  DoSelectionChange;
END;

PROCEDURE TCodeEditor.MoveCaret(CONST Position: TCodePosition; Shift: TShiftState;
  PreserveDesiredColumn: Boolean);
VAR
  OldCaret          : TCodePosition;
  OldAnchor         : TCodePosition;
  OldTopLine        : Integer;
  OldLeftColumn     : Integer;
  OldNeedle         : STRING;
  HadExtra          : Boolean;
  BrOpen            : TCodePosition;
  BrClose           : TCodePosition;
  FirstLine         : Integer;
  LastLine          : Integer;

  PROCEDURE IncludeLine(Line: Integer);
  BEGIN
    FirstLine := Min(FirstLine, Line);
    LastLine := Max(LastLine, Line);
  END;

BEGIN
  FinishUndoGroup;
  IF NOT PreserveDesiredColumn THEN
    FDesiredColumn := -1;

  OldCaret := FCaret;
  OldAnchor := FAnchor;
  OldTopLine := FTopLine;
  OldLeftColumn := FLeftColumn;
  OldNeedle := OccurrenceNeedle;
  HadExtra := HasMultipleSelections;
  FirstLine := FCaret.Line;
  LastLine := FCaret.Line;
  IF MatchingBracketPosition(BrOpen, BrClose) THEN BEGIN
    IncludeLine(BrOpen.Line);
    IncludeLine(BrClose.Line);
  END;

  IF NOT (ssShift IN Shift) THEN
    ClearExtraSelections;
  FCaret := NormalizePosition(Position);
  IF NOT (ssShift IN Shift) THEN
    FAnchor := FCaret;
  EnsureCaretVisible;

  // Repaint only what a caret/selection move can change. A full Invalidate on
  // every drag tick repaints the minimap and gutter too, which flickers badly
  // over RDP. Vertical scrolling becomes a ScrollWindowEx copy; horizontal
  // scrolling, multi-caret teardown or an occurrence-highlight change still
  // fall back to wider repaints.
  IF (FLeftColumn <> OldLeftColumn) OR HadExtra THEN
    Invalidate
  ELSE BEGIN
    IF FTopLine <> OldTopLine THEN
      ScrollViewport(OldTopLine);
    IF OccurrenceNeedle <> OldNeedle THEN
      InvalidateTextArea
    ELSE BEGIN
      IncludeLine(FCaret.Line);
      IF NOT (ssShift IN Shift) THEN BEGIN
        // Selection collapsed: the old selected span needs unpainting.
        IncludeLine(OldAnchor.Line);
        IncludeLine(OldCaret.Line);
      END;
      IF MatchingBracketPosition(BrOpen, BrClose) THEN BEGIN
        IncludeLine(BrOpen.Line);
        IncludeLine(BrClose.Line);
      END;
      InvalidateTextLines(FirstLine, LastLine);
    END;
  END;
  DoCaretChange;
  DoSelectionChange;
END;

PROCEDURE TCodeEditor.MoveCaretVertically(DeltaLines: Integer; Shift: TShiftState);
VAR
  Target            : TCodePosition;
BEGIN
  // Remember the column the user is aiming for so that passing through short
  // lines doesn't permanently snap the caret to their length.
  IF FDesiredColumn < 0 THEN
    FDesiredColumn := FCaret.Column;
  Target.Line := FCaret.Line + DeltaLines;
  Target.Column := FDesiredColumn;
  MoveCaret(Target, Shift, True);
END;

FUNCTION TCodeEditor.PrevWordPosition(CONST Position: TCodePosition): TCodePosition;
VAR
  LineText          : STRING;
BEGIN
  Result := NormalizePosition(Position);
  IF Result.Column = 0 THEN BEGIN
    IF Result.Line > 0 THEN BEGIN
      Dec(Result.Line);
      Result.Column := Length(FLines[Result.Line]);
    END;
    Exit;
  END;

  LineText := FLines[Result.Line];
  WHILE (Result.Column > 0) AND LineText[Result.Column].IsWhiteSpace DO
    Dec(Result.Column);
  IF (Result.Column > 0) AND IsWordChar(LineText[Result.Column]) THEN
    WHILE (Result.Column > 0) AND IsWordChar(LineText[Result.Column]) DO
      Dec(Result.Column)
  ELSE
    WHILE (Result.Column > 0) AND NOT (LineText[Result.Column].IsWhiteSpace OR
      IsWordChar(LineText[Result.Column])) DO
      Dec(Result.Column);
END;

FUNCTION TCodeEditor.NextWordPosition(CONST Position: TCodePosition): TCodePosition;
VAR
  LineText          : STRING;
BEGIN
  Result := NormalizePosition(Position);
  LineText := FLines[Result.Line];
  IF Result.Column >= Length(LineText) THEN BEGIN
    IF Result.Line < FLines.Count - 1 THEN BEGIN
      Inc(Result.Line);
      Result.Column := 0;
    END;
    Exit;
  END;

  IF IsWordChar(LineText[Result.Column + 1]) THEN
    WHILE (Result.Column < Length(LineText)) AND IsWordChar(LineText[Result.Column + 1]) DO
      Inc(Result.Column)
  ELSE IF NOT LineText[Result.Column + 1].IsWhiteSpace THEN
    WHILE (Result.Column < Length(LineText)) AND NOT (LineText[Result.Column + 1].IsWhiteSpace OR
      IsWordChar(LineText[Result.Column + 1])) DO
      Inc(Result.Column);
  WHILE (Result.Column < Length(LineText)) AND LineText[Result.Column + 1].IsWhiteSpace DO
    Inc(Result.Column);
END;

PROCEDURE TCodeEditor.KeyDown(VAR Key: Word; Shift: TShiftState);
VAR
  UndoItem          : TCodeUndoItem;
BEGIN
  INHERITED;
  HideHoverHint;

  IF CompletionVisible THEN BEGIN
    CASE Key OF
      VK_ESCAPE: BEGIN
          HideCompletion;
          HideSignatureHelp;
          Key := 0;
          Exit;
        END;
      VK_UP: BEGIN
          MoveCompletionSelection(-1);
          Key := 0;
          Exit;
        END;
      VK_DOWN: BEGIN
          MoveCompletionSelection(1);
          Key := 0;
          Exit;
        END;
      VK_RETURN, VK_TAB: BEGIN
          AcceptCompletion;
          FSuppressKeyPress := True;
          Key := 0;
          Exit;
        END;
    END;
  END;

  IF TemplatesVisible THEN BEGIN
    CASE Key OF
      VK_ESCAPE: BEGIN
          HideTemplates;
          Key := 0;
          Exit;
        END;
      VK_UP: BEGIN
          MoveTemplateSelection(-1);
          Key := 0;
          Exit;
        END;
      VK_DOWN: BEGIN
          MoveTemplateSelection(1);
          Key := 0;
          Exit;
        END;
      VK_RETURN, VK_TAB: BEGIN
          AcceptTemplate;
          FSuppressKeyPress := True;
          Key := 0;
          Exit;
        END;
    END;
  END;

  IF HasMultipleSelections AND NOT (ssCtrl IN Shift) AND NOT (ssAlt IN Shift) AND
    (Key IN [VK_LEFT, VK_RIGHT, VK_UP, VK_DOWN, VK_HOME, VK_END, VK_PRIOR, VK_NEXT]) THEN BEGIN
    MoveMultipleCarets(Key, Shift);
    Key := 0;
    Exit;
  END;

  CASE Key OF
    VK_LEFT:
      IF ssCtrl IN Shift THEN
        MoveCaret(PrevWordPosition(FCaret), Shift)
      ELSE IF FCaret.Column > 0 THEN
        MoveCaret(TCodePosition.Create(FCaret.Line, FCaret.Column - 1), Shift)
      ELSE IF FCaret.Line > 0 THEN
        MoveCaret(TCodePosition.Create(FCaret.Line - 1, Length(FLines[FCaret.Line - 1])), Shift);
    VK_RIGHT:
      IF ssCtrl IN Shift THEN
        MoveCaret(NextWordPosition(FCaret), Shift)
      ELSE IF FCaret.Column < Length(FLines[FCaret.Line]) THEN
        MoveCaret(TCodePosition.Create(FCaret.Line, FCaret.Column + 1), Shift)
      ELSE IF FCaret.Line < FLines.Count - 1 THEN
        MoveCaret(TCodePosition.Create(FCaret.Line + 1, 0), Shift);
    VK_UP:
      MoveCaretVertically(-1, Shift);
    VK_DOWN:
      MoveCaretVertically(1, Shift);
    VK_HOME:
      IF ssCtrl IN Shift THEN
        MoveCaret(TCodePosition.Create(0, 0), Shift)
      ELSE
        MoveCaret(TCodePosition.Create(FCaret.Line, 0), Shift);
    VK_END:
      IF ssCtrl IN Shift THEN
        MoveCaret(TCodePosition.Create(FLines.Count - 1, Length(FLines[FLines.Count - 1])), Shift)
      ELSE
        MoveCaret(TCodePosition.Create(FCaret.Line, Length(FLines[FCaret.Line])), Shift);
    VK_PRIOR:
      MoveCaretVertically(-VisibleLineCount, Shift);
    VK_NEXT:
      MoveCaretVertically(VisibleLineCount, Shift);
    VK_TAB:
      IF ssShift IN Shift THEN BEGIN
        UnindentSelection;
        FSuppressKeyPress := True;
        Key := 0;
      END;
    VK_INSERT:
      // Classic clipboard chords; keeps them working now the host forms no longer
      // bind them form-wide (which hijacked paste while the search box had focus).
      IF Shift = [ssCtrl] THEN BEGIN
        CopyToClipboard;
        Key := 0;
      END ELSE IF Shift = [ssShift] THEN BEGIN
        HideCompletion;
        HideSignatureHelp;
        HideTemplates;
        PasteFromClipboard;
        Key := 0;
      END;
    VK_DELETE: BEGIN
        IF FReadOnly THEN BEGIN
          MessageBeep(MB_ICONWARNING);
          Key := 0;
          Exit;
        END;
        IF Shift = [ssShift] THEN BEGIN
          CutToClipboard;
          Key := 0;
          Exit;
        END;
        HideCompletion;
        HideSignatureHelp;
        HideTemplates;
        IF HasMultipleSelections THEN BEGIN
          DeleteAllSelections(False);
          Key := 0;
          Exit;
        END;
        FinishUndoGroup;
        UndoItem := CaptureUndoState;
        IF HasSelection THEN
          DeleteSelection
        ELSE IF FCaret.Column < Length(FLines[FCaret.Line]) THEN BEGIN
          FLines[FCaret.Line] := Copy(FLines[FCaret.Line], 1, FCaret.Column) +
            Copy(FLines[FCaret.Line], FCaret.Column + 2, MaxInt);
        END ELSE IF FCaret.Line < FLines.Count - 1 THEN BEGIN
          FLines[FCaret.Line] := FLines[FCaret.Line] + FLines[FCaret.Line + 1];
          FLines.Delete(FCaret.Line + 1);
          ShiftBreakpoints(FCaret.Line + 1, -1);
          ShiftLineMarkers(FCaret.Line + 1, -1);
        END;
        LinesChanged(Self);
        CommitUndoState(UndoItem);
        Key := 0;
      END;
    Ord('A'):
      IF ssCtrl IN Shift THEN BEGIN
        SelectAll;
        Key := 0;
      END;
    Ord('C'):
      IF ssCtrl IN Shift THEN BEGIN
        CopyToClipboard;
        Key := 0;
      END;
    Ord('D'):
      // Alt+D is a two-key alias for hosts where an action owns Ctrl+D (the TOPS
      // script editors bind Ctrl+D to Reformat). Shift = [ssAlt] excludes AltGr
      // (ssCtrl+ssAlt), which types a character on some international layouts.
      IF (ssCtrl IN Shift) OR (Shift = [ssAlt]) THEN BEGIN
        AddNextSelectionOccurrence;
        IF Shift = [ssAlt] THEN
          FSuppressSysChar := True; // eat the trailing WM_SYSCHAR (menu beep)
        Key := 0;
      END;
    Ord('L'):
      IF (ssCtrl IN Shift) AND (ssShift IN Shift) THEN BEGIN
        SelectAllSelectionOccurrences;
        Key := 0;
      END;
    Ord('X'):
      IF ssCtrl IN Shift THEN BEGIN
        CutToClipboard;
        Key := 0;
      END;
    Ord('F'):
      IF ssCtrl IN Shift THEN BEGIN
        ShowFind;
        Key := 0;
      END;
    Ord('H'):
      IF ssCtrl IN Shift THEN BEGIN
        ShowReplace;
        Key := 0;
      END;
    Ord('J'):
      IF Shift = [ssCtrl] THEN BEGIN
        TriggerTemplates;
        // Ctrl+J arrives in KeyPress as the #10 control character.
        FSuppressKeyPress := True;
        Key := 0;
      END;
    Ord('V'):
      IF ssCtrl IN Shift THEN BEGIN
        HideCompletion;
        HideSignatureHelp;
        HideTemplates;
        PasteFromClipboard;
        FSuppressKeyPress := True;
        Key := 0;
      END;
    VK_SPACE:
      IF ssCtrl IN Shift THEN BEGIN
        IF ssShift IN Shift THEN
          TriggerSignatureHelp
        ELSE
          TriggerCompletion;
        FSuppressKeyPress := True;
        Key := 0;
      END;
    Ord('Y'):
      IF ssCtrl IN Shift THEN BEGIN
        Redo;
        Key := 0;
      END;
    Ord('Z'):
      IF ssCtrl IN Shift THEN BEGIN
        IF ssShift IN Shift THEN
          Redo
        ELSE
          Undo;
        Key := 0;
      END;
    VK_OEM_PLUS, VK_ADD:
      IF ssCtrl IN Shift THEN BEGIN
        ZoomIn;
        Key := 0;
      END;
    VK_OEM_MINUS, VK_SUBTRACT:
      IF ssCtrl IN Shift THEN BEGIN
        ZoomOut;
        Key := 0;
      END;
    Ord('0'), VK_NUMPAD0:
      IF ssCtrl IN Shift THEN BEGIN
        ZoomReset;
        Key := 0;
      END;
    VK_F5, VK_F9: BEGIN
        ToggleBreakpoint(FCaret.Line + 1);
        Key := 0;
      END;
    VK_ESCAPE:
      IF HasMultipleSelections THEN BEGIN
        ClearMultipleSelections;
        Key := 0;
      END ELSE IF SignatureVisible THEN BEGIN
        HideSignatureHelp;
        Key := 0;
      END ELSE IF SearchVisible THEN BEGIN
        HideSearchPanel;
        Key := 0;
      END;
  END;
END;

PROCEDURE TCodeEditor.KeyPress(VAR Key: Char);
VAR
  Line              : STRING;
  UndoItem          : TCodeUndoItem;
BEGIN
  INHERITED;

  IF FSuppressKeyPress THEN BEGIN
    FSuppressKeyPress := False;
    Key := #0;
    Exit;
  END;

  CASE Key OF
    #22: BEGIN
        HideCompletion;
        HideSignatureHelp;
        HideTemplates;
        PasteFromClipboard;
        Key := #0;
      END;
    #8: BEGIN
        IF FReadOnly THEN BEGIN
          MessageBeep(MB_ICONWARNING);
          Key := #0;
          Exit;
        END;
        HideCompletion;
        HideTemplates;
        IF HasMultipleSelections THEN BEGIN
          DeleteAllSelections(True);
          Key := #0;
          Exit;
        END;
        FinishUndoGroup;
        UndoItem := CaptureUndoState;
        IF HasSelection THEN
          DeleteSelection
        ELSE IF FCaret.Column > 0 THEN BEGIN
          Line := FLines[FCaret.Line];
          Delete(Line, FCaret.Column, 1);
          FLines[FCaret.Line] := Line;
          Dec(FCaret.Column);
          FAnchor := FCaret;
        END ELSE IF FCaret.Line > 0 THEN BEGIN
          FCaret.Column := Length(FLines[FCaret.Line - 1]);
          FLines[FCaret.Line - 1] := FLines[FCaret.Line - 1] + FLines[FCaret.Line];
          FLines.Delete(FCaret.Line);
          ShiftBreakpoints(FCaret.Line, -1);
          ShiftLineMarkers(FCaret.Line, -1);
          Dec(FCaret.Line);
          FAnchor := FCaret;
        END;
        LinesChanged(Self);
        EnsureCaretVisible;
        CommitUndoState(UndoItem);
        Key := #0;
      END;
    #9: BEGIN
        IF FReadOnly THEN BEGIN
          MessageBeep(MB_ICONWARNING);
          Key := #0;
          Exit;
        END;
        HideCompletion;
        HideTemplates;
        FinishUndoGroup;
        IF HasSelection AND (SelectionStart.Line <> SelectionEnd.Line) THEN
          IndentSelection
        ELSE
          InsertText(StringOfChar(' ', FOptions.TabSize));
        Key := #0;
      END;
    #13: BEGIN
        IF FReadOnly THEN BEGIN
          MessageBeep(MB_ICONWARNING);
          Key := #0;
          Exit;
        END;
        HideCompletion;
        HideSignatureHelp;
        HideTemplates;
        FinishUndoGroup;
        InsertText(sLineBreak);
        Key := #0;
      END;
  ELSE
    // Accept any printable character, including Unicode above #255 (IME,
    // non-Western keyboard layouts).
    IF Key >= #32 THEN BEGIN
      InsertTypedText(Key);
      IF TemplatesVisible THEN
        // Keep narrowing the template list while the user types.
        ShowTemplates(False)
      ELSE BEGIN
        IF CharInSet(Key, ['.', '(', '<']) THEN BEGIN
          ShowCompletion(Key, False)
        END ELSE IF CompletionVisible THEN
          ShowCompletion(#0, False);
        IF CharInSet(Key, ['(', '<']) THEN
          ShowSignatureHelp(Key, False)
        ELSE IF Key = ',' THEN
          UpdateSignatureHelp(Key);
      END;
      Key := #0;
    END;
  END;
END;

PROCEDURE TCodeEditor.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
VAR
  Thumb             : TRect;
  NewPos            : Integer;
  OldTop            : Integer;
BEGIN
  INHERITED;
  HideHoverHint;
  IF Button = mbLeft THEN BEGIN
    SetFocus;
    HideCompletion;
    HideTemplates;
    IF MinimapVisible AND PtInRect(MinimapRect, Point(X, Y)) THEN BEGIN
      FMinimapDragging := True;
      ScrollMinimapTo(Y);
      Exit;
    END;
    IF StyledVerticalVisible AND PtInRect(StyledVerticalScrollRect, Point(X, Y)) THEN BEGIN
      Thumb := StyledVerticalThumbRect;
      IF PtInRect(Thumb, Point(X, Y)) THEN BEGIN
        FScrollBarDragging := True;
        FScrollDragOffset := Y - Thumb.Top;
      END ELSE BEGIN
        IF Y < Thumb.Top THEN
          NewPos := FTopLine - VisibleLineCount
        ELSE
          NewPos := FTopLine + VisibleLineCount;
        NewPos := EnsureRange(NewPos, 0, Max(0, FLines.Count - VisibleLineCount));
        IF NewPos <> FTopLine THEN BEGIN
          OldTop := FTopLine;
          FTopLine := NewPos;
          UpdateScrollBars;
          ScrollViewport(OldTop);
        END;
      END;
      Exit;
    END;
    IF StyledHorizontalVisible AND PtInRect(StyledHorizontalScrollRect, Point(X, Y)) THEN BEGIN
      Thumb := StyledHorizontalThumbRect;
      IF PtInRect(Thumb, Point(X, Y)) THEN BEGIN
        FHScrollBarDragging := True;
        FScrollDragOffset := X - Thumb.Left;
      END ELSE BEGIN
        IF X < Thumb.Left THEN
          NewPos := FLeftColumn - VisibleColumnCount
        ELSE
          NewPos := FLeftColumn + VisibleColumnCount;
        NewPos := EnsureRange(NewPos, 0, Max(0, MaxLineLength - VisibleColumnCount + 1));
        IF NewPos <> FLeftColumn THEN BEGIN
          FLeftColumn := NewPos;
          UpdateScrollBars;
          Invalidate;
        END;
      END;
      Exit;
    END;
    IF FOptions.ShowGutter AND (FGutterWidth > 0) AND (X < BreakpointMarginWidth) THEN BEGIN
      NewPos := LineAtPoint(Point(X, Y));
      IF NewPos >= 0 THEN
        ToggleBreakpoint(NewPos + 1);
      Exit;
    END;
    MoveCaret(PointToCaret(Point(X, Y)), Shift);
    IF ssDouble IN Shift THEN
      SelectWordAtCaret;
  END;
END;

PROCEDURE TCodeEditor.MouseMove(Shift: TShiftState; X, Y: Integer);
VAR
  Track             : TRect;
  Thumb             : TRect;
  ThumbExtent       : Integer;
  Travel            : Integer;
  MaxTopLine        : Integer;
  MaxLeftCol        : Integer;
  NewPos            : Integer;
  OldTop            : Integer;
BEGIN
  INHERITED;
  IF FScrollBarDragging THEN BEGIN
    Track := StyledVerticalScrollRect;
    Thumb := StyledVerticalThumbRect;
    ThumbExtent := Thumb.Height;
    Travel := Max(1, Track.Height - ThumbExtent);
    MaxTopLine := Max(0, FLines.Count - VisibleLineCount);
    NewPos := EnsureRange(Y - FScrollDragOffset - Track.Top, 0, Travel);
    IF MaxTopLine > 0 THEN
      NewPos := MulDiv(NewPos, MaxTopLine, Travel)
    ELSE
      NewPos := 0;
    IF NewPos <> FTopLine THEN BEGIN
      OldTop := FTopLine;
      FTopLine := NewPos;
      UpdateScrollBars;
      UpdateCaret;
      ScrollViewport(OldTop);
    END;
    Exit;
  END;

  IF FMinimapDragging THEN BEGIN
    ScrollMinimapTo(Y);
    Exit;
  END;

  IF FHScrollBarDragging THEN BEGIN
    Track := StyledHorizontalScrollRect;
    Thumb := StyledHorizontalThumbRect;
    ThumbExtent := Thumb.Width;
    Travel := Max(1, Track.Width - ThumbExtent);
    MaxLeftCol := Max(0, MaxLineLength - VisibleColumnCount + 1);
    NewPos := EnsureRange(X - FScrollDragOffset - Track.Left, 0, Travel);
    IF MaxLeftCol > 0 THEN
      NewPos := MulDiv(NewPos, MaxLeftCol, Travel)
    ELSE
      NewPos := 0;
    IF NewPos <> FLeftColumn THEN BEGIN
      FLeftColumn := NewPos;
      UpdateScrollBars;
      UpdateCaret;
      Invalidate;
    END;
    Exit;
  END;

  IF ssLeft IN Shift THEN BEGIN
    MoveCaret(PointToCaret(Point(X, Y)), Shift + [ssShift]);
    HideHoverHint;
    Exit;
  END;

  // Hover-to-hint: restart the dwell timer whenever the mouse actually moves.
  IF Assigned(FOnGetHint) AND ((X <> FHoverMouse.X) OR (Y <> FHoverMouse.Y)) THEN BEGIN
    HideHoverHint;
    FHoverMouse := Point(X, Y);
    FHoverTimer.Enabled := True;
  END;
END;

PROCEDURE TCodeEditor.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
BEGIN
  INHERITED;
  FScrollBarDragging := False;
  FHScrollBarDragging := False;
  FMinimapDragging := False;
END;

PROCEDURE TCodeEditor.SelectWordAtCaret;
VAR
  LineText          : STRING;
  StartCol          : Integer;
  EndCol            : Integer;
BEGIN
  IF (FCaret.Line < 0) OR (FCaret.Line >= FLines.Count) THEN
    Exit;

  LineText := FLines[FCaret.Line];
  StartCol := FCaret.Column;
  EndCol := FCaret.Column;

  IF NOT ((StartCol < Length(LineText)) AND IsWordChar(LineText[StartCol + 1])) THEN BEGIN
    IF (StartCol > 0) AND IsWordChar(LineText[StartCol]) THEN BEGIN
      Dec(StartCol);
      Dec(EndCol);
    END ELSE
      Exit;
  END;

  WHILE (StartCol > 0) AND IsWordChar(LineText[StartCol]) DO
    Dec(StartCol);
  WHILE (EndCol < Length(LineText)) AND IsWordChar(LineText[EndCol + 1]) DO
    Inc(EndCol);

  FAnchor := TCodePosition.Create(FCaret.Line, StartCol);
  FCaret := TCodePosition.Create(FCaret.Line, EndCol);
  EnsureCaretVisible;
  Invalidate;
  DoCaretChange;
  DoSelectionChange;
END;

FUNCTION TCodeEditor.LineAtPoint(CONST Point: TPoint): Integer;
BEGIN
  Result := FTopLine + (Point.Y DIV FLineHeight);
  IF (Result < 0) OR (Result >= FLines.Count) THEN
    Result := -1;
END;

PROCEDURE TCodeEditor.BreakpointsChanged;
BEGIN
  IF csDestroying IN ComponentState THEN
    Exit;
  Invalidate;
  IF csDesigning IN ComponentState THEN
    Update;                             // the form designer doesn't always honor a plain Invalidate
  IF Assigned(FOnBreakpointsChanged) AND NOT (csLoading IN ComponentState) THEN
    FOnBreakpointsChanged(Self);
END;

FUNCTION TCodeEditor.HasBreakpoint(Line: Integer): Boolean;
BEGIN
  Result := FBreakpoints.ContainsLine(Line);
END;

PROCEDURE TCodeEditor.AddBreakpoint(Line: Integer);
BEGIN
  IF (Line < 1) OR (Line > FLines.Count) THEN
    Exit;
  IF FBreakpoints.ContainsLine(Line) THEN
    Exit;
  FBreakpoints.AddLine(Line);
END;

PROCEDURE TCodeEditor.RemoveBreakpoint(Line: Integer);
BEGIN
  FBreakpoints.RemoveLine(Line);
END;

PROCEDURE TCodeEditor.ToggleBreakpoint(Line: Integer);
BEGIN
  IF (Line < 1) OR (Line > FLines.Count) THEN
    Exit;
  IF FBreakpoints.ContainsLine(Line) THEN
    RemoveBreakpoint(Line)
  ELSE
    AddBreakpoint(Line);
END;

PROCEDURE TCodeEditor.ClearBreakpoints;
BEGIN
  IF FBreakpoints.Count = 0 THEN
    Exit;
  FBreakpoints.Clear;
END;

FUNCTION TCodeEditor.BreakpointLines: TArray<Integer>;
BEGIN
  Result := FBreakpoints.SortedLines;
END;

FUNCTION TCodeEditor.AddLineMarker(Line: Integer; Kind: TCodeLineMarkerKind): TCodeLineMarker;
BEGIN
  Result := NIL;
  IF (Line < 1) OR (Line > FLines.Count) THEN
    Exit;
  IF FLineMarkers.ContainsLine(Line, Kind) THEN
    Exit(FLineMarkers[FLineMarkers.IndexOfLine(Line, Kind)]);
  Result := FLineMarkers.AddLine(Line, Kind);
END;

PROCEDURE TCodeEditor.RemoveLineMarker(Line: Integer; Kind: TCodeLineMarkerKind);
BEGIN
  FLineMarkers.RemoveLine(Line, Kind);
END;

PROCEDURE TCodeEditor.ClearLineMarkers;
BEGIN
  IF FLineMarkers.Count = 0 THEN
    Exit;
  FLineMarkers.Clear;
END;

PROCEDURE TCodeEditor.SetBreakpoints(Value: TCodeBreakpoints);
BEGIN
  FBreakpoints.Assign(Value);
END;

PROCEDURE TCodeEditor.SetLineMarkers(Value: TCodeLineMarkers);
BEGIN
  FLineMarkers.Assign(Value);
END;

PROCEDURE TCodeEditor.LineMarkersChanged;
BEGIN
  IF csDestroying IN ComponentState THEN
    Exit;
  Invalidate;
  IF csDesigning IN ComponentState THEN
    Update;
END;

PROCEDURE TCodeEditor.SetExecutionLine(Value: Integer);
VAR
  Idx               : Integer;
BEGIN
  IF (Value < 1) OR (Value > FLines.Count) THEN
    Value := -1;                        // -1 (or any value < 1) means "no current line"
  IF FExecutionLine = Value THEN
    Exit;
  FExecutionLine := Value;
  IF FExecutionLine >= 1 THEN BEGIN
    Idx := FExecutionLine - 1;
    IF Idx < FTopLine THEN
      FTopLine := Idx
    ELSE IF Idx >= FTopLine + VisibleLineCount THEN
      FTopLine := Idx - VisibleLineCount + 1;
    FTopLine := EnsureRange(FTopLine, 0, Max(0, FLines.Count - VisibleLineCount));
    UpdateScrollBars;
  END;
  Invalidate;
END;

PROCEDURE TCodeEditor.ShiftBreakpoints(AfterLine, Delta: Integer);
VAR
  I                 : Integer;
  Affected          : Boolean;
BEGIN
  IF Delta = 0 THEN
    Exit;

  Affected := (FExecutionLine > AfterLine);
  IF NOT Affected THEN
    FOR I := 0 TO FBreakpoints.Count - 1 DO
      IF RemapLineAfterEdit(FBreakpoints[I].Line, AfterLine, Delta) <> FBreakpoints[I].Line THEN
        BEGIN
        Affected := True;
        Break;
      END;
  IF NOT Affected THEN
    Exit;

  FBreakpoints.BeginUpdate;
  TRY
    FOR I := FBreakpoints.Count - 1 DOWNTO 0 DO
      FBreakpoints[I].Line := RemapLineAfterEdit(FBreakpoints[I].Line, AfterLine, Delta);
    // Remapping can produce duplicates when lines are merged together.
    FOR I := FBreakpoints.Count - 1 DOWNTO 1 DO
      IF FBreakpoints.IndexOfLine(FBreakpoints[I].Line) < I THEN
        FBreakpoints.Delete(I);
  FINALLY
    FBreakpoints.EndUpdate;
  END;

  IF FExecutionLine > AfterLine THEN BEGIN
    IF (Delta < 0) AND (FExecutionLine <= AfterLine - Delta) THEN
      FExecutionLine := -1
    ELSE
      FExecutionLine := FExecutionLine + Delta;
  END;
END;

PROCEDURE TCodeEditor.ShiftLineMarkers(AfterLine, Delta: Integer);
VAR
  I                 : Integer;
BEGIN
  IF Delta = 0 THEN
    Exit;

  FLineMarkers.BeginUpdate;
  TRY
    FOR I := FLineMarkers.Count - 1 DOWNTO 0 DO
      FLineMarkers[I].Line := EnsureRange(RemapLineAfterEdit(FLineMarkers[I].Line, AfterLine,
        Delta),
        1, Max(1, FLines.Count));
  FINALLY
    FLineMarkers.EndUpdate;
  END;
END;

PROCEDURE TCodeEditor.PaintBreakpointGlyph(CONST CellRect: TRect; HasBp, IsExec: Boolean);
VAR
  Size              : Integer;
  Dot               : TRect;
  Cx, Cy            : Integer;
  Arrow             : ARRAY[0..2] OF TPoint;
BEGIN
  Size := Min(CellRect.Width, FLineHeight) - 4;
  IF Size < 6 THEN
    Size := Min(CellRect.Width, FLineHeight);
  Cx := (CellRect.Left + CellRect.Right) DIV 2;
  Cy := (CellRect.Top + CellRect.Bottom) DIV 2;

  IF HasBp THEN BEGIN
    Dot := Rect(Cx - Size DIV 2, Cy - Size DIV 2, Cx - Size DIV 2 + Size, Cy - Size DIV 2 + Size);
    Canvas.Brush.Color := $003C3CE0;
    Canvas.Pen.Color := $002020A0;
    Canvas.Ellipse(Dot);
  END;

  IF IsExec THEN BEGIN
    Arrow[0] := Point(CellRect.Left + 2, Cy - Size DIV 3);
    Arrow[1] := Point(CellRect.Left + 2, Cy + Size DIV 3);
    Arrow[2] := Point(CellRect.Right - 2, Cy);
    IF HasBp THEN BEGIN
      Canvas.Brush.Color := $0020D0F0;
      Canvas.Pen.Color := $001090C0;
    END ELSE BEGIN
      Canvas.Brush.Color := $00E0A020;
      Canvas.Pen.Color := $00A07010;
    END;
    Canvas.Polygon(Arrow);
  END;
END;

PROCEDURE TCodeEditor.PaintExecutableDot(CONST CellRect: TRect);
VAR
  Size              : Integer;
  Cx, Cy            : Integer;
  Dot               : TRect;
BEGIN
  // A small blue dot, like the Delphi IDE's "this line generates code" marker;
  // deliberately smaller than the breakpoint circle it shares the margin with.
  Size := Max(4, (Min(CellRect.Width, FLineHeight) - 4) DIV 2);
  Cx := (CellRect.Left + CellRect.Right) DIV 2;
  Cy := (CellRect.Top + CellRect.Bottom) DIV 2;
  Dot := Rect(Cx - Size DIV 2, Cy - Size DIV 2, Cx - Size DIV 2 + Size, Cy - Size DIV 2 + Size);
  Canvas.Brush.Color := $00E04830;
  Canvas.Pen.Color := $00A02818;
  Canvas.Ellipse(Dot);
END;

FUNCTION TCodeEditor.QueryExecutableLine(Line: Integer): Boolean;
BEGIN
  Result := False;
  IF Assigned(FOnQueryExecutableLine) THEN
    FOnQueryExecutableLine(Self, Line, Result);
END;

FUNCTION TCodeEditor.WordAtPoint(CONST P: TPoint; OUT WordPos: TCodePosition): STRING;
VAR
  R                 : TRect;
  LineIndex         : Integer;
  Col               : Integer;
  LineText          : STRING;
  StartCol          : Integer;
  EndCol            : Integer;
BEGIN
  Result := '';
  WordPos := TCodePosition.Create(0, 0);
  R := ClientTextRect;
  IF (P.X < R.Left) OR (P.Y < R.Top) THEN
    Exit;                               // over the gutter or above the text

  LineIndex := FTopLine + (P.Y - R.Top) DIV FLineHeight;
  IF (LineIndex < 0) OR (LineIndex >= FLines.Count) THEN
    Exit;
  // Character directly under the mouse (no half-cell rounding — we want the
  // glyph pointed at, not the nearest caret gap). Col is a 1-based string index.
  Col := FLeftColumn + (P.X - R.Left) DIV FCharWidth + 1;
  LineText := FLines[LineIndex];
  IF (Col < 1) OR (Col > Length(LineText)) OR NOT IsWordChar(LineText[Col]) THEN
    Exit;

  StartCol := Col;
  EndCol := Col;
  WHILE (StartCol > 1) AND IsWordChar(LineText[StartCol - 1]) DO
    Dec(StartCol);
  WHILE (EndCol < Length(LineText)) AND IsWordChar(LineText[EndCol + 1]) DO
    Inc(EndCol);
  // Absorb a leading dotted member chain (a.b.c) so hovering a field still
  // yields the qualified name the evaluator expects.
  WHILE (StartCol > 2) AND (LineText[StartCol - 1] = '.') AND
    IsWordChar(LineText[StartCol - 2]) DO
  BEGIN
    Dec(StartCol, 2);
    WHILE (StartCol > 1) AND IsWordChar(LineText[StartCol - 1]) DO
      Dec(StartCol);
  END;

  WordPos := TCodePosition.Create(LineIndex, Col - 1);
  Result := Copy(LineText, StartCol, EndCol - StartCol + 1);
END;

PROCEDURE TCodeEditor.HoverTimerFired(Sender: TObject);
VAR
  HoverWord         : STRING;
  WordPos           : TCodePosition;
  HintText          : STRING;
BEGIN
  FHoverTimer.Enabled := False;
  IF NOT Assigned(FOnGetHint) THEN
    Exit;
  // Don't fight the other popups for screen space.
  IF CompletionVisible OR SignatureVisible OR TemplatesVisible THEN
    Exit;

  HoverWord := WordAtPoint(FHoverMouse, WordPos);
  IF HoverWord = '' THEN
    Exit;

  HintText := '';
  FOnGetHint(Self, WordPos.Line + 1, WordPos.Column + 1, HoverWord, HintText);
  IF HintText <> '' THEN
    ShowHoverHint(FHoverMouse, HintText);
END;

PROCEDURE TCodeEditor.ShowHoverHint(CONST P: TPoint; CONST HintText: STRING);
VAR
  R                 : TRect;
  Origin            : TPoint;
BEGIN
  IF HintText = '' THEN
    Exit;
  IF FHintWindow = NIL THEN
    FHintWindow := THintWindow.Create(Self);

  R := FHintWindow.CalcHintRect(Max(240, ClientWidth - P.X), HintText, NIL);
  Origin := ClientToScreen(Point(P.X + 12, P.Y + FLineHeight + 2));
  OffsetRect(R, Origin.X, Origin.Y);
  FHintWindow.ActivateHint(R, HintText);
  FHintVisible := True;
END;

PROCEDURE TCodeEditor.HideHoverHint;
BEGIN
  FHoverTimer.Enabled := False;
  IF FHintVisible THEN BEGIN
    IF Assigned(FHintWindow) THEN
      FHintWindow.ReleaseHandle;
    FHintVisible := False;
  END;
END;

PROCEDURE TCodeEditor.CMMouseLeave(VAR Message: TMessage);
BEGIN
  INHERITED;
  HideHoverHint;
  FHoverMouse := Point(-1, -1);
END;

FUNCTION TCodeEditor.FirstLineMarkerAny(Line: Integer): TCodeLineMarker;
VAR
  I                 : Integer;
BEGIN
  Result := NIL;
  FOR I := 0 TO FLineMarkers.Count - 1 DO
    IF FLineMarkers[I].Line = Line THEN BEGIN
      IF (Result = NIL) OR (Ord(FLineMarkers[I].Kind) < Ord(Result.Kind)) THEN
        Result := FLineMarkers[I];
    END;
END;

FUNCTION TCodeEditor.MarkerBackgroundColor(Marker: TCodeLineMarker;
  CONST ThemeColors: TCodeEditorThemeColors): TColor;
BEGIN
  Result := clNone;
  IF NOT Assigned(Marker) THEN
    Exit;
  IF Marker.Background <> clNone THEN
    Exit(Marker.Background);

  CASE Marker.Kind OF
    lmkExecutable:
      IF IsDarkTheme(ThemeColors) THEN
        Result := $00282020
      ELSE
        Result := $00F4F4F4;
    lmkError:
      IF IsDarkTheme(ThemeColors) THEN
        Result := $00202060
      ELSE
        Result := $00E8E8FF;
    lmkWarning:
      IF IsDarkTheme(ThemeColors) THEN
        Result := $00204060
      ELSE
        Result := $00D8F4FF;
    lmkInfo:
      IF IsDarkTheme(ThemeColors) THEN
        Result := ShiftBrightness(ThemeColors.Background, 18)
      ELSE
        Result := ShiftBrightness(ThemeColors.Background, -12);
  END;
END;

PROCEDURE TCodeEditor.PaintLineMarkerGlyph(CONST CellRect: TRect; Marker: TCodeLineMarker);
VAR
  R                 : TRect;
  Cx, Cy            : Integer;
  Size              : Integer;
  Points            : ARRAY[0..2] OF TPoint;
  ForeColor         : TColor;
BEGIN
  IF NOT Assigned(Marker) THEN
    Exit;

  IF Marker.Foreground <> clNone THEN
    ForeColor := Marker.Foreground
  ELSE
    CASE Marker.Kind OF
      lmkExecutable: ForeColor := $00707070;
      lmkError: ForeColor := $002020D0;
      lmkWarning: ForeColor := $0000A0E0;
    ELSE
      ForeColor := $00C08020;
    END;

  Size := Max(6, Min(CellRect.Width, FLineHeight) - 8);
  Cx := (CellRect.Left + CellRect.Right) DIV 2;
  Cy := (CellRect.Top + CellRect.Bottom) DIV 2;
  Canvas.Brush.Color := ForeColor;
  Canvas.Pen.Color := ForeColor;

  CASE Marker.Kind OF
    lmkExecutable: BEGIN
        R := Rect(Cx - Size DIV 2, Cy - Size DIV 2, Cx - Size DIV 2 + Size, Cy - Size DIV 2 + Size);
        Canvas.Rectangle(R);
      END;
    lmkError: BEGIN
        Canvas.MoveTo(Cx - Size DIV 2, Cy - Size DIV 2);
        Canvas.LineTo(Cx + Size DIV 2, Cy + Size DIV 2);
        Canvas.MoveTo(Cx + Size DIV 2, Cy - Size DIV 2);
        Canvas.LineTo(Cx - Size DIV 2, Cy + Size DIV 2);
      END;
    lmkWarning: BEGIN
        Points[0] := Point(Cx, Cy - Size DIV 2);
        Points[1] := Point(Cx - Size DIV 2, Cy + Size DIV 2);
        Points[2] := Point(Cx + Size DIV 2, Cy + Size DIV 2);
        Canvas.Polygon(Points);
      END;
  ELSE
    R := Rect(Cx - Size DIV 2, Cy - Size DIV 2, Cx - Size DIV 2 + Size, Cy - Size DIV 2 + Size);
    Canvas.Ellipse(R);
  END;
END;

PROCEDURE TCodeEditor.Paint;
BEGIN
  // Resolve the theme once per paint; the Paint* helpers all read FPaintTheme
  // instead of allocating their own copy per call (or worse, per line).
  FPaintTheme := ActiveTheme;
  TRY
    Canvas.Brush.Color := FPaintTheme.Background;
    Canvas.FillRect(ClientRect);
    Canvas.Font.Assign(Font);
    Canvas.Font.Size := ScaledFontSize;
    Canvas.Font.Color := FPaintTheme.Text;
    PaintGutter;
    PaintText;
    PaintMinimap;
    PaintStyledScrollBars;
  FINALLY
    FreeAndNil(FPaintTheme);
  END;
END;

PROCEDURE TCodeEditor.PaintGutter;
VAR
  I                 : Integer;
  LineIndex         : Integer;
  Y                 : Integer;
  Text              : STRING;
  R                 : TRect;
  Cell              : TRect;
  HasBp             : Boolean;
  IsExec            : Boolean;
  Marker            : TCodeLineMarker;
  ThemeColors       : TCodeEditorThemeColors;
BEGIN
  IF NOT FOptions.ShowGutter THEN
    Exit;

  ThemeColors := FPaintTheme;
  BEGIN
    R := Rect(0, 0, FGutterWidth, ClientHeight);
    Canvas.Brush.Style := bsSolid;
    Canvas.Brush.Color := ThemeColors.GutterBackground;
    Canvas.FillRect(R);
    Canvas.Pen.Color := ThemeColors.GutterBorder;
    Canvas.MoveTo(FGutterWidth - 1, 0);
    Canvas.LineTo(FGutterWidth - 1, ClientHeight);

    FOR I := 0 TO VisibleLineCount - 1 DO BEGIN
      LineIndex := FTopLine + I;
      IF LineIndex >= FLines.Count THEN
        Break;

      Y := I * FLineHeight + 1;
      HasBp := HasBreakpoint(LineIndex + 1);
      IsExec := (LineIndex + 1) = FExecutionLine;
      Marker := FirstLineMarkerAny(LineIndex + 1);

      IF HasBp OR IsExec THEN BEGIN
        Cell := Rect(0, Y - 1, BreakpointMarginWidth, Y - 1 + FLineHeight);
        PaintBreakpointGlyph(Cell, HasBp, IsExec);
        Canvas.Brush.Style := bsSolid;
        Canvas.Brush.Color := ThemeColors.GutterBackground;
      END ELSE IF QueryExecutableLine(LineIndex + 1) THEN BEGIN
        // Executable-line dot, in the same margin a breakpoint/arrow would use.
        Cell := Rect(0, Y - 1, BreakpointMarginWidth, Y - 1 + FLineHeight);
        PaintExecutableDot(Cell);
        Canvas.Brush.Style := bsSolid;
        Canvas.Brush.Color := ThemeColors.GutterBackground;
      END;

      IF Assigned(Marker) THEN BEGIN
        Cell := Rect(BreakpointMarginWidth, Y - 1, BreakpointMarginWidth + 14, Y - 1 + FLineHeight);
        PaintLineMarkerGlyph(Cell, Marker);
        Canvas.Brush.Style := bsSolid;
        Canvas.Brush.Color := ThemeColors.GutterBackground;
      END;

      Canvas.Font.Color := ThemeColors.GutterText;
      Text := IntToStr(LineIndex + 1);
      Canvas.TextOut(FGutterWidth - Canvas.TextWidth(Text) - 8, Y, Text);
    END;
  END;
END;

PROCEDURE TCodeEditor.PaintText;
VAR
  I                 : Integer;
  LineIndex         : Integer;
  Y                 : Integer;
  LineText          : STRING;
  DrawText          : STRING;
  R                 : TRect;
  Marker            : TCodeLineMarker;
  MarkerColor       : TColor;
  ThemeColors       : TCodeEditorThemeColors;
  HaveBracketMatch  : Boolean;
  BracketOpen       : TCodePosition;
  BracketClose      : TCodePosition;
  OccurrenceNeedle  : STRING;
BEGIN
  R := ClientTextRect;
  ThemeColors := FPaintTheme;

  // Per-paint work hoisted out of the per-line loop: the bracket scan can
  // touch the whole document, and the occurrence needle never changes mid-paint.
  HaveBracketMatch := MatchingBracketPosition(BracketOpen, BracketClose);
  OccurrenceNeedle := '';
  IF HasSelection AND (SelectionStart.Line = SelectionEnd.Line) THEN
    OccurrenceNeedle := GetSelectedText;

  Canvas.Brush.Color := ThemeColors.Background;
  FOR I := 0 TO VisibleLineCount - 1 DO BEGIN
    LineIndex := FTopLine + I;
    IF LineIndex >= FLines.Count THEN
      Break;

    Y := I * FLineHeight + 1;
    LineText := FLines[LineIndex];
    // Tabs are drawn as a single space cell so the glyphs line up with the
    // one-column-per-character caret arithmetic.
    IF Pos(#9, LineText) > 0 THEN
      DrawText := StringReplace(LineText, #9, ' ', [rfReplaceAll])
    ELSE
      DrawText := LineText;
    Marker := FirstLineMarkerAny(LineIndex + 1);
    MarkerColor := MarkerBackgroundColor(Marker, ThemeColors);
    IF MarkerColor <> clNone THEN BEGIN
      Canvas.Brush.Color := MarkerColor;
      Canvas.FillRect(Rect(R.Left, Y - 1, R.Right, Y - 1 + FLineHeight));
      Canvas.Brush.Color := ThemeColors.Background;
    END;
    IF (LineIndex + 1) = FExecutionLine THEN BEGIN
      IF IsDarkTheme(ThemeColors) THEN
        Canvas.Brush.Color := ShiftBrightness(ThemeColors.Background, 28)
      ELSE
        Canvas.Brush.Color := ShiftBrightness(ThemeColors.Background, -22);
      Canvas.FillRect(Rect(R.Left, Y - 1, R.Right, Y - 1 + FLineHeight));
      Canvas.Brush.Color := ThemeColors.Background;
    END;
    PaintSearchMatchesLine(LineIndex, Y, LineText);
    PaintOccurrenceHighlightsLine(LineIndex, Y, LineText, OccurrenceNeedle);
    PaintSelectionLine(LineIndex, Y, LineText);
    PaintLineTokens(LineIndex, R.Left, Y, DrawText, clNone);
    PaintSelectedTextLine(LineIndex, R.Left, Y, DrawText);
    IF HaveBracketMatch THEN
      PaintBracketMatchesLine(LineIndex, Y, BracketOpen, BracketClose);
    PaintMultipleCaretsLine(LineIndex, Y);
  END;
END;

PROCEDURE TCodeEditor.PaintMinimap;
VAR
  R                 : TRect;
  ViewR             : TRect;
  ThemeColors       : TCodeEditorThemeColors;
  LineIndex         : Integer;
  FirstLine         : Integer;
  LastLine          : Integer;
  ScrollOffset      : Integer;
  Y                 : Integer;
  LineText          : STRING;
  Trimmed           : STRING;
  FirstNonSpace     : Integer;
  X                 : Integer;
  SegmentWidth      : Integer;
  LineColor         : TColor;
  Tokens            : TCodeTokenArray;
  Token             : TCodeToken;
  Style             : TCodeTextStyle;
  TokenX            : Integer;
  TokenWidth        : Integer;

  FUNCTION MapColumn(Column: Integer): Integer;
  BEGIN
    Result := R.Left + 4 + Min(R.Width - 8, MulDiv(Column, R.Width - 8, 120));
  END;

  PROCEDURE PaintPlainLine;
  BEGIN
    Trimmed := TrimLeft(LineText);
    IF Trimmed = '' THEN
      Exit;

    FirstNonSpace := Length(LineText) - Length(Trimmed);
    X := MapColumn(FirstNonSpace);
    SegmentWidth := Max(2, Min(R.Right - X - 3, MulDiv(Length(Trimmed), R.Width - 8, 120)));
    Canvas.Brush.Color := LineColor;
    Canvas.FillRect(Rect(X, Y, X + SegmentWidth, Min(Y + MinimapLineHeight - 1, R.Bottom)));
  END;

BEGIN
  IF NOT MinimapVisible THEN
    Exit;

  R := MinimapRect;
  IF R.IsEmpty THEN
    Exit;

  ThemeColors := FPaintTheme;
  BEGIN
    IF IsDarkTheme(ThemeColors) THEN
      Canvas.Brush.Color := ShiftBrightness(ThemeColors.Background, 10)
    ELSE
      Canvas.Brush.Color := ShiftBrightness(ThemeColors.Background, -6);
    Canvas.FillRect(R);
    Canvas.Pen.Color := ThemeColors.GutterBorder;
    Canvas.MoveTo(R.Left, R.Top);
    Canvas.LineTo(R.Left, R.Bottom);

    IF IsDarkTheme(ThemeColors) THEN
      LineColor := ShiftBrightness(ThemeColors.Text, -55)
    ELSE
      LineColor := ShiftBrightness(ThemeColors.Text, 90);

    ScrollOffset := MinimapScrollOffset;
    FirstLine := Max(0, ScrollOffset DIV MinimapLineHeight);
    LastLine := Min(FLines.Count - 1, (ScrollOffset + R.Height) DIV MinimapLineHeight + 1);
    FOR LineIndex := FirstLine TO LastLine DO BEGIN
      IF FLines.Count <= 0 THEN
        Break;
      Y := R.Top + LineIndex * MinimapLineHeight - ScrollOffset;
      IF Y >= R.Bottom - 2 THEN
        Continue;
      LineText := FLines[LineIndex];

      IF Assigned(FHighlighter) THEN BEGIN
        Tokens := LineTokens(LineIndex);
        IF Length(Tokens) = 0 THEN
          PaintPlainLine
        ELSE
          FOR Token IN Tokens DO BEGIN
            IF Token.Kind = tkWhitespace THEN
              Continue;
            Style := TokenStyleForTheme(Token.Kind, FHighlighter.Styles[Token.Kind], ThemeColors);
            TokenX := MapColumn(Token.Start - 1);
            TokenWidth := Max(1, Min(R.Right - TokenX - 3, MulDiv(Token.Length, R.Width - 8, 120)));
            Canvas.Brush.Color := Style.Foreground;
            Canvas.FillRect(Rect(TokenX, Y, TokenX + TokenWidth,
              Min(Y + MinimapLineHeight - 1, R.Bottom)));
          END;
      END ELSE
        PaintPlainLine;
    END;

    ViewR := MinimapViewportRect;
    Canvas.Brush.Style := bsClear;
    IF IsDarkTheme(ThemeColors) THEN
      Canvas.Pen.Color := ShiftBrightness(ThemeColors.SelectionBackground, -20)
    ELSE
      Canvas.Pen.Color := ShiftBrightness(ThemeColors.SelectionBackground, 20);
    Canvas.Rectangle(ViewR);
    Canvas.Brush.Style := bsSolid;
  END;
END;

PROCEDURE TCodeEditor.PaintStyledScrollBars;
VAR
  Track             : TRect;
  Thumb             : TRect;
  ThemeColors       : TCodeEditorThemeColors;
  TrackColor        : TColor;
  ThumbColor        : TColor;
BEGIN
  IF NOT FStyledScrollBars THEN
    Exit;

  ThemeColors := FPaintTheme;
  TrackColor := ThemeColors.GutterBackground;
  IF IsDarkTheme(ThemeColors) THEN
    ThumbColor := ShiftBrightness(TrackColor, 40)
  ELSE
    ThumbColor := ShiftBrightness(TrackColor, -50);

  IF StyledVerticalVisible THEN BEGIN
    Track := StyledVerticalScrollRect;
    Canvas.Brush.Color := TrackColor;
    Canvas.FillRect(Track);

    Thumb := StyledVerticalThumbRect;
    IF Thumb.Height > 0 THEN BEGIN
      InflateRect(Thumb, -2, -2);
      Canvas.Brush.Color := ThumbColor;
      Canvas.FillRect(Thumb);
    END;
  END;

  IF StyledHorizontalVisible THEN BEGIN
    Track := StyledHorizontalScrollRect;
    Canvas.Brush.Color := TrackColor;
    Canvas.FillRect(Track);

    Thumb := StyledHorizontalThumbRect;
    IF Thumb.Width > 0 THEN BEGIN
      InflateRect(Thumb, -2, -2);
      Canvas.Brush.Color := ThumbColor;
      Canvas.FillRect(Thumb);
    END;
  END;
END;

PROCEDURE TCodeEditor.PaintSelectionLine(ALineIndex, Y: Integer; CONST LineText: STRING);
VAR
  Range             : TCodeSelectionRange;
  StartCol          : Integer;
  EndCol            : Integer;
  X1                : Integer;
  X2                : Integer;
  R                 : TRect;
  ThemeColors       : TCodeEditorThemeColors;

  PROCEDURE PaintRange(CONST AStart, AEnd: TCodePosition);
  BEGIN
    IF (ALineIndex < AStart.Line) OR (ALineIndex > AEnd.Line) THEN
      Exit;

    StartCol := 0;
    EndCol := Length(LineText);
    IF ALineIndex = AStart.Line THEN
      StartCol := AStart.Column;
    IF ALineIndex = AEnd.Line THEN
      EndCol := AEnd.Column;

    R := ClientTextRect;
    X1 := R.Left + (StartCol - FLeftColumn) * FCharWidth;
    X2 := R.Left + (EndCol - FLeftColumn) * FCharWidth;
    IF ComparePositions(AStart, AEnd) = 0 THEN
      Exit;

    Canvas.Brush.Color := ThemeColors.SelectionBackground;
    Canvas.FillRect(Rect(Max(R.Left, X1), Y - 1, Max(R.Left, X2), Y + FLineHeight - 1));
  END;

BEGIN
  IF NOT HasSelection AND NOT HasMultipleSelections THEN
    Exit;

  ThemeColors := FPaintTheme;
  IF HasSelection THEN
    PaintRange(SelectionStart, SelectionEnd);
  IF HasMultipleSelections THEN
    FOR Range IN FSelections DO
      PaintRange(RangeStart(Range), RangeEnd(Range));
END;

PROCEDURE TCodeEditor.PaintMultipleCaretsLine(ALineIndex, Y: Integer);
VAR
  Range             : TCodeSelectionRange;
  Position          : TCodePosition;
  R                 : TRect;
  X                 : Integer;
  ThemeColors       : TCodeEditorThemeColors;

  PROCEDURE PaintCaretAt(CONST CaretPosition: TCodePosition);
  BEGIN
    IF CaretPosition.Line <> ALineIndex THEN
      Exit;

    R := ClientTextRect;
    X := R.Left + (CaretPosition.Column - FLeftColumn) * FCharWidth;
    IF (X < R.Left) OR (X > R.Right) THEN
      Exit;

    Canvas.Pen.Color := ThemeColors.SelectionBackground;
    Canvas.MoveTo(X, Y);
    Canvas.LineTo(X, Y + FLineHeight - 1);
    Canvas.Pen.Color := ThemeColors.Text;
    Canvas.MoveTo(X + 1, Y);
    Canvas.LineTo(X + 1, Y + FLineHeight - 1);
  END;
BEGIN
  IF NOT HasMultipleSelections THEN
    Exit;

  ThemeColors := FPaintTheme;
  FOR Range IN FSelections DO
    IF ComparePositions(Range.Anchor, Range.Caret) = 0 THEN BEGIN
      Position := NormalizePosition(Range.Caret);
      PaintCaretAt(Position);
    END;
END;

PROCEDURE TCodeEditor.PaintBracketMatchesLine(ALineIndex, Y: Integer;
  CONST OpenPos, ClosePos: TCodePosition);
VAR
  R                 : TRect;
  X                 : Integer;
  Box               : TRect;

  PROCEDURE PaintMatch(CONST Position: TCodePosition);
  BEGIN
    IF Position.Line <> ALineIndex THEN
      Exit;
    R := ClientTextRect;
    X := R.Left + (Position.Column - FLeftColumn) * FCharWidth;
    Box := Rect(X, Y - 1, X + FCharWidth, Y + FLineHeight - 1);
    IF (Box.Right < R.Left) OR (Box.Left > R.Right) THEN
      Exit;
    Canvas.Brush.Style := bsClear;
    Canvas.Pen.Color := FPaintTheme.SelectionBackground;
    Canvas.Rectangle(Box);
    Canvas.Brush.Style := bsSolid;
  END;

BEGIN
  PaintMatch(OpenPos);
  PaintMatch(ClosePos);
END;

PROCEDURE TCodeEditor.PaintOccurrenceHighlightsLine(ALineIndex, Y: Integer;
  CONST LineText, Needle: STRING);
VAR
  SearchStart       : Integer;
  FoundAt           : Integer;
  R                 : TRect;
  X1                : Integer;
  X2                : Integer;
  FillColor         : TColor;
  Range             : TCodeSelectionRange;

  FUNCTION SameRange(CONST AStart, AEnd, BStart, BEnd: TCodePosition): Boolean;
  BEGIN
    Result := (ComparePositions(AStart, BStart) = 0) AND (ComparePositions(AEnd, BEnd) = 0);
  END;

  FUNCTION IsActiveSelection(CONST AStart, AEnd: TCodePosition): Boolean;
  VAR
    ActiveStart     : TCodePosition;
    ActiveEnd       : TCodePosition;
    ActiveRange     : TCodeSelectionRange;
  BEGIN
    ActiveStart := SelectionStart;
    ActiveEnd := SelectionEnd;
    Result := SameRange(AStart, AEnd, ActiveStart, ActiveEnd);
    IF Result THEN
      Exit;

    FOR ActiveRange IN FSelections DO BEGIN
      IF ComparePositions(ActiveRange.Anchor, ActiveRange.Caret) = 0 THEN
        Continue;
      IF SameRange(AStart, AEnd, RangeStart(ActiveRange), RangeEnd(ActiveRange)) THEN
        Exit(True);
    END;
  END;
BEGIN
  IF Needle = '' THEN
    Exit;

  IF IsDarkTheme(FPaintTheme) THEN
    FillColor := ShiftBrightness(FPaintTheme.Background, 36)
  ELSE
    FillColor := ShiftBrightness(FPaintTheme.Background, -24);

  R := ClientTextRect;
  SearchStart := 1;
  REPEAT
    FoundAt := PosEx(Needle, LineText, SearchStart);
    IF FoundAt = 0 THEN
      Break;

    Range.Anchor := TCodePosition.Create(ALineIndex, FoundAt - 1);
    Range.Caret := TCodePosition.Create(ALineIndex, FoundAt - 1 + Length(Needle));
    IF NOT IsActiveSelection(RangeStart(Range), RangeEnd(Range)) THEN BEGIN
      X1 := R.Left + (RangeStart(Range).Column - FLeftColumn) * FCharWidth;
      X2 := R.Left + (RangeEnd(Range).Column - FLeftColumn) * FCharWidth;
      Canvas.Brush.Color := FillColor;
      Canvas.FillRect(Rect(Max(R.Left, X1), Y - 1, Max(R.Left, X2), Y + FLineHeight - 1));
    END;

    SearchStart := FoundAt + Max(1, Length(Needle));
  UNTIL SearchStart > Length(LineText);
END;

PROCEDURE TCodeEditor.PaintSearchMatchesLine(ALineIndex, Y: Integer; CONST LineText: STRING);
VAR
  I                 : Integer;
  Match             : TCodeSearchMatch;
  R                 : TRect;
  X1                : Integer;
  X2                : Integer;
  FillColor         : TColor;
BEGIN
  IF NOT SearchVisible OR NOT Assigned(FSearchMatches) THEN
    Exit;

  R := ClientTextRect;
  FOR I := 0 TO FSearchMatches.Count - 1 DO BEGIN
    Match := FSearchMatches[I];
    IF Match.Line <> ALineIndex THEN
      Continue;

    X1 := R.Left + (Match.Column - FLeftColumn) * FCharWidth;
    X2 := R.Left + (Match.Column + Match.Length - FLeftColumn) * FCharWidth;
    IF I = FSearchIndex THEN
      FillColor := $00606000
    ELSE
      FillColor := $00404040;

    Canvas.Brush.Color := FillColor;
    Canvas.FillRect(Rect(Max(R.Left, X1), Y - 1, Max(R.Left, X2), Y + FLineHeight - 1));
  END;
END;

PROCEDURE TCodeEditor.PaintLineTokens(ALineIndex, X, Y: Integer; CONST LineText: STRING;
  ForcedColor: TColor);
VAR
  Tokens            : TCodeTokenArray;
  Token             : TCodeToken;
  Style             : TCodeTextStyle;
  Text              : STRING;
  TokenX            : Integer;
BEGIN
  IF NOT Assigned(FHighlighter) THEN BEGIN
    IF ForcedColor <> clNone THEN
      Canvas.Font.Color := ForcedColor
    ELSE
      Canvas.Font.Color := FPaintTheme.Text;
    Canvas.Brush.Style := bsClear;
    Canvas.TextOut(X - FLeftColumn * FCharWidth, Y, LineText);
    Canvas.Brush.Style := bsSolid;
    Exit;
  END;

  Tokens := LineTokens(ALineIndex);
  FOR Token IN Tokens DO BEGIN
    Text := Copy(LineText, Token.Start, Token.Length);
    TokenX := X + (Token.Start - 1 - FLeftColumn) * FCharWidth;
    Style := FHighlighter.Styles[Token.Kind];
    IF FOptions.ThemeSyntaxColors THEN
      Style := TokenStyleForTheme(Token.Kind, Style, FPaintTheme);
    IF ForcedColor <> clNone THEN
      Canvas.Font.Color := ForcedColor
    ELSE
      Canvas.Font.Color := Style.Foreground;
    Canvas.Font.Style := Style.FontStyle;
    Canvas.Brush.Style := bsClear;
    Canvas.TextOut(TokenX, Y, Text);
  END;

  Canvas.Brush.Style := bsSolid;
  Canvas.Font.Style := Font.Style;
END;

PROCEDURE TCodeEditor.PaintSelectedTextLine(ALineIndex, X, Y: Integer; CONST LineText: STRING);
VAR
  R                 : TRect;
  Range             : TCodeSelectionRange;

  // Redraws the selected slice of the line clipped to the selection rect,
  // using the theme's SelectionText color so selected text stays readable.
  PROCEDURE PaintRange(CONST AStart, AEnd: TCodePosition);
  VAR
    StartCol        : Integer;
    EndCol          : Integer;
    X1              : Integer;
    X2              : Integer;
    SaveIndex       : Integer;
  BEGIN
    IF (ALineIndex < AStart.Line) OR (ALineIndex > AEnd.Line) THEN
      Exit;
    IF ComparePositions(AStart, AEnd) = 0 THEN
      Exit;

    StartCol := 0;
    EndCol := Length(LineText);
    IF ALineIndex = AStart.Line THEN
      StartCol := AStart.Column;
    IF ALineIndex = AEnd.Line THEN
      EndCol := Min(EndCol, AEnd.Column);
    IF EndCol <= StartCol THEN
      Exit;

    X1 := Max(R.Left, R.Left + (StartCol - FLeftColumn) * FCharWidth);
    X2 := Max(R.Left, R.Left + (EndCol - FLeftColumn) * FCharWidth);
    IF X2 <= X1 THEN
      Exit;

    SaveIndex := SaveDC(Canvas.Handle);
    TRY
      IntersectClipRect(Canvas.Handle, X1, Y - 1, X2, Y + FLineHeight - 1);
      PaintLineTokens(ALineIndex, X, Y, LineText, FPaintTheme.SelectionText);
    FINALLY
      RestoreDC(Canvas.Handle, SaveIndex);
    END;
  END;

BEGIN
  IF NOT HasSelection AND NOT HasMultipleSelections THEN
    Exit;

  R := ClientTextRect;
  IF HasSelection THEN
    PaintRange(SelectionStart, SelectionEnd);
  IF HasMultipleSelections THEN
    FOR Range IN FSelections DO
      PaintRange(RangeStart(Range), RangeEnd(Range));
END;

END.

