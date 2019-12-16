unit uFuncs;

interface
uses
   SysUtils,windows,system.classes,strutils,registry,urlmon,
   ShlObj;
procedure IEEmulator(VerCode: Integer);

function IsWin64: Boolean;
implementation
procedure IEEmulator(VerCode: Integer);
const
  IE_SET_PATH_32='SOFTWARE\Microsoft\Internet Explorer\MAIN\FeatureControl\FEATURE_BROWSER_EMULATION';
  IE_SET_PATH_64='SOFTWARE\Wow6432Node\Microsoft\Internet Explorer\MAIN\FeatureControl\FEATURE_BROWSER_EMULATION';
var
  RegObj: TRegistry;
  sPath:string;
begin
  RegObj := TRegistry.Create;
  try
    //RegObj.RootKey := HKEY_CURRENT_USER;
    RegObj.RootKey := HKEY_LOCAL_MACHINE;
    RegObj.Access := KEY_ALL_ACCESS;
    if isWin64 then sPath := IE_SET_PATH_64 else sPath:=IE_SET_PATH_32;
    if not RegObj.OpenKey(sPath, False) then exit;
    try
      RegObj.WriteInteger(ExtractFileName(ParamStr(0)), VerCode);
      //regobj.READ
    finally
      RegObj.CloseKey;
    end;
  finally
    RegObj.Free;
  end;
end;
function IsWin64: Boolean;
var
  Kernel32Handle: THandle;
  IsWow64Process: function(Handle: Windows.THandle; var Res: Windows.BOOL): Windows.BOOL; stdcall;
  GetNativeSystemInfo: procedure(var lpSystemInfo: TSystemInfo); stdcall;
  isWoW64: Bool;
  SystemInfo: TSystemInfo;
const
  PROCESSOR_ARCHITECTURE_AMD64 = 9;
  PROCESSOR_ARCHITECTURE_IA64 = 6;
begin
  Kernel32Handle := GetModuleHandle('KERNEL32.DLL');
  if Kernel32Handle = 0 then
    Kernel32Handle := LoadLibrary('KERNEL32.DLL');
  if Kernel32Handle <> 0 then
  begin
    IsWOW64Process := GetProcAddress(Kernel32Handle,'IsWow64Process');
    GetNativeSystemInfo := GetProcAddress(Kernel32Handle,'GetNativeSystemInfo');
    if Assigned(IsWow64Process) then
    begin
      IsWow64Process(GetCurrentProcess,isWoW64);
      Result := isWoW64 and Assigned(GetNativeSystemInfo);
      if Result then
      begin
        GetNativeSystemInfo(SystemInfo);
        Result := (SystemInfo.wProcessorArchitecture = PROCESSOR_ARCHITECTURE_AMD64) or
                  (SystemInfo.wProcessorArchitecture = PROCESSOR_ARCHITECTURE_IA64);
      end;
    end
    else Result := False;
  end
  else Result := False;
end;
end.
