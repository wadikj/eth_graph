unit u_ScrProps;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls,
  Buttons;

type

  { TfrmScrOptions }

  TfrmScrOptions = class(TForm)
    btChange: TButton;
    btNew: TButton;
    btDel: TButton;
    btClose: TButton;
    Label1: TLabel;
    Label2: TLabel;
    leName: TLabeledEdit;
    leFileName: TLabeledEdit;
    lbScripts: TListBox;
    mmHint: TMemo;
    OpenDialog1: TOpenDialog;
    SpeedButton1: TSpeedButton;
    procedure btChangeClick(Sender: TObject);
    procedure btDelClick(Sender: TObject);
    procedure btNewClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure lbScriptsSelectionChange(Sender: TObject; User: boolean);
    procedure SpeedButton1Click(Sender: TObject);
  private
    FEditIndex:Integer;//индекс редактируемой записи. Если -1, то новая запись
    FModified:boolean;
    procedure Init;
    procedure NewScr;
    procedure SaveChanges;
    procedure EditScr;
  public

  end;

var
  frmScrOptions: TfrmScrOptions;

function ScrProperties:boolean;

implementation

uses u_options;

function ScrProperties: boolean;
begin
  Application.CreateForm(TfrmScrOptions,frmScrOptions);
  frmScrOptions.Init;
  frmScrOptions.ShowModal;
  Result:=frmScrOptions.FModified;
  FreeAndNil(frmScrOptions);
end;

{$R *.lfm}

{ TfrmScrOptions }

procedure TfrmScrOptions.SpeedButton1Click(Sender: TObject);
begin
  OpenDialog1.InitialDir:=Options.ScrDir;
  if OpenDialog1.Execute then
    leFileName.Text:=OpenDialog1.FileName;
end;

procedure TfrmScrOptions.FormClose(Sender: TObject;
  var CloseAction: TCloseAction);
begin
  CloseAction:=caHide;
end;

procedure TfrmScrOptions.btNewClick(Sender: TObject);
begin
  NewScr;
end;

procedure TfrmScrOptions.btChangeClick(Sender: TObject);
begin
  SaveChanges;
end;

procedure TfrmScrOptions.btDelClick(Sender: TObject);
begin
  ///
end;

procedure TfrmScrOptions.lbScriptsSelectionChange(Sender: TObject; User: boolean
  );
var I:Integer;
begin
  if not User then Exit;
  I:=lbScripts.ItemIndex;
  if I<>FEditIndex then begin
    FEditIndex:=I;
    EditScr;
  end;
end;

procedure TfrmScrOptions.Init;
var
  I: Integer;
begin
  FModified:=False;
  lbScripts.Clear;
  for I:=0 to Options.Scripts.Count-1 do
    lbScripts.Items.Add(Options.Scripts[I].Name);
  if lbScripts.Count<>0 then begin
    lbScripts.Selected[0]:=True;
    EditScr;
  end;
end;

procedure TfrmScrOptions.NewScr;
begin
  FEditIndex:=-1;
  leFileName.Text:='';
  leName.Text:='';
  mmHint.Clear;
end;

procedure TfrmScrOptions.SaveChanges;
begin
  if (leFileName.Text='')or(leName.Text='')or(mmHint.Text='') then begin
    ShowMessage('Не заданы все параметры скрипта. Сохранение невозможно');
    Exit;
  end;
  if FEditIndex=-1 then begin
    Options.Scripts.Add;
    FEditIndex:=lbScripts.Items.Add(leName.Text);
    lbScripts.ItemIndex:=FEditIndex;
  end;

  Options.Scripts[FEditIndex].Name:=leName.Text;
  Options.Scripts[FEditIndex].FileName:=leFileName.Text;
  Options.Scripts[FEditIndex].Hint:=mmHint.Text;
  lbScripts.Items[FEditIndex]:=leName.Text;

  FModified:=True;
end;

procedure TfrmScrOptions.EditScr;
begin
  leName.Text:=Options.Scripts[FEditIndex].Name;
  leFileName.Text:=Options.Scripts[FEditIndex].FileName;
  mmHint.Text:=Options.Scripts[FEditIndex].Hint;
end;

end.

