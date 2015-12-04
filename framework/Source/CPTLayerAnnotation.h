#import "CPTAnnotation.h"
#import "CPTDefinitions.h"

@class CPTConstraints;

@interface CPTLayerAnnotation : CPTAnnotation

@property (nonatomic, readonly, nullable) cpt_weak CPTLayer *anchorLayer;
@property (nonatomic, readwrite, assign) CPTRectAnchor rectAnchor;

/// @name Initialization
/// @{
-(nonnull instancetype)initWithAnchorLayer:(nonnull CPTLayer *)anchorLayer NS_DESIGNATED_INITIALIZER;
-(nonnull instancetype)initWithCoder:(nonnull NSCoder *)coder NS_DESIGNATED_INITIALIZER;
/// @}

@end
