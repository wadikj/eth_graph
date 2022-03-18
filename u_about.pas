unit u_about;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls;

type

  { TfrmAbout }

  TfrmAbout = class(TForm)
    btCancel: TButton;
    Image2: TImage;
    Memo1: TMemo;
    procedure Image1Click(Sender: TObject);
  private

  public

  end;

var
  frmAbout: TfrmAbout;

procedure ShowAbout;

implementation

procedure ShowAbout;
begin
  Application.CreateForm(TfrmAbout,frmAbout);
  frmAbout.ShowModal;
end;

{$R *.lfm}

{ TfrmAbout }

procedure TfrmAbout.Image1Click(Sender: TObject);
begin

end;

end.

