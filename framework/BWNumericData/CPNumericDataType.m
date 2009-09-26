
#import "CPNumericDataType.h"
#import "NSExceptionExtensions.h"
#import "GTMLogger.h"

static CPDataTypeFormat DataTypeForDtypeString(NSString *dtypeString);
static NSInteger SampleBytesForDtypeString(NSString* dtypeString);
static CFByteOrder ByteOrderForDtypeString(NSString* dtypeString);


CPNumericDataType CPDataType(CPDataTypeFormat format, NSInteger sampleBytes, CFByteOrder byteOrder)
{
    CPNumericDataType result;
    
    result.dataType = format;
    result.sampleBytes = sampleBytes;
    result.byteOrder = byteOrder;
    
    return result;
}


CPNumericDataType CPDataTypeWithDataTypeString(NSString* dtypeString)
{
    CPNumericDataType type;
    
    type.dataType = DataTypeForDtypeString(dtypeString);
    
    type.sampleBytes = SampleBytesForDtypeString(dtypeString);
    type.byteOrder = ByteOrderForDtypeString(dtypeString);
    
    return type;
}


NSString *CPDataTypeStringFromDataType(CPNumericDataType dtype)
{
    NSString *byteOrderString = nil;
    NSString *typeString = nil;
    
    switch (dtype.byteOrder) {
        case NS_LittleEndian:
            byteOrderString = @"<";
            break;
        case NS_BigEndian:
            byteOrderString = @">";
            break;
    }
    
    switch (dtype.dataType) {
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
            dtype.sampleBytes];
}


CPDataTypeFormat DataTypeForDtypeString(NSString *dtypeString)
{
    CPDataTypeFormat result;
    
    NSCAssert([dtypeString length] >= 3, @"dtypeString is too short");
    
    switch ([[dtypeString lowercaseString] characterAtIndex:1]) {
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
                        format:@"Unknown type in dtypestring"];
    }
    
    return result;
}


NSInteger SampleBytesForDtypeString(NSString* dtypeString)
{
    NSCAssert([dtypeString length] >= 3, @"dtypeString is too short");
    NSInteger result = [[dtypeString substringFromIndex:2] integerValue];
    NSCAssert(result > 0, @"sample bytes is negative.");
    
    return result;
}

CFByteOrder ByteOrderForDtypeString(NSString * dtypeString)
{
    NSCAssert([dtypeString length] >= 3, @"dtypeString is too short");
    CFByteOrder result;
    
    switch ([[dtypeString lowercaseString] characterAtIndex:0]) {
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
                        format:@"Unknown byte order in dtypestring"];
    }
    
    return result;
}