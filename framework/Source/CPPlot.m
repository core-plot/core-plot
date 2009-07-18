
#import "CPPlot.h"
#import "CPPlotSpace.h"
#import "CPPlotRange.h"
#import "NSNumberExtensions.h"

///	@cond
@interface CPPlot()

@property (nonatomic, readwrite, assign) BOOL dataNeedsReloading;

@end
///	@endcond

@implementation CPPlot

@synthesize dataSource;
@synthesize identifier;
@synthesize plotSpace;
@synthesize dataNeedsReloading;

#pragma mark -
#pragma mark init/dealloc

-(id)initWithFrame:(CGRect)newFrame
{
	if (self = [super initWithFrame:newFrame]) {
        self.dataNeedsReloading = YES;
	}
	return self;
}

-(void)dealloc
{
    self.dataSource = nil;
    self.identifier = nil;
    self.plotSpace = nil;
    [super dealloc];
}

#pragma mark -
#pragma mark Drawing

-(void)drawInContext:(CGContextRef)theContext
{
    if ( self.dataNeedsReloading ) [self reloadData];
    [super drawInContext:theContext];
}

#pragma mark -
#pragma mark Layout

+(CGFloat)defaultZPosition 
{
	return CPDefaultZPositionPlot;
}

#pragma mark -
#pragma mark Data Source

-(void)reloadData
{
    self.dataNeedsReloading = NO;
    [self setNeedsDisplay];
}

-(NSArray *)decimalNumbersFromDataSourceForField:(NSUInteger)fieldEnum recordIndexRange:(NSRange)indexRange 
{
    NSArray *numbers;
    
    if ( self.dataSource ) {
        if ( [self.dataSource respondsToSelector:@selector(numbersForPlot:field:recordIndexRange:)] ) {
            numbers = [self.dataSource numbersForPlot:self field:fieldEnum recordIndexRange:indexRange];
            NSMutableArray *decimalNumbers = [NSMutableArray arrayWithCapacity:numbers.count];
            for ( NSNumber *n in numbers ) {
                [decimalNumbers addObject:[n decimalNumber]];
            }
            numbers = decimalNumbers;
        }
        else {
            BOOL respondsToSingleValueSelector = [self.dataSource respondsToSelector:@selector(numberForPlot:field:recordIndex:)];
            NSUInteger recordIndex;
            NSMutableArray *fieldValues = [NSMutableArray arrayWithCapacity:indexRange.length];
            for ( recordIndex = indexRange.location; recordIndex < indexRange.location + indexRange.length; ++recordIndex ) {
                if ( respondsToSingleValueSelector ) {
                    NSNumber *number = [self.dataSource numberForPlot:self field:fieldEnum recordIndex:recordIndex];
                    [fieldValues addObject:[number decimalNumber]];
                }
                else {
                    [fieldValues addObject:[NSDecimalNumber zero]];
                }
            }
            numbers = fieldValues;
        }
    }
    else {
        numbers = [NSArray array];
    }
    
    return numbers;
}

-(NSRange)recordIndexRangeForPlotRange:(CPPlotRange *)plotRange 
{
    if ( nil == self.dataSource ) return NSMakeRange(0, 0);
    
    NSRange resultRange;
    if ( [self.dataSource respondsToSelector:@selector(recordIndexRangeForPlot:plotRange:)] ) {
        resultRange = [self.dataSource recordIndexRangeForPlot:self plotRange:plotRange];
    }
    else {
        resultRange = NSMakeRange(0, [self.dataSource numberOfRecordsForPlot:self]);
    }
    
    return resultRange;
}

#pragma mark -
#pragma mark Accessors

-(void)setDataSource:(id <CPPlotDataSource>)newSource 
{
    if ( newSource != dataSource ) {
        dataSource = newSource;
        self.dataNeedsReloading = YES;
    }
}

-(void)setDataNeedsReloading
{
	self.dataNeedsReloading = YES;
    [self setNeedsDisplay];
}

@end
