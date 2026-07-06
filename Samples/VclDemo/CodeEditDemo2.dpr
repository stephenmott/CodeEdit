program CodeEditDemo2;

uses
  Vcl.Forms,
  DemoMain2 in 'DemoMain2.pas' {Form2},
  Vcl.Themes,
  Vcl.Styles;

{$R *.res}

begin
  Application.Initialize;
  if not TStyleManager.TrySetStyle('Windows Modern Dark') then
    TStyleManager.TrySetStyle('Windows11 Modern Dark');
  Application.CreateForm(TForm2, Form2);
  Application.Run;
end.
