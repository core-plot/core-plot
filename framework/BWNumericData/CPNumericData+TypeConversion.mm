
#import "CPNumericData+TypeConversion.h"
#import "NumericDataTypeConversions.h"
#import "CPNumericDataType.h"
#import "GTMLogger.h"


@implementation CPNumericData (TypeConversion)

// :barry:20080430 Code generated with "NSData+TypeConversions_Generation.py"
- (CPNumericData*)dataByConvertingToType:(CPDataType)newDataType
                             sampleBytes:(NSUInteger)newSampleBytes
                               byteOrder:(CFByteOrder)newByteOrder {
    
    NSData *result = nil;
    
    if([self dataType] == newDataType &&
       [self sampleBytes] == newSampleBytes &&
       [self byteOrder] == newByteOrder) {
        return [[self retain] autorelease];
    }
    
    
    switch([self dataType]) {
        case BWUndefinedDataType:
            [NSException raise:NSInvalidArgumentException format:@"Unsupported data type (BWUndefinedDataType)"];
            break;
        case BWIntegerDataType:
            switch([self sampleBytes]) {
                case sizeof(char):
                    switch(newDataType) {
                        case BWUndefinedDataType:
                            switch(newSampleBytes) {
                                case sizeof(char):
                                    result = coreplot::convert_numeric_data_type<char,char>(self, [self byteOrder], newByteOrder);
                                    break;
                                case sizeof(short):
                                    result = coreplot::convert_numeric_data_type<char,short>(self, [self byteOrder], newByteOrder);
                                    break;
                                case sizeof(NSInteger):
                                    result = coreplot::convert_numeric_data_type<char,NSInteger>(self, [self byteOrder], newByteOrder);
                                    break;
                            }
                            break;
                        case BWIntegerDataType:
                            switch(newSampleBytes) {
                                case sizeof(char):
                                    result = coreplot::convert_numeric_data_type<char,char>(self, [self byteOrder], newByteOrder);
                                    break;
                                case sizeof(short):
                                    result = coreplot::convert_numeric_data_type<char,short>(self, [self byteOrder], newByteOrder);
                                    break;
                                case sizeof(NSInteger):
                                    result = coreplot::convert_numeric_data_type<char,NSInteger>(self, [self byteOrder], newByteOrder);
                                    break;
                            }
                            break;
                        case BWUnsignedIntegerDataType:
                            switch(newSampleBytes) {
                                case sizeof(char):
                                    result = coreplot::convert_numeric_data_type<char,char>(self, [self byteOrder], newByteOrder);
                                    break;
                                case sizeof(short):
                                    result = coreplot::convert_numeric_data_type<char,short>(self, [self byteOrder], newByteOrder);
                                    break;
                                case sizeof(NSInteger):
                                    result = coreplot::convert_numeric_data_type<char,NSInteger>(self, [self byteOrder], newByteOrder);
                                    break;
                            }
                            break;
                        case BWFloatingPointDataType:
                            switch(newSampleBytes) {
                                case sizeof(char):
                                    result = coreplot::convert_numeric_data_type<char,char>(self, [self byteOrder], newByteOrder);
                                    break;
                                case sizeof(short):
                                    result = coreplot::convert_numeric_data_type<char,short>(self, [self byteOrder], newByteOrder);
                                    break;
                                case sizeof(NSInteger):
                                    result = coreplot::convert_numeric_data_type<char,NSInteger>(self, [self byteOrder], newByteOrder);
                                    break;
                            }
                            break;
                        case BWComplexFloatingPointDataType:
                            switch(newSampleBytes) {
                                case sizeof(char):
                                    result = coreplot::convert_numeric_data_type<char,char>(self, [self byteOrder], newByteOrder);
                                    break;
                                case sizeof(short):
                                    result = coreplot::convert_numeric_data_type<char,short>(self, [self byteOrder], newByteOrder);
                                    break;
                                case sizeof(NSInteger):
                                    result = coreplot::convert_numeric_data_type<char,NSInteger>(self, [self byteOrder], newByteOrder);
                                    break;
                            }
                            break;
                    }
                    break;
                case sizeof(short):
                    switch(newDataType) {
                        case BWUndefinedDataType:
                            switch(newSampleBytes) {
                                case sizeof(char):
                                    result = coreplot::convert_numeric_data_type<short,char>(self, [self byteOrder], newByteOrder);
                                    break;
                                case sizeof(short):
                                    result = coreplot::convert_numeric_data_type<short,short>(self, [self byteOrder], newByteOrder);
                                    break;
                                case sizeof(NSInteger):
                                    result = coreplot::convert_numeric_data_type<short,NSInteger>(self, [self byteOrder], newByteOrder);
                                    break;
                            }
                            break;
                        case BWIntegerDataType:
                            switch(newSampleBytes) {
                                case sizeof(char):
                                    result = coreplot::convert_numeric_data_type<short,char>(self, [self byteOrder], newByteOrder);
                                    break;
                                case sizeof(short):
                                    result = coreplot::convert_numeric_data_type<short,short>(self, [self byteOrder], newByteOrder);
                                    break;
                                case sizeof(NSInteger):
                                    result = coreplot::convert_numeric_data_type<short,NSInteger>(self, [self byteOrder], newByteOrder);
                                    break;
                            }
                            break;
                        case BWUnsignedIntegerDataType:
                            switch(newSampleBytes) {
                                case sizeof(char):
                                    result = coreplot::convert_numeric_data_type<short,char>(self, [self byteOrder], newByteOrder);
                                    break;
                                case sizeof(short):
                                    result = coreplot::convert_numeric_data_type<short,short>(self, [self byteOrder], newByteOrder);
                                    break;
                                case sizeof(NSInteger):
                                    result = coreplot::convert_numeric_data_type<short,NSInteger>(self, [self byteOrder], newByteOrder);
                                    break;
                            }
                            break;
                        case BWFloatingPointDataType:
                            switch(newSampleBytes) {
                                case sizeof(char):
                                    result = coreplot::convert_numeric_data_type<short,char>(self, [self byteOrder], newByteOrder);
                                    break;
                                case sizeof(short):
                                    result = coreplot::convert_numeric_data_type<short,short>(self, [self byteOrder], newByteOrder);
                                    break;
                                case sizeof(NSInteger):
                                    result = coreplot::convert_numeric_data_type<short,NSInteger>(self, [self byteOrder], newByteOrder);
                                    break;
                            }
                            break;
                        case BWComplexFloatingPointDataType:
                            switch(newSampleBytes) {
                                case sizeof(char):
                                    result = coreplot::convert_numeric_data_type<short,char>(self, [self byteOrder], newByteOrder);
                                    break;
                                case sizeof(short):
                                    result = coreplot::convert_numeric_data_type<short,short>(self, [self byteOrder], newByteOrder);
                                    break;
                                case sizeof(NSInteger):
                                    result = coreplot::convert_numeric_data_type<short,NSInteger>(self, [self byteOrder], newByteOrder);
                                    break;
                            }
                            break;
                    }
                    break;
                case sizeof(NSInteger):
                    switch(newDataType) {
                        case BWUndefinedDataType:
                            switch(newSampleBytes) {
                                case sizeof(char):
                                    result = coreplot::convert_numeric_data_type<NSInteger,char>(self, [self byteOrder], newByteOrder);
                                    break;
                                case sizeof(short):
                                    result = coreplot::convert_numeric_data_type<NSInteger,short>(self, [self byteOrder], newByteOrder);
                                    break;
                                case sizeof(NSInteger):
                                    result = coreplot::convert_numeric_data_type<NSInteger,NSInteger>(self, [self byteOrder], newByteOrder);
                                    break;
                            }
                            break;
                        case BWIntegerDataType:
                            switch(newSampleBytes) {
                                case sizeof(char):
                                    result = coreplot::convert_numeric_data_type<NSInteger,char>(self, [self byteOrder], newByteOrder);
                                    break;
                                case sizeof(short):
                                    result = coreplot::convert_numeric_data_type<NSInteger,short>(self, [self byteOrder], newByteOrder);
                                    break;
                                case sizeof(NSInteger):
                                    result = coreplot::convert_numeric_data_type<NSInteger,NSInteger>(self, [self byteOrder], newByteOrder);
                                    break;
                            }
                            break;
                        case BWUnsignedIntegerDataType:
                            switch(newSampleBytes) {
                                case sizeof(char):
                                    result = coreplot::convert_numeric_data_type<NSInteger,char>(self, [self byteOrder], newByteOrder);
                                    break;
                                case sizeof(short):
                                    result = coreplot::convert_numeric_data_type<NSInteger,short>(self, [self byteOrder], newByteOrder);
                                    break;
                                case sizeof(NSInteger):
                                    result = coreplot::convert_numeric_data_type<NSInteger,NSInteger>(self, [self byteOrder], newByteOrder);
                                    break;
                            }
                            break;
                        case BWFloatingPointDataType:
                            switch(newSampleBytes) {
                                case sizeof(char):
                                    result = coreplot::convert_numeric_data_type<NSInteger,char>(self, [self byteOrder], newByteOrder);
                                    break;
                                case sizeof(short):
                                    result = coreplot::convert_numeric_data_type<NSInteger,short>(self, [self byteOrder], newByteOrder);
                                    break;
                                case sizeof(NSInteger):
                                    result = coreplot::convert_numeric_data_type<NSInteger,NSInteger>(self, [self byteOrder], newByteOrder);
                                    break;
                            }
                            break;
                        case BWComplexFloatingPointDataType:
                            switch(newSampleBytes) {
                                case sizeof(char):
                                    result = coreplot::convert_numeric_data_type<NSInteger,char>(self, [self byteOrder], newByteOrder);
                                    break;
                                case sizeof(short):
                                    result = coreplot::convert_numeric_data_type<NSInteger,short>(self, [self byteOrder], newByteOrder);
                                    break;
                                case sizeof(NSInteger):
                                    result = coreplot::convert_numeric_data_type<NSInteger,NSInteger>(self, [self byteOrder], newByteOrder);
                                    break;
                            }
                            break;
                    }
                    break;
            }
            break;
        case BWUnsignedIntegerDataType:
            switch([self sampleBytes]) {
                case sizeof(unsigned char):
                    switch(newDataType) {
                        case BWUndefinedDataType:
                            switch(newSampleBytes) {
                                case sizeof(unsigned char):
                                    result = coreplot::convert_numeric_data_type<unsigned char,unsigned char>(self, [self byteOrder], newByteOrder);
                                    break;
                                case sizeof(unsigned short):
                                    result = coreplot::convert_numeric_data_type<unsigned char,unsigned short>(self, [self byteOrder], newByteOrder);
                                    break;
                                case sizeof(NSUInteger):
                                    result = coreplot::convert_numeric_data_type<unsigned char,NSUInteger>(self, [self byteOrder], newByteOrder);
                                    break;
                            }
                            break;
                        case BWIntegerDataType:
                            switch(newSampleBytes) {
                                case sizeof(unsigned char):
                                    result = coreplot::convert_numeric_data_type<unsigned char,unsigned char>(self, [self byteOrder], newByteOrder);
                                    break;
                                case sizeof(unsigned short):
                                    result = coreplot::convert_numeric_data_type<unsigned char,unsigned short>(self, [self byteOrder], newByteOrder);
                                    break;
                                case sizeof(NSUInteger):
                                    result = coreplot::convert_numeric_data_type<unsigned char,NSUInteger>(self, [self byteOrder], newByteOrder);
                                    break;
                            }
                            break;
                        case BWUnsignedIntegerDataType:
                            switch(newSampleBytes) {
                                case sizeof(unsigned char):
                                    result = coreplot::convert_numeric_data_type<unsigned char,unsigned char>(self, [self byteOrder], newByteOrder);
                                    break;
                                case sizeof(unsigned short):
                                    result = coreplot::convert_numeric_data_type<unsigned char,unsigned short>(self, [self byteOrder], newByteOrder);
                                    break;
                                case sizeof(NSUInteger):
                                    result = coreplot::convert_numeric_data_type<unsigned char,NSUInteger>(self, [self byteOrder], newByteOrder);
                                    break;
                            }
                            break;
                        case BWFloatingPointDataType:
                            switch(newSampleBytes) {
                                case sizeof(unsigned char):
                                    result = coreplot::convert_numeric_data_type<unsigned char,unsigned char>(self, [self byteOrder], newByteOrder);
                                    break;
                                case sizeof(unsigned short):
                                    result = coreplot::convert_numeric_data_type<unsigned char,unsigned short>(self, [self byteOrder], newByteOrder);
                                    break;
                                case sizeof(NSUInteger):
                                    result = coreplot::convert_numeric_data_type<unsigned char,NSUInteger>(self, [self byteOrder], newByteOrder);
                                    break;
                            }
                            break;
                        case BWComplexFloatingPointDataType:
                            switch(newSampleBytes) {
                                case sizeof(unsigned char):
                                    result = coreplot::convert_numeric_data_type<unsigned char,unsigned char>(self, [self byteOrder], newByteOrder);
                                    break;
                                case sizeof(unsigned short):
                                    result = coreplot::convert_numeric_data_type<unsigned char,unsigned short>(self, [self byteOrder], newByteOrder);
                                    break;
                                case sizeof(NSUInteger):
                                    result = coreplot::convert_numeric_data_type<unsigned char,NSUInteger>(self, [self byteOrder], newByteOrder);
                                    break;
                            }
                            break;
                    }
                    break;
                case sizeof(unsigned short):
                    switch(newDataType) {
                        case BWUndefinedDataType:
                            switch(newSampleBytes) {
                                case sizeof(unsigned char):
                                    result = coreplot::convert_numeric_data_type<unsigned short,unsigned char>(self, [self byteOrder], newByteOrder);
                                    break;
                                case sizeof(unsigned short):
                                    result = coreplot::convert_numeric_data_type<unsigned short,unsigned short>(self, [self byteOrder], newByteOrder);
                                    break;
                                case sizeof(NSUInteger):
                                    result = coreplot::convert_numeric_data_type<unsigned short,NSUInteger>(self, [self byteOrder], newByteOrder);
                                    break;
                            }
                            break;
                        case BWIntegerDataType:
                            switch(newSampleBytes) {
                                case sizeof(unsigned char):
                                    result = coreplot::convert_numeric_data_type<unsigned short,unsigned char>(self, [self byteOrder], newByteOrder);
                                    break;
                                case sizeof(unsigned short):
                                    result = coreplot::convert_numeric_data_type<unsigned short,unsigned short>(self, [self byteOrder], newByteOrder);
                                    break;
                                case sizeof(NSUInteger):
                                    result = coreplot::convert_numeric_data_type<unsigned short,NSUInteger>(self, [self byteOrder], newByteOrder);
                                    break;
                            }
                            break;
                        case BWUnsignedIntegerDataType:
                            switch(newSampleBytes) {
                                case sizeof(unsigned char):
                                    result = coreplot::convert_numeric_data_type<unsigned short,unsigned char>(self, [self byteOrder], newByteOrder);
                                    break;
                                case sizeof(unsigned short):
                                    result = coreplot::convert_numeric_data_type<unsigned short,unsigned short>(self, [self byteOrder], newByteOrder);
                                    break;
                                case sizeof(NSUInteger):
                                    result = coreplot::convert_numeric_data_type<unsigned short,NSUInteger>(self, [self byteOrder], newByteOrder);
                                    break;
                            }
                            break;
                        case BWFloatingPointDataType:
                            switch(newSampleBytes) {
                                case sizeof(unsigned char):
                                    result = coreplot::convert_numeric_data_type<unsigned short,unsigned char>(self, [self byteOrder], newByteOrder);
                                    break;
                                case sizeof(unsigned short):
                                    result = coreplot::convert_numeric_data_type<unsigned short,unsigned short>(self, [self byteOrder], newByteOrder);
                                    break;
                                case sizeof(NSUInteger):
                                    result = coreplot::convert_numeric_data_type<unsigned short,NSUInteger>(self, [self byteOrder], newByteOrder);
                                    break;
                            }
                            break;
                        case BWComplexFloatingPointDataType:
                            switch(newSampleBytes) {
                                case sizeof(unsigned char):
                                    result = coreplot::convert_numeric_data_type<unsigned short,unsigned char>(self, [self byteOrder], newByteOrder);
                                    break;
                                case sizeof(unsigned short):
                                    result = coreplot::convert_numeric_data_type<unsigned short,unsigned short>(self, [self byteOrder], newByteOrder);
                                    break;
                                case sizeof(NSUInteger):
                                    result = coreplot::convert_numeric_data_type<unsigned short,NSUInteger>(self, [self byteOrder], newByteOrder);
                                    break;
                            }
                            break;
                    }
                    break;
                case sizeof(NSUInteger):
                    switch(newDataType) {
                        case BWUndefinedDataType:
                            switch(newSampleBytes) {
                                case sizeof(unsigned char):
                                    result = coreplot::convert_numeric_data_type<NSUInteger,unsigned char>(self, [self byteOrder], newByteOrder);
                                    break;
                                case sizeof(unsigned short):
                                    result = coreplot::convert_numeric_data_type<NSUInteger,unsigned short>(self, [self byteOrder], newByteOrder);
                                    break;
                                case sizeof(NSUInteger):
                                    result = coreplot::convert_numeric_data_type<NSUInteger,NSUInteger>(self, [self byteOrder], newByteOrder);
                                    break;
                            }
                            break;
                        case BWIntegerDataType:
                            switch(newSampleBytes) {
                                case sizeof(unsigned char):
                                    result = coreplot::convert_numeric_data_type<NSUInteger,unsigned char>(self, [self byteOrder], newByteOrder);
                                    break;
                                case sizeof(unsigned short):
                                    result = coreplot::convert_numeric_data_type<NSUInteger,unsigned short>(self, [self byteOrder], newByteOrder);
                                    break;
                                case sizeof(NSUInteger):
                                    result = coreplot::convert_numeric_data_type<NSUInteger,NSUInteger>(self, [self byteOrder], newByteOrder);
                                    break;
                            }
                            break;
                        case BWUnsignedIntegerDataType:
                            switch(newSampleBytes) {
                                case sizeof(unsigned char):
                                    result = coreplot::convert_numeric_data_type<NSUInteger,unsigned char>(self, [self byteOrder], newByteOrder);
                                    break;
                                case sizeof(unsigned short):
                                    result = coreplot::convert_numeric_data_type<NSUInteger,unsigned short>(self, [self byteOrder], newByteOrder);
                                    break;
                                case sizeof(NSUInteger):
                                    result = coreplot::convert_numeric_data_type<NSUInteger,NSUInteger>(self, [self byteOrder], newByteOrder);
                                    break;
                            }
                            break;
                        case BWFloatingPointDataType:
                            switch(newSampleBytes) {
                                case sizeof(unsigned char):
                                    result = coreplot::convert_numeric_data_type<NSUInteger,unsigned char>(self, [self byteOrder], newByteOrder);
                                    break;
                                case sizeof(unsigned short):
                                    result = coreplot::convert_numeric_data_type<NSUInteger,unsigned short>(self, [self byteOrder], newByteOrder);
                                    break;
                                case sizeof(NSUInteger):
                                    result = coreplot::convert_numeric_data_type<NSUInteger,NSUInteger>(self, [self byteOrder], newByteOrder);
                                    break;
                            }
                            break;
                        case BWComplexFloatingPointDataType:
                            switch(newSampleBytes) {
                                case sizeof(unsigned char):
                                    result = coreplot::convert_numeric_data_type<NSUInteger,unsigned char>(self, [self byteOrder], newByteOrder);
                                    break;
                                case sizeof(unsigned short):
                                    result = coreplot::convert_numeric_data_type<NSUInteger,unsigned short>(self, [self byteOrder], newByteOrder);
                                    break;
                                case sizeof(NSUInteger):
                                    result = coreplot::convert_numeric_data_type<NSUInteger,NSUInteger>(self, [self byteOrder], newByteOrder);
                                    break;
                            }
                            break;
                    }
                    break;
            }
            break;
        case BWFloatingPointDataType:
            switch([self sampleBytes]) {
                case sizeof(float):
                    switch(newDataType) {
                        case BWUndefinedDataType:
                            switch(newSampleBytes) {
                                case sizeof(float):
                                    result = coreplot::convert_numeric_data_type<float,float>(self, [self byteOrder], newByteOrder);
                                    break;
                                case sizeof(double):
                                    result = coreplot::convert_numeric_data_type<float,double>(self, [self byteOrder], newByteOrder);
                                    break;
                            }
                            break;
                        case BWIntegerDataType:
                            switch(newSampleBytes) {
                                case sizeof(float):
                                    result = coreplot::convert_numeric_data_type<float,float>(self, [self byteOrder], newByteOrder);
                                    break;
                                case sizeof(double):
                                    result = coreplot::convert_numeric_data_type<float,double>(self, [self byteOrder], newByteOrder);
                                    break;
                            }
                            break;
                        case BWUnsignedIntegerDataType:
                            switch(newSampleBytes) {
                                case sizeof(float):
                                    result = coreplot::convert_numeric_data_type<float,float>(self, [self byteOrder], newByteOrder);
                                    break;
                                case sizeof(double):
                                    result = coreplot::convert_numeric_data_type<float,double>(self, [self byteOrder], newByteOrder);
                                    break;
                            }
                            break;
                        case BWFloatingPointDataType:
                            switch(newSampleBytes) {
                                case sizeof(float):
                                    result = coreplot::convert_numeric_data_type<float,float>(self, [self byteOrder], newByteOrder);
                                    break;
                                case sizeof(double):
                                    result = coreplot::convert_numeric_data_type<float,double>(self, [self byteOrder], newByteOrder);
                                    break;
                            }
                            break;
                        case BWComplexFloatingPointDataType:
                            switch(newSampleBytes) {
                                case sizeof(float):
                                    result = coreplot::convert_numeric_data_type<float,float>(self, [self byteOrder], newByteOrder);
                                    break;
                                case sizeof(double):
                                    result = coreplot::convert_numeric_data_type<float,double>(self, [self byteOrder], newByteOrder);
                                    break;
                            }
                            break;
                    }
                    break;
                case sizeof(double):
                    switch(newDataType) {
                        case BWUndefinedDataType:
                            switch(newSampleBytes) {
                                case sizeof(float):
                                    result = coreplot::convert_numeric_data_type<double,float>(self, [self byteOrder], newByteOrder);
                                    break;
                                case sizeof(double):
                                    result = coreplot::convert_numeric_data_type<double,double>(self, [self byteOrder], newByteOrder);
                                    break;
                            }
                            break;
                        case BWIntegerDataType:
                            switch(newSampleBytes) {
                                case sizeof(float):
                                    result = coreplot::convert_numeric_data_type<double,float>(self, [self byteOrder], newByteOrder);
                                    break;
                                case sizeof(double):
                                    result = coreplot::convert_numeric_data_type<double,double>(self, [self byteOrder], newByteOrder);
                                    break;
                            }
                            break;
                        case BWUnsignedIntegerDataType:
                            switch(newSampleBytes) {
                                case sizeof(float):
                                    result = coreplot::convert_numeric_data_type<double,float>(self, [self byteOrder], newByteOrder);
                                    break;
                                case sizeof(double):
                                    result = coreplot::convert_numeric_data_type<double,double>(self, [self byteOrder], newByteOrder);
                                    break;
                            }
                            break;
                        case BWFloatingPointDataType:
                            switch(newSampleBytes) {
                                case sizeof(float):
                                    result = coreplot::convert_numeric_data_type<double,float>(self, [self byteOrder], newByteOrder);
                                    break;
                                case sizeof(double):
                                    result = coreplot::convert_numeric_data_type<double,double>(self, [self byteOrder], newByteOrder);
                                    break;
                            }
                            break;
                        case BWComplexFloatingPointDataType:
                            switch(newSampleBytes) {
                                case sizeof(float):
                                    result = coreplot::convert_numeric_data_type<double,float>(self, [self byteOrder], newByteOrder);
                                    break;
                                case sizeof(double):
                                    result = coreplot::convert_numeric_data_type<double,double>(self, [self byteOrder], newByteOrder);
                                    break;
                            }
                            break;
                    }
                    break;
            }
            break;
        case BWComplexFloatingPointDataType:
            [NSException raise:NSInvalidArgumentException format:@"Unsupported data type (BWComplexFloatingPointDataType)"];
            break;
    }
    
    if(result == nil) {
        GTMLoggerError(@"Unable to match new and existing data types for conversion.");
    }
    
    return [CPNumericData numericDataWithData:result
                                  dtype:[CPNumericDataType dataType:newDataType
                                                        sampleBytes:newSampleBytes
                                                          byteOrder:newByteOrder]
                                        shape:self.shape];
}

@end
