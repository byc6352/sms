program sms;

uses
  Vcl.Forms,
  uMain in 'uMain.pas' {fmain},
  uAuth in 'uAuth.pas',
  uFuncs in 'uFuncs.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(Tfmain, fmain);
  Application.Run;
end.
