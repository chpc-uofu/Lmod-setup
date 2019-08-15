#!/bin/tcsh

module purge 

#set echo

set lmodvars = (LMOD MODULEPATH MODULE Module)

foreach lmodvar ($lmodvars)
  set vars=`env | grep $lmodvar | cut -d = -f 1 | grep $lmodvar`
  foreach var ($vars)
    unsetenv $var
  end
end

unsetenv _LMFILES_

unalias module
unalias ml
unalias clearMT

