#import "CPGraph.h"
#import "CPPlot.h"
#import "CPPlotArea.h"
#import "CPPlotAreaFrame.h"
#import "CPPlotSpace.h"
#import "CPPlotRange.h"
#import "NSNumberExtensions.h"
#import "CPUtilities.h"

///	@cond
@interface CPPlot()

@property (nonatomic, readwrite, assign) BOOL dataNeedsReloading;
@property (nonatomic, readwrite, retain) NSMutableDictionary *cachedData;

@property (nonatomic, readwrite, assign) NSUInteger cachedDataCount;
@property (nonatomic, readwrite, assign) BOOL doublePrecisionCache;

@end
///	@endcond

#pragma mark -

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

/**	@property plotArea
 *	@brief The plot area for the plot.
 **/
@dynamic plotArea;

/**	@property dataNeedsReloading
 *	@brief If YES, the plot data will be reloaded from the data source before the layer content is drawn.
 **/
@synthesize dataNeedsReloading;

@synthesize cachedData;

/**	@property cachedDataCount
 *	@brief The number of data points stored in the cache.
 **/
@synthesize cachedDataCount;

/**	@property doublePrecisionCache
 *	@brief If YES, the cache holds data of type 'double', otherwise it holds NSNumber.
 **/
@synthesize doublePrecisionCache;

#pragma mark -
#pragma mark init/dealloc

-(id)initWithFrame:(CGRect)newFrame
{
	if ( self = [super initWithFrame:newFrame] ) {
		cachedData = nil;
		cachedDataCount = 0;
		doublePrecisionCache = NO;
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
    [self reloadDataIfNeeded];
    [super drawInContext:theContext];
}

#pragma mark -
#pragma mark Layout

+(CGFloat)defaultZPosition 
{
	return CPDefaultZPositionPlot;
}

-(void)layoutSublayers {
	// do nothing
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
    [self setNeedsLayout];
}

/**	@brief Reload data from the data source only if the data cache is out of date.
 **/
-(void)reloadDataIfNeeded
{
	if ( self.dataNeedsReloading ) {
		[self reloadData];
	}
}

/**	@brief Gets a range of plot data for the given plot and field.
 *	@param fieldEnum The field index.
 *	@param indexRange The range of the data indexes of interest.
 *	@return An array of data points.
 **/
-(id)numbersFromDataSourceForField:(NSUInteger)fieldEnum recordIndexRange:(NSRange)indexRange 
{
    id numbers;  // could be NSArray or NSData
    
    if ( self.dataSource ) {
        if ( [self.dataSource respondsToSelector:@selector(doublesForPlot:field:recordIndexRange:)] ) {
            numbers = [NSMutableData dataWithLength:sizeof(double)*indexRange.length];
            double *fieldValues = [numbers mutableBytes];
            double *doubleValues = [self.dataSource doublesForPlot:self field:fieldEnum recordIndexRange:indexRange];
            memcpy( fieldValues, doubleValues, sizeof(double)*indexRange.length );
            self.doublePrecisionCache = YES;
        }
        else if ( [self.dataSource respondsToSelector:@selector(numbersForPlot:field:recordIndexRange:)] ) {
            numbers = [NSArray arrayWithArray:[self.dataSource numbersForPlot:self field:fieldEnum recordIndexRange:indexRange]];
            self.doublePrecisionCache = NO;
        }
        else if ( [self.dataSource respondsToSelector:@selector(doubleForPlot:field:recordIndex:)] ) {
            NSUInteger recordIndex;
            NSMutableData *fieldData = [NSMutableData dataWithLength:sizeof(double)*indexRange.length];
            double *fieldValues = [fieldData mutableBytes];
            for ( recordIndex = indexRange.location; recordIndex < indexRange.location + indexRange.length; ++recordIndex ) {
                double number = [self.dataSource doubleForPlot:self field:fieldEnum recordIndex:recordIndex];
                *fieldValues++ = number;
            }
            numbers = fieldData;
            self.doublePrecisionCache = YES;
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
            self.doublePrecisionCache = NO;
        }
    }
    else {
        numbers = [NSArray array];
		self.doublePrecisionCache = NO;
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
-(void)cacheNumbers:(id)numbers forField:(NSUInteger)fieldEnum 
{
	if ( numbers == nil ) {
		self.cachedDataCount = 0;
		return;
	}
	else if ( [numbers respondsToSelector:@selector(count)] ) {
		self.cachedDataCount = [(NSArray *)numbers count];
	}
	else {
		self.cachedDataCount = [(NSData *)numbers length] / sizeof(double);
	}
    if ( cachedData == nil ) cachedData = [[NSMutableDictionary alloc] initWithCapacity:5];
    [cachedData setObject:[[numbers copy] autorelease] forKey:[NSNumber numberWithUnsignedInteger:fieldEnum]];
}

/**	@brief Retrieves an array of numbers from the cache.
 *	@param fieldEnum The field enumerator identifying the field.
 *	@return The array of cached numbers.
 **/
-(id)cachedNumbersForField:(NSUInteger)fieldEnum 
{
    return [self.cachedData objectForKey:[NSNumber numberWithUnsignedInteger:fieldEnum]];
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
    CPPlotRange *range = nil;
    if ( numbers && numbers.count > 0 ) {
        NSNumber *min = [numbers valueForKeyPath:@"@min.self"];
        NSNumber *max = [numbers valueForKeyPath:@"@max.self"];
        NSDecimal length = CPDecimalSubtract([max decimalValue], [min decimalValue]);
        range = [CPPlotRange plotRangeWithLocation:[min decimalValue] length:length];
    }
    return range;
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
        [self setNeedsLayout];
    }
}

/**	@brief Marks the receiver as needing the data source reloaded before the content is next drawn.
 **/
-(void)setDataNeedsReloading
{
	self.dataNeedsReloading = YES;
    [self setNeedsDisplay];
    [self setNeedsLayout];
}

-(CPPlotArea *)plotArea
{
	return self.graph.plotAreaFrame.plotArea;
}

@end
