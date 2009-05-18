
#import "CPAnimationTransition.h"
#import "CPAnimationKeyFrame.h"
#import "CPAnimation.h"

@implementation CPAnimationTransition

@synthesize duration, identifier, animation, startKeyFrame, endKeyFrame, continuingTransition;

-(void)dealloc 
{
    self.identifier = nil;
    self.animation = nil;
    self.startKeyFrame = nil;
    self.endKeyFrame = nil;
    self.continuingTransition = nil;
    [super dealloc];
}

@end
