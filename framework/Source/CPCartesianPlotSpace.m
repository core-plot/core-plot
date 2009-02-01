
#import "CPCartesianPlotSpace.h"

CGFloat NSDecimalFloatValue(NSDecimal dec)
{
	return [[NSDecimalNumber decimalNumberWithDecimal:dec] floatValue]; 
}

@implementation CPCartesianPlotSpace

#pragma mark Implementation of CPPlotSpace

-(CGPoint)viewPointForPlotPoint:(NSArray *)decimalNumbers;
{
	if ([decimalNumbers count] == 2)
	{
		NSDecimal boundsw = [[NSDecimalNumber decimalNumberWithMantissa:self.bounds.size.width exponent:0 isNegative:NO] decimalValue];
		NSDecimal boundsh = [[NSDecimalNumber decimalNumberWithMantissa:self.bounds.size.height exponent:0 isNegative:NO] decimalValue];

		
		NSDecimal x = [[decimalNumbers objectAtIndex:0] decimalValue];
		NSDecimalSubtract(&x, &x, &(XRange.location), NSRoundPlain);
		NSDecimalDivide(&x, &x, &(XRange.length), NSRoundPlain);
		NSDecimalMultiply(&x, &x, &boundsw, NSRoundPlain);
		NSDecimal y = [[decimalNumbers objectAtIndex:1] decimalValue];
		NSDecimalSubtract(&y, &y, &(YRange.location), NSRoundPlain);
		NSDecimalDivide(&y, &y, &(YRange.length), NSRoundPlain);
		NSDecimalMultiply(&y, &y, &boundsh, NSRoundPlain);
		
		return CGPointMake(NSDecimalFloatValue(x), NSDecimalFloatValue(y));
	}
	else
		// What do we return in this case?
		return CGPointMake(0.f, 0.f);
}

-(NSArray *)plotPointForViewPoint:(CGPoint)point
{
	NSDecimal pointx = [[[[NSDecimalNumber alloc] initWithFloat:point.x] autorelease] decimalValue];
	NSDecimal pointy = [[[[NSDecimalNumber alloc] initWithFloat:point.y] autorelease] decimalValue];
	NSDecimal boundsw = [[NSDecimalNumber decimalNumberWithMantissa:self.bounds.size.width exponent:0 isNegative:NO] decimalValue];
	NSDecimal boundsh = [[NSDecimalNumber decimalNumberWithMantissa:self.bounds.size.height exponent:0 isNegative:NO] decimalValue];

	NSDecimal x;
	NSDecimalDivide(&x, &pointx, &boundsw, NSRoundPlain);
	NSDecimalMultiply(&x, &x, &(XRange.length), NSRoundPlain);
	NSDecimalAdd(&x, &x, &(XRange.location), NSRoundPlain);

	NSDecimal y;
	NSDecimalDivide(&y, &pointy, &boundsh, NSRoundPlain);
	NSDecimalMultiply(&y, &y, &(YRange.length), NSRoundPlain);
	NSDecimalAdd(&y, &y, &(YRange.location), NSRoundPlain);

	return [NSArray arrayWithObjects:[NSDecimalNumber decimalNumberWithDecimal:x],[NSDecimalNumber decimalNumberWithDecimal:y],nil];
}

@end
