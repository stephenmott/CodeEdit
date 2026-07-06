UNIT CodeEdit.Templates;

INTERFACE

USES
  System.Classes,
  System.Generics.Collections;

TYPE
  // A reusable block of code inserted via Ctrl+J. The Name is what the user
  // types to select it; Language ('' = any) ties it to a highlighter's
  // LanguageName. In Code, '|' marks where the caret lands after insertion
  // and '||' produces a literal '|'.
  TCodeTemplate = CLASS(TCollectionItem)
  PRIVATE
    FName: STRING;
    FDescription: STRING;
    FLanguage: STRING;
    FCode: TStringList;
    FUNCTION GetCode: TStrings;
    PROCEDURE SetCode(Value: TStrings);
  PROTECTED
    FUNCTION GetDisplayName: STRING; OVERRIDE;
  PUBLIC
    CONSTRUCTOR Create(Collection: TCollection); OVERRIDE;
    DESTRUCTOR Destroy; OVERRIDE;
    PROCEDURE Assign(Source: TPersistent); OVERRIDE;
    FUNCTION MatchesLanguage(CONST ALanguage: STRING): Boolean;
  PUBLISHED
    PROPERTY Name: STRING READ FName WRITE FName;
    PROPERTY Description: STRING READ FDescription WRITE FDescription;
    PROPERTY Language: STRING READ FLanguage WRITE FLanguage;
    PROPERTY Code: TStrings READ GetCode WRITE SetCode;
  END;

  TCodeTemplates = CLASS(TOwnedCollection)
  PRIVATE
    FUNCTION GetItem(Index: Integer): TCodeTemplate;
    PROCEDURE SetItem(Index: Integer; Value: TCodeTemplate);
  PUBLIC
    CONSTRUCTOR Create(AOwner: TPersistent);
    FUNCTION Add: TCodeTemplate;
    FUNCTION AddTemplate(CONST AName, ADescription, ALanguage, ACode: STRING): TCodeTemplate;
    FUNCTION FindByName(CONST AName, ALanguage: STRING): TCodeTemplate;
    // Fills AList with templates for ALanguage ('' = any) whose name starts
    // with APrefix ('' = all), sorted by name.
    PROCEDURE GetMatching(CONST ALanguage, APrefix: STRING; AList: TList<TCodeTemplate>);
    // JSON persistence: {"templates":[{"name","description","language","code"},...]}
    PROCEDURE LoadFromFile(CONST FileName: STRING);
    PROCEDURE SaveToFile(CONST FileName: STRING);
    PROCEDURE LoadFromStream(Stream: TStream);
    PROCEDURE SaveToStream(Stream: TStream);
    PROPERTY Items[Index: Integer]: TCodeTemplate READ GetItem WRITE SetItem; DEFAULT;
  END;

  // Two template layers: Templates holds the application's built-in set
  // (hard-coded or streamed from the DFM) and UserTemplates holds the end
  // user's own additions, persisted as JSON in UserFileName. GetTemplates
  // merges both; a user template hides a built-in one with the same name, so
  // users can also override shipped templates.
  TCodeTemplateProvider = CLASS(TComponent)
  PRIVATE
    FTemplates: TCodeTemplates;
    FUserFileName: STRING;
    FUserTemplates: TCodeTemplates;
    PROCEDURE SetTemplates(Value: TCodeTemplates);
    PROCEDURE SetUserTemplates(Value: TCodeTemplates);
  PUBLIC
    CONSTRUCTOR Create(AOwner: TComponent); OVERRIDE;
    DESTRUCTOR Destroy; OVERRIDE;
    PROCEDURE GetTemplates(CONST ALanguage, APrefix: STRING; AList: TList<TCodeTemplate>); VIRTUAL;
    // Loads UserTemplates from UserFileName; quietly does nothing when the
    // file does not exist yet (first run).
    PROCEDURE LoadUserTemplates;
    PROCEDURE SaveUserTemplates;
    // Operate on the built-in Templates collection.
    PROCEDURE LoadFromFile(CONST FileName: STRING);
    PROCEDURE SaveToFile(CONST FileName: STRING);
    PROCEDURE LoadFromStream(Stream: TStream);
    PROCEDURE SaveToStream(Stream: TStream);
    PROPERTY UserTemplates: TCodeTemplates READ FUserTemplates WRITE SetUserTemplates;
  PUBLISHED
    PROPERTY Templates: TCodeTemplates READ FTemplates WRITE SetTemplates;
    PROPERTY UserFileName: STRING READ FUserFileName WRITE FUserFileName;
  END;

// Applies AIndent to every line after the first and resolves the caret
// marker: the first unescaped '|' is removed and reported in ACaretLine /
// ACaretColumn (0-based offsets within the returned text); '||' becomes a
// literal '|'. One trailing line break is dropped so TStrings.Text round-trips
// without appending an empty line.
FUNCTION ExpandCodeTemplate(CONST ATemplateText, AIndent: STRING;
  OUT ACaretLine, ACaretColumn: Integer; OUT AHasCaret: Boolean): STRING;

IMPLEMENTATION

USES
  System.Generics.Defaults,
  System.JSON,
  System.StrUtils,
  System.SysUtils;

FUNCTION ExpandCodeTemplate(CONST ATemplateText, AIndent: STRING;
  OUT ACaretLine, ACaretColumn: Integer; OUT AHasCaret: Boolean): STRING;
VAR
  Text              : STRING;
  Lines             : TStringList;
  Line              : STRING;
  Builder           : TStringBuilder;
  Column            : Integer;
  I, J              : Integer;
BEGIN
  ACaretLine := 0;
  ACaretColumn := 0;
  AHasCaret := False;

  Text := StringReplace(ATemplateText, #13#10, #10, [rfReplaceAll]);
  Text := StringReplace(Text, #13, #10, [rfReplaceAll]);
  IF (Text <> '') AND (Text[Length(Text)] = #10) THEN
    SetLength(Text, Length(Text) - 1);

  Lines := TStringList.Create;
  Builder := TStringBuilder.Create;
  TRY
    Lines.LineBreak := #10;
    Lines.Text := Text;
    IF Lines.Count = 0 THEN
      Lines.Add('');

    FOR I := 0 TO Lines.Count - 1 DO BEGIN
      Line := Lines[I];
      Column := 0;
      IF I > 0 THEN BEGIN
        Builder.Append(sLineBreak);
        Builder.Append(AIndent);
        Column := Length(AIndent);
      END;

      J := 1;
      WHILE J <= Length(Line) DO BEGIN
        IF Line[J] = '|' THEN BEGIN
          IF (J < Length(Line)) AND (Line[J + 1] = '|') THEN BEGIN
            Builder.Append('|');
            Inc(Column);
            Inc(J, 2);
            Continue;
          END;
          IF NOT AHasCaret THEN BEGIN
            AHasCaret := True;
            ACaretLine := I;
            ACaretColumn := Column;
          END ELSE BEGIN
            Builder.Append('|');
            Inc(Column);
          END;
          Inc(J);
          Continue;
        END;
        Builder.Append(Line[J]);
        Inc(Column);
        Inc(J);
      END;
    END;
    Result := Builder.ToString;
  FINALLY
    Builder.Free;
    Lines.Free;
  END;
END;

{ TCodeTemplate }

CONSTRUCTOR TCodeTemplate.Create(Collection: TCollection);
BEGIN
  INHERITED;
  FCode := TStringList.Create;
END;

DESTRUCTOR TCodeTemplate.Destroy;
BEGIN
  FCode.Free;
  INHERITED;
END;

PROCEDURE TCodeTemplate.Assign(Source: TPersistent);
BEGIN
  IF Source IS TCodeTemplate THEN BEGIN
    FName := TCodeTemplate(Source).FName;
    FDescription := TCodeTemplate(Source).FDescription;
    FLanguage := TCodeTemplate(Source).FLanguage;
    FCode.Assign(TCodeTemplate(Source).FCode);
  END ELSE
    INHERITED;
END;

FUNCTION TCodeTemplate.GetDisplayName: STRING;
BEGIN
  Result := FName;
  IF FLanguage <> '' THEN
    Result := Result + ' (' + FLanguage + ')';
  IF Result = '' THEN
    Result := INHERITED GetDisplayName;
END;

FUNCTION TCodeTemplate.GetCode: TStrings;
BEGIN
  Result := FCode;
END;

PROCEDURE TCodeTemplate.SetCode(Value: TStrings);
BEGIN
  FCode.Assign(Value);
END;

FUNCTION TCodeTemplate.MatchesLanguage(CONST ALanguage: STRING): Boolean;
BEGIN
  Result := (FLanguage = '') OR (ALanguage = '') OR SameText(FLanguage, ALanguage);
END;

{ TCodeTemplates }

CONSTRUCTOR TCodeTemplates.Create(AOwner: TPersistent);
BEGIN
  INHERITED Create(AOwner, TCodeTemplate);
END;

FUNCTION TCodeTemplates.GetItem(Index: Integer): TCodeTemplate;
BEGIN
  Result := TCodeTemplate(INHERITED Items[Index]);
END;

PROCEDURE TCodeTemplates.SetItem(Index: Integer; Value: TCodeTemplate);
BEGIN
  INHERITED Items[Index] := Value;
END;

FUNCTION TCodeTemplates.Add: TCodeTemplate;
BEGIN
  Result := TCodeTemplate(INHERITED Add);
END;

FUNCTION TCodeTemplates.AddTemplate(CONST AName, ADescription, ALanguage,
  ACode: STRING): TCodeTemplate;
BEGIN
  Result := Add;
  Result.Name := AName;
  Result.Description := ADescription;
  Result.Language := ALanguage;
  Result.Code.Text := ACode;
END;

FUNCTION TCodeTemplates.FindByName(CONST AName, ALanguage: STRING): TCodeTemplate;
VAR
  I                 : Integer;
BEGIN
  FOR I := 0 TO Count - 1 DO
    IF SameText(Items[I].Name, AName) AND Items[I].MatchesLanguage(ALanguage) THEN
      Exit(Items[I]);
  Result := NIL;
END;

PROCEDURE SortTemplatesByName(AList: TList<TCodeTemplate>);
BEGIN
  AList.Sort(TComparer<TCodeTemplate>.Construct(
    FUNCTION(CONST Left, Right: TCodeTemplate): Integer
    BEGIN
      Result := CompareText(Left.Name, Right.Name);
    END));
END;

PROCEDURE TCodeTemplates.GetMatching(CONST ALanguage, APrefix: STRING;
  AList: TList<TCodeTemplate>);
VAR
  I                 : Integer;
  Item              : TCodeTemplate;
BEGIN
  FOR I := 0 TO Count - 1 DO BEGIN
    Item := Items[I];
    IF Item.MatchesLanguage(ALanguage) AND
      ((APrefix = '') OR StartsText(APrefix, Item.Name)) THEN
      AList.Add(Item);
  END;

  SortTemplatesByName(AList);
END;

PROCEDURE TCodeTemplates.SaveToStream(Stream: TStream);
VAR
  Root              : TJSONObject;
  Arr               : TJSONArray;
  Obj               : TJSONObject;
  I                 : Integer;
  Bytes             : TBytes;
BEGIN
  Root := TJSONObject.Create;
  TRY
    Arr := TJSONArray.Create;
    Root.AddPair('templates', Arr);
    FOR I := 0 TO Count - 1 DO BEGIN
      Obj := TJSONObject.Create;
      Obj.AddPair('name', Items[I].Name);
      Obj.AddPair('description', Items[I].Description);
      Obj.AddPair('language', Items[I].Language);
      Obj.AddPair('code', Items[I].Code.Text);
      Arr.AddElement(Obj);
    END;
    Bytes := TEncoding.UTF8.GetBytes(Root.Format(2));
    Stream.WriteBuffer(Bytes, Length(Bytes));
  FINALLY
    Root.Free;
  END;
END;

PROCEDURE TCodeTemplates.LoadFromStream(Stream: TStream);
VAR
  Bytes             : TBytes;
  Value             : TJSONValue;
  Arr               : TJSONArray;
  Obj               : TJSONObject;
  Element           : TJSONValue;
  Item              : TCodeTemplate;
BEGIN
  SetLength(Bytes, Stream.Size - Stream.Position);
  IF Length(Bytes) > 0 THEN
    Stream.ReadBuffer(Bytes, Length(Bytes));

  Value := TJSONObject.ParseJSONValue(TEncoding.UTF8.GetString(Bytes));
  IF NOT Assigned(Value) THEN
    RAISE EStreamError.Create('Invalid template file: not valid JSON');
  TRY
    IF Value IS TJSONArray THEN
      Arr := TJSONArray(Value)
    ELSE IF (Value IS TJSONObject) AND
      (TJSONObject(Value).GetValue('templates') IS TJSONArray) THEN
      Arr := TJSONArray(TJSONObject(Value).GetValue('templates'))
    ELSE
      RAISE EStreamError.Create('Invalid template file: no template list found');

    BeginUpdate;
    TRY
      Clear;
      FOR Element IN Arr DO
        IF Element IS TJSONObject THEN BEGIN
          Obj := TJSONObject(Element);
          Item := Add;
          Item.Name := Obj.GetValue<STRING>('name', '');
          Item.Description := Obj.GetValue<STRING>('description', '');
          Item.Language := Obj.GetValue<STRING>('language', '');
          Item.Code.Text := Obj.GetValue<STRING>('code', '');
        END;
    FINALLY
      EndUpdate;
    END;
  FINALLY
    Value.Free;
  END;
END;

PROCEDURE TCodeTemplates.SaveToFile(CONST FileName: STRING);
VAR
  Stream            : TFileStream;
BEGIN
  Stream := TFileStream.Create(FileName, fmCreate);
  TRY
    SaveToStream(Stream);
  FINALLY
    Stream.Free;
  END;
END;

PROCEDURE TCodeTemplates.LoadFromFile(CONST FileName: STRING);
VAR
  Stream            : TFileStream;
BEGIN
  Stream := TFileStream.Create(FileName, fmOpenRead OR fmShareDenyWrite);
  TRY
    LoadFromStream(Stream);
  FINALLY
    Stream.Free;
  END;
END;

{ TCodeTemplateProvider }

CONSTRUCTOR TCodeTemplateProvider.Create(AOwner: TComponent);
BEGIN
  INHERITED;
  FTemplates := TCodeTemplates.Create(Self);
  FUserTemplates := TCodeTemplates.Create(Self);
END;

DESTRUCTOR TCodeTemplateProvider.Destroy;
BEGIN
  FUserTemplates.Free;
  FTemplates.Free;
  INHERITED;
END;

PROCEDURE TCodeTemplateProvider.SetTemplates(Value: TCodeTemplates);
BEGIN
  FTemplates.Assign(Value);
END;

PROCEDURE TCodeTemplateProvider.SetUserTemplates(Value: TCodeTemplates);
BEGIN
  FUserTemplates.Assign(Value);
END;

PROCEDURE TCodeTemplateProvider.GetTemplates(CONST ALanguage, APrefix: STRING;
  AList: TList<TCodeTemplate>);
VAR
  UserMatches       : TList<TCodeTemplate>;
  BuiltInMatches    : TList<TCodeTemplate>;
  Item              : TCodeTemplate;
  UserItem          : TCodeTemplate;
  Hidden            : Boolean;
BEGIN
  UserMatches := TList<TCodeTemplate>.Create;
  BuiltInMatches := TList<TCodeTemplate>.Create;
  TRY
    FUserTemplates.GetMatching(ALanguage, APrefix, UserMatches);
    FTemplates.GetMatching(ALanguage, APrefix, BuiltInMatches);

    AList.AddRange(UserMatches);
    FOR Item IN BuiltInMatches DO BEGIN
      Hidden := False;
      FOR UserItem IN UserMatches DO
        IF SameText(UserItem.Name, Item.Name) THEN BEGIN
          Hidden := True;
          Break;
        END;
      IF NOT Hidden THEN
        AList.Add(Item);
    END;

    SortTemplatesByName(AList);
  FINALLY
    BuiltInMatches.Free;
    UserMatches.Free;
  END;
END;

PROCEDURE TCodeTemplateProvider.LoadUserTemplates;
BEGIN
  IF (FUserFileName <> '') AND FileExists(FUserFileName) THEN
    FUserTemplates.LoadFromFile(FUserFileName);
END;

PROCEDURE TCodeTemplateProvider.SaveUserTemplates;
BEGIN
  IF FUserFileName = '' THEN
    RAISE EStreamError.Create('Cannot save user templates: UserFileName is not set');
  FUserTemplates.SaveToFile(FUserFileName);
END;

PROCEDURE TCodeTemplateProvider.SaveToStream(Stream: TStream);
BEGIN
  FTemplates.SaveToStream(Stream);
END;

PROCEDURE TCodeTemplateProvider.LoadFromStream(Stream: TStream);
BEGIN
  FTemplates.LoadFromStream(Stream);
END;

PROCEDURE TCodeTemplateProvider.SaveToFile(CONST FileName: STRING);
BEGIN
  FTemplates.SaveToFile(FileName);
END;

PROCEDURE TCodeTemplateProvider.LoadFromFile(CONST FileName: STRING);
BEGIN
  FTemplates.LoadFromFile(FileName);
END;

END.

