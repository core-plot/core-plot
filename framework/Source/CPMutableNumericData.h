#import <Foundation/Foundation.h>
#import "CPNumericDataType.h"

@interface CPMutableNumericData : NSObject <NSCopying, NSMutableCopying, NSCoding> {
@private
    NSMutableData *data;
    CPNumericDataType dataType;
    NSArray *shape; // array of dimension shapes (NSNumber<unsigned>)
}

/// @name Data Buffer
/// @{
@property (copy, readonly) NSMutableData *data;
@property (readonly) void *mutableBytes;
@property (readonly) NSUInteger length;
///	@}

/// @name Data Format
/// @{
@property (assign, readonly) CPNumericDataType dataType;
@property (readonly) CPDataTypeFormat dataTypeFormat;
@property (readonly) NSUInteger sampleBytes;
@property (readonly) CFByteOrder byteOrder;
///	@}

/// @name Dimensions
/// @{
@property (copy, readwrite) NSArray *shape;
@property (readonly) NSUInteger numberOfDimensions;
@property (readonly) NSUInteger numberOfSamples;
///	@}

/// @name Factory Methods
/// @{
+(CPMutableNumericData *)numericDataWithData:(NSData *)newData
									dataType:(CPNumericDataType)newDataType
									   shape:(NSArray *)shapeArray;
///	@}

/// @name Initialization
/// @{
-(id)initWithData:(NSData *)newData
		 dataType:(CPNumericDataType)newDataType
            shape:(NSArray *)shapeArray;

-(id)initWithData:(NSData *)newData
   dataTypeString:(NSString *)newDataTypeString
            shape:(NSArray *)shapeArray;
///	@}

/// @name Samples
/// @{
-(void *)samplePointer:(NSUInteger)sample;
-(NSNumber *)sampleValue:(NSUInteger)sample;
///	@}

@end
