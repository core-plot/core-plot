
#import <Foundation/Foundation.h>

@interface CPAnimationKeyFrame : NSObject {
	@private
    id <NSObject, NSCopying> identifier;
    BOOL isInitialFrame;
    NSTimeInterval duration;
}

@property (nonatomic, readwrite, copy) id <NSCopying> identifier;
@property (nonatomic, readwrite, assign) BOOL isInitialFrame;
@property (nonatomic, readwrite, assign) NSTimeInterval duration;

-(id)initAsInitialFrame:(BOOL)isFirst;

@end
