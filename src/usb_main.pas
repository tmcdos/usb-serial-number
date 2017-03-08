unit usb_main;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls;

type
  TForm1 = class(TForm)
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    StaticText1: TEdit;
    btn1: TButton;
    memo1: TMemo;
    btn3: TButton;
    procedure btn1Click(Sender: TObject);
    procedure btn3Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    procedure usb_add(Sender: TObject);
    procedure usb_del(Sender: TObject);
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

uses detect_usb;

procedure TForm1.btn1Click(Sender: TObject);
var
  dwRequired:cardinal;
  hDev, hAllDevices:HDEVINFO;
  dwInfo:DWord;
  Data:SP_DEVINFO_DATA;
  buf:PChar;
  s:string;
begin
  memo1.Clear;
  hDev:=SetupDiCreateDeviceInfoList(nil, 0);
  If cardinal(hDev)=INVALID_HANDLE_VALUE then
  begin
    ShowMessage('Error in SetupDiCreateDeviceInfoList');
    exit;
  end;
  hAllDevices:=SetupDiGetClassDevsExA(nil, nil, 0, DIGCF_PRESENT or DIGCF_ALLCLASSES,
  hDev, nil, 0);
  If cardinal(hAllDevices)=INVALID_HANDLE_VALUE then
  begin
    ShowMessage('Error in SetupDiGetClassDevsExA');
    exit;
  end;
  FillChar(Data, SizeOf(SP_DEVINFO_DATA), 0);
  Data.cbSize:=SizeOf(SP_DEVINFO_DATA);
  dwInfo:=0;
  If not SetupDiEnumDeviceInfo(hAllDevices, dwInfo, @Data) then
  begin
    ShowMessage('Error in SetupDiEnumDeviceInfo');
    exit;
  end;
  buf:=StrAlloc(100);
  While SetupDiEnumDeviceInfo(hAllDevices, dwInfo, @Data) do
  begin
    dwRequired:=0;
    FillChar(buf^, 100, #0);
    If SetupDiGetDeviceRegistryPropertyA(hAllDevices, @Data, SPDRP_DEVICEDESC, nil, buf, 100, @dwRequired) then
    begin
      s:=string(buf);
      Memo1.Lines.Add(s);
    end;
    inc(dwInfo);
  end;
  StrDispose(buf);
  SetupDiDestroyDeviceInfoList(hAllDevices);
  SetupDiDestroyDeviceInfoList(hDev);
end;

procedure UpCase(s:Pointer); Assembler;
asm
  PUSH ESI
  CLD
  MOV ESI,EAX
@@1:
  LODSB
  OR AL,AL
  JZ @@2
  CMP AL,'a'
  JB @@1
  CMP AL,'z'
  JA @@1
  SUB AL,$20
  MOV [ESI-1],AL
  JMP @@1
@@2:
  POP ESI
end;

procedure TForm1.btn3Click(Sender: TObject);
var
  DeviceList:HDEVINFO;
  DeviceFilter: HDEVINFO;
  usb_GUID:TGUID;
  deviceIndex:Integer;
  interfaceIndex:Integer;
  deviceInfo:TSPDevInfoData;
  interfaceInfo:TSPDeviceInterfaceData;
  DetailData:TSPDeviceInterfaceDetailData;
  ErrNum:Cardinal;
  SerialNum:string;
  p1,p2:PAnsiChar;
  p:Pointer;
begin
  deviceInfo.cbSize := SizeOf(TSPDevInfoData);
  interfaceInfo.cbSize := SizeOf(TSPDeviceInterfaceData);
  DetailData.cbSize := 5; // the only valid value !!!

  // scan for USB devices
  DeviceList := SetupDiCreateDeviceInfoList(nil, 0);
  if DeviceList <> INVALID_HANDLE_VALUE then
  try
    // Retrieve the device information set for the interface class
    usb_GUID := GUID_DEVINTERFACE_USB_DEVICE;
    DeviceFilter := SetupDiGetClassDevsExA(@usb_GUID, nil, 0,
      DIGCF_PRESENT or DIGCF_DEVICEINTERFACE, DeviceList, nil, 0);
    if DeviceFilter <> INVALID_HANDLE_VALUE then
    try
      // enumerate the devices
      deviceIndex := 0;
      while True do
      begin
        // for each device
        if SetupDiEnumDeviceInfo(DeviceFilter, deviceIndex, @deviceInfo) then
        begin
          interfaceIndex := 0;
          while True do
          begin
            // for each interface
            if SetupDiEnumDeviceInterfaces(DeviceFilter, @deviceInfo, usb_GUID, interfaceIndex, interfaceInfo) then
            begin
              // get the details
              try
                if SetupDiGetDeviceRegistryPropertyA(DeviceFilter, @deviceInfo, SPDRP_SERVICE, nil,
                  @DetailData.DevicePath[1], Length(DetailData.DevicePath), Nil) then
                  if StrComp(@DetailData.DevicePath[1],'USBSTOR')=0 then // only USB memory sticks
                    if SetupDiGetDeviceInterfaceDetailA(DeviceFilter, @interfaceInfo,
                      @DetailData, Length(DetailData.DevicePath), Nil, @deviceInfo) then
                    begin
                      p1:=StrScan(@DetailData.DevicePath[1],'#');
                      Inc(p1);
                      p2:=StrRScan(@DetailData.DevicePath[1],'#');
                      SetLength(SerialNum,p2-p1);
                      StrLCopy(PAnsiChar(Pointer(SerialNum)),p1,p2-p1);
                      UpCase(Pointer(SerialNum));
                      if SetupDiGetDeviceRegistryPropertyA(DeviceFilter, @deviceInfo, SPDRP_LOCATION_INFORMATION,
                        nil, @DetailData.DevicePath[1], Length(DetailData.DevicePath), Nil) then
                      begin
                        // add the device
                        memo1.Lines.Add(SerialNum+'='+StrPas(@DetailData.DevicePath[1]));
                      End;
                    end;
              finally
                ErrNum := GetLastError;
              end;
            end
            else
            begin
              ErrNum := GetLastError;
              if ErrNum = ERROR_NO_MORE_ITEMS then break;
            end;
            Inc(interfaceIndex);
          end;
        end
        else
        begin
          ErrNum := GetLastError;
          if ErrNum = ERROR_NO_MORE_ITEMS then break;
        end;
        Inc(deviceIndex);
      end;
    finally
      SetupDiDestroyDeviceInfoList(DeviceFilter);
    end;
  finally
    SetupDiDestroyDeviceInfoList(DeviceList);
  end;
end;

procedure Tform1.usb_add(Sender:TObject);
Begin
  StaticText1.Text:=intf_name;
  MessageDlg('USB added',mtInformation,[mbOK],0);
end;

procedure Tform1.usb_del(Sender:TObject);
Begin
  MessageDlg('USB removed',mtInformation,[mbOK],0);
  StaticText1.Text:='';
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  with TComponentUSB.Create(Self) do
  Begin
    OnUSBArrival:=usb_add;
    OnUSBRemove:=usb_del;
  end;
end;

end.

