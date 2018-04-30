# CHPCs Lmod 
* [Modules setup](#modulesetup)
    * [System spider cache](#scache)

* [Module file format](#moduleformat)
    * [Version variable](#version)
    * [Help section](#help)
    * [Description section](#whatis)
    * [Environment variables](#env)
* [Other module file format features](#moduleformatother)
    * [Dependencies](#depend)
    * [Module properties](#prop)
    * [Family](#family)
    * [Defining aliases in the module files](#alias)
    * [Module hiding, versions and aliase](#ver)

## <a name="modulesetup"></a>Modules setup

We have a specific installation strategy for Lmod in order to have different versions to co-exist in the sys branch. We follow the installation instructions at [http://lmod.readthedocs.io/en/latest/030_installing.html](http://lmod.readthedocs.io/en/latest/030_installing.html), but, with a twist.

* Download the Lmod source to the srcdir
* make the cache directories, e.g.
```
$ mkdir -p /uufs/chpc.utah.edu/sys/installdir/lmod/systemfiles/7.7-c7/
$ touch /uufs/chpc.utah.edu/sys/installdir/lmod/systemfiles/7.7-c7/system.txt
$ mkdir -p /uufs/chpc.utah.edu/sys/installdir/lmod/cache/7.7-c7
```
* In srcdir, configure and preinstall:
```
$ ./configure --prefix=/uufs/chpc.utah.edu/sys/installdir --with-module-root-path=/uufs/chpc.utah.edu/sys/modulefiles/CHPC-c7 --with-spiderCacheDir=/uufs/chpc.utah.edu/sys/installdir/lmod/cache/7.7-c7 --with-updateSystemFn=/uufs/chpc.utah.edu/sys/installdir/lmod/systemfiles/7.7-c7/system.txt --with-colorize=YES --with-tcl=YES --with-autoSwap=YES --with-useDotFiles=YES --with-mpathSearch=yes
$ make pre-install
```
* Modify the installed files to replace `lmod/lmod` references. This allows us to run lmod directly from the given version directory (in this case 7.7.29):
```
$ grep -rl "lmod\/lmod" * | xargs sed -i 's/lmod\/lmod/lmod\/7.7.29/g'
```
* Modify `libexec/SitePackage.lua` - use the file from older version to add hooks for module load logging and for licensed programs checks
* Test the new Lmod installation - this requires unloading the existing Lmod and starting the new one in an user shell. We have examples of scripts that do thia, e.g. `/uufs/chpc.utah.edu/sys/modulefiles/scripts/switch_to_18.csh`. Dont forget to source the file so that changes take effect.
* When ready to deploy, modify `/uufs/chpc.utah.edu/sys/etc/profile.d/module.[csh,sh]` to change the Lmod version to source

### <a name="scache"></a>System spider cache

We are using cache, which is being put to `/uufs/chpc.utah.edu/sys/installdir/lmod/cache`, different location for different Lmod version (or, better to say, different locations of our module files). More info on this is at [http://lmod.readthedocs.io/en/latest/130_spider_cache.html](http://lmod.readthedocs.io/en/latest/130_spider_cache.html).

Our particular setup involves running `/uufs/chpc.utah.edu/sys/modulefiles/scripts/caching/update_cache-c7.sh`. We should try to run this as a cron job.

To run module commands without using the cache:
```
$ module --ignore_cache avail
```
(Note - the caching does not seem to work in the currently active Lmod version, 7.1.6, but it works in the testing version, 7.7.29. Not sure why is that but I am leaving it as is and will check again when 7.7.29 is made active).

### Environment variables 

Lets consider to change the following [environment variables](http://lmod.readthedocs.io/en/latest/090_configuring_lmod.html), which modify Lmods behavior:
```
LMOD_PIN_VERSIONS - default - no - may want to set to yes to module restore the same versions of modules which were used with module save.
LMOD_SHORTTIME - default - 2 - set to large value (86400) to prevent user spider cache to be generated - TURN THIS ON when auto cache generation is functional.
```

## <a name="moduleformat"></a>Module file format

We should strive to keep the module format somewhat consistent. Each module file should contain the following:

### <a name="version"></a>Version variable

It is advantageous to define the package version first since the module file can then refer to this throughout the module file, e.g.
```
local version = "18.1"
local base = pathJoin("/uufs/chpc.utah.edu/sys/installdir/pgi", version)
```

### <a name="help"></a>Help section

We need to agree on a format. I feel that some help pages are too long, e.g.
```
help(
[[
This module sets the following env. variables:
     a. PATH
     b. LD_LIBRARY_PATH
     c. the MANPATH variable
        You can invoke the man page as follows:
            man 3 netcdf

     d. The following env. variables:
        NETCDFC        :: /uufs/chpc.utah.edu/sys/installdir/netcdf-c/4.4.1-c7/
        NETCDFC_INCDIR :: /uufs/chpc.utah.edu/sys/installdir/netcdf-c/4.4.1-c7/include
        NETCDFC_LIBDIR :: /uufs/chpc.utah.edu/sys/installdir/netcdf-c/4.4.1-c7/lib

     e. This version of netcdf-c has been built with the FOLLOWING libraries:
        1./uufs/chpc.utah.edu/sys/installdir/zlib/1.2.8-c7/
        2./uufs/chpc.utah.edu/sys/installdir/szip/2.1-c7/
        3./uufs/chpc.utah.edu/sys/installdir/hdf5/1.8.17-c7/

for the netCDF-c package (v.4.4.1) for Centos7
]])

```

### <a name="whatis"></a>Description section

Description defines some tags associated with the module, which can be used in searching, e.g.:
```
whatis("Name: PGI Compilers")
whatis("Version: " .. version)
whatis("Category: compiler")
whatis("Description  : Compiler (C, C++, Fortran)")
whatis("Keywords: System, compiler")
whatis("URL: http://www.pgroup.com/")
whatis("Installed on 2/26/2018")
```
Note that we are using the `version` variable defined at the start.

For Keywords, lets use the Tags used in the Application database, which are listed in [Tags.csv](Tags.csv). The application database categories, defined in [Categories.csv](Categories.csv), are not very detailed, but, it may not be a bad idea to start using that so we can potentially in the future group the modules based on these categories. We may expand the Applications, though, for different fields of science.

### <a name="env"></a>Environmental variables

We usually need to define PATH and other variables, and, when practical we should also define an environmental variable that specifies the package location and include/library location, e.g.
```
prepend_path("PATH",pathJoin(base, "/bin"))
prepend_path("LD_LIBRARY_PATH",pathJoin(base,"/lib"))
prepend_path("MANPATH",pathJoin(base,"/share/man/man3"))
setenv("NETCDFC",base)
setenv("NETCDFC_INCDIR",pathJoin(base,"/include"))
setenv("NETCDFC_LIBDIR",pathJoin(base,"/lib"))
```

## <a name="moduleformatother"></a>Other module file format features

All Lua module file functions are listed at [http://lmod.readthedocs.io/en/latest/050_lua_modulefiles.html](http://lmod.readthedocs.io/en/latest/050_lua_modulefiles.html).

### <a name="depend"></a>Dependencies

Dependencies can be included in several different ways. See [http://lmod.readthedocs.io/en/latest/098_dependent_modules.html](http://lmod.readthedocs.io/en/latest/098_dependent_modules.html) for details. Most common possibilities are summarized below.

#### <a name="hier"></a>Hierarchy

We handle direct dependencies on compilers, MPI, CUDA and potentially other packages (Python, R) via hierarchy. Compilers and MPI should be always done this way, for other tools only if they dont depend on a compiler and MPI (e.g. if we have a MPI parallel CUDA code, the MPI dependency will be handled by the hierarchy and CUDA dependency explicitly in one of the way below).

#### <a name=""></a>Use of RPATH

In general the best approach for library dependencies is hardcoding the dynamic library path in the executable via RPATH, i.e. linking as
```
-Lmy_lib_path -lmy_lib -Wl,-rpath=my_lib_path
```

#### <a name=""></a>Explicit loading

For dependencies that require other things than dynamic libraries (e.g. executables from bin directory), the best option for explicit loading is `depends_on()`. Using that will load the dependent module if its not loaded yet, unload when the original module is unloaded, but keep the dependent module if it has been loaded earlier.
```
depends_on("cuda/9.1")
```
#### <a name=""></a>Prerequisite definition

For expert users, we may use the `prereq()` function. If the dependent module is not loaded, loading a module with `prereq()` will error out with a message that the prerequisite module has not been loaded. This leaves the dependency handling on the user.

### <a name="prop"></a>Module properties via labels

Modules can be labelled for different groupings. [http://lmod.readthedocs.io/en/latest/145_properties.html#lmodrc-label](http://lmod.readthedocs.io/en/latest/145_properties.html#lmodrc-label) There are two default labels:

#### <a name=""></a>State

`experimental`,`testing`,`obsolete`. 

I propose to mark older version obsolete, AND potentially hide them (list them as hidden in `/uufs/chpc.utah.edu/sys/modulefiles/etc/rc`):
```
add_property("state","obsolete")
```

#### <a name=""></a>Architecture

`gpu`,`mic`,...

For our purposes we should mark GPU built packages with this label, e.g.
```
add_property("arch","gpu")
```
I have also defined a new property, `host`, which should be used for packages which have been built both for GPU and CPU (host):
```
add_property("arch","gpu:host")
```


### <a name="family"></a>Family

Defines that only one module in a family can be loaded at a time, e.g.

```
family("R")
```
List of families:
* Compiler 
* mpi
* R - own built R or OpenR
* Python - own built, Anaconda, Intel Python
* hdf5 - hdf5, phdf5
* boost - boost, pboost
* java - Oracle or OpenJDK
* matlab - in case package uses old Matlab for which we dont have modules and have hard coded paths (delft3dvis)
* idl - potential similar need to matlab above
* gaussian 

Questionable families:
libflame, scala, cuda, julia, spark, gromacs, hoomd

### <a name="alias"></a>Defining aliases in the module files

Command aliases are useful, and Lmod defines `set_alias()` function for that purpose. However, aliases dont get expanded in bash non-interactive (e.g. job scripts) shells. Therefore, instead of using `set_alias()` function in the module files, we should use shell functions using the `set_shell_function()` function. Furthermore, in Bash, we need to `export` the newly created shell function. Therefore, the whole alias creation of `newcmd` pointing to `oldcmd` is as follows:
```
local bashStr = 'orgcmd "$@"'
local cshStr  = "orgcmd $*"
set_shell_function("newcmd",bashStr,cshStr)
if (myShellName() == "bash") then
 execute{cmd="export -f newcmd",modeA={"load"}}
end
```
The `execute` function runs a given command `cmd` in a given Lmod mode `modeA` - in this case it will export the newcmd function when the module is loaded.

**NOTE - aliases dont work with `mpirun`**. `mpirun` under the hood calls a binary program launcher, which does not expand the aliases, or shell functions, e.g. in bash:
```
$ myfunction(){ ./a.out; }
$ export -f myfunction
$ mpirun -np 1 myfunction
 [proxy:0:0@notchpeak1] HYDU_create_process (../../utils/launch/launch.c:825): execvp error on file myfunction (No such file or directory)
```
The mpirun sh script calls `+ mpiexec.hydra -np 1 myfunction` and mpiexec.hydra somehow calls program in the argument (here `myfunction`). Since the system() call expands the exported shell function correctly, mpiexec.hydra probably calls ssh or similar to launch a new remote shell. The alias is not known in the remote shell and the launch fails.

### <a name="ver"></a>Module hiding, versions and aliases

We can create shorter version or an alias for a module by a definition in `/uufs/chpc.utah.edu/sys/modulefiles/etc/rc`.  This is recommended for modules with long versions or where versions differ significantly, e.g.:
```
 module-version intel/2018.1.163 18.1 18
 module-version intel/2018.0.128 18.0 
 module-version lumerical/8.19.1466 8.19 2018a 18a
 module-alias python2 python/2.7.11
 module-alias python3 python/3.5.2
```

We can also hide older modules in the same rc file with e.g.:
```
 hide-version R/3.2.1
```

We should make a habit to hide older modules as we install newer versions of programs.

