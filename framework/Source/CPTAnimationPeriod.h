#import "CPTAnimation.h"

@class CPTAnimationOperation;
@class CPTPlotRange;

@interface CPTAnimationPeriod : NSObject {
    @private
    NSValue *startValue;
    NSValue *endValue;
    CGFloat duration;
    CGFloat delay;
    CGFloat startOffset;
}

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
+(id)periodWithStart:(CGFloat)aStart end:(CGFloat)anEnd duration:(CGFloat)aDuration withDelay:(CGFloat)aDelay;
+(id)periodWithStartPoint:(CGPoint)aStartPoint endPoint:(CGPoint)anEndPoint duration:(CGFloat)aDuration withDelay:(CGFloat)aDelay;
+(id)periodWithStartSize:(CGSize)aStartSize endSize:(CGSize)anEndSize duration:(CGFloat)aDuration withDelay:(CGFloat)aDelay;
+(id)periodWithStartRect:(CGRect)aStartRect endRect:(CGRect)anEndRect duration:(CGFloat)aDuration withDelay:(CGFloat)aDelay;
+(id)periodWithStartDecimal:(NSDecimal)aStartDecimal endDecimal:(NSDecimal)anEndDecimal duration:(CGFloat)aDuration withDelay:(CGFloat)aDelay;
+(id)periodWithStartPlotRange:(CPTPlotRange *)aStartPlotRange endPlotRange:(CPTPlotRange *)anEndPlotRange duration:(CGFloat)aDuration withDelay:(CGFloat)aDelay;
/// @}

/// @name Initialization
/// @{
-(id)initWithStart:(CGFloat)aStart end:(CGFloat)anEnd duration:(CGFloat)aDuration withDelay:(CGFloat)aDelay;
-(id)initWithStartPoint:(CGPoint)aStartPoint endPoint:(CGPoint)anEndPoint duration:(CGFloat)aDuration withDelay:(CGFloat)aDelay;
-(id)initWithStartSize:(CGSize)aStartSize endSize:(CGSize)anEndSize duration:(CGFloat)aDuration withDelay:(CGFloat)aDelay;
-(id)initWithStartRect:(CGRect)aStartRect endRect:(CGRect)anEndRect duration:(CGFloat)aDuration withDelay:(CGFloat)aDelay;
-(id)initWithStartDecimal:(NSDecimal)aStartDecimal endDecimal:(NSDecimal)anEndDecimal duration:(CGFloat)aDuration withDelay:(CGFloat)aDelay;
-(id)initWithStartPlotRange:(CPTPlotRange *)aStartPlotRange endPlotRange:(CPTPlotRange *)anEndPlotRange duration:(CGFloat)aDuration withDelay:(CGFloat)aDelay;
/// @}

@end

#pragma mark -

/** @category CPTAnimationPeriod(AbstractMethods)
 *  @brief CPTAnimationPeriod abstract methods—must be overridden by subclasses
 **/
@interface CPTAnimationPeriod(AbstractMethods)

/// @name Interpolation
/// @{
-(NSValue *)tweenedValueForProgress:(CGFloat)progress;
/// @}

@end

#pragma mark -

@interface CPTAnimation(CPTAnimationPeriodAdditions)

/// @name CGFloat Property Animation
/// @{
+(CPTAnimationOperation *)animate:(id)object property:(NSString *)property from:(CGFloat)from to:(CGFloat)to duration:(CGFloat)duration withDelay:(CGFloat)delay animationCurve:(CPTAnimationCurve)animationCurve delegate:(NSObject<CPTAnimationDelegate> *)delegate;
+(CPTAnimationOperation *)animate:(id)object property:(NSString *)property from:(CGFloat)from to:(CGFloat)to duration:(CGFloat)duration animationCurve:(CPTAnimationCurve)animationCurve delegate:(NSObject<CPTAnimationDelegate> *)delegate;
+(CPTAnimationOperation *)animate:(id)object property:(NSString *)property from:(CGFloat)from to:(CGFloat)to duration:(CGFloat)duration;
/// @}

/// @name CGPoint Property Animation
/// @{
+(CPTAnimationOperation *)animate:(id)object property:(NSString *)property fromPoint:(CGPoint)from toPoint:(CGPoint)to duration:(CGFloat)duration withDelay:(CGFloat)delay animationCurve:(CPTAnimationCurve)animationCurve delegate:(NSObject<CPTAnimationDelegate> *)delegate;
+(CPTAnimationOperation *)animate:(id)object property:(NSString *)property fromPoint:(CGPoint)from toPoint:(CGPoint)to duration:(CGFloat)duration animationCurve:(CPTAnimationCurve)animationCurve delegate:(NSObject<CPTAnimationDelegate> *)delegate;
+(CPTAnimationOperation *)animate:(id)object property:(NSString *)property fromPoint:(CGPoint)from toPoint:(CGPoint)to duration:(CGFloat)duration;
/// @}

/// @name CGSize Property Animation
/// @{
+(CPTAnimationOperation *)animate:(id)object property:(NSString *)property fromSize:(CGSize)from toSize:(CGSize)to duration:(CGFloat)duration withDelay:(CGFloat)delay animationCurve:(CPTAnimationCurve)animationCurve delegate:(NSObject<CPTAnimationDelegate> *)delegate;
+(CPTAnimationOperation *)animate:(id)object property:(NSString *)property fromSize:(CGSize)from toSize:(CGSize)to duration:(CGFloat)duration animationCurve:(CPTAnimationCurve)animationCurve delegate:(NSObject<CPTAnimationDelegate> *)delegate;
+(CPTAnimationOperation *)animate:(id)object property:(NSString *)property fromSize:(CGSize)from toSize:(CGSize)to duration:(CGFloat)duration;
/// @}

/// @name CGRect Property Animation
/// @{
+(CPTAnimationOperation *)animate:(id)object property:(NSString *)property fromRect:(CGRect)from toRect:(CGRect)to duration:(CGFloat)duration withDelay:(CGFloat)delay animationCurve:(CPTAnimationCurve)animationCurve delegate:(NSObject<CPTAnimationDelegate> *)delegate;
+(CPTAnimationOperation *)animate:(id)object property:(NSString *)property fromRect:(CGRect)from toRect:(CGRect)to duration:(CGFloat)duration animationCurve:(CPTAnimationCurve)animationCurve delegate:(NSObject<CPTAnimationDelegate> *)delegate;
+(CPTAnimationOperation *)animate:(id)object property:(NSString *)property fromRect:(CGRect)from toRect:(CGRect)to duration:(CGFloat)duration;
/// @}

/// @name NSDecimal Property Animation
/// @{
+(CPTAnimationOperation *)animate:(id)object property:(NSString *)property fromDecimal:(NSDecimal)from toDecimal:(NSDecimal)to duration:(CGFloat)duration withDelay:(CGFloat)delay animationCurve:(CPTAnimationCurve)animationCurve delegate:(NSObject<CPTAnimationDelegate> *)delegate;
+(CPTAnimationOperation *)animate:(id)object property:(NSString *)property fromDecimal:(NSDecimal)from toDecimal:(NSDecimal)to duration:(CGFloat)duration animationCurve:(CPTAnimationCurve)animationCurve delegate:(NSObject<CPTAnimationDelegate> *)delegate;
+(CPTAnimationOperation *)animate:(id)object property:(NSString *)property fromDecimal:(NSDecimal)from toDecimal:(NSDecimal)to duration:(CGFloat)duration;
/// @}

/// @name CPTPlotRange Property Animation
/// @{
+(CPTAnimationOperation *)animate:(id)object property:(NSString *)property fromPlotRange:(CPTPlotRange *)from toPlotRange:(CPTPlotRange *)to duration:(CGFloat)duration withDelay:(CGFloat)delay animationCurve:(CPTAnimationCurve)animationCurve delegate:(NSObject<CPTAnimationDelegate> *)delegate;
+(CPTAnimationOperation *)animate:(id)object property:(NSString *)property fromPlotRange:(CPTPlotRange *)from toPlotRange:(CPTPlotRange *)to duration:(CGFloat)duration animationCurve:(CPTAnimationCurve)animationCurve delegate:(NSObject<CPTAnimationDelegate> *)delegate;
+(CPTAnimationOperation *)animate:(id)object property:(NSString *)property fromPlotRange:(CPTPlotRange *)from toPlotRange:(CPTPlotRange *)to duration:(CGFloat)duration;
/// @}

@end
