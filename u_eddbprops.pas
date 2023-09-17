unit u_edDbProps;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls,
  Buttons;

type

  { TfrmDBGraphProps }

  TfrmDBGraphProps = class(TForm)
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    cbSortTypes: TComboBox;
    Label2: TLabel;
    leWPR: TLabeledEdit;
  private
    procedure IninForm;

  public

  end;

var
  frmDBGraphProps: TfrmDBGraphProps;

function EditDBGraphProps:boolean;

implementation

uses u_data, eth_tbl, gdata, SQLDB;

function EditDBGraphProps: boolean;
begin
  Application.CreateForm(TfrmDBGraphProps,frmDBGraphProps);
  frmDBGraphProps.IninForm;
  if frmDBGraphProps.ShowModal=mrOK then begin
    Result:=frmTable.Data.SaveWPRAnDSort(frmDBGraphProps.leWPR.Text,
      PtrInt(frmDBGraphProps.cbSortTypes.Items.Objects[frmDBGraphProps.cbSortTypes.ItemIndex]));
  end;
end;

{$R *.lfm}

{ TfrmDBGraphProps }

procedure TfrmDBGraphProps.IninForm;
var I:PtrInt;
begin
  leWPR.Text:=frmTable.Data.TextWPR;
  DM.LoadStrings('select sid, sname from sort_info',cbSortTypes.Items);
  I:=cbSortTypes.Items.IndexOfObject(TObject(PtrInt(frmTable.Data.SortID)));
  if I<>-1 then
    cbSortTypes.ItemIndex:=I;
end;

end.

