@echo off
chcp 65001 > nul
setlocal enabledelayedexpansion

:: 배치 파일의 현재 위치 가져오기
set "SCRIPT_PATH=%~dp0"
set "TEMP_FILE=%SCRIPT_PATH%temp.txt"

:: 로그 파일 이름 설정 (간단한 이름 사용)
set "LOGFILE=%SCRIPT_PATH%system_check_result.txt"
set "SUMMARY_FILE=%SCRIPT_PATH%system_check_summary.txt"

echo 로그 파일이 "%LOGFILE%"에 저장됩니다...

:: 로그 파일 헤더 작성
echo =========================================== > "%LOGFILE%"
echo     시스템 하드웨어 점검 스크립트 결과     >> "%LOGFILE%"
echo 점검 날짜: %date% %time%                   >> "%LOGFILE%"
echo =========================================== >> "%LOGFILE%"
echo. >> "%LOGFILE%"

echo ===================================
echo     시스템 하드웨어 점검 스크립트
echo ===================================
echo.

echo 1. 그래픽 드라이버 확인 중...
echo 1. 그래픽 드라이버 확인 결과 >> "%LOGFILE%"
echo ----------------------------------- >> "%LOGFILE%"
echo -----------------------------------
wmic path win32_VideoController get Name, DriverVersion > "%TEMP_FILE%" 2>&1
type "%TEMP_FILE%"
type "%TEMP_FILE%" >> "%LOGFILE%"
echo. >> "%LOGFILE%"
echo.

echo 2. 설치된 파이썬 버전 확인 중...
echo 2. 설치된 파이썬 버전 확인 결과 >> "%LOGFILE%"
echo ----------------------------------- >> "%LOGFILE%"
echo -----------------------------------
echo 파이썬 버전 확인 방법 1: >> "%LOGFILE%"
echo 파이썬 버전 확인 방법 1:
where python > "%TEMP_FILE%" 2>&1
type "%TEMP_FILE%"
type "%TEMP_FILE%" >> "%LOGFILE%"
echo. >> "%LOGFILE%"
echo.

if exist "%TEMP_FILE%" (
    findstr /C:"python" "%TEMP_FILE%" > nul
    if !errorlevel! equ 0 (
        echo 파이썬이 설치되어 있습니다. >> "%LOGFILE%"
        echo 파이썬이 설치되어 있습니다.
    ) else (
        echo 파이썬을 찾을 수 없습니다. >> "%LOGFILE%"
        echo 파이썬을 찾을 수 없습니다.
    )
)
echo. >> "%LOGFILE%"
echo.

echo 모든 파이썬 버전: >> "%LOGFILE%"
echo 모든 파이썬 버전:
python --version > "%TEMP_FILE%" 2>&1
type "%TEMP_FILE%"
type "%TEMP_FILE%" >> "%LOGFILE%"
echo. >> "%LOGFILE%"
echo.

echo PATH에 있는 다른 파이썬 버전 확인: >> "%LOGFILE%"
echo PATH에 있는 다른 파이썬 버전 확인:
echo. >> "%LOGFILE%"
echo.

set "FOUND_PYTHON=0"
for /f "delims=" %%i in ('where python 2^>nul') do (
    set "FOUND_PYTHON=1"
    echo 위치: %%i >> "%LOGFILE%"
    echo 위치: %%i
    "%%i" --version > "%TEMP_FILE%" 2>&1
    type "%TEMP_FILE%"
    type "%TEMP_FILE%" >> "%LOGFILE%"
    echo. >> "%LOGFILE%"
    echo.
)

if !FOUND_PYTHON! equ 0 (
    echo PATH에서 파이썬을 찾을 수 없습니다. >> "%LOGFILE%"
    echo PATH에서 파이썬을 찾을 수 없습니다.
    echo. >> "%LOGFILE%"
    echo.
)

echo 파이썬 버전 확인 방법 2 (레지스트리): >> "%LOGFILE%"
echo 파이썬 버전 확인 방법 2 (레지스트리):
reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Python" /s > "%TEMP_FILE%" 2>&1
type "%TEMP_FILE%"
type "%TEMP_FILE%" >> "%LOGFILE%"
echo. >> "%LOGFILE%"
echo.

reg query "HKEY_CURRENT_USER\SOFTWARE\Python" /s > "%TEMP_FILE%" 2>&1
type "%TEMP_FILE%"
type "%TEMP_FILE%" >> "%LOGFILE%"
echo. >> "%LOGFILE%"
echo.

echo 3. CUDA 버전 확인 중...
echo 3. CUDA 버전 확인 결과 >> "%LOGFILE%"
echo ----------------------------------- >> "%LOGFILE%"
echo -----------------------------------

:: CUDA 기본 경로 확인
echo CUDA 설치 디렉토리 확인: >> "%LOGFILE%"
echo CUDA 설치 디렉토리 확인:

set "CUDA_BASE_DIR=C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA"
set "CUDA_FOUND=0"

if exist "%CUDA_BASE_DIR%" (
    echo CUDA 기본 경로 발견: "%CUDA_BASE_DIR%" >> "%LOGFILE%"
    echo CUDA 기본 경로 발견: "%CUDA_BASE_DIR%"
    
    echo. >> "%LOGFILE%"
    echo.
    
    echo 설치된 CUDA 버전 목록: >> "%LOGFILE%"
    echo 설치된 CUDA 버전 목록:
    dir "%CUDA_BASE_DIR%" /b > "%TEMP_FILE%" 2>&1
    type "%TEMP_FILE%"
    type "%TEMP_FILE%" >> "%LOGFILE%"
    echo. >> "%LOGFILE%"
    echo.
    
    set "CUDA_FOUND=1"
    
    :: 각 CUDA 버전 폴더 확인
    for /d %%d in ("%CUDA_BASE_DIR%\v*") do (
        echo CUDA 버전: %%~nxd >> "%LOGFILE%"
        echo CUDA 버전: %%~nxd
        
        if exist "%%d\bin\nvcc.exe" (
            echo NVCC 컴파일러 정보: >> "%LOGFILE%"
            echo NVCC 컴파일러 정보:
            "%%d\bin\nvcc.exe" --version > "%TEMP_FILE%" 2>&1
            type "%TEMP_FILE%"
            type "%TEMP_FILE%" >> "%LOGFILE%"
            echo. >> "%LOGFILE%"
            echo.
        ) else (
            echo NVCC 컴파일러를 찾을 수 없습니다. >> "%LOGFILE%"
            echo NVCC 컴파일러를 찾을 수 없습니다.
            echo. >> "%LOGFILE%"
            echo.
        )
        
        :: CUDA 라이브러리 확인
        if exist "%%d\lib" (
            echo CUDA 라이브러리 경로: %%d\lib >> "%LOGFILE%"
            echo CUDA 라이브러리 경로: %%d\lib
            
            :: CUDA 라이브러리 파일 중 일부만 표시
            dir "%%d\lib\*.dll" /b | findstr "cudart" > "%TEMP_FILE%" 2>&1
            if !errorlevel! equ 0 (
                echo CUDA 런타임 라이브러리: >> "%LOGFILE%"
                echo CUDA 런타임 라이브러리:
                type "%TEMP_FILE%"
                type "%TEMP_FILE%" >> "%LOGFILE%"
            ) else (
                echo CUDA 런타임 라이브러리를 찾을 수 없습니다. >> "%LOGFILE%"
                echo CUDA 런타임 라이브러리를 찾을 수 없습니다.
            )
            echo. >> "%LOGFILE%"
            echo.
        )
    )
) else (
    echo CUDA 기본 경로를 찾을 수 없습니다: "%CUDA_BASE_DIR%" >> "%LOGFILE%"
    echo CUDA 기본 경로를 찾을 수 없습니다: "%CUDA_BASE_DIR%"
    echo. >> "%LOGFILE%"
    echo.
)

:: NVIDIA-SMI 확인
echo NVIDIA-SMI 정보: >> "%LOGFILE%"
echo NVIDIA-SMI 정보:
nvidia-smi > "%TEMP_FILE%" 2>&1
set "SMI_ERROR=%ERRORLEVEL%"
type "%TEMP_FILE%"
type "%TEMP_FILE%" >> "%LOGFILE%"

if %SMI_ERROR% NEQ 0 (
    echo NVIDIA-SMI를 찾을 수 없습니다. NVIDIA 드라이버가 제대로 설치되지 않았을 수 있습니다. >> "%LOGFILE%"
    echo NVIDIA-SMI를 찾을 수 없습니다. NVIDIA 드라이버가 제대로 설치되지 않았을 수 있습니다.
) else (
    :: NVIDIA-SMI에서 CUDA 버전 추출
    findstr /C:"CUDA Version" "%TEMP_FILE%" > "%TEMP_FILE%.cuda" 2>&1
    if !errorlevel! equ 0 (
        echo NVIDIA-SMI에서 보고된 CUDA 버전: >> "%LOGFILE%"
        echo NVIDIA-SMI에서 보고된 CUDA 버전:
        type "%TEMP_FILE%.cuda"
        type "%TEMP_FILE%.cuda" >> "%LOGFILE%"
    )
    if exist "%TEMP_FILE%.cuda" del "%TEMP_FILE%.cuda" > nul 2>&1
)
echo. >> "%LOGFILE%"
echo.

:: 시스템 경로에서 CUDA 관련 항목 확인
echo 시스템 PATH에서 CUDA 관련 항목 확인: >> "%LOGFILE%"
echo 시스템 PATH에서 CUDA 관련 항목 확인:
echo %PATH% > "%TEMP_FILE%"

findstr /i "CUDA" "%TEMP_FILE%" > "%TEMP_FILE%.cuda" 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo PATH에서 CUDA 경로를 찾을 수 없습니다. >> "%LOGFILE%"
    echo PATH에서 CUDA 경로를 찾을 수 없습니다.
) else (
    type "%TEMP_FILE%.cuda"
    type "%TEMP_FILE%.cuda" >> "%LOGFILE%"
)
if exist "%TEMP_FILE%.cuda" del "%TEMP_FILE%.cuda" > nul 2>&1
echo. >> "%LOGFILE%"
echo.

:: 환경 변수 확인
echo CUDA 관련 환경 변수 확인: >> "%LOGFILE%"
echo CUDA 관련 환경 변수 확인:
set | findstr /i "CUDA" > "%TEMP_FILE%" 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo CUDA 관련 환경 변수를 찾을 수 없습니다. >> "%LOGFILE%"
    echo CUDA 관련 환경 변수를 찾을 수 없습니다.
) else (
    type "%TEMP_FILE%"
    type "%TEMP_FILE%" >> "%LOGFILE%"
)
echo. >> "%LOGFILE%"
echo.

echo ===================================
echo          점검 완료
echo ===================================
echo 결과가 "%LOGFILE%" 파일에 저장되었습니다.
echo.

:: 그래픽 드라이버, 파이썬, CUDA 버전 정보 수집
set "GPU_INFO="
set "PYTHON_VERSIONS="
set "CUDA_VERSIONS="

:: 그래픽 드라이버 정보 수집
for /f "skip=1 tokens=1,2" %%a in ('wmic path win32_VideoController get Name^, DriverVersion 2^>nul') do (
    if not "%%a"=="" (
        set "GPU_INFO=!GPU_INFO!%%a %%b, "
    )
)
if defined GPU_INFO set "GPU_INFO=!GPU_INFO:~0,-2!"

:: 파이썬 버전 정보 수집
for /f "tokens=1,2" %%a in ('python --version 2^>^&1') do set "MAIN_PYTHON=%%a %%b"

:: 설치된 모든 파이썬 버전 찾기
for /f "delims=" %%i in ('where python 2^>nul') do (
    for /f "tokens=1,2" %%a in ('"%%i" --version 2^>^&1') do (
        if not defined PYTHON_VERSIONS (
            set "PYTHON_VERSIONS=%%b"
        ) else (
            set "PYTHON_VERSIONS=!PYTHON_VERSIONS!, %%b"
        )
    )
)

:: CUDA 버전 찾기
if exist "C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA" (
    for /d %%d in ("C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\v*") do (
        for /f "tokens=*" %%v in ("%%~nxd") do (
            if not defined CUDA_VERSIONS (
                set "CUDA_VERSIONS=%%v"
            ) else (
                set "CUDA_VERSIONS=!CUDA_VERSIONS!, %%v"
            )
        )
    )
)

:: NVIDIA-SMI에서 CUDA 버전 가져오기 (드라이버가 지원하는 CUDA 버전)
if %SMI_ERROR% EQU 0 (
    for /f "tokens=*" %%a in ('nvidia-smi --query-gpu^=driver_version --format^=csv^,noheader 2^>nul') do (
        set "DRIVER_VERSION=%%a"
    )
    
    for /f "tokens=*" %%a in ('nvidia-smi --query-gpu^=cuda_version --format^=csv^,noheader 2^>nul') do (
        set "DRIVER_CUDA=%%a"
        if not defined DRIVER_CUDA set "DRIVER_CUDA=알 수 없음"
    )
) else (
    set "DRIVER_VERSION=알 수 없음"
    set "DRIVER_CUDA=알 수 없음"
)

:: 요약 정보 추가 (상세 버전 포함)
echo =========================================== >> "%LOGFILE%"
echo                점검 요약                    >> "%LOGFILE%"
echo =========================================== >> "%LOGFILE%"
echo. >> "%LOGFILE%"

echo 1. 그래픽 드라이버: >> "%LOGFILE%"
wmic path win32_VideoController get Name 2>nul | findstr /v "^$" | findstr /v "Name" > nul
if %ERRORLEVEL% EQU 0 (
    echo [O] 그래픽 드라이버가 설치되어 있습니다. >> "%LOGFILE%"
    echo     - 드라이버 정보: !GPU_INFO! >> "%LOGFILE%"
) else (
    echo [X] 그래픽 드라이버를 찾을 수 없습니다. >> "%LOGFILE%"
)
echo. >> "%LOGFILE%"

echo 2. 파이썬: >> "%LOGFILE%"
where python > nul 2>&1
if %ERRORLEVEL% EQU 0 (
    echo [O] 파이썬이 설치되어 있습니다. >> "%LOGFILE%"
    echo     - 기본 파이썬 버전: !MAIN_PYTHON! >> "%LOGFILE%"
    echo     - 설치된 버전: !PYTHON_VERSIONS! >> "%LOGFILE%"
) else (
    echo [X] 파이썬을 찾을 수 없습니다. >> "%LOGFILE%"
)
echo. >> "%LOGFILE%"

echo 3. CUDA 툴킷: >> "%LOGFILE%"
if !CUDA_FOUND! EQU 1 (
    echo [O] CUDA 툴킷이 설치되어 있습니다. >> "%LOGFILE%"
    echo     - 설치된 CUDA 버전: !CUDA_VERSIONS! >> "%LOGFILE%"
    echo     - 드라이버 버전: !DRIVER_VERSION! >> "%LOGFILE%"
    echo     - 드라이버 지원 CUDA: !DRIVER_CUDA! >> "%LOGFILE%"
) else (
    if %SMI_ERROR% EQU 0 (
        echo [△] NVIDIA 드라이버는 설치되어 있지만 CUDA 툴킷을 찾을 수 없습니다. >> "%LOGFILE%"
        echo     - 드라이버 버전: !DRIVER_VERSION! >> "%LOGFILE%"
        echo     - 드라이버 지원 CUDA: !DRIVER_CUDA! >> "%LOGFILE%"
    ) else (
        echo [X] CUDA 툴킷 및 NVIDIA 드라이버를 찾을 수 없습니다. >> "%LOGFILE%"
    )
)
echo. >> "%LOGFILE%"

:: 요약 파일 생성
echo =========================================== > "%SUMMARY_FILE%"
echo                시스템 점검 요약             >> "%SUMMARY_FILE%"
echo =========================================== >> "%SUMMARY_FILE%"
echo 점검 날짜: %date% %time%                   >> "%SUMMARY_FILE%"
echo. >> "%SUMMARY_FILE%"

echo 1. 그래픽 드라이버: >> "%SUMMARY_FILE%"
wmic path win32_VideoController get Name 2>nul | findstr /v "^$" | findstr /v "Name" > nul
if %ERRORLEVEL% EQU 0 (
    echo [O] 그래픽 드라이버가 설치되어 있습니다. >> "%SUMMARY_FILE%"
    echo     - 드라이버 정보: !GPU_INFO! >> "%SUMMARY_FILE%"
) else (
    echo [X] 그래픽 드라이버를 찾을 수 없습니다. >> "%SUMMARY_FILE%"
)
echo. >> "%SUMMARY_FILE%"

echo 2. 파이썬: >> "%SUMMARY_FILE%"
where python > nul 2>&1
if %ERRORLEVEL% EQU 0 (
    echo [O] 파이썬이 설치되어 있습니다. >> "%SUMMARY_FILE%"
    echo     - 기본 파이썬 버전: !MAIN_PYTHON! >> "%SUMMARY_FILE%"
    echo     - 설치된 버전: !PYTHON_VERSIONS! >> "%SUMMARY_FILE%"
) else (
    echo [X] 파이썬을 찾을 수 없습니다. >> "%SUMMARY_FILE%"
)
echo. >> "%SUMMARY_FILE%"

echo 3. CUDA 툴킷: >> "%SUMMARY_FILE%"
if !CUDA_FOUND! EQU 1 (
    echo [O] CUDA 툴킷이 설치되어 있습니다. >> "%SUMMARY_FILE%"
    echo     - 설치된 CUDA 버전: !CUDA_VERSIONS! >> "%SUMMARY_FILE%"
    echo     - 드라이버 버전: !DRIVER_VERSION! >> "%SUMMARY_FILE%"
    echo     - 드라이버 지원 CUDA: !DRIVER_CUDA! >> "%SUMMARY_FILE%"
) else (
    if %SMI_ERROR% EQU 0 (
        echo [△] NVIDIA 드라이버는 설치되어 있지만 CUDA 툴킷을 찾을 수 없습니다. >> "%SUMMARY_FILE%"
        echo     - 드라이버 버전: !DRIVER_VERSION! >> "%SUMMARY_FILE%"
        echo     - 드라이버 지원 CUDA: !DRIVER_CUDA! >> "%SUMMARY_FILE%"
    ) else (
        echo [X] CUDA 툴킷 및 NVIDIA 드라이버를 찾을 수 없습니다. >> "%SUMMARY_FILE%"
    )
)
echo. >> "%SUMMARY_FILE%"

:: 로그 파일이 생성되었는지 확인
if exist "%LOGFILE%" (
    echo 로그 파일이 성공적으로 저장되었습니다: "%LOGFILE%"
) else (
    echo 경고: 로그 파일 생성에 문제가 있을 수 있습니다.
)

if exist "%SUMMARY_FILE%" (
    echo 요약 파일이 성공적으로 저장되었습니다: "%SUMMARY_FILE%"
) else (
    echo 경고: 요약 파일 생성에 문제가 있을 수 있습니다.
)

:: 임시 파일 삭제
if exist "%TEMP_FILE%" del "%TEMP_FILE%" > nul 2>&1

echo 아무 키나 눌러서 종료하세요...
pause > nul