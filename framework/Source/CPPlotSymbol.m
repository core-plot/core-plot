#import <Foundation/Foundation.h>
#import <math.h>
#import "CPLineStyle.h"
#import "CPPlotSymbol.h"
#import "CPDefinitions.h"

@implementation CPPlotSymbol

@synthesize size, symbolType, lineStyle, fillColor;

#pragma mark -
#pragma mark init/dealloc

-(id)init
{
	if ( self = [super init] ) {
		size = CGSizeMake(5.0, 5.0);
		self.symbolType = CPPlotSymbolTypeNone;
		self.lineStyle = [CPLineStyle lineStyle];
		self.fillColor = CGColorGetConstantColor(kCGColorBlack);
	}
	return self;
}

-(void)dealloc
{
	self.lineStyle = nil;
	self.fillColor = nil;
	
	[super dealloc];
}

#pragma mark -
#pragma mark Accessors

-(void)setFillColor:(CGColorRef)aFillColor
{
	if ( aFillColor != fillColor ) {
		CGColorRetain(aFillColor);
		CGColorRelease(fillColor);
		fillColor = aFillColor;
	}
}

#pragma mark -
#pragma mark Class methods

+(CPPlotSymbol *)crossPlotSymbol
{
	CPPlotSymbol *symbol = [[self alloc] init];
	symbol.symbolType = CPPlotSymbolTypeCross;
	
	return [symbol autorelease];
}

+(CPPlotSymbol *)ellipsePlotSymbol
{
	CPPlotSymbol *symbol = [[self alloc] init];
	symbol.symbolType = CPPlotSymbolTypeEllipse;
	
	return [symbol autorelease];
}

+(CPPlotSymbol *)rectanglePlotSymbol
{
	CPPlotSymbol *symbol = [[self alloc] init];
	symbol.symbolType = CPPlotSymbolTypeRectangle;
	
	return [symbol autorelease];
}

+(CPPlotSymbol *)plusPlotSymbol
{
	CPPlotSymbol *symbol = [[self alloc] init];
	symbol.symbolType = CPPlotSymbolTypePlus;
	
	return [symbol autorelease];
}

+(CPPlotSymbol *)starPlotSymbol
{
	CPPlotSymbol *symbol = [[self alloc] init];
	symbol.symbolType = CPPlotSymbolTypeStar;
	
	return [symbol autorelease];
}

+(CPPlotSymbol *)diamondPlotSymbol
{
	CPPlotSymbol *symbol = [[self alloc] init];
	symbol.symbolType = CPPlotSymbolTypeDiamond;
	
	return [symbol autorelease];
}

+(CPPlotSymbol *)trianglePlotSymbol
{
	CPPlotSymbol *symbol = [[self alloc] init];
	symbol.symbolType = CPPlotSymbolTypeTriangle;
	
	return [symbol autorelease];
}

+(CPPlotSymbol *)pentagonPlotSymbol
{
	CPPlotSymbol *symbol = [[self alloc] init];
	symbol.symbolType = CPPlotSymbolTypePentagon;
	
	return [symbol autorelease];
}

+(CPPlotSymbol *)hexagonPlotSymbol
{
	CPPlotSymbol *symbol = [[self alloc] init];
	symbol.symbolType = CPPlotSymbolTypeHexagon;
	
	return [symbol autorelease];
}

+(CPPlotSymbol *)dashPlotSymbol
{
	CPPlotSymbol *symbol = [[self alloc] init];
	symbol.symbolType = CPPlotSymbolTypeDash;
	
	return [symbol autorelease];
}

+(CPPlotSymbol *)snowPlotSymbol
{
	CPPlotSymbol *symbol = [[self alloc] init];
	symbol.symbolType = CPPlotSymbolTypeSnow;
	
	return [symbol autorelease];
}

//	+(CPPlotSymbol *)plotSymbolWithString:(NSString *)aString;
//	+(CPPlotSymbol *)plotSymbolWithImage:(CGImageRef)anImage;

#pragma mark -
#pragma mark NSCopying methods

-(id)copyWithZone:(NSZone *)zone
{
	CPPlotSymbol *copy = [[[self class] allocWithZone:zone] init];
	
	copy.size = self.size;
	copy.symbolType = self.symbolType;
	copy.lineStyle = [[self.lineStyle copy] autorelease];
	CGColorRef fillCopy = CGColorCreateCopy(self.fillColor);
    copy.fillColor = fillCopy;
	CGColorRelease(fillCopy);
	
    return copy;
}

#pragma mark -
#pragma mark Drawing

-(void)renderInContext:(CGContextRef)theContext atPoint:(CGPoint)center
{
	if (self.lineStyle || self.fillColor) {
		CGFloat dx, dy;
		CGSize symbolSize = self.size;
		CGSize halfSize = CGSizeMake(symbolSize.width / 2.0, symbolSize.height / 2.0);
		// TODO: check for flipped
		CGRect bounds = CGRectMake(center.x - halfSize.width, center.y - halfSize.height, symbolSize.width, symbolSize.height);
		
		CGMutablePathRef symbolPath = CGPathCreateMutable();
		
		switch (self.symbolType) {
			case CPPlotSymbolTypeRectangle:
				CGPathAddRect(symbolPath, NULL, bounds);
				break;
			case CPPlotSymbolTypeEllipse:
				CGPathAddEllipseInRect(symbolPath, NULL, bounds);
				break;
			case CPPlotSymbolTypeCross:
				CGPathMoveToPoint(symbolPath, NULL, CGRectGetMinX(bounds), CGRectGetMaxY(bounds));
				CGPathAddLineToPoint(symbolPath, NULL, CGRectGetMaxX(bounds), CGRectGetMinY(bounds));
				CGPathMoveToPoint(symbolPath, NULL,  CGRectGetMaxX(bounds), CGRectGetMaxY(bounds));
				CGPathAddLineToPoint(symbolPath, NULL, CGRectGetMinX(bounds), CGRectGetMinY(bounds));
				break;
			case CPPlotSymbolTypePlus:
				CGPathMoveToPoint(symbolPath, NULL, center.x, CGRectGetMaxY(bounds));
				CGPathAddLineToPoint(symbolPath, NULL, center.x, CGRectGetMinY(bounds));
				CGPathMoveToPoint(symbolPath, NULL, CGRectGetMinX(bounds), center.y);
				CGPathAddLineToPoint(symbolPath, NULL, CGRectGetMaxX(bounds), center.y);
				break;
			case CPPlotSymbolTypePentagon:
				CGPathMoveToPoint(symbolPath, NULL, center.x, CGRectGetMaxY(bounds));
				CGPathAddLineToPoint(symbolPath, NULL, center.x + halfSize.width * 0.95105651630, center.y + halfSize.height * 0.30901699437);
				CGPathAddLineToPoint(symbolPath, NULL, center.x + halfSize.width * 0.58778525229, center.y - halfSize.height * 0.80901699437);
				CGPathAddLineToPoint(symbolPath, NULL, center.x - halfSize.width * 0.58778525229, center.y - halfSize.height * 0.80901699437);
				CGPathAddLineToPoint(symbolPath, NULL, center.x - halfSize.width * 0.95105651630, center.y + halfSize.height * 0.30901699437);
				CGPathCloseSubpath(symbolPath);
				break;
			case CPPlotSymbolTypeStar:
				CGPathMoveToPoint(symbolPath, NULL, center.x, CGRectGetMaxY(bounds));
				CGPathAddLineToPoint(symbolPath, NULL, center.x + halfSize.width * 0.22451398829, center.y + halfSize.height * 0.30901699437);
				CGPathAddLineToPoint(symbolPath, NULL, center.x + halfSize.width * 0.95105651630, center.y + halfSize.height * 0.30901699437);
				CGPathAddLineToPoint(symbolPath, NULL, center.x + halfSize.width * 0.36327126400, center.y - halfSize.height * 0.11803398875);
				CGPathAddLineToPoint(symbolPath, NULL, center.x + halfSize.width * 0.58778525229, center.y - halfSize.height * 0.80901699437);
				CGPathAddLineToPoint(symbolPath, NULL, center.x                                 , center.y - halfSize.height * 0.38196601125);
				CGPathAddLineToPoint(symbolPath, NULL, center.x - halfSize.width * 0.58778525229, center.y - halfSize.height * 0.80901699437);
				CGPathAddLineToPoint(symbolPath, NULL, center.x - halfSize.width * 0.36327126400, center.y - halfSize.height * 0.11803398875);
				CGPathAddLineToPoint(symbolPath, NULL, center.x - halfSize.width * 0.95105651630, center.y + halfSize.height * 0.30901699437);
				CGPathAddLineToPoint(symbolPath, NULL, center.x - halfSize.width * 0.22451398829, center.y + halfSize.height * 0.30901699437);
				CGPathCloseSubpath(symbolPath);
				break;
			case CPPlotSymbolTypeDiamond:
				CGPathMoveToPoint(symbolPath, NULL, center.x, CGRectGetMaxY(bounds));
				CGPathAddLineToPoint(symbolPath, NULL, CGRectGetMaxX(bounds), center.y);
				CGPathAddLineToPoint(symbolPath, NULL, center.x, CGRectGetMinY(bounds));
				CGPathAddLineToPoint(symbolPath, NULL, CGRectGetMinX(bounds), center.y);
				CGPathCloseSubpath(symbolPath);
				break;
			case CPPlotSymbolTypeTriangle:
#if CGFLOAT_IS_DOUBLE
				dy = halfSize.height / sqrt(2.0);
#else
				dy = halfSize.height / sqrtf(2.0);
#endif
				
				CGPathMoveToPoint(symbolPath, NULL, center.x, CGRectGetMaxY(bounds));
				CGPathAddLineToPoint(symbolPath, NULL, center.x + halfSize.width, center.y - dy);
				CGPathAddLineToPoint(symbolPath, NULL, center.x - halfSize.width, center.y - dy);
				CGPathCloseSubpath(symbolPath);
				break;
			case CPPlotSymbolTypeDash:
				CGPathMoveToPoint(symbolPath, NULL, CGRectGetMinX(bounds), center.y);
				CGPathAddLineToPoint(symbolPath, NULL, CGRectGetMaxX(bounds), center.y);
				break;
			case CPPlotSymbolTypeHexagon:
#if CGFLOAT_IS_DOUBLE
				dx = halfSize.width * sqrt(3.0) / 2.0;
#else
				dx = halfSize.width * sqrtf(3.0) / 2.0;
#endif
				dy = halfSize.height / 2.0;
				
				CGPathMoveToPoint(symbolPath, NULL, center.x, CGRectGetMaxY(bounds));
				CGPathAddLineToPoint(symbolPath, NULL, center.x + dx, center.y + dy);
				CGPathAddLineToPoint(symbolPath, NULL, center.x + dx, center.y - dy);
				CGPathAddLineToPoint(symbolPath, NULL, center.x, CGRectGetMinY(bounds));
				CGPathAddLineToPoint(symbolPath, NULL, center.x - dx, center.y - dy);
				CGPathAddLineToPoint(symbolPath, NULL, center.x - dx, center.y + dy);
				CGPathCloseSubpath(symbolPath);
				break;
			case CPPlotSymbolTypeSnow:
#if CGFLOAT_IS_DOUBLE
				dx = halfSize.width * sqrt(3.0) / 2.0;
#else
				dx = halfSize.width * sqrtf(3.0) / 2.0;
#endif
				dy = halfSize.height / 2.0;
				
				CGPathMoveToPoint(symbolPath, NULL, center.x, CGRectGetMaxY(bounds));
				CGPathAddLineToPoint(symbolPath, NULL, center.x, CGRectGetMinY(bounds));
				CGPathMoveToPoint(symbolPath, NULL, center.x + dx, center.y - dy);
				CGPathAddLineToPoint(symbolPath, NULL, center.x - dx, center.y + dy);
				CGPathMoveToPoint(symbolPath, NULL, center.x - dx, center.y - dy);
				CGPathAddLineToPoint(symbolPath, NULL, center.x + dx, center.y + dy);
				break;
		}
		CGContextBeginPath(theContext);
		CGContextAddPath(theContext, symbolPath);
		
		CGPathDrawingMode drawingMode;
		if (self.lineStyle) {
			[self.lineStyle setLineStyleInContext:theContext];
			if (self.fillColor) {
				CGContextSetFillColorWithColor(theContext, self.fillColor);
				drawingMode = kCGPathFillStroke;
			} else {
				drawingMode = kCGPathStroke;
			}
		} else {
			CGContextSetFillColorWithColor(theContext, self.fillColor);
			drawingMode = kCGPathFill;
		}
		CGContextDrawPath(theContext, drawingMode);
		
		CGPathRelease(symbolPath);
	}
}

@end
