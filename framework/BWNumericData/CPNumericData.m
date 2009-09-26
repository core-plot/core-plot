#import "CPNumericData.h"
#import "CPMutableNumericData.h"
#import "GTMLogger.h"
#import "CPExceptions.h"

NSString * const CPNumericDataException = @"CPNumericDataException";

@interface CPSerializedNumericData : NSObject <NSCoding> {
    NSData *data;
    CPNumericDataType dtype;
    NSArray *shape;
}
@property (assign,readwrite) CPNumericDataType dtype;
@property (copy,readwrite) NSData *data;
@property (retain,readwrite) NSArray *shape;

-(id)initWithData:(NSData *)d
            dtype:(CPNumericDataType)dtype
            shape:(NSArray *)s;
@end

@interface CPNumericData ()
@property (assign,readwrite) CPNumericDataType dtype;
@property (copy,readwrite) NSData *data;
@property (copy,readwrite) NSArray *shape;

-(void)commonInitWithData:(NSData *)_data
                    dtype:(CPNumericDataType)_dtype
                    shape:(NSArray *)_shape;
@end

@implementation CPNumericData
@synthesize dtype;
@synthesize data;
@synthesize shape;
@dynamic ndims;
@dynamic nSamples;

+(CPNumericData *)numericDataWithData:(NSData *)theData
                                dtype:(CPNumericDataType)_dtype
                                shape:(NSArray *)shapeArray 
{
    
    return [[[CPNumericData alloc] initWithData:theData
                                          dtype:_dtype
                                          shape:shapeArray]
            autorelease];
}


-(id)initWithData:(NSData *)_data
        	dtype:(CPNumericDataType)newDType
            shape:(NSArray *)newShape 
{
    
    if( (self = [super init]) ) {
        [self commonInitWithData:_data
                           dtype:newDType
                           shape:newShape];
    }
    
    return self;
}

-(id)initWithData:(NSData *)theData
      dtypeString:(NSString *)dtypeString
            shape:(NSArray *)shapeArray 
{
    
    return [self initWithData:theData
                        dtype:CPDataTypeWithDataTypeString(dtypeString)
                        shape:shapeArray];
}

-(void)commonInitWithData:(NSData *)_data
                    dtype:(CPNumericDataType)_dtype
                    shape:(NSArray *)_shape 
{
    
    self.data = _data;
    self.dtype = _dtype;
    
    if(_shape == nil) {
        self.shape = [NSArray arrayWithObject:[NSNumber numberWithUnsignedInt:self.nSamples]];
    } else {
        NSUInteger prod = 1;
        for(NSNumber *cNum in _shape) {
            prod *= [cNum unsignedIntValue];
        }
        
        if(prod != self.nSamples) {
            [NSException raise:CPDataException 
                        format:@"Shape product (%u) does not match data size (%u)",prod,self.nSamples];
        }
        
        self.shape = _shape;
    }
}

-(void)dealloc 
{
    [data release];
    [shape release];
    
    [super dealloc];
}

-(NSUInteger)ndims 
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

-(NSUInteger)nSamples
{
    return ([self length]/self.dtype.sampleBytes);
}

-(CPDataTypeFormat)dataType 
{
    return self.dtype.dataType;
}

-(NSUInteger)sampleBytes 
{
    return self.dtype.sampleBytes;
}

-(CFByteOrder)byteOrder
{
    return self.dtype.byteOrder;
}

// Implementation generated with CPNumericData+TypeConversion_Generation.py
-(NSNumber *)sampleValue:(NSUInteger)sample 
{
    NSNumber *result=nil;
    
    switch([self dataType]) {
        case CPUndefinedDataType:
            [NSException raise:NSInvalidArgumentException format:@"Unsupported data type (BWUndefinedDataType)"];
            break;
        case CPIntegerDataType:
            switch([self sampleBytes]) {
                case sizeof(char):
                    result = [NSNumber numberWithChar:*(char*)[self samplePointer:sample]];
                    break;
                case sizeof(short):
                    result = [NSNumber numberWithShort:*(short*)[self samplePointer:sample]];
                    break;
                case sizeof(NSInteger):
                    result = [NSNumber numberWithInteger:*(NSInteger*)[self samplePointer:sample]];
                    break;
            }
            break;
        case CPUnsignedIntegerDataType:
            switch([self sampleBytes]) {
                case sizeof(unsigned char):
                    result = [NSNumber numberWithUnsignedChar:*(unsigned char*)[self samplePointer:sample]];
                    break;
                case sizeof(unsigned short):
                    result = [NSNumber numberWithUnsignedShort:*(unsigned short*)[self samplePointer:sample]];
                    break;
                case sizeof(NSUInteger):
                    result = [NSNumber numberWithUnsignedInteger:*(NSUInteger*)[self samplePointer:sample]];
                    break;
            }
            break;
        case CPFloatingPointDataType:
            switch([self sampleBytes]) {
                case sizeof(float):
                    result = [NSNumber numberWithFloat:*(float*)[self samplePointer:sample]];
                    break;
                case sizeof(double):
                    result = [NSNumber numberWithDouble:*(double*)[self samplePointer:sample]];
                    break;
            }
            break;
        case CPComplexFloatingPointDataType:
            [NSException raise:NSInvalidArgumentException format:@"Unsupported data type (BWComplexFloatingPointDataType)"];
            break;
    }
    
    return result;
}

-(void *)samplePointer:(NSUInteger)sample 
{
    NSParameterAssert(sample < self.nSamples);
    return (void*) ((char*)[self bytes] + sample*[self sampleBytes]);
}

-(NSString *)description 
{
    NSMutableString *s = [NSMutableString stringWithCapacity:self.nSamples];
    [s appendFormat:@"["];
    for(NSUInteger i=0; i<self.nSamples; i++) {
        [s appendFormat:@" %@",[self sampleValue:i]];
    }
    [s appendFormat:@" ] <%@,(%@)>", self.dtype, self.shape];
    
    return s;
}

#pragma mark NSCopying and NSMutableCopying
-(id)mutableCopyWithZone:(NSZone *)zone 
{
    if(NSShouldRetainWithZone(self, zone)) {
        return [self retain];
    }
    
    return [[CPMutableNumericData allocWithZone:zone] initWithData:self.data
                                                             dtype:self.dtype
                                                             shape:self.shape];
}

-(id)copyWithZone:(NSZone *)zone
{
    return [[[self class] allocWithZone:zone] initWithData:self.data
                                                     dtype:self.dtype
                                                     shape:self.shape];
}

#pragma mark NSCoding
-(id)replacementObjectForArchiver:(NSArchiver*)archiver {
    return [[[CPSerializedNumericData alloc] initWithData:self.data
                                                    dtype:self.dtype
                                                    shape:self.shape]
            autorelease];
}
@end

@implementation CPSerializedNumericData
@synthesize data;
@synthesize dtype;
@synthesize shape;

-(id)initWithData:(NSData *)d
            dtype:(CPNumericDataType)_dtype
            shape:(NSArray *)s 
{
    if( (self = [super init]) ) {
        self.data = d;
        self.dtype = _dtype;
        self.shape = s;
    }
    
    return self;
}

-(void)encodeWithCoder:(NSCoder *)encoder 
{
    //[super encodeWithCoder:encoder];
    
    CPNumericDataType _type = self.dtype;
    
    if([encoder allowsKeyedCoding]) {
        [encoder encodeObject:self.data forKey:@"data"];
        [encoder encodeObject:[NSValue valueWithBytes:&(_type)
                                             objCType:@encode(CPNumericDataType)]
                       forKey:@"dtype"];
        [encoder encodeObject:self.shape forKey:@"shape"];
    } else {
        [encoder encodeDataObject:self.data];
        [encoder encodeObject:[NSValue valueWithBytes:&(_type)
                                             objCType:@encode(CPNumericDataType)]];
        [encoder encodeObject:self.shape];
    }
}

-(id)initWithCoder:(NSCoder *)decoder 
{    
    self = [super init]; //initWithCoder:decoder];
    
    if([decoder allowsKeyedCoding]) {
        self.data = [decoder decodeObjectForKey:@"data"];
        
        NSValue *dtypeValue = [decoder decodeObjectForKey:@"dtype"];
        CPNumericDataType _dtype;
        [dtypeValue getValue:&_dtype];
        self.dtype = _dtype;
        
        self.shape = [decoder decodeObjectForKey:@"shape"];
    } else {
        self.data = [decoder decodeDataObject];
        
        NSValue *dtypeValue = [decoder decodeObject];
        CPNumericDataType _dtype;
        [dtypeValue getValue:&_dtype];
        self.dtype = _dtype;
        
        
        self.shape = [decoder decodeObject];
    }
    
    return self;
}

-(id)awakeAfterUsingCoder:(NSCoder *)decoder 
{
    CPNumericData *replacement = [[CPNumericData alloc] initWithData:self.data
                                                               dtype:self.dtype
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

