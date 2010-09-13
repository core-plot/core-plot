#import "CPLayerAnnotation.h"
#import "CPAnnotationHostLayer.h"
#import "CPConstrainedPosition.h"
#import "CPLayer.h"

///	@cond
@interface CPLayerAnnotation()

@property (nonatomic, readwrite, retain) CPConstrainedPosition *xConstrainedPosition;
@property (nonatomic, readwrite, retain) CPConstrainedPosition *yConstrainedPosition;

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

@synthesize xConstrainedPosition;
@synthesize yConstrainedPosition;

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
		xConstrainedPosition = nil;
		yConstrainedPosition = nil;
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
	CPLayer *content = self.contentLayer;
	if ( content ) {
		CPAnnotationHostLayer *hostLayer = self.annotationHostLayer;
		if ( hostLayer ) {
			if ( !self.xConstrainedPosition || !self.yConstrainedPosition ) {
				[self setConstraints];
			}

			CGFloat myRotation = self.rotation;
			CGPoint anchor = self.contentAnchorPoint;
			
			CPLayer *theAnchorLayer = self.anchorLayer;
			CGRect anchorLayerBounds = theAnchorLayer.bounds;
			
			CPConstrainedPosition *xConstraint = self.xConstrainedPosition;
			CPConstrainedPosition *yConstraint = self.yConstrainedPosition;
			xConstraint.lowerBound = CGRectGetMinX(anchorLayerBounds);
			xConstraint.upperBound = CGRectGetMaxX(anchorLayerBounds);
			yConstraint.lowerBound = CGRectGetMinY(anchorLayerBounds);
			yConstraint.upperBound = CGRectGetMaxY(anchorLayerBounds);
			
			CGPoint referencePoint = CGPointMake(xConstraint.position, yConstraint.position);
			CGPoint newPosition = [theAnchorLayer convertPoint:referencePoint toLayer:hostLayer];
			
			CGPoint offset = self.displacement;
			newPosition.x = round(newPosition.x + offset.x);
			newPosition.y = round(newPosition.y + offset.y);
			
			// Pixel-align the label layer to prevent blurriness
			if ( myRotation == 0.0 ) {
				CGSize currentSize = content.bounds.size;
				
				newPosition.x = newPosition.x - round(currentSize.width * anchor.x) + (currentSize.width * anchor.x);
				newPosition.y = newPosition.y - round(currentSize.height * anchor.y) + (currentSize.height * anchor.y);
			}
			content.anchorPoint = anchor;
			content.position = newPosition;
			content.transform = CATransform3DMakeRotation(myRotation, 0.0, 0.0, 1.0);
			[content setNeedsDisplay];
		}
	}
}

#pragma mark -
#pragma mark Constraints

-(void)setConstraints
{
	CGRect anchorBounds = self.anchorLayer.bounds;
	
	if ( CGRectIsEmpty(anchorBounds) ) return;
    
    CPAlignment xAlign, yAlign;
    switch ( self.rectAnchor ) {
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
    xConstrainedPosition = [[CPConstrainedPosition alloc] initWithAlignment:xAlign lowerBound:CGRectGetMinX(anchorBounds) upperBound:CGRectGetMaxX(anchorBounds)];
    
    [yConstrainedPosition release];
    yConstrainedPosition = [[CPConstrainedPosition alloc] initWithAlignment:yAlign lowerBound:CGRectGetMinY(anchorBounds) upperBound:CGRectGetMaxY(anchorBounds)];
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
