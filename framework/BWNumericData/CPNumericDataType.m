
#import "CPNumericDataType.h"
#import "NSExceptionExtensions.h"
#import "GTMLogger.h"

@interface CPNumericDataType ()
@property (assign,readwrite) CPDataType dataType;
@property (assign,readwrite) NSUInteger sampleBytes;
@property (assign,readwrite) CFByteOrder byteOrder;
@end

@implementation CPNumericDataType
@synthesize dataType;
@synthesize sampleBytes;
@synthesize byteOrder;
@synthesize dtypeString;

+ (CPNumericDataType*)dataType:(CPDataType)theType
                   sampleBytes:(NSUInteger)theSampleBytes
                     byteOrder:(CFByteOrder)theByteOrder {
    return [[[self alloc] initWithDataType:theType
                               sampleBytes:theSampleBytes
                                 byteOrder:theByteOrder]
            autorelease];
}

+ (CPNumericDataType*)dataTypeWithDtypeString:(NSString*)dtypeString {
    return [self dataType:[self dataTypeForDtypeString:dtypeString]
              sampleBytes:[self sampleBytesForDtypeString:dtypeString]
                byteOrder:[self byteOrderForDtypeString:dtypeString]];
}
    
- (id)initWithDataType:(CPDataType)theType
           sampleBytes:(NSUInteger)theSampleBytes
             byteOrder:(CFByteOrder)theByteOrder {
    
    if( (self = [super init]) ) {
        self.dataType = theType;
        self.sampleBytes = theSampleBytes;
        self.byteOrder = theByteOrder;
    }
    
    return self;
}

+ (NSString*)dtypeStringForDataType:(CPDataType)dataType
                        sampleBytes:(NSUInteger)sampleBytes
                          byteOrder:(CFByteOrder)byteOrder {
    
    NSString *byteOrderString = nil;
    NSString *typeString = nil;
    
    switch (byteOrder) {
        case NS_LittleEndian:
            byteOrderString = @"<";
            break;
        case NS_BigEndian:
            byteOrderString = @">";
            break;
    }
    
    switch (dataType) {
        case BWFloatingPointDataType:
            typeString = @"f";
            break;
        case BWIntegerDataType:
            typeString = @"i";
            break;
        case BWUnsignedIntegerDataType:
            typeString = @"u";
            break;
        case BWComplexFloatingPointDataType:
            typeString = @"c";
            break;
        case BWUndefinedDataType:
            [NSException raiseGenericFormat:@"Unsupported data type"];
    }
    
    return [NSString stringWithFormat:@"%@%@%u", 
            byteOrderString, 
            typeString, 
            sampleBytes];
}

+ (CPDataType)dataTypeForDtypeString:(NSString*)dtypeString {
    CPDataType result;
    
    NSAssert([dtypeString length] >= 3, @"dtypeString is too short");
    switch ([[dtypeString lowercaseString] characterAtIndex:1]) {
        case 'f':
            result = BWFloatingPointDataType;
            break;
        case 'i':
            result = BWIntegerDataType;
            break;
        case 'u':
            result = BWUnsignedIntegerDataType;
            break;
        case 'c':
            result = BWComplexFloatingPointDataType;
            break;
        default:
            [NSException raiseGenericFormat:@"Unknown type in dtypestring"];
    }
    
    return result;
}

- (NSString*)dtypeString {
    return [[self class] dtypeStringForDataType:self.dataType
                                    sampleBytes:self.sampleBytes
                                      byteOrder:self.byteOrder];
}

+ (NSUInteger)sampleBytesForDtypeString:(NSString*)dtypeString {
    NSAssert([dtypeString length] >= 3, @"dtypeString is too short");
    return [[dtypeString substringFromIndex:2] intValue];
}

+ (CFByteOrder)byteOrderForDtypeString:(NSString*)dtypeString {
    NSAssert([dtypeString length] >= 3, @"dtypeString is too short");
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
            [NSException raiseGenericFormat:@"Unknown byte order in dtypestring"];
    }
    
    return result;
}

- (BOOL)isEqualToDataType:(CPNumericDataType*)otherDType {
    
    return (self.dataType == otherDType.dataType &&
            self.sampleBytes == otherDType.sampleBytes &&
            self.byteOrder == otherDType.byteOrder);
}

- (NSString*)description {
    return [NSString stringWithFormat:@"dtype(%@)", self.dtypeString];
}

#pragma mark NSCopying
- (id)copyWithZone:(NSZone *)zone {
    return [[[self class] allocWithZone:zone] initWithDataType:self.dataType
                                                   sampleBytes:self.sampleBytes
                                                     byteOrder:self.byteOrder];
}

#pragma mark NSCoding
- (void)encodeWithCoder:(NSCoder *)encoder {
    //[super encodeWithCoder:encoder];
    
    if([encoder allowsKeyedCoding]) {
        [encoder encodeObject:self.dtypeString forKey:@"dtypeString"];
    } else {
        [encoder encodeObject:self.dtypeString];
    }
}

- (id)initWithCoder:(NSCoder *)decoder {    
    self = [super init]; //initWithCoder:decoder];
    NSString *dtypeString;
    
    if([decoder allowsKeyedCoding]) {
        dtypeString = [decoder decodeObjectForKey:@"dtypeString"];
    } else {
        dtypeString = [decoder decodeObject];
    }
    
    self.dataType = [[self class] dataTypeForDtypeString:dtypeString];
    self.sampleBytes = [[self class] sampleBytesForDtypeString:dtypeString];
    self.byteOrder = [[self class] byteOrderForDtypeString:dtypeString];
    
    return self;
}
@end
