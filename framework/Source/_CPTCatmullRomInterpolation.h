/// @file

/**
 *  @brief The type of knot parameterization to use for Catmull-Rom curve generation.
 *  @see See the [Wikipedia article](https://en.wikipedia.org/wiki/Centripetal_Catmull–Rom_spline) on Catmull-Rom splines for details.
 **/
typedef NS_ENUM (NSInteger, CPTCatmullRomType) {
    CPTCatmullRomTypeUniform,    ///< Uniform parameterization.
    CPTCatmullRomTypeChordal,    ///< Chordal parameterization.
    CPTCatmullRomTypeCentripetal ///< Centripetal parameterization.
};

@interface _CPTCatmullRomInterpolation : NSObject

+(nonnull CGMutablePathRef)newPathForViewPoints:(nonnull const CGPoint *)viewPoints indexRange:(NSRange)indexRange withGranularity:(NSUInteger)granularity CF_RETURNS_RETAINED;

@end
