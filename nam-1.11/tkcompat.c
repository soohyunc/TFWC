/*
 * Copyright (c) 1997 Regents of the University of California.
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 * 3. All advertising materials mentioning features or use of this software
 *    must display the following acknowledgement:
 *       This product includes software developed by the Computer Systems
 *       Engineering Group at Lawrence Berkeley Laboratory.
 * 4. Neither the name of the University nor of the Laboratory may be used
 *    to endorse or promote products derived from this software without
 *    specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE REGENTS AND CONTRIBUTORS ``AS IS'' AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED.  IN NO EVENT SHALL THE REGENTS OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 * OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
 * OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
 * SUCH DAMAGE.
 *
 * -------------------------------
 *
 * Filename: tkcompat.c
 *
 * Description:
 *     These are functions that are required for compiling with previous
 *     versions of tcl or tk.  
 *
 * @(#) $Header: /home/narwhal/u0/soohyunc/CVS_SERV/TFWC/nam-1.11/tkcompat.c,v 1.1.1.1 2005/05/08 22:37:16 soohyunc Exp $
 */

#ifndef TKCOMPAT_C
#define TKCOMPAT_C

#include "tk.h"

#if TK_MAJOR_VERSION < 8
#include "tkcompat.h"

/*
 *---------------------------------------------------------------------------
 *
 * Tk_GetFontMetrics --
 *
 *	Returns overall ascent and descent metrics for the given font.
 *	These values can be used to space multiple lines of text and
 *	to align the baselines of text in different fonts.
 *
 */
void Tk_GetFontMetrics(Tk_Font pf, Tk_FontMetrics *fmPtr)
{
	fmPtr->ascent = pf->ascent;
	fmPtr->descent = pf->descent;
	fmPtr->linespace = pf->ascent + pf->descent;
}
#endif /* (TK_MAJOR_VERSION < 8) */

#endif /* #ifdef TKCOMPAT_C */ 