unit uAuth;

interface
uses
  windows,comobj,sysutils,registry,dialogs,forms,strutils,winsock;
const
  APP_ID='aa';
  ROOT_KEY=HKEY_LOCAL_MACHINE;
  APP_KEY='Software\myphone\'+APP_ID;
  DEVICE_ID_VALUE='device_id';
  USER_ID_VALUE='user_id';
  AUTH_CODE_VALUE='auth_code';
  AUTH_TIME_VALUE='auth_time';
  AUTH_LENGTH='auth_length';

  USER_ID='0000';
  SERVER_PORT=8888;
  //SERVER_IP='127.0.0.1';
  SERVER_IP='154.221.19.215';
  //SERVER_IP='103.97.3.61';

  function getGUID():string;
  function authorize():boolean;
  function RemoteAuth(txt:string):string;
  //-----------------------------------------------------------------
  function getRegString(key:string;value:string):string;
  function SetRegString(key:string;value:string;data:string):boolean;
  function getReginteger(key:string;value:string):integer;
  function SetRegInteger(key:string;value:string;data:integer):boolean;

  function SetRegTime(key:string;value:string;data:tDateTime):boolean;
  function SetRegInt(key:string;value:string;data:integer):boolean;
implementation
//comobj
function RemoteAuth(txt:string):string;
var
  wd:TWSAData;
  res,sock:integer;
  addr:TSockAddrIn;
  buf:array[0..31] of ansichar;
  tmp:ansistring;
begin
  result:='';
  res:=WSAStartup(MakeWord(2,2),wd);
  if(res<>0)then begin
    showmessage('�������');
     //application.Terminate;
     exit;
  end;
  sock:=socket(PF_INET,SOCK_STREAM,0);
  if INVALID_SOCKET = sock then begin
    showmessage('�������');
     //application.Terminate;
     exit;
  end;
  addr.sin_family:=PF_INET;
  addr.sin_port:=htons(SERVER_PORT);
  addr.sin_addr.S_addr:=inet_addr(PansiChar(SERVER_IP));
  res:=connect(sock,addr,SizeOf(addr));
  if res = SOCKET_ERROR then begin
    closesocket(sock);
    showmessage('���ӷ�����ʧ�ܣ�');
    //application.Terminate;
    exit;
  end;
  tmp:=ansistring(txt);
  copymemory(@buf[0],@tmp[1],length(tmp));
  res:=send(sock,buf,length(tmp),0);
  if res <> length(txt) then begin
    closesocket(sock);
    showmessage('��������ʧ�ܣ�');
    //application.Terminate;
    exit;
  end;
  zeromemory(@buf[0],sizeof(buf));
  res:=recv(sock,buf,SizeOf(buf),0);
  if (SOCKET_ERROR=res) then begin
    closesocket(sock);
    showmessage('��������ʧ�ܣ�');
    //application.Terminate;
    exit;
  end;
  result:=buf;
  closesocket(sock);
  WSACleanup();
end;
function getGUID():string;
 var
  sGUID: string;
begin
  sGUID := CreateClassID;
  //ShowMessage(sGUID); // ���ߴ������ŵ�Guid
  Delete(sGUID, 1, 1);
  Delete(sGUID, Length(sGUID), 1);
  //ShowMessage(sGUID); // ȥ�������ŵ�Guid��ռ36λ�м��м���
  sGUID:= StringReplace(sGUID, '-', '', [rfReplaceAll]);
  //ShowMessage(sGUID); // ȥ�����ŵ�Guid��ռ32λ
  result:=sGUID;
end;
function authorize():boolean;
var
  deviceID,authCode,txt,op:string;
begin
  result:=false;
  deviceID:=getRegString(app_key,DEVICE_ID_VALUE);
  authCode:=getRegString(app_key,AUTH_CODE_VALUE);
  if(length(deviceID)<>32) or (length(authCode)<>12)then begin //1.��������Ի���
     authCode:= InputBox('��������Ȩ�룺','��Ȩ�룺','');//�����ֱ�Ϊ���⣬��ʾ��Ĭ��ֵ
     authCode:=trim(authCode);
     if(length(authCode)<>12)then begin  //��Ȩ���������
       showmessage('��Ȩ���������');
       //application.Terminate;
       exit;
     end;
     //deviceID:=leftstr(getGUID(),12);
     deviceID:=getGUID();
     txt:='01'+APP_ID+authCode+USER_ID+deviceID;
     txt:=RemoteAuth(txt);
     if(txt='')then begin
        //application.Terminate;
       exit;
     end;
     op:=leftstr(txt,2);
     if(op='00')then begin //��Ȩʧ��
        showmessage('��Ȩʧ�ܣ�');
        //application.Terminate;
        exit;
     end;
     if(op='01')then begin //��Ȩ�ɹ�
        showmessage('��Ȩ�ɹ���');
        SetRegString(APP_KEY,DEVICE_ID_VALUE,deviceID);
        SetRegInteger(APP_KEY,USER_ID_VALUE,0);
        SetRegString(APP_KEY,AUTH_CODE_VALUE,authCode);
        SetRegTime(APP_KEY,AUTH_TIME_VALUE,now());
        SetRegInteger(APP_KEY,AUTH_LENGTH,strtoint(rightstr(txt,4)));
        result:=true;
        exit;
     end;
  end;
  txt:='00'+APP_ID+authCode+USER_ID+deviceID;
  txt:=RemoteAuth(txt);
  if(txt='')then begin
    //application.Terminate;
    exit;
  end;
  op:=leftstr(txt,2);
  if(op='00')then begin //��֤ʧ��
    if(txt='000001')then
      showmessage('��Ȩ���ѹ��ڣ�')
    else
      showmessage('��֤ʧ�ܣ�');
    SetRegString(APP_KEY,DEVICE_ID_VALUE,'');
    SetRegString(APP_KEY,AUTH_CODE_VALUE,'');
    //application.Terminate;
    exit;
  end;
  if(op='01')then begin //��֤�ɹ�
    //showmessage('ʣ��ʹ��ʱ�䣺'+rightstr(txt,4));
    result:=true;
  end;
end;
//-----------------------------------------------------------------------
function SetRegInt(key:string;value:string;data:integer):boolean;
var
  reg:TRegistry;
begin
  result:=false;
  reg:=tRegistry.Create;
  reg.RootKey:=ROOT_KEY;
  if(reg.OpenKey(key,true))then begin
    reg.WriteInteger(value,data);
    reg.CloseKey;
    result:=true;
  end;
  reg.Destroy;
end;
function SetRegTime(key:string;value:string;data:tDateTime):boolean;
var
  reg:TRegistry;
begin
  result:=false;
  reg:=tRegistry.Create;
  reg.RootKey:=ROOT_KEY;
  if(reg.OpenKey(key,true))then begin
    reg.WriteDateTime(value,data);
    reg.CloseKey;
    result:=true;
  end;
  reg.Destroy;
end;
function SetRegInteger(key:string;value:string;data:integer):boolean;
var
  reg:TRegistry;
begin
  result:=false;
  reg:=tRegistry.Create;
  reg.RootKey:=ROOT_KEY;
  if(reg.OpenKey(key,true))then begin
    reg.WriteInteger(value,data);
    reg.CloseKey;
    result:=true;
  end;
  reg.Destroy;
end;
function SetRegString(key:string;value:string;data:string):boolean;
var
  reg:TRegistry;
begin
  result:=false;
  reg:=tRegistry.Create;
  reg.RootKey:=ROOT_KEY;
  if(reg.OpenKey(key,true))then begin
    reg.WriteString(value,data);
    reg.CloseKey;
    result:=true;
  end;
  reg.Destroy;
end;
function getReginteger(key:string;value:string):integer;
var
  reg:TRegistry;
begin
  result:=-1;
  reg:=tRegistry.Create;
  reg.RootKey:=ROOT_KEY;
  if(reg.OpenKey(key,false))then begin
    result:=reg.Readinteger(value);
    //reg.wr
    reg.CloseKey;
  end;
  reg.Destroy;
end;
function getRegString(key:string;value:string):string;
var
  reg:TRegistry;
begin
  result:='';
  reg:=tRegistry.Create;
  reg.RootKey:=ROOT_KEY;
  if(reg.OpenKey(key,false))then begin
    result:=reg.ReadString(value);
    reg.CloseKey;
  end;
  reg.Destroy;
end;
end.
