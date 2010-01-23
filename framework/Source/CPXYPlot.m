
#import "CPXYPlot.h"

NSString * const CPXYPlotBindingLowerErrorBarValues = @"lowerErrorBarValues";  ///< Lower error bar values.
NSString * const CPXYPlotBindingUpperErrorBarValues = @"upperErrorBarValues";	///< Upper error bar values.

static NSString * const CPLowerErrorValuesBindingContext = @"CPLowerErrorValuesBindingContext";
static NSString * const CPUpperErrorValuesBindingContext = @"CPUpperErrorValuesBindingContext";

/// @cond
@interface CPXYPlot ()

@property (nonatomic, readwrite, assign) id observedObjectForLowerErrorValues;
@property (nonatomic, readwrite, assign) id observedObjectForUpperErrorValues;

@property (nonatomic, readwrite, retain) NSValueTransformer *lowerErrorValuesTransformer;
@property (nonatomic, readwrite, retain) NSValueTransformer *upperErrorValuesTransformer;

@property (nonatomic, readwrite, copy) NSString *keyPathForLowerErrorValues;
@property (nonatomic, readwrite, copy) NSString *keyPathForUpperErrorValues;

@property (nonatomic, readwrite, copy) NSArray *lowerErrorValues;
@property (nonatomic, readwrite, copy) NSArray *upperErrorValues;

@end
/// @endcond

@implementation CPXYPlot

@synthesize observedObjectForLowerErrorValues;
@synthesize observedObjectForUpperErrorValues;
@synthesize lowerErrorValuesTransformer;
@synthesize upperErrorValuesTransformer;
@synthesize keyPathForLowerErrorValues;
@synthesize keyPathForUpperErrorValues;

#pragma mark -
#pragma mark Initialization and Dealloc

-(void)dealloc
{
	if ( observedObjectForLowerErrorValues ) [self unbind:CPXYPlotBindingLowerErrorBarValues];
	observedObjectForLowerErrorValues = nil;
	if ( observedObjectForUpperErrorValues ) [self unbind:CPXYPlotBindingUpperErrorBarValues];
	observedObjectForUpperErrorValues = nil;
        
	[keyPathForLowerErrorValues release];
	[keyPathForUpperErrorValues release];
	[lowerErrorValuesTransformer release];
    [upperErrorValuesTransformer release];
    
	[super dealloc];
}

#pragma mark -
#pragma mark Bindings

-(void)bind:(NSString *)binding toObject:(id)observable withKeyPath:(NSString *)keyPath options:(NSDictionary *)options
{
	[super bind:binding toObject:observable withKeyPath:keyPath options:options];
	if ([binding isEqualToString:CPXYPlotBindingLowerErrorBarValues]) {
		[observable addObserver:self forKeyPath:keyPath options:0 context:CPLowerErrorValuesBindingContext];
		self.observedObjectForLowerErrorValues = observable;
		self.keyPathForLowerErrorValues = keyPath;
		[self setDataNeedsReloading];
		
		NSString *transformerName = [options objectForKey:@"NSValueTransformerNameBindingOption"];
		if ( transformerName != nil ) {
            self.lowerErrorValuesTransformer = [NSValueTransformer valueTransformerForName:transformerName];
        }			
	}
	else if ([binding isEqualToString:CPXYPlotBindingUpperErrorBarValues]) {
		[observable addObserver:self forKeyPath:keyPath options:0 context:CPUpperErrorValuesBindingContext];
		self.observedObjectForUpperErrorValues = observable;
		self.keyPathForUpperErrorValues = keyPath;
		[self setDataNeedsReloading];
		
		NSString *transformerName = [options objectForKey:@"NSValueTransformerNameBindingOption"];
		if ( transformerName != nil ) {
            self.upperErrorValuesTransformer = [NSValueTransformer valueTransformerForName:transformerName];
        }			
	}
}

-(void)unbind:(NSString *)bindingName
{
	if ([bindingName isEqualToString:CPXYPlotBindingLowerErrorBarValues]) {
		[observedObjectForLowerErrorValues removeObserver:self forKeyPath:self.keyPathForLowerErrorValues];
		self.observedObjectForLowerErrorValues = nil;
		self.keyPathForLowerErrorValues = nil;
        self.lowerErrorValuesTransformer = nil;
		[self setDataNeedsReloading];
	}	
	else if ([bindingName isEqualToString:CPXYPlotBindingUpperErrorBarValues]) {
		[observedObjectForUpperErrorValues removeObserver:self forKeyPath:self.keyPathForUpperErrorValues];
		self.observedObjectForUpperErrorValues = nil;
		self.keyPathForUpperErrorValues = nil;
        self.upperErrorValuesTransformer = nil;
		[self setDataNeedsReloading];
	}	
	[super unbind:bindingName];
}

#pragma mark -
#pragma mark Accessors

-(void)setLowerErrorValues:(NSArray *)newValues 
{
    [self cacheNumbers:newValues forField:CPXYPlotLowerErrorBar];
}

-(NSArray *)lowerErrorValues 
{
    return [self cachedNumbersForField:CPXYPlotLowerErrorBar];
}

-(void)setUpperErrorValues:(NSArray *)newValues 
{
    [self cacheNumbers:newValues forField:CPXYPlotUpperErrorBar];
}

-(NSArray *)upperErrorValues 
{
    return [self cachedNumbersForField:CPXYPlotUpperErrorBar];
}

-(BOOL)hasErrorBars 
{
    return ( self.lowerErrorValues != nil && self.upperErrorValues != nil );
}

@end
