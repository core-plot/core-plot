#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

@class CPColor;
@class CPLineStyle;

/**	@brief A line style delegate.
 **/
@protocol CPLineStyleDelegate <NSObject>

/**	@brief This method is called when the line style changes.
 *	@param lineStyle The line style that changed.
 **/
-(void)lineStyleDidChange:(CPLineStyle *)lineStyle; 

@end

@interface CPLineStyle : NSObject <NSCopying> {
@private
	__weak id <CPLineStyleDelegate> delegate;
	CGLineCap lineCap;
//	CGLineDash lineDash; // We should make a struct to keep this information
	CGLineJoin lineJoin;
	CGFloat miterLimit;
	CGFloat lineWidth;
	NSArray *dashPattern;
	CGFloat patternPhase;
//	StrokePattern; // We should make a struct to keep this information
    CPColor *lineColor;
}

@property (nonatomic, readwrite, assign) __weak id <CPLineStyleDelegate> delegate; 
@property (nonatomic, readwrite, assign) CGLineCap lineCap;
@property (nonatomic, readwrite, assign) CGLineJoin lineJoin;
@property (nonatomic, readwrite, assign) CGFloat miterLimit;
@property (nonatomic, readwrite, assign) CGFloat lineWidth;
@property (nonatomic, readwrite, retain) NSArray *dashPattern;
@property (nonatomic, readwrite, assign) CGFloat patternPhase;
@property (nonatomic, readwrite, retain) CPColor *lineColor;

/// @name Factory Methods
/// @{
+(CPLineStyle *)lineStyle;
///	@}

/// @name Drawing
/// @{
-(void)setLineStyleInContext:(CGContextRef)theContext;
///	@}

@end
