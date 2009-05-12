

#import "CPAxis.h"
#import "CPPlotSpace.h"

@implementation CPAxis

@synthesize majorTickLocations;
@synthesize minorTickLocations;
@synthesize minorTickLength;
@synthesize majorTickLength;
@synthesize range;

-(void)dealloc {
    self.majorTickLocations = nil;
    self.minorTickLocations = nil;
    [super dealloc];
}

-(void)drawInContext:(CGContextRef)theContext withPlotSpace:(CPPlotSpace*)aPlotSpace;
{
    
}

@end
