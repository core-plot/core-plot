
// Based on CTGradient (http://blog.oofn.net/2006/01/15/gradients-in-cocoa/)
// CTGradient is in public domain (Thanks Chad Weider!)

#import <Foundation/Foundation.h>
#import "CPDefinitions.h"

typedef struct _CPGradientElement {
	CPRGBColor color;
	float position;
	
	struct _CPGradientElement *nextElement;
} CPGradientElement;

typedef enum _CPBlendingMode {
	CPLinearBlendingMode,
	CPChromaticBlendingMode,
	CPInverseChromaticBlendingMode
} CPGradientBlendingMode;


@interface CPGradient : NSObject <NSCopying, NSCoding>  {
	CPGradientElement *elementList;
	CPGradientBlendingMode blendingMode;
	CGFunctionRef gradientFunction;
    CGFloat angle;
}

@property (assign) CGFloat angle;

+(id)gradientWithBeginningColor:(CGColorRef)begin endingColor:(CGColorRef)end;

+(id)aquaSelectedGradient;
+(id)aquaNormalGradient;
+(id)aquaPressedGradient;

+(id)unifiedSelectedGradient;
+(id)unifiedNormalGradient;
+(id)unifiedPressedGradient;
+(id)unifiedDarkGradient;

+(id)sourceListSelectedGradient;
+(id)sourceListUnselectedGradient;

+(id)rainbowGradient;
+(id)hydrogenSpectrumGradient;

-(CPGradient *)gradientWithAlphaComponent:(float)alpha;

-(CPGradient *)addColorStop:(CGColorRef)color atPosition:(float)position;	// positions given relative to [0,1]
-(CPGradient *)removeColorStopAtIndex:(NSUInteger)index;
-(CPGradient *)removeColorStopAtPosition:(float)position;

-(CPGradientBlendingMode)blendingMode;
-(CGColorRef)colorStopAtIndex:(NSUInteger)index;
-(CGColorRef)colorAtPosition:(float)position;


-(void)drawSwatchInRect:(CGRect)rect inContext:(CGContextRef)context;
-(void)fillRect:(CGRect)rect inContext:(CGContextRef)context;	// fills rect with axial gradient
                                                                                    // angle in degrees
-(void)radialFillRect:(CGRect)rect inContext:(CGContextRef)context;		// fills rect with radial gradient
                                                                        // gradient from center outwards

@end
