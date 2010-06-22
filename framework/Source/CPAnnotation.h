
#import <Foundation/Foundation.h>


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

@end


@interface CPAnnotation (Abstract)

-(void)updateContentLayer;

@end
