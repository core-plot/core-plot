#import "CPTAnnotation.h"
#import "CPTDefinitions.h"

@class CPTConstraints;

@interface CPTLayerAnnotation : CPTAnnotation

@property (nonatomic, readonly) __cpt_weak CPTLayer *anchorLayer;
@property (nonatomic, readwrite, assign) CPTRectAnchor rectAnchor;

-(instancetype)initWithAnchorLayer:(CPTLayer *)anchorLayer NS_DESIGNATED_INITIALIZER;
-(instancetype)initWithCoder:(NSCoder *)coder NS_DESIGNATED_INITIALIZER;

@end
