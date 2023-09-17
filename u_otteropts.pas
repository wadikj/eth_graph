unit u_otteropts;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, Buttons,
  StdCtrls;

type

  { TfrmOtherOpts }

  TfrmOtherOpts = class(TForm)
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    cbShowLog: TCheckBox;
    lePyPath: TLabeledEdit;
    leDBPath: TLabeledEdit;
    leScrPath: TLabeledEdit;
    OpenDialog1: TOpenDialog;
    SelectDirectoryDialog1: TSelectDirectoryDialog;
    SpeedButton1: TSpeedButton;
    SpeedButton2: TSpeedButton;
    sbSelectDBPath: TSpeedButton;
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure sbSelectDBPathClick(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure SpeedButton2Click(Sender: TObject);
  private
    procedure LoadOpts;
    procedure SaveOpts;

  public

  end;

var
  frmOtherOpts: TfrmOtherOpts;

procedure EditOtherOpth;

implementation

uses u_options, eth_tbl;

procedure EditOtherOpth;
begin
  Application.CreateForm(TfrmOtherOpts, frmOtherOpts);
  frmOtherOpts.LoadOpts;
  if frmOtherOpts.ShowModal=mrOK then
    frmOtherOpts.SaveOpts;
  FreeAndNil(frmOtherOpts);
end;

{$R *.lfm}

{ TfrmOtherOpts }

procedure TfrmOtherOpts.FormClose(Sender: TObject; var CloseAction: TCloseAction
  );
begin
  CloseAction:=caHide;
end;

procedure TfrmOtherOpts.sbSelectDBPathClick(Sender: TObject);
begin
  OpenDialog1.FileName:=leDBPath.Text;
  if OpenDialog1.Execute then
    leDBPath.Text:=OpenDialog1.FileName;
end;

procedure TfrmOtherOpts.SpeedButton1Click(Sender: TObject);
begin
  OpenDialog1.FileName:=lePyPath.Text;
  if OpenDialog1.Execute then
    lePyPath.Text:=OpenDialog1.FileName;
end;

procedure TfrmOtherOpts.SpeedButton2Click(Sender: TObject);
begin
  SelectDirectoryDialog1.FileName:=leScrPath.Text;
  if SelectDirectoryDialog1.Execute then
    leScrPath.Text:=SelectDirectoryDialog1.FileName;
end;

procedure TfrmOtherOpts.LoadOpts;
begin
  lePyPath.Text:=Options.PyPath;
  leScrPath.Text:=Options.ScrDir;
  cbShowLog.Checked:=Options.ShowLog;
  leDBPath.Text:=Options.DBPath;
  if frmTable.Data<>nil then begin
    sbSelectDBPath.Enabled:=False;
    leDBPath.Enabled:=False;
    leDBPath.Hint:='Можно редактировать только если нет открытого графика';
  end;
end;

procedure TfrmOtherOpts.SaveOpts;
begin
  Options.PyPath:=lePyPath.Text;
  Options.ScrDir:=leScrPath.Text;
  Options.ShowLog:=cbShowLog.Checked;
  if frmTable.Data=nil then
    Options.DBPath:=leDBPath.Text;
end;

end.

