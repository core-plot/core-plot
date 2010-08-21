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
                             sampleBytes:(NSUInteger)newSampleBytes
                               byteOrder:(CFByteOrder)newByteOrder 
{
	NSData *result = nil;
	switch( [self dataTypeFormat] ) {
		case CPUndefinedDataType:
			[NSException raise:NSInvalidArgumentException format:@"Unsupported data type (CPUndefinedDataType)"];
			break;
		case CPIntegerDataType:
			switch( [self sampleBytes] ) {
				case sizeof(char):
					switch( newDataType ) {
						case CPUndefinedDataType:
							switch( newSampleBytes ) {
								case sizeof(char):
									result = coreplot::convert_numeric_data_type<char, char>(self.data, [self byteOrder], newByteOrder);
									break;
								case sizeof(short):
									result = coreplot::convert_numeric_data_type<char, short>(self.data, [self byteOrder], newByteOrder);
									break;
								case sizeof(NSInteger):
									result = coreplot::convert_numeric_data_type<char, NSInteger>(self.data, [self byteOrder], newByteOrder);
									break;
							}
							break;
						case CPIntegerDataType:
							switch( newSampleBytes ) {
								case sizeof(char):
									result = coreplot::convert_numeric_data_type<char, char>(self.data, [self byteOrder], newByteOrder);
									break;
								case sizeof(short):
									result = coreplot::convert_numeric_data_type<char, short>(self.data, [self byteOrder], newByteOrder);
									break;
								case sizeof(NSInteger):
									result = coreplot::convert_numeric_data_type<char, NSInteger>(self.data, [self byteOrder], newByteOrder);
									break;
							}
							break;
						case CPUnsignedIntegerDataType:
							switch( newSampleBytes ) {
								case sizeof(char):
									result = coreplot::convert_numeric_data_type<char, char>(self.data, [self byteOrder], newByteOrder);
									break;
								case sizeof(short):
									result = coreplot::convert_numeric_data_type<char, short>(self.data, [self byteOrder], newByteOrder);
									break;
								case sizeof(NSInteger):
									result = coreplot::convert_numeric_data_type<char, NSInteger>(self.data, [self byteOrder], newByteOrder);
									break;
							}
							break;
						case CPFloatingPointDataType:
							switch( newSampleBytes ) {
								case sizeof(char):
									result = coreplot::convert_numeric_data_type<char, char>(self.data, [self byteOrder], newByteOrder);
									break;
								case sizeof(short):
									result = coreplot::convert_numeric_data_type<char, short>(self.data, [self byteOrder], newByteOrder);
									break;
								case sizeof(NSInteger):
									result = coreplot::convert_numeric_data_type<char, NSInteger>(self.data, [self byteOrder], newByteOrder);
									break;
							}
							break;
						case CPComplexFloatingPointDataType:
							switch( newSampleBytes ) {
								case sizeof(char):
									result = coreplot::convert_numeric_data_type<char, char>(self.data, [self byteOrder], newByteOrder);
									break;
								case sizeof(short):
									result = coreplot::convert_numeric_data_type<char, short>(self.data, [self byteOrder], newByteOrder);
									break;
								case sizeof(NSInteger):
									result = coreplot::convert_numeric_data_type<char, NSInteger>(self.data, [self byteOrder], newByteOrder);
									break;
							}
							break;
					}
					break;
				case sizeof(short):
					switch( newDataType ) {
						case CPUndefinedDataType:
							switch( newSampleBytes ) {
								case sizeof(char):
									result = coreplot::convert_numeric_data_type<short, char>(self.data, [self byteOrder], newByteOrder);
									break;
								case sizeof(short):
									result = coreplot::convert_numeric_data_type<short, short>(self.data, [self byteOrder], newByteOrder);
									break;
								case sizeof(NSInteger):
									result = coreplot::convert_numeric_data_type<short, NSInteger>(self.data, [self byteOrder], newByteOrder);
									break;
							}
							break;
						case CPIntegerDataType:
							switch( newSampleBytes ) {
								case sizeof(char):
									result = coreplot::convert_numeric_data_type<short, char>(self.data, [self byteOrder], newByteOrder);
									break;
								case sizeof(short):
									result = coreplot::convert_numeric_data_type<short, short>(self.data, [self byteOrder], newByteOrder);
									break;
								case sizeof(NSInteger):
									result = coreplot::convert_numeric_data_type<short, NSInteger>(self.data, [self byteOrder], newByteOrder);
									break;
							}
							break;
						case CPUnsignedIntegerDataType:
							switch( newSampleBytes ) {
								case sizeof(char):
									result = coreplot::convert_numeric_data_type<short, char>(self.data, [self byteOrder], newByteOrder);
									break;
								case sizeof(short):
									result = coreplot::convert_numeric_data_type<short, short>(self.data, [self byteOrder], newByteOrder);
									break;
								case sizeof(NSInteger):
									result = coreplot::convert_numeric_data_type<short, NSInteger>(self.data, [self byteOrder], newByteOrder);
									break;
							}
							break;
						case CPFloatingPointDataType:
							switch( newSampleBytes ) {
								case sizeof(char):
									result = coreplot::convert_numeric_data_type<short, char>(self.data, [self byteOrder], newByteOrder);
									break;
								case sizeof(short):
									result = coreplot::convert_numeric_data_type<short, short>(self.data, [self byteOrder], newByteOrder);
									break;
								case sizeof(NSInteger):
									result = coreplot::convert_numeric_data_type<short, NSInteger>(self.data, [self byteOrder], newByteOrder);
									break;
							}
							break;
						case CPComplexFloatingPointDataType:
							switch( newSampleBytes ) {
								case sizeof(char):
									result = coreplot::convert_numeric_data_type<short, char>(self.data, [self byteOrder], newByteOrder);
									break;
								case sizeof(short):
									result = coreplot::convert_numeric_data_type<short, short>(self.data, [self byteOrder], newByteOrder);
									break;
								case sizeof(NSInteger):
									result = coreplot::convert_numeric_data_type<short, NSInteger>(self.data, [self byteOrder], newByteOrder);
									break;
							}
							break;
					}
					break;
				case sizeof(NSInteger):
					switch( newDataType ) {
						case CPUndefinedDataType:
							switch( newSampleBytes ) {
								case sizeof(char):
									result = coreplot::convert_numeric_data_type<NSInteger, char>(self.data, [self byteOrder], newByteOrder);
									break;
								case sizeof(short):
									result = coreplot::convert_numeric_data_type<NSInteger, short>(self.data, [self byteOrder], newByteOrder);
									break;
								case sizeof(NSInteger):
									result = coreplot::convert_numeric_data_type<NSInteger, NSInteger>(self.data, [self byteOrder], newByteOrder);
									break;
							}
							break;
						case CPIntegerDataType:
							switch( newSampleBytes ) {
								case sizeof(char):
									result = coreplot::convert_numeric_data_type<NSInteger, char>(self.data, [self byteOrder], newByteOrder);
									break;
								case sizeof(short):
									result = coreplot::convert_numeric_data_type<NSInteger, short>(self.data, [self byteOrder], newByteOrder);
									break;
								case sizeof(NSInteger):
									result = coreplot::convert_numeric_data_type<NSInteger, NSInteger>(self.data, [self byteOrder], newByteOrder);
									break;
							}
							break;
						case CPUnsignedIntegerDataType:
							switch( newSampleBytes ) {
								case sizeof(char):
									result = coreplot::convert_numeric_data_type<NSInteger, char>(self.data, [self byteOrder], newByteOrder);
									break;
								case sizeof(short):
									result = coreplot::convert_numeric_data_type<NSInteger, short>(self.data, [self byteOrder], newByteOrder);
									break;
								case sizeof(NSInteger):
									result = coreplot::convert_numeric_data_type<NSInteger, NSInteger>(self.data, [self byteOrder], newByteOrder);
									break;
							}
							break;
						case CPFloatingPointDataType:
							switch( newSampleBytes ) {
								case sizeof(char):
									result = coreplot::convert_numeric_data_type<NSInteger, char>(self.data, [self byteOrder], newByteOrder);
									break;
								case sizeof(short):
									result = coreplot::convert_numeric_data_type<NSInteger, short>(self.data, [self byteOrder], newByteOrder);
									break;
								case sizeof(NSInteger):
									result = coreplot::convert_numeric_data_type<NSInteger, NSInteger>(self.data, [self byteOrder], newByteOrder);
									break;
							}
							break;
						case CPComplexFloatingPointDataType:
							switch( newSampleBytes ) {
								case sizeof(char):
									result = coreplot::convert_numeric_data_type<NSInteger, char>(self.data, [self byteOrder], newByteOrder);
									break;
								case sizeof(short):
									result = coreplot::convert_numeric_data_type<NSInteger, short>(self.data, [self byteOrder], newByteOrder);
									break;
								case sizeof(NSInteger):
									result = coreplot::convert_numeric_data_type<NSInteger, NSInteger>(self.data, [self byteOrder], newByteOrder);
									break;
							}
							break;
					}
					break;
			}
			break;
		case CPUnsignedIntegerDataType:
			switch( [self sampleBytes] ) {
				case sizeof(unsigned char):
					switch( newDataType ) {
						case CPUndefinedDataType:
							switch( newSampleBytes ) {
								case sizeof(unsigned char):
									result = coreplot::convert_numeric_data_type<unsigned char, unsigned char>(self.data, [self byteOrder], newByteOrder);
									break;
								case sizeof(unsigned short):
									result = coreplot::convert_numeric_data_type<unsigned char, unsigned short>(self.data, [self byteOrder], newByteOrder);
									break;
								case sizeof(NSUInteger):
									result = coreplot::convert_numeric_data_type<unsigned char, NSUInteger>(self.data, [self byteOrder], newByteOrder);
									break;
							}
							break;
						case CPIntegerDataType:
							switch( newSampleBytes ) {
								case sizeof(unsigned char):
									result = coreplot::convert_numeric_data_type<unsigned char, unsigned char>(self.data, [self byteOrder], newByteOrder);
									break;
								case sizeof(unsigned short):
									result = coreplot::convert_numeric_data_type<unsigned char, unsigned short>(self.data, [self byteOrder], newByteOrder);
									break;
								case sizeof(NSUInteger):
									result = coreplot::convert_numeric_data_type<unsigned char, NSUInteger>(self.data, [self byteOrder], newByteOrder);
									break;
							}
							break;
						case CPUnsignedIntegerDataType:
							switch( newSampleBytes ) {
								case sizeof(unsigned char):
									result = coreplot::convert_numeric_data_type<unsigned char, unsigned char>(self.data, [self byteOrder], newByteOrder);
									break;
								case sizeof(unsigned short):
									result = coreplot::convert_numeric_data_type<unsigned char, unsigned short>(self.data, [self byteOrder], newByteOrder);
									break;
								case sizeof(NSUInteger):
									result = coreplot::convert_numeric_data_type<unsigned char, NSUInteger>(self.data, [self byteOrder], newByteOrder);
									break;
							}
							break;
						case CPFloatingPointDataType:
							switch( newSampleBytes ) {
								case sizeof(unsigned char):
									result = coreplot::convert_numeric_data_type<unsigned char, unsigned char>(self.data, [self byteOrder], newByteOrder);
									break;
								case sizeof(unsigned short):
									result = coreplot::convert_numeric_data_type<unsigned char, unsigned short>(self.data, [self byteOrder], newByteOrder);
									break;
								case sizeof(NSUInteger):
									result = coreplot::convert_numeric_data_type<unsigned char, NSUInteger>(self.data, [self byteOrder], newByteOrder);
									break;
							}
							break;
						case CPComplexFloatingPointDataType:
							switch( newSampleBytes ) {
								case sizeof(unsigned char):
									result = coreplot::convert_numeric_data_type<unsigned char, unsigned char>(self.data, [self byteOrder], newByteOrder);
									break;
								case sizeof(unsigned short):
									result = coreplot::convert_numeric_data_type<unsigned char, unsigned short>(self.data, [self byteOrder], newByteOrder);
									break;
								case sizeof(NSUInteger):
									result = coreplot::convert_numeric_data_type<unsigned char, NSUInteger>(self.data, [self byteOrder], newByteOrder);
									break;
							}
							break;
					}
					break;
				case sizeof(unsigned short):
					switch( newDataType ) {
						case CPUndefinedDataType:
							switch( newSampleBytes ) {
								case sizeof(unsigned char):
									result = coreplot::convert_numeric_data_type<unsigned short, unsigned char>(self.data, [self byteOrder], newByteOrder);
									break;
								case sizeof(unsigned short):
									result = coreplot::convert_numeric_data_type<unsigned short, unsigned short>(self.data, [self byteOrder], newByteOrder);
									break;
								case sizeof(NSUInteger):
									result = coreplot::convert_numeric_data_type<unsigned short, NSUInteger>(self.data, [self byteOrder], newByteOrder);
									break;
							}
							break;
						case CPIntegerDataType:
							switch( newSampleBytes ) {
								case sizeof(unsigned char):
									result = coreplot::convert_numeric_data_type<unsigned short, unsigned char>(self.data, [self byteOrder], newByteOrder);
									break;
								case sizeof(unsigned short):
									result = coreplot::convert_numeric_data_type<unsigned short, unsigned short>(self.data, [self byteOrder], newByteOrder);
									break;
								case sizeof(NSUInteger):
									result = coreplot::convert_numeric_data_type<unsigned short, NSUInteger>(self.data, [self byteOrder], newByteOrder);
									break;
							}
							break;
						case CPUnsignedIntegerDataType:
							switch( newSampleBytes ) {
								case sizeof(unsigned char):
									result = coreplot::convert_numeric_data_type<unsigned short, unsigned char>(self.data, [self byteOrder], newByteOrder);
									break;
								case sizeof(unsigned short):
									result = coreplot::convert_numeric_data_type<unsigned short, unsigned short>(self.data, [self byteOrder], newByteOrder);
									break;
								case sizeof(NSUInteger):
									result = coreplot::convert_numeric_data_type<unsigned short, NSUInteger>(self.data, [self byteOrder], newByteOrder);
									break;
							}
							break;
						case CPFloatingPointDataType:
							switch( newSampleBytes ) {
								case sizeof(unsigned char):
									result = coreplot::convert_numeric_data_type<unsigned short, unsigned char>(self.data, [self byteOrder], newByteOrder);
									break;
								case sizeof(unsigned short):
									result = coreplot::convert_numeric_data_type<unsigned short, unsigned short>(self.data, [self byteOrder], newByteOrder);
									break;
								case sizeof(NSUInteger):
									result = coreplot::convert_numeric_data_type<unsigned short, NSUInteger>(self.data, [self byteOrder], newByteOrder);
									break;
							}
							break;
						case CPComplexFloatingPointDataType:
							switch( newSampleBytes ) {
								case sizeof(unsigned char):
									result = coreplot::convert_numeric_data_type<unsigned short, unsigned char>(self.data, [self byteOrder], newByteOrder);
									break;
								case sizeof(unsigned short):
									result = coreplot::convert_numeric_data_type<unsigned short, unsigned short>(self.data, [self byteOrder], newByteOrder);
									break;
								case sizeof(NSUInteger):
									result = coreplot::convert_numeric_data_type<unsigned short, NSUInteger>(self.data, [self byteOrder], newByteOrder);
									break;
							}
							break;
					}
					break;
				case sizeof(NSUInteger):
					switch( newDataType ) {
						case CPUndefinedDataType:
							switch( newSampleBytes ) {
								case sizeof(unsigned char):
									result = coreplot::convert_numeric_data_type<NSUInteger, unsigned char>(self.data, [self byteOrder], newByteOrder);
									break;
								case sizeof(unsigned short):
									result = coreplot::convert_numeric_data_type<NSUInteger, unsigned short>(self.data, [self byteOrder], newByteOrder);
									break;
								case sizeof(NSUInteger):
									result = coreplot::convert_numeric_data_type<NSUInteger, NSUInteger>(self.data, [self byteOrder], newByteOrder);
									break;
							}
							break;
						case CPIntegerDataType:
							switch( newSampleBytes ) {
								case sizeof(unsigned char):
									result = coreplot::convert_numeric_data_type<NSUInteger, unsigned char>(self.data, [self byteOrder], newByteOrder);
									break;
								case sizeof(unsigned short):
									result = coreplot::convert_numeric_data_type<NSUInteger, unsigned short>(self.data, [self byteOrder], newByteOrder);
									break;
								case sizeof(NSUInteger):
									result = coreplot::convert_numeric_data_type<NSUInteger, NSUInteger>(self.data, [self byteOrder], newByteOrder);
									break;
							}
							break;
						case CPUnsignedIntegerDataType:
							switch( newSampleBytes ) {
								case sizeof(unsigned char):
									result = coreplot::convert_numeric_data_type<NSUInteger, unsigned char>(self.data, [self byteOrder], newByteOrder);
									break;
								case sizeof(unsigned short):
									result = coreplot::convert_numeric_data_type<NSUInteger, unsigned short>(self.data, [self byteOrder], newByteOrder);
									break;
								case sizeof(NSUInteger):
									result = coreplot::convert_numeric_data_type<NSUInteger, NSUInteger>(self.data, [self byteOrder], newByteOrder);
									break;
							}
							break;
						case CPFloatingPointDataType:
							switch( newSampleBytes ) {
								case sizeof(unsigned char):
									result = coreplot::convert_numeric_data_type<NSUInteger, unsigned char>(self.data, [self byteOrder], newByteOrder);
									break;
								case sizeof(unsigned short):
									result = coreplot::convert_numeric_data_type<NSUInteger, unsigned short>(self.data, [self byteOrder], newByteOrder);
									break;
								case sizeof(NSUInteger):
									result = coreplot::convert_numeric_data_type<NSUInteger, NSUInteger>(self.data, [self byteOrder], newByteOrder);
									break;
							}
							break;
						case CPComplexFloatingPointDataType:
							switch( newSampleBytes ) {
								case sizeof(unsigned char):
									result = coreplot::convert_numeric_data_type<NSUInteger, unsigned char>(self.data, [self byteOrder], newByteOrder);
									break;
								case sizeof(unsigned short):
									result = coreplot::convert_numeric_data_type<NSUInteger, unsigned short>(self.data, [self byteOrder], newByteOrder);
									break;
								case sizeof(NSUInteger):
									result = coreplot::convert_numeric_data_type<NSUInteger, NSUInteger>(self.data, [self byteOrder], newByteOrder);
									break;
							}
							break;
					}
					break;
			}
			break;
		case CPFloatingPointDataType:
			switch( [self sampleBytes] ) {
				case sizeof(float):
					switch( newDataType ) {
						case CPUndefinedDataType:
							switch( newSampleBytes ) {
								case sizeof(float):
									result = coreplot::convert_numeric_data_type<float, float>(self.data, [self byteOrder], newByteOrder);
									break;
								case sizeof(double):
									result = coreplot::convert_numeric_data_type<float, double>(self.data, [self byteOrder], newByteOrder);
									break;
							}
							break;
						case CPIntegerDataType:
							switch( newSampleBytes ) {
								case sizeof(float):
									result = coreplot::convert_numeric_data_type<float, float>(self.data, [self byteOrder], newByteOrder);
									break;
								case sizeof(double):
									result = coreplot::convert_numeric_data_type<float, double>(self.data, [self byteOrder], newByteOrder);
									break;
							}
							break;
						case CPUnsignedIntegerDataType:
							switch( newSampleBytes ) {
								case sizeof(float):
									result = coreplot::convert_numeric_data_type<float, float>(self.data, [self byteOrder], newByteOrder);
									break;
								case sizeof(double):
									result = coreplot::convert_numeric_data_type<float, double>(self.data, [self byteOrder], newByteOrder);
									break;
							}
							break;
						case CPFloatingPointDataType:
							switch( newSampleBytes ) {
								case sizeof(float):
									result = coreplot::convert_numeric_data_type<float, float>(self.data, [self byteOrder], newByteOrder);
									break;
								case sizeof(double):
									result = coreplot::convert_numeric_data_type<float, double>(self.data, [self byteOrder], newByteOrder);
									break;
							}
							break;
						case CPComplexFloatingPointDataType:
							switch( newSampleBytes ) {
								case sizeof(float):
									result = coreplot::convert_numeric_data_type<float, float>(self.data, [self byteOrder], newByteOrder);
									break;
								case sizeof(double):
									result = coreplot::convert_numeric_data_type<float, double>(self.data, [self byteOrder], newByteOrder);
									break;
							}
							break;
					}
					break;
				case sizeof(double):
					switch( newDataType ) {
						case CPUndefinedDataType:
							switch( newSampleBytes ) {
								case sizeof(float):
									result = coreplot::convert_numeric_data_type<double, float>(self.data, [self byteOrder], newByteOrder);
									break;
								case sizeof(double):
									result = coreplot::convert_numeric_data_type<double, double>(self.data, [self byteOrder], newByteOrder);
									break;
							}
							break;
						case CPIntegerDataType:
							switch( newSampleBytes ) {
								case sizeof(float):
									result = coreplot::convert_numeric_data_type<double, float>(self.data, [self byteOrder], newByteOrder);
									break;
								case sizeof(double):
									result = coreplot::convert_numeric_data_type<double, double>(self.data, [self byteOrder], newByteOrder);
									break;
							}
							break;
						case CPUnsignedIntegerDataType:
							switch( newSampleBytes ) {
								case sizeof(float):
									result = coreplot::convert_numeric_data_type<double, float>(self.data, [self byteOrder], newByteOrder);
									break;
								case sizeof(double):
									result = coreplot::convert_numeric_data_type<double, double>(self.data, [self byteOrder], newByteOrder);
									break;
							}
							break;
						case CPFloatingPointDataType:
							switch( newSampleBytes ) {
								case sizeof(float):
									result = coreplot::convert_numeric_data_type<double, float>(self.data, [self byteOrder], newByteOrder);
									break;
								case sizeof(double):
									result = coreplot::convert_numeric_data_type<double, double>(self.data, [self byteOrder], newByteOrder);
									break;
							}
							break;
						case CPComplexFloatingPointDataType:
							switch( newSampleBytes ) {
								case sizeof(float):
									result = coreplot::convert_numeric_data_type<double, float>(self.data, [self byteOrder], newByteOrder);
									break;
								case sizeof(double):
									result = coreplot::convert_numeric_data_type<double, double>(self.data, [self byteOrder], newByteOrder);
									break;
							}
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

#pragma mark -
#pragma mark Utilities

using namespace std;

/**	@brief Convert the type of elements in a numeric data array.
 *
 *	Each element in the input is converted (via C type-casting) to
 *	the desired output type. No warning is produced at run time if information
 *	will be lost by the type conversion (though a compiler warning is likely).
 *
 *	@param in NSData instance containing numeric data of uniform type.
 *	@param inByteOrder Endian order of the input data.
 *	@param outByteOrder Desired endian order of the output data.
 *	@tparam InType Type of the numeric data (e.g., <code>double</code>).
 *	@tparam OutType Type of the desired output data (e.g., <code>float</code>).
 *	@return NSData instance containing a copy of the input with all elements' type converted to OutType and endian order swapped if required to outByteOrder.
 **/
template<typename InType, typename OutType>
NSData *coreplot::convert_numeric_data_type(NSData *in, CFByteOrder inByteOrder=NSHostByteOrder(), CFByteOrder outByteOrder=NSHostByteOrder()) {
	auto_ptr<vector<OutType> > outPtr(convert_data_type<InType,OutType>(numeric_data_to_vector<InType>(in)));
	if ( inByteOrder != outByteOrder ) {
		swap_byte_order(outPtr->begin(), outPtr->end());
	}
	
	return vector_to_numeric_data(outPtr);
}

/** @brief Swap the byte order of each element in a numeric array.
 *
 *	Swaps the endian byte order of each element. Obviously, the
 *	input should contain numeric data of the same type.
 *
 *	@param in NSData instance containing numeric data of uniform type.
 *	@tparam T Type of the numeric data (e.g., <code>double</code>).
 *	@return NSData instance containing a copy of the input with all elements' endian order swapped.
 **/
template<typename T>
NSData *coreplot::swap_numeric_data_byte_order(NSData *in) {
	using namespace coreplot;
	return vector_to_numeric_data(swap_vector_byte_order(numeric_data_to_vector<T>(in)));
}

/** @brief Swap the byte order of each element in a numeric array in place.
 *
 *	Swaps the endian byte order of each element in place. Obviously, the
 *	input should contain numeric data of the same type.
 *
 *	@param in NSMutableData* containing numeric data of uniform type. The data will be swapped in-place.
 *	@tparam T Type of the numeric data (e.g., <code>double</code>).
 **/
template<typename T>
void coreplot::swap_numeric_data_byte_order(NSMutableData *in) {
	T *inPtr = (T*)[in mutableBytes];
	swap_byte_order(inPtr, inPtr+([in length]/sizeof(T)));
}

/** @brief Swap the byte order of each element in a vector.
 *	@param vptr A vector containing numeric data of uniform type.
 *	@tparam T Type of the numeric data (e.g., <code>double</code>).
 *	@return A vector containing a copy of the input with all elements' endian order swapped.
 **/
template<typename T>
auto_ptr<vector<T> > coreplot::swap_vector_byte_order(auto_ptr<vector<T> > vptr) {
	swap_byte_order(vptr->begin(), vptr->end());
	return vptr;
}

/** @brief Convert the data type of each element in a vector.
 *	@param in A vector containing numeric data of uniform type.
 *	@tparam T Type of the numeric data (e.g., <code>double</code>).
 *	@tparam U Type of the desired output data (e.g., <code>float</code>).
 *	@return A vector containing a copy of the input with all elements converted to the new type.
 **/
template<typename T, typename U>
auto_ptr<vector<U> > coreplot::convert_data_type(auto_ptr<vector<T> > in) {
	return auto_ptr<vector<U> >(new vector<U>(in->begin(), in->end()));
}

/** @brief Swap the byte order of each element in a vector.
 *	@param begin The input iterator.
 *	@param end The output iterator.
 *	@tparam InputOutputIterator Type of the iterators.
 **/
template<typename InputOutputIterator>
void coreplot::swap_byte_order(InputOutputIterator begin, 
							   InputOutputIterator end) {
	transform(begin, end, begin, pointer_to_unary_function<typename iterator_traits<InputOutputIterator>::value_type,
			  typename iterator_traits<InputOutputIterator>::value_type> (coreplot::__byteswap));
}

/** @brief Swap the byte order of a numeric value.
 *	@param v A numeric value.
 *	@tparam T Type of the numeric value (e.g., <code>double</code>).
 *	@return The numeric value with its byte order reversed.
 **/
template<typename T>
T coreplot::__byteswap(T v) {
	assert(sizeof(coreplot::byte)==1);
	coreplot::byte *vbytes = (coreplot::byte*)&v;
	reverse(vbytes, vbytes+sizeof(T));
	return v;
}

/** @brief Converts a data buffer containing numeric data of uniform type to a vector.
 *	@param d An NSData instance containing numeric data of uniform type.
 *	@tparam T Type of the numeric data (e.g., <code>double</code>).
 *	@return A vector containing the numeric data from the data buffer.
 **/
template<typename T>
auto_ptr<vector<T> > coreplot::numeric_data_to_vector(NSData *d) {
	auto_ptr<vector<T> > vptr(new vector<T>((T*)[d bytes], (T*)((T*)[d bytes]+([d length]/sizeof(T)))));
	
	return vptr;
}

/** @brief Converts a vector containing numeric data of uniform type to a data buffer.
 *	@param vptr A vector containing numeric data of uniform type.
 *	@tparam T Type of the numeric data (e.g., <code>double</code>).
 *	@return An NSData instance containing the numeric data from the vector.
 **/
template<typename T>
NSData *coreplot::vector_to_numeric_data(auto_ptr<vector<T> > vptr) {
	vector<T>& v = *vptr;
	NSData *result = [[NSData alloc] initWithBytes:&v[0] length:v.size()*sizeof(T)];
	
	return [result autorelease];
}
