#import "CPTMutableNumericData.h"
#import "CPTNumericDataType.h"
#import <Foundation/Foundation.h>

/** @category CPTMutableNumericData(TypeConversion)
 *  @brief Type conversion methods for CPTMutableNumericData.
 **/
@interface CPTMutableNumericData(TypeConversion)

/// @name Data Format
/// @{
@property (assign, readwrite) CPTNumericDataType dataType;
@property (assign, readwrite) CPTDataTypeFormat dataTypeFormat;
@property (assign, readwrite) size_t sampleBytes;
@property (assign, readwrite) CFByteOrder byteOrder;
/// @}

/// @name Type Conversion
/// @{
-(void)convertToType:(CPTDataTypeFormat)newDataType sampleBytes:(size_t)newSampleBytes byteOrder:(CFByteOrder)newByteOrder;
/// @}

@end
