unit u_othergrids;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, Spin,
  ExtCtrls;

type

  { TfrmGridOpts }

  TfrmGridOpts = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    fd: TFontDialog;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    lbFontName: TLabel;
    Panel1: TPanel;
    seRowHeight: TSpinEdit;
    seColWidth: TSpinEdit;
    seFirstWidth: TSpinEdit;
    seFontSize: TSpinEdit;
    procedure Button3Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure seFontSizeChange(Sender: TObject);
  private
    procedure InitView;
    procedure SaveForm;
  public

  end;

var
  frmGridOpts: TfrmGridOpts;

function  EditOtherGrigOpts:boolean;

implementation

uses u_options;

function EditOtherGrigOpts: boolean;
begin
  Result:=False;
  Application.CreateForm(TfrmGridOpts,frmGridOpts);
  frmGridOpts.InitView;
  if frmGridOpts.ShowModal=mrOK then begin
    frmGridOpts.SaveForm;
    Result:=True;
  end;
  FreeAndNil(frmGridOpts);
end;

{$R *.lfm}

{ TfrmGridOpts }

procedure TfrmGridOpts.FormClose(Sender: TObject; var CloseAction: TCloseAction
  );
begin
  CloseAction:=caHide;
end;

procedure TfrmGridOpts.seFontSizeChange(Sender: TObject);
begin
  Panel1.Font.Size:=seFontSize.Value;
end;

procedure TfrmGridOpts.Button3Click(Sender: TObject);
begin
  fd.Font.Name:=Panel1.Font.Name;
  fd.Font.Size:=Panel1.Font.Size;
  if fd.Execute then begin
    lbFontName.Caption:=fd.Font.Name;
    seFontSize.Value:=fd.Font.Size;
    Panel1.Font:=fd.Font;
  end;
end;

procedure TfrmGridOpts.InitView;
begin
  seRowHeight.Value:=Options.gDefRowHeight;
  seColWidth.Value:=Options.gDefColWidth;
  seFirstWidth.Value:=Options.gFirstCol;
  seFontSize.Value:=Options.gFontSize;
  lbFontName.Caption:=Options.gFontName;
  Panel1.Font.Name:=Options.gFontName;
  Panel1.Font.Size:=Options.gFontSize;
end;

procedure TfrmGridOpts.SaveForm;
begin
  Options.gFontName:=Panel1.Font.Name;
  Options.gFontSize:=Panel1.Font.Size;
  Options.gFirstCol:=seFirstWidth.Value;
  Options.gDefColWidth:=seColWidth.Value;
  Options.gDefRowHeight:=seRowHeight.Value;
end;

end.

