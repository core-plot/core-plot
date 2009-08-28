//
//  CorePlotQCPlugInPlugIn.m
//  CorePlotQCPlugIn
//
//  Created by Caleb Cannon on 8/3/09.
//  Copyright (c) 2009 __MyCompanyName__. All rights reserved.
//

/* It's highly recommended to use CGL macros instead of changing the current context for plug-ins that perform OpenGL rendering */
#import <OpenGL/CGLMacro.h>

#import "CorePlotQCPlugIn.h"

#define	kQCPlugIn_Name				@"CorePlotQCPlugIn"
#define	kQCPlugIn_Description		@"CorePlotQCPlugIn base plugin."


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



@implementation CorePlotQCPlugIn

// TODO: Make the port accessors dynamic, that way certain inputs can be removed based on settings and subclasses won't need the @dynamic declarations

/* 
Accessor for the output image
*/
@dynamic outputImage;

/*
Dynamic accessors for the static PlugIn inputs
*/
@dynamic inputPixelsWide, inputPixelsHigh;
@dynamic inputBackgroundColor, inputPlotAreaColor, inputBorderColor;
@dynamic inputAxisColor, inputAxisLineWidth, inputAxisMinorTickWidth, inputAxisMajorTickWidth, inputAxisMajorTickLength, inputAxisMinorTickLength;
@dynamic inputMajorGridLineWidth, inputMinorGridLineWidth;
@dynamic inputXMin, inputXMax, inputYMin, inputYMax;
@dynamic inputLeftMargin, inputRightMargin, inputTopMargin, inputBottomMargin;
@dynamic inputXMajorIntervals, inputYMajorIntervals, inputXMinorIntervals, inputYMinorIntervals;

/*
Synthesized accessors for internal PlugIn settings
*/
@synthesize numberOfPlots;

+ (NSDictionary*) attributes
{
	/*
	Return a dictionary of attributes describing the plug-in (QCPlugInAttributeNameKey, QCPlugInAttributeDescriptionKey...).
	*/
	
	return [NSDictionary dictionaryWithObjectsAndKeys:
			kQCPlugIn_Name, QCPlugInAttributeNameKey, 
			kQCPlugIn_Description, QCPlugInAttributeDescriptionKey, 
			nil];
}

+ (QCPlugInExecutionMode) executionMode
{
	/*
	Return the execution mode of the plug-in: kQCPlugInExecutionModeProvider, kQCPlugInExecutionModeProcessor, or kQCPlugInExecutionModeConsumer.
	*/
	
	return kQCPlugInExecutionModeProcessor;
}

+ (QCPlugInTimeMode) timeMode
{
	/*
	Return the time dependency mode of the plug-in: kQCPlugInTimeModeNone, kQCPlugInTimeModeIdle or kQCPlugInTimeModeTimeBase.
	*/
	
	return kQCPlugInTimeModeNone;
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

- (QCPlugInViewController*) createViewController
{
	/*
	Return a new QCPlugInViewController to edit the internal settings of this plug-in instance.
	You can return a subclass of QCPlugInViewController if necessary.
	*/
	
	return [[QCPlugInViewController alloc] initWithPlugIn:self viewNibName:@"Settings"];
}

#pragma mark -
#pragma markInput and output port configuration

+ (NSArray*) sortedPropertyPortKeys
{
	return [NSArray arrayWithObjects:
			@"inputPixelsWide", 
			@"inputPixelsHigh", 
			@"inputBackgroundColor", 
			@"inputPlotAreaColor", 
			@"inputBorderColor", 
			@"inputAxisColor", 
			@"inputAxisLineWidth",
			
			@"inputLeftMargin",
			@"inputRightMargin",
			@"inputTopMargin",
			@"inputBottomMargin",
			
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
	 Specify the optional attributes for property based ports (QCPortAttributeNameKey, QCPortAttributeDefaultValueKey...).
	 */
	
	if ([key isEqualToString:@"inputXMin"])
		return [NSDictionary dictionaryWithObjectsAndKeys:
				@"X Range Min", QCPortAttributeNameKey,
				[NSNumber numberWithFloat:-1.0], QCPortAttributeDefaultValueKey,
				nil];
	
	if ([key isEqualToString:@"inputXMax"])
		return [NSDictionary dictionaryWithObjectsAndKeys:
				@"X Range Max", QCPortAttributeNameKey,
				[NSNumber numberWithFloat:1.0], QCPortAttributeDefaultValueKey,
				nil];
	
	if ([key isEqualToString:@"inputYMin"])
		return [NSDictionary dictionaryWithObjectsAndKeys:
				@"Y Range Min", QCPortAttributeNameKey,
				[NSNumber numberWithFloat:-1.0], QCPortAttributeDefaultValueKey,
				nil];
	
	if ([key isEqualToString:@"inputYMax"])
		return [NSDictionary dictionaryWithObjectsAndKeys:
				@"Y Range Max", QCPortAttributeNameKey,
				[NSNumber numberWithFloat:1.0], QCPortAttributeDefaultValueKey,
				nil];

	if ([key isEqualToString:@"inputLeftMargin"])
		return [NSDictionary dictionaryWithObjectsAndKeys:
				@"Left Margin", QCPortAttributeNameKey,
				[NSNumber numberWithInt:60], QCPortAttributeDefaultValueKey,
				nil];

	if ([key isEqualToString:@"inputRightMargin"])
		return [NSDictionary dictionaryWithObjectsAndKeys:
				@"Right Margin", QCPortAttributeNameKey,
				[NSNumber numberWithInt:60], QCPortAttributeDefaultValueKey,
				nil];

	if ([key isEqualToString:@"inputTopMargin"])
		return [NSDictionary dictionaryWithObjectsAndKeys:
				@"Top Margin", QCPortAttributeNameKey,
				[NSNumber numberWithInt:60], QCPortAttributeDefaultValueKey,
				nil];

	if ([key isEqualToString:@"inputBottomMargin"])
		return [NSDictionary dictionaryWithObjectsAndKeys:
				@"Bottom Margin", QCPortAttributeNameKey,
				[NSNumber numberWithInt:60], QCPortAttributeDefaultValueKey,
				nil];
	
	if ([key isEqualToString:@"inputXMajorIntervals"])
		return [NSDictionary dictionaryWithObjectsAndKeys:
				@"X Major Intervals", QCPortAttributeNameKey,
				[NSNumber numberWithFloat:4], QCPortAttributeDefaultValueKey,
				[NSNumber numberWithFloat:0], QCPortAttributeMinimumValueKey,
				nil];
	
	if ([key isEqualToString:@"inputYMajorIntervals"])
		return [NSDictionary dictionaryWithObjectsAndKeys:
				@"Y Major Intervals", QCPortAttributeNameKey,
				[NSNumber numberWithFloat:4], QCPortAttributeDefaultValueKey,
				[NSNumber numberWithFloat:0], QCPortAttributeMinimumValueKey,
				nil];
	
	if ([key isEqualToString:@"inputXMinorIntervals"])
		return [NSDictionary dictionaryWithObjectsAndKeys:
				@"X Minor Intervals", QCPortAttributeNameKey,
				[NSNumber numberWithInt:1], QCPortAttributeDefaultValueKey,
				[NSNumber numberWithInt:0], QCPortAttributeMinimumValueKey,
				nil];
	
	if ([key isEqualToString:@"inputYMinorIntervals"])
		return [NSDictionary dictionaryWithObjectsAndKeys:
				@"Y Minor Intervals", QCPortAttributeNameKey,
				[NSNumber numberWithInt:1], QCPortAttributeDefaultValueKey,
				[NSNumber numberWithInt:0], QCPortAttributeMinimumValueKey,
				nil];
	
	if ([key isEqualToString:@"inputAxisColor"])
		return [NSDictionary dictionaryWithObjectsAndKeys:
				@"Axis Color", QCPortAttributeNameKey,
				CGColorCreateGenericRGB(1.0, 1.0, 1.0, 1.0), QCPortAttributeDefaultValueKey,
				nil];
	
	if ([key isEqualToString:@"inputAxisLineWidth"])
		return [NSDictionary dictionaryWithObjectsAndKeys:
				@"Axis Line Width", QCPortAttributeNameKey,
				[NSNumber numberWithDouble:0.0], QCPortAttributeMinimumValueKey,
				[NSNumber numberWithDouble:1.0], QCPortAttributeDefaultValueKey,
				nil];
	
	if ([key isEqualToString:@"inputAxisMajorTickWidth"])
		return [NSDictionary dictionaryWithObjectsAndKeys:
				@"Major Tick Width", QCPortAttributeNameKey,
				[NSNumber numberWithDouble:0.0], QCPortAttributeMinimumValueKey,
				[NSNumber numberWithDouble:2.0], QCPortAttributeDefaultValueKey,
				nil];
	
	if ([key isEqualToString:@"inputAxisMinorTickWidth"])
		return [NSDictionary dictionaryWithObjectsAndKeys:
				@"Minor Tick Width", QCPortAttributeNameKey,
				[NSNumber numberWithDouble:0.0], QCPortAttributeMinimumValueKey,
				[NSNumber numberWithDouble:1.0], QCPortAttributeDefaultValueKey,
				nil];
	
	if ([key isEqualToString:@"inputAxisMajorTickLength"])
		return [NSDictionary dictionaryWithObjectsAndKeys:
				@"Major Tick Length", QCPortAttributeNameKey,
				[NSNumber numberWithDouble:0.0], QCPortAttributeMinimumValueKey,
				[NSNumber numberWithDouble:10.0], QCPortAttributeDefaultValueKey,
				nil];
	
	if ([key isEqualToString:@"inputAxisMinorTickLength"])
		return [NSDictionary dictionaryWithObjectsAndKeys:
				@"Minor Tick Length", QCPortAttributeNameKey,
				[NSNumber numberWithDouble:0.0], QCPortAttributeMinimumValueKey,
				[NSNumber numberWithDouble:3.0], QCPortAttributeDefaultValueKey,
				nil];
	
	if ([key isEqualToString:@"inputMajorGridLineWidth"])
		return [NSDictionary dictionaryWithObjectsAndKeys:
				@"Major Grid Line Width", QCPortAttributeNameKey,
				[NSNumber numberWithDouble:0.0], QCPortAttributeMinimumValueKey,
				[NSNumber numberWithDouble:1.0], QCPortAttributeDefaultValueKey,
				nil];
	
	if ([key isEqualToString:@"inputMinorGridLineWidth"])
		return [NSDictionary dictionaryWithObjectsAndKeys:
				@"Minor Grid Line Width", QCPortAttributeNameKey,
				[NSNumber numberWithDouble:0.0], QCPortAttributeMinimumValueKey,
				[NSNumber numberWithDouble:0.0], QCPortAttributeDefaultValueKey,
				nil];
	
	if ([key isEqualToString:@"inputBorderColor"])
		return [NSDictionary dictionaryWithObjectsAndKeys:
				@"Border Color", QCPortAttributeNameKey,
				CGColorCreateGenericRGB(1.0, 1.0, 1.0, 0.0), QCPortAttributeDefaultValueKey,
				nil];
	
	if ([key isEqualToString:@"inputBackgroundColor"])
		return [NSDictionary dictionaryWithObjectsAndKeys:
				@"Background Color", QCPortAttributeNameKey,
				CGColorCreateGenericRGB(0.0, 0.0, 0.0, 0.2), QCPortAttributeDefaultValueKey,
				nil];
	
	if ([key isEqualToString:@"inputPlotAreaColor"])
		return [NSDictionary dictionaryWithObjectsAndKeys:
				@"Plot Area Color", QCPortAttributeNameKey,
				CGColorCreateGenericRGB(0.0, 0.0, 0.0, 0.4), QCPortAttributeDefaultValueKey,
				nil];
	
	if ([key isEqualToString:@"inputPixelsWide"])
		return [NSDictionary dictionaryWithObjectsAndKeys:
				@"Pixels Wide", QCPortAttributeNameKey,
				[NSNumber numberWithInt:1], QCPortAttributeMinimumValueKey,
				[NSNumber numberWithInt:512], QCPortAttributeDefaultValueKey,
				nil];
	
	if ([key isEqualToString:@"inputPixelsHigh"])
		return [NSDictionary dictionaryWithObjectsAndKeys:
				@"Pixels High", QCPortAttributeNameKey,
				[NSNumber numberWithInt:1], QCPortAttributeMinimumValueKey,
				[NSNumber numberWithInt:512], QCPortAttributeDefaultValueKey,
				nil];
	
	if ([key isEqualToString:@"outputImage"])
		return [NSDictionary dictionaryWithObjectsAndKeys:
				@"Image", QCPortAttributeNameKey,
				nil];
	
	return nil;
}

#pragma mark -
#pragma markGraph configuration

- (void) createGraph
{ 
	if (!graph)
	{
		// Create graph from theme
		CPTheme *theme = [CPTheme themeNamed:kCPPlainBlackTheme];
		graph = (CPXYGraph *)[theme newGraph];
				
		// Setup scatter plot space
		CPXYPlotSpace *plotSpace = (CPXYPlotSpace *)graph.defaultPlotSpace;
		[plotSpace setAutoresizingMask:kCALayerWidthSizable|kCALayerHeightSizable];
		plotSpace.xRange = [CPPlotRange plotRangeWithLocation:CPDecimalFromFloat(1.0) length:CPDecimalFromFloat(1.0)];
		plotSpace.yRange = [CPPlotRange plotRangeWithLocation:CPDecimalFromFloat(-1.0) length:CPDecimalFromFloat(1.0)];
		
		
		// Axes
		CPXYAxisSet *axisSet = (CPXYAxisSet *)graph.axisSet;
		axisSet.overlayLayerInsetX = -0.f;
		axisSet.overlayLayerInsetY = -0.f;
		
		CPXYAxis *x = axisSet.xAxis;
		x.majorIntervalLength = CPDecimalFromString(@"0.5");
		x.constantCoordinateValue = CPDecimalFromString(@"0.0");
		x.minorTicksPerInterval = 2;
		
		CPXYAxis *y = axisSet.yAxis;
		y.majorIntervalLength = CPDecimalFromString(@"0.5");
		y.minorTicksPerInterval = 5;
		y.constantCoordinateValue = CPDecimalFromString(@"0.0");
	}		
}

- (CGColorRef) defaultColorForPlot:(NSUInteger)index alpha:(float)alpha
{
	switch (index) {
		case 0:
			return CGColorCreateGenericRGB(1.0, 0.0, 0.0, alpha);
			break;
		case 1:
			return CGColorCreateGenericRGB(0.0, 1.0, 0.0, alpha);
			break;
		case 2:
			return CGColorCreateGenericRGB(0.0, 0.0, 1.0, alpha);
			break;
		case 3:
			return CGColorCreateGenericRGB(1.0, 1.0, 0.0, alpha);
			break;
		case 4:
			return CGColorCreateGenericRGB(1.0, 0.0, 1.0, alpha);
			break;
		case 5:
			return CGColorCreateGenericRGB(0.0, 1.0, 1.0, alpha);
			break;
		default:
			return CGColorCreateGenericRGB(1.0, 0.0, 0.0, alpha);
			break;
	}
}

- (void) addPlots:(NSUInteger)count
{
	for (int i = 0; i < count; i++)
		[self addPlotWithIndex:i+numberOfPlots];
}

- (BOOL) configureAxis
{
	CPColor *axisColor = [CPColor colorWithCGColor:self.inputAxisColor];
	
	CPXYAxisSet *set = (CPXYAxisSet *)graph.axisSet;
	set.xAxis.axisLineStyle.lineColor = axisColor;
	set.yAxis.axisLineStyle.lineColor = axisColor;
	
	set.xAxis.majorTickLineStyle.lineColor = axisColor;
	set.yAxis.majorTickLineStyle.lineColor = axisColor;
	
	set.xAxis.minorTickLineStyle.lineColor = axisColor;
	set.yAxis.minorTickLineStyle.lineColor = axisColor;
	
	set.xAxis.axisLabelTextStyle.color = axisColor;
	set.yAxis.axisLabelTextStyle.color = axisColor;
	
	double xrange = self.inputXMax - self.inputXMin;
	set.xAxis.majorIntervalLength = CPDecimalFromDouble(xrange / (self.inputXMajorIntervals));
	set.xAxis.minorTicksPerInterval = self.inputXMinorIntervals;
	set.xAxis.constantCoordinateValue = CPDecimalFromString(@"0.0");
	
	double yrange = self.inputYMax - self.inputYMin;
	set.yAxis.majorIntervalLength = CPDecimalFromDouble(yrange / (self.inputYMajorIntervals));
	set.yAxis.minorTicksPerInterval = self.inputYMinorIntervals;
	set.yAxis.constantCoordinateValue = CPDecimalFromString(@"0.0");

	set.xAxis.axisLineStyle.lineWidth = self.inputAxisLineWidth;
	set.yAxis.axisLineStyle.lineWidth = self.inputAxisLineWidth;

	set.xAxis.minorTickLineStyle.lineWidth = self.inputAxisMinorTickWidth;
	set.yAxis.minorTickLineStyle.lineWidth = self.inputAxisMinorTickWidth;
	set.xAxis.majorTickLineStyle.lineWidth = self.inputAxisMajorTickWidth;
	set.yAxis.majorTickLineStyle.lineWidth = self.inputAxisMajorTickWidth;
	
	set.xAxis.minorTickLength = self.inputAxisMinorTickLength;
	set.yAxis.minorTickLength = self.inputAxisMinorTickLength;
	
	set.xAxis.majorTickLength = self.inputAxisMajorTickLength;
	set.yAxis.majorTickLength = self.inputAxisMajorTickLength;
	
	if ([self didValueForInputKeyChange:@"inputMajorGridLineWidth"])
	{
		CPLineStyle *majorGridLineStyle;
		if (self.inputMajorGridLineWidth == 0.0)
			majorGridLineStyle = nil;
		else
		{
			majorGridLineStyle = [CPLineStyle lineStyle];
			majorGridLineStyle.lineColor = [CPColor colorWithCGColor:self.inputAxisColor];
			majorGridLineStyle.lineWidth = self.inputMajorGridLineWidth;
		}
		
		set.xAxis.majorGridLineStyle = majorGridLineStyle;
		set.yAxis.majorGridLineStyle = majorGridLineStyle;
	}

	if ([self didValueForInputKeyChange:@"inputMinorGridLineWidth"])
	{
		CPLineStyle *minorGridLineStyle;
		if (self.inputMinorGridLineWidth == 0.0)
			minorGridLineStyle = nil;
		else
		{
			minorGridLineStyle = [CPLineStyle lineStyle];
			minorGridLineStyle.lineColor = [CPColor colorWithCGColor:self.inputAxisColor];
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
	id<QCPlugInInputImageSource> img = [self valueForInputKey:key];
	if (!img)
		return nil;
	
	#if __BIG_ENDIAN__
    NSString *pixelFormat = QCPlugInPixelFormatARGB8;
	#else
    NSString *pixelFormat = QCPlugInPixelFormatBGRA8;
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

- (void) createImageResourcesWithContext:(id<QCPlugInContext>)context
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
	imageProvider = [context outputImageProviderFromBufferWithPixelFormat:QCPlugInPixelFormatBGRA8
															   pixelsWide:(NSInteger)boundsSize.width
															   pixelsHigh:(NSInteger)boundsSize.height
															  baseAddress:imageData 
															  bytesPerRow:rowBytes 
														  releaseCallback:_BufferReleaseCallback 
														   releaseContext:NULL 
															   colorSpace:[context colorSpace] 
														 shouldColorMatch:YES];
	#else
	imageProvider = [context outputImageProviderFromBufferWithPixelFormat:QCPlugInPixelFormatARGB8
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

-(NSUInteger)numberOfRecordsForPlot:(CPPlot *)plot 
{	
	return 0;
}

-(NSNumber *)numberForPlot:(CPPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index 
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
	
	graph.paddingLeft = self.inputLeftMargin;
	graph.paddingRight = self.inputRightMargin;
	graph.paddingTop = self.inputTopMargin;
	graph.paddingBottom = self.inputBottomMargin;
	
	// Perform some sanity checks.  If there is a configuration error set the error flag so that a message is displayed
	if (self.inputXMax <= self.inputXMin || self.inputYMax <= self.inputYMin)
		return NO;
	
	[graph layoutSublayers];
	[graph layoutIfNeeded];
	
	graph.fill = [CPFill fillWithColor:[CPColor colorWithCGColor:self.inputBackgroundColor]];
	graph.plotArea.fill = [CPFill fillWithColor:[CPColor colorWithCGColor:self.inputPlotAreaColor]];
	
	// Configure the plot space and axis sets	
	CPXYPlotSpace *plotSpace = (CPXYPlotSpace *)graph.defaultPlotSpace;
	plotSpace.xRange = [CPPlotRange plotRangeWithLocation:CPDecimalFromFloat(self.inputXMin) length:CPDecimalFromFloat(self.inputXMax-self.inputXMin)];
	plotSpace.yRange = [CPPlotRange plotRangeWithLocation:CPDecimalFromFloat(self.inputYMin) length:CPDecimalFromFloat(self.inputYMax-self.inputYMin)];
	
	CPXYAxisSet *set = (CPXYAxisSet *)graph.axisSet;
	[[(CPBorderedLayer *)set.overlayLayer borderLineStyle] setLineColor:[CPColor colorWithCGColor:self.inputBorderColor]];
	set.xAxis.constantCoordinateValue = CPDecimalFromString(@"0.0");
	set.yAxis.constantCoordinateValue = CPDecimalFromString(@"0.0");
	
	[self configureAxis];	

	
	// TODO: for some reason certain plot elements aren't being layed out correctly when, for example,
	// adjusting the plot ranges.
	[graph layoutSublayers];
	[graph layoutIfNeeded];

	return YES;
}

@end

@implementation CorePlotQCPlugIn (Execution)

- (BOOL) execute:(id<QCPlugInContext>)context atTime:(NSTimeInterval)time withArguments:(NSDictionary*)arguments
{	
	// Configure the plot for drawing
	configurationCheck = [self configureGraph];
	
	// TODO: Make sure I'm not leaking memory

	// If the output image dimensions change recreate the image resources
	if ([self didValueForInputKeyChange:@"inputPixelsWide"] || [self didValueForInputKeyChange:@"inputPixelsHigh"] || !imageProvider)
		[self freeImageResources];
	
	[self createImageResourcesWithContext:context];


	// Draw the plot
	CGSize boundsSize = graph.bounds.size;
	CGContextClearRect(bitmapContext, CGRectMake(0.0f, 0.0f, boundsSize.width, boundsSize.height));
	CGContextSetFillColorWithColor(bitmapContext, self.inputBackgroundColor);
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

	CGContextSetAllowsAntialiasing(bitmapContext, false);
	CGContextFlush(bitmapContext);	
	
	// .. and put it on the output port
	self.outputImage = imageProvider;
			
	return YES;
}

@end
