
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
@synthesize defaultPlotSpace;
@synthesize fill;

#pragma mark -
#pragma mark Init/Dealloc

-(id)init
{
	if ( self = [super init] ) {
        self.bounds = CGRectMake(0.0, 0.0, 100.0, 100.0);
        self.fill = nil;
		plots = [[NSMutableArray alloc] init];
        
        // Plot area
        plotArea = [[CPPlotArea alloc] init];
		plotArea.frame = CGRectInset(self.bounds, 20.0, 20.0); // Replace later with true margins
        [self addSublayer:plotArea];

        // Plot spaces
		plotSpaces = [[NSMutableArray alloc] init];
        [self addPlotSpace:[self createPlotSpace]];
        
        // Axis set
        self.axisSet = [self createAxisSet];
        
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
        [self setNeedsLayout];
    }
}

#pragma mark -
#pragma mark Dimensions

-(CGRect)plotAreaFrame
{
	return plotArea.frame;
}

-(void)setPlotAreaFrame:(CGRect)frame
{
    plotArea.frame = frame;
    [self setNeedsLayout];
}

#pragma mark -
#pragma mark Drawing

-(void)renderAsVectorInContext:(CGContextRef)theContext
{
	[self.fill fillRect:self.bounds inContext:theContext];
}

#pragma mark -
#pragma mark Sublayer Layout

-(void)layoutSublayers 
{
    if ( self.plotArea && self.axisSet ) {
        // Axis set coordinates must correspond to plot area
        CGRect axisSetBounds = self.bounds;
        axisSetBounds.origin = [self convertPoint:self.bounds.origin toLayer:self.plotArea];
        self.axisSet.bounds = axisSetBounds;
        self.axisSet.anchorPoint = CGPointZero;
        self.axisSet.position = self.bounds.origin;
    }
}

@end
