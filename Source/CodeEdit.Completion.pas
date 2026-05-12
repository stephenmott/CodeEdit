unit CodeEdit.Completion;

interface

uses
  System.Classes,
  System.Generics.Collections;

type
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

  TCodeCompletionContext = record
    Line: Integer;
    Column: Integer;
    Prefix: string;
    TriggerChar: Char;
    LineText: string;
    ExplicitRequest: Boolean;
  end;

  TCodeCompletionItem = class
  private
    FCaption: string;
    FDetail: string;
    FInsertText: string;
    FKind: TCodeCompletionItemKind;
  public
    constructor Create(const ACaption, AInsertText: string; AKind: TCodeCompletionItemKind = ckText;
      const ADetail: string = '');
    property Caption: string read FCaption write FCaption;
    property InsertText: string read FInsertText write FInsertText;
    property Detail: string read FDetail write FDetail;
    property Kind: TCodeCompletionItemKind read FKind write FKind;
  end;

  TCodeCompletionItems = class(TObjectList<TCodeCompletionItem>)
  public
    procedure AddItem(const ACaption, AInsertText: string; AKind: TCodeCompletionItemKind = ckText;
      const ADetail: string = '');
  end;

  TCodeCompletionEvent = procedure(Sender: TObject; const Context: TCodeCompletionContext;
    Items: TCodeCompletionItems) of object;

  TCustomCodeCompletionProvider = class(TComponent)
  private
    FOnGetCompletions: TCodeCompletionEvent;
  public
    procedure GetCompletions(const Context: TCodeCompletionContext; Items: TCodeCompletionItems); virtual;
  published
    property OnGetCompletions: TCodeCompletionEvent read FOnGetCompletions write FOnGetCompletions;
  end;

  TKeywordCompletionProvider = class(TCustomCodeCompletionProvider)
  private
    FKeywords: TStringList;
    function GetKeywords: TStrings;
    procedure SetKeywords(Value: TStrings);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure GetCompletions(const Context: TCodeCompletionContext; Items: TCodeCompletionItems); override;
  published
    property Keywords: TStrings read GetKeywords write SetKeywords;
  end;

implementation

uses
  System.StrUtils,
  System.SysUtils;

constructor TCodeCompletionItem.Create(const ACaption, AInsertText: string; AKind: TCodeCompletionItemKind;
  const ADetail: string);
begin
  inherited Create;
  FCaption := ACaption;
  FInsertText := AInsertText;
  FKind := AKind;
  FDetail := ADetail;
end;

procedure TCodeCompletionItems.AddItem(const ACaption, AInsertText: string; AKind: TCodeCompletionItemKind;
  const ADetail: string);
begin
  Add(TCodeCompletionItem.Create(ACaption, AInsertText, AKind, ADetail));
end;

procedure TCustomCodeCompletionProvider.GetCompletions(const Context: TCodeCompletionContext;
  Items: TCodeCompletionItems);
begin
  if Assigned(FOnGetCompletions) then
    FOnGetCompletions(Self, Context, Items);
end;

constructor TKeywordCompletionProvider.Create(AOwner: TComponent);
begin
  inherited;
  FKeywords := TStringList.Create;
  FKeywords.CaseSensitive := False;
  FKeywords.Sorted := True;
  FKeywords.Duplicates := dupIgnore;
end;

destructor TKeywordCompletionProvider.Destroy;
begin
  FKeywords.Free;
  inherited;
end;

procedure TKeywordCompletionProvider.SetKeywords(Value: TStrings);
begin
  FKeywords.Assign(Value);
end;

function TKeywordCompletionProvider.GetKeywords: TStrings;
begin
  Result := FKeywords;
end;

procedure TKeywordCompletionProvider.GetCompletions(const Context: TCodeCompletionContext;
  Items: TCodeCompletionItems);
var
  Keyword: string;
begin
  inherited;
  for Keyword in FKeywords do
    if (Context.Prefix = '') or StartsText(Context.Prefix, Keyword) then
      Items.AddItem(Keyword, Keyword, ckKeyword);
end;

end.
