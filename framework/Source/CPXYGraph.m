
#import "CPXYGraph.h"
#import "CPCartesianPlotSpace.h"
#import "CPExceptions.h"


@implementation CPXYGraph

// Designated initializer
-(id)initWithXScaleType:(CPScaleType)xScaleType yScaleType:(CPScaleType)yScaleType
{
    if ( self = [super init] ) {
        CPPlotSpace *space;
        if ( xScaleType == CPScaleTypeLinear && yScaleType == CPScaleTypeLinear ) {
            space = [[CPCartesianPlotSpace alloc] init];
        }
        else {
            NSLog(@"Unsupported scale types in initWithXScaleType:yScaleType:");
            [self release]; self = nil;
        }
        [self addPlotSpace:space];
        [space release];
    }
    return self;
}

-(id)init {
    return [self initWithXScaleType:CPScaleTypeLinear yScaleType:CPScaleTypeLinear];
}

#pragma mark -
#pragma mark Drawing

-(void)renderAsVectorInContext:(CGContextRef)theContext
{
    // Temporary: fill bounds
    CGContextSetGrayFillColor(theContext, 0.7, 1.0);
    CGContextFillRect(theContext, self.bounds); 
}

@end
