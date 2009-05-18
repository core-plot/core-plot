
#import "CPAnimation.h"
#import "CPAnimationTransition.h"
#import "CPAnimationKeyFrame.h"

@implementation CPAnimation

@synthesize graph;
@synthesize animationKeyFrames = mutableKeyFrames;
@synthesize animationTransitions = mutableTransitions;
@synthesize currentKeyFrame;

#pragma mark -
#pragma mark Init/Dealloc

-(id)initWithGraph:(CPGraph *)newGraph
{
    if ( self = [super init] ) {
        graph = [newGraph retain];
    }
    return self;
}

-(void)dealloc 
{
    [graph release];
    [super dealloc];
}

#pragma mark -
#pragma mark Key Frames

-(void)addAnimationKeyFrame:(CPAnimationKeyFrame *)newKeyFrame
{
    
}

-(CPAnimationKeyFrame *)animationKeyFrameWithIdentifier:(id <NSCopying>)identifier
{
    return nil;
}

#pragma mark -
#pragma mark Transitions

-(void)addAnimationTransition:(CPAnimationTransition *)newTransition fromKeyFrame:(CPAnimationKeyFrame *)startFrame toKeyFrame:(CPAnimationKeyFrame *)endFrame 
{
    
}

-(CPAnimationTransition *)animationTransitionWithIdentifier:(id <NSCopying>)identifier
{
    return nil;
}

-(void)animationTransitionDidFinish:(CPAnimationTransition *)transition
{
    // Update state here
}

#pragma mark -
#pragma mark Animating

-(void)performTransition:(CPAnimationTransition *)transition 
{
    
}

-(void)performTransitionToKeyFrame:(CPAnimationKeyFrame *)keyFrame
{
    
}

@end
