#import <Foundation/Foundation.h>
#import "CPTNumericDataType.h"

@interface CPTNumericData : NSObject <NSCopying, NSMutableCopying, NSCoding> {
@protected
    NSData *data;
    CPTNumericDataType dataType;
    NSArray *shape; // array of dimension shapes (NSNumber<unsigned>)
}

/// @name Data Buffer
/// @{
@property (copy, readonly) NSData *data;
@property (readonly) const void *bytes;
@property (readonly) NSUInteger length;
///	@}

/// @name Data Format
/// @{
@property (assign, readonly) CPTNumericDataType dataType;
@property (readonly) CPTDataTypeFormat dataTypeFormat;
@property (readonly) size_t sampleBytes;
@property (readonly) CFByteOrder byteOrder;
///	@}

/// @name Dimensions
/// @{
@property (copy, readonly) NSArray *shape;
@property (readonly) NSUInteger numberOfDimensions;
@property (readonly) NSUInteger numberOfSamples;
///	@}

/// @name Factory Methods
/// @{
+(CPTNumericData *)numericDataWithData:(NSData *)newData
							 dataType:(CPTNumericDataType)newDataType
                                shape:(NSArray *)shapeArray;

+(CPTNumericData *)numericDataWithData:(NSData *)newData
					   dataTypeString:(NSString *)newDataTypeString
                                shape:(NSArray *)shapeArray;

+(CPTNumericData *)numericDataWithArray:(NSArray *)newData
							  dataType:(CPTNumericDataType)newDataType
								 shape:(NSArray *)shapeArray;

+(CPTNumericData *)numericDataWithArray:(NSArray *)newData
						dataTypeString:(NSString *)newDataTypeString
								 shape:(NSArray *)shapeArray;
///	@}

/// @name Initialization
/// @{
-(id)initWithData:(NSData *)newData
		 dataType:(CPTNumericDataType)newDataType
            shape:(NSArray *)shapeArray;

-(id)initWithData:(NSData *)newData
   dataTypeString:(NSString *)newDataTypeString
            shape:(NSArray *)shapeArray;

-(id)initWithArray:(NSArray *)newData
		  dataType:(CPTNumericDataType)newDataType
			 shape:(NSArray *)shapeArray;

-(id)initWithArray:(NSArray *)newData
	dataTypeString:(NSString *)newDataTypeString
			 shape:(NSArray *)shapeArray;
///	@}

/// @name Samples
/// @{
-(void *)samplePointer:(NSUInteger)sample;
-(NSNumber *)sampleValue:(NSUInteger)sample;
-(NSArray *)sampleArray;
///	@}

@end
