#ifdef CPT_IS_FRAMEWORK
#import <CorePlot/CPTNumericData.h>
#import <CorePlot/CPTNumericDataType.h>
#else
#import "CPTNumericData.h"
#import "CPTNumericDataType.h"
#endif

@interface CPTMutableNumericData : CPTNumericData

/// @name Data Buffer
/// @{
@property (nonatomic, readonly, nonnull) void *mutableBytes;
/// @}

/// @name Dimensions
/// @{
@property (nonatomic, readwrite, copy, nonnull) CPTNumberArray *shape;
/// @}

/// @name Samples
/// @{
-(nullable void *)mutableSamplePointer:(NSUInteger)sample NS_RETURNS_INNER_POINTER;
-(nullable void *)mutableSamplePointerAtIndex:(NSUInteger)idx, ... NS_RETURNS_INNER_POINTER;
/// @}

@end
