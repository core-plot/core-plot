#import "CPTLayerAnnotation.h"

#import "CPTAnnotationHostLayer.h"
#import "CPTConstraints.h"
#import "CPTLayer.h"

///	@cond
@interface CPTLayerAnnotation()

@property (nonatomic, readwrite, retain) CPTConstraints *xConstraints;
@property (nonatomic, readwrite, retain) CPTConstraints *yConstraints;

-(void)setConstraints;

@end

///	@endcond

#pragma mark -

/**	@brief Positions a content layer relative to an anchor point in a reference layer.
 *
 *	Layer annotations are positioned relative to a reference layer. This allows the
 *	annotation content layer to move with changes in the reference layer.
 *	This is useful for applications such as titles attached to an edge of the reference layer.
 **/
@implementation CPTLayerAnnotation

/**	@property anchorLayer
 *	@brief The reference layer.
 **/
@synthesize anchorLayer;

/**	@property rectAnchor
 *	@brief The anchor position for the annotation.
 **/
@synthesize rectAnchor;

@synthesize xConstraints;
@synthesize yConstraints;

#pragma mark -
#pragma mark Init/Dealloc

///	@name Initialization
///	@{

/** @brief Initializes a newly allocated CPTLayerAnnotation object with the provided reference layer.
 *
 *	This is the designated initializer. The initialized layer will be anchored to
 *	@link CPTRectAnchor::CPTRectAnchorTop CPTRectAnchorTop @endlink by default.
 *
 *	@param newAnchorLayer The reference layer. Must be non-nil.
 *  @return The initialized CPTLayerAnnotation object.
 **/
-(id)initWithAnchorLayer:(CPTLayer *)newAnchorLayer
{
	NSParameterAssert(newAnchorLayer);

	if ( (self = [super init]) ) {
		anchorLayer	 = newAnchorLayer;
		rectAnchor	 = CPTRectAnchorTop;
		xConstraints = nil;
		yConstraints = nil;
		[self setConstraints];
	}
	return self;
}

///	@}

-(void)dealloc
{
	anchorLayer = nil;
	[xConstraints release];
	[yConstraints release];
	[super dealloc];
}

#pragma mark -
#pragma mark NSCoding methods

-(void)encodeWithCoder:(NSCoder *)coder
{
	[super encodeWithCoder:coder];

	[coder encodeConditionalObject:self.anchorLayer forKey:@"CPTLayerAnnotation.anchorLayer"];
	[coder encodeObject:self.xConstraints forKey:@"CPTLayerAnnotation.xConstraints"];
	[coder encodeObject:self.yConstraints forKey:@"CPTLayerAnnotation.yConstraints"];
	[coder encodeInteger:self.rectAnchor forKey:@"CPTLayerAnnotation.rectAnchor"];
}

-(id)initWithCoder:(NSCoder *)coder
{
	if ( (self = [super initWithCoder:coder]) ) {
		anchorLayer	 = [coder decodeObjectForKey:@"CPTLayerAnnotation.anchorLayer"];
		xConstraints = [[coder decodeObjectForKey:@"CPTLayerAnnotation.xConstraints"] retain];
		yConstraints = [[coder decodeObjectForKey:@"CPTLayerAnnotation.yConstraints"] retain];
		rectAnchor	 = [coder decodeIntegerForKey:@"CPTLayerAnnotation.rectAnchor"];
	}
	return self;
}

#pragma mark -
#pragma mark Layout

///	@cond

-(void)positionContentLayer
{
	CPTLayer *content = self.contentLayer;

	if ( content ) {
		CPTAnnotationHostLayer *hostLayer = self.annotationHostLayer;
		if ( hostLayer ) {
			CPTLayer *theAnchorLayer = self.anchorLayer;
			CGRect anchorLayerBounds = theAnchorLayer.bounds;

			CGFloat xPosition = [self.xConstraints positionForLowerBound:CGRectGetMinX(anchorLayerBounds)
															  upperBound:CGRectGetMaxX(anchorLayerBounds)];
			CGFloat yPosition = [self.yConstraints positionForLowerBound:CGRectGetMinY(anchorLayerBounds)
															  upperBound:CGRectGetMaxY(anchorLayerBounds)];

			CGPoint referencePoint = CGPointMake(xPosition, yPosition);
			CGPoint newPosition	   = [theAnchorLayer convertPoint:referencePoint toLayer:hostLayer];

			CGPoint offset = self.displacement;
			newPosition.x += offset.x;
			newPosition.y += offset.y;

			content.anchorPoint = self.contentAnchorPoint;
			content.position	= newPosition;
			content.transform	= CATransform3DMakeRotation(self.rotation, 0.0, 0.0, 1.0);
			[content pixelAlign];
			[content setNeedsDisplay];
		}
	}
}

///	@endcond

#pragma mark -
#pragma mark Constraints

///	@cond

-(void)setConstraints
{
	CPTConstraints *xConstraint = nil;
	CPTConstraints *yConstraint = nil;

	switch ( self.rectAnchor ) {
		case CPTRectAnchorRight:
			xConstraint = [[CPTConstraints alloc] initWithUpperOffset:0.0];
			yConstraint = [[CPTConstraints alloc] initWithRelativeOffset:0.5];
			break;

		case CPTRectAnchorTopRight:
			xConstraint = [[CPTConstraints alloc] initWithUpperOffset:0.0];
			yConstraint = [[CPTConstraints alloc] initWithUpperOffset:0.0];
			break;

		case CPTRectAnchorTop:
			xConstraint = [[CPTConstraints alloc] initWithRelativeOffset:0.5];
			yConstraint = [[CPTConstraints alloc] initWithUpperOffset:0.0];
			break;

		case CPTRectAnchorTopLeft:
			xConstraint = [[CPTConstraints alloc] initWithLowerOffset:0.0];
			yConstraint = [[CPTConstraints alloc] initWithUpperOffset:0.0];
			break;

		case CPTRectAnchorLeft:
			xConstraint = [[CPTConstraints alloc] initWithLowerOffset:0.0];
			yConstraint = [[CPTConstraints alloc] initWithRelativeOffset:0.5];
			break;

		case CPTRectAnchorBottomLeft:
			xConstraint = [[CPTConstraints alloc] initWithLowerOffset:0.0];
			yConstraint = [[CPTConstraints alloc] initWithLowerOffset:0.0];
			break;

		case CPTRectAnchorBottom:
			xConstraint = [[CPTConstraints alloc] initWithRelativeOffset:0.5];
			yConstraint = [[CPTConstraints alloc] initWithLowerOffset:0.0];
			break;

		case CPTRectAnchorBottomRight:
			xConstraint = [[CPTConstraints alloc] initWithUpperOffset:0.0];
			yConstraint = [[CPTConstraints alloc] initWithLowerOffset:0.0];
			break;

		case CPTRectAnchorCenter:
			xConstraint = [[CPTConstraints alloc] initWithRelativeOffset:0.5];
			yConstraint = [[CPTConstraints alloc] initWithRelativeOffset:0.5];
			break;
	}

	self.xConstraints = xConstraint;
	[xConstraint release];

	self.yConstraints = yConstraint;
	[yConstraint release];
}

///	@endcond

#pragma mark -
#pragma mark Accessors

///	@cond

-(void)setRectAnchor:(CPTRectAnchor)newAnchor
{
	if ( newAnchor != rectAnchor ) {
		rectAnchor = newAnchor;
		[self setConstraints];
		[self positionContentLayer];
	}
}

///	@endcond

@end
