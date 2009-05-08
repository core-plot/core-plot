
#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import "CPLayer.h"

@class CPFill;

@interface CPPlotArea : CPLayer {
    NSMutableArray *plotSpaces;
	CPFill *fill;
}

@property (nonatomic, readwrite, retain) CPFill *fill;

@end
