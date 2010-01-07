#import "CPPlatformSpecificCategories.h"

/**	@brief Platform-specific extensions to CPColor.
 **/
@implementation CPColor (CPPlatformSpecificColorExtensions)

/// @addtogroup CPColor
/// @{

/**	@property uiColor
 *	@brief Gets the color value as a UIColor.
 **/
-(UIColor *)uiColor
{
	return [UIColor colorWithCGColor:self.cgColor];
}

///	@}

@end
@implementation CPLayer (CPPlatformSpecificLayerExtensions)

-(CPNativeImage *)imageOfLayer 
{
    UIGraphicsBeginImageContext(self.bounds.size);
	
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextSaveGState(context);
	CGContextSetAllowsAntialiasing(context, true);
	
	CGContextTranslateCTM(context, 0.0, self.bounds.size.height);
	CGContextScaleCTM(context, 1.0, -1.0);
	
	[self recursivelyRenderInContext:context];
	CPNativeImage *layerImage = UIGraphicsGetImageFromCurrentImageContext();
	CGContextSetAllowsAntialiasing(context, false);
	
	CGContextRestoreGState(context);
	UIGraphicsEndImageContext();
    
    return layerImage;
}

@end

@implementation NSNumber (CPPlatformSpecificExtensions)

-(BOOL)isLessThan:(NSNumber *)other 
{
    return ( [self compare:other] == NSOrderedAscending );
}

-(BOOL)isLessThanOrEqualTo:(NSNumber *)other 
{
    return ( [self compare:other] == NSOrderedSame || [self compare:other] == NSOrderedAscending );
}

-(BOOL)isGreaterThan:(NSNumber *)other 
{
    return ( [self compare:other] == NSOrderedDescending );
}

-(BOOL)isGreaterThanOrEqualTo:(NSNumber *)other 
{
    return ( [self compare:other] == NSOrderedSame || [self compare:other] == NSOrderedDescending );
}

@end