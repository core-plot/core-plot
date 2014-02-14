#import "CPTFunctionDataSource.h"

#import "CPTMutablePlotRange.h"
#import "CPTNumericData.h"
#import "CPTScatterPlot.h"
#import "CPTUtilities.h"
#import "CPTXYPlotSpace.h"
#import "tgmath.h"

/// @cond

static void *const CPTFunctionDataSourceKVOContext = (void *)&CPTFunctionDataSourceKVOContext;

@interface CPTFunctionDataSource()

@property (nonatomic, readwrite) double cachedStep;
@property (nonatomic, readwrite) NSUInteger dataCount;
@property (nonatomic, readwrite) NSUInteger cachedCount;
@property (nonatomic, readwrite, retain) CPTMutablePlotRange *cachedPlotRange;

-(void)plotBoundsChanged;
-(void)plotSpaceChanged;

@end

/// @endcond

#pragma mark -

/**
 *  @brief A datasource class that automatically creates scatter plot data from a function.
 **/
@implementation CPTFunctionDataSource

/** @property CPTDataSourceFunction dataSourceFunction
 *  @brief The function used to generate plot data.
 **/
@synthesize dataSourceFunction;

/** @property __cpt_weak CPTPlot *dataPlot
 *  @brief The plot that will display the function values. Must be an instance of CPTScatterPlot.
 **/
@synthesize dataPlot;

/** @property CGFloat resolution
 *  @brief The maximum number of pixels between data points on the plot. Default is @num{1.0}.
 **/
@synthesize resolution;

/** @property CPTPlotRange *dataRange
 *  @brief The maximum range of x-values that will be plotted. If @nil (the default), the function will be plotted for all visible x-values.
 **/
@synthesize dataRange;

@synthesize cachedStep;
@synthesize cachedCount;
@synthesize dataCount;
@synthesize cachedPlotRange;

#pragma mark -
#pragma mark Init/Dealloc

/** @brief Creates and returns a new CPTFunctionDataSource instance initialized with the provided function and plot.
 *  @param plot The plot that will display the function values.
 *  @param function The function used to generate plot data.
 *  @return A new CPTFunctionDataSource instance initialized with the provided function and plot.
 **/
+(id)dataSourceForPlot:(CPTPlot *)plot withFunction:(CPTDataSourceFunction)function
{
    return [[[self alloc] initForPlot:plot withFunction:function] autorelease];
}

/** @brief Initializes a newly allocated CPTFunctionDataSource object with the provided function and plot.
 *  @param plot The plot that will display the function values.
 *  @param function The function used to generate plot data.
 *  @return The initialized CPTFunctionDataSource object.
 **/
-(id)initForPlot:(CPTPlot *)plot withFunction:(CPTDataSourceFunction)function
{
    NSParameterAssert([plot isKindOfClass:[CPTScatterPlot class]]);
    NSParameterAssert(function);

    if ( (self = [super init]) ) {
        dataPlot           = plot;
        dataSourceFunction = function;
        resolution         = CPTFloat(1.0);
        cachedStep         = 0.0;
        dataCount          = 0;
        cachedCount        = 0;
        cachedPlotRange    = nil;
        dataRange          = nil;

        dataPlot.cachePrecision = CPTPlotCachePrecisionDouble;
        dataPlot.dataSource     = self;

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(plotBoundsChanged)
                                                     name:CPTLayerBoundsDidChangeNotification
                                                   object:dataPlot];
        [dataPlot addObserver:self
                   forKeyPath:@"plotSpace"
                      options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld | NSKeyValueObservingOptionInitial
                      context:CPTFunctionDataSourceKVOContext];
    }
    return self;
}

/// @cond

// function and plot are required; this will fail the assertions in -initForPlot:withFunction:
-(id)init
{
    return [self initForPlot:nil withFunction:NULL];
}

-(void)dealloc
{
    [cachedPlotRange release];
    [dataRange release];

    [[NSNotificationCenter defaultCenter] removeObserver:self];

#if MAC_OS_X_VERSION_10_6 < MAC_OS_X_VERSION_MAX_ALLOWED || __IPHONE_4_0 < __IPHONE_OS_VERSION_MAX_ALLOWED
    [dataPlot removeObserver:self forKeyPath:@"plotSpace" context:CPTFunctionDataSourceKVOContext];
#else
    [dataPlot removeObserver:self forKeyPath:@"plotSpace"];
#endif

    [super dealloc];
}

/// @endcond

#pragma mark -
#pragma mark Accessors

/// @cond

-(void)setResolution:(CGFloat)newResolution
{
    NSParameterAssert( newResolution > CPTFloat(0.0) );

    if ( newResolution != resolution ) {
        resolution = newResolution;

        self.cachedCount     = 0;
        self.cachedPlotRange = nil;

        [self plotBoundsChanged];
    }
}

-(void)setDataRange:(CPTPlotRange *)newRange
{
    if ( newRange != dataRange ) {
        [dataRange release];
        dataRange = [newRange retain];

        if ( ![dataRange containsRange:self.cachedPlotRange] ) {
            self.cachedCount     = 0;
            self.cachedPlotRange = nil;

            [self plotBoundsChanged];
        }
    }
}

/// @endcond

#pragma mark -
#pragma mark Notifications

/// @cond

/** @internal
 *  @brief Reloads the plot with more closely spaced data points when needed.
 **/
-(void)plotBoundsChanged
{
    CPTPlot *plot = self.dataPlot;

    if ( plot ) {
        CGFloat width = plot.bounds.size.width;
        if ( width > CPTFloat(0.0) ) {
            NSUInteger count = (NSUInteger)ceil(width / self.resolution) + 1;

            if ( count > self.cachedCount ) {
                self.dataCount   = count;
                self.cachedCount = count;

                CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)plot.plotSpace;
                self.cachedStep = plotSpace.xRange.lengthDouble / count;

                [plot reloadData];
            }
        }
        else {
            self.dataCount   = 0;
            self.cachedCount = 0;
            self.cachedStep  = 0.0;
        }
    }
}

/** @internal
 *  @brief Adds new data points as needed while scrolling.
 **/
-(void)plotSpaceChanged
{
    CPTPlot *plot = self.dataPlot;

    CPTXYPlotSpace *plotSpace      = (CPTXYPlotSpace *)plot.plotSpace;
    CPTMutablePlotRange *plotRange = [plotSpace.xRange mutableCopy];

    [plotRange intersectionPlotRange:self.dataRange];

    CPTMutablePlotRange *cachedRange = self.cachedPlotRange;

    double step = self.cachedStep;

    if ( [cachedRange containsRange:plotRange] ) {
        // no new data needed
    }
    else if ( ![cachedRange intersectsRange:plotRange] || (step == 0.0) ) {
        self.cachedCount     = 0;
        self.cachedPlotRange = plotRange;

        [self plotBoundsChanged];
    }
    else {
        if ( step > 0.0 ) {
            double minLimit = plotRange.minLimitDouble;
            if ( ![cachedRange containsDouble:minLimit] ) {
                NSUInteger numPoints = (NSUInteger)ceil( (cachedRange.minLimitDouble - minLimit) / step );

                NSDecimal offset = CPTDecimalFromDouble(step * numPoints);
                cachedRange.location = CPTDecimalSubtract(cachedRange.location, offset);
                cachedRange.length   = CPTDecimalAdd(cachedRange.length, offset);

                self.dataCount += numPoints;

                [plot insertDataAtIndex:0 numberOfRecords:numPoints];
            }

            double maxLimit = plotRange.maxLimitDouble;
            if ( ![cachedRange containsDouble:maxLimit] ) {
                NSUInteger numPoints = (NSUInteger)ceil( (maxLimit - cachedRange.maxLimitDouble) / step );

                NSDecimal offset = CPTDecimalFromDouble(step * numPoints);
                cachedRange.length = CPTDecimalAdd(cachedRange.length, offset);

                self.dataCount += numPoints;

                [plot insertDataAtIndex:plot.cachedDataCount numberOfRecords:numPoints];
            }
        }
        else {
            double maxLimit = plotRange.maxLimitDouble;
            if ( ![cachedRange containsDouble:maxLimit] ) {
                NSUInteger numPoints = (NSUInteger)ceil( (cachedRange.maxLimitDouble - maxLimit) / step );

                NSDecimal offset = CPTDecimalFromDouble(step * numPoints);
                cachedRange.location = CPTDecimalSubtract(cachedRange.location, offset);
                cachedRange.length   = CPTDecimalAdd(cachedRange.length, offset);

                self.dataCount += numPoints;

                [plot insertDataAtIndex:0 numberOfRecords:numPoints];
            }

            double minLimit = plotRange.minLimitDouble;
            if ( ![cachedRange containsDouble:minLimit] ) {
                NSUInteger numPoints = (NSUInteger)ceil( (minLimit - cachedRange.minLimitDouble) / step );

                NSDecimal offset = CPTDecimalFromDouble(step * numPoints);
                cachedRange.length = CPTDecimalAdd(cachedRange.length, offset);

                self.dataCount += numPoints;

                [plot insertDataAtIndex:plot.cachedDataCount numberOfRecords:numPoints];
            }
        }
    }

    [plotRange release];
}

/// @endcond

#pragma mark -
#pragma mark KVO Methods

/// @cond

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ( (context == CPTFunctionDataSourceKVOContext) && [keyPath isEqualToString:@"plotSpace"] && [object isEqual:self.dataPlot] ) {
        CPTPlotSpace *oldSpace = [change objectForKey:NSKeyValueChangeOldKey];
        CPTPlotSpace *newSpace = [change objectForKey:NSKeyValueChangeNewKey];

        if ( oldSpace ) {
            [[NSNotificationCenter defaultCenter] removeObserver:self
                                                            name:CPTPlotSpaceCoordinateMappingDidChangeNotification
                                                          object:oldSpace];
        }

        if ( newSpace ) {
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(plotSpaceChanged)
                                                         name:CPTPlotSpaceCoordinateMappingDidChangeNotification
                                                       object:newSpace];
        }

        self.cachedPlotRange = nil;
        [self plotSpaceChanged];
    }
    else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

/// @endcond

#pragma mark -
#pragma mark CPTScatterPlotDataSource Methods

/// @cond

-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot
{
    NSUInteger count = 0;

    if ( [plot isEqual:self.dataPlot] ) {
        count = self.dataCount;
    }

    return count;
}

-(CPTNumericData *)dataForPlot:(CPTPlot *)plot recordIndexRange:(NSRange)indexRange
{
    CPTNumericData *numericData = nil;

    NSUInteger count = self.dataCount;

    if ( count > 0 ) {
        CPTPlotRange *xRange = self.cachedPlotRange;

        if ( !xRange ) {
            [self plotSpaceChanged];
            xRange = self.cachedPlotRange;
        }

        NSMutableData *data = [[NSMutableData alloc] initWithLength:indexRange.length * 2 * sizeof(double)];

        double *xBytes = data.mutableBytes;
        double *yBytes = data.mutableBytes + ( indexRange.length * sizeof(double) );

        CPTDataSourceFunction function = self.dataSourceFunction;

        double location = xRange.locationDouble;
        double length   = xRange.lengthDouble;
        double denom    = (double)( count - ( (count > 1) ? 1 : 0 ) );

        NSUInteger lastIndex = NSMaxRange(indexRange);

        for ( NSUInteger i = indexRange.location; i < lastIndex; i++ ) {
            double x = location + ( (double)i / denom ) * length;

            *xBytes++ = x;
            *yBytes++ = function(x);
        }

        NSArray *shape = [NSArray arrayWithObjects:[NSNumber numberWithUnsignedInteger:indexRange.length], [NSNumber numberWithUnsignedInteger:2], nil];

        numericData = [CPTNumericData numericDataWithData:data
                                                 dataType:CPTDataType( CPTFloatingPointDataType, sizeof(double), CFByteOrderGetCurrent() )
                                                    shape:shape
                                                dataOrder:CPTDataOrderColumnsFirst];

        [data release];
    }

    return numericData;
}

/// @endcond

@end
