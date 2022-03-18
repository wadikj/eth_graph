unit u_timeints;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ExtCtrls, ComCtrls, u_options;

type

  { TfrmHours }

  TfrmHours = class(TForm)
    btDelTimes: TButton;
    btSetNonTimes: TButton;
    btSetTimes: TButton;
    btClose: TButton;
    cbUse: TCheckBox;
    Label1: TLabel;
    leText: TLabeledEdit;
    leHours: TLabeledEdit;
    leTimes: TLabeledEdit;
    lbTypes: TListBox;
    lvTimes: TListView;
    PageControl1: TPageControl;
    tsNonTimes: TTabSheet;
    tsTimes: TTabSheet;
    procedure btCloseClick(Sender: TObject);
    procedure btDelTimesClick(Sender: TObject);
    procedure btSetNonTimesClick(Sender: TObject);
    procedure btSetTimesClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure lbTypesSelectionChange(Sender: TObject; User: boolean);
    procedure lvTimesSelectItem(Sender: TObject; Item: TListItem;
      Selected: Boolean);
  private
    //
    FPrevType:Integer;
    function FindItem(AText:string):TListItem;
  public
    procedure Init;
    procedure ShowType(AType:TDayType);
    procedure SaveType;
  end;

var
  frmHours: TfrmHours;

procedure EditTimes;

implementation

procedure EditTimes;
begin
  Application.CreateForm(TfrmHours,frmHours);
  frmHours.Init;
  frmHours.ShowModal;
end;

{$R *.lfm}

{ TfrmHours }

procedure TfrmHours.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  CloseAction:=caFree;
end;

procedure TfrmHours.lbTypesSelectionChange(Sender: TObject; User: boolean);
begin
  //change selection - save surrent list
  SaveType;
  //view selected item
  FPrevType:=lbTypes.ItemIndex;
  ShowType(TDayType(PtrInt(lbTypes.Items.Objects[FPrevType])));
end;

procedure TfrmHours.lvTimesSelectItem(Sender: TObject; Item: TListItem;
  Selected: Boolean);
begin
  if Selected=False then Exit;
  leHours.Text:=Item.Caption;
  leTimes.Text:=Item.SubItems[0];
end;

function TfrmHours.FindItem(AText: string): TListItem;
var I:Integer;
begin
  Result:=nil;
  for I:=0 to lvTimes.Items.Count-1 do begin
    if AText=lvTimes.Items[I].Caption then begin
      Result:=lvTimes.Items[I];
      Break;
    end;
  end;
end;

procedure TfrmHours.btDelTimesClick(Sender: TObject);
begin
  if lvTimes.ItemIndex=-1 then Exit;
  lvTimes.Items.Delete(lvTimes.ItemIndex);
  leHours.Text:='';
  leTimes.Text:='';
end;

procedure TfrmHours.btSetNonTimesClick(Sender: TObject);
var dt:TDayType;
begin
  dt:=TDayType(FPrevType);
  Options.xTextOnly[dt].Use:=cbUse.Checked;
  Options.xTextOnly[dt].Txt:=leText.Text;
end;

procedure TfrmHours.btCloseClick(Sender: TObject);
begin
  SaveType;
  ModalResult:=mrClose;
end;

procedure TfrmHours.btSetTimesClick(Sender: TObject);
var li:TListItem;
begin
  li:=FindItem(leHours.Text);
  if li=nil then begin
    li:=lvTimes.Items.Add;
    li.Caption:=leHours.Text;
    li.SubItems.Add(leTimes.Text);
    li.Selected:=True;
  end else
    li.SubItems[0]:=leTimes.Text;
end;

procedure TfrmHours.Init;
var dt:TDayType;
begin
  FPrevType:=-1;
  for dt:=Low(TDayType) to High(TDayType) do begin
    if Options.TypeNames[dt]<>'' then
      lbTypes.Items.AddObject(TypeText[dt],TObject(PtrInt(dt)));;
  end;
  lbTypes.ItemIndex:=0;
end;

procedure TfrmHours.ShowType(AType: TDayType);
var I:Integer;
    li:TListItem;
begin
  lvTimes.Items.BeginUpdate;
  try
    lvTimes.Clear;
    for I:=0 to Options.FWorkHours[AType].Count-1 do begin
      li:=lvTimes.Items.Add;
      li.Caption:=Options.FWorkHours[AType].Keys[I];
      li.SubItems.Add(Options.FWorkHours[AType].Data[I]);
    end;
  finally
    lvTimes.Items.EndUpdate;
  end;
  if lvTimes.Items.Count=0 then begin
    leHours.Text:='';
    leTimes.Text:='';
  end else begin
    lvTimes.ItemIndex:=0;
  end;
  //untimed
  cbUse.Checked:=Options.xTextOnly[AType].Use;
  leText.Text:=Options.xTextOnly[AType].Txt;
end;

procedure TfrmHours.SaveType;
var I:integer;
    dt:TDayType;
    H,T:string;
begin
  if FPrevType=-1 then Exit;
  dt:=TDayType(PtrInt(lbTypes.Items.Objects[FPrevType]));
  Options.FWorkHours[dt].Clear;
  for I:=0 to lvTimes.Items.Count-1 do begin
    H:=lvTimes.Items[I].Caption;
    T:=lvTimes.Items[I].SubItems[0];
    Options.FWorkHours[dt].AddOrSetData(Trim(H),T);
  end;
end;

end.

