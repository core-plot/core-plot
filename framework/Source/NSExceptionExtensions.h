#import <Foundation/Foundation.h>

/**	@category NSException(CPExtensions)
 *	@brief Core Plot extensions to NSException.
 **/
@interface NSException(CPExtensions)

+(void)raiseGenericFormat:(NSString*)fmt,...;

@end
