-- -*- lua -*-

help([[This module sets the PATH variable for anaconda3/2019.03
       (i.e. python/3.7.3) ]])

local version = "2019.03"
local base = pathJoin("/uufs/chpc.utah.edu/sys/installdir", myModuleName(), version) 

setenv("ANACONDA_ROOT",base)
prepend_path("PATH",pathJoin(base,"bin"))

-- starting with conda 4.6 (June 2019), more needs to be sourced so that virtual environments work
-- we source the conda.[sh,csh] at module load, and unset all the stuff that this sets manually at unload
-- this happens at load
execute{cmd="source " .. base .. "/etc/profile.d/conda."..myShellType(),modeA={"load"}}

-- this happens at unload
-- could also do "conda deactivate; " but that should be part of independent VE module
if (myShellType() == "csh") then
  -- csh sets these environment variables and an alias for conda
  cmd = "unsetenv CONDA_EXE; unsetenv _CONDA_ROOT; unsetenv _CONDA_EXE; " ..
        "unsetenv CONDA_SHLVL; unalias conda"
  execute{cmd=cmd, modeA={"unload"}}
end
if (myShellType() == "sh") then
  -- bash sets environment variables, shell functions and path to condabin
  if (mode() == "unload") then
    remove_path("PATH", pathJoin(base,"condabin"))
  end
  cmd = "unset CONDA_EXE; unset _CE_CONDA; unset _CE_M; " ..
        "unset -f __conda_activate; unset -f __conda_reactivate; " .. 
        "unset -f __conda_hashr; unset CONDA_SHLVL; unset _CONDA_EXE; " .. 
        "unset _CONDA_ROOT; unset -f conda"
  execute{cmd=cmd, modeA={"unload"}}
end

whatis("Name         : Anaconda3 2019.03 | Python 3.7.3")
whatis("Version      : Anaconda3 2019.03 & Python 3.7.3")
whatis("Category     : Compiler")
whatis("Description  : Python environment ")
whatis("URL          : http://www.continuum.io/ ")
whatis("Installed on : 05/09/2019 ")
whatis("Modified on  : --- ")
whatis("Installed by : WRC")

family("python")

-- Change Module Path
local mroot = os.getenv("MODULEPATH_ROOT")
local mdir = pathJoin(mroot,"Compiler/anaconda",version)
prepend_path("MODULEPATH",mdir)

