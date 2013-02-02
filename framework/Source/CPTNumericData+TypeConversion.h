#import "CPTNumericData.h"
#import "CPTNumericDataType.h"

/** @category CPTNumericData(TypeConversion)
 *  @brief Type conversion methods for CPTNumericData.
 **/
@interface CPTNumericData(TypeConversion)

/// @name Type Conversion
/// @{
-(CPTNumericData *)dataByConvertingToDataType:(CPTNumericDataType)newDataType;

-(CPTNumericData *)dataByConvertingToType:(CPTDataTypeFormat)newDataType sampleBytes:(size_t)newSampleBytes byteOrder:(CFByteOrder)newByteOrder;
/// @}

/// @name Data Conversion Utilities
/// @{
-(void)convertData:(NSData *)sourceData dataType:(CPTNumericDataType *)sourceDataType toData:(NSMutableData *)destData dataType:(CPTNumericDataType *)destDataType;
-(void)swapByteOrderForData:(NSMutableData *)sourceData sampleSize:(size_t)sampleSize;
/// @}

@end
