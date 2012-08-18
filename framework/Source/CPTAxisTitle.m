#import "CPTAxisTitle.h"

#import "CPTExceptions.h"
#import "CPTLayer.h"
#import "CPTUtilities.h"
#import <tgmath.h>

/**	@brief An axis title.
 *
 *	The title can be text-based or can be the content of any CPTLayer provided by the user.
 **/
@implementation CPTAxisTitle

#pragma mark -
#pragma mark Init/Dealloc

/// @name Initialization
/// @{

-(id)initWithContentLayer:(CPTLayer *)layer
{
    if ( layer ) {
        if ( (self = [super initWithContentLayer:layer]) ) {
            self.rotation = NAN;
        }
    }
    else {
        [self release];
        self = nil;
    }
    return self;
}

///	@}

#pragma mark -
#pragma mark Label comparison

// Axis labels are equal if they have the same location
-(BOOL)isEqual:(id)object
{
    if ( self == object ) {
        return YES;
    }
    else if ( [object isKindOfClass:[self class]] ) {
        CPTAxisTitle *otherTitle = object;

        if ( (self.rotation != otherTitle.rotation) || (self.offset != otherTitle.offset) ) {
            return NO;
        }
        if ( ![self.contentLayer isEqual:otherTitle] ) {
            return NO;
        }
        return CPTDecimalEquals(self.tickLocation, ( (CPTAxisLabel *)object ).tickLocation);
    }
    else {
        return NO;
    }
}

-(NSUInteger)hash
{
    NSUInteger hashValue = 0;

    // Equal objects must hash the same.
    double tickLocationAsDouble = CPTDecimalDoubleValue(self.tickLocation);

    if ( !isnan(tickLocationAsDouble) ) {
        hashValue = (NSUInteger)fmod(ABS(tickLocationAsDouble), (double)NSUIntegerMax);
    }
    hashValue += (NSUInteger)fmod(ABS(self.rotation), (double)NSUIntegerMax);
    hashValue += (NSUInteger)fmod(ABS(self.offset), (double)NSUIntegerMax);

    return hashValue;
}

@end
