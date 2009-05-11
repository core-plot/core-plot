#import <Foundation/Foundation.h>
#import "CPLineStyle.h"
#import "CPFill.h"
#import "CPPlotSymbol.h"

@implementation CPPlotSymbol

@synthesize size, symbolType, lineStyle, fill;

#pragma mark -
#pragma mark init/dealloc

-(id)init
{
	if ( self = [super init] ) {
		self.size = CGSizeMake(5.0, 5.0);
		self.symbolType = CPPlotSymbolTypeNone;
		self.lineStyle = [CPLineStyle lineStyle];
		self.fill = nil;
	}
	return self;
}

-(void)dealloc
{
	self.lineStyle = nil;
	self.fill = nil;
	
	[super dealloc];
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

#pragma mark -
#pragma mark NSCopying methods

-(id)copyWithZone:(NSZone *)zone
{
	CPPlotSymbol *copy = [[[self class] allocWithZone:zone] init];
	
	copy.size = self.size;
	copy.symbolType = self.symbolType;
	copy.lineStyle = [[self.lineStyle copy] autorelease];
    copy.fill = [self.fill copy];
	
    return copy;
}

#pragma mark -
#pragma mark Drawing

-(void)renderInContext:(CGContextRef)theContext atPoint:(CGPoint)center
{
	if (self.symbolType != CPPlotSymbolTypeNone) {
		if (self.lineStyle || self.fill) {
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
					dx = halfSize.width * 0.86602540378; // sqrt(3.0) / 2.0;
					dy = halfSize.height / 2.0;
					
					CGPathMoveToPoint(symbolPath, NULL, center.x, CGRectGetMaxY(bounds));
					CGPathAddLineToPoint(symbolPath, NULL, center.x + dx, center.y - dy);
					CGPathAddLineToPoint(symbolPath, NULL, center.x - dx, center.y - dy);
					CGPathCloseSubpath(symbolPath);
					break;
				case CPPlotSymbolTypeDash:
					CGPathMoveToPoint(symbolPath, NULL, CGRectGetMinX(bounds), center.y);
					CGPathAddLineToPoint(symbolPath, NULL, CGRectGetMaxX(bounds), center.y);
					break;
				case CPPlotSymbolTypeHexagon:
					dx = halfSize.width * 0.86602540378; // sqrt(3.0) / 2.0;
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
					dx = halfSize.width * 0.86602540378; // sqrt(3.0) / 2.0;
					dy = halfSize.height / 2.0;
					
					CGPathMoveToPoint(symbolPath, NULL, center.x, CGRectGetMaxY(bounds));
					CGPathAddLineToPoint(symbolPath, NULL, center.x, CGRectGetMinY(bounds));
					CGPathMoveToPoint(symbolPath, NULL, center.x + dx, center.y - dy);
					CGPathAddLineToPoint(symbolPath, NULL, center.x - dx, center.y + dy);
					CGPathMoveToPoint(symbolPath, NULL, center.x - dx, center.y - dy);
					CGPathAddLineToPoint(symbolPath, NULL, center.x + dx, center.y + dy);
					break;
			}
			
			if (self.fill) {
				// use fillRect instead of fillPath so that images and gradients are properly centered in the symbol
				CGContextSaveGState(theContext);
				CGContextBeginPath(theContext);
				CGContextAddPath(theContext, symbolPath);
				CGContextClip(theContext);
				[self.fill fillRect:bounds inContext:theContext];
				CGContextRestoreGState(theContext);
			}
			
			if (self.lineStyle) {
				[self.lineStyle setLineStyleInContext:theContext];
				CGContextBeginPath(theContext);
				CGContextAddPath(theContext, symbolPath);
				CGContextStrokePath(theContext);
			}
			
			CGPathRelease(symbolPath);
		}		
	}
}

@end
