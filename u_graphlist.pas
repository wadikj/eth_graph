unit u_GraphList;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ComCtrls;

type

  { TfrmGraphList }

  TfrmGraphList = class(TForm)
    ImageList1: TImageList;
    ToolBar1: TToolBar;
    tbNewGraph: TToolButton;
    tbDelSelected: TToolButton;
    tbAlwaysOnTop: TToolButton;
    tbUpdate: TToolButton;
    tbCmp: TToolButton;
    ToolButton2: TToolButton;
    ToolButton5: TToolButton;
    ToolButton6: TToolButton;
    tbOpenSelected: TToolButton;
    tv: TTreeView;
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure tbAlwaysOnTopClick(Sender: TObject);
    procedure tbCmpClick(Sender: TObject);
    procedure tbDelSelectedClick(Sender: TObject);
    procedure tbNewGraphClick(Sender: TObject);
    procedure tbOpenSelectedClick(Sender: TObject);
    procedure tbUpdateClick(Sender: TObject);
    procedure ToolButton5Click(Sender: TObject);
    procedure ToolButton6Click(Sender: TObject);
    procedure tvDblClick(Sender: TObject);
    procedure tvExpanding(Sender: TObject; Node: TTreeNode;
      var AllowExpansion: Boolean);
  private
    function GetAlwaysOnTop: boolean;
    procedure SetAlwaysOnTop(AValue: boolean);
    procedure InitForm;
    procedure SetImageIndex;
    function CreateMonthNode(AIID, AYear, AMonth:Integer):TTreeNode;
  public

  published
    property AlwaysOnTop:boolean read GetAlwaysOnTop write SetAlwaysOnTop;

  end;

var
  frmGraphList: TfrmGraphList = nil;

procedure ViewGraphList;

implementation

uses u_options, paramstorage, u_data, eth_tbl, u_newDBGraph, SQLDB, StrUtils,
  windows, s_tools, u_makediffs, gdata, process, u_memo, LConvEncoding;

const SavedProps = 'Left,Top,Width,Height,AlwaysOnTop';
      DefNodeText = '++++++';


procedure ViewGraphList;
begin
  if not Assigned(frmGraphList) then begin
    Application.CreateForm(TfrmGraphList,frmGraphList);
    frmGraphList.InitForm;
  end;
  frmGraphList.Show;
end;

{$R *.lfm}

{ TfrmGraphList }

procedure TfrmGraphList.FormCloseQuery(Sender: TObject; var CanClose: boolean);
begin
  CanClose:=True;
  Options.SaveComponent(SavedProps,Self);
end;

procedure TfrmGraphList.FormCreate(Sender: TObject);
begin
  Options.LoadComponent(SavedProps,Self);
  SetImageIndex;
end;

procedure TfrmGraphList.FormDestroy(Sender: TObject);
begin
  Options.SaveComponent(SavedProps,Self);
  frmGraphList:=nil;
end;

procedure TfrmGraphList.tbAlwaysOnTopClick(Sender: TObject);
begin
  AlwaysOnTop:=tbAlwaysOnTop.Down;
  SetImageIndex;
end;

procedure TfrmGraphList.tbCmpClick(Sender: TObject);
var TmpGraph:TGraphData;
    PyPath,sname,S2,S3: String;
    CPath:string;
begin
  if tv.Selected=nil then begin
    ShowMessage('graph not selected!');
    Exit;
  end;
  if tv.Selected.Level<>2 then begin
    ShowMessage('graph not selected!');
    Exit;
  end;
  //frmTable.LoadGraph(PtrInt(tv.Selected.Data));
  CPath:=Options.ScrDir;
  PyPath:=Options.PyPath;
  try
    TmpGraph:=TGraphData.Create;
    TmpGraph.LoadFromDB(PtrInt(tv.Selected.Data));
    TmpGraph.SaveData(CPath+'\m2');
  finally
    TmpGraph.Free;
  end;
  frmTable.Data.SaveData(CPath+'\m1');

  try
    sname:={CPath+}'cmpgraphs.py';
    RunCommandIndir1(CPath, PyPath, [sname], S2, S3, [poStderrToOutPut]);
  finally
    S2:='Current dir:'+GetCurrentDir+#13+
      'CPath:'+CPath+#13+
      'sname:'+sname+#13+
      S2;
    ShowMemo(cp1251toutf8(S2+S3),'Дифф графиков');
  end;

end;

procedure TfrmGraphList.tbDelSelectedClick(Sender: TObject);
var I:Integer;
    SQL:string;
begin
  //удаление графика
  //валим все вхождения в graph_data
  //сам график в graph
  ///!!!и по идее надо валить данные из таблицы суммированного учета
  ///!!!не отлажено
  if tv.Selected=nil then Exit;
  if tv.Selected.Level<>2 then Exit;
  if Application.MessageBox(PChar('Удалить график за '+tv.Selected.Text+'?'), 'ETH_GRAPH', MB_YESNO+MB_ICONWARNING)=IDNO then
     Exit;
  I:=PtrInt(tv.Selected.Data);
  SQL:='delete from graph_data where gid='+IntToStr(I);
  DM.ExecSQL(SQL);
  SQL:='delete from graph where gid = '  + IntToStr(I);
  DM.ExecSQL(SQL);
  //и валим его из древовиева
  tv.Selected.Delete;
end;

procedure TfrmGraphList.tbNewGraphClick(Sender: TObject);
var I,gid,iid:Integer;
    S,S1,S2:string;
    n,r:TTreeNode;
    b:boolean;
begin
  gid:=CreateDBGraph;
  if gid=-1 then
     Exit;

  S:='select iid from graph where gid = '+IntToStr(gid);
  S:=DM.GetQSingle(S);
  n:=nil;
  r:=tv.Items[0];
  iid:=StrToInt(S);
  //ищем родительскую ноду
  for I:=0 to r.Count-1 do begin
    if Integer(r.Items[i].Data) = iid then begin
      n:=r.Items[I];
      Break;
    end;
  end;
  if n=nil then begin
    //если создали график, а ноду не нашли, то значит, нужно создать новую
    //пихаем в конец списка //потом переделать н впихивание в нужный мест
    //идем снизу вверх по узлам месяцев и впихиваем ее в то же место, где месяц ноды
    //больше текущего
    S:='select iid from graph where gid='+IntToStr(gid);
    S2:=DM.GetQSingle(S);
    S:='select gyear || ''*'' || gmonth from graph_info where iid = ' + S2;
    S:=DM.GetQSingle(S);
    S1:=DivStr(S,'*');
    n:=CreateMonthNode(S2.ToInteger,S1.ToInteger,S.ToInteger);
  end else begin
    n.Collapse(True);
    n.DeleteChildren;
    tv.Items.AddChild(n,DefNodeText);
  end;
  //валим детей, добавляем пустой узел
  //и вызываем Expanding
  b:=False;
  tvExpanding(nil,n,b);
  ///!!! и выделяем
  for I:=0 to n.Count-1 do begin
    if Integer(n.Items[I].Data)=gid then begin
      n.Items[I].Selected:=True;
      Break;
    end;
  end;
end;

procedure TfrmGraphList.tbOpenSelectedClick(Sender: TObject);
begin
  if tv.Selected=nil then Exit;
  if tv.Selected.Level<>2 then Exit;
  frmTable.LoadGraph(PtrInt(tv.Selected.Data));
end;

procedure TfrmGraphList.tbUpdateClick(Sender: TObject);
begin
  InitForm;
end;

procedure TfrmGraphList.ToolButton5Click(Sender: TObject);
var SQL:string;
begin
  //открываем график такого же типа, как и открытый, то на месяц раньше (если он есть)
  //лезем в MainForm.Data, извлекаем там дынные графика и далее отыскиваем нужный
  //cjmpare and sort gyear*100+gmonth
  if frmTable.Data=nil then Exit;

  SQL:=' with a as '+
    '(select gyear, gmonth, tid, gyear*100+gmonth as ym from graph_info gi join graph g on gi.iid = g.iid '+
    'where gid=%d) '+
    'select gid, gi.gyear, gi.gmonth, (gi.gyear*100+gi.gmonth) as ymt '+
    'from graph g join graph_info gi on g.iid = gi.iid join a on ymt<a.ym '+
    'where  a.tid=g.tid '+
    'order by ymt desc '+
    'limit 1';
  SQL:=DM.GetQSingle(SQL.Format([frmTable.Data.GraphID]));
  if SQL<>'' then
    frmTable.LoadGraph(SQL.ToInteger)
  else
    ShowMessage('График на предыдущий месяц не обнаружен!!!');

end;

procedure TfrmGraphList.ToolButton6Click(Sender: TObject);
var SQL:string;
begin
  {возвращает график того же типа, что и переданный, но на месяц позже}
  {with a as
    (select gyear, gmonth, tid, gyear*100+gmonth as ym from graph_info gi join graph g on gi.iid = g.iid
    where gid=4)
    select gid, gi.gyear, gi.gmonth, (gi.gyear*100+gi.gmonth) as ymt
    from graph g join graph_info gi on g.iid = gi.iid join a on ymt>a.ym
    where  a.tid=g.tid
    order by ymt
    limit 1  }
  if frmTable.Data=nil then Exit;

  SQL:=' with a as '+
    '(select gyear, gmonth, tid, gyear*100+gmonth as ym from graph_info gi join graph g on gi.iid = g.iid '+
    'where gid=%d) '+
    'select gid, gi.gyear, gi.gmonth, (gi.gyear*100+gi.gmonth) as ymt '+
    'from graph g join graph_info gi on g.iid = gi.iid join a on ymt>a.ym '+
    'where  a.tid=g.tid '+
    'order by ymt '+
    'limit 1';
  SQL:=DM.GetQSingle(SQL.Format([frmTable.Data.GraphID]));
  if SQL<>'' then
    frmTable.LoadGraph(SQL.ToInteger)
  else
    ShowMessage('График на следующий месяц не обнаружен!!!');
end;


procedure TfrmGraphList.tvDblClick(Sender: TObject);
begin
  tbOpenSelected.Click;
end;

procedure TfrmGraphList.tvExpanding(Sender: TObject; Node: TTreeNode;
  var AllowExpansion: Boolean);
var DS:TSQLQuery;
    I:PtrInt;
    S:string;
    tn:TTreeNode;
begin
  tn:=Node.GetFirstChild;
  if tn=nil then Exit;
  if tn.Text<>DefNodeText then Exit;
  try
    tv.Items.BeginUpdate;
    Node.DeleteChildren;
    I:=PtrInt(Node.Data);
    DS:=DM.GetDS('select gid, t.tname, g.tname, sname, lm from graph g join sort_info s on g.sid=s.sid '+
      ' join graph_types t on g.tid = t.tid where iid='+IntToStr(I)+
      ' order by iif(t.torder==0, 1, 0) , t.torder ');
    while not DS.EOF do begin
      I:=DS.Fields[0].AsInteger;
      S:={'Тип: '+}IfThen(DS.Fields[2].AsString<>'',DS.Fields[2].AsString,DS.Fields[1].AsString);
      S:=S+{'; Персонал: '}'['+DS.Fields[3].AsString+'] Изм: '+DateTimeToStr(DM._std(DS.Fields[4].AsString));
      //S:=S+'['+IntToStr(Node.Level+1)+'][gid:'+DS.Fields[0].AsString+']';
      tv.Items.AddChildObject(Node,S,Pointer(I));
      DS.Next;
    end;
  finally
    DM.CloseDS(DS);
    tv.Items.EndUpdate;
  end;
end;

function TfrmGraphList.GetAlwaysOnTop: boolean;
begin
  Result:=FormStyle=fsStayOnTop;
end;

procedure TfrmGraphList.SetAlwaysOnTop(AValue: boolean);
begin
  if AValue then FormStyle:=fsStayOnTop else FormStyle:=fsNormal;
end;

procedure TfrmGraphList.InitForm;
var r:TTreeNode;
    DS:TSQLQuery;
    S:string;
begin
  try
    tv.Items.BeginUpdate;
    tv.Items.Clear;
    S:=Options.DBPath;
    if S='' then S:='echc.sqlite';
    r:=tv.Items.AddObject(nil,S,Pointer(0));
    DS:=DM.GetDS('select iid, gyear, gmonth from graph_info order by gyear, gmonth');
    while not DS.EOF do begin
      CreateMonthNode(DS.Fields[0].AsInteger,DS.Fields[1].AsInteger,DS.Fields[2].AsInteger);
      DS.Next;
    end;
    DM.CloseDS(DS);
    r.Expand(False);
  finally
    tv.Items.EndUpdate;
  end;
end;

procedure TfrmGraphList.SetImageIndex;
begin
  if AlwaysOnTop then tbAlwaysOnTop.ImageIndex:=7
  else tbAlwaysOnTop.ImageIndex:=8;
end;

function TfrmGraphList.CreateMonthNode(AIID, AYear, AMonth: Integer): TTreeNode;
var S:string;
begin
  S:=AYear.ToString+'-'+AMonth.ToString{+'[iid:'+AIID.ToString+']'};
  Result:=tv.Items.AddChildObject(tv.Items[0],S,Pointer(AIID));
  tv.Items.AddChildObject(Result,DefNodeText,Pointer(-1));
end;

end.

