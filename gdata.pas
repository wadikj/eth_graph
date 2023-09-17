unit gdata;

{$mode objfpc}{$H+}
{$ModeSwitch AdvancedRecords}

interface

uses
  Classes, SysUtils, ComObj, Forms, Dialogs, u_options, Graphics;

type

  { TGraphItem }

  TGraphItem = record
    FName:string;//имя работника
    FSMInfo:boolean;//инфа о четной смене
    Days:array [1..31] of TDayItem;//дни работника
    //add for DB work
    FModified:boolean;//для сохранения, сбрасывается при нем
    FUpdated:boolean;//для обновления, сбрасыватся в OnDataChange или EndUpdate
    FWorkerID:integer;//ид работника
    FLineID:integer;//ид строки работника в базе или -1, если запись новая//did
    function GetDays(ADayCount:Integer):string;
    procedure SetDays(AData:string);
  end;

  TGraphItems = array of TGraphItem;

  //инфа о фоне ячейки
  TCellBg = record
    BgColor:TColor;
    FontColor:TColor;
    Styles:TFontStyles;
  end;

  //что у нас выводится при раскраске ячейки

  TCellUseStyle = (cusVih, cusSM, cusFontStyle, cusFontColor, cusBgColor);
  //выхи и праздники, снеты горизонтально, исп стили шрифта, исп цвет щрифта, исп свет фона
  TCellUseStyles = set of TCellUseStyle;

  TStateChange = (scNone, scLoad, scSave, scModify, scInit);

  TStateChangeEvent = procedure (Sender:TObject; Change:TStateChange) of object;

  { TGraphData }

  TGraphData = class
    private
      FCurrMonth: integer;
      FCurYear: Integer;
      FFileName: string;
      FModified: boolean;
      FMontDays:integer;
      FOnDataChange: TStateChangeEvent;
      FWorkerConut:integer;
      FItems:TGraphItems;
      FWPR: QWord; ///graph_info.wlist
      //DB Data support
      FGraphInfo:Integer;//Graph_Info iid
      FGraphID:Integer;//какой график используем gid
      FSortID:Integer;//порядок сортировки sid
      FGraphType:Integer;//какой тип графика используем tid
      FGraphTypeName:string;//Для произвольных типов tname
      //Begin/EndUpdate Support
      FUpdateCount:Integer;
      FStateChange:TStateChange;
      //по идее, на форме устанавливаются эти контролы(месяц, год, тип графика,
      //порядок сортировки), оно передается в этот класс, и он себя читает из БД
      //используем либо тек месяц, либо то, что было открыто в прошлый раз
      procedure CreateManList(AData:TStrings);
      function GetInDB: boolean;
      function GetKey: Integer;
      function GetLoaded: boolean;
      function GetSMInfo: string;
      function GetTextWPR: string;
      function GetWorker(WIndex: Integer): string;
      function GetWorkerConut: Integer;
      function GetWorkerUpdated(AWorkerIdx: Integer): boolean;
      procedure SetSMInfo(AValue: string);
      procedure SetTextWPR(AValue: string);
      procedure SetWorker(WIndex: Integer; AValue: string);
      procedure SetWorkerCount(AValue: Integer);
      procedure DoDataChange;
      procedure SetWorkerUpdated(AWorkerIdx: Integer; AValue: boolean);
    public
      constructor Create;
      destructor Destroy; override;
      procedure ImportData(XL:OleVariant);
      procedure ExportData(XP:OleVariant);
      procedure ExportOldGraph(XP:OleVariant);
      procedure SaveData(const AFileName:string);
      function SaveToStrings:TStrings;
      function SaveToDB:boolean;//graph only, withou ghaph_info
      function LoadData(const AFileName:string):boolean;
      function LoadFromDB(AMonth,AYear,AGraphType:Integer;ATypeName:string):boolean;overload;
      function LoadFromDB(AGraphID:Integer):boolean;overload;
      function ImportFromFile(WList,GType:Integer; GName:string=''):boolean;
      function SaveWPRAnDSort(AWPR:string; ASort:Integer):boolean;
      procedure NewData;
      function GetIniName:string;
      procedure Analyze;
      //read graph data
      function GetCellValue(AWorker,ADay:Integer):string;
      function GetCellText(AWorker,ADay:Integer):string;
      function GetCellInfo(AWorker,ADay:Integer):TDayItem;
      function GetCellBg(AWorker,ADay:Integer;UseStyles:TCellUseStyles):TCellBg;
      function GetExpInfo(AWorker,ADay:Integer;out S1,S2,S3:string):string;//для именованного графика
      //write graph data
      procedure SetCellDayType(AWorker,ADay:Integer;ADayType:TDayType);
      procedure SetCellHours(AWorker,ADay:Integer;AHours:string);
      procedure SetCellSm(AWorker:Integer;A_SM:Boolean);
      procedure Analyze(Errors:TStrings);
      //date
      property CurrMonth:Integer read FCurrMonth write FCurrMonth;
      property CurrYear:Integer read FCurYear write FCurYear;
      function GetSD:string;

      property WPR:QWord read FWPR write FWPR;//выхи и праздники для сохранения
      property TextWPR:string read GetTextWPR write SetTextWPR;//выхи и праздники в тексте
      function IsDayWPR(ADay:Integer):boolean;//вых или праздничный день
      procedure GetManList(AList:TStrings);
      property SMInfo:string read GetSMInfo write SetSMInfo;//инфа о сменах в текстовом виде

      property FileName:string read FFileName write FFileName;
      property Modified:boolean read FModified write FModified;
      property Workers[WIndex:Integer]:string read GetWorker write SetWorker;
      procedure BeginUpdate;
      procedure EndUpdate;
      property OnDataChange:TStateChangeEvent read FOnDataChange write FOnDataChange;
      //work with DB support
      property Loaded:boolean read GetLoaded;
      property SortID:Integer read FSortID;
      property GraphID:Integer read FGraphID;
      property GraphType:Integer read FGraphType;
      procedure ChangeType(ANewType:Integer);
      function DBCreateBlank(AYear, AMonth, ASort:IntPtr; AWPR:QWord; AType:IntPtr):integer;//
      procedure UsePrev(APrewID:Integer);
      procedure ApplyAbsenses;
      function GetDayDay(AWorkerIdx:Integer):Integer;
      function GetWorkerIndex(WID:Integer):Integer;///wid-> index in list
      function GetWorkerID(WIndex:Integer):Integer;
      function GetUpdated(WIndex:Integer):boolean;
      property WorkerUpdated[AWorkerIdx:Integer]:boolean read GetWorkerUpdated write SetWorkerUpdated;
      function GetWorkerExtra(AWorkerIndex:Integer; AExtraName:string):Integer;
      function GetSortName:string;
      function GetTypeName:string;

      property Key:Integer read GetKey;
    published
      //import/export - old format
      property MonthDays:Integer read FMontDays write FMontDays; // auto from month and year
      property WorkerCount:Integer read GetWorkerConut write SetWorkerCount;
      property InDB:boolean read GetInDB;

  end;

implementation

uses s_tools, u_memo, u_data, StrUtils, dateutils, Math, SQLDB, windows;

{ TGraphItem }

function TGraphItem.GetDays(ADayCount: Integer): string;
var D:Integer;
begin
  Result:='';
  for D:=1 to ADayCount do
    Result:=Result+Days[D].FHours+'!'+IntToStr(Integer(Days[D].FType))+'|';
end;

procedure TGraphItem.SetDays(AData: string);
var A,B:TStringArray;
    I:Integer;
begin
  A:=AData.Split(['|']);
  for I:=Low(A) to High(A) do begin
    if A[I]='' then Break;
    B:=A[I].Split(['!']);
    Days[I+1].FHours:=B[0];
    Days[I+1].FType:=TDayType(B[1].ToInteger);
    FModified:=False;
  end;
end;

{ TGraphData }

procedure TGraphData.CreateManList(AData: TStrings);
var Wrk,Day,I:Integer;
    O,T:boolean;S:string;
    sd:string;
    OLen,TLen:integer;
    di:TDayItem;
begin
  //по идее надо переделать на следующее
  //при экспорте вводим, какие данные выводить
  //какие типы выводить
  //и условие на вывод
  //например, количество раб часов не равно чему то
  //чобы настраивалось
  sd:=GetSD;
  for Day:=1 to MonthDays do begin
    O:=False;T:=False;
    OLen:=0;TLen:=0;
    for Wrk:=0 to WorkerCount-1 do begin
      di:=GetCellInfo(Wrk,Day);
      S:='';
      case di.FType of
        dtOHT:begin
          O:=True;
          OLen:=Max(OLen,StrToInt(di.FHours));
        end;
        dtTU:begin
          T:=True;
          TLen:=Max(TLen,(StrToInt(di.FHours)));
        end;
        dtDay:begin
          if di.FHours<>'12' then begin
            if not Options.FWorkHours[di.FType].Find(di.FHours,I) then begin
              Continue;
            end;
            S:=IntToStr(Day)+sd+'|'+
            Options.FWorkHours[di.FType].Data[I]+'|'+
            FItems[Wrk].FName;
          end;
        end;
        dtZam:begin
        end;
        dtOther:begin
          //S:=IntToStr(Day)+sd+'|8:00-17:00|'+FItems[Wrk].FName;
        end;
      end;
      if S<>'' then AData.Add(S);
    end;
    S:='';
    if O then begin
      S:=IntToStr(Day)+SD;
      if not Options.FWorkHours[dtOHT].Find(IntToStr(OLen),I) then begin
        S:=S+'|ERROR!!!|'+IntToStr(OLen);
      end else
        S:=S+'|'+Options.FWorkHours[dtOHT].Data[I]+'|День охраны труда';
    end;
    if T then begin
      S:=IntToStr(Day)+SD;
      if not Options.FWorkHours[dtTU].Find(IntToStr(TLen),I) then begin
        S:=S+'|ERROR!!!|'+IntToStr(TLen);
      end else
        S:=S+'|'+Options.FWorkHours[dtTU].Data[I]+'|День технической учебы';
    end;
    if S<>'' then AData.Add(S);
  end;
end;

function TGraphData.GetInDB: boolean;
begin
  Result:=FGraphType<>-1;
end;

function TGraphData.GetKey: Integer;
begin
  Result:=FCurYear*100+FGraphType;
end;

function TGraphData.GetLoaded: boolean;
begin
  Result:=FWPR<>0;
end;

function TGraphData.GetSMInfo: string;
var I:Integer;
begin
  Result:='';
  for I:=0 to High(FItems) do
    if FItems[I].FSMInfo then
      Result:=StrListAdd(Result,IntToStr(I));
end;

function TGraphData.GetTextWPR: string;
var I:Integer;
begin
  Result:='';
  for I:=1 to 31 do
    if ((FWPR shr I) and $1)<>0 then
      Result:=StrListAdd(Result,IntToStr(I),',');
end;

function TGraphData.GetWorker(WIndex: Integer): string;
begin
  Result:='ERROR!!!!';
  if (WIndex>High(FItems)) or (WIndex<0)then begin
    ShowMessage('Index not in bounds');
    Exit;
  end;
  Result:=FItems[WIndex].FName;
end;

function TGraphData.GetWorkerConut: Integer;
begin
  Result:=Length(FItems);
end;

function TGraphData.GetWorkerUpdated(AWorkerIdx: Integer): boolean;
begin
  Result:=FItems[AWorkerIdx].FUpdated;
end;

procedure TGraphData.SetSMInfo(AValue: string);
var S:string;
    I:Integer;
begin
  for I:=Low(FItems) to High(FItems) do
    FItems[I].FSMInfo:=False;
  while AValue<>'' do begin
    S:=DivStr(AValue);
    I:=StrToInt(S);
    if I<=High(FItems) then
      FItems[I].FSMInfo:=True;
  end;
end;

procedure TGraphData.SetTextWPR(AValue: string);
var S:string;
    I:Integer;
    J,DW:DWord;
begin
  FWPR:=0;
  while AValue<>'' do begin
    S:=DivStr(AValue,',');
    I:=StrToInt(S);
    DW:=1;
    J:=(DW shl I);
    FWPR:=FWPR or J;
  end;
end;

procedure TGraphData.SetWorker(WIndex: Integer; AValue: string);
begin
  FItems[WIndex].FName:=AValue;
  FModified:=True;
end;

procedure TGraphData.SetWorkerCount(AValue: Integer);
begin
  SetLength(FItems,AValue);
  FModified:=False;
end;

procedure TGraphData.DoDataChange;
begin
  if FUpdateCount<>0 then Exit;
  if FOnDataChange<>nil then begin
    FOnDataChange(Self,FStateChange);
    FStateChange:=scNone;
  end;
end;

procedure TGraphData.SetWorkerUpdated(AWorkerIdx: Integer; AValue: boolean);
begin
  FItems[AWorkerIdx].FUpdated:=AValue;
end;

constructor TGraphData.Create;
begin
  CurrYear:=0;
  CurrMonth:=0;
  FWPR:=0;
  FUpdateCount:=0;
  FOnDataChange:=nil;
  FGraphID:=-1;
  FGraphInfo:=-1;
  FGraphType:=-1;
  FGraphTypeName:='';
  FModified:=False;
  FSortID:=-1;
  FStateChange:=scNone;
end;

destructor TGraphData.Destroy;
begin
  SetLength(FItems,0);
  inherited Destroy;
end;

procedure TGraphData.ImportData(XL: OleVariant);
var Sh:OleVariant;
  I,J: Integer;
begin
  //если месяц и год не установлены вручную при экспорте на главной форме , то
  //Error
  if (CurrMonth=0) or (CurrYear=0) then begin
    ShowMessage('current Month and Year must be set!!!');
    Exit;
  end;
  MonthDays:=DaysInAMonth(CurrYear,CurrMonth);
  //читаем из старого формата
  SetLength(FItems,Options.DefWorkerCount);
  //читаем работников
  Sh:=XL.ActiveSheet;
  //для каждого работника
  for I:=0 to Options.DefWorkerCount-1 do begin
    //читаем фамилию
    FItems[I].FName:=Sh.Cells[I+Options.FirstWorker,1].Value;
    FItems[I].FSMInfo:=False;
    //читаем его дни
    for J:=1 to MonthDays do begin
      FItems[I].Days[J].FHours:=Sh.Cells[I+Options.FirstWorker,J+Options.FirstDay-1].Value;
    end;
  end;
  //тут надо извлечь глобальную инфу о сменах и запихнуть ее в данные работника
  SetSMInfo(Options.gTSSM);
  Sh:=Null;
  ShowMessage('Import Complete!!!');
  Analyze;
end;

procedure TGraphData.ExportData(XP: OleVariant);
var Sh:OleVariant;
    Wrk,Day,I:Integer;
    S,S1,S2,S3:string;
    BR:Integer;
    SL:TStringList;
    f:Single;
begin
  Sh:=XP.ActiveSheet;
  SL:=TStringList.Create;
  for Wrk:=0 to WorkerCount-1 do begin
    for Day:=1 to MonthDays do begin
      S:=GetExpInfo(Wrk,Day,S1,S2,S3);
      BR:=Options.xFirstRow+Wrk*3;                         //WideString(UTF8Decode('выхи'))
      if Pos(',',S1)>0 then begin
        Sh.Cells[BR,Day+Options.xFirstCol-1].NumberFormat:='0,0';
        try
          f:=s1.ToSingle;
            Sh.Cells[BR,Day+Options.xFirstCol-1].Value:=f;
        except
          Sh.Cells[BR,Day+Options.xFirstCol-1].Value:=WideString(UTF8Decode(S1));
          ShowMessage(S1);
        end;
      end else
        Sh.Cells[BR,Day+Options.xFirstCol-1].Value:=WideString(UTF8Decode(S1));
      Sh.Cells[BR+1,Day+Options.xFirstCol-1].Value:=WideString(UTF8Decode(''''+S2));
      Sh.Cells[BR+2,Day+Options.xFirstCol-1].Value:=WideString(UTF8Decode(''''+S3));
      if S<>'' then SL.Add(S);
    end;
  end;
  if SL.Count<>0 then begin
    ShowMemo(SL.Text, 'Ошибки при импорте именного графика');
    SL.Clear;
  end;
  CreateManList(SL);
  for I:=0 to SL.Count-1 do begin
    S3:=SL[I];
    S1:=DivStr(S3,'|');
    S2:=DivStr(S3,'|');
    Sh.Cells[Options.xMansRow+I,Options.xMansCol].Value:=WideString(UTF8Decode(S1));
    Sh.Cells[Options.xMansRow+I,Options.xMansColTime].Value:=WideString(UTF8Decode(S2));
    Sh.Cells[Options.xMansRow+I,Options.xMansColName].Value:=WideString(UTF8Decode(S3));
  end;
  SL.Free;
end;

procedure TGraphData.ExportOldGraph(XP: OleVariant);
var Sh:OleVariant;
    Wrk,Day:Integer;
    S1:string;
    BR:Integer;
    //SL:TStringList;
    ei:TOEItem;
    di:TDayItem;
    bg:TCellBg;
begin
  Sh:=XP.ActiveSheet;
  for Wrk:=0 to WorkerCount-1 do begin
    for Day:=1 to MonthDays do begin
      di:=GetCellInfo(Wrk,Day);
      ei:=Options.OEDayRules.Items[Integer(di.FType)];
      S1:=di.FHours;
      if ei.UseStr and (not Options.AlwaysUseHours) then S1:=ei.OtherStr;

      BR:=Options.FirstWorker+Wrk;
      Sh.Cells[BR,Day+Options.FirstDay-1].Value:=WideString(UTF8Decode(S1));
      bg:=GetCellBg(Wrk,Day,[cusVih, cusFontStyle, cusFontColor, cusBgColor]);
      if ei.USeFont then begin
        Sh.Cells[BR,Day+Options.FirstDay-1].Font.Color:=bg.FontColor;
        if fsBold in bg.Styles then
          Sh.Cells[BR,Day+Options.FirstDay-1].Font.Bold:=True;
        if fsUnderline in bg.Styles then
          Sh.Cells[BR,Day+Options.FirstDay-1].Font.Underline:=2;
        if fsItalic in bg.Styles then
          Sh.Cells[BR,Day+Options.FirstDay-1].Font.Italic:=True;
        if fsStrikeOut in bg.Styles then
          Sh.Cells[BR,Day+Options.FirstDay-1].Font.Strikethrough:=True;
      end;
      if IsDayWPR(Day) then begin
        if Options.UseWeekendColors then
          Sh.Cells[BR,Day+Options.FirstDay-1].Interior.Color:=bg.BgColor
      end else begin
        if ei.UseBG then
          Sh.Cells[BR,Day+Options.FirstDay-1].Interior.Color:=bg.BgColor;
      end;
    end;
  end;
end;

procedure TGraphData.SaveData(const AFileName: string);
var SL:TStringList;
begin
  if (CurrYear=0) or (CurrMonth=0) then begin
    ShowMessage('GraphData not Loaded!!!');
    Exit;
  end;
  try
    SL:=TStringList(SaveToStrings);
    SL.SaveToFile(AFileName);
    FModified:=False;
  finally
    SL.Free;
  end;
end;

function TGraphData.SaveToStrings: TStrings;
var W:Integer;
    Q:QWord;
    S:string;
begin
  //сохраняем для себя
  //пишем месяц, год
  //в данных пишем для каждого чела
  //Фамилия=12!1|!2|...
  Result:=TStringList.Create;
  Result.Add('y='+IntToStr(CurrYear));
  Result.Add('m='+IntToStr(CurrMonth));
  Result.Add('w='+IntToStr(WorkerCount));
  Q:=FWPR;
  Result.Add('p='+UIntToStr(Q));
  Result.Add('s='+GetSMInfo);
  Result.Add('#');
  for W:=0 to WorkerCount-1 do begin
    S:=FItems[W].FName+'=';
    {for D:=1 to MonthDays do
      S:=S+FItems[W].Days[D].FHours+'!'+IntToStr(Integer(FItems[W].Days[D].FType))+'|';}
    S:=S+FItems[W].GetDays(MonthDays);
    Result.Add(S);
  end;
end;

function TGraphData.SaveToDB: boolean;
var I:Integer;
    ISQL,USQL,S:string;
    DS:TSQLQuery;
    ucount:integer;
begin
  //сохранение графика
  //где то надо сохранять WPR, наверное, сразу же после изменения и будем
  //сохранять, так как они очень редко меняться будут
  try
    DS:=DM.GetDS('',False);
    if FGraphID = -1 then begin
      ISQL:='insert into graph(iid, sid, tid, tname, lm) values ('+
        '%d, %d, %d, ''%s'', ''%s'') returning gid'.Format([FGraphInfo,
        FSortID, FGraphType, FGraphTypeName, DM._dts(Now(),True)]);
      DS.SQL.Text:=ISQL;
      DS.Open;
      FGraphID:=DS.Fields[0].AsInteger;
      DS.Close;
    end else
      if FModified then begin
        USQL:='update graph set sid=%d, lm=''%s'' where gid=%d'.Format([
          FSortID, DM._dts(Now(),True), FGraphID]);
        DS.SQL.Text:=USQL;
        DS.ExecSQL;
      end;
    ISQL:='insert into graph_data(gid, wid, gdata) values (%d,%d,''%s'') returning did';
    USQL:='update graph_data set gdata=''%s'' where did=%d';
    DS:=DM.GetDS('',False);
    ucount:=0;
    for I:=0 to High(FItems) do begin
      if not FItems[I].FModified then Continue;
      if FItems[I].FLineID<>-1 then begin
        S:=USQL.Format([FItems[I].GetDays(FMontDays),FItems[I].FLineID]);
        DS.SQL.Text:=S;
        DS.ExecSQL;
        Inc(ucount);
      end else begin
        S:=ISQL.Format([FGraphID,FItems[I].FWorkerID,FItems[I].GetDays(FMontDays)]);
        DS.SQL.Text:=S;
        DS.Active:=True;
        FItems[i].FLineID:=DS.Fields[0].AsInteger;
        DS.Close;
        Inc(ucount);
      end;
      FItems[I].FModified:=False;
    end;
    if ucount<>0 then begin
      USQL:='update graph set lm=''%s'' where gid=%d'.Format([
        DM._dts(Now(),True), FGraphID]);
      DS.SQL.Text:=USQL;
      DS.ExecSQL;
    end;
  finally
    DM.CloseDS(DS);
  end;
  FModified:=False;
  Result:=True;
  FStateChange:=scSave;
  DoDataChange;
end;

function TGraphData.LoadData(const AFileName: string): boolean;
var W,M,I,WCount:Integer;
    SL:TStringList;
    S,S1,_SMINFO:string;
begin
  FGraphID:=-1;
  FGraphInfo:=-1;
  FGraphType:=-1;
  FSortID:=-1;
  Result:=False;
  if not FileExists(AFileName) then begin
    ShowMessage(Format('File %s not found!',[FileName]));
    Exit;
  end;
  SL:=TStringList.Create;
  SL.LoadFromFile(AFileName);
  for W:=0 to SL.Count-1 do begin
    S:=SL[W];
    S1:=DivStr(S,'=');
    case S1 of
      'm':CurrMonth:=StrToInt(S);
      'y':CurrYear:=StrToInt(S);
      'w':WCount:=StrToInt(S);
      'p':FWPR:=QWord(StrToInt(S));
      's':_SMINFO:=S;//
      '#':begin
        M:=W;
        Break;
      end
      else
        Continue;
    end;
  end;
  if (CurrYear=0) or (CurrMonth=0) then begin
    SL.Free;
    ShowMessage(Format('Bad format of file %s. Month or year not found!',[FileName]));
    Exit;
  end;
  Inc(M);
  W:=0;
  SetLength(FItems,WCount);
  MonthDays:=DaysInAMonth(CurrYear,CurrMonth);
  for I:=M to SL.Count-1 do begin
    S:=SL[I];
    S1:=DivStr(S,'='); //фамилия
    FItems[W].FName:=S1;
    FItems[W].SetDays(S);
    Inc(W);
  end;
  SetSMInfo(_SMINFO);
  SL.Free;
  Result:=True;
  FModified:=False;
  FFileName:=AFileName;
end;

function TGraphData.LoadFromDB(AMonth, AYear, AGraphType: Integer;
  ATypeName: string): boolean;
begin
  //ищем нашу строчку в таблице графиков
  //получаем ее ид
  //и вызываем загрузку по ид
end;

function TGraphData.LoadFromDB(AGraphID: Integer): boolean;
var SQL:string;
    DS:TSQLQuery;
    I,J:Integer;
    S:string;
begin
  //грузим строчку нашего графика, если есть GID, то все остальное есть(наверное)
  SQL:='select gid, iid, sid, tid, tname, lm from graph where gid='+IntToStr(AGraphID);
  DS:=DM.GetDS(SQL);
  FGraphID:=AGraphID;
  FSortID:=DS.Fields[2].AsInteger;
  FGraphType:=DS.Fields[3].AsInteger;
  FGraphTypeName:=DS.Fields[4].AsString;;
  //потом извлекаем данные из граф_инфо (если надо!!!)
  if DS.Fields[1].AsInteger<>FGraphInfo then begin
    FGraphInfo:=DS.Fields[1].AsInteger;
    DS.Close;
    DS.SQL.Text:='select iid, gyear, gmonth, def_sid, wlist, udata '+
      'from GRAPH_INFO where iid = '+IntToStr(FGraphInfo);
    DS.Open;
    FWPR:=QWord(DS.Fields[4].AsLargeInt);
    FCurrMonth:=DS.Fields[2].AsInteger;
    FCurYear:=DS.Fields[1].AsInteger;
  end;
  DS.Close;
  FMontDays:=DaysInAMonth(CurrYear,CurrMonth);
  SQL:=DM.GetQSingle('select count(oid) from sort_order where sid='+IntToStr(FSortID));
  SetLength(FItems,StrToInt(SQL));
  //потом получаем данные из граф_даты одним запростом и людей и дынные
  {SQL:='select s.wid, w.wname, prt, ' +
    ' (select did || ''*'' || gdata from graph_data gd where gd.wid = s.wid and gd.gid = g.gid) as qqq '+
    ' from sort_order s join workers w on s.wid=w.wid join graph g on g.sid=s.sid '+
    ' where s.sid=%d and g.gid=%d order by oindex '.Format([FSortID, FGraphID]);}
  SQL:='with acte as ( ' +
    'select s.wid as wid, w.wname as wname, prt, oindex, s.sid ' +
    'from sort_order s join workers w on s.wid=w.wid '+
    'where s.sid=%d)' +
    'select a.wid, wname, prt, g.gdata, g.did ' +
    'from acte a left join graph_data g on a.wid=g.wid and gid=%d '+
    'order by a.oindex ';
  DS.SQL.Text:=SQL.Format([FSortID,FGraphID]);
  DS.Open;
  for I:=0 to High(FItems) do begin
    S:=DS.Fields[3].AsString;
    if S='' then begin
      FItems[I].FLineID:=-1;
      FItems[I].FModified:=True;
      FModified:=True;
      for J:=1 to FMontDays do begin
        FItems[I].Days[J].FHours:='';
        FItems[I].Days[J].FType:=dtUnk;
      end;
    end else begin
      FItems[I].FLineID:=DS.Fields[4].AsInteger;
      FItems[I].SetDays(S);
    end;
    FItems[I].FWorkerID:=DS.Fields[0].AsInteger;
    FItems[I].FName:=DS.Fields[1].AsString;
    FItems[I].FSMInfo:=DS.Fields[2].AsInteger=1;
    FItems[I].FModified:=False;
    FItems[I].FUpdated:=True;
    DS.Next;
  end;
  DM.CloseDS(DS);
  FModified:=False;
  FStateChange:=scLoad;
  DoDataChange;
  Result:=True;
  //а потом говорим форме, чтобы она перерисовалась
  //или кто нас вызвал, говорит
end;

function TGraphData.ImportFromFile(WList, GType: Integer; GName: string
  ): boolean;
var I:Integer;
    DS:TSQLQuery;
    SQL,S,S1:string;
begin
  Result:=False;
  FGraphID:=-1;
  //проверяем
  //график есть вообще
  if not Loaded then Exit;
  //количество людей в списке и в графике одинаково
  S:=DM.GetQSingle('select count(oid) from sort_order where sid=%d'.Format([WList]));
  if (S='0') or (StrToINt(S)<>Length(FItems)) then Exit;
  //проверяем, есть ли у нас graph_info
  S:=DM.GetQSingle('select iid from graph_info where gyear=%d and gmonth=%d'.Format([FCurYear,FCurrMonth]));
  //создаем, если нет, на основе данных текущего графика
  //и пихаем данные из нее в тек график
  S1:='';
  if S='' then begin
    SQL:='insert into graph_info(gyear, gmonth, def_sid, wlist) values (%d, %d, %d, %d) returning iid'.Format([FCurYear,FCurrMonth,WList,FWPR]);
    DS:=DM.GetDS(SQL);
    FGraphInfo:=DS.Fields[0].AsInteger;///_iid
    DM.CloseDS(DS);
  end else begin
    //надо проверить, есть ли у нас уже такой график, куда будем экспортировать
    //если есть, спрашиваем, надо ли переписать данные или свалить?
    //по хорошему, это надо проверять в форме выбора
    FGraphInfo:=StrToInt(S);
    SQL:='select gid from graph where iid=%s and tid=%d and tname=''%s'' '.Format([S,GType, GName]);
    S1:=DM.GetQSingle(SQL);
    if S1<>'' then begin
      if Application.MessageBox('Такой график уже есть. Заменить', 'ETH_GRAPH',
        MB_YESNO+MB_ICONWARNING)=IDNO then Exit;
      FGraphID:=StrToInt(S1);
    end;
  end;
  if FGraphID<>-1 then begin
    //валим старый график
    SQL:='delete from graph_data where gid='+IntToStr(FGraphID);
    DM.ExecSQL(SQL);
    //и запихиваем новые значения в graph
    //а там кроме lm ничего и не поменяется
    SQL:='update graph set sid=%d where gid=%d'.Format([WList,FGraphID]);
    DM.ExecSQL(SQL);
  end;
  FSortID:=WList;
  FGraphType:=GType;
  FGraphTypeName:=GName;
  FModified:=True;
  SQL:='select workers.wid, wname, prt from sort_order join workers on workers.wid = sort_order.wid where sid=%d order by oindex '.Format([FSortID]);
  DS:=DM.GetDS(SQL);
  for I:=0 to High(FItems) do begin
    FItems[I].FName:=DS.Fields[1].AsString;
    FItems[I].FWorkerID:=DS.Fields[0].AsInteger;
    FItems[I].FSMInfo:=DS.Fields[2].AsInteger=0;
    FItems[I].FModified:=True;
    FItems[I].FUpdated:=True;
    FItems[I].FLineID:=-1;//graph_data.did
    DS.Next;
  end;
  DM.CloseDS(DS);
  Result:=True;
end;

function TGraphData.SaveWPRAnDSort(AWPR: string; ASort: Integer): boolean;
var SQL:string;
begin
  Result:=False;
  if AWPR<>TextWPR then begin
    TextWPR:=AWPR;
    SQL:='update graph_info set wlist=%d where iid=%d'.Format([FWPR,FGraphInfo]);
    DM.ExecSQL(SQL);
    Result:=True;
  end;
  if ASort<>FSortID then begin
    Result:=True;
    SaveToDB;
    FSortID:=ASort;
    SQL:='update graph set sid=%d where gid=%d'.Format([FSortID,FGraphID]);
    DM.ExecSQL(SQL);
    LoadFromDB(FGraphID);
  end;
end;

procedure TGraphData.NewData;
var I,J:Integer;
    dt:TDateTime;
    TWPR:string;
begin
  //по заданным данным из месяца и года и впр очищает график
  //работники
  //дни
  TWPR:=TextWPR;
  FWPR:=0;
  SetLength(FItems,Options.FWorkerList.Count);
  MonthDays:=DaysInAMonth(CurrYear,CurrMonth);
  for I:=0 to Options.FWorkerList.Count-1 do begin
    FItems[I].FName:=Options.FWorkerList[I];
    FItems[I].FSMInfo:=False;
    for J:=1 to 31 do begin
      FItems[I].Days[J].FHours:='';
      FItems[I].Days[J].FType:=dtUnk;
    end;
  end;
  FWorkerConut:=Length(FItems);
  //выходные
  for I:=1 to MonthDays do begin
    dt:=EncodeDate(CurrYear,CurrMonth,I);
    J:=DayOfWeek(dt);
    if (J=1)or(J=7) then
      TWPR:=StrListAdd(TWPR,IntToStr(I));
  end;
  TextWPR:=TWPR;
  //етные смены
  SetSMInfo(Options.gTSSM);
end;

function TGraphData.GetIniName: string;
begin
  Result:='';
  ShowMessage('ERROR!!!');
  EXIT;
  Result:=Application.Params[0];
  Result:=ChangeFileExt(Result,'.ini');
end;

procedure TGraphData.Analyze;
var I,J:Integer;
    S:string;
    t:TDayType;
begin
  for I:=0 to WorkerCount-1 do begin
    for J:=1 to MonthDays do begin
      t:=dtUnk;
      S:=FItems[I].Days[J].FHours;
      S:=Trim(AnsiUpperCase(S));
      if S='12' then t:=dtDay else
      if S='' then t:=dtMP else
      if S='4' then begin
        if (J<>FMontDays) then
          if FItems[I].Days[J+1].FHours='8'
          then t:=dtNightFirst;
      end else
      if S='8' then begin
        if (J<>1) then
          if FItems[I].Days[J-1].FHours='4'
          then t:=dtNightLast;
      end else
      if S='В' then t:=dtVih else
      if (S='') or (S='МП') then t:=dtMP else
      if S='ОТ' then t:=dtOtp else
      if S='ФВ' then t:=dtFV;
      FItems[I].Days[J].FType:=t;
    end;
  end;
end;

function TGraphData.GetCellValue(AWorker, ADay: Integer): string;
var S:string;
begin
  ////!!!!отображение некоторых типов в графике прибиваем гвоздями - убрать!!!
  Result:=Options.FDayStyles[FItems[Aworker].Days[ADay].FType].FTypeStr;
  S:=FItems[Aworker].Days[ADay].FHours;
  if (Result='') or (Options.gShowHours and (S<>'')) then
    Result:=S;
  if Options.gShowMP and (FItems[Aworker].Days[ADay].FType=dtMP) then
    Result:=Result+'МП';

  if Options.gShowDefChars then begin
    if FItems[Aworker].Days[ADay].FType in [dtNightFirst, dtNightLast, dtDay,
      dtOHT, dtTU, dtZam, dtOther,dtMed] then
      Result:=Result+StrTypes[FItems[Aworker].Days[ADay].FType];
  end;
end;

function TGraphData.GetCellText(AWorker, ADay: Integer): string;
begin
  Result:=FItems[Aworker].Days[ADay].FHours;
end;

function TGraphData.GetCellInfo(AWorker, ADay: Integer): TDayItem;
begin
  if (AWorker>High(FItems)) or (ADay>31) or (AWorker<0) or (ADay <0) then
    Exit;
  Result:=FItems[AWorker].Days[ADay];
end;

function TGraphData.GetCellBg(AWorker, ADay: Integer; UseStyles: TCellUseStyles
  ): TCellBg;
var dt:TDayType;
begin
  //(cusVih, cusSM, sucFontStyle, cusFontColor, cusBgColor)
  Result.BgColor:=clWhite;
  Result.FontColor:=clBlack;
  Result.Styles:=[];
  if (AWorker>High(FItems)) or (ADay>31) or (AWorker<0) or (ADay <0) then
    Exit;

  dt:=FItems[AWorker].Days[ADay].FType;
  if Integer(DT)>Integer(High(TDayType)) then dt:=dtUnk;
  if (cusFontColor in UseStyles) then
    Result.FontColor:=Options.FDayStyles[DT].FFontColor;
  if (cusBgColor in UseStyles) then
    Result.BgColor:=Options.FDayStyles[DT].FBackColor;
  if (cusFontStyle in UseStyles) then
    Result.Styles:=Options.FDayStyles[DT].FFontFlags;
  //смены
  if (cusSM in UseStyles)and(Result.BgColor=clWhite) and (FItems[AWorker].FSMInfo) then
    Result.BgColor:=Options.gColSM;
  //выхи
  if (cusVih in UseStyles) and (IsDayWPR(ADay)) then
     Result.BgColor:=Options.gColVih;
end;

function TGraphData.GetExpInfo(AWorker, ADay: Integer; out S1, S2, S3: string
  ): string;
var di:TDayItem;
    I:Integer;
begin
  Result:='';
  di:=GetCellInfo(AWorker,ADay);
  S1:='ERROR!!!';
  S2:='';S3:='';
  if Options.xTextOnly[di.FType].Use then begin
    S1:=Options.xTextOnly[di.FType].Txt;
    Exit;
  end;
  if not Options.FWorkHours[di.FType].Find(di.FHours,I) then begin
    //пишем в лог
    Result:=Workers[AWorker] + ' - ['+IntToStr(ADay)+'] - неизвестное сочетание типа и часов.'+#13+
      'Тип: '+Options.TypeNames[di.FType]+' , Часы: ['+di.FHours+']';
    Exit;
  end;
  S1:=di.FHours;
  S3:=Options.FWorkHours[di.FType].Data[I];
  S2:=DivStr(S3,'-');
  if S3.IndexOf('|')<>0 then begin
    S1:=S3;
    S3:=DivStr(S1,'|');
    if S1='' then
      S1:=di.FHours;
  end;
end;

procedure TGraphData.SetCellDayType(AWorker, ADay: Integer; ADayType: TDayType);
begin
  FItems[AWorker].Days[ADay].FType:=ADayType;
  FItems[AWorker].FModified:=True;
  FItems[AWorker].FUpdated:=True;
  FModified:=True;
  FStateChange:=scModify;
  DoDataChange;
end;

procedure TGraphData.SetCellHours(AWorker, ADay: Integer; AHours: string);
begin
  FItems[AWorker].Days[ADay].FHours:=AHours;
  FItems[AWorker].FModified:=True;
  FItems[AWorker].FUpdated:=True;
  FModified:=True;
  FStateChange:=scModify;
  DoDataChange;
end;

procedure TGraphData.SetCellSm(AWorker: Integer; A_SM: Boolean);
begin
  FItems[AWorker].FSMInfo:=A_SM;
  {FItems[AWorker].FModified:=True;////!!!неа
  FItems[AWorker].FUpdated:=True;
  FModified:=True;
  DoDataChange;}
end;

procedure TGraphData.Analyze(Errors: TStrings);
var Wrk,Day:Integer;
    O,T:boolean;
    DSize:string;
begin
  //1. отысктиваем непомеченные дни
  for Wrk:=0 to WorkerCount-1 do begin
    for  Day:=1 to MonthDays do begin
      if FItems[Wrk].Days[Day].FType=dtUnk then
        Errors.Add(Format('[%s][%d] - неизвестный тип дня',[FItems[Wrk].FName,Day]));
    end;
  end;
  //2. проверяем, чтобы все ту и охт были одинаковые
  for  Day:=1 to MonthDays do begin
    O:=False;
    T:=False;
    DSize:='';
    for Wrk:=0 to WorkerCount-1 do begin
      if not (FItems[Wrk].Days[Day].FType in [dtTU, dtOHT]) then Continue;
      if FItems[Wrk].Days[Day].FType=dtOHT then begin
        O:=True;
        if DSize='' then DSize:=FItems[Wrk].Days[Day].FHours
        else begin
          if DSize<>FItems[Wrk].Days[Day].FHours then
            Errors.Add(Format('[Day:%d]-не совпадают продолжительности дня ОХТ',[Day]));
        end;
      end else
      if FItems[Wrk].Days[Day].FType=dtTU then begin
        T:=True;
        if DSize='' then DSize:=FItems[Wrk].Days[Day].FHours
        else begin
          if DSize<>FItems[Wrk].Days[Day].FHours then
            Errors.Add(Format('[Day:%d]-не совпадают продолжительности дня ТУ',[Day]));
        end;
      end;
    end;
    if O and T then begin
      Errors.Add(Format('[Day:%d]-ТУ и ОХТ одновременно',[Day]));
    end;
  end;
end;

function TGraphData.GetSD: string;
begin
  Result:='.'+IfThen(CurrMonth<10,'0')+
    IntToStr(CurrMonth)+'.'+IntToStr(CurrYear);
end;

function TGraphData.IsDayWPR(ADay: Integer): boolean;
begin
  Result:=((FWPR shr ADay) and $1)<>0;
end;

procedure TGraphData.GetManList(AList: TStrings);
var I:Integer;
begin
  for I:=0 to High(FItems) do
    AList.Add(FItems[I].FName);
end;

procedure TGraphData.BeginUpdate;
begin
  Inc(FUpdateCount);
end;

procedure TGraphData.EndUpdate;
var I:Integer;
begin
  Dec(FUpdateCount);
  if FUpdateCount=0 then
    DoDataChange;
  for I:=0 to WorkerCount-1 do
    FItems[I].FUpdated:=False;
end;

procedure TGraphData.ChangeType(ANewType: Integer);
var I: Integer;
begin
  FGraphType:=ANewType;
  FGraphID:=-1;
  for I:=0 to High(FItems) do begin
    FItems[I].FModified:=True;
    FItems[I].FLineID:=-1;
  end;
  FModified:=True;
end;

function TGraphData.DBCreateBlank(AYear, AMonth, ASort: IntPtr; AWPR: QWord;
  AType: IntPtr): integer;
var I,J:Integer;
    S:string;
    DS:TSQLQuery;
begin
  Result:=-1;
  //предполагается, что у нас пустой график
  //смтрим, есть ли graph_info
  FCurrMonth:=AMonth;
  FCurYear:=AYear;
  FSortID:=ASort;
  FMontDays:=DaysInAMonth(FCurYear,FCurrMonth);
  //задаем впр и тип
  FWPR:=AWPR;
  FGraphType:=AType;
  FGraphID:=-1;
  FModified:=True;
  S:='select iid from graph_info where gyear = %d and gmonth = %d'.Format([AYear,AMonth]);
  S:=DM.GetQSingle(S);
  if S='' then begin
    //если нет, то создаем
    S:='insert into graph_info(gyear, gmonth, def_sid, wlist)' +
      'values (%d, %d, %d, %u) returning iid'.Format([FCurYear,FCurrMonth,FSortID,DWord(FWPR)]);
    S:=DM.GetQSingle(S);
    FGraphInfo:=StrToInt(S);
  end else begin
    FGraphInfo:=StrToInt(S);
  end;
  //загружаем людей из списка
  S:='select count(wid) from sort_order where sid='+IntToStr(FSortID);
  S:=DM.GetQSingle(S);
  SetLength(FItems,StrToInt(S));
  S:='select s.wid, w.wname, prt from sort_order s join workers w on s.wid=w.wid '+
    ' where sid=%d order by oindex'.Format([FSortID]);
  DS:=DM.GetDS(S);
  for I:=0 to High(FItems) do begin
    FItems[I].FLineID:=-1;
    FItems[I].FModified:=True;
    FItems[I].FUpdated:=True;
    FItems[I].FName:=DS.Fields[1].AsString;
    FItems[I].FSMInfo:=DS.Fields[2].AsInteger=1;
    FItems[I].FWorkerID:=DS.Fields[0].AsInteger;
    for J:=1 to 31 do begin
      FItems[I].Days[J].FHours:='';
      FItems[I].Days[J].FType:=dtUnk;
    end;
    DS.Next;
  end;
  DM.CloseDS(DS);
  Result:=0;
end;

procedure TGraphData.UsePrev(APrewID: Integer);
var FTempData:TGraphData;

  procedure FillWorker(WIndex,Offset:Integer);
  var I:Integer;
  const
    ATypes:array [0..3] of TDayType = (dtDay, dtNightFirst, dtNightLast, dtMP);
    AHours:array [0..3] of string = ('12', '4', '8', '');
  begin
    for I:=1 to FMontDays-Offset do begin
      FItems[WIndex].Days[I+Offset].FType:=ATypes[I mod 4];
      FItems[WIndex].Days[I+Offset].FHours:=AHours[I mod 4];
    end;
  end;

var I,J,Offs:Integer;

begin
  //передается ид графика, из которого надо извлечь данные
  //извлекаеся сменность (с помощью DayDay)
  FTempData:=TGraphData.Create;
  FTempData.LoadFromDB(APrewID);
  for I:=0 to High(FItems) do begin
    J:=FItems[I].FWorkerID;
    Offs:=FTempData.GetDayDay(FTempData.GetWorkerIndex(J))-(FTempData.MonthDays-28);
    if Offs<0 then Inc(Offs,4);
    J:=GetWorkerIndex(J);
    FillWorker(J,Offs);
  end;
  //и переходы между месяцами
  for I:=0 to High(FTempData.FItems) do begin
    if FTempData.FItems[I].Days[FTempData.FMontDays].FType=dtNightFirst then begin
      J:=FTempData.FItems[I].FWorkerID;
      J:=GetWorkerIndex(J);
      FItems[J].Days[1].FHours:='8';
      FItems[J].Days[1].FType:=dtNightLast;
    end;
  end;
  // не проверяется правильность того, что там не предыдущий месяц
  FreeAndNil(FTempData);
end;

procedure TGraphData.ApplyAbsenses;
var SQL:string;
    ADateFirst, ADateLast:TDateTime;
    DS:TSQLQuery;
    AY,AM,AFirstDay,ALastDay:Word;
    AType:TDayType;
    L,I:Integer;
begin
  ADateFirst:=EncodeDate(FCurYear,FCurrMonth,1);
  ADateLast:=EncodeDate(FCurYear,FCurrMonth,DaysInAMonth(FCurYear,FCurrMonth));
  //открываем отсутствия
  //в дни отсутствия ставим флаг, который у нас стоит при вводе отсутствия
  SQL:='select adate, alen, atype, a.wid from absenses a join workers w on a.wid = w.wid where adate '+
    'between ''%s'' and ''%s'' '.Format([DM._dts(IncDay(ADateFirst,-31)), DM._dts(ADateLast)]);
  //ShowMessage(SQL);
  DS:=DM.GetDS(SQL);
  while not DS.EOF do begin
    //выкусываем из отсутствия текущий месяц
    ADateFirst:=DM._std(DS.Fields[0].AsString);
    L:=DS.Fields[1].AsInteger;
    ADateLast:=IncDay(ADateFirst, L-1);
    if ADateLast<EncodeDate(FCurYear,FCurrMonth,1) then begin
      //это все в предыдущем месяце
      DS.Next;
      Continue;
    end;
    DecodeDate(ADateFirst,AY,AM,AFirstDay);
    if AM<>FCurrMonth then AFirstDay:=1;
    DecodeDate(ADateLast,AY,AM,ALastDay);
    if AM<>FCurrMonth then ALastDay:=MonthDays;
    AType:=TDayType(DS.Fields[2].AsInteger);
    L:=GetWorkerIndex(DS.Fields[3].AsInteger);
    //если есть работник, то задаем ему осутствия
    if L<>-1 then begin
      for I:=AFirstDay to ALastDay do
        FItems[L].Days[I].FType:=AType;
      FItems[L].FModified:=True;
      FItems[L].FUpdated:=True;
    end;
    DS.Next;
  end;
  DM.CloseDS(DS);
  FModified:=True;
end;

function TGraphData.GetDayDay(AWorkerIdx: Integer): Integer;
var I,J,K:Integer;
    m:array [0..3] of Integer;
    DayType:TDayType;
    Hours:string;
begin
  //возвращает номер дня, в котором у нас дневная смена
  //день от 1 до 4
  for I:=0 to 3 do m[I]:=0;
  Result:=0;
  J:=AWorkerIdx;
  if J=-1 then Exit;
  for I:=1 to FMontDays do begin
    DayType:=FItems[J].Days[I].FType;
    Hours:=FItems[J].Days[I].FHours;
    if not (DayType in [dtDay, dtNightFirst, dt2Night, dtOtp, dtOther, dtLearn]) then Continue;
{  TDayType = (dtUnk, dtNightFirst, dtNightLast, dtDay, dtOHT, dtTU,
    dtOtp, dtZam, dtVih, dtMP, dt2Night, dtOther, dtFV, dtEzhedn, dtMed, dtLearn,
    dtLine, dtLocked, dtDisease);
}
    K:=I;
    if (DayType in [dtOtp, dtOther, dtLearn]) then begin
      if Hours='4' then Inc(K,3)
      else if Hours<>'12' then Continue;
    end;
    if DayType in [dtNightFirst, dt2Night] then
      K:=K+3;

    K:=K mod 4;
    m[k]:=m[k]+1;
  end;
  K:=0;
  for I:=1 to 3 do begin
    if m[I]>m[K] then K:=I;
  end;
  if K=0 then K:=4;
  Result:=K;
end;

function TGraphData.GetWorkerIndex(WID: Integer): Integer;
var I:Integer;
begin
  Result:=-1;
  for I:=0 to High(FItems) do
    if FItems[I].FWorkerID=WID then begin
      Result:=I;
      Break;
    end;
  if Result=-1 then
    ShowMessage('Worker not found:'+IntToStr(WID));
end;

function TGraphData.GetWorkerID(WIndex: Integer): Integer;
begin
  Result:=FItems[WIndex].FWorkerID;
end;

function TGraphData.GetUpdated(WIndex: Integer): boolean;
begin
  Result:=FItems[WIndex].FUpdated;
end;

function TGraphData.GetWorkerExtra(AWorkerIndex: Integer; AExtraName: string
  ): Integer;
var ei:TExtraItem;
    I: Integer;
begin
  Result:=0;
  ei:=Options.gExtraCols.ByShortName[AExtraName];
  if ei=nil then Exit;
  for I:=1 to FMontDays do
    Result:=Result+ei.GetUsedHoursOfTypeDef(FItems[AWorkerIndex].Days[I],False);
end;

function TGraphData.GetSortName: string;
var S:string;
begin
  S:='select s.sname from sort_info s join graph g on s.sid = g.sid where gid = '+IntToStr(FGraphID);
  Result:=DM.GetQSingle(S);
end;

function TGraphData.GetTypeName: string;
var S:string;
begin
  S:='select t.tname from graph_types t join graph g on t.tid = g.tid where gid = '+IntToStr(FGraphID);
  Result:=DM.GetQSingle(S);
end;

end.

