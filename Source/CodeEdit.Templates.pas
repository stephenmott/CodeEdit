unit CodeEdit.Templates;

interface

uses
  System.Classes,
  System.Generics.Collections;

type
  // A reusable block of code inserted via Ctrl+J. The Name is what the user
  // types to select it; Language ('' = any) ties it to a highlighter's
  // LanguageName. In Code, '|' marks where the caret lands after insertion
  // and '||' produces a literal '|'.
  TCodeTemplate = class(TCollectionItem)
  private
    FName: string;
    FDescription: string;
    FLanguage: string;
    FCode: TStringList;
    function GetCode: TStrings;
    procedure SetCode(Value: TStrings);
  protected
    function GetDisplayName: string; override;
  public
    constructor Create(Collection: TCollection); override;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
    function MatchesLanguage(const ALanguage: string): Boolean;
  published
    property Name: string read FName write FName;
    property Description: string read FDescription write FDescription;
    property Language: string read FLanguage write FLanguage;
    property Code: TStrings read GetCode write SetCode;
  end;

  TCodeTemplates = class(TOwnedCollection)
  private
    function GetItem(Index: Integer): TCodeTemplate;
    procedure SetItem(Index: Integer; Value: TCodeTemplate);
  public
    constructor Create(AOwner: TPersistent);
    function Add: TCodeTemplate;
    function AddTemplate(const AName, ADescription, ALanguage, ACode: string): TCodeTemplate;
    function FindByName(const AName, ALanguage: string): TCodeTemplate;
    // Fills AList with templates for ALanguage ('' = any) whose name starts
    // with APrefix ('' = all), sorted by name.
    procedure GetMatching(const ALanguage, APrefix: string; AList: TList<TCodeTemplate>);
    property Items[Index: Integer]: TCodeTemplate read GetItem write SetItem; default;
  end;

  TCodeTemplateProvider = class(TComponent)
  private
    FTemplates: TCodeTemplates;
    procedure SetTemplates(Value: TCodeTemplates);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure GetTemplates(const ALanguage, APrefix: string; AList: TList<TCodeTemplate>); virtual;
    procedure LoadFromFile(const FileName: string);
    procedure SaveToFile(const FileName: string);
    procedure LoadFromStream(Stream: TStream);
    procedure SaveToStream(Stream: TStream);
  published
    property Templates: TCodeTemplates read FTemplates write SetTemplates;
  end;

// Applies AIndent to every line after the first and resolves the caret
// marker: the first unescaped '|' is removed and reported in ACaretLine /
// ACaretColumn (0-based offsets within the returned text); '||' becomes a
// literal '|'. One trailing line break is dropped so TStrings.Text round-trips
// without appending an empty line.
function ExpandCodeTemplate(const ATemplateText, AIndent: string;
  out ACaretLine, ACaretColumn: Integer; out AHasCaret: Boolean): string;

implementation

uses
  System.Generics.Defaults,
  System.JSON,
  System.StrUtils,
  System.SysUtils;

function ExpandCodeTemplate(const ATemplateText, AIndent: string;
  out ACaretLine, ACaretColumn: Integer; out AHasCaret: Boolean): string;
var
  Text: string;
  Lines: TStringList;
  Line: string;
  Builder: TStringBuilder;
  Column: Integer;
  I, J: Integer;
begin
  ACaretLine := 0;
  ACaretColumn := 0;
  AHasCaret := False;

  Text := StringReplace(ATemplateText, #13#10, #10, [rfReplaceAll]);
  Text := StringReplace(Text, #13, #10, [rfReplaceAll]);
  if (Text <> '') and (Text[Length(Text)] = #10) then
    SetLength(Text, Length(Text) - 1);

  Lines := TStringList.Create;
  Builder := TStringBuilder.Create;
  try
    Lines.LineBreak := #10;
    Lines.Text := Text;
    if Lines.Count = 0 then
      Lines.Add('');

    for I := 0 to Lines.Count - 1 do
    begin
      Line := Lines[I];
      Column := 0;
      if I > 0 then
      begin
        Builder.Append(sLineBreak);
        Builder.Append(AIndent);
        Column := Length(AIndent);
      end;

      J := 1;
      while J <= Length(Line) do
      begin
        if Line[J] = '|' then
        begin
          if (J < Length(Line)) and (Line[J + 1] = '|') then
          begin
            Builder.Append('|');
            Inc(Column);
            Inc(J, 2);
            Continue;
          end;
          if not AHasCaret then
          begin
            AHasCaret := True;
            ACaretLine := I;
            ACaretColumn := Column;
          end
          else
          begin
            Builder.Append('|');
            Inc(Column);
          end;
          Inc(J);
          Continue;
        end;
        Builder.Append(Line[J]);
        Inc(Column);
        Inc(J);
      end;
    end;
    Result := Builder.ToString;
  finally
    Builder.Free;
    Lines.Free;
  end;
end;

{ TCodeTemplate }

constructor TCodeTemplate.Create(Collection: TCollection);
begin
  inherited;
  FCode := TStringList.Create;
end;

destructor TCodeTemplate.Destroy;
begin
  FCode.Free;
  inherited;
end;

procedure TCodeTemplate.Assign(Source: TPersistent);
begin
  if Source is TCodeTemplate then
  begin
    FName := TCodeTemplate(Source).FName;
    FDescription := TCodeTemplate(Source).FDescription;
    FLanguage := TCodeTemplate(Source).FLanguage;
    FCode.Assign(TCodeTemplate(Source).FCode);
  end
  else
    inherited;
end;

function TCodeTemplate.GetDisplayName: string;
begin
  Result := FName;
  if FLanguage <> '' then
    Result := Result + ' (' + FLanguage + ')';
  if Result = '' then
    Result := inherited GetDisplayName;
end;

function TCodeTemplate.GetCode: TStrings;
begin
  Result := FCode;
end;

procedure TCodeTemplate.SetCode(Value: TStrings);
begin
  FCode.Assign(Value);
end;

function TCodeTemplate.MatchesLanguage(const ALanguage: string): Boolean;
begin
  Result := (FLanguage = '') or (ALanguage = '') or SameText(FLanguage, ALanguage);
end;

{ TCodeTemplates }

constructor TCodeTemplates.Create(AOwner: TPersistent);
begin
  inherited Create(AOwner, TCodeTemplate);
end;

function TCodeTemplates.GetItem(Index: Integer): TCodeTemplate;
begin
  Result := TCodeTemplate(inherited Items[Index]);
end;

procedure TCodeTemplates.SetItem(Index: Integer; Value: TCodeTemplate);
begin
  inherited Items[Index] := Value;
end;

function TCodeTemplates.Add: TCodeTemplate;
begin
  Result := TCodeTemplate(inherited Add);
end;

function TCodeTemplates.AddTemplate(const AName, ADescription, ALanguage,
  ACode: string): TCodeTemplate;
begin
  Result := Add;
  Result.Name := AName;
  Result.Description := ADescription;
  Result.Language := ALanguage;
  Result.Code.Text := ACode;
end;

function TCodeTemplates.FindByName(const AName, ALanguage: string): TCodeTemplate;
var
  I: Integer;
begin
  for I := 0 to Count - 1 do
    if SameText(Items[I].Name, AName) and Items[I].MatchesLanguage(ALanguage) then
      Exit(Items[I]);
  Result := nil;
end;

procedure TCodeTemplates.GetMatching(const ALanguage, APrefix: string;
  AList: TList<TCodeTemplate>);
var
  I: Integer;
  Item: TCodeTemplate;
begin
  for I := 0 to Count - 1 do
  begin
    Item := Items[I];
    if Item.MatchesLanguage(ALanguage) and
      ((APrefix = '') or StartsText(APrefix, Item.Name)) then
      AList.Add(Item);
  end;

  AList.Sort(TComparer<TCodeTemplate>.Construct(
    function(const Left, Right: TCodeTemplate): Integer
    begin
      Result := CompareText(Left.Name, Right.Name);
    end));
end;

{ TCodeTemplateProvider }

constructor TCodeTemplateProvider.Create(AOwner: TComponent);
begin
  inherited;
  FTemplates := TCodeTemplates.Create(Self);
end;

destructor TCodeTemplateProvider.Destroy;
begin
  FTemplates.Free;
  inherited;
end;

procedure TCodeTemplateProvider.SetTemplates(Value: TCodeTemplates);
begin
  FTemplates.Assign(Value);
end;

procedure TCodeTemplateProvider.GetTemplates(const ALanguage, APrefix: string;
  AList: TList<TCodeTemplate>);
begin
  FTemplates.GetMatching(ALanguage, APrefix, AList);
end;

procedure TCodeTemplateProvider.SaveToStream(Stream: TStream);
var
  Root: TJSONObject;
  Arr: TJSONArray;
  Obj: TJSONObject;
  I: Integer;
  Bytes: TBytes;
begin
  Root := TJSONObject.Create;
  try
    Arr := TJSONArray.Create;
    Root.AddPair('templates', Arr);
    for I := 0 to FTemplates.Count - 1 do
    begin
      Obj := TJSONObject.Create;
      Obj.AddPair('name', FTemplates[I].Name);
      Obj.AddPair('description', FTemplates[I].Description);
      Obj.AddPair('language', FTemplates[I].Language);
      Obj.AddPair('code', FTemplates[I].Code.Text);
      Arr.AddElement(Obj);
    end;
    Bytes := TEncoding.UTF8.GetBytes(Root.Format(2));
    Stream.WriteBuffer(Bytes, Length(Bytes));
  finally
    Root.Free;
  end;
end;

procedure TCodeTemplateProvider.LoadFromStream(Stream: TStream);
var
  Bytes: TBytes;
  Value: TJSONValue;
  Arr: TJSONArray;
  Obj: TJSONObject;
  Element: TJSONValue;
  Item: TCodeTemplate;
begin
  SetLength(Bytes, Stream.Size - Stream.Position);
  if Length(Bytes) > 0 then
    Stream.ReadBuffer(Bytes, Length(Bytes));

  Value := TJSONObject.ParseJSONValue(TEncoding.UTF8.GetString(Bytes));
  if not Assigned(Value) then
    raise EStreamError.Create('Invalid template file: not valid JSON');
  try
    if Value is TJSONArray then
      Arr := TJSONArray(Value)
    else if (Value is TJSONObject) and
      (TJSONObject(Value).GetValue('templates') is TJSONArray) then
      Arr := TJSONArray(TJSONObject(Value).GetValue('templates'))
    else
      raise EStreamError.Create('Invalid template file: no template list found');

    FTemplates.BeginUpdate;
    try
      FTemplates.Clear;
      for Element in Arr do
        if Element is TJSONObject then
        begin
          Obj := TJSONObject(Element);
          Item := FTemplates.Add;
          Item.Name := Obj.GetValue<string>('name', '');
          Item.Description := Obj.GetValue<string>('description', '');
          Item.Language := Obj.GetValue<string>('language', '');
          Item.Code.Text := Obj.GetValue<string>('code', '');
        end;
    finally
      FTemplates.EndUpdate;
    end;
  finally
    Value.Free;
  end;
end;

procedure TCodeTemplateProvider.SaveToFile(const FileName: string);
var
  Stream: TFileStream;
begin
  Stream := TFileStream.Create(FileName, fmCreate);
  try
    SaveToStream(Stream);
  finally
    Stream.Free;
  end;
end;

procedure TCodeTemplateProvider.LoadFromFile(const FileName: string);
var
  Stream: TFileStream;
begin
  Stream := TFileStream.Create(FileName, fmOpenRead or fmShareDenyWrite);
  try
    LoadFromStream(Stream);
  finally
    Stream.Free;
  end;
end;

end.
