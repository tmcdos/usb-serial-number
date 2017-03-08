object Form1: TForm1
  Left = 192
  Top = 111
  Width = 490
  Height = 303
  Caption = 'USB serial number detector'
  Color = clBtnFace
  Constraints.MinHeight = 130
  Constraints.MinWidth = 490
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  DesignSize = (
    482
    276)
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 8
    Top = 38
    Width = 395
    Height = 16
    Caption = 'Unplug your USB flash, then plug it again and tell me its name'
    Font.Charset = ANSI_CHARSET
    Font.Color = clGreen
    Font.Height = -13
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Label2: TLabel
    Left = 8
    Top = 58
    Width = 433
    Height = 16
    Caption = #1057#1085#1080#1084#1080#1090#1077' USB '#1092#1083#1077#1096#1082#1091', '#1087#1086#1089#1090#1072#1074#1100#1090#1077' '#1077#1077' '#1089#1085#1086#1074#1072' '#1080' '#1089#1082#1072#1078#1080#1090#1077' '#1084#1085#1077' '#1077#1077' '#1080#1084#1103
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clBlue
    Font.Height = -13
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Label3: TLabel
    Left = 8
    Top = 78
    Width = 456
    Height = 16
    Caption = #1048#1079#1074#1072#1076#1077#1090#1077' USB '#1092#1083#1072#1096#1082#1072#1090#1072', '#1087#1086#1089#1090#1072#1074#1077#1090#1077' '#1103' '#1086#1073#1088#1072#1090#1085#1086' '#1080' '#1084#1080' '#1082#1072#1078#1077#1090#1077' '#1080#1084#1077#1090#1086' '#1081
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clRed
    Font.Height = -13
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object StaticText1: TEdit
    Left = 8
    Top = 8
    Width = 465
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    BevelInner = bvLowered
    HideSelection = False
    ImeMode = imDisable
    ParentColor = True
    ReadOnly = True
    TabOrder = 0
  end
  object btn1: TButton
    Left = 12
    Top = 108
    Width = 113
    Height = 25
    Caption = 'ALL device names'
    TabOrder = 1
    Visible = False
    OnClick = btn1Click
  end
  object memo1: TMemo
    Left = 0
    Top = 144
    Width = 482
    Height = 132
    Align = alBottom
    ScrollBars = ssBoth
    TabOrder = 2
  end
  object btn3: TButton
    Left = 192
    Top = 108
    Width = 75
    Height = 25
    Caption = 'Show USB'
    TabOrder = 3
    OnClick = btn3Click
  end
end
