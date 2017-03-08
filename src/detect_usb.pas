// Component to detect when usb devices are connected or disconnected
// using RegisterDeviceNotification
// Example - \\?\USB#Vid_febe&Pid_fb01#0000000000002A31#{a5dcbf10-6530-11d2-901f-00c04fb951ed}

unit Detect_Usb;

interface

uses
  Windows, Messages, SysUtils, Classes, Forms;

const
  GUID_DEVINTERFACE_USB_DEVICE: TGUID = '{A5DCBF10-6530-11D2-901F-00C04FB951ED}';
  DBT_DEVICEARRIVAL          = $8000;          // system detected a new device
  DBT_DEVICEREMOVECOMPLETE   = $8004;          // device is gone
  DBT_DEVTYP_DEVICEINTERFACE = $00000005;      // device interface class
  DBT_DEVTYP_VOLUME          = $00000002;

  DIGCF_ALLCLASSES      = $00000004;
  DIGCF_PRESENT         = $00000002;
  DIGCF_PROFILE         = $00000008;
  DIGCF_DEVICEINTERFACE = $00000010;

  SPDRP_DEVICEDESC                  = $00000000; // DeviceDesc (R/W)
  {$EXTERNALSYM SPDRP_DEVICEDESC}
  SPDRP_HARDWAREID                  = $00000001; // HardwareID (R/W)
  {$EXTERNALSYM SPDRP_HARDWAREID}
  SPDRP_COMPATIBLEIDS               = $00000002; // CompatibleIDs (R/W)
  {$EXTERNALSYM SPDRP_COMPATIBLEIDS}
  SPDRP_UNUSED0                     = $00000003; // unused
  {$EXTERNALSYM SPDRP_UNUSED0}
  SPDRP_SERVICE                     = $00000004; // Service (R/W)
  {$EXTERNALSYM SPDRP_SERVICE}
  SPDRP_UNUSED1                     = $00000005; // unused
  {$EXTERNALSYM SPDRP_UNUSED1}
  SPDRP_UNUSED2                     = $00000006; // unused
  {$EXTERNALSYM SPDRP_UNUSED2}
  SPDRP_CLASS                       = $00000007; // Class (R--tied to ClassGUID)
  {$EXTERNALSYM SPDRP_CLASS}
  SPDRP_CLASSGUID                   = $00000008; // ClassGUID (R/W)
  {$EXTERNALSYM SPDRP_CLASSGUID}
  SPDRP_DRIVER                      = $00000009; // Driver (R/W)
  {$EXTERNALSYM SPDRP_DRIVER}
  SPDRP_CONFIGFLAGS                 = $0000000A; // ConfigFlags (R/W)
  {$EXTERNALSYM SPDRP_CONFIGFLAGS}
  SPDRP_MFG                         = $0000000B; // Mfg (R/W)
  {$EXTERNALSYM SPDRP_MFG}
  SPDRP_FRIENDLYNAME                = $0000000C; // FriendlyName (R/W)
  {$EXTERNALSYM SPDRP_FRIENDLYNAME}
  SPDRP_LOCATION_INFORMATION        = $0000000D; // LocationInformation (R/W)
  {$EXTERNALSYM SPDRP_LOCATION_INFORMATION}
  SPDRP_PHYSICAL_DEVICE_OBJECT_NAME = $0000000E; // PhysicalDeviceObjectName (R)
  {$EXTERNALSYM SPDRP_PHYSICAL_DEVICE_OBJECT_NAME}
  SPDRP_CAPABILITIES                = $0000000F; // Capabilities (R)
  {$EXTERNALSYM SPDRP_CAPABILITIES}
  SPDRP_UI_NUMBER                   = $00000010; // UiNumber (R)
  {$EXTERNALSYM SPDRP_UI_NUMBER}
  SPDRP_UPPERFILTERS                = $00000011; // UpperFilters (R/W)
  {$EXTERNALSYM SPDRP_UPPERFILTERS}
  SPDRP_LOWERFILTERS                = $00000012; // LowerFilters (R/W)
  {$EXTERNALSYM SPDRP_LOWERFILTERS}
  SPDRP_BUSTYPEGUID                 = $00000013; // BusTypeGUID (R)
  {$EXTERNALSYM SPDRP_BUSTYPEGUID}
  SPDRP_LEGACYBUSTYPE               = $00000014; // LegacyBusType (R)
  {$EXTERNALSYM SPDRP_LEGACYBUSTYPE}
  SPDRP_BUSNUMBER                   = $00000015; // BusNumber (R)
  {$EXTERNALSYM SPDRP_BUSNUMBER}
  SPDRP_ENUMERATOR_NAME             = $00000016; // Enumerator Name (R)
  {$EXTERNALSYM SPDRP_ENUMERATOR_NAME}
  SPDRP_SECURITY                    = $00000017; // Security (R/W, binary form)
  {$EXTERNALSYM SPDRP_SECURITY}
  SPDRP_SECURITY_SDS                = $00000018; // Security (W, SDS form)
  {$EXTERNALSYM SPDRP_SECURITY_SDS}
  SPDRP_DEVTYPE                     = $00000019; // Device Type (R/W)
  {$EXTERNALSYM SPDRP_DEVTYPE}
  SPDRP_EXCLUSIVE                   = $0000001A; // Device is exclusive-access (R/W)
  {$EXTERNALSYM SPDRP_EXCLUSIVE}
  SPDRP_CHARACTERISTICS             = $0000001B; // Device Characteristics (R/W)
  {$EXTERNALSYM SPDRP_CHARACTERISTICS}
  SPDRP_ADDRESS                     = $0000001C; // Device Address (R)
  {$EXTERNALSYM SPDRP_ADDRESS}
  SPDRP_UI_NUMBER_DESC_FORMAT       = $0000001D; // UiNumberDescFormat (R/W)
  SPDRP_DEVICE_POWER_DATA           = $0000001E;
  {$EXTERNALSYM SPDRP_UI_NUMBER_DESC_FORMAT}
  SPDRP_REMOVAL_POLICY              = $0000001F; // Removal Policy ®
  SPDRP_REMOVAL_POLICY_HW_DEFAULT   = $00000020; // Hardware Removal Policy ®
  SPDRP_REMOVAL_POLICY_OVERRIDE     = $00000021; // Removal Policy Override (RW)
  SPDRP_INSTALL_STATE               = $00000022; // Device Install State ®
  SPDRP_LOCATION_PATHS              = $00000023; // Device Location Paths ®
  SPDRP_MAXIMUM_PROPERTY            = $00000024; // Upper bound on ordinals
  {$EXTERNALSYM SPDRP_MAXIMUM_PROPERTY}

type
  PDevBroadcastHdr  = ^DEV_BROADCAST_HDR;
  DEV_BROADCAST_HDR = packed record
    dbch_size: DWORD;
    dbch_devicetype: DWORD;
    dbch_reserved: DWORD;
  end;

  PDevBroadcastVolume       =  ^DEV_BROADCAST_VOLUME;
  DEV_BROADCAST_VOLUME      =  packed record
     dbch_size:              DWORD;
     dbch_devicetype:        DWORD;
     dbch_reserved:          DWORD;
     dbcv_unitmask:          DWORD;
     dbcv_flags:             WORD;
  end;
  
  PDevBroadcastDeviceInterface  = ^DEV_BROADCAST_DEVICEINTERFACE;
  DEV_BROADCAST_DEVICEINTERFACE = record
    dbcc_size: DWORD;
    dbcc_devicetype: DWORD;
    dbcc_reserved: DWORD;
    dbcc_classguid: TGUID;
    dbcc_name: AnsiChar;
  end;

  PSPDevInfoData = ^TSPDevInfoData;
  SP_DEVINFO_DATA = packed record
    cbSize: DWORD;
    ClassGuid: TGUID;
    DevInst: DWORD; // DEVINST handle
    Reserved: PCardinal;
  end;
  TSPDevInfoData = SP_DEVINFO_DATA;

  PSPDeviceInterfaceData = ^TSPDeviceInterfaceData;
  SP_DEVICE_INTERFACE_DATA = packed record
    cbSize: DWORD;
    InterfaceClassGuid: TGUID;
    Flags: DWORD;
    Reserved: PCardinal;
  end;
  TSPDeviceInterfaceData = SP_DEVICE_INTERFACE_DATA;

  PSPDeviceInterfaceDetailData = ^TSPDeviceInterfaceDetailData;
  SP_DEVICE_INTERFACE_DETAIL_DATA = packed record
    cbSize: DWORD;
    DevicePath: array [1..150] of AnsiChar;
  end;
  TSPDeviceInterfaceDetailData = SP_DEVICE_INTERFACE_DETAIL_DATA;

  HDEVINFO = THandle;

  TComponentUSB = class(TComponent)
  private
    FWindowHandle: HWND;
    FOnUSBArrival: TNotifyEvent;
    FOnUSBRemove: TNotifyEvent;
    procedure WndProc(var Msg: TMessage);
    function USBRegister: Boolean;
  protected
    procedure WMDeviceChange(var Msg: TMessage); dynamic;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    property OnUSBArrival: TNotifyEvent read FOnUSBArrival write FOnUSBArrival;
    property OnUSBRemove: TNotifyEvent read FOnUSBRemove write FOnUSBRemove;
  end;

function SetupDiCreateDeviceInfoList(
  ClassGuid:PGuid;
  hwndParent:HWND):HDEVINFO;
  stdcall; external 'setupapi.dll';
function SetupDiGetClassDevsExA(
  ClassGuid:PGuid;
  Enumerator:PChar;
  hwndParent:cardinal;
  Flags:DWord;
  DeviceInfoSet:HDEVINFO;
  MachineName:PChar;
  Reserved:DWord):HDEVINFO;
  stdcall; external 'setupapi.dll';
function SetupDiGetDeviceRegistryPropertyA(
  DeviceInfoSet:HDEVINFO;
  DeviceInfoData:PSPDEVINFODATA;
  Property_:DWord;
  PropertyRegDataType:PDWORD;
  PropertyBuffer:Pointer;
  PropertyBufferSize:cardinal;
  RequiredSize:PDWORD):longbool;
  stdcall; external 'setupapi.dll';
function SetupDiEnumDeviceInfo(
  DeviceInfoSet:HDEVINFO;
  MemberIndex:DWord;
  DeviceInfoData:PSPDEVINFODATA):longbool;
  stdcall; external 'setupapi.dll';
function SetupDiEnumDeviceInterfaces(
  DeviceInfoSet: HDEVINFO;
  DeviceInfoData: PSPDevInfoData;
  const InterfaceClassGuid: TGUID;
  MemberIndex: DWORD;
  var DeviceInterfaceData: TSPDeviceInterfaceData): BOOL;
  stdcall; external 'SetupApi.dll';
function SetupDiGetDeviceInterfaceDetailA(
  DeviceInfoSet: HDEVINFO;
  DeviceInterfaceData: PSPDeviceInterfaceData;
  DeviceInterfaceDetailData: PSPDeviceInterfaceDetailData;
  DeviceInterfaceDetailDataSize: DWORD;
  RequiredSize: PDWORD;
  Device: PSPDevInfoData): BOOL;
  stdcall; external 'SetupApi.dll';
function SetupDiDestroyDeviceInfoList(DeviceInfoSet:HDEVINFO):longbool; stdcall; external 'setupapi.dll';
function SetupDiGetClassDevsA(ClassGuid:PGuid; Enumerator:PChar; hwndParent:HWND; Flags:DWord):HDEVINFO; stdcall; external 'setupapi.dll';

var
  Datos: PDevBroadcastHdr;
  DatDev:PDevBroadcastVolume;
  intf_name:AnsiString;

implementation

constructor TComponentUSB.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FWindowHandle := AllocateHWnd(WndProc);
  USBRegister;
end;

destructor TComponentUSB.Destroy;
begin
  DeallocateHWnd(FWindowHandle);
  inherited Destroy;
end;

procedure TComponentUSB.WndProc(var Msg: TMessage);
begin
  if (Msg.Msg = WM_DEVICECHANGE) then 
  begin
    try
      WMDeviceChange(Msg);
    except
      Application.HandleException(Self);
    end;
  end
  else Msg.Result := DefWindowProc(FWindowHandle, Msg.Msg, Msg.wParam, Msg.lParam);
end;

procedure TComponentUSB.WMDeviceChange(var Msg: TMessage);
begin
  if (Msg.wParam = DBT_DEVICEARRIVAL) or (Msg.wParam = DBT_DEVICEREMOVECOMPLETE) then 
  begin
    Datos := PDevBroadcastHdr(Msg.lParam);
    if Datos^.dbch_devicetype = DBT_DEVTYP_DEVICEINTERFACE then 
    begin // USB Device
      if Msg.wParam = DBT_DEVICEARRIVAL then 
      begin
        intf_name:=StrPas(@PDevBroadcastDeviceInterface(Datos)^.dbcc_name);
      end 
      else 
      begin
        intf_name:='';
      end;
    end;
    if Datos^.dbch_devicetype = DBT_DEVTYP_VOLUME{DEVICEINTERFACE} then 
    begin // USB Device
      DatDev:=PDevBroadcastVolume(Msg.lParam);
      if (DatDev^.dbcv_unitmask and $3FFFFFF) <> 0 then
      begin
        // only devices with drive letter
        if Msg.wParam = DBT_DEVICEARRIVAL then 
        begin
          if Assigned(FOnUSBArrival) then FOnUSBArrival(Self);
        end 
        else 
        begin
          if Assigned(FOnUSBRemove) then FOnUSBRemove(Self);
        end;
      end;
    end;
  end;
end;

function TComponentUSB.USBRegister: Boolean;
var
  dbi: DEV_BROADCAST_DEVICEINTERFACE;
  Size: Integer;
  r: Pointer;
begin
  Result := False;
  Size := SizeOf(DEV_BROADCAST_DEVICEINTERFACE);
  ZeroMemory(@dbi, Size);
  dbi.dbcc_size := Size;
  dbi.dbcc_devicetype := DBT_DEVTYP_DEVICEINTERFACE;
  dbi.dbcc_reserved := 0;
  dbi.dbcc_classguid  := GUID_DEVINTERFACE_USB_DEVICE;
  dbi.dbcc_name := #0;

  r := RegisterDeviceNotification(FWindowHandle, @dbi, DEVICE_NOTIFY_WINDOW_HANDLE);
  if Assigned(r) then Result := True;
end;

end.
