#import "CPPlatformSpecificCategories.h"

@implementation CPLayer (CPPlatformSpecificLayerExtensions)

-(CPNativeImage *)imageOfLayer 
{
    UIGraphicsBeginImageContext(self.bounds.size);
	
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextSaveGState(context);
	CGContextSetAllowsAntialiasing(context, true);
	
	CGContextTranslateCTM(context, 0.0f, self.bounds.size.height);
	CGContextScaleCTM(context, 1.0f, -1.0f);
	
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