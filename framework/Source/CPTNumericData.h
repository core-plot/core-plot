#import "CPTNumericDataType.h"

@interface CPTNumericData : NSObject<NSCopying, NSMutableCopying, NSCoding>

/// @name Data Buffer
/// @{
@property (nonatomic, readonly, copy) NSData *data;
@property (nonatomic, readonly) const void *bytes;
@property (nonatomic, readonly) NSUInteger length;
/// @}

/// @name Data Format
/// @{
@property (nonatomic, readonly) CPTNumericDataType dataType;
@property (nonatomic, readonly) CPTDataTypeFormat dataTypeFormat;
@property (nonatomic, readonly) size_t sampleBytes;
@property (nonatomic, readonly) CFByteOrder byteOrder;
/// @}

/// @name Dimensions
/// @{
@property (nonatomic, readonly, copy) NSArray *shape;
@property (nonatomic, readonly) NSUInteger numberOfDimensions;
@property (nonatomic, readonly) NSUInteger numberOfSamples;
@property (nonatomic, readonly) CPTDataOrder dataOrder;
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
