
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
	CPSignNone,		///< No offset
	CPSignPositive,	///< Positive offset
	CPSignNegative	///< Negative offset
} CPSign;

/// @name Default Z Positions
/// @{
extern const CGFloat CPDefaultZPositionAxis;
extern const CGFloat CPDefaultZPositionAxisSet;
extern const CGFloat CPDefaultZPositionGraph;
extern const CGFloat CPDefaultZPositionPlot;
extern const CGFloat CPDefaultZPositionPlotArea; 
extern const CGFloat CPDefaultZPositionPlotGroup; 
extern const CGFloat CPDefaultZPositionPlotSpace;
/// @}

