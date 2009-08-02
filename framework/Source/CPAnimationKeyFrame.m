
#import "CPAnimationKeyFrame.h"

/**	@brief An animation key frame.
 *	@note Not implemented.
 *	@todo
 *	- Implement CPAnimationKeyFrame.
 *	- Add documentation for CPAnimationKeyFrame.
 **/
@implementation CPAnimationKeyFrame


/**	@property identifier
 *	@todo Needs documentation.
 **/
@synthesize identifier;

/**	@property isInitialFrame
 *	@todo Needs documentation.
 **/
@synthesize isInitialFrame;

/**	@property duration
 *	@todo Needs documentation.
 **/
@synthesize duration;

/**	@todo Needs documentation.
 *	@param isFirst Needs documentation.
 *	@return Needs documentation.
 **/
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
