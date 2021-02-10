#import "CPTFieldFunctionDataSource.h"

#import "CPTExceptions.h"
#import "CPTMutablePlotRange.h"
#import "CPTNumericData.h"
#import "CPTVectorFieldPlot.h"
#import "CPTContourPlot.h"
#import "CPTUtilities.h"
#import "CPTXYPlotSpace.h"
#import "tgmath.h"

/// @cond

static void *CPTFieldFunctionDataSourceKVOContext = (void *)&CPTFieldFunctionDataSourceKVOContext;
static void *CPTContourFunctionDataSourceKVOContext = (void *)&CPTContourFunctionDataSourceKVOContext;

@interface CPTFieldFunctionDataSource()

@property (nonatomic, readwrite, nonnull) CPTPlot *dataPlot;
@property (nonatomic, readwrite) double cachedXStep;
@property (nonatomic, readwrite) NSUInteger dataXCount;
@property (nonatomic, readwrite) NSUInteger cachedXCount;
@property (nonatomic, readwrite) double lastXValue;
@property (nonatomic, readwrite, strong, nullable) CPTMutablePlotRange *cachedPlotXRange;
@property (nonatomic, readwrite) double cachedYStep;
@property (nonatomic, readwrite) NSUInteger dataYCount;
@property (nonatomic, readwrite) NSUInteger cachedYCount;
@property (nonatomic, readwrite) double lastYValue;
@property (nonatomic, readwrite, strong, nullable) CPTMutablePlotRange *cachedPlotYRange;

-(nonnull instancetype)initForPlot:(nonnull CPTPlot *)plot NS_DESIGNATED_INITIALIZER;
-(void)plotBoundsChanged;
-(void)plotSpaceChanged;

@end

/// @endcond

#pragma mark -

/**
 *  @brief A datasource class that automatically creates vector field plot data from a function or Objective-C block.
 **/
@implementation CPTFieldFunctionDataSource

/** @property nullable CPTFieldDataSourceBlock dataSourceBlock
 *  @brief The Objective-C block used to generate plot data.
 **/
@synthesize dataSourceBlockX;

/** @property nullable CPTFieldDataSourceBlock dataSourceBlock
 *  @brief The Objective-C block used to generate plot data.
 **/
@synthesize dataSourceBlockY;

/** @property nullable CPTContourDataSourceBlock dataSourceBlock
 *  @brief The Objective-C block used to generate plot data.
 **/
@synthesize dataSourceBlock;

/** @property nonnull CPTPlot *dataPlot
 *  @brief The plot that will display the function values. Must be an instance of CPTVectorFieldPlot.
 **/
@synthesize dataPlot;

/** @property CGFloat resolutionX
 *  @brief The maximum number of pixels between data points on the plot. Default is @num{1.0}.
 **/
@synthesize resolutionX;

/** @property CGFloat resolutionY
 *  @brief The maximum number of pixels between data points on the plot. Default is @num{1.0}.
 **/
@synthesize resolutionY;

/** @property nullable CPTPlotRange *dataXRange
 *  @brief The maximum range of x-values that will be plotted. If @nil (the default), the function will be plotted for all visible x-values.
 **/
@synthesize dataXRange;

/** @property nullable CPTPlotRange *dataRange
 *  @brief The maximum range of x-values that will be plotted. If @nil (the default), the function will be plotted for all visible y-values.
 **/
@synthesize dataYRange;

@synthesize cachedXStep;
@synthesize cachedXCount;
@synthesize dataXCount;
@synthesize lastXValue;
@synthesize cachedPlotXRange;
@synthesize cachedYStep;
@synthesize cachedYCount;
@synthesize dataYCount;
@synthesize lastYValue;
@synthesize cachedPlotYRange;

#pragma mark -
#pragma mark Init/Dealloc

/** @brief Creates and returns a new CPTFieldFunctionDataSource instance initialized with the provided block and plot.
 *  @param plot The plot that will display the function values.
 *  @param blockX The Objective-C block used to generate vector plot data.
 *  @param blockY The Objective-C block used to generate vector plot data.
 *  @return A new CPTFieldFunctionDataSource instance initialized with the provided blocks and plot.
 **/
+(nonnull instancetype)dataSourceForPlot:(nonnull CPTPlot *)plot withBlockX:(nonnull CPTFieldDataSourceBlock)blockX withBlockY:(nullable CPTFieldDataSourceBlock)blockY
{
    return [[self alloc] initForPlot:plot withBlockX:blockX withBlockY:blockY];
}

/** @brief Creates and returns a new CPTContourFunctionDataSource instance initialized with the provided block and plot.
 *  @param plot The plot that will display the function values.
 *  @param block The Objective-C block used to generate contour plot data.
 *  @return A new CPTContourFunctionDataSource instance initialized with the provided blocks and plot.
 **/
+(nonnull instancetype)dataSourceForPlot:(nonnull CPTPlot *)plot withBlock:(nonnull CPTContourDataSourceBlock)block
{
    return [[self alloc] initForPlot:plot withBlock:block];
}

/** @brief Initializes a newly allocated CPTFieldFunctionDataSource object with the provided block and plot.
 *  @param plot The plot that will display the function values.
 *  @param blockX The Objective-C block used to generate vector plot data.
 *  @param blockY The Objective-C block used to generate vector plot data.
 *  @return The initialized CPTFieldFunctionDataSource object.
 **/
-(nonnull instancetype)initForPlot:(nonnull CPTPlot *)plot withBlockX:(nonnull CPTFieldDataSourceBlock)blockX withBlockY:(nullable CPTFieldDataSourceBlock)blockY
{
    NSParameterAssert(blockX);
    NSParameterAssert(blockY);

    if ( (self = [self initForPlot:plot]) ) {
        dataSourceBlockX = blockX;
        dataSourceBlockY = blockY;

        plot.dataSource = self;
    }
    return self;
}

/** @brief Initializes a newly allocated CPTContourFunctionDataSource object with the provided block and plot.
 *  @param plot The plot that will display the function values.
 *  @param block The Objective-C block used to generate contour data.
 *  @return The initialized CPTContourFunctionDataSource object.
 **/
-(nonnull instancetype)initForPlot:(nonnull CPTPlot *)plot withBlock:(nonnull CPTContourDataSourceBlock)block
{
    NSParameterAssert(block);

    if ( (self = [self initForPlot:plot]) ) {
        dataSourceBlock = block;

        plot.dataSource = self;
    }
    return self;
}

/// @cond

-(nonnull instancetype)initForPlot:(nonnull CPTPlot *)plot
{
    NSParameterAssert([plot isKindOfClass:[CPTVectorFieldPlot class]] || [plot isKindOfClass:[CPTContourPlot class]]);
   
    if ( (self = [super init]) ) {
        dataPlot           = plot;
        dataSourceBlockX    = nil;
        dataSourceBlockY    = nil;
        resolutionX         = CPTFloat(1.0);
        resolutionY         = CPTFloat(1.0);
        cachedXStep         = 0.0;
        dataXCount         = 0;
        cachedXCount        = 0;
        cachedPlotXRange    = nil;
        dataXRange          = nil;
        cachedYStep         = 0.0;
        dataYCount         = 0;
        cachedYCount        = 0;
        cachedPlotYRange    = nil;
        dataYRange          = nil;

        plot.cachePrecision = CPTPlotCachePrecisionDouble;

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(plotBoundsChanged)
                                                     name:CPTLayerBoundsDidChangeNotification
                                                   object:plot];
        if ([plot isKindOfClass:[CPTVectorFieldPlot class]]) {
            [plot addObserver:self
               forKeyPath:@"plotSpace"
                  options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld | NSKeyValueObservingOptionInitial
                  context:CPTFieldFunctionDataSourceKVOContext];
        }
        else {
            [plot addObserver:self
               forKeyPath:@"plotSpace"
                  options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld | NSKeyValueObservingOptionInitial
                  context:CPTContourFunctionDataSourceKVOContext];
        }
    }
    return self;
}

// function and plot are required; this will fail the assertions in -initForPlot:withBlockX:withBlockY:
-(nonnull instancetype)init
{
    [NSException raise:CPTException format:@"%@ must be initialized with a function or a block.", NSStringFromClass([self class])];
    return [self initForPlot:[CPTVectorFieldPlot layer] withBlockX:^(double x, double y) {
        return sin(x) * cos(y);
    } withBlockY:^(double x, double y) {
        return cos(x) * sin(y);
    }];
    
//    [NSException raise:CPTException format:@"%@ must be initialized with a function or a block.", NSStringFromClass([self class])];
//    return [self initForPlot:[CPTContourPlot layer] withBlock:^(double x, double y) {
//        return sin(x) * sin(y);
//    }];
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];

    if ([dataPlot isKindOfClass:[CPTVectorFieldPlot class]]) {
        [dataPlot removeObserver:self forKeyPath:@"plotSpace" context:CPTFieldFunctionDataSourceKVOContext];
    }
    else if ([dataPlot isKindOfClass:[CPTContourPlot class]]) {
        [dataPlot removeObserver:self forKeyPath:@"plotSpace" context:CPTContourFunctionDataSourceKVOContext];
    }
}

/// @endcond

#pragma mark -
#pragma mark Accessors

/// @cond

-(void)setResolutionX:(CGFloat)newResolution
{
    NSParameterAssert(newResolution > CPTFloat(0.0) );

    if ( newResolution != resolutionX ) {
        resolutionX = newResolution;

        self.cachedXCount     = 0;
        self.cachedPlotXRange = nil;
        
        [self plotBoundsChanged];
    }
}

-(void)setResolutionY:(CGFloat)newResolution
{
    NSParameterAssert(newResolution > CPTFloat(0.0) );

    if ( newResolution != resolutionY ) {
        resolutionY = newResolution;
        
        self.cachedYCount     = 0;
        self.cachedPlotYRange = nil;

        [self plotBoundsChanged];
    }
}

-(void)setDataRangeX:(nullable CPTPlotRange *)newRange
{
    if ( newRange != self.dataXRange ) {
        self.dataXRange = newRange;

        if ( ![self.dataXRange containsRange:self.cachedPlotXRange] ) {
            self.cachedXCount     = 0;
            self.cachedPlotXRange = nil;

            [self plotBoundsChanged];
        }
    }
}

-(void)setDataRangeY:(nullable CPTPlotRange *)newRange
{
    if ( newRange != self.dataYRange ) {
        self.dataYRange = newRange;

        if ( ![self.dataYRange containsRange:self.cachedPlotYRange] ) {
            self.cachedYCount     = 0;
            self.cachedPlotYRange = nil;

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
        CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)plot.plotSpace;

        if ( plotSpace ) {
            BOOL needsReloading = FALSE;
            
            CGFloat width = plot.bounds.size.width;
            if ( width > CPTFloat(0.0) ) {
                NSUInteger count = (NSUInteger)lrint(ceil(width / self.resolutionX) ) + 1;

                if ( count > self.cachedXCount ) {
                    self.dataXCount   = count;
                    self.cachedXCount = count;

                    self.cachedXStep = plotSpace.xRange.lengthDouble / count;

                    needsReloading = TRUE;
                }
            }
            else {
                self.dataXCount   = 0;
                self.cachedXCount = 0;
                self.cachedXStep  = 0.0;
            }
            CGFloat height = plot.bounds.size.height;
            if ( height > CPTFloat(0.0) ) {
                NSUInteger count = (NSUInteger)lrint(ceil(height / self.resolutionY) ) + 1;

                if ( count > self.cachedYCount ) {
                    self.dataYCount   = count;
                    self.cachedYCount = count;

                    self.cachedYStep = plotSpace.yRange.lengthDouble / count;

                    needsReloading = TRUE;
                }
            }
            else {
                self.dataYCount   = 0;
                self.cachedYCount = 0;
                self.cachedYStep  = 0.0;
            }
            if ( needsReloading ) {
                [plot reloadData];
            }
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
    CPTMutablePlotRange *plotXRange = [plotSpace.xRange mutableCopy];
    CPTMutablePlotRange *plotYRange = [plotSpace.yRange mutableCopy];

    [plotXRange intersectionPlotRange:self.dataXRange];
    [plotYRange intersectionPlotRange:self.dataYRange];

    CPTMutablePlotRange *cachedXRange = self.cachedPlotXRange;
    CPTMutablePlotRange *cachedYRange = self.cachedPlotYRange;

    double stepX = self.cachedXStep;
    double stepY = self.cachedYStep;

    if ( [cachedXRange containsRange:plotXRange] && [cachedYRange containsRange:plotYRange]) {
        // no new data needed
    }
    else if ( ![cachedXRange intersectsRange:plotXRange] || (stepX == 0.0) || plotXRange.maxLimitDouble > cachedXRange.maxLimitDouble || plotXRange.minLimitDouble < cachedXRange.minLimitDouble )  {
        self.cachedXCount     = 0;
        self.cachedPlotXRange = plotXRange;

        [self plotBoundsChanged];
    }
    else if ( ![cachedYRange intersectsRange:plotYRange] || (stepY == 0.0) || plotYRange.maxLimitDouble > cachedYRange.maxLimitDouble || plotYRange.minLimitDouble < cachedYRange.minLimitDouble ) {
        self.cachedYCount     = 0;
        self.cachedPlotYRange = plotYRange;

        [self plotBoundsChanged];
    }
    else {
        if ( stepY > 0.0 ) {
            double minLimit = plotYRange.minLimitDouble;
            if ( ![cachedYRange containsDouble:minLimit] ) {
                NSUInteger numPoints = (NSUInteger)lrint( (ceil( (cachedYRange.minLimitDouble - minLimit) / stepY ) ) );

                NSDecimal offset = CPTDecimalFromDouble(stepY * numPoints);
                cachedYRange.locationDecimal = CPTDecimalSubtract(cachedYRange.locationDecimal, offset);
                
                [plot replaceRowDataShiftDown:YES numberOfRecords:numPoints columnCount:self.dataXCount rowCount:self.dataYCount];
            }
            double maxLimit = plotYRange.maxLimitDouble;
            if ( ![cachedYRange containsDouble:maxLimit] ) {
                NSUInteger numPoints = (NSUInteger)lrint(ceil( (maxLimit - cachedYRange.maxLimitDouble) / stepY ) );

                NSDecimal offset = CPTDecimalFromDouble(stepY * numPoints);
                cachedYRange.locationDecimal = CPTDecimalAdd(cachedYRange.locationDecimal, offset);

                [plot replaceRowDataShiftDown:NO numberOfRecords:numPoints columnCount:self.dataXCount rowCount:self.dataYCount];
            }
        }
        else {
            double maxLimit = plotYRange.maxLimitDouble;
            if ( ![cachedYRange containsDouble:maxLimit] ) {
                NSUInteger numPoints = (NSUInteger)lrint(ceil( (cachedYRange.maxLimitDouble - maxLimit) / stepY ) );

                NSDecimal offset = CPTDecimalFromDouble(stepY * numPoints);
                cachedYRange.locationDecimal = CPTDecimalSubtract(cachedYRange.locationDecimal, offset);

                [plot replaceRowDataShiftDown:NO numberOfRecords:numPoints columnCount:self.dataXCount rowCount:self.dataYCount];
            }
            double minLimit = plotYRange.minLimitDouble;
            if ( ![cachedYRange containsDouble:minLimit] ) {
                NSUInteger numPoints = (NSUInteger)lrint(ceil( (minLimit - cachedYRange.minLimitDouble) / stepY ) );

                NSDecimal offset = CPTDecimalFromDouble(stepY * numPoints);
                cachedYRange.locationDecimal = CPTDecimalAdd(cachedYRange.locationDecimal, offset);

                [plot replaceRowDataShiftDown:YES numberOfRecords:numPoints columnCount:self.dataXCount rowCount:self.dataYCount];
            }
        }
        
        if ( stepX > 0.0 ) {
            double minLimit = plotXRange.minLimitDouble;
            if ( ![cachedXRange containsDouble:minLimit] ) {
                NSUInteger numPoints = (NSUInteger)lrint( (ceil( (cachedXRange.minLimitDouble - minLimit) / stepX ) ) );

                NSDecimal offset = CPTDecimalFromDouble(stepX * numPoints);
                cachedXRange.locationDecimal = CPTDecimalSubtract(cachedXRange.locationDecimal, offset);
                
                [plot replaceColumnDataShiftLeft:YES numberOfRecords:numPoints columnCount:self.dataXCount rowCount:self.dataYCount];
            }
            double maxLimit = plotXRange.maxLimitDouble;
            if ( ![cachedXRange containsDouble:maxLimit] ) {
                NSUInteger numPoints = (NSUInteger)lrint(ceil( (maxLimit - cachedXRange.maxLimitDouble) / stepX ) );

                NSDecimal offset = CPTDecimalFromDouble(stepX * numPoints);
                cachedXRange.locationDecimal = CPTDecimalAdd(cachedXRange.locationDecimal, offset);

                [plot replaceColumnDataShiftLeft:NO numberOfRecords:numPoints columnCount:self.dataXCount rowCount:self.dataYCount];
            }
        }
        else {
            double maxLimit = plotXRange.maxLimitDouble;
            if ( ![cachedXRange containsDouble:maxLimit] ) {
                NSUInteger numPoints = (NSUInteger)lrint(ceil( (cachedXRange.maxLimitDouble - maxLimit) / stepX ) );

                NSDecimal offset = CPTDecimalFromDouble(stepX * numPoints);
                cachedXRange.locationDecimal = CPTDecimalSubtract(cachedXRange.locationDecimal, offset);

                [plot replaceColumnDataShiftLeft:NO numberOfRecords:numPoints columnCount:self.dataXCount rowCount:self.dataYCount];
            }
            double minLimit = plotXRange.minLimitDouble;
            if ( ![cachedXRange containsDouble:minLimit] ) {
                NSUInteger numPoints = (NSUInteger)lrint(ceil( (minLimit - cachedXRange.minLimitDouble) / stepX ) );

                NSDecimal offset = CPTDecimalFromDouble(stepX * numPoints);
                cachedXRange.locationDecimal = CPTDecimalAdd(cachedXRange.locationDecimal, offset);
                
                [plot replaceColumnDataShiftLeft:YES numberOfRecords:numPoints columnCount:self.dataXCount rowCount:self.dataYCount];
            }
        }
    }
}

/// @endcond

#pragma mark -
#pragma mark KVO Methods

/// @cond

-(void)observeValueForKeyPath:(nullable NSString *)keyPath ofObject:(nullable id)object change:(NSDictionary<NSString *, CPTPlotSpace *> *)change context:(nullable void *)context
{
    if ( (context == CPTFieldFunctionDataSourceKVOContext || context == CPTContourFunctionDataSourceKVOContext) && [keyPath isEqualToString:@"plotSpace"] && [object isEqual:self.dataPlot] ) {
        CPTPlotSpace *oldSpace = change[NSKeyValueChangeOldKey];
        CPTPlotSpace *newSpace = change[NSKeyValueChangeNewKey];

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

        self.cachedPlotXRange = nil;
        self.cachedPlotYRange = nil;
        [self plotSpaceChanged];
    }
    else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

/// @endcond

#pragma mark -
#pragma mark CPTFieldPlotDataSource Methods

/// @cond

-(NSUInteger)numberOfRecordsForPlot:(nonnull CPTPlot *)plot
{
    NSUInteger count = 0;

    if ( [plot isEqual:self.dataPlot] ) {
        count = self.dataXCount * self.dataYCount;
    }

    return count;
}

-(nullable CPTNumericData *)dataForPlot:(nonnull CPTPlot *)plot recordIndexRange:(NSRange)indexRange
{
    CPTNumericData *numericData = nil;

    if ( self.dataXCount > 0 && self.dataYCount > 0) {
        CPTPlotRange *xRange = self.cachedPlotXRange;
        CPTPlotRange *yRange = self.cachedPlotYRange;

        if ( !xRange ) {
            [self plotSpaceChanged];
            xRange = self.cachedPlotXRange;
        }
        if ( !yRange ) {
            [self plotSpaceChanged];
            yRange = self.cachedPlotYRange;
        }
        
        NSUInteger startYIndex = indexRange.location / self.dataXCount;
        NSUInteger startXIndex = indexRange.location % self.dataXCount;
        
        NSUInteger lastYIndex = NSMaxRange(indexRange) / self.dataXCount;
        if ( NSMaxRange(indexRange) % self.dataXCount > 0 ) {
            lastYIndex ++;
        }
        NSUInteger lastXIndex =  NSMaxRange(indexRange) % self.dataXCount > 0 ? NSMaxRange(indexRange) % self.dataXCount : self.dataXCount;

        double startX, startY, incrementX, incrementY;
        if ( [plot cachedNumbersForField:CPTVectorFieldPlotFieldX] == nil || indexRange.length == self.dataXCount * self.dataYCount) {
            double locationX = xRange.locationDouble;
            double lengthX   = xRange.lengthDouble;
            double denomX    = (double)(self.dataXCount - ( (self.dataXCount > 1) ? 1 : 0 ) );
            startX = locationX;
            incrementX = lengthX / denomX;
        }
        else {
            if (indexRange.length < self.dataXCount ) {
                if ( (NSInteger)startXIndex - 2 >= 0 ) {
                    incrementX = [plot cachedDoubleForField:CPTVectorFieldPlotFieldX recordIndex:startXIndex - 1] - [plot cachedDoubleForField:CPTVectorFieldPlotFieldX recordIndex:startXIndex - 2];
                    startX = [plot cachedDoubleForField:CPTVectorFieldPlotFieldX recordIndex:0];
                }
                else {
                    incrementX = [plot cachedDoubleForField:CPTVectorFieldPlotFieldX recordIndex:lastXIndex + 1] - [plot cachedDoubleForField:CPTVectorFieldPlotFieldX recordIndex:lastXIndex];
                    startX = [plot cachedDoubleForField:CPTVectorFieldPlotFieldX recordIndex:self.dataXCount - 1] - (self.dataXCount - 1) * incrementX;
                }
            }
            else {
                incrementX = [plot cachedDoubleForField:CPTVectorFieldPlotFieldX recordIndex:lastXIndex + 1] - [plot cachedDoubleForField:CPTVectorFieldPlotFieldX recordIndex:lastXIndex];
                startX = [plot cachedDoubleForField:CPTVectorFieldPlotFieldX recordIndex:0];
            }
        }

        if ( [plot cachedNumbersForField:CPTVectorFieldPlotFieldY] == nil || indexRange.length == self.dataXCount * self.dataYCount) {
            double locationY = yRange.locationDouble;
            double lengthY   = yRange.lengthDouble;
            double denomY    = (double)(self.dataYCount - ( (self.dataYCount > 1) ? 1 : 0 ) );
            startY = locationY;
            incrementY = lengthY / denomY;
        }
        else {
            if ( (NSInteger)startYIndex - 2 >= 0 ) {
                incrementY = [plot cachedDoubleForField:CPTVectorFieldPlotFieldY recordIndex:(startYIndex - 1) * self.dataXCount] - [plot cachedDoubleForField:CPTVectorFieldPlotFieldY recordIndex:(startYIndex - 2) * self.dataXCount];
                startY = [plot cachedDoubleForField:CPTVectorFieldPlotFieldY recordIndex:0];
            }
            else {
                incrementY = [plot cachedDoubleForField:CPTVectorFieldPlotFieldY recordIndex:(lastYIndex + 1) * self.dataXCount] - [plot cachedDoubleForField:CPTVectorFieldPlotFieldY recordIndex:lastYIndex * self.dataXCount];
                startY = [plot cachedDoubleForField:CPTVectorFieldPlotFieldY recordIndex:self.dataXCount * self.dataYCount - 1] - (self.dataYCount - 1) * incrementY;
            }
        }

        if ([plot isKindOfClass:[CPTVectorFieldPlot class]]) {
            NSMutableData *data = [[NSMutableData alloc] initWithLength:indexRange.length * 4 * sizeof(double)];

            double *xBytes = data.mutableBytes;
            double *yBytes = data.mutableBytes + (indexRange.length * sizeof(double) );
            double *lengthBytes = data.mutableBytes + (indexRange.length * 2 * sizeof(double) );
            double *directionBytes = data.mutableBytes + (indexRange.length * 3 * sizeof(double) );

            CPTFieldDataSourceBlock functionBlockX = self.dataSourceBlockX;
            CPTFieldDataSourceBlock functionBlockY = self.dataSourceBlockY;

            if ( functionBlockX && functionBlockY ) {
                double _maxVectorLength = ((CPTVectorFieldPlot*)plot).maxVectorLength;
                double fx = 0.0;
                double fy = 0.0;
                double x = 0.0;
                double y = 0.0;
                double vectorLength = 0.0;
                for ( NSUInteger i = startYIndex; i < lastYIndex; i++ ) {
                    y = startY + (double)i * incrementY;
                    for ( NSUInteger j = startXIndex; j < lastXIndex; j++ ) {
                        x = startX + (double)j * incrementX;
                        *xBytes++ = x;
                        *yBytes++ = y;
                        fx = functionBlockX(x, y);
                        fy = functionBlockY(x, y);
                        vectorLength = sqrt(fx * fx + fy * fy);
                        *lengthBytes++ = (double)vectorLength;
                        *directionBytes++ = (double)atan2(fy, fx);
                        _maxVectorLength = MAX(_maxVectorLength, vectorLength);
                    }
                }
                lengthBytes = data.mutableBytes + (indexRange.length * 2 * sizeof(double) );
                NSUInteger yEnd = (NSInteger)lastYIndex - (NSInteger)startYIndex > 0 ?  lastYIndex - startYIndex : 0;
                NSUInteger xEnd = (NSInteger)lastXIndex - (NSInteger)startXIndex > 0 ?  lastYIndex - startYIndex : 0;
                for ( NSUInteger i = 0; i < yEnd; i++ ) {
                    for ( NSUInteger j = 0; j < xEnd; j++ ) {
                        *lengthBytes = *lengthBytes / _maxVectorLength;
                        lengthBytes++;
                    }
                }
                ((CPTVectorFieldPlot*)plot).maxVectorLength = _maxVectorLength;
            }
            
            numericData = [CPTNumericData numericDataWithData:data
                                                 dataType:CPTDataType(CPTFloatingPointDataType, sizeof(double), CFByteOrderGetCurrent() )
                                                    shape:@[@(indexRange.length), @4]
                                                dataOrder:CPTDataOrderColumnsFirst];
        }
        else {
            NSMutableData *data = [[NSMutableData alloc] initWithLength:indexRange.length * 3 * sizeof(double)];

            double *xBytes = data.mutableBytes;
            double *yBytes = data.mutableBytes + (indexRange.length * sizeof(double) );
            double *functionValueBytes = data.mutableBytes + (indexRange.length * 2 * sizeof(double) );
            
            CPTContourDataSourceBlock functionBlock = self.dataSourceBlock;
            
            if ( functionBlock ) {
                double _maxFValue = ((CPTContourPlot*)plot).maxFunctionValue;
                double _minFValue = ((CPTContourPlot*)plot).minFunctionValue;
                double f = 0.0;
                double x = 0.0;
                double y = 0.0;
                for ( NSUInteger i = startYIndex; i < lastYIndex; i++ ) {
                    y = startY + (double)i * incrementY;
                    for ( NSUInteger j = startXIndex; j < lastXIndex; j++ ) {
                        x = startX + (double)j * incrementX;;
                        *xBytes++ = x;
                        *yBytes++ = y;
                        f = functionBlock(x, y);
                        *functionValueBytes++ = f;
                        _maxFValue = MAX(_maxFValue, f);
                        _minFValue = MIN(_minFValue, f);
                    }
                }
                ((CPTContourPlot*)plot).maxFunctionValue = _maxFValue;
                ((CPTContourPlot*)plot).minFunctionValue = _minFValue;
            }
            
            numericData = [CPTNumericData numericDataWithData:data
                                                     dataType:CPTDataType(CPTFloatingPointDataType, sizeof(double), CFByteOrderGetCurrent() )
                                                        shape:@[@(indexRange.length), @3]
                                                    dataOrder:CPTDataOrderColumnsFirst];
        }
    }

    return numericData;
}

/// @endcond


#pragma mark -
#pragma mark Accessors

/// @cond
-(NSUInteger)getDataXCount {
    return self.dataXCount;
}

-(NSUInteger)getDataYCount {
    return self.dataYCount;
}

/// @endcond

@end
