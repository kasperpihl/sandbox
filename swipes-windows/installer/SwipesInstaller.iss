; Script for Inno Setup http://www.jrsoftware.org/isdl.php

#define MyAppName "Swipes"
#define MyAppVersion "0.1.1"
#define MyAppPublisher "Swipes Incorporated"
#define MyAppURL "http://www.swipesapp.com/"
#define MyAppExeName "electron.exe"
#define ElectronLocation "C:\work\electron\electron-v0.31.2-win32-ia32\*"

[Setup]
; NOTE: The value of AppId uniquely identifies this application.
; Do not use the same AppId value in installers for other applications.
; (To generate a new GUID, click Tools | Generate GUID inside the IDE.)
AppId={{26B330DE-18EF-4A59-BF79-884E8B8A3D3C}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
;AppVerName={#MyAppName} {#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}
AppUpdatesURL={#MyAppURL}
DefaultDirName={userpf}\{#MyAppName}
DisableDirPage=yes
DefaultGroupName={#MyAppName}
AllowNoIcons=yes
;LicenseFile=license.rtf
OutputBaseFilename=InstallSwipes
Compression=lzma
SolidCompression=yes
WizardImageFile=swipes-ui-windows-wizard-big.bmp
WizardSmallImageFile=swipes-ui-windows-wizard-small.bmp
                          
[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}";

[Files]
; copy Electron
Source: {#ElectronLocation}; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs
; copy our app
Source: "..\swipes-app\*"; DestDir: "{app}\resources\app"; Excludes: "index_not_used.html"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{group}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"
Name: "{commondesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Tasks: desktopicon
