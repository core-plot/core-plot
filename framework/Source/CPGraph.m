
#import "CPGraph.h"
#import "CPExceptions.h"
#import "CPPlot.h"
#import "CPPlotArea.h"
#import "CPPlotSpace.h"
#import "CPFill.h"
#import "CPAxisSet.h"
#import "CPAxis.h"

@implementation CPGraph

@synthesize axisSet;
@synthesize plotArea;
@synthesize fill;

#pragma mark -
#pragma mark Init/Dealloc

-(id)initWithFrame:(CGRect)newFrame
{
	if ( self = [super initWithFrame:newFrame] ) {
        self.fill = nil;
		plots = [[NSMutableArray alloc] init];
        
        // Plot area
        plotArea = [[CPPlotArea alloc] initWithFrame:CGRectInset(self.bounds, 40.0, 40.0)]; // TODO: Replace later with true margins
        [self addSublayer:plotArea];

        // Plot spaces
		plotSpaces = [[NSMutableArray alloc] init];
        CPPlotSpace *newPlotSpace = [self newPlotSpace];
        [self addPlotSpace:newPlotSpace];
        [newPlotSpace release];
        
        // Axis set
        CPAxisSet *newAxisSet = [self newAxisSet];
        self.axisSet = newAxisSet;
        [newAxisSet release];
        
		self.needsDisplayOnBoundsChange = YES;
        [self setNeedsLayout];
	}
	return self;
}

-(void)dealloc
{
	self.axisSet = nil;
	self.plotArea = nil;
    self.fill = nil;
	[plots release];
	[plotSpaces release];
	[super dealloc];
}

#pragma mark -
#pragma mark Retrieving Plots

-(NSArray *)allPlots 
{    
	return [NSArray arrayWithArray:plots];
}

-(CPPlot *)plotAtIndex:(NSUInteger)index
{
    return [plots objectAtIndex:index];
}

-(CPPlot *)plotWithIdentifier:(id <NSCopying>)identifier 
{
	for (CPPlot *plot in plots) {
        if ( [[plot identifier] isEqual:identifier] ) return plot;
	}
    return nil;
}

#pragma mark -
#pragma mark Organizing Plots

-(void)addPlot:(CPPlot *)plot
{
	[self addPlot:plot toPlotSpace:self.defaultPlotSpace];
}

-(void)addPlot:(CPPlot *)plot toPlotSpace:(CPPlotSpace *)space
{
	plot.frame = space.bounds;
	[plots addObject:plot];
    plot.plotSpace = space;
	[space addSublayer:plot];	
    [self setNeedsLayout];
}

-(void)removePlot:(CPPlot *)plot
{
    if ( [plots containsObject:plot] ) {
        [plots removeObject:plot];
        plot.plotSpace = nil;
        [plot removeFromSuperlayer];
        [self setNeedsLayout];
    }
    else {
        [NSException raise:CPException format:@"Tried to remove CPPlot which did not exist."];
    }
}

-(void)insertPlot:(CPPlot* )plot atIndex:(NSUInteger)index 
{
	[self insertPlot:plot atIndex:index intoPlotSpace:self.defaultPlotSpace];
}

-(void)insertPlot:(CPPlot* )plot atIndex:(NSUInteger)index intoPlotSpace:(CPPlotSpace *)space
{
	[plots insertObject:plot atIndex:index];
    plot.plotSpace = space;
    [space addSublayer:plot];
    [self setNeedsLayout];
}

-(void)removePlotWithIdentifier:(id <NSCopying>)identifier 
{
	CPPlot* plotToRemove = [self plotWithIdentifier:identifier];
	[plotToRemove setPlotSpace:nil];
	[plotToRemove removeFromSuperlayer];
	[plots removeObjectIdenticalTo:plotToRemove];
}

#pragma mark -
#pragma mark Retrieving Plot Spaces

-(CPPlotSpace *)defaultPlotSpace {
    return ( plotSpaces.count > 0 ? [plotSpaces objectAtIndex:0] : nil );
}

-(NSArray *)allPlotSpaces
{
	return [NSArray arrayWithArray:plotSpaces];
}

-(CPPlotSpace *)plotSpaceAtIndex:(NSUInteger)index
{
	return ( plotSpaces.count > index ? [plotSpaces objectAtIndex:index] : nil );
}

-(CPPlotSpace *)plotSpaceWithIdentifier:(id <NSCopying>)identifier
{
	for (CPPlotSpace *plotSpace in plotSpaces) {
        if ( [[plotSpace identifier] isEqual:identifier] ) return plotSpace;
	}
    return nil;	
}

#pragma mark -
#pragma mark Organizing Plot Spaces

-(void)addPlotSpace:(CPPlotSpace *)space
{
	space.frame = self.plotArea.bounds;
	[plotSpaces addObject:space];
	[self.plotArea addSublayer:space];
    [self setNeedsLayout];
}

-(void)removePlotSpace:(CPPlotSpace *)plotSpace
{
	if ( [plotSpaces containsObject:plotSpace] ) {
        [plotSpaces removeObject:plotSpace];
        [plotSpace removeFromSuperlayer];
        for ( CPAxis *axis in self.axisSet.axes ) {
            if ( axis.plotSpace == plotSpace ) axis.plotSpace = nil;
        }
    }
    else {
        [NSException raise:CPException format:@"Tried to remove CPPlotSpace which did not exist."];
    }
	[self setNeedsLayout];
}

#pragma mark -
#pragma mark Axis Set

-(void)setAxisSet:(CPAxisSet *)newSet
{
    if ( newSet != axisSet ) {
        [axisSet release];
        [axisSet removeFromSuperlayer];
        axisSet = [newSet retain];
        if ( axisSet ) [self addSublayer:axisSet];
        [axisSet positionInGraph:self];
    }
}

#pragma mark -
#pragma mark Drawing

-(void)renderAsVectorInContext:(CGContextRef)theContext
{
	[self.fill fillRect:self.bounds inContext:theContext];
}

#pragma mark -
#pragma mark Layout

-(void)layoutSublayers 
{
    [super layoutSublayers];
    [self.axisSet positionInGraph:self];
}

#pragma mark -
#pragma mark Accessors

-(void)setFill:(CPFill *)newFill 
{
    if ( newFill != fill ) {
        [fill release];
        fill = [newFill retain];
        [self setNeedsDisplay];
    }
}

@end
