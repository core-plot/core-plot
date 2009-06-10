
#import "CPPlotSpace.h"
#import "CPPlotArea.h"
#import "CPAxisSet.h"
#import "CPLineStyle.h"

@implementation CPPlotSpace

@synthesize identifier;

#pragma mark -
#pragma mark Drawing

-(void)renderAsVectorInContext:(CGContextRef)theContext
{
	[[CPLineStyle lineStyle] setLineStyleInContext:theContext];
	CGContextStrokeRectWithWidth(theContext, self.bounds, 1.0f);
	CGContextFillEllipseInRect(theContext, CGRectMake(-2, -2, 4, 4));
}

@end
