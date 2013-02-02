#import "CPTNumericData.h"
#import "CPTNumericDataType.h"

@interface CPTMutableNumericData : CPTNumericData {
}

/// @name Data Buffer
/// @{
@property (readonly) void *mutableBytes;
/// @}

/// @name Dimensions
/// @{
@property (copy, readwrite) NSArray *shape;
/// @}

@end
