library hookMsgDll;

uses
  SysUtils,
  Windows,
  Classes,
  unitHook in 'unitHook.pas';

{$R *.res}

const
  HOOK_MEM_FILENAME = 'tmp.hkt';

var
  hhk: HHOOK;
  Hook: array[0..4] of TNtHookClass;

  //内存映射
  MemFile: THandle;
  startPid: PDWORD;   //保存PID

{--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--}

//拦截 MessageBoxA

function NewMessageBoxA(_hWnd: HWND; lpText, lpCaption: PAnsiChar; uType: UINT): Integer; stdcall;
type
  TNewMessageBoxA = function(_hWnd: HWND; lpText, lpCaption: PAnsiChar; uType: UINT): Integer; stdcall;
begin
  lpText := PAnsiChar('已经被拦截 MessageBoxA');
  Hook[0].UnHook;
  Result := TNewMessageBoxA(Hook[0].BaseAddr)(_hWnd, lpText, lpCaption, uType);
  Hook[0].Hook;
end;

//拦截 MessageBoxW
function NewMessageBoxW(_hWnd: HWND; lpText, lpCaption: PWideChar; uType: UINT): Integer; stdcall;
type
  TNewMessageBoxW = function(_hWnd: HWND; lpText, lpCaption: PWideChar; uType: UINT): Integer; stdcall;
begin
  lpText := '已经被拦截 MessageBoxW';
  Hook[2].UnHook;
  Result := TNewMessageBoxW(Hook[2].BaseAddr)(_hWnd, lpText, lpCaption, uType);
  Hook[2].Hook;
end;

procedure NewGetLocalTime(var lpSystemTime: TSystemTime); stdcall;
begin
  Hook[4].UnHook;
  GetLocalTime(lpSystemTime);
  lpSystemTime.wYear := lpSystemTime.wYear - 3;
  Hook[4].Hook;
end;

//拦截 MessageBeep
function NewMessageBeep(uType: UINT): BOOL; stdcall;
type
  TNewMessageBeep = function(uType: UINT): BOOL; stdcall;
begin
  Result := True;
end;

//拦截 OpenProcess , 防止关闭
function NewOpenProcess(dwDesiredAccess: DWORD; bInheritHandle: BOOL; dwProcessId: DWORD): THandle; stdcall;
type
  TNewOpenProcess = function(dwDesiredAccess: DWORD; bInheritHandle: BOOL; dwProcessId: DWORD): THandle; stdcall;
begin
  if startPid^ = dwProcessId then
  begin
    result := 0;
    Exit;
  end;
  Hook[3].UnHook;
  Result := TNewOpenProcess(Hook[3].BaseAddr)(dwDesiredAccess, bInheritHandle, dwProcessId);
  Hook[3].Hook;
end;

{--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--}

//安装API Hook
procedure InitHook;
begin

  Hook[0] := TNtHookClass.Create('user32.dll', 'MessageBoxA', @NewMessageBoxA);
  Hook[1] := TNtHookClass.Create('user32.dll', 'MessageBeep', @NewMessageBeep);
  Hook[2] := TNtHookClass.Create('user32.dll', 'MessageBoxW', @NewMessageBoxW);
  Hook[3] := TNtHookClass.Create('kernel32.dll', 'OpenProcess', @NewOpenProcess);

  Hook[4] := TNtHookClass.Create('kernel32.dll', 'GetLocalTime', @NewGetLocalTime);
end;

//删除API Hook
procedure UninitHook;
var
  I: Integer;
begin
  for I := 0 to High(Hook) do
  begin
    FreeAndNil(Hook[I]);
  end;
end;

{--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--}

//内存映射共想
procedure MemShared();
begin
  MemFile := OpenFileMapping(FILE_MAP_ALL_ACCESS, False, HOOK_MEM_FILENAME);
//打开内存映射文件
  if MemFile = 0 then
  begin  //打开失败则衉c2建内存映射文件
    MemFile := CreateFileMapping($FFFFFFFF, nil, PAGE_READWRITE, 0, 4, HOOK_MEM_FILENAME);
  end;
  if MemFile <> 0 then
//映射文件到变量
    startPid := MapViewOfFile(MemFile, FILE_MAP_ALL_ACCESS, 0, 0, 0);
end;

//传递消息

function HookProc(code: Integer; wparam: WPARAM; lparam: LPARAM): LRESULT; stdcall;
begin
  Result := CallNextHookEx(hhk, code, wParam, lParam);
end;

//开始HOOK
procedure StartHook(pid: DWORD); stdcall;
begin
  startPid^ := pid;
  hhk := SetWindowsHookEx(WH_CALLWNDPROC, HookProc, hInstance, 0);
end;

//结束HOOK
procedure EndHook; stdcall;
begin
  if hhk <> 0 then
    UnhookWindowsHookEx(hhk);
end;

//环境处理
procedure DllEntry(dwResaon: DWORD);
begin
  case dwResaon of
    DLL_PROCESS_ATTACH:
      InitHook;   //DLL载入
    DLL_PROCESS_DETACH:
      UninitHook; //DLL删除
//    DLL_THREAD_ATTACH:
//      InitHook;   //DLL载入
//    DLL_THREAD_DETACH:
//      UninitHook; //DLL删除
  end;
end;

exports
  StartHook,
  EndHook;

begin
  MemShared;
  { 分配DLL程序到 DllProc 变量 }
  DllProc := @DllEntry;
  { 调用DLL加载处理 }
  DllEntry(DLL_PROCESS_ATTACH);
end.

