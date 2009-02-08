@echo off
rem RCS: @(#) $Id: mkd.bat,v 1.1.1.1 2005/05/08 22:37:08 soohyunc Exp $

if exist %1\nul goto end

md %1
if errorlevel 1 goto end

echo Created directory %1

:end



