

#import "CPBarPlot.h"


@interface CPBarPlot ()

@property (nonatomic, readwrite, retain) NSMutableArray *observedObjectsForXValues;
@property (nonatomic, readwrite, retain) NSMutableArray *observedObjectsForYValues;
@property (nonatomic, readwrite, retain) NSMutableArray *keyPathsForXValues;
@property (nonatomic, readwrite, retain) NSMutableArray *keyPathsForYValues;

@end


@implementation CPBarPlot

@synthesize numericTypeForX;
@synthesize numericTypeForY;
@synthesize observedObjectsForXValues;
@synthesize observedObjectsForYValues;
@synthesize keyPathsForXValues;
@synthesize keyPathsForYValues;


-(void)dealloc
{
    self.keyPathsForXValues = nil;
    self.keyPathsForYValues = nil;
    self.observedObjectsForXValues = nil;
    self.observedObjectsForYValues = nil;
    [super dealloc];
}


-(void)bind:(NSString *)binding toObject:(id)observable withKeyPath:(NSString *)keyPath options:(NSDictionary *)options
{
    NSUInteger siblingIndex = 0;
    NSArray *keyComponents = [binding componentsSeparatedByString:@" "];
    NSString *bindingRoot = [[keyComponents subarrayWithRange:NSMakeRange(0, 2)] componentsJoinedByString:@" "];
    if ( keyComponents.count > 2 ) siblingIndex = [[keyComponents objectAtIndex:2] integerValue];
    if ([bindingRoot isEqualToString:@"X Values"]) {
        // TBW
    }
    else if ([bindingRoot isEqualToString:@"Y Values"]) {
        // TBW
    }
    else {
        [super bind:binding toObject:observable withKeyPath:keyPath options:options];
    }
    [self setNeedsDisplay];
}


-(void)unbind:(NSString *)bindingName
{
//    if ([bindingName isEqualToString:@"X Values"]) {
//		[observedObjectForXValues removeObserver:self forKeyPath:keyPathForXValues];
//        self.observedObjectForXValues = nil;
//        self.keyPathForXValues = nil;
//    }	
//    else if ([bindingName isEqualToString:@"Y Values"]) {
//		[observedObjectForYValues removeObserver:self forKeyPath:keyPathForYValues];
//        self.observedObjectForYValues = nil;
//        self.keyPathForYValues = nil;
//    }	
//	[super unbind:bindingName];
//	[self setNeedsDisplay];
}


@end
