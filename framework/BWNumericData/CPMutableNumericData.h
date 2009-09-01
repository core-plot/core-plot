
#import <Cocoa/Cocoa.h>
#import "CPNumericDataType.h"

@interface CPMutableNumericData : NSMutableData {
    NSMutableData *data;
    CPNumericDataType *dtype;
    NSArray *shape; //array of dimension shapes (NSNumber<unsigned>)
}

@property (retain,readonly) CPNumericDataType *dtype;
@property (copy,readonly) NSArray* shape;
@property (readonly) NSUInteger ndims;

/*!
 @method     
 @abstract   Initialize a CPNumericData object from data, dtype, and shape.
 @discussion Data retained (not copied)
 @throws NSException if shape is non-nil and the product of the shape elements does not match
 the data size (length/sampleBytes(dtype)).
 */

- (id)initWithData:(NSMutableData*)_data
             dtype:(CPNumericDataType*)_dtype
             shape:(NSArray*)_shape;
@end
