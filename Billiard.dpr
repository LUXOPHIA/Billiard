program Billiard;

uses
  FMX.Forms,
  Main in 'Main.pas' {Form1},
  Core in 'Core.pas',
  FJX in '_LIBRARY\FJX.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
