#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import "CPTResponder.h"

@class CPTGraph;
@class CPTShadow;

@interface CPTLayer : CALayer <CPTResponder> {
	@private
	CGFloat paddingLeft;
	CGFloat paddingTop;
	CGFloat paddingRight;
	CGFloat paddingBottom;
	BOOL masksToBorder;
	CPTShadow *shadow;
	BOOL renderingRecursively;
	BOOL useFastRendering;
    __weak CPTGraph *graph;
	CGPathRef outerBorderPath;
	CGPathRef innerBorderPath;
}

/// @name Graph
/// @{
@property (nonatomic, readwrite, assign) __weak CPTGraph *graph;
/// @}

/// @name Padding
/// @{
@property (nonatomic, readwrite) CGFloat paddingLeft;
@property (nonatomic, readwrite) CGFloat paddingTop;
@property (nonatomic, readwrite) CGFloat paddingRight;
@property (nonatomic, readwrite) CGFloat paddingBottom;
///	@}

/// @name Drawing
/// @{
@property (readwrite, assign) CGFloat contentsScale;
@property (nonatomic, readonly, assign) BOOL useFastRendering;
@property (nonatomic, readwrite, copy) CPTShadow *shadow;
///	@}

/// @name Masking
/// @{
@property (nonatomic, readwrite, assign) BOOL masksToBorder;
@property (nonatomic, readwrite, assign) CGPathRef outerBorderPath;
@property (nonatomic, readwrite, assign) CGPathRef innerBorderPath;
@property (nonatomic, readonly, assign) CGPathRef maskingPath;
@property (nonatomic, readonly, assign) CGPathRef sublayerMaskingPath;
///	@}

/// @name Layout
/// @{
@property (readonly) NSSet *sublayersExcludedFromAutomaticLayout;
///	@}

/// @name Initialization
/// @{
-(id)initWithFrame:(CGRect)newFrame;
///	@}

/// @name Drawing
/// @{
-(void)renderAsVectorInContext:(CGContextRef)context;
-(void)recursivelyRenderInContext:(CGContextRef)context;
-(void)layoutAndRenderInContext:(CGContextRef)context;
-(NSData *)dataForPDFRepresentationOfLayer;
///	@}

/// @name Masking
/// @{
-(void)applySublayerMaskToContext:(CGContextRef)context forSublayer:(CPTLayer *)sublayer withOffset:(CGPoint)offset;
-(void)applyMaskToContext:(CGContextRef)context;
///	@}

/// @name Layout
/// @{
-(void)pixelAlign;
-(void)sublayerMarginLeft:(CGFloat *)left top:(CGFloat *)top right:(CGFloat *)right bottom:(CGFloat *)bottom;
///	@}

@end
