
#import "CPPlotRange.h"
#import "CPPlatformSpecificCategories.h"
#import "NSDecimalNumberExtensions.h"
#import "CPUtilities.h"

/** @brief Defines a range of plot data
 **/

@implementation CPPlotRange

/** @property location
 *  @brief The starting value of the range.
 **/
@synthesize location;

/** @property length
 *  @brief The length of the range.
 **/
@synthesize length;

/** @property end
 *  @brief The ending value of the range.
 **/
@dynamic end;

#pragma mark -
#pragma mark Init/Dealloc

/** @brief Creates and returns a new CPPlotRange instance initialized with the provided location and length.
 *  @param loc The starting location of the range.
 *  @param len The length of the range.
 *  @return A new CPPlotRange instance initialized with the provided location and length.
 **/
+(CPPlotRange *)plotRangeWithLocation:(NSDecimal)loc length:(NSDecimal)len
{
	return [[[CPPlotRange alloc] initWithLocation:loc length:len] autorelease];
}

/** @brief Initializes a newly allocated CPPlotRange object with the provided location and length.
 *  @param loc The starting location of the range.
 *  @param len The length of the range.
 *  @return The initialized CPPlotRange object.
 **/
-(id)initWithLocation:(NSDecimal)loc length:(NSDecimal)len
{
	if (self = [super init]) {
		self.location = loc;
		self.length = len;
	}
	return self;	
}

-(void)dealloc
{
	[super dealloc];
}

#pragma mark -
#pragma mark Accessors

-(NSDecimal)end 
{
    return CPDecimalAdd(self.location, self.length);
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
    [encoder encodeObject:[NSDecimalNumber decimalNumberWithDecimal:self.location]];
    [encoder encodeObject:[NSDecimalNumber decimalNumberWithDecimal:self.length]];
    
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
        location = [[decoder decodeObject] decimalValue];
        length = [[decoder decodeObject] decimalValue];
    }
    
    return self;
}

#pragma mark -
#pragma mark Checking Containership

/** @brief Determines whether a given number is inside the range.
 *  @param number The number to check.
 *  @return True if <tt>location</tt> ≤ <tt>number</tt> ≤ <tt>end</tt>.
 **/
-(BOOL)contains:(NSDecimal)number
{
	return (CPDecimalGreaterThanOrEqualTo(number, location) && CPDecimalLessThanOrEqualTo(number, self.end));
}

#pragma mark -
#pragma mark Description

- (NSString*)description
{
	return [NSString stringWithFormat:@"CPPlotRange from %@, length %@", NSDecimalString(&location, [NSLocale currentLocale]), NSDecimalString(&length, [NSLocale currentLocale])]; 
}

@end
