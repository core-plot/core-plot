#import "CPTDefinitions.h"
#import "CPTGraph.h"

@interface CPTPolarGraph : CPTGraph

/// @name Initialization
/// @{
-(nonnull instancetype)initWithFrame:(CGRect)newFrame majorScaleType:(CPTScaleType)newMajorScaleType minorScaleType:(CPTScaleType)newMinorScaleType; // NS_DESIGNATED_INITIALIZER;

//-(nullable instancetype)initWithCoder:(nonnull NSCoder *)coder NS_DESIGNATED_INITIALIZER;
//-(nonnull instancetype)initWithLayer:(nonnull id)layer NS_DESIGNATED_INITIALIZER;

/// @}

@end
