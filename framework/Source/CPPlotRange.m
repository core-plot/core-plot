//
//  CPPlotRange.m
//  CorePlot
//
//  Created by Bob Beaty on 2/23/09.
//  as part of the CorePlot project
//

// Apple Headers

// System Headers

// Third Party Headers

// Other Headers

// Class Headers
#import "CPPlotRange.h"

// Superclass Headers

// Forward Class Declarations

// Public Data Types

// Public Constants

// Public Macros


@implementation CPPlotRange
/*"
** The purpose of this class is to model a plot range (location and length)
** while allowing the proper encoing of the ivars in Core Animation. In the
** more straight-forward implementation, this might be a struct with two
** NSDecimal values (themselves structs). This works fine for a lot of things,
** but Core Animation wants to encode these properties and since these
** structs can't conform to the NSCoder protocol, the Core Animation needs to
** know them and how to encode/decode them. This, unfortunately, isn't the
** case, so we're stuck with runtime error messages that look a lot like this:
**
** 2009-02-23 09:49:43.454 CPTestApp[37628:10b] unhandled property type encoding: `{_CPPlotRange="location"{?="_exponent"b8"_length"b4"_isNegative"b1"_isCompact"b1"_reserved"b18"_mantissa"[8S]}"length"{?="_exponent"b8"_length"b4"_isNegative"b1"_isCompact"b1"_reserved"b18"_mantissa"[8S]}}'
**
** So, in order to make this a clean implementation, we need to make this a
** first-class citizen using NSDecimalNumber objects that conform to the
** NSCoding protocol, and then everything will work.
**
** The convenience methods on this guy make it possible to use NSDecimal
** values in and out of this guy so as to make it appear as close to the
** 'traditional' implementation as possible.
"*/

//----------------------------------------------------------------------------
//               Accessor Methods
//----------------------------------------------------------------------------
@synthesize location;
@synthesize length;

//----------------------------------------------------------------------------
//               Class Creation Methods
//----------------------------------------------------------------------------
+ (CPPlotRange *) plotRangeWithDoubleLocation:(CPDouble)loc andLength:(CPDouble)len
/*"
** This method creates and returns an autoreleased CPPlotRange based on the
** location and length parameters provided. The CPDoubles are converted to
** the necessary data types for the new CPPlotRange instance and the result
** is returned.
"*/
{
	return [[[CPPlotRange alloc] initWithDoubleLocation:loc andLength:len] autorelease];
}

+ (CPPlotRange *) plotRangeWithDecimalLocation:(NSDecimal)loc andLength:(NSDecimal)len
/*"
** This method creates and returns an autoreleased CPPlotRange based on the
** location and length parameters provided. The doubles are converted to
** the necessary data types for the new CPPlotRange instance and the result
** is returned.
"*/
{
	return [[[CPPlotRange alloc] initWithDecimalLocation:loc andLength:len] autorelease];
}

+ (CPPlotRange *) plotRangeWithDecimalNumberLocation:(NSDecimalNumber *)loc andLength:(NSDecimalNumber *)len
/*"
** This method creates and returns an autoreleased CPPlotRange based on the
** location and length parameters provided. The doubles are converted to
** the necessary data types for the new CPPlotRange instance and the result
** is returned.
"*/
{
	return [[[CPPlotRange alloc] initWithDecimalNumberLocation:loc andLength:len] autorelease];
}


//----------------------------------------------------------------------------
//               Initialization Methods
//----------------------------------------------------------------------------
- (id) initWithDoubleLocation:(CPDouble)loc andLength:(CPDouble)len
/*"
** Given the double values for location and length, we can initialize
** this guy nicely. These CPDouble values will be used to create new
** NSDecimalNumber instances and those will be retained for use.
"*/
{
	if (self = [super init]) {
		self.location = [NSDecimalNumber decimalNumberWithDecimal:[[NSNumber numberWithDouble:loc] decimalValue]];
		self.length = [NSDecimalNumber decimalNumberWithDecimal:[[NSNumber numberWithDouble:len] decimalValue]];
	}
	return self;	
}

- (id) initWithDecimalLocation:(NSDecimal)loc andLength:(NSDecimal)len
/*"
** Given the NSDecimal values for location and length, we can initialize
** this guy nicely. These NSDecimal values will be used to create new
** NSDecimalNumber instances and those will be retained for use.
"*/
{
	if (self = [super init]) {
		self.location = [NSDecimalNumber decimalNumberWithDecimal:loc];
		self.length = [NSDecimalNumber decimalNumberWithDecimal:len];
	}
	return self;	
}

- (id) initWithDecimalNumberLocation:(NSDecimalNumber *)loc andLength:(NSDecimalNumber *)len
/*"
** Given the NSDecimalNumber values for location and length, we can initialize
** this guy nicely. The values will be copied into this instance, so don't
** expect the values to track the arguments as they change.
"*/
{
	if (self = [super init]) {
		self.location = loc;
		self.length = len;
	}
	return self;	
}

//----------------------------------------------------------------------------
//               NSObject Overridden Methods
//----------------------------------------------------------------------------

- (void) dealloc
/*"
 **	This method is called then the class is deallocated (freed) and
 **	we need to clean things up. For the most part, this is really
 **	pretty simple, but it can get nasty at times, so we need to be
 **	careful.
 "*/
{
	// drop all the memory we're using
	self.location = nil;
	self.length = nil;
	// ...and don't forget to call the super's dealloc too...
	[super dealloc];
}

@end
