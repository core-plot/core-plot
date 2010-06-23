
#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

@class CPAnnotationLayer;
@class CPLayer;


@interface CPAnnotation : NSObject {
	CPAnnotationLayer *annotationLayer;
	CPLayer *contentLayer;
    CGPoint displacement;
}

@property (nonatomic, readwrite, retain) CPLayer *contentLayer;
@property (nonatomic, readwrite, assign) CPAnnotationLayer *annotationLayer;
@property (nonatomic, readwrite, assign) CGPoint displacement;

-(void)positionContentLayer;

@end
