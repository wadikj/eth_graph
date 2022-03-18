unit u_summ;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls,
  Grids, gdata, eth_tbl, u_options, fgl;

{файл с суммами заводится на каждый год
какой файл открывать, смотрим по текущему году открытого графика (если не совпадает, с текущим графиком, то переоткрываем)
файл находится в папке программы (по хорошему, надо сделать выбор, но пофиг)
имя файла - "год".s
если файла нет, то создаем
идентификация пользователя - по ФИО (если что, надо будет корректировать в графике, чтобы были однинаковые)
колонки, добавляемые для суммирования - идентифицируются по ShortName (не должно быть одиноковыми)

формат файла
1 строка - перечень имен колонок через ","
остальные строки - имена работников = список значений на каждый месяц
Каримов С.Ф.=120@142@134!125@130@151!0@0@0!....

запись данных в эту таблицу ведется только по прямому запросу пользователя
процесс записи
1. Передается в форму список людей. Если имеются новые люди, то выдается запрос - добавить?
  если неуспешно, то процесс передачи данных прекоащается
2. Если добавление прошло успешно, то происходит импорт
  Для каждого работника передается каждое значение суммы из текущего графика
3. После этого происходит пересчет общих сумм


форма позволяет задать
1. Элементы(колонки), которые показываются.
2. Интервал месяцев, за которые показываются данные и происходит суммирование

вид формы
             !01 ! 01 ! 02! 02!   !   !
             ! А !  S ! A ! S !(A)!(S)!
Каримов С.Ф. !120!125 !130!135!250!260!    !
Кармелюк Н.А !121!128 !131!140!252!268!
             !   !    !   !   !   !   !

форма с расчетами открывается из главной из спец меню
при открытии смотрится, какой год открыт в граыике, такой год с суммами и открываем

также год проверяется при экспорте элементов из графика
и при необходимости открывается нужный
}

type
  TMontsList = array [1..12] of TstringList;

  { TWorker }

  TWorker = class
    private
      FName:string;
      FMontsList:TMontsList;
      function GetValue(AIndex, AMonth: Integer): string;
      procedure SetValue(AIndex, AMonth:Integer; ASumm:string);
    public
      constructor Create(ASummCount:Integer);
      destructor Destroy;override;
      property Value[AIndex, AMonth:Integer]:string read GetValue write SetValue;
      property Name:string read FName write FName;
      procedure Clear;
  end;

  TWorkers = specialize TFPGObjectList<TWorker>;

  { TWorkerList }

  TWorkerList = class
    private
      FWorkers: TWorkers;
      FColumns:TStringList;
      FYear:Integer;
      function GetColNames: string;
      function GetWorker(AIndex:Integer): TWorker;
      function GetWorkerByName(AName: string): TWorker;
      function GetWorkerCount: Integer;
      procedure SetColNames(AValue: string);
    public
      constructor Create;
      destructor Destroy; override;
      property Workers[AIndex:Integer]:TWorker read GetWorker;
      property WorkerCount:Integer read GetWorkerCount;
      property ColNames:string read GetColNames write SetColNames; //over ","
      property ColList:TStringList read FColumns;
      property WorkerByName[AName:string]:TWorker read GetWorkerByName;
      function AddWorker(AName:string):Integer; //return new index
      function  HasWorker(ANAme:string):Integer; // index of worker or -1
      procedure SetWorkerData(AWorkerName,AColName, AData:string; AMonth:Integer);//sets values for all workers from Graph
      procedure SetWorkerText(AWorkerName, AData:string);//for reading file
      function GetWorkerData(AWorker:integer):string;
      function GetSumm(AWIndex, AColIndex, AFirstMonth,ALastMonth:Integer):string;

      procedure WriteFile;
      procedure ReadFile(AYear:Integer);
      function CheckDataCols(ACols:string):boolean;
      function GetFileName(AYear:Integer):string;

  end;

type

  { TfrmSumm }

  TfrmSumm = class(TForm)
      btCopy: TButton;
      btUpate: TButton;
      btRead: TButton;
      cbFirst: TComboBox;
      cbLast: TComboBox;
      Label1: TLabel;
      Label2: TLabel;
      Panel1: TPanel;
      sgSumm: TStringGrid;
      procedure btCopyClick(Sender: TObject);
      procedure btUpateClick(Sender: TObject);
      procedure btReadClick(Sender: TObject);
      procedure cbFirstSelect(Sender: TObject);
      procedure cbLastSelect(Sender: TObject);
      procedure FormCreate(Sender: TObject);
      procedure FormDestroy(Sender: TObject);
      procedure FormShow(Sender: TObject);
    private
      FWList:TWorkerList;
      FFirstMonth:Integer;
      FLastMonth:Integer;
      procedure SetFirstMonth(AValue: Integer);
      procedure SetLastMonth(AValue: Integer);
      procedure CheckDataYear;
    public
      procedure UpdateView; //update cells
      procedure InitView; //init grid sizes
    published
      property FirstMonth:Integer read FFirstMonth write SetFirstMonth;
      property LastMonth:Integer read FLastMonth write SetLastMonth;
  end;

var
  frmSumm: TfrmSumm;

implementation

uses s_tools, Clipbrd;

{$R *.lfm}

{ TfrmSumm }

procedure TfrmSumm.btUpateClick(Sender: TObject);
begin
  InitView;
  UpdateView;
end;

procedure TfrmSumm.btCopyClick(Sender: TObject);
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

procedure TfrmSumm.btReadClick(Sender: TObject);
var XMonth{, XYear}:Integer;
    I,J,K,L,M:Integer;
    ei:TExtraItem;
begin
  XMonth:=frmTable.GraphData.CurrMonth;
  //XYear:=frmTable.GraphData.CurrYear;
  CheckDataYear;
  Caption:='Суммированный учет рабочего времени за '+IntToStr(FWList.FYear)+' год';
  //сначала экспорт работников
  for I:= 0 to frmTable.GraphData.WorkerCount-1 do begin
    J:=FWList.HasWorker(frmTable.GraphData.Workers[I]);
    if J=-1 then begin
      //ShowMessage('Add worker '+ frmTable.GraphData.Workers[I]);
      FWList.AddWorker(frmTable.GraphData.Workers[I]);
    end;
  end;
  //теперь для каждого работника создаем и перетаскиваем данные
  for I:=0 to frmTable.GraphData.WorkerCount-1 do begin
    for J:=0 to Options.gExtraCols.Count-1 do begin
      K:=FWList.FColumns.IndexOf(Options.gExtraCols.Items[J].ShortName);
      if K=-1 then Continue;
      ei:=Options.gExtraCols.Items[J];
      M:=0;
      for L:=1 to frmTable.GraphData.MonthDays do begin
        M:=M+ei.GetUsedHoursOfTypeDef(frmTable.GraphData.GetCellInfo(I,L),False);
      end;
      FWList.SetWorkerData(frmTable.GraphData.Workers[I],FWList.FColumns[k],IntToStr(m),XMonth);
    end;
  end;
  InitView;
  UpdateView;
end;

procedure TfrmSumm.cbFirstSelect(Sender: TObject);
begin
  FFirstMonth:=cbFirst.ItemIndex+1;
end;

procedure TfrmSumm.cbLastSelect(Sender: TObject);
begin
  FLastMonth:=cbLast.ItemIndex+1;
end;

procedure TfrmSumm.FormCreate(Sender: TObject);
begin
  FFirstMonth:=1;
  FLastMonth:=3;
  FWList:=TWorkerList.Create;
  Options.LoadComponent('Left,Top,Width,Height,FirstMonth,LastMonth',Self);
  FWList.ColNames:=Options.sCols;
end;

procedure TfrmSumm.FormDestroy(Sender: TObject);
begin
  Options.SaveComponent('Left,Top,Width,Height,FirstMonth,LastMonth',Self);
  FWList.Free;
end;

procedure TfrmSumm.FormShow(Sender: TObject);
begin
  CheckDataYear;
  if FWList.FYear=0 then Exit;
  InitView;
  UpdateView;
end;

procedure TfrmSumm.SetFirstMonth(AValue: Integer);
begin
  if FFirstMonth=AValue then Exit;
  FFirstMonth:=AValue;
  cbFirst.ItemIndex:=FFirstMonth-1;
end;

procedure TfrmSumm.SetLastMonth(AValue: Integer);
begin
  if FLastMonth=AValue then Exit;
  FLastMonth:=AValue;
  cbLast.ItemIndex:=FLastMonth-1;
end;

procedure TfrmSumm.CheckDataYear;
var XYear:Integer;
begin
  //проверяет, какой год открыт в графике, и если не совпадлает с текущим для таблицы, то
  //переоткрывеает нужные данные
  if frmTable.GraphData=nil then Exit;
  XYear:=frmTable.GraphData.CurrYear;
  if XYear<>FWList.FYear then begin
    if XYear<>0 then
      FWList.WriteFile;
    if XYear<>0 then begin
      FWList.ReadFile(XYear);
    end;
  end;
end;

procedure TfrmSumm.UpdateView;
var I,J,X,Y,S:Integer;
    Offs:integer;
begin
  //роботники
  for I:=0 to FWList.WorkerCount-1 do begin
    sgSumm.Cells[0,I+2]:=FWList.Workers[I].Name;
  end;
  S:=FWList.FColumns.Count;
  //зоголовок
  for I:=0 to (FLastMonth-FFirstMonth) do begin
    for J:=0 to S-1 do begin
      sgSumm.Cells[I*S+J+1,0]:=IntToStr(FFirstMonth+I);
      sgSumm.Cells[I*S+J+1,1]:=FWList.FColumns[J];
    end;
  end;
  for J:=0 to S-1 do begin
    sgSumm.Cells[(FLastMonth-FFirstMonth+1)*S+1+J,0]:='SUM';
    sgSumm.Cells[(FLastMonth-FFirstMonth+1)*S+1+J,1]:='('+FWList.FColumns[J]+')';
  end;
  Offs:=(FLastMonth-FFirstMonth+1)*FWList.FColumns.Count+1;
  //все остальное
  for Y:=0 to FWList.WorkerCount-1  do begin //для каждого работника
    for I:=FFirstMonth to FLastMonth do begin //для каждого месяца
      for J:=0 to FWList.FColumns.Count-1 do begin
        sgSumm.Cells[1+(I-FFirstMonth)*FWList.FColumns.Count+J,Y+2]:=FWList.Workers[Y].FMontsList[I][J];
      end;
    end;
    ///   суммы
    for X:=0 to FWList.FColumns.Count-1 do begin
      S:=0;
      for I:=FFirstMonth to FLastMonth do begin
        S:=S+StrToInt(FWList.Workers[Y].FMontsList[I][X]);
      end;
      sgSumm.Cells[Offs+X,Y+2]:=IntToStr(S)
    end;
  end;
end;

procedure TfrmSumm.InitView;
begin
  sgSumm.ColWidths[0]:=200;
  sgSumm.RowCount:=FWList.WorkerCount+2;
  sgSumm.ColCount:=FWList.FColumns.Count*(FLastMonth-FFirstMonth+2)+1;
end;

{ TWorkerList }

function TWorkerList.GetColNames: string;
var
  I: Integer;
begin
  Result:='';
  if FColumns.Count = 0 then Exit;
  Result:=FColumns[0];
  for I:=1 to FColumns.Count-1 do
    Result:=Result+','+FColumns[I];
end;

function TWorkerList.GetWorker(AIndex: Integer): TWorker;
begin
  Result:=nil;
  if (AIndex>=FWorkers.Count)or(AIndex<0) then Exit;
  Result:=FWorkers[AIndex];
end;

function TWorkerList.GetWorkerByName(AName: string): TWorker;
begin
  Result:=GetWorker(HasWorker(AName));
end;

function TWorkerList.GetWorkerCount: Integer;
begin
  Result:=FWorkers.Count;
end;

procedure TWorkerList.SetColNames(AValue: string);
begin
  FColumns.Clear;
  while AValue<>'' do
    FColumns.Add(DivStr(AValue,','));
end;

constructor TWorkerList.Create;
begin
  FWorkers:=TWorkers.Create(True);
  FColumns:=TStringList.Create;

  FYear:=0;
end;

destructor TWorkerList.Destroy;
begin
  WriteFile;
  FWorkers.Free;
  FColumns.Free;
  inherited Destroy;
end;

function TWorkerList.AddWorker(AName: string): Integer;
var W:TWorker;
begin
  W:=TWorker.Create(FColumns.Count);
  W.FName:=AName;
  Result:=FWorkers.Add(W);
end;

function TWorkerList.HasWorker(ANAme: string): Integer;
var I:Integer;
begin
  Result:=-1;
  for I:=0 to FWorkers.Count-1 do begin
    if FWorkers[I].Name=ANAme then begin
      Result:=I;
      break;
    end;
  end;
end;

procedure TWorkerList.SetWorkerData(AWorkerName, AColName, AData: string;
  AMonth: Integer);
var CI:Integer;
    W:TWorker;
begin
  //raise exceptions if data incorrect
  CI:=FColumns.IndexOf(AColName);
  W:=WorkerByName[AWorkerName];
  W.FMontsList[AMonth][CI]:=AData;
end;

procedure TWorkerList.SetWorkerText(AWorkerName, AData: string);
var W:TWorker;
    I,M,C:Integer;
    S1,S2:string;
begin
  //set data extracted from file
  I:=HasWorker(AWorkerName);
  if I=-1 then begin
    I:=AddWorker(AWorkerName);
  end;
  W:=WorkerByName[AWorkerName];
  M:=1;
  while AData<>'' do begin
    S1:=DivStr(AData, '!');
    C:=0;
    while S1<>'' do begin
      S2:=DivStr(S1,'@');
      W.FMontsList[M][C]:=S2;
      Inc(C);
    end;
    Inc(M)
  end;
end;

function TWorkerList.GetWorkerData(AWorker: integer): string;
var W:TWorker;
    S:string;
    I,J:Integer;
begin
  W:=FWorkers[AWorker];
  Result:='';
  for I:=1 to 12 do begin
    S:='';
    for J:=0 to FColumns.Count-1 do begin
      S:=StrListAdd(S,W.Value[J,I],'@');
    end;
    Result:=StrListAdd(Result,S,'!');
  end;
end;

function TWorkerList.GetSumm(AWIndex, AColIndex, AFirstMonth,
  ALastMonth: Integer): string;
var W:TWorker;
    I:Integer;
    R:Integer;
begin
  W:=Workers[AWIndex];
  Result:='ERR!';
  R:=0;
  for I:=AFirstMonth to ALastMonth do
    R:=R+StrToInt(W.FMontsList[I][AColIndex]);
  Result:=IntToStr(R);
end;

procedure TWorkerList.WriteFile;
var SL:TStringList;
    I:Integer;
begin
  if FYear=0 then Exit;
  try
    SL:=TStringList.Create;
    SL.Add(ColNames);
    for I:=0 to FWorkers.Count-1 do
      SL.Add(FWorkers[I].Name+'='+GetWorkerData(I));
    SL.SaveToFile(GetFileName(FYear));
  finally
    SL.Free;
  end;
end;

procedure TWorkerList.ReadFile(AYear: Integer);
var fName,S,S1,S2:string;
    SL:TStringList;
begin
  FYear:=AYear;
  FWorkers.Clear;
  fName:=GetFileName(AYear);
  if not FileExists(fName) then begin
    Exit;
  end;
  SL:=TStringList.Create;
  try
    SL.LoadFromFile(fName);
    S:=SL[0];
    SL.Delete(0);
    if CheckDataCols(S) then begin
      ColNames:=S;
      for S in SL do begin
        S2:=S;
        S1:=DivStr(S2,'=');
        SetWorkerText(S1,S2);
      end;
    end else begin
      ShowMessage('Колонки для ведения суммированного учета изменились'#13+
      'Данные за '+IntToStr(FYear)+' будут удалены. Для их восстановления '#13+
      'откройте все графики за этот год и экспортируйте данные заново.');
      ColNames:=Options.sCols;
    end;
  finally
    SL.Free;
  end;
end;

function TWorkerList.CheckDataCols(ACols: string): boolean;
begin
  Result:=True;
  if ACols=Options.sCols then Exit;
  Result:=False;
end;

function TWorkerList.GetFileName(AYear: Integer): string;
begin
  Result:=ExtractFilePath(Application.ExeName)+'\'+IntToStr(AYear)+'.s';
end;

{ TWorker }

function TWorker.GetValue(AIndex, AMonth: Integer): string;
begin
  Result:=FMontsList[AMonth][AIndex];
end;

procedure TWorker.SetValue(AIndex, AMonth: Integer; ASumm: string);
begin
  FMontsList[AMonth][AIndex]:=ASumm;
end;

constructor TWorker.Create(ASummCount: Integer);
var
  I, J: Integer;
begin
  for I:=1 to 12 do begin
    FMontsList[I]:=TStringList.Create;
    for J:=0 to ASummCount-1 do
      FMontsList[I].Add('0');
  end;
end;

destructor TWorker.Destroy;
var
  I: Integer;
begin
  for I:=1 to 12 do
    FMontsList[I].Free;
  inherited Destroy;
end;

procedure TWorker.Clear;
var
  I, J: Integer;
begin
  for I:=1 to 12 do begin
    for J:=0 to FMontsList[I].Count-1 do
      FMontsList[I].Add('0');
  end;
end;

end.



