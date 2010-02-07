#import <Foundation/Foundation.h>
#import "CPLayer.h"

@class CPLineStyle;

@interface CPPlotFrame : CPLayer {
@private
	CPLineStyle *borderLineStyle;
}

@property (nonatomic, readwrite, copy) CPLineStyle *borderLineStyle;

@end
