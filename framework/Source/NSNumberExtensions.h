/** @category NSNumber(CPTExtensions)
 *  @brief Core Plot extensions to NSNumber.
 **/
@interface NSNumber(CPTExtensions)

+(instancetype)numberWithCGFloat:(CGFloat)number;

-(CGFloat)cgFloatValue;
-(instancetype)initWithCGFloat:(CGFloat)number;

-(NSDecimalNumber *)decimalNumber;

@end
