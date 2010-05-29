#import <Cocoa/Cocoa.h>
#import "CPNumericDataType.h"

@interface CPMutableNumericData : NSMutableData {
@private
    NSMutableData *data;
    CPNumericDataType dataType;
    NSArray *shape; //array of dimension shapes (NSNumber<unsigned>)
}

@property (assign, readonly) CPNumericDataType dataType;
@property (copy, readonly) NSArray *shape;
@property (readonly) NSUInteger numberOfDimensions;

/*!
 @method     
 @abstract   Initialize a CPNumericData object from data, dtype, and shape.
 @discussion Data retained (not copied)
 @throws NSException if shape is non-nil and the product of the shape elements does not match
 the data size (length/sampleBytes(dtype)).
 */

-(id)initWithData:(NSMutableData *)newData
		 dataType:(CPNumericDataType)newDataType
            shape:(NSArray *)shapeArray;

@end
