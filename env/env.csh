#!/bin/tcsh
# -----------------------------------------------
# Script written by Wim R. Cardoen 
# Goal:
#      a.retrieve the environmental variables
#      b.write the result in a file (.lua suffix) 
# User input:
#      cmd as string
#      -> source line  
# -----------------------------------------------
# USER INPUT ::
#setenv CMD_STRING "source /uufs/chpc.utah.edu/sys/pkg/intel/ics/bin/compilervars.csh intel64"
setenv CMD_STRING "source /uufs/chpc.utah.edu/sys/installdir/anaconda3/2019.03/etc/profile.d/conda.csh"
setenv FILENAME "trial-csh.lua"
# ------------------------------------------------------------------------------------
# Please let me (u0253283@utah.edu) know if you see any bug. Thanks!

# Generate the ANTE temp. file 
python -c "import env; env.dump(0)"

# Execute cmd 
eval $CMD_STRING

# Generate the POST temp. file
python -c "import env; env.dump(1)" 

# Generate lua file
python -c "import env; env.writeEnvCmdsToFile('$FILENAME')"

# Clean up temp. files (ANTE & POST)
python -c "import env; env.cleanup()"
