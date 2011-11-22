#import "CPTLimitBand.h"

#import "CPTFill.h"
#import "CPTPlotRange.h"

/**
 *	@brief Defines a range and fill used to highlight a band of data.
 **/
@implementation CPTLimitBand

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

/** @brief Creates and returns a new CPTLimitBand instance initialized with the provided range and fill.
 *  @param newRange The range of the band.
 *  @param newFill The fill used to draw the interior of the band.
 *  @return A new CPTLimitBand instance initialized with the provided range and fill.
 **/
+(CPTLimitBand *)limitBandWithRange:(CPTPlotRange *)newRange fill:(CPTFill *)newFill
{
	return [[[CPTLimitBand alloc] initWithRange:newRange fill:newFill] autorelease];
}

/** @brief Initializes a newly allocated CPTLimitBand object with the provided range and fill.
 *  @param newRange The range of the band.
 *  @param newFill The fill used to draw the interior of the band.
 *  @return The initialized CPTLimitBand object.
 **/
-(id)initWithRange:(CPTPlotRange *)newRange fill:(CPTFill *)newFill
{
	if ( (self = [super init]) ) {
		range = [newRange retain];
		fill  = [newFill retain];
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
	CPTLimitBand *newBand = [[CPTLimitBand allocWithZone:zone] init];

	if ( newBand ) {
		newBand->range = [self->range copyWithZone:zone];
		newBand->fill  = [self->fill copyWithZone:zone];
	}
	return newBand;
}

#pragma mark -
#pragma mark NSCoding

-(void)encodeWithCoder:(NSCoder *)encoder
{
	if ( [encoder allowsKeyedCoding] ) {
		[encoder encodeObject:range forKey:@"CPTLimitBand.range"];
		[encoder encodeObject:fill forKey:@"CPTLimitBand.fill"];
	}
	else {
		[encoder encodeObject:range];
		[encoder encodeObject:fill];
	}
}

-(id)initWithCoder:(NSCoder *)decoder
{
	CPTPlotRange *newRange;
	CPTFill *newFill;

	if ( [decoder allowsKeyedCoding] ) {
		newRange = [decoder decodeObjectForKey:@"CPTLimitBand.range"];
		newFill	 = [decoder decodeObjectForKey:@"CPTLimitBand.fill"];
	}
	else {
		newRange = [decoder decodeObject];
		newFill	 = [decoder decodeObject];
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
