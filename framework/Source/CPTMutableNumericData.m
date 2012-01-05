#import "CPTMutableNumericData.h"

#import "CPTExceptions.h"

///	@cond
@interface CPTMutableNumericData()

-(void)commonInitWithData:(NSData *)newData dataType:(CPTNumericDataType)newDataType shape:(NSArray *)shapeArray;

@end

///	@endcond

#pragma mark -

/** @brief An annotated NSMutableData type.
 *
 *	CPTNumericData combines a mutable data buffer with information
 *	about the data (shape, data type, size, etc.).
 *	The data is assumed to be an array of one or more dimensions
 *	of a single type of numeric data. Each numeric value in the array,
 *	which can be more than one byte in size, is referred to as a "sample".
 *	The structure of this object is similar to the NumPy ndarray
 *	object.
 **/
@implementation CPTMutableNumericData

/** @property mutableBytes
 *	@brief Returns a pointer to the data buffer’s contents.
 **/
@dynamic mutableBytes;

/** @property shape
 *	@brief The shape of the data buffer array. Set a new shape to change the size of the data buffer.
 *
 *	The shape describes the dimensions of the sample array stored in
 *	the data buffer. Each entry in the shape array represents the
 *	size of the corresponding array dimension and should be an unsigned
 *	integer encoded in an instance of NSNumber.
 **/
@dynamic shape;

#pragma mark -
#pragma mark Factory Methods

/** @brief Creates and returns a new CPTMutableNumericData instance.
 *	@param newData The data buffer.
 *	@param newDataType The type of data stored in the buffer.
 *	@param shapeArray The shape of the data buffer array.
 *  @return A new CPTMutableNumericData instance.
 **/
+(CPTMutableNumericData *)numericDataWithData:(NSData *)newData
									 dataType:(CPTNumericDataType)newDataType
										shape:(NSArray *)shapeArray
{
	return [[[CPTMutableNumericData alloc] initWithData:newData
											   dataType:newDataType
												  shape:shapeArray]
			autorelease];
}

/** @brief Creates and returns a new CPTMutableNumericData instance.
 *	@param newData The data buffer.
 *	@param newDataTypeString The type of data stored in the buffer.
 *	@param shapeArray The shape of the data buffer array.
 *  @return A new CPTMutableNumericData instance.
 **/
+(CPTMutableNumericData *)numericDataWithData:(NSData *)newData
							   dataTypeString:(NSString *)newDataTypeString
										shape:(NSArray *)shapeArray
{
	return [[[CPTMutableNumericData alloc] initWithData:newData
											   dataType:CPTDataTypeWithDataTypeString(newDataTypeString)
												  shape:shapeArray]
			autorelease];
}

#pragma mark -
#pragma mark Init/Dealloc

/** @brief Initializes a newly allocated CPTMutableNumericData object with the provided data. This is the designated initializer.
 *	@param newData The data buffer.
 *	@param newDataType The type of data stored in the buffer.
 *	@param shapeArray The shape of the data buffer array.
 *  @return The initialized CPTMutableNumericData instance.
 **/
-(id)initWithData:(NSData *)newData
		 dataType:(CPTNumericDataType)newDataType
			shape:(NSArray *)shapeArray
{
	if ( (self = [super init]) ) {
		[self commonInitWithData:newData
						dataType:newDataType
						   shape:shapeArray];
	}

	return self;
}

///	@cond

-(void)commonInitWithData:(NSData *)newData
				 dataType:(CPTNumericDataType)newDataType
					shape:(NSArray *)shapeArray
{
	NSParameterAssert( CPTDataTypeIsSupported(newDataType) );

	data	 = [newData mutableCopy];
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
			[NSException raise:CPTNumericDataException
						format:@"Shape product (%u) does not match data size (%u)", prod, self.numberOfSamples];
		}

		shape = [shapeArray copy];
	}
}

///	@endcond

#pragma mark -
#pragma mark Accessors

///	@cond

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

		( (NSMutableData *)data ).length = sampleCount * self.sampleBytes;
	}
}

///	@endcond

#pragma mark -
#pragma mark NSMutableCopying

-(id)mutableCopyWithZone:(NSZone *)zone
{
	return [[CPTMutableNumericData allocWithZone:zone] initWithData:self.data
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

		CPTNumericDataType selfDataType = self.dataType;
		[encoder encodeInteger:selfDataType.dataTypeFormat forKey:@"CPTMutableNumericData.dataType.dataTypeFormat"];
		[encoder encodeInteger:selfDataType.sampleBytes forKey:@"CPTMutableNumericData.dataType.sampleBytes"];
		[encoder encodeInteger:selfDataType.byteOrder forKey:@"CPTMutableNumericData.dataType.byteOrder"];

		[encoder encodeObject:self.shape forKey:@"shape"];
	}
	else {
		[encoder encodeObject:self.data];

		CPTNumericDataType selfDataType = self.dataType;
		[encoder encodeValueOfObjCType:@encode(CPTDataTypeFormat) at:&(selfDataType.dataTypeFormat)];
		[encoder encodeValueOfObjCType:@encode(NSUInteger) at:&(selfDataType.sampleBytes)];
		[encoder encodeValueOfObjCType:@encode(CFByteOrder) at:&(selfDataType.byteOrder)];

		[encoder encodeObject:self.shape];
	}
}

-(id)initWithCoder:(NSCoder *)decoder
{
	if ( (self = [super init]) ) {
		NSData *newData;
		CPTNumericDataType newDataType;
		NSArray *shapeArray;

		if ( [decoder allowsKeyedCoding] ) {
			newData = [decoder decodeObjectForKey:@"data"];

			newDataType = CPTDataType([decoder decodeIntegerForKey:@"CPTMutableNumericData.dataType.dataTypeFormat"],
									  [decoder decodeIntegerForKey:@"CPTMutableNumericData.dataType.sampleBytes"],
									  [decoder decodeIntegerForKey:@"CPTMutableNumericData.dataType.byteOrder"]);

			shapeArray = [decoder decodeObjectForKey:@"shape"];
		}
		else {
			newData = [decoder decodeObject];

			[decoder decodeValueOfObjCType:@encode(CPTDataTypeFormat) at:&(newDataType.dataTypeFormat)];
			[decoder decodeValueOfObjCType:@encode(NSUInteger) at:&(newDataType.sampleBytes)];
			[decoder decodeValueOfObjCType:@encode(CFByteOrder) at:&(newDataType.byteOrder)];

			shapeArray = [decoder decodeObject];
		}

		[self commonInitWithData:newData dataType:newDataType shape:shapeArray];
	}

	return self;
}

@end
