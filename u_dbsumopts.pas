unit u_DBSumOpts;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ComCtrls, StdCtrls,
  Buttons, CheckLst;

type

  { TfrmDBSummOpt }

  TfrmDBSummOpt = class(TForm)
    bbDown: TBitBtn;
    bbDown1: TBitBtn;
    bbAddSumm: TBitBtn;
    bbDelSumm: TBitBtn;
    bbUp: TBitBtn;
    bbUp1: TBitBtn;
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    clb: TCheckListBox;
    Label1: TLabel;
    Label2: TLabel;
    lbSumm: TListBox;
    procedure bbDown1Click(Sender: TObject);
    procedure bbAddSummClick(Sender: TObject);
    procedure bbDelSummClick(Sender: TObject);
    procedure bbDownClick(Sender: TObject);
    procedure bbUp1Click(Sender: TObject);
    procedure bbUpClick(Sender: TObject);
    procedure BitBtn1Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
  private
    FMonts,
    FSummary:TStringList;
    procedure InitView;
  public

  end;

var
  frmDBSummOpt: TfrmDBSummOpt;

function ShowDBSummOpts(AMonts, ASummary:TStringList):boolean;

implementation

uses u_options;

function ShowDBSummOpts(AMonts, ASummary: TStringList): boolean;
begin
  //на входе - списки того, что показывать в месяце и суммарно
  Application.CreateForm(TfrmDBSummOpt,frmDBSummOpt);
  frmDBSummOpt.FMonts:=AMonts;
  frmDBSummOpt.FSummary:=ASummary;
  frmDBSummOpt.InitView;
  Result:=frmDBSummOpt.ShowModal=mrOK;


end;

{$R *.lfm}

{ TfrmDBSummOpt }

procedure TfrmDBSummOpt.FormClose(Sender: TObject; var CloseAction: TCloseAction
  );
begin
  CloseAction:=caFree;
end;

procedure TfrmDBSummOpt.BitBtn1Click(Sender: TObject);
var sa:TStringArray;
    I: Integer;
begin
  //monts
  FMonts.Clear;
  for I:=0 to clb.Count-1 do begin
    if not clb.Checked[I] then Continue;
    sa:=clb.Items[I].Split(' - ');
    FMonts.Add(sa[0]);
  end;
  FSummary.Clear;
  FSummary.AddStrings(lbSumm.Items);
  ModalResult:=mrOK;
end;

procedure TfrmDBSummOpt.bbUpClick(Sender: TObject);
begin
  if clb.ItemIndex<1 then Exit;
  clb.Items.Move(clb.ItemIndex,clb.ItemIndex-1);
end;

procedure TfrmDBSummOpt.bbDownClick(Sender: TObject);
begin
  if (clb.ItemIndex<0)or(clb.ItemIndex>=clb.Items.Count-1)  then Exit;
  clb.Items.Move(clb.ItemIndex,clb.ItemIndex+1);
end;

procedure TfrmDBSummOpt.bbDown1Click(Sender: TObject);
begin
  if (lbSumm.ItemIndex<0)or(lbSumm.ItemIndex>=lbSumm.Items.Count-1)  then Exit;
  lbSumm.Items.Move(lbSumm.ItemIndex,lbSumm.ItemIndex+1);
end;

procedure TfrmDBSummOpt.bbAddSummClick(Sender: TObject);
var S,S1:string;
    sa:TStringArray;
    BadInput:boolean;
begin
  S:=InputBox('ETH_GRAPH','Введите название вычисляемой колонки:','');
  if S<>'' then begin
    sa:=S.Split('+');
    BadInput:=False;
    for S1 in sa do begin
      if Options.gExtraCols.ByShortName[S1]=nil then begin
        BadInput:=True;
        Break;
      end;
    end;
    if BadInput then begin
      ShowMessage('Введено недопустимое имя колонки');
    end else begin
      lbSumm.Items.Add(S);
    end;
  end;
end;

procedure TfrmDBSummOpt.bbDelSummClick(Sender: TObject);
begin
  if lbSumm.ItemIndex=-1 then Exit;
  lbSumm.Items.Delete(lbSumm.ItemIndex);
end;

procedure TfrmDBSummOpt.bbUp1Click(Sender: TObject);
begin
  if lbSumm.ItemIndex<1 then Exit;
  lbSumm.Items.Move(lbSumm.ItemIndex,lbSumm.ItemIndex-1);
end;

procedure TfrmDBSummOpt.InitView;
var S:string;
    ei:TExtraItem;
    I,J:Integer;
    sa:TStringArray;
begin
  //monts
  //кто есть
  for I:=0 to FMonts.Count-1 do begin
    S:=FMonts[I] + ' - ';
    ei:=Options.gExtraCols.ByShortName[FMonts[I]];
    if ei<>nil then S:=S+ei.LongName
    else begin
      S:=S+'column deleted';
    end;
    clb.Checked[clb.Items.Add(S)]:=ei<>nil;
  end;
  //кого нет - unchecked
  sa:=Options.sCols.Split([',']);
  for I:=0 to High(sa) do begin
    ei:=Options.gExtraCols.ByShortName[sa[I]];
    if FMonts.IndexOf(ei.ShortName)=-1 then begin
      S:=ei.ShortName+' - ' + ei.LongName;
      clb.Checked[clb.Items.Add(S)]:=False;
    end;
  end;
  //summary
  lbSumm.Items.AddStrings(FSummary);
end;

end.

