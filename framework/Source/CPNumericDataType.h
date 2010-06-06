#import <Foundation/Foundation.h>

//	@TODO: add CPDecimalDataType
typedef enum _CPDataTypeFormat {
    CPUndefinedDataType = 0,
    CPIntegerDataType,
    CPUnsignedIntegerDataType,
    CPFloatingPointDataType,
    CPComplexFloatingPointDataType
} CPDataTypeFormat;

typedef struct _CPNumericDataType {
    CPDataTypeFormat dataTypeFormat;
    NSUInteger sampleBytes;
    CFByteOrder byteOrder;
} CPNumericDataType;

#if __cplusplus
extern "C" {
#endif
    
    CPNumericDataType CPDataType(CPDataTypeFormat format, NSUInteger sampleBytes, CFByteOrder byteOrder);
    CPNumericDataType CPDataTypeWithDataTypeString(NSString *dtypeString);
    NSString *CPDataTypeStringFromDataType(CPNumericDataType dataType);
    
#if __cplusplus
}
#endif



