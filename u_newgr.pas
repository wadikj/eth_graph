unit u_newgr;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, Spin,
  ExtCtrls;

type

  { TfrmNewGr }

  TfrmNewGr = class(TForm)
    Button1: TButton;
    Button2: TButton;
    cbMonth: TComboBox;
    Label1: TLabel;
    Label2: TLabel;
    leWeekends: TLabeledEdit;
    leFileName: TLabeledEdit;
    seYear: TSpinEdit;
    procedure cbMonthSelect(Sender: TObject);
  private

  public

  end;

var
  frmNewGr: TfrmNewGr;

implementation

uses s_tools, u_options;

{$R *.lfm}

{ TfrmNewGr }

procedure TfrmNewGr.cbMonthSelect(Sender: TObject);
var S,S1:string;
begin
  if cbMonth.ItemIndex<1 then Exit;
  S:=cbMonth.Items[cbMonth.ItemIndex];
  DivStr(S,'-');
  leFileName.Text:=S;
  S1:=Options.DefDataDir+'\'+S+'.gr';
  if FileExists(S1) then begin
    if MessageDlg('Файл уже существует. Использовать текущее имя файла?',mtWarning,mbYesNo,0,mbYes)=mrYes then
      leFileName.Text:=S
    else
      leFileName.Text:='';
  end;
end;

end.

