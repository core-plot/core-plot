#import "CPTAnimation.h"

@class CPTAnimationOperation;
@class CPTPlotRange;

@interface CPTAnimationPeriod : NSObject

/// @name Timing Values
/// @{
@property (nonatomic, readwrite, copy) NSValue *startValue;
@property (nonatomic, readwrite, copy) NSValue *endValue;
@property (nonatomic, readwrite) CGFloat duration;
@property (nonatomic, readwrite) CGFloat delay;
@property (nonatomic, readonly) CGFloat startOffset;
/// @}

/// @name Factory Methods
/// @{
+(instancetype)periodWithStart:(CGFloat)aStart end:(CGFloat)anEnd duration:(CGFloat)aDuration withDelay:(CGFloat)aDelay;
+(instancetype)periodWithStartPoint:(CGPoint)aStartPoint endPoint:(CGPoint)anEndPoint duration:(CGFloat)aDuration withDelay:(CGFloat)aDelay;
+(instancetype)periodWithStartSize:(CGSize)aStartSize endSize:(CGSize)anEndSize duration:(CGFloat)aDuration withDelay:(CGFloat)aDelay;
+(instancetype)periodWithStartRect:(CGRect)aStartRect endRect:(CGRect)anEndRect duration:(CGFloat)aDuration withDelay:(CGFloat)aDelay;
+(instancetype)periodWithStartDecimal:(NSDecimal)aStartDecimal endDecimal:(NSDecimal)anEndDecimal duration:(CGFloat)aDuration withDelay:(CGFloat)aDelay;
+(instancetype)periodWithStartPlotRange:(CPTPlotRange *)aStartPlotRange endPlotRange:(CPTPlotRange *)anEndPlotRange duration:(CGFloat)aDuration withDelay:(CGFloat)aDelay;
/// @}

/// @name Initialization
/// @{
-(instancetype)initWithStart:(CGFloat)aStart end:(CGFloat)anEnd duration:(CGFloat)aDuration withDelay:(CGFloat)aDelay;
-(instancetype)initWithStartPoint:(CGPoint)aStartPoint endPoint:(CGPoint)anEndPoint duration:(CGFloat)aDuration withDelay:(CGFloat)aDelay;
-(instancetype)initWithStartSize:(CGSize)aStartSize endSize:(CGSize)anEndSize duration:(CGFloat)aDuration withDelay:(CGFloat)aDelay;
-(instancetype)initWithStartRect:(CGRect)aStartRect endRect:(CGRect)anEndRect duration:(CGFloat)aDuration withDelay:(CGFloat)aDelay;
-(instancetype)initWithStartDecimal:(NSDecimal)aStartDecimal endDecimal:(NSDecimal)anEndDecimal duration:(CGFloat)aDuration withDelay:(CGFloat)aDelay;
-(instancetype)initWithStartPlotRange:(CPTPlotRange *)aStartPlotRange endPlotRange:(CPTPlotRange *)anEndPlotRange duration:(CGFloat)aDuration withDelay:(CGFloat)aDelay;
/// @}

@end

#pragma mark -

/** @category CPTAnimationPeriod(AbstractMethods)
 *  @brief CPTAnimationPeriod abstract methods—must be overridden by subclasses
 **/
@interface CPTAnimationPeriod(AbstractMethods)

/// @name Initialization
/// @{
-(void)setStartValueFromObject:(id)boundObject propertyGetter:(SEL)boundGetter;
/// @}

/// @name Interpolation
/// @{
-(NSValue *)tweenedValueForProgress:(CGFloat)progress;
/// @}

/// @name Comparison
/// @{
-(BOOL)canStartWithValueFromObject:(id)boundObject propertyGetter:(SEL)boundGetter;
/// @}

@end

#pragma mark -

@interface CPTAnimation(CPTAnimationPeriodAdditions)

/// @name CGFloat Property Animation
/// @{
+(CPTAnimationOperation *)animate:(id)object property:(NSString *)property from:(CGFloat)from to:(CGFloat)to duration:(CGFloat)duration withDelay:(CGFloat)delay animationCurve:(CPTAnimationCurve)animationCurve delegate:(id<CPTAnimationDelegate>)delegate;
+(CPTAnimationOperation *)animate:(id)object property:(NSString *)property from:(CGFloat)from to:(CGFloat)to duration:(CGFloat)duration animationCurve:(CPTAnimationCurve)animationCurve delegate:(id<CPTAnimationDelegate>)delegate;
+(CPTAnimationOperation *)animate:(id)object property:(NSString *)property from:(CGFloat)from to:(CGFloat)to duration:(CGFloat)duration;
/// @}

/// @name CGPoint Property Animation
/// @{
+(CPTAnimationOperation *)animate:(id)object property:(NSString *)property fromPoint:(CGPoint)from toPoint:(CGPoint)to duration:(CGFloat)duration withDelay:(CGFloat)delay animationCurve:(CPTAnimationCurve)animationCurve delegate:(id<CPTAnimationDelegate>)delegate;
+(CPTAnimationOperation *)animate:(id)object property:(NSString *)property fromPoint:(CGPoint)from toPoint:(CGPoint)to duration:(CGFloat)duration animationCurve:(CPTAnimationCurve)animationCurve delegate:(id<CPTAnimationDelegate>)delegate;
+(CPTAnimationOperation *)animate:(id)object property:(NSString *)property fromPoint:(CGPoint)from toPoint:(CGPoint)to duration:(CGFloat)duration;
/// @}

/// @name CGSize Property Animation
/// @{
+(CPTAnimationOperation *)animate:(id)object property:(NSString *)property fromSize:(CGSize)from toSize:(CGSize)to duration:(CGFloat)duration withDelay:(CGFloat)delay animationCurve:(CPTAnimationCurve)animationCurve delegate:(id<CPTAnimationDelegate>)delegate;
+(CPTAnimationOperation *)animate:(id)object property:(NSString *)property fromSize:(CGSize)from toSize:(CGSize)to duration:(CGFloat)duration animationCurve:(CPTAnimationCurve)animationCurve delegate:(id<CPTAnimationDelegate>)delegate;
+(CPTAnimationOperation *)animate:(id)object property:(NSString *)property fromSize:(CGSize)from toSize:(CGSize)to duration:(CGFloat)duration;
/// @}

/// @name CGRect Property Animation
/// @{
+(CPTAnimationOperation *)animate:(id)object property:(NSString *)property fromRect:(CGRect)from toRect:(CGRect)to duration:(CGFloat)duration withDelay:(CGFloat)delay animationCurve:(CPTAnimationCurve)animationCurve delegate:(id<CPTAnimationDelegate>)delegate;
+(CPTAnimationOperation *)animate:(id)object property:(NSString *)property fromRect:(CGRect)from toRect:(CGRect)to duration:(CGFloat)duration animationCurve:(CPTAnimationCurve)animationCurve delegate:(id<CPTAnimationDelegate>)delegate;
+(CPTAnimationOperation *)animate:(id)object property:(NSString *)property fromRect:(CGRect)from toRect:(CGRect)to duration:(CGFloat)duration;
/// @}

/// @name NSDecimal Property Animation
/// @{
+(CPTAnimationOperation *)animate:(id)object property:(NSString *)property fromDecimal:(NSDecimal)from toDecimal:(NSDecimal)to duration:(CGFloat)duration withDelay:(CGFloat)delay animationCurve:(CPTAnimationCurve)animationCurve delegate:(id<CPTAnimationDelegate>)delegate;
+(CPTAnimationOperation *)animate:(id)object property:(NSString *)property fromDecimal:(NSDecimal)from toDecimal:(NSDecimal)to duration:(CGFloat)duration animationCurve:(CPTAnimationCurve)animationCurve delegate:(id<CPTAnimationDelegate>)delegate;
+(CPTAnimationOperation *)animate:(id)object property:(NSString *)property fromDecimal:(NSDecimal)from toDecimal:(NSDecimal)to duration:(CGFloat)duration;
/// @}

/// @name CPTPlotRange Property Animation
/// @{
+(CPTAnimationOperation *)animate:(id)object property:(NSString *)property fromPlotRange:(CPTPlotRange *)from toPlotRange:(CPTPlotRange *)to duration:(CGFloat)duration withDelay:(CGFloat)delay animationCurve:(CPTAnimationCurve)animationCurve delegate:(id<CPTAnimationDelegate>)delegate;
+(CPTAnimationOperation *)animate:(id)object property:(NSString *)property fromPlotRange:(CPTPlotRange *)from toPlotRange:(CPTPlotRange *)to duration:(CGFloat)duration animationCurve:(CPTAnimationCurve)animationCurve delegate:(id<CPTAnimationDelegate>)delegate;
+(CPTAnimationOperation *)animate:(id)object property:(NSString *)property fromPlotRange:(CPTPlotRange *)from toPlotRange:(CPTPlotRange *)to duration:(CGFloat)duration;
/// @}

@end
