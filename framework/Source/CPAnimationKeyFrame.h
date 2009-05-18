
#import <Cocoa/Cocoa.h>

@interface CPAnimationKeyFrame : NSObject {
    id <NSCopying> identifier;
    BOOL isInitialFrame;
}

@property (nonatomic, readwrite, copy) id <NSCopying> identifier;

-(id)initAsInitialFrame:(BOOL)isFirst;

@end
