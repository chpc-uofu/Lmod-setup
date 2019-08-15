#!/bin/sh

#set echo

clearMT
source /uufs/chpc.utah.edu/sys/modulefiles/scripts/clear_lmod.sh
export MODULERCFILE=/uufs/chpc.utah.edu/sys/modulefiles/etc/rc18
source /uufs/chpc.utah.edu/sys/installdir/lmod/7.7.29/init/profile

# System Module Provision
 if [ -z "$__Init_Default_Modules" ]; then
    export __Init_Default_Modules=1;
    export LMOD_SYSTEM_DEFAULT_MODULES="chpc"
    module --initial_load restore
 else
    module refresh
 fi


