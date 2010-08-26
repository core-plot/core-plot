#import "CPNumericData+TypeConversion.h"
#import "CPNumericDataTypeConversions.h"
#import "CPNumericDataType.h"

@implementation CPNumericData(TypeConversion)

/** @brief Copies the current numeric data and converts the data to a new data type.
 *  @param newDataType The new data type.
 *	@return A copy of the current numeric data converted to the new data type.
 **/
-(CPNumericData *)dataByConvertingToDataType:(CPNumericDataType)newDataType
{
    return [self dataByConvertingToType:newDataType.dataTypeFormat
                            sampleBytes:newDataType.sampleBytes
                              byteOrder:newDataType.byteOrder];
}

/** @brief Copies the current numeric data and converts the data to a new data type.
 *  @param newDataType The new data type format.
 *  @param newSampleBytes The number of bytes used to store each sample.
 *  @param newByteOrder The new byte order.
 *	@return A copy of the current numeric data converted to the new data type.
 **/
// Code generated with "CPNumericData+TypeConversions_Generation.py"
-(CPNumericData *)dataByConvertingToType:(CPDataTypeFormat)newDataType
                             sampleBytes:(size_t)newSampleBytes
                               byteOrder:(CFByteOrder)newByteOrder 
{
	NSParameterAssert(CPDataTypeIsSupported(CPDataType(newDataType, newSampleBytes, newByteOrder)));
	NSParameterAssert(newDataType != CPUndefinedDataType);
	NSParameterAssert(newDataType != CPComplexFloatingPointDataType);

	NSData *result = nil;
	switch ( self.dataTypeFormat ) {
		case CPUndefinedDataType:
			[NSException raise:NSInvalidArgumentException format:@"Unsupported data type (CPUndefinedDataType)"];
			break;
		case CPIntegerDataType:
			switch ( self.sampleBytes ) {
				case sizeof(int8_t):
					switch ( newDataType ) {
						case CPUndefinedDataType:
							[NSException raise:NSInvalidArgumentException format:@"Unsupported new data type (CPUndefinedDataType)"];
							break;
						case CPIntegerDataType:
							switch ( newSampleBytes ) {
								case sizeof(int8_t):
									result = coreplot::convert_numeric_data_type<int8_t, int8_t>(self.data, self.byteOrder, newByteOrder);
									break;
								case sizeof(int16_t):
									result = coreplot::convert_numeric_data_type<int8_t, int16_t>(self.data, self.byteOrder, newByteOrder);
									break;
								case sizeof(int32_t):
									result = coreplot::convert_numeric_data_type<int8_t, int32_t>(self.data, self.byteOrder, newByteOrder);
									break;
								case sizeof(int64_t):
									result = coreplot::convert_numeric_data_type<int8_t, int64_t>(self.data, self.byteOrder, newByteOrder);
									break;
							}
							break;
						case CPUnsignedIntegerDataType:
							switch ( newSampleBytes ) {
								case sizeof(uint8_t):
									result = coreplot::convert_numeric_data_type<int8_t, uint8_t>(self.data, self.byteOrder, newByteOrder);
									break;
								case sizeof(uint16_t):
									result = coreplot::convert_numeric_data_type<int8_t, uint16_t>(self.data, self.byteOrder, newByteOrder);
									break;
								case sizeof(uint32_t):
									result = coreplot::convert_numeric_data_type<int8_t, uint32_t>(self.data, self.byteOrder, newByteOrder);
									break;
								case sizeof(uint64_t):
									result = coreplot::convert_numeric_data_type<int8_t, uint64_t>(self.data, self.byteOrder, newByteOrder);
									break;
							}
							break;
						case CPFloatingPointDataType:
							switch ( newSampleBytes ) {
								case sizeof(float):
									result = coreplot::convert_numeric_data_type<int8_t, float>(self.data, self.byteOrder, newByteOrder);
									break;
								case sizeof(double):
									result = coreplot::convert_numeric_data_type<int8_t, double>(self.data, self.byteOrder, newByteOrder);
									break;
							}
							break;
						case CPComplexFloatingPointDataType:
							[NSException raise:NSInvalidArgumentException format:@"Unsupported new data type (CPComplexFloatingPointDataType)"];
							break;
					}
					break;
				case sizeof(int16_t):
					switch ( newDataType ) {
						case CPUndefinedDataType:
							[NSException raise:NSInvalidArgumentException format:@"Unsupported new data type (CPUndefinedDataType)"];
							break;
						case CPIntegerDataType:
							switch ( newSampleBytes ) {
								case sizeof(int8_t):
									result = coreplot::convert_numeric_data_type<int16_t, int8_t>(self.data, self.byteOrder, newByteOrder);
									break;
								case sizeof(int16_t):
									result = coreplot::convert_numeric_data_type<int16_t, int16_t>(self.data, self.byteOrder, newByteOrder);
									break;
								case sizeof(int32_t):
									result = coreplot::convert_numeric_data_type<int16_t, int32_t>(self.data, self.byteOrder, newByteOrder);
									break;
								case sizeof(int64_t):
									result = coreplot::convert_numeric_data_type<int16_t, int64_t>(self.data, self.byteOrder, newByteOrder);
									break;
							}
							break;
						case CPUnsignedIntegerDataType:
							switch ( newSampleBytes ) {
								case sizeof(uint8_t):
									result = coreplot::convert_numeric_data_type<int16_t, uint8_t>(self.data, self.byteOrder, newByteOrder);
									break;
								case sizeof(uint16_t):
									result = coreplot::convert_numeric_data_type<int16_t, uint16_t>(self.data, self.byteOrder, newByteOrder);
									break;
								case sizeof(uint32_t):
									result = coreplot::convert_numeric_data_type<int16_t, uint32_t>(self.data, self.byteOrder, newByteOrder);
									break;
								case sizeof(uint64_t):
									result = coreplot::convert_numeric_data_type<int16_t, uint64_t>(self.data, self.byteOrder, newByteOrder);
									break;
							}
							break;
						case CPFloatingPointDataType:
							switch ( newSampleBytes ) {
								case sizeof(float):
									result = coreplot::convert_numeric_data_type<int16_t, float>(self.data, self.byteOrder, newByteOrder);
									break;
								case sizeof(double):
									result = coreplot::convert_numeric_data_type<int16_t, double>(self.data, self.byteOrder, newByteOrder);
									break;
							}
							break;
						case CPComplexFloatingPointDataType:
							[NSException raise:NSInvalidArgumentException format:@"Unsupported new data type (CPComplexFloatingPointDataType)"];
							break;
					}
					break;
				case sizeof(int32_t):
					switch ( newDataType ) {
						case CPUndefinedDataType:
							[NSException raise:NSInvalidArgumentException format:@"Unsupported new data type (CPUndefinedDataType)"];
							break;
						case CPIntegerDataType:
							switch ( newSampleBytes ) {
								case sizeof(int8_t):
									result = coreplot::convert_numeric_data_type<int32_t, int8_t>(self.data, self.byteOrder, newByteOrder);
									break;
								case sizeof(int16_t):
									result = coreplot::convert_numeric_data_type<int32_t, int16_t>(self.data, self.byteOrder, newByteOrder);
									break;
								case sizeof(int32_t):
									result = coreplot::convert_numeric_data_type<int32_t, int32_t>(self.data, self.byteOrder, newByteOrder);
									break;
								case sizeof(int64_t):
									result = coreplot::convert_numeric_data_type<int32_t, int64_t>(self.data, self.byteOrder, newByteOrder);
									break;
							}
							break;
						case CPUnsignedIntegerDataType:
							switch ( newSampleBytes ) {
								case sizeof(uint8_t):
									result = coreplot::convert_numeric_data_type<int32_t, uint8_t>(self.data, self.byteOrder, newByteOrder);
									break;
								case sizeof(uint16_t):
									result = coreplot::convert_numeric_data_type<int32_t, uint16_t>(self.data, self.byteOrder, newByteOrder);
									break;
								case sizeof(uint32_t):
									result = coreplot::convert_numeric_data_type<int32_t, uint32_t>(self.data, self.byteOrder, newByteOrder);
									break;
								case sizeof(uint64_t):
									result = coreplot::convert_numeric_data_type<int32_t, uint64_t>(self.data, self.byteOrder, newByteOrder);
									break;
							}
							break;
						case CPFloatingPointDataType:
							switch ( newSampleBytes ) {
								case sizeof(float):
									result = coreplot::convert_numeric_data_type<int32_t, float>(self.data, self.byteOrder, newByteOrder);
									break;
								case sizeof(double):
									result = coreplot::convert_numeric_data_type<int32_t, double>(self.data, self.byteOrder, newByteOrder);
									break;
							}
							break;
						case CPComplexFloatingPointDataType:
							[NSException raise:NSInvalidArgumentException format:@"Unsupported new data type (CPComplexFloatingPointDataType)"];
							break;
					}
					break;
				case sizeof(int64_t):
					switch ( newDataType ) {
						case CPUndefinedDataType:
							[NSException raise:NSInvalidArgumentException format:@"Unsupported new data type (CPUndefinedDataType)"];
							break;
						case CPIntegerDataType:
							switch ( newSampleBytes ) {
								case sizeof(int8_t):
									result = coreplot::convert_numeric_data_type<int64_t, int8_t>(self.data, self.byteOrder, newByteOrder);
									break;
								case sizeof(int16_t):
									result = coreplot::convert_numeric_data_type<int64_t, int16_t>(self.data, self.byteOrder, newByteOrder);
									break;
								case sizeof(int32_t):
									result = coreplot::convert_numeric_data_type<int64_t, int32_t>(self.data, self.byteOrder, newByteOrder);
									break;
								case sizeof(int64_t):
									result = coreplot::convert_numeric_data_type<int64_t, int64_t>(self.data, self.byteOrder, newByteOrder);
									break;
							}
							break;
						case CPUnsignedIntegerDataType:
							switch ( newSampleBytes ) {
								case sizeof(uint8_t):
									result = coreplot::convert_numeric_data_type<int64_t, uint8_t>(self.data, self.byteOrder, newByteOrder);
									break;
								case sizeof(uint16_t):
									result = coreplot::convert_numeric_data_type<int64_t, uint16_t>(self.data, self.byteOrder, newByteOrder);
									break;
								case sizeof(uint32_t):
									result = coreplot::convert_numeric_data_type<int64_t, uint32_t>(self.data, self.byteOrder, newByteOrder);
									break;
								case sizeof(uint64_t):
									result = coreplot::convert_numeric_data_type<int64_t, uint64_t>(self.data, self.byteOrder, newByteOrder);
									break;
							}
							break;
						case CPFloatingPointDataType:
							switch ( newSampleBytes ) {
								case sizeof(float):
									result = coreplot::convert_numeric_data_type<int64_t, float>(self.data, self.byteOrder, newByteOrder);
									break;
								case sizeof(double):
									result = coreplot::convert_numeric_data_type<int64_t, double>(self.data, self.byteOrder, newByteOrder);
									break;
							}
							break;
						case CPComplexFloatingPointDataType:
							[NSException raise:NSInvalidArgumentException format:@"Unsupported new data type (CPComplexFloatingPointDataType)"];
							break;
					}
					break;
			}
			break;
		case CPUnsignedIntegerDataType:
			switch ( self.sampleBytes ) {
				case sizeof(uint8_t):
					switch ( newDataType ) {
						case CPUndefinedDataType:
							[NSException raise:NSInvalidArgumentException format:@"Unsupported new data type (CPUndefinedDataType)"];
							break;
						case CPIntegerDataType:
							switch ( newSampleBytes ) {
								case sizeof(int8_t):
									result = coreplot::convert_numeric_data_type<uint8_t, int8_t>(self.data, self.byteOrder, newByteOrder);
									break;
								case sizeof(int16_t):
									result = coreplot::convert_numeric_data_type<uint8_t, int16_t>(self.data, self.byteOrder, newByteOrder);
									break;
								case sizeof(int32_t):
									result = coreplot::convert_numeric_data_type<uint8_t, int32_t>(self.data, self.byteOrder, newByteOrder);
									break;
								case sizeof(int64_t):
									result = coreplot::convert_numeric_data_type<uint8_t, int64_t>(self.data, self.byteOrder, newByteOrder);
									break;
							}
							break;
						case CPUnsignedIntegerDataType:
							switch ( newSampleBytes ) {
								case sizeof(uint8_t):
									result = coreplot::convert_numeric_data_type<uint8_t, uint8_t>(self.data, self.byteOrder, newByteOrder);
									break;
								case sizeof(uint16_t):
									result = coreplot::convert_numeric_data_type<uint8_t, uint16_t>(self.data, self.byteOrder, newByteOrder);
									break;
								case sizeof(uint32_t):
									result = coreplot::convert_numeric_data_type<uint8_t, uint32_t>(self.data, self.byteOrder, newByteOrder);
									break;
								case sizeof(uint64_t):
									result = coreplot::convert_numeric_data_type<uint8_t, uint64_t>(self.data, self.byteOrder, newByteOrder);
									break;
							}
							break;
						case CPFloatingPointDataType:
							switch ( newSampleBytes ) {
								case sizeof(float):
									result = coreplot::convert_numeric_data_type<uint8_t, float>(self.data, self.byteOrder, newByteOrder);
									break;
								case sizeof(double):
									result = coreplot::convert_numeric_data_type<uint8_t, double>(self.data, self.byteOrder, newByteOrder);
									break;
							}
							break;
						case CPComplexFloatingPointDataType:
							[NSException raise:NSInvalidArgumentException format:@"Unsupported new data type (CPComplexFloatingPointDataType)"];
							break;
					}
					break;
				case sizeof(uint16_t):
					switch ( newDataType ) {
						case CPUndefinedDataType:
							[NSException raise:NSInvalidArgumentException format:@"Unsupported new data type (CPUndefinedDataType)"];
							break;
						case CPIntegerDataType:
							switch ( newSampleBytes ) {
								case sizeof(int8_t):
									result = coreplot::convert_numeric_data_type<uint16_t, int8_t>(self.data, self.byteOrder, newByteOrder);
									break;
								case sizeof(int16_t):
									result = coreplot::convert_numeric_data_type<uint16_t, int16_t>(self.data, self.byteOrder, newByteOrder);
									break;
								case sizeof(int32_t):
									result = coreplot::convert_numeric_data_type<uint16_t, int32_t>(self.data, self.byteOrder, newByteOrder);
									break;
								case sizeof(int64_t):
									result = coreplot::convert_numeric_data_type<uint16_t, int64_t>(self.data, self.byteOrder, newByteOrder);
									break;
							}
							break;
						case CPUnsignedIntegerDataType:
							switch ( newSampleBytes ) {
								case sizeof(uint8_t):
									result = coreplot::convert_numeric_data_type<uint16_t, uint8_t>(self.data, self.byteOrder, newByteOrder);
									break;
								case sizeof(uint16_t):
									result = coreplot::convert_numeric_data_type<uint16_t, uint16_t>(self.data, self.byteOrder, newByteOrder);
									break;
								case sizeof(uint32_t):
									result = coreplot::convert_numeric_data_type<uint16_t, uint32_t>(self.data, self.byteOrder, newByteOrder);
									break;
								case sizeof(uint64_t):
									result = coreplot::convert_numeric_data_type<uint16_t, uint64_t>(self.data, self.byteOrder, newByteOrder);
									break;
							}
							break;
						case CPFloatingPointDataType:
							switch ( newSampleBytes ) {
								case sizeof(float):
									result = coreplot::convert_numeric_data_type<uint16_t, float>(self.data, self.byteOrder, newByteOrder);
									break;
								case sizeof(double):
									result = coreplot::convert_numeric_data_type<uint16_t, double>(self.data, self.byteOrder, newByteOrder);
									break;
							}
							break;
						case CPComplexFloatingPointDataType:
							[NSException raise:NSInvalidArgumentException format:@"Unsupported new data type (CPComplexFloatingPointDataType)"];
							break;
					}
					break;
				case sizeof(uint32_t):
					switch ( newDataType ) {
						case CPUndefinedDataType:
							[NSException raise:NSInvalidArgumentException format:@"Unsupported new data type (CPUndefinedDataType)"];
							break;
						case CPIntegerDataType:
							switch ( newSampleBytes ) {
								case sizeof(int8_t):
									result = coreplot::convert_numeric_data_type<uint32_t, int8_t>(self.data, self.byteOrder, newByteOrder);
									break;
								case sizeof(int16_t):
									result = coreplot::convert_numeric_data_type<uint32_t, int16_t>(self.data, self.byteOrder, newByteOrder);
									break;
								case sizeof(int32_t):
									result = coreplot::convert_numeric_data_type<uint32_t, int32_t>(self.data, self.byteOrder, newByteOrder);
									break;
								case sizeof(int64_t):
									result = coreplot::convert_numeric_data_type<uint32_t, int64_t>(self.data, self.byteOrder, newByteOrder);
									break;
							}
							break;
						case CPUnsignedIntegerDataType:
							switch ( newSampleBytes ) {
								case sizeof(uint8_t):
									result = coreplot::convert_numeric_data_type<uint32_t, uint8_t>(self.data, self.byteOrder, newByteOrder);
									break;
								case sizeof(uint16_t):
									result = coreplot::convert_numeric_data_type<uint32_t, uint16_t>(self.data, self.byteOrder, newByteOrder);
									break;
								case sizeof(uint32_t):
									result = coreplot::convert_numeric_data_type<uint32_t, uint32_t>(self.data, self.byteOrder, newByteOrder);
									break;
								case sizeof(uint64_t):
									result = coreplot::convert_numeric_data_type<uint32_t, uint64_t>(self.data, self.byteOrder, newByteOrder);
									break;
							}
							break;
						case CPFloatingPointDataType:
							switch ( newSampleBytes ) {
								case sizeof(float):
									result = coreplot::convert_numeric_data_type<uint32_t, float>(self.data, self.byteOrder, newByteOrder);
									break;
								case sizeof(double):
									result = coreplot::convert_numeric_data_type<uint32_t, double>(self.data, self.byteOrder, newByteOrder);
									break;
							}
							break;
						case CPComplexFloatingPointDataType:
							[NSException raise:NSInvalidArgumentException format:@"Unsupported new data type (CPComplexFloatingPointDataType)"];
							break;
					}
					break;
				case sizeof(uint64_t):
					switch ( newDataType ) {
						case CPUndefinedDataType:
							[NSException raise:NSInvalidArgumentException format:@"Unsupported new data type (CPUndefinedDataType)"];
							break;
						case CPIntegerDataType:
							switch ( newSampleBytes ) {
								case sizeof(int8_t):
									result = coreplot::convert_numeric_data_type<uint64_t, int8_t>(self.data, self.byteOrder, newByteOrder);
									break;
								case sizeof(int16_t):
									result = coreplot::convert_numeric_data_type<uint64_t, int16_t>(self.data, self.byteOrder, newByteOrder);
									break;
								case sizeof(int32_t):
									result = coreplot::convert_numeric_data_type<uint64_t, int32_t>(self.data, self.byteOrder, newByteOrder);
									break;
								case sizeof(int64_t):
									result = coreplot::convert_numeric_data_type<uint64_t, int64_t>(self.data, self.byteOrder, newByteOrder);
									break;
							}
							break;
						case CPUnsignedIntegerDataType:
							switch ( newSampleBytes ) {
								case sizeof(uint8_t):
									result = coreplot::convert_numeric_data_type<uint64_t, uint8_t>(self.data, self.byteOrder, newByteOrder);
									break;
								case sizeof(uint16_t):
									result = coreplot::convert_numeric_data_type<uint64_t, uint16_t>(self.data, self.byteOrder, newByteOrder);
									break;
								case sizeof(uint32_t):
									result = coreplot::convert_numeric_data_type<uint64_t, uint32_t>(self.data, self.byteOrder, newByteOrder);
									break;
								case sizeof(uint64_t):
									result = coreplot::convert_numeric_data_type<uint64_t, uint64_t>(self.data, self.byteOrder, newByteOrder);
									break;
							}
							break;
						case CPFloatingPointDataType:
							switch ( newSampleBytes ) {
								case sizeof(float):
									result = coreplot::convert_numeric_data_type<uint64_t, float>(self.data, self.byteOrder, newByteOrder);
									break;
								case sizeof(double):
									result = coreplot::convert_numeric_data_type<uint64_t, double>(self.data, self.byteOrder, newByteOrder);
									break;
							}
							break;
						case CPComplexFloatingPointDataType:
							[NSException raise:NSInvalidArgumentException format:@"Unsupported new data type (CPComplexFloatingPointDataType)"];
							break;
					}
					break;
			}
			break;
		case CPFloatingPointDataType:
			switch ( self.sampleBytes ) {
				case sizeof(float):
					switch ( newDataType ) {
						case CPUndefinedDataType:
							[NSException raise:NSInvalidArgumentException format:@"Unsupported new data type (CPUndefinedDataType)"];
							break;
						case CPIntegerDataType:
							switch ( newSampleBytes ) {
								case sizeof(int8_t):
									result = coreplot::convert_numeric_data_type<float, int8_t>(self.data, self.byteOrder, newByteOrder);
									break;
								case sizeof(int16_t):
									result = coreplot::convert_numeric_data_type<float, int16_t>(self.data, self.byteOrder, newByteOrder);
									break;
								case sizeof(int32_t):
									result = coreplot::convert_numeric_data_type<float, int32_t>(self.data, self.byteOrder, newByteOrder);
									break;
								case sizeof(int64_t):
									result = coreplot::convert_numeric_data_type<float, int64_t>(self.data, self.byteOrder, newByteOrder);
									break;
							}
							break;
						case CPUnsignedIntegerDataType:
							switch ( newSampleBytes ) {
								case sizeof(uint8_t):
									result = coreplot::convert_numeric_data_type<float, uint8_t>(self.data, self.byteOrder, newByteOrder);
									break;
								case sizeof(uint16_t):
									result = coreplot::convert_numeric_data_type<float, uint16_t>(self.data, self.byteOrder, newByteOrder);
									break;
								case sizeof(uint32_t):
									result = coreplot::convert_numeric_data_type<float, uint32_t>(self.data, self.byteOrder, newByteOrder);
									break;
								case sizeof(uint64_t):
									result = coreplot::convert_numeric_data_type<float, uint64_t>(self.data, self.byteOrder, newByteOrder);
									break;
							}
							break;
						case CPFloatingPointDataType:
							switch ( newSampleBytes ) {
								case sizeof(float):
									result = coreplot::convert_numeric_data_type<float, float>(self.data, self.byteOrder, newByteOrder);
									break;
								case sizeof(double):
									result = coreplot::convert_numeric_data_type<float, double>(self.data, self.byteOrder, newByteOrder);
									break;
							}
							break;
						case CPComplexFloatingPointDataType:
							[NSException raise:NSInvalidArgumentException format:@"Unsupported new data type (CPComplexFloatingPointDataType)"];
							break;
					}
					break;
				case sizeof(double):
					switch ( newDataType ) {
						case CPUndefinedDataType:
							[NSException raise:NSInvalidArgumentException format:@"Unsupported new data type (CPUndefinedDataType)"];
							break;
						case CPIntegerDataType:
							switch ( newSampleBytes ) {
								case sizeof(int8_t):
									result = coreplot::convert_numeric_data_type<double, int8_t>(self.data, self.byteOrder, newByteOrder);
									break;
								case sizeof(int16_t):
									result = coreplot::convert_numeric_data_type<double, int16_t>(self.data, self.byteOrder, newByteOrder);
									break;
								case sizeof(int32_t):
									result = coreplot::convert_numeric_data_type<double, int32_t>(self.data, self.byteOrder, newByteOrder);
									break;
								case sizeof(int64_t):
									result = coreplot::convert_numeric_data_type<double, int64_t>(self.data, self.byteOrder, newByteOrder);
									break;
							}
							break;
						case CPUnsignedIntegerDataType:
							switch ( newSampleBytes ) {
								case sizeof(uint8_t):
									result = coreplot::convert_numeric_data_type<double, uint8_t>(self.data, self.byteOrder, newByteOrder);
									break;
								case sizeof(uint16_t):
									result = coreplot::convert_numeric_data_type<double, uint16_t>(self.data, self.byteOrder, newByteOrder);
									break;
								case sizeof(uint32_t):
									result = coreplot::convert_numeric_data_type<double, uint32_t>(self.data, self.byteOrder, newByteOrder);
									break;
								case sizeof(uint64_t):
									result = coreplot::convert_numeric_data_type<double, uint64_t>(self.data, self.byteOrder, newByteOrder);
									break;
							}
							break;
						case CPFloatingPointDataType:
							switch ( newSampleBytes ) {
								case sizeof(float):
									result = coreplot::convert_numeric_data_type<double, float>(self.data, self.byteOrder, newByteOrder);
									break;
								case sizeof(double):
									result = coreplot::convert_numeric_data_type<double, double>(self.data, self.byteOrder, newByteOrder);
									break;
							}
							break;
						case CPComplexFloatingPointDataType:
							[NSException raise:NSInvalidArgumentException format:@"Unsupported new data type (CPComplexFloatingPointDataType)"];
							break;
					}
					break;
			}
			break;
		case CPComplexFloatingPointDataType:
			[NSException raise:NSInvalidArgumentException format:@"Unsupported data type (CPComplexFloatingPointDataType)"];
			break;
	}
	
    if ( result == nil ) {
        NSLog(@"Unable to match new and existing data types for conversion.");
    }
    
    return [CPNumericData numericDataWithData:result
									 dataType:CPDataType(newDataType, newSampleBytes, newByteOrder)
                                        shape:self.shape];
}

@end
