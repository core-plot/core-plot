#import <Foundation/Foundation.h>
#import "CPAnnotation.h"
#import "CPConstrainedPosition.h"

@interface CPLayerAnnotation : CPAnnotation {
@private
	__weak CPLayer *anchorLayer;
	CPConstrainedPosition *xConstrainedPosition;
    CPConstrainedPosition *yConstrainedPosition;
    CPRectAnchor rectAnchor;
}

@property (nonatomic, readonly, assign) __weak CPLayer *anchorLayer;
@property (nonatomic, readwrite, assign) CPRectAnchor rectAnchor;

-(id)initWithAnchorLayer:(CPLayer *)anchorLayer;

@end
