unit u_newDBGraph;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, Spin,
  ExtCtrls, Buttons, gdata;

type

  { TfrmNewDBGraph }

  TfrmNewDBGraph = class(TForm)
    bbOk: TBitBtn;
    bbCancel: TBitBtn;
    cbMonth: TComboBox;
    cbSortList: TComboBox;
    cbGType: TComboBox;
    cbUseAbsenses: TCheckBox;
    cbPredGraph: TComboBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    leWeekends: TLabeledEdit;
    seYear: TSpinEdit;
    procedure bbCancelClick(Sender: TObject);
    procedure bbOkClick(Sender: TObject);
    procedure cbMonthSelect(Sender: TObject);
    procedure cbPredGraphSelect(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormDestroy(Sender: TObject);
    procedure seYearChange(Sender: TObject);
  private
    FData:TGraphData;
    FPrevData:TGraphData;
    function InitView:boolean;
    function GetGraphID:Integer;
    procedure ChangeDate;
    procedure ChangeTemplate;
    function GetWPR(AYear, AMonth:word):string;
    function TextWPR(AValue:QWord):string;
    function IntWPR(AValue:string):QWord;

    function CopyGraph:boolean;
    function BlankGraph:boolean;
    function BuildGraph:boolean;
  public


  end;

var
  frmNewDBGraph: TfrmNewDBGraph;

function CreateDBGraph:Integer;

implementation

uses u_data, s_tools, SQLDB, DateUtils;

function CreateDBGraph: Integer;
begin
  //создаем новый график и сразу пихаем его в датабазу и возвращаем ИД
  //если не создали ничего, то возвращаем -1
  //в процессе можем создавать классы типа TGraphData для работы с данными
  //график не должен существовать в БД!!!
  Result:=-1;
  Application.CreateForm(TfrmNewDBGraph, frmNewDBGraph);
  if not frmNewDBGraph.InitView then begin
    FreeAndNil(frmNewDBGraph);
    Exit;
  end;
  if frmNewDBGraph.ShowModal=mrOK then begin
    Result:=frmNewDBGraph.GetGraphID;
  end;
  FreeAndNil(frmNewDBGraph);
end;

{$R *.lfm}

{ TfrmNewDBGraph }

procedure TfrmNewDBGraph.FormDestroy(Sender: TObject);
begin
  FreeAndNil(FData);
  FreeAndNil(FPrevData);
end;

procedure TfrmNewDBGraph.seYearChange(Sender: TObject);
begin
  ChangeDate;
end;

procedure TfrmNewDBGraph.FormClose(Sender: TObject;
  var CloseAction: TCloseAction);
begin
  CloseAction:=caHide;
end;

procedure TfrmNewDBGraph.cbMonthSelect(Sender: TObject);
begin
  ChangeDate;
end;

procedure TfrmNewDBGraph.bbOkClick(Sender: TObject);
var Success:boolean;
    S:string;
    I:Integer;
begin
  Success:=False;
  ///!!!должны быть выбраны тип и прочее, тоже надо проверить
  if cbGType.ItemIndex=-1 then begin
    ShowMessage('Необходимо задать тип графика');
    Exit;
  end;
  if cbSortList.ItemIndex=-1 then begin
    ShowMessage('Необходимо хадать список персонала');
    Exit;
  end;
  //проверяем, вдруг у нас уже есть график тaкого же типа,
  //тогда предупреждаем об этом и сваливаем
  S:='select count (g.iid) from graph_info gi join  graph g on g.iid = gi.iid '+
    'where gyear = %d and gmonth = %d and tid=%d '.Format([seYear.Value, cbMonth.ItemIndex+1,
    PtrInt(cbGType.Items.Objects[cbGType.ItemIndex])]);
  S:=DM.GetQSingle(S);
  I:=StrToInt(S);
  if I=1 then begin
    ShowMessage('График такого типа уже имеется. Измените тип графика или удалите данные!!!');
    Exit;
  end;
  if I>1 then begin
    ShowMessage('Есть несколько графиков данного типа. Необходимо устранить эту ошибку!!!');
    Exit;
  end;
  if cbPredGraph.ItemIndex=0 then begin
    //new graph without data
    //если без шаблона, то делаем пустой
    Success:=BlankGraph;
  end else begin
    I:=PtrInt(cbPredGraph.Items.Objects[cbPredGraph.ItemIndex]);
    S:='select gmonth from graph_info gi join graph g on gi.iid = g.iid where gid='+IntToStr(I);
    S:=DM.GetQSingle(S);
    if StrToInt(S)=cbMonth.ItemIndex+1 then begin
      //copy graph
      //если у нас инфа берется из шаблона тек месяца, то тупо копируем
      Success:=CopyGraph;
    end else begin
      //если из шаблона предыдущего месяца, то строим график
      //берем из шаблона смены и переходы между месяцами
      Success:=BuildGraph;
    end;
  end;

  //и не забываем отсутствия

  //в любом случае у нас после окончания работ имеется график, который нужно сохранить
  //если функция сождания вернула True


  if Success then begin
    FData.SaveToDB;
    ModalResult:=mrOK;
  end;
end;

procedure TfrmNewDBGraph.bbCancelClick(Sender: TObject);
begin

end;

procedure TfrmNewDBGraph.cbPredGraphSelect(Sender: TObject);
begin
  ChangeTemplate;
end;

function TfrmNewDBGraph.InitView: boolean;
var S:string;
begin
  Result:=False;
  FData:=nil;
  FPrevData:=nil;
  S:=DM.GetQSingle('select count(sid) from sort_info');
  if S='0' then begin
    ShowMessage('Нет списка персонала для создания графика!!!');
    Exit;
  end;
  S:=DM.GetQSingle('select count(tid) from graph_types');
  if S='0' then begin
    ShowMessage('Не создан хотя бы один тип графика!!!');
    Exit;
  end;
  //заполняем типы графика
  DM.LoadStrings('select tid, tname from graph_types', cbGType.Items);
  //заполняем списки персонала
  DM.LoadStrings('select sid, sname from sort_info', cbSortList.Items);
  Result:=True;
  ChangeDate;
  ChangeTemplate;
end;

function TfrmNewDBGraph.GetGraphID: Integer;
begin
  Result:=-1;
  if FData<>nil then
    Result:=FData.GraphID;
end;

procedure TfrmNewDBGraph.ChangeDate;
var ADay,AYear,AMonth:Word;
    I1,I2:Integer;
    S,S1:string;
    DS:TSQLQuery;
begin
  //меняется дата
  //заполняем список графиков, доступных для шаблона
  try
    cbPredGraph.Items.BeginUpdate;
    cbPredGraph.Items.Clear;
    cbPredGraph.Items.AddObject('Не использовать', TObject(-1));
    //список графиков за заданный месяц и за предыдущий
    I1:=-1;I2:=-1;
    AYear:=seYear.Value;
    AMonth:=cbMonth.ItemIndex+1;
    //изменяем впр
    leWeekends.Text:=GetWPR(AYear,AMonth);
    leWeekends.Enabled:=True;
    S:=DM.GetQSingle('select iid from graph_info where gyear=%d and gmonth=%d'.Format([AYear, AMonth]));
    if S<>'' then begin
      I1:=StrToInt(S);
    end;
    ADay:=1;
    IncAMonth(AYear,AMonth,ADay,-1);
    S:=DM.GetQSingle('select iid from graph_info where gyear=%d and gmonth=%d'.Format([AYear, AMonth]));
    if S<>'' then begin
      I2:=StrToInt(S);
    end;
    S:='';
    if I1<>-1 then S:=IntToStr(I1);
    if I2<>-1 then S:=StrListAdd(S,IntToStr(I2));
    if S<>'' then begin
      S1:='select gid, g.tid, gt.tname, gmonth, gyear from graph g  join graph_types gt on g.tid = gt.tid '+
        'join graph_info gi on g.iid = gi.iid where g.iid in (%s)'.Format([S]);
      DS:=DM.GetDS(S1);
      while not DS.EOF do begin
        S:=DefaultFormatSettings.LongMonthNames[DS.Fields[3].AsInteger]+', '+DS.Fields[4].AsString+ '['+
          DS.Fields[2].AsString+']';
        cbPredGraph.Items.AddObject(S,TObject(PtrInt(DS.Fields[0].AsInteger)));
        DS.Next;
      end;
      DM.CloseDS(DS);
    end;
  finally
    cbPredGraph.ItemIndex:=0;
    cbPredGraph.Items.EndUpdate;
  end;
end;

procedure TfrmNewDBGraph.ChangeTemplate;
var I,J:Integer;
    S:string;
begin
  //если же вообще не использовать шаблон, то все редактируется
  if cbPredGraph.ItemIndex=0 then begin
    leWeekends.Enabled:=True;
    leWeekends.Text:=GetWPR(seYear.Value,cbMonth.ItemIndex+1);
    cbSortList.Enabled:=True;
    cbUseAbsenses.Enabled:=True;
    cbUseAbsenses.Checked:=True;
    Exit;
  end;
  //устанавливаем тот же список персонала, что и в шаблоне
  //и запрещаем его редактирование
  //если у нас в шаблоне тот же месяц, что и для создания, то просто
  //копируем все из шаблона и энаблим (кроме типа графика)
  I:=PtrInt(cbPredGraph.Items.Objects[cbPredGraph.ItemIndex]);
  S:='select gmonth from graph_info gi join graph g on g.iid = gi.iid where g.gid = ' + IntToStr(I);
  S:=DM.GetQSingle(S);

  J:=StrToInt(DM.GetQSingle('select sid from graph where gid = '+IntToStr(I)));
  J:=cbSortList.Items.IndexOfObject(TObject(PtrInt(J)));
  if J<>-1 then cbSortList.ItemIndex:=J;
  cbSortList.Enabled:=False;

  if cbMonth.ItemIndex + 1 = StrToInt(S) then begin
    //в шаблоне тот же месяц, что и создаем
    S:='select wlist from graph_info gi join graph g on g.iid = gi.iid where g.gid = ' + IntToStr(I);
    S:=DM.GetQSingle(S);
    leWeekends.Text:=TextWPR(StrToInt(S));
    leWeekends.Enabled:=False;
    cbUseAbsenses.Enabled:=False;
    Exit;
  end;
  //если же предыдущий месяц, то можно редактировать все кроме списка людей
  //устанавливаем те же впр ()
  ///!!!если у нас уже есть графики на требуемый месяц, то ВПР надо брать оттуда
  S:='select wlist from graph_info where gyear = %d and gmonth = %d'.Format([seYear.Value,cbMonth.ItemIndex+1]);
  S:=DM.GetQSingle(S);
  if S='' then begin
    leWeekends.Enabled:=True;
    leWeekends.Text:=GetWPR(seYear.Value,cbMonth.ItemIndex+1);
  end else begin
    leWeekends.Text:=TextWPR(QWord(StrToInt(S)));
    leWeekends.Enabled:=False;
  end;
  cbSortList.Enabled:=True;
  cbUseAbsenses.Enabled:=True;
  cbUseAbsenses.Checked:=True;
end;

function TfrmNewDBGraph.GetWPR(AYear, AMonth: word): string;
var I:Integer;
    MonthDays, J:Integer;
    dt: TDateTime;
begin
  Result:='';
  MonthDays:=DaysInAMonth(AYear,AMonth);
  for I:=1 to MonthDays do begin
    dt:=EncodeDate(AYear,AMonth,I);
    J:=DayOfWeek(dt);
    if (J=1)or(J=7) then
      Result:=StrListAdd(Result,IntToStr(I));
  end;
end;

function TfrmNewDBGraph.TextWPR(AValue: QWord): string;
var I:Word;
begin
  Result:='';
  for I:=1 to 31 do
    if ((AValue shr I) and $1)<>0 then
      Result:=StrListAdd(Result,IntToStr(I),',');
end;

function TfrmNewDBGraph.IntWPR(AValue: string): QWord;
var S:string;
    I:Integer;
    J,DW:DWord;
begin
  Result:=0;
  while AValue<>'' do begin
    S:=DivStr(AValue,',');
    I:=StrToInt(S);
    DW:=1;
    J:=(DW shl I);
    Result:=Result or J;
  end;
end;

function TfrmNewDBGraph.CopyGraph: boolean;
var I:Integer;
begin
  //если у нас инфа берется из шаблона тек месяца, то тупо копируем
  FData:=TGraphData.Create;
  I:=PtrInt(cbPredGraph.Items.Objects[cbPredGraph.ItemIndex]);
  FData.LoadFromDB(I);
  FData.ChangeType(PtrInt(cbGType.Items.Objects[cbGType.ItemIndex]));
  Result:=True;
end;

function TfrmNewDBGraph.BlankGraph: boolean;
begin
  //new empty graph
  FData:=TGraphData.Create;
  FData.DBCreateBlank(seYear.Value,cbMonth.ItemIndex+1,
    PtrInt(cbSortList.Items.Objects[cbSortList.ItemIndex]),
    IntWPR(leWeekends.Text), QWord(cbGType.Items.Objects[cbGType.ItemIndex]));
  //FData.TextWPR:=leWeekends.Text;
  if cbUseAbsenses.Checked then
    FData.ApplyAbsenses;
  FData.Modified:=True;
  Result:=True;
end;

function TfrmNewDBGraph.BuildGraph: boolean;
var I:Integer;
begin
  Result:=BlankGraph;
  I:=-1;
  if cbPredGraph.ItemIndex<>-1 then
    I:=PtrInt(cbPredGraph.Items.Objects[cbPredGraph.ItemIndex]);
  if I<>-1 then
    FData.UsePrev(I);
  if cbUseAbsenses.Checked then
    FData.ApplyAbsenses;
  Result:=True;
end;


end.

