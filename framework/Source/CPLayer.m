

#import "CPLayer.h"


@implementation CPLayer

-(id)init
{
	if ( self = [super init] ) {
		self.needsDisplayOnBoundsChange = YES;
        self.isOpaque = NO;
	}
	return self;
}

@end
