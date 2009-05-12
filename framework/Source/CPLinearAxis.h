

#import <Foundation/Foundation.h>
#import "CPAxis.h"

@interface CPLinearAxis : CPAxis {
	CGFloat angle;
}

@property (nonatomic, readwrite, assign) CGFloat angle;

@end
