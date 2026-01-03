@echo off
setlocal

REM Always run from this script's folder
cd /d "%~dp0"

echo === BudgetlyDB Setup (LocalDB) ===

REM Quick check: do we have sqlcmd?
where sqlcmd >nul 2>nul
if errorlevel 1 (
  echo sqlcmd not found. Install "SQL Server Command Line Utilities" or SQL Server tools.
  pause
  exit /b 1
)

echo Dropping BudgetlyDB if it exists...
sqlcmd -S "(localdb)\MSSQLLocalDB" -E -Q "IF DB_ID('BudgetlyDB') IS NOT NULL BEGIN ALTER DATABASE BudgetlyDB SET SINGLE_USER WITH ROLLBACK IMMEDIATE; DROP DATABASE BudgetlyDB; END"
if errorlevel 1 goto :fail

echo Creating BudgetlyDB...
sqlcmd -S "(localdb)\MSSQLLocalDB" -E -Q "CREATE DATABASE BudgetlyDB"
if errorlevel 1 goto :fail

echo Applying schema...
sqlcmd -S "(localdb)\MSSQLLocalDB" -E -d BudgetlyDB -i "schema.sql"
if errorlevel 1 goto :fail

echo Seeding demo data...
sqlcmd -S "(localdb)\MSSQLLocalDB" -E -d BudgetlyDB -i "seed.sql"
if errorlevel 1 goto :fail

echo.
echo Done! BudgetlyDB created + seeded.
pause
exit /b 0

:fail
echo.
echo Failed. Check the error output above.
pause
exit /b 1
