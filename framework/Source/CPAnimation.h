
#import <Foundation/Foundation.h>

@class CPGraph;
@class CPAnimationTransition;
@class CPAnimationKeyFrame;

@interface CPAnimation : NSObject {
    CPGraph *graph;
    NSMutableSet *mutableKeyFrames;
    NSMutableSet *mutableTransitions;
    CPAnimationKeyFrame *currentKeyFrame;
}

@property (nonatomic, readonly, retain) CPGraph *graph;
@property (nonatomic, readonly, retain) NSSet *animationKeyFrames;
@property (nonatomic, readonly, retain) NSSet *animationTransitions;
@property (nonatomic, readonly, retain) CPAnimationKeyFrame *currentKeyFrame;

-(id)initWithGraph:(CPGraph *)graph;

// Key frames
-(void)addAnimationKeyFrame:(CPAnimationKeyFrame *)newKeyFrame;
-(CPAnimationKeyFrame *)animationKeyFrameWithIdentifier:(id <NSCopying>)identifier;

// Transitions
-(void)addAnimationTransition:(CPAnimationTransition *)newTransition fromKeyFrame:(CPAnimationKeyFrame *)startFrame toKeyFrame:(CPAnimationKeyFrame *)endFrame;
-(CPAnimationTransition *)animationTransitionWithIdentifier:(id <NSCopying>)identifier;

-(void)animationTransitionDidFinish:(CPAnimationTransition *)transition;

// Animating
-(void)performTransition:(CPAnimationTransition *)transition;
-(void)performTransitionToKeyFrame:(CPAnimationKeyFrame *)keyFrame;

@end
