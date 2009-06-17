
#import "CPGraph.h"
#import "CPExceptions.h"
#import "CPPlot.h"
#import "CPPlotArea.h"
#import "CPPlotSpace.h"
#import "CPFill.h"
#import "CPAxisSet.h"
#import "CPAxis.h"

@interface CPGraph()

@property (nonatomic, readwrite, retain) NSMutableArray *plots;
@property (nonatomic, readwrite, retain) NSMutableArray *plotSpaces;

@end

@implementation CPGraph

@synthesize axisSet;
@synthesize plotArea;
@synthesize fill;
@synthesize plots;
@synthesize plotSpaces;

#pragma mark -
#pragma mark Init/Dealloc

-(id)initWithFrame:(CGRect)newFrame
{
	if ( self = [super initWithFrame:newFrame] ) {
        self.fill = nil;
		self.plots = [[NSMutableArray alloc] init];
        
        // Plot area
        self.plotArea = [[CPPlotArea alloc] initWithFrame:self.bounds];
        [self addSublayer:self.plotArea];
		
        // Plot spaces
		self.plotSpaces = [[NSMutableArray alloc] init];
        CPPlotSpace *newPlotSpace = [self newPlotSpace];
        [self addPlotSpace:newPlotSpace];
        [newPlotSpace release];
        
        // Axis set
        CPAxisSet *newAxisSet = [self newAxisSet];
        self.axisSet = newAxisSet;
        [newAxisSet release];
        
		self.needsDisplayOnBoundsChange = YES;
	}
	return self;
}

-(void)dealloc
{
	[axisSet release];
	[plotArea release];
    self.fill = nil;
	self.plots = nil;
	self.plotSpaces = nil;
	[super dealloc];
}

#pragma mark -
#pragma mark Retrieving Plots

-(NSArray *)allPlots 
{    
	return [NSArray arrayWithArray:self.plots];
}

-(CPPlot *)plotAtIndex:(NSUInteger)index
{
    return [self.plots objectAtIndex:index];
}

-(CPPlot *)plotWithIdentifier:(id <NSCopying>)identifier 
{
	for (CPPlot *plot in self.plots) {
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
	if (plot) {
		[self.plots addObject:plot];
		plot.plotSpace = space;
		[space addSublayer:plot];	
		[self setNeedsDisplay];
	}
}

-(void)removePlot:(CPPlot *)plot
{
    if ( [self.plots containsObject:plot] ) {
        [self.plots removeObject:plot];
        plot.plotSpace = nil;
        [plot removeFromSuperlayer];
		[self setNeedsDisplay];
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
	if (plot) {
		[self.plots insertObject:plot atIndex:index];
		plot.plotSpace = space;
		[space addSublayer:plot];
		[self setNeedsDisplay];
	}
}

-(void)removePlotWithIdentifier:(id <NSCopying>)identifier 
{
	CPPlot* plotToRemove = [self plotWithIdentifier:identifier];
	if (plotToRemove) {
		plotToRemove.plotSpace = nil;
		[plotToRemove removeFromSuperlayer];
		[self.plots removeObjectIdenticalTo:plotToRemove];
		[self setNeedsDisplay];
	}
}

#pragma mark -
#pragma mark Retrieving Plot Spaces

-(CPPlotSpace *)defaultPlotSpace {
    return ( self.plotSpaces.count > 0 ? [self.plotSpaces objectAtIndex:0] : nil );
}

-(NSArray *)allPlotSpaces
{
	return [NSArray arrayWithArray:self.plotSpaces];
}

-(CPPlotSpace *)plotSpaceAtIndex:(NSUInteger)index
{
	return ( self.plotSpaces.count > index ? [self.plotSpaces objectAtIndex:index] : nil );
}

-(CPPlotSpace *)plotSpaceWithIdentifier:(id <NSCopying>)identifier
{
	for (CPPlotSpace *plotSpace in self.plotSpaces) {
        if ( [[plotSpace identifier] isEqual:identifier] ) return plotSpace;
	}
    return nil;	
}

#pragma mark -
#pragma mark Organizing Plot Spaces

-(void)addPlotSpace:(CPPlotSpace *)space
{
	space.frame = self.plotArea.bounds;
	[self.plotSpaces addObject:space];
	[self.plotArea addSublayer:space];
}

-(void)removePlotSpace:(CPPlotSpace *)plotSpace
{
	if ( [self.plotSpaces containsObject:plotSpace] ) {
        [self.plotSpaces removeObject:plotSpace];
        [plotSpace removeFromSuperlayer];
        for ( CPAxis *axis in self.axisSet.axes ) {
            if ( axis.plotSpace == plotSpace ) axis.plotSpace = nil;
        }
    }
    else {
        [NSException raise:CPException format:@"Tried to remove CPPlotSpace which did not exist."];
    }
}

#pragma mark -
#pragma mark Axis Set

-(void)setAxisSet:(CPAxisSet *)newSet
{
    if ( newSet != axisSet ) {
        [axisSet removeFromSuperlayer];
		[newSet retain];
        [axisSet release];
        axisSet = newSet;
        if ( axisSet ) {
			axisSet.graph = self;
			[self addSublayer:axisSet];	
		}
		[self setNeedsDisplay];
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

+(CGFloat)defaultZPosition 
{
	return CPDefaultZPositionGraph;
}

-(void)layoutSublayers 
{
	[super layoutSublayers];
	
    if ( self.axisSet ) {
        // Set the bounds so that the axis set coordinates coincide with the 
        // plot area drawing coordinates.
        CGRect axisSetBounds = self.bounds;
        axisSetBounds.origin = [self convertPoint:self.bounds.origin toLayer:self.plotArea];
		
		CPAxisSet *theAxisSet = self.axisSet;
        theAxisSet.bounds = axisSetBounds;
        theAxisSet.anchorPoint = CGPointZero;
        theAxisSet.position = self.bounds.origin;
    }
}

#pragma mark -
#pragma mark Accessors

-(void)setFill:(CPFill *)newFill 
{
    if ( newFill != fill ) {
		[newFill retain];
        [fill release];
        fill = newFill;
        [self setNeedsDisplay];
    }
}

@end
