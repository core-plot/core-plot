
#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import "CPPlatformSpecificDefines.h"

@interface CPLayer : CALayer {

}

// Drawing
-(void)renderAsVectorInContext:(CGContextRef)context;
-(void)recursivelyRenderInContext:(CGContextRef)context;
-(NSData *)dataForPDFRepresentationOfLayer;

@end
