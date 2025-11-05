; IPTV Casper - Inno Setup Installer Script
; This script creates a professional Windows installer for IPTV Casper

#define MyAppName "IPTV Casper"
#define MyAppVersion "1.0.0"
#define MyAppPublisher "dark0venom"
#define MyAppURL "https://github.com/dark0venom/IPTV-CASPER"
#define MyAppExeName "iptv_casper.exe"
#define MyAppDescription "Professional IPTV Player with Floating Window"

[Setup]
; NOTE: The value of AppId uniquely identifies this application.
; Do not use the same AppId value in installers for other applications.
AppId={{8A5F3B2C-9D4E-4F1A-B3C5-7E9A1D6F8B2C}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppVerName={#MyAppName} {#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}/issues
AppUpdatesURL={#MyAppURL}/releases
DefaultDirName={autopf}\{#MyAppName}
DefaultGroupName={#MyAppName}
AllowNoIcons=yes
LicenseFile=..\LICENSE.txt
InfoBeforeFile=..\installer\info_before.txt
InfoAfterFile=..\installer\info_after.txt
OutputDir=..\installer\output
OutputBaseFilename=IPTV-Casper-Setup-v{#MyAppVersion}
SetupIconFile=..\assets\images\app_icon.ico
UninstallDisplayIcon={app}\{#MyAppExeName}
Compression=lzma2/max
SolidCompression=yes
WizardStyle=modern
ArchitecturesAllowed=x64
ArchitecturesInstallIn64BitMode=x64
PrivilegesRequired=admin
DisableProgramGroupPage=yes
; Windows version requirements
MinVersion=10.0.17763

; Wizard images (optional - uncomment if you have custom images)
;WizardImageFile=..\installer\wizard-image.bmp
;WizardSmallImageFile=..\installer\wizard-small-image.bmp

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked
Name: "quicklaunchicon"; Description: "{cm:CreateQuickLaunchIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked; OnlyBelowVersion: 6.1; Check: not IsAdminInstallMode
Name: "fileassoc"; Description: "Associate .m3u and .m3u8 files with {#MyAppName}"; GroupDescription: "File Associations:"

[Files]
; Main application files
Source: "..\production-release\{#MyAppExeName}"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\production-release\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs
; Documentation
Source: "..\production-release\README.txt"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\CHANGELOG.md"; DestDir: "{app}\docs"; Flags: ignoreversion
Source: "..\FLOATING_WINDOW_GUIDE.md"; DestDir: "{app}\docs"; Flags: ignoreversion
; License
Source: "..\LICENSE.txt"; DestDir: "{app}"; Flags: ignoreversion
; NOTE: Don't use "Flags: ignoreversion" on any shared system files

[Icons]
; Start Menu icons
Name: "{group}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Comment: "{#MyAppDescription}"
Name: "{group}\{cm:ProgramOnTheWeb,{#MyAppName}}"; Filename: "{#MyAppURL}"
Name: "{group}\Documentation"; Filename: "{app}\docs"
Name: "{group}\{cm:UninstallProgram,{#MyAppName}}"; Filename: "{uninstallexe}"
; Desktop icon
Name: "{autodesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Tasks: desktopicon; Comment: "{#MyAppDescription}"
; Quick Launch icon
Name: "{userappdata}\Microsoft\Internet Explorer\Quick Launch\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Tasks: quicklaunchicon

[Registry]
; File associations for .m3u files
Root: HKCR; Subkey: ".m3u"; ValueType: string; ValueName: ""; ValueData: "IPTVCasperPlaylist"; Flags: uninsdeletevalue; Tasks: fileassoc
Root: HKCR; Subkey: "IPTVCasperPlaylist"; ValueType: string; ValueName: ""; ValueData: "IPTV Casper Playlist"; Flags: uninsdeletekey; Tasks: fileassoc
Root: HKCR; Subkey: "IPTVCasperPlaylist\DefaultIcon"; ValueType: string; ValueName: ""; ValueData: "{app}\{#MyAppExeName},0"; Tasks: fileassoc
Root: HKCR; Subkey: "IPTVCasperPlaylist\shell\open\command"; ValueType: string; ValueName: ""; ValueData: """{app}\{#MyAppExeName}"" ""%1"""; Tasks: fileassoc

; File associations for .m3u8 files
Root: HKCR; Subkey: ".m3u8"; ValueType: string; ValueName: ""; ValueData: "IPTVCasperPlaylist"; Flags: uninsdeletevalue; Tasks: fileassoc
Root: HKCR; Subkey: "IPTVCasperPlaylist8"; ValueType: string; ValueName: ""; ValueData: "IPTV Casper Playlist"; Flags: uninsdeletekey; Tasks: fileassoc
Root: HKCR; Subkey: "IPTVCasperPlaylist8\DefaultIcon"; ValueType: string; ValueName: ""; ValueData: "{app}\{#MyAppExeName},0"; Tasks: fileassoc
Root: HKCR; Subkey: "IPTVCasperPlaylist8\shell\open\command"; ValueType: string; ValueName: ""; ValueData: """{app}\{#MyAppExeName}"" ""%1"""; Tasks: fileassoc

; Application paths
Root: HKLM; Subkey: "Software\Microsoft\Windows\CurrentVersion\App Paths\{#MyAppExeName}"; ValueType: string; ValueName: ""; ValueData: "{app}\{#MyAppExeName}"; Flags: uninsdeletekey
Root: HKLM; Subkey: "Software\Microsoft\Windows\CurrentVersion\App Paths\{#MyAppExeName}"; ValueType: string; ValueName: "Path"; ValueData: "{app}"

[Run]
; Option to launch the application after installation
Filename: "{app}\{#MyAppExeName}"; Description: "{cm:LaunchProgram,{#StringChange(MyAppName, '&', '&&')}}"; Flags: nowait postinstall skipifsilent

[UninstallDelete]
; Clean up any files created by the application
Type: filesandordirs; Name: "{app}\data"
Type: filesandordirs; Name: "{userappdata}\{#MyAppName}"

[Code]
// Custom Pascal Script functions

// Check if .NET Framework or required components are installed
function InitializeSetup(): Boolean;
begin
  Result := True;
  
  // Add any pre-installation checks here
  if not IsWindows10OrLater then
  begin
    MsgBox('This application requires Windows 10 or later.', mbError, MB_OK);
    Result := False;
  end;
end;

function IsWindows10OrLater: Boolean;
begin
  Result := (GetWindowsVersion >= $0A000000); // Windows 10 is version 10.0
end;

// Check if the app is currently running before uninstall
function InitializeUninstall(): Boolean;
var
  ErrorCode: Integer;
begin
  Result := True;
  
  // Try to find if the app is running
  if CheckForMutexes('Global\{#MyAppName}') then
  begin
    if MsgBox('The application is currently running. Please close it before uninstalling.' + #13#10 + #13#10 + 
              'Do you want to force close it now?', mbConfirmation, MB_YESNO) = IDYES then
    begin
      // Try to close the application gracefully
      Exec('taskkill', '/F /IM {#MyAppExeName}', '', SW_HIDE, ewWaitUntilTerminated, ErrorCode);
      Sleep(1000); // Wait for process to close
      Result := True;
    end
    else
      Result := False;
  end;
end;

// Custom page for additional options
procedure CurStepChanged(CurStep: TSetupStep);
begin
  if CurStep = ssPostInstall then
  begin
    // Perform any post-installation tasks here
    // For example, setting up default configurations
  end;
end;

// Cleanup on uninstall
procedure CurUninstallStepChanged(CurUninstallStep: TUninstallStep);
begin
  if CurUninstallStep = usPostUninstall then
  begin
    // Perform cleanup tasks
    if MsgBox('Do you want to remove all user settings and playlists?', mbConfirmation, MB_YESNO) = IDYES then
    begin
      DelTree(ExpandConstant('{userappdata}\{#MyAppName}'), True, True, True);
    end;
  end;
end;

[CustomMessages]
english.LaunchProgram=Launch IPTV Casper
english.CreateDesktopIcon=Create a &desktop icon
english.CreateQuickLaunchIcon=Create a &Quick Launch icon
