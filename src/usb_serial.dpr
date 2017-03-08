program usb_serial;

uses
  Forms,
  usb_main in 'usb_main.pas' {Form1};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.

