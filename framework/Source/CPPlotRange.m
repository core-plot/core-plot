
#import "CPPlotRange.h"
#import "CPPlatformSpecificCategories.h"

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

#pragma mark -
#pragma mark Accessors

-(NSDecimalNumber *)end 
{
    return [self.location decimalNumberByAdding:self.length];
}

#pragma mark -
#pragma mark NSCopying

-(id)copyWithZone:(NSZone *)zone 
{
    CPPlotRange *newRange = [[CPPlotRange allocWithZone:zone] init];
    newRange.location = self.location;
    newRange.length = self.length;
    return newRange;
}

#pragma mark -
#pragma mark NSCoding

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

#pragma mark -
#pragma mark Checking Containership

-(BOOL)contains:(NSDecimalNumber *)number
{
	return ([number isGreaterThanOrEqualTo:location] && [number isLessThanOrEqualTo:self.end]);
}

#pragma mark -
#pragma mark Description

- (NSString*)description
{
	return [NSString stringWithFormat:@"CPPlotRange from %@, length %@", location, length]; 
}

@end
