#import "CPNumericData.h"
#import "CPMutableNumericData.h"
#import "CPExceptions.h"

NSString * const CPNumericDataException = @"CPNumericDataException";

@interface CPSerializedNumericData : NSObject <NSCoding> {
@private
    NSData *data;
    CPNumericDataType dataType;
    NSArray *shape;
}

@property (assign, readwrite) CPNumericDataType dataType;
@property (copy, readwrite) NSData *data;
@property (retain, readwrite) NSArray *shape;

-(id)initWithData:(NSData *)data
		 dataType:(CPNumericDataType)dtype
            shape:(NSArray *)shape;

@end

#pragma mark -

@interface CPNumericData()

@property (assign, readwrite) CPNumericDataType dataType;
@property (copy, readwrite) NSData *data;
@property (copy, readwrite) NSArray *shape;

-(void)commonInitWithData:(NSData *)newData
				 dataType:(CPNumericDataType)dataType
                    shape:(NSArray *)shapeArray;

@end

#pragma mark -

@implementation CPNumericData

@synthesize dataType;
@synthesize dataTypeFormat;
@synthesize data;
@synthesize shape;
@dynamic numberOfDimensions;
@dynamic numberOfSamples;

+(CPNumericData *)numericDataWithData:(NSData *)newData
							 dataType:(CPNumericDataType)dataType
                                shape:(NSArray *)shapeArray 
{
    return [[[CPNumericData alloc] initWithData:newData
									   dataType:dataType
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
    self.data = newData;
    self.dataType = newDataType;
    
    if ( shapeArray == nil ) {
        self.shape = [NSArray arrayWithObject:[NSNumber numberWithUnsignedInteger:self.numberOfSamples]];
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
        
        self.shape = shapeArray;
    }
}

-(void)dealloc 
{
    [data release];
    [shape release];
    
    [super dealloc];
}

-(NSUInteger)numberOfDimensions 
{
    return [[self shape] count];
}

-(const void *)bytes 
{
    return [[self data] bytes];
}

-(NSUInteger)length
{
    return [[self data] length];
}

-(NSUInteger)numberOfSamples
{
    return ([self length] / self.dataType.sampleBytes);
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

// Implementation generated with CPNumericData+TypeConversion_Generation.py
-(NSNumber *)sampleValue:(NSUInteger)sample 
{
    NSNumber *result = nil;
    
	switch( [self dataTypeFormat] ) {
		case CPUndefinedDataType:
			[NSException raise:NSInvalidArgumentException format:@"Unsupported data type (CPUndefinedDataType)"];
			break;
		case CPIntegerDataType:
			switch( [self sampleBytes] ) {
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
			switch( [self sampleBytes] ) {
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
			switch( [self sampleBytes] ) {
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
    return (void*) ((char*)[self bytes] + sample * [self sampleBytes]);
}

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
#pragma mark NSCopying and NSMutableCopying

-(id)mutableCopyWithZone:(NSZone *)zone 
{
    if ( NSShouldRetainWithZone(self, zone)) {
        return [self retain];
    }
    
    return [[CPMutableNumericData allocWithZone:zone] initWithData:self.data
														  dataType:self.dataType
                                                             shape:self.shape];
}

-(id)copyWithZone:(NSZone *)zone
{
    return [[[self class] allocWithZone:zone] initWithData:self.data
												  dataType:self.dataType
                                                     shape:self.shape];
}

#pragma mark -
#pragma mark NSCoding

-(id)replacementObjectForArchiver:(NSArchiver*)archiver {
    return [[[CPSerializedNumericData alloc] initWithData:self.data
												 dataType:self.dataType
                                                    shape:self.shape]
            autorelease];
}

@end

#pragma mark -

@implementation CPSerializedNumericData
@synthesize data;
@synthesize dataType;
@synthesize shape;

-(id)initWithData:(NSData *)newData
		 dataType:(CPNumericDataType)newDataType
            shape:(NSArray *)shapeArray
{
    if ( self = [super init] ) {
        self.data = newData;
        self.dataType = newDataType;
        self.shape = shapeArray;
    }
    
    return self;
}

-(void)encodeWithCoder:(NSCoder *)encoder 
{
    //[super encodeWithCoder:encoder];
    
    if ( [encoder allowsKeyedCoding] ) {
        [encoder encodeObject:self.data forKey:@"data"];
        
        [encoder encodeInteger:self.dataType.dataTypeFormat forKey:@"dataType.dataTypeFormat"];
        [encoder encodeInteger:self.dataType.sampleBytes forKey:@"dataType.sampleBytes"];
        [encoder encodeInteger:self.dataType.byteOrder forKey:@"dataType.byteOrder"];
        
        [encoder encodeObject:self.shape forKey:@"shape"];
    }
	else {
        CPNumericDataType selfDataType = self.dataType;
        
        [encoder encodeObject:self.data];
        [encoder encodeValueOfObjCType:@encode(CPDataTypeFormat) at:&(selfDataType.dataTypeFormat)];
        [encoder encodeValueOfObjCType:@encode(NSInteger) at:&(selfDataType.sampleBytes)];
        [encoder encodeValueOfObjCType:@encode(CFByteOrder) at:&(selfDataType.byteOrder)];
        
        [encoder encodeObject:self.shape];
    }
}

-(id)initWithCoder:(NSCoder *)decoder 
{    
    self = [super init]; //initWithCoder:decoder];
    
    if ( [decoder allowsKeyedCoding] ) {
        self.data = [decoder decodeObjectForKey:@"data"];
        
        self.dataType = CPDataType([decoder decodeIntegerForKey:@"dataType.dataType"],
								   [decoder decodeIntegerForKey:@"dataType.sampleBytes"],
								   [decoder decodeIntegerForKey:@"dataType.byteOrder"]);
        
        self.shape = [decoder decodeObjectForKey:@"shape"];
    }
	else {
        self.data = [decoder decodeObject];
        
        CPNumericDataType selfDataType;
        [decoder decodeValueOfObjCType:@encode(CPDataTypeFormat) at:&(selfDataType.dataTypeFormat)];
        [decoder decodeValueOfObjCType:@encode(NSInteger) at:&(selfDataType.sampleBytes)];
        [decoder decodeValueOfObjCType:@encode(CFByteOrder) at:&(selfDataType.byteOrder)];
        
        self.dataType = selfDataType;
        
        self.shape = [decoder decodeObject];
    }
    
    return self;
}

-(id)awakeAfterUsingCoder:(NSCoder *)decoder 
{
    CPNumericData *replacement = [[CPNumericData alloc] initWithData:self.data
															dataType:self.dataType
                                                               shape:self.shape];
    
    [self release];
    
    return replacement;
}

-(void)dealloc 
{
    [data release];
    [shape release];
    
    [super dealloc];
}

@end

