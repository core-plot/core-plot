
#import "CPCartesianPlotSpace.h"

@implementation CPCartesianPlotSpace

@synthesize scale, offset;

#pragma mark Implementation of CPPlotSpace
-(CGPoint)viewPointForPlotPoint:(NSArray *)decimalNumbers;
{
	if ([decimalNumbers count] == 2)
		return CGPointMake(([[decimalNumbers objectAtIndex:0] floatValue] - offset.x) * scale.x, 
						   ([[decimalNumbers objectAtIndex:1] floatValue] - offset.y) * scale.y);
	else
		// What do we return in this case?
		return CGPointMake(0.f, 0.f);
}

-(NSArray *)plotPointForViewPoint:(CGPoint)point
{
	NSDecimalNumber* x = [[[NSDecimalNumber alloc] initWithFloat:(point.x / scale.x) - offset.x] autorelease];
	NSDecimalNumber* y = [[[NSDecimalNumber alloc] initWithFloat:(point.y / scale.y) - offset.y] autorelease];
	return [NSArray arrayWithObjects:x,y,nil];
	
}

- (void) updateScaleAndOffset
{
	scale.x = (self.bounds.size.width) / ([upperX floatValue] - [lowerX floatValue]); 
	scale.y = (self.bounds.size.height) / ([upperY floatValue] - [lowerY floatValue]); 
	
	// This assumes bounds.origin = {0.0 0.0};
	offset = CGPointMake([lowerX floatValue], [lowerY floatValue]);
};

#pragma mark getters/setters

- (void) setBounds:(CGRect)rect
{
	[super setBounds:rect];
	[self updateScaleAndOffset];
}

- (NSArray*) XRange
{
	return [NSArray arrayWithObjects:lowerX, upperX, nil];
}

- (void) setXRange:(NSArray*)range
{
	[lowerX release];
	[upperX release];
	
	//Add bounds checking?
	[[range objectAtIndex:0] retain];
	[[range objectAtIndex:1] retain];
	
	lowerX = [range objectAtIndex:0];
	upperX = [range objectAtIndex:1];
	[self updateScaleAndOffset];
}

- (NSArray*) YRange
{
	return [NSArray arrayWithObjects:lowerY, upperY, nil];
}

- (void) setYRange:(NSArray*)range
{
	[lowerY release];
	[upperY release];
	
	//Add bounds checking?
	[[range objectAtIndex:0] retain];
	[[range objectAtIndex:1] retain];
	
	lowerY = [range objectAtIndex:0];
	upperY = [range objectAtIndex:1];
	[self updateScaleAndOffset];
}

#pragma mark init/dealloc

- (void) dealloc
{
	[lowerX release];
	[upperX release];
	[lowerY release];
	[upperY release];
	
	[super dealloc];
}

@end
