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
    procedure FormCreate(Sender: TObject);
  private

  public

  end;

procedure ShowMemo(AData,ACaption:string);
var
  frmMemo: TfrmMemo;

implementation

uses u_options;

const props = 'Left,Top,Width,Height';

procedure ShowMemo(AData, ACaption: string);
begin
  Application.CreateForm(TfrmMemo,frmMemo);
  frmMemo.Caption:=ACaption;
  frmMemo.Memo1.Lines.Text:=AData;
  frmMemo.Show;
end;

{$R *.lfm}

{ TfrmMemo }

procedure TfrmMemo.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  Options.SaveComponent(props,Self);
  CloseAction:=caFree;
end;

procedure TfrmMemo.FormCreate(Sender: TObject);
begin
  Options.LoadComponent(props,Self);
end;

end.

