unit u_gridprops;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, Grids,
  StdCtrls, ExtCtrls, u_options;

type


  { TfrmGrprops }

  TfrmGrprops = class(TForm)
    btSet: TButton;
    btClose: TButton;
    cbBold: TCheckBox;
    cbUnderline: TCheckBox;
    cbStrikeOut: TCheckBox;
    cbItalic: TCheckBox;
    cbBackColor: TColorButton;
    cbFontColor: TColorButton;
    leTxt: TLabeledEdit;
    sg: TStringGrid;
    procedure btSetClick(Sender: TObject);
    procedure sgPrepareCanvas(Sender: TObject; aCol, aRow: Integer;
      aState: TGridDrawState);
    procedure sgSelection(Sender: TObject; aCol, aRow: Integer);
  private

  public
    procedure InitForm;
  end;

var
  frmGrprops: TfrmGrprops;


procedure SetDayColors;


implementation

procedure SetDayColors;
begin
  Application.CreateForm(TfrmGrprops,frmGrprops);
  frmGrprops.InitForm;
  frmGrprops.ShowModal;
  FreeAndNil(frmGrprops);
end;

{$R *.lfm}

{ TfrmGrprops }

procedure TfrmGrprops.sgPrepareCanvas(Sender: TObject; aCol, aRow: Integer;
  aState: TGridDrawState);
var dt:TDayType;
    I:Integer;
begin
  if aCol=0 then Exit;
  if aRow=0 then Exit;
  I:=aRow-1;
  if I>Integer(High(TDayType)) then Exit;
  dt:=TDayType(I);
  sg.Canvas.Brush.Color:=Options.FDayStyles[dt].FBackColor;
  sg.Canvas.Font.Color:=Options.FDayStyles[dt].FFontColor;
  sg.Canvas.Font.Style:=Options.FDayStyles[dt].FFontFlags;
end;

procedure TfrmGrprops.btSetClick(Sender: TObject);
var dt:TDayType;
    I,ACol,aRow:Integer;
    fs:TFontStyles;
begin
  acol:=sg.SelectedRange[0].Left;
  aRow:=sg.SelectedRange[0].Top;;
  if aCol=0 then Exit;
  if aRow=0 then Exit;
  I:=aRow-1;
  if I>Integer(High(TDayType)) then Exit;
  dt:=TDayType(I);

  Options.FDayStyles[dt].FBackColor:=cbBackColor.ButtonColor;
  Options.FDayStyles[dt].FFontColor:=cbFontColor.ButtonColor;

  fs:=[];
  if cbBold.Checked then fs:=fs+[fsBold];
  if cbItalic.Checked then fs:=fs+[fsItalic];
  if cbStrikeOut.Checked then fs:=fs+[fsStrikeOut];
  if cbUnderline.Checked then fs:=fs+[fsUnderline];

  Options.FDayStyles[dt].FFontFlags:=fs;
  Options.FDayStyles[dt].FTypeStr:=leTxt.Text;
end;

procedure TfrmGrprops.sgSelection(Sender: TObject; aCol, aRow: Integer);
var dt:TDayType;
    I:Integer;
begin
  if (aCol=0) or (aRow=0) then Exit;
  I:=aRow-1;
  if I>Integer(High(TDayType)) then Exit;
  dt:=TDayType(I);
  cbBackColor.ButtonColor:=Options.FDayStyles[dt].FBackColor;
  cbFontColor.ButtonColor:=Options.FDayStyles[dt].FFontColor;
  cbBold.Checked:=fsBold in Options.FDayStyles[dt].FFontFlags;
  cbItalic.Checked:=fsItalic in Options.FDayStyles[dt].FFontFlags;
  cbUnderline.Checked:=fsUnderline in Options.FDayStyles[dt].FFontFlags;
  cbStrikeOut.Checked:=fsStrikeOut in Options.FDayStyles[dt].FFontFlags;
  leTxt.Text:=Options.FDayStyles[dt].FTypeStr;
end;

procedure TfrmGrprops.InitForm;
var  I:TDayType;
begin
  sg.RowCount:=2+Integer(High(TDayType));
  sg.Cells[0,0]:='Название';
  sg.Cells[1,0]:='Образец';
  for I:=Low(TDayType) to High(TDayType) do begin
    sg.Cells[0,Integer(I)+1]:=TypeText[I];
    sg.Cells[1,Integer(I)+1]:=StrTypes[i];
  end;
  sg.DefaultRowHeight:=Options.gDefRowHeight;
  sgSelection(self, 1, 1);
end;

end.

