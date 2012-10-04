#import "CPTLegendEntry.h"

#import "CPTPlot.h"
#import "CPTTextStyle.h"
#import "CPTUtilities.h"
#import "NSCoderExtensions.h"
#import <tgmath.h>

/// @cond
@interface CPTLegendEntry()

@property (nonatomic, readonly, retain) NSString *title;

@end

/// @endcond

#pragma mark -

/**
 *  @brief A graph legend entry.
 **/
@implementation CPTLegendEntry

/** @property __cpt_weak CPTPlot *plot
 *  @brief The plot associated with this legend entry.
 **/
@synthesize plot;

/** @property NSUInteger index
 *  @brief The zero-based index of the legend entry for the given plot.
 **/
@synthesize index;

/** @property NSUInteger row
 *  @brief The row number where this entry appears in the legend (first row is @num{0}).
 **/
@synthesize row;

/** @property NSUInteger column
 *  @brief The column number where this entry appears in the legend (first column is @num{0}).
 **/
@synthesize column;

/// @cond

/** @property NSString *title
 *  @brief The legend entry title.
 **/
@dynamic title;

/// @endcond

/** @property CPTTextStyle *textStyle
 *  @brief The text style used to draw the legend entry title.
 **/
@synthesize textStyle;

/** @property CGSize titleSize
 *  @brief The size of the legend entry title when drawn using the @ref textStyle.
 **/
@dynamic titleSize;

#pragma mark -
#pragma mark Init/Dealloc

/// @name Initialization
/// @{

/** @brief Initializes a newly allocated CPTLegendEntry object.
 *
 *  The initialized object will have the following properties:
 *  - @ref plot = @nil
 *  - @ref index = @num{0}
 *  - @ref row = @num{0}
 *  - @ref column = @num{0}
 *  - @ref textStyle = @nil
 *
 *  @return The initialized object.
 **/
-(id)init
{
    if ( (self = [super init]) ) {
        plot      = nil;
        index     = 0;
        row       = 0;
        column    = 0;
        textStyle = nil;
    }
    return self;
}

/// @}

/// @cond

-(void)dealloc
{
    [textStyle release];

    [super dealloc];
}

/// @endcond

#pragma mark -
#pragma mark NSCoding Methods

/// @cond

-(void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeConditionalObject:self.plot forKey:@"CPTLegendEntry.plot"];
    [coder encodeInteger:(NSInteger)self.index forKey:@"CPTLegendEntry.index"];
    [coder encodeInteger:(NSInteger)self.row forKey:@"CPTLegendEntry.row"];
    [coder encodeInteger:(NSInteger)self.column forKey:@"CPTLegendEntry.column"];
    [coder encodeObject:self.textStyle forKey:@"CPTLegendEntry.textStyle"];
}

-(id)initWithCoder:(NSCoder *)coder
{
    if ( (self = [super init]) ) {
        plot      = [coder decodeObjectForKey:@"CPTLegendEntry.plot"];
        index     = (NSUInteger)[coder decodeIntegerForKey : @"CPTLegendEntry.index"];
        row       = (NSUInteger)[coder decodeIntegerForKey : @"CPTLegendEntry.row"];
        column    = (NSUInteger)[coder decodeIntegerForKey : @"CPTLegendEntry.column"];
        textStyle = [[coder decodeObjectForKey:@"CPTLegendEntry.textStyle"] retain];
    }
    return self;
}

/// @endcond

#pragma mark -
#pragma mark Drawing

/** @brief Draws the legend title centered vertically in the given rectangle.
 *  @param rect The bounding rectangle where the title should be drawn.
 *  @param context The graphics context to draw into.
 *  @param scale The drawing scale factor. Must be greater than zero (@num{0}).
 **/
-(void)drawTitleInRect:(CGRect)rect inContext:(CGContextRef)context scale:(CGFloat)scale
{
#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, CPTFloat(0.0), rect.origin.y);
    CGContextScaleCTM( context, CPTFloat(1.0), CPTFloat(-1.0) );
    CGContextTranslateCTM( context, CPTFloat(0.0), -CGRectGetMaxY(rect) );
#endif
    // center the title vertically
    CGRect textRect     = rect;
    CGSize theTitleSize = self.titleSize;
    if ( theTitleSize.height < textRect.size.height ) {
        CGFloat offset = (textRect.size.height - theTitleSize.height) / CPTFloat(2.0);
        if ( scale == 1.0 ) {
            offset = round(offset);
        }
        else {
            offset = round(offset * scale) / scale;
        }
        textRect = CPTRectInset(textRect, 0.0, offset);
    }
    CPTAlignRectToUserSpace(context, textRect);
    [self.title drawInRect:textRect withTextStyle:self.textStyle inContext:context];
#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
    CGContextRestoreGState(context);
#endif
}

#pragma mark -
#pragma mark Accessors

/// @cond

-(void)setTextStyle:(CPTTextStyle *)newTextStyle
{
    if ( newTextStyle != textStyle ) {
        [textStyle release];
        textStyle = [newTextStyle retain];
    }
}

-(NSString *)title
{
    return [self.plot titleForLegendEntryAtIndex:self.index];
}

-(CGSize)titleSize
{
    CGSize theTitleSize = CGSizeZero;

    NSString *theTitle         = self.title;
    CPTTextStyle *theTextStyle = self.textStyle;

    if ( theTitle && theTextStyle ) {
        theTitleSize = [theTitle sizeWithTextStyle:theTextStyle];
    }

    return theTitleSize;
}

/// @endcond

@end
