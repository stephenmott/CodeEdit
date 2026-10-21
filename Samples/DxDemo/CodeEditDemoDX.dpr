program CodeEditDemoDX;

{ CodeEdit with DevExpress skins: the VclDemo2 form plus a TdxSkinController,
  a skin picker, TCodeEditorDevExpressTheme keeping the editor's colours in
  step with the skin, and a TCodeEditorSettings whose options dialog offers
  "Follow the DevExpress skin" (CodeEdit.DevExpressTheme registers it).
  Needs the DevExpress VCL library on the library path. }

uses
  Vcl.Forms,
  DemoMainDX in 'DemoMainDX.pas' {FormDX};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFormDX, FormDX);
  Application.Run;
end.
