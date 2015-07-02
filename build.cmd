@echo off
cd %~dp0

SETLOCAL
    SET DNXPATH=%USERPROFILE%\.dnx
    SET DNVMPATH=%DNXPATH%\dnvm
    SET DNVMCMD=%DNVMPATH%\dnvm.cmd
    SET DNVMURI="https://raw.githubusercontent.com/aspnet/Home/dev/dnvm.cmd"

    IF NOT EXIST "%DNVMPATH%" (
        mkdir "%DNVMPATH%"
    )

    IF NOT EXIST "%DNVMCMD%" (
        @powershell -NoProfile -ExecutionPolicy Unrestricted -Command "$ProgressPreference = 'SilentlyContinue'; Invoke-WebRequest '%DNVMURI%' -OutFile '%DNVMCMD%'"

        CALL "%DNVMCMD%" update-self
    )

    CALL "%DNVMCMD%" upgrade -runtime CLR -arch x86
    CALL "%DNVMCMD%" upgrade -runtime CoreCLR -arch x86
    CALL "%DNVMCMD%" use default -runtime CLR -arch x86

    SET NUGETCMD=%LOCALAPPDATA%\NuGet\nuget.exe
    SET NUGETURI="https://www.nuget.org/nuget.exe"

    IF NOT EXIST "%NUGETCMD%" (
        @powershell -NoProfile -ExecutionPolicy Unrestricted -Command "$ProgressPreference = 'SilentlyContinue'; Invoke-WebRequest '%NUGETURI%' -OutFile '%NUGETCMD%'"
    )

    SET NUGETROOT=.nuget
    SET NUGET=%NUGETROOT%\nuget.exe

    IF NOT EXIST "%NUGETROOT%" (
        mkdir "%NUGETROOT%"
    )

    IF NOT EXIST "%NUGET%" (
        cp "%NUGETCMD%" "%NUGET%"
    )

    SET SAKE=packages\Sake\tools\Sake.exe
    SET INCLUDES=src\build\sake
    SET MAKE=make.shade

    IF NOT EXIST "%SAKE%" (
        "%NUGET%" install Sake -pre -o packages -ExcludeVersion
    )
    
    "%SAKE%" -I "%INCLUDES%" -f "%MAKE%" %*
ENDLOCAL