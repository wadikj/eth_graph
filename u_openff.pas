unit u_openFF;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls;

type

  { TfrmOpenFF }

  TfrmOpenFF = class(TForm)
    btDelFile: TButton;
    btAddFile: TButton;
    btOpenFile2: TButton;
    btOpenFile3: TButton;
    ListBox1: TListBox;
    OpenFile: TOpenDialog;
    OpenFolder: TSelectDirectoryDialog;
    procedure btAddFileClick(Sender: TObject);
    procedure btOpenFile2Click(Sender: TObject);
    procedure btDelFileClick(Sender: TObject);
  private
    FModified:Boolean;
    FFile:Boolean;
    procedure InitForm;
    procedure CloseForm;

  public

  end;

var
  frmOpenFF: TfrmOpenFF;

procedure OpenFileFolder(AFile:Boolean);

implementation

uses u_options, Windows;

procedure OpenFileFolder(AFile: Boolean);
begin
  Application.CreateForm(TfrmOpenFF,frmOpenFF);
  frmOpenFF.FFile:=AFile;
  frmOpenFF.InitForm;
  frmOpenFF.ShowModal;
  frmOpenFF.CloseForm;
  FreeAndNil(frmOpenFF);
end;

{$R *.lfm}

{ TfrmOpenFF }

procedure TfrmOpenFF.btOpenFile2Click(Sender: TObject);
var WS:WideString;
begin
  if ListBox1.ItemIndex=-1 then Exit;
  WS:=WideString(ListBox1.Items[ListBox1.ItemIndex]);
  ShellExecuteW(0,'open',PWideChar(ws),nil,nil,SW_SHOW);
end;

procedure TfrmOpenFF.btDelFileClick(Sender: TObject);
begin
  if ListBox1.ItemIndex=-1 then Exit;
  ListBox1.Items.Delete(ListBox1.ItemIndex);
end;

procedure TfrmOpenFF.btAddFileClick(Sender: TObject);
begin
  if FFile and OpenFile.Execute then begin
    ListBox1.Items.Add(OpenFile.FileName);
    FModified:=True;
  end;
  if (not FFile) and OpenFolder.Execute then begin
    ListBox1.Items.Add(OpenFolder.FileName);
    FModified:=True;
  end;
end;

procedure TfrmOpenFF.InitForm;
begin
  FModified:=False;
  if FFile then begin
    ListBox1.Items.Assign(Options.FFiles);
    Caption:='Список файлов';
  end
  else
    ListBox1.Items.Assign(Options.FFolders);
end;

procedure TfrmOpenFF.CloseForm;
begin
  if not FModified then Exit;
  if FFile then
    Options.FFiles.Assign(ListBox1.Items)
  else
    Options.FFolders.Assign(ListBox1.Items);
  FModified:=False;
end;

end.

