
#import "CPScatterPlot.h"

static NSString *CPXValuesBindingContext = @"CPXValuesBindingContext";
static NSString *CPYValuesBindingContext = @"CPYValuesBindingContext";


@interface CPScatterPlot ()

@property (nonatomic, readwrite, retain) id observedObjectForXValues;
@property (nonatomic, readwrite, retain) id observedObjectForYValues;
@property (nonatomic, readwrite, copy) NSString *keyPathForXValues;
@property (nonatomic, readwrite, copy) NSString *keyPathForYValues;

@end


@implementation CPScatterPlot

@synthesize numericType;
@synthesize observedObjectForXValues;
@synthesize observedObjectForYValues;
@synthesize keyPathForXValues;
@synthesize keyPathForYValues;
@synthesize hasErrorBars;


+(void)initialize
{
    [self exposeBinding:@"xValues"];	
    [self exposeBinding:@"yValues"];	
}

-(id)init
{
    if (self = [super init]) {
        self.numericType = CPNumericTypeFloat;
    }
    return self;
}



-(void)dealloc
{
    self.keyPathForXValues = nil;
    self.keyPathForYValues = nil;
    self.observedObjectForXValues = nil;
    self.observedObjectForYValues = nil;
    [super dealloc];
}


-(void)bind:(NSString *)binding toObject:(id)observable withKeyPath:(NSString *)keyPath options:(NSDictionary *)options
{
    if ([binding isEqualToString:@"xValues"]) {
        [observable addObserver:self forKeyPath:keyPath options:0 context:CPXValuesBindingContext];
        self.observedObjectForXValues = observable;
        self.keyPathForXValues = keyPath;
    }
    else if ([binding isEqualToString:@"yValues"]) {
        [observable addObserver:self forKeyPath:keyPath options:0 context:CPYValuesBindingContext];
        self.observedObjectForYValues = observable;
        self.keyPathForYValues = keyPath;
    }
    else {
        [super bind:binding toObject:observable withKeyPath:keyPath options:options];
    }
    [self setNeedsDisplay];
}


-(void)unbind:(NSString *)bindingName
{
    if ([bindingName isEqualToString:@"xValues"]) {
		[observedObjectForXValues removeObserver:self forKeyPath:keyPathForXValues];
        self.observedObjectForXValues = nil;
        self.keyPathForXValues = nil;
    }	
    else if ([bindingName isEqualToString:@"yValues"]) {
		[observedObjectForYValues removeObserver:self forKeyPath:keyPathForYValues];
        self.observedObjectForYValues = nil;
        self.keyPathForYValues = nil;
    }	
	[super unbind:bindingName];
	[self setNeedsDisplay];
}


@end
