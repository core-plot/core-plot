#import "CorePlotQCPlugin.h"
#import <OpenGL/CGLMacro.h>

#define kQCPlugIn_Name        @"CorePlotQCPlugIn"
#define kQCPlugIn_Description @"CorePlotQCPlugIn base plugin."

#pragma mark -

@interface CorePlotQCPlugIn()

@property (nonatomic, readwrite, strong, nullable) NSMutableData *imageData;
@property (nonatomic, readwrite, assign, nullable) CGContextRef bitmapContext;
@property (nonatomic, readwrite, strong, nullable) id<QCPlugInOutputImageProvider> imageProvider;

void drawErrorText(CGContextRef __nonnull context, CGRect rect);

@end

#pragma mark -

// Draws the string "ERROR" in the given context in big red letters
void drawErrorText(CGContextRef __nonnull context, CGRect rect)
{
    CGContextSaveGState(context);

    CGFloat w = rect.size.width;
    CGFloat h = rect.size.height;

    CGContextSelectFont(context, "Verdana", h / 4, kCGEncodingMacRoman);
    CGContextSetTextDrawingMode(context, kCGTextFillStroke);

    CGContextSetRGBFillColor(context, 1, 0, 0, 0.5);
    CGContextSetRGBStrokeColor(context, 0, 0, 0, 1);

    CGContextSetTextMatrix(context, CGAffineTransformIdentity);

    // Compute the width of the text
    CGPoint r0 = CGContextGetTextPosition(context);
    CGContextSetTextDrawingMode(context, kCGTextInvisible);
    CGContextShowText(context, "ERROR", 5); // 10
    CGPoint r1 = CGContextGetTextPosition(context);

    CGFloat width  = r1.x - r0.x;
    CGFloat height = h / 3;

    CGFloat x = rect.origin.x + w / 2.0 - width / 2.0;
    CGFloat y = rect.origin.y + h / 2.0 - height / 2.0;

    CGContextSetTextDrawingMode(context, kCGTextFillStroke);
    CGContextShowTextAtPoint(context, x, y, "ERROR", 5);

    CGContextRestoreGState(context);
}

#pragma mark -

@implementation CorePlotQCPlugIn

@synthesize graph;
@synthesize imageData;
@synthesize bitmapContext;
@synthesize imageProvider;

// TODO: Make the port accessors dynamic, that way certain inputs can be removed based on settings and subclasses won't need the @dynamic declarations

/*
 * Accessor for the output image
 */
@dynamic outputImage;

/*
 * Dynamic accessors for the static PlugIn inputs
 */
@dynamic inputPixelsWide, inputPixelsHigh;
@dynamic inputPlotAreaColor;
@dynamic inputAxisColor, inputAxisLineWidth, inputAxisMinorTickWidth, inputAxisMajorTickWidth, inputAxisMajorTickLength, inputAxisMinorTickLength;
@dynamic inputMajorGridLineWidth, inputMinorGridLineWidth;
@dynamic inputXMin, inputXMax, inputYMin, inputYMax;
@dynamic inputXMajorIntervals, inputYMajorIntervals, inputXMinorIntervals, inputYMinorIntervals;

/*
 * Synthesized accessors for internal PlugIn settings
 */
@synthesize numberOfPlots;

+(nonnull NSDictionary<NSString *, NSString *> *)attributes
{
    /*
     * Return a dictionary of attributes describing the plug-in (QCPlugInAttributeNameKey, QCPlugInAttributeDescriptionKey...).
     */

    return @{
        QCPlugInAttributeNameKey: kQCPlugIn_Name,
        QCPlugInAttributeDescriptionKey: kQCPlugIn_Description
    };
}

+(QCPlugInExecutionMode)executionMode
{
    /*
     * Return the execution mode of the plug-in: kQCPlugInExecutionModeProvider, kQCPlugInExecutionModeProcessor, or kQCPlugInExecutionModeConsumer.
     */

    return kQCPlugInExecutionModeProcessor;
}

+(QCPlugInTimeMode)timeMode
{
    /*
     * Return the time dependency mode of the plug-in: kQCPlugInTimeModeNone, kQCPlugInTimeModeIdle or kQCPlugInTimeModeTimeBase.
     */

    return kQCPlugInTimeModeNone;
}

-(nonnull instancetype)init
{
    if ((self = [super init])) {
        /*
         * Allocate any permanent resource required by the plug-in.
         */

        [self createGraph];

        self.numberOfPlots = 1;

        imageData     = nil;
        imageProvider = nil;
        bitmapContext = NULL;
    }

    return self;
}

-(void)dealloc
{
    [self freeResources];
}

-(void)freeImageResources
{
    self.bitmapContext = NULL;
    self.imageData     = nil;
}

-(void)freeResources
{
    [self freeImageResources];
    self.graph = nil;
}

-(nullable QCPlugInViewController *)createViewController
{
    /*
     * Return a new QCPlugInViewController to edit the internal settings of this plug-in instance.
     * You can return a subclass of QCPlugInViewController if necessary.
     */

    return [[QCPlugInViewController alloc] initWithPlugIn:self viewNibName:@"Settings"];
}

#pragma mark -
#pragma mark Input and output port configuration

+(nonnull CPTStringArray *)sortedPropertyPortKeys
{
    return @[@"inputPixelsWide",
             @"inputPixelsHigh",
             @"inputPlotAreaColor",
             @"inputAxisColor",
             @"inputAxisLineWidth",

             @"inputXMin",
             @"inputXMax",
             @"inputYMin",
             @"inputYMax",

             @"inputXMajorIntervals",
             @"inputYMajorIntervals",
             @"inputAxisMajorTickLength",
             @"inputAxisMajorTickWidth",

             @"inputXMinorIntervals",
             @"inputYMinorIntervals",
             @"inputAxisMinorTickLength",
             @"inputAxisMinorTickWidth"];
}

+(nullable CPTDictionary *)attributesForPropertyPortWithKey:(nullable NSString *)key
{
    /*
     * Specify the optional attributes for property based ports (QCPortAttributeNameKey, QCPortAttributeDefaultValueKey...).
     */

    if ( [key isEqualToString:@"inputXMin"] ) {
        return @{
            QCPortAttributeNameKey: @"X Range Min",
            QCPortAttributeDefaultValueKey: @(-1.0)
        };
    }

    if ( [key isEqualToString:@"inputXMax"] ) {
        return @{
            QCPortAttributeNameKey: @"X Range Max",
            QCPortAttributeDefaultValueKey: @1.0
        };
    }

    if ( [key isEqualToString:@"inputYMin"] ) {
        return @{
            QCPortAttributeNameKey: @"Y Range Min",
            QCPortAttributeDefaultValueKey: @(-1.0)
        };
    }

    if ( [key isEqualToString:@"inputYMax"] ) {
        return @{
            QCPortAttributeNameKey: @"Y Range Max",
            QCPortAttributeDefaultValueKey: @1.0
        };
    }

    if ( [key isEqualToString:@"inputXMajorIntervals"] ) {
        return @{
            QCPortAttributeNameKey: @"X Major Intervals",
            QCPortAttributeDefaultValueKey: @4.0,
            QCPortAttributeMinimumValueKey: @0.0
        };
    }

    if ( [key isEqualToString:@"inputYMajorIntervals"] ) {
        return @{
            QCPortAttributeNameKey: @"Y Major Intervals",
            QCPortAttributeDefaultValueKey: @4.0,
            QCPortAttributeMinimumValueKey: @0.0
        };
    }

    if ( [key isEqualToString:@"inputXMinorIntervals"] ) {
        return @{
            QCPortAttributeNameKey: @"X Minor Intervals",
            QCPortAttributeDefaultValueKey: @1,
            QCPortAttributeMinimumValueKey: @0
        };
    }

    if ( [key isEqualToString:@"inputYMinorIntervals"] ) {
        return @{
            QCPortAttributeNameKey: @"Y Minor Intervals",
            QCPortAttributeDefaultValueKey: @1,
            QCPortAttributeMinimumValueKey: @0
        };
    }

    if ( [key isEqualToString:@"inputAxisColor"] ) {
        CGColorRef axisColor  = CGColorCreateGenericRGB(1.0, 1.0, 1.0, 1.0);
        CPTDictionary *result = @{
                                    QCPortAttributeNameKey: @"Axis Color",
                                    QCPortAttributeDefaultValueKey: (id)CFBridgingRelease(axisColor)
        };
        return result;
    }

    if ( [key isEqualToString:@"inputAxisLineWidth"] ) {
        return @{
            QCPortAttributeNameKey: @"Axis Line Width",
            QCPortAttributeMinimumValueKey: @0.0,
            QCPortAttributeDefaultValueKey: @1.0
        };
    }

    if ( [key isEqualToString:@"inputAxisMajorTickWidth"] ) {
        return @{
            QCPortAttributeNameKey: @"Major Tick Width",
            QCPortAttributeMinimumValueKey: @0.0,
            QCPortAttributeDefaultValueKey: @2.0
        };
    }

    if ( [key isEqualToString:@"inputAxisMinorTickWidth"] ) {
        return @{
            QCPortAttributeNameKey: @"Minor Tick Width",
            QCPortAttributeMinimumValueKey: @0.0,
            QCPortAttributeDefaultValueKey: @1.0
        };
    }

    if ( [key isEqualToString:@"inputAxisMajorTickLength"] ) {
        return @{
            QCPortAttributeNameKey: @"Major Tick Length",
            QCPortAttributeMinimumValueKey: @0.0,
            QCPortAttributeDefaultValueKey: @10.0
        };
    }

    if ( [key isEqualToString:@"inputAxisMinorTickLength"] ) {
        return @{
            QCPortAttributeNameKey: @"Minor Tick Length",
            QCPortAttributeMinimumValueKey: @0.0,
            QCPortAttributeDefaultValueKey: @3.0
        };
    }

    if ( [key isEqualToString:@"inputMajorGridLineWidth"] ) {
        return @{
            QCPortAttributeNameKey: @"Major Grid Line Width",
            QCPortAttributeMinimumValueKey: @0.0,
            QCPortAttributeDefaultValueKey: @1.0
        };
    }

    if ( [key isEqualToString:@"inputMinorGridLineWidth"] ) {
        return @{
            QCPortAttributeNameKey: @"Minor Grid Line Width",
            QCPortAttributeMinimumValueKey: @0.0,
            QCPortAttributeDefaultValueKey: @0.0
        };
    }

    if ( [key isEqualToString:@"inputPlotAreaColor"] ) {
        CGColorRef plotAreaColor = CGColorCreateGenericRGB(0.0, 0.0, 0.0, 0.4);
        CPTDictionary *result    = @{
                                       QCPortAttributeNameKey: @"Plot Area Color",
                                       QCPortAttributeDefaultValueKey: (id)CFBridgingRelease(plotAreaColor)
        };
        return result;
    }

    if ( [key isEqualToString:@"inputPixelsWide"] ) {
        return @{
            QCPortAttributeNameKey: @"Pixels Wide",
            QCPortAttributeMinimumValueKey: @1,
            QCPortAttributeDefaultValueKey: @512
        };
    }

    if ( [key isEqualToString:@"inputPixelsHigh"] ) {
        return @{
            QCPortAttributeNameKey: @"Pixels High",
            QCPortAttributeMinimumValueKey: @1,
            QCPortAttributeDefaultValueKey: @512
        };
    }

    if ( [key isEqualToString:@"outputImage"] ) {
        return @{
            QCPortAttributeNameKey: @"Image"
        };
    }

    return nil;
}

#pragma mark -
#pragma mark Graph configuration

-(void)createGraph
{
    if ( !self.graph ) {
        // Create graph from theme
        CPTTheme *theme      = [CPTTheme themeNamed:kCPTPlainBlackTheme];
        CPTXYGraph *newGraph = (CPTXYGraph *)[theme newGraph];
        self.graph = newGraph;

        // Setup scatter plot space
        CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)newGraph.defaultPlotSpace;
        plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:@1.0 length:@1.0];
        plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:@(-1.0) length:@1.0];

        // Axes
        CPTXYAxisSet *axisSet = (CPTXYAxisSet *)newGraph.axisSet;

        CPTXYAxis *x = axisSet.xAxis;
        x.majorIntervalLength   = @0.5;
        x.minorTicksPerInterval = 2;

        CPTXYAxis *y = axisSet.yAxis;
        y.majorIntervalLength   = @0.5;
        y.minorTicksPerInterval = 5;
    }
}

-(nonnull CGColorRef)newDefaultColorForPlot:(NSUInteger)index alpha:(CGFloat)alpha
{
    CGColorRef color;

    switch ( index ) {
        case 0:
            color = CGColorCreateGenericRGB(1.0, 0.0, 0.0, alpha);
            break;

        case 1:
            color = CGColorCreateGenericRGB(0.0, 1.0, 0.0, alpha);
            break;

        case 2:
            color = CGColorCreateGenericRGB(0.0, 0.0, 1.0, alpha);
            break;

        case 3:
            color = CGColorCreateGenericRGB(1.0, 1.0, 0.0, alpha);
            break;

        case 4:
            color = CGColorCreateGenericRGB(1.0, 0.0, 1.0, alpha);
            break;

        case 5:
            color = CGColorCreateGenericRGB(0.0, 1.0, 1.0, alpha);
            break;

        default:
            color = CGColorCreateGenericRGB(1.0, 0.0, 0.0, alpha);
            break;
    }

    return color;
}

-(void)addPlots:(NSUInteger)count
{
    NSUInteger plotCount = self.numberOfPlots;

    for ( NSUInteger i = 0; i < count; i++ ) {
        [self addPlotWithIndex:i + plotCount];
    }
}

-(BOOL)configureAxis
{
    CPTColor *axisColor = [CPTColor colorWithCGColor:self.inputAxisColor];

    CPTXYAxisSet *set              = (CPTXYAxisSet *)self.graph.axisSet;
    CPTMutableLineStyle *lineStyle = [CPTMutableLineStyle lineStyle];

    lineStyle.lineColor     = axisColor;
    lineStyle.lineWidth     = self.inputAxisLineWidth;
    set.xAxis.axisLineStyle = lineStyle;
    set.yAxis.axisLineStyle = lineStyle;

    lineStyle.lineWidth          = self.inputAxisMajorTickWidth;
    set.xAxis.majorTickLineStyle = lineStyle;
    set.yAxis.majorTickLineStyle = lineStyle;

    lineStyle.lineWidth          = self.inputAxisMinorTickWidth;
    set.xAxis.minorTickLineStyle = lineStyle;
    set.yAxis.minorTickLineStyle = lineStyle;

    CPTMutableTextStyle *textStyle = [CPTMutableTextStyle textStyle];
    textStyle.color          = axisColor;
    set.xAxis.labelTextStyle = textStyle;

    double xrange = self.inputXMax - self.inputXMin;
    set.xAxis.majorIntervalLength   = @(xrange / (self.inputXMajorIntervals));
    set.xAxis.minorTicksPerInterval = self.inputXMinorIntervals;

    double yrange = self.inputYMax - self.inputYMin;
    set.yAxis.majorIntervalLength   = @(yrange / (self.inputYMajorIntervals));
    set.yAxis.minorTicksPerInterval = self.inputYMinorIntervals;

    set.xAxis.minorTickLength = self.inputAxisMinorTickLength;
    set.yAxis.minorTickLength = self.inputAxisMinorTickLength;

    set.xAxis.majorTickLength = self.inputAxisMajorTickLength;
    set.yAxis.majorTickLength = self.inputAxisMajorTickLength;

    if ( [self didValueForInputKeyChange:@"inputMajorGridLineWidth"] || [self didValueForInputKeyChange:@"inputAxisColor"] ) {
        CPTMutableLineStyle *majorGridLineStyle = nil;
        if ( self.inputMajorGridLineWidth == 0.0 ) {
            majorGridLineStyle = nil;
        }
        else {
            majorGridLineStyle           = [CPTMutableLineStyle lineStyle];
            majorGridLineStyle.lineColor = [CPTColor colorWithCGColor:self.inputAxisColor];
            majorGridLineStyle.lineWidth = self.inputMajorGridLineWidth;
        }

        set.xAxis.majorGridLineStyle = majorGridLineStyle;
        set.yAxis.majorGridLineStyle = majorGridLineStyle;
    }

    if ( [self didValueForInputKeyChange:@"inputMinorGridLineWidth"] || [self didValueForInputKeyChange:@"inputAxisColor"] ) {
        CPTMutableLineStyle *minorGridLineStyle;
        if ( self.inputMinorGridLineWidth == 0.0 ) {
            minorGridLineStyle = nil;
        }
        else {
            minorGridLineStyle           = [CPTMutableLineStyle lineStyle];
            minorGridLineStyle.lineColor = [CPTColor colorWithCGColor:self.inputAxisColor];
            minorGridLineStyle.lineWidth = self.inputMinorGridLineWidth;
        }

        set.xAxis.minorGridLineStyle = minorGridLineStyle;
        set.yAxis.minorGridLineStyle = minorGridLineStyle;
    }

    return YES;
}

-(nonnull CGColorRef)dataLineColor:(NSUInteger)index
{
    NSString *key = [NSString stringWithFormat:@"plotDataLineColor%lu", (unsigned long)index];

    return (__bridge CGColorRef)([self valueForInputKey:key]);
}

-(CGFloat)dataLineWidth:(NSUInteger)index
{
    NSString *key = [NSString stringWithFormat:@"plotDataLineWidth%lu", (unsigned long)index];

    NSNumber *inputValue = [self valueForInputKey:key];

    return inputValue.doubleValue;
}

-(nullable CGColorRef)areaFillColor:(NSUInteger)index
{
    NSString *key = [NSString stringWithFormat:@"plotFillColor%lu", (unsigned long)index];

    return (__bridge CGColorRef)([self valueForInputKey:key]);
}

-(nullable CGImageRef)newAreaFillImage:(NSUInteger)index
{
    NSString *key = [NSString stringWithFormat:@"plotFillImage%lu", (unsigned long)index];

    id<QCPlugInInputImageSource> img = [self valueForInputKey:key];

    if ( !img ) {
        return nil;
    }

#if __BIG_ENDIAN__
    NSString *pixelFormat = QCPlugInPixelFormatARGB8;
#else
    NSString *pixelFormat = QCPlugInPixelFormatBGRA8;
#endif

    CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
    [img lockBufferRepresentationWithPixelFormat:pixelFormat colorSpace:rgbColorSpace forBounds:[img imageBounds]];
    CGColorSpaceRelease(rgbColorSpace);

    const void *baseAddress     = [img bufferBaseAddress];
    NSUInteger pixelsWide       = [img bufferPixelsWide];
    NSUInteger pixelsHigh       = [img bufferPixelsHigh];
    NSUInteger bitsPerComponent = 8;
    NSUInteger bytesPerRow      = [img bufferBytesPerRow];
    CGColorSpaceRef colorSpace  = [img bufferColorSpace];

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wincompatible-pointer-types-discards-qualifiers"

    CGContextRef imgContext = CGBitmapContextCreate(baseAddress,
                                                    pixelsWide,
                                                    pixelsHigh,
                                                    bitsPerComponent,
                                                    bytesPerRow,
                                                    colorSpace,
                                                    (CGBitmapInfo)kCGImageAlphaNoneSkipLast);

#pragma clang diagnostic pop

    CGImageRef imageRef = CGBitmapContextCreateImage(imgContext);

    [img unlockBufferRepresentation];

    CGContextRelease(imgContext);

    return imageRef;
}

static void _BufferReleaseCallback(const void *__nonnull __unused address, void *__nonnull __unused context)
{
    // Don't do anything.  We release the buffer manually when it's recreated or during dealloc
}

-(void)createImageResourcesWithContext:(nonnull id<QCPlugInContext>)context
{
    // Create a CG bitmap for drawing.  The image data is released when QC calls _BufferReleaseCallback
    CGSize boundsSize           = self.graph.bounds.size;
    NSUInteger bitsPerComponent = 8;
    size_t rowBytes             = (size_t)boundsSize.width * 4;

    if ( rowBytes % 16 ) {
        rowBytes = ((rowBytes / 16) + 1) * 16;
    }

    if ( !self.imageData ) {
        size_t bufferLength = rowBytes * (size_t)boundsSize.height;
        void *buffer        = valloc(bufferLength);

        if ( !buffer ) {
            NSLog(@"Couldn't allocate memory for image data");
            return;
        }

        self.imageData = [NSMutableData dataWithBytesNoCopy:buffer length:bufferLength];
    }

    CGContextRef newContext = CGBitmapContextCreate(self.imageData.mutableBytes,
                                                    (size_t)boundsSize.width,
                                                    (size_t)boundsSize.height,
                                                    bitsPerComponent,
                                                    rowBytes,
                                                    [context colorSpace],
                                                    (CGBitmapInfo)kCGImageAlphaPremultipliedFirst);
    self.bitmapContext = newContext;

    if ( !newContext ) {
        self.imageData = nil;
        NSLog(@"Couldn't create bitmap context");
        return;
    }

    CGContextRelease(newContext);

    if ( rowBytes % 16 ) {
        rowBytes = ((rowBytes / 16) + 1) * 16;
    }

    // Note: I don't have a PPC to test on so this may or may not cause some color issues
#if __BIG_ENDIAN__
    self.imageProvider = [context outputImageProviderFromBufferWithPixelFormat:QCPlugInPixelFormatBGRA8
                                                                    pixelsWide:(NSUInteger)boundsSize.width
                                                                    pixelsHigh:(NSUInteger)boundsSize.height
                                                                   baseAddress:self.imageData.bytes
                                                                   bytesPerRow:rowBytes
                                                               releaseCallback:_BufferReleaseCallback
                                                                releaseContext:NULL
                                                                    colorSpace:[context colorSpace]
                                                              shouldColorMatch:YES];
#else
    self.imageProvider = [context outputImageProviderFromBufferWithPixelFormat:QCPlugInPixelFormatARGB8
                                                                    pixelsWide:(NSUInteger)boundsSize.width
                                                                    pixelsHigh:(NSUInteger)boundsSize.height
                                                                   baseAddress:self.imageData.bytes
                                                                   bytesPerRow:rowBytes
                                                               releaseCallback:_BufferReleaseCallback
                                                                releaseContext:NULL
                                                                    colorSpace:[context colorSpace]
                                                              shouldColorMatch:YES];
#endif
}

#pragma mark -
#pragma mark Data source methods

-(NSUInteger)numberOfRecordsForPlot:(nonnull CPTPlot *__unused)plot
{
    return 0;
}

-(nullable id)numberForPlot:(nonnull CPTPlot *__unused)plot field:(NSUInteger __unused)fieldEnum recordIndex:(NSUInteger __unused)index
{
    return @0;
}

#pragma mark -
#pragma mark Methods for dealing with plugin keys

-(NSUInteger)numberOfPlots
{
    return numberOfPlots;
}

-(void)setNumberOfPlots:(NSUInteger)number
{
    number = MAX(1, number);

    if ( number > numberOfPlots ) {
        [self addPlots:number - numberOfPlots];
    }
    else {
        [self removePlots:numberOfPlots - number];
    }

    numberOfPlots = number;
}

+(nonnull CPTStringArray *)plugInKeys
{
    return @[@"numberOfPlots"];
}

-(nonnull id)serializedValueForKey:(nonnull NSString *)key
{
    /*
     * Provide custom serialization for the plug-in internal settings that are not values complying to the <NSCoding> protocol.
     * The return object must be nil or a PList compatible i.e. NSString, NSNumber, NSDate, NSData, NSArray or NSDictionary.
     */

    if ( [key isEqualToString:@"numberOfPlots"] ) {
        return @(self.numberOfPlots);
    }
    else {
        return [super serializedValueForKey:key];
    }
}

-(void)setSerializedValue:(nonnull id)serializedValue forKey:(nonnull NSString *)key
{
    /*
     * Provide deserialization for the plug-in internal settings that were custom serialized in -serializedValueForKey.
     * Deserialize the value, then call [self setValue:value forKey:key] to set the corresponding internal setting of the plug-in instance to that deserialized value.
     */

    if ( [key isEqualToString:@"numberOfPlots"] ) {
        [self setNumberOfPlots:MAX(1, [(NSNumber *) serializedValue unsignedIntegerValue])];
    }
    else {
        [super setSerializedValue:serializedValue forKey:key];
    }
}

#pragma mark -
#pragma mark Accessors

-(void)setBitmapContext:(nullable CGContextRef)newContext
{
    if ( newContext != bitmapContext ) {
        CGContextRelease(bitmapContext);
        bitmapContext = CGContextRetain(newContext);
    }
}

#pragma mark -
#pragma mark Subclass methods

-(void)addPlotWithIndex:(NSUInteger __unused)index
{
    /*
     * Subclasses should override this method to create their own ports, plots, and add the plots to the graph
     */
}

-(void)removePlots:(NSUInteger __unused)count
{
    /*
     * Subclasses should override this method to remove plots and their ports
     */
}

-(BOOL)configurePlots
{
    /*
     * Subclasses sjpi;d override this method to configure the plots (i.e., by using values from the input ports)
     */

    return YES;
}

-(BOOL)configureGraph
{
    /*
     * Subclasses can override this method to configure the graph (i.e., by using values from the input ports)
     */

    // Configure the graph area
    CGRect frame = CPTRectMake(0.0, 0.0, MAX(1, self.inputPixelsWide), MAX(1, self.inputPixelsHigh));

    self.graph.bounds = frame;

    self.graph.paddingLeft   = 0.0;
    self.graph.paddingRight  = 0.0;
    self.graph.paddingTop    = 0.0;
    self.graph.paddingBottom = 0.0;

    // Perform some sanity checks.  If there is a configuration error set the error flag so that a message is displayed
    if ((self.inputXMax <= self.inputXMin) || (self.inputYMax <= self.inputYMin)) {
        return NO;
    }

    self.graph.fill               = nil;
    self.graph.plotAreaFrame.fill = [CPTFill fillWithColor:[CPTColor colorWithCGColor:self.inputPlotAreaColor]];
    if ( self.inputAxisLineWidth > 0.0 ) {
        CPTMutableLineStyle *lineStyle = [CPTMutableLineStyle lineStyle];
        lineStyle.lineWidth                      = self.inputAxisLineWidth;
        lineStyle.lineColor                      = [CPTColor colorWithCGColor:self.inputAxisColor];
        self.graph.plotAreaFrame.borderLineStyle = lineStyle;
    }
    else {
        self.graph.plotAreaFrame.borderLineStyle = nil;
    }

    // Configure the plot space and axis sets
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)self.graph.defaultPlotSpace;
    plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:@(self.inputXMin) length:@(self.inputXMax - self.inputXMin)];
    plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:@(self.inputYMin) length:@(self.inputYMax - self.inputYMin)];

    [self configureAxis];

    [self.graph layoutIfNeeded];
    [self.graph setNeedsDisplay];

    return YES;
}

@end

#pragma mark -

@implementation CorePlotQCPlugIn(Execution)

-(BOOL)execute:(nonnull id<QCPlugInContext>)context atTime:(NSTimeInterval __unused)time withArguments:(nullable CPTDictionary *__unused)arguments
{
    // Configure the plot for drawing
    BOOL configurationCheck = [self configureGraph];

    // If the output image dimensions change recreate the image resources
    if ( [self didValueForInputKeyChange:@"inputPixelsWide"] || [self didValueForInputKeyChange:@"inputPixelsHigh"] || !self.imageProvider ) {
        [self freeImageResources];
    }

    // Verifies that the image data + bitmap context are valid
    [self createImageResourcesWithContext:context];

    // Draw the plot ...
    CGSize boundsSize      = self.graph.bounds.size;
    CGContextRef bmContext = self.bitmapContext;
    CGContextClearRect(bmContext, CPTRectMake(0.0, 0.0, boundsSize.width, boundsSize.height));
    CGContextSetRGBFillColor(bmContext, 0.0, 0.0, 0.0, 0.0);
    CGContextFillRect(bmContext, CPTRectMake(0, 0, boundsSize.width, boundsSize.height));
    CGContextSetAllowsAntialiasing(bmContext, true);

    if ( configurationCheck ) {
        [self configurePlots];
        [self.graph recursivelyRenderInContext:bmContext];
    }
    else {
        drawErrorText(bmContext, CPTRectMake(0, 0, self.inputPixelsWide, self.inputPixelsHigh));
    }

    // CGContextSetAllowsAntialiasing(bitmapContext, false);
    CGContextFlush(bmContext);

    // ... and put it on the output port
    id<QCPlugInOutputImageProvider> provider = self.imageProvider;
    if ( provider ) {
        self.outputImage = provider;
        return YES;
    }
    else {
        return NO;
    }
}

@end
