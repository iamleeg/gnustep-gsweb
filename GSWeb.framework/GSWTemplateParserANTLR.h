/* GSWTemplateParserANTLR.h - GSWeb: Class GSWTemplateParserANTLR
   Copyright (C) 1999 Free Software Foundation, Inc.
   
   Written by:	Manuel Guesdon <mguesdon@sbuilders.com>
   Date: 		Mar 1999
   
   This file is part of the GNUstep Web Library.
   
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
*/

// $Id$

#ifndef _GSWTemplateParserANTLR_h__
	#define _GSWTemplateParserANTLR_h__

#include <gsantlr/ANTLRCommon.h>
#include <gsantlr/ANTLRTextStreams.h>
#include "GSWTemplateParser.h"
#include "GSWHTMLTokenTypes.h"
#include "GSWPageDefLexer.h"
#include "GSWPageDefParser.h"
#include "GSWPageDefParserExt.h"
#include "GSWHTMLAttrLexer.h"
#include "GSWHTMLAttrParser.h"
#include "GSWHTMLAttrParserExt.h"


//====================================================================
@interface GSWTemplateParserANTLR : GSWTemplateParser
{
  NSMutableDictionary* _tagsNames;
  NSMutableDictionary* _tagsAttrs;
};
-(void)dealloc;
-(NSArray*)templateElements;
-(NSArray*)createElementsStartingWithAST:(ANTLRDefAST*)_AST
                          stopOnTagNamed:(NSString*)_stopTagName;

-(BOOL)parseTag:(ANTLRDefAST)_AST;
-(NSString*)getTagNameFor:(ANTLRDefAST)_AST;
-(NSDictionary*)getTagAttrsFor:(ANTLRDefAST)_AST;
@end

#endif //_GSWTemplateParserANTLR_h__
