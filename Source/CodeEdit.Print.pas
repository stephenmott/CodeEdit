UNIT CodeEdit.Print;

// Printing for TCodeEditor: TCodeEditorPrinter paginates the editor's text
// for a device, draws pages with the highlighter's colours, line numbers and
// header/footer bands, prints them (optionally through the standard print
// dialog) and shows a preview dialog. Pages are laid out per device, so the
// same component serves the printer, the preview bitmap and any custom
// canvas a host wants to draw into (Paginate + DrawPage).

INTERFACE

USES
  System.Classes,
  System.SysUtils,
  System.Types,
  System.UITypes,
  Vcl.Controls,
  Vcl.ExtCtrls,
  Vcl.Forms,
  Vcl.Graphics,
  Vcl.Printers,
  Vcl.StdCtrls,
  Winapi.Windows,
  CodeEdit.Editor,
  CodeEdit.Highlighter;

TYPE
  // Page margins in millimetres, measured from the paper edge.
  TCodePrintMargins = CLASS(TPersistent)
  PRIVATE
    FValues: ARRAY[0..3] OF Integer;
    FOnChange: TNotifyEvent;
    FUNCTION GetValue(Index: Integer): Integer;
    PROCEDURE SetValue(Index: Integer; Value: Integer);
  PUBLIC
    CONSTRUCTOR Create;
    PROCEDURE Assign(Source: TPersistent); OVERRIDE;
    PROPERTY OnChange: TNotifyEvent READ FOnChange WRITE FOnChange;
  PUBLISHED
    PROPERTY Left: Integer INDEX 0 READ GetValue WRITE SetValue DEFAULT 15;
    PROPERTY Top: Integer INDEX 1 READ GetValue WRITE SetValue DEFAULT 15;
    PROPERTY Right: Integer INDEX 2 READ GetValue WRITE SetValue DEFAULT 15;
    PROPERTY Bottom: Integer INDEX 3 READ GetValue WRITE SetValue DEFAULT 15;
  END;

  TCodePrintOption = (
    cpoLineNumbers,       // line-number column on the left of the text
    cpoSyntaxColors,      // token colours from the highlighter; off = black (bold/italic kept)
    cpoWordWrap,          // wrap long lines at the right margin; off = cut
    cpoHeader,            // print the Header band
    cpoFooter,            // print the Footer band
    cpoSelectionOnly      // only the lines covered by the editor's selection
    );
  TCodePrintOptions = SET OF TCodePrintOption;

  // Portrait/landscape, or whatever the printer (or the Printer Setup
  // dialog) is currently set to.
  TCodePrintOrientation = (cprPrinterDefault, cprPortrait, cprLandscape);

  // One printed row: a document line or, with word wrap, a slice of one.
  TCodePrintRow = RECORD
    Line: Integer;        // 0-based document line
    StartCol: Integer;    // 0-based first column of the slice
    Length: Integer;      // characters in the slice
    First: Boolean;       // first slice of its line (carries the line number)
  END;

  // The layout of the document for one device: the result of Paginate and
  // the input to DrawPage. All rectangles are in device pixels in the
  // canvas's coordinate space.
  TCodePrintLayout = RECORD
    DpiX: Integer;
    DpiY: Integer;
    Paper: TRect;         // the physical sheet
    Printable: TRect;     // the part of it the device can mark
    Content: TRect;       // Paper inside the margins, clipped to Printable
    Body: TRect;          // Content minus the header and footer bands
    CharWidth: Integer;
    LineHeight: Integer;
    GutterWidth: Integer; // line-number column including its gap; 0 when off
    Columns: Integer;     // text cells per row
    RowsPerPage: Integer;
    HeaderHeight: Integer;
    FooterHeight: Integer;
    Rows: TArray<TCodePrintRow>;
    PageCount: Integer;
  END;

  TCodeEditorPrinter = CLASS(TComponent)
  PRIVATE
    FEditor: TCodeEditor;
    FTitle: STRING;
    FHeader: STRING;
    FFooter: STRING;
    FMargins: TCodePrintMargins;
    FOptions: TCodePrintOptions;
    FFont: TFont;
    FUseEditorFont: Boolean;
    FHeaderFont: TFont;
    FCopies: Integer;
    FOrientation: TCodePrintOrientation;
    PROCEDURE SetEditor(Value: TCodeEditor);
    PROCEDURE SetMargins(Value: TCodePrintMargins);
    PROCEDURE SetFont(Value: TFont);
    PROCEDURE SetHeaderFont(Value: TFont);
    FUNCTION EffectiveFont: TFont;
    FUNCTION SourceLineRange(OUT FirstLine, LastLine: Integer): Boolean;
    PROCEDURE SetupFont(ACanvas: TCanvas; AFont: TFont; DpiY: Integer);
    PROCEDURE DrawBand(ACanvas: TCanvas; CONST Layout: TCodePrintLayout; CONST Text: STRING;
      PageIndex: Integer; IsHeader: Boolean);
    PROCEDURE DrawRow(ACanvas: TCanvas; CONST Layout: TCodePrintLayout; CONST Row: TCodePrintRow;
      Y: Integer);
    FUNCTION PrinterPaper(OUT Paper, Printable: TRect; OUT DpiX, DpiY: Integer): Boolean;
    PROCEDURE ApplyOrientation;
    PROCEDURE CheckPrinter;
  PROTECTED
    PROCEDURE Notification(AComponent: TComponent; Operation: TOperation); OVERRIDE;
  PUBLIC
    CONSTRUCTOR Create(AOwner: TComponent); OVERRIDE;
    DESTRUCTOR Destroy; OVERRIDE;
    // Lays the document out for a device. ACanvas is used to measure the
    // fonts; PaperRect is the physical sheet and PrintableRect the part the
    // device can reach (pass the same rect for a bitmap).
    FUNCTION Paginate(ACanvas: TCanvas; CONST PaperRect, PrintableRect: TRect;
      DpiX, DpiY: Integer): TCodePrintLayout;
    // Draws one page (0-based) of a layout. Clears nothing: fill the page
    // first when drawing into a bitmap.
    PROCEDURE DrawPage(ACanvas: TCanvas; CONST Layout: TCodePrintLayout; PageIndex: Integer);
    // Pages the document takes on the current printer (A4 at 300 dpi when no
    // printer is installed).
    FUNCTION PageCount: Integer;
    // Prints every page, or the 1-based inclusive range, on the current printer.
    PROCEDURE Print; OVERLOAD;
    PROCEDURE Print(FromPage, ToPage: Integer); OVERLOAD;
    // Shows the standard print dialog (page range, copies, printer) and
    // prints accordingly. False when the user cancels.
    FUNCTION Execute: Boolean;
    // Modal print preview with paging, zoom and a Print button.
    PROCEDURE Preview;
    // Header/footer macro expansion: $TITLE, $PAGE, $PAGES, $DATE, $TIME.
    // Sections separated by '|' are placed left | centre | right.
    FUNCTION ExpandMacros(CONST S: STRING; PageIndex, APageCount: Integer): STRING;
  PUBLISHED
    PROPERTY Editor: TCodeEditor READ FEditor WRITE SetEditor;
    // Shown by $TITLE in the header/footer and as the print job's name.
    PROPERTY Title: STRING READ FTitle WRITE FTitle;
    PROPERTY Header: STRING READ FHeader WRITE FHeader;
    PROPERTY Footer: STRING READ FFooter WRITE FFooter;
    PROPERTY Margins: TCodePrintMargins READ FMargins WRITE SetMargins;
    PROPERTY Options: TCodePrintOptions READ FOptions WRITE FOptions
      DEFAULT [cpoLineNumbers, cpoSyntaxColors, cpoWordWrap, cpoHeader, cpoFooter];
    // Text font when UseEditorFont is False.
    PROPERTY Font: TFont READ FFont WRITE SetFont;
    PROPERTY UseEditorFont: Boolean READ FUseEditorFont WRITE FUseEditorFont DEFAULT True;
    PROPERTY HeaderFont: TFont READ FHeaderFont WRITE SetHeaderFont;
    PROPERTY Copies: Integer READ FCopies WRITE FCopies DEFAULT 1;
    PROPERTY Orientation: TCodePrintOrientation READ FOrientation WRITE FOrientation
      DEFAULT cprPrinterDefault;
  END;

  // The preview dialog. Created by TCodeEditorPrinter.Preview; public so a
  // host can subclass or restyle it.
  TCodePrintPreviewForm = CLASS(TForm)
  PRIVATE
    FPrinter: TCodeEditorPrinter;
    FLayout: TCodePrintLayout;
    FPage: Integer;
    FZoomPercent: Integer;        // 0 = fit page, -1 = fit width
    FPageBitmap: Vcl.Graphics.TBitmap;   // the page at device resolution
    FToolbar: TPanel;
    FFirstButton: TButton;
    FPrevButton: TButton;
    FNextButton: TButton;
    FLastButton: TButton;
    FPageLabel: TLabel;
    FZoomCombo: TComboBox;
    FPrintButton: TButton;
    FCloseButton: TButton;
    FScrollBox: TScrollBox;
    FImage: TImage;
    PROCEDURE BuildLayout;
    PROCEDURE RenderPage;
    PROCEDURE UpdateView;
    PROCEDURE NavigateClick(Sender: TObject);
    PROCEDURE ZoomChange(Sender: TObject);
    PROCEDURE PrintClick(Sender: TObject);
    PROCEDURE CloseClick(Sender: TObject);
    PROCEDURE ScrollBoxResize(Sender: TObject);
    PROCEDURE FormKeyDown(Sender: TObject; VAR Key: Word; Shift: TShiftState);
  PUBLIC
    CONSTRUCTOR CreateFor(APrinter: TCodeEditorPrinter);
    DESTRUCTOR Destroy; OVERRIDE;
    PROPERTY Page: Integer READ FPage;
  END;

IMPLEMENTATION

USES
  System.Math,
  System.StrUtils,
  Vcl.Dialogs;

CONST
  FallbackDpi       = 300;
  A4WidthMm         = 210;
  A4HeightMm        = 297;
  PreviewMaxDpi     = 300;      // render the preview page at most this fine

FUNCTION MmToPx(Mm, Dpi: Integer): Integer;
BEGIN
  Result := Round(Mm * Dpi / 25.4);
END;

{ TCodePrintMargins }

CONSTRUCTOR TCodePrintMargins.Create;
VAR
  I                 : Integer;
BEGIN
  INHERITED Create;
  FOR I := 0 TO 3 DO
    FValues[I] := 15;
END;

PROCEDURE TCodePrintMargins.Assign(Source: TPersistent);
BEGIN
  IF Source IS TCodePrintMargins THEN BEGIN
    FValues := TCodePrintMargins(Source).FValues;
    IF Assigned(FOnChange) THEN
      FOnChange(Self);
  END ELSE
    INHERITED;
END;

FUNCTION TCodePrintMargins.GetValue(Index: Integer): Integer;
BEGIN
  Result := FValues[Index];
END;

PROCEDURE TCodePrintMargins.SetValue(Index: Integer; Value: Integer);
BEGIN
  Value := Max(0, Value);
  IF FValues[Index] <> Value THEN BEGIN
    FValues[Index] := Value;
    IF Assigned(FOnChange) THEN
      FOnChange(Self);
  END;
END;

{ TCodeEditorPrinter }

CONSTRUCTOR TCodeEditorPrinter.Create(AOwner: TComponent);
BEGIN
  INHERITED Create(AOwner);
  FMargins := TCodePrintMargins.Create;
  FOptions := [cpoLineNumbers, cpoSyntaxColors, cpoWordWrap, cpoHeader, cpoFooter];
  FFont := TFont.Create;
  FFont.Name := 'Consolas';
  FFont.Size := 10;
  FUseEditorFont := True;
  FHeaderFont := TFont.Create;
  FHeaderFont.Name := 'Segoe UI';
  FHeaderFont.Size := 9;
  FHeader := '$TITLE||$DATE $TIME';
  FFooter := '|Page $PAGE of $PAGES|';
  FCopies := 1;
  FOrientation := cprPrinterDefault;
END;

DESTRUCTOR TCodeEditorPrinter.Destroy;
BEGIN
  FHeaderFont.Free;
  FFont.Free;
  FMargins.Free;
  INHERITED;
END;

PROCEDURE TCodeEditorPrinter.Notification(AComponent: TComponent; Operation: TOperation);
BEGIN
  INHERITED;
  IF (Operation = opRemove) AND (AComponent = FEditor) THEN
    FEditor := NIL;
END;

PROCEDURE TCodeEditorPrinter.SetEditor(Value: TCodeEditor);
BEGIN
  IF FEditor <> Value THEN BEGIN
    IF Assigned(FEditor) THEN
      FEditor.RemoveFreeNotification(Self);
    FEditor := Value;
    IF Assigned(FEditor) THEN
      FEditor.FreeNotification(Self);
  END;
END;

PROCEDURE TCodeEditorPrinter.SetMargins(Value: TCodePrintMargins);
BEGIN
  FMargins.Assign(Value);
END;

PROCEDURE TCodeEditorPrinter.SetFont(Value: TFont);
BEGIN
  FFont.Assign(Value);
END;

PROCEDURE TCodeEditorPrinter.SetHeaderFont(Value: TFont);
BEGIN
  FHeaderFont.Assign(Value);
END;

FUNCTION TCodeEditorPrinter.EffectiveFont: TFont;
BEGIN
  IF FUseEditorFont AND Assigned(FEditor) THEN
    Result := FEditor.Font
  ELSE
    Result := FFont;
END;

// The document lines to print: everything, or the selection's lines.
FUNCTION TCodeEditorPrinter.SourceLineRange(OUT FirstLine, LastLine: Integer): Boolean;
VAR
  SelStart          : TCodePosition;
  SelEnd            : TCodePosition;
BEGIN
  FirstLine := 0;
  LastLine := -1;
  Result := Assigned(FEditor) AND (FEditor.Lines.Count > 0);
  IF NOT Result THEN
    Exit;
  LastLine := FEditor.Lines.Count - 1;
  IF (cpoSelectionOnly IN FOptions) AND FEditor.HasSelection THEN BEGIN
    SelStart := FEditor.SelectionStart;
    SelEnd := FEditor.SelectionEnd;
    FirstLine := SelStart.Line;
    LastLine := SelEnd.Line;
    // A selection ending at column 0 of a line doesn't include that line.
    IF (SelEnd.Column = 0) AND (LastLine > FirstLine) THEN
      Dec(LastLine);
  END;
END;

// Puts AFont on the canvas at the device's resolution, keeping its point size.
PROCEDURE TCodeEditorPrinter.SetupFont(ACanvas: TCanvas; AFont: TFont; DpiY: Integer);
VAR
  PointSize         : Integer;
BEGIN
  PointSize := AFont.Size;
  ACanvas.Font.Assign(AFont);
  ACanvas.Font.PixelsPerInch := DpiY;
  ACanvas.Font.Size := PointSize;
  ACanvas.Font.Color := clBlack;
END;

FUNCTION TCodeEditorPrinter.ExpandMacros(CONST S: STRING; PageIndex, APageCount: Integer): STRING;
BEGIN
  Result := S;
  // $PAGES before $PAGE: the shorter macro is a prefix of the longer one.
  Result := StringReplace(Result, '$PAGES', IntToStr(APageCount), [rfReplaceAll, rfIgnoreCase]);
  Result := StringReplace(Result, '$PAGE', IntToStr(PageIndex + 1), [rfReplaceAll, rfIgnoreCase]);
  Result := StringReplace(Result, '$TITLE', FTitle, [rfReplaceAll, rfIgnoreCase]);
  Result := StringReplace(Result, '$DATE', DateToStr(Now), [rfReplaceAll, rfIgnoreCase]);
  Result := StringReplace(Result, '$TIME', TimeToStr(Now), [rfReplaceAll, rfIgnoreCase]);
END;

FUNCTION TCodeEditorPrinter.Paginate(ACanvas: TCanvas; CONST PaperRect, PrintableRect: TRect;
  DpiX, DpiY: Integer): TCodePrintLayout;
VAR
  FirstLine         : Integer;
  LastLine          : Integer;
  Line              : Integer;
  Text              : STRING;
  Len               : Integer;
  Start             : Integer;
  Chunk             : Integer;
  BreakAt           : Integer;
  FirstSlice        : Boolean;
  Rows              : TArray<TCodePrintRow>;
  RowCount          : Integer;
  Digits            : Integer;
  BandText          : Integer;

  PROCEDURE AddRow(ALine, AStart, ALength: Integer; AFirst: Boolean);
  BEGIN
    IF RowCount = Length(Rows) THEN
      SetLength(Rows, Max(64, RowCount * 2));
    Rows[RowCount].Line := ALine;
    Rows[RowCount].StartCol := AStart;
    Rows[RowCount].Length := ALength;
    Rows[RowCount].First := AFirst;
    Inc(RowCount);
  END;

BEGIN
  Result := Default(TCodePrintLayout);
  Result.DpiX := Max(1, DpiX);
  Result.DpiY := Max(1, DpiY);
  Result.Paper := PaperRect;
  Result.Printable := PrintableRect;

  // Margins from the paper edge, then clipped to what the device can print.
  Result.Content := Rect(PaperRect.Left + MmToPx(FMargins.Left, DpiX),
    PaperRect.Top + MmToPx(FMargins.Top, DpiY),
    PaperRect.Right - MmToPx(FMargins.Right, DpiX),
    PaperRect.Bottom - MmToPx(FMargins.Bottom, DpiY));
  Result.Content.Left := Max(Result.Content.Left, PrintableRect.Left);
  Result.Content.Top := Max(Result.Content.Top, PrintableRect.Top);
  Result.Content.Right := Min(Result.Content.Right, PrintableRect.Right);
  Result.Content.Bottom := Min(Result.Content.Bottom, PrintableRect.Bottom);
  IF Result.Content.Right <= Result.Content.Left + 10 THEN
    Result.Content.Right := Result.Content.Left + 10;
  IF Result.Content.Bottom <= Result.Content.Top + 10 THEN
    Result.Content.Bottom := Result.Content.Top + 10;

  // Text metrics. Tabs are printed as a single cell, as the editor draws them.
  SetupFont(ACanvas, EffectiveFont, DpiY);
  Result.CharWidth := Max(1, ACanvas.TextWidth('M'));
  Result.LineHeight := Max(1, ACanvas.TextHeight('Wg') + Max(1, DpiY DIV 150));

  // Header/footer bands: the band font's height plus a gap for the rule.
  SetupFont(ACanvas, FHeaderFont, DpiY);
  BandText := ACanvas.TextHeight('Wg');
  IF (cpoHeader IN FOptions) AND (FHeader <> '') THEN
    Result.HeaderHeight := BandText + Result.LineHeight;
  IF (cpoFooter IN FOptions) AND (FFooter <> '') THEN
    Result.FooterHeight := BandText + Result.LineHeight;
  Result.Body := Result.Content;
  Inc(Result.Body.Top, Result.HeaderHeight);
  Dec(Result.Body.Bottom, Result.FooterHeight);
  IF Result.Body.Bottom < Result.Body.Top + Result.LineHeight THEN
    Result.Body.Bottom := Result.Body.Top + Result.LineHeight;

  Rows := NIL;
  RowCount := 0;
  IF SourceLineRange(FirstLine, LastLine) THEN BEGIN
    IF cpoLineNumbers IN FOptions THEN BEGIN
      Digits := Length(IntToStr(LastLine + 1));
      Result.GutterWidth := (Digits + 2) * Result.CharWidth;
    END;
    Result.Columns := Max(1, (Result.Body.Width - Result.GutterWidth) DIV Result.CharWidth);

    FOR Line := FirstLine TO LastLine DO BEGIN
      Text := FEditor.Lines[Line];
      Len := Length(Text);
      IF Len = 0 THEN
        AddRow(Line, 0, 0, True)
      ELSE IF NOT (cpoWordWrap IN FOptions) THEN
        AddRow(Line, 0, Min(Len, Result.Columns), True)
      ELSE BEGIN
        Start := 0;
        FirstSlice := True;
        WHILE Start < Len DO BEGIN
          Chunk := Min(Result.Columns, Len - Start);
          IF Start + Chunk < Len THEN BEGIN
            // Prefer breaking after a space in the second half of the row.
            BreakAt := Chunk;
            WHILE (BreakAt > Result.Columns DIV 2) AND (Text[Start + BreakAt] <> ' ') DO
              Dec(BreakAt);
            IF BreakAt > Result.Columns DIV 2 THEN
              Chunk := BreakAt;
          END;
          AddRow(Line, Start, Chunk, FirstSlice);
          Inc(Start, Chunk);
          FirstSlice := False;
        END;
      END;
    END;
  END ELSE
    Result.Columns := Max(1, Result.Body.Width DIV Result.CharWidth);

  SetLength(Rows, RowCount);
  Result.Rows := Rows;
  Result.RowsPerPage := Max(1, Result.Body.Height DIV Result.LineHeight);
  Result.PageCount := (RowCount + Result.RowsPerPage - 1) DIV Result.RowsPerPage;
END;

PROCEDURE TCodeEditorPrinter.DrawBand(ACanvas: TCanvas; CONST Layout: TCodePrintLayout;
  CONST Text: STRING; PageIndex: Integer; IsHeader: Boolean);
VAR
  Expanded          : STRING;
  Parts             : TArray<STRING>;
  TextY             : Integer;
  RuleY             : Integer;
  Part              : STRING;
BEGIN
  Expanded := ExpandMacros(Text, PageIndex, Layout.PageCount);
  Parts := Expanded.Split(['|']);
  SetupFont(ACanvas, FHeaderFont, Layout.DpiY);
  ACanvas.Brush.Style := bsClear;

  IF IsHeader THEN BEGIN
    TextY := Layout.Content.Top;
    RuleY := Layout.Body.Top - Layout.LineHeight DIV 2;
  END ELSE BEGIN
    TextY := Layout.Content.Bottom - ACanvas.TextHeight('Wg');
    RuleY := Layout.Body.Bottom + Layout.LineHeight DIV 2;
  END;

  // left | centre | right; a string without '|' is a single left section.
  IF Length(Parts) >= 1 THEN
    ACanvas.TextOut(Layout.Content.Left, TextY, Parts[0]);
  IF Length(Parts) >= 2 THEN BEGIN
    Part := Parts[1];
    ACanvas.TextOut(Layout.Content.Left + (Layout.Content.Width - ACanvas.TextWidth(Part)) DIV 2,
      TextY, Part);
  END;
  IF Length(Parts) >= 3 THEN BEGIN
    Part := Parts[2];
    ACanvas.TextOut(Layout.Content.Right - ACanvas.TextWidth(Part), TextY, Part);
  END;

  ACanvas.Pen.Color := clGray;
  ACanvas.Pen.Width := Max(1, Layout.DpiY DIV 150);
  ACanvas.MoveTo(Layout.Content.Left, RuleY);
  ACanvas.LineTo(Layout.Content.Right, RuleY);
  ACanvas.Pen.Width := 1;
  ACanvas.Brush.Style := bsSolid;
END;

PROCEDURE TCodeEditorPrinter.DrawRow(ACanvas: TCanvas; CONST Layout: TCodePrintLayout;
  CONST Row: TCodePrintRow; Y: Integer);
VAR
  LineText          : STRING;
  Number            : STRING;
  TextX             : Integer;
  Tokens            : TCodeTokenArray;
  Token             : TCodeToken;
  Style             : TCodeTextStyle;
  SliceStart        : Integer;
  SliceEnd          : Integer;
  Piece             : STRING;
  Highlighter       : TCustomCodeHighlighter;
BEGIN
  ACanvas.Brush.Style := bsClear;

  IF (Layout.GutterWidth > 0) AND Row.First THEN BEGIN
    ACanvas.Font.Style := [];
    ACanvas.Font.Color := clGray;
    Number := IntToStr(Row.Line + 1);
    ACanvas.TextOut(Layout.Body.Left + Layout.GutterWidth - 2 * Layout.CharWidth -
      ACanvas.TextWidth(Number), Y, Number);
  END;

  IF Row.Length = 0 THEN
    Exit;
  LineText := FEditor.Lines[Row.Line];
  IF Pos(#9, LineText) > 0 THEN
    LineText := StringReplace(LineText, #9, ' ', [rfReplaceAll]);
  TextX := Layout.Body.Left + Layout.GutterWidth;

  Highlighter := FEditor.Highlighter;
  Tokens := NIL;
  IF Assigned(Highlighter) THEN
    Tokens := FEditor.LineTokens(Row.Line);

  IF Length(Tokens) = 0 THEN BEGIN
    ACanvas.Font.Style := [];
    ACanvas.Font.Color := clBlack;
    ACanvas.TextOut(TextX, Y, Copy(LineText, Row.StartCol + 1, Row.Length));
  END ELSE
    FOR Token IN Tokens DO BEGIN
      // Clip the token to this row's slice of the line.
      SliceStart := Max(Token.Start - 1, Row.StartCol);
      SliceEnd := Min(Token.Start - 1 + Token.Length, Row.StartCol + Row.Length);
      IF SliceEnd <= SliceStart THEN
        Continue;
      IF Token.Kind = tkWhitespace THEN
        Continue;
      Piece := Copy(LineText, SliceStart + 1, SliceEnd - SliceStart);
      Style := Highlighter.Styles[Token.Kind];
      ACanvas.Font.Style := Style.FontStyle;
      IF (cpoSyntaxColors IN FOptions) AND (Style.Foreground <> clNone) AND
        (Style.Foreground <> clDefault) THEN
        ACanvas.Font.Color := ColorToRGB(Style.Foreground)
      ELSE
        ACanvas.Font.Color := clBlack;
      ACanvas.TextOut(TextX + (SliceStart - Row.StartCol) * Layout.CharWidth, Y, Piece);
    END;

  ACanvas.Font.Style := [];
  ACanvas.Brush.Style := bsSolid;
END;

PROCEDURE TCodeEditorPrinter.DrawPage(ACanvas: TCanvas; CONST Layout: TCodePrintLayout;
  PageIndex: Integer);
VAR
  I                 : Integer;
  RowIndex          : Integer;
  Y                 : Integer;
  SaveIdx           : Integer;
BEGIN
  IF (PageIndex < 0) OR (PageIndex >= Layout.PageCount) OR NOT Assigned(FEditor) THEN
    Exit;

  IF Layout.HeaderHeight > 0 THEN
    DrawBand(ACanvas, Layout, FHeader, PageIndex, True);
  IF Layout.FooterHeight > 0 THEN
    DrawBand(ACanvas, Layout, FFooter, PageIndex, False);

  SetupFont(ACanvas, EffectiveFont, Layout.DpiY);
  SaveIdx := SaveDC(ACanvas.Handle);
  TRY
    // Unwrapped rows are cut at the right margin rather than running into it.
    IntersectClipRect(ACanvas.Handle, Layout.Body.Left, Layout.Body.Top, Layout.Body.Right,
      Layout.Body.Bottom);
    FOR I := 0 TO Layout.RowsPerPage - 1 DO BEGIN
      RowIndex := PageIndex * Layout.RowsPerPage + I;
      IF RowIndex >= Length(Layout.Rows) THEN
        Break;
      Y := Layout.Body.Top + I * Layout.LineHeight;
      DrawRow(ACanvas, Layout, Layout.Rows[RowIndex], Y);
    END;
  FINALLY
    RestoreDC(ACanvas.Handle, SaveIdx);
    ACanvas.Refresh;
  END;
END;

// Physical sheet and printable area of the current printer, in printer
// pixels relative to the printable origin (which is where its canvas draws).
FUNCTION TCodeEditorPrinter.PrinterPaper(OUT Paper, Printable: TRect; OUT DpiX, DpiY: Integer):
  Boolean;
VAR
  DC                : HDC;
  OffX              : Integer;
  OffY              : Integer;
BEGIN
  Result := Printer.Printers.Count > 0;
  IF NOT Result THEN BEGIN
    DpiX := FallbackDpi;
    DpiY := FallbackDpi;
    Paper := Rect(0, 0, MmToPx(A4WidthMm, DpiX), MmToPx(A4HeightMm, DpiY));
    Printable := Paper;
    Exit;
  END;
  DC := Printer.Handle;
  DpiX := Max(1, GetDeviceCaps(DC, LOGPIXELSX));
  DpiY := Max(1, GetDeviceCaps(DC, LOGPIXELSY));
  OffX := GetDeviceCaps(DC, PHYSICALOFFSETX);
  OffY := GetDeviceCaps(DC, PHYSICALOFFSETY);
  Paper := Rect(-OffX, -OffY, -OffX + GetDeviceCaps(DC, PHYSICALWIDTH),
    -OffY + GetDeviceCaps(DC, PHYSICALHEIGHT));
  Printable := Rect(0, 0, Printer.PageWidth, Printer.PageHeight);
END;

PROCEDURE TCodeEditorPrinter.ApplyOrientation;
BEGIN
  CASE FOrientation OF
    cprPortrait: Printer.Orientation := poPortrait;
    cprLandscape: Printer.Orientation := poLandscape;
  END;
END;

PROCEDURE TCodeEditorPrinter.CheckPrinter;
BEGIN
  IF Printer.Printers.Count = 0 THEN
    RAISE EPrinter.Create('No printer is installed');
  IF NOT Assigned(FEditor) THEN
    RAISE EPrinter.Create('TCodeEditorPrinter.Editor is not assigned');
END;

FUNCTION TCodeEditorPrinter.PageCount: Integer;
VAR
  Paper             : TRect;
  Printable         : TRect;
  DpiX              : Integer;
  DpiY              : Integer;
  Measure           : Vcl.Graphics.TBitmap;
BEGIN
  IF NOT Assigned(FEditor) THEN
    Exit(0);
  ApplyOrientation;
  IF PrinterPaper(Paper, Printable, DpiX, DpiY) THEN
    Result := Paginate(Printer.Canvas, Paper, Printable, DpiX, DpiY).PageCount
  ELSE BEGIN
    Measure := Vcl.Graphics.TBitmap.Create;
    TRY
      Result := Paginate(Measure.Canvas, Paper, Printable, DpiX, DpiY).PageCount;
    FINALLY
      Measure.Free;
    END;
  END;
END;

PROCEDURE TCodeEditorPrinter.Print;
BEGIN
  Print(1, MaxInt);
END;

PROCEDURE TCodeEditorPrinter.Print(FromPage, ToPage: Integer);
VAR
  Paper             : TRect;
  Printable         : TRect;
  DpiX              : Integer;
  DpiY              : Integer;
  Layout            : TCodePrintLayout;
  PageIndex         : Integer;
  FirstIndex        : Integer;
  LastIndex         : Integer;
BEGIN
  CheckPrinter;
  ApplyOrientation;
  Printer.Copies := Max(1, FCopies);
  IF FTitle <> '' THEN
    Printer.Title := FTitle
  ELSE
    Printer.Title := 'CodeEdit';

  Printer.BeginDoc;
  TRY
    PrinterPaper(Paper, Printable, DpiX, DpiY);
    Layout := Paginate(Printer.Canvas, Paper, Printable, DpiX, DpiY);
    FirstIndex := Max(0, FromPage - 1);
    LastIndex := Min(Layout.PageCount - 1, ToPage - 1);
    IF LastIndex < FirstIndex THEN BEGIN
      Printer.Abort;
      Exit;
    END;
    FOR PageIndex := FirstIndex TO LastIndex DO BEGIN
      IF PageIndex > FirstIndex THEN
        Printer.NewPage;
      DrawPage(Printer.Canvas, Layout, PageIndex);
      IF Printer.Aborted THEN
        Break;
    END;
  FINALLY
    IF Printer.Printing AND NOT Printer.Aborted THEN
      Printer.EndDoc;
  END;
END;

FUNCTION TCodeEditorPrinter.Execute: Boolean;
VAR
  Dialog            : TPrintDialog;
  Pages             : Integer;
  SavedOptions      : TCodePrintOptions;
BEGIN
  CheckPrinter;
  Dialog := TPrintDialog.Create(NIL);
  TRY
    Pages := Max(1, PageCount);
    Dialog.Options := [poPageNums, poWarning];
    IF Assigned(FEditor) AND FEditor.HasSelection THEN
      Dialog.Options := Dialog.Options + [poSelection];
    Dialog.MinPage := 1;
    Dialog.MaxPage := Pages;
    Dialog.FromPage := 1;
    Dialog.ToPage := Pages;
    Dialog.Copies := Max(1, FCopies);
    Result := Dialog.Execute;
    IF NOT Result THEN
      Exit;

    SavedOptions := FOptions;
    TRY
      IF Dialog.Copies > 0 THEN
        FCopies := Dialog.Copies;
      CASE Dialog.PrintRange OF
        prPageNums:
          Print(Dialog.FromPage, Dialog.ToPage);
        prSelection: BEGIN
            Include(FOptions, cpoSelectionOnly);
            Print;
          END;
      ELSE
        Print;
      END;
    FINALLY
      FOptions := SavedOptions;
    END;
  FINALLY
    Dialog.Free;
  END;
END;

PROCEDURE TCodeEditorPrinter.Preview;
VAR
  Form              : TCodePrintPreviewForm;
BEGIN
  IF NOT Assigned(FEditor) THEN
    RAISE EPrinter.Create('TCodeEditorPrinter.Editor is not assigned');
  Form := TCodePrintPreviewForm.CreateFor(Self);
  TRY
    Form.ShowModal;
  FINALLY
    Form.Free;
  END;
END;

{ TCodePrintPreviewForm }

CONSTRUCTOR TCodePrintPreviewForm.CreateFor(APrinter: TCodeEditorPrinter);

  FUNCTION NewButton(CONST ACaption: STRING; ALeft, AWidth: Integer; AClick: TNotifyEvent):
    TButton;
  BEGIN
    Result := TButton.Create(Self);
    Result.Parent := FToolbar;
    Result.Caption := ACaption;
    Result.SetBounds(ALeft, 6, AWidth, 25);
    Result.OnClick := AClick;
  END;

BEGIN
  INHERITED CreateNew(NIL);
  FPrinter := APrinter;
  FPageBitmap := Vcl.Graphics.TBitmap.Create;
  FPageBitmap.PixelFormat := pf24bit;

  IF FPrinter.Title <> '' THEN
    Caption := 'Print Preview - ' + FPrinter.Title
  ELSE
    Caption := 'Print Preview';
  Position := poScreenCenter;
  Width := 960;
  Height := 760;
  KeyPreview := True;
  OnKeyDown := FormKeyDown;

  FToolbar := TPanel.Create(Self);
  FToolbar.Parent := Self;
  FToolbar.Align := alTop;
  FToolbar.Height := 37;
  FToolbar.BevelOuter := bvNone;

  FFirstButton := NewButton('|<', 8, 32, NavigateClick);
  FPrevButton := NewButton('<', 44, 32, NavigateClick);
  FNextButton := NewButton('>', 80, 32, NavigateClick);
  FLastButton := NewButton('>|', 116, 32, NavigateClick);

  FPageLabel := TLabel.Create(Self);
  FPageLabel.Parent := FToolbar;
  FPageLabel.SetBounds(160, 11, 120, 17);
  FPageLabel.AutoSize := True;

  FZoomCombo := TComboBox.Create(Self);
  FZoomCombo.Parent := FToolbar;
  FZoomCombo.Style := csDropDownList;
  FZoomCombo.SetBounds(300, 7, 110, 23);
  FZoomCombo.Items.Add('Fit page');
  FZoomCombo.Items.Add('Fit width');
  FZoomCombo.Items.Add('50%');
  FZoomCombo.Items.Add('75%');
  FZoomCombo.Items.Add('100%');
  FZoomCombo.Items.Add('150%');
  FZoomCombo.Items.Add('200%');
  FZoomCombo.ItemIndex := 0;
  FZoomCombo.OnChange := ZoomChange;

  FPrintButton := NewButton('Print...', 430, 80, PrintClick);
  FCloseButton := NewButton('Close', 520, 80, CloseClick);
  FCloseButton.Cancel := True;

  FScrollBox := TScrollBox.Create(Self);
  FScrollBox.Parent := Self;
  FScrollBox.Align := alClient;
  FScrollBox.Color := clAppWorkSpace;
  FScrollBox.ParentColor := False;
  FScrollBox.BorderStyle := bsNone;
  FScrollBox.OnResize := ScrollBoxResize;

  FImage := TImage.Create(Self);
  FImage.Parent := FScrollBox;
  FImage.AutoSize := True;
  FImage.Left := 0;
  FImage.Top := 0;

  FZoomPercent := 0;
  BuildLayout;
  FPage := 0;
  RenderPage;
  UpdateView;
END;

DESTRUCTOR TCodePrintPreviewForm.Destroy;
BEGIN
  FPageBitmap.Free;
  INHERITED;
END;

// Paginates against the printer's paper and resolution (capped for the
// preview bitmap) or A4 at 300 dpi when nothing is installed.
PROCEDURE TCodePrintPreviewForm.BuildLayout;
VAR
  Paper             : TRect;
  Printable         : TRect;
  DpiX              : Integer;
  DpiY              : Integer;
  Scale             : Double;
BEGIN
  FPrinter.ApplyOrientation;
  FPrinter.PrinterPaper(Paper, Printable, DpiX, DpiY);
  IF DpiY > PreviewMaxDpi THEN BEGIN
    // Render at a coarser resolution: the preview bitmap would otherwise
    // run to a hundred megabytes on a 600 dpi laser.
    Scale := PreviewMaxDpi / DpiY;
    Paper := Rect(Round(Paper.Left * Scale), Round(Paper.Top * Scale), Round(Paper.Right * Scale),
      Round(Paper.Bottom * Scale));
    Printable := Rect(Round(Printable.Left * Scale), Round(Printable.Top * Scale),
      Round(Printable.Right * Scale), Round(Printable.Bottom * Scale));
    DpiX := Round(DpiX * Scale);
    DpiY := PreviewMaxDpi;
  END;
  // Draw with the paper's top-left at the bitmap origin.
  OffsetRect(Printable, -Paper.Left, -Paper.Top);
  OffsetRect(Paper, -Paper.Left, -Paper.Top);
  FPageBitmap.SetSize(Max(1, Paper.Width), Max(1, Paper.Height));
  FLayout := FPrinter.Paginate(FPageBitmap.Canvas, Paper, Printable, DpiX, DpiY);
END;

PROCEDURE TCodePrintPreviewForm.RenderPage;
BEGIN
  FPageBitmap.Canvas.Brush.Style := bsSolid;
  FPageBitmap.Canvas.Brush.Color := clWhite;
  FPageBitmap.Canvas.FillRect(Rect(0, 0, FPageBitmap.Width, FPageBitmap.Height));
  FPrinter.DrawPage(FPageBitmap.Canvas, FLayout, FPage);
END;

// Scales the rendered page to the chosen zoom and centres it in the box.
PROCEDURE TCodePrintPreviewForm.UpdateView;
VAR
  Scale             : Double;
  View              : Vcl.Graphics.TBitmap;
  W                 : Integer;
  H                 : Integer;
  Avail             : Integer;
BEGIN
  IF FLayout.PageCount = 0 THEN
    FPageLabel.Caption := 'Nothing to print'
  ELSE
    FPageLabel.Caption := Format('Page %d of %d', [FPage + 1, FLayout.PageCount]);
  FFirstButton.Enabled := FPage > 0;
  FPrevButton.Enabled := FPage > 0;
  FNextButton.Enabled := FPage < FLayout.PageCount - 1;
  FLastButton.Enabled := FPage < FLayout.PageCount - 1;

  // Zoom is relative to the page at screen resolution (100% = actual size).
  CASE FZoomPercent OF
    0: BEGIN
        Avail := FScrollBox.ClientWidth - 24;
        Scale := Min(Avail / FPageBitmap.Width, (FScrollBox.ClientHeight - 24) / FPageBitmap.Height);
      END;
    -1: Scale := (FScrollBox.ClientWidth - 24) / FPageBitmap.Width;
  ELSE
    Scale := FZoomPercent / 100 * Screen.PixelsPerInch / FLayout.DpiX;
  END;
  Scale := Max(0.02, Scale);
  W := Max(1, Round(FPageBitmap.Width * Scale));
  H := Max(1, Round(FPageBitmap.Height * Scale));

  View := Vcl.Graphics.TBitmap.Create;
  TRY
    View.PixelFormat := pf24bit;
    View.SetSize(W, H);
    SetStretchBltMode(View.Canvas.Handle, HALFTONE);
    SetBrushOrgEx(View.Canvas.Handle, 0, 0, NIL);
    StretchBlt(View.Canvas.Handle, 0, 0, W, H, FPageBitmap.Canvas.Handle, 0, 0,
      FPageBitmap.Width, FPageBitmap.Height, SRCCOPY);
    // A thin frame so the sheet stands out from the workspace.
    View.Canvas.Brush.Style := bsClear;
    View.Canvas.Pen.Color := clGray;
    View.Canvas.Rectangle(0, 0, W, H);
    FImage.Picture.Bitmap.Assign(View);
  FINALLY
    View.Free;
  END;

  FImage.Left := Max(12, (FScrollBox.ClientWidth - W) DIV 2);
  FImage.Top := Max(12, (FScrollBox.ClientHeight - H) DIV 2);
END;

PROCEDURE TCodePrintPreviewForm.NavigateClick(Sender: TObject);
VAR
  NewPage           : Integer;
BEGIN
  NewPage := FPage;
  IF Sender = FFirstButton THEN
    NewPage := 0
  ELSE IF Sender = FPrevButton THEN
    NewPage := FPage - 1
  ELSE IF Sender = FNextButton THEN
    NewPage := FPage + 1
  ELSE IF Sender = FLastButton THEN
    NewPage := FLayout.PageCount - 1;
  NewPage := EnsureRange(NewPage, 0, Max(0, FLayout.PageCount - 1));
  IF NewPage <> FPage THEN BEGIN
    FPage := NewPage;
    RenderPage;
    UpdateView;
  END;
END;

PROCEDURE TCodePrintPreviewForm.ZoomChange(Sender: TObject);
BEGIN
  CASE FZoomCombo.ItemIndex OF
    0: FZoomPercent := 0;
    1: FZoomPercent := -1;
  ELSE
    FZoomPercent := StrToIntDef(StringReplace(FZoomCombo.Text, '%', '', []), 100);
  END;
  UpdateView;
END;

PROCEDURE TCodePrintPreviewForm.PrintClick(Sender: TObject);
BEGIN
  FPrinter.Execute;
END;

PROCEDURE TCodePrintPreviewForm.CloseClick(Sender: TObject);
BEGIN
  Close;
END;

PROCEDURE TCodePrintPreviewForm.ScrollBoxResize(Sender: TObject);
BEGIN
  IF FZoomPercent <= 0 THEN
    UpdateView;
END;

PROCEDURE TCodePrintPreviewForm.FormKeyDown(Sender: TObject; VAR Key: Word; Shift: TShiftState);
BEGIN
  CASE Key OF
    VK_PRIOR: NavigateClick(FPrevButton);
    VK_NEXT: NavigateClick(FNextButton);
    VK_HOME: IF ssCtrl IN Shift THEN NavigateClick(FFirstButton);
    VK_END: IF ssCtrl IN Shift THEN NavigateClick(FLastButton);
  ELSE
    Exit;
  END;
  Key := 0;
END;

END.
