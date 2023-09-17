unit u_makediffs;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ComCtrls, StdCtrls, process;

type

  { TfrmPasteEK }

  TfrmPasteEK = class(TForm)
    cbScr: TComboBox;
    ImageList1: TImageList;
    Memo1: TMemo;
    ToolBar1: TToolBar;
    tbRun: TToolButton;
    ToolButton2: TToolButton;
    ToolButton3: TToolButton;
    tbProps: TToolButton;
    procedure cbScrSelect(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure tbRunClick(Sender: TObject);
    procedure tbPropsClick(Sender: TObject);
  private
    procedure InitScrCombo;
  public

  end;

var
  frmPasteEK: TfrmPasteEK;

procedure MakeDiffs;

function RunCommandIndir1(const curdir:TProcessString;const exename:TProcessString;const commands:array of TProcessString;out outputstring:string; out ErrorString:string; Options : TProcessOptions = [];SWOptions:TShowWindowOptions=swoNone):boolean;

implementation

uses eth_tbl, gdata, u_memo, LConvEncoding, u_options, u_ScrProps;

procedure MakeDiffs;
begin
  Application.CreateForm(TfrmPasteEK, frmPasteEK);
  frmPasteEK.InitScrCombo;
  frmPasteEK.Show;
end;

{$R *.lfm}

function RunCommandIndir1(const curdir:TProcessString;const exename:TProcessString;const commands:array of TProcessString;out outputstring:string; out ErrorString:string; Options : TProcessOptions = [];SWOptions:TShowWindowOptions=swoNone):boolean;
Var
    p : TProcess;
    i,
    exitstatus : integer;
begin
  p:=DefaultTProcess.create(nil);
  if Options<>[] then
    P.Options:=Options;
  P.ShowWindow:=SwOptions;
  p.Executable:=exename;
  if curdir<>'' then
    p.CurrentDirectory:=curdir;
  if high(commands)>=0 then
   for i:=low(commands) to high(commands) do
     p.Parameters.add(commands[i]);
  try
    result:=p.RunCommandLoop(outputstring,errorstring,exitstatus)=0;
  finally
    p.free;
  end;
  if exitstatus<>0 then result:=false;
end;


{ TfrmPasteEK }

procedure TfrmPasteEK.tbRunClick(Sender: TObject);
var SL:TStrings;
    sname:string;
    S2,S3:string;
    r:boolean;
    CPath,PyPath: string;
begin
  if not frmTable.Data.Loaded then begin
    ShowMessage('Hеобходимо открыть график!!!');
    Exit;
  end;
  CPath:=Options.ScrDir;
  PyPath:=Options.PyPath;
  SL:=frmTable.Data.SaveToStrings;
  SL.SaveToFile(CPath+'\'+'fmyfile');
  Memo1.Lines.SaveToFile(CPath+'\'+'fkfile');
  sname:=Options.Scripts[cbScr.ItemIndex].FileName;
  //sname:=CPath+'\'+sname;

  r:=RunCommandIndir1(CPath, PyPath, [sname], S2, S3, [poStderrToOutPut]);
  if r then begin
    ShowMemo(cp1251toutf8(S2+S3),{'Дифф'}Options.Scripts[cbScr.ItemIndex].Name);
  end else begin
    ShowMemo(cp1251toutf8(S2+S3),Options.Scripts[cbScr.ItemIndex].Name+' - Ошибка выполнения скрипта!!!');
  end;
end;

procedure TfrmPasteEK.tbPropsClick(Sender: TObject);
begin
  if ScrProperties then
   InitScrCombo;
end;

procedure TfrmPasteEK.InitScrCombo;
var I:Integer;
begin
  cbScr.Items.Clear;
  for I:=0 to Options.Scripts.Count-1 do begin
    cbScr.Items.Add(Options.Scripts[I].Name);
  end;
  if cbScr.Items.Count<>0 then
    cbScr.ItemIndex:=0;
end;

procedure TfrmPasteEK.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  CloseAction:=caFree;
end;

procedure TfrmPasteEK.cbScrSelect(Sender: TObject);
begin
  cbScr.Hint:=Options.Scripts[cbScr.ItemIndex].Hint;
end;

end.

