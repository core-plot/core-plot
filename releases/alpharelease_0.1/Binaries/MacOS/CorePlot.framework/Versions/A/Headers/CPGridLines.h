#import <Foundation/Foundation.h>
#import "CPLayer.h"

@class CPAxis;

@interface CPGridLines : CPLayer {
@private
	__weak CPAxis *axis;
	BOOL major;
}

@property (nonatomic, readwrite, assign) __weak CPAxis *axis;
@property (nonatomic, readwrite) BOOL major;

@end
