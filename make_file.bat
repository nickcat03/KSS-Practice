@echo off

copy original.sfc patched.sfc

asar patch.asm patched.sfc

pause