#import "CPLayerAnnotation.h"
#import "CPAnnotationHostLayer.h"
#import "CPConstrainedPosition.h"
#import "CPLayer.h"

///	@cond
@interface CPLayerAnnotation()

-(void)setConstraints;

@end
///	@endcond

#pragma mark -

/**	@brief Positions a content layer relative to some anchor point in a reference layer.
 *	@todo More documentation needed 
 **/
@implementation CPLayerAnnotation

/**	@property anchorLayer
 *	@brief The reference layer.
 **/
@synthesize anchorLayer;

/**	@property rectAnchor
 *	@brief The anchor position for the annotation.
 **/
@synthesize rectAnchor;

#pragma mark -
#pragma mark Init/Dealloc

/** @brief Initializes a newly allocated CPLayerAnnotation object with the provided reference layer.
 *
 *	This is the designated initializer. The initialized layer will be anchored to
 *	CPRectAnchor#CPRectAnchorTop by default.
 *
 *	@param newAnchorLayer The reference layer.
 *  @return The initialized CPLayerAnnotation object.
 **/
-(id)initWithAnchorLayer:(CPLayer *)newAnchorLayer
{
    if ( self = [super init] ) {
        anchorLayer = newAnchorLayer;
        rectAnchor = CPRectAnchorTop;
        [self setConstraints];
    }
    return self;
}

-(void)dealloc
{
	anchorLayer = nil;
    [xConstrainedPosition release];
    [yConstrainedPosition release];
    [super dealloc];
}

#pragma mark -
#pragma mark Layout

-(void)positionContentLayer
{
	if ( !xConstrainedPosition || !yConstrainedPosition ) {
		[self setConstraints];
	}
	
	CGRect anchorLayerBounds = anchorLayer.bounds;
	xConstrainedPosition.lowerBound = CGRectGetMinX(anchorLayerBounds);
    xConstrainedPosition.upperBound = CGRectGetMaxX(anchorLayerBounds);
    yConstrainedPosition.lowerBound = CGRectGetMinY(anchorLayerBounds);
    yConstrainedPosition.upperBound = CGRectGetMaxY(anchorLayerBounds);
	
    CGPoint referencePoint = CGPointMake(xConstrainedPosition.position, yConstrainedPosition.position);
    CGPoint point = [anchorLayer convertPoint:referencePoint toLayer:self.annotationHostLayer];
    point.x = round(point.x + self.displacement.x);
    point.y = round(point.y + self.displacement.y);
    self.contentLayer.position = point;
    [self.contentLayer pixelAlign];
}

#pragma mark -
#pragma mark Constraints

-(void)setConstraints
{
	if ( CGRectIsEmpty(anchorLayer.bounds) ) return;
    
    CPAlignment xAlign, yAlign;
    switch ( rectAnchor ) {
        case CPRectAnchorRight:
            xAlign = CPAlignmentRight;
            yAlign = CPAlignmentMiddle;
            break;
        case CPRectAnchorTopRight:
            xAlign = CPAlignmentRight;
            yAlign = CPAlignmentTop;
            break;
        case CPRectAnchorTop:
            xAlign = CPAlignmentCenter;
            yAlign = CPAlignmentTop;
            break;
        case CPRectAnchorTopLeft:
            xAlign = CPAlignmentLeft;
            yAlign = CPAlignmentTop;
            break;
        case CPRectAnchorLeft:
            xAlign = CPAlignmentLeft;
            yAlign = CPAlignmentMiddle;
            break;
        case CPRectAnchorBottomLeft:
            xAlign = CPAlignmentLeft;
            yAlign = CPAlignmentBottom;
            break;
        case CPRectAnchorBottom:
            xAlign = CPAlignmentCenter;
            yAlign = CPAlignmentBottom;
            break;
        case CPRectAnchorBottomRight:
            xAlign = CPAlignmentRight;
            yAlign = CPAlignmentBottom;
            break;
        case CPRectAnchorCenter:
            xAlign = CPAlignmentCenter;
            yAlign = CPAlignmentMiddle;
            break;
        default:
            xAlign = CPAlignmentCenter;
            yAlign = CPAlignmentMiddle;
            break;
    }
    
    [xConstrainedPosition release];
    xConstrainedPosition = [[CPConstrainedPosition alloc] initWithAlignment:xAlign lowerBound:CGRectGetMinX(anchorLayer.bounds) upperBound:CGRectGetMaxX(anchorLayer.bounds)];
    
    [yConstrainedPosition release];
    yConstrainedPosition = [[CPConstrainedPosition alloc] initWithAlignment:yAlign lowerBound:CGRectGetMinY(anchorLayer.bounds) upperBound:CGRectGetMaxY(anchorLayer.bounds)];
}

#pragma mark -
#pragma mark Accessors

-(void)setRectAnchor:(CPRectAnchor)newAnchor 
{
    if ( newAnchor != rectAnchor ) {
        rectAnchor = newAnchor;
        [self setConstraints];
        [self positionContentLayer];
    }
}

@end
