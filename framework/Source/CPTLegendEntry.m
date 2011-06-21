#import "CPTLegendEntry.h"

#import "CPTPlot.h"
#import "CPTTextStyle.h"

/**	@cond */
@interface CPTLegendEntry()

@property (nonatomic, readwrite, assign) CGSize titleSize;

@end
/**	@endcond */

#pragma mark -

/**	@brief A graph legend entry.
 **/
@implementation CPTLegendEntry

/**	@property plot
 *	@brief The plot associated with this legend entry.
 **/
@synthesize plot;

/**	@property index
 *	@brief index The zero-based index of the legend entry for the given plot.
 **/
@synthesize index;

/**	@property row
 *	@brief The row number where this entry appears in the legend (first row is 0).
 **/
@synthesize row;

/**	@property column
 *	@brief The column number where this entry appears in the legend (first column is 0).
 **/
@synthesize column;

/**	@property title
 *	@brief The legend entry title.
 **/
@synthesize title;

/**	@property textStyle
 *	@brief The text style used to draw the legend entry title.
 **/
@synthesize textStyle;

/**	@property titleSize
 *	@brief The size of the legend entry title when drawn using the textStyle.
 **/
@synthesize titleSize;

#pragma mark -
#pragma mark Init/Dealloc

-(id)init
{
	if ( (self = [super init]) ) {
		plot = nil;
		index = 0;
		row = 0;
		column = 0;
		title = nil;
		textStyle = nil;
		titleSize = CGSizeZero;
	}
	return self;
}

-(void)dealloc
{
	[title release];
	[textStyle release];
	
	[super dealloc];
}

#pragma mark -
#pragma mark Drawing

-(void)drawTitleInRect:(CGRect)rect inContext:(CGContextRef)context;
{
#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
	CGContextSaveGState(context);
	CGContextTranslateCTM(context, 0.0, rect.origin.y);
	CGContextScaleCTM(context, 1.0, -1.0);
	CGContextTranslateCTM(context, 0.0, -CGRectGetMaxY(rect));
#endif
	// center the title vertically
	CGRect textRect = rect;
	CGSize theTitleSize = self.titleSize;
	if ( theTitleSize.height < textRect.size.height ) {
		textRect = CGRectInset(textRect, 0.0, (textRect.size.height - theTitleSize.height) / 2.0);
	}
	[self.title drawInRect:textRect withTextStyle:self.textStyle inContext:context];
#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
	CGContextRestoreGState(context);
#endif
}

#pragma mark -
#pragma mark Accessors

-(void)setTitle:(NSString *)newTitle
{
	if ( newTitle != title ) {
		[title release];
		title = [newTitle retain];
		self.titleSize = CGSizeZero;
	}
}

-(void)setTextStyle:(CPTTextStyle *)newTextStyle
{
	if ( newTextStyle != textStyle ) {
		[textStyle release];
		textStyle = [newTextStyle retain];
		self.titleSize = CGSizeZero;
	}
}

-(CGSize)titleSize
{
	if ( CGSizeEqualToSize(titleSize, CGSizeZero) ) {
		NSString *theTitle = self.title;
		CPTTextStyle *theTextStyle = self.textStyle;
		
		if ( theTitle && theTextStyle ) {
			titleSize = [theTitle sizeWithTextStyle:theTextStyle];
		}
	}

	return titleSize;
}

@end
