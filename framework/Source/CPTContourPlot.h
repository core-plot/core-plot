//
//  CPTContourPlot.h
//  CorePlot Mac
//
//  Created by Steve Wainwright on 19/12/2020.
//

#import "CPTDefinitions.h"
#import "CPTLineStyle.h"
#import "CPTFill.h"
#import "CPTPlot.h"
#import "CPTFieldFunctionDataSource.h"

@class CPTFill;
@class CPTContourPlot;


/**
 *  @brief Contour plot bindings.
 **/
typedef NSString *CPTContourPlotBinding cpt_swift_struct;

/// @ingroup plotBindingsContourPlot
/// @{
extern CPTContourPlotBinding __nonnull const CPTContourPlotBindingXValues;
extern CPTContourPlotBinding __nonnull const CPTContourPlotBindingYValues;
extern CPTContourPlotBinding __nonnull const CPTContourPlotBindingFunctionValues;
/// @}

/**
 *  @brief Enumeration of Contourplot data source field types
 **/
typedef NS_ENUM (NSInteger, CPTContourPlotField) {
    CPTContourPlotFieldX,     ///< X values.
    CPTContourPlotFieldY,     ///< Y values.
    CPTContourPlotFieldFunctionValue,  ///< function value  values.
};

/**
 *  @brief Enumeration of Contour plot interpolation algorithms
 **/
typedef NS_ENUM (NSInteger, CPTContourPlotInterpolation) {
    CPTContourPlotInterpolationLinear,    ///< Linear interpolation.
    CPTContourPlotInterpolationCurved     ///< Curved interpolation.
};

/**
 *  @brief Enumration of Contour plot curved interpolation style options
 **/
typedef NS_ENUM (NSInteger, CPTContourPlotCurvedInterpolationOption) {
    CPTContourPlotCurvedInterpolationNormal,                ///< Standard Curved Interpolation (Bezier Curve)
    CPTContourPlotCurvedInterpolationCatmullRomUniform,     ///< Catmull-Rom Spline Interpolation with alpha = @num{0.0}.
    CPTContourPlotCurvedInterpolationCatmullRomCentripetal, ///< Catmull-Rom Spline Interpolation with alpha = @num{0.5}.
    CPTContourPlotCurvedInterpolationCatmullRomChordal,     ///< Catmull-Rom Spline Interpolation with alpha = @num{1.0}.
    CPTContourPlotCurvedInterpolationCatmullCustomAlpha,    ///< Catmull-Rom Spline Interpolation with a custom alpha value.
    CPTContourPlotCurvedInterpolationHermiteCubic           ///< Hermite Cubic Spline Interpolation
};

double TestFunction(double x,double y);



#pragma mark -

/**
 *  @brief A Contour plot data source.
 **/
@protocol CPTContourPlotDataSource<CPTPlotDataSource>

@optional

/// @}

/// @name Contour  Style
/// @{

/** @brief @optional Gets a range of contour line styles for the given range plot.
 *  @param plot The Contour plot.
 *  @param indexRange The range of the isoCurve indexes of interest.
 *  @return An array of line styles.
 **/
-(nullable CPTLineStyleArray *)lineStylesForContourPlot:(nonnull CPTContourPlot *)plot isoCurveIndexRange:(NSRange)indexRange;

/** @brief @optional Gets a contour style for the given range plot.
 *  This method will not be called if
 *  @link CPTContourPlotDataSource::lineStylesForContourPlot:recordIndexRange: -lineStylesForContourPlot:recordIndexRange: @endlink
 *  is also implemented in the datasource.
 *  @param plot The range plot.
 *  @param idx The data index of interest.
 *  @return The contour style for the isoCurve with the given index. If the data source returns @nil, the default line style is used.
 *  If the data source returns an NSNull object, no line is drawn.
 **/
-(nullable CPTLineStyle *)lineStyleForContourPlot:(nonnull CPTContourPlot *)plot isoCurveIndex:(NSUInteger)idx;

/// @}

/// @name Contour  Fill
/// @{

/** @brief @optional Gets a range of contour fills for the given range plot.
 *  @param plot The Contour plot.
 *  @param indexRange The range of the isoCurve indexes of interest.
 *  @return An array of fill styles.
 **/
-(nullable CPTFillArray *)fillsForContourPlot:(nonnull CPTContourPlot *)plot isoCurveIndexRange:(NSRange)indexRange;

/** @brief @optional Gets a contour fill for the given range plot.
 *  This method will not be called if
 *  @link CPTContourPlotDataSource::lfillForContourPlot:recordIndexRange: -fillForContourPlot:recordIndexRange: @endlink
 *  is also implemented in the datasource.
 *  @param plot The range plot.
 *  @param idx The data index of interest.
 *  @return The fill for the isoCurve with the given index. If the data source returns @nil, no fill is used.
 *  If the data source returns an NSNull object, no fill is drawn.
 **/
-(nullable CPTFill *)fillForContourPlot:(nonnull CPTContourPlot *)plot isoCurveIndex:(NSUInteger)idx;

/// @}

/// @name Isocurve Labeling 
/// @{

/** @brief @optional Gets a range of data labels for the given plot.
 *  @param plot The plot.
 *  @param indexRange The range of the data indexes of interest.
 *  @return An array of data labels.
 **/
-(nullable CPTLayerArray *)isoCurveLabelsForPlot:(nonnull CPTPlot *)plot isoCurveIndexRange:(NSRange)indexRange;

/** @brief @optional Gets a isocurve label for the given plot isocurve contour.
 *  This method will not be called if
 *  @link CPTContourPlotDataSource::isoCurveLabelsForPlot:recordIndexRange: -dataLabelsForPlot:recordIndexRange: @endlink
 *  is also implemented in the datasource.
 *  @param plot The plot.
 *  @param idx The data index of interest.
 *  @return The data label for the point with the given index.
 *  If you return @nil, the default data label will be used. If you return an instance of NSNull,
 *  no label will be shown for the index in question.
 **/
-(nullable CPTLayer *)isoCurveLabelForPlot:(nonnull CPTContourPlot *)plot isoCurveIndex:(NSUInteger)idx;

/// @}


@end

#pragma mark -

/**
 *  @brief Contour plot delegate.
 **/
@protocol CPTContourPlotDelegate<CPTPlotDelegate>

@optional

/// @name Point Selection
/// @{

/** @brief @optional Informs the delegate that a contour base point
 *  @if MacOnly was both pressed and released. @endif
 *  @if iOSOnly received both the touch down and up events. @endif
 *  @param plot The Contour plot.
 *  @param idx The index of the
 *  @if MacOnly clicked bar. @endif
 *  @if iOSOnly touched bar. @endif
 **/
-(void) contourPlot:(nonnull  CPTContourPlot *)plot contourWasSelectedAtRecordIndex:(NSUInteger)idx;

/** @brief @optional Informs the delegate that  a contour base point
 *  @if MacOnly was both pressed and released. @endif
 *  @if iOSOnly received both the touch down and up events. @endif
 *  @param plot The Contour plot.
 *  @param idx The index of the
 *  @if MacOnly clicked bar. @endif
 *  @if iOSOnly touched bar. @endif
 *  @param event The event that triggered the selection.
 **/
-(void) contourPlot:(nonnull  CPTContourPlot *)plot contourWasSelectedAtRecordIndex:(NSUInteger)idx withEvent:(nonnull CPTNativeEvent *)event;

/** @brief @optional Informs the delegate that a contour base point
 *  @if MacOnly was pressed. @endif
 *  @if iOSOnly touch started. @endif
 *  @param plot The Contour plot.
 *  @param idx The index of the
 *  @if MacOnly clicked bar. @endif
 *  @if iOSOnly touched bar. @endif
 **/
-(void) contourPlot:(nonnull  CPTContourPlot *)plot  contourTouchDownAtRecordIndex:(NSUInteger)idx;

/** @brief @optional Informs the delegate that a contour base point
 *  @if MacOnly was pressed. @endif
 *  @if iOSOnly touch started. @endif
 *  @param plot The Contour plot.
 *  @param idx The index of the
 *  @if MacOnly clicked bar. @endif
 *  @if iOSOnly touched bar. @endif
 *  @param event The event that triggered the selection.
 **/
-(void) contourPlot:(nonnull  CPTContourPlot *)plot  contourTouchDownAtRecordIndex:(NSUInteger)idx withEvent:(nonnull CPTNativeEvent *)event;

/** @brief @optional Informs the delegate that a contour base point
 *  @if MacOnly was released. @endif
 *  @if iOSOnly touch ended. @endif
 *  @param plot The Contour plot.
 *  @param idx The index of the
 *  @if MacOnly clicked bar. @endif
 *  @if iOSOnly touched bar. @endif
 **/
-(void) contourPlot:(nonnull  CPTContourPlot *)plot  contourTouchUpAtRecordIndex:(NSUInteger)idx;

/** @brief @optional Informs the delegate that a contour base point
 *  @if MacOnly was released. @endif
 *  @if iOSOnly touch ended. @endif
 *  @param plot The Contour plot.
 *  @param idx The index of the
 *  @if MacOnly clicked bar. @endif
 *  @if iOSOnly touched bar. @endif
 *  @param event The event that triggered the selection.
 **/
-(void) contourPlot:(nonnull  CPTContourPlot *)plot  contourTouchUpAtRecordIndex:(NSUInteger)idx withEvent:(nonnull CPTNativeEvent *)event;

/// @}

@end

#pragma mark -

@interface CPTContourPlot : CPTPlot

/// @name Contour Data Source
/// @{
@property (nonatomic, readwrite, strong, nullable) CPTContourDataSourceBlock dataSourceBlock;
/// @}
 
/// @name Contour Appearance Data Source
/// @{
@property (nonatomic, readwrite, cpt_weak_property, nullable) id<CPTPlotDataSource> contourAppearanceDataSource;
/// @}

/// @name Appearance
/// @{
@property (nonatomic, readwrite, copy, nullable) CPTLineStyle *isoCurveLineStyle;
@property (nonatomic, readwrite, assign) double minFunctionValue;
@property (nonatomic, readwrite, assign) double maxFunctionValue;
@property (nonatomic, readwrite, assign) NSUInteger noIsoCurves;
@property (nonatomic, readwrite, assign) CPTContourPlotInterpolation interpolation;
@property (nonatomic, readwrite, assign) CPTContourPlotCurvedInterpolationOption curvedInterpolationOption;
@property (nonatomic, readwrite, assign) CGFloat curvedInterpolationCustomAlpha;
@property (nonatomic, readwrite, assign) CGFloat isoCurvesLabelOffset;
@property (nonatomic, readwrite, assign) CGFloat isoCurvesLabelRotation;
@property (nonatomic, readwrite, copy, nullable) CPTTextStyle *isoCurvesLabelTextStyle;
@property (nonatomic, readwrite, strong, nullable) NSFormatter *isoCurvesLabelFormatter;
@property (nonatomic, readwrite, strong, nullable) CPTShadow *isoCurvesLabelShadow;
@property (nonatomic, readwrite, assign) BOOL showIsoCurvesLabels;
@property (nonatomic, readwrite, strong, nonnull) CPTMutableNumberArray *limits;       // left, right, bottom, top;
/// @}

/// @name Contour IsoCurve Styles
/// @{
-(void)reloadContourLineStyles;
-(void)reloadContourLineStylesInIsoCurveIndexRange:(NSRange)indexRange;
/// @}

/// @name Contour IsoCurve Labels
/// @{
-(void)reloadContourLabels;
-(void)reloadContourLabelsInIsoCurveIndexRange:(NSRange)indexRange;
/// @}

/// @name Accessors
/// @{
-(nullable CPTNumberArray *)getIsoCurveValues;
-(NSUInteger)getNoDataPointsUsedForIsoCurves;
/// @}

@end

