

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

#if defined(TARGET_IPHONE_SIMULATOR) || defined(TARGET_OS_IPHONE)
#import <UIKit/UIKit.h>
#define PLATFORMIMAGETYPE UIImage
#else
#define PLATFORMIMAGETYPE NSBitmapImageRep
#endif

@interface CPLayer : CALayer {

}

// Colors and colorspaces
+ (CGColorSpaceRef)createGenericRGBSpace;
+ (CGColorSpaceRef)genericRGBSpace;
+ (CGColorRef)clearColor; 
+ (CGColorRef)whiteColor; 
+ (CGColorRef)blackColor; 

// Drawing
-(void)renderAsVectorInContext:(CGContextRef)context;
-(void)recursivelyRenderInContext:(CGContextRef)context;
-(NSData *)dataForPDFRepresentationOfLayer;
-(PLATFORMIMAGETYPE *)imageOfLayer;

@end
