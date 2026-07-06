UNIT CodeEdit.Completion;

INTERFACE

USES
  System.Classes,
  System.Generics.Collections;

TYPE
  TCodeCompletionItemKind = (
    ckText,
    ckKeyword,
    ckFunction,
    ckProcedure,
    ckMethod,
    ckProperty,
    ckVariable,
    ckClass,
    ckTable,
    ckColumn,
    ckSnippet,
    ckParameter
    );

  TCodeCompletionContext = RECORD
    Line: Integer;
    Column: Integer;
    Prefix: STRING;
    TriggerChar: Char;
    LineText: STRING;
    ExplicitRequest: Boolean;
  END;

  TCodeSignatureHelpContext = RECORD
    Line: Integer;
    Column: Integer;
    LineText: STRING;
    FunctionName: STRING;
    TriggerChar: Char;
    ActiveParameter: Integer;
    ExplicitRequest: Boolean;
  END;

  TCodeCompletionItem = CLASS
  PRIVATE
    FCaption: STRING;
    FDetail: STRING;
    FInsertText: STRING;
    FKind: TCodeCompletionItemKind;
  PUBLIC
    CONSTRUCTOR Create(CONST ACaption, AInsertText: STRING; AKind: TCodeCompletionItemKind = ckText;
      CONST ADetail: STRING = '');
    PROPERTY Caption: STRING READ FCaption WRITE FCaption;
    PROPERTY InsertText: STRING READ FInsertText WRITE FInsertText;
    PROPERTY Detail: STRING READ FDetail WRITE FDetail;
    PROPERTY Kind: TCodeCompletionItemKind READ FKind WRITE FKind;
  END;

  TCodeCompletionItems = CLASS(TObjectList<TCodeCompletionItem>)
  PUBLIC
    PROCEDURE AddItem(CONST ACaption, AInsertText: STRING; AKind: TCodeCompletionItemKind = ckText;
      CONST ADetail: STRING = '');
  END;

  TCodeSignatureItem = CLASS
  PRIVATE
    FDetail: STRING;
    FName: STRING;
    FParameters: TStringList;
    FUNCTION GetParameters: TStrings;
  PUBLIC
    CONSTRUCTOR Create(CONST AName: STRING; CONST AParameters: ARRAY OF STRING; CONST ADetail: STRING
      = '');
    DESTRUCTOR Destroy; OVERRIDE;
    PROPERTY Detail: STRING READ FDetail WRITE FDetail;
    PROPERTY Name: STRING READ FName WRITE FName;
    PROPERTY Parameters: TStrings READ GetParameters;
  END;

  TCodeSignatureItems = CLASS(TObjectList<TCodeSignatureItem>)
  PUBLIC
    PROCEDURE AddItem(CONST AName: STRING; CONST AParameters: ARRAY OF STRING; CONST ADetail: STRING
      = '');
  END;

  TCodeCompletionEvent = PROCEDURE(Sender: TObject; CONST Context: TCodeCompletionContext;
    Items: TCodeCompletionItems) OF OBJECT;
  TCodeSignatureHelpEvent = PROCEDURE(Sender: TObject; CONST Context: TCodeSignatureHelpContext;
    Items: TCodeSignatureItems) OF OBJECT;

  TCustomCodeCompletionProvider = CLASS(TComponent)
  PRIVATE
    FOnGetCompletions: TCodeCompletionEvent;
    FOnGetSignatureHelp: TCodeSignatureHelpEvent;
  PUBLIC
    PROCEDURE GetCompletions(CONST Context: TCodeCompletionContext; Items: TCodeCompletionItems);
      VIRTUAL;
    PROCEDURE GetSignatureHelp(CONST Context: TCodeSignatureHelpContext; Items:
      TCodeSignatureItems);
      VIRTUAL;
  PUBLISHED
    PROPERTY OnGetCompletions: TCodeCompletionEvent READ FOnGetCompletions WRITE FOnGetCompletions;
    PROPERTY OnGetSignatureHelp: TCodeSignatureHelpEvent READ FOnGetSignatureHelp WRITE
      FOnGetSignatureHelp;
  END;

  TKeywordCompletionProvider = CLASS(TCustomCodeCompletionProvider)
  PRIVATE
    FKeywords: TStringList;
    FUNCTION GetKeywords: TStrings;
    PROCEDURE SetKeywords(Value: TStrings);
  PUBLIC
    CONSTRUCTOR Create(AOwner: TComponent); OVERRIDE;
    DESTRUCTOR Destroy; OVERRIDE;
    PROCEDURE GetCompletions(CONST Context: TCodeCompletionContext; Items: TCodeCompletionItems);
      OVERRIDE;
  PUBLISHED
    PROPERTY Keywords: TStrings READ GetKeywords WRITE SetKeywords;
  END;

IMPLEMENTATION

USES
  System.StrUtils,
  System.SysUtils;

CONSTRUCTOR TCodeCompletionItem.Create(CONST ACaption, AInsertText: STRING; AKind:
  TCodeCompletionItemKind;
  CONST ADetail: STRING);
BEGIN
  INHERITED Create;
  FCaption := ACaption;
  FInsertText := AInsertText;
  FKind := AKind;
  FDetail := ADetail;
END;

PROCEDURE TCodeCompletionItems.AddItem(CONST ACaption, AInsertText: STRING; AKind:
  TCodeCompletionItemKind;
  CONST ADetail: STRING);
BEGIN
  Add(TCodeCompletionItem.Create(ACaption, AInsertText, AKind, ADetail));
END;

CONSTRUCTOR TCodeSignatureItem.Create(CONST AName: STRING; CONST AParameters: ARRAY OF STRING;
  CONST ADetail: STRING);
VAR
  Parameter         : STRING;
BEGIN
  INHERITED Create;
  FName := AName;
  FDetail := ADetail;
  FParameters := TStringList.Create;
  FOR Parameter IN AParameters DO
    FParameters.Add(Parameter);
END;

DESTRUCTOR TCodeSignatureItem.Destroy;
BEGIN
  FParameters.Free;
  INHERITED;
END;

FUNCTION TCodeSignatureItem.GetParameters: TStrings;
BEGIN
  Result := FParameters;
END;

PROCEDURE TCodeSignatureItems.AddItem(CONST AName: STRING; CONST AParameters: ARRAY OF STRING;
  CONST ADetail: STRING);
BEGIN
  Add(TCodeSignatureItem.Create(AName, AParameters, ADetail));
END;

PROCEDURE TCustomCodeCompletionProvider.GetCompletions(CONST Context: TCodeCompletionContext;
  Items: TCodeCompletionItems);
BEGIN
  IF Assigned(FOnGetCompletions) THEN
    FOnGetCompletions(Self, Context, Items);
END;

PROCEDURE TCustomCodeCompletionProvider.GetSignatureHelp(CONST Context: TCodeSignatureHelpContext;
  Items: TCodeSignatureItems);
BEGIN
  IF Assigned(FOnGetSignatureHelp) THEN
    FOnGetSignatureHelp(Self, Context, Items);
END;

CONSTRUCTOR TKeywordCompletionProvider.Create(AOwner: TComponent);
BEGIN
  INHERITED;
  FKeywords := TStringList.Create;
  FKeywords.CaseSensitive := False;
  FKeywords.Sorted := True;
  FKeywords.Duplicates := dupIgnore;
END;

DESTRUCTOR TKeywordCompletionProvider.Destroy;
BEGIN
  FKeywords.Free;
  INHERITED;
END;

PROCEDURE TKeywordCompletionProvider.SetKeywords(Value: TStrings);
BEGIN
  FKeywords.Assign(Value);
END;

FUNCTION TKeywordCompletionProvider.GetKeywords: TStrings;
BEGIN
  Result := FKeywords;
END;

PROCEDURE TKeywordCompletionProvider.GetCompletions(CONST Context: TCodeCompletionContext;
  Items: TCodeCompletionItems);
VAR
  Keyword           : STRING;
BEGIN
  INHERITED;
  FOR Keyword IN FKeywords DO
    IF (Context.Prefix = '') OR StartsText(Context.Prefix, Keyword) THEN
      Items.AddItem(Keyword, Keyword, ckKeyword);
END;

END.

