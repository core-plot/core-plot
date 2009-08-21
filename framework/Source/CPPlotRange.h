
#import <Foundation/Foundation.h>
#import "CPDefinitions.h"

@interface CPPlotRange : NSObject <NSCoding, NSCopying> {
	@private
	NSDecimal location;
	NSDecimal length;
}

@property (readwrite) NSDecimal location;
@property (readwrite) NSDecimal length;
@property (readonly) NSDecimal end;

+(CPPlotRange *)plotRangeWithLocation:(NSDecimal)loc length:(NSDecimal)len;

-(id)initWithLocation:(NSDecimal)loc length:(NSDecimal)len;

-(BOOL)contains:(NSDecimal)number;

@end
