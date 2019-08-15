#!/bin/tcsh

#set echo

clearMT
source /uufs/chpc.utah.edu/sys/modulefiles/scripts/clear_lmod.csh
setenv MODULERCFILE /uufs/chpc.utah.edu/sys/modulefiles/etc/rc18
source /uufs/chpc.utah.edu/sys/installdir/lmod/7.7.29/init/cshrc

# System Module Provision
if ( ! $?__Init_Default_Modules )  then
   setenv LMOD_SYSTEM_DEFAULT_MODULES "chpc"
   module --initial_load restore
   setenv __Init_Default_Modules 1
else
   module refresh
endif

