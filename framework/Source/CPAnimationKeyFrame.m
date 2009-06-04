
#import "CPAnimationKeyFrame.h"

@implementation CPAnimationKeyFrame

@synthesize identifier;
@synthesize duration;

-(id)initAsInitialFrame:(BOOL)isFirst
{
    if ( self = [super init] ) {
        isInitialFrame = isFirst;
    }
    return self;
}

-(void)dealloc 
{
    self.identifier = nil;
    [super dealloc];
}

@end
