#import "CPTMutableNumericData.h"

/** @brief An annotated NSMutableData type.
 *
 *  CPTNumericData combines a mutable data buffer with information
 *  about the data (shape, data type, size, etc.).
 *  The data is assumed to be an array of one or more dimensions
 *  of a single type of numeric data. Each numeric value in the array,
 *  which can be more than one byte in size, is referred to as a @quote{sample}.
 *  The structure of this object is similar to the NumPy <code>ndarray</code>
 *  object.
 **/
@implementation CPTMutableNumericData

/** @property void *mutableBytes
 *  @brief Returns a pointer to the data buffer’s contents.
 **/
@dynamic mutableBytes;

/** @property NSArray *shape
 *  @brief The shape of the data buffer array. Set a new shape to change the size of the data buffer.
 *
 *  The shape describes the dimensions of the sample array stored in
 *  the data buffer. Each entry in the shape array represents the
 *  size of the corresponding array dimension and should be an unsigned
 *  integer encoded in an instance of NSNumber.
 **/
@dynamic shape;

#pragma mark -
#pragma mark Accessors

/// @cond

-(void *)mutableBytes
{
    return [(NSMutableData *)self.data mutableBytes];
}

-(void)setShape:(NSArray *)newShape
{
    if ( newShape != shape ) {
        [shape release];
        shape = [newShape copy];

        NSUInteger sampleCount = 1;
        for ( NSNumber *num in shape ) {
            sampleCount *= [num unsignedIntegerValue];
        }

        ( (NSMutableData *)self.data ).length = sampleCount * self.sampleBytes;
    }
}

/// @endcond

@end
