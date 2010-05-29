#import <Cocoa/Cocoa.h>

typedef enum _CPDataTypeFormat {
    CPUndefinedDataType = 0,
    CPIntegerDataType,
    CPUnsignedIntegerDataType,
    CPFloatingPointDataType,
    CPComplexFloatingPointDataType
} CPDataTypeFormat;

typedef struct _CPNumericDataType {
    CPDataTypeFormat dataTypeFormat;
    NSInteger sampleBytes;
    CFByteOrder byteOrder;
} CPNumericDataType;

#if __cplusplus
extern "C" {
#endif
    
    CPNumericDataType CPDataType(CPDataTypeFormat format, NSInteger sampleBytes, CFByteOrder byteOrder);
    CPNumericDataType CPDataTypeWithDataTypeString(NSString *dtypeString);
    NSString *CPDataTypeStringFromDataType(CPNumericDataType dataType);
    
#if __cplusplus
}
#endif



