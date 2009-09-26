#import <Cocoa/Cocoa.h>

typedef enum {
    CPUndefinedDataType = 0,
    CPIntegerDataType,
    CPUnsignedIntegerDataType,
    CPFloatingPointDataType,
    CPComplexFloatingPointDataType
} CPDataTypeFormat;

typedef struct {
    CPDataTypeFormat dataType;
    NSUInteger sampleBytes;
    CFByteOrder byteOrder;
} CPNumericDataType;


CPNumericDataType CPDataType(CPDataTypeFormat format, NSUInteger sampleBytes, CFByteOrder byteOrder);
CPNumericDataType CPDataTypeWithDataTypeString(NSString * dtypeString);
NSString *CPDataTypeStringFromDataType(CPNumericDataType dtype);