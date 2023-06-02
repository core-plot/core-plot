/// @file

#ifdef CPT_IS_FRAMEWORK
#import <CorePlot/CPTMutableNumericData.h>
#import <CorePlot/CPTNumericDataType.h>
#else
#import "CPTMutableNumericData.h"
#import "CPTNumericDataType.h"
#endif

@interface CPTMutableNumericData(TypeConversion)

/// @name Data Format
/// @{
@property (nonatomic, readwrite, assign) CPTNumericDataType dataType;
@property (nonatomic, readwrite, assign) CPTDataTypeFormat dataTypeFormat;
@property (nonatomic, readwrite, assign) size_t sampleBytes;
@property (nonatomic, readwrite, assign) CFByteOrder byteOrder;
/// @}

/// @name Type Conversion
/// @{
-(void)convertToType:(CPTDataTypeFormat)newDataType sampleBytes:(size_t)newSampleBytes byteOrder:(CFByteOrder)newByteOrder;
/// @}

@end
