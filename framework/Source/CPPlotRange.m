
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
	[location release];
    [length release];
    
	[super dealloc];
}

#pragma mark <NSCoding>
- (void)encodeWithCoder:(NSCoder *)encoder 
{
    [encoder encodeObject:self.location];
    [encoder encodeObject:self.length];
    
    if ([[super class] conformsToProtocol:@protocol(NSCoding)]) {
        [(id <NSCoding>)super encodeWithCoder:encoder];
    }
}

- (id)initWithCoder:(NSCoder *)decoder 
{
    if ([[super class] conformsToProtocol:@protocol(NSCoding)]) {
        self = [(id <NSCoding>)super initWithCoder:decoder];
    } else {
        self = [super init];
    }
    
    if (self) {
        location = [[decoder decodeObject] retain];
        length = [[decoder decodeObject] retain];
    }
    
    return self;
}

@end
