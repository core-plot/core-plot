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
