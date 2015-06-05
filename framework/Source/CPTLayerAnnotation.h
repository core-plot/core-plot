#import "CPTAnnotation.h"
#import "CPTDefinitions.h"

@class CPTConstraints;

@interface CPTLayerAnnotation : CPTAnnotation

@property (nonatomic, readonly, nullable) __cpt_weak CPTLayer *anchorLayer;
@property (nonatomic, readwrite, assign) CPTRectAnchor rectAnchor;

-(nonnull instancetype)initWithAnchorLayer:(nonnull CPTLayer *)anchorLayer NS_DESIGNATED_INITIALIZER;
-(nonnull instancetype)initWithCoder:(nonnull NSCoder *)coder NS_DESIGNATED_INITIALIZER;

@end
