#import "CPGraph.h"
#import "CPPlot.h"
#import "CPPlotArea.h"
#import "CPPlotAreaFrame.h"
#import "CPPlotRange.h"
#import "CPPlotSpace.h"
#import "CPPlotSpaceAnnotation.h"
#import "CPTextLayer.h"
#import "NSNumberExtensions.h"
#import "CPUtilities.h"

///	@cond
@interface CPPlot()

@property (nonatomic, readwrite, assign) BOOL dataNeedsReloading;
@property (nonatomic, readwrite, retain) NSMutableDictionary *cachedData;

@property (nonatomic, readwrite, assign) BOOL needsRelabel;
@property (nonatomic, readwrite, assign) BOOL labelFormatterChanged;
@property (nonatomic, readwrite, assign) NSRange labelIndexRange;
@property (nonatomic, readwrite, retain) NSMutableArray *labelAnnotations;

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

/** @property delegate
 *	@brief The plot delegate.
 **/
@synthesize delegate;

/**	@property cachedDataCount
 *	@brief The number of data points stored in the cache.
 **/
@synthesize cachedDataCount;

/**	@property doublePrecisionCache
 *	@brief If YES, the cache holds data of type 'double', otherwise it holds NSNumber.
 **/
@synthesize doublePrecisionCache;

/**	@property needsRelabel
 *	@brief If YES, the plot needs to be relabeled before the layer content is drawn.
 **/
@synthesize needsRelabel;

/**	@property labelOffset
 *	@brief The distance that labels should be offset from their anchor points. The direction of the offset is defined by subclasses.
 **/
@synthesize labelOffset;

/**	@property labelRotation
 *	@brief The rotation of the data labels in radians.
 *  Set this property to <code>M_PI/2.0</code> to have labels read up the screen, for example.
 **/
@synthesize labelRotation;

/**	@property labelField
 *	@brief The plot field identifier of the data field used to generate automatic labels.
 **/
@synthesize labelField;

/**	@property labelTextStyle
 *	@brief The text style used to draw the data labels.
 *	Set this property to <code>nil</code> to hide the data labels.
 **/
@synthesize labelTextStyle;

/**	@property labelFormatter
 *	@brief The number formatter used to format the data labels.
 *	Set this property to <code>nil</code> to hide the data labels.
 *  If you need a non-numerical label, such as a date, you can use a formatter than turns
 *  the numerical plot coordinate into a string (eg 'Jan 10, 2010'). 
 *  The CPTimeFormatter is useful for this purpose.
 **/
@synthesize labelFormatter;

@synthesize labelFormatterChanged;

@synthesize labelIndexRange;

@synthesize labelAnnotations;

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
		needsRelabel = YES;
		labelOffset = 0.0;
		labelRotation = 0.0;
		labelField = 0;
		labelTextStyle = nil;
		labelFormatter = nil;
		labelFormatterChanged = YES;
		labelIndexRange = NSMakeRange(0, 0);
		labelAnnotations = nil;
		
		self.masksToBounds = YES;
	}
	return self;
}

-(void)dealloc
{
	[cachedData release];
    [identifier release];
    [plotSpace release];
	[labelTextStyle release];
	[labelFormatter release];
	[labelAnnotations release];

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

-(void)layoutSublayers 
{
	[self relabel];
    [super layoutSublayers];
}

#pragma mark -
#pragma mark Data Source

/**	@brief Marks the receiver as needing the data source reloaded before the content is next drawn.
 **/
-(void)setDataNeedsReloading
{
	self.dataNeedsReloading = YES;
}

/**	@brief Reload data from the data source.
 **/
-(void)reloadData
{
    self.dataNeedsReloading = NO;
	self.needsRelabel = YES;
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
            for ( recordIndex = indexRange.location; recordIndex < indexRange.location + indexRange.length; recordIndex++ ) {
                if ( respondsToSingleValueSelector ) {
                    NSNumber *number = [self.dataSource numberForPlot:self field:fieldEnum recordIndex:recordIndex];
					if ( number ) {
						[fieldValues addObject:number];
					}
					else {
						[fieldValues addObject:[NSNull null]];
					}

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
 *	@param plotRange The range expressed in data values.
 *	@return The range of record indexes.
 *	Returns <code>{0, numberOfRecords}</code> if the datasource does not implement the 
 *	-recordIndexRangeForPlot:plotRange: method.
 **/
-(NSRange)recordIndexRangeForPlotRange:(CPPlotRange *)plotRange 
{
    if ( nil == self.dataSource ) return NSMakeRange(0, 0);
    
    NSRange resultRange;
	id <CPPlotDataSource> theDataSource = self.dataSource;
    if ( [theDataSource respondsToSelector:@selector(recordIndexRangeForPlot:plotRange:)] ) {
        resultRange = [theDataSource recordIndexRangeForPlot:self plotRange:plotRange];
    }
    else {
        resultRange = NSMakeRange(0, [theDataSource numberOfRecordsForPlot:self]);
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

/**	@brief Retrieves a single number from the cache.
 *	@param fieldEnum The field enumerator identifying the field.
 *	@param index The index of the desired data value.
 *	@return The cached number.
 **/
-(NSNumber *)cachedNumberForField:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index
{
    id numbers = [self cachedNumbersForField:fieldEnum];
	if ( [numbers isKindOfClass:[NSArray class]] ) {
		NSArray *numberArray = (NSArray *)numbers;
		if ( index < numberArray.count ) {
			return [numberArray objectAtIndex:index];
		}
	}
	else {
		NSData *numberData = (NSData *)numbers;
		if ( index * sizeof(double) < numberData.length ) {
			const double *doubleData = numberData.bytes;
			return [NSNumber numberWithDouble:doubleData[index]];
		}
	}
	return nil;
}

/**	@brief Retrieves a single number from the cache.
 *	@param fieldEnum The field enumerator identifying the field.
 *	@param index The index of the desired data value.
 *	@return The cached number.
 **/
-(double)cachedDoubleForField:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index
{
    id numbers = [self cachedNumbersForField:fieldEnum];
	if ( [numbers isKindOfClass:[NSArray class]] ) {
		NSArray *numberArray = (NSArray *)numbers;
		if ( index < numberArray.count ) {
			return [[numberArray objectAtIndex:index] doubleValue];
		}
	}
	else {
		NSData *numberData = (NSData *)numbers;
		if ( index * sizeof(double) < numberData.length ) {
			const double *doubleData = numberData.bytes;
			return doubleData[index];
		}
	}
	return NAN;
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
#pragma mark Data Labels

/**	@brief Marks the receiver as needing to update the labels before the content is next drawn.
 **/
-(void)setNeedsRelabel
{
    self.needsRelabel = YES;
}

/**	@brief Updates the data labels.
 **/
-(void)relabel
{
    if ( !self.needsRelabel ) return;
	NSLog(@"relabel %@", self);
	
    self.needsRelabel = NO;

	id <CPPlotDataSource> theDataSource = self.dataSource;
	CPTextStyle *dataLabelTextStyle = self.labelTextStyle;
	NSNumberFormatter *dataLabelFormatter = self.labelFormatter;
	
	BOOL dataSourceProvidesLabels = [theDataSource respondsToSelector:@selector(dataLabelForPlot:recordIndex:)];
	BOOL plotProvidesLabels = dataLabelTextStyle && dataLabelFormatter;
	
	if ( !dataSourceProvidesLabels && !plotProvidesLabels ) {
		Class annotationClass = [CPAnnotation class];
		for ( CPAnnotation *annotation in self.labelAnnotations) {
			if ( [annotation isKindOfClass:annotationClass] ) {
				[self removeAnnotation:annotation];
			}
		}
		self.labelAnnotations = nil;
		return;
	}
	
	NSLog(@"Generate labels");
	
	NSRange indexRange = self.labelIndexRange;
	if ( !self.labelAnnotations ) {
		self.labelAnnotations = [NSMutableArray arrayWithCapacity:indexRange.length];
	}
	
	CPPlotSpace *thePlotSpace = self.plotSpace;
	NSMutableArray *labelArray = self.labelAnnotations;
	NSUInteger oldLabelCount = labelArray.count;
	Class nullClass = [NSNull class];
	id labelFieldDataCache = nil;
	BOOL doubleCache = self.doublePrecisionCache;
	
	for ( NSUInteger i = 0; i < indexRange.length; i++ ) {
		CPLayer *newLabelLayer = nil;
		
		if ( dataSourceProvidesLabels ) {
			newLabelLayer = [[theDataSource dataLabelForPlot:self recordIndex:indexRange.location + i] retain];
		}
		
		if ( !newLabelLayer && plotProvidesLabels ) {
			if ( !labelFieldDataCache ) {
				labelFieldDataCache = [self cachedNumbersForField:self.labelField];
			}
			NSNumber *dataValue;
			if ( doubleCache ) {
				const double *dataCacheBytes = [(NSData *)labelFieldDataCache bytes];
				double dataValueAsDouble = dataCacheBytes[indexRange.location + i];
				dataValue = [NSNumber numberWithDouble:dataValueAsDouble];
			}
			else {
				dataValue = [(NSArray *)labelFieldDataCache objectAtIndex:indexRange.location + i];
			}

			NSString *labelString = [dataLabelFormatter stringForObjectValue:dataValue];
			newLabelLayer = [[CPTextLayer alloc] initWithText:labelString style:dataLabelTextStyle];
		}
		
		if ( [newLabelLayer isKindOfClass:nullClass] ) {
			[newLabelLayer release];
			newLabelLayer = nil;
		}
		
		CPPlotSpaceAnnotation *labelAnnotation;
		if ( i < oldLabelCount ) {
			labelAnnotation = [labelArray objectAtIndex:i];
		}
		else {
			labelAnnotation = [[CPPlotSpaceAnnotation alloc] initWithPlotSpace:thePlotSpace anchorPlotPoint:nil];
			[labelArray addObject:labelAnnotation];
			[self addAnnotation:labelAnnotation];
			[labelAnnotation release];
		}

		labelAnnotation.contentLayer = newLabelLayer;
		[self positionLabelAnnotation:labelAnnotation forIndex:indexRange.location + i];
		
		[newLabelLayer release];
	}
	
	// remove labels that are no longer needed
	while ( labelArray.count > indexRange.length ) {
		CPAnnotation *oldAnnotation = [labelArray objectAtIndex:labelArray.count - 1];
		if ( [oldAnnotation isKindOfClass:[CPAnnotation class]] ) {
			[self removeAnnotation:oldAnnotation];
		}
		[labelArray removeLastObject];
	}
}	

/**	@brief Sets the labelIndexRange and informs the receiver that it needs to relabel.
 *	@param indexRange The new indexRange for the labels.
 *
 *	@todo Needs more documentation.
 **/
-(void)relabelIndexRange:(NSRange)indexRange
{
	self.labelIndexRange = indexRange;
	self.needsRelabel = YES;
}

#pragma mark -
#pragma mark Accessors

-(void)setDataSource:(id <CPPlotDataSource>)newSource 
{
    if ( newSource != dataSource ) {
        dataSource = newSource;
        [self setDataNeedsReloading];
    }
}

-(void)setDataNeedsReloading:(BOOL)newDataNeedsReloading
{
    if (newDataNeedsReloading != dataNeedsReloading) {
        dataNeedsReloading = newDataNeedsReloading;
        if ( dataNeedsReloading ) {
			[self setNeedsDisplay];
			[self setNeedsLayout];
        }
    }
}

-(CPPlotArea *)plotArea
{
	return self.graph.plotAreaFrame.plotArea;
}

-(void)setNeedsRelabel:(BOOL)newNeedsRelabel 
{
    if (newNeedsRelabel != needsRelabel) {
        needsRelabel = newNeedsRelabel;
        if ( needsRelabel ) {
            [self setNeedsLayout];
        }
    }
}

-(void)setLabelTextStyle:(CPTextStyle *)newStyle 
{
	if ( newStyle != labelTextStyle ) {
		[labelTextStyle release];
		labelTextStyle = [newStyle copy];

		if ( labelTextStyle && !self.labelFormatter ) {
			NSNumberFormatter *newFormatter = [[NSNumberFormatter alloc] init];
			newFormatter.minimumIntegerDigits = 1;
			newFormatter.maximumFractionDigits = 1; 
			newFormatter.minimumFractionDigits = 1;
			self.labelFormatter = newFormatter;
			[newFormatter release];
		}
		
		self.needsRelabel = YES;
	}
}

-(void)setLabelOffset:(CGFloat)newOffset 
{
    if ( newOffset != labelOffset ) {
        labelOffset = newOffset;
		self.needsRelabel = YES;
    }
}

-(void)setLabelRotation:(CGFloat)newRotation 
{
    if ( newRotation != labelRotation ) {
        labelRotation = newRotation;
		[self setNeedsLayout];
        self.needsRelabel = YES;
    }
}

-(void)setLabelFormatter:(NSNumberFormatter *)newTickLabelFormatter 
{
    if ( newTickLabelFormatter != labelFormatter ) {
        [labelFormatter release];
        labelFormatter = [newTickLabelFormatter retain];
		self.labelFormatterChanged = YES;
        self.needsRelabel = YES;
    }
}

@end

#pragma mark -

@implementation CPPlot(AbstractMethods)

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
#pragma mark Data Labels

/**	@brief Adjusts the position of the data label annotation for the plot point at the given index.
 *  @param label The annotation for the data label.
 *  @param index The data index for the label.
 **/
-(void)positionLabelAnnotation:(CPPlotSpaceAnnotation *)label forIndex:(NSUInteger)index
{
	// do nothing--implementation provided by subclasses
}

@end
