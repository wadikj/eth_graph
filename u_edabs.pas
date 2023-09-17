unit u_edabs;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, Spin,
  ExtCtrls, Buttons, DateTimePicker, SQLDB;

type

  { TfrmEditAbs }

  TfrmEditAbs = class(TForm)
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    cbWorker: TComboBox;
    cbType: TComboBox;
    dtStart: TDateTimePicker;
    Label1: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    leComm: TLabeledEdit;
    seLen: TSpinEdit;
    procedure BitBtn1Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
  private
    FAID:Integer;
    procedure InitForm;
    procedure FillForm;
    function SaveData:boolean;
  public

  end;

var
  frmEditAbs: TfrmEditAbs;

function EditAbs(AID:Integer = -1):boolean;

implementation

uses u_data, u_options;

function EditAbs(AID: Integer): boolean;
begin
  Application.CreateForm(TfrmEditAbs,frmEditAbs);
  frmEditAbs.FAID:=AID;
  frmEditAbs.InitForm;
  frmEditAbs.FillForm;
  if  AID<>-1 then
    frmEditAbs.Caption:='Ввод отсутствия';
  Result:=frmEditAbs.ShowModal=mrOK;
  FreeAndNil(frmEditAbs);
end;

{$R *.lfm}

{ TfrmEditAbs }

procedure TfrmEditAbs.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  CloseAction:=caHide;
end;

procedure TfrmEditAbs.BitBtn1Click(Sender: TObject);
begin
  if SaveData then
    ModalResult:=mrOK;
end;

procedure TfrmEditAbs.InitForm;
var T:TDayType;
begin
  //заполняем и очищаем
  //работники
  DM.LoadStrings('select wid, wname from workers order by wname', cbWorker.Items);
  //типы
  for T in TDayType do begin
    cbType.Items.AddObject(TypeText[T], TObject(PtrInt(T)));
  end;
  //дата начала now
  dtStart.Date:=Now;
  leComm.Text:='';
end;

procedure TfrmEditAbs.FillForm;
var SQL:string;
    DS:TSQLQuery;
    I,J:PtrInt;
begin
  ///извлекаем из БД
  if FAID=-1 then Exit;
  SQL:='select adate, alen, atype, ainfo, wid ' +
    ' from absenses where aid = %d'.Format([FAID]);
  DS:=DM.GetDS(SQL);
  dtStart.Date:=DM._std(DS.FieldByName('adate').AsString);
  seLen.Value:=DS.FieldByName('alen').AsInteger;
  leComm.Text:=DS.FieldByName('ainfo').AsString;

  I:=DS.FieldByName('atype').AsInteger;
  J:=cbType.Items.IndexOfObject(TObject(I));
  if J<>-1 then cbType.ItemIndex:=J;

  I:=DS.FieldByName('wid').AsInteger;
  J:=cbWorker.Items.IndexOfObject(TObject(I));
  if J<>-1 then cbWorker.ItemIndex:=J;

end;

function TfrmEditAbs.SaveData: boolean;
var SQL:String;
begin
  Result:=False;
  if cbType.ItemIndex=-1 then begin
    ShowMessage('Введите тип отсутствия!!!');
    Exit;
  end;

  if cbWorker.ItemIndex=-1 then begin
    ShowMessage('Введите отсутствующего работника!!!');
    Exit;
  end;

  if FAID=-1 then begin //new abs
    SQL:='insert into absenses (adate, alen, atype, wid, ainfo) '+
      'values (''%s'', %d, %d, %d, ''%s'')'.Format([DM._dts(dtStart.Date),
      seLen.Value, PtrInt(cbType.Items.Objects[cbType.ItemIndex]),
      PtrInt(cbWorker.Items.Objects[cbWorker.ItemIndex]), leComm.Text]);
  end else begin
    SQL:='update absenses set adate = ''%s'', alen = %d, atype = %d, wid = %d, '+
      'ainfo = ''%s'' where aid = %d';
    SQL:=SQL.Format([DM._dts(dtStart.Date),
      seLen.Value, PtrInt(cbType.Items.Objects[cbType.ItemIndex]),
      PtrInt(cbWorker.Items.Objects[cbWorker.ItemIndex]), leComm.Text, FAID]);
    ///ShowMessage(SQL);
  end;
  DM.ExecSQL(SQL);
  Result:=True;
end;

end.

