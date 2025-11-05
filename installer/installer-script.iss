; IPTV Casper - Windows Installer Script
; Created with Inno Setup 6
; https://jrsoftware.org/isinfo.php

#define MyAppName "IPTV Casper"
#define MyAppVersion "1.0.0"
#define MyAppPublisher "dark0venom"
#define MyAppURL "https://github.com/dark0venom/IPTV-CASPER"
#define MyAppExeName "iptv_casper.exe"
#define MyAppDescription "Modern IPTV Player with Floating Window"

[Setup]
; NOTE: The value of AppId uniquely identifies this application.
; Do not use the same AppId value in installers for other applications.
AppId={{IPTV-CASPER-2025-1.0.0}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}/issues
AppUpdatesURL={#MyAppURL}/releases
DefaultDirName={autopf}\{#MyAppName}
DefaultGroupName={#MyAppName}
AllowNoIcons=yes
LicenseFile=..\LICENSE.txt
InfoBeforeFile=..\installer\info-before.txt
InfoAfterFile=..\installer\info-after.txt
OutputDir=..\installer-output
OutputBaseFilename=IPTV-Casper-Setup-v{#MyAppVersion}
SetupIconFile=..\assets\images\app_icon.ico
Compression=lzma2/ultra64
SolidCompression=yes
WizardStyle=modern
ArchitecturesAllowed=x64
ArchitecturesInstallIn64BitMode=x64
PrivilegesRequired=admin
UninstallDisplayIcon={app}\{#MyAppExeName}
UninstallDisplayName={#MyAppName}
VersionInfoVersion={#MyAppVersion}
VersionInfoCompany={#MyAppPublisher}
VersionInfoDescription={#MyAppDescription}
VersionInfoCopyright=Copyright (C) 2025 {#MyAppPublisher}
MinVersion=10.0.17763

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"
Name: "quicklaunchicon"; Description: "{cm:CreateQuickLaunchIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
Source: "..\production-release\{#MyAppExeName}"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\production-release\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs
; NOTE: Don't use "Flags: ignoreversion" on any shared system files

[Icons]
Name: "{group}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"
Name: "{group}\{cm:UninstallProgram,{#MyAppName}}"; Filename: "{uninstallexe}"
Name: "{autodesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Tasks: desktopicon
Name: "{userappdata}\Microsoft\Internet Explorer\Quick Launch\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Tasks: quicklaunchicon

[Run]
Filename: "{app}\{#MyAppExeName}"; Description: "{cm:LaunchProgram,{#StringChange(MyAppName, '&', '&&')}}"; Flags: nowait postinstall skipifsilent

[Code]
function InitializeSetup(): Boolean;
var
  Version: TWindowsVersion;
begin
  GetWindowsVersionEx(Version);
  
  // Check for Windows 10 version 1809 (10.0.17763) or later
  if (Version.Major < 10) or 
     ((Version.Major = 10) and (Version.Build < 17763)) then
  begin
    MsgBox('This application requires Windows 10 version 1809 (build 17763) or later.' + #13#10 + 
           'Please update your Windows before installing.', mbError, MB_OK);
    Result := False;
  end
  else
    Result := True;
end;

procedure CurStepChanged(CurStep: TSetupStep);
begin
  if CurStep = ssPostInstall then
  begin
    // You can add post-install tasks here
  end;
end;

function NextButtonClick(CurPageID: Integer): Boolean;
begin
  Result := True;
  
  if CurPageID = wpSelectDir then
  begin
    // Validate installation directory
    if Length(WizardDirValue) > 200 then
    begin
      MsgBox('Installation path is too long. Please choose a shorter path.', mbError, MB_OK);
      Result := False;
    end;
  end;
end;

procedure CurUninstallStepChanged(CurUninstallStep: TUninstallStep);
var
  ResultCode: Integer;
begin
  if CurUninstallStep = usPostUninstall then
  begin
    // Clean up any additional files or registry entries
    if MsgBox('Do you want to remove all user data and settings?', mbConfirmation, MB_YESNO) = IDYES then
    begin
      // Add cleanup code here if needed
    end;
  end;
end;
