
#import "CPGraph.h"
#import "CPPlot.h"
#import "CPPlotArea.h"

@implementation CPGraph

@synthesize axisSet;
@synthesize plotArea;

// Temporary method just to show something...
- (void)drawInContext:(CGContextRef)theContext
{
	NSAttributedString* tempString = [[NSAttributedString alloc] initWithString:@"CPGraph" attributes:nil];
	[tempString drawAtPoint:NSMakePoint(10.f, 10.f)];
	[tempString release];
};

#pragma mark getters/setters
- (void) setBounds:(CGRect)rect
{
	[plotArea setBounds:rect];
	[super setBounds:rect];
};

- (void) setPlotArea:(CPPlotArea*)aPlotArea
{
	[plotArea removeFromSuperlayer];
	[plotArea release];
	[aPlotArea retain];
	plotArea = aPlotArea;
	[self addSublayer:plotArea];
	[plotArea setNeedsDisplayOnBoundsChange:YES];
//	[plotArea setFrame:[self frame]];
};

#pragma mark plots array management

-(void)addPlot:(CPPlot *)plot
{
//	[plot setFrame:[plotArea frame]];
	[plot setNeedsDisplayOnBoundsChange:YES];
	[plotArea addSublayer:plot];	
	[plots addObject:plot];
}

-(NSArray *)allPlots 
{    
	return [NSArray arrayWithArray:plots];
}

-(void)removePlotAtIndex:(NSUInteger)index 
{
	[[plots objectAtIndex:index] removeFromSuperview];
	[plots removeObjectAtIndex:index];
}

-(void)insertPlot:(CPPlot* )plot AtIndex:(NSUInteger)index 
{
	[plot setNeedsDisplayOnBoundsChange:YES];

	// This probably needs some ordering
	[plotArea addSublayer:plot];
	
	[plots insertObject:plot atIndex:index];
}

-(void)removePlotWithIdentifier:(id <NSCopying>)identifier 
{
	CPPlot* plotToRemove = [self plotWithIdentifier:identifier];
	[plotToRemove removeFromSuperlayer];
	[plots removeObject:plotToRemove];
}

-(CPPlot *)plotWithIdentifier:(id <NSCopying>)identifier 
{
	for (CPPlot* plot in plots)
		// Is this comparison correct?
		if ([plot identifier] == identifier)
			return plot;
	
    return nil;
}

-(void)replacePlotAtIndex:(NSUInteger)index withPlot:(CPPlot *)plot 
{
	[(CPPlot*)[plots objectAtIndex:index] removeFromSuperlayer];
	[plotArea addSublayer:plot];
	[plots replaceObjectAtIndex:index withObject:plot];
}

#pragma mark init/dealloc

- (id) init
{
	self = [super init];
	if (self != nil) {
		plots = [[NSMutableArray alloc] init];
	}
	return self;
}

- (void) dealloc
{
	self.axisSet = nil;
	self.plotArea = nil;
	[plots release];
	[super dealloc];
}

@end
