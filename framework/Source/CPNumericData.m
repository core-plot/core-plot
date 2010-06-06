#import "CPNumericData.h"
#import "CPMutableNumericData.h"
#import "CPExceptions.h"

NSString * const CPNumericDataException = @"CPNumericDataException";

@interface CPNumericData()

@property (assign, readwrite) CPNumericDataType dataType;
@property (copy, readwrite) NSData *data;
@property (copy, readwrite) NSArray *shape;

-(void)commonInitWithData:(NSData *)newData
				 dataType:(CPNumericDataType)newDataType
                    shape:(NSArray *)shapeArray;

@end

#pragma mark -

@implementation CPNumericData

@synthesize dataType;
@dynamic dataTypeFormat;
@synthesize data;
@synthesize shape;
@dynamic bytes;
@dynamic length;
@dynamic numberOfDimensions;
@dynamic numberOfSamples;

#pragma mark -
#pragma mark Init/Dealloc

+(CPNumericData *)numericDataWithData:(NSData *)newData
							 dataType:(CPNumericDataType)newDataType
                                shape:(NSArray *)shapeArray 
{
    return [[[CPNumericData alloc] initWithData:newData
									   dataType:newDataType
                                          shape:shapeArray]
            autorelease];
}


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

-(id)initWithData:(NSData *)newData
   dataTypeString:(NSString *)newDataTypeString
            shape:(NSArray *)shapeArray 
{
    return [self initWithData:newData
					 dataType:CPDataTypeWithDataTypeString(newDataTypeString)
                        shape:shapeArray];
}

-(void)commonInitWithData:(NSData *)newData
				 dataType:(CPNumericDataType)newDataType
                    shape:(NSArray *)shapeArray
{
    data = [newData copy];
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

-(void)dealloc 
{
    [data release];
    [shape release];
    
    [super dealloc];
}

#pragma mark -
#pragma mark Accessors

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
    return (self.length / self.dataType.sampleBytes);
}

-(CPDataTypeFormat)dataTypeFormat 
{
    return self.dataType.dataTypeFormat;
}

-(NSUInteger)sampleBytes 
{
    return self.dataType.sampleBytes;
}

-(CFByteOrder)byteOrder
{
    return self.dataType.byteOrder;
}

#pragma mark -
#pragma mark Samples

// Implementation generated with CPNumericData+TypeConversion_Generation.py
-(NSNumber *)sampleValue:(NSUInteger)sample 
{
    NSNumber *result = nil;
    
	switch( [self dataTypeFormat] ) {
		case CPUndefinedDataType:
			[NSException raise:NSInvalidArgumentException format:@"Unsupported data type (CPUndefinedDataType)"];
			break;
		case CPIntegerDataType:
			switch( self.sampleBytes ) {
				case sizeof(char):
					result = [NSNumber numberWithChar:*(char *)[self samplePointer:sample]];
					break;
				case sizeof(short):
					result = [NSNumber numberWithShort:*(short *)[self samplePointer:sample]];
					break;
				case sizeof(NSInteger):
					result = [NSNumber numberWithInteger:*(NSInteger *)[self samplePointer:sample]];
					break;
			}
			break;
		case CPUnsignedIntegerDataType:
			switch( self.sampleBytes ) {
				case sizeof(unsigned char):
					result = [NSNumber numberWithUnsignedChar:*(unsigned char *)[self samplePointer:sample]];
					break;
				case sizeof(unsigned short):
					result = [NSNumber numberWithUnsignedShort:*(unsigned short *)[self samplePointer:sample]];
					break;
				case sizeof(NSUInteger):
					result = [NSNumber numberWithUnsignedInteger:*(NSUInteger *)[self samplePointer:sample]];
					break;
			}
			break;
		case CPFloatingPointDataType:
			switch( self.sampleBytes ) {
				case sizeof(float):
					result = [NSNumber numberWithFloat:*(float *)[self samplePointer:sample]];
					break;
				case sizeof(double):
					result = [NSNumber numberWithDouble:*(double *)[self samplePointer:sample]];
					break;
			}
			break;
		case CPComplexFloatingPointDataType:
			[NSException raise:NSInvalidArgumentException format:@"Unsupported data type (CPComplexFloatingPointDataType)"];
			break;
	}
    
    return result;
}

-(void *)samplePointer:(NSUInteger)sample 
{
    NSParameterAssert(sample < self.numberOfSamples);
    return (void*) ((char*)self.bytes + sample * self.sampleBytes);
}

#pragma mark -
#pragma mark Description

-(NSString *)description 
{
    NSMutableString *descriptionString = [NSMutableString stringWithCapacity:self.numberOfSamples];
    [descriptionString appendFormat:@"["];
    for ( NSUInteger i = 0; i < self.numberOfSamples; i++ ) {
        [descriptionString appendFormat:@" %@",[self sampleValue:i]];
    }
    [descriptionString appendFormat:@" ] <%@,(%@)>", self.dataType, self.shape];
    
    return descriptionString;
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
