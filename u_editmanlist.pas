unit u_editManList;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls;

type

  { TfrmEditManList }

  TfrmEditManList = class(TForm)
    btSave: TButton;
    btLoad: TButton;
    Button5: TButton;
    Button6: TButton;
    Button7: TButton;
    btSet: TButton;
    Memo1: TMemo;
    OpenDialog1: TOpenDialog;
    SaveDialog1: TSaveDialog;
    procedure btLoadClick(Sender: TObject);
    procedure btSaveClick(Sender: TObject);
    procedure btSetClick(Sender: TObject);
    procedure Button7Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    function GetManList: TStrings;
    procedure SetManList(AValue: TStrings);

  public
    property ManList:TStrings read GetManList write SetManList;

  end;

var
  frmEditManList: TfrmEditManList;

procedure EditWorkers;

implementation

uses eth_tbl, u_options, Math;

const PropList = 'Left,Top,Width,Height';

procedure EditWorkers;
begin
  Application.CreateForm(TfrmEditManList,frmEditManList);
  frmEditManList.ManList:=Options.FWorkerList;
  if frmEditManList.ShowModal=mrOK then
    Options.FWorkerList.Assign(frmEditManList.ManList);
  FreeAndNil(frmEditManList);
end;

{$R *.lfm}

{ TfrmEditManList }

procedure TfrmEditManList.SetManList(AValue: TStrings);
begin
  Memo1.Lines.Assign(AValue);
end;

procedure TfrmEditManList.Button7Click(Sender: TObject);
begin
  Memo1.Lines.Clear;
  frmTable.GraphData.GetManList(Memo1.Lines);
end;

procedure TfrmEditManList.FormCreate(Sender: TObject);
begin
  Options.LoadComponent(PropList,Self);
end;

procedure TfrmEditManList.FormDestroy(Sender: TObject);
begin
  Options.SaveComponent(PropList,Self);
end;

procedure TfrmEditManList.btSetClick(Sender: TObject);
var I,J:Integer;
begin
  //задаем текущему графику новый список людей
  //при задании, если у нас длины нового и старого списка отличаются
  //сообщаем, что лишние люди будут обрезаны, да;
  I:=Memo1.Lines.Count;
  if frmTable.GraphData.WorkerCount<>Memo1.Lines.Count then begin
    case  MessageDlg('Запрос','Количество работников в графике отличается от количества работников в этом списке. Изменить количество работников в графике?',
      mtWarning,mbYesNoCancel,'') of
      mrYes:frmTable.GraphData.WorkerCount:=I;
      mrNo:I:=Min(I,frmTable.GraphData.WorkerCount);
      mrCancel:Exit;
    end;
  end;
  for J:=0 to I-1 do
    frmTable.GraphData.Workers[J]:=Memo1.Lines[J];
  if frmTable.GraphData.WorkerCount>Memo1.Lines.Count then
    for J:=I to frmTable.GraphData.WorkerCount-1 do
      frmTable.GraphData.Workers[J]:='';
  //обновить и сетку
  frmTable.UpdateData;
end;

procedure TfrmEditManList.btSaveClick(Sender: TObject);
begin
  if SaveDialog1.Execute then
    Memo1.Lines.SaveToFile(SaveDialog1.FileName);
end;

procedure TfrmEditManList.btLoadClick(Sender: TObject);
begin
  if OpenDialog1.Execute then
      Memo1.Lines.LoadFromFile(OpenDialog1.FileName);
end;

function TfrmEditManList.GetManList: TStrings;
begin
  Result:=Memo1.Lines;
end;

end.

