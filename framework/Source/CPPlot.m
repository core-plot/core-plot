
#import "CPPlot.h"
#import "CPPlotSpace.h"
#import "CPPlotRange.h"
#import "NSNumberExtensions.h"
#import "CPUtilities.h"

///	@cond
@interface CPPlot()

@property (nonatomic, readwrite, assign) BOOL dataNeedsReloading;
@property (nonatomic, readwrite, retain) NSMutableDictionary *cachedData;

@end
///	@endcond

/**	@brief An abstract plot class.
 *
 *	Each data series on the graph is represented by a plot.
 **/
@implementation CPPlot

/**	@property dataSource
 *	@brief The data source for the plot.
 **/
@synthesize dataSource;

/**	@property identifier
 *	@brief An object used to identify the plot in collections.
 **/
@synthesize identifier;

/**	@property plotSpace
 *	@brief The plot space for the plot.
 **/
@synthesize plotSpace;

/**	@property dataNeedsReloading
 *	@brief If YES, the plot data will be reloaded from the data source before the layer content is drawn.
 **/
@synthesize dataNeedsReloading;

@synthesize cachedData;

#pragma mark -
#pragma mark init/dealloc

-(id)initWithFrame:(CGRect)newFrame
{
	if ( self = [super initWithFrame:newFrame] ) {
		cachedData = nil;
		dataSource = nil;
		identifier = nil;
		plotSpace = nil;
        dataNeedsReloading = YES;
	}
	return self;
}

-(void)dealloc
{
	[cachedData release];
    [identifier release];
    [plotSpace release];
    [super dealloc];
}

#pragma mark -
#pragma mark Drawing

-(void)drawInContext:(CGContextRef)theContext
{
    if ( self.dataNeedsReloading ) [self reloadData];
    [super drawInContext:theContext];
}

#pragma mark -
#pragma mark Layout

+(CGFloat)defaultZPosition 
{
	return CPDefaultZPositionPlot;
}

#pragma mark -
#pragma mark Fields

/**	@brief Number of fields in a plot data record.
 *	@return The number of fields.
 **/
-(NSUInteger)numberOfFields 
{
    return 0;
}

/**	@brief Identifiers (enum values) identifying the fields.
 *	@return Array of NSNumbers for the various field identifiers.
 **/
-(NSArray *)fieldIdentifiers 
{
    return [NSArray array];
}

/**	@brief The field identifiers that correspond to a particular coordinate.
 *  @param coord The coordinate for which the corresponding field identifiers are desired.
 *	@return Array of NSNumbers for the field identifiers.
 **/
-(NSArray *)fieldIdentifiersForCoordinate:(CPCoordinate)coord 
{
    return [NSArray array];
}

#pragma mark -
#pragma mark Data Source

/**	@brief Reload data from the data source.
 **/
-(void)reloadData
{
    self.dataNeedsReloading = NO;
    [self setNeedsDisplay];
}

/**	@brief Gets a range of plot data for the given plot and field.
 *	@param fieldEnum The field index.
 *	@param indexRange The range of the data indexes of interest.
 *	@return An array of data points.
 **/
-(NSArray *)numbersFromDataSourceForField:(NSUInteger)fieldEnum recordIndexRange:(NSRange)indexRange 
{
    NSArray *numbers;
    
    if ( self.dataSource ) {
        if ( [self.dataSource respondsToSelector:@selector(numbersForPlot:field:recordIndexRange:)] ) {
            numbers = [NSArray arrayWithArray:[self.dataSource numbersForPlot:self field:fieldEnum recordIndexRange:indexRange]];
        }
        else {
            BOOL respondsToSingleValueSelector = [self.dataSource respondsToSelector:@selector(numberForPlot:field:recordIndex:)];
            NSUInteger recordIndex;
            NSMutableArray *fieldValues = [NSMutableArray arrayWithCapacity:indexRange.length];
            for ( recordIndex = indexRange.location; recordIndex < indexRange.location + indexRange.length; ++recordIndex ) {
                if ( respondsToSingleValueSelector ) {
                    NSNumber *number = [self.dataSource numberForPlot:self field:fieldEnum recordIndex:recordIndex];
                    [fieldValues addObject:number];
                }
                else {
                    [fieldValues addObject:[NSDecimalNumber zero]];
                }
            }
            numbers = fieldValues;
        }
    }
    else {
        numbers = [NSArray array];
    }
    
    return numbers;
}

/**	@brief Determines the record index range corresponding to a given range of data.
 *	This method is optional.
 *	@param plotRange The range expressed in data values.
 *	@return The range of record indexes.
 **/
-(NSRange)recordIndexRangeForPlotRange:(CPPlotRange *)plotRange 
{
    if ( nil == self.dataSource ) return NSMakeRange(0, 0);
    
    NSRange resultRange;
    if ( [self.dataSource respondsToSelector:@selector(recordIndexRangeForPlot:plotRange:)] ) {
        resultRange = [self.dataSource recordIndexRangeForPlot:self plotRange:plotRange];
    }
    else {
        resultRange = NSMakeRange(0, [self.dataSource numberOfRecordsForPlot:self]);
    }
    
    return resultRange;
}

#pragma mark -
#pragma mark Data Caching

/**	@brief Stores an array of numbers in the cache.
 *	@param numbers An array of numbers to cache.
 *	@param fieldEnum The field enumerator identifying the field.
 **/
-(void)cacheNumbers:(NSArray *)numbers forField:(NSUInteger)fieldEnum 
{
	if ( numbers == nil ) return;
    if ( cachedData == nil ) cachedData = [[NSMutableDictionary alloc] initWithCapacity:5];
    [cachedData setObject:[[numbers copy] autorelease] forKey:[NSNumber numberWithUnsignedInt:fieldEnum]];
}

/**	@brief Retrieves an array of numbers from the cache.
 *	@param fieldEnum The field enumerator identifying the field.
 *	@return The array of cached numbers.
 **/
-(NSArray *)cachedNumbersForField:(NSUInteger)fieldEnum 
{
    return [self.cachedData objectForKey:[NSNumber numberWithUnsignedInt:fieldEnum]];
}

#pragma mark -
#pragma mark Data Ranges

/**	@brief Determines the smallest plot range that fully encloses the data for a particular field.
 *	@param fieldEnum The field enumerator identifying the field.
 *	@return The plot range enclosing the data.
 **/
-(CPPlotRange *)plotRangeForField:(NSUInteger)fieldEnum 
{
    if ( self.dataNeedsReloading ) [self reloadData];
    NSArray *numbers = [self cachedNumbersForField:fieldEnum];
    NSNumber *min = [numbers valueForKeyPath:@"@min.self"];
    NSNumber *max = [numbers valueForKeyPath:@"@max.self"];
    NSDecimal length = CPDecimalSubtract([max decimalValue], [min decimalValue]);
    return [CPPlotRange plotRangeWithLocation:[min decimalValue] length:length];
}

/**	@brief Determines the smallest plot range that fully encloses the data for a particular coordinate.
 *	@param coord The coordinate identifier.
 *	@return The plot range enclosing the data.
 **/
-(CPPlotRange *)plotRangeForCoordinate:(CPCoordinate)coord 
{
    NSArray *fields = [self fieldIdentifiersForCoordinate:coord];
    if ( fields.count == 0 ) return nil;
    
    CPPlotRange *unionRange = [self plotRangeForField:[[fields lastObject] unsignedIntValue]];
    for ( NSNumber *field in fields ) {
        [unionRange unionPlotRange:[self plotRangeForField:field.unsignedIntValue]];
    }
    
    return unionRange;
}

#pragma mark -
#pragma mark Accessors

-(void)setDataSource:(id <CPPlotDataSource>)newSource 
{
    if ( newSource != dataSource ) {
        dataSource = newSource;
        self.dataNeedsReloading = YES;
		[self setNeedsDisplay];
    }
}

/**	@brief Marks the receiver as needing the data source reloaded before the content is next drawn.
 **/
-(void)setDataNeedsReloading
{
	self.dataNeedsReloading = YES;
    [self setNeedsDisplay];
}

@end
