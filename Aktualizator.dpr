program Aktualizator;

uses
  FMX.Forms,
  Unit20 in 'Unit20.pas' {Form20};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm20, Form20);
  Application.Run;
end.
