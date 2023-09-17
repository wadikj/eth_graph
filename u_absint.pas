unit u_absInt;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, Buttons,
  DateTimePicker;

type

  { TfrmSelAbsInt }

  TfrmSelAbsInt = class(TForm)
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    cbTempl: TComboBox;
    cbSortFrom: TComboBox;
    dtStart: TDateTimePicker;
    dtEnd: TDateTimePicker;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    procedure cbTemplSelect(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
  private
    procedure TM;
    procedure NM;
    procedure TK;
    procedure NK;
  public

  end;

var
  frmSelAbsInt: TfrmSelAbsInt;

function SelectAbsInt(var AFirst, ALast:TDate; var AOrder:string):boolean;

implementation

uses DateUtils;

const so:array [0..2] of string = ('adate, wname','wname, adate','atype, adate');

{
Текущий месяц
Следующий месяц
Текущий квартал
Следующий квартал
Произвольно
}

function SelectAbsInt(var AFirst, ALast: TDate; var AOrder: string): boolean;
begin
  Result:=False;
  Application.CreateForm(TfrmSelAbsInt,frmSelAbsInt);
  frmSelAbsInt.dtStart.Date:=AFirst;
  frmSelAbsInt.dtEnd.Date:=ALast;
  frmSelAbsInt.cbTempl.ItemIndex:=4;
  if AOrder<>'adate, wname' then frmSelAbsInt.cbSortFrom.ItemIndex:=1;
  if AOrder<>'wname, adate' then frmSelAbsInt.cbSortFrom.ItemIndex:=2;
  if frmSelAbsInt.ShowModal=mrOK then begin
    AFirst:=(frmSelAbsInt.dtStart.Date);
    ALast:=frmSelAbsInt.dtEnd.Date;
    AOrder:=so[frmSelAbsInt.cbSortFrom.ItemIndex];
    Result:=True;
  end;
  FreeAndNil(frmSelAbsInt);
end;

{$R *.lfm}

{ TfrmSelAbsInt }

procedure TfrmSelAbsInt.FormClose(Sender: TObject; var CloseAction: TCloseAction
  );
begin
  CloseAction:=caHide;
end;

procedure TfrmSelAbsInt.cbTemplSelect(Sender: TObject);
begin
  case cbTempl.ItemIndex of
    0:TM;
    1:NM;
    2:TK;
    3:NK;
  end;
end;

procedure TfrmSelAbsInt.TM;
var D,M,Y:Word;
begin
  DecodeDate(Now,Y,M,D);
  dtStart.Date:=EncodeDate(Y,M,1);
  dtEnd.Date:=EncodeDate(Y,M,DaysInAMonth(Y,M));
end;

procedure TfrmSelAbsInt.NM;
var D,M,Y:Word;
begin
  DecodeDate(Now,Y,M,D);
  IncAMonth(Y,M,D,1);
  dtStart.Date:=EncodeDate(Y,M,1);
  dtEnd.Date:=EncodeDate(Y,M,DaysInAMonth(Y,M));
end;

procedure TfrmSelAbsInt.TK;
var D,M,Y:Word;
    M1,M2:Word;
begin
  DecodeDate(Now,Y,M,D);
  M1:=(((M-1) div 3) * 3)+1;
  M2:=M1+2;
  dtStart.Date:=EncodeDate(Y,M1,1);
  dtEnd.Date:=EncodeDate(Y,M2,DaysInAMonth(Y,M2));
end;

procedure TfrmSelAbsInt.NK;
var D,M,Y:Word;
    M1,M2:Word;
begin
  DecodeDate(Now,Y,M,D);
  IncAMonth(Y,M,D,3);
  M1:=(((M-1) div 3) * 3)+1;
  M2:=M1+2;
  dtStart.Date:=EncodeDate(Y,M1,1);
  dtEnd.Date:=EncodeDate(Y,M2,DaysInAMonth(Y,M2));
end;

end.

