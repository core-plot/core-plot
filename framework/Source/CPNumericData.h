#import <Foundation/Foundation.h>
#import "CPNumericDataType.h"

@interface CPNumericData : NSObject <NSCopying, NSMutableCopying, NSCoding> {
@protected
    NSData *data;
    CPNumericDataType dataType;
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
@property (assign, readonly) CPNumericDataType dataType;
@property (readonly) CPDataTypeFormat dataTypeFormat;
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
+(CPNumericData *)numericDataWithData:(NSData *)newData
							 dataType:(CPNumericDataType)newDataType
                                shape:(NSArray *)shapeArray;

+(CPNumericData *)numericDataWithData:(NSData *)newData
					   dataTypeString:(NSString *)newDataTypeString
                                shape:(NSArray *)shapeArray;

+(CPNumericData *)numericDataWithArray:(NSArray *)newData
							  dataType:(CPNumericDataType)newDataType
								 shape:(NSArray *)shapeArray;

+(CPNumericData *)numericDataWithArray:(NSArray *)newData
						dataTypeString:(NSString *)newDataTypeString
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

-(id)initWithArray:(NSArray *)newData
		  dataType:(CPNumericDataType)newDataType
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
