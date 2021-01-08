//
//  CPTVectorFieldPlot.h
//  CorePlot Mac
//
//  Created by Steve Wainwright on 13/12/2020.
//

#import "CPTDefinitions.h"
#import "CPTLineStyle.h"
#import "CPTPlot.h"

@class CPTFill;
@class CPTVectorFieldPlot;

/**
 *  @brief Vector Field plot bindings.
 **/
typedef NSString *CPTVectorFieldPlotBinding cpt_swift_struct;

/// @ingroup plotBindingsVectorFieldPlot
/// @{
extern CPTVectorFieldPlotBinding __nonnull const CPTVectorFieldPlotBindingXValues;
extern CPTVectorFieldPlotBinding __nonnull const CPTVectorFieldPlotBindingYValues;
extern CPTVectorFieldPlotBinding __nonnull const CPTVectorFieldPlotBindingVectorLengthValues;
extern CPTVectorFieldPlotBinding __nonnull const CPTVectorFieldPlotBindingVectorDirectionValues;
extern CPTVectorFieldPlotBinding __nonnull const CPTVectorFieldPlotBindingVectorLineStyles;
/// @}

/**
 *  @brief Enumeration of VectorField plot data source field types
 **/
typedef NS_ENUM (NSInteger, CPTVectorFieldPlotField) {
    CPTVectorFieldPlotFieldX,     ///< X values.
    CPTVectorFieldPlotFieldY,     ///< Y values.
    CPTVectorFieldPlotFieldVectorLength,  ///< vector length values.
    CPTVectorFieldPlotFieldVectorDirection,   ///< vector direction values.
};

/**
 *  @brief vector field arrow  types.
 **/
typedef NS_ENUM (NSInteger, CPTVectorFieldArrowType) {
    CPTVectorFieldArrowTypeNone,  ///< No arrow.
    CPTVectorFieldArrowTypeOpen,  ///< Open arrow .
    CPTVectorFieldArrowTypeSolid, ///< Solid arrow .
    CPTVectorFieldArrowTypeSwept ///< Swept arrow.
};

#pragma mark -

/**
 *  @brief A Vector Field plot data source.
 **/
@protocol CPTVectorFieldPlotDataSource<CPTPlotDataSource>
@optional

/// @name Vector  Style
/// @{

/** @brief @optional Gets a range of vector line styles for the given range plot.
 *  @param plot The Vector Field plot.
 *  @param indexRange The range of the data indexes of interest.
 *  @return An array of line styles.
 **/
-(nullable CPTLineStyleArray *)lineStylesForVectorFieldPlot:(nonnull CPTVectorFieldPlot *)plot recordIndexRange:(NSRange)indexRange;

/** @brief @optional Gets a vector line style for the given range plot.
 *  This method will not be called if
 *  @link CPTVectorFieldPlotDataSource::lineStylesForVectorFieldPlot:recordIndexRange: -lineStylesForVectorFieldPlot:recordIndexRange: @endlink
 *  is also implemented in the datasource.
 *  @param plot The range plot.
 *  @param idx The data index of interest.
 *  @return The vector line style for the vector with the given index. If the data source returns @nil, the default line style is used.
 *  If the data source returns an NSNull object, no line is drawn.
 **/
-(nullable CPTLineStyle *)lineStyleForVectorFieldPlot:(nonnull CPTVectorFieldPlot *)plot recordIndex:(NSUInteger)idx;

/// @}

@end

#pragma mark -

/**
 *  @brief Vector Field plot delegate.
 **/
@protocol CPTVectorFieldPlotDelegate<CPTPlotDelegate>

@optional

/// @name Point Selection
/// @{

/** @brief @optional Informs the delegate that a vector  base point
 *  @if MacOnly was both pressed and released. @endif
 *  @if iOSOnly received both the touch down and up events. @endif
 *  @param plot The Vector Field plot.
 *  @param idx The index of the
 *  @if MacOnly clicked bar. @endif
 *  @if iOSOnly touched bar. @endif
 **/
-(void)vectorFieldPlot:(nonnull CPTVectorFieldPlot *)plot vectorFieldWasSelectedAtRecordIndex:(NSUInteger)idx;

/** @brief @optional Informs the delegate that  a vector base point
 *  @if MacOnly was both pressed and released. @endif
 *  @if iOSOnly received both the touch down and up events. @endif
 *  @param plot The Vector Field plot.
 *  @param idx The index of the
 *  @if MacOnly clicked bar. @endif
 *  @if iOSOnly touched bar. @endif
 *  @param event The event that triggered the selection.
 **/
-(void)vectorFieldPlot:(nonnull CPTVectorFieldPlot *)plot vectorFieldWasSelectedAtRecordIndex:(NSUInteger)idx withEvent:(nonnull CPTNativeEvent *)event;

/** @brief @optional Informs the delegate that a vector base point
 *  @if MacOnly was pressed. @endif
 *  @if iOSOnly touch started. @endif
 *  @param plot The Vector Field plot.
 *  @param idx The index of the
 *  @if MacOnly clicked bar. @endif
 *  @if iOSOnly touched bar. @endif
 **/
-(void)vectorFieldPlot:(nonnull CPTVectorFieldPlot *)plot vectorFieldTouchDownAtRecordIndex:(NSUInteger)idx;

/** @brief @optional Informs the delegate that a vector base point
 *  @if MacOnly was pressed. @endif
 *  @if iOSOnly touch started. @endif
 *  @param plot The Vector Field plot.
 *  @param idx The index of the
 *  @if MacOnly clicked bar. @endif
 *  @if iOSOnly touched bar. @endif
 *  @param event The event that triggered the selection.
 **/
-(void)vectorFieldPlot:(nonnull CPTVectorFieldPlot *)plot vectorFieldTouchDownAtRecordIndex:(NSUInteger)idx withEvent:(nonnull CPTNativeEvent *)event;

/** @brief @optional Informs the delegate that a vector base point
 *  @if MacOnly was released. @endif
 *  @if iOSOnly touch ended. @endif
 *  @param plot The Vector Field plot.
 *  @param idx The index of the
 *  @if MacOnly clicked bar. @endif
 *  @if iOSOnly touched bar. @endif
 **/
-(void)vectorFieldPlot:(nonnull CPTVectorFieldPlot *)plot vectorFieldTouchUpAtRecordIndex:(NSUInteger)idx;

/** @brief @optional Informs the delegate that a vector base point
 *  @if MacOnly was released. @endif
 *  @if iOSOnly touch ended. @endif
 *  @param plot The Vector Field plot.
 *  @param idx The index of the
 *  @if MacOnly clicked bar. @endif
 *  @if iOSOnly touched bar. @endif
 *  @param event The event that triggered the selection.
 **/
-(void)vectorFieldPlot:(nonnull CPTVectorFieldPlot *)plot vectorFieldTouchUpAtRecordIndex:(NSUInteger)idx withEvent:(nonnull CPTNativeEvent *)event;

/// @}

@end

#pragma mark -

@interface CPTVectorFieldPlot : CPTPlot

/// @name Vector LineStyles Data Source
/// @{
@property (nonatomic, readwrite, cpt_weak_property, nullable) id<CPTPlotDataSource> vectorLineStylesDataSource;
/// @}

/// @name Appearance
/// @{
@property (nonatomic, readwrite, assign) CGFloat normalisedVectorLength;
@property (nonatomic, readwrite, assign) CGFloat maxVectorLength;
@property (nonatomic, readwrite, copy, nullable) CPTLineStyle *vectorLineStyle;
@property (nonatomic, readwrite, assign) CGSize arrowSize;
@property (nonatomic, readwrite, assign) CPTVectorFieldArrowType arrowType;
@property (nonatomic, readwrite, strong, nullable) CPTFill *arrowFill;
@property (nonatomic, readwrite, assign) BOOL usesEvenOddClipRule;

/// @}

/// @name Vector Style
/// @{
-(void)reloadVectorLineStyles;
-(void)reloadVectorLineStylesInIndexRange:(NSRange)indexRange;
/// @}

@end
