#import "CPLayer.h"

@class CPFill;

@interface CPPlotArea : CPLayer {
	CPFill *fill;
}

@property (nonatomic, readwrite, retain) CPFill *fill;

@end
