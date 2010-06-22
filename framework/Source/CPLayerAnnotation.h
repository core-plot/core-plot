

#import <Foundation/Foundation.h>
#import "CPAnnotation.h"
#import "CPConstrainedPosition.h"


@interface CPLayerAnnotation : CPAnnotation {
	CPLayer *referenceLayer;
	CPConstrainedPosition *xConstrainedPosition;
    CPConstrainedPosition *yConstrainedPosition;
    CPRectAnchor rectAnchor;
}

@property (readonly, assign) CPLayer *referenceLayer;
@property (readwrite, assign) CPRectAnchor rectAnchor;

-(id)initWithReferenceLayer:(CPLayer *)referenceLayer;

@end
