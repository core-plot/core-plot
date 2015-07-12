#import "CPTDefinitions.h"
#import "CPTNumericDataType.h"

@interface CPTNumericData : NSObject<NSCopying, NSMutableCopying, NSCoding>

/// @name Data Buffer
/// @{
@property (nonatomic, readonly, copy, nonnull) NSData *data;
@property (nonatomic, readonly, nonnull) const void *bytes;
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
@property (nonatomic, readonly, copy, nonnull) CPTNumberArray shape;
@property (nonatomic, readonly) NSUInteger numberOfDimensions;
@property (nonatomic, readonly) NSUInteger numberOfSamples;
@property (nonatomic, readonly) CPTDataOrder dataOrder;
/// @}

/// @name Factory Methods
/// @{
+(nonnull instancetype)numericDataWithData:(nonnull NSData *)newData dataType:(CPTNumericDataType)newDataType shape:(nullable CPTNumberArray)shapeArray;
+(nonnull instancetype)numericDataWithData:(nonnull NSData *)newData dataTypeString:(nonnull NSString *)newDataTypeString shape:(nullable CPTNumberArray)shapeArray;
+(nonnull instancetype)numericDataWithArray:(nonnull CPTNumberArray)newData dataType:(CPTNumericDataType)newDataType shape:(nullable CPTNumberArray)shapeArray;
+(nonnull instancetype)numericDataWithArray:(nonnull CPTNumberArray)newData dataTypeString:(nonnull NSString *)newDataTypeString shape:(nullable CPTNumberArray)shapeArray;

+(nonnull instancetype)numericDataWithData:(nonnull NSData *)newData dataType:(CPTNumericDataType)newDataType shape:(nullable CPTNumberArray)shapeArray dataOrder:(CPTDataOrder)order;
+(nonnull instancetype)numericDataWithData:(nonnull NSData *)newData dataTypeString:(nonnull NSString *)newDataTypeString shape:(nullable CPTNumberArray)shapeArray dataOrder:(CPTDataOrder)order;
+(nonnull instancetype)numericDataWithArray:(nonnull CPTNumberArray)newData dataType:(CPTNumericDataType)newDataType shape:(nullable CPTNumberArray)shapeArray dataOrder:(CPTDataOrder)order;
+(nonnull instancetype)numericDataWithArray:(nonnull CPTNumberArray)newData dataTypeString:(nonnull NSString *)newDataTypeString shape:(nullable CPTNumberArray)shapeArray dataOrder:(CPTDataOrder)order;
/// @}

/// @name Initialization
/// @{
-(nonnull instancetype)initWithData:(nonnull NSData *)newData dataType:(CPTNumericDataType)newDataType shape:(nullable CPTNumberArray)shapeArray;
-(nonnull instancetype)initWithData:(nonnull NSData *)newData dataTypeString:(nonnull NSString *)newDataTypeString shape:(nullable CPTNumberArray)shapeArray;
-(nonnull instancetype)initWithArray:(nonnull CPTNumberArray)newData dataType:(CPTNumericDataType)newDataType shape:(nullable CPTNumberArray)shapeArray;
-(nonnull instancetype)initWithArray:(nonnull CPTNumberArray)newData dataTypeString:(nonnull NSString *)newDataTypeString shape:(nullable CPTNumberArray)shapeArray;

-(nonnull instancetype)initWithData:(nonnull NSData *)newData dataType:(CPTNumericDataType)newDataType shape:(nullable CPTNumberArray)shapeArray dataOrder:(CPTDataOrder)order NS_DESIGNATED_INITIALIZER;
-(nonnull instancetype)initWithData:(nonnull NSData *)newData dataTypeString:(nonnull NSString *)newDataTypeString shape:(nullable CPTNumberArray)shapeArray dataOrder:(CPTDataOrder)order;
-(nonnull instancetype)initWithArray:(nonnull CPTNumberArray)newData dataType:(CPTNumericDataType)newDataType shape:(nullable CPTNumberArray)shapeArray dataOrder:(CPTDataOrder)order;
-(nonnull instancetype)initWithArray:(nonnull CPTNumberArray)newData dataTypeString:(nonnull NSString *)newDataTypeString shape:(nullable CPTNumberArray)shapeArray dataOrder:(CPTDataOrder)order;

-(nonnull instancetype)initWithCoder:(nonnull NSCoder *)coder NS_DESIGNATED_INITIALIZER;
/// @}

/// @name Samples
/// @{
-(NSUInteger)sampleIndex:(NSUInteger)idx, ...;
-(nullable const void *)samplePointer:(NSUInteger)sample;
-(nullable const void *)samplePointerAtIndex:(NSUInteger)idx, ...;
-(nullable NSNumber *)sampleValue:(NSUInteger)sample;
-(nullable NSNumber *)sampleValueAtIndex:(NSUInteger)idx, ...;
-(nonnull CPTNumberArray)sampleArray;
/// @}

@end
