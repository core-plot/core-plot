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

#if __cplusplus
extern "C" {
#endif
    
    CPNumericDataType CPDataType(CPDataTypeFormat format, NSUInteger sampleBytes, CFByteOrder byteOrder);
    CPNumericDataType CPDataTypeWithDataTypeString(NSString * dtypeString);
    NSString *CPDataTypeStringFromDataType(CPNumericDataType dtype);
    
#if __cplusplus
}
#endif