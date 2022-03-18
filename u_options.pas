unit u_options;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, paramstorage, Graphics, fgl;

type

  TDayTimes = array [1..12] of string; //времена начала и конца

  //ДЛЯ ХРАНЕНИЯ РАСКРАСКИ сеток
  TCellParams = record
    FBackColor:TColor;
    FFontColor:TColor;
    FFontFlags:TFontStyles;
    FTypeStr:string;
  end;

  TDayType = (dtUnk, dtNightFirst, dtNightLast, dtDay, dtOHT, dtTU,
    dtOtp, dtZam, dtVih, dtMP, dt2Night, dtOther, dtFV, dtEzhedn, dtMed, dtLearn,
    dtLine, dtLocked, dtDisease);

  TDayTypes = set of TDayType;

  //инфа о дне работы
  TDayItem = record
    FHours:string;   //часы или что то строковое
    FType:TDayType;  // тип дня работы
  end;


  TDayStyles = array [TDayType] of TCellParams;

  THoursMap = specialize TFPGMap<string,string>;//на входе буква в клеточке, на выходе время

  TWorkHours = array [TDayType] of THoursMap;

  //actions in editor
  TEditAction = record
    Caption:string;
    HotKey:TShortCut;
    Acion:string;
    Use:boolean;
    ShowQInput:boolean;
  end;

  TActions = array of TEditAction;


  //списки доп строк и столбцов храним в коллекциях такого типа
  //и редактируем в одной форме
  TUsedHours = record
    DayType:TDayType;
    UsedHours:Integer;
  end;

  //тип для хранения инфы экспорта в старый формат

  { TOEItem }

  TOEItem = class (TCollectionItem)
    private
      FDayType: TDayType;
      FExported: boolean;
      FOtherStr: string;
      FUseBG: boolean;
      FUSeFont: boolean;
      FUseStr: boolean;
      function GetName: string;
    public
      property Name:string read GetName;
      constructor Create(ACollection: TCollection); override;
    published
      property AType:TDayType read FDayType write FDayType;
      property Exported:boolean read FExported write FExported;
      property UseBG:boolean read FUseBG write FUseBG;
      property USeFont:boolean read FUSeFont write FUSeFont;
      property UseStr:boolean read FUseStr write FUseStr;
      property OtherStr:string read FOtherStr write FOtherStr;
  end;

  { TOECollection }

  TOECollection = class (TCollection)
    private
      function GetItems(AIndex: Integer): TOEItem;
    public
      property Items[AIndex:Integer]:TOEItem read GetItems;
  end;


  {на элекмент каждого типа, у которого количество учитываемых  часов отичается от
  количества заданных часов, заводим элемент массива. если количество заданных
  совпадает с количеством используемых, то ничего не заводим. это нужно только для
  того, чтобы верно считались ночные часы
  можно вообще плюнуть и хранить в каждой ячейке время начала и конца, как в R3,
  и вводить их так же
  может и переделаю как-нибудь
  нет, хрен кто их будет вводить, в том числе и я, нужна привязка к типам ячеек}
  TUsedArray = array of TUsedHours;

  { TExtraItem }

  TExtraItem = class (TCollectionItem)
    private
      FDayTypes: TDayTypes;
      FLongName: string;
      FShortName: string;
      FUseCount: boolean;
      FVisible: boolean;
      FUsedArray:TUsedArray;
      function GetHoursOfType(AType: TDayType): Integer;
      function GetSavedHours: string;
      procedure SetHoursOfType(AType: TDayType; AValue: Integer);
      procedure SetSavedHours(AValue: string);
      function GetTypeIndex(AType:TDayType):Integer;
    public
      constructor Create(ACollection: TCollection); override;
      destructor Destroy; override;
      function GetUsedHoursOfTypeDef(AItem:TDayItem;IsWeekend:boolean):Integer;//по типу дня возвращает количество учитываемых в данном правиле часов.
      property HoursOfType[AType:TDayType]:Integer read GetHoursOfType write SetHoursOfType;//0, if not used or used hours from day info
    published
      property ShortName:string read FShortName write FShortName;
      property LongName:string read FLongName write FLongName;
      property DayTypes:TDayTypes read FDayTypes write FDayTypes;
      property Visible:boolean read FVisible write FVisible;  //это меняется в сетке при ее редактировании из менюшки
      property SavedHours:string read GetSavedHours write SetSavedHours ;//only for read/write in ini
      property UseCount:boolean read FUseCount write FUseCount;//if true, use not a hours, only count of days  with this types
  end;

  { TExtraCollection }

  TExtraCollection = class (TCollection)
    private
      function GetExtraItem(Index: Integer): TExtraItem;
      function GetVisibleCount: Integer;
      function GetVisiblies(AIndex: Integer): TExtraItem;
    public
      property VisibleCount:Integer read GetVisibleCount;
      property Visiblies[AIndex:Integer]:TExtraItem read GetVisiblies;
      property Items[Index:Integer]:TExtraItem read GetExtraItem;
  end;

  { TOnlyTextItem }

  TOnlyTextItem = class(TCollectionItem)
    private
      FTxt: string;
      FUse: boolean;
    published
      property Use:boolean read FUse write FUse;
      property Txt:string read FTxt write FTxt;
  end;

  { TOnlyTextCollection }

  TOnlyTextCollection = class(TCollection)
    private
      function GetItems(AIndex: TDayType): TOnlyTextItem;
    public
      property Items[AIndex:TDayType]:TOnlyTextItem read GetItems;default;
  end;




  { TOptions }

  TOptions = class (TCustomPropStorage)
    private
      FAlwaysUseHours: boolean;
      FDaysLine: Integer;
      FDefDataDir: string;
      FDefImpMonth: integer;
      FDefImpYear: integer;
      FDefWorkerCount: Integer;
      FExtraCols: TExtraCollection;
      FExtraRows: TExtraCollection;
      FFirstDay: Integer;
      FFirstWorker: Integer;
      FgColSM: TColor;
      FgColVih: TColor;
      FgDefColWidth: integer;
      FgDefRowHeight: integer;
      FgFirstCol: integer;
      FgFontName: string;
      FgFontSize: Integer;
      FgSetOnlyUnk: boolean;
      FgShowDefChars: boolean;
      FgShowMP: boolean;
      FgTSSM: string;
      FOEDayRules: TOECollection;
      FsCols: string;
      FUseWeekendColors: boolean;
      FxFirstCol: integer;
      FxFirstRow: Integer;
      FxMansCol: Integer;
      FxMansColName: Integer;
      FxMansColTime: Integer;
      FxMansRow: integer;
      FxTextOnly: TOnlyTextCollection;
      function GetTypeCodes(AType: TDayType): string;
      function GetTypeNames(AType: TDayType): string;
    public
      FDayStyles:TDayStyles;
      FWorkHours:TWorkHours;
      FWorkerList:TStringList;
      FActions:TActions;
      FFolders:TStringList;
      FFiles:TStringList;
      FMRUList:TStringList;
      constructor Create(AFileName:string);override;
      destructor Destroy;override;
      procedure Load;override;
      procedure Save;override;
      procedure LoadHoursMap(ADayType:TDayType;AData:TStrings);
      procedure SaveHoursMap(ADayType:TDayType;AData:TStrings);
      function CellParamsToString(AParams:TCellParams):String;
      procedure StrToCellParams(AData:string;var AParams:TCellParams);
      property TypeNames[AType:TDayType]:string read GetTypeNames;
      property TypeCodes[AType:TDayType]:string read GetTypeCodes;


    published
      //imp-exp to old format
      property DaysLine:Integer read FDaysLine write FDaysLine;
      property FirstWorker:Integer read FFirstWorker write FFirstWorker;
      property FirstDay:Integer read FFirstDay write FFirstDay;
      property UseWeekendColors:boolean read FUseWeekendColors write FUseWeekendColors;
      property OEDayRules:TOECollection read FOEDayRules;
      property AlwaysUseHours:boolean read FAlwaysUseHours write FAlwaysUseHours;
      //date
      //view Sg options
      property gShowMP:boolean read FgShowMP write FgShowMP;//показывать ли мп
      property gShowDefChars:boolean read FgShowDefChars write FgShowDefChars;//показывать буквы определенных элементов
      property gSetOnlyUnk:boolean read FgSetOnlyUnk write FgSetOnlyUnk;//устанавливать только неизвестные дни
      property gDefRowHeight:Integer read FgDefRowHeight write FgDefRowHeight;//высота строки
      property gDefColWidth:Integer read FgDefColWidth write FgDefColWidth;//ширина строк
      property gFirstCol:integer read FgFirstCol write FgFirstCol;//ширина первой строки
      property gFontName:string read FgFontName write FgFontName;
      property gFontSize:Integer read FgFontSize write FgFontSize;
      //список доп колонок (суммарных)
      property gExtraCols:TExtraCollection read FExtraCols;
      property gExtraRows:TExtraCollection read FExtraRows;
      //export opts
      property xFirstCol:integer read FxFirstCol write FxFirstCol;
      property xFirstRow:Integer read FxFirstRow write FxFirstRow;
      property xMansRow:integer read FxMansRow write FxMansRow;
      property xMansCol:Integer read FxMansCol write FxMansCol;
      property xMansColTime:Integer read FxMansColTime write FxMansColTime;
      property xMansColName:Integer read FxMansColName write FxMansColName;
      property xTextOnly:TOnlyTextCollection read FxTextOnly;

      //это используется при импорте из старого экселя
      property DefWorkerCount:Integer read FDefWorkerCount write FDefWorkerCount;

      //дата импорта
      property DefImpYear:Integer read FDefImpYear write FDefImpYear;
      property DefImpMonth:Integer read FDefImpMonth write FDefImpMonth;
      //прочие цвета
      property gColVih:TColor read FgColVih write FgColVih;//цвет выходных
      property gColSM:TColor read FgColSM write FgColSM; // цвет чет смены
      property gTSSM:string read FgTSSM write FgTSSM;//люди, которые будут подсвечиватья цветом чет смены
      //этот параметр используется для нового графика, ели график уже есть, то оно хранится в нем


      property DefDataDir:string  read FDefDataDir write FDefDataDir;
      property sCols:string read FsCols write FsCols;//колонки для суммированного учета


  end;


const
  StrTypes : array [TDayType] of string = ('U','NF','NL','D','O','T','OT',
    'Z','B','MP','4 8', 'A','F','E','M','U','L','R','Б');
  TypeText : array [TDayType] of string = ('Не задано','Начало ночь','Конец ночь',
    'Смена день','Охрана труда','Tехучеба','Отпуск','Замещение','Bыходной','Межсменный промежуток',
    'С ночи в ночь', 'Прочее','Фактич. выходной','Ежедневная работа','Медкомиссия',
    'Обучение','Выезд на линию','Зарезервировано', 'Больничный');

function Options:TOptions;

implementation

uses s_tools;

var FOptions:TOptions;

function Options: TOptions;
begin
  if FOptions=nil then
    FOptions:=TOptions.Create('');
  Result:=FOptions;
end;

{ TOnlyTextCollection }

function TOnlyTextCollection.GetItems(AIndex: TDayType): TOnlyTextItem;
begin
  Result:=TOnlyTextItem(inherited Items[Integer(AIndex)]);
end;

{ TOECollection }

function TOECollection.GetItems(AIndex: Integer): TOEItem;
begin
  Result:=TOEItem(inherited Items[AIndex]);
end;

{ TOEItem }

function TOEItem.GetName: string;
begin
  Result:=TypeText[FDayType];
end;

constructor TOEItem.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  FDayType:=dtUnk;
  FExported:=False;
  FOtherStr:='';
  FUseBG:=False;
  FUSeFont:=False;
end;

{ TExtraItem }

function TExtraItem.GetSavedHours: string;
var
  I: Integer;
begin
  //преоборазуем FUsedHours в строку вида тип!часы|тип!часы
  Result:='';
  for I:=Low(FUsedArray) to High(FUsedArray) do
    Result:=StrListAdd(Result,IntToStr(Integer(FUsedArray[I].DayType))+'!'+IntToStr(FUsedArray[I].UsedHours),'|');
end;

function TExtraItem.GetHoursOfType(AType: TDayType): Integer;
var
  I: Integer;
begin
  Result:=0;
  I:=GetTypeIndex(AType);
  if I=-1 then Exit;
  Result:=FUsedArray[I].UsedHours;
end;

procedure TExtraItem.SetHoursOfType(AType: TDayType; AValue: Integer);
var
  I: Integer;
begin
  I:=GetTypeIndex(AType);
  if I=-1 then begin //не найден элемент
    if AValue<>0 then begin //нвые часы не нравны 0, заводим новый элемент
      SetLength(FUsedArray,Length(FUsedArray)+1);
      FUsedArray[High(FUsedArray)].UsedHours:=AValue;
      FUsedArray[High(FUsedArray)].DayType:=AType;
    end;
  end else //элемент найден
    if AValue=0 then begin //delete old item, часы равны 0
      Delete(FUsedArray,I,1);
    end else begin
      FUsedArray[I].UsedHours:=AValue; // обновляем часы
    end;
end;

procedure TExtraItem.SetSavedHours(AValue: string);
var S:string;
begin
  while AValue<>'' do begin
    SetLength(FUsedArray,Length(FUsedArray)+1);
    S:=DivStr(AValue,'|');
    FUsedArray[High(FUsedArray)].DayType:=TDayType(StrToInt(DivStr(S,'!')));
    FUsedArray[High(FUsedArray)].UsedHours:=StrToInt(S);
  end;
end;

function TExtraItem.GetTypeIndex(AType: TDayType): Integer;
var
  I: Integer;
begin
  Result:=-1;
  if High(FUsedArray)=0 then Exit;
  for I:=Low(FUsedArray) to High(FUsedArray) do
    if FUsedArray[I].DayType=AType then begin
      Result:=I;
      Exit;
    end;
end;

function TExtraItem.GetUsedHoursOfTypeDef(AItem: TDayItem; IsWeekend: boolean
  ): Integer;
var I:Integer;
begin
  //пока ложим на Weekend
{  смотрим, если тип нашего дня есть в поддерживаемых, то извлекаем
  число из Hours. Если FUsedArray не пустой, то смотрим, если наш тип есть там, то используем число из этого типа}
  Result:=0;
  if not (AItem.FType in FDayTypes) then begin
    Exit;
  end;
  if FUseCount then begin
    Result:=1;
    Exit;
  end;
  if Length(FUsedArray)<>0 then begin
    for I:=Low(FUsedArray) to High(FUsedArray) do begin
      if FUsedArray[I].DayType=AItem.FType then begin
        Result:=FUsedArray[I].UsedHours;
        Exit;
      end;
    end;
  end;
  if IsNumber(AItem.FHours) then
    Result:=StrToInt(AItem.FHours);
end;

constructor TExtraItem.Create(ACollection: TCollection);
begin
  inherited;
  SetLength(FUsedArray,0);
end;

destructor TExtraItem.Destroy;
begin
  SetLength(FUsedArray,0);
  inherited Destroy;
end;

{ TExtraCollection }

function TExtraCollection.GetExtraItem(Index: Integer): TExtraItem;
begin
  Result:=TExtraItem(inherited Items[Index]);
end;

function TExtraCollection.GetVisibleCount: Integer;
var I:Integer;
begin
  Result:=0;
  for I:=0 to Count-1 do
    if Items[I].Visible then Inc(Result);
end;

function TExtraCollection.GetVisiblies(AIndex: Integer): TExtraItem;
var I,J:Integer;
begin
  Result:=nil;
  J:=0;
  for I:=0 to Count-1 do begin
    if Items[I].Visible then begin
      if AIndex=J then begin
        Result:=Items[I];
        Break;
      end else
        Inc(J);
    end;
  end;
end;



{ TOptions }

function TOptions.GetTypeCodes(AType: TDayType): string;
begin
  Result:=StrTypes[AType];
end;

function TOptions.GetTypeNames(AType: TDayType): string;
begin
  Result:=TypeText[AType];
end;

constructor TOptions.Create(AFileName: string);
var dt:TDayType;
    I:Integer;
begin
  for dt := Low(TDayType) to High(TDayType) do begin
    FWorkHours[dt]:=THoursMap.Create;
    FWorkHours[dt].Sorted:=True;
  end;
  for I:=1 to 12 do
    FWorkHours[dtDay].Add(IntToStr(I),'7:30-'+IntToStr(7+I)+':30');

  FWorkHours[dtNightFirst].Add('4','19:30-24:00');
  FWorkHours[dtNightLast].Add('8','00:00-7:30');
  FWorkHours[dtFV].Add('ФВ','');
  FWorkHours[dtVih].Add('В','');
  FWorkHours[dtMP].Add('МП','');

  gShowDefChars:=True;
  gShowMP:=False;
  gDefColWidth:=70;
  gDefRowHeight:=38;
  gSetOnlyUnk:=True;
  gFirstCol:=250;
  gFontSize:=16;
  gFontName:='';

  xFirstCol:=2;
  xFirstRow:=18;
  xMansRow:=85;
  xMansCol:=2;
  FDefImpYear:=2021;
  FDefImpMonth:=5;
  FDefWorkerCount:=18;
  for dt:=Low(TDayType) to High(TDayType) do begin
    FDayStyles[dt].FFontColor:=clBlack;
    FDayStyles[dt].FBackColor:=clWhite;
    FDayStyles[dt].FFontFlags:=[];
    FDayStyles[dt].FTypeStr:='';
  end;
  FWorkerList:=TStringList.Create;
  FgColVih:=TColor($e9e9e9);
  FgColSM:=TColor($f2f2f2);
  FgTSSM:='';
  FExtraCols:=TExtraCollection.Create(TExtraItem);
  FExtraRows:=TExtraCollection.Create(TExtraItem);
  FOEDayRules:=TOECollection.Create(TOEItem);
  FFolders:=TStringList.Create;
  FFiles:=TStringList.Create;
  FMRUList:=TStringList.Create;
  FxTextOnly:=TOnlyTextCollection.Create(TOnlyTextItem);
  inherited Create(AFileName);
end;

destructor TOptions.Destroy;
var dt:TDayType;
begin
  for dt:=Low(TDayType) to High(TDayType)
    do FWorkHours[dt].Free;
  inherited Destroy;
  //тут всю фигню добавить, что в конструкторе создана
  FWorkerList.Free;
  FxTextOnly.Free;
end;

procedure TOptions.Load;
var SL:TStringList;
    I:Integer;
    dt: TDayType;
    S:string;
    T:TOnlyTextItem;
begin
  inherited Load;
  SL:=TStringList.Create;
  LoadStrings('workers',FWorkerList);
  for dt:=Low(TDayType) to High(TDayType) do begin
    SL.Clear;
    LoadStrings('dayhours'+IntToStr(Integer(dt)),SL);
    LoadHoursMap(dt,SL);
  end;
  SL.Clear;
  LoadStrings('daystyles',SL);
  for I:=0 to SL.Count-1 do begin
    if TDayType(I)>High(TDayType) then Break;
    StrToCellParams(SL[I],FDayStyles[TDayType(I)]);
  end;
  SL.Clear;
  LoadStrings('actions',SL);
  SetLength(FActions,SL.Count);
  for I:=0 to SL.Count-1 do begin
    S:=SL[I];
    FActions[I].Caption:=DivStr(S,'@');
    FActions[I].HotKey:=TShortCut(StrToInt(DivStr(S,'@')));
    FActions[I].Acion:=DivStr(S,'@');
    FActions[I].Use:=Boolean(StrToIntDef(DivStr(S,'@'),1));
    FActions[I].ShowQInput:=Boolean(StrToIntDef(DivStr(S,'@'),1));
  end;
  LoadStrings('files',FFiles);
  LoadStrings('folders',FFolders);
  LoadStrings('mru',FMRUList);
  SL.Free;
  ///!!!либо это надо делать после загрузки этой коллекции, добивая до нужного количества
  ///!!либо переделать саму загрузку коллекций в базовом классе

  while FxTextOnly.Count-1<Integer(High(TDayType)) do begin
    T:=TOnlyTextItem(FxTextOnly.Add);
    T.Use:=False;
    T.Txt:='';
  end;
end;

procedure TOptions.Save;
var SL:TStringList;
    I:Integer;
    dt:TDayType;
begin
  SL:=TStringList.Create;
  SaveStrings('workers',FWorkerList);
  for dt:=Low(TDayType) to High(TDayType) do begin
    SL.Clear;
    SaveHoursMap(dt,SL);
    SaveStrings('dayhours'+IntToStr(Integer(dt)),SL);
  end;
  SL.Clear;
  for dt:=Low(TDayType) to High(TDayType) do
    SL.Add(CellParamsToString(FDayStyles[dt]));
  SaveStrings('daystyles',SL);
  SL.Clear;
  for I:=0 to High(FActions) do
    SL.Add(FActions[I].Caption+'@'+IntToStr(FActions[I].HotKey)+'@'+FActions[I].Acion+
    '@'+IntToStr(Integer(FActions[I].Use))+'@'+IntToStr(Integer(FActions[I].ShowQInput))) ;
  SaveStrings('actions',SL);
  SL.Free;
  SaveStrings('files',FFiles);
  SaveStrings('folders',FFolders);
  SaveStrings('mru',FMRUList);
  inherited Save;
end;

procedure TOptions.LoadHoursMap(ADayType: TDayType; AData: TStrings);
var I:Integer;
    S,S1:string;
begin
  for I:=0 to AData.Count-1 do begin
    S1:=AData[I];
    S:=DivStr(S1,'=');
    FWorkHours[ADayType].AddOrSetData(S,S1);
  end;
end;

procedure TOptions.SaveHoursMap(ADayType: TDayType; AData: TStrings);
var I:Integer;
begin
  AData.Clear;
  for I:=0 to FWorkHours[ADayType].Count-1 do
    AData.Add(FWorkHours[ADayType].Keys[I]+'='+FWorkHours[ADayType].Data[I]);
end;

function TOptions.CellParamsToString(AParams: TCellParams): String;
begin
  Result:=IntToStr(AParams.FBackColor)+','+IntToStr(AParams.FFontColor)+','+
  IntToStr(Integer(AParams.FFontFlags))+','+AParams.FTypeStr;
end;

procedure TOptions.StrToCellParams(AData: string; var AParams: TCellParams);
begin
  AParams.FBackColor:=StrToInt(DivStr(AData,','));
  AParams.FFontColor:=StrToInt(DivStr(AData,','));
  AParams.FFontFlags:=TFontStyles(StrToInt(DivStr(AData,',')));
  AParams.FTypeStr:=AData;
end;

initialization

  FOptions:=nil;

finalization

  FOptions.Save;
  FreeAndNil(FOptions);

end.

