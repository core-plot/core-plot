//
// Created by Mikkel Gravgaard on 27/11/14.
// From this post: http://stackoverflow.com/questions/9489736/catmull-rom-curve-with-no-cusps-and-no-self-intersections
//

#import <Foundation/Foundation.h>

typedef enum {
    CatmullRomTypeUniform,
    CatmullRomTypeChordal,
    CatmullRomTypeCentripetal
}
CatmullRomType;

@interface CPTCatmullRomInterpolation : NSObject
+(UIBezierPath *)bezierPathFromPoints:(NSArray *)points withGranularity:(NSInteger)granularity;
@end
