PROGRAM CodeEditDemo;

USES
  Vcl.Forms,
  Demo.Main IN 'Demo.Main.pas' {MainForm},
  Vcl.Themes,
  Vcl.Styles;

{$R *.res}

BEGIN
  Application.Initialize;
  IF NOT TStyleManager.TrySetStyle('Windows Modern Dark') THEN
    TStyleManager.TrySetStyle('Windows11 Modern Dark');
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
END.
