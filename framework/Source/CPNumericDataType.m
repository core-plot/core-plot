#import "CPNumericDataType.h"
#import "NSExceptionExtensions.h"

static CPDataTypeFormat DataTypeForDataTypeString(NSString *dataTypeString);
static NSUInteger SampleBytesForDataTypeString(NSString *dataTypeString);
static CFByteOrder ByteOrderForDataTypeString(NSString *dataTypeString);

#pragma mark -
#pragma mark Data type utilities

/**	@brief Initializes a CPNumericDataType struct with the given parameter values.
 *	@param format The data type format.
 *	@param sampleBytes The number of bytes in each sample.
 *	@param byteOrder The byte order used to store the data samples.
 *	@return The initialized CPNumericDataType struct.
 **/
CPNumericDataType CPDataType(CPDataTypeFormat format, NSUInteger sampleBytes, CFByteOrder byteOrder)
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
        case NS_LittleEndian:
            byteOrderString = @"<";
            break;
        case NS_BigEndian:
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
        case CPUndefinedDataType:
            [NSException raise:NSGenericException format:@"Unsupported data type"];
    }
    
    return [NSString stringWithFormat:@"%@%@%u", 
            byteOrderString, 
            typeString, 
            dataType.sampleBytes];
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
        default:
            [NSException raise:NSGenericException 
                        format:@"Unknown type in dataTypeString"];
    }
    
    return result;
}

NSUInteger SampleBytesForDataTypeString(NSString *dataTypeString)
{
    NSCAssert([dataTypeString length] >= 3, @"dataTypeString is too short");
    NSInteger result = [[dataTypeString substringFromIndex:2] integerValue];
    NSCAssert(result > 0, @"sample bytes is negative.");
    
    return result;
}

CFByteOrder ByteOrderForDataTypeString(NSString *dataTypeString)
{
    NSCAssert([dataTypeString length] >= 3, @"dataTypeString is too short");
    CFByteOrder result;
    
    switch ( [[dataTypeString lowercaseString] characterAtIndex:0] ) {
        case '=':
            result = NSHostByteOrder();
            break;
        case '<':
            result = NS_LittleEndian;
            break;
        case '>':
            result = NS_BigEndian;
            break;
        default:
            [NSException raise:NSGenericException
                        format:@"Unknown byte order in dataTypeString"];
    }
    
    return result;
}
