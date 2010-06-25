#import <Foundation/Foundation.h>
#import "CPAnnotation.h"
#import "CPConstrainedPosition.h"

@interface CPLayerAnnotation : CPAnnotation {
@private
	CPLayer *anchorLayer;
	CPConstrainedPosition *xConstrainedPosition;
    CPConstrainedPosition *yConstrainedPosition;
    CPRectAnchor rectAnchor;
}

@property (nonatomic, readonly, assign) CPLayer *anchorLayer;
@property (nonatomic, readwrite, assign) CPRectAnchor rectAnchor;

-(id)initWithAnchorLayer:(CPLayer *)anchorLayer;

@end
