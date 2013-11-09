#import "CPTDefinitions.h"
#import "CPTResponder.h"
#import <QuartzCore/QuartzCore.h>

@class CPTGraph;
@class CPTShadow;

/// @name Layout
/// @{

/** @brief Notification sent by all layers when the layer @link CALayer::bounds bounds @endlink change.
 *  @ingroup notification
 **/
extern NSString *const CPTLayerBoundsDidChangeNotification;

/// @}

@interface CPTLayer : CALayer<CPTResponder>

/// @name Graph
/// @{
@property (nonatomic, readwrite, cpt_weak_property) __cpt_weak CPTGraph *graph;
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
@property (nonatomic, readwrite, copy) CPTShadow *shadow;
@property (nonatomic, readonly) CGSize shadowMargin;
/// @}

/// @name Masking
/// @{
@property (nonatomic, readwrite, assign) BOOL masksToBorder;
@property (nonatomic, readwrite, assign) CGPathRef outerBorderPath;
@property (nonatomic, readwrite, assign) CGPathRef innerBorderPath;
@property (nonatomic, readonly) CGPathRef maskingPath;
@property (nonatomic, readonly) CGPathRef sublayerMaskingPath;
/// @}

/// @name Identification
/// @{
@property (nonatomic, readwrite, copy) id<NSCopying, NSCoding, NSObject> identifier;
/// @}

/// @name Layout
/// @{
@property (nonatomic, readonly) NSSet *sublayersExcludedFromAutomaticLayout;
/// @}

/// @name Initialization
/// @{
-(instancetype)initWithFrame:(CGRect)newFrame;
/// @}

/// @name Drawing
/// @{
-(void)renderAsVectorInContext:(CGContextRef)context;
-(void)recursivelyRenderInContext:(CGContextRef)context;
-(void)layoutAndRenderInContext:(CGContextRef)context;
-(NSData *)dataForPDFRepresentationOfLayer;
/// @}

/// @name Masking
/// @{
-(void)applySublayerMaskToContext:(CGContextRef)context forSublayer:(CPTLayer *)sublayer withOffset:(CGPoint)offset;
-(void)applyMaskToContext:(CGContextRef)context;
/// @}

/// @name Layout
/// @{
-(void)pixelAlign;
-(void)sublayerMarginLeft:(CGFloat *)left top:(CGFloat *)top right:(CGFloat *)right bottom:(CGFloat *)bottom;
/// @}

/// @name Information
/// @{
-(void)logLayers;
/// @}

@end
