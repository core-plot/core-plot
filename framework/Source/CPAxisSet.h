#import <Foundation/Foundation.h>
#import "CPLayer.h"

@interface CPAxisSet : CPLayer {
	@private
    NSArray *axes;
}

@property (nonatomic, readwrite, retain) NSArray *axes;

-(void)relabelAxes;

@end
