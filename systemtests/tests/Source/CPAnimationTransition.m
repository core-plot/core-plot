
#import "CPAnimationTransition.h"
#import "CPAnimationKeyFrame.h"
#import "CPAnimation.h"

/**	@brief An animation transition.
 *	@note Not implemented.
 *	@todo
 *	- Implement CPAnimationTransition.
 *	- Add documentation for CPAnimationTransition.
 **/
@implementation CPAnimationTransition

/// @defgroup CPAnimationTransition CPAnimationTransition
/// @{

/**	@property identifier
 *	@todo Needs documentation.
 **/
@synthesize identifier;

/**	@property duration
 *	@todo Needs documentation.
 **/
@synthesize duration;

/**	@property reversible
 *	@todo Needs documentation.
 **/
@synthesize reversible;

/**	@property animation
 *	@todo Needs documentation.
 **/
@synthesize animation;

/**	@property startKeyFrame
 *	@todo Needs documentation.
 **/
@synthesize startKeyFrame;

/**	@property endKeyFrame
 *	@todo Needs documentation.
 **/
@synthesize endKeyFrame;

/**	@property continuingTransition
 *	@todo Needs documentation.
 **/
@synthesize continuingTransition;

#pragma mark -
#pragma mark Init/Dealloc

-(id)init
{
	if ( self = [super init] ) {
		identifier = nil;
		startKeyFrame = nil;
		endKeyFrame = nil;
		continuingTransition = nil;
		duration = 0.0;
		animation = nil;
		reversible = NO;
	}
	return self;
}

-(void)dealloc 
{
    [identifier release];
    [animation release];
    [startKeyFrame release];
    [endKeyFrame release];
    [continuingTransition release];
    [super dealloc];
}

///	@}

@end

///	@brief CPAnimationTransition abstract methods—must be overridden by subclasses
@implementation CPAnimationTransition(AbstractMethods)

/// @addtogroup CPAnimationTransition
/// @{

/**	@todo Needs documentation.
 **/
-(void)performTransition
{
	
}

///	@}

@end
