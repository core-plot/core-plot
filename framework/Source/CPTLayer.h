#import "CPTDefinitions.h"
#import "CPTResponder.h"
#import <QuartzCore/QuartzCore.h>

/// @file

@class CPTGraph;
@class CPTShadow;

/// @name Layout
/// @{

/** @brief Notification sent by all layers when the layer @link CALayer::bounds bounds @endlink change.
 *  @ingroup notification
 **/
extern NSString *__nonnull const CPTLayerBoundsDidChangeNotification;

/// @}

/**
 *  @brief An array of CALayer objects.
 **/
typedef NSArray<CALayer *> CPTSublayerArray;

/**
 *  @brief A mutable array of CALayer objects.
 **/
typedef NSMutableArray<CALayer *> CPTMutableSublayerArray;

/**
 *  @brief A set of CALayer objects.
 **/
typedef NSSet<CALayer *> CPTSublayerSet;

/**
 *  @brief A mutable set of CALayer objects.
 **/
typedef NSMutableSet<CALayer *> CPTMutableSublayerSet;

@interface CPTLayer : CALayer<CPTResponder, NSSecureCoding>

/// @name Graph
/// @{
@property (nonatomic, readwrite, cpt_weak_property, nullable) CPTGraph *graph;
/// @}

/// @name Padding
/// @{
@property (nonatomic, readwrite) CGFloat paddingLeft;
@property (nonatomic, readwrite) CGFloat paddingTop;
@property (nonatomic, readwrite) CGFloat paddingRight;
@property (nonatomic, readwrite) CGFloat paddingBottom;
/// @}

/// @name Drawing
/// @{
@property (readwrite) CGFloat contentsScale;
@property (nonatomic, readonly) BOOL useFastRendering;
@property (nonatomic, readwrite, copy, nullable) CPTShadow *shadow;
@property (nonatomic, readonly) CGSize shadowMargin;
/// @}

/// @name Masking
/// @{
@property (nonatomic, readwrite, assign) BOOL masksToBorder;
@property (nonatomic, readwrite, assign, nullable)  CGPathRef outerBorderPath;
@property (nonatomic, readwrite, assign, nullable)  CGPathRef innerBorderPath;
@property (nonatomic, readonly, nullable)  CGPathRef maskingPath;
@property (nonatomic, readonly, nullable)  CGPathRef sublayerMaskingPath;
/// @}

/// @name Identification
/// @{
@property (nonatomic, readwrite, copy, nullable) id<NSCopying, NSCoding, NSObject> identifier;
/// @}

/// @name Layout
/// @{
@property (nonatomic, readonly, nullable) CPTSublayerSet *sublayersExcludedFromAutomaticLayout;
/// @}

/// @name Initialization
/// @{
-(nonnull instancetype)initWithFrame:(CGRect)newFrame NS_DESIGNATED_INITIALIZER;
-(nullable instancetype)initWithCoder:(nonnull NSCoder *)coder NS_DESIGNATED_INITIALIZER;
-(nonnull instancetype)initWithLayer:(nonnull id)layer NS_DESIGNATED_INITIALIZER;
/// @}

/// @name Drawing
/// @{
-(void)renderAsVectorInContext:(nonnull CGContextRef)context;
-(void)recursivelyRenderInContext:(nonnull CGContextRef)context;
-(void)layoutAndRenderInContext:(nonnull CGContextRef)context;
-(nonnull NSData *)dataForPDFRepresentationOfLayer;
/// @}

/// @name Masking
/// @{
-(void)applySublayerMaskToContext:(nonnull CGContextRef)context forSublayer:(nonnull CPTLayer *)sublayer withOffset:(CGPoint)offset;
-(void)applyMaskToContext:(nonnull CGContextRef)context;
/// @}

/// @name Layout
/// @{
-(void)pixelAlign;
-(void)sublayerMarginLeft:(nonnull CGFloat *)left top:(nonnull CGFloat *)top right:(nonnull CGFloat *)right bottom:(nonnull CGFloat *)bottom;
/// @}

/// @name Information
/// @{
-(void)logLayers;
/// @}

@end
