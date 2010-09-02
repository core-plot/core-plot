#import <Foundation/Foundation.h>

/// @file

/**	@brief Enumeration of data formats for numeric data.
 **/
typedef enum _CPDataTypeFormat {
    CPUndefinedDataType = 0,		///< Undefined
    CPIntegerDataType,				///< Integer
    CPUnsignedIntegerDataType,		///< Unsigned integer
    CPFloatingPointDataType,		///< Floating point
    CPComplexFloatingPointDataType,	///< Complex floating point
	CPDecimalDataType				///< NSDecimal
} CPDataTypeFormat;

/**	@brief Struct that describes the encoding of numeric data samples.
 **/
typedef struct _CPNumericDataType {
    CPDataTypeFormat dataTypeFormat;	///< Data type format
    size_t sampleBytes;					///< Number of bytes in each sample
    CFByteOrder byteOrder;				///< Byte order
} CPNumericDataType;

#if __cplusplus
extern "C" {
#endif
    
	/// @name Data Type Utilities
	/// @{
    CPNumericDataType CPDataType(CPDataTypeFormat format, size_t sampleBytes, CFByteOrder byteOrder);
    CPNumericDataType CPDataTypeWithDataTypeString(NSString *dataTypeString);
    NSString *CPDataTypeStringFromDataType(CPNumericDataType dataType);
	BOOL CPDataTypeIsSupported(CPNumericDataType format);
    ///	@}

#if __cplusplus
}
#endif
