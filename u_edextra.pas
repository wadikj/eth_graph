unit u_edextra;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls,
  CheckLst, u_options;

type

  { TfrmEditExtra }

  TfrmEditExtra = class(TForm)
    btAdd: TButton;
    btDel: TButton;
    btSetHours: TButton;
    btDel2: TButton;
    btUp: TButton;
    btDown: TButton;
    Button5: TButton;
    cbUseCount: TCheckBox;
    clbUsedTypes: TCheckListBox;
    Label1: TLabel;
    Label2: TLabel;
    leFullName: TLabeledEdit;
    leShortName: TLabeledEdit;
    lbItems: TListBox;
    procedure btAddClick(Sender: TObject);
    procedure btSetHoursClick(Sender: TObject);
    procedure btDel2Click(Sender: TObject);
    procedure btDelClick(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure lbItemsSelectionChange(Sender: TObject; User: boolean);
  private
    FExtra:TExtraCollection;
    FExtraItem:TExtraItem;
    procedure InitForm;
    procedure FillDayTypes;
    procedure SelectLine;
    procedure AddItem;
    procedure SaveItem;
    procedure DeleteItem;
  public

  end;

var
  frmEditExtra: TfrmEditExtra;

procedure EditExtra(ACols:boolean);

implementation

uses StrUtils;

procedure EditExtra(ACols: boolean);
begin
  Application.CreateForm(TfrmEditExtra,frmEditExtra);
  with frmEditExtra do
    if ACols then  begin
      Label1.Caption:='Доп. колонки';
      Caption:='Дополнительные колонки';
      FExtra:=Options.gExtraCols;
    end else begin
      FExtra:=Options.gExtraRows;
    end;
  frmEditExtra.InitForm;
  frmEditExtra.ShowModal;
end;

{$R *.lfm}

{ TfrmEditExtra }

procedure TfrmEditExtra.FormClose(Sender: TObject; var CloseAction: TCloseAction
  );
begin
  CloseAction:=caFree;
end;

procedure TfrmEditExtra.btAddClick(Sender: TObject);
begin
  AddItem;
end;

procedure TfrmEditExtra.btSetHoursClick(Sender: TObject);
var I,J:integer;
    S:string;
    dt:TDayType;
begin
  I:=PtrInt(clbUsedTypes.Items.Objects[clbUsedTypes.ItemIndex]);
  dt:=TDayType(clbUsedTypes.ItemIndex);
  S:=IntToStr(I);
  if I=0 then S:='';
  S:=InputBox('Hours','Hours',S);
  if S='' then J:=0
  else J:=StrToInt(S);
  if I<>J then begin
    clbUsedTypes.Items.Objects[clbUsedTypes.ItemIndex]:=TObject(PtrInt(J));
    clbUsedTypes.Items[clbUsedTypes.ItemIndex]:=TypeText[dt]+
      IfThen(J<>0,'('+IntToStr(J)+')','');
  end;
end;

procedure TfrmEditExtra.btDel2Click(Sender: TObject);
begin
  SaveItem;
end;

procedure TfrmEditExtra.btDelClick(Sender: TObject);
begin
  DeleteItem;
end;

procedure TfrmEditExtra.Button5Click(Sender: TObject);
begin
  Close;
end;

procedure TfrmEditExtra.lbItemsSelectionChange(Sender: TObject; User: boolean);
begin
  if not User then Exit;
  SelectLine;
end;

procedure TfrmEditExtra.InitForm;
var I:Integer;
begin
  lbItems.Clear;
  for I:=0 to FExtra.Count-1 do
    lbItems.Items.Add((FExtra.Items[I] as TExtraItem).LongName);
  if lbItems.Count>0 then begin
    lbItems.ItemIndex:=0;
    SelectLine;
  end;
end;

procedure TfrmEditExtra.FillDayTypes;
var
  I: TDayType;
  J,K:Integer;
begin
  clbUsedTypes.Clear;
  //в объекте храним число часов, если что
  for I:=Low(TDayType) to High(TDayType) do begin
    J:=clbUsedTypes.Items.Add(TypeText[I]);    //тут в скобочках пишем исп часы, если не равны 0
    K:=FExtraItem.HoursOfType[I];
    clbUsedTypes.Items.Objects[J]:=TObject(PtrInt(K));
    if K<>0 then clbUsedTypes.Items[J]:=clbUsedTypes.Items[J]+'('+IntToStr(K)+')';
    if I in FExtraItem.DayTypes then
      clbUsedTypes.Checked[J]:=True;
  end;
end;

procedure TfrmEditExtra.SelectLine;
begin
  //выбрали  элемент из списка слева
  FExtraItem:=TExtraItem(FExtra.Items[lbItems.ItemIndex]);
  leFullName.Text:=FExtraItem.LongName;
  leShortName.Text:=FExtraItem.ShortName;
  cbUseCount.Checked:=FExtraItem.UseCount;
  FillDayTypes;
end;

procedure TfrmEditExtra.AddItem;
var I:Integer;
begin
  FExtraItem:=TExtraItem(FExtra.Add);
  FExtraItem.LongName:='New Item';
  I:=lbItems.Items.Add(FExtraItem.LongName);
  lbItems.ItemIndex:=I;
  SelectLine;
end;

procedure TfrmEditExtra.SaveItem;
var dts:TDayTypes;
    I,J:Integer;
begin
  FExtraItem.LongName:=leFullName.Text;
  FExtraItem.ShortName:=leShortName.Text;
  FExtraItem.UseCount:=cbUseCount.Checked;
  dts:=[];
  for I:=0 to clbUsedTypes.Count-1 do begin
    if clbUsedTypes.Checked[I] then
      dts:=dts+[TDayType(I)];
    J:=ptrint(clbUsedTypes.Items.Objects[I]);
    FExtraItem.HoursOfType[TDayType(I)]:=J;
  end;
  FExtraItem.DayTypes:=dts;
  lbItems.Items[lbItems.ItemIndex]:=FExtraItem.LongName;
end;

procedure TfrmEditExtra.DeleteItem;
begin
  FExtraItem.Free;
  InitForm;
end;

end.

