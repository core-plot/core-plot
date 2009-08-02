
#import <Foundation/Foundation.h>

@class CPGraph;
@class CPAnimationTransition;
@class CPAnimationKeyFrame;

@interface CPAnimation : NSObject {
@private
    CPGraph *graph;
    NSMutableSet *mutableKeyFrames;
    NSMutableSet *mutableTransitions;
    CPAnimationKeyFrame *currentKeyFrame;
}

@property (nonatomic, readonly, retain) CPGraph *graph;
@property (nonatomic, readonly, retain) NSSet *animationKeyFrames;
@property (nonatomic, readonly, retain) NSSet *animationTransitions;
@property (nonatomic, readonly, retain) CPAnimationKeyFrame *currentKeyFrame;

/// @name Initialization
/// @{
-(id)initWithGraph:(CPGraph *)graph;
///	@}

/// @name Key Frames
/// @{
-(void)addAnimationKeyFrame:(CPAnimationKeyFrame *)newKeyFrame;
-(CPAnimationKeyFrame *)animationKeyFrameWithIdentifier:(id <NSCopying>)identifier;
///	@}

/// @name Transitions
/// @{
-(void)addAnimationTransition:(CPAnimationTransition *)newTransition fromKeyFrame:(CPAnimationKeyFrame *)startFrame toKeyFrame:(CPAnimationKeyFrame *)endFrame;
-(CPAnimationTransition *)animationTransitionWithIdentifier:(id <NSCopying>)identifier;

-(void)animationTransitionDidFinish:(CPAnimationTransition *)transition;
///	@}

/// @name Animating
/// @{
-(void)performTransition:(CPAnimationTransition *)transition;
-(void)performTransitionToKeyFrame:(CPAnimationKeyFrame *)keyFrame;
///	@}

@end
