
#import <Foundation/Foundation.h>

@class CPAnimation;
@class CPAnimationKeyFrame;

@interface CPAnimationTransition : NSObject {
    id <NSCopying> identifier;
    CPAnimationKeyFrame *startKeyFrame;
    CPAnimationKeyFrame *endKeyFrame;
    CPAnimationTransition *continuingTransition;
    NSTimeInterval duration;
    CPAnimation *animation;
}

@property (nonatomic, readwrite, copy) id <NSCopying> identifier;
@property (nonatomic, readwrite, assign) NSTimeInterval duration;
@property (nonatomic, readonly, assign) BOOL reversible;
@property (nonatomic, readwrite, assign) CPAnimation *animation;
@property (nonatomic, readwrite, retain) CPAnimationKeyFrame *startKeyFrame;
@property (nonatomic, readwrite, retain) CPAnimationKeyFrame *endKeyFrame;
@property (nonatomic, readwrite, retain) CPAnimationTransition *continuingTransition;

@end

@interface CPAnimationTransition(AbstractMethods)

-(void)performTransition;

@end
