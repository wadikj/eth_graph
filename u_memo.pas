unit u_memo;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls;

type

  { TfrmMemo }

  TfrmMemo = class(TForm)
    Memo1: TMemo;
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormDestroy(Sender: TObject);
  private

  public

  end;

procedure ShowMemo(AData,ACaption:string);
procedure Log(S:string);

var
  frmMemo: TfrmMemo;

implementation

uses u_options, u_ScrProps;

const props = 'Left,Top,Width,Height';

var frmLog:TfrmMemo = nil;

function GetMemoForm(ACaption:string):TfrmMemo;
var I:Integer;
begin
  Result:=nil;
  for I:=0 to Screen.FormCount-1 do begin
    if (Screen.Forms[I] is TfrmMemo)and(Screen.Forms[I].Caption = ACaption) then begin
      Result:=(Screen.Forms[I]) as TfrmMemo;
      Break;
    end;
  end;
end;

procedure ShowMemo(AData, ACaption: string);
begin
  frmMemo:=GetMemoForm(ACaption);
  if frmMemo=nil then begin
    Application.CreateForm(TfrmMemo,frmMemo);
    frmMemo.Caption:=ACaption;
    Options.LoadComponent(props,frmMemo);
  end;
  frmMemo.Memo1.Lines.Text:=AData;
  frmMemo.Show;
end;

procedure Log(S: string);
begin
  if not Options.ShowLog then Exit;
  if frmLog=nil then begin
    Application.CreateForm(TfrmMemo,frmLog);
    frmLog.Name:='Log';
    frmLog.Caption:='Log';
    Options.LoadComponent(props,frmLog);
    frmLog.Show;
  end;
  frmLog.Memo1.Lines.Add(S);
end;

{$R *.lfm}

{ TfrmMemo }

procedure TfrmMemo.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  Options.SaveComponent(props,Self);
  if Name='Log' then
    CloseAction:=caHide
  else
    CloseAction:=caFree;
end;

procedure TfrmMemo.FormDestroy(Sender: TObject);
begin
  Options.SaveComponent(props,Self);
end;

end.

