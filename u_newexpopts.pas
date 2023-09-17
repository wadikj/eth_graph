unit U_newexpopts;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls,
  Buttons, ComObj, Variants;

type

  { TfrmNewExp }

  TfrmNewExp = class(TForm)
    btExport: TButton;
    btCancel: TButton;
    GroupBox1: TGroupBox;
    Label1: TLabel;
    leColFirstDay: TLabeledEdit;
    cbDocName: TComboBox;
    leRowFirstWorker: TLabeledEdit;
    leRowManFirst: TLabeledEdit;
    leColDate: TLabeledEdit;
    leColTime: TLabeledEdit;
    leColWorker: TLabeledEdit;
    SpeedButton1: TSpeedButton;
    procedure btExportClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure SpeedButton1Click(Sender: TObject);
  private
    FWB:OleVariant;
    //FXL:OleVariant;
    procedure Init;
    procedure SaveChanges;
  public

  end;

var
  frmNewExp: TfrmNewExp;

function EditExpOption:boolean;

procedure ExportNew;

implementation

uses u_options, eth_tbl, u_openXL, u_openFF;

function EditExpOption: boolean;
begin
  ///!!!вальнут это !!!
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
    frmNewExp.FWB:=Options.GetDocument(frmNewExp.cbDocName.Text);
    if frmTable.GraphData<>nil then begin
      frmTable.GraphData.ExportData(frmNewExp.FWB);
      if not frmNewExp.FWB.Application.Visible then frmNewExp.FWB.Application.Visible:=True;
      //frmNewExp.FXL.Saved[0]:=True;
    end
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
  if cbDocName.Text<>'' then
    ModalResult:=mrOK;
end;

procedure TfrmNewExp.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  CloseAction:=caHide;
end;

procedure TfrmNewExp.SpeedButton1Click(Sender: TObject);
var S:string;
begin
  S:=OpenFileFolder(True);
  //FWB:=SelExcelDoc(S);
  if S<>'' then cbDocName.Text:=S;
end;

procedure TfrmNewExp.Init;
begin
  FWB:=Null;
  leColFirstDay.Text:=IntToStr(Options.xFirstCol);
  leRowFirstWorker.Text:=IntToStr(Options.xFirstRow);
  leRowManFirst.Text:=IntToStr(Options.xMansRow);
  leColDate.Text:=IntToStr(Options.xMansCol);
  leColTime.Text:=IntToStr(Options.xMansColTime);
  leColWorker.Text:=IntToStr(Options.xMansColName);
  cbDocName.Items.Assign(Options.FFiles);
  cbDocName.Caption:=Options.xNewTemplate;
end;

procedure TfrmNewExp.SaveChanges;
begin
  Options.xFirstCol:=StrToInt(leColFirstDay.Text);
  Options.xFirstRow:=StrToInt(leRowFirstWorker.Text);
  Options.xMansRow:=StrToInt(leRowManFirst.Text);
  Options.xMansCol:=StrToInt(leColDate.Text);
  Options.xMansColTime:=StrToInt(leColTime.Text);
  Options.xMansColName:=StrToInt(leColWorker.Text);
  //if (Options.xNewTemplate='') or (Options.XUseLastNewTempl) then
  Options.xNewTemplate:=cbDocName.Caption;
end;

end.

