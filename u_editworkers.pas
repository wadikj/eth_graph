unit u_editWorkers;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, Buttons;

type

  { TfrmWorkers }

  TfrmWorkers = class(TForm)
    bbNew: TBitBtn;
    bbDel: TBitBtn;
    bbClose: TBitBtn;
    bbRename: TBitBtn;
    bbToFile: TBitBtn;
    bbFromFile: TBitBtn;
    lb: TListBox;
    OpenDialog1: TOpenDialog;
    SaveDialog1: TSaveDialog;
    procedure bbDelClick(Sender: TObject);
    procedure bbFromFileClick(Sender: TObject);
    procedure bbNewClick(Sender: TObject);
    procedure bbRenameClick(Sender: TObject);
    procedure bbToFileClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
  private
    procedure LoadWorkers;
    procedure DeleteWorker;
    procedure RenameWorker;
    procedure NewWorker;
    procedure AddWorkers(SL:TStrings);
  public

  end;

var
  frmWorkers: TfrmWorkers;

procedure EditWorkersDB;

implementation

uses u_data, SQLDB;

procedure EditWorkersDB;
begin
  Application.CreateForm(TfrmWorkers,frmWorkers);
  frmWorkers.LoadWorkers;
  frmWorkers.ShowModal;
  frmWorkers:=nil;
end;

{$R *.lfm}

{ TfrmWorkers }

procedure TfrmWorkers.bbToFileClick(Sender: TObject);
begin
  if SaveDialog1.Execute then
    lb.Items.SaveToFile(SaveDialog1.FileName);
end;

procedure TfrmWorkers.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  CloseAction:=caFree;
end;

procedure TfrmWorkers.LoadWorkers;
var
  SQL: String;
begin
  //загрузка с базы
  SQL:='select wid, wname from workers order by wname';
  DM.LoadStrings(SQL,lb.Items);
end;

procedure TfrmWorkers.DeleteWorker;
var I:PtrInt;
    SQL:string;
begin
  if lb.ItemIndex=-1 then Exit;
  I:=PtrInt(lb.Items.Objects[lb.ItemIndex]);
  SQL:='delete from workers where wid='+IntToStr(I);
  DM.ExecSQL(SQL);
  lb.Items.Delete(lb.ItemIndex);
end;

procedure TfrmWorkers.RenameWorker;
var I:PtrInt;
    SQL,S:string;
begin
  if lb.ItemIndex=-1 then Exit;
  I:=PtrInt(lb.Items.Objects[lb.ItemIndex]);
  S:=lb.Items[lb.ItemIndex];
  if not InputQuery('ETH Graph', 'Rename Worker', S) then Exit;
  SQL:='update workers set wname=''%s'' where wid=%d'.Format([S,I]);
  DM.ExecSQL(SQL);
  try
    lb.Items.BeginUpdate;
    lb.Sorted:=False;
    lb.Items[lb.ItemIndex]:=S;
    lb.Sorted:=True;
  finally
    lb.Items.EndUpdate;
  end;
end;

procedure TfrmWorkers.NewWorker;
var S,S1,SQL:string;
  I:PtrInt;
begin
  S:='';
  if not InputQuery('ETH Graph', 'Введите имя нового работника',S) then Exit;
  SQL:='insert into workers(wname) values(''%s'')';
  DM.ExecSQL(SQL.Format([S]));
  S1:=DM.GetQSingle('select max(wid) from workers');
  if S1='' then begin
    ShowMessage('Error creating worker!!!');
    Exit;
  end;
  I:=StrToInt(S1);
  lb.Items.AddObject(S,TObject(I));
end;

procedure TfrmWorkers.AddWorkers(SL: TStrings);
var DS:TSQLQuery;
    S:string;
begin
  DS:=DM.GetDS('',False);
  DS.SQL.Text:='insert into workers(wname) values(?)';
  DS.Prepare;
  for S in SL do begin
    DS.Params[0].AsString:=S;
    DS.ExecSQL;
  end;
  (DS.Transaction as TSQLTransaction).Commit;
  DM.CloseDS(DS);
  try
    lb.Items.BeginUpdate;
    LoadWorkers;
  finally
    lb.Items.EndUpdate;
  end;
end;

procedure TfrmWorkers.bbFromFileClick(Sender: TObject);
var SL:TStringList;
begin
  if OpenDialog1.Execute then begin
    SL:=TStringList.Create;
    SL.LoadFromFile(OpenDialog1.FileName);
    AddWorkers(SL);
    SL.Free;
  end;
end;

procedure TfrmWorkers.bbDelClick(Sender: TObject);
begin
  DeleteWorker;
end;

procedure TfrmWorkers.bbNewClick(Sender: TObject);
begin
  NewWorker;
end;

procedure TfrmWorkers.bbRenameClick(Sender: TObject);
begin
  RenameWorker;
end;

end.

