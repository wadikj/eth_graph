program Eth_graph;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, eth_tbl, gdata, impOpts, u_options, u_gridprops, u_timeints,
  U_newexpopts, u_editManList, u_othercolors, u_editActions, u_QickInput,
  u_memo, u_edextra, u_OldExport, u_newgr, u_othergrids, u_openFF, u_openXL,
  u_summ, u_about, u_editSumm
  { you can add units after this };

{$R *.res}

begin
  RequireDerivedFormResource:=True;
  Application.Scaled:=True;
  Application.Initialize;
  Application.CreateForm(TfrmTable, frmTable);
  Application.CreateForm(TfrmQuickInput, frmQuickInput);
  Application.CreateForm(TfrmSumm, frmSumm);
  Application.CreateForm(TfrmAbout, frmAbout);
  Application.CreateForm(TfrmSummOpt, frmSummOpt);
  Application.Run;
end.

