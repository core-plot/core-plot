#import "CPTMutableNumericData.h"
#import "CPTNumericDataType.h"

/** @category CPTMutableNumericData(TypeConversion)
 *  @brief Type conversion methods for CPTMutableNumericData.
 **/
@interface CPTMutableNumericData(TypeConversion)

/// @name Data Format
/// @{
@property (readwrite, assign) CPTNumericDataType dataType;
@property (readwrite, assign) CPTDataTypeFormat dataTypeFormat;
@property (readwrite, assign) size_t sampleBytes;
@property (readwrite, assign) CFByteOrder byteOrder;
/// @}

/// @name Type Conversion
/// @{
-(void)convertToType:(CPTDataTypeFormat)newDataType sampleBytes:(size_t)newSampleBytes byteOrder:(CFByteOrder)newByteOrder;
/// @}

@end
