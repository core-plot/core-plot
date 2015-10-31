#import "CPTNumericData.h"
#import "CPTNumericDataType.h"

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
-(nullable void *)mutableSamplePointer:(NSUInteger)sample;
-(nullable void *)mutableSamplePointerAtIndex:(NSUInteger)idx, ...;
/// @}

@end
