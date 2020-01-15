unit ufrmHookMsg;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, tlhelp32, StdCtrls;

type
  TfrmHookMsg = class(TForm)
    EditName: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    EditDll: TEdit;
    Inject: TButton;
    procedure InjectClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmHookMsg: TfrmHookMsg;

implementation

{$R *.dfm}

{ 列举进程 }
procedure GetMyProcessID(const AFilename: string; const PathMatch: Boolean; var ProcessID: DWORD);
var
  lppe: TProcessEntry32;
  SsHandle: Thandle;
  FoundAProc, FoundOK: boolean;
begin
  ProcessID := 0;
  { 创建系统快照 }
  SsHandle := CreateToolHelp32SnapShot(TH32CS_SnapProcess, 0);

  { 取得快照中的第一个进程 }
  { 一定要设置结构的大小,否则将返回False }
  lppe.dwSize := sizeof(TProcessEntry32);
  FoundAProc := Process32First(SsHandle, lppe);
  while FoundAProc do
  begin
    { 进行匹配 }
    if PathMatch then
      FoundOK := AnsiStricomp(lppe.szExefile, PChar(AFilename)) = 0
    else
      FoundOK := AnsiStricomp(PChar(ExtractFilename(lppe.szExefile)), PChar(ExtractFilename(AFilename))) = 0;
    if FoundOK then
    begin
      ProcessID := lppe.th32ProcessID;
      break;
    end;
    { 未找到,继续下一个进程 }
    FoundAProc := Process32Next(SsHandle, lppe);
  end;
  CloseHandle(SsHandle);
end;

{ 设置权限 }
function EnabledDebugPrivilege(const Enabled: Boolean): Boolean;
var
  hTk: THandle; { 打开令牌句柄 }
  rtnTemp: Dword; { 调整权限时返回的值 }
  TokenPri: TOKEN_PRIVILEGES;
const
  SE_DEBUG = 'SeDebugPrivilege'; { 查询值 }
begin
  Result := False;
  { 获取进程令牌句柄,设置权限 }
  if (OpenProcessToken(GetCurrentProcess(), TOKEN_ADJUST_PRIVILEGES, hTk)) then
  begin
    TokenPri.PrivilegeCount := 1;
    { 获取Luid值 }
    LookupPrivilegeValue(nil, SE_DEBUG, TokenPri.Privileges[0].Luid);

    if Enabled then
      TokenPri.Privileges[0].Attributes := SE_PRIVILEGE_ENABLED
    else
      TokenPri.Privileges[0].Attributes := 0;

    rtnTemp := 0;
    { 设置新的权限 }
    AdjustTokenPrivileges(hTk, False, TokenPri, sizeof(TokenPri), nil, rtnTemp);

    Result := GetLastError = ERROR_SUCCESS;
    CloseHandle(hTk);

  end;
end;

{ 调试函数 }
procedure OutPutText(var CH: PChar);
var
  FileHandle: TextFile;
begin
  AssignFile(FileHandle, 'zztest.txt');
  Append(FileHandle);
  Writeln(FileHandle, CH);
  Flush(FileHandle);
  CloseFile(FileHandle);
end;

{ 注入远程进程 }
function InjectTo(const Host, Guest: string; const PID: DWORD = 0): DWORD;
var
  { 被注入的进程句柄,进程ID}
  hRemoteProcess: THandle;
  dwRemoteProcessId: DWORD;
  { 写入远程进程的内容大小 }
  memSize: DWORD;
  { 写入到远程进程后的地址 }
  pszLibFileRemote: Pointer;
  iReturnCode: Boolean;
  lpNumberOfBytesWritten: THandle;
  lpThreadId: DWORD;
  { 指向函数LoadLibraryW的地址 }
  pfnStartAddr: TFNThreadStartRoutine;
  { dll全路径,需要写到远程进程的内存中去 }
  pszLibAFilename: PwideChar;
begin
  Result := 0;
  { 设置权限 }
  EnabledDebugPrivilege(True);

  { 为注入的dll文件路径分配内存大小,由于为WideChar,故要乘2 }
  Getmem(pszLibAFilename, Length(Guest) * 2 + 1);
  StringToWideChar(Guest, pszLibAFilename, Length(Guest) * 2 + 1);

  { 获取进程ID }
  if PID > 0 then
    dwRemoteProcessId := PID
  else
    GetMyProcessID(Host, False, dwRemoteProcessId);

  { 取得远程进程句柄,具有写入权限}
  hRemoteProcess := OpenProcess(PROCESS_CREATE_THREAD + {允许远程创建线程}
    PROCESS_VM_OPERATION + {允许远程VM操作}
    PROCESS_VM_WRITE, {允许远程VM写}
    FALSE, dwRemoteProcessId);

  { 用函数VirtualAllocex在远程进程分配空间,并用WriteProcessMemory中写入dll路径 }
  memSize := (1 + lstrlenW(pszLibAFilename)) * sizeof(WCHAR);
  pszLibFileRemote := PWIDESTRING(VirtualAllocEx(hRemoteProcess, nil, memSize, MEM_COMMIT, PAGE_READWRITE));
  lpNumberOfBytesWritten := 0;
  iReturnCode := WriteProcessMemory(hRemoteProcess, pszLibFileRemote, pszLibAFilename, memSize, lpNumberOfBytesWritten);
  if iReturnCode then
  begin
    pfnStartAddr := GetProcAddress(GetModuleHandle('Kernel32'), 'LoadLibraryW');
    lpThreadId := 0;
    { 在远程进程中启动dll }
    Result := CreateRemoteThread(hRemoteProcess, nil, 0, pfnStartAddr, pszLibFileRemote, 0, lpThreadId);
  end;
  { 释放内存空间 }
  Freemem(pszLibAFilename);
end;

{ 测试 }
procedure TfrmHookMsg.InjectClick(Sender: TObject);
var
  DllPath: string;
begin
  DllPath := EditDll.Text;
  if (not FileExists(DllPath)) or (ExtractFilePath(DllPath) = '') then
    DllPath := ExtractFilePath(ParamStr(0)) + EditDll.Text;
  if FileExists(DllPath) then
    ShowMessage(IntToStr(InjectTo(EditName.Text, DllPath)))

end;

end.

