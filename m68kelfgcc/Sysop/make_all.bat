@echo off
echo ================= INICIO ================
cd D:\Projetos\MMSJ320\m68kelfgcc\Sysop\mmsjos
call build_mmsjos.bat %*
cd D:\Projetos\MMSJ320\m68kelfgcc\Sysop\progs\files
call build_files.bat %*
cd D:\Projetos\MMSJ320\m68kelfgcc\Sysop\progs\note
call build_note.bat %*
cd D:\Projetos\MMSJ320\m68kelfgcc\Sysop\progs\wftp
call build_wftp.bat %*
cd D:\Projetos\MMSJ320\m68kelfgcc\Sysop\progschar\edit
call build_edit.bat %*
cd D:\Projetos\MMSJ320\m68kelfgcc\Sysop\progschar\mcalc
call build_mcalc.bat %*
cd D:\Projetos\MMSJ320\m68kelfgcc\Sysop\progschar\net
call build_net.bat %*
cd D:\Projetos\MMSJ320\m68kelfgcc\Sysop\progschar\term
call build_term.bat %*
cd D:\Projetos\MMSJ320\m68kelfgcc\Sysop\progschar\ftpd
call build_ftpd.bat %*
cd D:\Projetos\MMSJ320\m68kelfgcc\Sysop
echo ================= FINAL =================
