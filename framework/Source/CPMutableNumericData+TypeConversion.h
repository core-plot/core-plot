#import <Foundation/Foundation.h>
#import "CPMutableNumericData.h"
#import "CPNumericDataType.h"

/**	@category CPMutableNumericData(TypeConversion)
 *	@brief Type conversion methods for CPMutableNumericData.
 **/
@interface CPMutableNumericData(TypeConversion)

/// @name Data Format
/// @{
@property (assign, readwrite) CPNumericDataType dataType;
@property (assign, readwrite) CPDataTypeFormat dataTypeFormat;
@property (assign, readwrite) size_t sampleBytes;
@property (assign, readwrite) CFByteOrder byteOrder;
///	@}

/// @name Type Conversion
/// @{
-(void)convertToType:(CPDataTypeFormat)newDataType
		 sampleBytes:(size_t)newSampleBytes
		   byteOrder:(CFByteOrder)newByteOrder;
///	@}

@end
