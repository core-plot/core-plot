#import "NSExceptionExtensions.h"

@implementation NSException(CPExtensions)

/**	@brief Raises an NSGenericException with the given format and arguments.
 *	@param fmt The format string using standard printf formatting codes.
 **/
+(void)raiseGenericFormat:(NSString*)fmt,...
{
	va_list args;
	va_start(args, fmt);
	
	[self raise:NSGenericException
		 format:fmt
	  arguments:args];
	
	va_end(args);
}

@end
