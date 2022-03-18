unit u_OldExport;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls,
  Buttons, u_options;

type

  { TfrmExpOldXL }

  TfrmExpOldXL = class(TForm)
    btSave: TButton;
    btExport: TButton;
    btCancel: TButton;
    cbUseWeek: TCheckBox;
    cbUseBG: TCheckBox;
    cbUseFont: TCheckBox;
    cbUseStr: TCheckBox;
    cbUseType: TCheckBox;
    cbOutHours: TCheckBox;
    edOtherStr: TEdit;
    GroupBox1: TGroupBox;
    leDocName: TLabeledEdit;
    leFirstWorker: TLabeledEdit;
    leFirstDate: TLabeledEdit;
    leDaysLine: TLabeledEdit;
    lb: TListBox;
    SpeedButton1: TSpeedButton;
    procedure btSaveClick(Sender: TObject);
    procedure btExportClick(Sender: TObject);
    procedure btCancelClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure lbSelectionChange(Sender: TObject; User: boolean);
    procedure SpeedButton1Click(Sender: TObject);
  private
    FEditItem:TOEItem;
    FWB:OleVariant;
    procedure InitForm;
    procedure InitDayRules;
    procedure SelectItem;
    procedure SaveItem;
    procedure SaveAll;

  public

  end;

var
  frmExpOldXL: TfrmExpOldXL;

procedure ExportOldXL;

function EditOldExpOpts:boolean;

implementation

uses u_openXL, eth_tbl;

procedure ExportOldXL;
begin
  Application.CreateForm(TfrmExpOldXL,frmExpOldXL);
  frmExpOldXL.InitForm;
  if frmExpOldXL.ShowModal=mrOK then begin
    if frmTable.GraphData<>nil then
      frmTable.GraphData.ExportOldGraph(frmExpOldXL.FWB)
    else
      ShowMessage('Нет графика для экспорта!!!');
  end;
  frmExpOldXL.FWB:=Null;
  FreeAndNil(frmExpOldXL);
end;

function EditOldExpOpts: boolean;
begin
  Application.CreateForm(TfrmExpOldXL,frmExpOldXL);
  frmExpOldXL.InitForm;
  Result:=frmExpOldXL.ShowModal=mrOK;
  FreeAndNil(frmExpOldXL);
end;

{$R *.lfm}

{ TfrmExpOldXL }

procedure TfrmExpOldXL.btSaveClick(Sender: TObject);
begin
  SaveAll;
end;

procedure TfrmExpOldXL.btExportClick(Sender: TObject);
begin
  SaveAll;
  if leDocName.Text<>'' then
    ModalResult:=mrOK;
end;

procedure TfrmExpOldXL.btCancelClick(Sender: TObject);
begin
  SaveAll;
  ModalResult:=mrCancel;
end;

procedure TfrmExpOldXL.FormClose(Sender: TObject; var CloseAction: TCloseAction
  );
begin
  CloseAction:=caHide;
end;

procedure TfrmExpOldXL.lbSelectionChange(Sender: TObject; User: boolean);
begin
  if User then
    SelectItem;
end;

procedure TfrmExpOldXL.SpeedButton1Click(Sender: TObject);
var S:string;
begin
  FWB:=SelExcelDoc(S);
  if S<>'' then leDocName.Text:=S;
end;

procedure TfrmExpOldXL.InitForm;
var I:Integer;
begin
  InitDayRules;
  lb.Clear;
  for I:=0 to Options.OEDayRules.Count-1 do begin
    lb.Items.Add(Options.OEDayRules.Items[I].Name);
  end;
  leFirstWorker.Text:=IntToStr(Options.FirstWorker);
  leFirstDate.Text:=IntToStr(Options.FirstDay);
  leDaysLine.Text:=IntToStr(Options.DaysLine);
  cbUseWeek.Checked:=Options.UseWeekendColors;
  cbOutHours.Checked:=Options.AlwaysUseHours;
  lb.ItemIndex:=0;
  FEditItem:=nil;
end;

procedure TfrmExpOldXL.InitDayRules;
var oe:TOEItem;
    I: TDayType;
begin
  if Options.OEDayRules.Count=0 then begin
    for I:=Low(TDayType) to High(TDayType) do begin
      oe:=TOEItem(Options.OEDayRules.Add);
      oe.AType:=I;
    end;
  end else begin
    //тут проверяем, чтобы у нас все элементы коллекции имели нужный индекс
    for I:=Low(TDayType) to High(TDayType) do begin
      if Options.OEDayRules.Count=Integer(I) then begin
        oe:=TOEItem(Options.OEDayRules.Add);
        oe.AType:=I;
      end else begin
        oe:=Options.OEDayRules.Items[Integer(I)];
        if oe.AType<>I then oe.AType:=I;
      end;
    end;
  end;
end;

procedure TfrmExpOldXL.SelectItem;
var I:Integer;
begin
  if FEditItem<>nil then SaveItem;
  I:=lb.ItemIndex;
  if I<>-1 then
    FEditItem:=Options.OEDayRules.Items[I]
  else begin
    ShowMessage('Выделен какой то левый элемент');
    FEditItem:=nil;
    Exit;
  end;
  cbUseType.Checked:=FEditItem.Exported;
  cbUseBG.Checked:=FEditItem.UseBG;
  cbUseFont.Checked:=FEditItem.USeFont;
  cbUseStr.Checked:=FEditItem.UseStr;
  edOtherStr.Text:=FEditItem.OtherStr;
end;

procedure TfrmExpOldXL.SaveItem;
begin
  if FEditItem=nil then Exit;
  FEditItem.Exported:=cbUseType.Checked;
  FEditItem.UseBG:=cbUseBG.Checked;
  FEditItem.USeFont:=cbUseFont.Checked;
  FEditItem.UseStr:=cbUseStr.Checked;
  FEditItem.OtherStr:=edOtherStr.Text;
end;

procedure TfrmExpOldXL.SaveAll;
begin
  SaveItem;
  Options.FirstWorker:=StrToInt(leFirstWorker.Text);
  Options.DaysLine:=StrToInt(leDaysLine.Text);
  Options.FirstDay:=StrToInt(leFirstDate.Text);
  Options.UseWeekendColors:=cbUseWeek.Checked;
  Options.AlwaysUseHours:=cbOutHours.Checked;
end;

end.

