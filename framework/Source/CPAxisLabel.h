
#import <Foundation/Foundation.h>
#import "CPLayer.h"
#import "CPDefinitions.h"

@class CPTextStyle;

@interface CPAxisLabel : CPLayer {
    NSString *text;
	CPTextStyle *textStyle;
    CPLayer *contentLayer;
    CGFloat offset;
    NSDecimal tickLocation;	// TODO: NSDecimal instance variables in CALayers cause an unhandled property type encoding error
}

@property (nonatomic, readonly, copy) NSString *text;
@property (nonatomic, readwrite, copy) CPTextStyle *textStyle;
@property (nonatomic, readonly, retain) CPLayer *contentLayer;
@property (nonatomic, readwrite, assign) CGFloat offset;
@property (nonatomic, readwrite) NSDecimal tickLocation;

/// @name Initialization
/// @{
-(id)initWithText:(NSString *)newText textStyle:(CPTextStyle *)style;
-(id)initWithContentLayer:(CPLayer *)layer;
///	@}

/// @name Layout
/// @{
-(void)positionRelativeToViewPoint:(CGPoint)point forCoordinate:(CPCoordinate)coordinate inDirection:(CPSign)direction;
-(void)positionBetweenViewPoint:(CGPoint)firstPoint andViewPoint:(CGPoint)secondPoint forCoordinate:(CPCoordinate)coordinate inDirection:(CPSign)direction;
///	@}

@end
