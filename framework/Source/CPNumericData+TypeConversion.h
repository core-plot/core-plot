#import <Foundation/Foundation.h>
#import "CPNumericData.h"

@interface CPNumericData(TypeConversion)

-(CPNumericData *)dataByConvertingToDataType:(CPNumericDataType)newDataType;

-(CPNumericData *)dataByConvertingToType:(CPDataTypeFormat)newDataType
                             sampleBytes:(NSUInteger)newSampleBytes
                               byteOrder:(CFByteOrder)newByteOrder;

@end
