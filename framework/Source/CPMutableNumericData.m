#import "CPNumericData.h"
#import "CPMutableNumericData.h"
#import "CPExceptions.h"

///	@cond
@interface CPMutableNumericData()

-(void)commonInitWithData:(NSData *)newData
				 dataType:(CPNumericDataType)newDataType
                    shape:(NSArray *)shapeArray;

@end
///	@endcond

#pragma mark -

/** @brief An annotated NSMutableData type.
 *
 *	CPNumericData combines a mutable data buffer with information
 *	about the data (shape, data type, size, etc.).
 *	The data is assumed to be an array of one or more dimensions
 *	of a single type of numeric data. Each numeric value in the array,
 *	which can be more than one byte in size, is referred to as a "sample".
 *	The structure of this object is similar to the NumPy ndarray
 *	object.
 **/
@implementation CPMutableNumericData

/** @property mutableBytes
 *	@brief Returns a pointer to the data buffer’s contents.
 **/
@dynamic mutableBytes;

/** @property shape
 *	@brief The shape of the data buffer array.
 *
 *	The shape describes the dimensions of the sample array stored in
 *	the data buffer. Each entry in the shape array represents the
 *	size of the corresponding array dimension and should be an unsigned
 *	integer encoded in an instance of NSNumber. 
 **/
@dynamic shape;

#pragma mark -
#pragma mark Factory Methods

/** @brief Creates and returns a new CPMutableNumericData instance.
 *	@param newData The data buffer.
 *	@param newDataType The type of data stored in the buffer.
 *	@param shapeArray The shape of the data buffer array.
 *  @return A new CPMutableNumericData instance.
 **/
+(CPMutableNumericData *)numericDataWithData:(NSData *)newData
									dataType:(CPNumericDataType)newDataType
									   shape:(NSArray *)shapeArray 
{
    return [[[CPMutableNumericData alloc] initWithData:newData
											  dataType:newDataType
												 shape:shapeArray]
            autorelease];
}

/** @brief Creates and returns a new CPMutableNumericData instance.
 *	@param newData The data buffer.
 *	@param newDataTypeString The type of data stored in the buffer.
 *	@param shapeArray The shape of the data buffer array.
 *  @return A new CPMutableNumericData instance.
 **/
+(CPMutableNumericData *)numericDataWithData:(NSData *)newData
							  dataTypeString:(NSString *)newDataTypeString
									   shape:(NSArray *)shapeArray 
{
    return [[[CPMutableNumericData alloc] initWithData:newData
											  dataType:CPDataTypeWithDataTypeString(newDataTypeString)
												 shape:shapeArray]
            autorelease];
}

#pragma mark -
#pragma mark Init/Dealloc

/** @brief Initializes a newly allocated CPMutableNumericData object with the provided data. This is the designated initializer.
 *	@param newData The data buffer.
 *	@param newDataType The type of data stored in the buffer.
 *	@param shapeArray The shape of the data buffer array.
 *  @return The initialized CPMutableNumericData instance.
 **/
-(id)initWithData:(NSData *)newData
		 dataType:(CPNumericDataType)newDataType
            shape:(NSArray *)shapeArray 
{
    if ( self = [super init] ) {
        [self commonInitWithData:newData
						dataType:newDataType
                           shape:shapeArray];
    }
    
    return self;
}

-(void)commonInitWithData:(NSData *)newData
				 dataType:(CPNumericDataType)newDataType
                    shape:(NSArray *)shapeArray
{
	NSParameterAssert(CPDataTypeIsSupported(newDataType));
	
    data = [newData mutableCopy];
    dataType = newDataType;
    
    if ( shapeArray == nil ) {
        shape = [[NSArray arrayWithObject:[NSNumber numberWithUnsignedInteger:self.numberOfSamples]] retain];
    }
	else {
        NSUInteger prod = 1;
        for ( NSNumber *cNum in shapeArray ) {
            prod *= [cNum unsignedIntegerValue];
        }
        
        if ( prod != self.numberOfSamples ) {
            [NSException raise:CPNumericDataException 
                        format:@"Shape product (%u) does not match data size (%u)", prod, self.numberOfSamples];
        }
        
        shape = [shapeArray copy];
    }
}

#pragma mark -
#pragma mark Accessors

-(void *)mutableBytes 
{
	return [(NSMutableData *)self.data mutableBytes];
}

#pragma mark -
#pragma mark NSMutableCopying

-(id)mutableCopyWithZone:(NSZone *)zone 
{
    if ( NSShouldRetainWithZone(self, zone)) {
        return [self retain];
    }
    
    return [[CPMutableNumericData allocWithZone:zone] initWithData:self.data
														  dataType:self.dataType
                                                             shape:self.shape];
}

#pragma mark -
#pragma mark NSCopying

-(id)copyWithZone:(NSZone *)zone
{
    return [[[self class] allocWithZone:zone] initWithData:self.data
												  dataType:self.dataType
                                                     shape:self.shape];
}

#pragma mark -
#pragma mark NSCoding

-(void)encodeWithCoder:(NSCoder *)encoder 
{
    //[super encodeWithCoder:encoder];
    
    if ( [encoder allowsKeyedCoding] ) {
        [encoder encodeObject:self.data forKey:@"data"];
        
		CPNumericDataType selfDataType = self.dataType;
		[encoder encodeInteger:selfDataType.dataTypeFormat forKey:@"dataType.dataTypeFormat"];
        [encoder encodeInteger:selfDataType.sampleBytes forKey:@"dataType.sampleBytes"];
        [encoder encodeInteger:selfDataType.byteOrder forKey:@"dataType.byteOrder"];
        
        [encoder encodeObject:self.shape forKey:@"shape"];
    }
	else {
        [encoder encodeObject:self.data];
		
		CPNumericDataType selfDataType = self.dataType;
		[encoder encodeValueOfObjCType:@encode(CPDataTypeFormat) at:&(selfDataType.dataTypeFormat)];
        [encoder encodeValueOfObjCType:@encode(NSUInteger) at:&(selfDataType.sampleBytes)];
        [encoder encodeValueOfObjCType:@encode(CFByteOrder) at:&(selfDataType.byteOrder)];
        
        [encoder encodeObject:self.shape];
    }
}

-(id)initWithCoder:(NSCoder *)decoder 
{
	if ( self = [super init] ) {
		NSData *newData;
		CPNumericDataType newDataType;
		NSArray	*shapeArray;
		
		if ( [decoder allowsKeyedCoding] ) {
			newData = [decoder decodeObjectForKey:@"data"];
			
			newDataType = CPDataType([decoder decodeIntegerForKey:@"dataType.dataTypeFormat"],
									 [decoder decodeIntegerForKey:@"dataType.sampleBytes"],
									 [decoder decodeIntegerForKey:@"dataType.byteOrder"]);
			
			shapeArray = [decoder decodeObjectForKey:@"shape"];
		}
		else {
			newData = [decoder decodeObject];
			
			[decoder decodeValueOfObjCType:@encode(CPDataTypeFormat) at:&(newDataType.dataTypeFormat)];
			[decoder decodeValueOfObjCType:@encode(NSUInteger) at:&(newDataType.sampleBytes)];
			[decoder decodeValueOfObjCType:@encode(CFByteOrder) at:&(newDataType.byteOrder)];
			
			shapeArray = [decoder decodeObject];
		}
		
		[self commonInitWithData:newData dataType:newDataType shape:shapeArray];
	}
	
    return self;
}

@end

