#import "CPTLimitBand.h"

#import "CPTFill.h"
#import "CPTPlotRange.h"

/**
 *  @brief Defines a range and fill used to highlight a band of data.
 **/
@implementation CPTLimitBand

/** @property CPTPlotRange *range
 *  @brief The data range for the band.
 **/
@synthesize range;

/** @property CPTFill *fill
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
+(instancetype)limitBandWithRange:(CPTPlotRange *)newRange fill:(CPTFill *)newFill
{
    return [[CPTLimitBand alloc] initWithRange:newRange fill:newFill];
}

/** @brief Initializes a newly allocated CPTLimitBand object with the provided range and fill.
 *  @param newRange The range of the band.
 *  @param newFill The fill used to draw the interior of the band.
 *  @return The initialized CPTLimitBand object.
 **/
-(instancetype)initWithRange:(CPTPlotRange *)newRange fill:(CPTFill *)newFill
{
    if ( (self = [super init]) ) {
        range = newRange;
        fill  = newFill;
    }
    return self;
}

/// @cond

-(instancetype)init
{
    return [self initWithRange:nil fill:nil];
}

/// @endcond

#pragma mark -
#pragma mark NSCopying Methods

/// @cond

-(id)copyWithZone:(NSZone *)zone
{
    CPTLimitBand *newBand = [[CPTLimitBand allocWithZone:zone] init];

    if ( newBand ) {
        newBand.range = self.range;
        newBand.fill  = self.fill;
    }
    return newBand;
}

/// @endcond

#pragma mark -
#pragma mark NSCoding Methods

/// @cond

-(void)encodeWithCoder:(NSCoder *)encoder
{
    if ( [encoder allowsKeyedCoding] ) {
        [encoder encodeObject:self.range forKey:@"CPTLimitBand.range"];
        [encoder encodeObject:self.fill forKey:@"CPTLimitBand.fill"];
    }
    else {
        [encoder encodeObject:self.range];
        [encoder encodeObject:self.fill];
    }
}

/// @endcond

/** @brief Returns an object initialized from data in a given unarchiver.
 *  @param decoder An unarchiver object.
 *  @return An object initialized from data in a given unarchiver.
 */
-(instancetype)initWithCoder:(NSCoder *)decoder
{
    if ( (self = [super init]) ) {
        if ( [decoder allowsKeyedCoding] ) {
            range = [decoder decodeObjectForKey:@"CPTLimitBand.range"];
            fill  = [decoder decodeObjectForKey:@"CPTLimitBand.fill"];
        }
        else {
            range = [decoder decodeObject];
            fill  = [decoder decodeObject];
        }
    }
    return self;
}

#pragma mark -
#pragma mark Description

/// @cond

-(NSString *)description
{
    return [NSString stringWithFormat:@"<%@ with range: %@ and fill: %@>", [super description], self.range, self.fill];
}

/// @endcond

@end
