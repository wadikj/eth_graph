unit impOpts;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls,
  Spin, Buttons;

type

  { TfrmImpOpts }

  TfrmImpOpts = class(TForm)
    btImport: TButton;
    btSaveOpts: TButton;
    btCancel: TButton;
    cbMonth: TComboBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label6: TLabel;
    leDocName: TLabeledEdit;
    seFirstWorker: TSpinEdit;
    seWorkCount: TSpinEdit;
    seFirstDay: TSpinEdit;
    seYear: TSpinEdit;
    SpeedButton1: TSpeedButton;
    procedure btImportClick(Sender: TObject);
    procedure btSaveOptsClick(Sender: TObject);
    procedure btCancelClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure SpeedButton1Click(Sender: TObject);
  private
    FWB:OleVariant;
    FDocName:string;
    procedure InitView;
    procedure SaveOptions;
  public

  end;

var
  frmImpOpts: TfrmImpOpts;


procedure ImportGraph;

implementation

uses u_openXL, u_options, eth_tbl;

procedure ImportGraph;
begin
  Application.CreateForm(TfrmImpOpts,frmImpOpts);
  frmImpOpts.InitView;
  if frmImpOpts.ShowModal=mrOK then begin
    frmTable.CreateData(Options.DefImpMonth,Options.DefImpYear);
    frmTable.GraphData.ImportData(frmImpOpts.FWB);
    frmTable.View;
  end;
  frmImpOpts.FWB:=Null;
  FreeAndNil(frmImpOpts);
end;

{$R *.lfm}

{ TfrmImpOpts }

procedure TfrmImpOpts.btSaveOptsClick(Sender: TObject);
begin
  SaveOptions;
end;

procedure TfrmImpOpts.btCancelClick(Sender: TObject);
begin
  ModalResult:=mrCancel;
end;

procedure TfrmImpOpts.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  CloseAction:=caHide;
end;

procedure TfrmImpOpts.SpeedButton1Click(Sender: TObject);
var S:string;
begin
  FWB:=SelExcelDoc(S);
  if S<>'' then leDocName.Text:=S;
end;

procedure TfrmImpOpts.btImportClick(Sender: TObject);
begin
  SaveOptions;
  if FDocName<>'' then
    ModalResult:=mrOK;
end;

procedure TfrmImpOpts.InitView;
begin
  seYear.Value:=Options.DefImpYear;
  cbMonth.ItemIndex:=Options.DefImpMonth;
  seWorkCount.Value:=Options.DefWorkerCount;
  seFirstWorker.Value:=Options.FirstWorker;
  seFirstDay.Value:=Options.FirstDay;
  FWB:=Null;
end;

procedure TfrmImpOpts.SaveOptions;
begin
  Options.DefImpYear:=seYear.Value;
  Options.DefImpMonth:=cbMonth.ItemIndex;
  Options.DefWorkerCount:=seWorkCount.Value;
  Options.FirstWorker:=seFirstWorker.Value;
  Options.FirstDay:=seFirstDay.Value;
end;

end.

