unit eth_tbl;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, Grids, ExtCtrls,
  StdCtrls, Menus, ActnList, gdata, u_options, Types, LCLProc, ComCtrls;

type

  TDataProc = procedure (ACol, ARow:Integer) of object;


  { TfrmTable }

  TfrmTable = class(TForm)
    Action1: TAction;
    al: TActionList;
    ApplicationProperties1: TApplicationProperties;
    il: TImageList;
    Label2: TLabel;
    Label3: TLabel;
    MainMenu1: TMainMenu;
    MenuItem1: TMenuItem;
    MenuItem10: TMenuItem;
    MenuItem11: TMenuItem;
    MenuItem12: TMenuItem;
    MenuItem13: TMenuItem;
    MenuItem14: TMenuItem;
    MenuItem15: TMenuItem;
    MenuItem16: TMenuItem;
    miSummOpts: TMenuItem;
    miReadme: TMenuItem;
    miAbout: TMenuItem;
    N3: TMenuItem;
    miSumm: TMenuItem;
    N1: TMenuItem;
    miOtherHours: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem3: TMenuItem;
    MenuItem4: TMenuItem;
    MenuItem5: TMenuItem;
    MenuItem6: TMenuItem;
    MenuItem7: TMenuItem;
    MenuItem8: TMenuItem;
    MenuItem9: TMenuItem;
    miSetOnlyUnk: TMenuItem;
    miFile: TMenuItem;
    miOpen: TMenuItem;
    miNew: TMenuItem;
    miSave: TMenuItem;
    miSaveAs: TMenuItem;
    miExpotrNamed: TMenuItem;
    miExportSM: TMenuItem;
    miImport: TMenuItem;
    miExit: TMenuItem;
    miEdit: TMenuItem;
    miOptions: TMenuItem;
    miGridOptions: TMenuItem;
    miSetVih: TMenuItem;
    miView: TMenuItem;
    miAlwaysShowTypes: TMenuItem;
    miShowMP: TMenuItem;
    miExtraCols: TMenuItem;
    miExtraRows: TMenuItem;
    miQuick: TMenuItem;
    miSetDay: TMenuItem;
    miSetNight: TMenuItem;
    miAnyFlags: TMenuItem;
    miCheckTable1: TMenuItem;
    miCellColors: TMenuItem;
    miOtherColors: TMenuItem;
    miAddCols: TMenuItem;
    miAddRows: TMenuItem;
    miEditQInput: TMenuItem;
    miTypeHours: TMenuItem;
    miWorkerList: TMenuItem;
    miStartActions: TMenuItem;
    N6: TMenuItem;
    N5: TMenuItem;
    miMRUEnd: TMenuItem;
    miMRUStart: TMenuItem;
    N2: TMenuItem;
    OpenDialog1: TOpenDialog;
    pmHours: TPopupMenu;
    pmTypes: TPopupMenu;
    SaveDialog1: TSaveDialog;
    sg: TStringGrid;
    Splitter1: TSplitter;
    sb: TStatusBar;
    ToolBar1: TToolBar;
    ToolButton1: TToolButton;
    ToolButton10: TToolButton;
    ToolButton2: TToolButton;
    ToolButton3: TToolButton;
    tbText: TToolButton;
    ToolButton4: TToolButton;
    ToolButton5: TToolButton;
    tbType: TToolButton;
    tbSetTempl: TToolButton;
    ToolButton7: TToolButton;
    ToolButton8: TToolButton;
    ToolButton9: TToolButton;
    procedure ApplicationProperties1Hint(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure FormCreate(Sender: TObject);
    procedure miAboutClick(Sender: TObject);
    procedure miAnyFlagsClick(Sender: TObject);
    procedure miReadmeClick(Sender: TObject);
    procedure miSummClick(Sender: TObject);
    procedure miOtherHoursClick(Sender: TObject);
    procedure miExpotrNamedClick(Sender: TObject);
    procedure miExportSMClick(Sender: TObject);
    procedure miImportClick(Sender: TObject);
    procedure miExitClick(Sender: TObject);
    procedure miCellColorsClick(Sender: TObject);
    procedure miOtherColorsClick(Sender: TObject);
    procedure miSummOptsClick(Sender: TObject);
    procedure miTypeHoursClick(Sender: TObject);
    procedure miWorkerListClick(Sender: TObject);
    procedure miNewClick(Sender: TObject);
    procedure miEditQInputClick(Sender: TObject);
    procedure MenuItem3Click(Sender: TObject);
    procedure MenuItem4Click(Sender: TObject);
    procedure miGridOptsClick(Sender: TObject);
    procedure miEditExtraRowClick(Sender: TObject);
    procedure miEditExtraColClick(Sender: TObject);
    procedure miSetVihClick(Sender: TObject);
    procedure miOpenClick(Sender: TObject);
    procedure miQuickClick(Sender: TObject);
    procedure miAlwaysShowTypesClick(Sender: TObject);
    procedure miCheckTableClick(Sender: TObject);
    procedure miSaveAsClick(Sender: TObject);
    procedure miSaveClick(Sender: TObject);
    procedure miSetDayClick(Sender: TObject);
    procedure miSetNightClick(Sender: TObject);
    procedure miSetOnlyUnkClick(Sender: TObject);
    procedure miShowMPClick(Sender: TObject);
    procedure sgPrepareCanvas(sender: TObject; aCol, aRow: Integer;
      aState: TGridDrawState);
    procedure sgSelection(Sender: TObject; aCol, aRow: Integer);
    procedure tbSetTemplClick(Sender: TObject);
    procedure tbTextClick(Sender: TObject);
    procedure tbTypeClick(Sender: TObject);
  private
    FData:TGraphData;
    FExtraFixedCols: Integer;
    FExtraFixedRows: Integer;
    FSetFlagType:TDayType;
    FTemplText:string;
    FTemplType:TDayType;
    procedure SetCellType(ACol,ARow:Integer; AType:TDayType);
    procedure SetCellHours(ACol,ARow:Integer; AHours:string);
    procedure SetSelection(DataProc:TDataProc);//proc for set templates to selection
    procedure SetNight(ACol, ARow:Integer);
    procedure SetDay(ACol, ARow:Integer);//dataproc
    procedure SetAnyFlag(ACol, ARow:Integer);//dataproc
    procedure SetANyHours(ACol, ARow:Integer);//dataproc
    function CheckUnk(ACol, ARow:Integer):boolean;
    procedure DoSetFlag(Sender:TObject);//handler for set flag
    procedure DoSetHours(Sender:TObject);//handler for set hours
    //при изменении ячейки перерисовывает служебные клеточки
    procedure UpdateSpecCol(ARow:Integer);
    procedure UpdateSpecRow(ACol:Integer);

    procedure UpdateActionList;
    //обработчики событий действия, меню
    procedure DoExecAction(sender:TObject);
    procedure DoExtraRowsClick(Sender:TObject);
    procedure DoExtraColsClick(Sender:TObject);
    procedure DoMRUClick(Sender:TObject);
    function GetCellType(ACol,ARow:Integer):TDayItem;

    //menu handlers
    procedure NewGraph;
    procedure SaveGraph;
    procedure SaveAs;
    procedure LoadGraph(AFileName:string);
    procedure LoadMRU;
    procedure AddToMRU(AFileName:string);
    procedure UpdateFormCaption;
    procedure DoSelectHours(Sender:TObject);//handler of hours popup menu
    procedure DoSelectType(Sender:TObject); // handler of type popup menu
    procedure DoReadHoursType(Sender:TObject);//set hours and type from current cell to templates
    procedure UnlockCell(Sender:TObject);//handler to unlock cell (Locked->Unknow)
  public
    procedure View;
    procedure InitView;
    procedure UpdateData;
    procedure UpdateMenu;
    procedure UpdateDTMenu;
    procedure UpdateRect(ARect:TRect);//обновление только переданного прямоугольника
    property ExtraFixedCols:Integer read FExtraFixedCols write FExtraFixedCols;
    function ColToDay(ACol:Integer):Integer;
    function DayToCol(ADay:integer):Integer;
    function RowToWorker(ARow:Integer):Integer;
    function WorkerToRow(AWorker:Integer):Integer;
    property GraphData:TGraphData read FData;
    procedure CreateData(AMonth,AYear:Integer);

    function CheckOpenedGraph:boolean;
  end;


  //будет куча методов, поэтому класс
  //работаем сначала с графиком, а потом, по окончании, пихаем все в сетку

  { TCancelExecute }

  TCancelExecute = class (Exception);

  { TAEngine }

  TAEngine = class
    private
      FChangedCells:TRect;
      FWorked:TRect;//где у нас происходит работа, в координатах работников
      FForm:TfrmTable;
      FScr:string;
      FDefHours:string;
      FBreakOp:boolean;
      function GetHours(ATempl:string):string;
      function GetType(ATempl:string):TDayType;
      procedure UpdateChanges;//для всех обработанных ячеек вызывает обновление суммарных полей
      procedure AddPoint(AWorker,ADay:Integer);
      procedure PasteSequ(AWorker, ADayFirst, ADayLast:Integer; ASeq:string);
    public
      constructor Create(AForm:TfrmTable;AScr:string);
      destructor Destroy;override;
      procedure Exec;
  end;


procedure ExecAction(AForm:TfrmTable;AScr:string);

var
  frmTable: TfrmTable;

implementation

uses s_tools, u_editActions, u_QickInput, u_memo, u_gridprops, u_othercolors,
  u_edextra, u_othergrids, u_newgr, u_OldExport, U_newexpopts, impOpts,
  u_editManList, u_timeints, u_summ, u_about, u_editSumm, Windows;

procedure ExecAction(AForm: TfrmTable; AScr: string);
var E:TAEngine;
begin
  E:=TAEngine.Create(AForm,AScr);
  try
    E.Exec;
  except
    on E:Exception do ShowMessage(E.Message);
  end;
  E.Free;
end;

{$R *.lfm}

{ TAEngine }

function TAEngine.GetHours(ATempl: string): string;
var S:string;
begin
  //на входе  - шаблон или часы
  //на выходе - часы, возможно полученные из шаблона
  if ATempl='' then begin
    Result:='';
    Exit;
  end;
  case ATempl[1] of
    '?':begin
      if FDefHours<>'?' then Result:=FDefHours
      else begin
        S:='';
        if InputQuery('def cell hours','Input value',S) then begin
          FDefHours:=S;
          Result:=FDefHours;
        end else begin
          raise TCancelExecute.Create('Опреация прервана пользователем!!!');
          FBreakOp:=True;
        end;
      end;
    end;
    '$':begin
      Result:=FForm.FTemplText;
    end
    else Result:=ATempl;
  end;
end;

function TAEngine.GetType(ATempl: string): TDayType;
var DT:TDayType;
begin
  Result:=dtUnk;
  if IsNumber(ATempl) then Result:=TDayType(StrToInt(ATempl))
  else begin
    dt:=frmTable.FTemplType;
    //TDayType(frmTable.cbTemplType.ItemIndex);
    if (DT>High(TDayType))or(DT<Low(TDayType)) then begin
      DT:=dtUnk;
      ShowMessage('Error TDayType Value!!!');
    end;
    Result:=DT;
  end;
end;

procedure TAEngine.UpdateChanges;
begin
  if FChangedCells.Left=-1 then Exit;
  FForm.UpdateRect(FChangedCells);
  Exit;
end;

procedure TAEngine.AddPoint(AWorker, ADay: Integer);
begin
  if FChangedCells.Left=-1 then begin
    FChangedCells.Left:=ADay;
    FChangedCells.Right:=ADay;
    FChangedCells.Top:=AWorker;
    FChangedCells.Bottom:=AWorker;
    Exit;
  end;
  FChangedCells.Left:=Min(FChangedCells.Left,ADay);
  FChangedCells.Right:=Max(FChangedCells.Left,ADay);
  FChangedCells.Top:=Min(FChangedCells.Top,AWorker);
  FChangedCells.Bottom:=Max(FChangedCells.Bottom,AWorker);
end;

procedure TAEngine.PasteSequ(AWorker, ADayFirst, ADayLast: Integer; ASeq: string
  );
var I,Last:Integer; // последний день, до которого заполняем
    Seq:string;
    S,S1:string;
    Rep:boolean;
begin
  //тут пофиг, заполняем от начала до конца переданного участка укзанной последовательностью
  //чтобы было хорошо, если последовательность из несколькох клеточек, и у нас выделен 1 день
  // то цикл должен быть пока не закончится последовательность

  //если Last <1, то заполняем до конца сетки
  //вылет за количество дней не возможен
  Last:=ADayLast;
  Rep:=True;
  if ADayFirst=ADayLast then begin
    Rep:=False;
    Last:=FForm.FData.MonthDays
  end;
  if (Last<1)or(Last>FForm.FData.MonthDays) then Last:=FForm.FData.MonthDays;
  Seq:=ASeq;
  for I:=ADayFirst to Last do begin
    S:=DivStr(Seq,'|');
    S1:=DivStr(S,'!');
    if FForm.FData.GetCellInfo(AWorker,I).FType<>dtLocked then begin
      if not(Options.gSetOnlyUnk and (FForm.FData.GetCellInfo(AWorker,I).FType<>dtUnk)) then begin
        //FForm.FData.Items[AWorker].Days[I].FHours:=GetHours(S1);
        FForm.FData.SetCellHours(AWorker,I,GetHours(S1));
        //FForm.FData.Items[AWorker].Days[I].FType:=GetType(S);
        FForm.FData.SetCellDayType(AWorker,I,GetType(S));
        AddPoint(AWorker,I);
      end;
    end;
    if (Seq='') and (Rep) then Seq:=ASeq;
    if Seq='' then Break;
  end;
end;

constructor TAEngine.Create(AForm: TfrmTable; AScr: string);
begin
  FChangedCells.Left:=-1;
  FScr:=AScr;
  FForm:=AForm;
  FBreakOp:=False;
  FDefHours:='?';
end;

destructor TAEngine.Destroy;
begin
  inherited Destroy;
end;

procedure TAEngine.Exec;
var S,Seq, _Seq:string;
    AFirst, ALast:Integer;
    RCount,I:Integer;
    AWorker:Integer;
begin
  Seq:=FScr;
  S:=DivStr(Seq,':');
  if S='' then raise TCancelExecute.Create('Не указаа команда в операции!!!');
  //смотрим, что обрабатываем
  if S[1]='m' then begin
    ShowMessage(Seq);
    Exit;
  end;
  FWorked.Left:=FForm.ColToDay(FForm.sg.Selection.Left);
  FWorked.Right:=FForm.ColToDay(FForm.sg.Selection.Right);
  FWorked.Top:=FForm.RowToWorker(FForm.sg.Selection.Top);
  FWorked.Bottom:=FForm.RowToWorker(FForm.sg.Selection.Bottom);
  //тут обрабатываем f
  //повторения
  RCount:=1;
  S:=DivStr(Seq,':');
  if IsNumber(S) then RCount:=StrToInt(S)
  else begin
    S:=InputBox('Repeat Count','Input reoeat count','1');
    RCount:=StrToInt(S);
  end;
  AFirst:=FWorked.Left;
  ALast:=FWorked.Right;
  _Seq:=Seq;
  if AFirst=ALast then begin // у нас один день выделен
    if RCount=0 then begin
      ALast:=-1 // повторяем до конца месяца
    end else begin
      //ALast:=0;
      _Seq:='';
      for I:=0 to RCount-1 do
        _Seq:=StrListAdd(_Seq,Seq,'|');
    end;
  end else begin
    //тут просто в интервале заполняем
  end;
  for AWorker:=FWorked.Top to FWorked.Bottom do begin
    PasteSequ(AWorker,AFirst,ALast,_Seq);
  end;
  UpdateChanges;
end;

{ TfrmTable }

procedure TfrmTable.ApplicationProperties1Hint(Sender: TObject);
begin
  sb.SimpleText:=Application.Hint;
end;

procedure TfrmTable.FormCloseQuery(Sender: TObject; var CanClose: boolean);
begin
  if (FData<>nil) and (FData.Modified) then begin
    if Application.MessageBox('Текущий рафик изменен. Вы действительно хотите выйти из программы?',
      'Сохранение графика', MB_YESNO+MB_ICONWARNING)=mrNo then
        CanClose:=False;
  end;
end;

procedure TfrmTable.FormCreate(Sender: TObject);
var I: Integer;
begin
  FData:=nil;
  FExtraFixedCols:=0;
  FExtraFixedRows:=0;
  UpdateDTMenu;
  LoadMRU;
  Screen.HintFont.Size:=16;
  FTemplType:=dtUnk;
  tbType.Caption:='Не задано';
  FTemplText:='12';
  for I:=0 to pmHours.Items.Count-2 do begin
    pmHours.Items[I].OnClick:=@DoSelectHours;
  end;
end;

procedure TfrmTable.miAboutClick(Sender: TObject);
begin
  ShowAbout;
end;

procedure TfrmTable.miAnyFlagsClick(Sender: TObject);
begin

end;

procedure TfrmTable.miReadmeClick(Sender: TObject);
var S:string;
begin
  S:=ExtractFileDir(Application.ExeName)+'\readme.docx';
  if FileExists(S) then
    ShellExecuteW(0,'open',PWideChar(WideString(s)),nil,nil,SW_SHOW);
end;

procedure TfrmTable.miSummClick(Sender: TObject);
begin
  if GraphData=nil then begin
    ShowMessage('Нет открытого графика - работа '#13'с сумированным учетом невозможна!!!');
  end else begin
    frmSumm.Show;
  end;
end;

procedure TfrmTable.miOtherHoursClick(Sender: TObject);
var S:string;
begin
  S:='';
  if InputQuery('Eth_Graph', 'Введите текст для графика:', S) then begin
    FTemplText:=S;
    tbText.Caption:=S;
  end;
end;

procedure TfrmTable.miExpotrNamedClick(Sender: TObject);
begin
  if not CheckOpenedGraph then Exit;
  ExportNew;
end;

procedure TfrmTable.miExportSMClick(Sender: TObject);
begin
  if not CheckOpenedGraph then Exit;
  ExportOldXL;
end;

procedure TfrmTable.miImportClick(Sender: TObject);
begin
  ImportGraph;
end;

procedure TfrmTable.miExitClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmTable.miCellColorsClick(Sender: TObject);
begin
  SetDayColors;
  View;
end;

procedure TfrmTable.miOtherColorsClick(Sender: TObject);
begin
  EditOtherColors;
  sg.Invalidate;
end;

procedure TfrmTable.miSummOptsClick(Sender: TObject);
begin
  EditSummCols;
end;

procedure TfrmTable.miTypeHoursClick(Sender: TObject);
begin
  EditTimes;
end;

procedure TfrmTable.miWorkerListClick(Sender: TObject);
begin
  EditWorkers;
end;

procedure TfrmTable.miNewClick(Sender: TObject);
begin
  NewGraph;
end;

procedure TfrmTable.miEditQInputClick(Sender: TObject);
begin
  if EditActions then
    UpdateActionList;
end;

procedure TfrmTable.MenuItem3Click(Sender: TObject);
begin
  frmGrprops.InitForm;
  frmGrprops.Show;
  sg.Invalidate;
end;

procedure TfrmTable.MenuItem4Click(Sender: TObject);
begin
  EditOtherColors;
  View;
end;

procedure TfrmTable.miGridOptsClick(Sender: TObject);
begin
  if EditOtherGrigOpts then
    View;
end;

procedure TfrmTable.miEditExtraRowClick(Sender: TObject);
begin
  EditExtra(False);
  View;
end;

procedure TfrmTable.miEditExtraColClick(Sender: TObject);
begin
  EditExtra(True);
  View;
end;

procedure TfrmTable.miSetVihClick(Sender: TObject);
var S:string;
begin
  if not CheckOpenedGraph then Exit;
  S:=FData.TextWPR;
  if InputQuery('Выходные и прадничные','Ввод выходных',S) then begin
    FData.TextWPR:=S;
    View;
  end;
end;

procedure TfrmTable.miOpenClick(Sender: TObject);
begin
  OpenDialog1.InitialDir:=Options.DefDataDir;
  if OpenDialog1.Execute then begin
    LoadGraph(OpenDialog1.FileName);
    AddToMRU(OpenDialog1.FileName);
  end;
end;

procedure TfrmTable.miQuickClick(Sender: TObject);
begin
  frmQuickInput.Visible:=not frmQuickInput.Visible;
  miQuick.Checked:=frmQuickInput.Visible;
end;

procedure TfrmTable.miAlwaysShowTypesClick(Sender: TObject);
begin
  Options.gShowDefChars:=not Options.gShowDefChars;
  UpdateData;
  miAlwaysShowTypes.Checked:=Options.gShowDefChars;
end;

procedure TfrmTable.miCheckTableClick(Sender: TObject);
var SL:TStringList;
begin
  if (FData= nil) then Exit;
  try
    SL:=TStringList.Create;
    FData.Analyze(SL);
    ShowMemo(SL.Text,'Анализ графика');
  finally
    SL.Free;
  end;
end;

procedure TfrmTable.miSaveAsClick(Sender: TObject);
begin
  if not CheckOpenedGraph then Exit;
  SaveAs;
end;

procedure TfrmTable.miSaveClick(Sender: TObject);
begin
  if not CheckOpenedGraph then Exit;
  SaveGraph;
end;

procedure TfrmTable.miSetDayClick(Sender: TObject);
begin
  if not CheckOpenedGraph then Exit;
  SetSelection(@SetDay);
end;

procedure TfrmTable.miSetNightClick(Sender: TObject);
begin
  if not CheckOpenedGraph then Exit;
  SetSelection(@SetNight);
end;

procedure TfrmTable.miSetOnlyUnkClick(Sender: TObject);
begin
  Options.gSetOnlyUnk:=not Options.gSetOnlyUnk;
  miSetOnlyUnk.Checked:=Options.gSetOnlyUnk;
end;

procedure TfrmTable.miShowMPClick(Sender: TObject);
begin
  Options.gShowMP:=not Options.gShowMP;
  UpdateData;
  miShowMP.Checked:=Options.gShowMP;
end;

procedure TfrmTable.sgPrepareCanvas(sender: TObject; aCol, aRow: Integer;
  aState: TGridDrawState);
var Style:TTextStyle;
    bg:TCellBg;
begin
  if FData=nil then Exit;
  if gdFixed in aState then begin
    if aCol=0 then Exit;
    if aCol<=FExtraFixedCols then begin
      Style:=sg.Canvas.TextStyle;
      Style.Alignment:=taCenter;
      sg.Canvas.TextStyle:=Style;
    end else
    if FData.IsDayWPR(aCol-FExtraFixedCols) then begin
      sg.Canvas.Font.Color:=clRed;
      sg.Canvas.Font.Style:=[fsBold];
    end;
  end;
  if aState<>[] then Exit;
  bg:=FData.GetCellBg(RowToWorker(aRow),ColToDay(aCol),[cusFontStyle,cusBgColor,cusFontColor,cusVih,cusSM]);
  sg.Canvas.Font.Color:=bg.FontColor;
  sg.Canvas.Brush.Color:=bg.BgColor;
  sg.Canvas.Font.Style:=bg.Styles;
end;

procedure TfrmTable.sgSelection(Sender: TObject; aCol, aRow: Integer);
var S:string;
    W,D:Integer;
begin
  if FData=nil then Exit;
  W:=RowToWorker(aRow);  W:=Max(0,W);
  D:=ColToDay(aCol);
  S:='['+FData.Workers[W]+']['+IntToStr(D)+']-'+'{'+
    FData.GetCellInfo(W,D).FHours+'}';
  S:=S+TypeText[FData.GetCellInfo(W,D).FType];
  sb.SimpleText:=S;
end;

procedure TfrmTable.tbSetTemplClick(Sender: TObject);
begin
  DoReadHoursType(tbSetTempl);
end;

procedure TfrmTable.tbTextClick(Sender: TObject);
begin
  DoSetHours(tbText);
end;

procedure TfrmTable.tbTypeClick(Sender: TObject);
begin
  FSetFlagType:=FTemplType;
  SetSelection(@SetAnyFlag);
end;

procedure TfrmTable.SetCellType(ACol, ARow: Integer; AType: TDayType);
begin
  if FData=nil then Exit;
  FData.SetCellDayType(RowToWorker(ARow),ColToDay(ACol),AType);
  sg.Cells[ACol,ARow]:=FData.GetCellValue(RowToWorker(ARow),ColToDay(ACol));
  UpdateSpecCol(ARow);
  UpdateSpecRow(ACol);
end;

procedure TfrmTable.SetCellHours(ACol, ARow: Integer; AHours: string);
begin
  if FData=nil then Exit;
  FData.SetCellHours(RowToWorker(ARow),ColToDay(ACol),FTemplText);///!!!AHours?
  sg.Cells[ACol,ARow]:=FData.GetCellValue(RowToWorker(ARow),ColToDay(ACol));
  UpdateSpecCol(ARow);
  UpdateSpecRow(ACol);
end;

procedure TfrmTable.SetSelection(DataProc: TDataProc);
var X,Y:Integer;
begin
  if FData=nil then Exit;
  for X:=sg.Selection.Left to sg.Selection.Right do
    for Y:=sg.Selection.Top to sg.Selection.Bottom do
      DataProc(X,Y);
end;

procedure TfrmTable.SetNight(ACol, ARow: Integer);
var S:string;
begin
  if FData=nil then Exit;
  if not CheckUnk(ACol,ARow) then Exit;
  S:=FData.GetCellInfo(RowToWorker(ARow),ColToDay(ACol)).FHours;
  if S='8' then
    SetCellType(ACol,ARow,dtNightLast)
  else
  if S='4'then
    SetCellType(ACol,ARow,dtNightFirst);
end;

procedure TfrmTable.SetDay(ACol, ARow: Integer);
begin
  if FData=nil then Exit;
  if not CheckUnk(ACol,ARow) then Exit;
  SetCellType(ACol,ARow,dtDay)
end;

procedure TfrmTable.SetAnyFlag(ACol, ARow: Integer);
begin
  if FData=nil then Exit;
  if not CheckUnk(ACol,ARow) then Exit;
  SetCellType(ACol,ARow,FSetFlagType);
end;

procedure TfrmTable.SetANyHours(ACol, ARow: Integer);
begin
  if FData=nil then Exit;
  if not CheckUnk(ACol,ARow) then Exit;
  SetCellHours(ACol,ARow,FTemplText);
end;

function TfrmTable.CheckUnk(ACol, ARow: Integer): boolean;
begin
  Result:=False;
  if GetCellType(ACol,ARow).FType=dtLocked then Exit;
  if Options.gSetOnlyUnk then begin
    if GetCellType(ACol,ARow).FType<>dtUnk then Exit;
    Result:=True;
  end else begin
    Result:=True;
    Exit;
  end;
end;

procedure TfrmTable.DoSetFlag(Sender: TObject);
var mi:TMenuItem;
begin
  if FData=nil then Exit;
  if not (Sender is TMenuItem) then Exit;
  mi:=TMenuItem(Sender);
  FSetFlagType:=TDayType(mi.Tag);
  SetSelection(@SetAnyFlag);
end;

procedure TfrmTable.DoSetHours(Sender: TObject);
begin
  if FData=nil then Exit;
  SetSelection(@SetANyHours);
end;

procedure TfrmTable.UpdateSpecCol(ARow: Integer);
var I,J,Summ:integer;
    EI:TExtraItem;
begin
  if FData=nil then Exit;
  if FExtraFixedCols=0 then Exit;
  for I:=0 to Options.gExtraCols.VisibleCount-1 do begin
    EI:=Options.gExtraCols.Visiblies[I];
    Summ:=0;
    for J:=1 to FData.MonthDays do begin
      Summ:=Summ+EI.GetUsedHoursOfTypeDef(FData.GetCellInfo(RowToWorker(ARow),J),False);
    end;
    sg.Cells[I+1,ARow]:=IntToStr(Summ);
  end;
end;

procedure TfrmTable.UpdateSpecRow(ACol: Integer);
var I,J,Summ:integer;
    EI:TExtraItem;
begin
  if FData=nil then Exit;
  if FExtraFixedRows=0 then Exit;
  for I:=0 to Options.gExtraRows.VisibleCount-1 do begin
    EI:=Options.gExtraRows.Visiblies[I];
    Summ:=0;
    for J:=0 to FData.WorkerCount-1 do begin
      Summ:=Summ+EI.GetUsedHoursOfTypeDef(FData.GetCellInfo(J,ColToDay(ACol)),False);
    end;
    sg.Cells[ACol,I+1]:=IntToStr(Summ);
  end;
end;

procedure TfrmTable.UpdateActionList;
var I:Integer;
    ac:TAction;
    mi:TMenuItem;
    S:string;
const
  ACCat = 'actn';
begin
  //сначала очищаем
  I:=miEdit.IndexOf(miStartActions)+1;
  while True do begin
    if miEdit.Count>I then
      miEdit.Delete(I)
    else
      Break;
  end;
  frmQuickInput.ClearButtons;
  for I:=al.ActionCount-1 downto 0 do
    if al.Actions[I].Category=ACCat then
      al.Actions[I].Free;
  for I:=0 to High(Options.FActions) do begin
    if not Options.FActions[I].Use then Continue;
    ac:=TAction.Create(Self);
    ac.Category:=ACCat;
    ac.Caption:=Options.FActions[I].Caption;
    ac.Tag:=I;
    ac.ShortCut:=Options.FActions[I].HotKey;
    ac.OnExecute:=@DoExecAction;
    ac.ActionList:=al;
    mi:=TMenuItem.Create(Self);
    mi.Action:=ac;
    miEdit.Add(mi);
    mi.ShortCut:=ac.ShortCut;
    mi.OnClick:=@DoExecAction;
    if Options.FActions[I].ShowQInput then begin
      S:='';
      if Options.FActions[I].HotKey<>0 then
        S:=ShortCutToText(Options.FActions[I].HotKey)+' ';
      frmQuickInput.AddButton(S+Options.FActions[I].Caption,AC);
    end;
  end;
end;

procedure TfrmTable.DoExecAction(sender: TObject);
var I:Integer;
begin
  if FData=nil then Exit;
  I:=Integer(TAction(sender).Tag);
  ExecAction(Self,Options.FActions[I].Acion);
end;

procedure TfrmTable.DoExtraRowsClick(Sender: TObject);
var EI:TExtraItem;
begin
  if FData=nil then Exit;
  EI:=Options.gExtraRows.Items[(Sender as TMenuItem).Tag];
  EI.Visible:=not EI.Visible;
  (Sender as TMenuItem).Checked:=EI.Visible;
  InitView;
  UpdateData;
end;

procedure TfrmTable.DoExtraColsClick(Sender: TObject);
var EI:TExtraItem;
begin
  if FData=nil then Exit;
  EI:=Options.gExtraCols.Items[(Sender as TMenuItem).Tag];
  EI.Visible:=not EI.Visible;
  (Sender as TMenuItem).Checked:=EI.Visible;
  InitView;
  UpdateData;
end;

procedure TfrmTable.DoMRUClick(Sender: TObject);
begin
  //кликаем на мру элемент
  if not(Sender is TMenuItem) then Exit;
  LoadGraph(TMenuItem(Sender).Caption);
  AddToMRU(TMenuItem(Sender).Caption);
  View;
end;

function TfrmTable.GetCellType(ACol, ARow: Integer): TDayItem;
begin
  Result.FHours:='';
  Result.FType:=dtUnk;
  if FData=nil then Exit;
  Result:=FData.GetCellInfo(RowToWorker(ARow),ColToDay(ACol));
end;

procedure TfrmTable.NewGraph;
begin
  if FData=nil then FData:=TGraphData.Create;
  Application.CreateForm(TfrmNewGr,frmNewGr);
  frmNewGr.leWeekends.Text:='';
  frmNewGr.leFileName.Text:='';
  if frmNewGr.ShowModal=mrOK then with frmNewGr do begin
    GraphData.CurrMonth:=cbMonth.ItemIndex;
    GraphData.CurrYear:=seYear.Value;
    GraphData.TextWPR:=leWeekends.Text;
    GraphData.NewData;
    if leFileName.Text<>'' then
      GraphData.FileName:=leFileName.Text+'.gr'
    else
      GraphData.FileName:='';
    UpdateFormCaption;
    FreeAndNil(frmNewGr);
    View;
  end;
end;

procedure TfrmTable.SaveGraph;
var S:string;
begin
  if FData=nil then Exit;
  S:=GraphData.FileName;
  if S='' then begin
    ShowMessage('Имя файла для сохранения не задано!!!'#13' Воспользуйтесь командой "Сохранить как..."');
    Exit;
  end;
  GraphData.SaveData(S);
  UpdateFormCaption;
  AddToMRU(S);
end;

procedure TfrmTable.SaveAs;
var S:string;
begin
  if FData=nil then Exit;
  SaveDialog1.FileName:=ExtractFileName(GraphData.FileName);
  SaveDialog1.InitialDir:=Options.DefDataDir;
  if SaveDialog1.Execute then begin
    S:=SaveDialog1.FileName;
    S:=LowerCase(ExtractFileExt(SaveDialog1.FileName));
    if S<>'.gr' then
      S:=SaveDialog1.FileName+'.gr'
    else
      S:=SaveDialog1.FileName;
    GraphData.FileName:=S;
    GraphData.SaveData(S);
    AddToMRU(S);
    UpdateFormCaption;
  end;
end;

procedure TfrmTable.LoadGraph(AFileName: string);
begin
  if FData=nil then FData:=TGraphData.Create
  else begin
    ///!!!проверяем, вруг есть что то не записаное
    if FData.Modified then begin
      if MessageDlg('Сохранение фапйла', 'Текущий график изменен. Сохранить?',mtConfirmation,mbYesNo,'')=mrYes then
        FData.SaveData(FData.FileName);
    end;
  end;
  FData.LoadData(AFileName);
  UpdateFormCaption;
  View;
end;

procedure TfrmTable.LoadMRU;
var I,J:Integer;
    mi:TMenuItem;
begin
  //сначала очищаем
  I:=mifile.IndexOf(miMRUStart)+1;
  while True do begin
    if miFile.Items[I]<>miMRUEnd then
      miFile.Delete(I)
    else
      Break;
  end;
  for J:=Options.FMRUList.Count-1 downto 0 do begin
    mi:=TMenuItem.Create(Self);
    mi.Caption:=Options.FMRUList[J];
    mi.OnClick:=@DoMRUClick;
    miFile.Insert(I,mi);
  end;
  miMRUEnd.Visible:=Options.FMRUList.Count<>0;
end;

procedure TfrmTable.AddToMRU(AFileName: string);
var I:integer;
begin
  I:=Options.FMRUList.IndexOf(AFileName);
  if I=-1 then
    Options.FMRUList.Insert(0,AFileName)
  else begin
    Options.FMRUList.Move(I,0);
  end;
  while Options.FMRUList.Count>10 do
    Options.FMRUList.Delete(Options.FMRUList.Count-1);
  LoadMRU;
end;

procedure TfrmTable.UpdateFormCaption;
begin
  Caption:='График за '+ DefaultFormatSettings.LongMonthNames[FData.CurrMonth] +
    ' '+IntToStr(FData.CurrYear)+'г. [' +GraphData.FileName + ']';

end;

procedure TfrmTable.DoSelectHours(Sender: TObject);
begin
  FTemplText:=(Sender as TMenuItem).Caption;
  tbText.Caption:=FTemplText;
  if FTemplText[1] = '{' then FTemplText:='';
end;

procedure TfrmTable.DoSelectType(Sender: TObject);
begin
  FTemplType:=TDayType((Sender as TMenuItem).Tag);
  tbType.Caption:=TypeText[FTemplType];
end;

procedure TfrmTable.DoReadHoursType(Sender: TObject);
var DT:TDayItem;
begin
  DT:=GetCellType(sg.Col,sg.Row);
  FTemplText:=DT.FHours;
  tbText.Caption:=FTemplText;
  FTemplType:=DT.FType;
  tbType.Caption:=TypeText[DT.FType];
end;

procedure TfrmTable.UnlockCell(Sender: TObject);
var dt:TDayType;
begin
  dt:=FData.GetCellInfo(RowToWorker(sg.Row),ColToDay(sg.Col)).FType;
  if dt=dtLocked then
    SetCellType(sg.Selection.Left,sg.Selection.Top,dtUnk);
end;

procedure TfrmTable.View;
begin
  if FData=nil then Exit;
  InitView;
  UpdateData;
  UpdateMenu;
end;

procedure TfrmTable.InitView;
var I,J:integer;
  c:TGridColumn;
begin
  if FData=nil then Exit;
  //настройка сетки
  //FData:=frmMain.FGraphData;
  FExtraFixedRows:=Options.gExtraRows.VisibleCount;
  FExtraFixedCols:=Options.gExtraCols.VisibleCount;
  sg.Columns.Clear;
  sg.ColCount:=20;
  //showmans;
  I:=FData.WorkerCount+1+FExtraFixedRows;
  ///ShowMessage(IntToStr(sg.RowCount));
  sg.RowCount:=I;
  sg.FixedCols:=FExtraFixedCols+1;
  sg.FixedRows:=FExtraFixedRows+1;
  sg.DefaultColWidth:=Options.gDefColWidth;
  sg.ColWidths[0]:=Options.gFirstCol;
  sg.DefaultRowHeight:=Options.gDefRowHeight;
  sg.Font.Name:=Options.gFontName;
  sg.Font.Size:=Options.gFontSize;
  for I:=1 to FData.MonthDays do begin
    C:=sg.Columns.Add;
    C.Alignment:=taCenter;
    C.Title.Caption:=IntToStr(I);
    C.Title.Alignment:=taCenter;
  end;
  //очищаем кусочек, где фикс строки и столбцы
  if (FExtraFixedRows<>0)and(FExtraFixedCols<>0) then
    for I:=1 to FExtraFixedCols do
      for J:=1 to FExtraFixedRows do
        sg.Cells[I,J]:='';

  //заголовок формы
  UpdateFormCaption;
  //Caption:='График за '+ DefaultFormatSettings.LongMonthNames[FData.CurrMonth] + ' '+IntToStr(FData.CurrYear)+'г.';
  {cbTemplType.Items.Clear;
  for dt:=Low(TDayType) to High(TDayType) do
    cbTemplType.Items.Add(TypeText[dt]);
  cbTemplType.ItemIndex:=0;}


end;

procedure TfrmTable.UpdateData;
var
  I: Integer;
  R:TRect;
begin
  if FData=nil then Exit;
  //фикс строки
  for I:=0 to Options.gExtraRows.VisibleCount-1 do
    sg.Cells[0,I+1]:=Options.gExtraRows.Visiblies[I].ShortName;
  //фикс колонки
  for I:=0 to Options.gExtraCols.VisibleCount-1 do
    sg.Cells[I+1,0]:=Options.gExtraCols.Visiblies[I].ShortName;

  for I:=0 to FData.WorkerCount-1 do
    sg.Cells[0,I+FExtraFixedRows+1]:=FData.Workers[I];//Items[I].FName;

  R.Left:=1;
  R.Right:=FData.MonthDays;
  R.Top:=0;
  R.Bottom:=FData.WorkerCount-1;
  UpdateRect(R);
end;

procedure TfrmTable.UpdateMenu;
var mi:TMenuItem;
  I: Integer;
begin
  miAlwaysShowTypes.Checked:=Options.gShowDefChars;
  miShowMP.Checked:=Options.gShowMP;
  miSetOnlyUnk.Checked:=Options.gSetOnlyUnk;

  UpdateActionList;
  //extra rows
  miExtraRows.Clear;
  for I:=0 to Options.gExtraRows.Count-1 do begin
    mi:=TMenuItem.Create(Self);
    mi.Caption:=Options.gExtraRows.Items[I].LongName;
    mi.Checked:=Options.gExtraRows.Items[I].Visible;
    mi.Tag:=I;
    mi.OnClick:=@DoExtraRowsClick;
    miExtraRows.Add(mi);
  end;
  //extra cols
  miExtraCols.Clear;
  for I:=0 to Options.gExtraCols.Count-1 do begin
    mi:=TMenuItem.Create(Self);
    mi.Caption:=Options.gExtraCols.Items[I].LongName;
    mi.Checked:=Options.gExtraCols.Items[I].Visible;
    mi.Tag:=I;
    mi.OnClick:=@DoExtraColsClick;
    miExtraCols.Add(mi);
  end;
end;

procedure TfrmTable.UpdateDTMenu;
var mi:TMenuItem;
    dt:TDayType;
begin
  ///!!!добавить пункт меню
  //снять "Зарезервировано"
  //и перед добавлением очищать все менюшки
  miAnyFlags.Clear;
  pmTypes.Items.Clear;
  for dt:=Low(TDayType) to High(TDayType) do begin
    mi:=TMenuItem.Create(Self);
    mi.Tag:=Integer(DT);
    mi.Caption:=TypeText[dt];
    mi.OnClick:=@DoSetFlag;
    miAnyFlags.Add(mi);
    //for pmTypes
    mi:=TMenuItem.Create(Self);
    mi.Tag:=Integer(DT);
    mi.Caption:=TypeText[dt];
    mi.OnClick:=@DoSelectType;
    pmTypes.Items.Add(mi);
  end;
  mi:=TMenuItem.Create(Self);
  mi.Caption:='-';
  miAnyFlags.Add(mi);

  mi:=TMenuItem.Create(Self);
  mi.Caption:='-';
  pmTypes.Items.Add(mi);

  mi:=TMenuItem.Create(Self);
  mi.Caption:='Убрать "Зарезервировано"';
  mi.OnClick:=@UnlockCell;
  miAnyFlags.Add(mi);

  mi:=TMenuItem.Create(Self);
  mi.Caption:='Убрать "Зарезервировано"';
  mi.OnClick:=@UnlockCell;
  pmTypes.Items.Add(mi);

end;

procedure TfrmTable.UpdateRect(ARect: TRect);
var
  I, J: Integer;
begin
  if FData=nil then Exit;
  //передаются работкики и дни
  for I:=ARect.Top to ARect.Bottom do begin
    for J:=ARect.Left to ARect.Right do begin
      sg.Cells[DayToCol(J),WorkerToRow(I)]:=FData.GetCellValue(I,J);
    end;
  end;
  for I:=ARect.Top to ARect.Bottom do
    UpdateSpecCol(WorkerToRow(I));
  for J:=ARect.Left to ARect.Right do
    UpdateSpecRow(DayToCol(J));
end;

function TfrmTable.ColToDay(ACol: Integer): Integer;
begin
  Result:=ACol-FExtraFixedCols;
end;

function TfrmTable.DayToCol(ADay: integer): Integer;
begin
  Result:=ADay+FExtraFixedCols;
end;

function TfrmTable.RowToWorker(ARow: Integer): Integer;
begin
  Result:=ARow-FExtraFixedRows-1;
end;

function TfrmTable.WorkerToRow(AWorker: Integer): Integer;
begin
  Result:=AWorker+FExtraFixedRows+1;
end;

procedure TfrmTable.CreateData(AMonth, AYear: Integer);
begin
  FData:=TGraphData.Create;
  FData.CurrMonth:=AMonth;
  FData.CurrYear:=AYear;
end;

function TfrmTable.CheckOpenedGraph: boolean;
begin
  Result:=False;
  if FData=nil then begin
    ShowMessage('Операция недоступна - нет открытого графика!');
    Exit;
  end;
  Result:=True;
end;

end.

