#import "CPTLayerAnnotation.h"
#import "CPTAnnotationHostLayer.h"
#import "CPTConstrainedPosition.h"
#import "CPTLayer.h"

/**	@cond */
@interface CPTLayerAnnotation()

@property (nonatomic, readwrite, retain) CPTConstrainedPosition *xConstrainedPosition;
@property (nonatomic, readwrite, retain) CPTConstrainedPosition *yConstrainedPosition;

-(void)setConstraints;

@end
/**	@endcond */

#pragma mark -

/**	@brief Positions a content layer relative to some anchor point in a reference layer.
 *	@todo More documentation needed 
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

@synthesize xConstrainedPosition;
@synthesize yConstrainedPosition;

#pragma mark -
#pragma mark Init/Dealloc

/** @brief Initializes a newly allocated CPTLayerAnnotation object with the provided reference layer.
 *
 *	This is the designated initializer. The initialized layer will be anchored to
 *	CPTRectAnchor#CPTRectAnchorTop by default.
 *
 *	@param newAnchorLayer The reference layer.
 *  @return The initialized CPTLayerAnnotation object.
 **/
-(id)initWithAnchorLayer:(CPTLayer *)newAnchorLayer
{
    if ( self = [super init] ) {
        anchorLayer = newAnchorLayer;
        rectAnchor = CPTRectAnchorTop;
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
	CPTLayer *content = self.contentLayer;
	if ( content ) {
		CPTAnnotationHostLayer *hostLayer = self.annotationHostLayer;
		if ( hostLayer ) {
			if ( !self.xConstrainedPosition || !self.yConstrainedPosition ) {
				[self setConstraints];
			}

			CGFloat myRotation = self.rotation;
			CGPoint anchor = self.contentAnchorPoint;
			
			CPTLayer *theAnchorLayer = self.anchorLayer;
			CGRect anchorLayerBounds = theAnchorLayer.bounds;
			
			CPTConstrainedPosition *xConstraint = self.xConstrainedPosition;
			CPTConstrainedPosition *yConstraint = self.yConstrainedPosition;
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
    
    CPTAlignment xAlign, yAlign;
    switch ( self.rectAnchor ) {
        case CPTRectAnchorRight:
            xAlign = CPTAlignmentRight;
            yAlign = CPTAlignmentMiddle;
            break;
        case CPTRectAnchorTopRight:
            xAlign = CPTAlignmentRight;
            yAlign = CPTAlignmentTop;
            break;
        case CPTRectAnchorTop:
            xAlign = CPTAlignmentCenter;
            yAlign = CPTAlignmentTop;
            break;
        case CPTRectAnchorTopLeft:
            xAlign = CPTAlignmentLeft;
            yAlign = CPTAlignmentTop;
            break;
        case CPTRectAnchorLeft:
            xAlign = CPTAlignmentLeft;
            yAlign = CPTAlignmentMiddle;
            break;
        case CPTRectAnchorBottomLeft:
            xAlign = CPTAlignmentLeft;
            yAlign = CPTAlignmentBottom;
            break;
        case CPTRectAnchorBottom:
            xAlign = CPTAlignmentCenter;
            yAlign = CPTAlignmentBottom;
            break;
        case CPTRectAnchorBottomRight:
            xAlign = CPTAlignmentRight;
            yAlign = CPTAlignmentBottom;
            break;
        case CPTRectAnchorCenter:
            xAlign = CPTAlignmentCenter;
            yAlign = CPTAlignmentMiddle;
            break;
        default:
            xAlign = CPTAlignmentCenter;
            yAlign = CPTAlignmentMiddle;
            break;
    }
    
    [xConstrainedPosition release];
    xConstrainedPosition = [[CPTConstrainedPosition alloc] initWithAlignment:xAlign lowerBound:CGRectGetMinX(anchorBounds) upperBound:CGRectGetMaxX(anchorBounds)];
    
    [yConstrainedPosition release];
    yConstrainedPosition = [[CPTConstrainedPosition alloc] initWithAlignment:yAlign lowerBound:CGRectGetMinY(anchorBounds) upperBound:CGRectGetMaxY(anchorBounds)];
}

#pragma mark -
#pragma mark Accessors

-(void)setRectAnchor:(CPTRectAnchor)newAnchor 
{
    if ( newAnchor != rectAnchor ) {
        rectAnchor = newAnchor;
        [self setConstraints];
        [self positionContentLayer];
    }
}

@end
