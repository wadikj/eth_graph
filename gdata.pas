unit gdata;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, ComObj, Forms, Dialogs, u_options, Graphics;

type

  TGraphItem = record
    FName:string;//имя работника
    FSMInfo:boolean;//инфа о четной смене
    Days:array [1..31] of TDayItem;//дни работника
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


  { TGraphData }

  TGraphData = class
    private
      FCurrMonth: integer;
      FCurYear: Integer;
      FFileName: string;
      FModified: boolean;
      FMontDays:integer;
      FWorkerConut:integer;
      FItems:TGraphItems;
      FWPR: dword;
      procedure CreateManList(AData:TStrings);
      function GetSMInfo: string;
      function GetTextWPR: string;
      function GetWorker(WIndex: Integer): string;
      function GetWorkerConut: Integer;
      procedure SetSMInfo(AValue: string);
      procedure SetTextWPR(AValue: string);
      procedure SetWorker(WIndex: Integer; AValue: string);
      procedure SetWorkerCount(AValue: Integer);
    public
      constructor Create;
      destructor Destroy; override;
      procedure ImportData(XL:OleVariant);
      procedure ExportData(XP:OleVariant);
      procedure ExportOldGraph(XP:OleVariant);
      procedure SaveData(const AFileName:string);
      function  LoadData(const AFileName:string):boolean;
      procedure NewData;
      function GetIniName:string;
      procedure Analyze;
      //read graph data
      function GetCellValue(AWorker,ADay:Integer):string;
      function GetCellText(AWorker,ADay:Integer):string;
      function GetCellInfo(AWorker,ADay:Integer):TDayItem;
      function GetCellBg(AWorker,ADay:Integer;UseStyles:TCellUseStyles):TCellBg;
      function GetExpInfo(AWorker,ADay:Integer;out S1,S2,S3:string):string;
      //write graph data
      procedure SetCellDayType(AWorker,ADay:Integer;ADayType:TDayType);
      procedure SetCellHours(AWorker,ADay:Integer;AHours:string);
      procedure SetCellSm(AWorker:Integer;A_SM:Boolean);
      procedure Analyze(Errors:TStrings);
      //date
      property CurrMonth:Integer read FCurrMonth write FCurrMonth;
      property CurrYear:Integer read FCurYear write FCurYear;
      function GetSD:string;

      property WPR:DWord read FWPR write FWPR;//выхи и праздники для сохранения
      property TextWPR:string read GetTextWPR write SetTextWPR;//выхи и праздники в тексте
      function IsDayWPR(ADay:Integer):boolean;//вых или праздничный день
      procedure GetManList(AList:TStrings);
      property SMInfo:string read GetSMInfo write SetSMInfo;//инфа о сменах в текстовом виде

      property FileName:string read FFileName write FFileName;
      property Modified:boolean read FModified write FModified;
      property Workers[WIndex:Integer]:string read GetWorker write SetWorker;


    published
      //import/export - old format
      property MonthDays:Integer read FMontDays write FMontDays; // auto from month and year
      property WorkerCount:Integer read GetWorkerConut write SetWorkerCount;

  end;

implementation

uses s_tools, u_memo, StrUtils, dateutils, Math;

{ TGraphData }

procedure TGraphData.CreateManList(AData: TStrings);
var Wrk,Day,I:Integer;
    O,T:boolean;S:string;
    sd:string;
    OLen,TLen:integer;
    di:TDayItem;
begin
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

constructor TGraphData.Create;
begin
  CurrYear:=0;
  CurrMonth:=0;
  FWPR:=0;
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
begin
  Sh:=XP.ActiveSheet;
  SL:=TStringList.Create;
  for Wrk:=0 to WorkerCount-1 do begin
    for Day:=1 to MonthDays do begin
      S:=GetExpInfo(Wrk,Day,S1,S2,S3);
      BR:=Options.xFirstRow+Wrk*3;
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
    W,D:Integer;
    Q:QWord;
    S:string;
begin
  //сохраняем для себя
  //пишем месяц, год
  //в данных пишем для каждого чела
  //Фамилия=12!1|!2|...
  if (CurrYear=0) or (CurrMonth=0) then begin
    ShowMessage('GraphData not Loaded!!!');
    Exit;
  end;
  SL:=TStringList.Create;
  try
    SL.Add('y='+IntToStr(CurrYear));
    SL.Add('m='+IntToStr(CurrMonth));
    SL.Add('w='+IntToStr(WorkerCount));
    Q:=FWPR;
    SL.Add('p='+UIntToStr(Q));
    SL.Add('s='+GetSMInfo);
    SL.Add('#');
    for W:=0 to WorkerCount-1 do begin
      S:=FItems[W].FName+'=';
      for D:=1 to MonthDays do
        S:=S+FItems[W].Days[D].FHours+'!'+IntToStr(Integer(FItems[W].Days[D].FType))+'|';
      SL.Add(S);
    end;
    SL.SaveToFile(AFileName);
    FModified:=False;
  finally
    SL.Free;
  end;
end;

function TGraphData.LoadData(const AFileName: string): boolean;
var W,M,D,I,WCount:Integer;
    SL:TStringList;
    S,S1,_SMINFO:string;
begin
  Result:=False;
  if not FileExists(AFileName) then begin
    ShowMessage(Format('File %s not found!',[FileName]));
    Exit;
  end;
  SL:=TStringList.Create;
  SL.LoadFromFile(AFileName);
  _SMINFO:='';
  M:=0;
  WCount:=0;
  for W:=0 to SL.Count-1 do begin
    S:=SL[W];
    S1:=DivStr(S,'=');
    case S1 of
      'm':CurrMonth:=StrToInt(S);
      'y':CurrYear:=StrToInt(S);
      'w':WCount:=StrToInt(S);
      'p':FWPR:=DWord(StrToInt(S));
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
    ShowMessage(Format('Bad for mat of file %s. Month or year not found!',[FileName]));
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
    D:=1;
    while S<>'' do begin
      S1:=DivStr(S,'|');//S1-day
      if Pos('!',S1)=0 then Break;//empty data
      FItems[W].Days[D].FHours:=DivStr(S1,'!');
      FItems[W].Days[D].FType:=TDayType(StrToInt(S1));
      Inc(D)
    end;
    Inc(W);
  end;
  SetSMInfo(_SMINFO);
  SL.Free;
  Result:=True;
  FFileName:=AFileName;
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
begin
  Result:=Options.FDayStyles[FItems[Aworker].Days[ADay].FType].FTypeStr;
  if Result='' then
    Result:=FItems[Aworker].Days[ADay].FHours;
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
  Result.FHours:='';
  Result.FType:=dtUnk;
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
end;

procedure TGraphData.SetCellDayType(AWorker, ADay: Integer; ADayType: TDayType);
begin
  FItems[AWorker].Days[ADay].FType:=ADayType;
  FModified:=True;
end;

procedure TGraphData.SetCellHours(AWorker, ADay: Integer; AHours: string);
begin
  FItems[AWorker].Days[ADay].FHours:=AHours;
  FModified:=True;
end;

procedure TGraphData.SetCellSm(AWorker: Integer; A_SM: Boolean);
begin
  FItems[AWorker].FSMInfo:=A_SM;
  FModified:=True;
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

end.

