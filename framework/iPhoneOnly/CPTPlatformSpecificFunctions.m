#import "CPTExceptions.h"
#import "CPTPlatformSpecificFunctions.h"
#import <UIKit/UIKit.h>

void CPTPushCGContext( CGContextRef newContext )
{
	UIGraphicsPushContext( newContext );
}

void CPTPopCGContext( void )
{
	UIGraphicsPopContext();
}

CGContextRef CPTGetCurrentContext( void )
{
	return UIGraphicsGetCurrentContext();
}
