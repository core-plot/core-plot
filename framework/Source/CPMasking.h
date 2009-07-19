
#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

/**	@brief Creates a new masking path.
 *	@todo More documentation needed 
 **/
@protocol CPMasking

/**	@brief Creates a new masking path.
 *	@note The caller must release the returned path.
 *	@return The new masking path.
 **/
-(CGPathRef)newMaskingPath; // Caller must release

@end
