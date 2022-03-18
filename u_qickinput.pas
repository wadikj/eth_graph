unit u_QickInput;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ActnList,
  Buttons, ExtCtrls;

type

  { TfrmQuickInput }

  TfrmQuickInput = class(TForm)
    ActionList1: TActionList;
    Button1: TButton;
    fp: TFlowPanel;
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    FBHeight: Integer;
    FBTop:Integer;
  public
    procedure ClearButtons;
    procedure AddButton(AText:string;AAction:TAction);
    procedure DoBtnClick(Sender:TObject);
  published
    property BHeight:Integer read FBHeight write FBHeight;

  end;

var
  frmQuickInput: TfrmQuickInput;

implementation

uses u_options, eth_tbl;

{$R *.lfm}

{ TfrmQuickInput }

procedure TfrmQuickInput.FormCreate(Sender: TObject);
begin
  FBHeight:=30;
  Options.LoadComponent('Left,Top,Font.Name,Font.Size,BHeight,Width,Height',Self);
end;

procedure TfrmQuickInput.FormClose(Sender: TObject;
  var CloseAction: TCloseAction);
begin
  CloseAction:=caHide;
  frmTable.miQuick.Checked:=False;
end;

procedure TfrmQuickInput.FormDestroy(Sender: TObject);
begin
  Options.SaveComponent('Left,Top,Font.Name,Font.Size,BHeight,Width,Height',Self);
end;

procedure TfrmQuickInput.ClearButtons;
begin
  while fp.ControlCount<>0 do
    fp.Controls[0].Free;
  while ActionList1.ActionCount<>0 do
    ActionList1.Actions[0].Free;
  FBTop:=0;
end;

procedure TfrmQuickInput.AddButton(AText: string; AAction: TAction);
var B:TSpeedButton;
  ac:TAction;
begin
  B:=TSpeedButton.Create(Self);
  B.Parent:=fp;
  //B.Width:=ClientWidth;
  B.Left:=0;
  B.Height:=BHeight;
  B.Top:=FBTop;
  B.Anchors:=[akTop,akLeft,akRight];
  B.Action:=AAction;
  B.Caption:=AText;
  B.Width:=140;
  B.Tag:=AAction.Tag;
  B.OnClick:=@DoBtnClick;
  Inc(FBTop,B.Height);
  ac:=TAction.Create(Self);
  ac.ShortCut:=AAction.ShortCut;
  ac.OnExecute:=AAction.OnExecute;
  ac.ActionList:=ActionList1;
  ClientHeight:=b.Height+BHeight;
end;

procedure TfrmQuickInput.DoBtnClick(Sender: TObject);
begin
  (Sender as TSpeedButton).Action.Execute;
end;

end.

