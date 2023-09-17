unit u_data;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, u_options, SQLite3Conn, SQLDB;

type

  { TDM }

  TDM = class(TDataModule)
    conn: TSQLite3Connection;
    qu: TSQLQuery;
    tr: TSQLTransaction;
    procedure DataModuleCreate(Sender: TObject);
  private

  public
    function GetDS(ASQL:string; Activate:Boolean = True):TSQLQuery;
    procedure CloseDS(AQuery:TSQLQuery);
    procedure ExecSQL(ASQL:string);
    function GetQSingle(ASQL:string):string;
    procedure LoadStrings(ASQL:string; AData:TStrings);//парвое поле - int, второе рассм как str
    function _dts(D:TDateTime; UseTime:boolean=False):string;
    function _std(S:string):TDateTime;
    function GetGraphName(AMonth, AYear, ATypeID:integer):string;

  end;

var
  DM: TDM;

implementation

{$R *.lfm}

{ TDM }

procedure TDM.DataModuleCreate(Sender: TObject);
begin
  if Options.DBPath<>'' then begin
    conn.DatabaseName:=Options.DBPath;
  end else
    Options.DBPath:=conn.DatabaseName;
end;

function TDM.GetDS(ASQL: string; Activate: Boolean): TSQLQuery;
begin
  qu.Active:=False;
  qu.SQL.Text:=ASQL;
  if Activate then
    qu.Active:=True;
  Result:=qu;
end;

procedure TDM.CloseDS(AQuery: TSQLQuery);
begin
  AQuery.Active:=False;
  tr.Commit;
end;

procedure TDM.ExecSQL(ASQL: string);
begin
  if not tr.Active then
    tr.Active:=True;
  qu.Active:=False;
  qu.SQL.Text:=ASQL;
  qu.ExecSQL;
  tr.Commit;
end;

function TDM.GetQSingle(ASQL: string): string;
var DS:TSQLQuery;
begin
  Result:='';
  DS:=GetDS(ASQL);
  if not DS.IsEmpty then
    Result:=DS.Fields[0].AsString;
  CloseDS(DS);
end;

procedure TDM.LoadStrings(ASQL: string; AData: TStrings);
var DS:TSQLQuery;
    I:PtrInt;
    S:string;
begin
  DS:=GetDS(ASQL);
  while not DS.EOF do begin
    I:=DS.Fields[0].AsInteger;
    S:=DS.Fields[1].AsString;
    AData.AddObject(S,TObject(I));
    DS.Next;
  end;
  CloseDS(DS);
end;

function TDM._dts(D: TDateTime; UseTime: boolean): string;
var SA:TStringArray;
    S:string;
begin
  SA:=DateToStr(D).Split('.');
  Result:=SA[2]+'-'+SA[1]+'-'+SA[0];
  if UseTime then begin
    Result:=Result+' '+TimeToStr(D);
  end;
end;

function TDM._std(S: string): TDateTime;
var SA,SA1:TStringArray;
begin
  SA1:=S.Split([' ']);
  SA:=SA1[0].Split(['-']);
  Result:=EncodeDate(StrToInt(SA[0]),StrToInt(SA[1]),StrToInt(SA[2]));
  if Length(SA1)<2 then Exit;
  Result:=Result+StrToTime(SA1[1]);
end;

function TDM.GetGraphName(AMonth, AYear, ATypeID: integer): string;
begin
  Result:=DefaultFormatSettings.LongMonthNames[AMonth] + ', '+IntToStr(AYear)+'['+
    GetQSingle('select tname from graph_types where tid='+IntToStr(ATypeID)+']');
end;

end.

