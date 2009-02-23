//
//  CPPlotRange.h
//  CorePlot
//
//  Created by Bob Beaty on 2/23/09.
//  as part of the CorePlot project
//

// Apple Headers
#import <Foundation/Foundation.h>

// System Headers

// Third Party Headers

// Other Headers
#import "CPDefinitions.h"

// Class Headers

// Superclass Headers

// Forward Class Declarations

// Public Data Types

// Public Constants

// Public Macros


@interface CPPlotRange : NSObject {
	@private
	NSDecimalNumber*	location;
	NSDecimalNumber*	length;
}

/*"              Accessor Methods                 "*/
@property (readwrite, copy) NSDecimalNumber* location;
@property (readwrite, copy) NSDecimalNumber* length;

/*"              Class Creation Methods           "*/
+ (CPPlotRange *) plotRangeWithDoubleLocation:(CPDouble)loc andLength:(CPDouble)len;
+ (CPPlotRange *) plotRangeWithDecimalLocation:(NSDecimal)loc andLength:(NSDecimal)len;
+ (CPPlotRange *) plotRangeWithDecimalNumberLocation:(NSDecimalNumber *)loc andLength:(NSDecimalNumber *)len;

/*"              Initialization Methods           "*/
- (id) initWithDoubleLocation:(CPDouble)loc andLength:(CPDouble)len;
- (id) initWithDecimalLocation:(NSDecimal)loc andLength:(NSDecimal)len;
- (id) initWithDecimalNumberLocation:(NSDecimalNumber *)loc andLength:(NSDecimalNumber *)len;

/*"              NSObject Overridden Methods      "*/
- (void) dealloc;

@end
