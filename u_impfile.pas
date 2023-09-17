unit u_impfile;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, Buttons;

type

  { TfrmImpFile }

  TfrmImpFile = class(TForm)
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    cbWList: TComboBox;
    cbGTypes: TComboBox;
    Label1: TLabel;
    Label2: TLabel;
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
  private
    procedure InitForm;

  public

  end;

var
  frmImpFile: TfrmImpFile;

procedure ImportFromFile;

implementation

uses SQLDB, u_data, eth_tbl;

procedure ImportFromFile;
var WID, TID:Integer;
    tname:string;
begin
  Application.CreateForm(TfrmImpFile,frmImpFile);
  frmImpFile.InitForm;
  if frmImpFile.ShowModal = mrOK then with frmImpFile do begin
    WID:=PtrInt(cbWList.Items.Objects[cbWList.ItemIndex]);
    tname:='';
    if cbGTypes.ItemIndex=-1 then begin
      TID:=-1;
      tname:=cbGTypes.Text;
    end else begin
      TID:=PtrInt(cbGTypes.Items.Objects[cbGTypes.ItemIndex]);
    end;
    if frmTable.Data.ImportFromFile(WID,TID,tname) then
      ShowMessage('Импорт успешен')
    else
      ShowMessage('Ошибка импорта');
  end;
end;

{$R *.lfm}

{ TfrmImpFile }

procedure TfrmImpFile.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  CloseAction:=caFree;
end;

procedure TfrmImpFile.InitForm;
begin
  DM.LoadStrings('select sid, sname from sort_info order by sid', cbWList.Items);
  if cbWList.Items.Count>0 then cbWList.ItemIndex:=0;
  DM.LoadStrings('select tid, tname from graph_types order by torder', cbGTypes.Items);
  if cbGTypes.Items.Count>0 then cbGTypes.ItemIndex:=0;
end;

end.

