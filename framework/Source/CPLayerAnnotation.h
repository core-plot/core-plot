

#import <Foundation/Foundation.h>
#import "CPAnnotation.h"
#import "CPConstrainedPosition.h"


@interface CPLayerAnnotation : CPAnnotation {
	CPLayer *referenceLayer;
	CPConstrainedPosition *xConstrainedPosition;
    CPConstrainedPosition *yConstrainedPosition;
}

@property (readonly, assign) CPLayer *referenceLayer;

-(id)initWithReferenceLayer:(CPLayer *)referenceLayer layerEdge:(CGRectEdge)edge alignment:(CPAlignment)alignment;

@end
