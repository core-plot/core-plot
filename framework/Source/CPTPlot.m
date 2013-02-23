#import "CPTPlot.h"

#import "CPTExceptions.h"
#import "CPTFill.h"
#import "CPTGraph.h"
#import "CPTLegend.h"
#import "CPTLineStyle.h"
#import "CPTMutableNumericData+TypeConversion.h"
#import "CPTMutablePlotRange.h"
#import "CPTPathExtensions.h"
#import "CPTPlotArea.h"
#import "CPTPlotAreaFrame.h"
#import "CPTPlotSpace.h"
#import "CPTPlotSpaceAnnotation.h"
#import "CPTShadow.h"
#import "CPTTextLayer.h"
#import "CPTUtilities.h"
#import "NSCoderExtensions.h"
#import <tgmath.h>

/** @defgroup plotAnimation Plots
 *  @brief Plot properties that can be animated using Core Animation.
 *  @if MacOnly
 *  @since Custom layer property animation is supported on MacOS 10.6 and later.
 *  @endif
 *  @ingroup animation
 **/

/** @defgroup plotAnimationAllPlots All Plots
 *  @brief Plot properties that can be animated using Core Animation for all plot types.
 *  @ingroup plotAnimation
 **/

/** @if MacOnly
 *  @defgroup plotBindings Plot Binding Identifiers
 *  @brief Binding identifiers for all plots.
 *  @endif
 **/

/** @if MacOnly
 *  @defgroup plotBindingsAllPlots Bindings For All Plots
 *  @brief Binding identifiers for all plots.
 *  @ingroup plotBindings
 *  @endif
 **/

NSString *const CPTPlotBindingDataLabels = @"dataLabels"; ///< Plot data labels.

/// @cond
@interface CPTPlot()

@property (nonatomic, readwrite, assign) BOOL dataNeedsReloading;
@property (nonatomic, readwrite, retain) NSMutableDictionary *cachedData;

@property (nonatomic, readwrite, assign) BOOL needsRelabel;
@property (nonatomic, readwrite, assign) NSRange labelIndexRange;
@property (nonatomic, readwrite, retain) NSMutableArray *labelAnnotations;
@property (nonatomic, readwrite, copy) NSArray *dataLabels;

@property (nonatomic, readwrite, assign) NSUInteger cachedDataCount;

-(CPTMutableNumericData *)numericDataForNumbers:(id)numbers;
-(void)setCachedDataType:(CPTNumericDataType)newDataType;
-(void)updateContentAnchorForLabel:(CPTPlotSpaceAnnotation *)label;

@end

/// @endcond

#pragma mark -

/** @brief An abstract plot class.
 *
 *  Each data series on the graph is represented by a plot. Data is provided by
 *  a datasource that conforms to the CPTPlotDataSource protocol.
 *  @if MacOnly
 *  Plots also support data binding on MacOS.
 *  @endif
 *
 *  A Core Plot plot will request its data from the datasource when it is first displayed.
 *  You can force it to load new data in several ways:
 *  - Call @link CPTGraph::reloadData -reloadData @endlink on the graph to reload all plots.
 *  - Call @link CPTPlot::reloadData -reloadData @endlink on the plot to reload all of the data for only that plot.
 *  - Call @link CPTPlot::reloadDataInIndexRange: -reloadDataInIndexRange: @endlink on the plot to reload a range
 *    of data indices without changing the total number of data points.
 *  - Call @link CPTPlot::insertDataAtIndex:numberOfRecords: -insertDataAtIndex:numberOfRecords: @endlink
 *    to insert new data at the given index. Any data at higher indices will be moved to make room.
 *    Only the new data will be requested from the datasource.
 *
 *  You can also remove data from the plot without reloading anything by using the
 *  @link CPTPlot::deleteDataInIndexRange: -deleteDataInIndexRange: @endlink method.
 *
 *  @see See @ref plotAnimation "Plots" for a list of animatable properties supported by each plot type.
 *  @if MacOnly
 *  @see See @ref plotBindings "Plot Bindings" for a list of binding identifiers supported by each plot type.
 *  @endif
 **/
@implementation CPTPlot

@dynamic dataLabels;

/** @property __cpt_weak id<CPTPlotDataSource> dataSource
 *  @brief The data source for the plot.
 **/
@synthesize dataSource;

/** @property NSString *title
 *  @brief The title of the plot displayed in the legend.
 **/
@synthesize title;

/** @property CPTPlotSpace *plotSpace
 *  @brief The plot space for the plot.
 **/
@synthesize plotSpace;

/** @property CPTPlotArea *plotArea
 *  @brief The plot area for the plot.
 **/
@dynamic plotArea;

/** @property BOOL dataNeedsReloading
 *  @brief If @YES, the plot data will be reloaded from the data source before the layer content is drawn.
 **/
@synthesize dataNeedsReloading;

@synthesize cachedData;

/** @property NSUInteger cachedDataCount
 *  @brief The number of data points stored in the cache.
 **/
@synthesize cachedDataCount;

/** @property BOOL doublePrecisionCache
 *  @brief If @YES, the cache holds data of type @double, otherwise it holds @ref NSDecimal.
 **/
@dynamic doublePrecisionCache;

/** @property CPTPlotCachePrecision cachePrecision
 *  @brief The numeric precision used to cache the plot data and perform all plot calculations. Defaults to #CPTPlotCachePrecisionAuto.
 **/
@synthesize cachePrecision;

/** @property CPTNumericDataType doubleDataType
 *  @brief The CPTNumericDataType used to cache plot data as @double.
 **/
@dynamic doubleDataType;

/** @property CPTNumericDataType decimalDataType
 *  @brief The CPTNumericDataType used to cache plot data as @ref NSDecimal.
 **/
@dynamic decimalDataType;

/** @property BOOL needsRelabel
 *  @brief If @YES, the plot needs to be relabeled before the layer content is drawn.
 **/
@synthesize needsRelabel;

/** @property CGFloat labelOffset
 *  @brief The distance that labels should be offset from their anchor points. The direction of the offset is defined by subclasses.
 *  @ingroup plotAnimationAllPlots
 **/
@synthesize labelOffset;

/** @property CGFloat labelRotation
 *  @brief The rotation of the data labels in radians.
 *  Set this property to @num{π/2} to have labels read up the screen, for example.
 *  @ingroup plotAnimationAllPlots
 **/
@synthesize labelRotation;

/** @property NSUInteger labelField
 *  @brief The plot field identifier of the data field used to generate automatic labels.
 **/
@synthesize labelField;

/** @property CPTTextStyle *labelTextStyle
 *  @brief The text style used to draw the data labels.
 *  Set this property to @nil to hide the data labels.
 **/
@synthesize labelTextStyle;

/** @property NSFormatter *labelFormatter
 *  @brief The number formatter used to format the data labels.
 *  Set this property to @nil to hide the data labels.
 *  If you need a non-numerical label, such as a date, you can use a formatter than turns
 *  the numerical plot coordinate into a string (e.g., @quote{Jan 10, 2010}).
 *  The CPTCalendarFormatter and CPTTimeFormatter classes are useful for this purpose.
 **/
@synthesize labelFormatter;

/** @property CPTShadow *labelShadow
 *  @brief The shadow applied to each data label.
 **/
@synthesize labelShadow;

@synthesize labelIndexRange;

@synthesize labelAnnotations;

/** @property BOOL alignsPointsToPixels
 *  @brief If @YES (the default), all plot points will be aligned to device pixels when drawing.
 **/
@synthesize alignsPointsToPixels;

#pragma mark -
#pragma mark Init/Dealloc

/// @cond

#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
#else
+(void)initialize
{
    if ( self == [CPTPlot class] ) {
        [self exposeBinding:CPTPlotBindingDataLabels];
    }
}

#endif

/// @endcond

/// @name Initialization
/// @{

/** @brief Initializes a newly allocated CPTPlot object with the provided frame rectangle.
 *
 *  This is the designated initializer. The initialized layer will have the following properties:
 *  - @ref cachedDataCount = @num{0}
 *  - @ref cachePrecision = #CPTPlotCachePrecisionAuto
 *  - @ref dataSource = @nil
 *  - @ref title = @nil
 *  - @ref plotSpace = @nil
 *  - @ref dataNeedsReloading = @NO
 *  - @ref needsRelabel = @YES
 *  - @ref labelOffset = @num{0.0}
 *  - @ref labelRotation = @num{0.0}
 *  - @ref labelField = @num{0}
 *  - @ref labelTextStyle = @nil
 *  - @ref labelFormatter = @nil
 *  - @ref labelShadow = @nil
 *  - @ref alignsPointsToPixels = @YES
 *  - @ref masksToBounds = @YES
 *  - @ref needsDisplayOnBoundsChange = @YES
 *
 *  @param newFrame The frame rectangle.
 *  @return The initialized CPTPlot object.
 **/
-(id)initWithFrame:(CGRect)newFrame
{
    if ( (self = [super initWithFrame:newFrame]) ) {
        cachedData           = [[NSMutableDictionary alloc] initWithCapacity:5];
        cachedDataCount      = 0;
        cachePrecision       = CPTPlotCachePrecisionAuto;
        dataSource           = nil;
        title                = nil;
        plotSpace            = nil;
        dataNeedsReloading   = NO;
        needsRelabel         = YES;
        labelOffset          = CPTFloat(0.0);
        labelRotation        = CPTFloat(0.0);
        labelField           = 0;
        labelTextStyle       = nil;
        labelFormatter       = nil;
        labelShadow          = nil;
        labelIndexRange      = NSMakeRange(0, 0);
        labelAnnotations     = nil;
        alignsPointsToPixels = YES;

        self.masksToBounds              = YES;
        self.needsDisplayOnBoundsChange = YES;
    }
    return self;
}

/// @}

/// @cond

-(id)initWithLayer:(id)layer
{
    if ( (self = [super initWithLayer:layer]) ) {
        CPTPlot *theLayer = (CPTPlot *)layer;

        cachedData           = [theLayer->cachedData retain];
        cachedDataCount      = theLayer->cachedDataCount;
        cachePrecision       = theLayer->cachePrecision;
        dataSource           = theLayer->dataSource;
        title                = [theLayer->title retain];
        plotSpace            = [theLayer->plotSpace retain];
        dataNeedsReloading   = theLayer->dataNeedsReloading;
        needsRelabel         = theLayer->needsRelabel;
        labelOffset          = theLayer->labelOffset;
        labelRotation        = theLayer->labelRotation;
        labelField           = theLayer->labelField;
        labelTextStyle       = [theLayer->labelTextStyle retain];
        labelFormatter       = [theLayer->labelFormatter retain];
        labelShadow          = [theLayer->labelShadow retain];
        labelIndexRange      = theLayer->labelIndexRange;
        labelAnnotations     = [theLayer->labelAnnotations retain];
        alignsPointsToPixels = theLayer->alignsPointsToPixels;
    }
    return self;
}

-(void)dealloc
{
    [cachedData release];
    [title release];
    [plotSpace release];
    [labelTextStyle release];
    [labelFormatter release];
    [labelShadow release];
    [labelAnnotations release];

    [super dealloc];
}

/// @endcond

#pragma mark -
#pragma mark NSCoding Methods

/// @cond

-(void)encodeWithCoder:(NSCoder *)coder
{
    [super encodeWithCoder:coder];

    if ( [self.dataSource conformsToProtocol:@protocol(NSCoding)] ) {
        [coder encodeConditionalObject:self.dataSource forKey:@"CPTPlot.dataSource"];
    }
    [coder encodeObject:self.title forKey:@"CPTPlot.title"];
    [coder encodeObject:self.plotSpace forKey:@"CPTPlot.plotSpace"];
    [coder encodeInt:self.cachePrecision forKey:@"CPTPlot.cachePrecision"];
    [coder encodeBool:self.needsRelabel forKey:@"CPTPlot.needsRelabel"];
    [coder encodeCGFloat:self.labelOffset forKey:@"CPTPlot.labelOffset"];
    [coder encodeCGFloat:self.labelRotation forKey:@"CPTPlot.labelRotation"];
    [coder encodeInteger:(NSInteger)self.labelField forKey:@"CPTPlot.labelField"];
    [coder encodeObject:self.labelTextStyle forKey:@"CPTPlot.labelTextStyle"];
    [coder encodeObject:self.labelFormatter forKey:@"CPTPlot.labelFormatter"];
    [coder encodeObject:self.labelShadow forKey:@"CPTPlot.labelShadow"];
    [coder encodeObject:[NSValue valueWithRange:self.labelIndexRange] forKey:@"CPTPlot.labelIndexRange"];
    [coder encodeObject:self.labelAnnotations forKey:@"CPTPlot.labelAnnotations"];
    [coder encodeBool:self.alignsPointsToPixels forKey:@"CPTPlot.alignsPointsToPixels"];

    // No need to archive these properties:
    // dataNeedsReloading
    // cachedData
    // cachedDataCount
}

-(id)initWithCoder:(NSCoder *)coder
{
    if ( (self = [super initWithCoder:coder]) ) {
        dataSource           = [coder decodeObjectForKey:@"CPTPlot.dataSource"];
        title                = [[coder decodeObjectForKey:@"CPTPlot.title"] copy];
        plotSpace            = [[coder decodeObjectForKey:@"CPTPlot.plotSpace"] retain];
        cachePrecision       = (CPTPlotCachePrecision)[coder decodeIntForKey : @"CPTPlot.cachePrecision"];
        needsRelabel         = [coder decodeBoolForKey:@"CPTPlot.needsRelabel"];
        labelOffset          = [coder decodeCGFloatForKey:@"CPTPlot.labelOffset"];
        labelRotation        = [coder decodeCGFloatForKey:@"CPTPlot.labelRotation"];
        labelField           = (NSUInteger)[coder decodeIntegerForKey : @"CPTPlot.labelField"];
        labelTextStyle       = [[coder decodeObjectForKey:@"CPTPlot.labelTextStyle"] copy];
        labelFormatter       = [[coder decodeObjectForKey:@"CPTPlot.labelFormatter"] retain];
        labelShadow          = [[coder decodeObjectForKey:@"CPTPlot.labelShadow"] retain];
        labelIndexRange      = [[coder decodeObjectForKey:@"CPTPlot.labelIndexRange"] rangeValue];
        labelAnnotations     = [[coder decodeObjectForKey:@"CPTPlot.labelAnnotations"] mutableCopy];
        alignsPointsToPixels = [coder decodeBoolForKey:@"CPTPlot.alignsPointsToPixels"];

        // support old archives
        if ( [coder containsValueForKey:@"CPTPlot.identifier"] ) {
            self.identifier = [coder decodeObjectForKey:@"CPTPlot.identifier"];
        }

        // init other properties
        cachedData         = [[NSMutableDictionary alloc] initWithCapacity:5];
        cachedDataCount    = 0;
        dataNeedsReloading = YES;
    }
    return self;
}

/// @endcond

#pragma mark -
#pragma mark Bindings

#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
#else

-(Class)valueClassForBinding:(NSString *)binding
{
    return [NSArray class];
}

#endif

#pragma mark -
#pragma mark Drawing

/// @cond

-(void)drawInContext:(CGContextRef)context
{
    [self reloadDataIfNeeded];
    [super drawInContext:context];

    id<CPTPlotDelegate> theDelegate = (id<CPTPlotDelegate>)self.delegate;
    if ( [theDelegate respondsToSelector:@selector(didFinishDrawing:)] ) {
        [theDelegate didFinishDrawing:self];
    }
}

/// @endcond

#pragma mark -
#pragma mark Animation

/// @cond

+(BOOL)needsDisplayForKey:(NSString *)aKey
{
    static NSArray *keys = nil;

    if ( !keys ) {
        keys = [[NSArray alloc] initWithObjects:
                @"labelOffset",
                @"labelRotation",
                nil];
    }

    if ( [keys containsObject:aKey] ) {
        return YES;
    }
    else {
        return [super needsDisplayForKey:aKey];
    }
}

/// @endcond

#pragma mark -
#pragma mark Layout

/// @cond

-(void)layoutSublayers
{
    [self relabel];
    [super layoutSublayers];
}

/// @endcond

#pragma mark -
#pragma mark Data Source

/**
 *  @brief Marks the receiver as needing the data source reloaded before the content is next drawn.
 **/
-(void)setDataNeedsReloading
{
    self.dataNeedsReloading = YES;
}

/**
 *  @brief Reload all plot data from the data source immediately.
 **/
-(void)reloadData
{
    [self.cachedData removeAllObjects];
    self.cachedDataCount = 0;
    [self reloadDataInIndexRange:NSMakeRange(0, [self.dataSource numberOfRecordsForPlot:self])];
}

/**
 *  @brief Reload plot data from the data source only if the data cache is out of date.
 **/
-(void)reloadDataIfNeeded
{
    if ( self.dataNeedsReloading ) {
        [self reloadData];
    }
}

/** @brief Reload plot data in the given index range from the data source immediately.
 *  @param indexRange The index range to load.
 **/
-(void)reloadDataInIndexRange:(NSRange)indexRange
{
    id<CPTPlotDataSource> theDataSource = (id<CPTPlotDataSource>)self.dataSource;

    NSParameterAssert(NSMaxRange(indexRange) <= [theDataSource numberOfRecordsForPlot:self]);

    self.dataNeedsReloading = NO;

    // Data labels
    if ( [theDataSource respondsToSelector:@selector(dataLabelsForPlot:recordIndexRange:)] ) {
        [self cacheArray:[theDataSource dataLabelsForPlot:self recordIndexRange:indexRange] forKey:CPTPlotBindingDataLabels atRecordIndex:indexRange.location];
    }
    else if ( [theDataSource respondsToSelector:@selector(dataLabelForPlot:recordIndex:)] ) {
        id nilObject          = [CPTPlot nilData];
        NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:indexRange.length];
        NSUInteger maxIndex   = NSMaxRange(indexRange);

        for ( NSUInteger idx = indexRange.location; idx < maxIndex; idx++ ) {
            CPTLayer *labelLayer = [theDataSource dataLabelForPlot:self recordIndex:idx];
            if ( labelLayer ) {
                [array addObject:labelLayer];
            }
            else {
                [array addObject:nilObject];
            }
        }

        [self cacheArray:array forKey:CPTPlotBindingDataLabels atRecordIndex:indexRange.location];
        [array release];
    }

    [self relabelIndexRange:indexRange];
}

/** @brief Insert records into the plot data cache at the given index.
 *  @param idx The starting index of the new records.
 *  @param numberOfRecords The number of records to insert.
 **/
-(void)insertDataAtIndex:(NSUInteger)idx numberOfRecords:(NSUInteger)numberOfRecords
{
    NSParameterAssert(idx <= self.cachedDataCount);
    Class numericClass = [CPTNumericData class];

    for ( id data in [self.cachedData allValues] ) {
        if ( [data isKindOfClass:numericClass] ) {
            CPTMutableNumericData *numericData = (CPTMutableNumericData *)data;
            size_t sampleSize                  = numericData.sampleBytes;
            size_t length                      = sampleSize * numberOfRecords;

            [(NSMutableData *)numericData.data increaseLengthBy:length];

            void *start        = [numericData samplePointer:idx];
            size_t bytesToMove = numericData.data.length - (idx + numberOfRecords) * sampleSize;
            if ( bytesToMove > 0 ) {
                memmove(start + length, start, bytesToMove);
            }
        }
        else {
            NSMutableArray *array = (NSMutableArray *)data;
            NSNull *nullObject    = [NSNull null];
            NSUInteger lastIndex  = idx + numberOfRecords - 1;
            for ( NSUInteger i = idx; i <= lastIndex; i++ ) {
                [array insertObject:nullObject atIndex:i];
            }
        }
    }

    self.cachedDataCount += numberOfRecords;
    [self reloadDataInIndexRange:NSMakeRange(idx, self.cachedDataCount - idx)];
}

/** @brief Delete records in the given index range from the plot data cache.
 *  @param indexRange The index range of the data records to remove.
 **/
-(void)deleteDataInIndexRange:(NSRange)indexRange
{
    NSParameterAssert(NSMaxRange(indexRange) <= self.cachedDataCount);
    Class numericClass = [CPTNumericData class];

    for ( id data in [self.cachedData allValues] ) {
        if ( [data isKindOfClass:numericClass] ) {
            CPTMutableNumericData *numericData = (CPTMutableNumericData *)data;
            size_t sampleSize                  = numericData.sampleBytes;
            void *start                        = [numericData samplePointer:indexRange.location];
            size_t length                      = sampleSize * indexRange.length;
            size_t bytesToMove                 = numericData.data.length - (indexRange.location + indexRange.length) * sampleSize;
            if ( bytesToMove > 0 ) {
                memmove(start, start + length, bytesToMove);
            }

            NSMutableData *dataBuffer = (NSMutableData *)numericData.data;
            dataBuffer.length -= length;
        }
        else {
            [(NSMutableArray *) data removeObjectsInRange:indexRange];
        }
    }

    self.cachedDataCount -= indexRange.length;
    [self relabelIndexRange:NSMakeRange(indexRange.location, self.cachedDataCount - indexRange.location)];
    [self setNeedsDisplay];
}

/**
 *  @brief A unique marker object used in collections to indicate that the datasource returned @nil.
 **/
+(id)nilData
{
    static id nilObject = nil;

    if ( !nilObject ) {
        nilObject = [[NSObject alloc] init];
    }

    return nilObject;
}

/** @brief Gets a range of plot data for the given plot and field.
 *  @param fieldEnum The field index.
 *  @param indexRange The range of the data indexes of interest.
 *  @return An array of data points.
 **/
-(id)numbersFromDataSourceForField:(NSUInteger)fieldEnum recordIndexRange:(NSRange)indexRange
{
    id numbers; // can be CPTNumericData, NSArray, or NSData

    id<CPTPlotDataSource> theDataSource = self.dataSource;

    if ( theDataSource ) {
        if ( [theDataSource respondsToSelector:@selector(dataForPlot:field:recordIndexRange:)] ) {
            numbers = [theDataSource dataForPlot:self field:fieldEnum recordIndexRange:indexRange];
        }
        else if ( [theDataSource respondsToSelector:@selector(doublesForPlot:field:recordIndexRange:)] ) {
            numbers = [NSMutableData dataWithLength:sizeof(double) * indexRange.length];
            double *fieldValues  = [numbers mutableBytes];
            double *doubleValues = [theDataSource doublesForPlot:self field:fieldEnum recordIndexRange:indexRange];
            memcpy(fieldValues, doubleValues, sizeof(double) * indexRange.length);
        }
        else if ( [theDataSource respondsToSelector:@selector(numbersForPlot:field:recordIndexRange:)] ) {
            numbers = [NSArray arrayWithArray:[theDataSource numbersForPlot:self field:fieldEnum recordIndexRange:indexRange]];
        }
        else if ( [theDataSource respondsToSelector:@selector(doubleForPlot:field:recordIndex:)] ) {
            NSUInteger recordIndex;
            NSMutableData *fieldData = [NSMutableData dataWithLength:sizeof(double) * indexRange.length];
            double *fieldValues      = [fieldData mutableBytes];
            for ( recordIndex = indexRange.location; recordIndex < indexRange.location + indexRange.length; ++recordIndex ) {
                double number = [theDataSource doubleForPlot:self field:fieldEnum recordIndex:recordIndex];
                *fieldValues++ = number;
            }
            numbers = fieldData;
        }
        else {
            BOOL respondsToSingleValueSelector = [theDataSource respondsToSelector:@selector(numberForPlot:field:recordIndex:)];
            NSNull *nullObject                 = [NSNull null];
            NSUInteger recordIndex;
            NSMutableArray *fieldValues = [NSMutableArray arrayWithCapacity:indexRange.length];
            for ( recordIndex = indexRange.location; recordIndex < indexRange.location + indexRange.length; recordIndex++ ) {
                if ( respondsToSingleValueSelector ) {
                    NSNumber *number = [theDataSource numberForPlot:self field:fieldEnum recordIndex:recordIndex];
                    if ( number ) {
                        [fieldValues addObject:number];
                    }
                    else {
                        [fieldValues addObject:nullObject];
                    }
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

/** @brief Gets a range of plot data for the given plot.
 *  @param indexRange The range of the data indexes of interest.
 *  @return Returns @YES if the datasource implements the
 *  @link CPTPlotDataSource::dataForPlot:recordIndexRange: -dataForPlot:recordIndexRange: @endlink
 *  method and it returns valid data.
 **/
-(BOOL)loadNumbersForAllFieldsFromDataSourceInRecordIndexRange:(NSRange)indexRange
{
    BOOL hasData = NO;

    id<CPTPlotDataSource> theDataSource = self.dataSource;

    if ( [theDataSource respondsToSelector:@selector(dataForPlot:recordIndexRange:)] ) {
        CPTNumericData *data = [[theDataSource dataForPlot:self recordIndexRange:indexRange] retain];

        if ( [data isKindOfClass:[CPTNumericData class]] ) {
            const NSUInteger sampleCount = data.numberOfSamples;
            CPTNumericDataType dataType  = data.dataType;

            NSArray *theShape           = data.shape;
            const NSUInteger rowCount   = [[theShape objectAtIndex:0] unsignedIntegerValue];
            const NSUInteger fieldCount = [[theShape objectAtIndex:1] unsignedIntegerValue];

            if ( (sampleCount > 0) && (fieldCount > 0) && (data.numberOfDimensions == 2) ) {
                // convert data type if needed
                switch ( self.cachePrecision ) {
                    case CPTPlotCachePrecisionAuto:
                        if ( self.doublePrecisionCache ) {
                            if ( !CPTDataTypeEqualToDataType(dataType, self.doubleDataType) ) {
                                CPTMutableNumericData *mutableData = [data mutableCopy];
                                mutableData.dataType = self.doubleDataType;
                                [data release];
                                data = mutableData;
                            }
                        }
                        else {
                            if ( !CPTDataTypeEqualToDataType(dataType, self.decimalDataType) ) {
                                CPTMutableNumericData *mutableData = [data mutableCopy];
                                mutableData.dataType = self.decimalDataType;
                                [data release];
                                data = mutableData;
                            }
                        }
                        break;

                    case CPTPlotCachePrecisionDecimal:
                        if ( !CPTDataTypeEqualToDataType(dataType, self.decimalDataType) ) {
                            CPTMutableNumericData *mutableData = [data mutableCopy];
                            mutableData.dataType = self.decimalDataType;
                            [data release];
                            data = mutableData;
                        }
                        break;

                    case CPTPlotCachePrecisionDouble:
                        if ( !CPTDataTypeEqualToDataType(dataType, self.doubleDataType) ) {
                            CPTMutableNumericData *mutableData = [data mutableCopy];
                            mutableData.dataType = self.doubleDataType;
                            [data release];
                            data = mutableData;
                        }
                        break;

                    default:
                        break;
                }

                // add the data to the cache
                const NSUInteger bufferLength = rowCount * dataType.sampleBytes;

                switch ( data.dataOrder ) {
                    case CPTDataOrderRowsFirst:
                    {
                        const void *sourceEnd = data.bytes + data.length;

                        for ( NSUInteger fieldNum = 0; fieldNum < fieldCount; fieldNum++ ) {
                            NSMutableData *tempData = [[NSMutableData alloc] initWithLength:bufferLength];

                            if ( CPTDataTypeEqualToDataType(dataType, self.doubleDataType) ) {
                                double *sourceData = [data samplePointerAtIndex:0, fieldNum];
                                double *destData   = tempData.mutableBytes;

                                while ( sourceData < (double *)sourceEnd ) {
                                    *destData++ = *sourceData;
                                    sourceData += fieldCount;
                                }
                            }
                            else {
                                NSDecimal *sourceData = [data samplePointerAtIndex:0, fieldNum];
                                NSDecimal *destData   = tempData.mutableBytes;

                                while ( sourceData < (NSDecimal *)sourceEnd ) {
                                    *destData++ = *sourceData;
                                    sourceData += fieldCount;
                                }
                            }

                            CPTMutableNumericData *tempNumericData = [[CPTMutableNumericData alloc] initWithData:tempData
                                                                                                        dataType:dataType
                                                                                                           shape:nil];
                            [tempData release];

                            [self cacheNumbers:tempNumericData forField:fieldNum atRecordIndex:indexRange.location];

                            [tempNumericData release];
                        }
                        hasData = YES;
                    }
                    break;

                    case CPTDataOrderColumnsFirst:
                        for ( NSUInteger fieldNum = 0; fieldNum < fieldCount; fieldNum++ ) {
                            NSData *tempData = [[NSData alloc] initWithBytesNoCopy:[data samplePointerAtIndex:0, fieldNum]
                                                                            length:bufferLength
                                                                      freeWhenDone:NO];

                            CPTMutableNumericData *tempNumericData = [[CPTMutableNumericData alloc] initWithData:tempData
                                                                                                        dataType:dataType
                                                                                                           shape:nil];
                            [tempData release];

                            [self cacheNumbers:tempNumericData forField:fieldNum atRecordIndex:indexRange.location];

                            [tempNumericData release];
                        }
                        hasData = YES;
                        break;

                    default:
                        break;
                }
            }
        }

        [data release];
    }

    return hasData;
}

#pragma mark -
#pragma mark Data Caching

-(NSUInteger)cachedDataCount
{
    [self reloadDataIfNeeded];
    return cachedDataCount;
}

/** @brief Copies an array of numbers to the cache.
 *  @param numbers An array of numbers to cache. Can be a CPTNumericData, NSArray, or NSData (NSData is assumed to be a c-style array of type @double).
 *  @param fieldEnum The field enumerator identifying the field.
 **/
-(void)cacheNumbers:(id)numbers forField:(NSUInteger)fieldEnum
{
    NSNumber *cacheKey = [NSNumber numberWithUnsignedInteger:fieldEnum];

    if ( numbers ) {
        CPTMutableNumericData *mutableNumbers = [self numericDataForNumbers:numbers];

        NSUInteger sampleCount = mutableNumbers.numberOfSamples;
        if ( sampleCount > 0 ) {
            [self.cachedData setObject:mutableNumbers forKey:cacheKey];
        }
        else {
            [self.cachedData removeObjectForKey:cacheKey];
        }

        self.cachedDataCount = sampleCount;

        switch ( self.cachePrecision ) {
            case CPTPlotCachePrecisionAuto:
                [self setCachedDataType:mutableNumbers.dataType];
                break;

            case CPTPlotCachePrecisionDouble:
                [self setCachedDataType:self.doubleDataType];
                break;

            case CPTPlotCachePrecisionDecimal:
                [self setCachedDataType:self.decimalDataType];
                break;
        }
    }
    else {
        [self.cachedData removeObjectForKey:cacheKey];
        self.cachedDataCount = 0;
    }
    self.needsRelabel = YES;
    [self setNeedsDisplay];
}

/** @brief Copies an array of numbers to replace a part of the cache.
 *  @param numbers An array of numbers to cache. Can be a CPTNumericData, NSArray, or NSData (NSData is assumed to be a c-style array of type @double).
 *  @param fieldEnum The field enumerator identifying the field.
 *  @param idx The index of the first data point to replace.
 **/
-(void)cacheNumbers:(id)numbers forField:(NSUInteger)fieldEnum atRecordIndex:(NSUInteger)idx
{
    if ( numbers ) {
        CPTMutableNumericData *mutableNumbers = [self numericDataForNumbers:numbers];

        NSUInteger sampleCount = mutableNumbers.numberOfSamples;
        if ( sampleCount > 0 ) {
            // Ensure the new data is the same type as the cache
            switch ( self.cachePrecision ) {
                case CPTPlotCachePrecisionAuto:
                    [self setCachedDataType:mutableNumbers.dataType];
                    break;

                case CPTPlotCachePrecisionDouble:
                {
                    CPTNumericDataType newType = self.doubleDataType;
                    [self setCachedDataType:newType];
                    mutableNumbers.dataType = newType;
                }
                break;

                case CPTPlotCachePrecisionDecimal:
                {
                    CPTNumericDataType newType = self.decimalDataType;
                    [self setCachedDataType:newType];
                    mutableNumbers.dataType = newType;
                }
                break;
            }

            // Ensure the data cache exists and is the right size
            NSNumber *cacheKey                   = [NSNumber numberWithUnsignedInteger:fieldEnum];
            CPTMutableNumericData *cachedNumbers = [self.cachedData objectForKey:cacheKey];
            if ( !cachedNumbers ) {
                cachedNumbers = [CPTMutableNumericData numericDataWithData:[NSData data]
                                                                  dataType:mutableNumbers.dataType
                                                                     shape:nil];
                [self.cachedData setObject:cachedNumbers forKey:cacheKey];
            }
            NSUInteger numberOfRecords = [self.dataSource numberOfRecordsForPlot:self];
            cachedNumbers.shape = [NSArray arrayWithObject:[NSNumber numberWithUnsignedInteger:numberOfRecords]];

            // Update the cache
            self.cachedDataCount = numberOfRecords;

            NSUInteger startByte = idx * cachedNumbers.sampleBytes;
            void *cachePtr       = cachedNumbers.mutableBytes + startByte;
            size_t numberOfBytes = MIN(mutableNumbers.data.length, cachedNumbers.data.length - startByte);
            memcpy(cachePtr, mutableNumbers.bytes, numberOfBytes);

            [self relabelIndexRange:NSMakeRange(idx, sampleCount)];
        }
        [self setNeedsDisplay];
    }
}

/// @cond

-(CPTMutableNumericData *)numericDataForNumbers:(id)numbers
{
    CPTMutableNumericData *mutableNumbers = nil;
    CPTNumericDataType loadedDataType;

    if ( [numbers isKindOfClass:[CPTNumericData class]] ) {
        mutableNumbers = [numbers mutableCopy];
        // ensure the numeric data is in a supported format; default to double if not already NSDecimal
        if ( !CPTDataTypeEqualToDataType(mutableNumbers.dataType, self.decimalDataType) &&
             !CPTDataTypeEqualToDataType(mutableNumbers.dataType, self.doubleDataType) ) {
            mutableNumbers.dataType = self.doubleDataType;
        }
    }
    else if ( [numbers isKindOfClass:[NSData class]] ) {
        loadedDataType = self.doubleDataType;
        mutableNumbers = [[CPTMutableNumericData alloc] initWithData:numbers dataType:loadedDataType shape:nil];
    }
    else if ( [numbers isKindOfClass:[NSArray class]] ) {
        if ( ( (NSArray *)numbers ).count == 0 ) {
            loadedDataType = self.doubleDataType;
        }
        else if ( [[(NSArray *) numbers objectAtIndex:0] isKindOfClass:[NSDecimalNumber class]] ) {
            loadedDataType = self.decimalDataType;
        }
        else {
            loadedDataType = self.doubleDataType;
        }

        mutableNumbers = [[CPTMutableNumericData alloc] initWithArray:numbers dataType:loadedDataType shape:nil];
    }
    else {
        [NSException raise:CPTException format:@"Unsupported number array format"];
    }

    return [mutableNumbers autorelease];
}

/// @endcond

-(BOOL)doublePrecisionCache
{
    BOOL result = NO;

    switch ( self.cachePrecision ) {
        case CPTPlotCachePrecisionAuto:
        {
            NSMutableDictionary *dataCache = self.cachedData;
            Class numberClass              = [NSNumber class];
            for ( id key in [dataCache allKeys] ) {
                if ( [key isKindOfClass:numberClass] ) {
                    result = CPTDataTypeEqualToDataType([(CPTMutableNumericData *)[dataCache objectForKey:key] dataType], self.doubleDataType);
                    break;
                }
            }
        }
        break;

        case CPTPlotCachePrecisionDouble:
            result = YES;
            break;

        default:
            // not double precision
            break;
    }
    return result;
}

/** @brief Retrieves an array of numbers from the cache.
 *  @param fieldEnum The field enumerator identifying the field.
 *  @return The array of cached numbers.
 **/
-(CPTMutableNumericData *)cachedNumbersForField:(NSUInteger)fieldEnum
{
    return [self.cachedData objectForKey:[NSNumber numberWithUnsignedInteger:fieldEnum]];
}

/** @brief Retrieves a single number from the cache.
 *  @param fieldEnum The field enumerator identifying the field.
 *  @param idx The index of the desired data value.
 *  @return The cached number.
 **/
-(NSNumber *)cachedNumberForField:(NSUInteger)fieldEnum recordIndex:(NSUInteger)idx
{
    CPTMutableNumericData *numbers = [self cachedNumbersForField:fieldEnum];

    return [numbers sampleValue:idx];
}

/** @brief Retrieves a single number from the cache.
 *  @param fieldEnum The field enumerator identifying the field.
 *  @param idx The index of the desired data value.
 *  @return The cached number or @NAN if no data is cached for the requested field.
 **/
-(double)cachedDoubleForField:(NSUInteger)fieldEnum recordIndex:(NSUInteger)idx
{
    CPTMutableNumericData *numbers = [self cachedNumbersForField:fieldEnum];

    if ( numbers ) {
        switch ( numbers.dataTypeFormat ) {
            case CPTFloatingPointDataType:
            {
                double *doubleNumber = (double *)[numbers samplePointer:idx];
                if ( doubleNumber ) {
                    return *doubleNumber;
                }
            }
            break;

            case CPTDecimalDataType:
            {
                NSDecimal *decimalNumber = (NSDecimal *)[numbers samplePointer:idx];
                if ( decimalNumber ) {
                    return CPTDecimalDoubleValue(*decimalNumber);
                }
            }
            break;

            default:
                [NSException raise:CPTException format:@"Unsupported data type format"];
                break;
        }
    }
    return NAN;
}

/** @brief Retrieves a single number from the cache.
 *  @param fieldEnum The field enumerator identifying the field.
 *  @param idx The index of the desired data value.
 *  @return The cached number or @NAN if no data is cached for the requested field.
 **/
-(NSDecimal)cachedDecimalForField:(NSUInteger)fieldEnum recordIndex:(NSUInteger)idx
{
    CPTMutableNumericData *numbers = [self cachedNumbersForField:fieldEnum];

    if ( numbers ) {
        switch ( numbers.dataTypeFormat ) {
            case CPTFloatingPointDataType:
            {
                double *doubleNumber = (double *)[numbers samplePointer:idx];
                if ( doubleNumber ) {
                    return CPTDecimalFromDouble(*doubleNumber);
                }
            }
            break;

            case CPTDecimalDataType:
            {
                NSDecimal *decimalNumber = (NSDecimal *)[numbers samplePointer:idx];
                if ( decimalNumber ) {
                    return *decimalNumber;
                }
            }
            break;

            default:
                [NSException raise:CPTException format:@"Unsupported data type format"];
                break;
        }
    }
    return CPTDecimalNaN();
}

/// @cond

-(void)setCachedDataType:(CPTNumericDataType)newDataType
{
    Class numberClass                   = [NSNumber class];
    NSMutableDictionary *dataDictionary = self.cachedData;

    for ( id key in [dataDictionary allKeys] ) {
        if ( [key isKindOfClass:numberClass] ) {
            CPTMutableNumericData *numericData = [dataDictionary objectForKey:key];
            numericData.dataType = newDataType;
        }
    }
}

/// @endcond

-(CPTNumericDataType)doubleDataType
{
    static CPTNumericDataType dataType;
    static BOOL initialized = NO;

    if ( !initialized ) {
        dataType    = CPTDataType( CPTFloatingPointDataType, sizeof(double), CFByteOrderGetCurrent() );
        initialized = YES;
    }

    return dataType;
}

-(CPTNumericDataType)decimalDataType
{
    static CPTNumericDataType dataType;
    static BOOL initialized = NO;

    if ( !initialized ) {
        dataType    = CPTDataType( CPTDecimalDataType, sizeof(NSDecimal), CFByteOrderGetCurrent() );
        initialized = YES;
    }

    return dataType;
}

/** @brief Retrieves an array of values from the cache.
 *  @param key The key identifying the field.
 *  @return The array of cached values.
 **/
-(NSArray *)cachedArrayForKey:(NSString *)key
{
    return [self.cachedData objectForKey:key];
}

/** @brief Retrieves a single value from the cache.
 *  @param key The key identifying the field.
 *  @param idx The index of the desired data value.
 *  @return The cached value or @nil if no data is cached for the requested key.
 **/
-(id)cachedValueForKey:(NSString *)key recordIndex:(NSUInteger)idx
{
    return [[self cachedArrayForKey:key] objectAtIndex:idx];
}

/** @brief Copies an array of arbitrary values to the cache.
 *  @param array An array of arbitrary values to cache.
 *  @param key The key identifying the field.
 **/
-(void)cacheArray:(NSArray *)array forKey:(NSString *)key
{
    if ( array ) {
        NSUInteger sampleCount = array.count;
        if ( sampleCount > 0 ) {
            [self.cachedData setObject:array forKey:key];
        }
        else {
            [self.cachedData removeObjectForKey:key];
        }

        self.cachedDataCount = sampleCount;
    }
    else {
        [self.cachedData removeObjectForKey:key];
        self.cachedDataCount = 0;
    }
}

/** @brief Copies an array of arbitrary values to replace a part of the cache.
 *  @param array An array of arbitrary values to cache.
 *  @param key The key identifying the field.
 *  @param idx The index of the first data point to replace.
 **/
-(void)cacheArray:(NSArray *)array forKey:(NSString *)key atRecordIndex:(NSUInteger)idx
{
    if ( array ) {
        NSUInteger sampleCount = array.count;
        if ( sampleCount > 0 ) {
            // Ensure the data cache exists and is the right size
            NSUInteger numberOfRecords   = [self.dataSource numberOfRecordsForPlot:self];
            NSMutableArray *cachedValues = [self.cachedData objectForKey:key];
            if ( !cachedValues ) {
                cachedValues = [NSMutableArray arrayWithCapacity:numberOfRecords];
                NSNull *nullObject = [NSNull null];
                for ( NSUInteger i = 0; i < numberOfRecords; i++ ) {
                    [cachedValues addObject:nullObject];
                }
                [self.cachedData setObject:cachedValues forKey:key];
            }

            // Update the cache
            self.cachedDataCount = numberOfRecords;
            [cachedValues replaceObjectsInRange:NSMakeRange(idx, sampleCount) withObjectsFromArray:array];
        }
    }
}

#pragma mark -
#pragma mark Data Ranges

/** @brief Determines the smallest plot range that fully encloses the data for a particular field.
 *  @param fieldEnum The field enumerator identifying the field.
 *  @return The plot range enclosing the data.
 **/
-(CPTPlotRange *)plotRangeForField:(NSUInteger)fieldEnum
{
    if ( self.dataNeedsReloading ) {
        [self reloadData];
    }
    CPTMutableNumericData *numbers = [self cachedNumbersForField:fieldEnum];
    CPTPlotRange *range            = nil;

    NSUInteger numberOfSamples = numbers.numberOfSamples;
    if ( numberOfSamples > 0 ) {
        if ( self.doublePrecisionCache ) {
            // TODO: Should use Accelerate framework for min and max as soon as the minimum iOS version is 4.0

            double min = INFINITY;
            double max = -INFINITY;

            const double *doubles    = (const double *)numbers.bytes;
            const double *lastSample = doubles + numberOfSamples;
            while ( doubles < lastSample ) {
                double value = *doubles++;

                if ( !isnan(value) ) {
                    min = MIN(min, value);
                    max = MAX(max, value);
                }
            }

            if ( max >= min ) {
                range = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(min) length:CPTDecimalFromDouble(max - min)];
            }
        }
        else {
            NSDecimal min = [[NSDecimalNumber maximumDecimalNumber] decimalValue];
            NSDecimal max = [[NSDecimalNumber minimumDecimalNumber] decimalValue];

            const NSDecimal *decimals   = (const NSDecimal *)numbers.bytes;
            const NSDecimal *lastSample = decimals + numberOfSamples;
            while ( decimals < lastSample ) {
                NSDecimal value = *decimals++;

                if ( !NSDecimalIsNotANumber(&value) ) {
                    if ( CPTDecimalLessThan(value, min) ) {
                        min = value;
                    }
                    if ( CPTDecimalGreaterThan(value, max) ) {
                        max = value;
                    }
                }
            }

            if ( CPTDecimalGreaterThanOrEqualTo(max, min) ) {
                range = [CPTPlotRange plotRangeWithLocation:min length:CPTDecimalSubtract(max, min)];
            }
        }
    }
    return range;
}

/** @brief Determines the smallest plot range that fully encloses the data for a particular coordinate.
 *  @param coord The coordinate identifier.
 *  @return The plot range enclosing the data.
 **/
-(CPTPlotRange *)plotRangeForCoordinate:(CPTCoordinate)coord
{
    NSArray *fields = [self fieldIdentifiersForCoordinate:coord];

    if ( fields.count == 0 ) {
        return nil;
    }

    CPTMutablePlotRange *unionRange = nil;
    for ( NSNumber *field in fields ) {
        CPTPlotRange *currentRange = [self plotRangeForField:field.unsignedIntValue];
        if ( !unionRange ) {
            unionRange = [[currentRange mutableCopy] autorelease];
        }
        else {
            [unionRange unionPlotRange:[self plotRangeForField:field.unsignedIntValue]];
        }
    }

    return unionRange;
}

#pragma mark -
#pragma mark Data Labels

/**
 *  @brief Marks the receiver as needing to update all data labels before the content is next drawn.
 *  @see @link CPTPlot::relabelIndexRange: -relabelIndexRange: @endlink
 **/
-(void)setNeedsRelabel
{
    self.labelIndexRange = NSMakeRange(0, self.cachedDataCount);
    self.needsRelabel    = YES;
}

/**
 *  @brief Updates the data labels in the labelIndexRange.
 **/
-(void)relabel
{
    if ( !self.needsRelabel ) {
        return;
    }

    self.needsRelabel = NO;

    NSNull *nullObject    = [NSNull null];
    Class nullClass       = [NSNull class];
    Class annotationClass = [CPTAnnotation class];

    CPTTextStyle *dataLabelTextStyle = self.labelTextStyle;
    NSFormatter *dataLabelFormatter  = self.labelFormatter;
    BOOL plotProvidesLabels          = dataLabelTextStyle && dataLabelFormatter;

    BOOL hasCachedLabels         = NO;
    NSMutableArray *cachedLabels = (NSMutableArray *)[self cachedArrayForKey:CPTPlotBindingDataLabels];
    for ( CPTLayer *label in cachedLabels ) {
        if ( ![label isKindOfClass:nullClass] ) {
            hasCachedLabels = YES;
            break;
        }
    }

    if ( !hasCachedLabels && !plotProvidesLabels ) {
        for ( CPTAnnotation *annotation in self.labelAnnotations ) {
            if ( [annotation isKindOfClass:annotationClass] ) {
                [self removeAnnotation:annotation];
            }
        }
        self.labelAnnotations = nil;
        return;
    }

    NSUInteger sampleCount = self.cachedDataCount;
    NSRange indexRange     = self.labelIndexRange;
    NSUInteger maxIndex    = NSMaxRange(indexRange);

    if ( !self.labelAnnotations ) {
        self.labelAnnotations = [NSMutableArray arrayWithCapacity:sampleCount];
    }

    CPTPlotSpace *thePlotSpace = self.plotSpace;
    CGFloat theRotation        = self.labelRotation;
    NSMutableArray *labelArray = self.labelAnnotations;
    NSUInteger oldLabelCount   = labelArray.count;
    id nilObject               = [CPTPlot nilData];

    CPTMutableNumericData *labelFieldDataCache = [self cachedNumbersForField:self.labelField];
    CPTShadow *theShadow                       = self.labelShadow;

    for ( NSUInteger i = indexRange.location; i < maxIndex; i++ ) {
        NSNumber *dataValue = [labelFieldDataCache sampleValue:i];

        CPTLayer *newLabelLayer;
        if ( isnan([dataValue doubleValue]) ) {
            newLabelLayer = nil;
        }
        else {
            newLabelLayer = [[self cachedValueForKey:CPTPlotBindingDataLabels recordIndex:i] retain];

            if ( ( (newLabelLayer == nil) || (newLabelLayer == nilObject) ) && plotProvidesLabels ) {
                NSString *labelString = [dataLabelFormatter stringForObjectValue:dataValue];
                newLabelLayer = [[CPTTextLayer alloc] initWithText:labelString style:dataLabelTextStyle];
            }

            if ( [newLabelLayer isKindOfClass:nullClass] || (newLabelLayer == nilObject) ) {
                [newLabelLayer release];
                newLabelLayer = nil;
            }
        }
        newLabelLayer.shadow = theShadow;

        CPTPlotSpaceAnnotation *labelAnnotation;
        if ( i < oldLabelCount ) {
            labelAnnotation = [labelArray objectAtIndex:i];
            if ( newLabelLayer ) {
                if ( [labelAnnotation isKindOfClass:nullClass] ) {
                    labelAnnotation = [[CPTPlotSpaceAnnotation alloc] initWithPlotSpace:thePlotSpace anchorPlotPoint:nil];
                    [labelArray replaceObjectAtIndex:i withObject:labelAnnotation];
                    [self addAnnotation:labelAnnotation];
                    [labelAnnotation release];
                }
            }
            else {
                if ( [labelAnnotation isKindOfClass:annotationClass] ) {
                    [labelArray replaceObjectAtIndex:i withObject:nullObject];
                    [self removeAnnotation:labelAnnotation];
                }
            }
        }
        else {
            if ( newLabelLayer ) {
                labelAnnotation = [[CPTPlotSpaceAnnotation alloc] initWithPlotSpace:thePlotSpace anchorPlotPoint:nil];
                [labelArray addObject:labelAnnotation];
                [self addAnnotation:labelAnnotation];
                [labelAnnotation release];
            }
            else {
                [labelArray addObject:nullObject];
            }
        }

        if ( newLabelLayer ) {
            labelAnnotation.contentLayer = newLabelLayer;
            labelAnnotation.rotation     = theRotation;
            [self positionLabelAnnotation:labelAnnotation forIndex:i];
            [self updateContentAnchorForLabel:labelAnnotation];

            [newLabelLayer release];
        }
    }

    // remove labels that are no longer needed
    while ( labelArray.count > sampleCount ) {
        CPTAnnotation *oldAnnotation = [labelArray objectAtIndex:labelArray.count - 1];
        if ( [oldAnnotation isKindOfClass:annotationClass] ) {
            [self removeAnnotation:oldAnnotation];
        }
        [labelArray removeLastObject];
    }
}

/** @brief Marks the receiver as needing to update a range of data labels before the content is next drawn.
 *  @param indexRange The index range needing update.
 *  @see setNeedsRelabel()
 **/
-(void)relabelIndexRange:(NSRange)indexRange
{
    self.labelIndexRange = indexRange;
    self.needsRelabel    = YES;
}

/// @cond

-(void)updateContentAnchorForLabel:(CPTPlotSpaceAnnotation *)label
{
    if ( label ) {
        CGPoint displacement = label.displacement;
        if ( CGPointEqualToPoint(displacement, CGPointZero) ) {
            displacement.y = CPTFloat(1.0); // put the label above the data point if zero displacement
        }
        CGFloat angle      = CPTFloat(M_PI) + atan2(displacement.y, displacement.x) - label.rotation;
        CGFloat newAnchorX = cos(angle);
        CGFloat newAnchorY = sin(angle);

        if ( ABS(newAnchorX) <= ABS(newAnchorY) ) {
            newAnchorX /= ABS(newAnchorY);
            newAnchorY  = signbit(newAnchorY) ? -CPTFloat(1.0) : CPTFloat(1.0);
        }
        else {
            newAnchorY /= ABS(newAnchorX);
            newAnchorX  = signbit(newAnchorX) ? -CPTFloat(1.0) : CPTFloat(1.0);
        }

        label.contentAnchorPoint = CPTPointMake( ( newAnchorX + CPTFloat(1.0) ) / CPTFloat(2.0), ( newAnchorY + CPTFloat(1.0) ) / CPTFloat(2.0) );
    }
}

/// @endcond

/**
 *  @brief Repositions all existing label annotations.
 **/
-(void)repositionAllLabelAnnotations
{
    NSArray *annotations  = self.labelAnnotations;
    NSUInteger labelCount = annotations.count;
    Class annotationClass = [CPTAnnotation class];

    for ( NSUInteger i = 0; i < labelCount; i++ ) {
        CPTPlotSpaceAnnotation *annotation = [annotations objectAtIndex:i];
        if ( [annotation isKindOfClass:annotationClass] ) {
            [self positionLabelAnnotation:annotation forIndex:i];
            [self updateContentAnchorForLabel:annotation];
        }
    }
}

#pragma mark -
#pragma mark Legends

/** @brief The number of legend entries provided by this plot.
 *  @return The number of legend entries.
 **/
-(NSUInteger)numberOfLegendEntries
{
    return 1;
}

/** @brief The title text of a legend entry.
 *  @param idx The index of the desired title.
 *  @return The title of the legend entry at the requested index.
 **/
-(NSString *)titleForLegendEntryAtIndex:(NSUInteger)idx
{
    NSString *legendTitle = self.title;

    if ( !legendTitle ) {
        if ( [self.identifier isKindOfClass:[NSString class]] ) {
            legendTitle = (NSString *)self.identifier;
        }
    }

    return legendTitle;
}

/** @brief Draws the legend swatch of a legend entry.
 *  Subclasses should call @super to draw the background fill and border.
 *  @param legend The legend being drawn.
 *  @param idx The index of the desired swatch.
 *  @param rect The bounding rectangle where the swatch should be drawn.
 *  @param context The graphics context to draw into.
 **/
-(void)drawSwatchForLegend:(CPTLegend *)legend atIndex:(NSUInteger)idx inRect:(CGRect)rect inContext:(CGContextRef)context
{
    CPTFill *theFill           = legend.swatchFill;
    CPTLineStyle *theLineStyle = legend.swatchBorderLineStyle;

    if ( theFill || theLineStyle ) {
        CGPathRef swatchPath;
        CGFloat radius = legend.swatchCornerRadius;
        if ( radius > 0.0 ) {
            radius     = MIN( MIN( radius, rect.size.width / CPTFloat(2.0) ), rect.size.height / CPTFloat(2.0) );
            swatchPath = CreateRoundedRectPath(rect, radius);
        }
        else {
            CGMutablePathRef mutablePath = CGPathCreateMutable();
            CGPathAddRect(mutablePath, NULL, rect);
            swatchPath = mutablePath;
        }

        if ( theFill ) {
            CGContextBeginPath(context);
            CGContextAddPath(context, swatchPath);
            [theFill fillPathInContext:context];
        }

        if ( theLineStyle ) {
            [theLineStyle setLineStyleInContext:context];
            CGContextBeginPath(context);
            CGContextAddPath(context, swatchPath);
            [theLineStyle strokePathInContext:context];
        }

        CGPathRelease(swatchPath);
    }
}

#pragma mark -
#pragma mark Responder Chain and User interaction

/// @name User Interaction
/// @{

/**
 *  @brief Informs the receiver that the user has
 *  @if MacOnly pressed the mouse button. @endif
 *  @if iOSOnly touched the screen. @endif
 *
 *
 *  If this plot has a delegate that responds to the
 *  @link CPTPlotDelegate::plot:dataLabelWasSelectedAtRecordIndex: -plot:dataLabelWasSelectedAtRecordIndex: @endlink and/or
 *  @link CPTPlotDelegate::plot:dataLabelWasSelectedAtRecordIndex:withEvent: -plot:dataLabelWasSelectedAtRecordIndex:withEvent: @endlink
 *  methods, the data labels are searched to find the index of the one containing the @par{interactionPoint}.
 *  The delegate method will be called and this method returns @YES if the @par{interactionPoint} is within a label.
 *  This method returns @NO if the @par{interactionPoint} is too far away from all of the data labels.
 *
 *  @param event The OS event.
 *  @param interactionPoint The coordinates of the interaction.
 *  @return Whether the event was handled or not.
 **/
-(BOOL)pointingDeviceDownEvent:(CPTNativeEvent *)event atPoint:(CGPoint)interactionPoint
{
    CPTGraph *theGraph = self.graph;

    if ( !theGraph || self.hidden ) {
        return NO;
    }

    id<CPTPlotDelegate> theDelegate = self.delegate;
    if ( [theDelegate respondsToSelector:@selector(plot:dataLabelWasSelectedAtRecordIndex:)] ||
         [theDelegate respondsToSelector:@selector(plot:dataLabelWasSelectedAtRecordIndex:withEvent:)] ) {
        // Inform delegate if a label was hit
        NSMutableArray *labelArray = self.labelAnnotations;
        NSUInteger labelCount      = labelArray.count;
        Class annotationClass      = [CPTAnnotation class];

        for ( NSUInteger idx = 0; idx < labelCount; idx++ ) {
            CPTPlotSpaceAnnotation *annotation = [labelArray objectAtIndex:idx];
            if ( [annotation isKindOfClass:annotationClass] ) {
                CPTLayer *labelLayer = annotation.contentLayer;
                if ( labelLayer && !labelLayer.hidden ) {
                    CGPoint labelPoint = [theGraph convertPoint:interactionPoint toLayer:labelLayer];

                    if ( CGRectContainsPoint(labelLayer.bounds, labelPoint) ) {
                        if ( [theDelegate respondsToSelector:@selector(plot:dataLabelWasSelectedAtRecordIndex:)] ) {
                            [theDelegate plot:self dataLabelWasSelectedAtRecordIndex:idx];
                        }
                        if ( [theDelegate respondsToSelector:@selector(plot:dataLabelWasSelectedAtRecordIndex:withEvent:)] ) {
                            [theDelegate plot:self dataLabelWasSelectedAtRecordIndex:idx withEvent:event];
                        }
                        return YES;
                    }
                }
            }
        }
    }

    return [super pointingDeviceDownEvent:event atPoint:interactionPoint];
}

/// @}

#pragma mark -
#pragma mark Accessors

/// @cond

-(NSArray *)dataLabels
{
    return [self cachedArrayForKey:CPTPlotBindingDataLabels];
}

-(void)setDataLabels:(NSArray *)newDataLabels
{
    [self cacheArray:newDataLabels forKey:CPTPlotBindingDataLabels];
    [self setNeedsRelabel];
}

-(void)setTitle:(NSString *)newTitle
{
    if ( newTitle != title ) {
        [title release];
        title = [newTitle copy];
        [[NSNotificationCenter defaultCenter] postNotificationName:CPTLegendNeedsLayoutForPlotNotification object:self];
    }
}

-(void)setDataSource:(id<CPTPlotDataSource>)newSource
{
    if ( newSource != dataSource ) {
        dataSource = newSource;
        [self setDataNeedsReloading];
    }
}

-(void)setDataNeedsReloading:(BOOL)newDataNeedsReloading
{
    if ( newDataNeedsReloading != dataNeedsReloading ) {
        dataNeedsReloading = newDataNeedsReloading;
        if ( dataNeedsReloading ) {
            [self setNeedsDisplay];
        }
    }
}

-(CPTPlotArea *)plotArea
{
    return self.graph.plotAreaFrame.plotArea;
}

-(void)setNeedsRelabel:(BOOL)newNeedsRelabel
{
    if ( newNeedsRelabel != needsRelabel ) {
        needsRelabel = newNeedsRelabel;
        if ( needsRelabel ) {
            [self setNeedsLayout];
        }
    }
}

-(void)setLabelTextStyle:(CPTTextStyle *)newStyle
{
    if ( newStyle != labelTextStyle ) {
        [labelTextStyle release];
        labelTextStyle = [newStyle copy];

        if ( labelTextStyle && !self.labelFormatter ) {
            NSNumberFormatter *newFormatter = [[NSNumberFormatter alloc] init];
            newFormatter.minimumIntegerDigits  = 1;
            newFormatter.maximumFractionDigits = 1;
            newFormatter.minimumFractionDigits = 1;
            self.labelFormatter                = newFormatter;
            [newFormatter release];
        }

        self.needsRelabel = YES;
    }
}

-(void)setLabelOffset:(CGFloat)newOffset
{
    if ( newOffset != labelOffset ) {
        labelOffset = newOffset;
        [self repositionAllLabelAnnotations];
    }
}

-(void)setLabelRotation:(CGFloat)newRotation
{
    if ( newRotation != labelRotation ) {
        labelRotation = newRotation;

        Class annotationClass = [CPTAnnotation class];
        for ( CPTPlotSpaceAnnotation *label in self.labelAnnotations ) {
            if ( [label isKindOfClass:annotationClass] ) {
                label.rotation = labelRotation;
                [self updateContentAnchorForLabel:label];
            }
        }
    }
}

-(void)setLabelFormatter:(NSFormatter *)newTickLabelFormatter
{
    if ( newTickLabelFormatter != labelFormatter ) {
        [labelFormatter release];
        labelFormatter    = [newTickLabelFormatter retain];
        self.needsRelabel = YES;
    }
}

-(void)setLabelShadow:(CPTShadow *)newLabelShadow
{
    if ( newLabelShadow != labelShadow ) {
        [labelShadow release];
        labelShadow = [newLabelShadow retain];

        Class annotationClass = [CPTAnnotation class];
        for ( CPTAnnotation *label in self.labelAnnotations ) {
            if ( [label isKindOfClass:annotationClass] ) {
                label.contentLayer.shadow = labelShadow;
            }
        }
    }
}

-(void)setCachePrecision:(CPTPlotCachePrecision)newPrecision
{
    if ( newPrecision != cachePrecision ) {
        cachePrecision = newPrecision;
        switch ( cachePrecision ) {
            case CPTPlotCachePrecisionAuto:
                // don't change data already in the cache
                break;

            case CPTPlotCachePrecisionDouble:
                [self setCachedDataType:self.doubleDataType];
                break;

            case CPTPlotCachePrecisionDecimal:
                [self setCachedDataType:self.decimalDataType];
                break;

            default:
                [NSException raise:NSInvalidArgumentException format:@"Invalid cache precision"];
                break;
        }
    }
}

-(void)setAlignsPointsToPixels:(BOOL)newAlignsPointsToPixels
{
    if ( newAlignsPointsToPixels != alignsPointsToPixels ) {
        alignsPointsToPixels = newAlignsPointsToPixels;
        [self setNeedsDisplay];
    }
}

-(void)setHidden:(BOOL)newHidden
{
    if ( newHidden != self.hidden ) {
        [super setHidden:newHidden];
        [self setNeedsRelabel];
    }
}

/// @endcond

@end

#pragma mark -

@implementation CPTPlot(AbstractMethods)

#pragma mark -
#pragma mark Fields

/** @brief Number of fields in a plot data record.
 *  @return The number of fields.
 **/
-(NSUInteger)numberOfFields
{
    return 0;
}

/** @brief Identifiers (enum values) identifying the fields.
 *  @return Array of NSNumber objects for the various field identifiers.
 **/
-(NSArray *)fieldIdentifiers
{
    return [NSArray array];
}

/** @brief The field identifiers that correspond to a particular coordinate.
 *  @param coord The coordinate for which the corresponding field identifiers are desired.
 *  @return Array of NSNumber objects for the field identifiers.
 **/
-(NSArray *)fieldIdentifiersForCoordinate:(CPTCoordinate)coord
{
    return [NSArray array];
}

#pragma mark -
#pragma mark Data Labels

/** @brief Adjusts the position of the data label annotation for the plot point at the given index.
 *  @param label The annotation for the data label.
 *  @param idx The data index for the label.
 **/
-(void)positionLabelAnnotation:(CPTPlotSpaceAnnotation *)label forIndex:(NSUInteger)idx
{
    // do nothing--implementation provided by subclasses
}

#pragma mark -
#pragma mark User Interaction

/**
 *  @brief Determines the index of the data element that is under the given point.
 *  @param point The coordinates of the interaction.
 *  @return The index of the data point that is under the given point or @ref NSNotFound if none was found.
 */
-(NSUInteger)dataIndexFromInteractionPoint:(CGPoint)point
{
    return NSNotFound;
}

@end
