
#import "CPAnimation.h"
#import "CPAnimationTransition.h"
#import "CPAnimationKeyFrame.h"

/**	@brief An animation.
 *	@note Not implemented.
 *	@todo
 *	- Implement CPAnimation.
 *	- Add documentation for CPAnimation.
 **/
@implementation CPAnimation

/**	@property graph
 *	@todo Needs documentation.
 **/
@synthesize graph;

/**	@property animationKeyFrames
 *	@todo Needs documentation.
 **/
@synthesize animationKeyFrames = mutableKeyFrames;

/**	@property animationTransitions
 *	@todo Needs documentation.
 **/
@synthesize animationTransitions = mutableTransitions;

/**	@property currentKeyFrame
 *	@todo Needs documentation.
 **/
@synthesize currentKeyFrame;

#pragma mark -
#pragma mark Init/Dealloc

-(id)initWithGraph:(CPGraph *)newGraph
{
    if ( self = [super init] ) {
        graph = [newGraph retain];
		mutableKeyFrames = nil;
		mutableTransitions = nil;
		currentKeyFrame = nil;
    }
    return self;
}

-(void)dealloc 
{
    [graph release];
	[mutableKeyFrames release];
	[mutableTransitions release];
	[currentKeyFrame release];
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
