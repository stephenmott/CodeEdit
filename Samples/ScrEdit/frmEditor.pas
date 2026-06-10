UNIT frmEditor;
{* Script Editor Form using CodeEdit }

{$I lzProduct.inc}
{$I TOPS.inc}
{$I lzAgent.inc}

{$C+}
{$D+}
{$L+}

INTERFACE

USES
  Winapi.Windows, Winapi.Messages,

  System.SysUtils, System.Variants, System.Classes, System.ImageList,

  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Menus, System.Actions, Vcl.ActnList,
  Vcl.ImgList, Vcl.StdCtrls,

  {DevExpress}
  cxGraphics, cxControls, cxLookAndFeels, cxLookAndFeelPainters, dxCore, cxClasses, cxContainer,
  cxEdit, cxInplaceContainer, cxGroupBox, cxFilter, cxCustomData, cxStyles, cxTL, cxTextEdit,
  cxTLdxBarBuiltInMenu, cxSplitter, cxImageList, cxButtons, cxCheckBox, cxPC,

  dxRibbonSkins, dxRibbonCustomizationForm, dxRibbon, dxStatusBar, dxRibbonStatusBar, dxBar,
  dxBarExtItems, dxBarBuiltInMenu, dxScrollbarAnnotations,

  {CodeEdit}
  CodeEdit.Highlighter, CodeEdit.Completion, CodeEdit.Editor,

  {JVCL}
  JvComponentBase, JvFormPlacement, JvAppStorage, JvAppRegistryStorage,

  {NexusDB}
{$IFDEF NEXUSDB}
  nxllConst, nxllTypes, nxdb, nxdbBase, nxsdDataDictionary, nxsdTypes, nxsdServerEngine,
{$ENDIF NEXUSDB}
  nxllComponent,

  {FastScript}
  fs_iinterpreter, fs_iTools,
  fs_iformsrtti, fs_igraphicsrtti, fs_iclassesrtti, fs_idialogsrtti, fs_iextctrlsrtti,
  fs_ipascal, fs_icpp, fs_ijs, fs_ibasic,

  uCalcul, uInterpreter,
{$IF DEFINED(NEXUSDB) }
  cliConsts,
  dmCliUtl,
{$IFEND NEXUSDB}
{$IFDEF NEXUSDB}
  dmNXComm,
{$IFNDEF Delphi10}
  dmNXControlD7,
{$ELSE Delphi10}
  dmNXControlDX,
{$ENDIF Delphi10}
  uNXControl,
{$ENDIF NEXUSDB}

{$IFDEF SITEM}
  dmSiteMon,
{$ENDIF SITEM}
  dmSCR,
  utlGUI,
  dmResource,

  uCliBase,

  utlNIL, lbTypes, lbGlobals, utlDXL, tabCLI, utlSYS,
{$IFDEF NEXUSDB}
  scrCLI,
{$ENDIF NEXUSDB}
{$IFDEF USEDBISAM}
  scrCLI,
{$ENDIF USEDBISAM}
  utlFRM, utlFMT, utlJS, utlJSF, utlPSF, uEtch, utlJSON
{$IFDEF DUCKCHECK}
  , utlDuck
{$ENDIF DUCKCHECK}
  ;

CONST
  cSource           = 'Source';

FUNCTION EditScript(
  AOwner: TComponent
  ; pScript, pIGUID: STRING
  ; VAR pNotes: STRING
{$IFDEF NEXUSDB}
  ; pDMWeb: TDataModuleCliUtil
{$ENDIF NEXUSDB}
{$IFDEF USEDBISAM}
  ; pDMWeb: TDataModuleCliUtil
{$ENDIF USEDBISAM}
  ; pLexer: STRING
  ; pTitle: STRING = 'Script Editor'
  ; pIsInterp: Boolean = False
  ; pBaseTable: STRING = ''
  ; pScriptDM: TDataModuleScript = NIL
{$IFDEF NEXUSDB}
  ; pConn: TDataModuleNXConn = NIL
  ; pItemScr: TLambtonItem = NIL
{$ENDIF NEXUSDB}
{$IFDEF USEDBISAM}
  ; pConn: TDataModuleDBIConn = NIL
  ; pItemScr: TLambtonItem = NIL
{$ENDIF USEDBISAM}
  ): STRING;

TYPE
  TForm1 = CLASS(TForm)
    dxRibbon1: TdxRibbon;
    dxRibbon1Tab1: TdxRibbonTab;
    dxRibbonStatusBar1: TdxRibbonStatusBar;
    cxGroupBox2: TcxGroupBox;
    cxGroupBox5: TcxGroupBox;
    cxPageControl2: TcxPageControl;
    cxTabSheet6: TcxTabSheet;
    cxGroupBox8: TcxGroupBox;
    chkPreserveLog: TcxCheckBox;
    cxTabSheet3: TcxTabSheet;
    cxGroupBox6: TcxGroupBox;
    cxPageControl1: TcxPageControl;
    cxTabSheet1: TcxTabSheet;
    cxTreeWatch: TcxTreeList;
    cxTreeWatchColumn1: TcxTreeListColumn;
    cxTreeWatchColumn2: TcxTreeListColumn;
    cxTreeWatchColumn3: TcxTreeListColumn;
    cxTabSheet2: TcxTabSheet;
    cxTreeWatches: TcxTreeList;
    cxTreeListColumn1: TcxTreeListColumn;
    cxTreeListColumn2: TcxTreeListColumn;
    cxTreeListColumn3: TcxTreeListColumn;
    cxGroupBox4: TcxGroupBox;
    cxButton1: TcxButton;
    cxButton2: TcxButton;
    cxSplitter2: TcxSplitter;
    cxSplitter1: TcxSplitter;
    cxGroupBox7: TcxGroupBox;
    cxGroupBox1: TcxGroupBox;
    cxGroupBox3: TcxGroupBox;
    cxTreeListVariables: TcxTreeList;
    cxCol1: TcxTreeListColumn;
    cxCol2: TcxTreeListColumn;
    cxCol3: TcxTreeListColumn;
    cxSplitter3: TcxSplitter;
    PrinterSetupDialog1: TPrinterSetupDialog;
    PrintDialog1: TPrintDialog;
    ImageList1: TImageList;
    imglGutterGlyphs: TImageList;
    ActionList1: TActionList;
    actTestScript: TAction;
    actFormat: TAction;
    actStepScript: TAction;
    actStopScript: TAction;
    actEvalScript: TAction;
    actCompile: TAction;
    actToggleBreak: TAction;
    actReplace: TAction;
    actFind: TAction;
    actPrintSetup: TAction;
    actViewOutput: TAction;
    actViewProduction: TAction;
    actViewTest: TAction;
    actComment: TAction;
    actUnComment: TAction;
    actFunction: TAction;
    actClose: TAction;
    actProcList: TAction;
    actTemplatePopup: TAction;
    actAddWatch: TAction;
    actDelWatch: TAction;
    actFontDown: TAction;
    actFontUp: TAction;
    actResetSizes: TAction;
    dxBarManager1: TdxBarManager;
    dxBarManager1Bar1: TdxBar;
    dxBarManager1Bar2: TdxBar;
    dxFile: TdxBarSubItem;
    dxEdit: TdxBarSubItem;
    dxRun: TdxBarSubItem;
    dxView: TdxBarSubItem;
    dxEditTables: TdxBarSubItem;
    dxImport: TdxBarSubItem;
    dxBarLargeButton1: TdxBarLargeButton;
    dxBarLargeButton2: TdxBarLargeButton;
    dxBarSeparator1: TdxBarSeparator;
    dxBarLargeButton3: TdxBarLargeButton;
    dxBarLargeButton4: TdxBarLargeButton;
    dxSave: TdxBarButton;
    dxPageSetup: TdxBarButton;
    dxPrintPreview: TdxBarButton;
    dxPrinterSetup: TdxBarButton;
    dxPrint: TdxBarButton;
    dxExit: TdxBarButton;
    dxCut: TdxBarButton;
    dxCopy: TdxBarButton;
    dxPaste: TdxBarButton;
    dxFind: TdxBarButton;
    dxReplace: TdxBarButton;
    dxFontName: TdxBarFontNameCombo;
    dxFontSize: TdxBarCombo;
    dxComment: TdxBarButton;
    dxUncomment: TdxBarButton;
    dxMatchDelimiter: TdxBarButton;
    dxCompile: TdxBarButton;
    dxToggleBreakpoint: TdxBarButton;
    dxStepScript: TdxBarButton;
    dxRunScript: TdxBarButton;
    dxStopScript: TdxBarButton;
    dxEvaluateScript: TdxBarButton;
    dxFunctions: TdxBarButton;
    dxBarButton1: TdxBarButton;
    dxViewProduction: TdxBarButton;
    dxViewOutput: TdxBarButton;
    JvAppRegistryStorage1: TJvAppRegistryStorage;
    JvFormStorage1: TJvFormStorage;
    cxStyleRepository1: TcxStyleRepository;
    cxStyle1: TcxStyle;
    cxImageList1: TcxImageList;
    cxImageList2: TcxImageList;
    CodeEditor1: TCodeEditor;
    KeywordCompletionProvider1: TKeywordCompletionProvider;
    DelphiCodeHighlighter1: TDelphiCodeHighlighter;
    JavaScriptCodeHighlighter1: TJavaScriptCodeHighlighter;
    SqlCodeHighlighter1: TSqlCodeHighlighter;
    TungliCodeHighlighter1: TTungliCodeHighlighter;
    BatchCodeHighlighter1: TBatchCodeHighlighter;
    PowerShellCodeHighlighter1: TPowerShellCodeHighlighter;
    IniCodeHighlighter1: TIniCodeHighlighter;
    YamlCodeHighlighter1: TYamlCodeHighlighter;
    PythonCodeHighlighter1: TPythonCodeHighlighter;
    CodeEditor2: TCodeEditor;
    CodeEditor3: TCodeEditor;
    PROCEDURE FormCreate(Sender: TObject);
    PROCEDURE FormDestroy(Sender: TObject);
    PROCEDURE FormShow(Sender: TObject);
    PROCEDURE FormCloseQuery(Sender: TObject; VAR CanClose: Boolean);
    PROCEDURE actExecute(Sender: TObject);
    PROCEDURE CodeEditorEnter(Sender: TObject);
    PROCEDURE CodeEditorChange(Sender: TObject);
    PROCEDURE CodeEditorCaretChange(Sender: TObject; CONST Caret: TCodePosition);
    PROCEDURE CodeEditorSelectionChange(Sender: TObject; CONST SelectionStart,
      SelectionEnd: TCodePosition);
    PROCEDURE CompletionGetCompletions(Sender: TObject; CONST Context: TCodeCompletionContext;
      Items: TCodeCompletionItems);
    PROCEDURE CompletionGetSignatureHelp(Sender: TObject; CONST Context: TCodeSignatureHelpContext;
      Items: TCodeSignatureItems);
    PROCEDURE EditorCommandClick(Sender: TObject);
  PROTECTED
    PROCEDURE CreateParams(VAR Params: TCreateParams); OVERRIDE;
    PROCEDURE WMSysCommand(VAR Message: TWMSysCommand); MESSAGE WM_SYSCOMMAND;
  PRIVATE
    fItem: STRING;
    fLastPos: TPoint;
    fLastLeftColumn: Integer;
    fLastTopLine: Integer;
    fSourceList: TStringList;
    fEvaluating: Boolean;
    fRunningFree: Boolean;
    FCurrentLine: Integer;
    fErrorLine: Integer;
    FRunning: Boolean;
    fStopped: Boolean;
    fCurrentMemo: TCodeEditor;
    fRunningMemo: TCodeEditor;
    fCurGUID: STRING;
    fLexer: STRING;
    fCalcul: TCalcul;
    fInterpreter: TInterpreter;
    fIsInterp: Boolean;
    fBaseTable: STRING;
    dmScript: TDataModuleScript;
    nxCtlItems: TCommonTable;
    nxLookup: TCommonTable;
    nxQueryTest: TCommonQuery;
    fTable: TCommonTable;
    fQuery: TCommonQuery;
    fdmWeb: TDataModuleCliUtil;
{$IFDEF NEXUSDB}
    fDMConn: TDataModuleNXConn;
{$ENDIF NEXUSDB}
{$IFDEF USEDBISAM}
    fDMConn: TDataModuleDBIConn;
{$ENDIF USEDBISAM}
    fItemScr: TLambtonItem;
    fIgnoreMissingVariables: Boolean;
    fFontSize: Integer;
    fZoomLevel: Integer;
    PROCEDURE OnGetVariable(Sender: TObject; CONST VariableName: STRING; VAR VariableValue: Variant;
      VAR Handled: Boolean; Index: Integer = 0);
    PROCEDURE ParentShow(Sender: TObject);
    PROCEDURE CheckButtons;
    FUNCTION CompileScript: Boolean;
    FUNCTION CompileScriptJS: Boolean;
    PROCEDURE ExecuteScript(pDebug: Boolean);
    PROCEDURE fsScript1RunLine(Sender: TfsScript; CONST UnitName, SourcePos: STRING);
    PROCEDURE fsScriptGetUnit(Sender: TfsScript; CONST UnitName: STRING; VAR UnitText: STRING);
    PROCEDURE SetCurGUID(CONST Value: STRING);
    PROCEDURE LogEvent(CONST pLevel: Integer; CONST pString: STRING);
    FUNCTION GetScriptText: STRING;
    PROCEDURE SetScriptText(CONST Value: STRING);
    PROCEDURE SetupEditors;
    PROCEDURE SetLexer(CONST Value: STRING);
{$IFDEF NEXUSDB}
    PROCEDURE SetdmWeb(CONST Value: TDataModuleCliUtil);
    PROCEDURE SetIsInterp(CONST Value: Boolean);
    PROCEDURE LoadTables(pDatabase: TnxDatabase; pTableList: TTableList; pOGUID: STRING);
{$ENDIF NEXUSDB}
{$IFDEF USEDBISAM}
    PROCEDURE SetdmWeb(CONST Value: TDataModuleCliUtil);
    PROCEDURE SetIsInterp(CONST Value: Boolean);
    PROCEDURE LoadTables(pDatabase: TDBISAMDatabase; pTableList: TTableList; pOGUID: STRING);
{$ENDIF USEDBISAM}
    FUNCTION FindVar(pName: STRING; pProc: TfsScript): Boolean;
    FUNCTION LookupVarType(pVar: STRING): STRING;
    PROCEDURE SetFontSize(CONST Value: Integer);
    PROCEDURE SetZoomLevel(CONST Value: Integer);
    PROCEDURE SetEditorErrorLine(Line: Integer);
    PROCEDURE SetEditorRunLine(Line: Integer);
    PROCEDURE AddFastScriptCompletions(CONST Context: TCodeCompletionContext;
      Items: TCodeCompletionItems);
    PROCEDURE AddJavaScriptCompletions(Items: TCodeCompletionItems);
    PROCEDURE AddCalcCompletions(Items: TCodeCompletionItems);
    PROCEDURE AddSqlCompletions(Items: TCodeCompletionItems);
  PUBLIC
    fResult: Integer;
    gOwner: TForm;
    fCurrentUnit: STRING;
    FUNCTION GetValue(Sender: TObject; pName: STRING): STRING;
    PROCEDURE UpdateVariables(pJustAdd: Boolean = False);
{$IFDEF NEXUSDB}
    PROPERTY dmConn: TDataModuleNXConn READ fDMConn WRITE fDMConn;
    PROPERTY dmWeb: TDataModuleCliUtil READ fdmWeb WRITE SetdmWeb;
    PROPERTY ItemScr: TLambtonItem READ fItemScr WRITE fItemScr;
{$ENDIF NEXUSDB}
{$IFDEF USEDBISAM}
    PROPERTY dmConn: TDataModuleDBIConn READ fDMConn WRITE fDMConn;
    PROPERTY dmWeb: TDataModuleCliUtil READ fdmWeb WRITE SetdmWeb;
    PROPERTY ItemScr: TLambtonItem READ fItemScr WRITE fItemScr;
{$ENDIF USEDBISAM}
    PROPERTY CurGUID: STRING READ fCurGUID WRITE SetCurGUID;
    PROPERTY ScriptText: STRING READ GetScriptText WRITE SetScriptText;
    PROPERTY Lexer: STRING READ fLexer WRITE SetLexer;
    PROPERTY IsInterp: Boolean READ fIsInterp WRITE SetIsInterp;
    PROPERTY BaseTable: STRING READ fBaseTable WRITE fBaseTable;
    PROPERTY Evaluating: Boolean READ fEvaluating WRITE fEvaluating;
    PROPERTY IgnoreMissingVariables: Boolean READ fIgnoreMissingVariables WRITE fIgnoreMissingVariables;
    PROPERTY FontSize: Integer READ fFontSize WRITE SetFontSize;
    PROPERTY ZoomLevel: Integer READ fZoomLevel WRITE SetZoomLevel;
  END;

VAR
  Form1             : TForm1;

IMPLEMENTATION

USES
  System.Math,
  System.StrUtils,
  frmEval,
  frmFunctionTree,
  frmProcList,
  scrCtl;

{$R *.dfm}

FUNCTION EditScript(
  AOwner: TComponent
  ; pScript, pIGUID: STRING
  ; VAR pNotes: STRING
{$IFDEF NEXUSDB}
  ; pDMWeb: TDataModuleCliUtil
{$ENDIF NEXUSDB}
{$IFDEF USEDBISAM}
  ; pDMWeb: TDataModuleCliUtil
{$ENDIF USEDBISAM}
  ; pLexer: STRING
  ; pTitle: STRING = 'Script Editor'
  ; pIsInterp: Boolean = False
  ; pBaseTable: STRING = ''
  ; pScriptDM: TDataModuleScript = NIL
{$IFDEF NEXUSDB}
  ; pConn: TDataModuleNXConn = NIL
  ; pItemScr: TLambtonItem = NIL
{$ENDIF NEXUSDB}
{$IFDEF USEDBISAM}
  ; pConn: TDataModuleDBIConn = NIL
  ; pItemScr: TLambtonItem = NIL
{$ENDIF USEDBISAM}
  ): STRING;
VAR
  lFrm              : TForm1;
  lOnLogOutput1     : TStringEvent;
  lOnLogOutput2     : TStringEvent;
BEGIN
  lOnLogOutput1 := NIL;
  lOnLogOutput2 := NIL;
  lFrm := TForm1.Create(AOwner);
  TRY
    IF AOwner IS TForm THEN
      TForm(AOwner).OnShow := lFrm.ParentShow;
    IF AOwner IS TForm THEN
      lFrm.gOwner := TForm(AOwner)
    ELSE
      lFrm.gOwner := NIL;
    lFrm.Caption := pTitle;
    lFrm.ScriptText := pScript;
    IF Assigned(pScriptDM) THEN
      lFrm.dmScript := pScriptDM;
{$IFDEF NEXUSDB}
    IF Assigned(pConn) THEN
      lFrm.dmConn := pConn;
    IF Assigned(pDMWeb) THEN BEGIN
      lFrm.dmWeb := pDMWeb;
      lOnLogOutput1 := pDMWeb.fItem.OnLogOutput;
      pDMWeb.fItem.OnLogOutput := lFrm.LogEvent;
    END;
    IF Assigned(pItemScr) THEN BEGIN
      lFrm.ItemScr := pItemScr;
      lOnLogOutput2 := lFrm.ItemScr.OnLogOutput;
      pItemScr.OnLogOutput := lFrm.LogEvent;
    END;
{$ENDIF NEXUSDB}
{$IFDEF USEDBISAM}
    IF Assigned(pConn) THEN
      lFrm.dmConn := pConn;
    IF Assigned(pDMWeb) THEN BEGIN
      lFrm.dmWeb := pDMWeb;
      lOnLogOutput1 := pDMWeb.fItem.OnLogOutput;
      pDMWeb.fItem.OnLogOutput := lFrm.LogEvent;
    END;
    IF Assigned(pItemScr) THEN BEGIN
      lFrm.ItemScr := pItemScr;
      lOnLogOutput2 := lFrm.ItemScr.OnLogOutput;
      pItemScr.OnLogOutput := lFrm.LogEvent;
    END;
{$ENDIF USEDBISAM}
    lFrm.Lexer := pLexer;
    lFrm.BaseTable := pBaseTable;
    lFrm.CurGUID := pIGUID;
    lFrm.IsInterp := pIsInterp;
    lFrm.CodeEditor3.Lines.Text := pNotes;
    lFrm.Showmodal;
    IF lFrm.fResult = mrOK THEN BEGIN
      Result := lFrm.ScriptText;
      pNotes := lFrm.CodeEditor3.Lines.Text;
    END ELSE
      Result := pScript;
{$IFDEF NEXUSDB}
    IF Assigned(pItemScr) THEN
      pItemScr.OnLogOutput := lOnLogOutput2;
    IF Assigned(pDMWeb) THEN
      pDMWeb.fItem.OnLogOutput := lOnLogOutput1;
{$ENDIF NEXUSDB}
{$IFDEF USEDBISAM}
    IF Assigned(pItemScr) THEN
      pItemScr.OnLogOutput := lOnLogOutput2;
    IF Assigned(pDMWeb) THEN
      pDMWeb.fItem.OnLogOutput := lOnLogOutput1;
{$ENDIF USEDBISAM}
    IF AOwner IS TForm THEN
      TForm(AOwner).OnShow := NIL;
  FINALLY
    lzSafeFreeAndNIL(lFrm);
  END;
END;

PROCEDURE TForm1.CreateParams(VAR Params: TCreateParams);
BEGIN
  INHERITED CreateParams(Params);
END;

PROCEDURE TForm1.WMSysCommand(VAR Message: TWMSysCommand);
BEGIN
  INHERITED;
END;

PROCEDURE TForm1.FormCreate(Sender: TObject);
VAR
  lWindowState      : TWindowState;
BEGIN
  cxPageControl1.ActivePageIndex := 0;
  cxPageControl2.ActivePageIndex := 0;

  dxThreading.dxEnableMultiThreading := False;
  SetSkinInterface(NIL, NIL, dxRibbon1);

  JvAppRegistryStorage1.RegRoot := hkCurrentUser;
  JvAppRegistryStorage1.Root := 'Software\Lambtons\' +
    ChangeFileExt(ExtractFilename(ParamStr(0)), '') +
    '\ScriptEditor\Settings';

  nxCtlItems := TCommonTable.Create(Self);
  nxLookup := TCommonTable.Create(Self);
  nxQueryTest := TCommonQuery.Create(Self);
  fIgnoreMissingVariables := False;
  fCurrentUnit := cSource;
  fSourceList := TStringList.Create;
  FCurrentLine := -1;
  fErrorLine := -1;
  fEvaluating := False;
  fCurrentMemo := CodeEditor1;
  fTable := TCommonTable.Create(Self);
  fQuery := TCommonQuery.Create(Self);
  fInterpreter := TInterpreter.Create;
  fCalcul := TCalcul.Create;
  fCalcul.OnGetVariable := OnGetVariable;
  fInterpreter.Calcul := fCalcul;

  fResult := mrCancel;
  SetupEditors;
  ScaleForm(Self);

  lWindowState := TWindowState(JvFormStorage1.ReadInteger('WindowState', ord(WindowState)));
  JvFormStorage1.RestoreFormPlacement;
  IF lWindowState <> wsMinimized THEN
    WindowState := lWindowState;

  fFontSize := CodeEditor1.Font.Size;
  fZoomLevel := 100;

  IF Height < 50 THEN
    Height := 500;
  IF Width < 50 THEN
    Width := 600;
  IF (Left < 0) OR (Left > Screen.Width - Width) THEN
    Left := (Screen.Width - Width) DIV 2;
  IF (Top < 0) OR (Top > Screen.Height - Height) THEN
    Top := (Screen.Height - Height) DIV 2;

  CheckButtons;
END;

PROCEDURE TForm1.FormDestroy(Sender: TObject);
BEGIN
  JvFormStorage1.SaveFormPlacement;
  JvFormStorage1.WriteInteger('WindowState', ord(WindowState));

  TRY
{$IF DEFINED(NEXUSDB) OR DEFINED(USEDBISAM)}
    fTable.Active := False;
    lzSafeFreeAndNIL(fTable);
    IF Assigned(ItemScr) AND Assigned(ItemScr.fTableList) THEN BEGIN
      ItemScr.fTableList.Clear;
      ItemScr.fTableList := NIL;
    END;
    IF Assigned(dmWeb) AND Assigned(dmWeb.fItem.TableList) THEN
      dmWeb.fItem.TableList.Clear;
{$IFEND USEDBISAM}
    lzSafeFreeAndNIL(fCalcul);
    lzSafeFreeAndNIL(fInterpreter);
{$IF DEFINED(NEXUSDB) OR DEFINED(USEDBISAM)}
    lzSafeFreeAndNIL(nxCtlItems);
    lzSafeFreeAndNIL(nxLookup);
    lzSafeFreeAndNIL(nxQueryTest);
    lzSafeFreeAndNIL(fTable);
    lzSafeFreeAndNIL(fQuery);
{$IFEND USEDBISAM}
    lzSafeFreeAndNIL(fSourceList);
{$IFDEF SITEM}
    dmMonitor.OnLogMemo := NIL;
{$ENDIF SITEM}
  EXCEPT
  END;
END;

PROCEDURE TForm1.FormShow(Sender: TObject);
BEGIN
  Self.Show;
END;

PROCEDURE TForm1.ParentShow(Sender: TObject);
BEGIN
  Self.Show;
END;

PROCEDURE TForm1.FormCloseQuery(Sender: TObject; VAR CanClose: Boolean);
BEGIN
  IF Assigned(fCurrentMemo) AND fCurrentMemo.Modified AND (fResult <> mrOK) THEN BEGIN
    CASE QueryTaskDlg(Self, 'Save Changes',
      'The script has changed, would you like to save the changes?', [cbYes, cbNo, cbCancel]) OF
      mrYes: fResult := mrOK;
      mrNo: fResult := mrCancel;
    ELSE
      CanClose := False;
    END;
  END ELSE
    CanClose := True;
END;

PROCEDURE TForm1.SetupEditors;
  PROCEDURE InitEditor(AEditor: TCodeEditor; AReadOnly: Boolean);
  BEGIN
    AEditor.CompletionProvider := KeywordCompletionProvider1;
    AEditor.StyledScrollBars := True;
    AEditor.Options.ShowMinimap := True;
    AEditor.Options.LineCommentPrefix := '//';
    AEditor.ReadOnly := AReadOnly;
    AEditor.OnEnter := CodeEditorEnter;
    AEditor.OnChange := CodeEditorChange;
    AEditor.OnCaretChange := CodeEditorCaretChange;
    AEditor.OnSelectionChange := CodeEditorSelectionChange;
  END;
BEGIN
  InitEditor(CodeEditor1, False);
  InitEditor(CodeEditor2, True);
  InitEditor(CodeEditor3, False);

  KeywordCompletionProvider1.OnGetCompletions := CompletionGetCompletions;
  KeywordCompletionProvider1.OnGetSignatureHelp := CompletionGetSignatureHelp;

  actTestScript.OnExecute := actExecute;
  actFormat.OnExecute := actExecute;
  actStepScript.OnExecute := actExecute;
  actStopScript.OnExecute := actExecute;
  actEvalScript.OnExecute := actExecute;
  actCompile.OnExecute := actExecute;
  actToggleBreak.OnExecute := actExecute;
  actReplace.OnExecute := actExecute;
  actFind.OnExecute := actExecute;
  actPrintSetup.OnExecute := actExecute;
  actViewOutput.OnExecute := actExecute;
  actViewProduction.OnExecute := actExecute;
  actViewTest.OnExecute := actExecute;
  actComment.OnExecute := actExecute;
  actUnComment.OnExecute := actExecute;
  actFunction.OnExecute := actExecute;
  actClose.OnExecute := actExecute;
  actProcList.OnExecute := actExecute;
  actTemplatePopup.OnExecute := actExecute;
  actAddWatch.OnExecute := actExecute;
  actDelWatch.OnExecute := actExecute;
  actFontDown.OnExecute := actExecute;
  actFontUp.OnExecute := actExecute;
  actResetSizes.OnExecute := actExecute;
  dxCut.OnClick := EditorCommandClick;
  dxCopy.OnClick := EditorCommandClick;
  dxPaste.OnClick := EditorCommandClick;
END;

PROCEDURE TForm1.EditorCommandClick(Sender: TObject);
BEGIN
  IF NOT Assigned(fCurrentMemo) THEN
    Exit;

  IF Sender = dxCut THEN
    fCurrentMemo.ExecuteCommand(eccCut)
  ELSE IF Sender = dxCopy THEN
    fCurrentMemo.ExecuteCommand(eccCopy)
  ELSE IF Sender = dxPaste THEN
    fCurrentMemo.ExecuteCommand(eccPaste);
END;

PROCEDURE TForm1.CodeEditorEnter(Sender: TObject);
BEGIN
  IF Sender IS TCodeEditor THEN BEGIN
    fCurrentMemo := TCodeEditor(Sender);
    fCurrentMemo.Options.LineCommentPrefix := IfThen(SameText(Lexer, 'PL/SQL'), '--', '//');
  END;
  CheckButtons;
END;

PROCEDURE TForm1.CodeEditorCaretChange(Sender: TObject; CONST Caret: TCodePosition);
BEGIN
  IF Assigned(fRunningMemo) THEN BEGIN
    fLastPos := Point(fRunningMemo.Caret.Column, fRunningMemo.Caret.Line);
    fLastTopLine := fRunningMemo.TopLine;
    fLastLeftColumn := fRunningMemo.LeftColumn;
  END;
  CheckButtons;
END;

PROCEDURE TForm1.CodeEditorSelectionChange(Sender: TObject; CONST SelectionStart,
  SelectionEnd: TCodePosition);
BEGIN
  IF Assigned(fRunningMemo) THEN BEGIN
    fLastPos := Point(fRunningMemo.Caret.Column, fRunningMemo.Caret.Line);
    fLastTopLine := fRunningMemo.TopLine;
    fLastLeftColumn := fRunningMemo.LeftColumn;
  END;
END;

PROCEDURE TForm1.CodeEditorChange(Sender: TObject);
BEGIN
  SetEditorErrorLine(-1);
  IF fCurrentUnit = cSource THEN
    fSourceList.Values[cSource] := Str2Hex(CodeEditor1.Lines.Text);
  IF Assigned(fRunningMemo) THEN BEGIN
    fLastPos := Point(fRunningMemo.Caret.Column, fRunningMemo.Caret.Line);
    fLastTopLine := fRunningMemo.TopLine;
    fLastLeftColumn := fRunningMemo.LeftColumn;
  END;
  CheckButtons;
END;

PROCEDURE TForm1.CheckButtons;
VAR
  lDoScript         : Boolean;
BEGIN
  lDoScript := True;

  dxFontName.Enabled := lDoScript;
  dxFontSize.Enabled := lDoScript;

  actStopScript.Enabled := FRunning AND lDoScript;
  actEvalScript.Enabled := FRunning AND lDoScript;
  actCompile.Enabled := (NOT FRunning) AND lDoScript;
  actClose.Enabled := NOT FRunning;
  actStepScript.Enabled := lDoScript;
  actTestScript.Enabled := lDoScript;
  actToggleBreak.Enabled := lDoScript;
  actFormat.Enabled := lDoScript;
  actFunction.Enabled := lDoScript;

  IF Assigned(fCurrentMemo) AND lDoScript THEN BEGIN
    actReplace.Enabled := True;
    actFind.Enabled := True;
    actPrintSetup.Enabled := True;
    actComment.Enabled := True;
    actUnComment.Enabled := True;
    actViewOutput.Enabled := True;
    actViewProduction.Enabled := True;
    actViewTest.Enabled := True;
  END ELSE BEGIN
    actReplace.Enabled := False;
    actFind.Enabled := False;
    actPrintSetup.Enabled := False;
    actComment.Enabled := False;
    actUnComment.Enabled := False;
    actViewOutput.Enabled := False;
    actViewProduction.Enabled := False;
    actViewTest.Enabled := False;
  END;
END;

PROCEDURE TForm1.actExecute(Sender: TObject);
VAR
  i                 : Integer;
  lNode             : TcxTreeListNode;
  lVal              : STRING;
  lPoint            : TCodePosition;
  lFrm              : TformFunctionTree;
BEGIN
  IF Sender = actResetSizes THEN BEGIN
    FontSize := 9;
    ZoomLevel := 100;
  END;

  IF Sender = actFontDown THEN BEGIN
    FontSize := FontSize - 1;
    ZoomLevel := ZoomLevel - 10;
  END;

  IF Sender = actFontUp THEN BEGIN
    FontSize := FontSize + 1;
    ZoomLevel := ZoomLevel + 10;
  END;

  IF Sender = actAddWatch THEN BEGIN
    lVal := fCurrentMemo.SelectedText;
    IF InputQuery('Add Watch', 'Variable', lVal) THEN BEGIN
      lNode := cxTreeWatches.Add;
      lNode.Texts[0] := lVal;
      UpdateVariables(False);
    END;
  END;

  IF Sender = actDelWatch THEN
    IF cxTreeWatches.FocusedNode <> NIL THEN
      cxTreeWatches.FocusedNode.Delete;

  IF Sender = actTemplatePopup THEN
    fCurrentMemo.TriggerCompletion;

  IF Sender = actClose THEN BEGIN
    fResult := mrOK;
    Close;
  END;

  IF Sender = actFunction THEN BEGIN
    lFrm := TformFunctionTree.Create(Self);
    TRY
      lFrm.ShowClasses := True;
      lFrm.ShowFunctions := True;
      lFrm.ShowTypes := True;
      lFrm.ShowVariables := True;
      lFrm.FillTree;
      IF (lFrm.Showmodal = mrOK) AND (lFrm.cxTreeListFunc.FocusedNode <> NIL) THEN
        fCurrentMemo.InsertText(lFrm.cxTreeListFunc.FocusedNode.Values[0]);
    FINALLY
      lzSafeFreeAndNIL(lFrm);
    END;
  END;

  IF Sender = actProcList THEN BEGIN
    i := ListProcedures(Self, fCurrentMemo.Lines.Text);
    IF i >= 0 THEN BEGIN
      lPoint := TCodePosition.Create(i, 1);
      fCurrentMemo.Caret := lPoint;
      fCurrentMemo.ShowLine(i);
      fCurrentMemo.TopLine := i;
      fCurrentMemo.Invalidate;
    END;
  END;

  IF Sender = actComment THEN
    fCurrentMemo.CommentSelection;

  IF Sender = actUnComment THEN
    fCurrentMemo.UncommentSelection;

  IF Sender = actPrintSetup THEN
    PrinterSetupDialog1.Execute;

  IF Sender = actReplace THEN
    fCurrentMemo.ShowReplace;

  IF Sender = actFind THEN
    fCurrentMemo.ShowFind;

  IF Sender = actCompile THEN BEGIN
    IF (Lexer = 'Pascal script') AND (NOT fIsInterp) THEN BEGIN
      IF CompileScript THEN
        ShowConsoleMessage(Self, lpInfo, 'Script Compiled with No Errors', '', '');
    END ELSE IF (Lexer = 'Pascal Calc') AND (fIsInterp) THEN BEGIN
      { Interpreter path stays with the host application. }
    END ELSE IF Lexer = 'PL/SQL' THEN BEGIN
{$IF DEFINED(NEXUSDB) OR DEFINED(USEDBISAM)}
      IF Assigned(fCurrentMemo) THEN BEGIN
        IF lzSafeOpenQuery(nxQueryTest, 'Select * from LAM_PIECES WHERE ' +
          fCurrentMemo.Lines.Text) THEN
          ShowConsoleMessage(Self, lpInfo, 'SQL OK', '', '')
        ELSE
          ShowConsoleMessage(Self, lpError, 'Error In SQL', gLastSQLError, '');
      END;
{$IFEND NEXUSDB}
    END ELSE IF Lexer = 'Java script' THEN BEGIN
      IF CompileScriptJS THEN
        ShowConsoleMessage(Self, lpInfo, 'Script Compiled with No Errors', '', '');
    END;
  END;

  IF Sender = actFormat THEN BEGIN
    lPoint := fCurrentMemo.Caret;
    IF (Lexer = 'Pascal Calc') AND (fIsInterp) THEN
      fCurrentMemo.Lines.Text := ps_beautify(fCurrentMemo.Lines.Text)
    ELSE IF Lexer = 'Java script' THEN
      fCurrentMemo.Lines.Text := js_beautify(fCurrentMemo.Lines.Text);
    fCurrentMemo.Caret := lPoint;
    fCurrentMemo.Modified := True;
  END;

  IF Sender = actEvalScript THEN
    IF (Lexer = 'Pascal script') AND Assigned(dmScript) THEN
      dmScript.Evaluate(fCurrentMemo.SelectedText);

  IF Sender = actStopScript THEN BEGIN
    fStopped := False;
    IF Assigned(dmScript) THEN
      dmScript.Terminate;
  END;

  IF Sender = actStepScript THEN
    IF (Lexer = 'Pascal script') AND (NOT fIsInterp) THEN BEGIN
      fRunningFree := False;
      IF FRunning THEN
        fStopped := False
      ELSE
        ExecuteScript(True);
    END;

  IF Sender = actTestScript THEN BEGIN
    IF (Lexer = 'Pascal script') AND (NOT fIsInterp) THEN BEGIN
      fRunningFree := True;
      IF NOT FRunning THEN
        ExecuteScript(False);
      fStopped := False;
    END ELSE IF Lexer = 'Java script' THEN BEGIN
      IF CompileScriptJS THEN
        ShowConsoleMessage(Self, lpInfo, 'Script Compiled with No Errors', '', '');
    END;
  END;

  IF Sender = actToggleBreak THEN
    IF Assigned(fCurrentMemo) THEN
      fCurrentMemo.ToggleBreakpoint(fCurrentMemo.Caret.Line + 1);

  CheckButtons;
END;

PROCEDURE TForm1.SetEditorErrorLine(Line: Integer);
BEGIN
  IF fErrorLine = Line THEN
    EXIT;
  IF fErrorLine >= 0 THEN
    CodeEditor1.RemoveLineMarker(fErrorLine + 1, lmkError);
  fErrorLine := Line;
  IF fErrorLine >= 0 THEN
    CodeEditor1.AddLineMarker(fErrorLine + 1, lmkError);
END;

PROCEDURE TForm1.SetEditorRunLine(Line: Integer);
BEGIN
  FCurrentLine := Line;
  IF Assigned(fRunningMemo) THEN BEGIN
    IF Line >= 0 THEN
      fRunningMemo.ExecutionLine := Line + 1
    ELSE
      fRunningMemo.ExecutionLine := -1;
  END ELSE BEGIN
    IF Line >= 0 THEN
      CodeEditor1.ExecutionLine := Line + 1
    ELSE
      CodeEditor1.ExecutionLine := -1;
  END;
END;

FUNCTION TForm1.CompileScript: Boolean;
VAR
  P                 : TPoint;
BEGIN
  Result := False;
  SetEditorErrorLine(-1);
  IF Assigned(dmScript) THEN BEGIN
    dmScript.ScriptText := fCurrentMemo.Lines.Text;
    fSourceList.Values[cSource] := Str2Hex(fCurrentMemo.Lines.Text);
{$IF DEFINED(NEXUSDB) OR DEFINED(USEDBISAM)}
    IF Assigned(dmWeb) THEN BEGIN
      dmWeb.OrderGUID := CurGUID;
      dmWeb.fItem.SelectedGUIDs := dmWeb.SelectedGUIDs;
      dmWeb.fItem.Refresh;
    END;
    IF Assigned(ItemScr) THEN
      ItemScr.OnLogOutput := LogEvent;
{$IFEND NEXUSDB}
{$IFDEF SITEM}
    dmMonitor.OnLogMemo := LogEvent;
{$ENDIF SITEM}
    dmScript.OnGetUnit := fsScriptGetUnit;
    TRY
      dmScript.SyntaxType := 'PascalScript';
      IF dmScript.CompileScript THEN BEGIN
        SetEditorErrorLine(-1);
        Result := True;
      END ELSE BEGIN
        P := fsPosToPoint(dmScript.ErrorPos);
        Dec(P.Y);
        Dec(P.X);
        fCurrentMemo.Caret := TCodePosition.Create(P.Y, P.X);
        SetEditorErrorLine(P.Y);
        ShowConsoleMessage(Self, lpInfo, 'Error Compiling Script', dmScript.ErrorMsg + ' ' +
          dmScript.ErrorPos, '');
      END;
    FINALLY
      dmScript.OnGetUnit := NIL;
    END;
  END;
END;

FUNCTION TForm1.CompileScriptJS: Boolean;
VAR
  lErrorMsg         : STRING;
  lErrorPos         : STRING;
  P                 : TPoint;
  lList             : TStringList;
BEGIN
  Result := True;
  lList := TStringList.Create;
  TRY
    IF Assigned(dmWeb) THEN
      lList.Text := dmWeb.GetLookupValues('LINKSJSVARS');
    Result := jsSyntaxCheck(fCurrentMemo.Lines.Text, lList, lErrorMsg, lErrorPos);
    IF NOT Result THEN BEGIN
      ShowConsoleMessage(Self, lpInfo, 'Error Compiling Script', lErrorMsg + ' ' + lErrorPos, '');
      P := fsPosToPoint(lErrorPos);
      Dec(P.Y);
      Dec(P.X);
      fCurrentMemo.Caret := TCodePosition.Create(P.Y, P.X);
      SetEditorErrorLine(P.Y);
    END ELSE
      SetEditorErrorLine(-1);
  FINALLY
    lzSafeFreeAndNIL(lList);
  END;
END;

PROCEDURE TForm1.ExecuteScript(pDebug: Boolean);
VAR
  P                 : TPoint;
BEGIN
  fRunningMemo := fCurrentMemo;
  IF NOT chkPreserveLog.Checked THEN
    CodeEditor2.Lines.Clear;
  dmScript.ScriptText := fCurrentMemo.Lines.Text;
  fSourceList.Values[cSource] := Str2Hex(fCurrentMemo.Lines.Text);
{$IF DEFINED(NEXUSDB) OR DEFINED(USEDBISAM)}
  IF Assigned(dmWeb) THEN BEGIN
    dmWeb.OrderGUID := CurGUID;
    dmWeb.fItem.SelectedGUIDs := dmWeb.SelectedGUIDs;
    dmWeb.fItem.Refresh;
  END;
  IF Assigned(ItemScr) THEN
    ItemScr.OnLogOutput := LogEvent;
{$IFEND NEXUSDB}
{$IFDEF SITEM}
  dmMonitor.OnLogMemo := LogEvent;
{$ENDIF SITEM}
  IF Assigned(dmScript) THEN BEGIN
    dmScript.SyntaxType := 'PascalScript';
    dmScript.OnGetUnit := fsScriptGetUnit;
    TRY
      IF dmScript.CompileScript THEN BEGIN
        SetEditorErrorLine(-1);
        fRunningFree := NOT pDebug;
        IF pDebug THEN
          UpdateVariables(True);
        dmScript.OnRunLine := fsScript1RunLine;
        TRY
          FRunning := True;
          CheckButtons;
          dmScript.ExecuteScript;
        FINALLY
          fCurrentUnit := cSource;
          fRunningMemo.Lines.Text := Hex2Str(fSourceList.Values[cSource]);
          fRunningMemo.ReadOnly := False;
          SetEditorRunLine(-1);
          fRunningMemo.Caret := TCodePosition.Create(fLastPos.Y, fLastPos.X);
          fRunningMemo.TopLine := fLastTopLine;
          fRunningMemo.LeftColumn := fLastLeftColumn;
          FRunning := False;
          fRunningMemo := NIL;
          cxTreeWatch.Clear;
          dmScript.OnRunLine := NIL;
          dmScript.OnGetUnit := NIL;
        END;
      END ELSE IF Assigned(dmScript) THEN BEGIN
        P := fsPosToPoint(dmScript.ErrorPos);
        Dec(P.Y);
        Dec(P.X);
        SetEditorErrorLine(P.Y);
        fRunningMemo.Caret := TCodePosition.Create(P.Y, P.X);
        ShowConsoleMessage(Self, lpInfo, 'Error Compiling Script', dmScript.ErrorMsg + ' ' +
          dmScript.ErrorPos, '');
      END;
    FINALLY
      dmScript.OnGetUnit := NIL;
    END;
  END;
END;

PROCEDURE TForm1.fsScript1RunLine(Sender: TfsScript; CONST UnitName, SourcePos: STRING);
VAR
  P                 : TPoint;
BEGIN
  IF Assigned(fRunningMemo) AND FRunning THEN BEGIN
    P := fsPosToPoint(SourcePos);
    Dec(P.Y);
    Dec(P.X);
    fStopped := fRunningMemo.HasBreakpoint(P.Y + 1) OR (NOT fRunningFree);
    IF fStopped THEN BEGIN
      IF (fCurrentUnit <> UnitName) AND (UnitName <> '') THEN BEGIN
        fCurrentUnit := UnitName;
        fRunningMemo.Lines.Text := Hex2Str(fSourceList.Values[UnitName]);
        fRunningMemo.ReadOnly := True;
      END ELSE IF (UnitName = '') AND (fCurrentUnit <> cSource) THEN BEGIN
        fCurrentUnit := cSource;
        fRunningMemo.ReadOnly := False;
        fRunningMemo.Lines.Text := Hex2Str(fSourceList.Values[cSource]);
      END;
      EnableWindow(Handle, True);
      SetFocus;
      fRunningMemo.Caret := TCodePosition.Create(P.Y, P.X);
      SetEditorRunLine(P.Y);
      fRunningMemo.ShowLine(P.Y);
      UpdateVariables(False);
      WHILE fStopped DO BEGIN
        Sleep(50);
        Application.ProcessMessages;
      END;
      CheckButtons;
    END;
  END;
END;

PROCEDURE TForm1.fsScriptGetUnit(Sender: TfsScript; CONST UnitName: STRING; VAR UnitText: STRING);
BEGIN
  { The original form loads additional source units from the host database.
    Keep this hook in place so the host can paste that loader back in unchanged. }
END;

PROCEDURE TForm1.LogEvent(CONST pLevel: Integer; CONST pString: STRING);
BEGIN
  CodeEditor2.Lines.Add(pString);
END;

FUNCTION TForm1.GetScriptText: STRING;
BEGIN
  Result := CodeEditor1.Lines.Text;
END;

PROCEDURE TForm1.SetScriptText(CONST Value: STRING);
BEGIN
  IF Assigned(fSourceList) THEN
    fSourceList.Values[cSource] := Str2Hex(Value);
  CodeEditor1.Lines.Text := Value;
  CodeEditor1.Modified := False;
END;

PROCEDURE TForm1.SetLexer(CONST Value: STRING);
BEGIN
  IF fLexer <> Value THEN BEGIN
    fLexer := Value;
    IF SameText(Value, 'Pascal script') OR SameText(Value, 'Pascal Calc') OR
      SameText(Value, 'C++') THEN
      CodeEditor1.Highlighter := DelphiCodeHighlighter1
    ELSE IF SameText(Value, 'PL/SQL') OR SameText(Value, 'SQL') THEN BEGIN
      CodeEditor1.Highlighter := SqlCodeHighlighter1;
      CodeEditor1.Options.LineCommentPrefix := '--';
    END ELSE IF SameText(Value, 'Java script') OR SameText(Value, 'JavaScript') THEN
      CodeEditor1.Highlighter := JavaScriptCodeHighlighter1
    ELSE IF SameText(Value, 'Tungli') THEN
      CodeEditor1.Highlighter := TungliCodeHighlighter1
    ELSE IF SameText(Value, 'Batch') THEN
      CodeEditor1.Highlighter := BatchCodeHighlighter1
    ELSE IF SameText(Value, 'PowerShell') THEN
      CodeEditor1.Highlighter := PowerShellCodeHighlighter1
    ELSE IF SameText(Value, 'INI') THEN
      CodeEditor1.Highlighter := IniCodeHighlighter1
    ELSE IF SameText(Value, 'YAML') THEN
      CodeEditor1.Highlighter := YamlCodeHighlighter1
    ELSE IF SameText(Value, 'Python') THEN
      CodeEditor1.Highlighter := PythonCodeHighlighter1;
  END;
END;

PROCEDURE TForm1.SetCurGUID(CONST Value: STRING);
BEGIN
  IF fCurGUID <> Value THEN BEGIN
    fCurGUID := Value;
{$IF DEFINED(NEXUSDB) OR DEFINED(USEDBISAM)}
    IF Assigned(ItemScr) THEN
      LoadTables(dmConn.Database, ItemScr.fTableList, Value);
    IF Assigned(dmWeb) THEN BEGIN
      IF Assigned(dmWeb.fItem) THEN
        LoadTables(dmWeb.dmCtl.dmConn.Database, dmWeb.fItem.TableList, Value);
      dmWeb.fItem.iGUID := Value;
      dmWeb.IDRetailerOrder := StrToIntDef(Copy(dmWeb.fItem.OrderID, 1, 4), 0);
      dmWeb.IDCollectionOrder := dmWeb.fItem.IDCollectionOrder;
    END;
{$IFEND NEXUSDB}
  END;
END;

PROCEDURE TForm1.OnGetVariable(Sender: TObject; CONST VariableName: STRING;
  VAR VariableValue: Variant; VAR Handled: Boolean; Index: Integer = 0);
BEGIN
  Handled := False;
END;

{$IFDEF NEXUSDB}
PROCEDURE TForm1.SetdmWeb(CONST Value: TDataModuleCliUtil);
BEGIN
  fdmWeb := Value;
  IF Assigned(fdmWeb) THEN BEGIN
    dmScript := fdmWeb.dmScript;
    dmConn := fdmWeb.dmCtl.dmConn;
    nxLookup.Database := fdmWeb.dmCtl.dmConn.Database;
    nxLookup.TableName := cTableLookup;
    nxLookup.Active := True;
    nxQueryTest.Database := fdmWeb.dmCtl.dmConn.Database;
    fTable.DB := TCommonDatabase(fdmWeb.dmCtl.dmConn.Database);
    fQuery.DB := TCommonDatabase(fdmWeb.dmCtl.dmConn.Database);
  END;
END;

PROCEDURE TForm1.SetIsInterp(CONST Value: Boolean);
BEGIN
  fIsInterp := Value;
END;

PROCEDURE TForm1.LoadTables(pDatabase: TnxDatabase; pTableList: TTableList; pOGUID: STRING);
BEGIN
END;
{$ENDIF NEXUSDB}

{$IFDEF USEDBISAM}
PROCEDURE TForm1.SetdmWeb(CONST Value: TDataModuleCliUtil);
BEGIN
  fdmWeb := Value;
  IF Assigned(fdmWeb) THEN BEGIN
    dmScript := fdmWeb.dmScript;
    dmConn := fdmWeb.dmCtl.dmConn;
    nxLookup.DatabaseName := fdmWeb.dmCtl.dmConn.Database.DatabaseName;
    nxLookup.SessionName := fdmWeb.dmCtl.dmConn.Database.SessionName;
    nxLookup.TableName := cTableLookup;
    nxLookup.Active := True;
    nxQueryTest.DatabaseName := fdmWeb.dmCtl.dmConn.Database.DatabaseName;
    nxQueryTest.SessionName := fdmWeb.dmCtl.dmConn.Database.SessionName;
    fTable.DatabaseName := fdmWeb.dmCtl.dmConn.Database.DatabaseName;
    fTable.SessionName := fdmWeb.dmCtl.dmConn.Database.SessionName;
    fQuery.DatabaseName := fdmWeb.dmCtl.dmConn.Database.DatabaseName;
    fQuery.SessionName := fdmWeb.dmCtl.dmConn.Database.SessionName;
  END;
END;

PROCEDURE TForm1.SetIsInterp(CONST Value: Boolean);
BEGIN
  fIsInterp := Value;
END;

PROCEDURE TForm1.LoadTables(pDatabase: TDBISAMDatabase; pTableList: TTableList; pOGUID: STRING);
BEGIN
END;
{$ENDIF USEDBISAM}

FUNCTION TForm1.FindVar(pName: STRING; pProc: TfsScript): Boolean;
VAR
  i                 : Integer;
  lVar              : TfsCustomVariable;
BEGIN
  Result := False;
  i := 0;
  WHILE (Result = False) AND (i < pProc.Count) DO BEGIN
    lVar := pProc.Items[i];
    IF (lVar IS TfsVariable) OR (lVar IS TfsParamItem) THEN BEGIN
      IF CompareText(lVar.Name, pName) = 0 THEN
        Result := True;
    END ELSE IF (lVar IS TfsProcVariable) THEN
      Result := FindVar(pName, TfsProcVariable(lVar).Prog);
    Inc(i);
  END;
END;

FUNCTION TForm1.LookupVarType(pVar: STRING): STRING;
VAR
  lLen              : Integer;
  i                 : Integer;
  lStr              : STRING;
BEGIN
  Result := '';
  lLen := Length(pVar);
  IF Assigned(fCurrentMemo) THEN BEGIN
    i := 0;
    WHILE (i < fCurrentMemo.Lines.Count) AND (Result = '') DO BEGIN
      lStr := fCurrentMemo.Lines[i];
      IF (FastPosNoCase(lStr, pVar, Length(lStr), lLen, 1) > 0) AND
        (FastPos(lStr, ':', Length(lStr), 1, 1) > 0) AND
        (FastPos(lStr, ':=', Length(lStr), 2, 1) = 0) THEN BEGIN
        lLen := FastPos(lStr, ':', Length(lStr), 1, 1) + 1;
        Result := strTrimA(Copy(lStr, lLen, Length(lStr) - lLen));
      END;
      Inc(i);
    END;
  END;
END;

FUNCTION TForm1.GetValue(Sender: TObject; pName: STRING): STRING;
BEGIN
  Result := '';
END;

PROCEDURE TForm1.UpdateVariables(pJustAdd: Boolean = False);
BEGIN
  { Existing debugger tree population is independent of the editor control.
    It can be moved over verbatim when this form is dropped back into the host project. }
END;

PROCEDURE TForm1.SetFontSize(CONST Value: Integer);
BEGIN
  IF (Value > 5) AND (fFontSize <> Value) THEN BEGIN
    fFontSize := Value;
    CodeEditor1.Font.Size := fFontSize;
    CodeEditor2.Font.Size := fFontSize;
    CodeEditor3.Font.Size := fFontSize;
    cxTreeWatch.Font.Size := fFontSize;
    cxTreeWatches.Font.Size := fFontSize;
    cxTreeListVariables.Font.Size := fFontSize;
  END;
END;

PROCEDURE TForm1.SetZoomLevel(CONST Value: Integer);
VAR
  lSize             : Integer;
BEGIN
  IF (Value > 10) AND (fZoomLevel <> Value) THEN BEGIN
    fZoomLevel := Value;
    lSize := Max(6, MulDiv(fFontSize, fZoomLevel, 100));
    CodeEditor1.Font.Size := lSize;
    CodeEditor2.Font.Size := lSize;
    CodeEditor3.Font.Size := lSize;
  END;
END;

PROCEDURE TForm1.AddFastScriptCompletions(CONST Context: TCodeCompletionContext;
  Items: TCodeCompletionItems);
CONST
  cMaxFallbackItems = 200;
VAR
  i                 : Integer;
  lIndex            : Integer;
  lRoot             : STRING;
  lChain            : STRING;
  lMember           : STRING;
  lExpr             : STRING;
  lClass            : TfsClassVariable;
  lVar              : TfsCustomVariable;
  lPrefix           : STRING;
  FUNCTION GetType(pHelper: TfsCustomHelper): STRING;
  BEGIN
    CASE pHelper.Typ OF
      fvtInt: Result := 'Integer';
      fvtBool: Result := 'Boolean';
      fvtFloat: Result := 'Extended';
      fvtChar: Result := 'Char';
      fvtString: Result := 'String';
      fvtClass: Result := pHelper.TypeName;
      fvtArray: Result := 'Array';
      fvtEnum: Result := pHelper.TypeName;
    ELSE
      Result := 'Variant';
    END;
  END;
  FUNCTION GetMemberClass(pClass: TfsClassVariable; CONST pName: STRING): TfsClassVariable;
  VAR
    j               : Integer;
  BEGIN
    Result := NIL;
    IF NOT Assigned(pClass) THEN
      EXIT;
    FOR j := 0 TO pClass.MembersCount - 1 DO
      IF SameText(pClass.Members[j].Name, pName) THEN BEGIN
        Result := fsGlobalUnit.FindClass(pClass.Members[j].TypeName);
        EXIT;
      END;
  END;
  FUNCTION HasCompletion(CONST pCaption: STRING): Boolean;
  VAR
    j               : Integer;
  BEGIN
    Result := False;
    FOR j := 0 TO Items.Count - 1 DO
      IF SameText(Items[j].Caption, pCaption) THEN BEGIN
        Result := True;
        EXIT;
      END;
  END;
  PROCEDURE AddClassMember(pObj: TObject);
  VAR
    lDetail         : STRING;
    lInsert         : STRING;
    lKind           : TCodeCompletionItemKind;
  BEGIN
    IF NOT (pObj IS TfsCustomVariable) THEN
      EXIT;

    lVar := TfsCustomVariable(pObj);
    lInsert := lVar.Name;
    lDetail := lVar.ClassName;
    lKind := ckVariable;
    IF pObj IS TfsPropertyHelper THEN BEGIN
      lDetail := 'property: ' + GetType(TfsCustomHelper(pObj));
      lKind := ckProperty;
    END ELSE IF pObj IS TfsEventHelper THEN BEGIN
      lDetail := 'event: ' + GetType(TfsCustomHelper(pObj));
      lKind := ckProperty;
    END ELSE IF pObj IS TfsMethodHelper THEN BEGIN
      lDetail := TfsMethodHelper(pObj).Syntax;
      lKind := ckMethod;
    END ELSE IF pObj IS TfsVariable THEN BEGIN
      lDetail := 'var: ' + GetType(TfsCustomHelper(pObj));
      lKind := ckVariable;
    END;

    IF (lPrefix <> '') AND (NOT SameText(Copy(lVar.Name, 1, Length(lPrefix)), lPrefix)) THEN
      EXIT;

    IF NOT HasCompletion(lVar.Name) THEN
      Items.AddItem(lVar.Name, lInsert, lKind, lDetail);
  END;
  PROCEDURE AddClassMembers(pClass: TfsClassVariable);
  VAR
    j               : Integer;
    lWalk           : TfsClassVariable;
  BEGIN
    lWalk := pClass;
    WHILE Assigned(lWalk) DO BEGIN
      FOR j := 0 TO lWalk.MembersCount - 1 DO
        AddClassMember(lWalk.Members[j]);
      IF lWalk.Ancestor <> '' THEN
        lWalk := fsGlobalUnit.FindClass(lWalk.Ancestor)
      ELSE
        lWalk := NIL;
    END;
  END;
BEGIN
  lExpr := '';
  lPrefix := Context.Prefix;
  IF Context.LineText = '' THEN
    EXIT;

  lIndex := EnsureRange(Context.Column, 0, Length(Context.LineText));
  IF (Context.TriggerChar = '.') AND (lIndex > 0) AND (Context.LineText[lIndex] = '.') THEN
    Dec(lIndex);

  WHILE (lIndex > 0) AND CharInSet(Context.LineText[lIndex],
    ['A'..'Z', 'a'..'z', '0'..'9', '_', '.']) DO
  BEGIN
    lExpr := Context.LineText[lIndex] + lExpr;
    Dec(lIndex);
  END;

  IF lExpr <> '' THEN BEGIN
    lRoot := GetToken(lExpr, '.', 0);
    lClass := fsGlobalUnit.FindClass(LookupVarType(lRoot));
    IF NOT Assigned(lClass) THEN
      lClass := fsGlobalUnit.FindClass(lRoot);

    i := 1;
    lChain := GetToken(lExpr, '.', i);
    WHILE (lChain <> '') AND Assigned(lClass) DO BEGIN
      lMember := lChain;
      Inc(i);
      lChain := GetToken(lExpr, '.', i);
      IF (lChain = '') AND (lPrefix <> '') AND SameText(lMember, lPrefix) THEN
        BREAK;
      lClass := GetMemberClass(lClass, lMember);
    END;

    IF Assigned(lClass) THEN BEGIN
      AddClassMembers(lClass);
      EXIT;
    END;
  END;

  IF Context.TriggerChar = '.' THEN
    EXIT;

  IF lPrefix = '' THEN
    EXIT;

  FOR i := 0 TO fsGlobalUnit.Count - 1 DO BEGIN
    IF Items.Count >= cMaxFallbackItems THEN
      EXIT;
    IF fsGlobalUnit.Items[i] IS TfsCustomVariable THEN BEGIN
      lVar := TfsCustomVariable(fsGlobalUnit.Items[i]);
      IF SameText(Copy(lVar.Name, 1, Length(lPrefix)), lPrefix) AND
        (NOT HasCompletion(lVar.Name)) THEN
        Items.AddItem(lVar.Name, lVar.Name, ckVariable, lVar.ClassName);
    END;
  END;
END;

PROCEDURE TForm1.AddJavaScriptCompletions(Items: TCodeCompletionItems);
VAR
  i                 : Integer;
BEGIN
  Items.AddItem('CurItem', 'CurItem', ckVariable, 'current item');
  FOR i := Low(cKeywords) TO High(cKeywords) DO
    Items.AddItem(cKeywords[i], cKeywords[i], ckKeyword, 'keyword');
  FOR i := Low(cLiterals) TO High(cLiterals) DO
    Items.AddItem(cLiterals[i], cLiterals[i], ckKeyword, 'literal');
  FOR i := Low(cKeywordsJQ) TO High(cKeywordsJQ) DO
    Items.AddItem(cKeywordsJQ[i], cKeywordsJQ[i], ckKeyword, 'jQuery');
END;

PROCEDURE TForm1.AddCalcCompletions(Items: TCodeCompletionItems);
CONST
  CalcKeywords: ARRAY[0..20] OF STRING = (
    'AND', 'OR', 'NOT', 'FreeVar', 'ExistVar', 'Logic', 'Numeric', 'String',
    'Char', 'Ascii', 'Eval', 'Abs', 'Frac', 'Trunc', 'Sqrt', 'Length', 'Pos',
    'Trim', 'Upper', 'Lower', 'IFF'
    );
VAR
  Keyword           : STRING;
BEGIN
  FOR Keyword IN CalcKeywords DO
    Items.AddItem(Keyword, Keyword, ckFunction, 'calculation');
END;

PROCEDURE TForm1.AddSqlCompletions(Items: TCodeCompletionItems);
CONST
  SqlKeywords: ARRAY[0..14] OF STRING = (
    'SELECT', 'FROM', 'WHERE', 'JOIN', 'LEFT JOIN', 'INNER JOIN', 'GROUP BY',
    'ORDER BY', 'AND', 'OR', 'NOT', 'IS NULL', 'IS NOT NULL', 'LIKE', 'IN'
    );
VAR
  Keyword: STRING;
BEGIN
  FOR Keyword IN SqlKeywords DO
    Items.AddItem(Keyword, Keyword, ckKeyword, 'SQL');
END;

PROCEDURE TForm1.CompletionGetCompletions(Sender: TObject; CONST Context: TCodeCompletionContext;
  Items: TCodeCompletionItems);
BEGIN
  IF SameText(Lexer, 'Pascal script') AND (NOT fIsInterp) THEN
    AddFastScriptCompletions(Context, Items)
  ELSE IF SameText(Lexer, 'Pascal Calc') OR SameText(Lexer, 'C++') THEN
    AddCalcCompletions(Items)
  ELSE IF SameText(Lexer, 'PL/SQL') THEN
    AddSqlCompletions(Items)
  ELSE IF SameText(Lexer, 'Java script') THEN
    AddJavaScriptCompletions(Items)
  ELSE
    AddFastScriptCompletions(Context, Items);
END;

PROCEDURE TForm1.CompletionGetSignatureHelp(Sender: TObject;
  CONST Context: TCodeSignatureHelpContext; Items: TCodeSignatureItems);
VAR
  i                 : Integer;
  j                 : Integer;
  lParam            : STRING;
  lVar              : TfsCustomVariable;
BEGIN
  IF SameText(Lexer, 'Pascal script') AND Assigned(dmScript) THEN BEGIN
    lVar := dmScript.fsScript.Find(Context.FunctionName);
    IF Assigned(lVar) THEN BEGIN
      Items.AddItem(Context.FunctionName, []);
      FOR i := 0 TO lVar.GetNumberOfRequiredParams - 1 DO
        Items[0].Parameters.Add(lVar.Params[i].Name + ':' + lVar.Params[i].GetFullTypeName);
    END;
  END ELSE IF SameText(Lexer, 'Java script') THEN BEGIN
    FOR i := Low(cTOPSVar) TO High(cTOPSVar) DO
      IF SameText(cTOPSVar[i], Context.FunctionName) THEN BEGIN
        Items.AddItem(Context.FunctionName, []);
        j := 0;
        lParam := GetToken(cTOPSVarP[i], ',', j);
        WHILE lParam <> '' DO BEGIN
          Items[0].Parameters.Add(lParam);
          Inc(j);
          lParam := GetToken(cTOPSVarP[i], ',', j);
        END;
        Break;
      END;
  END ELSE IF SameText(Lexer, 'Pascal Calc') OR SameText(Lexer, 'C++') THEN BEGIN
    IF SameText(Context.FunctionName, 'IFF') THEN
      Items.AddItem('IFF', ['Condition:POINTER', 'TrueValue:POINTER', 'FalseValue:POINTER'])
    ELSE IF SameText(Context.FunctionName, 'Copy') THEN
      Items.AddItem('Copy', ['StringVariable:POINTER', 'Index:POINTER', 'Count:POINTER'])
    ELSE IF SameText(Context.FunctionName, 'Replace') THEN
      Items.AddItem('Replace', ['StringVariable:POINTER', 'OldValue:POINTER', 'NewValue:POINTER']);
  END;
END;

END.
