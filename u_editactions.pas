unit u_editActions;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls, LCLProc, u_options;

type

  { TfrmEditActions }

  TfrmEditActions = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    Button5: TButton;
    cbUse: TCheckBox;
    cbView: TCheckBox;
    gbActions: TGroupBox;
    Label1: TLabel;
    leName: TLabeledEdit;
    leKey: TLabeledEdit;
    leAction: TLabeledEdit;
    lb: TListBox;
    mmHelp: TMemo;
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure cbUseChange(Sender: TObject);
    procedure lbSelectionChange(Sender: TObject; User: boolean);
  private
    procedure InitList;
    procedure SelectItem;
    procedure StoreItem;
    procedure DeleteItem;
    procedure NewItem;
  public

  end;

var
  frmEditActions: TfrmEditActions;


function EditActions:boolean;//если да, то переделываем менюху

implementation

function EditActions: boolean;
begin
  Result:=True;
  Application.CreateForm(TfrmEditActions,frmEditActions);
  frmEditActions.Button2.Click;
  frmEditActions.InitList;
  if frmEditActions.lb.Count<>0 then
    frmEditActions.lb.ItemIndex:=0;
  frmEditActions.ShowModal;
end;

{$R *.lfm}

{ TfrmEditActions }

procedure TfrmEditActions.Button3Click(Sender: TObject);
begin
  StoreItem;
end;

procedure TfrmEditActions.Button2Click(Sender: TObject);
var BasePT:Integer;
begin
  BasePT:=gbActions.Left+gbActions.Width+5;
  if ClientWidth>BasePT then ClientWidth:=BasePT
  else begin
    ClientWidth:=BasePT+582;
    mmHelp.Width:=568;
  end;
end;

procedure TfrmEditActions.Button4Click(Sender: TObject);
begin
  NewItem;
end;

procedure TfrmEditActions.Button5Click(Sender: TObject);
begin
  DeleteItem;
end;

procedure TfrmEditActions.cbUseChange(Sender: TObject);
begin
  if not cbUse.Checked then begin
    cbView.Checked:=False;
    cbView.Enabled:=False;
  end else begin
    cbView.Checked:=True;
    cbView.Enabled:=True;
  end;
end;

procedure TfrmEditActions.lbSelectionChange(Sender: TObject; User: boolean);
begin
  SelectItem;
end;

procedure TfrmEditActions.InitList;
var I:Integer;
begin
  lb.Items.BeginUpdate;
  try
    lb.Items.Clear;
    for I:=0 to High(Options.FActions) do
      lb.Items.Add(Options.FActions[I].Caption);
  finally
    lb.Items.EndUpdate;
  end;
end;

procedure TfrmEditActions.SelectItem;
var I:Integer;
begin
  I:=lb.ItemIndex;
  if I=-1 then Exit;
  leName.Text:=Options.FActions[I].Caption;
  leKey.Text:=ShortCutToText(Options.FActions[I].HotKey);
  leAction.Text:=Options.FActions[I].Acion;
  cbUse.Checked:=Options.FActions[I].Use;
  cbView.Checked:=Options.FActions[I].ShowQInput;
end;

procedure TfrmEditActions.StoreItem;
var I:Integer;
begin
  I:=lb.ItemIndex;
  if I=-1 then Exit;
  Options.FActions[I].Caption:=leName.Text;
  Options.FActions[I].HotKey:=TextToShortCut(leKey.Text);
  Options.FActions[I].Acion:=leAction.Text;
  Options.FActions[I].Use:=cbUse.Checked;
  Options.FActions[I].ShowQInput:=cbView.Checked;
  InitList;
end;

procedure TfrmEditActions.DeleteItem;
var
  I: Integer;
begin
  I:=lb.ItemIndex;
  if I=-1 then Exit;
  Delete(Options.FActions,I,1);
  InitList;
end;

procedure TfrmEditActions.NewItem;
begin
  SetLength(Options.FActions,Length(Options.FActions)+1);
  Options.FActions[High(Options.FActions)].Caption:='<новый>';
  Options.FActions[High(Options.FActions)].HotKey:=0;
  Options.FActions[High(Options.FActions)].Acion:='';
  Options.FActions[High(Options.FActions)].Use:=True;
  Options.FActions[High(Options.FActions)].ShowQInput:=True;
  InitList;
  lb.ItemIndex:=lb.Items.Count-1;
end;

{
lclprocs

TextToShortCut

для того, чтобы пользователь мог задаать вввод каких то элементов, он создает
шаблоны действия и привязывает их к горячим клавишам
шаблон вышлядит так
буква(тип действия){:последовательность элеметнов, которые вводятся в ячейки сетки}
c:без параметров - копирует в буфер первую строку выделенного диапазона
p:без параметров - вставляет из буфера строку элементов. вставка начинается с первой выделенной ячейки
  и выполняется для всех строк выделенного блока
i:параметры - вставляет параметры в выделенное
r:вставляет параметры в выделенное до окончания сетки. из выделения используется только номер первой колонки
m:lsdk  - выводит сообщение
f:параметры - заполняет выбранную область параметром.

параметры выглядят - см формат сохранения графика набор ячеек, разделенных "|"
в ячейке находится текст клеточки и флаг, разделенные "!"
если текст клеточки равен ?, то значение запрашивается в диалоговом окне (один раз за исполнение)
если текст клеточки равен $, то берется значение из редактора внизу формы
если тип клеточки равен $, то берется значение из комбы внизу формы
тип клеточки не может быть ?


мы можем заполнять сетку следующими образами
1. просто вставить в ячейку значение(последовательность) i - нужна только первая ячейка
2. заполнить последовательностью выделенное              f - начало и конец выделения
  f и i одно и то же, только выполняется в зависимости от наличия выделения


3. заполнить последовательностью до конца сетки          l(L) - первая ячейка
4. повторить последовательность N раз                    r:N:последов - первая ячейка, N можно запросить
  l и r тоже можно свести к одному и тому же, если N=0, то заполняем до конца
  если у нас есть выделение, то заполняем отлько выделение

5. вставить из буфера                                    p - первая и последняя (если первая = последняя,
          то вставляем все, иначе только то, что влезет

если выделено более 1 дня, то все операции работают только над выделенным куском
тогда
f:N: последовательноть - заполняем последовательностью от начала до конца (N=0) или указанное число раз
и в общем то все


сами действия хранятся в настройках, и оттуда берутся для выполнения или для редактирования

выполнение реализовано в форме с сеткой
}


end.

