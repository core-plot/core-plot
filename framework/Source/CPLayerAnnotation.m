
#import "CPLayerAnnotation.h"
#import "CPAnnotationLayer.h"
#import "CPConstrainedPosition.h"
#import "CPLayer.h"

static NSString *CPReferenceLayerFrameContext = @"CPReferenceLayerFrameContext";


@implementation CPLayerAnnotation

@synthesize referenceLayer;

-(id)initWithReferenceLayer:(CPLayer *)newReferenceLayer layerEdge:(CGRectEdge)edge alignment:(CPAlignment)alignment
{
    if ( self = [super init] ) {
        referenceLayer = newReferenceLayer;
        
        [referenceLayer addObserver:self forKeyPath:@"frame" options:0 context:CPReferenceLayerFrameContext];
        
        CPAlignment xAlign, yAlign;
        switch ( edge ) {
            case CGRectMaxXEdge:
                xAlign = CPAlignmentRight;
                yAlign = alignment;
                break;
            case CGRectMinXEdge:
                xAlign = CPAlignmentLeft;
                yAlign = alignment;
                break;
            case CGRectMaxYEdge:
                xAlign = alignment;
                yAlign = CPAlignmentTop;
                break;
            case CGRectMinYEdge:
                xAlign = alignment;
                yAlign = CPAlignmentBottom;
                break;
            default:
                break;
        }
        xConstrainedPosition = [[CPConstrainedPosition alloc] initWithAlignment:xAlign lowerBound:CGRectGetMinX(newReferenceLayer.bounds) upperBound:CGRectGetMaxX(newReferenceLayer.bounds)];
        yConstrainedPosition = [[CPConstrainedPosition alloc] initWithAlignment:yAlign lowerBound:CGRectGetMinY(newReferenceLayer.bounds) upperBound:CGRectGetMaxY(newReferenceLayer.bounds)];

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

-(void)updateLayerContent
{
	xConstrainedPosition.lowerBound = CGRectGetMinX(referenceLayer.bounds);
    xConstrainedPosition.upperBound = CGRectGetMaxX(referenceLayer.bounds);
    yConstrainedPosition.lowerBound = CGRectGetMinY(referenceLayer.bounds);
    yConstrainedPosition.upperBound = CGRectGetMaxY(referenceLayer.bounds);
    CGPoint referencePoint = CGPointMake(xConstrainedPosition.position, yConstrainedPosition.position);
    self.contentLayer.position = [referenceLayer convertPoint:referencePoint toLayer:self.annotationLayer];
}

@end
