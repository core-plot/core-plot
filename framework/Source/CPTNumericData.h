#import "CPTNumericDataType.h"

@interface CPTNumericData : NSObject<NSCopying, NSMutableCopying, NSCoding> {
    @protected
    NSData *data;
    CPTNumericDataType dataType;
    NSArray *shape; // array of dimension shapes (NSNumber<unsigned>)
    CPTDataOrder dataOrder;
}

/// @name Data Buffer
/// @{
@property (readonly, copy) NSData *data;
@property (readonly, assign) const void *bytes;
@property (readonly, assign) NSUInteger length;
/// @}

/// @name Data Format
/// @{
@property (readonly, assign) CPTNumericDataType dataType;
@property (readonly, assign) CPTDataTypeFormat dataTypeFormat;
@property (readonly, assign) size_t sampleBytes;
@property (readonly, assign) CFByteOrder byteOrder;
/// @}

/// @name Dimensions
/// @{
@property (readonly, copy) NSArray *shape;
@property (readonly, assign) NSUInteger numberOfDimensions;
@property (readonly, assign) NSUInteger numberOfSamples;
@property (readonly, assign) CPTDataOrder dataOrder;
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
