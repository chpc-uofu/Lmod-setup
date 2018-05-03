-- -*- lua -*-

-- Lua's comment line starts with "--"

-- example version - needs to be at the top so that other sections have it
local version = "18.1"

help([[
]])

--At least put a name, version, and URL. 
--some of the others are kind of optional
whatis("Name         : ")
whatis("Version      : " .. version)
whatis("Category     : ")
whatis("Description  : ")
whatis("URL          : ")
whatis("Installed on : ")
whatis("Modified on  : ")
whatis("Installed by : ")

-- example base installation directory
-- if the module name is the same as installation directory, we can also use
-- the myModuleName() function, otherwise replace myModuleName() with explicit directory name
local base = pathJoin("/uufs/chpc.utah.edu/sys/installdir", myModuleName(), version)

-- often we want to define the base directory of the package
setenv("MYPKG",base)
-- and prepend the PATH
prepend_path("PATH",pathJoin(base,"bin")

-- for libraries, we want to set the INCDIR and LIBDIR, e.g.
-- setenv("NETCDFC_INCDIR",pathJoin(base,"/include"))
-- setenv("NETCDFC_LIBDIR",pathJoin(base,"/lib"))

-- for other module files features see https://github.com/CHPC-UofU/Lmod-setup/blob/master/readme.md#moduleformat
