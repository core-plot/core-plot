#import "CPTNumericData.h"
#import "CPTNumericDataType.h"

@interface CPTMutableNumericData : CPTNumericData

/// @name Data Buffer
/// @{
@property (nonatomic, readonly) void *mutableBytes;
/// @}

/// @name Dimensions
/// @{
@property (nonatomic, readwrite, copy) NSArray *shape;
/// @}

@end
