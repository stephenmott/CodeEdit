UNIT frmScrEdit;
{* Script Editor Form }
(**************************************************************************)
(* Purpose    : 1)                                                       *)
(*            : 2)                                                        *)
(* Author     : SAM                                                       *)
(* Version    : 3.0.0                                                     *)
(* Date       : 20/11/2006                                                *)
(* KOL ok?    : Not yet                                                   *)
(* DebugDefine: debugXXXX                                                 *)
(* Notes      :          is the base class for                            *)
(*            :                                                           *)
(**************************************************************************)

{ (+93) 94, 187, 280, 373, 466, 559, 652, 745, 838, 931, 1024, 1117, 1210, 1303, 1396, 1489 }

{* -=-=- History -=-=-
Date      Who  Build Notes
20061020  SAM        Initial Code
20120328  SAM    131 Added hint evaluation ^QF b131_01
20120328  SAM    131 Updated ways debug variables are calculated ^QF b131_02
-=-=- History Ends -=-=-}

{$I lzProduct.inc}
{$I TOPS.inc}
{$I lzAgent.inc}

{$C+  + Enables or disables the generation of code for assertions}
{$D+  + generation of debug information}
{$L+  LOCALSYMBOLS ON}

INTERFACE

USES
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ActnList, ImgList, Clipbrd, DB, INIFiles,

  {NexusDB}
{$IFDEF NEXUSDB}
  nxllConst, nxllTypes, nxdb, nxdbBase, nxsdDataDictionary, nxsdTypes, nxsdServerEngine,
{$ENDIF NEXUSDB}
  nxllComponent,

{$IFDEF USEDBISAM}
  dbisamtb,
{$ENDIF USEDBISAM}

  {DevExpress}
  dxBarDBNav, dxBar, dxBarExtItems, cxPC, cxControls, cxGraphics,
  dxStatusBar, cxClasses, dxSkinsCore, dxSkinsDefaultPainters, dxSkinscxPCPainter,
  dxSkinsdxStatusBarPainter, dxSkinsdxBarPainter, dxSkinsdxDockControlPainter,
  dxSkinsdxRibbonPainter, dxRibbonStatusBar, dxRibbon, dxRibbonForm, cxLookAndFeels,
  cxLookAndFeelPainters, cxContainer, cxEdit, cxSplitter, cxGroupBox, cxCustomData, cxStyles,
  cxTL, cxTextEdit, cxTLdxBarBuiltInMenu, cxInplaceContainer, cxSpinEdit, dxRibbonSkins,
  dxSkinsForm, dxRibbonCustomizationForm, dxThreading,

  dxSkinOffice2007Green, dxSkinSpringTime, dxSkinBlack, dxSkinCaramel, dxSkinCoffee, dxSkinDarkSide,
  dxSkinGlassOceans, dxSkiniMaginary, dxSkinLilian, dxSkinLiquidSky, dxSkinLondonLiquidSky,
  dxSkinMcSkin, dxSkinMoneyTwins, dxSkinOffice2007Black, dxSkinOffice2007Blue, dxSkinOffice2007Pink,
  dxSkinOffice2007Silver, dxSkinPumpkin, dxSkinSilver, dxSkinStardust, dxSkinSummer2008,
  dxSkinValentine, dxSkinXmas2008Blue, dxSkinDarkRoom, dxSkinFoggy,
  dxSkinOffice2010Black, dxSkinOffice2010Blue, dxSkinOffice2010Silver, dxSkinSeven, dxSkinSharp,
  dxSkinBlueprint, dxSkinDevExpressDarkStyle, dxSkinDevExpressStyle, dxSkinHighContrast,
  dxSkinSevenClassic, dxSkinSharpPlus, dxSkinTheAsphaltWorld, dxSkinVS2010, dxSkinWhiteprint,
  dxSkinMetropolis, dxSkinMetropolisDark, dxSkinOffice2013DarkGray, dxSkinOffice2013LightGray,
  dxSkinOffice2013White, dxSkinBlue,

  {EC Edit}
  ecSyntMemo, ecActns, ecKeyMap, ecSyntAnal, ecPrint, ecPopupCtrl, ecAutoReplace, ecSyntDlg,
  ecExtHighlight,

  {FastScript}
  fs_iinterpreter, fs_iTools,
  fs_iformsrtti, fs_igraphicsrtti, fs_iclassesrtti, fs_idialogsrtti, fs_iextctrlsrtti,  // Code Library Support
  fs_ipascal, fs_icpp, fs_ijs, fs_ibasic, // Script Language Support

  {FastStrings}
  FastStrings, FastStringFuncs,

  {Jedi}
  JvFormPlacement, JvComponent, JvAppStorage, JvAppRegistryStorage, JvComponentBase, JvTypes,

  TaskDialog,

  uCalcul, uInterpreter,

  {Lanboss}
{$IF DEFINED(NEXUSDB) OR DEFINED(USEDBISAM)}
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
{$IFDEF USEDBISAM}
  dmDBIComm,
  dmDBIControl,
{$ENDIF USEDBISAM}

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
  utlFRM, utlFMT, utlJS, utlJSF, utlPSF, uEtch, dxBarBuiltInMenu, Menus, StdCtrls, utlJSON,
  cxButtons, cxCheckBox, ecPropManager, dxCore, cxFilter,
  dxScrollbarAnnotations, cxImageList, System.Actions, System.ImageList
{$IFDEF DUCKCHECK}
  , utlDuck
{$ENDIF DUCKCHECK}
  ;                                     //, utlJSF2;

CONST
  cSource           = 'Source';

  cKeywordsCal      : ARRAY[0..70] OF STRING =
    (
    'AND',
    'OR',
    'NOT',
    'FreeVar',
    'ExistVar',
    'Logic',
    'Numeric',
    'String',
    'Char',
    'Ascii',
    'Eval',
    'NumBase',
    'BaseNum',
    'Div',
    'Mod',
    'Abs',
    'Frac',
    'Trunc',
    'Heaviside',
    'Sign',
    'Sqrt',
    'Ln',
    'Exp',
    'Cos',
    'CTg',
    'Ch',
    'CTh',
    'Sin',
    'Sh',
    'Tg',
    'Th',
    'ArcSin',
    'ArcCos',
    'ArcTg',
    'ArcCtg',
    'MaxVal',
    'MinVal',
    'SumVal',
    'AvgVal',
    '||',
    'Like',
    'Wildcard',
    'Length',
    'Pos',
    'Trim',
    'TrimLeft',
    'TrimRight',
    'Upper',
    'Lower',
    'Copy',
    'CopyTo',
    'Delete',
    'Insert',
    'Replace',
    'IFF',
    'Prefix',
    'Year',
    'Month',
    'Day',
    'WeekDay',
    'Hour',
    'Minute',
    'Sec',
    'StrToStamp',
    'LastDay',
    'StampToStr',
    'StampToDateStr',
    'StampToTimeStr',
    '_NOW',
    '_TIME',
    '_DATE'
    );

  cKeywordsCalP     : ARRAY[0..70] OF STRING =
    (
    '',
    '',
    '',
    'VariableName:POINTER',
    'VariableName:POINTER',
    'TestVar:POINTER',
    'StringVariable:POINTER',
    'StringVariable:POINTER',
    'CharVariable:POINTER',
    'IntegerVariable:POINTER',
    'FormulaVariable:POINTER',
    'StringVariable:POINTER,Base:POINTER',
    'IntegerVariable:POINTER,Base:POINTER',
    '',
    '',
    'Variable:POINTER',
    'Variable:POINTER',
    'Variable:POINTER',
    'Variable:POINTER',
    'Variable:POINTER',
    'Variable:POINTER',
    'Variable:POINTER',
    'Variable:POINTER',
    'Variable:POINTER',
    'Variable:POINTER',
    'Variable:POINTER',
    'Variable:POINTER',
    'Variable:POINTER',
    'Variable:POINTER',
    'Variable:POINTER',
    'Variable:POINTER',
    'Variable:POINTER',
    'Variable:POINTER',
    'Variable:POINTER',
    'Variable:POINTER',
    'Variable1:POINTER,Variable2:POINTER',
    'Variable1:POINTER,Variable2:POINTER',
    'Variable1:POINTER,Variable2:POINTER',
    'Variable1:POINTER,Variable2:POINTER',
    '',
    '',
    '',
    'StringVariable:POINTER',
    'SubStringVariable:POINTER,StringVariable:POINTER',
    'StringVariable:POINTER',
    'StringVariable:POINTER',
    'StringVariable:POINTER',
    'StringVariable:POINTER',
    'StringVariable:POINTER',
    'StringVariable:POINTER,StartInteger:POINTER,[EndInteger:POINTER]',
    'StringVariable:POINTER,StartInteger:POINTER,[EndInteger:POINTER]',
    'StringVariable:POINTER,StartInteger:POINTER,[EndInteger:POINTER]',
    'StringVariable:POINTER,StartInteger:POINTER,LengthInteger:POINTER',
    'StringVariable:POINTER,SearchFor:POINTER,ReplaceWith:POINTER,ReplaceAll:POINTER,IgnoreCase:POINTER',
    'BooleanCondition:POINTER,TrueValue:POINTER,FalseValue:POINTER',
    'Count:Integer,Char:Integer,String:STRING',
    'StringYear:STRING',
    'StringMonth:STRING',
    'StringDay:STRING',
    'WeekDay:STRING',
    'Hour:STRING',
    'Minute:STRING',
    'Sec:STRING',
    'DateString:STRING',
    'Month:STRING',
    'DateStamp:FLOAT',
    'DateStr:FLOAT',
    'TimeStr:FLOAT',
    '',
    '',
    ''
    );

TYPE
  TformScrEdit = CLASS(TdxRibbonForm)
    SyntFindDialog1: TSyntFindDialog;
    SyntReplaceDialog1: TSyntReplaceDialog;
    PrinterSetupDialog1: TPrinterSetupDialog;
    SyntAutoReplace1: TSyntAutoReplace;
    AutoCompleteFSScript: TAutoCompletePopup;
    ecSyntPrinter1: TecSyntPrinter;
    SyntStyles1: TSyntStyles;
    SyntStyles2: TSyntStyles;
    SyntKeyMapping1: TSyntKeyMapping;
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
    ecPrintAction1: TecPrintAction;
    ecPreviewAction1: TecPreviewAction;
    ecPageSetupAction1: TecPageSetupAction;
    actPrintSetup: TAction;
    ecIncrementalSearch1: TecIncrementalSearch;
    ecSearchAgain1: TecSearchAgain;
    actViewOutput: TAction;
    actViewProduction: TAction;
    actViewTest: TAction;
    actComment: TAction;
    actUnComment: TAction;
    actFunction: TAction;
    dxBarManager1: TdxBarManager;
    dxFile: TdxBarSubItem;
    dxEdit: TdxBarSubItem;
    dxRun: TdxBarSubItem;
    dxCompile: TdxBarButton;
    dxToggleBreakpoint: TdxBarButton;
    dxStepScript: TdxBarButton;
    dxRunScript: TdxBarButton;
    dxStopScript: TdxBarButton;
    dxEvaluateScript: TdxBarButton;
    dxSave: TdxBarButton;
    dxPageSetup: TdxBarButton;
    dxPrintPreview: TdxBarButton;
    dxPrinterSetup: TdxBarButton;
    dxCut: TdxBarButton;
    dxPrint: TdxBarButton;
    dxCopy: TdxBarButton;
    dxExit: TdxBarButton;
    dxPaste: TdxBarButton;
    dxFind: TdxBarButton;
    dxReplace: TdxBarButton;
    dxSearchAgain: TdxBarButton;
    dxIncrementalSearch: TdxBarButton;
    dxFontName: TdxBarFontNameCombo;
    dxView: TdxBarSubItem;
    dxViewProduction: TdxBarButton;
    dxViewOutput: TdxBarButton;
    dxEditTables: TdxBarSubItem;
    dxFontSize: TdxBarCombo;
    dxComment: TdxBarButton;
    dxUncomment: TdxBarButton;
    dxMatchDelimiter: TdxBarButton;
    dxImport: TdxBarSubItem;
    dxFunctions: TdxBarButton;
    actClose: TAction;
    JvAppRegistryStorage1: TJvAppRegistryStorage;
    JvFormStorage1: TJvFormStorage;
    ParamCompletionFSScript: TParamCompletion;
    actMatchDelim: TecCommandAction;
    HyperlinkHighlighter1: THyperlinkHighlighter;
    ecCopy1: TecCopy;
    ecCut1: TecCut;
    ecPaste1: TecPaste;
    actProcList: TAction;
    dxBarButton1: TdxBarButton;
    dxRibbon1Tab1: TdxRibbonTab;
    dxRibbon1: TdxRibbon;
    dxRibbonStatusBar1: TdxRibbonStatusBar;
    cxStyleRepository1: TcxStyleRepository;
    cxStyle1: TcxStyle;
    cxImageList1: TcxImageList;
    TemplatePopup1: TTemplatePopup;
    cxImageList2: TcxImageList;
    actTemplatePopup: TAction;
    AutoCompleteSQL: TAutoCompletePopup;
    AutoCompleteJS: TAutoCompletePopup;
    AutoCompleteCalc: TAutoCompletePopup;
    ParamCompletionCalc: TParamCompletion;
    ParamCompletionSQL: TParamCompletion;
    ParamCompletionJS: TParamCompletion;
    actAddWatch: TAction;
    actDelWatch: TAction;
    cxGroupBox2: TcxGroupBox;
    cxGroupBox5: TcxGroupBox;
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
    cxPageControl2: TcxPageControl;
    cxTabSheet6: TcxTabSheet;
    SyntaxMemoOutput: TSyntaxMemo;
    cxTabSheet3: TcxTabSheet;
    SyntaxMemoNotes: TSyntaxMemo;
    cxSplitter2: TcxSplitter;
    cxSplitter1: TcxSplitter;
    cxGroupBox7: TcxGroupBox;
    cxGroupBox1: TcxGroupBox;
    SyntaxMemoProduction: TSyntaxMemo;
    cxGroupBox3: TcxGroupBox;
    cxTreeListVariables: TcxTreeList;
    cxCol1: TcxTreeListColumn;
    cxCol2: TcxTreeListColumn;
    cxCol3: TcxTreeListColumn;
    cxSplitter3: TcxSplitter;
    cxGroupBox8: TcxGroupBox;
    chkPreserveLog: TcxCheckBox;
    actFontDown: TAction;
    actFontUp: TAction;
    dxBarLargeButton1: TdxBarLargeButton;
    dxBarLargeButton2: TdxBarLargeButton;
    dxBarSeparator1: TdxBarSeparator;
    PropsManager1: TPropsManager;
    ecCustomizeEditorOptionsAction1: TecCustomizeEditorOptionsAction;
    dxBarLargeButton3: TdxBarLargeButton;
    dxBarLargeButton4: TdxBarLargeButton;
    actResetSizes: TAction;
    PROCEDURE SyntaxMemoProductionCaretPosChanged(Sender: TObject);
    PROCEDURE SyntaxMemoProductionChange(Sender: TObject);
    PROCEDURE SyntaxMemoProductionDblClick(Sender: TObject);
    PROCEDURE SyntaxMemoProductionEnter(Sender: TObject);
    PROCEDURE SyntaxMemoProductionGutterClick(Sender: TObject;
      Line: Integer; Buton: TMouseButton; Shift: TShiftState; XY: TPoint);
    PROCEDURE SyntaxMemoProductionIncSearchChange(Sender: TObject;
      State: TIncSearchState);
    PROCEDURE CheckErrorLine(Sender: TObject; Line: Integer; VAR Show: Boolean);
    PROCEDURE CheckCodeLine(Sender: TObject; Line: Integer; VAR Show: Boolean);
    PROCEDURE CheckBreakLine(Sender: TObject; Line: Integer; VAR Show: Boolean);
    PROCEDURE CheckRunLine(Sender: TObject; Line: Integer; VAR Show: Boolean);
    FUNCTION IsCodeLine(Line: Integer): Boolean;
    FUNCTION IsBreakPt(Line: Integer): Boolean;
    PROCEDURE ToggleBreakpoint(Line: Integer);
    PROCEDURE FormCreate(Sender: TObject);
    PROCEDURE FormDestroy(Sender: TObject);
    PROCEDURE actExecute(Sender: TObject);
    PROCEDURE ParamCompletionFSScriptGetParams(Sender: TObject; CONST FuncName: ecString; pPos:
      Integer);
    PROCEDURE FormCloseQuery(Sender: TObject; VAR CanClose: Boolean);
    PROCEDURE FormShow(Sender: TObject);
    PROCEDURE SyntaxMemoProductionGetTokenHint(Sender: TObject; TokenIndex: Integer; VAR HintText:
      STRING);
    PROCEDURE SyntaxMemoProductionSelectionChanged(Sender: TObject);
    PROCEDURE SyntaxMemoProductionTextChanged(Sender: TObject; Pos, Count,
      LineChange: Integer);
    PROCEDURE ParamCompletionJSGetParams(Sender: TObject; CONST FuncName: ecString; aPos: Integer);
    PROCEDURE AutoCompleteJSAfterComplete(Sender: TObject; CONST Item: ecString);
    PROCEDURE AutoCompleteJSBeforeComplete(Sender: TObject; VAR Item: ecString);
    PROCEDURE AutoCompleteJSGetAutoCompleteList(Sender: TObject;
      aPos: TPoint; List, Display: TecStrings);
    PROCEDURE AutoCompleteJSCanShow(Sender: TObject; VAR DoShow: Boolean);
    PROCEDURE AutoCompleteJSFilter(Sender: TCustomAutoCompletePopup;
      CONST Item, DisplayItem, Filter: STRING; VAR Accept: Boolean);
    PROCEDURE AutoCompleteFSScriptFilter(Sender: TCustomAutoCompletePopup;
      CONST Item, DisplayItem, Filter: STRING; VAR Accept: Boolean);
    PROCEDURE ParamCompletionCalcGetParams(Sender: TObject; CONST FuncName: ecString; aPos: Integer);
    PROCEDURE AutoCompleteCalcAfterComplete(Sender: TObject; CONST Item: ecString);
    PROCEDURE AutoCompleteCalcBeforeComplete(Sender: TObject; VAR Item: ecString);
    PROCEDURE AutoCompleteCalcFilter(Sender: TCustomAutoCompletePopup; CONST Item, DisplayItem,
      Filter: STRING; VAR Accept: Boolean);
    PROCEDURE ecCustomizeEditorOptionsAction1ExecuteOK(Sender: TObject);
    PROCEDURE AutoCompleteFSScriptGetAutoCompleteList(Sender: TObject;
      aPos: TPoint; List, Display: TecStrings);
    PROCEDURE AutoCompleteFSScriptBeforeComplete(Sender: TObject;
      VAR Item: ecString);
    PROCEDURE AutoCompleteFSScriptAfterComplete(Sender: TObject;
      CONST Item: ecString);
    procedure AutoCompleteCalcGetAutoCompleteList(Sender: TObject; aPos: TPoint;
      List, Display: TecStrings);
  PROTECTED
    PROCEDURE CreateParams(VAR Params: TCreateParams); OVERRIDE; // !!SM!!
    PROCEDURE WMSysCommand(VAR Message: TWMSysCommand); MESSAGE WM_SYSCOMMAND;
  PRIVATE
    { Private declarations }
    fItem: STRING;
    fLastPos: TPoint;
    fLastPosX: Integer;
    fLastPosY: Integer;
    fSourceList: TStringList;
    fEvaluating: Boolean;
    //fMinModal: TMinModal;
    fRunningFree: Boolean;
    FBreakPoints: TList;
    FCurrentLine: Integer;
    fErrorLine: Integer;
    FRunning: Boolean;
    fStopped: Boolean;
    fFormatter: TLBFormatter;
    fCurrentMemo: TSyntaxMemo;
    fRunningMemo: TSyntaxMemo;
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
    FUNCTION GetTableVal(pField: STRING): Variant;
    PROCEDURE OnGetVariable(Sender: TObject; CONST VariableName: STRING; VAR VariableValue: Variant;
      VAR Handled: Boolean; Index: Integer = 0);
    PROCEDURE ParentShow(Sender: TObject);

    FUNCTION LookupVarType(pVar: STRING): STRING;
    PROCEDURE CheckButtons;
    FUNCTION CompileScript: Boolean;
    FUNCTION CompileScriptJS: Boolean;
    PROCEDURE ExecuteScript(pDebug: Boolean);

    PROCEDURE fsScript1RunLine(Sender: TfsScript; CONST UnitName, SourcePos: STRING);
    PROCEDURE SetCurGUID(CONST Value: STRING);
    PROCEDURE LogEvent(CONST pLevel: Integer; CONST pString: STRING);
    FUNCTION GetScriptText: STRING;
    PROCEDURE SetScriptText(CONST Value: STRING);
    PROCEDURE SetupMemos;
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
    PROCEDURE fsScriptGetUnit(Sender: TfsScript; CONST UnitName: STRING; VAR UnitText: STRING);
    FUNCTION FindVar(pName: STRING; pProc: TfsScript): Boolean;
    PROCEDURE SetFontSize(CONST Value: Integer);
    PROCEDURE SetZoomLevel(CONST Value: Integer);

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
    PROPERTY IgnoreMissingVariables: Boolean READ fIgnoreMissingVariables WRITE
      fIgnoreMissingVariables;
    PROPERTY FontSize: Integer READ fFontSize WRITE SetFontSize;
    PROPERTY ZoomLevel: Integer READ fZoomLevel WRITE SetZoomLevel;
  END;

VAR
  formScrEdit       : TformScrEdit;

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

IMPLEMENTATION

USES frmEval, frmFunctionTree, frmProcList, scrCtl;

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
  lFrm              : TformScrEdit;
  lOnLogOutput1     : TStringEvent;
  lOnLogOutput2     : TStringEvent;
BEGIN
  lOnLogOutput1 := NIL;
  lOnLogOutput2 := NIL;
  lFrm := TformScrEdit.Create(AOwner);
  TRY
    TForm(AOwner).OnShow := lFrm.ParentShow;
    lFrm.gOwner := TForm(AOwner);
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
    //    lFrm.SetZOrder(True);
    lFrm.SyntaxMemoNotes.Lines.Text := pNotes;
    lFrm.Showmodal;
    IF lFrm.fResult = mrOK THEN BEGIN
      Result := lFrm.ScriptText;
      pNotes := lFrm.SyntaxMemoNotes.Lines.Text;
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
    TForm(AOwner).OnShow := NIL;
  FINALLY
    lzSafeFreeAndNIL(lFrm);
  END;
END;

PROCEDURE TformScrEdit.FormCreate(Sender: TObject);
VAR
  lWindowState      : TWindowState;
BEGIN
  cxPageControl1.ActivePageIndex := 0;
  cxPageControl2.ActivePageIndex := 0;

  dxThreading.dxEnableMultiThreading := False;
  SetSkinInterface(NIL, NIL, dxRibbon1);
  ThemeSyntaxMemo(SyntaxMemoProduction);
  ThemeSyntaxMemo(SyntaxMemoOutput);

  PropsManager1.UseRegistry := True;
  PropsManager1.RootKey := rkCurrentUser;
  PropsManager1.IniSection := 'Software\Lambtons\' +
    ChangeFileExt(ExtractFilename(ParamStr(0)), '') +
    '\ScriptEditor\Properties';

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
  //fMinModal := TMinModal.Create(Self);
  fFormatter := TLBFormatter.Create;
  FBreakPoints := TList.Create;
  FCurrentLine := -1;
  fErrorLine := -1;
  fEvaluating := False;
  fCurrentMemo := SyntaxMemoProduction;
  fTable := TCommonTable.Create(Self);
  fQuery := TCommonQuery.Create(Self);
  fInterpreter := TInterpreter.Create;
  fCalcul := TCalcul.Create;
  fCalcul.OnGetVariable := OnGetVariable;
  fInterpreter.Calcul := fCalcul;

  fResult := mrCancel;
  CheckButtons;
  SetupMemos;
  ScaleForm(Self);

  lWindowState := TWindowState(JvFormStorage1.ReadInteger('WindowState', ord(WindowState)));
  JvFormStorage1.RestoreFormPlacement;
  IF lWindowState <> wsMinimized THEN
    WindowState := lWindowState;

  //  fZoomLevel := JvFormStorage1.ReadInteger('ZoomLevel', 100);

  PropsManager1.Add(SyntaxMemoProduction);
  PropsManager1.Add(SyntaxMemoOutput);
  PropsManager1.Add(SyntaxMemoNotes);

  PropsManager1.LoadProps;
  PropsManager1.UpdateAll;
  fZoomLevel := SyntaxMemoProduction.Zoom;

  fFontSize := SyntaxMemoProduction.Font.Size;
  //  FontSize := JvFormStorage1.ReadInteger('FontSize', SyntaxMemoProduction.Font.Size);

    //  cxGroupBox2.Height := JvFormStorage1.ReadInteger('cxGroupBox2_Height', cxGroupBox2.Height);
    //  cxTreeWatch.Width := JvFormStorage1.ReadInteger('cxTreeWatch_Width', cxTreeWatch.Width);

  IF Height < 50 THEN
    Height := 500;
  IF Width < 50 THEN
    Width := 600;
  IF (Left < 0) OR (Left > Screen.Width - Width) THEN
    Left := (Screen.Width - Width) DIV 2;
  IF (Top < 0) OR (Top > Screen.Height - Height) THEN
    Top := (Screen.Height - Height) DIV 2;

  WHILE SyntFindDialog1.History.Count > 20 DO
    SyntFindDialog1.History.Delete(SyntFindDialog1.History.Count - 1);

  WHILE SyntReplaceDialog1.History.Count > 20 DO
    SyntReplaceDialog1.History.Delete(SyntReplaceDialog1.History.Count - 1);

  //winShowTaskbarIcon(Self.Handle);
END;

PROCEDURE TformScrEdit.FormDestroy(Sender: TObject);
BEGIN
  PropsManager1.SaveProps;

  JvFormStorage1.SaveFormPlacement;
  JvFormStorage1.WriteInteger('WindowState', ord(WindowState));
  //JvFormStorage1.WriteInteger('FontSize', FontSize);
  //JvFormStorage1.WriteInteger('ZoomLevel', ZoomLevel);

  //  JvFormStorage1.WriteInteger('cxGroupBox2_Height', cxGroupBox2.Height);
  //  JvFormStorage1.WriteInteger('cxTreeWatch_Width', cxTreeWatch.Width);
    //lzSafeFreeAndNIL(fMinModal);

  fFormatter.Free;
  FBreakPoints.Free;
  TRY
{$IF DEFINED(NEXUSDB) OR DEFINED(USEDBISAM)}
    fTable.Active := False;
    lzSafeFreeAndNIL(fTable);
    IF Assigned(ItemScr) AND Assigned(ItemScr.fTableList) THEN BEGIN
      ItemScr.fTableList.Clear;
      ItemScr.fTableList := NIL;
    END;
    IF Assigned(dmWeb) AND Assigned(dmWeb.fItem.TableList) THEN BEGIN
      dmWeb.fItem.TableList.Clear;
      //dmWeb.fItem.TableList := NIL;
    END;
{$IFEND NEXUSDB USEDBISAM}
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

PROCEDURE TformScrEdit.FormShow(Sender: TObject);
BEGIN
  Self.Show;
  //  SetWindowPos(Handle, gOwner.Handle, 0, 0, 0, 0, SWP_NOMOVE OR SWP_NOSIZE OR SWP_SHOWWINDOW);
END;

PROCEDURE TformScrEdit.ParentShow(Sender: TObject);
BEGIN
  //  winShowTaskbarIcon(Self.Handle);
  Self.Show;
  //  SetWindowPos(Handle, gOwner.Handle, 0, 0, 0, 0, SWP_NOMOVE OR SWP_NOSIZE OR SWP_SHOWWINDOW);
END;

PROCEDURE TformScrEdit.CreateParams(VAR Params: TCreateParams);
BEGIN
  INHERITED;

  IF Assigned(Screen.ActiveForm) THEN
    Params.WndParent := Screen.ActiveForm.Handle;

  IF (Params.WndParent <> 0) AND (IsIconic(Params.WndParent)
    OR NOT IsWindowVisible(Params.WndParent)
    OR NOT IsWindowEnabled(Params.WndParent)) THEN
    Params.WndParent := 0;

  IF Params.WndParent = 0 THEN
    Params.WndParent := Application.Handle;
END;

PROCEDURE TformScrEdit.WMSysCommand(VAR Message: TWMSysCommand);
BEGIN
  IF Message.CmdType = SC_MINIMIZE THEN BEGIN
    ShowWindow(gOwner.Handle, SW_SHOWMINNOACTIVE);
    Hide;
    Visible := False;
  END;

  IF Message.CmdType = SC_MAXIMIZE THEN BEGIN
    ShowWindow(gOwner.Handle, SW_SHOWNA);
    Visible := True;
    Show;
  END;

  IF Message.CmdType = SC_RESTORE THEN BEGIN
    ShowWindow(gOwner.Handle, SW_SHOWNA);
    Visible := True;
    Show;
  END;

  INHERITED;
END;

PROCEDURE TformScrEdit.actExecute(Sender: TObject);
VAR
  lPoint            : TPoint;
  lList             : TStringList;
  i                 : Integer;
  lFrm              : TformFunctionTree;
  lStr              : STRING;
  lVal              : STRING;
  lShowVar          : STRING;
  lNode             : TcxTreeListNode;
  FUNCTION _StripCommentFromLine(pStr: STRING): STRING;
  VAR
    i               : Integer;
  BEGIN
    Result := '';
    i := 1;
    IF strTrimA(pStr) <> '' THEN BEGIN
      WHILE (pStr[i] = ' ') OR (pStr[i] = #9) DO BEGIN
        Result := Result + pStr[i];
        Inc(i);
      END;
      WHILE (i < Length(pStr) + 1) AND (pStr[i] = '/') AND (pStr[i + 1] = '/') DO BEGIN
        Inc(i);
        Inc(i);
      END;
      WHILE (i <= Length(pStr)) DO BEGIN
        Result := Result + pStr[i];
        Inc(i);
      END;
    END;
  END;
  PROCEDURE _RunInterpScript;
  VAR
    lFieldName      : STRING;
    lQuote          : STRING;
    i               : Integer;
  BEGIN
    fCalcul.VarObj.Clear;
    lQuote := fCalcul.QuoteChar;
{$IF DEFINED(NEXUSDB) OR DEFINED(USEDBISAM)}
    fCalcul.VarObj.SetValue('fShowVar', lQuote + ' ' + lQuote);
    fCalcul.VarObj.SetValue('fResult', lQuote + 'FALSE' + lQuote);
    fCalcul.VarObj.SetValue('fReadOnly', lQuote + 'FALSE' + lQuote);
    fCalcul.VarObj.SetValue('fHidden', lQuote + 'FALSE' + lQuote);
    fCalcul.VarObj.SetValue('fDefault', lQuote + 'FALSE' + lQuote);
    fCalcul.VarObj.SetValue('fGraphic', lQuote + 'Default' + lQuote);
    IF fBaseTable <> '' THEN BEGIN
      IF Assigned(fItemScr) THEN BEGIN
        CommonPopulateVariables(ItemScr.fTableList, fCalcul, False);
      END ELSE BEGIN
        fTable.Active := False;
        fTable.TableName := fBaseTable;
        fTable.IndexName := 'iIGUID';
        fTable.Active := True;
        fTable.Refresh;
        IF fTable.FindKey([CurGUID]) THEN BEGIN
          CommonPopulateVariables(TCommonTable(fTable), fCalcul, False);
        END;
      END;
      lFieldName := Copy(Caption, Pos('for ', Caption) + 4, 99);
      lFieldName := Copy(lFieldName, 1, LastDelimiter('_', lFieldName) - 1);
      IF fTable.FindField(lFieldName) <> NIL THEN BEGIN
        IF fTable.FieldByName(lFieldName).AsString = '' THEN
          fCalcul.VarObj.SetValue('fCurrent', lQuote + cNULLVal + lQuote)
        ELSE
          fCalcul.VarObj.SetValue('fCurrent', lQuote + fTable.FieldByName(lFieldName).AsString +
            lQuote);
      END;
      fTable.Active := False;
      CommonPopulateGarmentVariables(CurGUID, TCommonQuery(fQuery), fCalcul);
      dmWeb.SetBasicVariables(fCalcul);
{$IFEND NEXUSDB}
    END;
    fInterpreter.Prog := SyntaxMemoProduction.Lines.Text + cCRLF + 'END.';
    fInterpreter.Execute;
    IF fInterpreter.Error THEN BEGIN
      ShowConsoleMessage(Self, lpError, 'Compile Error', fInterpreter.ErrorText,
        fCalcul.Variables);
      SyntaxMemoProduction.SetSelection(fInterpreter.ErrorPos, 1);
    END ELSE BEGIN
      lStr := Copy(fCalcul.VarObj.GetValue('fShowVar'), 2, 999);
      lStr := Copy(lStr, 1, Length(lStr) - 1);
      lList := TStringList.Create;
      TRY
        i := 0;
        lVal := GetToken(lStr, ',', i);
        WHILE lVal <> '' DO BEGIN
          lShowVar := fCalcul.VarObj.GetValue(lVal);
          //          IF lShowVar = '' THEN
          //            lShowVar := GetTableVal(lVal);
          lList.Add(lVal + '=' + lShowVar);
          Inc(i);
          lVal := GetToken(lStr, ',', i);
        END;
        lList.Add('fIDRetailer = ' + fCalcul.VarObj.GetValue('fIDRetailer'));
        lList.Add('fIDRetailerOrder = ' + fCalcul.VarObj.GetValue('fIDRetailerOrder'));
        lList.Add('fIDRetailerEmployee = ' + fCalcul.VarObj.GetValue('fIDRetailerEmployee'));
        lList.Add('fIDRetailerEmployeeOrder = ' +
          fCalcul.VarObj.GetValue('fIDRetailerEmployeeOrder'));
        lList.Add('fDefault = ' + fCalcul.VarObj.GetValue('fDefault'));
        lList.Add('fResult = ' + fCalcul.VarObj.GetValue('fResult'));
        lList.Add('fReadOnly = ' + fCalcul.VarObj.GetValue('fReadOnly'));
        lList.Add('fHidden = ' + fCalcul.VarObj.GetValue('fHidden'));
        lList.Add('fGraphic = ' + fCalcul.VarObj.GetValue('fGraphic'));
        lList.Add('fCurrent = ' + fCalcul.VarObj.GetValue('fCurrent'));
        lList.Add('fIDCollectionOrder = ' + fCalcul.VarObj.GetValue('fIDCollectionOrder'));
        lList.Add('fIDWholesaler = ' + fCalcul.VarObj.GetValue('fIDWholesaler'));
        lList.Add('fIDWholesalerOrder = ' + fCalcul.VarObj.GetValue('fIDWholesalerOrder'));
        IF NOT chkPreserveLog.Checked THEN
          SyntaxMemoOutput.Lines.Clear;
        SyntaxMemoOutput.Lines.AddStrings(lList);
        ShowConsoleMessage(Self, lpInfo, 'Compiled OK', lList.Text, '');
      FINALLY
        lzSafeFreeAndNIL(lList);
      END;
    END;
  END;
BEGIN

  IF Sender = actResetSizes THEN BEGIN
    FontSize := 9;
    ZoomLevel := 100;
    PropsManager1.SaveProps;
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
    lVal := fCurrentMemo.SelText;
    IF InputQuery('Add Watch', 'Variable', lVal) THEN BEGIN
      lNode := cxTreeWatches.Add;
      lNode.Texts[0] := lVal;
      UpdateVariables(False);
    END;
  END;

  IF Sender = actDelWatch THEN BEGIN
    IF cxTreeWatches.FocusedNode <> NIL THEN
      cxTreeWatches.FocusedNode.Delete;
  END;

  IF Sender = actTemplatePopup THEN BEGIN
    SyntaxMemoProduction.ExecCommand(701);
  END;

  IF Sender = actClose THEN BEGIN
    fResult := mrOK;
    Close;
  END;

  IF Sender = actFunction THEN BEGIN
    lFrm := TformFunctionTree.Create(Self);
    lFrm.ShowClasses := True;
    lFrm.ShowFunctions := True;
    lFrm.ShowTypes := True;
    lFrm.ShowVariables := True;
    lFrm.FillTree;
    IF (lFrm.Showmodal = mrOK) AND (lFrm.cxTreeListFunc.FocusedNode <> NIL) THEN BEGIN
      fCurrentMemo.InsertText(lFrm.cxTreeListFunc.FocusedNode.Values[0]);
    END;
    lzSafeFreeAndNIL(lFrm);
  END;

  IF Sender = actProcList THEN BEGIN
    IF Assigned(fCurrentMemo) THEN BEGIN
      i := ListProcedures(Self, fCurrentMemo.Lines.Text);
      IF i >= 0 THEN BEGIN
        lPoint.Y := i;
        lPoint.X := 1;
        fCurrentMemo.BeginUpdate;
        TRY
          fCurrentMemo.CaretPos := lPoint;
          fCurrentMemo.ShowLine(i);
          fCurrentMemo.TopLine := i;
        FINALLY
          fCurrentMemo.EndUpdate;
        END;
        fCurrentMemo.Invalidate;
      END;
    END;
  END;

  IF Assigned(fCurrentMemo) THEN BEGIN
    IF Sender = actComment THEN BEGIN
      IF strTrimA(fCurrentMemo.SelText) <> '' THEN BEGIN
        lList := TStringList.Create;
        TRY
          lList.Text := fCurrentMemo.SelText;
          FOR i := 0 TO lList.Count - 1 DO BEGIN
            lList[i] := '//' + lList[i];
          END;
          fCurrentMemo.SelText := lList.Text;
        FINALLY
          lzSafeFreeAndNIL(lList);
        END;
      END ELSE BEGIN
        IF strTrimA(fCurrentMemo.Lines[fCurrentMemo.CaretPos.Y]) <> '' THEN
          fCurrentMemo.Lines[fCurrentMemo.CaretPos.Y] := '//' +
            fCurrentMemo.Lines[fCurrentMemo.CaretPos.Y];
      END;
    END;

    IF Sender = actUnComment THEN BEGIN
      IF fCurrentMemo.SelText <> '' THEN BEGIN
        lList := TStringList.Create;
        TRY
          lList.Text := fCurrentMemo.SelText;
          FOR i := 0 TO lList.Count - 1 DO BEGIN
            lList[i] := _StripCommentFromLine(lList[i]);
          END;
          fCurrentMemo.SelText := lList.Text;
        FINALLY
          lzSafeFreeAndNIL(lList);
        END;
      END ELSE BEGIN
        IF strTrimA(fCurrentMemo.Lines[fCurrentMemo.CaretPos.Y]) <> '' THEN
          fCurrentMemo.Lines[fCurrentMemo.CaretPos.Y] :=
            _StripCommentFromLine(fCurrentMemo.Lines[fCurrentMemo.CaretPos.Y]);
      END;
    END;
  END;

  IF Sender = actPrintSetup THEN BEGIN
    PrinterSetupDialog1.Execute;
  END;

  IF Sender = actReplace THEN BEGIN
    SyntReplaceDialog1.Execute;
  END;

  IF Sender = actFind THEN BEGIN
    SyntFindDialog1.Execute;
  END;

  IF Sender = actCompile THEN BEGIN
    IF (Lexer = 'Pascal script') AND (NOT fIsInterp) THEN BEGIN
      IF CompileScript THEN
        ShowConsoleMessage(Self, lpInfo, 'Script Compiled with No Errors', '', '');
    END ELSE IF (Lexer = 'Pascal Calc') AND (fIsInterp) THEN BEGIN
      _RunInterpScript;
    END ELSE IF (Lexer = 'C++') AND (fIsInterp) THEN BEGIN
      _RunInterpScript;
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
    IF (Lexer = 'Pascal Calc') AND (fIsInterp) THEN BEGIN
      IF Self.ActiveControl = fCurrentMemo THEN BEGIN
        lPoint := fCurrentMemo.CaretPos;
        fCurrentMemo.Lines.Text := ps_beautify(fCurrentMemo.Lines.Text);
        fCurrentMemo.CaretPos := lPoint;
        fCurrentMemo.Modified := True;
      END;
    END ELSE IF NOT fIsInterp THEN BEGIN
      lPoint := fCurrentMemo.CaretPos;
      IF Self.ActiveControl = fCurrentMemo THEN BEGIN
        fFormatter.ReformatEcMemo(fCurrentMemo, False);
        fCurrentMemo.Modified := True;
      END;
    END ELSE IF Lexer = 'Java script' THEN BEGIN
      IF Self.ActiveControl = fCurrentMemo THEN BEGIN
        lPoint := fCurrentMemo.CaretPos;
        fCurrentMemo.Lines.Text := js_beautify(fCurrentMemo.Lines.Text);
        fCurrentMemo.CaretPos := lPoint;
        fCurrentMemo.Modified := True;
      END;
    END;
  END;

  IF Sender = actEvalScript THEN BEGIN
    IF Lexer = 'Pascal script' THEN BEGIN
      IF Assigned(dmScript) THEN dmScript.Evaluate(fCurrentMemo.SelText);
    END;
  END;

  IF Sender = actStopScript THEN BEGIN
    fStopped := False;
    IF Assigned(dmScript) THEN dmScript.Terminate;
  END;

  IF Sender = actStepScript THEN BEGIN
    IF (Lexer = 'Pascal script') AND (NOT fIsInterp) THEN BEGIN
      fRunningFree := False;
      IF FRunning THEN BEGIN
        fStopped := False;
        Exit;
      END ELSE
        ExecuteScript(True);
    END;
  END;

  IF Sender = actTestScript THEN BEGIN
    IF (Lexer = 'Pascal script') AND (NOT fIsInterp) THEN BEGIN
      fRunningFree := True;
      IF NOT FRunning THEN
        ExecuteScript(False);
      fStopped := False;
    END ELSE IF (Lexer = 'Pascal Calc') AND (fIsInterp) THEN BEGIN
      _RunInterpScript;
    END ELSE IF (Lexer = 'C++') AND (fIsInterp) THEN BEGIN
      _RunInterpScript;
    END ELSE IF Lexer = 'PL/SQL' THEN BEGIN
{$IF DEFINED(NEXUSDB) OR DEFINED(USEDBISAM)}
      IF Assigned(fCurrentMemo) THEN BEGIN
        IF lzSafeOpenQuery(nxQueryTest, 'Select * from LAM_PIECES WHERE ' + fCurrentMemo.Lines.Text)
          THEN
          ShowConsoleMessage(Self, lpInfo, 'SQL OK', '', '')
        ELSE
          ShowConsoleMessage(Self, lpInfo, 'Error In SQL', gLastSQLError, '')
      END;
{$IFEND NEXUSDB}
    END ELSE IF Lexer = 'Java script' THEN BEGIN
      IF CompileScriptJS THEN
        ShowConsoleMessage(Self, lpInfo, 'Script Compiled with No Errors', '', '');
    END;
  END;

  IF Sender = actToggleBreak THEN BEGIN
    ToggleBreakpoint(fCurrentMemo.CaretPos.Y);
    fCurrentMemo.Invalidate;
  END;

  CheckButtons;
END;

PROCEDURE TformScrEdit.CheckButtons;
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
    ecPrintAction1.Enabled := True;
    ecPreviewAction1.Enabled := True;
    ecPageSetupAction1.Enabled := True;
    actPrintSetup.Enabled := True;
    actComment.Enabled := True;
    actUnComment.Enabled := True;
    actMatchDelim.Enabled := True;
    ecSyntPrinter1.SyntMemo := fCurrentMemo;
    actViewOutput.Enabled := True;
    actViewProduction.Enabled := True;
    actViewTest.Enabled := True;
  END ELSE BEGIN
    actReplace.Enabled := False;
    actFind.Enabled := False;
    ecPrintAction1.Enabled := False;
    ecPreviewAction1.Enabled := False;
    ecPageSetupAction1.Enabled := False;
    actPrintSetup.Enabled := False;
    actComment.Enabled := False;
    actUnComment.Enabled := False;
    actMatchDelim.Enabled := False;
    ecSyntPrinter1.SyntMemo := NIL;
    actViewOutput.Enabled := False;
    actViewProduction.Enabled := False;
    actViewTest.Enabled := False;
  END;

END;

PROCEDURE TformScrEdit.SetupMemos;
//VAR
//  i                 : Integer;
  PROCEDURE _AddGutters(pMemo: TSyntaxMemo);
  VAR
    lObj            : TGutterObject;
  BEGIN
    {Code Line}
    pMemo.Gutter.Objects.Clear;
    lObj := pMemo.Gutter.Objects.Add;
    lObj.Hint := 'Code Line';
    lObj.Line := -1;
    lObj.Margin := -1;
    lObj.ImageIndex := 0;
    lObj.OnCheckLine := CheckCodeLine;
    lObj.Band := 1;
    lObj.BgColor := clNone;
    lObj.ForeColor := clNone;
    lObj.SelInvertColors := False;

    {Run Line}
    lObj := pMemo.Gutter.Objects.Add;
    lObj.Hint := 'Current Run Line';
    lObj.Line := -1;
    lObj.Margin := -1;
    lObj.ImageIndex := 1;
    lObj.OnCheckLine := CheckRunLine;
    lObj.Band := 1;
    lObj.BgColor := clTeal;
    lObj.ForeColor := clWhite;
    lObj.SelInvertColors := True;

    {}
    lObj := pMemo.Gutter.Objects.Add;
    lObj.Hint := '';
    lObj.Line := -1;
    lObj.Margin := -1;
    lObj.ImageIndex := 2;
    lObj.OnCheckLine := NIL;
    lObj.Band := 1;
    lObj.BgColor := clRed;
    lObj.ForeColor := clWhite;
    lObj.SelInvertColors := True;

    {Error Line}
    lObj := pMemo.Gutter.Objects.Add;
    lObj.Hint := 'Error Line';
    lObj.Line := -1;
    lObj.Margin := -1;
    lObj.ImageIndex := 4;
    lObj.OnCheckLine := CheckErrorLine;
    lObj.Band := 1;
    lObj.BgColor := clSilver;
    lObj.ForeColor := clNone;
    lObj.SelInvertColors := False;

    {Break Line}
    lObj := pMemo.Gutter.Objects.Add;
    lObj.Line := -1;
    lObj.Margin := -1;
    lObj.ImageIndex := 3;
    lObj.OnCheckLine := CheckBreakLine;
    lObj.Band := 1;
    lObj.BgColor := clRed;
    lObj.ForeColor := clWhite;
    lObj.SelInvertColors := True;
    pMemo.IncSearchIgnoreCase := True;

  END;
BEGIN
  _AddGutters(SyntaxMemoProduction);
  SyntaxMemoOutput.Gutter.Objects.Clear;
  //  FOR i := 0 TO SyntAnalyzer1.Formats.Count - 1 DO BEGIN
  //    SyntAnalyzer1.Formats[i].Font.Size := SyntAnalyzer1.DefStyle.Font.Size;
  //  END;
END;

PROCEDURE TformScrEdit.SyntaxMemoProductionCaretPosChanged(Sender: TObject);
BEGIN
  IF Assigned(fRunningMemo) THEN BEGIN
    fLastPos := fRunningMemo.CaretPos;
    fLastPosX := fRunningMemo.ScrollPosY;
    fLastPosY := fRunningMemo.ScrollPosX;
  END;
  CheckButtons;
END;

PROCEDURE TformScrEdit.SyntaxMemoProductionChange(Sender: TObject);
BEGIN
  fErrorLine := -1;
  IF Assigned(fRunningMemo) THEN BEGIN
    fLastPos := fRunningMemo.CaretPos;
    fLastPosX := fRunningMemo.ScrollPosY;
    fLastPosY := fRunningMemo.ScrollPosX;
  END;
  CheckButtons;
END;

PROCEDURE TformScrEdit.SyntaxMemoProductionDblClick(Sender: TObject);
BEGIN
  CheckButtons;
END;

PROCEDURE TformScrEdit.SyntaxMemoProductionEnter(Sender: TObject);
BEGIN
  IF Sender IS TSyntaxMemo THEN BEGIN
    fCurrentMemo := TSyntaxMemo(Sender);
    SyntFindDialog1.Control := fCurrentMemo;
    actMatchDelim.SyntMemo := fCurrentMemo;
    HyperlinkHighlighter1.Editor := fCurrentMemo;
    TemplatePopup1.SyntMemo := fCurrentMemo;
    ecIncrementalSearch1.SyntMemo := fCurrentMemo;
    fCurrentMemo.WordWrap := False;
    IF Sender = SyntaxMemoOutput THEN BEGIN
      //
    END ELSE BEGIN
      SyntReplaceDialog1.Control := fCurrentMemo;
      SyntAutoReplace1.SyntMemo := fCurrentMemo;
      ParamCompletionFSScript.SyntMemo := NIL;
      AutoCompleteFSScript.SyntMemo := NIL;
      AutoCompleteCalc.SyntMemo := NIL;
      AutoCompleteSQL.SyntMemo := NIL;
      AutoCompleteJS.SyntMemo := NIL;
      IF (Lexer = 'Pascal script') AND (NOT fIsInterp) THEN BEGIN
        ParamCompletionFSScript.SyntMemo := fCurrentMemo;
        AutoCompleteFSScript.SyntMemo := fCurrentMemo;
      END ELSE IF (Lexer = 'Pascal Calc') AND (fIsInterp) THEN BEGIN
        ParamCompletionCalc.SyntMemo := fCurrentMemo;
        AutoCompleteCalc.SyntMemo := fCurrentMemo
      END ELSE IF (Lexer = 'C++') AND (fIsInterp) THEN BEGIN
        ParamCompletionCalc.SyntMemo := fCurrentMemo;
        AutoCompleteCalc.SyntMemo := fCurrentMemo
      END ELSE IF Lexer = 'PL/SQL' THEN BEGIN
        ParamCompletionSQL.SyntMemo := fCurrentMemo;
        AutoCompleteSQL.SyntMemo := fCurrentMemo
      END ELSE IF Lexer = 'Java script' THEN BEGIN
        ParamCompletionJS.SyntMemo := fCurrentMemo;
        AutoCompleteJS.SyntMemo := fCurrentMemo;
      END;
    END;
  END;
  CheckButtons;

END;

PROCEDURE TformScrEdit.SyntaxMemoProductionGutterClick(Sender: TObject; Line: Integer; Buton:
  TMouseButton; Shift: TShiftState; XY: TPoint);
BEGIN
  ToggleBreakpoint(Line);
END;

PROCEDURE TformScrEdit.SyntaxMemoProductionIncSearchChange(Sender: TObject; State: TIncSearchState);
BEGIN
  IF Assigned(fCurrentMemo) THEN BEGIN
    CASE State OF
      isStop: dxRibbonStatusBar1.Panels[0].Text := '';
      isStart: dxRibbonStatusBar1.Panels[0].Text := 'Searching for: ';
      isStrChange: BEGIN
          SyntFindDialog1.FindText := fCurrentMemo.IncSearchStr;
          dxRibbonStatusBar1.Panels[0].Text := 'Searching for: ' +
            fCurrentMemo.IncSearchStr;
        END;
    END;
  END;
END;

PROCEDURE TformScrEdit.ToggleBreakpoint(Line: Integer);
BEGIN
  IF IsBreakPt(Line) THEN
    FBreakPoints.Remove(TObject(Line))
  ELSE
    FBreakPoints.Add(TObject(Line));
  fCurrentMemo.Invalidate;
END;

FUNCTION TformScrEdit.IsBreakPt(Line: Integer): Boolean;
BEGIN
  Result := FBreakPoints.IndexOf(Pointer(Line)) <> -1;
END;

FUNCTION TformScrEdit.IsCodeLine(Line: Integer): Boolean;
BEGIN
  Result := False;
  IF Assigned(dmScript) THEN
    Result := dmScript.IsExecutableLine(Line + 1);
END;

PROCEDURE TformScrEdit.CheckRunLine(Sender: TObject; Line: Integer; VAR Show: Boolean);
BEGIN
  Show := (FCurrentLine = Line);
END;

PROCEDURE TformScrEdit.CheckBreakLine(Sender: TObject; Line: Integer; VAR Show: Boolean);
BEGIN
  Show := IsBreakPt(Line);
END;

PROCEDURE TformScrEdit.CheckCodeLine(Sender: TObject; Line: Integer; VAR Show: Boolean);
BEGIN
  Show := IsCodeLine(Line);
END;

PROCEDURE TformScrEdit.CheckErrorLine(Sender: TObject; Line: Integer; VAR Show: Boolean);
BEGIN
  Show := fErrorLine = Line;
END;

PROCEDURE TformScrEdit.AutoCompleteFSScriptGetAutoCompleteList(Sender: TObject; aPos: TPoint; List,
  Display: TecStrings);
VAR
  lLine             : STRING;
  lStr              : STRING;
  i                 : Integer;
  j                 : Integer;
  lObj              : STRING;
  lMem              : STRING;
  lClass            : TfsClassVariable;
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
  FUNCTION GetClass(pClass: TfsClassVariable; pName: STRING): TfsClassVariable;
  VAR
    i               : Integer;
  BEGIN
    Result := NIL;
    i := 0;
    WHILE (i < pClass.MembersCount) AND (Result = NIL) DO BEGIN
      IF CompareText(pClass.Members[i].Name, pName) = 0 THEN
        Result := fsGlobalUnit.FindClass(pClass.Members[i].TypeName);
      Inc(i);
    END;
  END;
  PROCEDURE AddListItem(pObj: TObject);
  VAR
    j               : Integer;
    k               : Integer;
    lOK             : Boolean;
    lSynt           : STRING;
  BEGIN
    lOK := False;
    IF Assigned(pObj) THEN BEGIN
      IF pObj IS TfsCustomVariable THEN BEGIN
        lStr := '';
        IF (pObj IS TfsPropertyHelper) OR (pObj IS TfsEventHelper) THEN BEGIN
          lStr := '\i0\\s2\property \t\\s1\' + TfsPropertyHelper(pObj).Name + '\s0\: ' +
            GetType(TfsCustomHelper(pObj));
          lOK := True;
        END ELSE IF pObj IS TfsMethodHelper THEN BEGIN
          lSynt := TfsMethodHelper(pObj).Syntax;
          j := Pos(' ', lSynt);
          k := 99;
          IF (TfsMethodHelper(pObj).NeedResult) AND {(TfsMethodHelper(pObj).Typ = fvtClass) AND}
            (TfsMethodHelper(pObj).TypeName <> '') THEN BEGIN
            lStr := '\i0\\s2\function \t\\s1\' + Copy(lSynt, j, k);
            lOK := True;
          END ELSE IF TfsMethodHelper(pObj).Typ = fvtConstructor THEN BEGIN
            lStr := 'constructor \t\\s1\' + Copy(lSynt, j, k);
            lOK := True;
          END ELSE BEGIN
            lStr := '\i1\\s3\procedure \t\\s1\' + Copy(lSynt, j, k);
            lOK := True;
          END;
        END ELSE IF pObj IS TfsVariable THEN BEGIN
          lStr := '\i0\\s2\var \t\\s1\' + TfsCustomVariable(pObj).Name + '\s0\: ' +
            GetType(TfsCustomHelper(pObj));
          lOK := True;
        END {ELSE
          ShowMessage('Unknown Variable:' + pObj.ClassName)};
        IF lOK THEN BEGIN
          lStr := FastReplace(lStr, '(', '\s0\ (');
          IF List.IndexOf(TfsCustomVariable(pObj).Name) < 0 THEN BEGIN
            List.Add(TfsCustomVariable(pObj).Name);
            Display.Add(lStr);
          END;
        END;
      END { ELSE
        ShowMessage('Unknown Class:' + pObj.ClassName)};
    END;
  END;
BEGIN
  IF Assigned(fCurrentMemo) THEN BEGIN
    lLine := fCurrentMemo.Lines[pPos.Y];
    i := pPos.X - 1;
    IF lLine <> '' THEN BEGIN
      WHILE (i > 0) AND (lLine[i] IN ['A'..'Z', 'a'..'z', '0'..'9', '.']) DO BEGIN
        Dec(i);
      END;
      lLine := Copy(lLine, i + 1, pPos.X);
      lObj := strTrimA(Copy(lLine, 1, pPos.X - i));
    END;
    IF FastPos(lObj, '.', Length(lObj), 1, 1) > 0 THEN
      lStr := Copy(lObj, 1, FastPos(lObj, '.', Length(lObj), 1, 1) - 1)
    ELSE
      lStr := lObj;
    lClass := fsGlobalUnit.FindClass(LookupVarType(lStr));
    List.Clear;
    Display.Clear;
    IF Assigned(lClass) THEN BEGIN
      WHILE lClass <> NIL DO BEGIN
        IF FastPos(lObj, '.', Length(lObj), 1, 1) > 0 THEN BEGIN
          i := 1;
          lMem := GetToken(lObj, '.', i);
          WHILE (lMem <> '') AND Assigned(lClass) DO BEGIN
            lClass := GetClass(lClass, lMem);
            Inc(i);
            lMem := GetToken(lObj, '.', i);
          END;
          IF Assigned(lClass) THEN BEGIN
            FOR j := 0 TO lClass.MembersCount - 1 DO
              AddListItem(lClass.Members[j]);
          END;
        END ELSE BEGIN
          FOR i := 0 TO lClass.MembersCount - 1 DO
            AddListItem(lClass.Members[i]);
        END;
        IF Assigned(lClass) THEN
          lClass := fsGlobalUnit.FindClass(lClass.Ancestor);
      END;
    END ELSE BEGIN
      FOR i := 0 TO fsGlobalUnit.Count - 1 DO
        AddListItem(fsGlobalUnit.Items[i]);
    END;
  END;
END;

PROCEDURE TformScrEdit.ParamCompletionFSScriptGetParams(Sender: TObject; CONST FuncName: ecString;
  pPos: Integer);
VAR
  lStr              : STRING;
  i                 : Integer;
  lClass            : TfsClassVariable;
  lVar              : TfsCustomVariable;
BEGIN
  TRY
    ParamCompletionFSScript.Items.Clear;
    IF Assigned(fCurrentMemo) AND Assigned(dmScript) THEN BEGIN
      lVar := dmScript.fsScript.Find(FuncName);
      IF Assigned(lVar) THEN BEGIN
        FOR i := 0 TO lVar.GetNumberOfRequiredParams - 1 DO
          ParamCompletionFSScript.Items.Add(lVar.Params[i].Name + ':' +
            lVar.Params[i].GetFullTypeName);
      END ELSE BEGIN
        lStr := fCurrentMemo.Lines[fCurrentMemo.CaretPos.Y];
        lStr := Copy(lStr, 1, Pos(FuncName, lStr) - 2);
        i := Length(lStr);
        WHILE (i > 0) AND (lStr[i] IN ['A'..'Z', 'a'..'z', '0'..'9', '.']) DO
          Dec(i);
        lStr := Copy(lStr, i + 1, Length(lStr));
        lClass := fsGlobalUnit.FindClass(LookupVarType(lStr));
        IF Assigned(lClass) THEN BEGIN
          lVar := lClass.Find(FuncName);
          IF Assigned(lVar) THEN BEGIN
            FOR i := 0 TO lVar.GetNumberOfRequiredParams - 1 DO
              ParamCompletionFSScript.Items.Add(lVar.Params[i].Name + ':' +
                lVar.Params[i].GetFullTypeName);
          END;
        END;
      END;
    END;
  EXCEPT
  END;
END;

FUNCTION TformScrEdit.LookupVarType(pVar: STRING): STRING;
VAR
  lLen              : Integer;
  i                 : Integer;
  lStr              : STRING;
BEGIN
  lLen := Length(pVar);
  IF Assigned(fCurrentMemo) THEN BEGIN
    i := 0;
    Result := '';
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

FUNCTION TformScrEdit.CompileScript: Boolean;
VAR
{$IFDEF SITEM}
  lStr              : STRING;
{$ENDIF SITEM}
  P                 : TPoint;
BEGIN
  Result := False;
  fCurrentMemo.Invalidate;
  IF Assigned(dmScript) THEN BEGIN
{$IFDEF SITEM}
    lStr := strLower(dmScript.ScriptText);
    IF Pos('.end', lStr) = 0 THEN BEGIN
      dmScript.ScriptText := dmScript.ScriptText + cCRLF + 'BEGIN';
      IF Pos('onsuccess(', lStr) <> 0 THEN
        dmScript.ScriptText := dmScript.ScriptText + cCRLF + 'OnSuccess(1000);';
      IF Pos('onfailure(', lStr) <> 0 THEN
        dmScript.ScriptText := dmScript.ScriptText + cCRLF + 'OnFailure(''Failure Message'');';
      dmScript.ScriptText := dmScript.ScriptText + cCRLF + 'END.' + cCRLF;
    END;
{$ENDIF SITEM}
    dmScript.ScriptText := fCurrentMemo.Lines.Text;
    fSourceList.Values[cSource] := Str2Hex(fCurrentMemo.Lines.Text);
{$IF DEFINED(NEXUSDB) OR DEFINED(USEDBISAM)}
    IF Assigned(dmWeb) THEN BEGIN
      dmWeb.OrderGUID := CurGUID;
      dmWeb.fItem.SelectedGUIDs := dmWeb.SelectedGUIDs;
      //    dmWeb.fItem.OnLogOutput := LogEvent;
      dmWeb.fItem.Refresh;
    END;
    IF Assigned(ItemScr) THEN BEGIN
      ItemScr.OnLogOutput := LogEvent;
    END;
{$IFEND NEXUSDB}

{$IFDEF SITEM}
    dmMonitor.OnLogMemo := LogEvent;
{$ENDIF SITEM}
    dmScript.OnGetUnit := fsScriptGetUnit;
    TRY
      dmScript.SyntaxType := 'PascalScript';
      IF dmScript.CompileScript THEN BEGIN
        fErrorLine := -1;
        Result := True;
      END ELSE BEGIN
        P := fsPosToPoint(dmScript.ErrorPos);
        P.Y := P.Y - 1;
        P.X := P.X - 1;
        fCurrentMemo.CaretPos := P;
        fErrorLine := P.Y;
        ShowConsoleMessage(Self, lpInfo, 'Error Compiling Script', dmScript.ErrorMsg + ' ' +
          dmScript.ErrorPos, '');
        fCurrentMemo.Invalidate;
        Result := False;
      END;
    FINALLY
      dmScript.OnGetUnit := NIL;
    END;
  END;
END;

FUNCTION TformScrEdit.CompileScriptJS: Boolean;
VAR
  lErrorMsg         : STRING;
  lErrorPos         : STRING;
  P                 : TPoint;
  lList             : TStringList;

{$IFDEF DUCKCHECK}
  ok                : Boolean;
  dukt              : TDUktape;
  LineNo            : Integer;
  LineStr           : STRING;
{$ENDIF DUCKCHECK}

BEGIN
  //  Result := False;
  fCurrentMemo.Invalidate;
  lList := TStringList.Create;
  TRY
    lList.Text := dmWeb.GetLookupValues('LINKSJSVARS');
    Result := jsSyntaxCheck(fCurrentMemo.Lines.Text, lList, lErrorMsg, lErrorPos);
    IF NOT Result THEN BEGIN
      ShowConsoleMessage(Self, lpInfo, 'Error Compiling Script', lErrorMsg + ' ' + lErrorPos, '');
      P := fsPosToPoint(lErrorPos);
      P.Y := P.Y - 1;
      P.X := P.X - 1;
      fCurrentMemo.CaretPos := P;
      fErrorLine := P.Y;
      fCurrentMemo.Invalidate;
      Result := False;
    END
{$IFDEF DUCKCHECK}
    ELSE BEGIN
      dukt := TDUktape.Create;
      TRY
        ok := dukt.EvalJSRaw(fCurrentMemo.Lines.Text, lErrorMsg);
        IF NOT ok THEN BEGIN
          ShowConsoleMessage(Self, lpInfo, 'Error Compiling Script', lErrorMsg, '');
          LineNo := Pos('(line ', lErrorMsg);
          LineStr := Copy(lErrorMsg, LineNo + 5, Length(lErrorMsg));
          LineNo := StrToIntDef(GetToken(LineStr, ')', 0), 0);
          P.Y := LineNo;
          P.X := 0;
          fCurrentMemo.CaretPos := P;
          fErrorLine := P.Y;
          fCurrentMemo.Invalidate;
          Result := False;
        END;
      FINALLY
        dukt.Free;
      END;
    END;
{$ELSE DUCKCHECK}
      ;
{$ENDIF DUCKCHECK}
    fCurrentMemo.Invalidate;
  FINALLY
    lzSafeFreeAndNIL(lList);
  END;
END;

PROCEDURE TformScrEdit.ExecuteScript(pDebug: Boolean);
VAR
  P                 : TPoint;
  lScrTemp          : STRING;
{$IFDEF SITEM}
  lStr              : STRING;
{$ENDIF SITEM}
  lFields           : TEtchList;
  lINI              : TINIFile;
  fTableAliases     : TStringList;
BEGIN
  fRunningMemo := fCurrentMemo;
  IF NOT chkPreserveLog.Checked THEN
    SyntaxMemoOutput.Lines.Clear;
  dmScript.ScriptText := fCurrentMemo.Lines.Text;
  fSourceList.Values[cSource] := Str2Hex(fCurrentMemo.Lines.Text);
{$IFDEF SITEM}
  lStr := strLower(dmScript.ScriptText);
  IF Pos('.end', lStr) = 0 THEN BEGIN
    dmScript.ScriptText := dmScript.ScriptText + cCRLF + 'BEGIN';
    IF Pos('onsuccess(', lStr) <> 0 THEN
      dmScript.ScriptText := dmScript.ScriptText + cCRLF + 'OnSuccess(1000);';
    IF Pos('onfailure(', lStr) <> 0 THEN
      dmScript.ScriptText := dmScript.ScriptText + cCRLF + 'OnFailure(''Failure Message'');';
    dmScript.ScriptText := dmScript.ScriptText + cCRLF + 'END.' + cCRLF;
  END;
  fCurrentMemo.Lines.Text := dmScript.ScriptText;
{$ENDIF SITEM}
{$IF DEFINED(NEXUSDB) OR DEFINED(USEDBISAM)}
  IF Assigned(dmWeb) THEN BEGIN
    dmWeb.OrderGUID := CurGUID;
    dmWeb.fItem.SelectedGUIDs := dmWeb.SelectedGUIDs;
    //    dmWeb.fItem.OnLogOutput := LogEvent;
    dmWeb.fItem.Refresh;
  END;
  IF Assigned(ItemScr) THEN BEGIN
    ItemScr.OnLogOutput := LogEvent;
  END;
{$IFEND NEXUSDB}

{$IFDEF SITEM}
  dmMonitor.OnLogMemo := LogEvent;
{$ENDIF SITEM}

  IF Assigned(dmScript) THEN BEGIN
    dmScript.SyntaxType := 'PascalScript';
    dmScript.OnGetUnit := fsScriptGetUnit;
    lINI := TINIFile.Create(ChangeFileExt(ParamStr(0), '.ini'));
    fTableAliases := TStringList.Create;
    lFields := TEtchList.Create;
    TRY
      lINI.ReadSectionValues('TableAliases', fTableAliases);
      IF fTableAliases.Count = 0 THEN BEGIN
        fTableAliases.Add('LAM_S2=LAM_SHIRTII');
        fTableAliases.Add('LAM_SII=LAM_SHIRTII');
      END;
      lFields.TableAliases.Assign(fTableAliases);
      IF dmScript.CompileScript THEN BEGIN
        fErrorLine := -1;
        fRunningMemo.Invalidate;
        lScrTemp := '';
        IF NOT VarIsNull(dmScript.fsScript.Variables['GraphName']) THEN
          dmScript.fsScript.Variables['GraphName'] := '';
        IF NOT VarIsNull(dmScript.fsScript.Variables['ShouldRunMulti']) THEN
          dmScript.fsScript.Variables['ShouldRunMulti'] := False;
        IF NOT VarIsNull(dmScript.fsScript.Variables['RunMulti']) THEN
          dmScript.fsScript.Variables['RunMulti'] := False;
        IF NOT VarIsNull(dmScript.fsScript.Variables['ScrTemp']) THEN
          dmScript.fsScript.Variables['ScrTemp'] := lScrTemp;
        IF NOT VarIsNull(dmScript.fsScript.Variables['fValidated']) THEN
          dmScript.fsScript.Variables['fValidated'] := False;
{$IF DEFINED(NEXUSDB) OR DEFINED(USEDBISAM)}
        IF NOT VarIsNull(dmScript.fsScript.Variables['CurItem']) AND Assigned(dmWeb) THEN
          dmScript.fsScript.Variables['CurItem'] := Integer(dmWeb.fItem);
        IF NOT VarIsNull(dmScript.fsScript.Variables['CurItem']) AND Assigned(ItemScr) THEN
          dmScript.fsScript.Variables['CurItem'] := Integer(ItemScr);
        IF NOT VarIsNull(dmScript.fsScript.Variables['dmConn']) THEN
          dmScript.fsScript.Variables['dmConn'] := Integer(dmConn);
        IF NOT VarIsNull(dmScript.fsScript.Variables['fDatabase']) THEN
          dmScript.fsScript.Variables['fDatabase'] := Integer(dmConn.Database);
        IF NOT VarIsNull(dmScript.fsScript.Variables['EtchFieldList']) THEN BEGIN
          lFields.SetJSONFields(dmWeb.ItemsDataSet.FieldByName('WDATA').AsString);
          dmScript.fsScript.Variables['EtchFieldList'] := Integer(lFields);
        END;
{$IFEND NEXUSDB}

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
          FCurrentLine := -1;
          fRunningMemo.ShowLine(-1);
          fRunningMemo.CaretPos := fLastPos;
          fRunningMemo.ScrollPosY := fLastPosX;
          fRunningMemo.ScrollPosX := fLastPosY;
          fRunningMemo.Invalidate;
          FRunning := False;
          fRunningMemo := NIL;
          cxTreeWatch.Clear;
          dmScript.OnRunLine := NIL;
          dmScript.OnGetUnit := NIL;
        END;
      END ELSE IF Assigned(dmScript) THEN BEGIN
        P := fsPosToPoint(dmScript.ErrorPos);
        P.Y := P.Y - 1;
        P.X := P.X - 1;
        fErrorLine := P.Y;
        fRunningMemo.CaretPos := P;
        fRunningMemo.Invalidate;
        ShowConsoleMessage(Self, lpInfo, 'Error Compiling Script', dmScript.ErrorMsg + ' ' +
          dmScript.ErrorPos, '');
      END;
    FINALLY
      lzSafeFreeAndNIL(lINI);
      lzSafeFreeAndNIL(fTableAliases);
      lzSafeFreeAndNIL(lFields);
    END;
  END;
END;

PROCEDURE TformScrEdit.SetCurGUID(CONST Value: STRING);
BEGIN
  IF fCurGUID <> Value THEN BEGIN
    fCurGUID := Value;
{$IF DEFINED(NEXUSDB) OR DEFINED(USEDBISAM)}
    IF Assigned(ItemScr) THEN
      LoadTables(dmConn.Database, ItemScr.fTableList, Value);
    IF Assigned(dmWeb) THEN BEGIN
      IF Assigned(dmWeb.fItem) THEN BEGIN
        LoadTables(dmWeb.dmCtl.dmConn.Database, dmWeb.fItem.TableList, Value);
      END;
      dmWeb.fItem.iGUID := Value;
      dmWeb.IDRetailerOrder := StrToIntDef(Copy(dmWeb.fItem.OrderID, 1, 4), 0);
      dmWeb.IDCollectionOrder := dmWeb.fItem.IDCollectionOrder;
    END;
{$IFEND NEXUSDB}
  END;
END;

PROCEDURE TformScrEdit.LogEvent(CONST pLevel: Integer; CONST pString: STRING);
BEGIN
  SyntaxMemoOutput.Lines.Add(pString);
END;

FUNCTION TformScrEdit.GetScriptText: STRING;
BEGIN
  Result := SyntaxMemoProduction.Lines.Text;
END;

PROCEDURE TformScrEdit.SetScriptText(CONST Value: STRING);
BEGIN
  fSourceList.Values[cSource] := Str2Hex(Value);
  SyntaxMemoProduction.Lines.Text := Value;
END;

PROCEDURE TformScrEdit.SetLexer(CONST Value: STRING);
BEGIN
  IF fLexer <> Value THEN BEGIN
    fLexer := Value;
    SyntaxMemoProduction.SyntaxAnalyzer := dmRes.SyntaxManager1.FindAnalyzer(Value);
    TemplatePopup1.SyntMemo := SyntaxMemoProduction;
  END;
END;

PROCEDURE TformScrEdit.AutoCompleteFSScriptBeforeComplete(Sender: TObject;
  VAR Item: ecString);
VAR
  fsVar             : TfsCustomVariable;
  j                 : Integer;
  k                 : Integer;
  lSynt             : STRING;
BEGIN
  fsVar := fsGlobalUnit.Find(Item);
  IF fsVar IS TfsMethodHelper THEN BEGIN
    lSynt := TfsMethodHelper(fsVar).Syntax;
    j := Pos(' ', lSynt) + 1;
    k := Pos('(', lSynt);
    IF k > 0 THEN
      Item := Copy(lSynt, j, k - j) + '('
    ELSE BEGIN
      k := Pos(':', lSynt);
      Item := Copy(lSynt, j, k - j) + ' ';
    END;
  END;
END;

PROCEDURE TformScrEdit.AutoCompleteFSScriptAfterComplete(Sender: TObject;
  CONST Item: ecString);
BEGIN
  ParamCompletionFSScript.Execute;
END;

PROCEDURE TformScrEdit.FormCloseQuery(Sender: TObject; VAR CanClose: Boolean);
BEGIN
  IF Assigned(fCurrentMemo) THEN BEGIN
    IF fCurrentMemo.Modified THEN BEGIN
      IF NOT (fResult = mrOK) THEN BEGIN
        CASE QueryTaskDlg(Self, 'Save Changes',
          'The script has changed, would you like to save the changes?', [cbYes, cbNo, cbCancel]) OF
          mrYes: fResult := mrOK;
          mrNo: fResult := mrCancel;
        ELSE
          CanClose := False;
        END;
      END;
    END ELSE
      CanClose := True;
  END ELSE
    CanClose := True;
END;

{$IFDEF NEXUSDB}

PROCEDURE TformScrEdit.SetdmWeb(CONST Value: TDataModuleCliUtil);
BEGIN
  fdmWeb := Value;
  IF Assigned(fdmWeb) THEN BEGIN
    //fdmWeb.fItem.OnLogOutput := LogEvent;
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
{$ENDIF NEXUSDB}

{$IFDEF USEDBISAM}

PROCEDURE TformScrEdit.SetdmWeb(CONST Value: TDataModuleCliUtil);
BEGIN
  fdmWeb := Value;
  IF Assigned(fdmWeb) THEN BEGIN
    //fdmWeb.fItem.OnLogOutput := LogEvent;
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
{$ENDIF USEDBISAM}

FUNCTION TformScrEdit.FindVar(pName: STRING; pProc: TfsScript): Boolean;
VAR
  i                 : Integer;
  //  j                 : Integer;
  lVar              : TfsCustomVariable;
BEGIN
  Result := False;
  i := 0;
  WHILE (Result = False) AND (i < pProc.Count) DO BEGIN
    lVar := pProc.Items[i];
    IF (lVar IS TfsVariable) OR
      (lVar IS TfsParamItem) THEN BEGIN
      IF CompareText(lVar.Name, pName) = 0 THEN
        Result := True;
    END ELSE IF (lVar IS TfsProcVariable) THEN BEGIN
      Result := FindVar(pName, TfsProcVariable(lVar).Prog)
    END;
    Inc(i);
  END;
END;

PROCEDURE TformScrEdit.UpdateVariables(pJustAdd: Boolean = False);
VAR
  i                 : Integer;
  lNode             : TcxTreeListNode;
  PROCEDURE _SetImage(pNode: TcxTreeListNode; pVar: TfsCustomVariable; pActive, pSub: Boolean);
  BEGIN
    IF Assigned(pNode) THEN BEGIN
      IF pVar IS TfsProcVariable THEN BEGIN
        pNode.ImageIndex := iifInt(pActive, 7, 6);
      END ELSE IF pVar IS TfsVariable THEN BEGIN
        IF pSub THEN
          pNode.ImageIndex := iifInt(pActive, 7, 6)
        ELSE
          pNode.ImageIndex := iifInt(pActive, 5, 4);
      END ELSE IF pVar IS TfsParamItem THEN BEGIN
        pNode.ImageIndex := iifInt(pActive, 3, 2);
      END ELSE BEGIN
        pNode.ImageIndex := iifInt(pActive, 1, 0);
      END;
      pNode.SelectedIndex := pNode.ImageIndex;
    END;
  END;
  FUNCTION _GetValue(pVar: TfsCustomVariable): STRING;
  VAR
    i               : Integer;
  BEGIN
    CASE pVar.Typ OF
      fvtInt: BEGIN
          Result := VarToStr(pVar.Value);
        END;
      fvtBool: BEGIN
          Result := VarToStr(pVar.Value);
        END;
      fvtFloat: BEGIN
          Result := VarToStr(pVar.Value);
        END;
      fvtChar: BEGIN
          Result := VarToStr(pVar.Value);
        END;
      fvtString: BEGIN
          Result := VarToStr(pVar.Value);
        END;
      fvtArray: BEGIN
          Result := '';
          FOR i := VarArrayLowBound(pVar.Value, 1) TO VarArrayDimCount(pVar.Value) - 1 DO BEGIN
            Result := Result + VarToStr(VarArrayGet(pVar.Value, [i])) + ',';
          END;
          Result := Copy(Result, 1, Length(Result) - 1);
        END;
      fvtVariant: BEGIN
          Result := VarToStr(pVar.Value);
        END;
      fvtInt64: BEGIN
          Result := VarToStr(pVar.Value);
        END;
    END;
  END;
  PROCEDURE _AddVar(pPFX: STRING; pVar: TfsCustomVariable);
  VAR
    cNode           : TcxTreeListNode;
  BEGIN
    IF (pVar.Typ IN [fvtInt, fvtBool, fvtFloat, fvtChar, fvtString, fvtArray, fvtVariant,
        fvtInt64])
      AND pVar.NeedResult AND
      (NOT pVar.IsReadOnly) THEN BEGIN
      IF pPFX <> '' THEN BEGIN
        lNode := cxTreeWatch.TopNode;
        WHILE lNode <> NIL DO BEGIN
          IF lNode.Texts[0] = Copy(pPFX, 2, 999) THEN BEGIN
            cNode := lNode.GetFirstChild;
            WHILE cNode <> NIL DO BEGIN
              IF cNode.Texts[0] = pVar.Name THEN BEGIN
                IF cNode.Texts[1] <> VarToStr(pVar.Value) THEN BEGIN
                  cNode.MakeVisible;
                  //                  cNode.ImageIndex := 2;
                  //                  cNode.SelectedIndex := 2;
                END ELSE BEGIN
                  //                  cNode.ImageIndex := 1;
                  //                  cNode.SelectedIndex := 1;
                END;
                _SetImage(cNode, pVar, cNode.Texts[1] <> VarToStr(pVar.Value), pPFX <> '');
                cNode.Texts[1] := _GetValue(pVar);
                Break;
              END;
              cNode := cNode.GetNextSibling;
            END;
            IF cNode = NIL THEN BEGIN
              cNode := lNode.AddChild;
              cNode.Texts[0] := pVar.Name;
              cNode.Values[1] := _GetValue(pVar);
              cNode.Texts[2] := pPFX + pVar.Name;
              //              cNode.ImageIndex := 1;
              //              cNode.SelectedIndex := 1;
              _SetImage(cNode, pVar, False, pPFX <> '');
              IF pJustAdd THEN
                lNode.Expand(True);
            END;
            Break;
          END;
          lNode := lNode.GetNext;
        END;
        IF lNode = NIL THEN BEGIN
          lNode := cxTreeWatch.Add;
          lNode.Texts[0] := Copy(pPFX, 2, 999);
          //          lNode.ImageIndex := 0;
          //          lNode.SelectedIndex := 0;
          lNode := lNode.AddChild;
          lNode.Texts[0] := pVar.Name;
          lNode.Values[1] := _GetValue(pVar);
          lNode.Texts[2] := pPFX + pVar.Name;
          //          lNode.ImageIndex := 1;
          //          lNode.SelectedIndex := 1;
          _SetImage(lNode, pVar, False, pPFX <> '');
          IF pJustAdd THEN
            lNode.Expand(True);
        END;
      END ELSE BEGIN
        lNode := cxTreeWatch.TopNode;
        WHILE lNode <> NIL DO BEGIN
          IF lNode.Texts[0] = pVar.Name THEN BEGIN
            IF lNode.Texts[1] <> _GetValue(pVar) THEN BEGIN
              lNode.MakeVisible;
              //              lNode.ImageIndex := 2;
              //              lNode.SelectedIndex := 2;
            END ELSE BEGIN
              //              lNode.ImageIndex := 1;
              //              lNode.SelectedIndex := 1;
            END;
            _SetImage(lNode, pVar, lNode.Texts[1] <> _GetValue(pVar), pPFX <> '');
            lNode.Values[1] := _GetValue(pVar);
            Break;
          END;
          lNode := lNode.GetNext;
        END;
        IF lNode = NIL THEN BEGIN
          lNode := cxTreeWatch.Add;
          lNode.Texts[0] := pVar.Name;
          lNode.Values[1] := _GetValue(pVar);
          lNode.Texts[2] := pVar.Name;
          //          lNode.ImageIndex := 1;
          //          lNode.SelectedIndex := 1;
          _SetImage(lNode, pVar, False, pPFX <> '');
        END;
      END;
    END;
  END;

  PROCEDURE _AddProc(pPFX: STRING; pProc: TfsCustomVariable);
  VAR
    i               : Integer;
  BEGIN
    IF pProc IS TfsProcVariable THEN BEGIN
      FOR i := 0 TO TfsProcVariable(pProc).Prog.Count - 1 DO BEGIN
        TRY
          IF TfsProcVariable(pProc).Prog.Items[i] IS TfsVariable THEN BEGIN
            _AddVar(pPFX + '.' + TfsProcVariable(pProc).Name,
              TfsVariable(TfsProcVariable(pProc).Prog.Items[i]));
          END ELSE IF TfsProcVariable(pProc).Prog.Items[i] IS TfsParamItem THEN BEGIN
            _AddVar(pPFX + '.' + TfsProcVariable(pProc).Name,
              TfsVariable(TfsProcVariable(pProc).Prog.Items[i]));
          END ELSE IF TfsProcVariable(pProc).Prog.Items[i] IS TfsProcVariable THEN BEGIN
            _AddProc(pPFX, TfsProcVariable(TfsProcVariable(pProc).Prog.Items[i]));
          END;
        EXCEPT
        END;
      END;
    END;
  END;
  PROCEDURE _UpdateWatches;
    //  VAR
    //    lVar            : TfsCustomVariable;
  BEGIN
    lNode := cxTreeWatches.TopNode;
    WHILE lNode <> NIL DO BEGIN
      IF FindVar(lNode.Texts[0], dmScript.fsScript) THEN
        lNode.Texts[1] := VarToStr(dmScript.fsScript.Evaluate(lNode.Texts[0]))
      ELSE
        lNode.Texts[1] := '';
      lNode := lNode.GetNext;
    END;
  END;
BEGIN
  cxTreeWatch.BeginUpdate;
  cxTreeWatches.BeginUpdate;
  TRY
    IF pJustAdd THEN
      cxTreeWatch.Clear;
    IF Assigned(dmScript) THEN BEGIN
      _UpdateWatches;
      FOR i := 0 TO dmScript.fsScript.Count - 1 DO BEGIN
        TRY
          IF (dmScript.fsScript.Items[i] IS TfsVariable) THEN BEGIN
            _AddVar('', dmScript.fsScript.Items[i]);
          END ELSE IF dmScript.fsScript.Items[i] IS TfsParamItem THEN BEGIN
            _AddVar('', dmScript.fsScript.Items[i]);
          END ELSE IF dmScript.fsScript.Items[i] IS TfsProcVariable THEN BEGIN
            _AddProc('', dmScript.fsScript.Items[i]);
          END;
        EXCEPT
        END;
      END;
    END;
  FINALLY
    cxTreeWatch.EndUpdate;
    cxTreeWatches.EndUpdate;
  END;
END;

(*
PROCEDURE TformScrEdit.UpdateVariables(pJustAdd: Boolean = False);
VAR
  i                 : Integer;
  lNode             : TcxTreeListNode;
  PROCEDURE _AddVar(pPFX: STRING; pVar: TfsVariable);
  VAR
    cNode           : TcxTreeListNode;
  BEGIN
    IF (pVar.Typ IN [fvtInt, fvtBool, fvtFloat, fvtChar, fvtString]) AND
      pVar.NeedResult AND
      (NOT pVar.IsReadOnly) THEN BEGIN
      IF pPFX <> '' THEN BEGIN
        lNode := cxTreeWatch.TopNode;
        WHILE lNode <> NIL DO BEGIN
          IF lNode.Texts[0] = Copy(pPFX, 2, 999) THEN BEGIN
            cNode := lNode.GetFirstChild;
            WHILE cNode <> NIL DO BEGIN
              IF cNode.Texts[0] = pVar.Name THEN BEGIN
                IF cNode.Texts[1] <> VarToStr(pVar.Value) THEN BEGIN
                  cNode.MakeVisible;
                  cNode.ImageIndex := 2;
                  cNode.SelectedIndex := 2;
                END ELSE BEGIN
                  cNode.ImageIndex := 1;
                  cNode.SelectedIndex := 1;
                END;
                cNode.Values[1] := pVar.Value;
                Break;
              END;
              cNode := cNode.GetNextSibling;
            END;
            IF cNode = NIL THEN BEGIN
              cNode := lNode.AddChild;
              cNode.Texts[0] := pVar.Name;
              cNode.Values[1] := pVar.Value;
              cNode.Texts[2] := pPFX + pVar.Name;
              cNode.ImageIndex := 1;
              cNode.SelectedIndex := 1;
              IF pJustAdd THEN
                lNode.Expand(True);
            END;
            Break;
          END;
          lNode := lNode.GetNext;
        END;
        IF lNode = NIL THEN BEGIN
          lNode := cxTreeWatch.Add;
          lNode.Texts[0] := Copy(pPFX, 2, 999);
          lNode.ImageIndex := 0;
          lNode.SelectedIndex := 0;
          lNode := lNode.AddChild;
          lNode.Texts[0] := pVar.Name;
          lNode.Values[1] := pVar.Value;
          lNode.Texts[2] := pPFX + pVar.Name;
          lNode.ImageIndex := 1;
          lNode.SelectedIndex := 1;
          IF pJustAdd THEN
            lNode.Expand(True);
        END;
      END ELSE BEGIN
        lNode := cxTreeWatch.TopNode;
        WHILE lNode <> NIL DO BEGIN
          IF lNode.Texts[0] = pVar.Name THEN BEGIN
            IF lNode.Texts[1] <> VarToStr(pVar.Value) THEN BEGIN
              lNode.MakeVisible;
              lNode.ImageIndex := 2;
              lNode.SelectedIndex := 2;
            END ELSE BEGIN
              lNode.ImageIndex := 1;
              lNode.SelectedIndex := 1;
            END;
            lNode.Values[1] := pVar.Value;
            Break;
          END;
          lNode := lNode.GetNext;
        END;
        IF lNode = NIL THEN BEGIN
          lNode := cxTreeWatch.Add;
          lNode.Texts[0] := pVar.Name;
          lNode.Values[1] := pVar.Value;
          lNode.Texts[2] := pPFX + pVar.Name;
          lNode.ImageIndex := 1;
          lNode.SelectedIndex := 1;
        END;
      END;
    END;
  END;
  PROCEDURE _AddProc(pPFX: STRING; pProc: TfsProcVariable);
  VAR
    i               : Integer;
  BEGIN
    FOR i := 0 TO pProc.Prog.Count - 1 DO BEGIN
      TRY
        IF pProc.Prog.Items[i] IS TfsVariable THEN BEGIN
          _AddVar(pPFX + '.' + pProc.Name, TfsVariable(pProc.Prog.Items[i]));
        END ELSE IF pProc.Prog.Items[i] IS TfsProcVariable THEN BEGIN
          _AddProc(pPFX, TfsProcVariable(pProc.Prog.Items[i]));
        END;
      EXCEPT
      END;
    END;
  END;
BEGIN
  cxTreeWatch.BeginUpdate;
  TRY
    IF pJustAdd THEN
      cxTreeWatch.Clear;
    IF Assigned(dmScript) THEN BEGIN
      FOR i := 0 TO dmScript.fsScript.Count - 1 DO BEGIN
        TRY
          IF dmScript.fsScript.Items[i] IS TfsVariable THEN BEGIN
            _AddVar('', TfsVariable(dmScript.fsScript.Items[i]));
          END ELSE IF dmScript.fsScript.Items[i] IS TfsProcVariable THEN BEGIN
            _AddProc('', TfsProcVariable(dmScript.fsScript.Items[i]));
          END;
        EXCEPT
        END;
      END;
    END;
  FINALLY
    cxTreeWatch.EndUpdate;
  END;
END;
*)
{b131_01}

FUNCTION TformScrEdit.GetValue(Sender: TObject; pName: STRING): STRING;
VAR
  i                 : Integer;
  lVar              : Variant;
BEGIN
  IF {NOT fRunningFree AND}fStopped THEN BEGIN
    Evaluating := True;
    TRY
      TRY
        IF FindVar(pName, dmScript.fsScript) THEN BEGIN
          lVar := dmScript.fsScript.Evaluate(pName);
          IF VarIsArray(lVar) THEN BEGIN
            Result := '';
            FOR i := VarArrayLowBound(lVar, 1) TO VarArrayDimCount(lVar) - 1 DO BEGIN
              Result := Result + VarToStr(VarArrayGet(lVar, [i])) + ',';
            END;
            Result := pName + ' = ' + QuotedStr(Copy(Result, 1, Length(Result) - 1));
          END ELSE BEGIN
            IF Pos('undeclared', LowerCase(VarToStr(lVar))) = 1 THEN
              Result := ''
            ELSE
              Result := pName + ' = ' + QuotedStr(VarToStr(lVar));
          END;
        END ELSE
          Result := 'undefined';
      EXCEPT ON E: Exception DO
          Result := E.Message;
      END;
    FINALLY
      Evaluating := False;
    END;
  END ELSE
    Result := '';
END;

PROCEDURE TformScrEdit.SyntaxMemoProductionGetTokenHint(Sender: TObject;
  TokenIndex: Integer; VAR HintText: STRING);
VAR
  i                 : Integer;
  lStr              : STRING;
  lSynt             : TClientSyntAnalyzer;
BEGIN
  TRY
    lSynt := NIL;
    IF (Sender IS TSyntaxMemo) THEN BEGIN
      IF (Sender IS TSyntaxMemo) THEN
        lSynt := (Sender AS TSyntaxMemo).SyntObj;
      IF lSynt <> NIL THEN
        WITH lSynt DO BEGIN
          IF TSyntaxMemo(Sender).SelText <> '' THEN BEGIN
            lStr := TSyntaxMemo(Sender).SelText;
            HintText := GetValue(Sender, lStr);
          END ELSE IF HintText = '' THEN BEGIN
            i := TokenIndex;
            lStr := '';
            WHILE (HintText = '') AND (i > 0) DO BEGIN
              IF TagStr[i] <> '' THEN BEGIN
                lStr := TagStr[i] + lStr;
                IF NOT (TagStr[i][1] IN ['.', '(', ')', '{', '}']) THEN
                  HintText := GetValue(Sender, lStr);
              END;
              Dec(i);
            END;
          END;
        END;
    END;
  EXCEPT ON E: Exception DO
      HintText := E.Message;
  END;
END;

PROCEDURE TformScrEdit.SetIsInterp(CONST Value: Boolean);
VAR
  i                 : Integer;
  j                 : Integer;
  lFieldName        : STRING;
  lVar              : STRING;
  lQuote            : STRING;
  lValue            : STRING;
  lFound            : Boolean;
  lFld              : TField;
BEGIN
  fIsInterp := Value;
  cxTreeListVariables.BeginUpdate;
  TRY
    cxTreeListVariables.Clear;
    lQuote := fCalcul.QuoteChar;
    IF fIsInterp THEN BEGIN
      cxCol1.Caption.Text := 'Variable';
      cxCol2.Caption.Text := 'Value';
      cxCol3.Caption.Text := '';
      cxCol3.Visible := False;
{$IF DEFINED(NEXUSDB) OR DEFINED(USEDBISAM)}
      WITH cxTreeListVariables.Add DO BEGIN
        TRY
          Texts[0] := 'fIDRetailer';
          Texts[1] := lQuote + IntToStr(dmConn.RetailerID) + lQuote;
        EXCEPT
        END;
      END;
      WITH cxTreeListVariables.Add DO BEGIN
        TRY
          Texts[0] := 'fIDRetailerEmployee';
          Texts[1] := lQuote + IntToStr(dmConn.EmployeeID) + lQuote;
        EXCEPT
        END;
      END;
      WITH cxTreeListVariables.Add DO BEGIN
        TRY
          Texts[0] := 'fMetric';
          IF dmConn.UserFlags AND cUseMetric = cUseMetric THEN
            Texts[1] := lQuote + 'TRUE' + lQuote
          ELSE
            Texts[1] := lQuote + 'FALSE' + lQuote;
        EXCEPT
        END;
      END;
      IF Assigned(dmWeb) THEN BEGIN
        WITH cxTreeListVariables.Add DO BEGIN
          TRY
            Texts[0] := 'fIDRetailerOrder';
            Texts[1] := lQuote + IntToStr(dmWeb.IDRetailerOrder) + lQuote;
          EXCEPT
          END;
        END;
        WITH cxTreeListVariables.Add DO BEGIN
          TRY
            Texts[0] := 'fIDRetailerEmployeeOrder';
            Texts[1] := lQuote + IntToStr(StrToIntDef(GetToken(dmWeb.CurrentOrder, '-', 1), 0)) +
              lQuote;
          EXCEPT
          END;
        END;
        WITH cxTreeListVariables.Add DO BEGIN
          TRY
            Texts[0] := 'fIDCollectionOrder';
            Texts[1] := lQuote + IntToStr(dmWeb.IDCollectionOrder) + lQuote;
          EXCEPT
          END;
        END;
        WITH cxTreeListVariables.Add DO BEGIN
          TRY
            Texts[0] := 'fIDWholesaler';
            Texts[1] := lQuote + IntToStr(dmWeb.dmCtl.dmConn.IDWholesaler) + lQuote;
          EXCEPT
          END;
        END;
        WITH cxTreeListVariables.Add DO BEGIN
          TRY
            Texts[0] := 'fIDWholesalerOrder';
            Texts[1] := lQuote + IntToStr(dmWeb.IDWholesalerOrder) + lQuote;
          EXCEPT
          END;
        END;
      END;

      CommonPopulateGarmentVariables(CurGUID, TCommonQuery(fQuery), fCalcul);
      FOR i := Low(fGarmentTableList) TO High(fGarmentTableList) DO BEGIN
        WITH cxTreeListVariables.Add DO BEGIN
          lVar := 'f' + Copy(fGarmentTableList[i].rTableName, Pos('LAM_',
            fGarmentTableList[i].rTableName) + 4, Length(fGarmentTableList[i].rTableName));
          TRY
            Texts[0] := lVar;
            Texts[1] := fCalcul.VarObj.GetValue(lVar);
          EXCEPT
          END;
        END;
      END;
{$IFEND NEXUSDB}
      WITH cxTreeListVariables.Add DO BEGIN
        TRY
          Texts[0] := 'fShowVar';
          Texts[1] := lQuote + ' ' + lQuote;
        EXCEPT
        END;
      END;
      WITH cxTreeListVariables.Add DO BEGIN
        TRY
          Texts[0] := 'fResult';
          Texts[1] := lQuote + 'FALSE' + lQuote;
        EXCEPT
        END;
      END;
      WITH cxTreeListVariables.Add DO BEGIN
        TRY
          Texts[0] := 'fReadOnly';
          Texts[1] := lQuote + 'FALSE' + lQuote;
        EXCEPT
        END;
      END;
      WITH cxTreeListVariables.Add DO BEGIN
        TRY
          Texts[0] := 'fHidden';
          Texts[1] := lQuote + 'FALSE' + lQuote;
        EXCEPT
        END;
      END;
      WITH cxTreeListVariables.Add DO BEGIN
        TRY
          Texts[0] := 'fDefault';
          Texts[1] := lQuote + 'FALSE' + lQuote;
        EXCEPT
        END;
      END;
      WITH cxTreeListVariables.Add DO BEGIN
        TRY
          Texts[0] := 'fGraphic';
          Texts[1] := lQuote + 'Default' + lQuote;
        EXCEPT
        END;
      END;
      IF fBaseTable <> '' THEN BEGIN
{$IF DEFINED(NEXUSDB) OR DEFINED(USEDBISAM)}
        IF Assigned(fItemScr) THEN BEGIN
          CommonPopulateVariables(ItemScr.fTableList, fCalcul, False);
          FOR j := 0 TO ItemScr.fTableList.Count - 1 DO BEGIN
            FOR i := 0 TO ItemScr.fTableList[j].FieldCount - 1 DO BEGIN
              lFieldName := ItemScr.fTableList[j].Fields[i].FieldName;
              IF (CompareText(lFieldName, 'IDRetailer') <> 0) AND
                (CompareText(lFieldName, 'IDRetailerEmployee') <> 0) THEN BEGIN
                lValue := ItemScr.fTableList[j].Fields[i].AsString;
                lValue := UpperCase(lValue);
                WITH cxTreeListVariables.Add DO BEGIN
                  TRY
                    Texts[0] := 'f' + lFieldName;
                    IF lValue = '' THEN
                      Texts[1] := lQuote + cNULLVal + lQuote
                    ELSE
                      Texts[1] := lQuote + lValue + lQuote;
                  EXCEPT
                  END;
                END;
              END;
            END;
            lFieldName := Copy(Caption, Pos('for ', Caption) + 4, 99);
            lFieldName := Copy(lFieldName, 1, LastDelimiter('_', lFieldName) - 1);
            IF ItemScr.fTableList[j].FindField(lFieldName) <> NIL THEN BEGIN
              WITH cxTreeListVariables.Add DO BEGIN
                TRY
                  Texts[0] := 'fCurrent';
                  IF ItemScr.fTableList[j].FieldByName(lFieldName).AsString = '' THEN
                    Texts[1] := lQuote + cNULLVal + lQuote
                  ELSE
                    Texts[1] := lQuote + ItemScr.fTableList[j].FieldByName(lFieldName).AsString +
                      lQuote;
                EXCEPT
                END;
              END;
            END;
          END;
        END ELSE BEGIN
          fTable.Active := False;
          fTable.TableName := fBaseTable;
          fTable.IndexName := 'iIGUID';
          fTable.Active := True;
          fTable.Refresh;
          IF fTable.FindKey([CurGUID]) THEN BEGIN
            FOR i := 0 TO fTable.FieldCount - 1 DO BEGIN
              IF (fTable.Fields[i].FieldName <> 'IDRetailer') AND
                (fTable.Fields[i].FieldName <> 'IDRetailerEmployee') THEN BEGIN
                WITH cxTreeListVariables.Add DO BEGIN
                  TRY
                    Texts[0] := 'f' + fTable.Fields[i].FieldName;
                    IF fTable.Fields[i].AsString = '' THEN
                      Texts[1] := lQuote + cNULLVal + lQuote
                    ELSE
                      Texts[1] := lQuote + UpperCase(fTable.Fields[i].AsString) + lQuote;
                  EXCEPT
                  END;
                END;
              END;
            END;
          END;
          lFieldName := Copy(Caption, Pos('for ', Caption) + 4, 99);
          lFieldName := Copy(lFieldName, 1, LastDelimiter('_', lFieldName) - 1);
          IF fTable.FindField(lFieldName) <> NIL THEN BEGIN
            WITH cxTreeListVariables.Add DO BEGIN
              TRY
                Texts[0] := 'fCurrent';
                IF fTable.FieldByName(lFieldName).AsString = '' THEN
                  Texts[1] := lQuote + cNULLVal + lQuote
                ELSE
                  Texts[1] := lQuote + fTable.FieldByName(lFieldName).AsString + lQuote;
              EXCEPT
              END;
            END;
          END;
          fTable.Active := False;
        END;
{$IFEND NEXUSDB}
      END;
    END ELSE BEGIN
      cxCol1.Caption.Text := 'Option';
      cxCol2.Caption.Text := 'Description';
      cxCol3.Caption.Text := 'Value';
      cxCol3.Visible := True;
      IF fBaseTable <> '' THEN BEGIN
{$IF DEFINED(NEXUSDB) OR DEFINED(USEDBISAM)}
        fTable.Active := False;
        fTable.TableName := fBaseTable;
        fTable.IndexName := 'iIGUID';
        fTable.Active := True;
        fTable.Refresh;
        lFound := fTable.FindKey([CurGUID]);
        IF Assigned(nxLookup) THEN BEGIN
          IF lzSafeOpenQuery(nxQueryTest, 'SELECT * FROM LAM_LINKS WHERE UPPER(BASETABLE)=' +
            QuotedStr(UpperCase(fBaseTable)) + ' ORDER BY FIELDORDER') THEN BEGIN
            WHILE NOT nxQueryTest.EOF DO BEGIN
              WITH cxTreeListVariables.Add DO BEGIN
                TRY
                  Texts[0] := nxQueryTest.FieldByName('OPTION').AsString;
                  Texts[1] := nxQueryTest.FieldByName('DESCRIPTION').AsString;
                  TRY
                    IF lFound AND (Pos('_0', nxQueryTest.FieldByName('OPTION').AsString) > 0) THEN
                      BEGIN
                      lFld := fTable.FindField(nxQueryTest.FieldByName('FIELDNAME').AsString);
                      IF lFld <> NIL THEN
                        Texts[2] := lFld.AsString;
                    END;
                  EXCEPT
                  END;
                EXCEPT
                END;
              END;
              nxQueryTest.Next;
            END;
            lzSafeCloseQuery(nxQueryTest);
          END;
        END;
        fTable.Active := False;
{$IFEND NEXUSDB}
      END ELSE BEGIN
        cxSplitter3.Visible := False;
        cxGroupBox3.Visible := False;
      END;
    END;
  FINALLY
    cxTreeListVariables.EndUpdate;
  END;
END;

{$IFDEF NEXUSDB}

PROCEDURE TformScrEdit.LoadTables(pDatabase: TnxDatabase; pTableList: TTableList; pOGUID:
  STRING);
VAR
  lName             : STRING;
  lSQL              : STRING;
  lCur              : Integer;
  lFieldREFER       : TField;
  lFieldIGUID       : TField;
  lQuery            : TnxQuery;
BEGIN
  IF NOT Assigned(pTableList) THEN
    pTableList := TTableList.Create
  ELSE
    pTableList.Clear;
  pTableList.Database := pDatabase;
  lSQL := 'SELECT * FROM ctlItems WHERE RGUID=(' + cCRLF +
    'SELECT TOP 1 RGUID FROM ctlItems WHERE IGUID=' + QuotedStr(pOGUID) + ')' + cCRLF +
    'ORDER BY REFER';
  lQuery := pDatabase.OpenQuery(lSQL, []);
  TRY
    IF lQuery.Active THEN BEGIN
      lFieldREFER := lQuery.FindField('REFER');
      lFieldIGUID := lQuery.FindField('IGUID');
      WHILE NOT lQuery.EOF DO BEGIN
        lName := lFieldREFER.AsString;
        lCur := pTableList.Add(lName);
        IF Assigned(pTableList[lCur]) THEN BEGIN
          pTableList[lCur].Active := True;
          TRY
            pTableList[lCur].IndexName := 'iIGUID';
          EXCEPT
            pTableList[lCur].Active := False;
            pTableList[lCur].AddIndex('iIGUID', 'IGUID', []);
            pTableList[lCur].IndexName := 'iIGUID';
            pTableList[lCur].Active := True;
          END;
          pTableList[lCur].Filter := 'IGUID=' + QuotedStr(lFieldIGUID.AsString);
          pTableList[lCur].SetRange([lFieldIGUID.AsString], [lFieldIGUID.AsString]);
        END;
        lQuery.Next;
      END;
    END;
  FINALLY
    lzSafeFreeAndNIL(lQuery);
  END;
END;
{$ENDIF NEXUSDB}

{$IFDEF USEDBISAM}

PROCEDURE TformScrEdit.LoadTables(pDatabase: TDBISAMDatabase; pTableList: TTableList; pOGUID:
  STRING);
VAR
  lName             : STRING;
  lSQL              : STRING;
  lCur              : Integer;
  lFieldREFER       : TField;
  lFieldIGUID       : TField;
  lQuery            : TDBISamQuery;
BEGIN
  IF NOT Assigned(pTableList) THEN
    pTableList := TTableList.Create
  ELSE
    pTableList.Clear;
  pTableList.Database := pDatabase;
  lSQL := 'SELECT * FROM ctlItems WHERE UPPER(RGUID) IN (' + cCRLF +
    'SELECT UPPER(RGUID) FROM ctlItems WHERE UPPER(IGUID)=' + QuotedStr(pOGUID) + ')' + cCRLF +
    'ORDER BY REFER';
  lQuery := TDBISamQuery.Create(NIL);
  TRY
    lQuery.DatabaseName := pDatabase.DatabaseName;
    lQuery.SessionName := pDatabase.SessionName;

    IF lzSafeOpenQuery(lQuery, lSQL) THEN BEGIN
      lFieldREFER := lQuery.FindField('REFER');
      lFieldIGUID := lQuery.FindField('IGUID');
      IF lQuery.FindField('IDCollection') <> NIL THEN
        dmWeb.IDCollectionOrder := lQuery.FieldByName('IDCollection').AsInteger;

      WHILE NOT lQuery.EOF DO BEGIN
        lName := lFieldREFER.AsString;
        lCur := pTableList.Add(lName);
        IF Assigned(pTableList[lCur]) THEN BEGIN
          pTableList[lCur].Active := True;
          TRY
            pTableList[lCur].IndexName := 'iIGUID';
          EXCEPT
            pTableList[lCur].Active := False;
            pTableList[lCur].AddIndex('iIGUID', 'IGUID', []);
            pTableList[lCur].IndexName := 'iIGUID';
            pTableList[lCur].Active := True;
          END;
          pTableList[lCur].Filter := 'IGUID=' + QuotedStr(lFieldIGUID.AsString);
          pTableList[lCur].SetRange([lFieldIGUID.AsString], [lFieldIGUID.AsString]);
        END;
        lQuery.Next;
      END;
    END;
  FINALLY
    lzSafeFreeAndNIL(lQuery);
  END;
END;
{$ENDIF USEDBISAM}

PROCEDURE TformScrEdit.OnGetVariable(Sender: TObject; CONST VariableName: STRING; VAR VariableValue:
  Variant; VAR Handled: Boolean; Index: Integer);
VAR
  //  i                 : Integer;
  //  j                 : Integer;
  lVal              : STRING;
  lQuote            : STRING;
  lTableList        : TTableList;
BEGIN
{$IF DEFINED(NEXUSDB) OR DEFINED(USEDBISAM)}
  lQuote := fCalcul.QuoteChar;
  lTableList := NIL;
  IF Assigned(ItemScr) THEN
    lTableList := ItemScr.fTableList;
  IF Assigned(dmWeb) AND Assigned(dmWeb.fItem) THEN
    lTableList := dmWeb.fItem.TableList;
  IF Assigned(lTableList) THEN BEGIN
    lVal := GetTableVal(VariableName);
    IF (lVal <> '') THEN BEGIN
      VariableValue := lVal;
      Handled := True;
    END ELSE BEGIN
      VariableValue := lQuote + cNULLVal + lQuote;
      Handled := IgnoreMissingVariables;
    END;
  END ELSE BEGIN
    VariableValue := lQuote + cNULLVal + lQuote;
    Handled := IgnoreMissingVariables;
  END;
{$IFEND NEXUSDB}
END;

FUNCTION TformScrEdit.GetTableVal(pField: STRING): Variant;
VAR
  i                 : Integer;
  j                 : Integer;
  lTableList        : TTableList;
  lQuote            : STRING;
BEGIN
{$IF DEFINED(NEXUSDB) OR DEFINED(USEDBISAM)}
  lTableList := NIL;
  lQuote := fCalcul.QuoteChar;
  Result := lQuote + 'NULL' + lQuote;
  IF Assigned(ItemScr) THEN
    lTableList := ItemScr.fTableList;
  IF Assigned(dmWeb) AND Assigned(dmWeb.fItem) THEN
    lTableList := dmWeb.fItem.TableList;
  IF Assigned(lTableList) THEN BEGIN
    i := 0;
    WHILE (i < lTableList.Count) AND (Result = lQuote + 'NULL' + lQuote) DO BEGIN
      j := 0;
      WHILE (j < lTableList[i].FieldCount) AND (Result = lQuote + 'NULL' +
        lQuote) DO BEGIN
        IF CompareText(pField, 'f' + lTableList[i].Fields[j].FieldName) = 0 THEN BEGIN
          //          CASE lTableList[i].Fields[j].DataType OF
          //            ftInteger,
          //              ftSmallint,
          //              ftWord,
          //              ftFloat,
          //              ftAutoInc,
          //              ftLargeint,
          //              ftCurrency:
          //              Result := lTableList[i].Fields[j].Value;
          //          ELSE
          Result := lQuote + lTableList[i].Fields[j].AsString + lQuote;
          //          END;
        END;
        Inc(j);
      END;
      Inc(i);
    END;
  END;
  IF Result = lQuote + 'NULL' + lQuote THEN
    Result := '';
  //    IF VarIsNull(Result) THEN
  //      Result := lQuote + 'NULL' + lQuote;
{$IFEND NEXUSDB}
END;

PROCEDURE TformScrEdit.fsScript1RunLine(Sender: TfsScript; CONST UnitName, SourcePos: STRING);
VAR
  P                 : TPoint;
BEGIN
  IF Assigned(fRunningMemo) AND FRunning THEN BEGIN
    P := fsPosToPoint(SourcePos);
    P.Y := P.Y - 1;
    P.X := P.X - 1;
    fStopped := IsBreakPt(P.Y) OR (NOT fRunningFree);
    IF fStopped THEN BEGIN
      { enable main window to allow debugging of modal forms }
      IF (fCurrentUnit <> UnitName) AND (UnitName <> '') THEN BEGIN
        fCurrentUnit := UnitName;
        fRunningMemo.Lines.Text := Hex2Str(fSourceList.Values[UnitName]);
        fRunningMemo.ReadOnly := True;
      END ELSE IF (UnitName = '') AND (fCurrentUnit <> cSource) THEN BEGIN
        fCurrentUnit := cSource;
        fRunningMemo.ReadOnly := False;
        fRunningMemo.Lines.Text := Hex2Str(fSourceList.Values[cSource]);
      END;
      { enable main window to allow debugging of modal forms }
      EnableWindow(Handle, True);
      SetFocus;
      fRunningMemo.CaretPos := P;
      FCurrentLine := P.Y;
      fRunningMemo.ShowLine(P.Y);
      fRunningMemo.Invalidate;
      UpdateVariables(False);
      WHILE fStopped DO BEGIN
        Sleep(50);
        Application.ProcessMessages;
      END;
      CheckButtons;
    END;
  END;
END;

PROCEDURE TformScrEdit.fsScriptGetUnit(Sender: TfsScript; CONST UnitName: STRING; VAR UnitText:
  STRING);
{$IF DEFINED(NEXUSDB) OR DEFINED(USEDBISAM)}
VAR
{$IFDEF NEXUSDB}
  lScripts          : TnxTable;
  lDB               : TnxDatabase;
{$ENDIF NEXUSDB}
{$IFDEF USEDBISAM}
  lScripts          : TDBISamTable;
{$ENDIF USEDBISAM}
{$IFEND NEXUSDB}
BEGIN
{$IF DEFINED(NEXUSDB) OR DEFINED(USEDBISAM)}
  TRY
{$IFDEF NEXUSDB}
    lDB := lzGetPooledDatabase(dmConn.SessionPool, dmConn.Alias, '');
    lScripts := TnxTable.Create(NIL);
    lScripts.Database := lDB;
    lScripts.TableName := cTableScripts;
{$ENDIF NEXUSDB}
{$IFDEF USEDBISAM}
    lScripts := TDBISamTable.Create(NIL);
    lScripts.DatabaseName := fdmWeb.dmCtl.dmConn.Database.DatabaseName;
    lScripts.SessionName := fdmWeb.dmCtl.dmConn.Database.SessionName;
    lScripts.TableName := cTableScripts;
{$ENDIF USEDBISAM}
    lScripts.Active := True;
    TRY
      IF lScripts.Active AND (fSourceList <> NIL) THEN BEGIN
        lScripts.IndexName := 'iTitle';
        lScripts.First;
        IF lScripts.FindKey([UnitName]) THEN BEGIN
          UnitText := PreCompileScript(lScripts.FieldByName('PRODS').AsString);
          fSourceList.Values[UnitName] := Str2Hex(UnitText);
        END;
      END;
    FINALLY
      lzSafeFreeAndNIL(lScripts);
{$IFDEF NEXUSDB}
      lzClosePooledDatabase(lDB);
{$ENDIF NEXUSDB}
    END;
  EXCEPT ON E: Exception DO BEGIN
      LogEvent(Integer(lpError), 'TDataModuleCliUtil.OnScriptGetUnit Error : ' + E.Message);
    END;
  END;
{$IFEND NEXUSDB}
END;

PROCEDURE TformScrEdit.SyntaxMemoProductionSelectionChanged(Sender: TObject);
BEGIN
  IF Assigned(fRunningMemo) THEN BEGIN
    fLastPos := fRunningMemo.CaretPos;
    fLastPosX := fRunningMemo.ScrollPosY;
    fLastPosY := fRunningMemo.ScrollPosX;
  END;
END;

PROCEDURE TformScrEdit.SyntaxMemoProductionTextChanged(Sender: TObject;
  Pos, Count, LineChange: Integer);
BEGIN
  IF fCurrentUnit = cSource THEN
    fSourceList.Values[cSource] := Str2Hex(fCurrentMemo.Lines.Text);
END;

PROCEDURE TformScrEdit.ParamCompletionJSGetParams(Sender: TObject; CONST FuncName: ecString; aPos:
  Integer);
VAR
  lVar              : STRING;
  i                 : Integer;
  j                 : Integer;
BEGIN
  ParamCompletionFSScript.Items.Clear;
  IF Assigned(fCurrentMemo) THEN BEGIN
    FOR i := Low(cTOPSVar) TO High(cTOPSVar) DO BEGIN
      IF cTOPSVar[i] = FuncName THEN BEGIN
        j := 0;
        lVar := GetToken(cTOPSVarP[i], ',', j);
        WHILE lVar <> '' DO BEGIN
          ParamCompletionJS.Items.Add(lVar);
          Inc(j);
          lVar := GetToken(cTOPSVarP[i], ',', j);
        END;
      END;
    END;
  END;
END;

PROCEDURE TformScrEdit.AutoCompleteJSAfterComplete(Sender: TObject; CONST Item: ecString);
BEGIN
  ParamCompletionJS.Execute;
END;

PROCEDURE TformScrEdit.AutoCompleteJSBeforeComplete(Sender: TObject; VAR Item: ecString);
VAR
  i                 : Integer;
  lFound            : Boolean;
BEGIN
  lFound := False;
  FOR i := Low(cTOPSVar) TO High(cTOPSVar) DO BEGIN
    IF (Pos(Item, cTOPSVar[i]) > 0) THEN BEGIN
      Item := cTOPSVar[i];
      lFound := True;
    END;
  END;
  IF NOT lFound THEN BEGIN
    FOR i := Low(cKeywords) TO High(cKeywords) DO BEGIN
      IF (Pos(Item, cKeywords[i]) > 0) THEN BEGIN
        Item := cKeywords[i];
        lFound := True;
      END;
    END;
  END;
  IF NOT lFound THEN BEGIN
    FOR i := Low(cLiterals) TO High(cLiterals) DO BEGIN
      IF (Pos(Item, cLiterals[i]) > 0) THEN BEGIN
        Item := cLiterals[i];
        lFound := True;
      END;
    END;
  END;
  IF NOT lFound THEN BEGIN
    FOR i := Low(cKeywordsJQ) TO High(cKeywordsJQ) DO BEGIN
      IF (Pos(Item, cKeywordsJQ[i]) > 0) THEN BEGIN
        Item := cKeywordsJQ[i];
        //        lFound := True;
      END;
    END;
  END;
END;

PROCEDURE TformScrEdit.AutoCompleteJSGetAutoCompleteList(Sender: TObject; aPos: TPoint; List,
  Display: TecStrings);
VAR
  i                 : Integer;
  j                 : Integer;
  lLine             : STRING;
  lObj              : STRING;
  lStr              : STRING;
  lFound            : Boolean;
BEGIN
  fItem := '';
  lLine := fCurrentMemo.Lines[aPos.Y];
  i := aPos.X - 1;
  IF lLine <> '' THEN BEGIN
    WHILE (i > 0) AND (lLine[i] IN ['A'..'Z', 'a'..'z', '0'..'9', '.', ')']) DO BEGIN
      Dec(i);
    END;
    fItem := UpperCase(Copy(lLine, aPos.X + 1, Length(lLine)));
    j := 1;
    WHILE (j < Length(fItem)) AND (fItem[j] IN ['A'..'Z', 'a'..'z', '0'..'9']) DO BEGIN
      Inc(j);
    END;
    fItem := Copy(fItem, 1, j - 1);
    lLine := Copy(lLine, i, aPos.X);
    lObj := strTrimA(Copy(lLine, 1, aPos.X - i));
    lObj := FastReplace(lObj, '(', '');
    lObj := FastReplace(lObj, ')', '');
  END;
  IF FastPos(lObj, '.', Length(lObj), 1, 1) > 0 THEN
    lStr := Copy(lObj, 1, FastPos(lObj, '.', Length(lObj), 1, 1) - 1)
  ELSE
    lStr := lObj;

  List.Clear;
  Display.Clear;

  lFound := False;
  IF lStr = 'CurItem' THEN BEGIN
    lFound := True;
    FOR i := Low(cTOPSVar) TO High(cTOPSVar) DO BEGIN
      IF 'CurItem' <> cTOPSVar[i] THEN
        List.Add(cTOPSVar[i]);
    END;
  END;
  IF NOT lFound THEN BEGIN
    List.Add('CurItem');
    FOR i := Low(cKeywords) TO High(cKeywords) DO BEGIN
      List.Add(cKeywords[i]);
    END;
    FOR i := Low(cLiterals) TO High(cLiterals) DO BEGIN
      List.Add(cLiterals[i]);
    END;
    FOR i := Low(cKeywordsJQ) TO High(cKeywordsJQ) DO BEGIN
      List.Add(cKeywordsJQ[i]);
    END;
  END;
END;

PROCEDURE TformScrEdit.AutoCompleteJSCanShow(Sender: TObject; VAR DoShow: Boolean);
VAR
  i                 : Integer;
BEGIN
  IF fItem <> '' THEN BEGIN
    IF Sender IS TAutoCompletePopup THEN BEGIN
      DoShow := False;
      i := 0;
      WHILE (NOT DoShow) AND (i < TAutoCompletePopup(Sender).Items.Count) DO BEGIN
        DoShow := Pos(fItem, UpperCase(TAutoCompletePopup(Sender).Items[i])) = 1;
        Inc(i);
      END;
    END;
  END;
END;

PROCEDURE TformScrEdit.AutoCompleteJSFilter(Sender: TCustomAutoCompletePopup; CONST Item,
  DisplayItem, Filter: STRING; VAR Accept: Boolean);
BEGIN
  Accept := Pos(Filter, Item) = 1;
END;

PROCEDURE TformScrEdit.AutoCompleteFSScriptFilter(Sender: TCustomAutoCompletePopup; CONST Item,
  DisplayItem, Filter: STRING; VAR Accept: Boolean);
BEGIN
  Accept := Pos(Filter, Item) = 1;
END;

PROCEDURE TformScrEdit.ParamCompletionCalcGetParams(Sender: TObject; CONST FuncName: ecString; aPos:
  Integer);
VAR
  lVar              : STRING;
  i                 : Integer;
  j                 : Integer;
BEGIN
  ParamCompletionCalc.Items.Clear;
  IF Assigned(fCurrentMemo) THEN BEGIN
    FOR i := Low(cKeywordsCal) TO High(cKeywordsCal) DO BEGIN
      IF cKeywordsCal[i] = FuncName THEN BEGIN
        j := 0;
        lVar := GetToken(cKeywordsCalP[i], ',', j);
        WHILE lVar <> '' DO BEGIN
          ParamCompletionCalc.Items.Add(lVar);
          Inc(j);
          lVar := GetToken(cKeywordsCalP[i], ',', j);
        END;
      END;
    END;
  END;
END;

PROCEDURE TformScrEdit.AutoCompleteCalcAfterComplete(Sender: TObject; CONST Item: ecString);
BEGIN
  ParamCompletionCalc.Execute;
END;

PROCEDURE TformScrEdit.AutoCompleteCalcBeforeComplete(Sender: TObject; VAR Item: ecString);
VAR
  i                 : Integer;
BEGIN
  FOR i := Low(cKeywordsCal) TO High(cKeywordsCal) DO BEGIN
    IF (Pos(Item, cKeywordsCal[i]) > 0) THEN BEGIN
      Item := cKeywordsCal[i];
    END;
  END;
END;

PROCEDURE TformScrEdit.AutoCompleteCalcFilter(Sender: TCustomAutoCompletePopup; CONST Item,
  DisplayItem, Filter: STRING; VAR Accept: Boolean);
BEGIN
  Accept := Pos(Filter, Item) = 1;
END;


PROCEDURE TformScrEdit.AutoCompleteCalcGetAutoCompleteList(Sender: TObject; aPos: TPoint; List,
  Display: TecStrings);
VAR
  i                 : Integer;
  j                 : Integer;
  lLine             : STRING;
  lObj              : STRING;
  lStr              : STRING;
  //  lFound            : Boolean;
BEGIN
  fItem := '';
  lLine := fCurrentMemo.Lines[aPos.Y];
  i := aPos.X - 1;
  IF lLine <> '' THEN BEGIN
    WHILE (i > 0) AND (lLine[i] IN ['A'..'Z', 'a'..'z', '0'..'9', '.', ')']) DO BEGIN
      Dec(i);
    END;
    fItem := UpperCase(Copy(lLine, aPos.X + 1, Length(lLine)));
    j := 1;
    WHILE (j < Length(fItem)) AND (fItem[j] IN ['A'..'Z', 'a'..'z', '0'..'9']) DO BEGIN
      Inc(j);
    END;
    fItem := Copy(fItem, 1, j - 1);
    lLine := Copy(lLine, i, aPos.X);
    lObj := strTrimA(Copy(lLine, 1, aPos.X - i));
    lObj := FastReplace(lObj, '(', '');
    lObj := FastReplace(lObj, ')', '');
  END;
  IF FastPos(lObj, '.', Length(lObj), 1, 1) > 0 THEN
    lStr := Copy(lObj, 1, FastPos(lObj, '.', Length(lObj), 1, 1) - 1)
  ELSE
    lStr := lObj;

  List.Clear;
  Display.Clear;

  FOR i := Low(cKeywordsCal) TO High(cKeywordsCal) DO BEGIN
    List.Add(cKeywordsCal[i]);
  END;
END;

PROCEDURE TformScrEdit.SetFontSize(CONST Value: Integer);
BEGIN
  IF (fFontSize > 5) AND (fFontSize <> Value) THEN BEGIN
    fFontSize := Value;
    cxTreeWatch.Font.Size := fFontSize;
    cxTreeWatches.Font.Size := fFontSize;
    cxTreeListVariables.Font.Size := fFontSize;
    PropsManager1.UpdateAll;
  END;
END;

PROCEDURE TformScrEdit.SetZoomLevel(CONST Value: Integer);
BEGIN
  IF (fZoomLevel > 10) AND (fZoomLevel <> Value) THEN BEGIN
    fZoomLevel := Value;
    SyntaxMemoProduction.Zoom := fZoomLevel;
    SyntaxMemoOutput.Zoom := fZoomLevel;
    SyntaxMemoNotes.Zoom := fZoomLevel;
    PropsManager1.UpdateAll;
  END;
END;

PROCEDURE TformScrEdit.ecCustomizeEditorOptionsAction1ExecuteOK(
  Sender: TObject);
BEGIN
  PropsManager1.UpdateAll;
END;

END.

