#import "CPTNumericDataType.h"

@interface CPTNumericData : NSObject<NSCopying, NSMutableCopying, NSCoding>

/// @name Data Buffer
/// @{
@property (nonatomic, readonly, copy) NSData *data;
@property (nonatomic, readonly, assign) const void *bytes;
@property (nonatomic, readonly, assign) NSUInteger length;
/// @}

/// @name Data Format
/// @{
@property (nonatomic, readonly, assign) CPTNumericDataType dataType;
@property (nonatomic, readonly, assign) CPTDataTypeFormat dataTypeFormat;
@property (nonatomic, readonly, assign) size_t sampleBytes;
@property (nonatomic, readonly, assign) CFByteOrder byteOrder;
/// @}

/// @name Dimensions
/// @{
@property (nonatomic, readonly, copy) NSArray *shape;
@property (nonatomic, readonly, assign) NSUInteger numberOfDimensions;
@property (nonatomic, readonly, assign) NSUInteger numberOfSamples;
@property (nonatomic, readonly, assign) CPTDataOrder dataOrder;
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
