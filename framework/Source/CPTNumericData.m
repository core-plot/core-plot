#import "CPTNumericData.h"

#import "CPTExceptions.h"
#import "CPTMutableNumericData.h"
#import "CPTNumericData+TypeConversion.h"
#import "CPTUtilities.h"
#import "complex.h"

///	@cond
@interface CPTNumericData()

-(void)commonInitWithData:(NSData *)newData dataType:(CPTNumericDataType)newDataType shape:(NSArray *)shapeArray;

-(NSData *)dataFromArray:(NSArray *)newData dataType:(CPTNumericDataType)newDataType;

@end

///	@endcond

#pragma mark -

/** @brief An annotated NSData type.
 *
 *	CPTNumericData combines a data buffer with information
 *	about the data (shape, data type, size, etc.).
 *	The data is assumed to be an array of one or more dimensions
 *	of a single type of numeric data. Each numeric value in the array,
 *	which can be more than one byte in size, is referred to as a "sample".
 *	The structure of this object is similar to the NumPy ndarray
 *	object.
 *
 *	The supported data types are:
 *	- 1, 2, 4, and 8-byte signed integers
 *	- 1, 2, 4, and 8-byte unsigned integers
 *	- <code>float</code> and <code>double</code> floating point numbers
 *	- <code>float complex</code> and <code>double complex</code> floating point complex numbers
 *	- NSDecimal base-10 numbers
 *
 *	All integer and floating point types can be represented using big endian or little endian
 *	byte order. Complex and decimal types support only the the host system's native byte order.
 **/
@implementation CPTNumericData

/** @property data
 *	@brief The data buffer.
 **/
@synthesize data;

/** @property bytes
 *	@brief Returns a pointer to the data buffer’s contents.
 **/
@dynamic bytes;

/** @property length
 *	@brief Returns the number of bytes contained in the data buffer.
 **/
@dynamic length;

/** @property dataType
 *	@brief The type of data stored in the data buffer.
 **/
@synthesize dataType;

/** @property dataTypeFormat
 *	@brief The format of the data stored in the data buffer.
 **/
@dynamic dataTypeFormat;

/** @property sampleBytes
 *	@brief The number of bytes in a single sample of data.
 **/
@dynamic sampleBytes;

/** @property byteOrder
 *	@brief The byte order used to store each sample in the data buffer.
 **/
@dynamic byteOrder;

/** @property shape
 *	@brief The shape of the data buffer array.
 *
 *	The shape describes the dimensions of the sample array stored in
 *	the data buffer. Each entry in the shape array represents the
 *	size of the corresponding array dimension and should be an unsigned
 *	integer encoded in an instance of NSNumber.
 **/
@synthesize shape;

/** @property numberOfDimensions
 *	@brief The number dimensions in the data buffer array.
 **/
@dynamic numberOfDimensions;

/** @property numberOfSamples
 *	@brief The number of samples of dataType stored in the data buffer.
 **/
@dynamic numberOfSamples;

#pragma mark -
#pragma mark Factory Methods

/** @brief Creates and returns a new CPTNumericData instance.
 *	@param newData The data buffer.
 *	@param newDataType The type of data stored in the buffer.
 *	@param shapeArray The shape of the data buffer array.
 *  @return A new CPTNumericData instance.
 **/
+(CPTNumericData *)numericDataWithData:(NSData *)newData
							  dataType:(CPTNumericDataType)newDataType
								 shape:(NSArray *)shapeArray
{
	return [[[CPTNumericData alloc] initWithData:newData
										dataType:newDataType
										   shape:shapeArray]
			autorelease];
}

/** @brief Creates and returns a new CPTNumericData instance.
 *	@param newData The data buffer.
 *	@param newDataTypeString The type of data stored in the buffer.
 *	@param shapeArray The shape of the data buffer array.
 *  @return A new CPTNumericData instance.
 **/
+(CPTNumericData *)numericDataWithData:(NSData *)newData
						dataTypeString:(NSString *)newDataTypeString
								 shape:(NSArray *)shapeArray
{
	return [[[CPTNumericData alloc] initWithData:newData
										dataType:CPTDataTypeWithDataTypeString(newDataTypeString)
										   shape:shapeArray]
			autorelease];
}

/** @brief Creates and returns a new CPTNumericData instance.
 *
 *	Objects in newData should be instances of NSNumber, NSDecimalNumber, NSString, or NSNull.
 *	Numbers and strings will be converted to newDataType and stored in the receiver.
 *	Any instances of NSNull will be treated as "not a number" (NAN) values for floating point types and "0" for integer types.
 *	@param newData An array of numbers.
 *	@param newDataType The type of data stored in the buffer.
 *	@param shapeArray The shape of the data buffer array.
 *  @return A new CPTNumericData instance.
 **/
+(CPTNumericData *)numericDataWithArray:(NSArray *)newData
							   dataType:(CPTNumericDataType)newDataType
								  shape:(NSArray *)shapeArray
{
	return [[[CPTNumericData alloc] initWithArray:newData
										 dataType:newDataType
											shape:shapeArray]
			autorelease];
}

/** @brief Creates and returns a new CPTNumericData instance.
 *
 *	Objects in newData should be instances of NSNumber, NSDecimalNumber, NSString, or NSNull.
 *	Numbers and strings will be converted to newDataTypeString and stored in the receiver.
 *	Any instances of NSNull will be treated as "not a number" (NAN) values for floating point types and "0" for integer types.
 *	@param newData An array of numbers.
 *	@param newDataTypeString The type of data stored in the buffer.
 *	@param shapeArray The shape of the data buffer array.
 *  @return A new CPTNumericData instance.
 **/
+(CPTNumericData *)numericDataWithArray:(NSArray *)newData
						 dataTypeString:(NSString *)newDataTypeString
								  shape:(NSArray *)shapeArray
{
	return [[[CPTNumericData alloc] initWithArray:newData
										 dataType:CPTDataTypeWithDataTypeString(newDataTypeString)
											shape:shapeArray]
			autorelease];
}

#pragma mark -
#pragma mark Init/Dealloc

/** @brief Initializes a newly allocated CPTNumericData object with the provided data. This is the designated initializer.
 *	@param newData The data buffer.
 *	@param newDataType The type of data stored in the buffer.
 *	@param shapeArray The shape of the data buffer array.
 *  @return The initialized CPTNumericData instance.
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

/** @brief Initializes a newly allocated CPTNumericData object with the provided data.
 *	@param newData The data buffer.
 *	@param newDataTypeString The type of data stored in the buffer.
 *	@param shapeArray The shape of the data buffer array.
 *  @return The initialized CPTNumericData instance.
 **/
-(id)initWithData:(NSData *)newData
   dataTypeString:(NSString *)newDataTypeString
			shape:(NSArray *)shapeArray
{
	return [self initWithData:newData
					 dataType:CPTDataTypeWithDataTypeString(newDataTypeString)
						shape:shapeArray];
}

/** @brief Initializes a newly allocated CPTNumericData object with the provided data.
 *
 *	Objects in newData should be instances of NSNumber, NSDecimalNumber, NSString, or NSNull.
 *	Numbers and strings will be converted to newDataType and stored in the receiver.
 *	Any instances of NSNull will be treated as "not a number" (NAN) values for floating point types and "0" for integer types.
 *	@param newData An array of numbers.
 *	@param newDataType The type of data stored in the buffer.
 *	@param shapeArray The shape of the data buffer array.
 *  @return The initialized CPTNumericData instance.
 **/
-(id)initWithArray:(NSArray *)newData
		  dataType:(CPTNumericDataType)newDataType
			 shape:(NSArray *)shapeArray
{
	return [self initWithData:[self dataFromArray:newData dataType:newDataType]
					 dataType:newDataType
						shape:shapeArray];
}

/** @brief Initializes a newly allocated CPTNumericData object with the provided data.
 *
 *	Objects in newData should be instances of NSNumber, NSDecimalNumber, NSString, or NSNull.
 *	Numbers and strings will be converted to newDataTypeString and stored in the receiver.
 *	Any instances of NSNull will be treated as "not a number" (NAN) values for floating point types and "0" for integer types.
 *	@param newData An array of numbers.
 *	@param newDataTypeString The type of data stored in the buffer.
 *	@param shapeArray The shape of the data buffer array.
 *  @return The initialized CPTNumericData instance.
 **/
-(id)initWithArray:(NSArray *)newData
	dataTypeString:(NSString *)newDataTypeString
			 shape:(NSArray *)shapeArray
{
	return [self initWithArray:newData
					  dataType:CPTDataTypeWithDataTypeString(newDataTypeString)
						 shape:shapeArray];
}

///	@cond

-(void)commonInitWithData:(NSData *)newData
				 dataType:(CPTNumericDataType)newDataType
					shape:(NSArray *)shapeArray
{
	NSParameterAssert( CPTDataTypeIsSupported(newDataType) );

	data	 = [newData copy];
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

-(void)dealloc
{
	[data release];
	[shape release];

	[super dealloc];
}

#pragma mark -
#pragma mark Accessors

///	@cond

-(NSUInteger)numberOfDimensions
{
	return self.shape.count;
}

-(const void *)bytes
{
	return self.data.bytes;
}

-(NSUInteger)length
{
	return self.data.length;
}

-(NSUInteger)numberOfSamples
{
	return self.length / self.dataType.sampleBytes;
}

-(CPTDataTypeFormat)dataTypeFormat
{
	return self.dataType.dataTypeFormat;
}

-(size_t)sampleBytes
{
	return self.dataType.sampleBytes;
}

-(CFByteOrder)byteOrder
{
	return self.dataType.byteOrder;
}

///	@endcond

#pragma mark -
#pragma mark Samples

/**	@brief Gets the value of a given sample in the data buffer.
 *	@param sample The index into the sample array. The array is treated as if it only has one dimension.
 *	@return The sample value wrapped in an instance of NSNumber or <code>nil</code> if the sample index is out of bounds.
 *
 *	NSNumber does not support complex numbers. Complex number types will be cast to
 *	<code>float</code> or <code>double</code> before being wrapped in an instance of NSNumber.
 **/
-(NSNumber *)sampleValue:(NSUInteger)sample
{
	NSNumber *result = nil;

	if ( sample < self.numberOfSamples ) {
		// Code generated with "CPTNumericData+TypeConversions_Generation.py"
		// ========================================================================

		switch ( self.dataTypeFormat ) {
			case CPTUndefinedDataType:
				[NSException raise:NSInvalidArgumentException format:@"Unsupported data type (CPTUndefinedDataType)"];
				break;

			case CPTIntegerDataType:
				switch ( self.sampleBytes ) {
					case sizeof(int8_t):
						result = [NSNumber numberWithChar:*(int8_t *)[self samplePointer:sample]];
						break;

					case sizeof(int16_t):
						result = [NSNumber numberWithShort:*(int16_t *)[self samplePointer:sample]];
						break;

					case sizeof(int32_t):
						result = [NSNumber numberWithLong:*(int32_t *)[self samplePointer:sample]];
						break;

					case sizeof(int64_t):
						result = [NSNumber numberWithLongLong:*(int64_t *)[self samplePointer:sample]];
						break;
				}
				break;

			case CPTUnsignedIntegerDataType:
				switch ( self.sampleBytes ) {
					case sizeof(uint8_t):
						result = [NSNumber numberWithUnsignedChar:*(uint8_t *)[self samplePointer:sample]];
						break;

					case sizeof(uint16_t):
						result = [NSNumber numberWithUnsignedShort:*(uint16_t *)[self samplePointer:sample]];
						break;

					case sizeof(uint32_t):
						result = [NSNumber numberWithUnsignedLong:*(uint32_t *)[self samplePointer:sample]];
						break;

					case sizeof(uint64_t):
						result = [NSNumber numberWithUnsignedLongLong:*(uint64_t *)[self samplePointer:sample]];
						break;
				}
				break;

			case CPTFloatingPointDataType:
				switch ( self.sampleBytes ) {
					case sizeof(float):
						result = [NSNumber numberWithFloat:*(float *)[self samplePointer:sample]];
						break;

					case sizeof(double):
						result = [NSNumber numberWithDouble:*(double *)[self samplePointer:sample]];
						break;
				}
				break;

			case CPTComplexFloatingPointDataType:
				switch ( self.sampleBytes ) {
					case sizeof(float complex):
						result = [NSNumber numberWithFloat:*(float complex *)[self samplePointer:sample]];
						break;

					case sizeof(double complex):
						result = [NSNumber numberWithDouble:*(double complex *)[self samplePointer:sample]];
						break;
				}
				break;

			case CPTDecimalDataType:
				switch ( self.sampleBytes ) {
					case sizeof(NSDecimal):
						result = [NSDecimalNumber decimalNumberWithDecimal:*(NSDecimal *)[self samplePointer:sample]];
						break;
				}
				break;
		}

		// End of code generated with "CPTNumericData+TypeConversions_Generation.py"
		// ========================================================================
	}

	return result;
}

/**	@brief Gets a pointer to a given sample in the data buffer.
 *	@param sample The index into the sample array. The array is treated as if it only has one dimension.
 *	@return A pointer to the sample or <code>NULL</code> if the sample index is out of bounds.
 **/
-(void *)samplePointer:(NSUInteger)sample
{
	if ( sample < self.numberOfSamples ) {
		return (void *)( (char *)self.bytes + sample * self.sampleBytes );
	}
	else {
		return NULL;
	}
}

/**	@brief Gets an array data samples from the receiver.
 *	@return An NSArray of NSNumber objects representing the data from the receiver.
 **/
-(NSArray *)sampleArray
{
	NSUInteger sampleCount	= self.numberOfSamples;
	NSMutableArray *samples = [[NSMutableArray alloc] initWithCapacity:sampleCount];

	for ( NSUInteger i = 0; i < sampleCount; i++ ) {
		[samples addObject:[self sampleValue:i]];
	}

	NSArray *result = [NSArray arrayWithArray:samples];
	[samples release];

	return result;
}

///	@cond

-(NSData *)dataFromArray:(NSArray *)newData dataType:(CPTNumericDataType)newDataType
{
	NSParameterAssert( CPTDataTypeIsSupported(newDataType) );
	NSParameterAssert(newDataType.dataTypeFormat != CPTUndefinedDataType);
	NSParameterAssert(newDataType.dataTypeFormat != CPTComplexFloatingPointDataType);

	NSMutableData *sampleData = [[NSMutableData alloc] initWithLength:newData.count * newDataType.sampleBytes];

	// Code generated with "CPTNumericData+TypeConversions_Generation.py"
	// ========================================================================

	switch ( newDataType.dataTypeFormat ) {
		case CPTUndefinedDataType:
			// Unsupported
			break;

		case CPTIntegerDataType:
			switch ( newDataType.sampleBytes ) {
				case sizeof(int8_t):
				{
					int8_t *toBytes = (int8_t *)sampleData.mutableBytes;
					for ( id sample in newData ) {
						if ( [sample respondsToSelector:@selector(charValue)] ) {
							*toBytes++ = (int8_t)[(NSNumber *)sample charValue];
						}
						else {
							*toBytes++ = 0;
						}
					}
				}
				break;

				case sizeof(int16_t):
				{
					int16_t *toBytes = (int16_t *)sampleData.mutableBytes;
					for ( id sample in newData ) {
						if ( [sample respondsToSelector:@selector(shortValue)] ) {
							*toBytes++ = (int16_t)[(NSNumber *)sample shortValue];
						}
						else {
							*toBytes++ = 0;
						}
					}
				}
				break;

				case sizeof(int32_t):
				{
					int32_t *toBytes = (int32_t *)sampleData.mutableBytes;
					for ( id sample in newData ) {
						if ( [sample respondsToSelector:@selector(longValue)] ) {
							*toBytes++ = (int32_t)[(NSNumber *)sample longValue];
						}
						else {
							*toBytes++ = 0;
						}
					}
				}
				break;

				case sizeof(int64_t):
				{
					int64_t *toBytes = (int64_t *)sampleData.mutableBytes;
					for ( id sample in newData ) {
						if ( [sample respondsToSelector:@selector(longLongValue)] ) {
							*toBytes++ = (int64_t)[(NSNumber *)sample longLongValue];
						}
						else {
							*toBytes++ = 0;
						}
					}
				}
				break;
			}
			break;

		case CPTUnsignedIntegerDataType:
			switch ( newDataType.sampleBytes ) {
				case sizeof(uint8_t):
				{
					uint8_t *toBytes = (uint8_t *)sampleData.mutableBytes;
					for ( id sample in newData ) {
						if ( [sample respondsToSelector:@selector(unsignedCharValue)] ) {
							*toBytes++ = (uint8_t)[(NSNumber *)sample unsignedCharValue];
						}
						else {
							*toBytes++ = 0;
						}
					}
				}
				break;

				case sizeof(uint16_t):
				{
					uint16_t *toBytes = (uint16_t *)sampleData.mutableBytes;
					for ( id sample in newData ) {
						if ( [sample respondsToSelector:@selector(unsignedShortValue)] ) {
							*toBytes++ = (uint16_t)[(NSNumber *)sample unsignedShortValue];
						}
						else {
							*toBytes++ = 0;
						}
					}
				}
				break;

				case sizeof(uint32_t):
				{
					uint32_t *toBytes = (uint32_t *)sampleData.mutableBytes;
					for ( id sample in newData ) {
						if ( [sample respondsToSelector:@selector(unsignedLongValue)] ) {
							*toBytes++ = (uint32_t)[(NSNumber *)sample unsignedLongValue];
						}
						else {
							*toBytes++ = 0;
						}
					}
				}
				break;

				case sizeof(uint64_t):
				{
					uint64_t *toBytes = (uint64_t *)sampleData.mutableBytes;
					for ( id sample in newData ) {
						if ( [sample respondsToSelector:@selector(unsignedLongLongValue)] ) {
							*toBytes++ = (uint64_t)[(NSNumber *)sample unsignedLongLongValue];
						}
						else {
							*toBytes++ = 0;
						}
					}
				}
				break;
			}
			break;

		case CPTFloatingPointDataType:
			switch ( newDataType.sampleBytes ) {
				case sizeof(float):
				{
					float *toBytes = (float *)sampleData.mutableBytes;
					for ( id sample in newData ) {
						if ( [sample respondsToSelector:@selector(floatValue)] ) {
							*toBytes++ = (float)[(NSNumber *) sample floatValue];
						}
						else {
							*toBytes++ = NAN;
						}
					}
				}
				break;

				case sizeof(double):
				{
					double *toBytes = (double *)sampleData.mutableBytes;
					for ( id sample in newData ) {
						if ( [sample respondsToSelector:@selector(doubleValue)] ) {
							*toBytes++ = (double)[(NSNumber *) sample doubleValue];
						}
						else {
							*toBytes++ = NAN;
						}
					}
				}
				break;
			}
			break;

		case CPTComplexFloatingPointDataType:
			switch ( newDataType.sampleBytes ) {
				case sizeof(float complex):
				{
					float complex *toBytes = (float complex *)sampleData.mutableBytes;
					for ( id sample in newData ) {
						if ( [sample respondsToSelector:@selector(floatValue)] ) {
							*toBytes++ = (float complex)[(NSNumber *) sample floatValue];
						}
						else {
							*toBytes++ = NAN;
						}
					}
				}
				break;

				case sizeof(double complex):
				{
					double complex *toBytes = (double complex *)sampleData.mutableBytes;
					for ( id sample in newData ) {
						if ( [sample respondsToSelector:@selector(doubleValue)] ) {
							*toBytes++ = (double complex)[(NSNumber *) sample doubleValue];
						}
						else {
							*toBytes++ = NAN;
						}
					}
				}
				break;
			}
			break;

		case CPTDecimalDataType:
			switch ( newDataType.sampleBytes ) {
				case sizeof(NSDecimal):
				{
					NSDecimal *toBytes = (NSDecimal *)sampleData.mutableBytes;
					for ( id sample in newData ) {
						if ( [sample respondsToSelector:@selector(decimalValue)] ) {
							*toBytes++ = (NSDecimal)[(NSNumber *)sample decimalValue];
						}
						else {
							*toBytes++ = CPTDecimalNaN();
						}
					}
				}
				break;
			}
			break;
	}

	// End of code generated with "CPTNumericData+TypeConversions_Generation.py"
	// ========================================================================

	if ( ( newDataType.byteOrder != CFByteOrderGetCurrent() ) && (newDataType.byteOrder != CFByteOrderUnknown) ) {
		[self swapByteOrderForData:sampleData sampleSize:newDataType.sampleBytes];
	}

	return [sampleData autorelease];
}

///	@endcond

#pragma mark -
#pragma mark Description

-(NSString *)description
{
	NSUInteger sampleCount			   = self.numberOfSamples;
	NSMutableString *descriptionString = [NSMutableString stringWithCapacity:sampleCount * 3];

	[descriptionString appendFormat:@"<%@ [", [super description]];
	for ( NSUInteger i = 0; i < sampleCount; i++ ) {
		if ( i > 0 ) {
			[descriptionString appendFormat:@","];
		}
		[descriptionString appendFormat:@" %@", [self sampleValue:i]];
	}
	[descriptionString appendFormat:@" ] {%@, %@}>", CPTDataTypeStringFromDataType(self.dataType), self.shape];

	return descriptionString;
}

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
		[encoder encodeObject:self.data forKey:@"CPTNumericData.data"];

		CPTNumericDataType selfDataType = self.dataType;
		[encoder encodeInteger:selfDataType.dataTypeFormat forKey:@"CPTNumericData.dataType.dataTypeFormat"];
		[encoder encodeInteger:selfDataType.sampleBytes forKey:@"CPTNumericData.dataType.sampleBytes"];
		[encoder encodeInteger:selfDataType.byteOrder forKey:@"CPTNumericData.dataType.byteOrder"];

		[encoder encodeObject:self.shape forKey:@"CPTNumericData.shape"];
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
			newData = [decoder decodeObjectForKey:@"CPTNumericData.data"];

			newDataType = CPTDataType([decoder decodeIntegerForKey:@"CPTNumericData.dataType.dataTypeFormat"],
									  [decoder decodeIntegerForKey:@"CPTNumericData.dataType.sampleBytes"],
									  [decoder decodeIntegerForKey:@"CPTNumericData.dataType.byteOrder"]);

			shapeArray = [decoder decodeObjectForKey:@"CPTNumericData.shape"];
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
