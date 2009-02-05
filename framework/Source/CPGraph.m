
#import "CPGraph.h"
#import "CPExceptions.h"
#import "CPPlot.h"
#import "CPPlotArea.h"
#import "CPPlotSpace.h"


@implementation CPGraph

@synthesize axisSet;
@synthesize plotArea;
@synthesize defaultPlotSpace;

#pragma mark Init/Dealloc
-(id)init
{
	self = [super init];
	if (self != nil) {
		plots = [[NSMutableArray alloc] init];
        plotArea = [[CPPlotArea alloc] init];
        [self addSublayer:plotArea];
	}
	return self;
}

-(void)dealloc
{
	self.axisSet = nil;
	self.plotArea = nil;
	[plots release];
	[super dealloc];
}

#pragma mark Drawing
-(void)drawInContext:(CGContextRef)theContext
{
    // Temporary method just to show something...
	NSAttributedString *tempString = [[NSAttributedString alloc] initWithString:@"CPGraph" attributes:nil];
	[tempString drawAtPoint:NSMakePoint(10.f, 10.f)];
	[tempString release];
}

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

#pragma mark Organizing Plots
-(void)addPlot:(CPPlot *)plot
{
	[self addPlot:plot toPlotSpace:self.defaultPlotSpace];
}

-(void)addPlot:(CPPlot *)plot toPlotSpace:(CPPlotSpace *)space
{
	[plots addObject:plot];
    plot.plotSpace = space;
	[space addSublayer:plot];	
}

-(void)removePlot:(CPPlot *)plot
{
    if ( [plots containsObject:plot] ) {
        [plots removeObject:plot];
        plot.plotSpace = nil;
        [plot removeFromSuperlayer];
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
}

-(void)removePlotWithIdentifier:(id <NSCopying>)identifier 
{
	CPPlot* plotToRemove = [self plotWithIdentifier:identifier];
	[plotToRemove removeFromSuperlayer];
	[plots removeObjectIdenticalTo:plotToRemove];
}

-(void)replacePlotAtIndex:(NSUInteger)index withPlot:(CPPlot *)plot 
{
	[(CPPlot*)[plots objectAtIndex:index] removeFromSuperlayer];
	[plotArea addSublayer:plot];
	[plots replaceObjectAtIndex:index withObject:plot];
}

#pragma mark Retrieving Plot Spaces
-(CPPlotSpace *)defaultPlotSpace {
    return ( plotSpaces.count > 0 ? [plotSpaces objectAtIndex:0] : nil );
}

#pragma mark Organizing Plot Spaces


#pragma mark Dimensions
-(void)setBounds:(CGRect)rect
{
    plotArea.bounds = rect;
	[super setBounds:rect];
}

-(void)setFrame:(CGRect)rect
{
    plotArea.frame = rect;
	[super setFrame:rect];
}

-(void)setPlotAreaFrame:(CGRect)frame
{
    plotArea.frame = frame;
}

@end
