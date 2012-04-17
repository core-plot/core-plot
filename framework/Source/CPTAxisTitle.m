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
#pragma mark Layout

/// @name Layout
/// @{

-(void)positionRelativeToViewPoint:(CGPoint)point forCoordinate:(CPTCoordinate)coordinate inDirection:(CPTSign)direction
{
	CGPoint newPosition	  = point;
	CGFloat *value		  = ( coordinate == CPTCoordinateX ? &(newPosition.x) : &(newPosition.y) );
	CGFloat titleRotation = self.rotation;

	if ( isnan(titleRotation) ) {
		titleRotation = (coordinate == CPTCoordinateX ? M_PI_2 : 0.0);
	}
	CGPoint anchor = CGPointZero;

	// Position the anchor point along the closest edge.
	switch ( direction ) {
		case CPTSignNone:
		case CPTSignNegative:
			*value -= self.offset;
			anchor	= ( coordinate == CPTCoordinateX ? CGPointMake(0.5, 0.0) : CGPointMake(0.5, 1.0) );
			break;

		case CPTSignPositive:
			*value += self.offset;
			anchor	= ( coordinate == CPTCoordinateX ? CGPointMake(0.5, 1.0) : CGPointMake(0.5, 0.0) );
			break;

		default:
			[NSException raise:CPTException format:@"Invalid sign in positionRelativeToViewPoint:inDirection:"];
			break;
	}

	// Pixel-align the title layer to prevent blurriness
	CPTLayer *content = self.contentLayer;

	content.anchorPoint = anchor;
	content.position	= newPosition;
	content.transform	= CATransform3DMakeRotation(titleRotation, 0.0, 0.0, 1.0);
	[content pixelAlign];
	[content setNeedsDisplay];
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
