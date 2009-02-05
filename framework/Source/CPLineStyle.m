
#import "CPLineStyle.h"


@implementation CPLineStyle


@synthesize lineCap, lineJoin, lineWidth, patternPhase, lineColor;

#pragma mark init/dealloc

+(CPLineStyle*)defaultLineStyle
{
    static CPLineStyle *defaultLineStyle = nil;
    if ( nil == defaultLineStyle ) defaultLineStyle = [[CPLineStyle alloc] init];
    return defaultLineStyle;
}

-(id)init
{
	if ( self = [super init] ) {
		self.lineCap = kCGLineCapButt;
		self.lineJoin = kCGLineJoinMiter;
		self.lineWidth = 1.f;
		self.patternPhase = CGSizeMake(0.f, 0.f);
		self.lineColor = CGColorGetConstantColor(kCGColorBlack);
	}
	return self;
}

-(void)dealloc
{
	CGColorRelease(lineColor);
	[super dealloc];
}

-(void)setLineStyleInContext:(CGContextRef)theContext
{
	CGContextSetLineCap(theContext, lineCap);
	CGContextSetLineJoin(theContext, lineJoin);
	CGContextSetLineWidth(theContext, lineWidth);
	CGContextSetPatternPhase(theContext, patternPhase);
	CGContextSetStrokeColorWithColor(theContext, lineColor);

}

#pragma mark Allocators
-(void)setLineColor:(CGColorRef)aLineColor
{
	if ( aLineColor != lineColor ) {
		CGColorRetain(aLineColor);
		CGColorRelease(lineColor);
		lineColor = aLineColor;
	}
}

@end
