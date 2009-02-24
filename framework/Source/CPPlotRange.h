
#import <Foundation/Foundation.h>
#import "CPDefinitions.h"

@interface CPPlotRange : NSObject {
	@private
	NSDecimalNumber *location;
	NSDecimalNumber *length;
}

@property (readwrite, copy) NSDecimalNumber *location;
@property (readwrite, copy) NSDecimalNumber *length;

+(CPPlotRange *)plotRangeWithLocation:(NSDecimal)loc length:(NSDecimal)len;

-(id)initWithLocation:(NSDecimal)loc length:(NSDecimal)len;

@end
