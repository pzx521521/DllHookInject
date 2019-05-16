object frmHookMsg: TfrmHookMsg
  Left = 0
  Top = 0
  Caption = 'frmHookMsg'
  ClientHeight = 134
  ClientWidth = 227
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 16
    Top = 8
    Width = 48
    Height = 13
    Caption = #36827#31243#21517#23383
  end
  object Label2: TLabel
    Left = 16
    Top = 48
    Width = 15
    Height = 13
    Caption = 'Dll:'
  end
  object EditName: TEdit
    Left = 88
    Top = 5
    Width = 121
    Height = 21
    TabOrder = 0
    Text = 'TestExe.exe'
  end
  object EditDll: TEdit
    Left = 88
    Top = 45
    Width = 121
    Height = 21
    TabOrder = 1
    Text = 'hookMsgDll.dll'
  end
  object Inject: TButton
    Left = 16
    Top = 93
    Width = 193
    Height = 25
    Caption = 'Inject'
    TabOrder = 2
    OnClick = InjectClick
  end
end
