#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import "CPLineStyle.h"
#import "CPResponder.h"
#import "CPPlatformSpecificDefines.h"

@protocol CPLayoutManager;
@class CPGraph;

@interface CPLayer : CALayer <CPResponder, CPLineStyleDelegate> {
@private
	CGFloat paddingLeft;
	CGFloat paddingTop;
	CGFloat paddingRight;
	CGFloat paddingBottom;
	BOOL masksToBorder;
	id <CPLayoutManager> layoutManager;
	BOOL renderingRecursively;
	BOOL useFastRendering;
    __weak CPGraph *graph;
	CGPathRef outerBorderPath;
	CGPathRef innerBorderPath;
}

/// @name Graph
/// @{
@property (nonatomic, readwrite, assign) __weak CPGraph *graph;
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
@property (nonatomic, readonly, assign) BOOL useFastRendering;
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
@property (readwrite, retain) id <CPLayoutManager> layoutManager;
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
-(void)applySublayerMaskToContext:(CGContextRef)context forSublayer:(CPLayer *)sublayer withOffset:(CGPoint)offset;
-(void)applyMaskToContext:(CGContextRef)context;
///	@}

/// @name Layout
/// @{
+(CGFloat)defaultZPosition;
-(void)pixelAlign;
///	@}

@end
