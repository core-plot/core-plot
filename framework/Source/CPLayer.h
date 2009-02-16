

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

@interface CPLayer : CALayer {

}

// Drawing
-(void)renderAsVectorInContext:(CGContextRef)context;
-(void)recursivelyRenderInContext:(CGContextRef)context;
-(void)writePDFOfLayerToFile:(NSString *)fileName;

@end
