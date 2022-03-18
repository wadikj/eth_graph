unit u_openXL;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, Buttons, ComObj;

type

  { TfrmSelExcelDoc }

  TfrmSelExcelDoc = class(TForm)
    btLoadIntGraph: TButton;
    btLoadIntGraph1: TButton;
    btLoadIntGraph2: TButton;
    btLoadIntGraph3: TButton;
    btLoadIntGraph4: TButton;
    Label3: TLabel;
    lb: TListBox;
    procedure btLoadIntGraph1Click(Sender: TObject);
    procedure btLoadIntGraph2Click(Sender: TObject);
    procedure btLoadIntGraph4Click(Sender: TObject);
    procedure btLoadIntGraphClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
  private
    FXL:OleVariant;
    FWB:OleVariant;
    FDocName:String;
  public
    procedure Init;
    procedure UpdateList;
    procedure GetSelected;

  end;

var
  frmSelExcelDoc: TfrmSelExcelDoc;


function SelExcelDoc(out DocName:string):OleVariant;

implementation

uses u_openFF;

function SelExcelDoc(out DocName: string): OleVariant;
begin
  Application.CreateForm(TfrmSelExcelDoc,frmSelExcelDoc);
  Result:=Null;
  frmSelExcelDoc.Init;
  if frmSelExcelDoc.ShowModal=mrOk then begin
    Result:=frmSelExcelDoc.FWB;
    DocName:=frmSelExcelDoc.FDocName;
  end;
  frmSelExcelDoc.FXL:=Null;
  frmSelExcelDoc.FWB:=Null;
  FreeAndNil(frmSelExcelDoc);
end;

{$R *.lfm}

{ TfrmSelExcelDoc }

procedure TfrmSelExcelDoc.FormCreate(Sender: TObject);
begin
  FXL:=Null;
  FWB:=Null;
end;

procedure TfrmSelExcelDoc.btLoadIntGraph4Click(Sender: TObject);
begin
  UpdateList;
end;

procedure TfrmSelExcelDoc.btLoadIntGraph1Click(Sender: TObject);
begin
  OpenFileFolder(True);
  UpdateList;
end;

procedure TfrmSelExcelDoc.btLoadIntGraph2Click(Sender: TObject);
begin
  GetSelected;
  if FXL<>Null then ModalResult:=mrOK;
end;

procedure TfrmSelExcelDoc.btLoadIntGraphClick(Sender: TObject);
begin
  OpenFileFolder(False);
end;

procedure TfrmSelExcelDoc.FormClose(Sender: TObject;
  var CloseAction: TCloseAction);
begin
  CloseAction:=caHide;
end;

procedure TfrmSelExcelDoc.Init;
begin
  UpdateList;
end;

procedure TfrmSelExcelDoc.UpdateList;
var
  I: Integer;
begin
  try
    FXL:=GetActiveOleObject('Excel.Application');
  except
    FXL:=Null;
  end;
  if FXL=Null then begin
    //ShowMessage('Нет открытых вокументов Excel!!!');
    Exit;
  end;
  lb.Clear;
  for I:=1 to FXL.WorkBooks.Count do begin
    lb.Items.Add(FXL.WorkBooks.Item[I].FullName);
   end;
end;

procedure TfrmSelExcelDoc.GetSelected;
begin
  if lb.ItemIndex<0 then Exit;
  FWB:=FXL.WorkBooks.Item[lb.ItemIndex+1];
  FDocName:=lb.Items[lb.ItemIndex];
end;

end.

