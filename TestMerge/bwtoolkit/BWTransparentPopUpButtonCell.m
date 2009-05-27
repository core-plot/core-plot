//
//  BWTransparentPopUpButtonCell.m
//  BWToolkit
//
//  Created by Brandon Walkin (www.brandonwalkin.com)
//  All code is provided under the New BSD license.
//

#import "BWTransparentPopUpButtonCell.h"
#import "NSImage+BWAdditions.h"

static NSImage *popUpFillN, *popUpFillP, *popUpRightN, *popUpRightP, *popUpLeftN, *popUpLeftP, *pullDownRightN, *pullDownRightP;
static NSColor *disabledColor, *enabledColor;

@interface BWTransparentPopUpButtonCell (BWTPUBCPrivate)
- (void)drawTitleWithFrame:(NSRect)cellFrame;
- (void)drawImageWithFrame:(NSRect)cellFrame;
@end

@implementation BWTransparentPopUpButtonCell

+ (void)initialize;
{
	NSBundle *bundle = [NSBundle bundleForClass:[BWTransparentPopUpButtonCell class]];
	
	popUpFillN = [[NSImage alloc] initWithContentsOfFile:[bundle pathForImageResource:@"TransparentPopUpFillN.tiff"]];
	popUpFillP = [[NSImage alloc] initWithContentsOfFile:[bundle pathForImageResource:@"TransparentPopUpFillP.tiff"]];
	popUpRightN = [[NSImage alloc] initWithContentsOfFile:[bundle pathForImageResource:@"TransparentPopUpRightN.tiff"]];
	popUpRightP = [[NSImage alloc] initWithContentsOfFile:[bundle pathForImageResource:@"TransparentPopUpRightP.tiff"]];
	popUpLeftN = [[NSImage alloc] initWithContentsOfFile:[bundle pathForImageResource:@"TransparentPopUpLeftN.tiff"]];
	popUpLeftP = [[NSImage alloc] initWithContentsOfFile:[bundle pathForImageResource:@"TransparentPopUpLeftP.tiff"]];
	pullDownRightN = [[NSImage alloc] initWithContentsOfFile:[bundle pathForImageResource:@"TransparentPopUpPullDownRightN.tif"]];
	pullDownRightP = [[NSImage alloc] initWithContentsOfFile:[bundle pathForImageResource:@"TransparentPopUpPullDownRightP.tif"]];
	
	enabledColor = [[NSColor whiteColor] retain];
	disabledColor = [[NSColor colorWithCalibratedWhite:0.6 alpha:1] retain];
}

- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
	cellFrame.size.height = popUpFillN.size.height;
	
	if ([self isHighlighted])
	{
		if ([self pullsDown])
			NSDrawThreePartImage(cellFrame, popUpLeftP, popUpFillP, pullDownRightP, NO, NSCompositeSourceOver, 1, YES);
		else
			NSDrawThreePartImage(cellFrame, popUpLeftP, popUpFillP, popUpRightP, NO, NSCompositeSourceOver, 1, YES);
	}
	else
	{
		if ([self pullsDown])
			NSDrawThreePartImage(cellFrame, popUpLeftN, popUpFillN, pullDownRightN, NO, NSCompositeSourceOver, 1, YES);
		else
			NSDrawThreePartImage(cellFrame, popUpLeftN, popUpFillN, popUpRightN, NO, NSCompositeSourceOver, 1, YES);
	}
		
	if ([self isEnabled])
		interiorColor = enabledColor;
	else
		interiorColor = disabledColor;
	
	if ([self image] == nil)
		[self drawTitleWithFrame:cellFrame];
	else
		[self drawImageWithFrame:cellFrame];
}

- (void)drawTitleWithFrame:(NSRect)cellFrame
{
	if (![[self title] isEqualToString:@""])
	{
		NSMutableDictionary *attributes = [[[NSMutableDictionary alloc] init] autorelease];
		[attributes addEntriesFromDictionary:[[self attributedTitle] attributesAtIndex:0 effectiveRange:NULL]];
		[attributes setObject:interiorColor forKey:NSForegroundColorAttributeName];
		
		NSMutableAttributedString *string = [[[NSMutableAttributedString alloc] initWithString:[self title] attributes:attributes] autorelease];
		
		[string drawAtPoint:NSMakePoint(8,2)];
	}	
}

- (void)drawImageWithFrame:(NSRect)cellFrame
{
	NSImage *image = [self image];
	
	if (image != nil)
	{
		[image setScalesWhenResized:NO];
		NSRect sourceRect = NSZeroRect;
		
		if ([[image name] isEqualToString:@"NSActionTemplate"])
			[image setSize:NSMakeSize(10,10)];
		
		sourceRect.size = [image size];
		
		NSPoint backgroundCenter;
		backgroundCenter.x = cellFrame.size.width / 2;
		backgroundCenter.y = cellFrame.size.height / 2;
		
		NSPoint drawPoint = backgroundCenter;
		drawPoint.x -= sourceRect.size.width / 2;
		drawPoint.y -= sourceRect.size.height / 2;
		
		drawPoint.x = 8;
		drawPoint.y = roundf(drawPoint.y) + 1;
		
		NSImage *glyphImage = image;
		
		if ([image isTemplate])
		{
			glyphImage = [image tintedImageWithColor:interiorColor];
			
			NSAffineTransform* xform = [NSAffineTransform transform];
			[xform translateXBy:0.0 yBy:cellFrame.size.height];
			[xform scaleXBy:1.0 yBy:-1.0];
			[xform concat];
		}
		
		[glyphImage drawAtPoint:drawPoint fromRect:sourceRect operation:NSCompositeSourceOver fraction:1];
	}	
}

- (NSControlSize)controlSize
{
	return NSSmallControlSize;
}

- (void)setControlSize:(NSControlSize)size
{
	
}

@end
