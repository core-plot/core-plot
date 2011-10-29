//
//  PlotItem.m
//  CorePlotGallery
//
//  Created by Jeff Buck on 9/4/10.
//  Copyright 2010 Jeff Buck. All rights reserved.
//

#import "PlotGallery.h"

#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
#else
// For IKImageBrowser
#import <Quartz/Quartz.h>
#endif

@implementation PlotItem

@synthesize defaultLayerHostingView;
@synthesize graphs;
@synthesize title;

+(void)registerPlotItem:(id)item
{
	NSLog(@"registerPlotItem for class %@", [item class]);

	Class itemClass = [item class];

	if ( itemClass ) {
		// There's no autorelease pool here yet...
		PlotItem *plotItem = [[itemClass alloc] init];
		if ( plotItem ) {
			[[PlotGallery sharedPlotGallery] addPlotItem:plotItem];
			[plotItem release];
		}
	}
}

-(id)init
{
	if ( (self = [super init]) ) {
		graphs = [[NSMutableArray alloc] init];
	}

	return self;
}

-(void)addGraph:(CPTGraph *)graph toHostingView:(CPTGraphHostingView *)layerHostingView
{
	[graphs addObject:graph];

	if ( layerHostingView ) {
		layerHostingView.hostedGraph = graph;
	}
}

-(void)addGraph:(CPTGraph *)graph
{
	[self addGraph:graph toHostingView:nil];
}

-(void)killGraph
{
	// Remove the CPTLayerHostingView
	if ( defaultLayerHostingView ) {
		[defaultLayerHostingView removeFromSuperview];

		defaultLayerHostingView.hostedGraph = nil;
		[defaultLayerHostingView release];
		defaultLayerHostingView = nil;
	}

	[cachedImage release];
	cachedImage = nil;

	[graphs removeAllObjects];
}

-(void)dealloc
{
	[self killGraph];
	[super dealloc];
}

// override to generate data for the plot if needed
-(void)generateData
{
}

-(NSComparisonResult)titleCompare:(PlotItem *)other
{
	return [title caseInsensitiveCompare:other.title];
}

-(void)setTitleDefaultsForGraph:(CPTGraph *)graph withBounds:(CGRect)bounds
{
	graph.title = title;
	CPTMutableTextStyle *textStyle = [CPTMutableTextStyle textStyle];
	textStyle.color				   = [CPTColor grayColor];
	textStyle.fontName			   = @"Helvetica-Bold";
	textStyle.fontSize			   = round(bounds.size.height / 20.0f);
	graph.titleTextStyle		   = textStyle;
	graph.titleDisplacement		   = CGPointMake( 0.0f, round(bounds.size.height / 18.0f) ); // Ensure that title displacement falls on an integral pixel
	graph.titlePlotAreaFrameAnchor = CPTRectAnchorTop;
}

-(void)setPaddingDefaultsForGraph:(CPTGraph *)graph withBounds:(CGRect)bounds
{
	float boundsPadding = round(bounds.size.width / 20.0f); // Ensure that padding falls on an integral pixel

	graph.paddingLeft = boundsPadding;

	if ( graph.titleDisplacement.y > 0.0 ) {
		graph.paddingTop = graph.titleDisplacement.y * 2;
	}
	else {
		graph.paddingTop = boundsPadding;
	}

	graph.paddingRight	= boundsPadding;
	graph.paddingBottom = boundsPadding;
}

#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE

// There's a UIImage function to scale and orient an existing image,
// but this will also work in pre-4.0 iOS
-(CGImageRef)newCGImageFromImage:(CGImageRef)image scaledToSize:(CGSize)size
{
	CGContextRef c = CGBitmapContextCreate( NULL,
											size.width,
											size.height,
											CGImageGetBitsPerComponent(image),
											CGImageGetBytesPerRow(image),
											CGImageGetColorSpace(image),
											CGImageGetAlphaInfo(image) );

	if ( c == NULL ) {
		return NULL;
	}

	CGContextDrawImage(c, CGRectMake(0, 0, size.width, size.height), image);
	CGImageRef newImage = CGBitmapContextCreateImage(c);
	CGContextRelease(c);

	return newImage;
}

-(UIImage *)image
{
	if ( cachedImage == nil ) {
		CGRect imageFrame = CGRectMake(0, 0, 400, 300);
		UIView *imageView = [[UIView alloc] initWithFrame:imageFrame];
		[imageView setOpaque:YES];
		[imageView setUserInteractionEnabled:NO];

		[self renderInView:imageView withTheme:nil];

		UIGraphicsBeginImageContext(imageView.bounds.size);
		CGContextRef c = UIGraphicsGetCurrentContext();
		CGContextGetCTM(c);
		CGContextScaleCTM(c, 1, -1);
		CGContextTranslateCTM(c, 0, -imageView.bounds.size.height);
		[imageView.layer renderInContext:c];
		cachedImage = [UIGraphicsGetImageFromCurrentImageContext ()retain];

		// rescale graph
		UIImage *bigImage	   = UIGraphicsGetImageFromCurrentImageContext();
		CGImageRef scaledImage = [self newCGImageFromImage:[bigImage CGImage] scaledToSize:CGSizeMake(100.0f, 75.0f)];
		cachedImage = [[UIImage imageWithCGImage:scaledImage] retain];
		CGImageRelease(scaledImage);
		UIGraphicsEndImageContext();

		[imageView release];
	}

	return cachedImage;
}

#else // OSX

-(NSImage *)image
{
	if ( cachedImage == nil ) {
		CGRect imageFrame = CGRectMake(0, 0, 400, 300);

		NSView *imageView = [[NSView alloc] initWithFrame:NSRectFromCGRect(imageFrame)];
		[imageView setWantsLayer:YES];

		[self renderInView:imageView withTheme:nil];

		CGSize boundsSize = imageFrame.size;

		NSBitmapImageRep *layerImage = [[NSBitmapImageRep alloc]
										initWithBitmapDataPlanes:NULL
													  pixelsWide:boundsSize.width
													  pixelsHigh:boundsSize.height
												   bitsPerSample:8
												 samplesPerPixel:4
														hasAlpha:YES
														isPlanar:NO
												  colorSpaceName:NSCalibratedRGBColorSpace
													 bytesPerRow:(NSInteger)boundsSize.width * 4
													bitsPerPixel:32];

		NSGraphicsContext *bitmapContext = [NSGraphicsContext graphicsContextWithBitmapImageRep:layerImage];
		CGContextRef context			 = (CGContextRef)[bitmapContext graphicsPort];

		CGContextClearRect( context, CGRectMake(0.0, 0.0, boundsSize.width, boundsSize.height) );
		CGContextSetAllowsAntialiasing(context, true);
		CGContextSetShouldSmoothFonts(context, false);
		[imageView.layer renderInContext:context];
		CGContextFlush(context);

		cachedImage = [[NSImage alloc] initWithSize:NSSizeFromCGSize(boundsSize)];
		[cachedImage addRepresentation:layerImage];
		[layerImage release];

		[imageView release];
	}

	return cachedImage;
}

#endif

-(void)applyTheme:(CPTTheme *)theme toGraph:(CPTGraph *)graph withDefault:(CPTTheme *)defaultTheme
{
	if ( theme == nil ) {
		[graph applyTheme:defaultTheme];
	}
	else if ( ![theme isKindOfClass:[NSNull class]] ) {
		[graph applyTheme:theme];
	}
}

#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
#else
-(void)setFrameSize:(NSSize)size
{
}

#endif

#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
-(void)renderInView:(UIView *)hostingView withTheme:(CPTTheme *)theme
#else
-(void)renderInView:(NSView *)hostingView withTheme:(CPTTheme *)theme
#endif
{
	[self killGraph];

	defaultLayerHostingView = [(CPTGraphHostingView *)[CPTGraphHostingView alloc] initWithFrame:hostingView.bounds];

#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
	defaultLayerHostingView.collapsesLayers = NO;
#else
	[defaultLayerHostingView setAutoresizesSubviews:YES];
	[defaultLayerHostingView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
#endif

	[hostingView addSubview:defaultLayerHostingView];
	[self generateData];
	[self renderInLayer:defaultLayerHostingView withTheme:theme];
}

-(void)renderInLayer:(CPTGraphHostingView *)layerHostingView withTheme:(CPTTheme *)theme
{
	NSLog(@"PlotItem:renderInLayer: Override me");
}

-(void)reloadData
{
	for ( CPTGraph *g in graphs ) {
		[g reloadData];
	}
}

#pragma mark -
#pragma mark IKImageBrowserItem methods

#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
#else

-(NSString *)imageUID
{
	return title;
}

-(NSString *)imageRepresentationType
{
	return IKImageBrowserNSImageRepresentationType;
}

-(id)imageRepresentation
{
	return [self image];
}

-(NSString *)imageTitle
{
	return title;
}

/*
 * - (NSString*)imageSubtitle
 * {
 *  return graph.title;
 * }
 */

#endif

@end
