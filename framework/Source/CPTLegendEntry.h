#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

@class CPTPlot;
@class CPTTextStyle;

@interface CPTLegendEntry : NSObject <NSCoding> {   
	@private
	__weak CPTPlot *plot;
	NSUInteger index;
	NSUInteger row;
	NSUInteger column;
	CPTTextStyle *textStyle;
}

/// @name Plot Info
/// @{
@property (nonatomic, readwrite, assign) __weak CPTPlot *plot;
@property (nonatomic, readwrite, assign) NSUInteger index;
///	@}

/// @name Formatting
/// @{
@property (nonatomic, readwrite, retain) CPTTextStyle *textStyle;
///	@}

/// @name Layout
/// @{
@property (nonatomic, readwrite, assign) NSUInteger row;
@property (nonatomic, readwrite, assign) NSUInteger column;
@property (nonatomic, readonly, assign) CGSize titleSize;
///	@}

/// @name Drawing
/// @{
-(void)drawTitleInRect:(CGRect)rect inContext:(CGContextRef)context;
///	@}

@end
