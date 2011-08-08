#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import "CPTShadow.h"

@class CPTColor;

@interface CPTMutableShadow : CPTShadow {
}

@property (nonatomic, readwrite, assign) CGSize shadowOffset;
@property (nonatomic, readwrite, assign) CGFloat shadowBlurRadius;
@property (nonatomic, readwrite, retain) CPTColor *shadowColor;

@end
