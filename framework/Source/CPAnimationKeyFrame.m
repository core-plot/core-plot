
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

#pragma mark -
#pragma mark Init/Dealloc

/**	@todo Needs documentation.
 *	@param isFirst Needs documentation.
 *	@return Needs documentation.
 **/
-(id)initAsInitialFrame:(BOOL)isFirst
{
    if ( self = [super init] ) {
		identifier = nil;
        isInitialFrame = isFirst;
		duration = 0.0;
   }
    return self;
}

-(void)dealloc 
{
    [identifier release];
    [super dealloc];
}

@end
