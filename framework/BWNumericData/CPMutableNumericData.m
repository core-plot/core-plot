
#import "CPMutableNumericData.h"
#import "CPNumericData.h"
#import "NSExceptionExtensions.h"
#import "CPExceptions.h"

@interface CPSerializedMutableNumericData : NSObject <NSCoding> {
    NSMutableData *data;
    CPNumericDataType dtype;
    NSArray *shape;
}
@property (assign,readwrite) CPNumericDataType dtype;
@property (retain,readwrite) NSMutableData *data;
@property (retain,readwrite) NSArray *shape;

-(id)initWithData:(NSMutableData *)d
            dtype:(CPNumericDataType)dtype
            shape:(NSArray *)s;
@end

@interface CPMutableNumericData ()
@property (assign,readwrite) CPNumericDataType dtype;
@property (retain,readwrite) NSMutableData *data;
@property (copy,readwrite) NSArray *shape;

-(void)commonInitWithData:(NSMutableData *)_data
                    dtype:(CPNumericDataType)dtype
                    shape:(NSArray *)_shape;
@end

@implementation CPMutableNumericData

@synthesize dtype;
@synthesize data;
@synthesize shape;
@dynamic ndims;

-(id)initWithData:(NSMutableData *)_data
            dtype:(CPNumericDataType)_dtype
            shape:(NSArray *)_shape 
{
    
    if( (self = [super init]) ) {
        [self commonInitWithData:_data
                           dtype:_dtype
                           shape:_shape];
    }
    
    return self;
}

-(void)commonInitWithData:(NSMutableData *)_data
                    dtype:(CPNumericDataType)_dtype
                    shape:(NSArray *)_shape 
{
    self.data = _data;
    self.dtype = _dtype;
    
    NSUInteger sampleBytes = self.dtype.sampleBytes;
    if(_shape == nil) {
        self.shape = [NSArray arrayWithObject:[NSNumber numberWithUnsignedInt:[self.data length]/sampleBytes]];
    } else {
        NSUInteger prod = 1;
        for(NSNumber *cNum in _shape) {
            prod *= [cNum unsignedIntValue];
        }
        
        if(prod != [self.data length]/sampleBytes) {
            [NSException raise:CPDataException 
                        format:@"Shape product (%u) does not match data size (%u)",prod,[self.data length]/sampleBytes];
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

-(void*)mutableBytes 
{
    return [[self data] mutableBytes];
}

-(NSUInteger)length 
{
    return [[self data] length];
}

#pragma mark NSCopying and NSMutableCopying
-(id)mutableCopyWithZone:(NSZone *)zone 
{
    return [[[self class] allocWithZone:zone] initWithData:self.data
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
-(id)replacementObjectForArchiver:(NSArchiver*)archiver 
{
    return [[[CPSerializedMutableNumericData alloc] initWithData:self.data
                                                           dtype:self.dtype
                                                           shape:self.shape]
            autorelease];
}
@end

@implementation CPSerializedMutableNumericData
@synthesize data;
@synthesize dtype;
@synthesize shape;

-(id)initWithData:(NSMutableData *)d
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
    
    if([encoder allowsKeyedCoding]) {
        [encoder encodeObject:self.data forKey:@"data"];
        [encoder encodeInteger:self.dtype.dataType forKey:@"dtype.dataType"];
        [encoder encodeInteger:self.dtype.sampleBytes forKey:@"dtype.sampleBytes"];
        [encoder encodeInteger:self.dtype.byteOrder forKey:@"dtype.byteOrder"];
        
        [encoder encodeObject:self.shape forKey:@"shape"];
    } else {
        CPNumericDataType _type = self.dtype;
        
        [encoder encodeObject:self.data];
        [encoder encodeValueOfObjCType:@encode(CPDataTypeFormat) at:&(_type.dataType)];
        [encoder encodeValueOfObjCType:@encode(NSInteger) at:&(_type.sampleBytes)];
        [encoder encodeValueOfObjCType:@encode(CFByteOrder) at:&(_type.byteOrder)];
        
        [encoder encodeObject:self.shape];
    }
}

-(id)initWithCoder:(NSCoder *)decoder 
{    
    self = [super init]; //initWithCoder:decoder];
    
    if([decoder allowsKeyedCoding]) {
        self.data = [decoder decodeObjectForKey:@"data"];
        
        
        
        self.dtype = CPDataType([decoder decodeIntegerForKey:@"dtype.dataType"],
                                [decoder decodeIntegerForKey:@"dtype.sampleBytes"],
                                [decoder decodeIntegerForKey:@"dtype.byteOrder"]);
        
        self.shape = [decoder decodeObjectForKey:@"shape"];
    } else {
        self.data = [decoder decodeObject];
        
        CPNumericDataType _type;
        [decoder decodeValueOfObjCType:@encode(CPDataTypeFormat) at:&(_type.dataType)];
        [decoder decodeValueOfObjCType:@encode(NSInteger) at:&(_type.sampleBytes)];
        [decoder decodeValueOfObjCType:@encode(CFByteOrder) at:&(_type.byteOrder)];
        
        self.dtype = _type;
        
        self.shape = [decoder decodeObject];
    }
    
    return self;
}


-(id)awakeAfterUsingCoder:(NSCoder *)decoder 
{
    CPMutableNumericData *replacement = [[CPMutableNumericData alloc] initWithData:self.data
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

