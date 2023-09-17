unit u_edWlists;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, Buttons,
  ExtCtrls, ComCtrls;

type

  { TfrmEdWList }

  TfrmEdWList = class(TForm)
    bbAddList: TBitBtn;
    bbDelList: TBitBtn;
    bbRenList: TBitBtn;
    bbUp: TBitBtn;
    bbDown: TBitBtn;
    bbAdd: TBitBtn;
    bbSave: TBitBtn;
    bbClose: TBitBtn;
    Bevel1: TBevel;
    ddDel: TBitBtn;
    cbList: TComboBox;
    bbAddAll: TBitBtn;
    bbDelAll: TBitBtn;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    lvList: TListView;
    lbOther: TListBox;
    procedure bbAddAllClick(Sender: TObject);
    procedure bbAddClick(Sender: TObject);
    procedure bbAddListClick(Sender: TObject);
    procedure bbDelAllClick(Sender: TObject);
    procedure bbDelListClick(Sender: TObject);
    procedure bbDownClick(Sender: TObject);
    procedure bbRenListClick(Sender: TObject);
    procedure bbSaveClick(Sender: TObject);
    procedure bbUpClick(Sender: TObject);
    procedure cbListSelect(Sender: TObject);
    procedure ddDelClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
  private
    FActiveListID:Integer;//ид активного списка работников
    procedure FillWList;//заполняет комбо со списками
    procedure FillListBoxes;//заполняет списки с учетом того, кто уже находится в левом списке
    procedure AddList;//добавляет список
    procedure DelList;//удаляет список
    procedure SaveWorkers;//на кнобку bbSave
    function GetCBIDIndex(AID:PtrInt):Integer;//возвращает индекс, по которому находится элемент с заданным ИД
    procedure RenameList;//переименовывает тек список
  public

  end;

var
  frmEdWList: TfrmEdWList;

procedure EditWorkersLists;

implementation

uses u_data, SQLDB, s_tools, math;

procedure EditWorkersLists;
begin
  Application.CreateForm(TfrmEdWList,frmEdWList);
  frmEdWList.FActiveListID:=-1;
  frmEdWList.FillWList;
  frmEdWList.ShowModal;
end;

{$R *.lfm}

{ TfrmEdWList }

procedure TfrmEdWList.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  CloseAction:=caFree;
end;

procedure TfrmEdWList.cbListSelect(Sender: TObject);
begin
  //интересно, он только если пользователь выбрал или и программно автоматом вызывается
  FActiveListID:=PtrInt(cbList.Items.Objects[cbList.ItemIndex]);
  FillListBoxes;
end;

procedure TfrmEdWList.ddDelClick(Sender: TObject);
var I:Integer;
begin
  I:=lvList.ItemIndex;
  if I<0 then Exit;
  lbOther.AddItem(lvList.Items[I].Caption, TObject(lvList.Items[I].Data));
  lvList.Items.Delete(I);
end;

procedure TfrmEdWList.bbAddListClick(Sender: TObject);
begin
  AddList;
end;

procedure TfrmEdWList.bbDelAllClick(Sender: TObject);
var I:Integer;
begin
  for I:=0 to lvList.Items.Count-1 do
    lbOther.AddItem(lvList.Items[I].Caption,TObject(lvList.Items[I].Data));
  lvList.Clear;
end;

procedure TfrmEdWList.bbDelListClick(Sender: TObject);
begin
  DelList;
end;

procedure TfrmEdWList.bbDownClick(Sender: TObject);
var I:Integer;
begin
  I:=lvList.ItemIndex;
  if (I<0) or (I>lvList.Items.Count-2) then Exit;
  lvList.Items.Move(I,I+1);
  lvList.ItemIndex:=I+1;
end;

procedure TfrmEdWList.bbRenListClick(Sender: TObject);
begin
  RenameList;
end;

procedure TfrmEdWList.bbSaveClick(Sender: TObject);
begin
  SaveWorkers;
end;

procedure TfrmEdWList.bbUpClick(Sender: TObject);
var I:Integer;
begin
  I:=lvList.ItemIndex;
  if I<1 then Exit;
  lvList.Items.Move(I,I-1);
  lvList.ItemIndex:=I-1;
end;

procedure TfrmEdWList.bbAddClick(Sender: TObject);
var I:Integer;
begin
  I:=lbOther.ItemIndex;
  if I<0 then Exit;
  lvList.AddItem(lbOther.Items[I], lbOther.Items.Objects[I]);
  lbOther.Items.Delete(I);
end;

procedure TfrmEdWList.bbAddAllClick(Sender: TObject);
var li:TListItem;
    I:Integer;
begin
  for I:=0 to lbOther.Count-1 do begin
    li:=lvList.Items.Add;
    li.Caption:=lbOther.Items[I];
    li.Data:=Pointer(lbOther.Items.Objects[I]);
  end;
  //lvList.Items.AddStrings(lbOther.Items);
  lbOther.Clear;
end;

procedure TfrmEdWList.FillWList;
var
  SQL: String;
  I: Integer;
begin
  SQL:='select sid, sname from sort_info order by sid desc';
  cbList.Items.Clear;
  DM.LoadStrings(SQL,cbList.Items);
  if FActiveListID=-1 then begin
    if cbList.Items.Count>0 then begin
      cbList.ItemIndex:=0;
      FActiveListID:=PtrInt(cbList.Items.Objects[0]);
    end;
  end else begin
    I:=GetCBIDIndex(FActiveListID);
    if I<>-1 then cbList.ItemIndex:=I
    else begin
      if cbList.Items.Count>0 then cbList.ItemIndex:=0;
    end;
  end;
  FillListBoxes;
end;

procedure TfrmEdWList.FillListBoxes;
var I,J:Integer;
    SQL: String;
    DS:TSQLQuery;
    li:TListItem;
begin
  try
    lbOther.Items.BeginUpdate;
    lvList.Items.BeginUpdate;

    lvList.Clear;
    lbOther.Clear;
    if FActiveListID = -1 then Exit;

    SQL:='select workers.wid, wname, prt from sort_order join workers on workers.wid=sort_order.wid '+
      'where sort_order.sid=%d order by oindex asc'.Format([FActiveListID]);
    //DM.LoadStrings(SQL,lvList.Items);
    DS:=DM.GetDS(SQL);
    while not DS.EOF do begin
      li:=lvList.Items.Add;
      li.Caption:=DS.Fields[1].AsString;
      li.Data:=Pointer(DS.Fields[0].AsInteger);
      li.Checked:=DS.Fields[2].AsInteger=1;
      DS.Next;
    end;
    DM.CloseDS(DS);
    SQL:='select wid, wname from workers';
    DM.LoadStrings(SQL,lbOther.Items);

    for I:=0 to lvList.Items.Count-1 do begin
      J:=lbOther.Items.IndexOfObject(TObject(lvList.Items[I].Data));
      if J<>-1 then
        lbOther.Items.Delete(J);
    end;
  finally
    lbOther.Items.EndUpdate;
    lvList.Items.EndUpdate;
  end;
end;

procedure TfrmEdWList.AddList;
var S,S1:string;
    I:PtrInt;
begin
  //добавляем имя списка, кидаем в базу и сразу делаем его активным
  S:='';
  if not InputQuery('ETH Graph', 'Введите имя нового списка работников', S) then Exit;
  S1:='insert into sort_info(sname) values(''%s'')'.Format([S]);
  //ShowMessage(S1);
  DM.ExecSQL(S1);
  I:=StrToInt(DM.GetQSingle('select max(sid) from sort_info'));
  FActiveListID:=I;
  I:=cbList.Items.AddObject(S,TObject(I));
  cbList.ItemIndex:=I;
  FillListBoxes;
end;

procedure TfrmEdWList.DelList;
var
  I: Integer;
begin
  if cbList.Items.Count=0 then Exit;
  if FActiveListID=0 then Exit;
  DM.ExecSQL('delete from sort_info where sid=%d'.Format([FActiveListID]));
  I:=GetCBIDIndex(FActiveListID);
  cbList.Items.Delete(I);
  FActiveListID:=-1;
  if cbList.Items.Count>0 then begin
    cbList.ItemIndex:=0;
    FActiveListID:=PtrInt(cbList.Items.Objects[0]);
  end;
  FillListBoxes;
end;

procedure TfrmEdWList.SaveWorkers;
var S,S1:string;
    I,J:Integer;
    SL:TStringList;
    DS:TSQLQuery;
begin
  //сохраняет отредактированный список работников
  //можно просто пройтись - можно, сначала удаляем из базы тех, которые в остатках
  //потом проходимся по рабочему и добавляем или изменяем тех, которые там есть
  //валим лишнее
  S:='-1';
  for I:=0 to lbOther.Count-1 do begin
    S:=StrListAdd(S,IntToStr(PtrInt(lbOther.Items.Objects[I])));
  end;
  S1:='delete from sort_order where sid=%d and wid in (%s)'.Format([FActiveListID,S]);
  //ShowMessage(S1);
  DM.ExecSQL(S1);

  //получаем список того, что есть в базе
  SL:=TStringList.Create;
  DM.LoadStrings('select wid, oindex from sort_order where sid='+IntToStr(FActiveListID), SL);

  DS:=DM.GetDS('',False);
  //обновляем то, что там есть
  DS.SQL.Text:='update sort_order set oindex=:p0, prt=:p1 where sid = :p2 and wid = :p3';
  DS.Prepare;
  DS.Params[2].AsInteger:=FActiveListID;
  for I:=0 to lvList.Items.Count-1 do begin
    J:=SL.IndexOfObject(TObject(lvList.Items[I].Data));
    if J=-1 then Continue;//нет в БД, потом обработаем
    DS.Params[0].AsInteger:=I;
    DS.Params[3].AsInteger:=LongInt(lvList.Items[I].Data);
    DS.Params[1].AsInteger:=IfThen(lvList.Items[I].Checked,1,0);
    {if DS.Params[1].AsInteger=1 then
      ShowMessage(lvList.Items[I].Caption + ' checked!');}
    DS.ExecSQL;
  end;

  //дописываем в базу то, чего там нет
  DS.SQL.Text:='insert into sort_order(sid, wid, oindex, prt) values(:p0, :p1, :p2, :p3)';
  DS.Prepare;
  DS.Params[0].AsInteger:=FActiveListID;
  for I:=0 to lvList.Items.Count-1 do begin
    if SL.IndexOfObject(TObject(lvList.Items[I].Data))<>-1 then Continue;//есть в БД, смотрим следующий
    DS.Params[1].AsInteger:=PtrInt(lvList.Items[I].Data);
    DS.Params[2].AsInteger:=I;
    DS.Params[3].AsInteger:=IfThen(lvList.Items[I].Checked,1,0);;
    DS.ExecSQL;
  end;
  SL.Free;
  TSQLTransaction(DS.Transaction).Commit;
end;

function TfrmEdWList.GetCBIDIndex(AID: PtrInt): Integer;
begin
  Result:=cbList.Items.IndexOfObject(TObject(AID));
end;

procedure TfrmEdWList.RenameList;
var
  S: String;
begin
  S:=cbList.Items[cbList.ItemIndex];
  if not InputQuery('ETH Graph', 'Введите новое имя списка работников', S) then Exit;
  DM.ExecSQL('update sort_info set sname = ''%s'' where sid = %d'.Format([S, FActiveListID]));
  cbList.Items[cbList.ItemIndex]:=S;
end;

end.

