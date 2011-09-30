#import "CPTAnnotation.h"
#import "CPTDefinitions.h"
#import <Foundation/Foundation.h>

@class CPTConstraints;

@interface CPTLayerAnnotation : CPTAnnotation {
	@private
	__weak CPTLayer *anchorLayer;
	CPTConstraints *xConstraints;
	CPTConstraints *yConstraints;
	CPTRectAnchor rectAnchor;
}

@property (nonatomic, readonly, assign) __weak CPTLayer *anchorLayer;
@property (nonatomic, readwrite, assign) CPTRectAnchor rectAnchor;

-(id)initWithAnchorLayer:(CPTLayer *)anchorLayer;

@end
