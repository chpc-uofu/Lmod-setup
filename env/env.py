# -*- coding: utf-8 -*-
"""
Created on Mon Dec  8 21:15:04 2014
@author: Wim R. Cardoen
"""
import datetime
import os
import pickle
import sys

PKLFILES = ['ANTE.pkl','POST.pkl']

def dump(ind):
    """
    Retrieve the environmental variables 
    and serialize them into a pickle object
      @input  :: ind \in [0,2[
      @return :: None
    """
    x = os.environ
    #pickle.dump(x, open(PKLFILES[ind],"wb" ))
    ofs=open(PKLFILES[ind],"wb")
    pickle.dump(x, ofs)
    ofs.close()
    return
    
def load(ind):
    """
    Load one of the pickled files into memory
       @input  :: ind \in [0,2[ 
       @return :: content as dictionary
    """
    x = pickle.load(open(PKLFILES[ind],"rb" ) )    
    return x

def rmTrailChar(str,c):
    """
    Remove all the trailing characters c from a string
      @input str :: starting string
      @input c   :: trailing characters
      @return    :: string without the trailing character
    """ 
    while(str[-1]==c and len(str)>0):
        str=str[:-1]
    return str
    
def getChangedEnv():
    """
    Find the difference in env. variables 
    between 2 pickled files (ANTE & POST sourcing) 
    and return them as Lua code 
      @return resLines :: list with lines of Lua code
    """
    dictLst = [ load(i) for i in range(len(PKLFILES))]

    resLines=[] 
    # CASE 1: Newly Defined Keys
    setLst = [ set([item for item in dictLst[i]])   for i in range(len(PKLFILES))] 
    newKeys = list(setLst[1] - setLst[0]) 

    print("  NEWLY DEFINED KEYS:: #{0}\n  {1}".format(len(newKeys),20*'=')) 
    if len(newKeys) > 0:
        resLines.append("-- NEWLY DEFINED KEYS :: ")
    for key in newKeys:
        print("    {0:<20} ::'{1}'".format(key,dictLst[1][key]))
        resLines.append('setenv("{0}","{1}")'.format(key,dictLst[1][key]))

    # CASE 2: Modified Keys
    resLines.append("")
    modKeys = [ key for key in list(setLst[0] & setLst[1]) \
                            if len(dictLst[0][key]) != len(dictLst[1][key])]

    print("\n\n  MODIFIED KEYS :: #{0}\n  {1}".format(len(modKeys),16*'=')) 
    if len(modKeys) > 0:
        resLines.append("-- MODIFIED KEYS ::")
    for key in modKeys:
        print("    ANTE:: {0:<20} ::'{1}'".format(key,dictLst[0][key]))
        print("    POST:: {0:<20} ::'{1}'\n".format(key,dictLst[1][key]))
        ind_old = dictLst[1][key].find(dictLst[0][key]) 
        len_old = len(dictLst[0][key])
        str = rmTrailChar(dictLst[1][key][:ind_old] + 
                          dictLst[1][key][ind_old+len_old:],':')
        resLines.append('prepend_path("{0}","{1}")'.format(key,str))
    return resLines 

def getHead(compiler,version,now=""):
    """
    Function which generates the Header of a 
    Compiler module file:
      @input compiler :: compiler name ('intel','pgi',...)
      @input version  :: version of the compiler
      @input now      :: date 
      @return         :: list of Lua lines
    """
    strA = 'This module loads the {0} compiler path and'.format(compiler.title())
    strB = 'environmental variables (v.{0})'.format(version)
    strC = 'whatis("Name: {0} Compilers")'.format(compiler.title()) 
    strD = 'whatis("Version: {0}")'.format(version)

    if compiler.lower().strip() == 'intel' :
        strE = 'whatis("URL: http://www.intel.com")'
    elif compiler.lower().strip() == 'pgi':
        strE = 'whatis("URL: http://www.pgroup.com")' 

    if len(now)== 0:
        today = datetime.date.today()
        strF = 'whatis("Installed on {0}/{1}/{2}")'.format(today.month,
                                     today.day, today.year)
    else:
        strF = 'whatis("Installed on {0}")'.format(now)

    res  = ['-- -*- lua -*-', '-- Created by a script by Wim R.M. Cardoen','help(',
            '[[', strA, strB, ']])','', strC, strD,
            'whatis("Category: compiler")','whatis("Keywords: System, compiler")',
            strE, strF, ''] 
    return res

def getTail(compiler,version):
    """
    Function which generates the Tail of a
    Compiler module file.
      @input compiler :: compiler name ('intel','pgi',..)
      @input version  :: version of the compiler
      @return         :: list of Lua lines
    """
    strA = 'local version = "{0}"'.format(version)
    strB = 'local mdir = pathJoin(mroot,"Compiler/{0}",version)'.format(compiler.lower()) 
    strC = '--      a. compiled with {0}/{1}'.format(compiler.title(),version)
    strD = '       local mdir = pathJoin(mroot,"Compiler",CLUSTERNAME,"{0}",version)'.format(compiler)
    res = ['','',
           '-- MODULEPATH modification to include packages',
           '-- that are compiled with this version of the compiler',
           '-- and available ON ALL clusters', strA,
           'local mroot = os.getenv("MODULEPATH_ROOT")', strB,
           'prepend_path("MODULEPATH",mdir)','','',
           '-- MODULEPATH modification to include packages',
           '-- that are:', strC,
           '--      b. ONLY available ON a specific cluster','',
           'local CLUSTERNAME = nil',
           'local str = os.getenv("UUFSCELL")','',
           'if str ~= nil then',
           '   if str == "ash.peaks" then',
           '      CLUSTERNAME = "ash"',
           '   elseif str == "ember.arches" then',
           '      CLUSTERNAME = "em"',
           '   elseif str == "kingspeak.peaks" then',
           '      CLUSTERNAME = "kp"',
           '   elseif str == "lonepeak.peaks" then',
           '      CLUSTERNAME = "lp"',
           '   end','',
           '   if CLUSTERNAME ~= nil then', strD,
           '       prepend_path("MODULEPATH",mdir)',
           '   end',
           'end']
    return res

def writeFile(filename,arr):
    """
    Write an arr of lines to a file
      @input filename :: name of the file
      @input arr      :: array of lines
      @return None
    """
    try:
        f=open(filename,'w')
        f.writelines("\n".join(arr))
        f.close()
    except IOError:
        print("  ERROR: can't write to '{0}'".format(filename))
    return 

def writeEnvCmdsToFile(filename="env.lua"):
    """
    Function to write ONLY the new & modified 
    env. variables into a file
      @input filename :: name of the file
      @return None
    """
    res = getChangedEnv()
    writeFile(filename,res)
    return

def writeCompFile(compiler,version):
    """
    Function which writes a module file (Lua)
    for a compiler (intel,pgi) of a certain version
      @input compiler :: name of the compiler
      @input version  :: version of the compiler
      @return None
    """
    res = getHead(compiler,version,now='')
    res.extend(getChangedEnv())
    res.extend(getTail(compiler,version))
    writeFile(version +'.lua',res) 
    return

def cleanup():
    """
    Function which removes the temporary created pickled files
      @return None
    """
    for i in range(len(PKLFILES)):
        os.remove(PKLFILES[i])
    return 
