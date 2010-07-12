#import "CPLimitBand.h"
#import "CPFill.h"
#import "CPPlotRange.h"

/** @brief Defines a range and fill used to highlight a band of data.
 **/
@implementation CPLimitBand

/** @property range
 *  @brief The data range for the band.
 **/
@synthesize range;

/** @property fill
 *  @brief The fill used to draw the band.
 **/
@synthesize fill;

#pragma mark -
#pragma mark Init/Dealloc

/** @brief Creates and returns a new CPLimitBand instance initialized with the provided range and fill.
 *  @param newRange The range of the band.
 *  @param newFill The fill used to draw the interior of the band.
 *  @return A new CPLimitBand instance initialized with the provided range and fill.
 **/
+(CPLimitBand *)limitBandWithRange:(CPPlotRange *)newRange fill:(CPFill *)newFill
{
	return [[[CPLimitBand alloc] initWithRange:newRange fill:newFill] autorelease];
}

/** @brief Initializes a newly allocated CPLimitBand object with the provided range and fill.
 *  @param newRange The range of the band.
 *  @param newFill The fill used to draw the interior of the band.
 *  @return The initialized CPLimitBand object.
 **/
-(id)initWithRange:(CPPlotRange *)newRange fill:(CPFill *)newFill
{
	if ( self = [super init] ) {
    	range = [newRange retain];
        fill = [newFill retain];
	}
	return self;	
}

-(void)dealloc
{
	[range release];
	[fill release];
	[super dealloc];
}

#pragma mark -
#pragma mark NSCopying

-(id)copyWithZone:(NSZone *)zone 
{
    CPLimitBand *newBand = [[CPLimitBand allocWithZone:zone] init];
	if ( newBand ) {
		newBand->range = [self->range copyWithZone:zone];
		newBand->fill = [self->fill copyWithZone:zone];
	}
    return newBand;
}

#pragma mark -
#pragma mark NSCoding

- (void)encodeWithCoder:(NSCoder *)encoder 
{
    if ( [encoder allowsKeyedCoding] ) {
		[encoder encodeObject:range forKey:@"range"];
		[encoder encodeObject:fill forKey:@"fill"];
	} else {
		[encoder encodeObject:range];
		[encoder encodeObject:fill];
	}
}

- (id)initWithCoder:(NSCoder *)decoder 
{
	CPPlotRange *newRange;
	CPFill *newFill;
	
    if ( [decoder allowsKeyedCoding] ) {
		newRange = [decoder decodeObjectForKey:@"range"];
		newFill = [decoder decodeObjectForKey:@"fill"];
	} else {
		newRange = [decoder decodeObject];
		newFill = [decoder decodeObject];
	}

    return [self initWithRange:newRange fill:newFill];
}

#pragma mark -
#pragma mark Description

-(NSString *)description
{
	return [NSString stringWithFormat:@"<%@ with range: %@ and fill: %@>", [super description], self.range, self.fill]; 
}

@end
