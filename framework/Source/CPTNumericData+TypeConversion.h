/// @file

#ifdef CPT_IS_FRAMEWORK
#import <CorePlot/CPTNumericData.h>
#import <CorePlot/CPTNumericDataType.h>
#else
#import "CPTNumericData.h"
#import "CPTNumericDataType.h"
#endif

@interface CPTNumericData(TypeConversion)

/// @name Type Conversion
/// @{
-(nonnull CPTNumericData *)dataByConvertingToDataType:(CPTNumericDataType)newDataType;

-(nonnull CPTNumericData *)dataByConvertingToType:(CPTDataTypeFormat)newDataType sampleBytes:(size_t)newSampleBytes byteOrder:(CFByteOrder)newByteOrder;
/// @}

/// @name Data Conversion Utilities
/// @{
-(void)convertData:(nonnull NSData *)sourceData dataType:(nonnull CPTNumericDataType *)sourceDataType toData:(nonnull NSMutableData *)destData dataType:(nonnull CPTNumericDataType *)destDataType;
-(void)swapByteOrderForData:(nonnull NSMutableData *)sourceData sampleSize:(size_t)sampleSize;
/// @}

@end
