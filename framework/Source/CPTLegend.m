#import "CPTLegend.h"

#import "CPTExceptions.h"
#import "CPTFill.h"
#import "CPTGraph.h"
#import "CPTLegendEntry.h"
#import "CPTLineStyle.h"
#import "CPTPlot.h"
#import "CPTTextStyle.h"
#import "CPTUtilities.h"
#import "NSCoderExtensions.h"
#import "NSNumberExtensions.h"
#import <tgmath.h>

/** @defgroup legendAnimation Legends
 *  @brief Legend properties that can be animated using Core Animation.
 *  @if MacOnly
 *  @since Custom layer property animation is supported on MacOS 10.6 and later.
 *  @endif
 *  @ingroup animation
 **/

NSString *const CPTLegendNeedsRedrawForPlotNotification        = @"CPTLegendNeedsRedrawForPlotNotification";
NSString *const CPTLegendNeedsLayoutForPlotNotification        = @"CPTLegendNeedsLayoutForPlotNotification";
NSString *const CPTLegendNeedsReloadEntriesForPlotNotification = @"CPTLegendNeedsReloadEntriesForPlotNotification";

/// @cond
@interface CPTLegend()

@property (nonatomic, readwrite, retain) NSMutableArray *plots;
@property (nonatomic, readwrite, retain) NSMutableArray *legendEntries;
@property (nonatomic, readwrite, retain) NSArray *rowHeightsThatFit;
@property (nonatomic, readwrite, retain) NSArray *columnWidthsThatFit;
@property (nonatomic, readwrite, assign) BOOL layoutChanged;

-(void)recalculateLayout;
-(void)removeLegendEntriesForPlot:(CPTPlot *)plot;
-(void)legendNeedsRedraw:(NSNotification *)notif;
-(void)legendNeedsLayout:(NSNotification *)notif;
-(void)legendNeedsReloadEntries:(NSNotification *)notif;

@end

/// @endcond

#pragma mark -

/** @brief A graph legend.
 *
 *  The legend consists of one or more legend entries associated with plots. Each legend
 *  entry is made up of a graphical @quote{swatch} that corresponds with the plot and a text
 *  title or label to identify the data series to the viewer. The swatches provide a visual
 *  connection to the plot. For instance, a swatch for a scatter plot might include a line
 *  segment drawn in the line style of the plot along with a plot symbol while a swatch for
 *  a pie chart might only show a rectangle or other shape filled with the background fill
 *  of the corresponding pie slice.
 *
 *  The plots are not required to belong to the same graph, although that is the usual
 *  case. This allows creation of a master legend that covers multiple graphs.
 *
 *  @see See @ref legendAnimation "Legends" for a list of animatable properties.
 **/
@implementation CPTLegend

/** @property CPTTextStyle *textStyle
 *  @brief The text style used to draw all legend entry titles.
 **/
@synthesize textStyle;

/** @property CGSize swatchSize
 *  @brief The size of the graphical swatch.
 *  If swatchSize is (@num{0.0}, @num{0.0}), swatches will be drawn using a square @num{150%} of the text size on a side.
 **/
@dynamic swatchSize;

/** @property CPTLineStyle *swatchBorderLineStyle
 *  @brief The line style for the border drawn around each swatch.
 *  If @nil (the default), no border is drawn.
 **/
@synthesize swatchBorderLineStyle;

/** @property CGFloat swatchCornerRadius
 *  @brief The corner radius for each swatch. Default is @num{0.0}.
 *  @ingroup legendAnimation
 **/
@synthesize swatchCornerRadius;

/** @property CPTFill *swatchFill
 *  @brief The background fill drawn behind each swatch.
 *  If @nil (the default), no fill is drawn.
 **/
@synthesize swatchFill;

/** @property NSUInteger numberOfRows
 *  @brief The desired number of rows of legend entries.
 *  If zero (@num{0}) (the default), the number of rows will be automatically determined.
 *  If both @ref numberOfRows and @ref numberOfColumns are greater than zero but their product is less than
 *  the total number of legend entries, some entries will not be shown.
 **/
@synthesize numberOfRows;

/** @property NSUInteger numberOfColumns
 *  @brief The desired number of columns of legend entries.
 *  If zero (@num{0}) (the default), the number of columns will be automatically determined.
 *  If both @ref numberOfRows and @ref numberOfColumns are greater than zero but their product is less than
 *  the total number of legend entries, some entries will not be shown.
 **/
@synthesize numberOfColumns;

/** @property BOOL equalRows
 *  @brief If @YES (the default) each row of legend entries will have the same height, otherwise rows will be sized to best fit the entries.
 **/
@synthesize equalRows;

/** @property BOOL equalColumns
 *  @brief If @YES each column of legend entries will have the same width, otherwise columns will be sized to best fit the entries.
 *  Default is @NO, meaning columns will be sized for the best fit.
 **/
@synthesize equalColumns;

/** @property NSArray *rowHeights
 *  @brief The desired height of each row of legend entries, including the swatch and title.
 *  Each element in this array should be an NSNumber representing the height of the corresponding row in device units.
 *  Rows are numbered from top to bottom starting from zero (@num{0}). If @nil, all rows will be sized automatically.
 *  If there are more rows in the legend than specified in this array, the remaining rows will be sized automatically.
 *  Default is @nil.
 **/
@synthesize rowHeights;

/** @property NSArray *rowHeightsThatFit
 *  @brief The computed best-fit height of each row of legend entries, including the swatch and title.
 *  Each element in this array is an NSNumber representing the height of the corresponding row in device units.
 *  Rows are numbered from top to bottom starting from zero (@num{0}).
 **/
@synthesize rowHeightsThatFit;

/** @property NSArray *columnWidths
 *  @brief The desired width of each column of legend entries, including the swatch, title, and title offset.
 *  Each element in this array should be an NSNumber representing the width of the corresponding column in device units.
 *  Columns are numbered from left to right starting from zero (@num{0}). If @nil, all columns will be sized automatically.
 *  If there are more columns in the legend than specified in this array, the remaining columns will be sized automatically.
 *  Default is @nil.
 **/
@synthesize columnWidths;

/** @property NSArray *columnWidthsThatFit
 *  @brief The computed best-fit width of each column of legend entries, including the swatch, title, and title offset.
 *  Each element in this array is an NSNumber representing the width of the corresponding column in device units.
 *  Columns are numbered from left to right starting from zero (@num{0}).
 **/
@synthesize columnWidthsThatFit;

/** @property CGFloat columnMargin
 *  @brief The margin between columns, specified in device units. Default is @num{10.0}.
 **/
@synthesize columnMargin;

/** @property CGFloat rowMargin
 *  @brief The margin between rows, specified in device units. Default is @num{5.0}.
 **/
@synthesize rowMargin;

/** @property CGFloat titleOffset
 *  @brief The distance between each swatch and its title, specified in device units. Default is @num{5.0}.
 **/
@synthesize titleOffset;

/** @property NSMutableArray *plots
 *  @brief An array of all plots associated with the legend.
 **/
@synthesize plots;

/** @property NSMutableArray *legendEntries
 *  @brief An array of all legend entries.
 **/
@synthesize legendEntries;

/** @property  BOOL layoutChanged
 *  @brief If @YES, the legend layout needs to recalculated.
 **/
@synthesize layoutChanged;

#pragma mark -
#pragma mark Factory Methods

/** @brief Creates and returns a new CPTLegend instance with legend entries for each plot in the given array.
 *  @param newPlots An array of plots.
 *  @return A new CPTLegend instance.
 **/
+(id)legendWithPlots:(NSArray *)newPlots
{
    return [[[self alloc] initWithPlots:newPlots] autorelease];
}

/** @brief Creates and returns a new CPTLegend instance with legend entries for each plot in the given graph.
 *  @param graph The graph.
 *  @return A new CPTLegend instance.
 **/
+(id)legendWithGraph:(CPTGraph *)graph
{
    return [[[self alloc] initWithGraph:graph] autorelease];
}

#pragma mark -
#pragma mark Init/Dealloc

/// @name Initialization
/// @{

/** @brief Initializes a newly allocated CPTLegend object with the provided frame rectangle.
 *
 *  This is the designated initializer. The initialized layer will have the following properties:
 *  - @ref layoutChanged = @YES
 *  - @ref textStyle = default text style
 *  - @ref swatchSize = (@num{0.0}, @num{0.0})
 *  - @ref swatchBorderLineStyle = @nil
 *  - @ref swatchCornerRadius = @num{0}
 *  - @ref swatchFill = @nil
 *  - @ref numberOfRows = @num{0}
 *  - @ref numberOfColumns = @num{0}
 *  - @ref equalRows = @YES
 *  - @ref equalColumns = @NO
 *  - @ref rowHeights = @nil
 *  - @ref rowHeightsThatFit = @nil
 *  - @ref columnWidths = @nil
 *  - @ref columnWidthsThatFit = @nil
 *  - @ref columnMargin = @num{10.0}
 *  - @ref rowMargin = @num{5.0}
 *  - @ref titleOffset = @num{5.0}
 *  - @ref paddingLeft = @num{5.0}
 *  - @ref paddingTop = @num{5.0}
 *  - @ref paddingRight = @num{5.0}
 *  - @ref paddingBottom = @num{5.0}
 *  - @ref needsDisplayOnBoundsChange = @YES
 *
 *  @param newFrame The frame rectangle.
 *  @return The initialized CPTLegend object.
 **/
-(id)initWithFrame:(CGRect)newFrame
{
    if ( (self = [super initWithFrame:newFrame]) ) {
        plots                 = [[NSMutableArray alloc] init];
        legendEntries         = [[NSMutableArray alloc] init];
        layoutChanged         = YES;
        textStyle             = [[CPTTextStyle alloc] init];
        swatchSize            = CGSizeZero;
        swatchBorderLineStyle = nil;
        swatchCornerRadius    = CPTFloat(0.0);
        swatchFill            = nil;
        numberOfRows          = 0;
        numberOfColumns       = 0;
        equalRows             = YES;
        equalColumns          = NO;
        rowHeights            = nil;
        rowHeightsThatFit     = nil;
        columnWidths          = nil;
        columnWidthsThatFit   = nil;
        columnMargin          = CPTFloat(10.0);
        rowMargin             = CPTFloat(5.0);
        titleOffset           = CPTFloat(5.0);

        self.paddingLeft                = CPTFloat(5.0);
        self.paddingTop                 = CPTFloat(5.0);
        self.paddingRight               = CPTFloat(5.0);
        self.paddingBottom              = CPTFloat(5.0);
        self.needsDisplayOnBoundsChange = YES;
    }
    return self;
}

/// @}

/** @brief Initializes a newly allocated CPTLegend object and adds legend entries for each plot in the given array.
 *  @param newPlots An array of plots.
 *  @return The initialized CPTLegend object.
 **/
-(id)initWithPlots:(NSArray *)newPlots
{
    if ( (self = [self initWithFrame:CGRectZero]) ) {
        for ( CPTPlot *plot in newPlots ) {
            [self addPlot:plot];
        }
    }
    return self;
}

/** @brief Initializes a newly allocated CPTLegend object and adds legend entries for each plot in the given graph.
 *  @param graph A graph.
 *  @return The initialized CPTLegend object.
 **/
-(id)initWithGraph:(CPTGraph *)graph
{
    if ( (self = [self initWithFrame:CGRectZero]) ) {
        for ( CPTPlot *plot in [graph allPlots] ) {
            [self addPlot:plot];
        }
    }
    return self;
}

/// @cond

-(id)initWithLayer:(id)layer
{
    if ( (self = [super initWithLayer:layer]) ) {
        CPTLegend *theLayer = (CPTLegend *)layer;

        plots                 = [theLayer->plots retain];
        legendEntries         = [theLayer->legendEntries retain];
        layoutChanged         = theLayer->layoutChanged;
        textStyle             = [theLayer->textStyle retain];
        swatchSize            = theLayer->swatchSize;
        swatchBorderLineStyle = [theLayer->swatchBorderLineStyle retain];
        swatchCornerRadius    = theLayer->swatchCornerRadius;
        swatchFill            = [theLayer->swatchFill retain];
        numberOfRows          = theLayer->numberOfRows;
        numberOfColumns       = theLayer->numberOfColumns;
        equalRows             = theLayer->equalRows;
        equalColumns          = theLayer->equalColumns;
        rowHeights            = [theLayer->rowHeights retain];
        rowHeightsThatFit     = [theLayer->rowHeightsThatFit retain];
        columnWidths          = [theLayer->columnWidths retain];
        columnWidthsThatFit   = [theLayer->columnWidthsThatFit retain];
        columnMargin          = theLayer->columnMargin;
        rowMargin             = theLayer->rowMargin;
        titleOffset           = theLayer->titleOffset;
    }
    return self;
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];

    [plots release];
    [legendEntries release];
    [textStyle release];
    [swatchBorderLineStyle release];
    [swatchFill release];
    [rowHeights release];
    [rowHeightsThatFit release];
    [columnWidths release];
    [columnWidthsThatFit release];

    [super dealloc];
}

/// @endcond

#pragma mark -
#pragma mark NSCoding Methods

/// @cond

-(void)encodeWithCoder:(NSCoder *)coder
{
    [super encodeWithCoder:coder];

    [coder encodeObject:self.plots forKey:@"CPTLegend.plots"];
    [coder encodeObject:self.legendEntries forKey:@"CPTLegend.legendEntries"];
    [coder encodeBool:self.layoutChanged forKey:@"CPTLegend.layoutChanged"];
    [coder encodeObject:self.textStyle forKey:@"CPTLegend.textStyle"];
    [coder encodeCPTSize:self.swatchSize forKey:@"CPTLegend.swatchSize"];
    [coder encodeObject:self.swatchBorderLineStyle forKey:@"CPTLegend.swatchBorderLineStyle"];
    [coder encodeCGFloat:self.swatchCornerRadius forKey:@"CPTLegend.swatchCornerRadius"];
    [coder encodeObject:self.swatchFill forKey:@"CPTLegend.swatchFill"];
    [coder encodeInteger:(NSInteger)self.numberOfRows forKey:@"CPTLegend.numberOfRows"];
    [coder encodeInteger:(NSInteger)self.numberOfColumns forKey:@"CPTLegend.numberOfColumns"];
    [coder encodeBool:self.equalRows forKey:@"CPTLegend.equalRows"];
    [coder encodeBool:self.equalColumns forKey:@"CPTLegend.equalColumns"];
    [coder encodeObject:self.rowHeights forKey:@"CPTLegend.rowHeights"];
    [coder encodeObject:self.rowHeightsThatFit forKey:@"CPTLegend.rowHeightsThatFit"];
    [coder encodeObject:self.columnWidths forKey:@"CPTLegend.columnWidths"];
    [coder encodeObject:self.columnWidthsThatFit forKey:@"CPTLegend.columnWidthsThatFit"];
    [coder encodeCGFloat:self.columnMargin forKey:@"CPTLegend.columnMargin"];
    [coder encodeCGFloat:self.rowMargin forKey:@"CPTLegend.rowMargin"];
    [coder encodeCGFloat:self.titleOffset forKey:@"CPTLegend.titleOffset"];
}

-(id)initWithCoder:(NSCoder *)coder
{
    if ( (self = [super initWithCoder:coder]) ) {
        plots                 = [[coder decodeObjectForKey:@"CPTLegend.plots"] mutableCopy];
        legendEntries         = [[coder decodeObjectForKey:@"CPTLegend.legendEntries"] mutableCopy];
        layoutChanged         = [coder decodeBoolForKey:@"CPTLegend.layoutChanged"];
        textStyle             = [[coder decodeObjectForKey:@"CPTLegend.textStyle"] copy];
        swatchSize            = [coder decodeCPTSizeForKey:@"CPTLegend.swatchSize"];
        swatchBorderLineStyle = [[coder decodeObjectForKey:@"CPTLegend.swatchBorderLineStyle"] copy];
        swatchCornerRadius    = [coder decodeCGFloatForKey:@"CPTLegend.swatchCornerRadius"];
        swatchFill            = [[coder decodeObjectForKey:@"CPTLegend.swatchFill"] copy];
        numberOfRows          = (NSUInteger)[coder decodeIntegerForKey : @"CPTLegend.numberOfRows"];
        numberOfColumns       = (NSUInteger)[coder decodeIntegerForKey : @"CPTLegend.numberOfColumns"];
        equalRows             = [coder decodeBoolForKey:@"CPTLegend.equalRows"];
        equalColumns          = [coder decodeBoolForKey:@"CPTLegend.equalColumns"];
        rowHeights            = [[coder decodeObjectForKey:@"CPTLegend.rowHeights"] copy];
        rowHeightsThatFit     = [[coder decodeObjectForKey:@"CPTLegend.rowHeightsThatFit"] retain];
        columnWidths          = [[coder decodeObjectForKey:@"CPTLegend.columnWidths"] copy];
        columnWidthsThatFit   = [[coder decodeObjectForKey:@"CPTLegend.columnWidthsThatFit"] retain];
        columnMargin          = [coder decodeCGFloatForKey:@"CPTLegend.columnMargin"];
        rowMargin             = [coder decodeCGFloatForKey:@"CPTLegend.rowMargin"];
        titleOffset           = [coder decodeCGFloatForKey:@"CPTLegend.titleOffset"];
    }
    return self;
}

/// @endcond

#pragma mark -
#pragma mark Drawing

/// @cond

-(void)renderAsVectorInContext:(CGContextRef)context
{
    if ( self.hidden ) {
        return;
    }

    [super renderAsVectorInContext:context];

    if ( self.legendEntries.count == 0 ) {
        return;
    }

    // calculate column positions
    NSArray *computedColumnWidths = self.columnWidthsThatFit;
    NSUInteger columnCount        = computedColumnWidths.count;
    CGFloat *actualColumnWidths   = malloc(sizeof(CGFloat) * columnCount);
    CGFloat *columnPositions      = malloc(sizeof(CGFloat) * columnCount);
    columnPositions[0] = self.paddingLeft;
    CGFloat theOffset       = self.titleOffset;
    CGSize theSwatchSize    = self.swatchSize;
    CGFloat theColumnMargin = self.columnMargin;

    for ( NSUInteger col = 0; col < columnCount; col++ ) {
        NSNumber *colWidth = [computedColumnWidths objectAtIndex:col];
        CGFloat width      = [colWidth cgFloatValue];
        actualColumnWidths[col] = width;
        if ( col < columnCount - 1 ) {
            columnPositions[col + 1] = columnPositions[col] + width + theOffset + theSwatchSize.width + theColumnMargin;
        }
    }

    // calculate row positions
    NSArray *computedRowHeights = self.rowHeightsThatFit;
    NSUInteger rowCount         = computedRowHeights.count;
    CGFloat *actualRowHeights   = malloc(sizeof(CGFloat) * rowCount);
    CGFloat *rowPositions       = malloc(sizeof(CGFloat) * rowCount);
    rowPositions[rowCount - 1] = self.paddingBottom;
    CGFloat theRowMargin = self.rowMargin;

    for ( NSUInteger rw = 0; rw < rowCount; rw++ ) {
        NSUInteger row      = rowCount - rw - 1;
        NSNumber *rowHeight = [computedRowHeights objectAtIndex:row];
        CGFloat height      = [rowHeight cgFloatValue];
        actualRowHeights[row] = height;
        if ( row < rowCount - 1 ) {
            rowPositions[row] = rowPositions[row + 1] + height + theRowMargin;
        }
    }

    // draw legend entries
    NSUInteger desiredRowCount    = self.numberOfRows;
    NSUInteger desiredColumnCount = self.numberOfColumns;

    id<CPTLegendDelegate> theDelegate = (id<CPTLegendDelegate>)self.delegate;
    BOOL delegateCanDraw              = [theDelegate respondsToSelector:@selector(legend:shouldDrawSwatchAtIndex:forPlot:inRect:inContext:)];

    for ( CPTLegendEntry *legendEntry in self.legendEntries ) {
        NSUInteger row = legendEntry.row;
        NSUInteger col = legendEntry.column;

        if ( ( (desiredRowCount == 0) || (row < desiredRowCount) ) &&
             ( (desiredColumnCount == 0) || (col < desiredColumnCount) ) ) {
            CGFloat left        = columnPositions[col];
            CGFloat rowPosition = rowPositions[row];
            CGRect swatchRect   = CPTAlignRectToUserSpace( context, CPTRectMake(left,
                                                                                rowPosition + (actualRowHeights[row] - theSwatchSize.height) / CPTFloat(2.0),
                                                                                theSwatchSize.width,
                                                                                theSwatchSize.height) );
            BOOL legendShouldDrawSwatch = YES;
            if ( delegateCanDraw ) {
                legendShouldDrawSwatch = [theDelegate      legend:self
                                          shouldDrawSwatchAtIndex:legendEntry.index
                                                          forPlot:legendEntry.plot
                                                           inRect:swatchRect
                                                        inContext:context];
            }
            if ( legendShouldDrawSwatch ) {
                [legendEntry.plot drawSwatchForLegend:self
                                              atIndex:legendEntry.index
                                               inRect:swatchRect
                                            inContext:context];
            }

            left += theSwatchSize.width + theOffset;

            [legendEntry drawTitleInRect:CPTAlignRectToUserSpace( context, CPTRectMake(left, rowPosition, actualColumnWidths[col] + CPTFloat(1.0), actualRowHeights[row]) )
                               inContext:context
                                   scale:self.contentsScale];
        }
    }

    free(actualColumnWidths);
    free(columnPositions);
    free(actualRowHeights);
    free(rowPositions);
}

/// @endcond

#pragma mark -
#pragma mark Animation

/// @cond

+(BOOL)needsDisplayForKey:(NSString *)aKey
{
    static NSArray *keys = nil;

    if ( !keys ) {
        keys = [[NSArray alloc] initWithObjects:
                @"swatchSize",
                @"swatchCornerRadius",
                nil];
    }

    if ( [keys containsObject:aKey] ) {
        return YES;
    }
    else {
        return [super needsDisplayForKey:aKey];
    }
}

/// @endcond

#pragma mark -
#pragma mark Layout

/**
 *  @brief Marks the receiver as needing to update the layout of its legend entries.
 **/
-(void)setLayoutChanged
{
    self.layoutChanged = YES;
}

/// @cond

-(void)layoutSublayers
{
    [self recalculateLayout];
    [super layoutSublayers];
}

-(void)recalculateLayout
{
    if ( !self.layoutChanged ) {
        return;
    }

    // compute the number of rows and columns needed to hold the legend entries
    NSUInteger rowCount           = self.numberOfRows;
    NSUInteger columnCount        = self.numberOfColumns;
    NSUInteger desiredRowCount    = rowCount;
    NSUInteger desiredColumnCount = columnCount;

    NSUInteger legendEntryCount = self.legendEntries.count;
    if ( (rowCount == 0) && (columnCount == 0) ) {
        rowCount    = (NSUInteger)sqrt( (double)legendEntryCount );
        columnCount = rowCount;
        if ( rowCount * columnCount < legendEntryCount ) {
            columnCount++;
        }
        if ( rowCount * columnCount < legendEntryCount ) {
            rowCount++;
        }
    }
    else if ( (rowCount == 0) && (columnCount > 0) ) {
        rowCount = legendEntryCount / columnCount;
        if ( legendEntryCount % columnCount ) {
            rowCount++;
        }
    }
    else if ( (rowCount > 0) && (columnCount == 0) ) {
        columnCount = legendEntryCount / rowCount;
        if ( legendEntryCount % rowCount ) {
            columnCount++;
        }
    }

    // compute row heights and column widths
    NSUInteger row               = 0;
    NSUInteger col               = 0;
    CGFloat *maxTitleHeight      = calloc( rowCount, sizeof(CGFloat) );
    CGFloat *maxTitleWidth       = calloc( columnCount, sizeof(CGFloat) );
    CGSize theSwatchSize         = self.swatchSize;
    NSArray *desiredRowHeights   = self.rowHeights;
    NSArray *desiredColumnWidths = self.columnWidths;
    Class numberClass            = [NSNumber class];

    for ( CPTLegendEntry *legendEntry in self.legendEntries ) {
        legendEntry.row    = row;
        legendEntry.column = col;
        CGSize titleSize = legendEntry.titleSize;

        if ( (desiredRowCount == 0) || (row < desiredRowCount) ) {
            maxTitleHeight[row] = MAX(MAX(maxTitleHeight[row], titleSize.height), theSwatchSize.height);

            if ( row < desiredRowHeights.count ) {
                id desiredRowHeight = [desiredRowHeights objectAtIndex:row];
                if ( [desiredRowHeight isKindOfClass:numberClass] ) {
                    maxTitleHeight[row] = MAX(maxTitleHeight[row], [(NSNumber *) desiredRowHeight cgFloatValue]);
                }
            }
        }

        if ( (desiredColumnCount == 0) || (col < desiredColumnCount) ) {
            maxTitleWidth[col] = MAX(MAX(maxTitleWidth[col], titleSize.width), theSwatchSize.width);

            if ( col < desiredColumnWidths.count ) {
                id desiredColumnWidth = [desiredColumnWidths objectAtIndex:col];
                if ( [desiredColumnWidth isKindOfClass:numberClass] ) {
                    maxTitleWidth[col] = MAX(maxTitleWidth[col], [(NSNumber *) desiredColumnWidth cgFloatValue]);
                }
            }
        }

        col++;
        if ( col >= columnCount ) {
            row++;
            col = 0;
            if ( row >= rowCount ) {
                break;
            }
        }
    }

    // save row heights and column widths
    NSMutableArray *maxRowHeights = [[NSMutableArray alloc] initWithCapacity:rowCount];
    for ( NSUInteger i = 0; i < rowCount; i++ ) {
        [maxRowHeights addObject:[NSNumber numberWithCGFloat:maxTitleHeight[i]]];
    }
    self.rowHeightsThatFit = maxRowHeights;

    NSMutableArray *maxColumnWidths = [[NSMutableArray alloc] initWithCapacity:columnCount];
    for ( NSUInteger i = 0; i < columnCount; i++ ) {
        [maxColumnWidths addObject:[NSNumber numberWithCGFloat:maxTitleWidth[i]]];
    }
    self.columnWidthsThatFit = maxColumnWidths;

    free(maxTitleHeight);
    free(maxTitleWidth);

    // compute the size needed to contain all legend entries, margins, and padding
    CGSize legendSize = CPTSizeMake(self.paddingLeft + self.paddingRight, self.paddingTop + self.paddingBottom);

    if ( self.equalColumns ) {
        NSNumber *maxWidth = [maxColumnWidths valueForKeyPath:@"@max.doubleValue"];
        legendSize.width += [maxWidth cgFloatValue] * columnCount;
    }
    else {
        for ( NSNumber *width in maxColumnWidths ) {
            legendSize.width += [width cgFloatValue];
        }
    }
    if ( columnCount > 0 ) {
        legendSize.width += ( (theSwatchSize.width + self.titleOffset) * columnCount ) + ( self.columnMargin * (columnCount - 1) );
    }

    NSUInteger rows = row;
    if ( col ) {
        rows++;
    }
    for ( NSNumber *height in maxRowHeights ) {
        legendSize.height += [height cgFloatValue];
    }
    if ( rows > 0 ) {
        legendSize.height += ( self.rowMargin * (rows - 1) );
    }

    [maxRowHeights release];
    [maxColumnWidths release];

    self.bounds = CPTRectMake(0.0, 0.0, legendSize.width, legendSize.height);
    [self pixelAlign];

    self.layoutChanged = NO;
}

/// @endcond

#pragma mark -
#pragma mark Plots

/** @brief All plots associated with the legend.
 *  @return An array of all plots associated with the legend.
 **/
-(NSArray *)allPlots
{
    return [NSArray arrayWithArray:self.plots];
}

/** @brief Gets the plot at the given index in the plot array.
 *  @param idx An index within the bounds of the plot array.
 *  @return The plot at the given index.
 **/
-(CPTPlot *)plotAtIndex:(NSUInteger)idx
{
    return [self.plots objectAtIndex:idx];
}

/** @brief Gets the plot with the given identifier from the plot array.
 *  @param identifier A plot identifier.
 *  @return The plot with the given identifier or nil if it was not found.
 **/
-(CPTPlot *)plotWithIdentifier:(id<NSCopying>)identifier
{
    for ( CPTPlot *plot in self.plots ) {
        if ( [[plot identifier] isEqual:identifier] ) {
            return plot;
        }
    }
    return nil;
}

#pragma mark -
#pragma mark Organizing Plots

/** @brief Add a plot to the legend.
 *  @param plot The plot.
 **/
-(void)addPlot:(CPTPlot *)plot
{
    if ( [plot isKindOfClass:[CPTPlot class]] ) {
        [self.plots addObject:plot];
        self.layoutChanged = YES;

        NSMutableArray *theLegendEntries = self.legendEntries;
        CPTTextStyle *theTextStyle       = self.textStyle;
        NSUInteger numberOfLegendEntries = [plot numberOfLegendEntries];
        for ( NSUInteger i = 0; i < numberOfLegendEntries; i++ ) {
            NSString *newTitle = [plot titleForLegendEntryAtIndex:i];
            if ( newTitle ) {
                CPTLegendEntry *newLegendEntry = [[CPTLegendEntry alloc] init];
                newLegendEntry.plot      = plot;
                newLegendEntry.index     = i;
                newLegendEntry.textStyle = theTextStyle;
                [theLegendEntries addObject:newLegendEntry];
                [newLegendEntry release];
            }
        }
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(legendNeedsRedraw:) name:CPTLegendNeedsRedrawForPlotNotification object:plot];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(legendNeedsLayout:) name:CPTLegendNeedsLayoutForPlotNotification object:plot];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(legendNeedsReloadEntries:) name:CPTLegendNeedsReloadEntriesForPlotNotification object:plot];
    }
}

/** @brief Add a plot to the legend at the given index in the plot array.
 *  @param plot The plot.
 *  @param idx An index within the bounds of the plot array.
 **/
-(void)insertPlot:(CPTPlot *)plot atIndex:(NSUInteger)idx
{
    if ( [plot isKindOfClass:[CPTPlot class]] ) {
        NSMutableArray *thePlots = self.plots;
        NSAssert(idx <= thePlots.count, @"index greater than the number of plots");

        NSMutableArray *theLegendEntries = self.legendEntries;
        NSUInteger legendEntryIndex      = 0;
        if ( idx == thePlots.count ) {
            legendEntryIndex = theLegendEntries.count;
        }
        else {
            CPTPlot *lastPlot = [thePlots objectAtIndex:idx];
            for ( CPTLegendEntry *legendEntry in theLegendEntries ) {
                if ( legendEntry.plot == lastPlot ) {
                    break;
                }
                legendEntryIndex++;
            }
        }

        [thePlots insertObject:plot atIndex:idx];
        self.layoutChanged = YES;

        CPTTextStyle *theTextStyle       = self.textStyle;
        NSUInteger numberOfLegendEntries = [plot numberOfLegendEntries];
        for ( NSUInteger i = 0; i < numberOfLegendEntries; i++ ) {
            NSString *newTitle = [plot titleForLegendEntryAtIndex:i];
            if ( newTitle ) {
                CPTLegendEntry *newLegendEntry = [[CPTLegendEntry alloc] init];
                newLegendEntry.plot      = plot;
                newLegendEntry.index     = i;
                newLegendEntry.textStyle = theTextStyle;
                [theLegendEntries insertObject:newLegendEntry atIndex:legendEntryIndex++];
                [newLegendEntry release];
            }
        }
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(legendNeedsRedraw:) name:CPTLegendNeedsRedrawForPlotNotification object:plot];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(legendNeedsLayout:) name:CPTLegendNeedsLayoutForPlotNotification object:plot];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(legendNeedsReloadEntries:) name:CPTLegendNeedsReloadEntriesForPlotNotification object:plot];
    }
}

/** @brief Remove a plot from the legend.
 *  @param plot The plot to remove.
 **/
-(void)removePlot:(CPTPlot *)plot
{
    if ( [self.plots containsObject:plot] ) {
        [self.plots removeObjectIdenticalTo:plot];
        [self removeLegendEntriesForPlot:plot];
        self.layoutChanged = YES;
        [[NSNotificationCenter defaultCenter] removeObserver:self name:CPTLegendNeedsRedrawForPlotNotification object:plot];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:CPTLegendNeedsLayoutForPlotNotification object:plot];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:CPTLegendNeedsReloadEntriesForPlotNotification object:plot];
    }
    else {
        [NSException raise:CPTException format:@"Tried to remove CPTPlot which did not exist."];
    }
}

/** @brief Remove a plot from the legend.
 *  @param identifier The identifier of the plot to remove.
 **/
-(void)removePlotWithIdentifier:(id<NSCopying>)identifier
{
    CPTPlot *plotToRemove = [self plotWithIdentifier:identifier];

    if ( plotToRemove ) {
        [self.plots removeObjectIdenticalTo:plotToRemove];
        [self removeLegendEntriesForPlot:plotToRemove];
        self.layoutChanged = YES;
        [[NSNotificationCenter defaultCenter] removeObserver:self name:CPTLegendNeedsRedrawForPlotNotification object:plotToRemove];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:CPTLegendNeedsLayoutForPlotNotification object:plotToRemove];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:CPTLegendNeedsReloadEntriesForPlotNotification object:plotToRemove];
    }
}

/// @cond

/** @internal
 *  @brief Remove all legend entries for the given plot from the legend.
 *  @param plot The plot.
 **/
-(void)removeLegendEntriesForPlot:(CPTPlot *)plot
{
    NSMutableArray *theLegendEntries = self.legendEntries;
    NSMutableArray *entriesToRemove  = [[NSMutableArray alloc] init];

    for ( CPTLegendEntry *legendEntry in theLegendEntries ) {
        if ( legendEntry.plot == plot ) {
            [entriesToRemove addObject:legendEntry];
        }
    }
    [theLegendEntries removeObjectsInArray:entriesToRemove];

    [entriesToRemove release];
}

/// @endcond

#pragma mark -
#pragma mark Notifications

/// @cond

-(void)legendNeedsRedraw:(NSNotification *)notif
{
    [self setNeedsDisplay];
}

-(void)legendNeedsLayout:(NSNotification *)notif
{
    self.layoutChanged = YES;
    [self setNeedsDisplay];
}

-(void)legendNeedsReloadEntries:(NSNotification *)notif
{
    CPTPlot *thePlot                 = (CPTPlot *)notif.object;
    NSMutableArray *theLegendEntries = self.legendEntries;

    NSUInteger legendEntryIndex = 0;

    for ( CPTLegendEntry *legendEntry in theLegendEntries ) {
        if ( legendEntry.plot == thePlot ) {
            break;
        }
        legendEntryIndex++;
    }

    [self removeLegendEntriesForPlot:thePlot];

    CPTTextStyle *theTextStyle       = self.textStyle;
    NSUInteger numberOfLegendEntries = [thePlot numberOfLegendEntries];
    for ( NSUInteger i = 0; i < numberOfLegendEntries; i++ ) {
        NSString *newTitle = [thePlot titleForLegendEntryAtIndex:i];
        if ( newTitle ) {
            CPTLegendEntry *newLegendEntry = [[CPTLegendEntry alloc] init];
            newLegendEntry.plot      = thePlot;
            newLegendEntry.index     = i;
            newLegendEntry.textStyle = theTextStyle;
            [theLegendEntries insertObject:newLegendEntry atIndex:legendEntryIndex++];
            [newLegendEntry release];
        }
    }
    self.layoutChanged = YES;
}

/// @endcond

#pragma mark -
#pragma mark Description

/// @cond

-(NSString *)description
{
    return [NSString stringWithFormat:@"<%@ for plots %@>", [super description], self.plots];
}

/// @endcond

#pragma mark -
#pragma mark Accessors

/// @cond

-(void)setTextStyle:(CPTTextStyle *)newTextStyle
{
    if ( newTextStyle != textStyle ) {
        [textStyle release];
        textStyle = [newTextStyle copy];
        [self.legendEntries makeObjectsPerformSelector:@selector(setTextStyle:) withObject:textStyle];
        self.layoutChanged = YES;
    }
}

-(void)setSwatchSize:(CGSize)newSwatchSize
{
    if ( !CGSizeEqualToSize(newSwatchSize, swatchSize) ) {
        swatchSize         = newSwatchSize;
        self.layoutChanged = YES;
    }
}

-(CGSize)swatchSize
{
    CGSize theSwatchSize = swatchSize;

    if ( CGSizeEqualToSize(theSwatchSize, CGSizeZero) ) {
        CPTTextStyle *theTextStyle = self.textStyle;
        CGFloat fontSize           = theTextStyle.fontSize;
        if ( fontSize > 0.0 ) {
            fontSize     *= CPTFloat(1.5);
            fontSize      = round(fontSize);
            theSwatchSize = CPTSizeMake(fontSize, fontSize);
        }
        else {
            theSwatchSize = CPTSizeMake(15.0, 15.0);
        }
    }
    return theSwatchSize;
}

-(void)setSwatchBorderLineStyle:(CPTLineStyle *)newSwatchBorderLineStyle
{
    if ( newSwatchBorderLineStyle != swatchBorderLineStyle ) {
        [swatchBorderLineStyle release];
        swatchBorderLineStyle = [newSwatchBorderLineStyle copy];
        [self setNeedsDisplay];
    }
}

-(void)setSwatchCornerRadius:(CGFloat)newSwatchCornerRadius
{
    if ( newSwatchCornerRadius != swatchCornerRadius ) {
        swatchCornerRadius = newSwatchCornerRadius;
        [self setNeedsDisplay];
    }
}

-(void)setSwatchFill:(CPTFill *)newSwatchFill
{
    if ( newSwatchFill != swatchFill ) {
        [swatchFill release];
        swatchFill = [newSwatchFill copy];
        [self setNeedsDisplay];
    }
}

-(void)setNumberOfRows:(NSUInteger)newNumberOfRows
{
    if ( newNumberOfRows != numberOfRows ) {
        numberOfRows       = newNumberOfRows;
        self.layoutChanged = YES;
    }
}

-(void)setNumberOfColumns:(NSUInteger)newNumberOfColumns
{
    if ( newNumberOfColumns != numberOfColumns ) {
        numberOfColumns    = newNumberOfColumns;
        self.layoutChanged = YES;
    }
}

-(void)setEqualRows:(BOOL)newEqualRows
{
    if ( newEqualRows != equalRows ) {
        equalRows          = newEqualRows;
        self.layoutChanged = YES;
    }
}

-(void)setEqualColumns:(BOOL)newEqualColumns
{
    if ( newEqualColumns != equalColumns ) {
        equalColumns       = newEqualColumns;
        self.layoutChanged = YES;
    }
}

-(void)setRowHeights:(NSArray *)newRowHeights
{
    if ( newRowHeights != rowHeights ) {
        [rowHeights release];
        rowHeights         = [newRowHeights copy];
        self.layoutChanged = YES;
    }
}

-(void)setColumnWidths:(NSArray *)newColumnWidths
{
    if ( newColumnWidths != columnWidths ) {
        [columnWidths release];
        columnWidths       = [newColumnWidths copy];
        self.layoutChanged = YES;
    }
}

-(void)setColumnMargin:(CGFloat)newColumnMargin
{
    if ( newColumnMargin != columnMargin ) {
        columnMargin       = newColumnMargin;
        self.layoutChanged = YES;
    }
}

-(void)setRowMargin:(CGFloat)newRowMargin
{
    if ( newRowMargin != rowMargin ) {
        rowMargin          = newRowMargin;
        self.layoutChanged = YES;
    }
}

-(void)setTitleOffset:(CGFloat)newTitleOffset
{
    if ( newTitleOffset != titleOffset ) {
        titleOffset        = newTitleOffset;
        self.layoutChanged = YES;
    }
}

-(void)setLayoutChanged:(BOOL)newLayoutChanged
{
    if ( newLayoutChanged != layoutChanged ) {
        layoutChanged = newLayoutChanged;
        if ( newLayoutChanged ) {
            self.rowHeightsThatFit   = nil;
            self.columnWidthsThatFit = nil;
            [self setNeedsLayout];
        }
    }
}

-(NSArray *)rowHeightsThatFit
{
    if ( !rowHeightsThatFit ) {
        [self recalculateLayout];
    }
    return rowHeightsThatFit;
}

-(NSArray *)columnWidthsThatFit
{
    if ( !columnWidthsThatFit ) {
        [self recalculateLayout];
    }
    return columnWidthsThatFit;
}

/// @endcond

@end
