#import "CPMutableNumericData+TypeConversion.h"
#import "CPNumericData+TypeConversion.h"

@implementation CPMutableNumericData(TypeConversion)

/** @property dataType
 *	@brief The type of data stored in the data buffer.
 **/
@dynamic dataType;

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

/** @brief Converts the current numeric data to a new data type.
 *  @param newDataType The new data type format.
 *  @param newSampleBytes The number of bytes used to store each sample.
 *  @param newByteOrder The new byte order.
 *	@return A copy of the current numeric data converted to the new data type.
 **/
-(void)convertToType:(CPDataTypeFormat)newDataType
		 sampleBytes:(size_t)newSampleBytes
		   byteOrder:(CFByteOrder)newByteOrder 
{
	self.dataType = CPDataType(newDataType, newSampleBytes, newByteOrder);
}

#pragma mark -
#pragma mark Accessors

-(void)setDataTypeFormat:(CPDataTypeFormat)newDataTypeFormat
{
	CPNumericDataType myDataType = self.dataType;
	if ( newDataTypeFormat != myDataType.dataTypeFormat ) {
		self.dataType = CPDataType(newDataTypeFormat, myDataType.sampleBytes, myDataType.byteOrder);
	}
}

-(void)setSampleBytes:(size_t)newSampleBytes
{
	CPNumericDataType myDataType = self.dataType;
	if ( newSampleBytes != myDataType.sampleBytes ) {
		self.dataType = CPDataType(myDataType.dataTypeFormat, newSampleBytes, myDataType.byteOrder);
	}
}

-(void)setByteOrder:(CFByteOrder)newByteOrder
{
	CPNumericDataType myDataType = self.dataType;
	if ( newByteOrder != myDataType.byteOrder ) {
		self.dataType = CPDataType(myDataType.dataTypeFormat, myDataType.sampleBytes, newByteOrder);
	}
}

-(void)setDataType:(CPNumericDataType)newDataType
{
	CPNumericDataType myDataType = self.dataType;
	if ( (myDataType.dataTypeFormat == newDataType.dataTypeFormat)
		&& (myDataType.sampleBytes == newDataType.sampleBytes)
		&& (myDataType.byteOrder == newDataType.byteOrder) ) {
		
		return;
	}
	
	NSParameterAssert(myDataType.dataTypeFormat != CPUndefinedDataType);
	NSParameterAssert(myDataType.byteOrder != CFByteOrderUnknown);
	
	NSParameterAssert(CPDataTypeIsSupported(newDataType));
	NSParameterAssert(newDataType.dataTypeFormat != CPUndefinedDataType);
	NSParameterAssert(newDataType.byteOrder != CFByteOrderUnknown);
	
	dataType = newDataType;
	
	if ( (myDataType.sampleBytes == sizeof(int8_t)) && (newDataType.sampleBytes == sizeof(int8_t)) ) {
		return;
	}
	
	NSMutableData *myData = (NSMutableData *)self.data;
	CFByteOrder hostByteOrder = CFByteOrderGetCurrent();
	
	NSUInteger sampleCount = myData.length / myDataType.sampleBytes;
	
	if ( myDataType.byteOrder != hostByteOrder ) {
		[self swapByteOrderForData:myData sampleSize:myDataType.sampleBytes];
	}
	
	if ( newDataType.sampleBytes > myDataType.sampleBytes ) {
		NSMutableData *newData = [[NSMutableData alloc] initWithLength:(sampleCount * newDataType.sampleBytes)];
		[self convertData:myData dataType:&myDataType toData:newData dataType:&newDataType];
		[data release];
		data = newData;
		myData = newData;
	}
	else {
		[self convertData:myData dataType:&myDataType toData:myData dataType:&newDataType];
		myData.length = sampleCount * newDataType.sampleBytes;
	}
	
	if ( newDataType.byteOrder != hostByteOrder ) {
		[self swapByteOrderForData:myData sampleSize:newDataType.sampleBytes];
	}
}

@end
