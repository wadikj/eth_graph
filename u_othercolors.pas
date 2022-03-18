unit u_othercolors;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, CheckLst, StdCtrls;

type

  { TfrmEditOther }

  TfrmEditOther = class(TForm)
    btSaveGlobal: TButton;
    btClose: TButton;
    btSaveLoc: TButton;
    cbVihColor: TColorButton;
    cbSmcolor: TColorButton;
    clbMans: TCheckListBox;
    Label1: TLabel;
    procedure btSaveGlobalClick(Sender: TObject);
    procedure btSaveLocClick(Sender: TObject);
  private
    FLocflSMData:boolean;
    procedure Init;
    procedure SaveData(Global:Boolean);
    function CheckList:string;
  public

  end;

var
  frmEditOther: TfrmEditOther;


procedure EditOtherColors;

implementation

uses u_options, s_tools, eth_tbl;

procedure EditOtherColors;
begin
  {редактирование остальных цветов раскраски
  список четных людей берем
  1. смотрим тек открытый график
  2. если его нет, то смотрим глобально
  если там нет ничего, то четные смны пустые.
  после редактирования пихаем их туда, откуда взяли


  сами чет смены храним непосредственно в графике.
  если при открытии или создании графика них нет, то подльзуемся глобальными
  и при сохранении их пихаем в график из глобальных
  }

  Application.CreateForm(TfrmEditOther,frmEditOther);
  frmEditOther.Init;
  frmEditOther.ShowModal;
  FreeAndNil(frmEditOther);
end;

{$R *.lfm}

{ TfrmEditOther }

procedure TfrmEditOther.btSaveGlobalClick(Sender: TObject);
begin
  SaveData(True);
end;

procedure TfrmEditOther.btSaveLocClick(Sender: TObject);
begin
  SaveData(False);
end;

procedure TfrmEditOther.Init;
var S:string;
    I:Integer;
begin
  cbVihColor.ButtonColor:=Options.gColVih;
  cbSmcolor.ButtonColor:=Options.gColSM;
  FLocflSMData:=False;

  //смотрим, откуда брать список людей со сменами
  //1.opened graph
  clbMans.Items.Clear;
  if frmTable.GraphData<>nil then begin
    frmTable.GraphData.GetManList(clbMans.Items);
    if clbMans.Items.Count>0 then begin
      FLocflSMData:=True;
      Label1.Caption:=Label1.Caption+'(тек. график)';
      S:=frmTable.GraphData.SMInfo;
      while S<>'' do begin
        I:=StrToInt(DivStr(S));
        if I<clbMans.Count then
          clbMans.Checked[I]:=True;
      end;
      Exit;
    end;

  end else begin
    //2.glodal
    btSaveLoc.Visible:=False;
    clbMans.Items.Assign(Options.FWorkerList);
    if clbMans.Items.Count>0 then begin
      FLocflSMData:=False;
      Label1.Caption:=Label1.Caption+'(глобально)';
      S:=Options.gTSSM;
      while S<>'' do begin
        I:=StrToInt(DivStr(S));
        if I<clbMans.Count then
          clbMans.Checked[I]:=True;
      end;
      Exit;
    end;
  end;
end;

procedure TfrmEditOther.SaveData(Global: Boolean);
begin
  Options.gColVih:=cbVihColor.ButtonColor;
  Options.gColSM:=cbSmcolor.ButtonColor;
  if clbMans.Count=0 then Exit;
  if not Global then begin
    frmTable.GraphData.SMInfo:=CheckList;
  end else begin
    Options.gTSSM:=CheckList;
  end;
end;

function TfrmEditOther.CheckList: string;
var I:integer;
begin
  Result:='';
  for I:=0 to  clbMans.Count-1 do
    if clbMans.Checked[I] then
      Result:=StrListAdd(Result,IntToStr(I));
end;

end.

