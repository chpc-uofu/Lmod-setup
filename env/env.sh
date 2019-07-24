#!/bin/bash
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
#export CMD_STRING="source /uufs/chpc.utah.edu/sys/pkg/intel/ics/bin/compilervars.sh intel64"
#export FILENAME="trial.lua"
export CMD_STRING=". /uufs/chpc.utah.edu/sys/installdir/anaconda3/2019.03/etc/profile.d/conda.sh"
export FILENAME="trial-sh.lua"
# ------------------------------------------------------------------------------------

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
