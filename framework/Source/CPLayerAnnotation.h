#import <Foundation/Foundation.h>
#import "CPAnnotation.h"
#import "CPConstrainedPosition.h"

@interface CPLayerAnnotation : CPAnnotation {
@private
	CPLayer *referenceLayer;
	CPConstrainedPosition *xConstrainedPosition;
    CPConstrainedPosition *yConstrainedPosition;
    CPRectAnchor rectAnchor;
}

@property (nonatomic, readonly, assign) CPLayer *referenceLayer;
@property (nonatomic, readwrite, assign) CPRectAnchor rectAnchor;

-(id)initWithReferenceLayer:(CPLayer *)referenceLayer;

@end
