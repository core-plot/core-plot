#import "CPAxis.h"
#import "CPGridLines.h"

/**	@brief An abstract class that draws grid lines for an axis.
 **/
@implementation CPGridLines

/**	@property axis
 *	@brief The axis.
 **/
@synthesize axis;

/**	@property major
 *	@brief If YES, draw the major grid lines, else draw the minor grid lines.
 **/
@synthesize major;

#pragma mark -
#pragma mark Init/Dealloc

-(id)initWithFrame:(CGRect)newFrame
{
	if ( self = [super initWithFrame:newFrame] ) {
		axis = nil;
		major = NO;
		
		self.needsDisplayOnBoundsChange = YES;
	}
	return self;
}

-(id)initWithLayer:(id)layer
{
	if ( self = [super initWithLayer:layer] ) {
		CPGridLines *theLayer = (CPGridLines *)layer;
		
		axis = theLayer->axis;
		major = theLayer->major;
	}
	return self;
}

#pragma mark -
#pragma mark Drawing

-(void)renderAsVectorInContext:(CGContextRef)theContext
{
	[self.axis drawGridLinesInContext:theContext isMajor:self.major];
}

#pragma mark -
#pragma mark Accessors

-(void)setAxis:(CPAxis *)newAxis 
{
    if ( newAxis != axis ) {
        axis = newAxis;
		[self setNeedsDisplay];		
	}
}

@end
