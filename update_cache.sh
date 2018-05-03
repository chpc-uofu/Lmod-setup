#!/bin/bash

#if [ `hostname` == "centos7.chpc.utah.edu" ]; then
if [ -z "$LMOD_VERSION" ]; then
  source /etc/profile.d/chpc.sh
fi
   
env >& ~/cron.txt

PATH_TO_LMOD_LIBEXEC=/uufs/chpc.utah.edu/sys/installdir/lmod/7.7.29/libexec/
#LMOD_DEFAULT_MODULEPATH="/uufs/chpc.utah.edu/sys/modulefiles/CHPC-18/Core:/uufs/chpc.utah.edu/sys/installdir/lmod/7.7.29/modulefiles/Core"
MYMODULEPATH="/uufs/chpc.utah.edu/sys/modulefiles/CHPC-18/Core"
LMOD_CACHEDIR=/uufs/chpc.utah.edu/sys/installdir/lmod/cache/7.7-c7
LMOD_TIMESTAMP_FN=/uufs/chpc.utah.edu/sys/installdir/lmod/systemfiles/7.7-c7/system.txt
$PATH_TO_LMOD_LIBEXEC/update_lmod_system_cache_files -D -t $LMOD_TIMESTAMP_FN -d $LMOD_CACHEDIR $MYMODULEPATH |& tee $LMOD_CACHEDIR/cache.out

#if [ $? -ne 0 ]; then
if grep -q ERROR $LMOD_CACHEDIR/cache.out; then
  echo "Cache generation error"
  # copy the backup files
  # the cache generation failed, send e-mail to operations? including content of $LMOD_CACHEDIR/cache.out
  ( echo -e "Error generating Lmod cache.\n\n" ; cat $LMOD_CACHEDIR/cache.out ) | mail -s "Lmod cache error" david.richardson@utah.edu martin.cuma@utah.edu
  exit 1
#else
#  rm $LMOD_CACHEDIR/cache.out
fi

# MC addition - update module reverse map for XALT
# not needed - better to do this before uploading XALT data to the database
#/uufs/chpc.utah.edu/sys/installdir/lmod/lmod/libexec/spider -o jsonReverseMapT  $LMOD_DEFAULT_MODULEPATH  > /uufs/chpc.utah.edu/sys/installdir/xalt/std/rmapD/jsonReverseMapT.json
