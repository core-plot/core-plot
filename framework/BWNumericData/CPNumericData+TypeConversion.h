
#import <Cocoa/Cocoa.h>
#import "CPNumericData.h"

@interface CPNumericData (TypeConversion)
- (CPNumericData*)dataByConvertingToType:(CPDataType)newDataType
                             sampleBytes:(NSUInteger)newSampleBytes
                               byteOrder:(CFByteOrder)newByteOrder;
@end
