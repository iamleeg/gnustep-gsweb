/** GSWProcFS.m - <title>GSWeb: Class GSWApplication</title>

   Copyright (C) 1999-2003 Free Software Foundation, Inc.
   
   Written by:  Manuel Guesdon <mguesdon@orange-concept.com>
   Date: 	Oct 1999

   $Revision$
   $Date$
   $Id$
   
   This file is part of the GNUstep Web Library.
   
   <abstract>
   /proc management
   </abstract>

   <license>
   This library is free software; you can redistribute it and/or
   modify it under the terms of the GNU Library General Public
   License as published by the Free Software Foundation; either
   version 2 of the License, or (at your option) any later version.
   
   This library is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
   Library General Public License for more details.
   
   You should have received a copy of the GNU Library General Public
   License along with this library; if not, write to the Free
   Software Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
   </license>
**/

#include "config.h"

RCS_ID("$Id$")

#include "GSWeb.h"

NSString* formattedByteSizeValue(unsigned int value)
{
  if (value<1024)
    return [NSString stringWithFormat:@"%u b",value];
  else if (value<1024L*1024L)
    return [NSString stringWithFormat:@"%.3f Kb",
		     (((double)value)/1024)];
  else if (value<1024L*1024L*1024L)
    return [NSString stringWithFormat:@"%.3f Mb",
		     (((double)value)/(1024L*1024L))];
  else
    return [NSString stringWithFormat:@"%.3f Gb",
		     (((double)value)/(1024L*1024L*1024L))];
};

@implementation GSWProcFSProcInfo

+ (GSWProcFSProcInfo *)filledProcInfo
{
  int processID = [[NSProcessInfo processInfo] processIdentifier];
  return [self filledProcInfoWithPID: processID];
}

+ (GSWProcFSProcInfo *)filledProcInfoWithPID: (int)processID
{
  GSWProcFSProcInfo *obj
    = AUTORELEASE([[self alloc] initFilledWithPID: processID]);
  return obj;
}

- (id)initFilledWithPID: (int)processID
{
  if ((self = [super init]))
    {
      _pid = processID;
      [self fill];
    };
  return self;
}

-(void)dealloc
{
  DESTROY(_user);
  DESTROY(_command);
  DESTROY(_ttyc);
  DESTROY(_environ);
  DESTROY(_commandLine);
  [super dealloc];
};

-(NSString*)description
{
  NSString* dscr=nil;
  unsigned int pageSize=NSPageSize();
  char* stateCString=NULL;
  switch(_state)
    {
    case GSWProcState__Sleeping:
      stateCString="Sleeping";
      break;
    case GSWProcState__Running:
      stateCString="Running";
      break;
    case GSWProcState__Zombie:
      stateCString="Zombie";
      break;
    case GSWProcState__Stopped:
      stateCString="Stopped";
      break;
    case GSWProcState__SleepWait:
      stateCString="Waiting-Sleeping";
      break;
    case GSWProcState__Unknown:
    default:
      stateCString="Unknown";
      break;
    };
  dscr=[NSString stringWithFormat:@"user: %@\ncmd: %@\nState: %s\nttyc: %@\nenviron: %@\ncommand line:%@\n",
                 _user,
                 _command,
                 stateCString,
                 _ttyc,
                 _environ,
                 _commandLine];
  dscr=[dscr stringByAppendingFormat:@"uid: %d\npid: %d\nppid: %d\npgrp: %d\nsession: %d\ntty: %d\ntpgid: %d\npriority: %d\nnice: %d\nsignal: %llX\nblocked: %llX\nsigIgnore: %llX\nsigCache: %llX\n",
             _uid,
             _pid,
             _ppid,
             _pgrp,
             _session,
             _tty,
             _tpgid,
             _priority,
             _nice,
             _signal,
             _blocked,
             _sigIgnore,
             _sigCatch];
  dscr=[dscr stringByAppendingFormat:@"startTime: %@\nuserTime: %f\nsystemTime: %f\ncumulativeUserTime: %f\ncumulativeSystemTime: %f\n",
             [NSDate dateWithTimeIntervalSinceReferenceDate:_startTime],
             _userTime,
             _systemTime,
             _cumulativeUserTime,
             _cumulativeSystemTime];
  dscr=[dscr stringByAppendingFormat:@"pagesNb=%ld (size: %@)\nresidentPagesNb: %ld (size: %@)\nsharedPagesNb: %ld (size: %@)\ntextResidentSize: %@\nsharedLibResidentSize: %@\ndataResidentSize: %@\ndirtyPagesNb: %ld\n",
             _pagesNb,
             formattedByteSizeValue(_pagesNb*pageSize),
             _residentPagesNb,
             formattedByteSizeValue(_residentPagesNb*pageSize),
             _sharedPagesNb,
             formattedByteSizeValue(_sharedPagesNb*pageSize),
             formattedByteSizeValue(_textResidentSize),
             formattedByteSizeValue(_sharedLibResidentSize),
             formattedByteSizeValue(_dataResidentSize),
             _dirtyPagesNb];
  dscr=[dscr stringByAppendingFormat:@"cpuUsage: %u%%\nvirtualMemorySize: %@\nresidentMemorySize: %@\nresidentMemorySizeLimit: %@\ntimeout: %lu\nit_real_value: %lu\n",
             _cpuUsagePC,
             formattedByteSizeValue(_virtualMemorySize),
             formattedByteSizeValue(_residentMemorySize),
             formattedByteSizeValue(_residentMemorySizeLimit),
             _timeout,
             _it_real_value];
  /*  unsigned long flags,
      unsigned long minorPageFaultNb,
      unsigned long majorPageFaultNb,
      unsigned long cumulativeMinorPageFaultNb,
      unsigned long cumulativeMajorPageFaultNb,
      unsigned long startCodeAddress,
      unsigned long endCodeAddress,
      unsigned long startStackAddress,
      unsigned long kernelStackPointerESP,
      unsigned long kernelStackPointerEIP,
      unsigned long kernelWaitChannelProc,
  */
  return dscr;
};
-(BOOL)fill
{
  //TODO
  [self fillStat];
  [self fillStatm];
  return YES;
};

+ (NSString *)contentOfProcFile: (NSString *)procFile
{
    NSString         * path;
    NSString         * content;
    NSStringEncoding   usedEncoding;
    NSError          * error = nil;
    
    path = [NSString stringWithFormat: @"/proc/%@", procFile];

    content = [NSString stringWithContentsOfFile:path
                                    usedEncoding:&usedEncoding
                                           error:&error];
    
    if (!content)
    {
        //LOGSeriousError(@"Read (%@) attempt failed", path);
    }
    
    return content;
}

-(NSString*)contentOfPIDFile:(NSString*)pidFile
{
  NSString* content=nil;
  NSString* path
    = [NSString stringWithFormat:@"%d/%@",
		(_pid ? _pid 
		 : [[NSProcessInfo processInfo] processIdentifier]),
		pidFile];
  content=[[self class] contentOfProcFile: path];
  return content;
};

-(BOOL)fillStatm
{
  BOOL ok=NO;
  NSString* pidstat=[self contentOfPIDFile:@"statm"];

  if (pidstat)
    {
      const char* statsChars=[pidstat UTF8String];
      if (sscanf(statsChars, "%ld %ld %ld %ld %ld %ld %ld",
                 &_pagesNb,//size
                 &_residentPagesNb,//resident
                 &_sharedPagesNb,//share
                 &_textResidentSize, //trs
                 &_sharedLibResidentSize,//lrs
                 &_dataResidentSize,//drs
                 &_dirtyPagesNb//dt
                 )==7)
        ok=YES;
    };
  return ok;
};

-(BOOL)fillStat
{
  BOOL ok=NO;
  NSString* pidstat = [self contentOfPIDFile: @"stat"];

  if (pidstat)
    {
      NSRange cmdEnd=[pidstat rangeOfString:@") "];
      if (cmdEnd.length>0)
        {
//          NSString* pid_cmd=[pidstat substringToIndex:cmdEnd.location];

          if (cmdEnd.location+cmdEnd.length<[pidstat length])
            {
              NSString* stats=[pidstat substringFromIndex:cmdEnd.location+cmdEnd.length];
              /*
                char* tmp = strrchr(S, ')');        // split into "PID (cmd" and "<rest>" 
                *tmp = '\0';                        // replace trailing ')' with NUL 
                // parse these two strings separately, skipping the leading "(". 
                memset(P->cmd, 0, sizeof P->cmd);   // clear even though *P xcalloc'd ?! 
                sscanf(S, "%d (%39c", &P->pid, P->cmd);
              */
              const char* statsChars=[stats UTF8String];
              char cState;
              long utime;
              long stime;
              long cutime;
              long cstime;
              long startTime;
              
              if (sscanf(statsChars,
                         "%c %d %d %d %d %d %lu %lu %lu %lu %lu %ld %ld %ld %ld %d "
                         "%d %lu %lu %ld %lu %lu %lu %lu %lu %lu %lu %lu %llX %llX %llX %llX %lu",
                         &cState, //state
                         &_ppid,//ppid
                         &_pgrp,//pgrp
                         &_session,//session
                         &_tty,//tty
                         &_tpgid,//tpgid,
                         &_flags,//flags
                         &_minorPageFaultNb,//min_flt
                         &_cumulativeMinorPageFaultNb,//cmin_flt
                         &_majorPageFaultNb,//maj_flt
                         &_cumulativeMajorPageFaultNb,//cmaj_flt,
                         &utime,//utime
                         &stime,//stime
                         &cutime,//cutime
                         &cstime,//cstime
                         &_priority,//priority
                         &_nice,//nice,
                         &_timeout,//timeout
                         &_it_real_value,//it_real_value
                         &startTime,//start_time
                         &_virtualMemorySize,//vsize
                         &_residentMemorySize,//rss,
                         &_residentMemorySizeLimit,//rss_rlim
                         &_startCodeAddress,//start_code
                         &_endCodeAddress,//end_code
                         &_startStackAddress,//start_stack,
                         &_kernelStackPointerESP,//kstk_esp
                         &_kernelStackPointerEIP,//kstk_eip
                         &_signal,//signal
                         &_blocked,//blocked
                         &_sigIgnore,//sigignore,
                         &_sigCatch,//sigcatch
                         &_kernelWaitChannelProc//wchan
                         )==33)
                {
                  ok=YES;
                  switch(cState)
                    {
                    case 'S':
                      _state=GSWProcState__Sleeping;
                      break;
                    case 'R':
                      _state=GSWProcState__Running;
                      break;
                    case 'Z':
                      _state=GSWProcState__Zombie;
                      break;
                    case 'T':
                      _state=GSWProcState__Stopped;
                      break;
                    case 'D':
                      _state=GSWProcState__SleepWait;
                      break;
                    default:
                      _state=GSWProcState__Unknown;
                      break;
                    };
                  _userTime=utime;
                  _systemTime=stime;
                  _cumulativeUserTime=cutime;
                  _cumulativeSystemTime=cstime;
                  startTime=[[NSDate dateWithTimeIntervalSince1970:(NSTimeInterval)_startTime]timeIntervalSinceReferenceDate];
                  
                  if (_tty == 0)
                    _tty = -1;  // the old notty val, update elsewhere bef. moving to 0 
                  /*			  if (linux_version_code < LINUX_VERSION(1,3,39))
                                          {
                                          P->priority = 2*15 - P->priority;       // map old meanings to new 
                                          P->nice = 15 - P->nice;
                                          }
                                          if (linux_version_code < LINUX_VERSION(1,1,30) && P->tty != -1)
                                          P->tty = 4*0x100 + P->tty;              // when tty wasn't full devno 
                  */
                };
            };
        };
    };
  return ok;
};

-(unsigned int)residentMemory
{
  unsigned int pageSize=NSPageSize();
 return (unsigned int)(_residentPagesNb*pageSize);  
};

-(unsigned int)sharedMemory
{
  unsigned int pageSize=NSPageSize();
 return (unsigned int)(_sharedPagesNb*pageSize);
};

-(unsigned int)virtualMemory
{
  return (unsigned int)_virtualMemorySize;
  
};
-(unsigned int)swapMemory
{
  //TODO
  return 0;
};

-(unsigned int)usedMemory
{
  unsigned int residentMemory=[self residentMemory];
  unsigned int sharedMemory=[self sharedMemory];
  unsigned int virtualMemory=[self virtualMemory];
  return max(residentMemory+sharedMemory,virtualMemory);
};

-(NSString*)formattedResidentMemory
{
  return formattedByteSizeValue([self residentMemory]);
};

-(NSString*)formattedSharedMemory
{
  
  return formattedByteSizeValue([self sharedMemory]);
}

-(NSString*)formattedVirtualMemory
{
  return formattedByteSizeValue([self virtualMemory]);
}

-(NSString*)formattedSwapMemory
{
  return formattedByteSizeValue([self swapMemory]);
}

-(NSString*)formattedUsedMemory
{
  return formattedByteSizeValue([self usedMemory]);
}


@end
