#import <OpenGL/CGLMacro.h>
#import "CorePlotQCPTlugIn.h"

#define	kQCPTlugIn_Name				@"CorePlotQCPTlugIn"
#define	kQCPTlugIn_Description		@"CorePlotQCPTlugIn base plugin."


// Draws the string "ERROR" in the given context in big red letters
void drawErrorText(CGContextRef context, CGRect rect)
{
	// :'(

	CGContextSaveGState(context);
	
    float w, h;
    w = rect.size.width;
    h = rect.size.height;
	
    CGContextSelectFont (context, "Verdana", h/4, kCGEncodingMacRoman);
    CGContextSetTextDrawingMode (context, kCGTextFillStroke);
	
    CGContextSetRGBFillColor (context, 1, 0, 0, 0.5);
    CGContextSetRGBStrokeColor (context, 0, 0, 0, 1);
	
	CGContextSetTextMatrix(context, CGAffineTransformIdentity);
	
	// Compute the width of the text
	CGPoint r0 = CGContextGetTextPosition(context);
	CGContextSetTextDrawingMode(context, kCGTextInvisible);
    CGContextShowText(context, "ERROR", 5); // 10
	CGPoint r1 = CGContextGetTextPosition(context);
	
	float width = r1.x - r0.x;
	float height = h/3;

	float x = rect.origin.x + rect.size.width/2.0 - width/2.0;
	float y = rect.origin.y + rect.size.height/2.0 - height/2.0;
	
	CGContextSetTextDrawingMode(context, kCGTextFillStroke);
    CGContextShowTextAtPoint (context, x, y, "ERROR", 5);
	
	CGContextRestoreGState(context);
}



@implementation CorePlotQCPTlugIn

// TODO: Make the port accessors dynamic, that way certain inputs can be removed based on settings and subclasses won't need the @dynamic declarations

/* 
Accessor for the output image
*/
@dynamic outputImage;

/*
Dynamic accessors for the static PlugIn inputs
*/
@dynamic inputPixelsWide, inputPixelsHigh;
@dynamic inputPlotAreaColor;
@dynamic inputAxisColor, inputAxisLineWidth, inputAxisMinorTickWidth, inputAxisMajorTickWidth, inputAxisMajorTickLength, inputAxisMinorTickLength;
@dynamic inputMajorGridLineWidth, inputMinorGridLineWidth;
@dynamic inputXMin, inputXMax, inputYMin, inputYMax;
@dynamic inputXMajorIntervals, inputYMajorIntervals, inputXMinorIntervals, inputYMinorIntervals;

/*
Synthesized accessors for internal PlugIn settings
*/
@synthesize numberOfPlots;

+ (NSDictionary*) attributes
{
	/*
	Return a dictionary of attributes describing the plug-in (QCPTlugInAttributeNameKey, QCPTlugInAttributeDescriptionKey...).
	*/
	
	return [NSDictionary dictionaryWithObjectsAndKeys:
			kQCPTlugIn_Name, QCPTlugInAttributeNameKey, 
			kQCPTlugIn_Description, QCPTlugInAttributeDescriptionKey, 
			nil];
}

+ (QCPTlugInExecutionMode) executionMode
{
	/*
	Return the execution mode of the plug-in: kQCPTlugInExecutionModeProvider, kQCPTlugInExecutionModeProcessor, or kQCPTlugInExecutionModeConsumer.
	*/
	
	return kQCPTlugInExecutionModeProcessor;
}

+ (QCPTlugInTimeMode) timeMode
{
	/*
	Return the time dependency mode of the plug-in: kQCPTlugInTimeModeNone, kQCPTlugInTimeModeIdle or kQCPTlugInTimeModeTimeBase.
	*/
	
	return kQCPTlugInTimeModeNone;
}

- (id) init
{
	if (self = [super init]) 
	{
		/*
		Allocate any permanent resource required by the plug-in.
		*/

		[self createGraph];

		numberOfPlots = 0;
		[self setNumberOfPlots:1];
		
		imageData = nil;
		imageProvider = nil;
		bitmapContext = nil;
	}
	
	return self;
}

- (void) finalize
{
	/*
	Release any non garbage collected resources created in -init.
	*/
	
	[super finalize];
}

- (void) dealloc
{
	/*
	Release any resources created in -init.
	*/
	
	[self freeResources];
	
	[super dealloc];
}

- (void) freeImageResources
{
	if (bitmapContext)
	{
		CGContextRelease(bitmapContext);
		bitmapContext = nil;
	}
	if (imageData)
	{
		free(imageData);
		imageData = nil;
	}	
}

- (void) freeResources
{
	[self freeImageResources];
	if (graph)
	{
		[graph release];
		graph = nil;
	}
}

- (QCPTlugInViewController*) createViewController
{
	/*
	Return a new QCPTlugInViewController to edit the internal settings of this plug-in instance.
	You can return a subclass of QCPTlugInViewController if necessary.
	*/
	
	return [[QCPTlugInViewController alloc] initWithPlugIn:self viewNibName:@"Settings"];
}

#pragma mark -
#pragma markInput and output port configuration

+ (NSArray*) sortedPropertyPortKeys
{
	return [NSArray arrayWithObjects:
			@"inputPixelsWide", 
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
			@"inputAxisMinorTickWidth",
			nil];
}

+ (NSDictionary*) attributesForPropertyPortWithKey:(NSString*)key
{
	/*
	 Specify the optional attributes for property based ports (QCPTortAttributeNameKey, QCPTortAttributeDefaultValueKey...).
	 */
	
	if ([key isEqualToString:@"inputXMin"])
		return [NSDictionary dictionaryWithObjectsAndKeys:
				@"X Range Min", QCPTortAttributeNameKey,
				[NSNumber numberWithFloat:-1.0], QCPTortAttributeDefaultValueKey,
				nil];
	
	if ([key isEqualToString:@"inputXMax"])
		return [NSDictionary dictionaryWithObjectsAndKeys:
				@"X Range Max", QCPTortAttributeNameKey,
				[NSNumber numberWithFloat:1.0], QCPTortAttributeDefaultValueKey,
				nil];
	
	if ([key isEqualToString:@"inputYMin"])
		return [NSDictionary dictionaryWithObjectsAndKeys:
				@"Y Range Min", QCPTortAttributeNameKey,
				[NSNumber numberWithFloat:-1.0], QCPTortAttributeDefaultValueKey,
				nil];
	
	if ([key isEqualToString:@"inputYMax"])
		return [NSDictionary dictionaryWithObjectsAndKeys:
				@"Y Range Max", QCPTortAttributeNameKey,
				[NSNumber numberWithFloat:1.0], QCPTortAttributeDefaultValueKey,
				nil];

	if ([key isEqualToString:@"inputXMajorIntervals"])
		return [NSDictionary dictionaryWithObjectsAndKeys:
				@"X Major Intervals", QCPTortAttributeNameKey,
				[NSNumber numberWithFloat:4], QCPTortAttributeDefaultValueKey,
				[NSNumber numberWithFloat:0], QCPTortAttributeMinimumValueKey,
				nil];
	
	if ([key isEqualToString:@"inputYMajorIntervals"])
		return [NSDictionary dictionaryWithObjectsAndKeys:
				@"Y Major Intervals", QCPTortAttributeNameKey,
				[NSNumber numberWithFloat:4], QCPTortAttributeDefaultValueKey,
				[NSNumber numberWithFloat:0], QCPTortAttributeMinimumValueKey,
				nil];
	
	if ([key isEqualToString:@"inputXMinorIntervals"])
		return [NSDictionary dictionaryWithObjectsAndKeys:
				@"X Minor Intervals", QCPTortAttributeNameKey,
				[NSNumber numberWithInt:1], QCPTortAttributeDefaultValueKey,
				[NSNumber numberWithInt:0], QCPTortAttributeMinimumValueKey,
				nil];
	
	if ([key isEqualToString:@"inputYMinorIntervals"])
		return [NSDictionary dictionaryWithObjectsAndKeys:
				@"Y Minor Intervals", QCPTortAttributeNameKey,
				[NSNumber numberWithInt:1], QCPTortAttributeDefaultValueKey,
				[NSNumber numberWithInt:0], QCPTortAttributeMinimumValueKey,
				nil];
	
	if ([key isEqualToString:@"inputAxisColor"])
		return [NSDictionary dictionaryWithObjectsAndKeys:
				@"Axis Color", QCPTortAttributeNameKey,
				[(id)CGColorCreateGenericRGB(1.0, 1.0, 1.0, 1.0) autorelease], QCPTortAttributeDefaultValueKey,
				nil];
	
	if ([key isEqualToString:@"inputAxisLineWidth"])
		return [NSDictionary dictionaryWithObjectsAndKeys:
				@"Axis Line Width", QCPTortAttributeNameKey,
				[NSNumber numberWithDouble:0.0], QCPTortAttributeMinimumValueKey,
				[NSNumber numberWithDouble:1.0], QCPTortAttributeDefaultValueKey,
				nil];
	
	if ([key isEqualToString:@"inputAxisMajorTickWidth"])
		return [NSDictionary dictionaryWithObjectsAndKeys:
				@"Major Tick Width", QCPTortAttributeNameKey,
				[NSNumber numberWithDouble:0.0], QCPTortAttributeMinimumValueKey,
				[NSNumber numberWithDouble:2.0], QCPTortAttributeDefaultValueKey,
				nil];
	
	if ([key isEqualToString:@"inputAxisMinorTickWidth"])
		return [NSDictionary dictionaryWithObjectsAndKeys:
				@"Minor Tick Width", QCPTortAttributeNameKey,
				[NSNumber numberWithDouble:0.0], QCPTortAttributeMinimumValueKey,
				[NSNumber numberWithDouble:1.0], QCPTortAttributeDefaultValueKey,
				nil];
	
	if ([key isEqualToString:@"inputAxisMajorTickLength"])
		return [NSDictionary dictionaryWithObjectsAndKeys:
				@"Major Tick Length", QCPTortAttributeNameKey,
				[NSNumber numberWithDouble:0.0], QCPTortAttributeMinimumValueKey,
				[NSNumber numberWithDouble:10.0], QCPTortAttributeDefaultValueKey,
				nil];
	
	if ([key isEqualToString:@"inputAxisMinorTickLength"])
		return [NSDictionary dictionaryWithObjectsAndKeys:
				@"Minor Tick Length", QCPTortAttributeNameKey,
				[NSNumber numberWithDouble:0.0], QCPTortAttributeMinimumValueKey,
				[NSNumber numberWithDouble:3.0], QCPTortAttributeDefaultValueKey,
				nil];
	
	if ([key isEqualToString:@"inputMajorGridLineWidth"])
		return [NSDictionary dictionaryWithObjectsAndKeys:
				@"Major Grid Line Width", QCPTortAttributeNameKey,
				[NSNumber numberWithDouble:0.0], QCPTortAttributeMinimumValueKey,
				[NSNumber numberWithDouble:1.0], QCPTortAttributeDefaultValueKey,
				nil];
	
	if ([key isEqualToString:@"inputMinorGridLineWidth"])
		return [NSDictionary dictionaryWithObjectsAndKeys:
				@"Minor Grid Line Width", QCPTortAttributeNameKey,
				[NSNumber numberWithDouble:0.0], QCPTortAttributeMinimumValueKey,
				[NSNumber numberWithDouble:0.0], QCPTortAttributeDefaultValueKey,
				nil];
	

	if ([key isEqualToString:@"inputPlotAreaColor"])
		return [NSDictionary dictionaryWithObjectsAndKeys:
				@"Plot Area Color", QCPTortAttributeNameKey,
				[(id)CGColorCreateGenericRGB(0.0, 0.0, 0.0, 0.4) autorelease], QCPTortAttributeDefaultValueKey,
				nil];
	
	if ([key isEqualToString:@"inputPixelsWide"])
		return [NSDictionary dictionaryWithObjectsAndKeys:
				@"Pixels Wide", QCPTortAttributeNameKey,
				[NSNumber numberWithInt:1], QCPTortAttributeMinimumValueKey,
				[NSNumber numberWithInt:512], QCPTortAttributeDefaultValueKey,
				nil];
	
	if ([key isEqualToString:@"inputPixelsHigh"])
		return [NSDictionary dictionaryWithObjectsAndKeys:
				@"Pixels High", QCPTortAttributeNameKey,
				[NSNumber numberWithInt:1], QCPTortAttributeMinimumValueKey,
				[NSNumber numberWithInt:512], QCPTortAttributeDefaultValueKey,
				nil];
	
	if ([key isEqualToString:@"outputImage"])
		return [NSDictionary dictionaryWithObjectsAndKeys:
				@"Image", QCPTortAttributeNameKey,
				nil];
	
	return nil;
}

#pragma mark -
#pragma mark Graph configuration

- (void) createGraph
{ 
	if (!graph)
	{
		// Create graph from theme
		CPTTheme *theme = [CPTTheme themeNamed:kCPTPlainBlackTheme];
		graph = (CPTXYGraph *)[theme newGraph];
				
		// Setup scatter plot space
		CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)graph.defaultPlotSpace;
		plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(1.0) length:CPTDecimalFromFloat(1.0)];
		plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(-1.0) length:CPTDecimalFromFloat(1.0)];
		
		// Axes
		CPTXYAxisSet *axisSet = (CPTXYAxisSet *)graph.axisSet;
		
		CPTXYAxis *x = axisSet.xAxis;
		x.majorIntervalLength = CPTDecimalFromFloat(0.5);
		x.minorTicksPerInterval = 2;
		
		CPTXYAxis *y = axisSet.yAxis;
		y.majorIntervalLength = CPTDecimalFromFloat(0.5);
		y.minorTicksPerInterval = 5;
	}		
}

- (CGColorRef) defaultColorForPlot:(NSUInteger)index alpha:(float)alpha
{
	CGColorRef color;
	switch (index) {
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
	
	[(id)color autorelease];
	return color;
}

- (void) addPlots:(NSUInteger)count
{
	for (int i = 0; i < count; i++)
		[self addPlotWithIndex:i+numberOfPlots];
}

- (BOOL) configureAxis
{
	CPTColor *axisColor = [CPTColor colorWithCGColor:self.inputAxisColor];
	
	CPTXYAxisSet *set = (CPTXYAxisSet *)graph.axisSet;
    CPTMutableLineStyle *lineStyle = [CPTMutableLineStyle lineStyle];
    lineStyle.lineColor = axisColor;
    lineStyle.lineWidth = self.inputAxisLineWidth;
	set.xAxis.axisLineStyle = lineStyle;
	set.yAxis.axisLineStyle = lineStyle;
	
    lineStyle.lineWidth = self.inputAxisMajorTickWidth;
	set.xAxis.majorTickLineStyle = lineStyle;
	set.yAxis.majorTickLineStyle = lineStyle;
    
    lineStyle.lineWidth = self.inputAxisMinorTickWidth;
	set.xAxis.minorTickLineStyle = lineStyle;
	set.yAxis.minorTickLineStyle = lineStyle;
	
    CPTMutableTextStyle *textStyle = [CPTMutableTextStyle textStyle];
    textStyle.color = axisColor;
	set.xAxis.labelTextStyle = textStyle;
	
	double xrange = self.inputXMax - self.inputXMin;
	set.xAxis.majorIntervalLength = CPTDecimalFromDouble(xrange / (self.inputXMajorIntervals));
	set.xAxis.minorTicksPerInterval = self.inputXMinorIntervals;
	
	double yrange = self.inputYMax - self.inputYMin;
	set.yAxis.majorIntervalLength = CPTDecimalFromDouble(yrange / (self.inputYMajorIntervals));
	set.yAxis.minorTicksPerInterval = self.inputYMinorIntervals;
	
	set.xAxis.minorTickLength = self.inputAxisMinorTickLength;
	set.yAxis.minorTickLength = self.inputAxisMinorTickLength;
	
	set.xAxis.majorTickLength = self.inputAxisMajorTickLength;
	set.yAxis.majorTickLength = self.inputAxisMajorTickLength;
	
	if ([self didValueForInputKeyChange:@"inputMajorGridLineWidth"] || [self didValueForInputKeyChange:@"inputAxisColor"])
	{
		CPTMutableLineStyle *majorGridLineStyle = nil;
		if (self.inputMajorGridLineWidth == 0.0)
			majorGridLineStyle = nil;
		else
		{
			majorGridLineStyle = [CPTMutableLineStyle lineStyle];
			majorGridLineStyle.lineColor = [CPTColor colorWithCGColor:self.inputAxisColor];
			majorGridLineStyle.lineWidth = self.inputMajorGridLineWidth;
		}
		
		set.xAxis.majorGridLineStyle = majorGridLineStyle;
		set.yAxis.majorGridLineStyle = majorGridLineStyle;
	}

	if ([self didValueForInputKeyChange:@"inputMinorGridLineWidth"] || [self didValueForInputKeyChange:@"inputAxisColor"])
	{
		CPTMutableLineStyle *minorGridLineStyle;
		if (self.inputMinorGridLineWidth == 0.0)
			minorGridLineStyle = nil;
		else
		{
			minorGridLineStyle = [CPTMutableLineStyle lineStyle];
			minorGridLineStyle.lineColor = [CPTColor colorWithCGColor:self.inputAxisColor];
			minorGridLineStyle.lineWidth = self.inputMinorGridLineWidth;
		}
		
		set.xAxis.minorGridLineStyle = minorGridLineStyle;
		set.yAxis.minorGridLineStyle = minorGridLineStyle;
	}
	
	return YES;
}	


- (CGColorRef) dataLineColor:(NSUInteger)index
{
	NSString *key = [NSString stringWithFormat:@"plotDataLineColor%i", index];
	return (CGColorRef)[self valueForInputKey:key];
}

- (CGFloat) dataLineWidth:(NSUInteger)index
{
	NSString *key = [NSString stringWithFormat:@"plotDataLineWidth%i", index];
	return [[self valueForInputKey:key] floatValue];
}

- (CGColorRef) areaFillColor:(NSUInteger)index
{
	NSString *key = [NSString stringWithFormat:@"plotFillColor%i", index];
	return (CGColorRef)[self valueForInputKey:key];
}

- (CGImageRef) areaFillImage:(NSUInteger)index
{
	NSString *key = [NSString stringWithFormat:@"plotFillImage%i", index];
	id<QCPTlugInInputImageSource> img = [self valueForInputKey:key];
	if (!img)
		return nil;
	
	#if __BIG_ENDIAN__
    NSString *pixelFormat = QCPTlugInPixelFormatARGB8;
	#else
    NSString *pixelFormat = QCPTlugInPixelFormatBGRA8;
	#endif
	
	[img lockBufferRepresentationWithPixelFormat:pixelFormat colorSpace:CGColorSpaceCreateDeviceRGB() forBounds:[img imageBounds]];
	void *baseAddress = (void *)[img bufferBaseAddress];
	NSUInteger pixelsWide = [img bufferPixelsWide];
	NSUInteger pixelsHigh = [img bufferPixelsHigh];
	NSUInteger bitsPerComponent = 8;
	NSUInteger bytesPerRow = [img bufferBytesPerRow];
	CGColorSpaceRef colorSpace = [img bufferColorSpace];
	
	CGContextRef imgContext = CGBitmapContextCreate(baseAddress, 
													pixelsWide, 
													pixelsHigh,
													bitsPerComponent,
													bytesPerRow,
													colorSpace,
													kCGImageAlphaNoneSkipLast);
	
	CGImageRef imageRef = CGBitmapContextCreateImage(imgContext);
	
	[img unlockBufferRepresentation];
	
	CGContextRelease(imgContext);
	
	return imageRef;
}

static void _BufferReleaseCallback(const void* address, void* context)
{
	// Don't do anything.  We release the buffer manually when it's recreated or during dealloc
}

- (void) createImageResourcesWithContext:(id<QCPTlugInContext>)context
{
	// Create a CG bitmap for drawing.  The image data is released when QC calls _BufferReleaseCallback
	CGSize boundsSize = graph.bounds.size;
	NSUInteger bitsPerComponent = 8;
	NSUInteger rowBytes = (NSInteger)boundsSize.width * 4;
	if(rowBytes % 16)
		rowBytes = ((rowBytes / 16) + 1) * 16;
	
	if (!imageData)
	{
		imageData = valloc( rowBytes * boundsSize.height );
		bitmapContext = CGBitmapContextCreate(imageData, 
											  boundsSize.width,
											  boundsSize.height, 
											  bitsPerComponent, 
											  rowBytes, 
											  [context colorSpace], 
											  kCGImageAlphaPremultipliedFirst);
	}
	if (!imageData)
	{
		NSLog(@"Couldn't allocate memory for image data");
		return;
	}
	if (!bitmapContext)
	{
		free(imageData);
		imageData = nil;
		NSLog(@"Couldn't create bitmap context");
		return;
	}

	if(rowBytes % 16)
		rowBytes = ((rowBytes / 16) + 1) * 16;
		
	// Note: I don't have a PPC to test on so this may or may not cause some color issues
	#if __BIG_ENDIAN__
	imageProvider = [context outputImageProviderFromBufferWithPixelFormat:QCPTlugInPixelFormatBGRA8
															   pixelsWide:(NSInteger)boundsSize.width
															   pixelsHigh:(NSInteger)boundsSize.height
															  baseAddress:imageData 
															  bytesPerRow:rowBytes 
														  releaseCallback:_BufferReleaseCallback 
														   releaseContext:NULL 
															   colorSpace:[context colorSpace] 
														 shouldColorMatch:YES];
	#else
	imageProvider = [context outputImageProviderFromBufferWithPixelFormat:QCPTlugInPixelFormatARGB8
															   pixelsWide:(NSInteger)boundsSize.width
															   pixelsHigh:(NSInteger)boundsSize.height
															  baseAddress:imageData
															  bytesPerRow:rowBytes 
														  releaseCallback:_BufferReleaseCallback 
														   releaseContext:NULL 
															   colorSpace:[context colorSpace]
														 shouldColorMatch:YES];
	#endif
}

#pragma mark -
#pragma markData source methods

-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot 
{	
	return 0;
}

-(NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index 
{
	return [NSNumber numberWithInt:0];
}

#pragma mark -
#pragma markMethods for dealing with plugin keys

- (void) setNumberOfPlots:(NSUInteger)number
{	
	number = MAX(1, number);
	
	if (number > numberOfPlots)
		[self addPlots:number - numberOfPlots];
	else
		[self removePlots:numberOfPlots - number];
	
	numberOfPlots = number;
}

+ (NSArray*) plugInKeys
{
	return [NSArray arrayWithObjects:
			@"numberOfPlots",
			nil];
}

- (id) serializedValueForKey:(NSString*)key;
{
	/*
	 Provide custom serialization for the plug-in internal settings that are not values complying to the <NSCoding> protocol.
	 The return object must be nil or a PList compatible i.e. NSString, NSNumber, NSDate, NSData, NSArray or NSDictionary.
	 */
	
	
	if ([key isEqualToString:@"numberOfPlots"])
		return [NSNumber numberWithInt:self.numberOfPlots];
	else
		return [super serializedValueForKey:key];
}

- (void) setSerializedValue:(id)serializedValue forKey:(NSString*)key
{
	/*
	 Provide deserialization for the plug-in internal settings that were custom serialized in -serializedValueForKey.
	 Deserialize the value, then call [self setValue:value forKey:key] to set the corresponding internal setting of the plug-in instance to that deserialized value.
	 */
	
	if ([key isEqualToString:@"numberOfPlots"])
		[self setNumberOfPlots:MAX(1, [serializedValue intValue])];
	else
		[super setSerializedValue:serializedValue forKey:key];
}

#pragma mark -
#pragma mark Subclass methods

- (void) addPlotWithIndex:(NSUInteger)index
{
	/*
	 Subclasses should override this method to create their own ports, plots, and add the plots to the graph
	 */
}

- (void) removePlots:(NSUInteger)count
{
	/*
	 Subclasses should override this method to remove plots and their ports
	 */
}

- (BOOL) configurePlots
{
	/*
	 Subclasses sjpi;d override this method to configure the plots (i.e., by using values from the input ports)
	 */
	
	return YES;
}

- (BOOL) configureGraph
{
	/*
	 Subclasses can override this method to configure the graph (i.e., by using values from the input ports)
	*/
	
	// Configure the graph area
	CGRect frame = CGRectMake(0.0, 0.0, MAX(1, self.inputPixelsWide), MAX(1, self.inputPixelsHigh));	
	[graph setBounds:frame];
	
	graph.paddingLeft = 0.0;
	graph.paddingRight = 0.0;
	graph.paddingTop = 0.0;
	graph.paddingBottom = 0.0;
		
	// Perform some sanity checks.  If there is a configuration error set the error flag so that a message is displayed
	if (self.inputXMax <= self.inputXMin || self.inputYMax <= self.inputYMin)
		return NO;
	
	[graph layoutSublayers];
	[graph layoutIfNeeded];
	
	graph.fill = nil;
	graph.plotAreaFrame.fill = [CPTFill fillWithColor:[CPTColor colorWithCGColor:self.inputPlotAreaColor]];
	if (self.inputAxisLineWidth > 0.0)
	{	
    	CPTMutableLineStyle *lineStyle = [CPTMutableLineStyle lineStyle];
        lineStyle.lineWidth = self.inputAxisLineWidth;
        lineStyle.lineColor = [CPTColor colorWithCGColor:self.inputAxisColor];
		graph.plotAreaFrame.borderLineStyle = lineStyle;
	}
	else {
		graph.plotAreaFrame.borderLineStyle = nil;
	}
	
	// Configure the plot space and axis sets	
	CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)graph.defaultPlotSpace;
	plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(self.inputXMin) length:CPTDecimalFromFloat(self.inputXMax-self.inputXMin)];
	plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(self.inputYMin) length:CPTDecimalFromFloat(self.inputYMax-self.inputYMin)];
	
	[self configureAxis];
	
	[graph layoutSublayers];
	[graph setNeedsDisplay];

	return YES;
}

@end

@implementation CorePlotQCPTlugIn (Execution)

- (BOOL) execute:(id<QCPTlugInContext>)context atTime:(NSTimeInterval)time withArguments:(NSDictionary*)arguments
{	
	// Configure the plot for drawing
	configurationCheck = [self configureGraph];
	
	// If the output image dimensions change recreate the image resources
	if ([self didValueForInputKeyChange:@"inputPixelsWide"] || [self didValueForInputKeyChange:@"inputPixelsHigh"] || !imageProvider)
		[self freeImageResources];
	
	// Verifies that the image data + bitmap context are valid
	[self createImageResourcesWithContext:context];

	// Draw the plot ...
	CGSize boundsSize = graph.bounds.size;
	CGContextClearRect(bitmapContext, CGRectMake(0.0f, 0.0f, boundsSize.width, boundsSize.height));
	CGContextSetRGBFillColor(bitmapContext, 0.0, 0.0, 0.0, 0.0);
	CGContextFillRect(bitmapContext, CGRectMake(0, 0, boundsSize.width, boundsSize.height));		
	CGContextSetAllowsAntialiasing(bitmapContext, true);
	
	if (configurationCheck)
	{
		[self configurePlots];
		[graph recursivelyRenderInContext:bitmapContext];
	}
	else
	{
		drawErrorText(bitmapContext, CGRectMake(0, 0, self.inputPixelsWide, self.inputPixelsHigh));
	}

	//CGContextSetAllowsAntialiasing(bitmapContext, false);
	CGContextFlush(bitmapContext);
	
	// ... and put it on the output port
	self.outputImage = imageProvider;
			
	return YES;
}

@end
