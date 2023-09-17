unit u_DBSummary;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ComCtrls, StdCtrls,
  ExtCtrls, Grids, gdata, fgl;

{
+ выбор интервала месяцев
+ работа с несколькими типами графика //сделать мап с ключем - тип графика, и при каждом
  событии проверять и изменять FWorkers - он тогда просто ссылка на тек рабочий список
  так же там кэшируются разные года
+ заполнение всех клеточек, в т.ч. Fixed
+ постороение общих сумм
  +форма доп настроек общих сумм
+ применение сортировок сумм графика
  + в том числе по вычисляемым колонкам(сорты - по алфавиту, по любому доступному
    списку персонала (если там нет человека, то он внизу списка), по любой вычисляемой
    колонке)
  + форма настроек
+ автоматическое обновление при изменении графика
+ запись в БД
+ чтение в БД
+ автоматическая инициализация при открытии
+ подгрузка автоматически из базы необходимых колонок (ситуация - когда у нас воркер
  может отсутствовать в данном месяце - цикл по всем воркерам с проверкой этого месяца)
- добавить настроку сетки, или брать из настроек главной сетки
- что оно тормозит то так при открытии? (!!! там почему то 2 раза UpteView идет
+ переделать получение вычисляемых колонок на методы из TGraphData везде


+ при загрузке графика надо проверять Modified, и если он True, то
  сохраняем предыдущий график
+ та же фигня и при прилете сохранения (тогда при загрузке сохранения не будет)
+ при загузке нового графика также пересчитываем тот месяц, который загрузили
  (вдруг у нас поменялись формулы вычисления сумм, да и быстро это в общем то)

+ надо массив в списке воркеров с ID графиков данного типа, чтобы лишний раз в
  базу не лазить и флаг Changed держать, и сбрасывать при прилеьте
    сообщения тип графика измененн - нельзя изменить тип графика
    можно только список персоала, на на выхи хдесь похрен

- отслеживать, что по данному типу надо вести суммирование!!! TOrder <> 0
!!!
- Косяк
  если у нас имеется старые данные, не совпадающие с тем, что в дазе для текущего графика
  то они не сохраняются в датабазе, хотя и должны
  они не сохраняются, даже если их там нет
  до тех пор, пока у нас не поменяется график
  тогда сохраняются только те люди, у которыз поменялись данные
  что то намудрено с флагами
  решение - руками сделать сейв
}

type

  TfrmDBSummary = class;
  TIntArray = array of Integer;


  { TMonthItem }

  TMonthItem = class
    private
      FValue:Integer;
      FID:Integer;
      FModified:boolean;
      procedure SetValue(AValue: Integer);
    public
      constructor Create;
      property Value:Integer read FValue write SetValue;
      property Modified:boolean read FModified write FModified;
      property ID:Integer read FID;
  end;

  //хранит суммарные поля для каждого месяца
  //ключ - имя вычисляемого поля, MonthItem - элемент хранения

  { TMonthData }

  TMonthData = class (specialize TFPGMap<string,TMonthItem>)
    private
      function GetKeyValue(AKey: string): Integer;
      procedure SetKeyValue(AKey: string; AValue: Integer);///убрать нафиг, она некорректная(не задается FID - только для новых графиков)
    public
      constructor Create;
      destructor Destroy; override;
      property KeyValue[AKey:string]:Integer read GetKeyValue write SetKeyValue;
      function GetItem(AKey:string):TMonthItem;
  end;


  //для каждого месяца
  TMonts = array [1..12] of TMonthData;

  { TWorker }

  //работник - хранит данные для каждого
  TWorker = class
    private
      FName:string; //имя
      FID:integer; //ид в БД
      FMonts:TMonts; //список месяцев
      FSummary:TMonthData; // суммарная инфа. В ключах может храниться не только
      //поля, но и их сочетания
      FUpdated:boolean;
      procedure CalcSummary(AFirst,ALast:Integer;AFields:TStringList);
    public
      constructor Create;
      destructor Destroy;override;
  end;

  TSortProc = function (W1,W2:TWorker; Key:string):Integer;


  TGraphIDs = array [1..12] of integer;//ид графика каждого месяца
  //-1 graph not found,  0 - graph not loaded
  { TWorkerList }

  //key - worker id, data - TWorker (список )
  TWorkerList = class(specialize TFPGMap<Integer,TWorker>)
    private
      FModified:boolean;
      FTypeID:Integer;
      //считается как вычисляемое из того, что там есть
      //FMonthCols:TStringList;//имена колонок для хранения месячной инфы
      //FSummCols:TStringList;//имена колонок для хранения сумм инфы. могут быть и сложные
      //типа С+А, тогда у нас получается сумма сумм колонок С+А
      f:TfrmDBSummary;
      FKey:Integer;
      FCurrYear:Integer;
      FGraphIDS:TGraphIDs;
    public
      constructor Create;
      destructor Destroy; override;
      //тут должны быть методы, которые вызываются при каком то изменении
      //графика (save, load, modify) и обновляют summary
      //также тут у нас методы загрузки самого себя по кусочкам
      procedure CalcSummary;//вычисляет Summary
      procedure CheckMonth(AMonth:Integer);
      procedure ReadData(AMonth:Integer);//from DB
      procedure SaveData(AMonth:Integer);//TO DB
      procedure CheckData(AData:TGraphData;CheckAll:boolean = False);//from current opened graph
      procedure ChangeMontsInterval;
  end;
  //пока по колхозному, тупо тип графика задается по первому загруженному
  //и если то, что прилетает от графика, не совпадлает по типу, то ничго не
  //делаем  не, тупо только 1 тип открываем

  TTypesList = specialize TFPGMap<Integer, TWorkerList>;


  { TfrmDBSummary }

  TfrmDBSummary = class(TForm)
    cbFirst: TComboBox;
    cbLast: TComboBox;
    cbSort: TComboBox;
    ImageList1: TImageList;
    sgSumm: TStringGrid;
    ToolBar1: TToolBar;
    cbUpdate: TToolButton;
    tbVisiblecols: TToolButton;
    tbCopy: TToolButton;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    procedure btCopyClick(Sender: TObject);
    procedure tbUpdateClick(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure cbFirstSelect(Sender: TObject);
    procedure cbSortChange(Sender: TObject);
    procedure cbSortClick(Sender: TObject);
    procedure cbSortCloseUp(Sender: TObject);
    procedure cbSortDropDown(Sender: TObject);
    procedure cbSortGetItems(Sender: TObject);
    procedure cbSortSelect(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure tbVisibleColsClick(Sender: TObject);
  private
    //тупо отображение, все данные в тек воркерсах
    //при прилете от внешки меняем тек воркерс на нужный

    //первый месяц показа
    FFirstMonth:Integer;
    //последний месяц показа
    FLastMonth:Integer;
    FMonthCols:TStringList;
    FSummCols: TStringList;
    //тупо массив с ид людей для сортировки, колонки берем из воркерлиста
    FWorkerOrder:TIntArray;
    FPrevSortIdx:Integer;

    FWorkers:TWorkerList;
    FTypes:TTypesList;
    procedure DoChangeState(Sender:TObject; AChange:TStateChange);
    function GetFirstMonth: Integer;
    function GetLastMonth: Integer;
    function GetSummCols: string;
    function GetUsedCols: string;
    procedure InitView;

    procedure SetFirstMonth(AValue: Integer);
    procedure SetLastMonth(AValue: Integer);
    procedure SetSummCols(AValue: string);
    procedure SetUsedCols(AValue: string);
    procedure UpdateView;
    procedure CheckGraphType(AData:TGraphData);
    procedure InitSummary;
    procedure FreeTypes;

    procedure InitSort;
    procedure SortIndex;
  public

  published
    property FirstMonth:Integer read GetFirstMonth write SetFirstMonth;
    property LastMonth:Integer read GetLastMonth write SetLastMonth;
    property UsedCols:string read GetUsedCols write SetUsedCols;
    property SummCols:string read GetSummCols write SetSummCols;

  end;

var
  frmDBSummary: TfrmDBSummary = nil;

procedure ShowDBSummary;

implementation


uses u_options, eth_tbl, u_DBSumOpts, s_tools, u_data, u_memo, SQLDB, Math, Clipbrd;

const SavedProps = 'Left,Top,Width,Height,FirstMonth,LastMonth';

procedure ShowDBSummary;
begin
  if frmTable.Data=nil then begin
    ShowMessage('Для работы необходим открытый график!!!');
    Exit;
  end;
  if  not Assigned(frmDBSummary) then begin
    Application.CreateForm(TfrmDBSummary,frmDBSummary);
  end;
  frmDBSummary.Show;
end;

{$R *.lfm}

{ TMonthData }

function TMonthData.GetKeyValue(AKey: string): Integer;
var I:Integer;
begin
  Result:=0;
  I:=IndexOf(AKey);
  if I<>-1 then
    Result:=Data[I].Value;
end;

procedure TMonthData.SetKeyValue(AKey: string; AValue: Integer);
var I:Integer;
    mi:TMonthItem;
begin
  I:=IndexOf(AKey);
  if I<>-1 then
    Data[I].Value:=AValue
  else begin
    mi:=TMonthItem.Create;
    mi.FModified:=True;
    mi.FValue:=AValue;
    Add(AKey,mi);
  end;
end;

constructor TMonthData.Create;
begin
  inherited Create;
end;

destructor TMonthData.Destroy;
var I:Integer;
begin
  for I:=0 to Count-1 do
    Data[I].Free;
  Clear;
  inherited Destroy;
end;

function TMonthData.GetItem(AKey: string): TMonthItem;
var
  I: Integer;
begin
  Result:=nil;
  I:=IndexOf(AKey);
  if I<>-1 then
    Result:=Data[I]
  else begin
    Result:=TMonthItem.Create;
    KeyData[AKey]:=Result;
  end;
end;

{ TfrmDBSummary }

procedure TfrmDBSummary.FormCreate(Sender: TObject);
begin
  //FCurrYear:=-1;
  FMonthCols:=TStringList.Create;
  FSummCols:=TStringList.Create;

  FWorkers:=nil;
  FTypes:=TTypesList.Create;
  FMonthCols.AddStrings(Options.sCols.Split([',']));
  FSummCols.AddStrings(FMonthCols);

  ///!!!debug only
  FFirstMonth:=1;
  FLastMonth:=12;

  Options.LoadComponent(SavedProps,Self);
  sgSumm.Cells[0,0]:='Месяцы';
  sgSumm.Cells[0,1]:='Колонки';

  frmTable.Data.OnDataChange:=@DoChangeState;
  DoChangeState(frmTable.Data,scInit);
end;

procedure TfrmDBSummary.FormDestroy(Sender: TObject);
begin
  frmDBSummary:=nil;
  frmTable.Data.OnDataChange:=nil;
  Options.SaveComponent(SavedProps,Self);
  FreeTypes;
  FTypes.Free;
  FSummCols.Free;
  FMonthCols.Free;
end;

procedure TfrmDBSummary.tbVisibleColsClick(Sender: TObject);
begin
  if ShowDBSummOpts(FMonthCols,FSummCols) then begin
    FWorkers.CheckData(frmTable.Data,True);
    InitView;
    UpdateView;
  end;
end;

procedure TfrmDBSummary.tbUpdateClick(Sender: TObject);
begin
  CheckGraphType(frmTable.Data);
  FWorkers.CheckData(frmTable.Data,True);
  InitView;
  UpdateView;
end;

procedure TfrmDBSummary.btCopyClick(Sender: TObject);
var SL:TStringList;
    I,J:Integer;
    S:string;
begin
  try
    SL:=TStringList.Create;
    for I:=0 to sgSumm.RowCount-1 do begin
      S:=sgSumm.Cells[0,I];
      for J:=1 to sgSumm.ColCount-1 do
        S:=S+#9+sgSumm.Cells[J,I];
      SL.Add(S);
    end;
    Clipboard.AsText:=SL.Text;
  finally
    SL.Free;
  end;
end;

procedure TfrmDBSummary.Button2Click(Sender: TObject);
begin

end;

procedure TfrmDBSummary.cbFirstSelect(Sender: TObject);
begin
  FFirstMonth:=cbFirst.ItemIndex+1;
  FLastMonth:=cbLast.ItemIndex+1;
  if FFirstMonth>FLastMonth then begin
    cbLast.OnSelect:=nil;
    cbFirst.OnSelect:=nil;
    FFirstMonth:=FLastMonth;
    cbLast.ItemIndex:=cbFirst.ItemIndex;
    cbLast.OnSelect:=@cbFirstSelect;
    cbFirst.OnSelect:=@cbFirstSelect;
  end;
  InitSummary;
  InitView;
  FWorkers.CalcSummary;
  UpdateView;
end;

procedure TfrmDBSummary.cbSortChange(Sender: TObject);
begin
end;

procedure TfrmDBSummary.cbSortClick(Sender: TObject);
begin
end;

procedure TfrmDBSummary.cbSortCloseUp(Sender: TObject);
begin
end;

procedure TfrmDBSummary.cbSortDropDown(Sender: TObject);
begin
end;

procedure TfrmDBSummary.cbSortGetItems(Sender: TObject);
var I,J:Integer;
begin
  I:=cbSort.ItemIndex;

//  Log('Get items, count='+IntToStr(I));
  try
    cbSort.Items.BeginUpdate;
    cbSort.Items.Clear;
    cbSort.Items.Add('Не сортировать');
    cbSort.Items.Add('По алфавиту');
    for J:=0 to FSummCols.Count-1 do begin
      cbSort.Items.Add(FSummCols[J]);
    end;
  finally
    cbSort.ItemIndex:=Min(cbSort.Items.Count,I);
    cbSort.Items.EndUpdate;
  end;
end;

procedure TfrmDBSummary.cbSortSelect(Sender: TObject);
begin
  //Log('Select, Text: '+cbSort.Text);
  //create sort index
  {InitSort;
  Log('sort start');
  SortIndex;
  Log('sort end');}
  //update View
  UpdateView;
end;

procedure TfrmDBSummary.DoChangeState(Sender: TObject; AChange: TStateChange);
begin
  {Sender - TGraphData}
  CheckGraphType(Sender as TGraphData);
  if Sender=nil then Exit;
  //если график не попадает в интервал отображаемых месяцев, то сваливаем
  if ((Sender as TGraphData).CurrMonth<FFirstMonth) or
    ((Sender as TGraphData).CurrMonth>FLastMonth) then
    Exit;
  case AChange of
    scNone:;
    scLoad:begin
      FWorkers.FGraphIDS[(Sender as TGraphData).CurrMonth]:=
        (Sender as TGraphData).GraphID;
      FWorkers.CheckData(TGraphData(Sender), False);
    end;
    scSave:FWorkers.SaveData(TGraphData(Sender).CurrMonth);
    scModify:FWorkers.CheckData(TGraphData(Sender), False);
    scInit:InitSummary;
  end;
  InitView;
  UpdateView;
end;

function TfrmDBSummary.GetFirstMonth: Integer;
begin
  Result:=cbFirst.ItemIndex+1;
end;

function TfrmDBSummary.GetLastMonth: Integer;
begin
  Result:=cbLast.ItemIndex+1;
end;

function TfrmDBSummary.GetSummCols: string;
var S:string;
begin
  Result:='';
  for S in FSummCols do
    Result:=StrListAdd(Result,S,',');
end;

function TfrmDBSummary.GetUsedCols: string;
var S:string;
begin
  Result:='';
  for S in FMonthCols do
    Result:=StrListAdd(Result,S,',');
end;

procedure TfrmDBSummary.InitView;
begin
  //настройка сетки
  ///!!!доработать, брать из настроек
  sgSumm.ColWidths[0]:=200;
  sgSumm.RowCount:=FWorkers.Count+2;
  sgSumm.ColCount:=FMonthCols.Count*(FLastMonth-FFirstMonth+1)+1+FSummCols.Count;
end;

procedure TfrmDBSummary.SetFirstMonth(AValue: Integer);
begin
  cbFirst.ItemIndex:=AValue-1;
  FFirstMonth:=AValue;
end;

procedure TfrmDBSummary.SetLastMonth(AValue: Integer);
begin
  cbLast.ItemIndex:=AValue-1;
  FLastMonth:=AValue;
end;

procedure TfrmDBSummary.SetSummCols(AValue: string);
begin
  FSummCols.AddStrings(AValue.Split([',']),True);
end;

procedure TfrmDBSummary.SetUsedCols(AValue: string);
begin
  FMonthCols.AddStrings(AValue.Split([',']),True);
end;

procedure TfrmDBSummary.UpdateView;
var I, J, K, L:Integer;
    ACol:Integer;
    CurrCName:string;
    mdata:TMonthData;
    Idx:Integer;
begin
  //переписываем из полей в сетку
  SortIndex;
  sgSumm.BeginUpdate;
  try
    //зоголовок
    Log('Update:Begin');
    K:=FMonthCols.Count;
    for I:=0 to (FLastMonth-FFirstMonth) do begin
      for J:=0 to K-1 do begin
        sgSumm.Cells[I*K+J+1,0]:=IntToStr(FFirstMonth+I);
        sgSumm.Cells[I*K+J+1,1]:=FMonthCols[J];
      end;
    end;
    L:=(FLastMonth-FFirstMonth+1)*FMonthCols.Count+1;
    for I:=0 to FSummCols.Count-1 do begin
      sgSumm.Cells[L+I,0]:='SUM';
      sgSumm.Cells[L+I,1]:=FSummCols[I];
    end;
    //workers names
    for I:=0 to FWorkers.Count-1 do begin
      Idx:=FWorkerOrder[I];
      //тут надо брать не I воркера, а через массив сортировки воркеров
      //sgSumm.Cells[0,I+2]:=FWorkers.Data[I].FName;
      sgSumm.Cells[0,I+2]:=FWorkers.Data[Idx].FName;
      //а теперь для каждого воркера запихиваем часы
      for J:=0 to FLastMonth-FFirstMonth do begin
        ACol:=1+FMonthCols.Count*J;
        //mdata:=FWorkers.Data[I].FMonts[FFirstMonth+J];
        mdata:=FWorkers.Data[Idx].FMonts[FFirstMonth+J];
        for K:=0 to FMonthCols.Count-1 do begin
          CurrCName:=FMonthCols[K];
          if mdata=nil then
            sgSumm.Cells[ACol+K,I+2]:=''
          else
            sgSumm.Cells[ACol+K,I+2]:=IntToStr(mdata.KeyValue[CurrCName]);
        end;
      end;
      //тут для каждого воркера пихаем суммарные колонки
      for J:=0 to FSummCols.Count-1 do begin
        //sgSumm.Cells[L+J,I+2]:=IntToStr(FWorkers.Data[I].FSummary.KeyValue[FSummCols[J]]);
        sgSumm.Cells[L+J,I+2]:=IntToStr(FWorkers.Data[Idx].FSummary.KeyValue[FSummCols[J]]);
      end;
    end;
    Log('Update:End');
  finally
    sgSumm.EndUpdate(True);
  end;
end;

procedure TfrmDBSummary.CheckGraphType(AData: TGraphData);
var I:Integer;
begin
  if (FWorkers=nil)or(FWorkers.FKey<>AData.Key) then begin
    I:=FTypes.IndexOf(AData.Key);
    if I=-1 then begin
      FWorkers:=TWorkerList.Create;
      FWorkers.FTypeID:=AData.GraphType;
      FWorkers.FKey:=AData.Key;
      FWorkers.FCurrYear:=AData.CurrYear;
      FWorkers.f:=Self;
      FTypes.AddOrSetData(AData.Key,FWorkers);
    end else begin
      FWorkers:=FTypes.Data[I];
    end;
    InitSummary;
  end;
end;

procedure TfrmDBSummary.InitSummary;
var SQL:string;
    I:Integer;
    DS:TSQLQuery;
    b:boolean;
begin
  //инициализация рассчетов
  //вызывается при запуске формы и при смене года
  //данные берем из текущего открытого графика
{  if FWorkers.FCurrYear <> frmTable.Data.CurrYear then begin
    FreeTypes;
    FWorkers:=nil;
  end;
  FWorkers:=TWorkerList.Create;
  FWorkers.FCurrYear:=frmTable.Data.CurrYear;
  FWorkers.FTypeID:=frmTable.Data.GraphType;
  FTypes.KeyData[frmTable.Data.GraphType]:=FWorkers;}
  //как то переделать для перехода на новый год
  Log('Init summary...');
  if FWorkers.FGraphIDS[1]=0 then begin
    Log('Load graph IDs...');
    for I:=1 to 12 do
      FWorkers.FGraphIDS[I]:=-1;
    SQL:='select g.gid, gi.gmonth from graph g join  graph_info gi on g.iid = gi.iid ' +
        ' where gi.gyear = %d and g.tid = %d'.Format([FWorkers.FCurrYear,frmTable.Data.GraphType]);
    DS:=DM.GetDS(SQL);
    while not DS.EOF do begin
      FWorkers.FGraphIDS[DS.Fields[1].AsInteger]:=DS.Fields[0].AsInteger;
      DS.Next;
    end;
    DM.CloseDS(DS);
  end;
  b:=False;
  for I:=FFirstMonth to FLastMonth do
    if (FWorkers.Count=0)or(FWorkers.Data[0].FMonts[1]=nil) then begin
      FWorkers.ReadData(I);
      b:=True;
    end;
  Log('Calc summary...');
  if b then
    FWorkers.CalcSummary;
  Log('Init Summary complete...');
end;

procedure TfrmDBSummary.FreeTypes;
var
  I: Integer;
begin
  for I:=0 to FTypes.Count-1 do
    FTypes.Data[I].Free;
end;

procedure TfrmDBSummary.InitSort;
var
  I: Integer;
begin
  SetLength(FWorkerOrder,FWorkers.Count);
  for I:=0 to FWorkers.Count-1 do
    FWorkerOrder[I]:=I;
  FPrevSortIdx:=0;
end;

function SortNames(W1,W2:TWorker; Key:string):Integer;register;
begin
  Result:=AnsiCompareText(W1.FName,W2.FName);
  //Log('Compare '+W1.FName+' ' +W2.FName);
end;
function SortSums(W1,W2:TWorker; Key:string):Integer;register;
begin
  Result:=W2.FSummary.KeyValue[Key]-W1.FSummary.KeyValue[Key];
end;


procedure TfrmDBSummary.SortIndex;
var Sort:string;
    P:TSortProc;
    I,J,K:Integer;
    Swaps:Boolean;
    S:string;
begin
  P:=nil;
  InitSort;
  if cbSort.ItemIndex=0 then begin
    Exit;
  end;
  if cbSort.ItemIndex=1 then
    P:=@SortNames
  else begin
    Sort:=FSummCols[cbSort.ItemIndex-2];
    Log('sort = '+ sort);
    P:=@SortSums;
  end;
  S:='';
  for I:=0 to High(FWorkerOrder) do
    S:=S+' '+IntToStr(FWorkerOrder[i]);
  //Log(S);
  //пизирек
  for I:=FWorkers.Count-2 downto 0 do begin
    //Log('I='+IntToStr(I));
    Swaps:=False;
    for J:=0 to I do begin
      if P(FWorkers.Data[FWorkerOrder[J]],FWorkers.Data[FWorkerOrder[J+1]],Sort)>0 then begin
        K:=FWorkerOrder[J+1];
        FWorkerOrder[J+1]:=FWorkerOrder[J];
        FWorkerOrder[J]:=K;
        Swaps:=True;
        //Log('Swap');
      end;
    end;
    if not Swaps then Break;
  end;
end;

{ TMonthItem }

procedure TMonthItem.SetValue(AValue: Integer);
begin
  if FValue=AValue then Exit;
  FValue:=AValue;
  FModified:=True;
end;

constructor TMonthItem.Create;
begin
  FValue:=0;
  FModified:=False;
  FID:=-1;
end;

{ TWorkerList }

constructor TWorkerList.Create;
var I: Integer;
begin
  inherited Create;
  FTypeID:=-1;
  FModified:=False;
  for I:=1 to 12 do
    FGraphIDS[I]:=0;
end;

destructor TWorkerList.Destroy;
var I:Integer;
begin
  for I:=0 to Count-1 do
    Data[I].Free;
  inherited Destroy;
end;

procedure TWorkerList.CalcSummary;
var I:Integer;
begin
  Log('Summ:start');
  for I:=0 to Count-1 do
    Data[I].CalcSummary(f.FFirstMonth,f.FLastMonth,f.FSummCols);
  Log('Summ:end');
end;

procedure TWorkerList.CheckMonth(AMonth: Integer);
begin

end;

procedure TWorkerList.ReadData(AMonth: Integer);
var gid:Integer;
    SQL: string;
    DS:TSQLQuery;
    W:TWorker;
    wid:Integer;
    md:TMonthItem;
    iCount:Integer;

  function CreateWorker(AWid:Integer; AName:string):TWorker;
  begin
    Result:=TWorker.Create;
    Result.FID:=AWid;
    Result.FUpdated:=False;
    Result.FName:=AName;
    KeyData[AWid]:=Result;
  end;

begin
  Log('Load Month %d...'.Format([AMonth]));
  //получаем список работников из БД
  //сравниваем с тем, что есть, и при необходимости обновляем
  //получаем ид графика для загрузки
  //получаем из базы для этого графика все данные
  //и грузим
  //по номеру месяца получаем ид графика
  gid := FGraphIDS[AMonth];
  if gid = -1 then begin
    //графика нет
    Log('Load:GraphID not Found. Exit ReadData...');
    Exit;
  end;
  if gid = 0 then begin
    SQL:='select gid from graph join  graph_info on graph.iid  = graph_info.iid ' +
      'where gyear=%d and gmonth=%d and tid = %d'.Format([FCurrYear,AMonth,FTypeID]);
    SQL:=DM.GetQSingle(SQL);
    if SQL='' then Exit;
    gid:=SQL.ToInteger;
  end;
  //получаем список работников, если нужно
  if Count = 0 then begin
    Log('Load:WorkerList Empty. Getting...');
    SQL:='select so.wid, wname from sort_order so join graph g on g.sid = so.sid join workers w on so.wid = w.wid ' +
      'where gid=%d order by oindex'.Format([gid]);
    DS:=DM.GetDS(SQL);
    while not DS.EOF do begin
      CreateWorker(DS.Fields[0].AsInteger, DS.Fields[1].AsString);
      DS.Next;
    end;
    DM.CloseDS(DS);
  end;
  SQL:='select aid, s.wid, sinfo, svalue, wname from s_data s join workers w on s.wid=w.wid '+
    'where gid = %d order by s.wid'.Format([gid]);
  DS:=DM.GetDS(SQL);
  wid:=0;
  W:=nil;
  Log('Load:Loading workers...');
  iCount:=0;
  while not DS.EOF do begin
    Inc(iCount);
    wid:=DS.Fields[1].AsInteger;
    //Log('Load:Loading worker %d'.Format([wid]));
    if (W=nil)or(W.FID<>wid) then begin
      try
        W:=KeyData[wid];
      except
        Log('Worker not found. Creating...');
        W:=CreateWorker(wid, DS.Fields[4].AsString);
        KeyData[wid]:=W;
      end;
    end;
    if W<>nil then begin
      //Log('Load: Key = %s'.Format([DS.Fields[2].AsString]));
      if W.FMonts[AMonth]= nil then
        W.FMonts[AMonth]:=TMonthData.Create;
      md:=W.FMonts[AMonth].GetItem(DS.Fields[2].AsString);
      md.FID:=DS.Fields[0].AsInteger;
      md.FValue:=DS.Fields[3].AsInteger;
    end;
    DS.Next;
  end;
  DM.CloseDS(DS);
  Log('Load:Loading complete... %d items loaded'.Format([iCount]));

end;

procedure TWorkerList.SaveData(AMonth: Integer);
var iSQL, uSQL:string;
    I, J, Cnt: Integer;
    W:TWorker;
    mi:TMonthItem;
    DS:TSQLQuery;
begin
  if FGraphIDS[AMonth]<1 then begin
    ShowMessage('Month=0');
    Exit;
  end;
  Log('Save data. Month = %d'.Format([AMonth]));
  Cnt:=0;
  //пишем в базу данные переданного месяца
  //только те, у которых стоит флаг "Modified" и те, у кого -1 FID
  iSQL:='insert into s_data (wid, gid, sinfo, svalue) '+
  'values (%d, %d, ''%s'', %d) returning aid';
  uSQL:='update s_data set svalue=%d where aid = %d';
  DS:=DM.GetDS('',False);
  for I:=0 to Count-1 do begin // по людям
    W:=Data[I];
    if W.FMonts[AMonth]=nil then Continue;
    for J:=0 to W.FMonts[AMonth].Count-1 do begin
      mi:=W.FMonts[AMonth].Data[J];
      if mi.Modified then begin
        Inc(Cnt);
        if mi.FID=-1 then begin
          DS.SQL.Text:=iSQL.Format([W.FID,FGraphIDS[AMonth],W.FMonts[AMonth].Keys[J],mi.Value]);
          DS.Open;
          mi.FID:=DS.Fields[0].AsInteger;
          DS.Close;
        end else begin
          DS.SQL.Text:=uSQL.Format([mi.Value,mi.FID]);
          DS.ExecSQL;
        end;
        mi.Modified:=False;
      end;
    end;
  end;
  DM.CloseDS(DS);
  Log('%d intem(s) saved'.Format([Cnt]));
end;

procedure TWorkerList.CheckData(AData: TGraphData; CheckAll: boolean);
var I,J,C, WID: Integer;
    W:TWorker;
    cols:TStringArray;
    mi:TMonthItem;
begin
  if FTypeID=-1 then FTypeID:=AData.GraphType;
  if AData.GraphType<>FTypeID then Exit;//по крайней мере, не будут портиться данные
  //из текущего графика обновляемся
  //если стоит CheckAll, то игнорируем флаг Updated
  //проверяем список людей и обновляем если что
  cols:=Options.sCols.Split([',']);
  for I:=0 to AData.WorkerCount-1 do begin
    WID:=AData.GetWorkerID(I);
    if IndexOf(WID)=-1 then begin
      //добавляем нового работника
      W:=TWorker.Create;
      W.FID:=WID;
      W.FUpdated:=True;
      W.FName:=AData.Workers[I];
      KeyData[WID]:=W;
    end else
      W:=KeyData[WID];
    //если надо
    if not CheckAll then begin
      if not AData.WorkerUpdated[I] then Continue;
    end;
    AData.WorkerUpdated[I]:=False;
    //извлекаем данные работника
    for J:=0 to High(cols) do begin
      //по каждому вычисляемому полю
      if W.FMonts[AData.CurrMonth] = nil then
        W.FMonts[AData.CurrMonth]:=TMonthData.Create;
      C:=W.FMonts[AData.CurrMonth].IndexOf(cols[J]);
      if C=-1 then begin
        mi:=TMonthItem.Create;
        W.FMonts[AData.CurrMonth].Add(cols[J],mi);
      end else begin
        mi:=W.FMonts[AData.CurrMonth].Data[C];
      end;
      mi.Value:=AData.GetWorkerExtra(I,cols[J]);
      if mi.Modified then W.FUpdated:=True;
    end;
    W.CalcSummary(f.FFirstMonth,f.FLastMonth,f.FSummCols);
  end;
end;

procedure TWorkerList.ChangeMontsInterval;
begin
  //обновляем список ид в GraphIDS, только те, которые не укзазаны
  //и читаем из базы те, которые еще не загружены

end;

{ TWorker }

procedure TWorker.CalcSummary(AFirst, ALast: Integer; AFields: TStringList);
var I,J, Summ : Integer;
    S:string;
    sa:TStringArray;
begin
  for J:=0 to AFields.Count-1 do begin
    S:=AFields[J];
    Summ:=0;
    if Pos('+',S)>0 then begin
      sa:=S.Split(['+']);
      for I:=0 to High(sa) do begin
        Summ:=Summ+FSummary.KeyValue[sa[I]];
      end;
    end else begin
      for I:=AFirst to ALast do
        if FMonts[I]<>nil then
          Summ:=Summ+FMonts[I].KeyValue[S];
    end;
    FSummary.KeyValue[S]:=Summ;
  end;
end;

constructor TWorker.Create;
var I:Integer;
begin
  for I:=1 to 12 do FMonts[I]:=nil;
  FName:='';
  FSummary:=TMonthData.Create;
  FUpdated:=False;
end;

destructor TWorker.Destroy;
var I:Integer;
begin
  for I:=1 to 12 do begin
    FreeAndNil(FMonts[I]);
  end;
  FreeAndNil(FSummary);
  inherited Destroy;
end;

end.

