# CHPCs Lmod 

## Modules setup

To be added

## Module file format

We should strive to keep the module format somewhat consistent. Each module file should contain the following:

### Version variable

It is advantageous to define the package version first since the module file can then refer to this throughout the module file, e.g.
```
local version = "18.1"
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

Description defines some tags associated with the module, e.g.
```
whatis("Name: PGI Compilers")
whatis("Version: " .. version)
whatis("Category: compiler")
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

