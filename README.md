# Dll 注入示例

### 说明 

+ 1. 网上的较乱, 这里只是整理了一下

+ 2. 采用了2中注入方式

  + 2.1 NtCreateThreadExProc(Inject3.dpr)
  + 2.2  CreateRemoteThread(RemoteInjectDll.dpr)

+ 3. Inject3.dpr 仅在debug下有效, 权限问题, 暂时未解决

+ 4. InjectDllRemote.dpr 不会出现该权限问题

+ 5. hookMsgDll.dpr 为要注入的dll, 里面拦截了几个函数:

     ```
       Hook[0] := TNtHookClass.Create('user32.dll', 'MessageBoxA', @NewMessageBoxA);
       Hook[1] := TNtHookClass.Create('user32.dll', 'MessageBeep', @NewMessageBeep);
       Hook[2] := TNtHookClass.Create('user32.dll', 'MessageBoxW', @NewMessageBoxW);
       Hook[3] := TNtHookClass.Create('kernel32.dll', 'OpenProcess', @NewOpenProcess);
       Hook[4] := TNtHookClass.Create('kernel32.dll', 'GetLocalTime', @NewGetLocalTime);
     ```

     + 5.1 delphi的Showmessage和MessageDlg 都是不会调用windows的MessageBoxW/MessageBoxA的, 这里困扰我很长时间
     + 5.2 注意拦截的函数必须声明 stdcall 

+ 6.  TestExe.dpr 为测试工程, 里面验证了 5 

### 打开顺序

+ 1. 写好拦截的函数, 编译dll(hookMsgDll.dpr)
+ 2. 写好验证的Exe, 用于被注入(TestExe.dpr)
+ 3. 选择注入方式:(Inject3.dpr/InjectDllRemote.dpr)二选一, 编译并把 hookMsgDll 注入到 TestExe 中 实现拦截
+ 4. 点击TestExe中的按钮进行验证

### 关于调试

+ 可以把dll和TestExe 放在一起为一个group, 同时打开, 然后在dll中Run->load process->process中输入TestExe的路径
+ 然后使用:(Inject3.dpr/InjectDllRemote.dpr)注入即可



