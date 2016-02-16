typedef NS_ENUM (NSInteger, CPTCatmullRomType) {
    CPTCatmullRomTypeUniform,
    CPTCatmullRomTypeChordal,
    CPTCatmullRomTypeCentripetal
};

@interface _CPTCatmullRomInterpolation : NSObject

+(UIBezierPath *)bezierPathFromPoints:(NSArray *)points withGranularity:(NSInteger)granularity;

@end
