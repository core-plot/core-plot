
#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

/**	@brief Implemented by view objects that can mask.
 *	@todo More documentation needed 
 **/
@protocol CPMasking

/**	@brief Creates a new masking path.
 *	@note The caller should not release the returned path.
 *	@return The new masking path.
 **/
-(CGPathRef)maskingPath; 

@end
