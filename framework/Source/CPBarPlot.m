
#import "CPBarPlot.h"
#import "CPXYPlotSpace.h"
#import "CPColor.h"
#import "CPLineStyle.h"
#import "CPFill.h"

NSString * const CPBarPlotBindingBarLengths = @"barLengths";

static NSString * const CPBarLengthsBindingContext = @"CPBarLengthsBindingContext";

@interface CPBarPlot ()

@property (nonatomic, readwrite, assign) id observedObjectForBarLengthValues;
@property (nonatomic, readwrite, copy) NSString *keyPathForBarLengthValues;
@property (nonatomic, readwrite, retain) NSArray *barLengths;

-(void)drawBarInContext:(CGContextRef)context fromBasePoint:(CGPoint *)basePoint toTipPoint:(CGPoint *)tipPoint;

@end

@implementation CPBarPlot

@synthesize observedObjectForBarLengthValues;
@synthesize keyPathForBarLengthValues;
@synthesize cornerRadius;
@synthesize barOffset;
@synthesize barWidth;
@synthesize lineStyle;
@synthesize fill;
@synthesize barLengths;
@synthesize barsAreHorizontal;
@synthesize baseValue;

-(id)initWithFrame:(CGRect)newFrame
{
	if (self = [super initWithFrame:newFrame]) {
        self.barsAreHorizontal = NO;
        self.baseValue = [NSDecimalNumber zero];
        self.barWidth = 10.0f;
        self.cornerRadius = 0.0f;
        self.barOffset = 0.0f;
        self.lineStyle = [CPLineStyle lineStyle];
        self.fill = [CPFill fillWithColor:[CPColor blackColor]];
	}
	return self;
}

-(void)dealloc
{
    self.keyPathForBarLengthValues = nil;
    self.observedObjectForBarLengthValues = nil;
    self.lineStyle = nil;
    self.fill = nil;
    self.barLengths = nil;
    self.baseValue = nil;
    [super dealloc];
}

-(void)bind:(NSString *)binding toObject:(id)observable withKeyPath:(NSString *)keyPath options:(NSDictionary *)options
{
    [super bind:binding toObject:observable withKeyPath:keyPath options:options];
    if ([binding isEqualToString:CPBarPlotBindingBarLengths]) {
        [observable addObserver:self forKeyPath:keyPath options:0 context:CPBarLengthsBindingContext];
        self.observedObjectForBarLengthValues = observable;
        self.keyPathForBarLengthValues = keyPath;
    }
    [self setNeedsDisplay];
}

-(void)unbind:(NSString *)bindingName
{
    if ([bindingName isEqualToString:CPBarPlotBindingBarLengths]) {
		[observedObjectForBarLengthValues removeObserver:self forKeyPath:keyPathForBarLengthValues];
        self.observedObjectForBarLengthValues = nil;
        self.keyPathForBarLengthValues = nil;
    }	
	[super unbind:bindingName];
	[self reloadData];
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == CPBarLengthsBindingContext) {
        [self reloadData];
    }
}

#pragma mark -
#pragma mark Accessors


#pragma mark -
#pragma mark Data Loading

-(void)reloadData 
{    
    [super reloadData];
	
    CPXYPlotSpace *xyPlotSpace = (CPXYPlotSpace *)self.plotSpace;
    self.barLengths = nil;
	
    if ( self.observedObjectForBarLengthValues ) {
        // Use bindings to retrieve data
        self.barLengths = [self.observedObjectForBarLengthValues valueForKeyPath:self.keyPathForBarLengthValues];
    }
    else if ( self.dataSource ) {
        NSRange indexRange = [self recordIndexRangeForPlotRange:xyPlotSpace.xRange];
        self.barLengths = [self decimalNumbersFromDataSourceForField:CPBarPlotFieldBarLength recordIndexRange:indexRange];
    }
}

#pragma mark -
#pragma mark Drawing

-(void)renderAsVectorInContext:(CGContextRef)theContext
{
    if ( self.barLengths == nil ) return;
    if ( self.lineStyle == nil && self.fill == nil ) return;
	
    NSDecimalNumber *plotPoint[2];
    CGPoint tipPoint, basePoint;
    CPCoordinate independentCoord = ( barsAreHorizontal ? CPCoordinateY : CPCoordinateX );
    CPCoordinate dependentCoord = ( barsAreHorizontal ? CPCoordinateX : CPCoordinateY );
    for (NSUInteger ii = 0; ii < [self.barLengths count]; ii++) {
        // Tip point
        plotPoint[independentCoord] = (NSDecimalNumber *)[NSDecimalNumber numberWithUnsignedInt:ii];
        plotPoint[dependentCoord] = [self.barLengths objectAtIndex:ii];
        tipPoint = [self.plotSpace viewPointForPlotPoint:plotPoint];
        
        // Base point
        plotPoint[dependentCoord] = self.baseValue;
        basePoint = [self.plotSpace viewPointForPlotPoint:plotPoint];
        
        // Offset
        CGFloat viewOffset = barOffset * barWidth;
        if ( barsAreHorizontal ) {
            basePoint.y += viewOffset;
            tipPoint.y += viewOffset;
        }
        else {
            basePoint.x += viewOffset;
            tipPoint.x += viewOffset;
        }
        
        // Draw
        [self drawBarInContext:theContext fromBasePoint:&basePoint toTipPoint:&tipPoint];
    }	
}

-(void)drawBarInContext:(CGContextRef)context fromBasePoint:(CGPoint *)basePoint toTipPoint:(CGPoint *)tipPoint 
{
    CPCoordinate widthCoordinate = ( barsAreHorizontal ? CPCoordinateY : CPCoordinateX );
    CGFloat point1[2];
    point1[0] = basePoint->x;
    point1[1] = basePoint->y;
    point1[widthCoordinate] += 0.5 * barWidth;
    point1[0] = round(point1[0]);
    point1[1] = round(point1[1]);
    
    CGFloat point2[2];
    point2[0] = tipPoint->x;
    point2[1] = tipPoint->y;
    point2[widthCoordinate] += 0.5 * barWidth;
    point2[0] = round(point2[0]);
    point2[1] = round(point2[1]);
    
    CGFloat point3[2];
    point3[0] = tipPoint->x;
    point3[1] = tipPoint->y;
    point3[0] = round(point3[0]);
    point3[1] = round(point3[1]);

    CGFloat point4[2];
    point4[0] = tipPoint->x;
    point4[1] = tipPoint->y;
    point4[widthCoordinate] -= 0.5 * barWidth;
    point4[0] = round(point4[0]);
    point4[1] = round(point4[1]);
    
    CGFloat point5[2];
    point5[0] = basePoint->x;
    point5[1] = basePoint->y;
    point5[widthCoordinate] -= 0.5 * barWidth;
    point5[0] = round(point5[0]);
    point5[1] = round(point5[1]);

    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, point1[0], point1[1]);
	CGPathAddArcToPoint(path, NULL, point2[0], point2[1], point3[0], point3[1], cornerRadius);
    CGPathAddArcToPoint(path, NULL, point4[0], point4[1], point5[0], point5[1], cornerRadius);
    CGPathAddLineToPoint(path, NULL, point5[0], point5[1]);
    
    CGContextAddPath(context, path);
    [self.fill fillPathInContext:context];

    CGContextAddPath(context, path);
    [self.lineStyle setLineStyleInContext:context];
    CGContextStrokePath(context);
    
    CGPathRelease(path);
}

#pragma mark -
#pragma mark Accessors

-(void)setLineStyle:(CPLineStyle *)value {
    if (lineStyle != value) {
        [lineStyle release];
        lineStyle = [value copy];
        [self setNeedsDisplay];
    }
}

-(void)setFill:(CPFill *)value {
    if (fill != value) {
        [fill release];
        fill = [value copy];
        [self setNeedsDisplay];
    }
}

-(void)setBarWidth:(CGFloat)value {
    if (barWidth != value) {
        barWidth = fabs(value);
        [self setNeedsDisplay];
    }
}

-(void)setBarOffset:(CGFloat)value {
    if (barOffset != value) {
        barOffset = value;
        [self setNeedsDisplay];
    }
}

-(void)setCornerRadius:(CGFloat)value {
    if (cornerRadius != value) {
        cornerRadius = fabs(value);
        [self setNeedsDisplay];
    }
}

-(void)setBaseValue:(NSDecimalNumber *)value {
    if (baseValue != value) {
        [baseValue release];
        baseValue = [value copy];
        [self setNeedsDisplay];
    }
}

-(void)setBarsAreHorizontal:(BOOL)value {
    if (barsAreHorizontal != value) {
        barsAreHorizontal = value;
        [self setNeedsDisplay];
    }
}



@end
