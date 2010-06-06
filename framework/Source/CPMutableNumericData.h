#import <Foundation/Foundation.h>
#import "CPNumericDataType.h"

extern NSString * const CPNumericDataException;

@interface CPMutableNumericData : NSObject <NSCopying, NSMutableCopying, NSCoding> {
@private
    NSMutableData *data;
    CPNumericDataType dataType;
    NSArray *shape; // array of dimension shapes (NSNumber<unsigned>)
}

@property (copy, readonly) NSMutableData *data;
@property (assign, readonly) CPNumericDataType dataType;
@property (copy, readwrite) NSArray *shape;

@property (readonly) void *mutableBytes;
@property (readonly) NSUInteger length;

@property (readonly) NSUInteger numberOfDimensions;
@property (readonly) NSUInteger numberOfSamples; //number of samples of dataType

@property (readonly) CPDataTypeFormat dataTypeFormat;
@property (readonly) NSUInteger sampleBytes;
@property (readonly) CFByteOrder byteOrder;

+(CPMutableNumericData *)numericDataWithData:(NSData *)newData
									dataType:(CPNumericDataType)newDataType
									   shape:(NSArray *)shapeArray;

-(id)initWithData:(NSData *)newData
		 dataType:(CPNumericDataType)newDataType
            shape:(NSArray *)shapeArray;

-(id)initWithData:(NSData *)newData
   dataTypeString:(NSString *)newDataTypeString
            shape:(NSArray *)shapeArray;

-(void *)samplePointer:(NSUInteger)sample;
-(NSNumber *)sampleValue:(NSUInteger)sample;

@end
