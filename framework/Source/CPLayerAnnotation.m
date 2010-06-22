
#import "CPLayerAnnotation.h"
#import "CPAnnotationLayer.h"
#import "CPConstrainedPosition.h"
#import "CPLayer.h"

static NSString *CPReferenceLayerFrameContext = @"CPReferenceLayerFrameContext";


@implementation CPLayerAnnotation

@synthesize referenceLayer;
@synthesize rectAnchor;

-(void)setConstraints
{
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
            break;
    }
    
    [xConstrainedPosition release];
    xConstrainedPosition = [[CPConstrainedPosition alloc] initWithAlignment:xAlign lowerBound:CGRectGetMinX(referenceLayer.bounds) upperBound:CGRectGetMaxX(referenceLayer.bounds)];
    
    [yConstrainedPosition release];
    yConstrainedPosition = [[CPConstrainedPosition alloc] initWithAlignment:yAlign lowerBound:CGRectGetMinY(referenceLayer.bounds) upperBound:CGRectGetMaxY(referenceLayer.bounds)];
}

-(id)initWithReferenceLayer:(CPLayer *)newReferenceLayer
{
    if ( self = [super init] ) {
        referenceLayer = newReferenceLayer;
        rectAnchor = CPRectAnchorTop;
        [self setConstraints];
        [referenceLayer addObserver:self forKeyPath:@"frame" options:0 context:CPReferenceLayerFrameContext];
    }
    return self;
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ( context == CPReferenceLayerFrameContext ) {
        [self updateContentLayer];
    }
    else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

-(void)dealloc
{
	[referenceLayer removeObserver:self forKeyPath:@"frame"];
	referenceLayer = nil;
    [xConstrainedPosition release];
    [yConstrainedPosition release];
    [super dealloc];
}

-(void)updateContentLayer
{
	xConstrainedPosition.lowerBound = CGRectGetMinX(referenceLayer.bounds);
    xConstrainedPosition.upperBound = CGRectGetMaxX(referenceLayer.bounds);
    yConstrainedPosition.lowerBound = CGRectGetMinY(referenceLayer.bounds);
    yConstrainedPosition.upperBound = CGRectGetMaxY(referenceLayer.bounds);
    CGPoint referencePoint = CGPointMake(xConstrainedPosition.position, yConstrainedPosition.position);
    CGPoint point = [referenceLayer convertPoint:referencePoint toLayer:self.annotationLayer];
    point.x = roundf(point.x);
    point.y = roundf(point.y);
    self.contentLayer.position = point;
}

-(void)setRectAnchor:(CPRectAnchor)newAnchor 
{
    if ( newAnchor != rectAnchor ) {
        rectAnchor = newAnchor;
        [self setConstraints];
        [self updateContentLayer];
    }
}

@end
