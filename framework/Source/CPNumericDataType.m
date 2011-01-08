#import "CPNumericDataType.h"
#import "NSExceptionExtensions.h"
#import "complex.h"

static CPDataTypeFormat DataTypeForDataTypeString(NSString *dataTypeString);
static size_t SampleBytesForDataTypeString(NSString *dataTypeString);
static CFByteOrder ByteOrderForDataTypeString(NSString *dataTypeString);

#pragma mark -
#pragma mark Data type utilities

/**	@brief Initializes a CPNumericDataType struct with the given parameter values.
 *	@param format The data type format.
 *	@param sampleBytes The number of bytes in each sample.
 *	@param byteOrder The byte order used to store the data samples.
 *	@return The initialized CPNumericDataType struct.
 **/
CPNumericDataType CPDataType(CPDataTypeFormat format, size_t sampleBytes, CFByteOrder byteOrder)
{
    CPNumericDataType result;
    
    result.dataTypeFormat = format;
    result.sampleBytes = sampleBytes;
    result.byteOrder = byteOrder;
    
    return result;
}

/**	@brief Initializes a CPNumericDataType struct from a data type string.
 *	@param dataTypeString The data type string.
 *	@return The initialized CPNumericDataType struct.
 **/
CPNumericDataType CPDataTypeWithDataTypeString(NSString *dataTypeString)
{
    CPNumericDataType type;
    
    type.dataTypeFormat = DataTypeForDataTypeString(dataTypeString);
    
    type.sampleBytes = SampleBytesForDataTypeString(dataTypeString);
    type.byteOrder = ByteOrderForDataTypeString(dataTypeString);
    
    return type;
}

/**	@brief Generates a string representation of the given data type.
 *	@param dataType The data type.
 *	@return The string representation of the given data type.
 **/
NSString *CPDataTypeStringFromDataType(CPNumericDataType dataType)
{
    NSString *byteOrderString = nil;
    NSString *typeString = nil;
    
    switch ( dataType.byteOrder ) {
        case CFByteOrderLittleEndian:
            byteOrderString = @"<";
            break;
        case CFByteOrderBigEndian:
            byteOrderString = @">";
            break;
    }
    
    switch ( dataType.dataTypeFormat ) {
        case CPFloatingPointDataType:
            typeString = @"f";
            break;
        case CPIntegerDataType:
            typeString = @"i";
            break;
        case CPUnsignedIntegerDataType:
            typeString = @"u";
            break;
        case CPComplexFloatingPointDataType:
            typeString = @"c";
            break;
		case CPDecimalDataType:
			typeString = @"d";
			break;

        case CPUndefinedDataType:
            [NSException raise:NSGenericException format:@"Unsupported data type"];
    }
    
    return [NSString stringWithFormat:@"%@%@%lu", 
            byteOrderString, 
            typeString, 
            dataType.sampleBytes];
}

/**	@brief Validates a data type format.
 *	@param format The data type format.
 *	@return Returns YES if the format is supported by CPNumericData, NO otherwise.
 **/
BOOL CPDataTypeIsSupported(CPNumericDataType format)
{
	BOOL result = YES;
	
	switch ( format.byteOrder ) {
		case CFByteOrderUnknown:
		case CFByteOrderLittleEndian:
		case CFByteOrderBigEndian:
			// valid byte order--continue checking
			break;
		default:
			// invalid byteorder
			result = NO;
			break;
	}
	
	if ( result ) {
		switch ( format.dataTypeFormat ) {
			case CPUndefinedDataType:
				// valid; any sampleBytes is ok
				break;
			case CPIntegerDataType:
				switch ( format.sampleBytes ) {
					case sizeof(int8_t):
					case sizeof(int16_t):
					case sizeof(int32_t):
					case sizeof(int64_t):
						// valid
						break;
					default:
						result = NO;
						break;
				}
				break;
			case CPUnsignedIntegerDataType:
				switch ( format.sampleBytes ) {
					case sizeof(uint8_t):
					case sizeof(uint16_t):
					case sizeof(uint32_t):
					case sizeof(uint64_t):
						// valid
						break;
					default:
						result = NO;
						break;
				}
				break;
			case CPFloatingPointDataType:
				switch ( format.sampleBytes ) {
					case sizeof(float):
					case sizeof(double):
						// valid
						break;
					default:
						result = NO;
						break;
				}
				break;
			case CPComplexFloatingPointDataType:
				switch ( format.sampleBytes ) {
					case sizeof(float complex):
					case sizeof(double complex):
						// only the native byte order is supported
						result = (format.byteOrder == CFByteOrderGetCurrent());
						break;
					default:
						result = NO;
						break;
				}
				break;
			case CPDecimalDataType:
				// only the native byte order is supported
				result = (format.sampleBytes == sizeof(NSDecimal)) && (format.byteOrder == CFByteOrderGetCurrent());
				break;
			default:
				// unrecognized data type format
				result = NO;
				break;
		}
	}
	
	return result;
}

/**	@brief Compares two data types for equality.
 *	@param dataType1 The first data type format.
 *	@param dataType2 The second data type format.
 *	@return Returns YES if the two data types have the same format, size, and byte order.
 **/
BOOL CPDataTypeEqualToDataType(CPNumericDataType dataType1, CPNumericDataType dataType2)
{
	return (dataType1.dataTypeFormat == dataType2.dataTypeFormat) && 
			  (dataType1.sampleBytes == dataType2.sampleBytes) &&
				(dataType1.byteOrder == dataType2.byteOrder);
}

#pragma mark -
#pragma mark Private functions

CPDataTypeFormat DataTypeForDataTypeString(NSString *dataTypeString)
{
    CPDataTypeFormat result;
    
    NSCAssert([dataTypeString length] >= 3, @"dataTypeString is too short");
    
    switch ( [[dataTypeString lowercaseString] characterAtIndex:1] ) {
        case 'f':
            result = CPFloatingPointDataType;
            break;
        case 'i':
            result = CPIntegerDataType;
            break;
        case 'u':
            result = CPUnsignedIntegerDataType;
            break;
        case 'c':
            result = CPComplexFloatingPointDataType;
            break;
        case 'd':
            result = CPDecimalDataType;
            break;
        default:
            [NSException raise:NSGenericException 
                        format:@"Unknown type in dataTypeString"];
    }
    
    return result;
}

size_t SampleBytesForDataTypeString(NSString *dataTypeString)
{
    NSCAssert([dataTypeString length] >= 3, @"dataTypeString is too short");
    NSInteger result = [[dataTypeString substringFromIndex:2] integerValue];
    NSCAssert(result > 0, @"sample bytes is negative.");
    
    return (size_t)result;
}

CFByteOrder ByteOrderForDataTypeString(NSString *dataTypeString)
{
    NSCAssert([dataTypeString length] >= 3, @"dataTypeString is too short");
    CFByteOrder result;
    
    switch ( [[dataTypeString lowercaseString] characterAtIndex:0] ) {
        case '=':
            result = CFByteOrderGetCurrent();
            break;
        case '<':
            result = CFByteOrderLittleEndian;
            break;
        case '>':
            result = CFByteOrderBigEndian;
            break;
        default:
            [NSException raise:NSGenericException
                        format:@"Unknown byte order in dataTypeString"];
    }
    
    return result;
}
