@echo off

setlocal

rem ## First, make sure the batch file exists in the folder we expect it to.  This is necessary in order to
rem ## verify that our relative path to the /Engine/Source directory is correct
if not exist "%~dp0..\..\Source" goto Error_BatchFileInWrongLocation


rem ## Change the CWD to /Engine/Source.  We always need to run UnrealBuildTool from /Engine/Source!
pushd "%~dp0..\..\Source"
if not exist ..\Build\BatchFiles\RunUBT.bat goto Error_BatchFileInWrongLocation

rem ## Check to make sure that we have a Binaries directory with at least one dependency that we know that UnrealBuildTool will need
rem ## in order to run.  It's possible the user acquired source but did not download and unpack the other prerequiste binaries.
if not exist ..\Build\BinaryPrerequisitesMarker.dat goto Error_MissingBinaryPrerequisites

rem ## Verify that dotnet is present
call "%~dp0GetDotnetPath.bat"
if errorlevel 1 goto Error_NoDotnetSDK
REM ## Skip msbuild detection if using dotnet as this is done for us by dotnet-cli

rem Check to see if the files in the UBT directory have changed. We conditionally include platform files from the .csproj file, but MSBuild doesn't recognize the dependency when new files are added. 
md ..\Intermediate\Build >nul 2>nul
dir /s /b Programs\UnrealBuildTool\*.cs >..\Intermediate\Build\UnrealBuildToolFiles.txt

if not exist ..\Platforms goto NoPlatforms
for /d %%D in (..\Platforms\*) do (
	if exist %%D\Source\Programs\UnrealBuildTool dir /s /b %%D\Source\Programs\UnrealBuildTool\*.cs 2> nul >> ..\Intermediate\Build\UnrealBuildToolFiles.txt
)
:NoPlatforms

if not exist ..\Restricted goto NoRestricted
for /d %%D in (..\Restricted\*) do (
	if exist %%D\Source\Programs\UnrealBuildTool dir /s /b %%D\Source\Programs\UnrealBuildTool\*.cs 2> nul >> ..\Intermediate\Build\UnrealBuildToolFiles.txt
)
:NoRestricted

fc /b ..\Intermediate\Build\UnrealBuildToolFiles.txt ..\Intermediate\Build\UnrealBuildToolPrevFiles.txt >nul 2>nul
if not errorlevel 1 goto SkipClean
copy /y ..\Intermediate\Build\UnrealBuildToolFiles.txt ..\Intermediate\Build\UnrealBuildToolPrevFiles.txt >nul

dotnet clean Programs\UnrealBuildTool\UnrealBuildTool.csproj -c Development -v quiet

:SkipClean
echo Building UnrealBuildTool...
dotnet build Programs\UnrealBuildTool\UnrealBuildTool.csproj -c Development -v quiet
if errorlevel 1 goto Error_UBTCompileFailed

rem ## Run UnrealBuildTool to generate Visual Studio solution and project files
rem ## NOTE: We also pass along any arguments here
dotnet ..\Binaries\DotNET\UnrealBuildTool\UnrealBuildTool.dll %*
if errorlevel 1 goto Error_UBTRunFailed

rem ## Success!
popd
exit /B 0

:Error_BatchFileInWrongLocation
echo.
echo RunUBT ERROR: The batch file does not appear to be located in the /Engine/Build/BatchFiles directory.  This script must be run from within that directory.
echo.
set RUNUBT_EXITCODE=1
goto Exit


:Error_MissingBinaryPrerequisites
echo.
echo RunUBT ERROR: It looks like you're missing some files that are required in order to run Unreal Build Tool.  Please check that you've downloaded and unpacked the engine source code, binaries, content and third-party dependencies before running this script.
echo.
set RUNUBT_EXITCODE=1
goto Exit

:Error_NoDotnetSDK
echo.
echo RunUBT ERROR: Unable to find a install of Dotnet SDK.  Please make sure you have it installed and that `dotnet` is a globally available command.
echo.
set RUNUBT_EXITCODE=1
goto Exit

:Error_UBTCompileFailed
echo.
echo RunUBT ERROR: UnrealBuildTool failed to compile.
echo.
set RUNUBT_EXITCODE=1
goto Exit


:Error_UBTRunFailed
echo.
echo RUNUBT ERROR: UnrealBuildTool exited with a failure
echo.
set RUNUBT_EXITCODE=%ERRORLEVEL%
goto Exit


:Exit
rem ## Restore original CWD in case we change it
popd
exit /B %RUNUBT_EXITCODE%
