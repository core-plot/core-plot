#import "NSExceptionExtensions.h"

@implementation NSException(CPExtensions)

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
