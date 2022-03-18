unit U_newexpopts;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls,
  Buttons;

type

  { TfrmNewExp }

  TfrmNewExp = class(TForm)
    btExport: TButton;
    btCancel: TButton;
    GroupBox1: TGroupBox;
    leColFirstDay: TLabeledEdit;
    leDocName: TLabeledEdit;
    leRowFirstWorker: TLabeledEdit;
    leRowManFirst: TLabeledEdit;
    leColDate: TLabeledEdit;
    leColTime: TLabeledEdit;
    leColWorker: TLabeledEdit;
    SpeedButton1: TSpeedButton;
    procedure btExportClick(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
  private
    FWB:OleVariant;
    procedure Init;
    procedure SaveChanges;

  public

  end;

var
  frmNewExp: TfrmNewExp;

function EditExpOption:boolean;

procedure ExportNew;

implementation

uses u_options, eth_tbl, u_openXL;

function EditExpOption: boolean;
begin
  Application.CreateForm(TfrmNewExp,frmNewExp);
  frmNewExp.Init;
  REsult:=frmNewExp.ShowModal=mrOK;
  FreeAndNil(frmNewExp);
end;

procedure ExportNew;
begin
  Application.CreateForm(TfrmNewExp,frmNewExp);
  frmNewExp.Init;
  if frmNewExp.ShowModal=mrOK then begin
    if frmTable.GraphData<>nil then
      frmTable.GraphData.ExportData(frmNewExp.FWB)
    else
      ShowMessage('Нет графика для экспорта!!!');
  end;
  frmNewExp.FWB:=Null;
  FreeAndNil(frmNewExp);
end;

{$R *.lfm}

{ TfrmNewExp }

procedure TfrmNewExp.btExportClick(Sender: TObject);
begin
  SaveChanges;
  if leDocName.Text<>'' then
    ModalResult:=mrOK;
end;

procedure TfrmNewExp.SpeedButton1Click(Sender: TObject);
var S:string;
begin
  FWB:=SelExcelDoc(S);
  if S<>'' then leDocName.Text:=S;
end;

procedure TfrmNewExp.Init;
begin
  leColFirstDay.Text:=IntToStr(Options.xFirstCol);
  leRowFirstWorker.Text:=IntToStr(Options.xFirstRow);
  leRowManFirst.Text:=IntToStr(Options.xMansRow);
  leColDate.Text:=IntToStr(Options.xMansCol);
  leColTime.Text:=IntToStr(Options.xMansColTime);
  leColWorker.Text:=IntToStr(Options.xMansColName);
end;

procedure TfrmNewExp.SaveChanges;
begin
  Options.xFirstCol:=StrToInt(leColFirstDay.Text);
  Options.xFirstRow:=StrToInt(leRowFirstWorker.Text);
  Options.xMansRow:=StrToInt(leRowManFirst.Text);
  Options.xMansCol:=StrToInt(leColDate.Text);
  Options.xMansColTime:=StrToInt(leColTime.Text);
  Options.xMansColName:=StrToInt(leColWorker.Text);
end;

end.

