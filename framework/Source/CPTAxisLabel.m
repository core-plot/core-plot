#import "CPTAxisLabel.h"

#import "CPTExceptions.h"
#import "CPTLayer.h"
#import "CPTMutableTextStyle.h"
#import "CPTTextLayer.h"
#import "CPTUtilities.h"
#import "NSCoderExtensions.h"
#import <tgmath.h>

/**	@brief An axis label.
 *
 *	The label can be text-based or can be the content of any CPTLayer provided by the user.
 **/
@implementation CPTAxisLabel

/**	@property contentLayer
 *	@brief The label content.
 **/
@synthesize contentLayer;

/**	@property offset
 *	@brief The offset distance between the axis and label.
 **/
@synthesize offset;

/**	@property rotation
 *	@brief The rotation of the label in radians.
 **/
@synthesize rotation;

/**	@property alignment
 *	@brief The alignment of the axis label with respect to the tick mark.
 **/
@synthesize alignment;

/**	@property tickLocation
 *	@brief The data coordinate of the ticklocation.
 **/
@synthesize tickLocation;

#pragma mark -
#pragma mark Init/Dealloc

/** @brief Initializes a newly allocated text-based CPTAxisLabel object with the provided text and style.
 *
 *	@param newText The label text.
 *	@param newStyle The text style for the label.
 *  @return The initialized CPTAxisLabel object.
 **/
-(id)initWithText:(NSString *)newText textStyle:(CPTTextStyle *)newStyle
{
	CPTTextLayer *newLayer = [[CPTTextLayer alloc] initWithText:newText style:newStyle];

	self = [self initWithContentLayer:newLayer];
	[newLayer release];

	return self;
}

/** @brief Initializes a newly allocated CPTAxisLabel object with the provided layer. This is the designated initializer.
 *
 *	@param layer The label content.
 *  @return The initialized CPTAxisLabel object.
 **/
-(id)initWithContentLayer:(CPTLayer *)layer
{
	if ( layer ) {
		if ( (self = [super init]) ) {
			contentLayer = [layer retain];
			offset		 = 20.0;
			rotation	 = 0.0;
			alignment	 = CPTAlignmentCenter;
			tickLocation = CPTDecimalFromInteger(0);
		}
	}
	else {
		[self release];
		self = nil;
	}
	return self;
}

-(void)dealloc
{
	[contentLayer release];
	[super dealloc];
}

#pragma mark -
#pragma mark NSCoding methods

-(void)encodeWithCoder:(NSCoder *)coder
{
	[coder encodeObject:self.contentLayer forKey:@"CPTAxisLabel.contentLayer"];
	[coder encodeCGFloat:self.offset forKey:@"CPTAxisLabel.offset"];
	[coder encodeCGFloat:self.rotation forKey:@"CPTAxisLabel.rotation"];
	[coder encodeInteger:self.alignment forKey:@"CPTAxisLabel.alignment"];
	[coder encodeDecimal:self.tickLocation forKey:@"CPTAxisLabel.tickLocation"];
}

-(id)initWithCoder:(NSCoder *)coder
{
	if ( (self = [super init]) ) {
		contentLayer = [[coder decodeObjectForKey:@"CPTAxisLabel.contentLayer"] retain];
		offset		 = [coder decodeCGFloatForKey:@"CPTAxisLabel.offset"];
		rotation	 = [coder decodeCGFloatForKey:@"CPTAxisLabel.rotation"];
		alignment	 = [coder decodeIntegerForKey:@"CPTAxisLabel.alignment"];
		tickLocation = [coder decodeDecimalForKey:@"CPTAxisLabel.tickLocation"];
	}
	return self;
}

#pragma mark -
#pragma mark Layout

/**	@brief Positions the axis label relative to the given point.
 *  The algorithm for positioning is different when the rotation property is non-zero.
 *  When zero, the anchor point is positioned along the closest side of the label.
 *  When non-zero, the anchor point is left at the center. This has consequences for
 *  the value taken by the offset.
 *	@param point The view point.
 *	@param coordinate The coordinate in which the label is being position. Orthogonal to the axis coordinate.
 *	@param direction The offset direction.
 **/
-(void)positionRelativeToViewPoint:(CGPoint)point forCoordinate:(CPTCoordinate)coordinate inDirection:(CPTSign)direction
{
	CPTLayer *content = self.contentLayer;

	if ( !content ) {
		return;
	}

	CGPoint newPosition = point;
	CGFloat *value		= ( coordinate == CPTCoordinateX ? &(newPosition.x) : &(newPosition.y) );
	CGFloat angle		= 0.0;

	CGFloat myRotation = self.rotation;
	content.transform = CATransform3DMakeRotation(myRotation, 0.0, 0.0, 1.0);
	CGRect contentFrame = content.frame;

	// Position the anchor point along the closest edge.
	switch ( direction ) {
		case CPTSignNone:
		case CPTSignNegative:
			*value -= self.offset;

			switch ( coordinate ) {
				case CPTCoordinateX:
					angle = M_PI;

					switch ( self.alignment ) {
						case CPTAlignmentBottom:
							newPosition.y += contentFrame.size.height / (CGFloat)2.0;
							break;

						case CPTAlignmentTop:
							newPosition.y -= contentFrame.size.height / (CGFloat)2.0;
							break;

						default: // middle
							     // no adjustment
							break;
					}
					break;

				case CPTCoordinateY:
					angle = -M_PI_2;

					switch ( self.alignment ) {
						case CPTAlignmentLeft:
							newPosition.x += contentFrame.size.width / (CGFloat)2.0;
							break;

						case CPTAlignmentRight:
							newPosition.x -= contentFrame.size.width / (CGFloat)2.0;
							break;

						default: // center
							     // no adjustment
							break;
					}
					break;

				default:
					[NSException raise:NSInvalidArgumentException format:@"Invalid coordinate in positionRelativeToViewPoint:forCoordinate:inDirection:"];
					break;
			}
			break;

		case CPTSignPositive:
			*value += self.offset;

			switch ( coordinate ) {
				case CPTCoordinateX:
					// angle = 0.0;

					switch ( self.alignment ) {
						case CPTAlignmentBottom:
							newPosition.y += contentFrame.size.height / (CGFloat)2.0;
							break;

						case CPTAlignmentTop:
							newPosition.y -= contentFrame.size.height / (CGFloat)2.0;
							break;

						default: // middle
							     // no adjustment
							break;
					}
					break;

				case CPTCoordinateY:
					angle = M_PI_2;

					switch ( self.alignment ) {
						case CPTAlignmentLeft:
							newPosition.x += contentFrame.size.width / (CGFloat)2.0;
							break;

						case CPTAlignmentRight:
							newPosition.x -= contentFrame.size.width / (CGFloat)2.0;
							break;

						default: // center
							     // no adjustment
							break;
					}
					break;

				default:
					[NSException raise:NSInvalidArgumentException format:@"Invalid coordinate in positionRelativeToViewPoint:forCoordinate:inDirection:"];
					break;
			}
			break;

		default:
			[NSException raise:NSInvalidArgumentException format:@"Invalid direction in positionRelativeToViewPoint:forCoordinate:inDirection:"];
			break;
	}

	angle += M_PI;
	angle -= myRotation;
	CGFloat newAnchorX = cos(angle);
	CGFloat newAnchorY = sin(angle);

	if ( ABS(newAnchorX) <= ABS(newAnchorY) ) {
		newAnchorX /= ABS(newAnchorY);
		newAnchorY	= signbit(newAnchorY) ? -1.0 : 1.0;
	}
	else {
		newAnchorY /= ABS(newAnchorX);
		newAnchorX	= signbit(newAnchorX) ? -1.0 : 1.0;
	}
	CGPoint anchor = CGPointMake( (newAnchorX + (CGFloat)1.0) / (CGFloat)2.0, (newAnchorY + (CGFloat)1.0) / (CGFloat)2.0 );

	content.anchorPoint = anchor;
	content.position	= newPosition;
	[content pixelAlign];
	[content setNeedsDisplay];
}

/**	@brief Positions the axis label between two given points.
 *	@param firstPoint The first view point.
 *	@param secondPoint The second view point.
 *	@param coordinate The axis coordinate.
 *	@param direction The offset direction.
 **/
-(void)positionBetweenViewPoint:(CGPoint)firstPoint andViewPoint:(CGPoint)secondPoint forCoordinate:(CPTCoordinate)coordinate inDirection:(CPTSign)direction
{
	[self positionRelativeToViewPoint:CGPointMake( (firstPoint.x + secondPoint.x) / (CGFloat)2.0, (firstPoint.y + secondPoint.y) / (CGFloat)2.0 )
						forCoordinate:coordinate
						  inDirection:direction];
}

#pragma mark -
#pragma mark Description

-(NSString *)description
{
	return [NSString stringWithFormat:@"<%@ {%@}>", [super description], self.contentLayer];
}

#pragma mark -
#pragma mark Label comparison

// Axis labels are equal if they have the same location
-(BOOL)isEqual:(id)object
{
	if ( self == object ) {
		return YES;
	}
	else if ( [object isKindOfClass:[self class]] ) {
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

	return hashValue;
}

@end
