/** GSWProjectBundle - <title>GSWeb: Class GSWProjectBundle</title>

   Copyright (C) 1999-2002 Free Software Foundation, Inc.
  
   Written by:	Manuel Guesdon <mguesdon@orange-concept.com>
   Date: 	Mar 1999
   
   $Revision$
   $Date$

   This file is part of the GNUstep Web Library.
   
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

// $Id$

#ifndef _GSWProjectBundle_h__
	#define _GSWProjectBundle_h__


//====================================================================
@interface GSWProjectBundle : GSWDeployedBundle
{
  NSDictionary* _subprojects;
  NSDictionary* _pbProjectDictionary;
};

-(id)initWithPath:(NSString*)aPath;
-(NSArray*)lockedPathsForResourcesOfType:(id)aType;
-(NSArray*)lockedPathsForResourcesInSubprojectsOfType:(id)aType;
-(NSString*)lockedRelativePathForResourceNamed:(NSString*)aName
                                      language:(NSString*)aLanguage;
-(NSString*)lockedRelativePathForResourceNamed:(NSString*)aName
                                     languages:(NSArray*)someLanguages;
-(NSDictionary*)subprojects;
-(BOOL)isFramework;
-(GSWDeployedBundle*)projectBundle;
-(NSString*)projectPath;
-(NSDictionary*)_pbProjectDictionary;
@end


@interface GSWProjectBundle (GSWProjectBundle)
+(GSWDeployedBundle*)projectBundleForProjectNamed:(NSString*)aName
                                      isFramework:(BOOL)isFramework;
@end


#endif //_GSWProjectBundle_h__
