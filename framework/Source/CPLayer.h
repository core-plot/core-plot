
#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import "CPPlatformSpecificDefines.h"

// Layer layout constants
enum CPLayerAutoresizingMask
{
    kCPLayerNotSizable			= 0,
    kCPLayerMinXMargin			= 1U << 0,
    kCPLayerWidthSizable		= 1U << 1,
    kCPLayerMaxXMargin			= 1U << 2,
    kCPLayerMinYMargin			= 1U << 3,
    kCPLayerHeightSizable		= 1U << 4,
    kCPLayerMaxYMargin			= 1U << 5
};

@interface CPLayer : CALayer {
	@protected
	unsigned int layerAutoresizingMask;
	CGRect previousBounds;
}

@property (nonatomic, readwrite) unsigned int layerAutoresizingMask;

-(id)initWithFrame:(CGRect)newFrame;

// Drawing
-(void)renderAsVectorInContext:(CGContextRef)context;
-(void)recursivelyRenderInContext:(CGContextRef)context;
-(NSData *)dataForPDFRepresentationOfLayer;

// User interaction
-(void)mouseOrFingerDownAtPoint:(CGPoint)interactionPoint;
-(void)mouseOrFingerUpAtPoint:(CGPoint)interactionPoint;
-(void)mouseOrFingerDraggedAtPoint:(CGPoint)interactionPoint;
-(void)mouseOrFingerCancelled;

@end
