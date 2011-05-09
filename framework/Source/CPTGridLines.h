#import <Foundation/Foundation.h>
#import "CPTLayer.h"

@class CPTAxis;

@interface CPTGridLines : CPTLayer {
@private
	__weak CPTAxis *axis;
	BOOL major;
}

@property (nonatomic, readwrite, assign) __weak CPTAxis *axis;
@property (nonatomic, readwrite) BOOL major;

@end
