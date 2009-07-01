
#import "CPPlotSpace.h"
#import "CPPlotArea.h"
#import "CPAxisSet.h"
#import "CPLineStyle.h"

NSString * const CPPlotSpaceCoordinateMappingDidChangeNotification = @"CPPlotSpaceCoordinateMappingDidChangeNotification";

@implementation CPPlotSpace

@synthesize identifier;

#pragma mark -
#pragma mark Initialize/Deallocate

-(id)initWithFrame:(CGRect)newFrame
{
	if (self = [super initWithFrame:newFrame]) {
		self.masksToBounds = YES;
	}
	return self;
}

#pragma mark -
#pragma mark Layout

+(CGFloat)defaultZPosition 
{
	return CPDefaultZPositionPlotSpace;
}

-(void)setBounds:(CGRect)newBounds {
    BOOL notify = !CGRectEqualToRect(newBounds, self.bounds);
    [super setBounds:newBounds];
    if ( notify ) [[NSNotificationCenter defaultCenter] postNotificationName:CPPlotSpaceCoordinateMappingDidChangeNotification object:self];
}

@end
