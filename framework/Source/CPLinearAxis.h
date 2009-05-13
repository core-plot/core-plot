

#import <Foundation/Foundation.h>
#import "CPAxis.h"

@interface CPLinearAxis : CPAxis {
	NSInteger independentRangeIndex;
	NSDecimalNumber* independentValue; 
}

@property (nonatomic, readwrite, assign) NSInteger independentRangeIndex;
@property (nonatomic, readwrite, retain) NSDecimalNumber* independentValue; 

@end
