#import <Cocoa/Cocoa.h>
#import "CPNumericDataType.h"

extern NSString * const CPNumericDataException;

@interface CPNumericData : NSData {
@private
    NSData *data;
    CPNumericDataType dataType;
    NSArray *shape; // array of dimension shapes (NSNumber<unsigned>)
}

@property (assign, readonly) CPNumericDataType dataType;
@property (copy, readonly) NSArray *shape;
@property (readonly) NSUInteger numberOfDimensions;
@property (readonly) NSUInteger numberOfSamples; //number of samples of dataType
@property (readonly) CPDataTypeFormat dataTypeFormat;
@property (readonly) NSUInteger sampleBytes;
@property (readonly) CFByteOrder byteOrder;

+(CPNumericData *)numericDataWithData:(NSData *)newData
							 dataType:(CPNumericDataType)newDataType
                                shape:(NSArray *)shapeArray;

/*!
 @method     
 @abstract   DESIGNATED INITIALIZER. Initialize a CPNumericData object from data, dtype, and shape
 @discussion A CPNumericData instance can be initialized from a numpy array (in python)::
 numericData = CPNumericData.alloc().initWithData_dtypeString_shape_(numpy_array,
 numpy_array.dtype.str,
 numpy_array.shape)
 
 @throws NSException if shape is non-nil and the product of the shape elements does not match
 the data size (length/sampleBytes(dtype)).
 @param theData NSData* (copied)
 @param dtype dtype (retained)
 @param shapeArray data shape (ala numpy) (copied). may be nil for 1-D data.
 */

-(id)initWithData:(NSData *)newData
		 dataType:(CPNumericDataType)newDataType
            shape:(NSArray *)shapeArray;

-(id)initWithData:(NSData *)theData
   dataTypeString:(NSString *)newDataTypeString
            shape:(NSArray *)shapeArray;

-(void *)samplePointer:(NSUInteger)sample;
-(NSNumber *)sampleValue:(NSUInteger)sample;

@end
