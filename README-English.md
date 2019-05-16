# Dll Inject Example

### Outline

+ 1. There is just someting copy form blog or others website.... 

+ 2. There are 2 funciton for injecting dll to exe

  + 2.1 NtCreateThreadExProc(Inject3.dpr)
  + 2.2  CreateRemoteThread(RemoteInjectDll.dpr)

+ 3. Inject3.dpr only working in Debug... windows' Permission

+ 4. InjectDllRemote.dpr working good without Debug

+ 5. hookMsgDll.dpr is the  injected dll, Blocking some functions inside:

     ```
       Hook[0] := TNtHookClass.Create('user32.dll', 'MessageBoxA', @NewMessageBoxA);
       Hook[1] := TNtHookClass.Create('user32.dll', 'MessageBeep', @NewMessageBeep);
       Hook[2] := TNtHookClass.Create('user32.dll', 'MessageBoxW', @NewMessageBoxW);
       Hook[3] := TNtHookClass.Create('kernel32.dll', 'OpenProcess', @NewOpenProcess);
       Hook[4] := TNtHookClass.Create('kernel32.dll', 'GetLocalTime', @NewGetLocalTime);
     ```

     + 5.1 delphi'fucntion Showmessage&MessageDlg will not uses the windows' MessageBoxW/MessageBoxA, Must pay attention here!!!
     + 5.2 pay attention -> all Blocked funciton must have the mark: stdcall 

+ 6.  TestExe.dpr is the test program, it vertify 5 

### How to test it 

+ 1. Writen all function  you wana blocked , make the dll(hookMsgDll.dpr)
+ 2. make the TestExe be Injected (TestExe.dpr)
+ 3. Choose a Inject Mathod:(Inject3.dpr/InjectDllRemote.dpr) 2 by 1, build The the program, and inject hookMsgDll to TestExe for blocking
+ 4. click the button in TestExe to vertify whether the TestExe is blocked

### About Debug

+ you can put the dll&TestExe in a group, then in dllRun->load process->process input the path of TestExe
+ and then uses:(Inject3.dpr/InjectDllRemote.dpr) for injecting


![getlocalTime.jpg](https://i.loli.net/2019/05/16/5cdd1f272131824039.jpg)
![origin.jpg](https://i.loli.net/2019/05/16/5cdd1f2722e5914814.jpg)
![Meesage.jpg](https://i.loli.net/2019/05/16/5cdd1f2731d2d23520.jpg)



