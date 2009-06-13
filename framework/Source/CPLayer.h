#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import "CPPlatformSpecificDefines.h"

@interface CPLayer : CALayer {
@private
    BOOL deallocating;
}

@property (nonatomic, readwrite) BOOL deallocating;

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

// Z position
+(CGFloat)defaultZPosition;

@end
