
#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

/// @file

/**
 *	@brief Enumeration of numeric types
 **/
typedef enum  _CPNumericType {
    CPNumericTypeInteger,	///< Integer
    CPNumericTypeFloat,		///< Float
    CPNumericTypeDouble		///< Double
} CPNumericType;

/**
 *	@brief Enumeration of error bar types
 **/
typedef enum _CPErrorBarType {
    CPErrorBarTypeCustom,			///< Custom error bars
    CPErrorBarTypeConstantRatio,	///< Constant ratio error bars
    CPErrorBarTypeConstantValue		///< Constant value error bars
} CPErrorBarType;

/**
 *	@brief Enumeration of axis scale types
 **/
typedef enum _CPScaleType {
    CPScaleTypeLinear,		///< Linear axis scale
    CPScaleTypeLogN,		///< Log base <i>n</i> axis scale
    CPScaleTypeLog10,		///< Log base 10 axis scale
    CPScaleTypeAngular,		///< Angular axis scale
	CPScaleTypeDateTime,	///< Date/time axis scale
	CPScaleTypeCategory		///< Category axis scale
} CPScaleType;

/**
 *	@brief Enumeration of axis coordinates
 **/
typedef enum _CPCoordinate {
    CPCoordinateX = 0,	///< X axis
    CPCoordinateY = 1,	///< Y axis
    CPCoordinateZ = 2	///< Z axis
} CPCoordinate;

/**
 *	@brief RGBA color for gradients
 **/
typedef struct _CPRGBAColor {
	CGFloat red;	///< The red component (0 ≤ red ≤ 1).
	CGFloat green;	///< The green component (0 ≤ green ≤ 1).
	CGFloat blue;	///< The blue component (0 ≤ blue ≤ 1).
	CGFloat alpha;	///< The alpha component (0 ≤ alpha ≤ 1).
} CPRGBAColor;

/**
 *	@brief Enumeration of label positioning offset directions
 **/
typedef enum _CPSign {
	CPSignNone     =  0, ///< No offset
	CPSignPositive = +1, ///< Positive offset
	CPSignNegative = -1	 ///< Negative offset
} CPSign;

/**
 *  @brief Enumeration of constraint types used in spring and strut model.
 **/
typedef enum _CPConstraint {
    CPConstraintNone,    ///< No constraint. Free movement, equivalent to "spring".
    CPConstraintFixed	 ///< Distance is fixed. Equivalent to a "strut".
} CPConstraint;

/**
 *	@brief Constraints for a relative position.
 **/
typedef struct _CPConstraints {
	CPConstraint lower;	///< The constraint on the lower range.
	CPConstraint upper;	///< The constraint on the upper range.
} CPConstraints;

/**
 *	@brief Locations around the edge of a rectangle.
 **/
typedef enum _CPRectAnchor {
	CPRectAnchorBottomLeft,		///< The bottom left corner
	CPRectAnchorBottom,			///< The bottom center
	CPRectAnchorBottomRight,	///< The bottom right corner
	CPRectAnchorLeft,			///< The left middle
	CPRectAnchorRight,			///< The right middle
	CPRectAnchorTopLeft,		///< The top left corner
	CPRectAnchorTop,			///< The top center
    CPRectAnchorTopRight,		///< The top right
    CPRectAnchorCenter			///< The center of the rect
} CPRectAnchor;

/**
 *	@brief Label and constraint alignment constants.
 **/
typedef enum _CPAlignment {
    CPAlignmentLeft,			///< Align horizontally to the left side.
    CPAlignmentCenter,			///< Align horizontally to the center.
    CPAlignmentRight,			///< Align horizontally to the right side.
    CPAlignmentTop,				///< Align vertically to the top.
    CPAlignmentMiddle,			///< Align vertically to the middle.
    CPAlignmentBottom			///< Align vertically to the bottom.
} CPAlignment;

/// @name Default Z Positions
/// @{
extern const CGFloat CPDefaultZPositionAxis;
extern const CGFloat CPDefaultZPositionAxisSet;
extern const CGFloat CPDefaultZPositionGraph;
extern const CGFloat CPDefaultZPositionPlot;
extern const CGFloat CPDefaultZPositionPlotArea; 
extern const CGFloat CPDefaultZPositionPlotAreaFrame; 
extern const CGFloat CPDefaultZPositionPlotGroup; 
/// @}

