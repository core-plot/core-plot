#import "CPTNumericDataType.h"
#import <Foundation/Foundation.h>

@interface CPTNumericData : NSObject<NSCopying, NSMutableCopying, NSCoding> {
    @protected
    NSData *data;
    CPTNumericDataType dataType;
    NSArray *shape; // array of dimension shapes (NSNumber<unsigned>)
    CPTDataOrder dataOrder;
}

/// @name Data Buffer
/// @{
@property (copy, readonly) NSData *data;
@property (readonly) const void *bytes;
@property (readonly) NSUInteger length;
/// @}

/// @name Data Format
/// @{
@property (assign, readonly) CPTNumericDataType dataType;
@property (readonly) CPTDataTypeFormat dataTypeFormat;
@property (readonly) size_t sampleBytes;
@property (readonly) CFByteOrder byteOrder;
/// @}

/// @name Dimensions
/// @{
@property (copy, readonly) NSArray *shape;
@property (readonly) NSUInteger numberOfDimensions;
@property (readonly) NSUInteger numberOfSamples;
@property (readonly) CPTDataOrder dataOrder;
/// @}

/// @name Factory Methods
/// @{
+(id)numericDataWithData:(NSData *)newData dataType:(CPTNumericDataType)newDataType shape:(NSArray *)shapeArray;
+(id)numericDataWithData:(NSData *)newData dataTypeString:(NSString *)newDataTypeString shape:(NSArray *)shapeArray;
+(id)numericDataWithArray:(NSArray *)newData dataType:(CPTNumericDataType)newDataType shape:(NSArray *)shapeArray;
+(id)numericDataWithArray:(NSArray *)newData dataTypeString:(NSString *)newDataTypeString shape:(NSArray *)shapeArray;

+(id)numericDataWithData:(NSData *)newData dataType:(CPTNumericDataType)newDataType shape:(NSArray *)shapeArray dataOrder:(CPTDataOrder)order;
+(id)numericDataWithData:(NSData *)newData dataTypeString:(NSString *)newDataTypeString shape:(NSArray *)shapeArray dataOrder:(CPTDataOrder)order;
+(id)numericDataWithArray:(NSArray *)newData dataType:(CPTNumericDataType)newDataType shape:(NSArray *)shapeArray dataOrder:(CPTDataOrder)order;
+(id)numericDataWithArray:(NSArray *)newData dataTypeString:(NSString *)newDataTypeString shape:(NSArray *)shapeArray dataOrder:(CPTDataOrder)order;
/// @}

/// @name Initialization
/// @{
-(id)initWithData:(NSData *)newData dataType:(CPTNumericDataType)newDataType shape:(NSArray *)shapeArray;
-(id)initWithData:(NSData *)newData dataTypeString:(NSString *)newDataTypeString shape:(NSArray *)shapeArray;
-(id)initWithArray:(NSArray *)newData dataType:(CPTNumericDataType)newDataType shape:(NSArray *)shapeArray;
-(id)initWithArray:(NSArray *)newData dataTypeString:(NSString *)newDataTypeString shape:(NSArray *)shapeArray;

-(id)initWithData:(NSData *)newData dataType:(CPTNumericDataType)newDataType shape:(NSArray *)shapeArray dataOrder:(CPTDataOrder)order;
-(id)initWithData:(NSData *)newData dataTypeString:(NSString *)newDataTypeString shape:(NSArray *)shapeArray dataOrder:(CPTDataOrder)order;
-(id)initWithArray:(NSArray *)newData dataType:(CPTNumericDataType)newDataType shape:(NSArray *)shapeArray dataOrder:(CPTDataOrder)order;
-(id)initWithArray:(NSArray *)newData dataTypeString:(NSString *)newDataTypeString shape:(NSArray *)shapeArray dataOrder:(CPTDataOrder)order;
/// @}

/// @name Samples
/// @{
-(NSUInteger)sampleIndex:(NSUInteger)idx, ...;
-(void *)samplePointer:(NSUInteger)sample;
-(void *)samplePointerAtIndex:(NSUInteger)idx, ...;
-(NSNumber *)sampleValue:(NSUInteger)sample;
-(NSNumber *)sampleValueAtIndex:(NSUInteger)idx, ...;
-(NSArray *)sampleArray;
/// @}

@end
