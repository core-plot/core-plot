
#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

/// @file

/**
 *	@brief Enumeration of numeric types
 **/
typedef enum  _CPTNumericType {
    CPTNumericTypeInteger,	///< Integer
    CPTNumericTypeFloat,	///< Float
    CPTNumericTypeDouble	///< Double
} CPTNumericType;

/**
 *	@brief Enumeration of error bar types
 **/
typedef enum _CPTErrorBarType {
    CPTErrorBarTypeCustom,			///< Custom error bars
    CPTErrorBarTypeConstantRatio,	///< Constant ratio error bars
    CPTErrorBarTypeConstantValue	///< Constant value error bars
} CPTErrorBarType;

/**
 *	@brief Enumeration of axis scale types
 **/
typedef enum _CPTScaleType {
    CPTScaleTypeLinear,		///< Linear axis scale
    CPTScaleTypeLog,		///< Logarithmic axis scale
    CPTScaleTypeAngular,	///< Angular axis scale (not implemented)
	CPTScaleTypeDateTime,	///< Date/time axis scale (not implemented)
	CPTScaleTypeCategory	///< Category axis scale (not implemented)
} CPTScaleType;

/**
 *	@brief Enumeration of axis coordinates
 **/
typedef enum _CPTCoordinate {
    CPTCoordinateX = 0,	///< X axis
    CPTCoordinateY = 1,	///< Y axis
    CPTCoordinateZ = 2	///< Z axis
} CPTCoordinate;

/**
 *	@brief RGBA color for gradients
 **/
typedef struct _CPTRGBAColor {
	CGFloat red;	///< The red component (0 ≤ red ≤ 1).
	CGFloat green;	///< The green component (0 ≤ green ≤ 1).
	CGFloat blue;	///< The blue component (0 ≤ blue ≤ 1).
	CGFloat alpha;	///< The alpha component (0 ≤ alpha ≤ 1).
} CPTRGBAColor;

/**
 *	@brief Enumeration of label positioning offset directions
 **/
typedef enum _CPTSign {
	CPTSignNone     =  0, ///< No offset
	CPTSignPositive = +1, ///< Positive offset
	CPTSignNegative = -1	 ///< Negative offset
} CPTSign;

/**
 *	@brief Locations around the edge of a rectangle.
 **/
typedef enum _CPTRectAnchor {
	CPTRectAnchorBottomLeft,	///< The bottom left corner
	CPTRectAnchorBottom,		///< The bottom center
	CPTRectAnchorBottomRight,	///< The bottom right corner
	CPTRectAnchorLeft,			///< The left middle
	CPTRectAnchorRight,			///< The right middle
	CPTRectAnchorTopLeft,		///< The top left corner
	CPTRectAnchorTop,			///< The top center
    CPTRectAnchorTopRight,		///< The top right
    CPTRectAnchorCenter			///< The center of the rect
} CPTRectAnchor;

/**
 *	@brief Label and constraint alignment constants.
 **/
typedef enum _CPTAlignment {
    CPTAlignmentLeft,			///< Align horizontally to the left side.
    CPTAlignmentCenter,			///< Align horizontally to the center.
    CPTAlignmentRight,			///< Align horizontally to the right side.
    CPTAlignmentTop,			///< Align vertically to the top.
    CPTAlignmentMiddle,			///< Align vertically to the middle.
    CPTAlignmentBottom			///< Align vertically to the bottom.
} CPTAlignment;
