#import <Foundation/Foundation.h>
#import "CPNumericData.h"
#import "CPNumericDataType.h"

/**	@category CPNumericData(TypeConversion)
 *	@brief Type conversion methods for CPNumericData.
 **/
@interface CPNumericData(TypeConversion)

/// @name Type Conversion
/// @{
-(CPNumericData *)dataByConvertingToDataType:(CPNumericDataType)newDataType;

-(CPNumericData *)dataByConvertingToType:(CPDataTypeFormat)newDataType
                             sampleBytes:(size_t)newSampleBytes
                               byteOrder:(CFByteOrder)newByteOrder;
///	@}

/// @name Data Conversion Utilities
/// @{
-(void)convertData:(NSData *)sourceData
		  dataType:(CPNumericDataType *)sourceDataType
			toData:(NSMutableData *)destData
		  dataType:(CPNumericDataType *)destDataType;
-(void)swapByteOrderForData:(NSMutableData *)sourceData sampleSize:(size_t)sampleSize;
///	@}

@end
