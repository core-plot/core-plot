#import "CPTLegend.h"

#import "CPTExceptions.h"
#import "CPTGraph.h"
#import "CPTLegendEntry.h"
#import "CPTPlot.h"
#import "CPTTextStyle.h"
#import "CPTUtilities.h"
#import "NSNumberExtensions.h"

NSString * const CPTLegendNeedsRedrawForPlotNotification = @"CPTLegendNeedsRedrawForPlotNotification";

/**	@cond */
@interface CPTLegend()

@property (nonatomic, readwrite, retain) NSMutableArray *plots;
@property (nonatomic, readwrite, retain) NSMutableArray *legendEntries;
@property (nonatomic, readwrite, retain) NSArray *columnWidthsThatFit;
@property (nonatomic, readwrite, assign) BOOL layoutChanged;

-(void)recalculateLayout;
-(void)removeLegendEntriesForPlot:(CPTPlot *)plot;
-(void)legendNeedsRedraw:(NSNotification *)notif;

@end
/**	@endcond */

#pragma mark -

/**	@brief A graph legend.
 *	The legend consists of one or more legend entries associated with plots. Each legend
 *	entry is made up of a graphical "swatch" that corresponds with the plot and a text
 *	title or label to identify the data series to the viewer. The swatches provide a visual
 *	connection to the plot. For instance, a swatch for a scatter plot might include a line 
 *	segment drawn in the line style of the plot along with a plot symbol while a swatch for
 *	a pie chart might only show a rectangle or other shape filled with the background fill
 *	of the corresponding pie slice.
 *
 *	The plots are not required to belong to the same graph, although that is the usual
 *	case. This allows creation of a master legend that covers multiple graphs.
 **/
@implementation CPTLegend

/**	@property textStyle
 *	@brief The text style used to draw all legend entry titles.
 **/
@synthesize textStyle;

/**	@property swatchSize
 *	@brief The size of the graphical swatch.
 *	If swatchSize is CGSizeZero, swatches will be drawn using a square 150% of the text size on a side.
 **/
@dynamic swatchSize;

/**	@property swatchBorderLineStyle
 *	@brief The line style for the border drawn around each swatch.
 *	If nil, no border is drawn.
 **/
@synthesize swatchBorderLineStyle;

/**	@property swatchCornerRadius
 *	@brief The corner radius for each swatch.
 **/
@synthesize swatchCornerRadius;

/**	@property swatchFill
 *	@brief The background fill drawn behind each swatch.
 **/
@synthesize swatchFill;

/**	@property numberOfColumns
 *	@brief The desired number of columns of legend entries.
 *	If 0, the number of columns will be automatically determined based on the available space and the size of each legend entry.
 **/
@synthesize numberOfColumns;

/**	@property equalColumns
 *	@brief If YES each column of legend entries will have the same width, otherwise columns will be sized to best fit the entries.
 **/
@synthesize equalColumns;

/**	@property columnWidths
 *	@brief The desired width of each column of legend entries, including the swatch, title, and title offset.
 *	Each element in this array should be an NSNumber representing the width of the corresponding column in device units.
 *	Columns are numbered from left to right starting from zero (0). If nil, all columns will be sized automatically.
 *	If there are more columns in the legend than specified in this array, the remaining columns will be sized automatically.
 **/
@synthesize columnWidths;

/**	@property columnWidthsThatFit
 *	@brief The computed best-fit width of each column of legend entries, including the swatch, title, and title offset.
 *	Each element in this array is an NSNumber representing the width of the corresponding column in device units.
 *	Columns are numbered from left to right starting from zero (0).
 **/
@synthesize columnWidthsThatFit;

/**	@property columnMargin
 *	@brief The margin between columns, specified in device units.
 **/
@synthesize columnMargin;

/**	@property rowMargin
 *	@brief The margin between rows, specified in device units.
 **/
@synthesize rowMargin;

/**	@property titleOffset
 *	@brief The distance between each swatch and its title, specified in device units.
 **/
@synthesize titleOffset;

/**	@property plots
 *	@brief An array of all plots associated with the legend.
 **/
@synthesize plots;

/**	@property legendEntries
 *	@brief An array of all legend entries.
 **/
@synthesize legendEntries;

/**	@property layoutChanged
 *	@brief If YES, the legend layout needs to recalculated.
 **/
@synthesize layoutChanged;

#pragma mark -
#pragma mark Factory Methods

/** @brief Creates and returns a new CPTLegend instance with legend entries for each plot in the given array.
 *	@param newPlots An array of plots.
 *  @return A new CPTLegend instance.
 **/
+(id)legendWithPlots:(NSArray *)newPlots
{
	return [[[self alloc] initWithPlots:newPlots] autorelease];
}

/** @brief Creates and returns a new CPTLegend instance with legend entries for each plot in the given graph.
 *	@param graph The graph.
 *  @return A new CPTLegend instance.
 **/
+(id)legendWithGraph:(CPTGraph *)graph
{
	return [[[self alloc] initWithGraph:graph] autorelease];
}

#pragma mark -
#pragma mark Init/Dealloc

// Designated initializer
-(id)initWithFrame:(CGRect)newFrame
{
	if ( (self = [super initWithFrame:newFrame]) ) {
		plots = [[NSMutableArray alloc] init];
		legendEntries = [[NSMutableArray alloc] init];
		layoutChanged = YES;
		textStyle = [[CPTTextStyle alloc] init];
		swatchSize = CGSizeZero;
		swatchBorderLineStyle = nil;
		swatchCornerRadius = 0.0;
		swatchFill = nil;
		numberOfColumns = 0;
		equalColumns = NO;
		columnWidths = nil;
		columnWidthsThatFit = nil;
		columnMargin = 10.0;
		rowMargin = 5.0;
		titleOffset = 5.0;
		
		self.paddingLeft = 5.0;
		self.paddingTop = 5.0;
		self.paddingRight = 5.0;
		self.paddingBottom = 5.0;
		self.needsDisplayOnBoundsChange = YES;
	}
	return self;
}

/** @brief Initializes a newly allocated CPTLegend object and adds legend entries for each plot in the given array.
 *	@param newPlots An array of plots.
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
 *	@param graph A graph.
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

-(id)initWithLayer:(id)layer
{
	if ( (self = [super initWithLayer:layer]) ) {
		CPTLegend *theLayer = (CPTLegend *)layer;
		
		plots = [theLayer->plots retain];
		legendEntries = [theLayer->legendEntries retain];
		layoutChanged = theLayer->layoutChanged;
		textStyle = [theLayer->textStyle retain];
		swatchSize = theLayer->swatchSize;
		swatchBorderLineStyle = [theLayer->swatchBorderLineStyle retain];
		swatchCornerRadius = theLayer->swatchCornerRadius;
		swatchFill = [theLayer->swatchFill retain];
		numberOfColumns = theLayer->numberOfColumns;
		equalColumns = theLayer->equalColumns;
		columnWidths = [theLayer->columnWidths retain];
		columnWidthsThatFit = [theLayer->columnWidthsThatFit retain];
		columnMargin = theLayer->columnMargin;
		rowMargin = theLayer->rowMargin;
		titleOffset = theLayer->titleOffset;
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
	[columnWidths release];
	[columnWidthsThatFit release];
	
	[super dealloc];
}

#pragma mark -
#pragma mark Drawing

-(void)renderAsVectorInContext:(CGContextRef)context
{
	if ( self.hidden ) return;
	
	[super renderAsVectorInContext:context];
	
	// calculate column positions
	NSArray *fixedColumnWidths = self.columnWidths;
	NSUInteger fixedColumnCount = fixedColumnWidths.count;
	NSArray *computedColumnWidths = self.columnWidthsThatFit;
	NSUInteger columnCount = computedColumnWidths.count;
	CGFloat *actualColumnWidths = malloc(sizeof(CGFloat) * columnCount);
	CGFloat *columnPositions = malloc(sizeof(CGFloat) * columnCount);
	columnPositions[0] = self.paddingLeft;
	CGFloat theOffset = self.titleOffset;
	CGSize theSwatchSize = self.swatchSize;
	CGFloat theColumnMargin = self.columnMargin;
	
	Class numberClass = [NSNumber class];
	for ( NSUInteger col = 0; col < columnCount; col++ ) {
		NSNumber *colWidth;
		if ( col < fixedColumnCount ) {
			colWidth = [fixedColumnWidths objectAtIndex:col];
			if ( ![colWidth isKindOfClass:numberClass] ) {
				colWidth = [computedColumnWidths objectAtIndex:col];
			}
		}
		else {
			colWidth = [computedColumnWidths objectAtIndex:col];
		}
		CGFloat width = [colWidth cgFloatValue];
		actualColumnWidths[col] = width;
		if ( col < columnCount - 1 ) {
			columnPositions[col + 1] = columnPositions[col] + width + theOffset + theSwatchSize.width + theColumnMargin;
		}
	}
	
	// calculate row height
	CGFloat rowHeight = theSwatchSize.height + self.rowMargin;
	CGFloat bottom = self.bounds.size.height - self.paddingTop - theSwatchSize.height;
	
	// draw legend entries
	for ( CPTLegendEntry *legendEntry in self.legendEntries ) {
		NSUInteger row = legendEntry.row;
		NSUInteger col = legendEntry.column;
		
		CGFloat left = columnPositions[col];
		CGFloat rowPosition = bottom - row * rowHeight;
		[legendEntry.plot drawSwatchForLegend:self
									  atIndex:legendEntry.index
									   inRect:CPTAlignRectToUserSpace(context, CGRectMake(left, rowPosition, theSwatchSize.width, theSwatchSize.height))
									inContext:context];
		
		left += theSwatchSize.width + theOffset;
		
		[legendEntry drawTitleInRect:CPTAlignRectToUserSpace(context, CGRectMake(left, rowPosition, actualColumnWidths[col], theSwatchSize.height))
						   inContext:context];
	}
	
	free(actualColumnWidths);
	free(columnPositions);
}

#pragma mark -
#pragma mark Layout

-(void)setLayoutChanged
{
	self.layoutChanged = YES;
}

-(void)layoutSublayers
{
	[super layoutSublayers];

	[self recalculateLayout];
}

// TODO: implement auto layout
-(void)recalculateLayout
{
	if ( !self.layoutChanged ) return;
	
	CGSize legendSize = CGSizeMake(self.paddingLeft + self.paddingRight, self.paddingTop + self.paddingBottom);
	NSUInteger desiredColumnCount = self.numberOfColumns;
	
	if ( desiredColumnCount > 0 ) { // User set number of columns
		NSUInteger row = 0;
		NSUInteger col = 0;
		CGFloat *maxTitleWidth = malloc(desiredColumnCount * sizeof(CGFloat));
		
		for ( CPTLegendEntry *legendEntry in self.legendEntries ) {
			legendEntry.row = row;
			legendEntry.column = col;
			
			CGSize titleSize = legendEntry.titleSize;
			maxTitleWidth[col] = MAX(maxTitleWidth[col], titleSize.width);
			
			col++;
			if ( col >= desiredColumnCount ) {
				row++;
				col = 0;
			}
		}
		
		NSMutableArray *maxColumnWidths = [[NSMutableArray alloc] initWithCapacity:desiredColumnCount];
		for ( NSUInteger i = 0; i < desiredColumnCount; i++ ) {
			[maxColumnWidths addObject:[NSNumber numberWithCGFloat:maxTitleWidth[i]]];
		}
		self.columnWidthsThatFit = maxColumnWidths;

		free(maxTitleWidth);
		
		CGSize theSwatchSize = self.swatchSize;
		
		if ( self.equalColumns ) {
			NSNumber *maxWidth = [maxColumnWidths valueForKeyPath:@"@max.doubleValue"];
			legendSize.width += [maxWidth cgFloatValue] * desiredColumnCount;
		}
		else {
			for ( NSNumber *width in maxColumnWidths ) {
				legendSize.width += [width cgFloatValue];
			}
		}
		legendSize.width += ((theSwatchSize.width + self.titleOffset) * desiredColumnCount) + (self.columnMargin * (desiredColumnCount - 1));
		
		NSUInteger rows = row;
		if ( col ) rows++;
		legendSize.height += (theSwatchSize.height * rows) + (self.rowMargin * (rows - 1));

		[maxColumnWidths release];
	}
	else { // Calculate number of columns automatically
		
	}
	
	self.bounds = CGRectMake(0.0, 0.0, legendSize.width, legendSize.height);
	
	self.layoutChanged = NO;
}

#pragma mark -
#pragma mark Plots

/**	@brief All plots associated with the legend.
 *	@return An array of all plots associated with the legend. 
 **/
-(NSArray *)allPlots 
{    
	return [NSArray arrayWithArray:self.plots];
}

/**	@brief Gets the plot at the given index in the plot array.
 *	@param index An index within the bounds of the plot array.
 *	@return The plot at the given index.
 **/
-(CPTPlot *)plotAtIndex:(NSUInteger)index
{
    return [self.plots objectAtIndex:index];
}

/**	@brief Gets the plot with the given identifier from the plot array.
 *	@param identifier A plot identifier.
 *	@return The plot with the given identifier or nil if it was not found.
 **/
-(CPTPlot *)plotWithIdentifier:(id <NSCopying>)identifier 
{
	for ( CPTPlot *plot in self.plots ) {
        if ( [[plot identifier] isEqual:identifier] ) return plot;
	}
    return nil;
}

#pragma mark -
#pragma mark Organizing Plots

/**	@brief Add a plot to the legend.
 *	@param plot The plot.
 **/
-(void)addPlot:(CPTPlot *)plot
{
	if ( [plot isKindOfClass:[CPTPlot class]] ) {
		[self.plots addObject:plot];
		self.layoutChanged = YES;
		
		NSMutableArray *theLegendEntries = self.legendEntries;
		CPTTextStyle *theTextStyle = self.textStyle;
		NSUInteger numberOfLegendEntries = [plot numberOfLegendEntries];
		for ( NSUInteger i = 0; i < numberOfLegendEntries; i++ ) {
			NSString *newTitle = [plot titleForLegendEntryAtIndex:i];
			if ( newTitle ) {
				CPTLegendEntry *newLegendEntry = [[CPTLegendEntry alloc] init];
				newLegendEntry.plot = plot;
				newLegendEntry.index = i;
				newLegendEntry.title = newTitle;
				newLegendEntry.textStyle = theTextStyle;
				[theLegendEntries addObject:newLegendEntry];
				[newLegendEntry release];
			}
		}
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(legendNeedsRedraw:) name:CPTLegendNeedsRedrawForPlotNotification object:plot];
	}
}

/**	@brief Add a plot to the legend at the given index in the plot array.
 *	@param plot The plot.
 *	@param index An index within the bounds of the plot array.
 **/
-(void)insertPlot:(CPTPlot* )plot atIndex:(NSUInteger)index 
{
	if ( [plot isKindOfClass:[CPTPlot class]] ) {
		NSMutableArray *thePlots = self.plots;
		NSAssert(index <= thePlots.count, @"index greater than the number of plots");
		
		NSMutableArray *theLegendEntries = self.legendEntries;
		NSUInteger legendEntryIndex = 0;
		if ( index == thePlots.count ) {
			legendEntryIndex = theLegendEntries.count;
		}
		else {
			CPTPlot *lastPlot = [thePlots objectAtIndex:index];
			for ( CPTLegendEntry *legendEntry in theLegendEntries ) {
				if ( legendEntry.plot == lastPlot ) break;
				legendEntryIndex++;
			}
		}

		[thePlots insertObject:plot atIndex:index];
		self.layoutChanged = YES;
		
		CPTTextStyle *theTextStyle = self.textStyle;
		NSUInteger numberOfLegendEntries = [plot numberOfLegendEntries];
		for ( NSUInteger i = 0; i < numberOfLegendEntries; i++ ) {
			NSString *newTitle = [plot titleForLegendEntryAtIndex:i];
			if ( newTitle ) {
				CPTLegendEntry *newLegendEntry = [[CPTLegendEntry alloc] init];
				newLegendEntry.plot = plot;
				newLegendEntry.index = i;
				newLegendEntry.title = newTitle;
				newLegendEntry.textStyle = theTextStyle;
				[theLegendEntries insertObject:newLegendEntry atIndex:legendEntryIndex++];
				[newLegendEntry release];
			}
		}
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(legendNeedsRedraw:) name:CPTLegendNeedsRedrawForPlotNotification object:plot];
	}
}

/**	@brief Remove a plot from the legend.
 *	@param plot The plot to remove.
 **/
-(void)removePlot:(CPTPlot *)plot
{
    if ( [self.plots containsObject:plot] ) {
        [self.plots removeObjectIdenticalTo:plot];
		[self removeLegendEntriesForPlot:plot];
		self.layoutChanged = YES;
        [[NSNotificationCenter defaultCenter] removeObserver:self name:CPTLegendNeedsRedrawForPlotNotification object:plot];
    }
    else {
        [NSException raise:CPTException format:@"Tried to remove CPTPlot which did not exist."];
    }
}

/**	@brief Remove a plot from the legend.
 *	@param identifier The identifier of the plot to remove.
 **/
-(void)removePlotWithIdentifier:(id <NSCopying>)identifier 
{
	CPTPlot* plotToRemove = [self plotWithIdentifier:identifier];
	if ( plotToRemove ) {
		[self.plots removeObjectIdenticalTo:plotToRemove];
		[self removeLegendEntriesForPlot:plotToRemove];
		self.layoutChanged = YES;
        [[NSNotificationCenter defaultCenter] removeObserver:self name:CPTLegendNeedsRedrawForPlotNotification object:plotToRemove];
	}
}

/**	@brief Remove all legend entries for the given plot from the legend.
 *	@param plot The plot.
 **/
-(void)removeLegendEntriesForPlot:(CPTPlot *)plot
{
	NSMutableArray *theLegendEntries = self.legendEntries;
	NSMutableArray *entriesToRemove = [[NSMutableArray alloc] init];
	
	for ( CPTLegendEntry *legendEntry in theLegendEntries ) {
		if ( legendEntry.plot == plot ) {
			[entriesToRemove addObject:legendEntry];
		}
	}
	[theLegendEntries removeObjectsInArray:entriesToRemove];
	
	[entriesToRemove release];
}

-(void)legendNeedsRedraw:(NSNotification *)notif
{
	[self setNeedsDisplay];
}

#pragma mark -
#pragma mark Accessors

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
		swatchSize = newSwatchSize;
		self.layoutChanged = YES;
	}
}

-(CGSize)swatchSize
{
	CGSize theSwatchSize = swatchSize;
	if ( CGSizeEqualToSize(theSwatchSize, CGSizeZero) ) {
		CPTTextStyle *theTextStyle = self.textStyle;
		CGFloat fontSize = theTextStyle.fontSize;
		if ( fontSize > 0.0 ) {
			fontSize *= 1.5;
			theSwatchSize = CGSizeMake(fontSize, fontSize);
		}
		else {
			theSwatchSize = CGSizeMake(15.0, 15.0);
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

-(void)setNumberOfColumns:(NSUInteger)newNumberOfColumns
{
	if ( newNumberOfColumns != numberOfColumns ) {
		numberOfColumns = newNumberOfColumns;
		self.layoutChanged = YES;
	}
}

-(void)setEqualColumns:(BOOL)newEqualColumns
{
	if ( newEqualColumns != equalColumns ) {
		equalColumns = newEqualColumns;
		self.layoutChanged = YES;
	}
}

-(void)setColumnWidths:(NSArray *)newColumnWidths
{
	if ( newColumnWidths != columnWidths ) {
		[columnWidths release];
		columnWidths = [newColumnWidths copy];
		self.layoutChanged = YES;
	}
}

-(void)setColumnMargin:(CGFloat)newColumnMargin
{
	if ( newColumnMargin != columnMargin ) {
		columnMargin = newColumnMargin;
		self.layoutChanged = YES;
	}
}

-(void)setRowMargin:(CGFloat)newRowMargin
{
	if ( newRowMargin != rowMargin ) {
		rowMargin = newRowMargin;
		self.layoutChanged = YES;
	}
}

-(void)setTitleOffset:(CGFloat)newTitleOffset
{
	if ( newTitleOffset != titleOffset ) {
		titleOffset = newTitleOffset;
		self.layoutChanged = YES;
	}
}

-(void)setLayoutChanged:(BOOL)newLayoutChanged
{
	if ( newLayoutChanged != layoutChanged ) {
		layoutChanged = newLayoutChanged;
		if ( newLayoutChanged ) {
			self.columnWidthsThatFit = nil;
			[self setNeedsLayout];
		}
	}
}

-(NSArray *)columnWidthsThatFit
{
	if ( !columnWidthsThatFit ) {
		[self recalculateLayout];
	}
	return columnWidthsThatFit;
}

@end
