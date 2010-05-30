#import "CPMutableNumericData.h"
#import "CPNumericData.h"
#import "NSExceptionExtensions.h"
#import "CPExceptions.h"

@interface CPSerializedMutableNumericData : NSObject <NSCoding> {
    NSMutableData *data;
    CPNumericDataType dataType;
    NSArray *shape;
}

@property (assign, readwrite) CPNumericDataType dataType;
@property (retain, readwrite) NSMutableData *data;
@property (retain, readwrite) NSArray *shape;

-(id)initWithData:(NSMutableData *)newData
		 dataType:(CPNumericDataType)newDataType
            shape:(NSArray *)shapeArray;
@end

#pragma mark -

@interface CPMutableNumericData ()

@property (assign, readwrite) CPNumericDataType dataType;
@property (retain, readwrite) NSMutableData *data;
@property (copy, readwrite) NSArray *shape;

-(void)commonInitWithData:(NSMutableData *)newData
				 dataType:(CPNumericDataType)newDataType
                    shape:(NSArray *)shapeArray;
@end

#pragma mark -

@implementation CPMutableNumericData

@synthesize dataType;
@synthesize data;
@synthesize shape;
@dynamic numberOfDimensions;

-(id)initWithData:(NSMutableData *)newData
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

-(void)commonInitWithData:(NSMutableData *)newData
				 dataType:(CPNumericDataType)newDataType
                    shape:(NSArray *)shapeArray 
{
    self.data = newData;
    self.dataType = newDataType;
    
    NSUInteger sampleBytes = self.dataType.sampleBytes;
    if ( shapeArray == nil ) {
        self.shape = [NSArray arrayWithObject:[NSNumber numberWithUnsignedInt:[self.data length] / sampleBytes]];
    }
	else {
        NSUInteger prod = 1;
        for ( NSNumber *cNum in shapeArray ) {
            prod *= [cNum unsignedIntValue];
        }
        
        if ( prod != [self.data length] / sampleBytes ) {
            [NSException raise:CPDataException 
                        format:@"Shape product (%u) does not match data size (%u)",prod,[self.data length] / sampleBytes];
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

-(void *)mutableBytes 
{
    return [[self data] mutableBytes];
}

-(NSUInteger)length 
{
    return [[self data] length];
}

#pragma mark -
#pragma mark NSCopying and NSMutableCopying

-(id)mutableCopyWithZone:(NSZone *)zone 
{
    return [[[self class] allocWithZone:zone] initWithData:self.data
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

-(id)replacementObjectForCoder:(NSCoder *)aCoder
{
    return [[[CPSerializedMutableNumericData alloc] initWithData:self.data
														dataType:self.dataType
                                                           shape:self.shape]
            autorelease];
}
@end

#pragma mark -

@implementation CPSerializedMutableNumericData
@synthesize data;
@synthesize dataType;
@synthesize shape;

-(id)initWithData:(NSMutableData *)newData
		 dataType:(CPNumericDataType)newDataType
            shape:(NSArray *)shapeArray 
{
    if ( (self = [super init]) ) {
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
    CPMutableNumericData *replacement = [[CPMutableNumericData alloc] initWithData:self.data
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

