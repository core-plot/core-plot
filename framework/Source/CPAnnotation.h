
#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

///	@file

@class CPAnnotationHostLayer;
@class CPLayer;

@interface CPAnnotation : NSObject {
	CPAnnotationHostLayer *annotationHostLayer;
	CPLayer *contentLayer;
    CGPoint displacement;
}

@property (nonatomic, readwrite, retain) CPLayer *contentLayer;
@property (nonatomic, readwrite, assign) CPAnnotationHostLayer *annotationHostLayer;
@property (nonatomic, readwrite, assign) CGPoint displacement;

-(void)positionContentLayer;

@end
