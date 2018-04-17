# CHPCs Lmod 

## Modules setup

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

### System spider cache

We are using cache, which is being put to `/uufs/chpc.utah.edu/sys/installdir/lmod/cache`, different location for different Lmod version (or, better to say, different locations of our module files). More info on this is at [http://lmod.readthedocs.io/en/latest/130_spider_cache.html](http://lmod.readthedocs.io/en/latest/130_spider_cache.html).

Our particular setup involves running `/uufs/chpc.utah.edu/sys/modulefiles/scripts/caching/update_cache-c7.sh`. We should try to run this as a cron job.

To run module commands without using the cache:
```
$ module --ignore_cache avail
```

## Module file format

We should strive to keep the module format somewhat consistent. Each module file should contain the following:

### Version variable

It is advantageous to define the package version first since the module file can then refer to this throughout the module file, e.g.
```
local version = "18.1"
local base = pathJoin("/uufs/chpc.utah.edu/sys/installdir/pgi", version)
```

### Help section

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

### Description section

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

### Environmental variables

We usually need to define PATH and other variables, and, when practical we should also define an environmental variable that specifies the package location and include/library location, e.g.
```
prepend_path("PATH",pathJoin(base, "/bin"))
prepend_path("LD_LIBRARY_PATH",pathJoin(base,"/lib"))
prepend_path("MANPATH",pathJoin(base,"/share/man/man3"))
setenv("NETCDFC",base)
setenv("NETCDFC_INCDIR",pathJoin(base,"/include"))
setenv("NETCDFC_LIBDIR",pathJoin(base,"/lib"))
```

## Other module file format features

All Lua module file functions are listed at [http://lmod.readthedocs.io/en/latest/050_lua_modulefiles.html](http://lmod.readthedocs.io/en/latest/050_lua_modulefiles.html).

### Dependencies

Dependencies can be included in several different ways

#### Hierarchy

#### Explicit loading

This loads the dependent module upon loading and unloads it when unloading, e.g.
```
load("hdf5/1.8.17")
```
However, note that if the user loads the dependent module (here `hdf5`) before, it gets unloaded when the module that contains the `load` statement gets unloaded.

#### Prerequisite definition

### Module properties via labels

Modules can be labelled for different groupings. [http://lmod.readthedocs.io/en/latest/145_properties.html#lmodrc-label](http://lmod.readthedocs.io/en/latest/145_properties.html#lmodrc-label) There are two default labels:

#### State

`experimental`,`testing`,`obsolete`. 

I propose to mark older version obsolete, AND potentially hide them (list them as hidden in `/uufs/chpc.utah.edu/sys/modulefiles/etc/rc`):
```
add_property("state","obsolete")
```

#### Architecture

`gpu`,`mic`,...

For our purposes we should mark GPU built packages with this label, e.g.
```
add_property("arch","gpu")
```

### Family

Defines that only one module in a family can be loaded at a time, e.g.

```
family("R")
```
List of families:
R, Python, CUDA

### Module versions and aliases

We can create shorter version or an alias for a module by a definition in `/uufs/chpc.utah.edu/sys/modulefiles/etc/rc`.  This is recommended for modules with long versions or where versions differ significantly, e.g.:
```
 module-version intel/2018.1.163 18.1 18
 module-version intel/2018.0.128 18.0 
 module-version lumerical/8.19.1466 8.19 2018a 18a
 module-alias python2 python/2.7.11
 module-alias python3 python/3.5.2
```
