
#import <Foundation/Foundation.h>
#import "CPDefinitions.h"

@interface CPPlotRange : NSObject <NSCoding, NSCopying> {
	@private
	NSDecimal location;
	NSDecimal length;
	double doublePrecisionLocation;
	double doublePrecisionLength;
}

@property (readwrite) NSDecimal location;
@property (readwrite) NSDecimal length;
@property (readonly) NSDecimal end;
@property (readwrite) double doublePrecisionLocation;
@property (readwrite) double doublePrecisionLength;
@property (readonly) double doublePrecisionEnd;

+(CPPlotRange *)plotRangeWithLocation:(NSDecimal)loc length:(NSDecimal)len;

-(id)initWithLocation:(NSDecimal)loc length:(NSDecimal)len;

-(BOOL)contains:(NSDecimal)number;

-(void)unionPlotRange:(CPPlotRange *)otherRange;

-(void)expandRangeByFactor:(NSDecimal)factor;

@end
