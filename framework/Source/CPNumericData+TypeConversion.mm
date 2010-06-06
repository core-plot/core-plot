#import "CPNumericData+TypeConversion.h"
#import "CPNumericDataTypeConversions.h"
#import "CPNumericDataType.h"

@implementation CPNumericData(TypeConversion)

-(CPNumericData *)dataByConvertingToDataType:(CPNumericDataType)newDataType
{
    return [self dataByConvertingToType:newDataType.dataTypeFormat
                            sampleBytes:newDataType.sampleBytes
                              byteOrder:newDataType.byteOrder];
}

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
