//
//  BWTransparentButtonCell.m
//  BWToolkit
//
//  Created by Brandon Walkin (www.brandonwalkin.com)
//  All code is provided under the New BSD license.
//

#import "BWTransparentButtonCell.h"
#import "NSImage+BWAdditions.h"

static NSImage *buttonLeftN, *buttonFillN, *buttonRightN, *buttonLeftP, *buttonFillP, *buttonRightP;
static NSColor *disabledColor, *enabledColor;

@interface BWTransparentButtonCell (BWTBCPrivate)
- (void)drawTitleWithFrame:(NSRect)cellFrame;
- (void)drawImageWithFrame:(NSRect)cellFrame;
@end

@implementation BWTransparentButtonCell

+ (void)initialize;
{
	NSBundle *bundle = [NSBundle bundleForClass:[BWTransparentButtonCell class]];
	
	buttonLeftN = [[NSImage alloc] initWithContentsOfFile:[bundle pathForImageResource:@"TransparentButtonLeftN.tiff"]];
	buttonFillN = [[NSImage alloc] initWithContentsOfFile:[bundle pathForImageResource:@"TransparentButtonFillN.tiff"]];
	buttonRightN = [[NSImage alloc] initWithContentsOfFile:[bundle pathForImageResource:@"TransparentButtonRightN.tiff"]];
	buttonLeftP = [[NSImage alloc] initWithContentsOfFile:[bundle pathForImageResource:@"TransparentButtonLeftP.tiff"]];
	buttonFillP = [[NSImage alloc] initWithContentsOfFile:[bundle pathForImageResource:@"TransparentButtonFillP.tiff"]];
	buttonRightP = [[NSImage alloc] initWithContentsOfFile:[bundle pathForImageResource:@"TransparentButtonRightP.tiff"]];

	enabledColor = [[NSColor whiteColor] retain];
	disabledColor = [[NSColor colorWithCalibratedWhite:0.6 alpha:1] retain];
}

- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
	cellFrame.size.height = buttonFillN.size.height;
	
	if ([self isHighlighted])
		NSDrawThreePartImage(cellFrame, buttonLeftP, buttonFillP, buttonRightP, NO, NSCompositeSourceOver, 1, YES);
	else
		NSDrawThreePartImage(cellFrame, buttonLeftN, buttonFillN, buttonRightN, NO, NSCompositeSourceOver, 1, YES);
	
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
		[attributes setObject:[NSFont systemFontOfSize:11] forKey:NSFontAttributeName];
		NSMutableAttributedString *string = [[[NSMutableAttributedString alloc] initWithString:[self title] attributes:attributes] autorelease];
		[self setAttributedTitle:string];
		
		cellFrame.origin.y += 2;
		[[self attributedTitle] drawInRect:cellFrame];
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
		drawPoint.y -= sourceRect.size.height / 2 ;
		
		drawPoint.x = roundf(drawPoint.x);
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
