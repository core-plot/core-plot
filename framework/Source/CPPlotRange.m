
#import "CPPlotRange.h"

@implementation CPPlotRange

@synthesize location;
@synthesize length;

#pragma mark -
#pragma mark Init/Dealloc

+(CPPlotRange *)plotRangeWithLocation:(NSDecimal)loc length:(NSDecimal)len
{
	return [[[CPPlotRange alloc] initWithLocation:loc length:len] autorelease];
}

-(id)initWithLocation:(NSDecimal)loc length:(NSDecimal)len
{
	if (self = [super init]) {
		self.location = [NSDecimalNumber decimalNumberWithDecimal:loc];
		self.length = [NSDecimalNumber decimalNumberWithDecimal:len];
	}
	return self;	
}

-(void)dealloc
{
	self.location = nil;
	self.length = nil;
	[super dealloc];
}

@end
