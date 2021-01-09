//
//  stdhdr.h
//  Coreplot-Contours
//
//  Created by Steve Wainwright on 31/12/2020.
//

#ifndef stdhdr_h
#define stdhdr_h

// stdhdr.h : include file for standard system include files,
//  or project specific include files that are used frequently, but
//      are changed infrequently
//



// TODO: reference additional headers your program requires here
#include <stdlib.h>
#include <stdio.h>
#include <math.h>
#include <time.h>
#include <assert.h>

//////////////////////////////////////////////////////////////////////
// include guards
//////////////////////////////////////////////////////////////////////
// getting rid of silly debug messages
//#pragma warning(push)
//
////#include <yvals.h>              // warning numbers get enabled in yvals.h
//
//#pragma warning(disable: 4018)  // signed/unsigned mismatch
//#pragma warning(disable: 4100)  // unreferenced formal parameter
//#pragma warning(disable: 4146)  // unary minus operator applied to unsigned type, result still unsigned
//#pragma warning(disable: 4244)  // 'conversion' conversion from 'type1' to 'type2', possible loss of data
//#pragma warning(disable: 4245)  // conversion from 'type1' to 'type2', signed/unsigned mismatch
//#pragma warning(disable: 4511)  // 'class' : copy constructor could not be generated
//#pragma warning(disable: 4512)  // 'class' : assignment operator could not be generated
//#pragma warning(disable: 4663)  // C++ language change: to explicitly specialize class template 'vector'
//#pragma warning(disable: 4710)  // 'function' : function not inlined
//#pragma warning(disable: 4786)  // identifier was truncated to 'number' characters in the debug information

#include <iostream>
#include <list>
#include <string>
#include <vector>
#include <fstream>
#include <iomanip>
//#pragma warning(pop)

#ifndef MAX
#define MAX(a,b) ((a)>(b)?(a):(b))
#endif


#endif /* stdhdr_h */
