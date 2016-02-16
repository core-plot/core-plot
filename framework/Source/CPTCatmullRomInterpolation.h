#import <Foundation/Foundation.h>

typedef NS_ENUM (NSInteger, CPTCatmullRomType) {
    CPTCatmullRomTypeUniform,
    CPTCatmullRomTypeChordal,
    CPTCatmullRomTypeCentripetal
};

@interface CPTCatmullRomInterpolation : NSObject

+(UIBezierPath *)bezierPathFromPoints:(NSArray *)points withGranularity:(NSInteger)granularity;

@end
