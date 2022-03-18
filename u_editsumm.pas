unit u_editSumm;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, Buttons;

type

  { TfrmSummOpt }

  TfrmSummOpt = class(TForm)
    btOk: TButton;
    btCancel: TButton;
    Label1: TLabel;
    Label2: TLabel;
    lbAll: TListBox;
    lbReq: TListBox;
    sbAdd: TSpeedButton;
    sbDel: TSpeedButton;
    sbUp: TSpeedButton;
    sbDown: TSpeedButton;
    procedure btOkClick(Sender: TObject);
    procedure sbAddClick(Sender: TObject);
    procedure sbDelClick(Sender: TObject);
    procedure sbDownClick(Sender: TObject);
    procedure sbUpClick(Sender: TObject);
  private
    procedure InitForm;
    procedure SaveData;
    procedure AddCol;
    procedure DelCol;
    procedure ColUp;
    procedure ColDown;
  public

  end;

var
  frmSummOpt: TfrmSummOpt;

function EditSummCols:boolean;

implementation

uses u_options, s_tools, LCLType;

function EditSummCols: boolean;
begin
  Application.CreateForm(TfrmSummOpt,frmSummOpt);
  frmSummOpt.InitForm;
  Result:=frmSummOpt.ShowModal=mrOK;
  FreeAndNil(frmSummOpt);
end;

{$R *.lfm}

{ TfrmSummOpt }

procedure TfrmSummOpt.btOkClick(Sender: TObject);
begin
  SaveData;
  ModalResult:=mrOK;
end;

procedure TfrmSummOpt.sbAddClick(Sender: TObject);
begin
  AddCol;
end;

procedure TfrmSummOpt.sbDelClick(Sender: TObject);
begin
  DelCol;
end;

procedure TfrmSummOpt.sbDownClick(Sender: TObject);
begin
  ColDown;
end;

procedure TfrmSummOpt.sbUpClick(Sender: TObject);
begin
  ColUp;
end;

procedure TfrmSummOpt.InitForm;
var X,S,S1:string;
    I:Integer;
begin
  X:=','+Options.sCols+',';
  for I:=0 to Options.gExtraCols.Count-1 do begin
    S:=Options.gExtraCols.Items[I].ShortName;
    S1:=Options.gExtraCols.Items[I].LongName+'('+S+')';
    if Pos(','+S+',',X)>0 then begin
      lbReq.Items.AddObject(S1,TObject(PtrInt(I)));
    end else begin
      lbAll.Items.AddObject(S1,TObject(Ptrint(I)));
    end;
  end;
end;

procedure TfrmSummOpt.SaveData;
var Res:string;
    I,J:Integer;
begin
  Res:='';
  for I:=0 to lbReq.Count-1 do begin
    J:=PtrInt(lbReq.Items.Objects[I]);
    Res:=StrListAdd(Res,Options.gExtraCols.Items[J].ShortName);
  end;
  //message to user if Res<>Options.sCols
  if Res<>Options.sCols then begin
    if Application.MessageBox('Список колонок для суммированного учата не совпадает с сохраненным в '+
      'настройках программы. При открытии данных за год они будут сброшенны. Продолжить?',
      'Сохранение настроек суммированного учета',MB_YESNO+MB_ICONWARNING)=mrYes then begin
        Options.sCols:=Res;
    end;
  end;
end;

procedure TfrmSummOpt.AddCol;
begin
  if lbAll.ItemIndex<0 then Exit;
  lbReq.Items.AddObject(lbAll.Items[lbAll.ItemIndex],lbAll.Items.Objects[lbAll.ItemIndex]);
  lbAll.Items.Delete(lbAll.ItemIndex);
end;

procedure TfrmSummOpt.DelCol;
begin
  if lbReq.ItemIndex<0 then Exit;
  lbAll.Items.AddObject(lbReq.Items[lbReq.ItemIndex],lbReq.Items.Objects[lbReq.ItemIndex]);
  lbReq.Items.Delete(lbReq.ItemIndex);
end;

procedure TfrmSummOpt.ColUp;
begin
  if lbReq.ItemIndex<1 then Exit;
  lbReq.Items.Move(lbReq.ItemIndex,lbReq.ItemIndex-1);
end;

procedure TfrmSummOpt.ColDown;
begin
  if (lbReq.ItemIndex<0)or(lbReq.ItemIndex>lbReq.Items.Count-2) then Exit;
  lbReq.Items.Move(lbReq.ItemIndex,lbReq.ItemIndex-1);
end;

end.

