@echo off
title Resource Builder
setlocal enabledelayedexpansion

set resources=%cd%

@REM use if resourcebuilder is not in the resouces folder
@REM set resources="YOUR RESOURCES FOLDER HERE"

:start
cd %resources%

set count=1
set options=

echo.
echo %cd%
echo [1] Current directory

for /d %%x in (*) do (
   set /A count=!count!+1
   set options[!count!]=%%x
   echo [!count!] %%x
)

echo.
set /p choose=Choose the directory that contains what you want to build:

set folder=%resources%

if /i %choose% gtr 1 set folder=!options[%choose%]!

:dir

cd %resources%%folder%

set count=2
set options=

echo.
echo %cd%
echo [1] Return
echo [2] Build all

for /d %%x in (*) do (
   set /A count=!count!+1
   set options[!count!]=%%x
   echo [!count!] Build %%x
)

echo.
set /p choose=Choose option:

if /i %choose% equ 1 goto :start

if /i %choose% equ 2 (
   set resource=all
) else (
   set resource=!options[%choose%]!
   cd %resource%
)

echo.
echo [1] pnpm
echo [2] yarn

echo.
set /p manager=Choose package manager:

if %resource% equ all (
   set alltotal=0
   set allresouces=

   for /d %%x in (*) do (
      set /A alltotal=!alltotal!+1
      set allresouces[!alltotal!]=%%x
   )
   set allcount=0
   goto :all
)

set buildfolder=%resource%
cd %resource%

:allcycle

set count=0
set builddirs[1]=web
set builddirs[2]=src
set builddirs[3]=ui
set builddirs[4]=phone
set builddirs[5]=resources

:cycle
if /i %count% equ 5 (
   if %resource% equ all (
      goto :all
   ) else (
      goto :dir
   )
)

set /A count=!count!+1

if exist !builddirs[%count%]!\ (
   cd !builddirs[%count%]!
   if /i %manager% equ 1 (
      goto :pnpm
   ) else (
      goto :yarn
   )
)
goto :cycle

:all
if /i %allcount% equ %alltotal% goto :start

if /i %allcount% gtr 0 cd ..

set /A allcount=!allcount!+1
set buildfolder=!allresouces[%allcount%]!
cd !allresouces[%allcount%]!
goto :allcycle

:pnpm
@echo on
@echo.
@echo %buildfolder%\!builddirs[%count%]! pnpm i
@echo.
@call "pnpm" i
@echo.
@echo %buildfolder%\!builddirs[%count%]! pnpm build
@echo.
@call "pnpm" build
@echo off
echo.
cd ..
goto :cycle

:yarn
@echo on
@echo.
@echo %buildfolder%\!builddirs[%count%]! yarn
@echo.
@call "yarn"
@echo.
@echo %buildfolder%\!builddirs[%count%]! yarn build
@echo.
@call "yarn" build
@echo off
echo.
cd ..
goto :cycle
