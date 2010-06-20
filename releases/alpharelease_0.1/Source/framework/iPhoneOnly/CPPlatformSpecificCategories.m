#import "CPPlatformSpecificCategories.h"

@implementation CPColor(CPPlatformSpecificColorExtensions)

/**	@property uiColor
 *	@brief Gets the color value as a UIColor.
 **/
@dynamic uiColor;

-(UIColor *)uiColor
{
	return [UIColor colorWithCGColor:self.cgColor];
}

@end

#pragma mark -

@implementation CPLayer(CPPlatformSpecificLayerExtensions)

-(CPNativeImage *)imageOfLayer 
{
    UIGraphicsBeginImageContext(self.bounds.size);
	
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextSaveGState(context);
	CGContextSetAllowsAntialiasing(context, true);
	
	CGContextTranslateCTM(context, 0.0, self.bounds.size.height);
	CGContextScaleCTM(context, 1.0, -1.0);
	
	[self layoutAndRenderInContext:context];
	CPNativeImage *layerImage = UIGraphicsGetImageFromCurrentImageContext();
	CGContextSetAllowsAntialiasing(context, false);
	
	CGContextRestoreGState(context);
	UIGraphicsEndImageContext();
    
    return layerImage;
}

@end

#pragma mark -

@implementation NSNumber(CPPlatformSpecificNumberExtensions)

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
