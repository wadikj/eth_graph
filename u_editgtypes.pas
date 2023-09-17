unit u_editgtypes;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ComCtrls,
  Buttons;

type

  { TAdvListItem }

  TAdvListItem = class(TListItem)
    private
      FTID:Integer;//тип графика
      FOrder:Integer;//порядок
      //назание хранится в Caption
      function GetUseCalc:boolean;
  end;

  TAdvLIClass = class of TAdvListItem;

  { TfrmGtypes }

  TfrmGtypes = class(TForm)
    bbDown: TBitBtn;
    bbClose: TBitBtn;
    btNew: TButton;
    btDel: TButton;
    btRename: TButton;
    btSetOrdered: TButton;
    bbUp: TBitBtn;
    lv: TListView;
    procedure bbDownClick(Sender: TObject);
    procedure bbUpClick(Sender: TObject);
    procedure btDelClick(Sender: TObject);
    procedure btNewClick(Sender: TObject);
    procedure btRenameClick(Sender: TObject);
    procedure btSetOrderedClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure lvCompare(Sender: TObject; Item1, Item2: TListItem;
      Data: Integer; var Compare: Integer);
    procedure lvCreateItemClass(Sender: TCustomListView;
      var ItemClass: TListItemClass);
    procedure lvSelectItem(Sender: TObject; Item: TListItem; Selected: Boolean);
  private
    FModified:Boolean;
    FSelGID:Integer;
    FSelMode:Boolean;
    procedure InitForm;
    function GetActiveItem:TAdvListItem;//*
    procedure LoadItems;//*
    procedure SaveItem(AItem:TAdvListItem);
    procedure NewItem;
    procedure DelItem;
    procedure RenameItem;
    procedure SetOrdered;
    procedure UpItem;
    procedure DownItem;
  public

  end;


var
  frmGtypes: TfrmGtypes;

function EditGTypes(ASelect:boolean; out Selected:Integer):boolean;

implementation

uses Math, SQLDB, u_data, StrUtils;

{
все операции выполняются по моменту (сразу все кладем в БД)
необязательные типы не могут быть выше обязатльных
для необязательных типов порядок не важен, их перемещать и нельзя (скрытно сортируются по tid)
если тип становится обязательным, то мы его пихаем с последним доступным номером


}

const DefUnOrdered=0;

function EditGTypes(ASelect: boolean; out Selected: Integer): boolean;
begin
  Application.CreateForm(TfrmGtypes,frmGtypes);
  if ASelect then
    frmGtypes.bbClose.Caption:='Выбрать';
  frmGtypes.FSelMode:=ASelect;
  frmGtypes.InitForm;
  frmGtypes.ShowModal;
  Result:=frmGtypes.FModified;
  Selected:=frmGtypes.FSelGID;
  FreeAndNil(frmGtypes);
end;

{$R *.lfm}

{ TAdvListItem }

function TAdvListItem.GetUseCalc: boolean;
begin
  Result:=FOrder>DefUnOrdered;
end;

{ TfrmGtypes }

procedure TfrmGtypes.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  CloseAction:=caHide;
end;

procedure TfrmGtypes.btNewClick(Sender: TObject);
begin
  NewItem;
end;

procedure TfrmGtypes.btRenameClick(Sender: TObject);
begin
  RenameItem;
end;

procedure TfrmGtypes.btSetOrderedClick(Sender: TObject);
begin
  SetOrdered;
end;

procedure TfrmGtypes.btDelClick(Sender: TObject);
begin
  DelItem;
end;

procedure TfrmGtypes.bbUpClick(Sender: TObject);
begin
  UpItem;
end;

procedure TfrmGtypes.bbDownClick(Sender: TObject);
begin
  DownItem;
end;

procedure TfrmGtypes.lvCompare(Sender: TObject; Item1, Item2: TListItem;
  Data: Integer; var Compare: Integer);

  function cf(ai:TAdvListItem):Integer;
  begin
    if ai.GetUseCalc then
      Result:=ai.FOrder
    else
      Result:=ai.FTID+100000;
  end;

var AI1,AI2:TAdvListItem;
    I1,I2:Integer;
begin
  AI1:=TAdvListItem(Item1);
  AI2:=TAdvListItem(Item2);
  I1:=cf(AI1);
  I2:=cf(AI2);
  Compare:=I1-I2;
end;

procedure TfrmGtypes.lvCreateItemClass(Sender: TCustomListView;
  var ItemClass: TListItemClass);
begin
  ItemClass:=TAdvListItem;
end;

procedure TfrmGtypes.lvSelectItem(Sender: TObject; Item: TListItem;
  Selected: Boolean);
var ai:TAdvListItem;
begin
  if not Selected then Exit;
  ai:=GetActiveItem;
  if ai=nil then Exit;
  bbUp.Enabled:=(ai.Index<>0) and ai.GetUseCalc;
  bbDown.Enabled:=(ai.Index<lv.Items.Count-1) and ai.GetUseCalc and
    TAdvListItem(lv.Items[ai.Index+1]).GetUseCalc;
  btSetOrdered.Caption:=IfThen(ai.GetUseCalc,'Не расчитывать', 'Рассчитывать');
  FSelGID:=ai.FTID;
end;

procedure TfrmGtypes.InitForm;
begin
  FModified:=False;
  FSelGID:=-1;
  LoadItems;
  if lv.Items.Count>0 then
    lv.Items[0].Selected:=True;
  lvSelectItem(Self,lv.Items[0],True);
end;

function TfrmGtypes.GetActiveItem: TAdvListItem;
begin
  Result:=nil;
  if lv.Selected=nil then Exit;
  Result:=TAdvListItem(lv.Selected);
end;

procedure TfrmGtypes.LoadItems;
var
  SQL: String;
  qu:TSQLQuery;
  ai:TAdvListItem;
begin
  SQL:='select tid, tname, torder from graph_types';
  try
    qu:=DM.GetDS(SQL);
    lv.Items.BeginUpdate;
    while not qu.EOF do begin
      ai:=TAdvListItem(lv.Items.Add);
      ai.Caption:=qu.Fields[1].AsString;
      ai.FTID:=qu.Fields[0].AsInteger;
      ai.FOrder:=qu.Fields[2].AsInteger;
      ai.SubItems.Add(IfThen(ai.GetUseCalc,IntToStr(ai.FOrder),'-'));
      ai.SubItems.Add(IfThen(ai.GetUseCalc,'Да','Нет'));
      qu.Next;
    end;
  finally
    lv.Items.EndUpdate;
    DM.CloseDS(qu);
  end;
  lv.Sort;
end;

procedure TfrmGtypes.SaveItem(AItem: TAdvListItem);
var SQL:string;
begin
  //сохраняем переданный итем
  SQL:='update graph_types set tname = ''%s'', torder = %d where tid = %d';
  DM.ExecSQL(SQL.Format([AItem.Caption,AItem.FOrder,AItem.FTID]));
  FModified:=True;
end;

procedure TfrmGtypes.NewItem;
var
  S: string;
  ai:TAdvListItem;
begin
  S:='';
  if not InputQuery('ETH Graph','Введите название нового типа графика', S) then Exit;
  try
    lv.Items.BeginUpdate;
    ai:=TAdvListItem(lv.Items.Add);
    ai.Caption:=S;
    ai.FOrder:=DefUnOrdered;
    ai.SubItems.Add('-');
    ai.SubItems.Add('Нет');
    S:='insert into graph_types(tname, torder) values (''%s'', %d)';
    S:=S.Format([ai.Caption, ai.FTID]);
    //ShowMessage(S);
    DM.ExecSQL(S);
    S:=DM.GetQSingle('select max(tid) from graph_types');
    if S<>'' then
      ai.FTID:=StrToInt(S);
  finally
    lv.Items.EndUpdate;
  end;
  FModified:=True;
end;

procedure TfrmGtypes.DelItem;
var SQL:string;
    ai:TAdvListItem;
    I:Integer;
begin
  ai:=GetActiveItem;
  if ai = nil then Exit;
  SQL:='delete from graph_types where tid = %d';
  try
    DM.ExecSQL(SQL.Format([ai.FTID]));
    I:=ai.Index;
    lv.Items.Delete(ai.Index);
    if I>=lv.Items.Count then Dec(I);
    if I>=0 then
      lv.Items[I].Selected:=True;
  except
    ShowMessage('Ошибка удаления типа графика - имеются связанные данные');
  end;
  FModified:=True;
end;

procedure TfrmGtypes.RenameItem;
var
  S: String;
  ai:TAdvListItem;
begin
  S:='';
  ai:=GetActiveItem;
  if ai=nil then Exit;
  if not InputQuery('ETH Graph','Введите новое имя типа графика', S) then Exit;
  ai.Caption:=S;
  SaveItem(ai);
end;


procedure TfrmGtypes.SetOrdered;
  function MaxOrder:Integer;
  var I:Integer;
  begin
    Result:=0;
    for I:=0 to lv.Items.Count-1 do begin
      Result:=Max(Result, TAdvListItem(lv.Items[I]).FOrder);
      if TAdvListItem(lv.Items[I]).FOrder<1 then Break
    end;
    Inc(Result);
  end;
var ai:TAdvListItem;
begin
  ai:=GetActiveItem;
  if ai=nil then Exit;
  if ai.FOrder = DefUnOrdered then begin
    ai.FOrder:=MaxOrder;
  end else begin
    ai.FOrder:=DefUnOrdered;
  end;
  try
    lv.Items.BeginUpdate;
    ai.SubItems[0]:=IfThen(ai.GetUseCalc,IntToStr(ai.FOrder),'-');
    ai.SubItems[1]:=IfThen(ai.GetUseCalc,'Да','Нет');
  finally
    lv.Items.EndUpdate;
  end;
  lv.Sort;
  SaveItem(ai);
  lvSelectItem(Self,ai,True);
end;

procedure TfrmGtypes.UpItem;
var ai,ai2:TAdvListItem;
begin
  ai:=GetActiveItem;
  ai2:=TAdvListItem(lv.Items[ai.Index-1]);
  try
    lv.Items.BeginUpdate;
    ai.FOrder:=ai.FOrder-1;
    ai.SubItems[0]:=IntToStr(ai.FOrder);
    ai2.FOrder:=ai2.FOrder+1;
    ai2.SubItems[0]:=IntToStr(ai2.FOrder);
  finally
    lv.Items.EndUpdate;
  end;
  SaveItem(ai);
  SaveItem(ai2);
  lv.Sort;
  lvSelectItem(Self,ai,True);
end;

procedure TfrmGtypes.DownItem;
var ai,ai2:TAdvListItem;
begin
  ai:=GetActiveItem;
  ai2:=TAdvListItem(lv.Items[ai.Index+1]);
  try
    lv.Items.BeginUpdate;
    ai.FOrder:=ai.FOrder+1;
    ai.SubItems[0]:=IntToStr(ai.FOrder);
    ai2.FOrder:=ai2.FOrder-1;
    ai2.SubItems[0]:=IntToStr(ai2.FOrder);
  finally
    lv.Items.EndUpdate;
  end;
  SaveItem(ai);
  SaveItem(ai2);
  lv.Sort;
  lvSelectItem(Self,ai,True);
end;

end.

