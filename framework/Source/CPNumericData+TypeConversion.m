#import "CPNumericData+TypeConversion.h"
#import "CPNumericDataType.h"

///	@cond
@interface CPNumericData(TypeConversionPrivateMethods)

-(void)swapByteOrderForData:(NSMutableData *)sourceData sampleSize:(size_t)sampleSize;

@end
///	@endcond

@implementation CPNumericData(TypeConversion)

/** @brief Copies the current numeric data and converts the data to a new data type.
 *  @param newDataType The new data type format.
 *  @param newSampleBytes The number of bytes used to store each sample.
 *  @param newByteOrder The new byte order.
 *	@return A copy of the current numeric data converted to the new data type.
 **/
-(CPNumericData *)dataByConvertingToType:(CPDataTypeFormat)newDataType
                             sampleBytes:(size_t)newSampleBytes
                               byteOrder:(CFByteOrder)newByteOrder 
{
	return [self dataByConvertingToDataType:CPDataType(newDataType, newSampleBytes, newByteOrder)];
}

/** @brief Copies the current numeric data and converts the data to a new data type.
 *  @param newDataType The new data type.
 *	@return A copy of the current numeric data converted to the new data type.
 **/
-(CPNumericData *)dataByConvertingToDataType:(CPNumericDataType)newDataType
{
	CPNumericDataType myDataType = self.dataType;
	NSParameterAssert(myDataType.dataTypeFormat != CPUndefinedDataType);
	NSParameterAssert(myDataType.dataTypeFormat != CPComplexFloatingPointDataType);
	NSParameterAssert(myDataType.byteOrder != CFByteOrderUnknown);
	
	NSParameterAssert(CPDataTypeIsSupported(newDataType));
	NSParameterAssert(newDataType.dataTypeFormat != CPUndefinedDataType);
	NSParameterAssert(newDataType.dataTypeFormat != CPComplexFloatingPointDataType);
	NSParameterAssert(newDataType.byteOrder != CFByteOrderUnknown);
	
	NSData *newData = nil;
	CFByteOrder hostByteOrder = CFByteOrderGetCurrent();
	
	if ( (myDataType.dataTypeFormat == newDataType.dataTypeFormat)
		&& (myDataType.sampleBytes == newDataType.sampleBytes)
		&& (myDataType.byteOrder == newDataType.byteOrder) ) {
		
		newData = [self.data retain];
	}
	else if ( (myDataType.sampleBytes == sizeof(int8_t)) && (newDataType.sampleBytes == sizeof(int8_t)) ) {
		newData = [self.data retain];
	}
	else {
		NSUInteger sampleCount = self.data.length / myDataType.sampleBytes;
		
		newData = [[NSMutableData alloc] initWithLength:(sampleCount * newDataType.sampleBytes)];
		
		NSData *sourceData = nil;
		if ( myDataType.byteOrder != hostByteOrder ) {
			sourceData = [self.data mutableCopy];
			[self swapByteOrderForData:(NSMutableData *)sourceData sampleSize:myDataType.sampleBytes];
		}
		else {
			sourceData = [self.data retain];
		}
		
		// Code generated with "CPNumericData+TypeConversions_Generation.py"
		// ========================================================================
		
		switch ( myDataType.dataTypeFormat ) {
			case CPUndefinedDataType:
				break;
			case CPIntegerDataType:
				switch ( myDataType.sampleBytes ) {
					case sizeof(int8_t):
						switch ( newDataType.dataTypeFormat ) {
							case CPUndefinedDataType:
								break;
							case CPIntegerDataType:
								switch ( newDataType.sampleBytes ) {
									case sizeof(int8_t): { // int8_t -> int8_t
										const int8_t *fromBytes = (int8_t *)sourceData.bytes;
										const int8_t *lastSample = fromBytes + sampleCount;
										int8_t *toBytes = (int8_t *)((NSMutableData *)newData).mutableBytes;
										while ( fromBytes < lastSample ) *toBytes++ = (int8_t)*fromBytes++;
									}
										break;
									case sizeof(int16_t): { // int8_t -> int16_t
										const int8_t *fromBytes = (int8_t *)sourceData.bytes;
										const int8_t *lastSample = fromBytes + sampleCount;
										int16_t *toBytes = (int16_t *)((NSMutableData *)newData).mutableBytes;
										while ( fromBytes < lastSample ) *toBytes++ = (int16_t)*fromBytes++;
									}
										break;
									case sizeof(int32_t): { // int8_t -> int32_t
										const int8_t *fromBytes = (int8_t *)sourceData.bytes;
										const int8_t *lastSample = fromBytes + sampleCount;
										int32_t *toBytes = (int32_t *)((NSMutableData *)newData).mutableBytes;
										while ( fromBytes < lastSample ) *toBytes++ = (int32_t)*fromBytes++;
									}
										break;
									case sizeof(int64_t): { // int8_t -> int64_t
										const int8_t *fromBytes = (int8_t *)sourceData.bytes;
										const int8_t *lastSample = fromBytes + sampleCount;
										int64_t *toBytes = (int64_t *)((NSMutableData *)newData).mutableBytes;
										while ( fromBytes < lastSample ) *toBytes++ = (int64_t)*fromBytes++;
									}
										break;
								}
								break;
							case CPUnsignedIntegerDataType:
								switch ( newDataType.sampleBytes ) {
									case sizeof(uint8_t): { // int8_t -> uint8_t
										const int8_t *fromBytes = (int8_t *)sourceData.bytes;
										const int8_t *lastSample = fromBytes + sampleCount;
										uint8_t *toBytes = (uint8_t *)((NSMutableData *)newData).mutableBytes;
										while ( fromBytes < lastSample ) *toBytes++ = (uint8_t)*fromBytes++;
									}
										break;
									case sizeof(uint16_t): { // int8_t -> uint16_t
										const int8_t *fromBytes = (int8_t *)sourceData.bytes;
										const int8_t *lastSample = fromBytes + sampleCount;
										uint16_t *toBytes = (uint16_t *)((NSMutableData *)newData).mutableBytes;
										while ( fromBytes < lastSample ) *toBytes++ = (uint16_t)*fromBytes++;
									}
										break;
									case sizeof(uint32_t): { // int8_t -> uint32_t
										const int8_t *fromBytes = (int8_t *)sourceData.bytes;
										const int8_t *lastSample = fromBytes + sampleCount;
										uint32_t *toBytes = (uint32_t *)((NSMutableData *)newData).mutableBytes;
										while ( fromBytes < lastSample ) *toBytes++ = (uint32_t)*fromBytes++;
									}
										break;
									case sizeof(uint64_t): { // int8_t -> uint64_t
										const int8_t *fromBytes = (int8_t *)sourceData.bytes;
										const int8_t *lastSample = fromBytes + sampleCount;
										uint64_t *toBytes = (uint64_t *)((NSMutableData *)newData).mutableBytes;
										while ( fromBytes < lastSample ) *toBytes++ = (uint64_t)*fromBytes++;
									}
										break;
								}
								break;
							case CPFloatingPointDataType:
								switch ( newDataType.sampleBytes ) {
									case sizeof(float): { // int8_t -> float
										const int8_t *fromBytes = (int8_t *)sourceData.bytes;
										const int8_t *lastSample = fromBytes + sampleCount;
										float *toBytes = (float *)((NSMutableData *)newData).mutableBytes;
										while ( fromBytes < lastSample ) *toBytes++ = (float)*fromBytes++;
									}
										break;
									case sizeof(double): { // int8_t -> double
										const int8_t *fromBytes = (int8_t *)sourceData.bytes;
										const int8_t *lastSample = fromBytes + sampleCount;
										double *toBytes = (double *)((NSMutableData *)newData).mutableBytes;
										while ( fromBytes < lastSample ) *toBytes++ = (double)*fromBytes++;
									}
										break;
								}
								break;
							case CPComplexFloatingPointDataType:
								break;
						}
						break;
					case sizeof(int16_t):
						switch ( newDataType.dataTypeFormat ) {
							case CPUndefinedDataType:
								break;
							case CPIntegerDataType:
								switch ( newDataType.sampleBytes ) {
									case sizeof(int8_t): { // int16_t -> int8_t
										const int16_t *fromBytes = (int16_t *)sourceData.bytes;
										const int16_t *lastSample = fromBytes + sampleCount;
										int8_t *toBytes = (int8_t *)((NSMutableData *)newData).mutableBytes;
										while ( fromBytes < lastSample ) *toBytes++ = (int8_t)*fromBytes++;
									}
										break;
									case sizeof(int16_t): { // int16_t -> int16_t
										const int16_t *fromBytes = (int16_t *)sourceData.bytes;
										const int16_t *lastSample = fromBytes + sampleCount;
										int16_t *toBytes = (int16_t *)((NSMutableData *)newData).mutableBytes;
										while ( fromBytes < lastSample ) *toBytes++ = (int16_t)*fromBytes++;
									}
										break;
									case sizeof(int32_t): { // int16_t -> int32_t
										const int16_t *fromBytes = (int16_t *)sourceData.bytes;
										const int16_t *lastSample = fromBytes + sampleCount;
										int32_t *toBytes = (int32_t *)((NSMutableData *)newData).mutableBytes;
										while ( fromBytes < lastSample ) *toBytes++ = (int32_t)*fromBytes++;
									}
										break;
									case sizeof(int64_t): { // int16_t -> int64_t
										const int16_t *fromBytes = (int16_t *)sourceData.bytes;
										const int16_t *lastSample = fromBytes + sampleCount;
										int64_t *toBytes = (int64_t *)((NSMutableData *)newData).mutableBytes;
										while ( fromBytes < lastSample ) *toBytes++ = (int64_t)*fromBytes++;
									}
										break;
								}
								break;
							case CPUnsignedIntegerDataType:
								switch ( newDataType.sampleBytes ) {
									case sizeof(uint8_t): { // int16_t -> uint8_t
										const int16_t *fromBytes = (int16_t *)sourceData.bytes;
										const int16_t *lastSample = fromBytes + sampleCount;
										uint8_t *toBytes = (uint8_t *)((NSMutableData *)newData).mutableBytes;
										while ( fromBytes < lastSample ) *toBytes++ = (uint8_t)*fromBytes++;
									}
										break;
									case sizeof(uint16_t): { // int16_t -> uint16_t
										const int16_t *fromBytes = (int16_t *)sourceData.bytes;
										const int16_t *lastSample = fromBytes + sampleCount;
										uint16_t *toBytes = (uint16_t *)((NSMutableData *)newData).mutableBytes;
										while ( fromBytes < lastSample ) *toBytes++ = (uint16_t)*fromBytes++;
									}
										break;
									case sizeof(uint32_t): { // int16_t -> uint32_t
										const int16_t *fromBytes = (int16_t *)sourceData.bytes;
										const int16_t *lastSample = fromBytes + sampleCount;
										uint32_t *toBytes = (uint32_t *)((NSMutableData *)newData).mutableBytes;
										while ( fromBytes < lastSample ) *toBytes++ = (uint32_t)*fromBytes++;
									}
										break;
									case sizeof(uint64_t): { // int16_t -> uint64_t
										const int16_t *fromBytes = (int16_t *)sourceData.bytes;
										const int16_t *lastSample = fromBytes + sampleCount;
										uint64_t *toBytes = (uint64_t *)((NSMutableData *)newData).mutableBytes;
										while ( fromBytes < lastSample ) *toBytes++ = (uint64_t)*fromBytes++;
									}
										break;
								}
								break;
							case CPFloatingPointDataType:
								switch ( newDataType.sampleBytes ) {
									case sizeof(float): { // int16_t -> float
										const int16_t *fromBytes = (int16_t *)sourceData.bytes;
										const int16_t *lastSample = fromBytes + sampleCount;
										float *toBytes = (float *)((NSMutableData *)newData).mutableBytes;
										while ( fromBytes < lastSample ) *toBytes++ = (float)*fromBytes++;
									}
										break;
									case sizeof(double): { // int16_t -> double
										const int16_t *fromBytes = (int16_t *)sourceData.bytes;
										const int16_t *lastSample = fromBytes + sampleCount;
										double *toBytes = (double *)((NSMutableData *)newData).mutableBytes;
										while ( fromBytes < lastSample ) *toBytes++ = (double)*fromBytes++;
									}
										break;
								}
								break;
							case CPComplexFloatingPointDataType:
								break;
						}
						break;
					case sizeof(int32_t):
						switch ( newDataType.dataTypeFormat ) {
							case CPUndefinedDataType:
								break;
							case CPIntegerDataType:
								switch ( newDataType.sampleBytes ) {
									case sizeof(int8_t): { // int32_t -> int8_t
										const int32_t *fromBytes = (int32_t *)sourceData.bytes;
										const int32_t *lastSample = fromBytes + sampleCount;
										int8_t *toBytes = (int8_t *)((NSMutableData *)newData).mutableBytes;
										while ( fromBytes < lastSample ) *toBytes++ = (int8_t)*fromBytes++;
									}
										break;
									case sizeof(int16_t): { // int32_t -> int16_t
										const int32_t *fromBytes = (int32_t *)sourceData.bytes;
										const int32_t *lastSample = fromBytes + sampleCount;
										int16_t *toBytes = (int16_t *)((NSMutableData *)newData).mutableBytes;
										while ( fromBytes < lastSample ) *toBytes++ = (int16_t)*fromBytes++;
									}
										break;
									case sizeof(int32_t): { // int32_t -> int32_t
										const int32_t *fromBytes = (int32_t *)sourceData.bytes;
										const int32_t *lastSample = fromBytes + sampleCount;
										int32_t *toBytes = (int32_t *)((NSMutableData *)newData).mutableBytes;
										while ( fromBytes < lastSample ) *toBytes++ = (int32_t)*fromBytes++;
									}
										break;
									case sizeof(int64_t): { // int32_t -> int64_t
										const int32_t *fromBytes = (int32_t *)sourceData.bytes;
										const int32_t *lastSample = fromBytes + sampleCount;
										int64_t *toBytes = (int64_t *)((NSMutableData *)newData).mutableBytes;
										while ( fromBytes < lastSample ) *toBytes++ = (int64_t)*fromBytes++;
									}
										break;
								}
								break;
							case CPUnsignedIntegerDataType:
								switch ( newDataType.sampleBytes ) {
									case sizeof(uint8_t): { // int32_t -> uint8_t
										const int32_t *fromBytes = (int32_t *)sourceData.bytes;
										const int32_t *lastSample = fromBytes + sampleCount;
										uint8_t *toBytes = (uint8_t *)((NSMutableData *)newData).mutableBytes;
										while ( fromBytes < lastSample ) *toBytes++ = (uint8_t)*fromBytes++;
									}
										break;
									case sizeof(uint16_t): { // int32_t -> uint16_t
										const int32_t *fromBytes = (int32_t *)sourceData.bytes;
										const int32_t *lastSample = fromBytes + sampleCount;
										uint16_t *toBytes = (uint16_t *)((NSMutableData *)newData).mutableBytes;
										while ( fromBytes < lastSample ) *toBytes++ = (uint16_t)*fromBytes++;
									}
										break;
									case sizeof(uint32_t): { // int32_t -> uint32_t
										const int32_t *fromBytes = (int32_t *)sourceData.bytes;
										const int32_t *lastSample = fromBytes + sampleCount;
										uint32_t *toBytes = (uint32_t *)((NSMutableData *)newData).mutableBytes;
										while ( fromBytes < lastSample ) *toBytes++ = (uint32_t)*fromBytes++;
									}
										break;
									case sizeof(uint64_t): { // int32_t -> uint64_t
										const int32_t *fromBytes = (int32_t *)sourceData.bytes;
										const int32_t *lastSample = fromBytes + sampleCount;
										uint64_t *toBytes = (uint64_t *)((NSMutableData *)newData).mutableBytes;
										while ( fromBytes < lastSample ) *toBytes++ = (uint64_t)*fromBytes++;
									}
										break;
								}
								break;
							case CPFloatingPointDataType:
								switch ( newDataType.sampleBytes ) {
									case sizeof(float): { // int32_t -> float
										const int32_t *fromBytes = (int32_t *)sourceData.bytes;
										const int32_t *lastSample = fromBytes + sampleCount;
										float *toBytes = (float *)((NSMutableData *)newData).mutableBytes;
										while ( fromBytes < lastSample ) *toBytes++ = (float)*fromBytes++;
									}
										break;
									case sizeof(double): { // int32_t -> double
										const int32_t *fromBytes = (int32_t *)sourceData.bytes;
										const int32_t *lastSample = fromBytes + sampleCount;
										double *toBytes = (double *)((NSMutableData *)newData).mutableBytes;
										while ( fromBytes < lastSample ) *toBytes++ = (double)*fromBytes++;
									}
										break;
								}
								break;
							case CPComplexFloatingPointDataType:
								break;
						}
						break;
					case sizeof(int64_t):
						switch ( newDataType.dataTypeFormat ) {
							case CPUndefinedDataType:
								break;
							case CPIntegerDataType:
								switch ( newDataType.sampleBytes ) {
									case sizeof(int8_t): { // int64_t -> int8_t
										const int64_t *fromBytes = (int64_t *)sourceData.bytes;
										const int64_t *lastSample = fromBytes + sampleCount;
										int8_t *toBytes = (int8_t *)((NSMutableData *)newData).mutableBytes;
										while ( fromBytes < lastSample ) *toBytes++ = (int8_t)*fromBytes++;
									}
										break;
									case sizeof(int16_t): { // int64_t -> int16_t
										const int64_t *fromBytes = (int64_t *)sourceData.bytes;
										const int64_t *lastSample = fromBytes + sampleCount;
										int16_t *toBytes = (int16_t *)((NSMutableData *)newData).mutableBytes;
										while ( fromBytes < lastSample ) *toBytes++ = (int16_t)*fromBytes++;
									}
										break;
									case sizeof(int32_t): { // int64_t -> int32_t
										const int64_t *fromBytes = (int64_t *)sourceData.bytes;
										const int64_t *lastSample = fromBytes + sampleCount;
										int32_t *toBytes = (int32_t *)((NSMutableData *)newData).mutableBytes;
										while ( fromBytes < lastSample ) *toBytes++ = (int32_t)*fromBytes++;
									}
										break;
									case sizeof(int64_t): { // int64_t -> int64_t
										const int64_t *fromBytes = (int64_t *)sourceData.bytes;
										const int64_t *lastSample = fromBytes + sampleCount;
										int64_t *toBytes = (int64_t *)((NSMutableData *)newData).mutableBytes;
										while ( fromBytes < lastSample ) *toBytes++ = (int64_t)*fromBytes++;
									}
										break;
								}
								break;
							case CPUnsignedIntegerDataType:
								switch ( newDataType.sampleBytes ) {
									case sizeof(uint8_t): { // int64_t -> uint8_t
										const int64_t *fromBytes = (int64_t *)sourceData.bytes;
										const int64_t *lastSample = fromBytes + sampleCount;
										uint8_t *toBytes = (uint8_t *)((NSMutableData *)newData).mutableBytes;
										while ( fromBytes < lastSample ) *toBytes++ = (uint8_t)*fromBytes++;
									}
										break;
									case sizeof(uint16_t): { // int64_t -> uint16_t
										const int64_t *fromBytes = (int64_t *)sourceData.bytes;
										const int64_t *lastSample = fromBytes + sampleCount;
										uint16_t *toBytes = (uint16_t *)((NSMutableData *)newData).mutableBytes;
										while ( fromBytes < lastSample ) *toBytes++ = (uint16_t)*fromBytes++;
									}
										break;
									case sizeof(uint32_t): { // int64_t -> uint32_t
										const int64_t *fromBytes = (int64_t *)sourceData.bytes;
										const int64_t *lastSample = fromBytes + sampleCount;
										uint32_t *toBytes = (uint32_t *)((NSMutableData *)newData).mutableBytes;
										while ( fromBytes < lastSample ) *toBytes++ = (uint32_t)*fromBytes++;
									}
										break;
									case sizeof(uint64_t): { // int64_t -> uint64_t
										const int64_t *fromBytes = (int64_t *)sourceData.bytes;
										const int64_t *lastSample = fromBytes + sampleCount;
										uint64_t *toBytes = (uint64_t *)((NSMutableData *)newData).mutableBytes;
										while ( fromBytes < lastSample ) *toBytes++ = (uint64_t)*fromBytes++;
									}
										break;
								}
								break;
							case CPFloatingPointDataType:
								switch ( newDataType.sampleBytes ) {
									case sizeof(float): { // int64_t -> float
										const int64_t *fromBytes = (int64_t *)sourceData.bytes;
										const int64_t *lastSample = fromBytes + sampleCount;
										float *toBytes = (float *)((NSMutableData *)newData).mutableBytes;
										while ( fromBytes < lastSample ) *toBytes++ = (float)*fromBytes++;
									}
										break;
									case sizeof(double): { // int64_t -> double
										const int64_t *fromBytes = (int64_t *)sourceData.bytes;
										const int64_t *lastSample = fromBytes + sampleCount;
										double *toBytes = (double *)((NSMutableData *)newData).mutableBytes;
										while ( fromBytes < lastSample ) *toBytes++ = (double)*fromBytes++;
									}
										break;
								}
								break;
							case CPComplexFloatingPointDataType:
								break;
						}
						break;
				}
				break;
			case CPUnsignedIntegerDataType:
				switch ( myDataType.sampleBytes ) {
					case sizeof(uint8_t):
						switch ( newDataType.dataTypeFormat ) {
							case CPUndefinedDataType:
								break;
							case CPIntegerDataType:
								switch ( newDataType.sampleBytes ) {
									case sizeof(int8_t): { // uint8_t -> int8_t
										const uint8_t *fromBytes = (uint8_t *)sourceData.bytes;
										const uint8_t *lastSample = fromBytes + sampleCount;
										int8_t *toBytes = (int8_t *)((NSMutableData *)newData).mutableBytes;
										while ( fromBytes < lastSample ) *toBytes++ = (int8_t)*fromBytes++;
									}
										break;
									case sizeof(int16_t): { // uint8_t -> int16_t
										const uint8_t *fromBytes = (uint8_t *)sourceData.bytes;
										const uint8_t *lastSample = fromBytes + sampleCount;
										int16_t *toBytes = (int16_t *)((NSMutableData *)newData).mutableBytes;
										while ( fromBytes < lastSample ) *toBytes++ = (int16_t)*fromBytes++;
									}
										break;
									case sizeof(int32_t): { // uint8_t -> int32_t
										const uint8_t *fromBytes = (uint8_t *)sourceData.bytes;
										const uint8_t *lastSample = fromBytes + sampleCount;
										int32_t *toBytes = (int32_t *)((NSMutableData *)newData).mutableBytes;
										while ( fromBytes < lastSample ) *toBytes++ = (int32_t)*fromBytes++;
									}
										break;
									case sizeof(int64_t): { // uint8_t -> int64_t
										const uint8_t *fromBytes = (uint8_t *)sourceData.bytes;
										const uint8_t *lastSample = fromBytes + sampleCount;
										int64_t *toBytes = (int64_t *)((NSMutableData *)newData).mutableBytes;
										while ( fromBytes < lastSample ) *toBytes++ = (int64_t)*fromBytes++;
									}
										break;
								}
								break;
							case CPUnsignedIntegerDataType:
								switch ( newDataType.sampleBytes ) {
									case sizeof(uint8_t): { // uint8_t -> uint8_t
										const uint8_t *fromBytes = (uint8_t *)sourceData.bytes;
										const uint8_t *lastSample = fromBytes + sampleCount;
										uint8_t *toBytes = (uint8_t *)((NSMutableData *)newData).mutableBytes;
										while ( fromBytes < lastSample ) *toBytes++ = (uint8_t)*fromBytes++;
									}
										break;
									case sizeof(uint16_t): { // uint8_t -> uint16_t
										const uint8_t *fromBytes = (uint8_t *)sourceData.bytes;
										const uint8_t *lastSample = fromBytes + sampleCount;
										uint16_t *toBytes = (uint16_t *)((NSMutableData *)newData).mutableBytes;
										while ( fromBytes < lastSample ) *toBytes++ = (uint16_t)*fromBytes++;
									}
										break;
									case sizeof(uint32_t): { // uint8_t -> uint32_t
										const uint8_t *fromBytes = (uint8_t *)sourceData.bytes;
										const uint8_t *lastSample = fromBytes + sampleCount;
										uint32_t *toBytes = (uint32_t *)((NSMutableData *)newData).mutableBytes;
										while ( fromBytes < lastSample ) *toBytes++ = (uint32_t)*fromBytes++;
									}
										break;
									case sizeof(uint64_t): { // uint8_t -> uint64_t
										const uint8_t *fromBytes = (uint8_t *)sourceData.bytes;
										const uint8_t *lastSample = fromBytes + sampleCount;
										uint64_t *toBytes = (uint64_t *)((NSMutableData *)newData).mutableBytes;
										while ( fromBytes < lastSample ) *toBytes++ = (uint64_t)*fromBytes++;
									}
										break;
								}
								break;
							case CPFloatingPointDataType:
								switch ( newDataType.sampleBytes ) {
									case sizeof(float): { // uint8_t -> float
										const uint8_t *fromBytes = (uint8_t *)sourceData.bytes;
										const uint8_t *lastSample = fromBytes + sampleCount;
										float *toBytes = (float *)((NSMutableData *)newData).mutableBytes;
										while ( fromBytes < lastSample ) *toBytes++ = (float)*fromBytes++;
									}
										break;
									case sizeof(double): { // uint8_t -> double
										const uint8_t *fromBytes = (uint8_t *)sourceData.bytes;
										const uint8_t *lastSample = fromBytes + sampleCount;
										double *toBytes = (double *)((NSMutableData *)newData).mutableBytes;
										while ( fromBytes < lastSample ) *toBytes++ = (double)*fromBytes++;
									}
										break;
								}
								break;
							case CPComplexFloatingPointDataType:
								break;
						}
						break;
					case sizeof(uint16_t):
						switch ( newDataType.dataTypeFormat ) {
							case CPUndefinedDataType:
								break;
							case CPIntegerDataType:
								switch ( newDataType.sampleBytes ) {
									case sizeof(int8_t): { // uint16_t -> int8_t
										const uint16_t *fromBytes = (uint16_t *)sourceData.bytes;
										const uint16_t *lastSample = fromBytes + sampleCount;
										int8_t *toBytes = (int8_t *)((NSMutableData *)newData).mutableBytes;
										while ( fromBytes < lastSample ) *toBytes++ = (int8_t)*fromBytes++;
									}
										break;
									case sizeof(int16_t): { // uint16_t -> int16_t
										const uint16_t *fromBytes = (uint16_t *)sourceData.bytes;
										const uint16_t *lastSample = fromBytes + sampleCount;
										int16_t *toBytes = (int16_t *)((NSMutableData *)newData).mutableBytes;
										while ( fromBytes < lastSample ) *toBytes++ = (int16_t)*fromBytes++;
									}
										break;
									case sizeof(int32_t): { // uint16_t -> int32_t
										const uint16_t *fromBytes = (uint16_t *)sourceData.bytes;
										const uint16_t *lastSample = fromBytes + sampleCount;
										int32_t *toBytes = (int32_t *)((NSMutableData *)newData).mutableBytes;
										while ( fromBytes < lastSample ) *toBytes++ = (int32_t)*fromBytes++;
									}
										break;
									case sizeof(int64_t): { // uint16_t -> int64_t
										const uint16_t *fromBytes = (uint16_t *)sourceData.bytes;
										const uint16_t *lastSample = fromBytes + sampleCount;
										int64_t *toBytes = (int64_t *)((NSMutableData *)newData).mutableBytes;
										while ( fromBytes < lastSample ) *toBytes++ = (int64_t)*fromBytes++;
									}
										break;
								}
								break;
							case CPUnsignedIntegerDataType:
								switch ( newDataType.sampleBytes ) {
									case sizeof(uint8_t): { // uint16_t -> uint8_t
										const uint16_t *fromBytes = (uint16_t *)sourceData.bytes;
										const uint16_t *lastSample = fromBytes + sampleCount;
										uint8_t *toBytes = (uint8_t *)((NSMutableData *)newData).mutableBytes;
										while ( fromBytes < lastSample ) *toBytes++ = (uint8_t)*fromBytes++;
									}
										break;
									case sizeof(uint16_t): { // uint16_t -> uint16_t
										const uint16_t *fromBytes = (uint16_t *)sourceData.bytes;
										const uint16_t *lastSample = fromBytes + sampleCount;
										uint16_t *toBytes = (uint16_t *)((NSMutableData *)newData).mutableBytes;
										while ( fromBytes < lastSample ) *toBytes++ = (uint16_t)*fromBytes++;
									}
										break;
									case sizeof(uint32_t): { // uint16_t -> uint32_t
										const uint16_t *fromBytes = (uint16_t *)sourceData.bytes;
										const uint16_t *lastSample = fromBytes + sampleCount;
										uint32_t *toBytes = (uint32_t *)((NSMutableData *)newData).mutableBytes;
										while ( fromBytes < lastSample ) *toBytes++ = (uint32_t)*fromBytes++;
									}
										break;
									case sizeof(uint64_t): { // uint16_t -> uint64_t
										const uint16_t *fromBytes = (uint16_t *)sourceData.bytes;
										const uint16_t *lastSample = fromBytes + sampleCount;
										uint64_t *toBytes = (uint64_t *)((NSMutableData *)newData).mutableBytes;
										while ( fromBytes < lastSample ) *toBytes++ = (uint64_t)*fromBytes++;
									}
										break;
								}
								break;
							case CPFloatingPointDataType:
								switch ( newDataType.sampleBytes ) {
									case sizeof(float): { // uint16_t -> float
										const uint16_t *fromBytes = (uint16_t *)sourceData.bytes;
										const uint16_t *lastSample = fromBytes + sampleCount;
										float *toBytes = (float *)((NSMutableData *)newData).mutableBytes;
										while ( fromBytes < lastSample ) *toBytes++ = (float)*fromBytes++;
									}
										break;
									case sizeof(double): { // uint16_t -> double
										const uint16_t *fromBytes = (uint16_t *)sourceData.bytes;
										const uint16_t *lastSample = fromBytes + sampleCount;
										double *toBytes = (double *)((NSMutableData *)newData).mutableBytes;
										while ( fromBytes < lastSample ) *toBytes++ = (double)*fromBytes++;
									}
										break;
								}
								break;
							case CPComplexFloatingPointDataType:
								break;
						}
						break;
					case sizeof(uint32_t):
						switch ( newDataType.dataTypeFormat ) {
							case CPUndefinedDataType:
								break;
							case CPIntegerDataType:
								switch ( newDataType.sampleBytes ) {
									case sizeof(int8_t): { // uint32_t -> int8_t
										const uint32_t *fromBytes = (uint32_t *)sourceData.bytes;
										const uint32_t *lastSample = fromBytes + sampleCount;
										int8_t *toBytes = (int8_t *)((NSMutableData *)newData).mutableBytes;
										while ( fromBytes < lastSample ) *toBytes++ = (int8_t)*fromBytes++;
									}
										break;
									case sizeof(int16_t): { // uint32_t -> int16_t
										const uint32_t *fromBytes = (uint32_t *)sourceData.bytes;
										const uint32_t *lastSample = fromBytes + sampleCount;
										int16_t *toBytes = (int16_t *)((NSMutableData *)newData).mutableBytes;
										while ( fromBytes < lastSample ) *toBytes++ = (int16_t)*fromBytes++;
									}
										break;
									case sizeof(int32_t): { // uint32_t -> int32_t
										const uint32_t *fromBytes = (uint32_t *)sourceData.bytes;
										const uint32_t *lastSample = fromBytes + sampleCount;
										int32_t *toBytes = (int32_t *)((NSMutableData *)newData).mutableBytes;
										while ( fromBytes < lastSample ) *toBytes++ = (int32_t)*fromBytes++;
									}
										break;
									case sizeof(int64_t): { // uint32_t -> int64_t
										const uint32_t *fromBytes = (uint32_t *)sourceData.bytes;
										const uint32_t *lastSample = fromBytes + sampleCount;
										int64_t *toBytes = (int64_t *)((NSMutableData *)newData).mutableBytes;
										while ( fromBytes < lastSample ) *toBytes++ = (int64_t)*fromBytes++;
									}
										break;
								}
								break;
							case CPUnsignedIntegerDataType:
								switch ( newDataType.sampleBytes ) {
									case sizeof(uint8_t): { // uint32_t -> uint8_t
										const uint32_t *fromBytes = (uint32_t *)sourceData.bytes;
										const uint32_t *lastSample = fromBytes + sampleCount;
										uint8_t *toBytes = (uint8_t *)((NSMutableData *)newData).mutableBytes;
										while ( fromBytes < lastSample ) *toBytes++ = (uint8_t)*fromBytes++;
									}
										break;
									case sizeof(uint16_t): { // uint32_t -> uint16_t
										const uint32_t *fromBytes = (uint32_t *)sourceData.bytes;
										const uint32_t *lastSample = fromBytes + sampleCount;
										uint16_t *toBytes = (uint16_t *)((NSMutableData *)newData).mutableBytes;
										while ( fromBytes < lastSample ) *toBytes++ = (uint16_t)*fromBytes++;
									}
										break;
									case sizeof(uint32_t): { // uint32_t -> uint32_t
										const uint32_t *fromBytes = (uint32_t *)sourceData.bytes;
										const uint32_t *lastSample = fromBytes + sampleCount;
										uint32_t *toBytes = (uint32_t *)((NSMutableData *)newData).mutableBytes;
										while ( fromBytes < lastSample ) *toBytes++ = (uint32_t)*fromBytes++;
									}
										break;
									case sizeof(uint64_t): { // uint32_t -> uint64_t
										const uint32_t *fromBytes = (uint32_t *)sourceData.bytes;
										const uint32_t *lastSample = fromBytes + sampleCount;
										uint64_t *toBytes = (uint64_t *)((NSMutableData *)newData).mutableBytes;
										while ( fromBytes < lastSample ) *toBytes++ = (uint64_t)*fromBytes++;
									}
										break;
								}
								break;
							case CPFloatingPointDataType:
								switch ( newDataType.sampleBytes ) {
									case sizeof(float): { // uint32_t -> float
										const uint32_t *fromBytes = (uint32_t *)sourceData.bytes;
										const uint32_t *lastSample = fromBytes + sampleCount;
										float *toBytes = (float *)((NSMutableData *)newData).mutableBytes;
										while ( fromBytes < lastSample ) *toBytes++ = (float)*fromBytes++;
									}
										break;
									case sizeof(double): { // uint32_t -> double
										const uint32_t *fromBytes = (uint32_t *)sourceData.bytes;
										const uint32_t *lastSample = fromBytes + sampleCount;
										double *toBytes = (double *)((NSMutableData *)newData).mutableBytes;
										while ( fromBytes < lastSample ) *toBytes++ = (double)*fromBytes++;
									}
										break;
								}
								break;
							case CPComplexFloatingPointDataType:
								break;
						}
						break;
					case sizeof(uint64_t):
						switch ( newDataType.dataTypeFormat ) {
							case CPUndefinedDataType:
								break;
							case CPIntegerDataType:
								switch ( newDataType.sampleBytes ) {
									case sizeof(int8_t): { // uint64_t -> int8_t
										const uint64_t *fromBytes = (uint64_t *)sourceData.bytes;
										const uint64_t *lastSample = fromBytes + sampleCount;
										int8_t *toBytes = (int8_t *)((NSMutableData *)newData).mutableBytes;
										while ( fromBytes < lastSample ) *toBytes++ = (int8_t)*fromBytes++;
									}
										break;
									case sizeof(int16_t): { // uint64_t -> int16_t
										const uint64_t *fromBytes = (uint64_t *)sourceData.bytes;
										const uint64_t *lastSample = fromBytes + sampleCount;
										int16_t *toBytes = (int16_t *)((NSMutableData *)newData).mutableBytes;
										while ( fromBytes < lastSample ) *toBytes++ = (int16_t)*fromBytes++;
									}
										break;
									case sizeof(int32_t): { // uint64_t -> int32_t
										const uint64_t *fromBytes = (uint64_t *)sourceData.bytes;
										const uint64_t *lastSample = fromBytes + sampleCount;
										int32_t *toBytes = (int32_t *)((NSMutableData *)newData).mutableBytes;
										while ( fromBytes < lastSample ) *toBytes++ = (int32_t)*fromBytes++;
									}
										break;
									case sizeof(int64_t): { // uint64_t -> int64_t
										const uint64_t *fromBytes = (uint64_t *)sourceData.bytes;
										const uint64_t *lastSample = fromBytes + sampleCount;
										int64_t *toBytes = (int64_t *)((NSMutableData *)newData).mutableBytes;
										while ( fromBytes < lastSample ) *toBytes++ = (int64_t)*fromBytes++;
									}
										break;
								}
								break;
							case CPUnsignedIntegerDataType:
								switch ( newDataType.sampleBytes ) {
									case sizeof(uint8_t): { // uint64_t -> uint8_t
										const uint64_t *fromBytes = (uint64_t *)sourceData.bytes;
										const uint64_t *lastSample = fromBytes + sampleCount;
										uint8_t *toBytes = (uint8_t *)((NSMutableData *)newData).mutableBytes;
										while ( fromBytes < lastSample ) *toBytes++ = (uint8_t)*fromBytes++;
									}
										break;
									case sizeof(uint16_t): { // uint64_t -> uint16_t
										const uint64_t *fromBytes = (uint64_t *)sourceData.bytes;
										const uint64_t *lastSample = fromBytes + sampleCount;
										uint16_t *toBytes = (uint16_t *)((NSMutableData *)newData).mutableBytes;
										while ( fromBytes < lastSample ) *toBytes++ = (uint16_t)*fromBytes++;
									}
										break;
									case sizeof(uint32_t): { // uint64_t -> uint32_t
										const uint64_t *fromBytes = (uint64_t *)sourceData.bytes;
										const uint64_t *lastSample = fromBytes + sampleCount;
										uint32_t *toBytes = (uint32_t *)((NSMutableData *)newData).mutableBytes;
										while ( fromBytes < lastSample ) *toBytes++ = (uint32_t)*fromBytes++;
									}
										break;
									case sizeof(uint64_t): { // uint64_t -> uint64_t
										const uint64_t *fromBytes = (uint64_t *)sourceData.bytes;
										const uint64_t *lastSample = fromBytes + sampleCount;
										uint64_t *toBytes = (uint64_t *)((NSMutableData *)newData).mutableBytes;
										while ( fromBytes < lastSample ) *toBytes++ = (uint64_t)*fromBytes++;
									}
										break;
								}
								break;
							case CPFloatingPointDataType:
								switch ( newDataType.sampleBytes ) {
									case sizeof(float): { // uint64_t -> float
										const uint64_t *fromBytes = (uint64_t *)sourceData.bytes;
										const uint64_t *lastSample = fromBytes + sampleCount;
										float *toBytes = (float *)((NSMutableData *)newData).mutableBytes;
										while ( fromBytes < lastSample ) *toBytes++ = (float)*fromBytes++;
									}
										break;
									case sizeof(double): { // uint64_t -> double
										const uint64_t *fromBytes = (uint64_t *)sourceData.bytes;
										const uint64_t *lastSample = fromBytes + sampleCount;
										double *toBytes = (double *)((NSMutableData *)newData).mutableBytes;
										while ( fromBytes < lastSample ) *toBytes++ = (double)*fromBytes++;
									}
										break;
								}
								break;
							case CPComplexFloatingPointDataType:
								break;
						}
						break;
				}
				break;
			case CPFloatingPointDataType:
				switch ( myDataType.sampleBytes ) {
					case sizeof(float):
						switch ( newDataType.dataTypeFormat ) {
							case CPUndefinedDataType:
								break;
							case CPIntegerDataType:
								switch ( newDataType.sampleBytes ) {
									case sizeof(int8_t): { // float -> int8_t
										const float *fromBytes = (float *)sourceData.bytes;
										const float *lastSample = fromBytes + sampleCount;
										int8_t *toBytes = (int8_t *)((NSMutableData *)newData).mutableBytes;
										while ( fromBytes < lastSample ) *toBytes++ = (int8_t)*fromBytes++;
									}
										break;
									case sizeof(int16_t): { // float -> int16_t
										const float *fromBytes = (float *)sourceData.bytes;
										const float *lastSample = fromBytes + sampleCount;
										int16_t *toBytes = (int16_t *)((NSMutableData *)newData).mutableBytes;
										while ( fromBytes < lastSample ) *toBytes++ = (int16_t)*fromBytes++;
									}
										break;
									case sizeof(int32_t): { // float -> int32_t
										const float *fromBytes = (float *)sourceData.bytes;
										const float *lastSample = fromBytes + sampleCount;
										int32_t *toBytes = (int32_t *)((NSMutableData *)newData).mutableBytes;
										while ( fromBytes < lastSample ) *toBytes++ = (int32_t)*fromBytes++;
									}
										break;
									case sizeof(int64_t): { // float -> int64_t
										const float *fromBytes = (float *)sourceData.bytes;
										const float *lastSample = fromBytes + sampleCount;
										int64_t *toBytes = (int64_t *)((NSMutableData *)newData).mutableBytes;
										while ( fromBytes < lastSample ) *toBytes++ = (int64_t)*fromBytes++;
									}
										break;
								}
								break;
							case CPUnsignedIntegerDataType:
								switch ( newDataType.sampleBytes ) {
									case sizeof(uint8_t): { // float -> uint8_t
										const float *fromBytes = (float *)sourceData.bytes;
										const float *lastSample = fromBytes + sampleCount;
										uint8_t *toBytes = (uint8_t *)((NSMutableData *)newData).mutableBytes;
										while ( fromBytes < lastSample ) *toBytes++ = (uint8_t)*fromBytes++;
									}
										break;
									case sizeof(uint16_t): { // float -> uint16_t
										const float *fromBytes = (float *)sourceData.bytes;
										const float *lastSample = fromBytes + sampleCount;
										uint16_t *toBytes = (uint16_t *)((NSMutableData *)newData).mutableBytes;
										while ( fromBytes < lastSample ) *toBytes++ = (uint16_t)*fromBytes++;
									}
										break;
									case sizeof(uint32_t): { // float -> uint32_t
										const float *fromBytes = (float *)sourceData.bytes;
										const float *lastSample = fromBytes + sampleCount;
										uint32_t *toBytes = (uint32_t *)((NSMutableData *)newData).mutableBytes;
										while ( fromBytes < lastSample ) *toBytes++ = (uint32_t)*fromBytes++;
									}
										break;
									case sizeof(uint64_t): { // float -> uint64_t
										const float *fromBytes = (float *)sourceData.bytes;
										const float *lastSample = fromBytes + sampleCount;
										uint64_t *toBytes = (uint64_t *)((NSMutableData *)newData).mutableBytes;
										while ( fromBytes < lastSample ) *toBytes++ = (uint64_t)*fromBytes++;
									}
										break;
								}
								break;
							case CPFloatingPointDataType:
								switch ( newDataType.sampleBytes ) {
									case sizeof(float): { // float -> float
										const float *fromBytes = (float *)sourceData.bytes;
										const float *lastSample = fromBytes + sampleCount;
										float *toBytes = (float *)((NSMutableData *)newData).mutableBytes;
										while ( fromBytes < lastSample ) *toBytes++ = (float)*fromBytes++;
									}
										break;
									case sizeof(double): { // float -> double
										const float *fromBytes = (float *)sourceData.bytes;
										const float *lastSample = fromBytes + sampleCount;
										double *toBytes = (double *)((NSMutableData *)newData).mutableBytes;
										while ( fromBytes < lastSample ) *toBytes++ = (double)*fromBytes++;
									}
										break;
								}
								break;
							case CPComplexFloatingPointDataType:
								break;
						}
						break;
					case sizeof(double):
						switch ( newDataType.dataTypeFormat ) {
							case CPUndefinedDataType:
								break;
							case CPIntegerDataType:
								switch ( newDataType.sampleBytes ) {
									case sizeof(int8_t): { // double -> int8_t
										const double *fromBytes = (double *)sourceData.bytes;
										const double *lastSample = fromBytes + sampleCount;
										int8_t *toBytes = (int8_t *)((NSMutableData *)newData).mutableBytes;
										while ( fromBytes < lastSample ) *toBytes++ = (int8_t)*fromBytes++;
									}
										break;
									case sizeof(int16_t): { // double -> int16_t
										const double *fromBytes = (double *)sourceData.bytes;
										const double *lastSample = fromBytes + sampleCount;
										int16_t *toBytes = (int16_t *)((NSMutableData *)newData).mutableBytes;
										while ( fromBytes < lastSample ) *toBytes++ = (int16_t)*fromBytes++;
									}
										break;
									case sizeof(int32_t): { // double -> int32_t
										const double *fromBytes = (double *)sourceData.bytes;
										const double *lastSample = fromBytes + sampleCount;
										int32_t *toBytes = (int32_t *)((NSMutableData *)newData).mutableBytes;
										while ( fromBytes < lastSample ) *toBytes++ = (int32_t)*fromBytes++;
									}
										break;
									case sizeof(int64_t): { // double -> int64_t
										const double *fromBytes = (double *)sourceData.bytes;
										const double *lastSample = fromBytes + sampleCount;
										int64_t *toBytes = (int64_t *)((NSMutableData *)newData).mutableBytes;
										while ( fromBytes < lastSample ) *toBytes++ = (int64_t)*fromBytes++;
									}
										break;
								}
								break;
							case CPUnsignedIntegerDataType:
								switch ( newDataType.sampleBytes ) {
									case sizeof(uint8_t): { // double -> uint8_t
										const double *fromBytes = (double *)sourceData.bytes;
										const double *lastSample = fromBytes + sampleCount;
										uint8_t *toBytes = (uint8_t *)((NSMutableData *)newData).mutableBytes;
										while ( fromBytes < lastSample ) *toBytes++ = (uint8_t)*fromBytes++;
									}
										break;
									case sizeof(uint16_t): { // double -> uint16_t
										const double *fromBytes = (double *)sourceData.bytes;
										const double *lastSample = fromBytes + sampleCount;
										uint16_t *toBytes = (uint16_t *)((NSMutableData *)newData).mutableBytes;
										while ( fromBytes < lastSample ) *toBytes++ = (uint16_t)*fromBytes++;
									}
										break;
									case sizeof(uint32_t): { // double -> uint32_t
										const double *fromBytes = (double *)sourceData.bytes;
										const double *lastSample = fromBytes + sampleCount;
										uint32_t *toBytes = (uint32_t *)((NSMutableData *)newData).mutableBytes;
										while ( fromBytes < lastSample ) *toBytes++ = (uint32_t)*fromBytes++;
									}
										break;
									case sizeof(uint64_t): { // double -> uint64_t
										const double *fromBytes = (double *)sourceData.bytes;
										const double *lastSample = fromBytes + sampleCount;
										uint64_t *toBytes = (uint64_t *)((NSMutableData *)newData).mutableBytes;
										while ( fromBytes < lastSample ) *toBytes++ = (uint64_t)*fromBytes++;
									}
										break;
								}
								break;
							case CPFloatingPointDataType:
								switch ( newDataType.sampleBytes ) {
									case sizeof(float): { // double -> float
										const double *fromBytes = (double *)sourceData.bytes;
										const double *lastSample = fromBytes + sampleCount;
										float *toBytes = (float *)((NSMutableData *)newData).mutableBytes;
										while ( fromBytes < lastSample ) *toBytes++ = (float)*fromBytes++;
									}
										break;
									case sizeof(double): { // double -> double
										const double *fromBytes = (double *)sourceData.bytes;
										const double *lastSample = fromBytes + sampleCount;
										double *toBytes = (double *)((NSMutableData *)newData).mutableBytes;
										while ( fromBytes < lastSample ) *toBytes++ = (double)*fromBytes++;
									}
										break;
								}
								break;
							case CPComplexFloatingPointDataType:
								break;
						}
						break;
				}
				break;
			case CPComplexFloatingPointDataType:
				break;
		}
		
		// End of code generated with "CPNumericData+TypeConversions_Generation.py"
		// ========================================================================
		
		[sourceData release];
		
		if ( newDataType.byteOrder != hostByteOrder ) {
			[self swapByteOrderForData:(NSMutableData *)newData sampleSize:newDataType.sampleBytes];
		}
	}
    
    CPNumericData *result = [CPNumericData numericDataWithData:newData
													  dataType:newDataType
														 shape:self.shape];
	[newData release];
	return result;
}

@end

@implementation CPNumericData(TypeConversionPrivateMethods)

-(void)swapByteOrderForData:(NSMutableData *)sourceData sampleSize:(size_t)sampleSize
{
	NSUInteger sampleCount;
	switch ( sampleSize ) {
		case sizeof(uint16_t): {
			uint16_t *samples = (uint16_t *)sourceData.mutableBytes;
			sampleCount = sourceData.length / sampleSize;
			uint16_t *lastSample = samples + sampleCount;
			
			while ( samples < lastSample ) {
				uint16_t swapped = CFSwapInt16(*samples);
				*samples++ = swapped;
			}
		}
			break;
		case sizeof(uint32_t): {
			uint32_t *samples = (uint32_t *)sourceData.mutableBytes;
			sampleCount = sourceData.length / sampleSize;
			uint32_t *lastSample = samples + sampleCount;
			
			while ( samples < lastSample ) {
				uint32_t swapped = CFSwapInt32(*samples);
				*samples++ = swapped;
			}
		}
			break;
		case sizeof(uint64_t): {
			uint64_t *samples = (uint64_t *)sourceData.mutableBytes;
			sampleCount = sourceData.length / sampleSize;
			uint64_t *lastSample = samples + sampleCount;
			
			while ( samples < lastSample ) {
				uint64_t swapped = CFSwapInt64(*samples);
				*samples++ = swapped;
			}
		}
			break;
		default:
			// do nothing
			break;
	}
}

@end
