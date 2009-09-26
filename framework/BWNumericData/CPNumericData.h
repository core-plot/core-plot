
#import <Cocoa/Cocoa.h>
#import "CPNumericDataType.h"

extern NSString * const CPNumericDataException;

@interface CPNumericData : NSData {
    NSData *data;
    CPNumericDataType dtype;
    NSArray *shape; // array of dimension shapes (NSNumber<unsigned>)
}

@property (assign,readonly) CPNumericDataType dtype;
@property (copy,readonly) NSArray *shape;
@property (readonly) NSUInteger ndims;
@property (readonly) NSUInteger nSamples; //number of samples of dtype
@property (readonly) CPDataTypeFormat dataType;
@property (readonly) NSUInteger sampleBytes;
@property (readonly) CFByteOrder byteOrder;


+(CPNumericData *)numericDataWithData:(NSData *)theData
                                dtype:(CPNumericDataType)_dtype
                                shape:(NSArray *)shapeArray;

/*!
 @method     
 @abstract   DESIGNATD INITIALIZER. Initialize a CPNumericData object from data, dtype, and shape
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

-(id)initWithData:(NSData *)theData
            dtype:(CPNumericDataType)_dtype
            shape:(NSArray *)shapeArray;

-(id)initWithData:(NSData *)theData
      dtypeString:(NSString *)dtypeString
            shape:(NSArray *)shapeArray;

-(NSUInteger)nSamples;
-(CPDataTypeFormat)dataType;
-(NSUInteger)sampleBytes;
-(CFByteOrder)byteOrder;


-(void *)samplePointer:(NSUInteger)sample;
-(NSNumber *)sampleValue:(NSUInteger)sample;
@end
