
#import "CPPlotSpace.h"
#import "CPPlotArea.h"
#import "CPAxisSet.h"
#import "CPLineStyle.h"

@implementation CPPlotSpace

@synthesize identifier;

#pragma mark -
#pragma mark Layout

+(CGFloat)defaultZPosition 
{
	return CPDefaultZPositionPlotSpace;
}

@end
