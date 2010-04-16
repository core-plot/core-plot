
#import <Foundation/Foundation.h>

@class CPAnimation;
@class CPAnimationKeyFrame;

@interface CPAnimationTransition : NSObject {
	@private
    id <NSObject, NSCopying> identifier;
    CPAnimationKeyFrame *startKeyFrame;
    CPAnimationKeyFrame *endKeyFrame;
    CPAnimationTransition *continuingTransition;
    NSTimeInterval duration;
    CPAnimation *animation;
	BOOL reversible;
}

@property (nonatomic, readwrite, copy) id <NSObject, NSCopying> identifier;
@property (nonatomic, readwrite, assign) NSTimeInterval duration;
@property (nonatomic, readonly, assign) BOOL reversible;
@property (nonatomic, readwrite, assign) CPAnimation *animation;
@property (nonatomic, readwrite, retain) CPAnimationKeyFrame *startKeyFrame;
@property (nonatomic, readwrite, retain) CPAnimationKeyFrame *endKeyFrame;
@property (nonatomic, readwrite, retain) CPAnimationTransition *continuingTransition;

@end

/**	@category CPAnimationTransition(AbstractMethods)
 *	@brief CPAnimationTransition abstract methods—must be overridden by subclasses
 **/
@interface CPAnimationTransition(AbstractMethods)

-(void)performTransition;

@end
