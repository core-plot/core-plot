#import <Foundation/Foundation.h>
#import "CPTAnnotation.h"
#import "CPTConstrainedPosition.h"

@interface CPTLayerAnnotation : CPTAnnotation {
@private
	__weak CPTLayer *anchorLayer;
	CPTConstrainedPosition *xConstrainedPosition;
    CPTConstrainedPosition *yConstrainedPosition;
    CPTRectAnchor rectAnchor;
}

@property (nonatomic, readonly, assign) __weak CPTLayer *anchorLayer;
@property (nonatomic, readwrite, assign) CPTRectAnchor rectAnchor;

-(id)initWithAnchorLayer:(CPTLayer *)anchorLayer;

@end
