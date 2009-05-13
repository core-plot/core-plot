#import <Foundation/Foundation.h>
#import "CPLineStyle.h"
#import "CPFill.h"
#import "CPPlotSymbol.h"

@interface CPPlotSymbol()

-(void)setSymbolPath;

@end

#pragma mark -

@implementation CPPlotSymbol

@synthesize size, symbolType, lineStyle, fill;

#pragma mark -
#pragma mark init/dealloc

-(id)init
{
	if ( self = [super init] ) {
		size = CGSizeMake(5.0, 5.0);
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
	CGPathRelease(symbolPath);
	
	[super dealloc];
}

#pragma mark -
#pragma mark Accessors

-(void)setSize:(CGSize)aSize
{
	size = aSize;
	[self setSymbolPath];
}

-(void)setSymbolType:(CPPlotSymbolType)theType
{
	symbolType = theType;
	[self setSymbolPath];
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
			CGContextSaveGState(theContext);
			CGContextTranslateCTM(theContext, center.x, center.y);
			
			if (self.fill) {
				// use fillRect instead of fillPath so that images and gradients are properly centered in the symbol
				CGSize symbolSize = self.size;
				CGSize halfSize = CGSizeMake(symbolSize.width / 2.0, symbolSize.height / 2.0);
				CGRect bounds = CGRectMake(-halfSize.width, -halfSize.height, symbolSize.width, symbolSize.height);
				
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
			
			CGContextRestoreGState(theContext);
		}		
	}
}

#pragma mark -
#pragma mark Private methods

-(void)setSymbolPath
{
	CGFloat dx, dy;
	CGSize symbolSize = self.size;
	CGSize halfSize = CGSizeMake(symbolSize.width / 2.0, symbolSize.height / 2.0);
	CGRect bounds = CGRectMake(-halfSize.width, -halfSize.height, symbolSize.width, symbolSize.height);
	
	CGPathRelease(symbolPath);
	symbolPath = CGPathCreateMutable();
	
	switch (self.symbolType) {
		case CPPlotSymbolTypeRectangle:
			CGPathAddRect(symbolPath, NULL, bounds);
			break;
		case CPPlotSymbolTypeEllipse:
			CGPathAddEllipseInRect(symbolPath, NULL, bounds);
			break;
		case CPPlotSymbolTypeCross:
			CGPathMoveToPoint(symbolPath,    NULL, CGRectGetMinX(bounds), CGRectGetMaxY(bounds));
			CGPathAddLineToPoint(symbolPath, NULL, CGRectGetMaxX(bounds), CGRectGetMinY(bounds));
			CGPathMoveToPoint(symbolPath,    NULL, CGRectGetMaxX(bounds), CGRectGetMaxY(bounds));
			CGPathAddLineToPoint(symbolPath, NULL, CGRectGetMinX(bounds), CGRectGetMinY(bounds));
			break;
		case CPPlotSymbolTypePlus:
			CGPathMoveToPoint(symbolPath,    NULL, 0.0,                   CGRectGetMaxY(bounds));
			CGPathAddLineToPoint(symbolPath, NULL, 0.0,                   CGRectGetMinY(bounds));
			CGPathMoveToPoint(symbolPath,    NULL, CGRectGetMinX(bounds), 0.0);
			CGPathAddLineToPoint(symbolPath, NULL, CGRectGetMaxX(bounds), 0.0);
			break;
		case CPPlotSymbolTypePentagon:
			CGPathMoveToPoint(symbolPath,    NULL,	0.0,                             CGRectGetMaxY(bounds));
			CGPathAddLineToPoint(symbolPath, NULL,  halfSize.width * 0.95105651630,  halfSize.height * 0.30901699437);
			CGPathAddLineToPoint(symbolPath, NULL,  halfSize.width * 0.58778525229, -halfSize.height * 0.80901699437);
			CGPathAddLineToPoint(symbolPath, NULL, -halfSize.width * 0.58778525229, -halfSize.height * 0.80901699437);
			CGPathAddLineToPoint(symbolPath, NULL, -halfSize.width * 0.95105651630,  halfSize.height * 0.30901699437);
			CGPathCloseSubpath(symbolPath);
			break;
		case CPPlotSymbolTypeStar:
			CGPathMoveToPoint(symbolPath,    NULL,  0.0,                             CGRectGetMaxY(bounds));
			CGPathAddLineToPoint(symbolPath, NULL,  halfSize.width * 0.22451398829,  halfSize.height * 0.30901699437);
			CGPathAddLineToPoint(symbolPath, NULL,  halfSize.width * 0.95105651630,  halfSize.height * 0.30901699437);
			CGPathAddLineToPoint(symbolPath, NULL,  halfSize.width * 0.36327126400, -halfSize.height * 0.11803398875);
			CGPathAddLineToPoint(symbolPath, NULL,  halfSize.width * 0.58778525229, -halfSize.height * 0.80901699437);
			CGPathAddLineToPoint(symbolPath, NULL,  0.0                           , -halfSize.height * 0.38196601125);
			CGPathAddLineToPoint(symbolPath, NULL, -halfSize.width * 0.58778525229, -halfSize.height * 0.80901699437);
			CGPathAddLineToPoint(symbolPath, NULL, -halfSize.width * 0.36327126400, -halfSize.height * 0.11803398875);
			CGPathAddLineToPoint(symbolPath, NULL, -halfSize.width * 0.95105651630,  halfSize.height * 0.30901699437);
			CGPathAddLineToPoint(symbolPath, NULL, -halfSize.width * 0.22451398829,  halfSize.height * 0.30901699437);
			CGPathCloseSubpath(symbolPath);
			break;
		case CPPlotSymbolTypeDiamond:
			CGPathMoveToPoint(symbolPath,    NULL, 0.0,                   CGRectGetMaxY(bounds));
			CGPathAddLineToPoint(symbolPath, NULL, CGRectGetMaxX(bounds), 0.0);
			CGPathAddLineToPoint(symbolPath, NULL, 0.0,                   CGRectGetMinY(bounds));
			CGPathAddLineToPoint(symbolPath, NULL, CGRectGetMinX(bounds), 0.0);
			CGPathCloseSubpath(symbolPath);
			break;
		case CPPlotSymbolTypeTriangle:
			dx = halfSize.width * 0.86602540378; // sqrt(3.0) / 2.0;
			dy = halfSize.height / 2.0;
			
			CGPathMoveToPoint(symbolPath,    NULL,  0.0, CGRectGetMaxY(bounds));
			CGPathAddLineToPoint(symbolPath, NULL,  dx, -dy);
			CGPathAddLineToPoint(symbolPath, NULL, -dx, -dy);
			CGPathCloseSubpath(symbolPath);
			break;
		case CPPlotSymbolTypeDash:
			CGPathMoveToPoint(symbolPath,    NULL, CGRectGetMinX(bounds), 0.0);
			CGPathAddLineToPoint(symbolPath, NULL, CGRectGetMaxX(bounds), 0.0);
			break;
		case CPPlotSymbolTypeHexagon:
			dx = halfSize.width * 0.86602540378; // sqrt(3.0) / 2.0;
			dy = halfSize.height / 2.0;
			
			CGPathMoveToPoint(symbolPath,    NULL, 0.0,  CGRectGetMaxY(bounds));
			CGPathAddLineToPoint(symbolPath, NULL, dx,   dy);
			CGPathAddLineToPoint(symbolPath, NULL, dx,  -dy);
			CGPathAddLineToPoint(symbolPath, NULL, 0.0,  CGRectGetMinY(bounds));
			CGPathAddLineToPoint(symbolPath, NULL, -dx, -dy);
			CGPathAddLineToPoint(symbolPath, NULL, -dx,  dy);
			CGPathCloseSubpath(symbolPath);
			break;
		case CPPlotSymbolTypeSnow:
			dx = halfSize.width * 0.86602540378; // sqrt(3.0) / 2.0;
			dy = halfSize.height / 2.0;
			
			CGPathMoveToPoint(symbolPath,    NULL,  0.0, CGRectGetMaxY(bounds));
			CGPathAddLineToPoint(symbolPath, NULL,  0.0, CGRectGetMinY(bounds));
			CGPathMoveToPoint(symbolPath,    NULL,  dx, -dy);
			CGPathAddLineToPoint(symbolPath, NULL, -dx,  dy);
			CGPathMoveToPoint(symbolPath,    NULL, -dx, -dy);
			CGPathAddLineToPoint(symbolPath, NULL,  dx,  dy);
			break;
	}	
}

@end

