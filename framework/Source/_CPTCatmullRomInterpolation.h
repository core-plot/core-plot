typedef NS_ENUM (NSInteger, CPTCatmullRomType) {
    CPTCatmullRomTypeUniform,
    CPTCatmullRomTypeChordal,
    CPTCatmullRomTypeCentripetal
};

@interface _CPTCatmullRomInterpolation : NSObject

+(nonnull CGMutablePathRef)newPathForViewPoints:(nonnull const CGPoint *)viewPoints indexRange:(NSRange)indexRange withGranularity:(NSUInteger)granularity CF_RETURNS_RETAINED;

@end
