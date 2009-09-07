#import <Cocoa/Cocoa.h>

typedef enum {
    CPUndefinedDataType = 0,
    CPIntegerDataType,
    CPUnsignedIntegerDataType,
    CPFloatingPointDataType,
    CPComplexFloatingPointDataType
} CPDataType;

/*!
    @class
    @abstract    Class to represent the data type of a CPNumericData instance's data.
    @discussion  CPNumericDataType is analogous to NumPy's dtype.
*/

@interface CPNumericDataType : NSObject <NSCoding, NSCopying> {
    CPDataType dataType;
    NSUInteger sampleBytes;
    CFByteOrder byteOrder;
}

@property (assign,readonly) CPDataType dataType;
@property (assign,readonly) NSUInteger sampleBytes;
@property (assign,readonly) CFByteOrder byteOrder;
@property (readonly) NSString *dtypeString;

+(CPNumericDataType *)dataType:(CPDataType)theType
                  sampleBytes:(NSUInteger)theSampleBytes
                    byteOrder:(CFByteOrder)theByteOrder;

+(CPNumericDataType *)dataTypeWithDtypeString:(NSString *)dtypeString;

+(NSString *)dtypeStringForDataType:(CPDataType)dataType
                       sampleBytes:(NSUInteger)sampleBytes
                         byteOrder:(CFByteOrder)byteOrder;

+(CPDataType)dataTypeForDtypeString:(NSString *)dtypeString;
+(NSUInteger)sampleBytesForDtypeString:(NSString *)dtypeString;
+(CFByteOrder)byteOrderForDtypeString:(NSString *)dtypeString;

-(id)initWithDataType:(CPDataType)theType
          sampleBytes:(NSUInteger)theSampleBytes
            byteOrder:(CFByteOrder)theByteOrder;

-(BOOL)isEqualToDataType:(CPNumericDataType *)otherDType;

@end
