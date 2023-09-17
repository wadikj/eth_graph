unit u_absenses;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ComCtrls, StdCtrls,
  Menus, windows;

type

  { TfrmAbs }

  TfrmAbs = class(TForm)
    ImageList1: TImageList;
    lv: TListView;
    StaticText1: TStaticText;
    ToolBar1: TToolBar;
    tbAddAbs: TToolButton;
    tbDelAbs: TToolButton;
    tbEditAbs: TToolButton;
    ToolButton1: TToolButton;
    tbDates: TToolButton;
    ToolButton3: TToolButton;
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure tbAddAbsClick(Sender: TObject);
    procedure tbDelAbsClick(Sender: TObject);
    procedure tbEditAbsClick(Sender: TObject);
    procedure tbDatesClick(Sender: TObject);
  private
    FDateFirst,
    FDateLast:TDate;
    FSortField: string;
    function GetSizes: string;
    procedure SetSizes(AValue: string);
    procedure ViewData;
    procedure UpdateView;
    procedure UpdateST;
  public

  published
    property CSizes:string read GetSizes write SetSizes;
    property DateFirst:TDate read FDateFirst write FDateFirst;
    property DateLast:TDate read FDateLast write FDateLast;
    property SortField:string read FSortField write FSortField;
  end;

var
  frmAbs: TfrmAbs = nil;

procedure ShowAbsenses;

implementation

uses u_data, u_options, u_edabs, u_absInt, s_tools, sqldb, DateUtils;

const SavedProps = 'Left,Top,Width,Height,CSizes,DateLast,DateFirst,SortField';

procedure ShowAbsenses;
begin
  if not Assigned(frmAbs) then begin
    Application.CreateForm(TfrmAbs,frmAbs);
    frmAbs.UpdateST;
    frmAbs.ViewData;
  end;
  frmAbs.Show;
end;

{$R *.lfm}

{ TfrmAbs }

procedure TfrmAbs.tbAddAbsClick(Sender: TObject);
begin
  if EditAbs() then
    UpdateView;
end;

procedure TfrmAbs.FormCreate(Sender: TObject);
begin
  frmAbs.FDateFirst:=StrToDate('01.01.2023');
  frmAbs.FDateLast:=StrToDate('31.12.2023');
  frmAbs.FSortField:='adate';
  Options.LoadComponent(SavedProps,Self);
end;

procedure TfrmAbs.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  Options.SaveComponent(SavedProps,Self);
  CloseAction:=caFree;
  frmAbs:=nil;
end;

procedure TfrmAbs.tbDelAbsClick(Sender: TObject);
var I:Integer;
    SQL: string;
begin
  if lv.ItemIndex=-1 then Exit;
  I:=StrToInt(lv.Items[lv.ItemIndex].Caption);
  if Application.MessageBox(PChar('Удалить строку с ИД '+IntToStr(I)+'?'), 'ETH_Graph',
    MB_YESNO+MB_ICONWARNING) <> IDYES  then Exit;
  SQL:='delete from absenses where aid = '+IntToStr(I);
  DM.ExecSQL(SQL);
  UpdateView;
end;

procedure TfrmAbs.tbEditAbsClick(Sender: TObject);
var I:Integer;
begin
  if lv.ItemIndex=-1 then Exit;
  I:=StrToInt(lv.Items[lv.ItemIndex].Caption);
  if EditAbs(I) then
    UpdateView;
end;

procedure TfrmAbs.tbDatesClick(Sender: TObject);
begin
  if SelectAbsInt(FDateFirst,FDateLast, FSortField) then begin
    UpdateView;
    UpdateST;
  end;
end;

procedure TfrmAbs.ViewData;
var DS:TSQLQuery;
    li:TListItem;
    SQL: string;
    df,dl:TDate;
    L:Integer;
begin
  SQL:='select aid, wname,  adate, alen, atype, a.wid, ainfo '+
    'from absenses a join workers w on a.wid = w.wid '+
    'where adate between ''%s'' and ''%s'' order by %s';
  SQL:=SQL.Format([DM._dts(IncDay(FDateFirst,-31)), DM._dts(FDateLast), FSortField]);
  DS:=DM.GetDS(SQL);
  while not DS.EOF do begin
    //проверяем руками
    df:=DM._std(DS.Fields[2].AsString);
    L:=DS.Fields[3].AsInteger;
    dl:=IncDay(df, L-1);
    if dl<FDateFirst then begin
      DS.Next;
      Continue;
    end;
    li:=lv.Items.Add;
    li.Caption:=DS.Fields[0].AsString;           //id
    li.SubItems.Add(DS.Fields[1].AsString);      //worker
    li.SubItems.Add(DateToStr(df));              //start
    li.SubItems.Add(DateToStr(dl));              //end
    li.SubItems.Add(IntToStr(L));                //len
    li.SubItems.Add(TypeText[TDayType(DS.Fields[4].AsInteger)]);//type
    li.SubItems.Add(DS.Fields[6].AsString);       //comment
    DS.Next;
  end;
  DM.CloseDS(DS);
end;

function TfrmAbs.GetSizes: string;
var I:Integer;
begin
  Result:='';
  for I:=0 to lv.Columns.Count-1 do
    Result:=StrListAdd(Result,IntToStr(lv.Column[I].Width));
end;

procedure TfrmAbs.SetSizes(AValue: string);
var A:TStringArray;
    I:Integer;
begin
  A:=AValue.Split([',']);
  try
    for I:=0 to lv.Columns.Count-1 do
      lv.Column[I].Width:=A[I].ToInteger;
  except
    ShowMessage('Col count and saved items count is different. Please reload programm');
  end;
end;

procedure TfrmAbs.UpdateView;
var I:Integer;
begin
  I:=lv.ItemIndex;
  try
    lv.BeginUpdate;
    lv.Clear;
    ViewData;
    if (I<lv.Items.Count) and (I>=0) then
      lv.ItemIndex:=I;
  finally
    lv.EndUpdate;
  end;
end;

procedure TfrmAbs.UpdateST;
begin
  StaticText1.Caption:=DateToStr(FDateFirst)+' - '+DateToStr(FDateLast);
end;

end.

