/** @category NSCoder(CPTExtensions)
 *  @brief Core Plot extensions to NSCoder.
 **/
@interface NSCoder(CPTExtensions)

/// @name Encoding Data
/// @{
-(void)encodeCGFloat:(CGFloat)number forKey:(NSString *)key;
-(void)encodeCPTPoint:(CGPoint)point forKey:(NSString *)key;
-(void)encodeCPTSize:(CGSize)size forKey:(NSString *)key;
-(void)encodeCPTRect:(CGRect)rect forKey:(NSString *)key;

-(void)encodeCGColorSpace:(CGColorSpaceRef)colorSpace forKey:(NSString *)key;
-(void)encodeCGPath:(CGPathRef)path forKey:(NSString *)key;
-(void)encodeCGImage:(CGImageRef)image forKey:(NSString *)key;

-(void)encodeDecimal:(NSDecimal)number forKey:(NSString *)key;
/// @}

/// @name Decoding Data
/// @{
-(CGFloat)decodeCGFloatForKey:(NSString *)key;
-(CGPoint)decodeCPTPointForKey:(NSString *)key;
-(CGSize)decodeCPTSizeForKey:(NSString *)key;
-(CGRect)decodeCPTRectForKey:(NSString *)key;

-(CGColorSpaceRef)newCGColorSpaceDecodeForKey:(NSString *)key;
-(CGPathRef)newCGPathDecodeForKey:(NSString *)key;
-(CGImageRef)newCGImageDecodeForKey:(NSString *)key;

-(NSDecimal)decodeDecimalForKey:(NSString *)key;
/// @}

@end
