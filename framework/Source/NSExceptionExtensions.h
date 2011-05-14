#import <Foundation/Foundation.h>

/**	@category NSException(CPTExtensions)
 *	@brief Core Plot extensions to NSException.
 **/
@interface NSException(CPTExtensions)

+(void)raiseGenericFormat:(NSString*)fmt,...;

@end
