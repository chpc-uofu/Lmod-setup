#!/bin/bash

#set -x
#echo Cleaning LMod

if [ -v "module" ]; then
  module purge 
fi

#set echo

lmodvars=(LMOD MODULEPATH MODULE Module)

for lmodvar in ${lmodvars[*]}; do
  vars=`env | grep $lmodvar | cut -d = -f 1 | grep $lmodvar`
  for var in $vars; do
    unset $var
  done
done

lmodfuncs=(ml module clearMT)
for lmodfunc in ${lmodfuncs[*]}; do
  funcs=`declare -F | cut  -f 3 -d " "|grep $lmodfunc`
  for func in $funcs; do
    unset -f $func
  done
done 

unset _LMFILES_

