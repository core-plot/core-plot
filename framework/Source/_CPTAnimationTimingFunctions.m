#import "_CPTAnimationTimingFunctions.h"

#import "CPTDefinitions.h"
#import <tgmath.h>

// time should be between 0 and duration for all timing functions

#pragma mark Linear

/**
 *  @brief Computes a linear animation timing function.
 *  @param time The elapsed time of the animation between zero (@num{0}) and @par{duration}.
 *  @param duration The overall duration of the animation in seconds.
 *  @return The animation progress in the range zero (@num{0}) to one (@num{1}) at the given @par{time}.
 **/
CGFloat CPTAnimationTimingFunctionLinear(CGFloat time, CGFloat duration)
{
    if ( time <= CPTFloat(0.0) ) {
        return 0.0;
    }

    time /= duration;

    if ( time >= CPTFloat(1.0) ) {
        return 1.0;
    }

    return time;
}

#pragma mark -
#pragma mark Back

/**
 *  @brief Computes a backing in animation timing function.
 *  @param time The elapsed time of the animation between zero (@num{0}) and @par{duration}.
 *  @param duration The overall duration of the animation in seconds.
 *  @return The animation progress in the range zero (@num{0}) to one (@num{1}) at the given @par{time}.
 **/
CGFloat CPTAnimationTimingFunctionBackIn(CGFloat time, CGFloat duration)
{
    const CGFloat s = CPTFloat(1.70158);

    if ( time <= CPTFloat(0.0) ) {
        return 0.0;
    }

    time /= duration;

    if ( time >= CPTFloat(1.0) ) {
        return 1.0;
    }

    return time * time * ( ( s + CPTFloat(1.0) ) * time - s );
}

/**
 *  @brief Computes a backing out animation timing function.
 *  @param time The elapsed time of the animation between zero (@num{0}) and @par{duration}.
 *  @param duration The overall duration of the animation in seconds.
 *  @return The animation progress in the range zero (@num{0}) to one (@num{1}) at the given @par{time}.
 **/
CGFloat CPTAnimationTimingFunctionBackOut(CGFloat time, CGFloat duration)
{
    const CGFloat s = CPTFloat(1.70158);

    if ( time <= CPTFloat(0.0) ) {
        return 0.0;
    }

    time = time / duration - CPTFloat(1.0);

    if ( time >= CPTFloat(0.0) ) {
        return 1.0;
    }

    return time * time * ( ( s + CPTFloat(1.0) ) * time + s ) + CPTFloat(1.0);
}

/**
 *  @brief Computes a backing in and out animation timing function.
 *  @param time The elapsed time of the animation between zero (@num{0}) and @par{duration}.
 *  @param duration The overall duration of the animation in seconds.
 *  @return The animation progress in the range zero (@num{0}) to one (@num{1}) at the given @par{time}.
 **/
CGFloat CPTAnimationTimingFunctionBackInOut(CGFloat time, CGFloat duration)
{
    const CGFloat s = CPTFloat(1.70158 * 1.525);

    if ( time <= CPTFloat(0.0) ) {
        return 0.0;
    }

    time /= duration * CPTFloat(0.5);

    if ( time >= CPTFloat(2.0) ) {
        return 1.0;
    }

    if ( time < CPTFloat(1.0) ) {
        return CPTFloat(0.5) * ( time * time * ( ( s + CPTFloat(1.0) ) * time - s ) );
    }
    else {
        time -= 2.0;

        return CPTFloat(0.5) * ( time * time * ( ( s + CPTFloat(1.0) ) * time + s ) + CPTFloat(2.0) );
    }
}

#pragma mark -
#pragma mark Bounce

/**
 *  @brief Computes a bounce in animation timing function.
 *  @param time The elapsed time of the animation between zero (@num{0}) and @par{duration}.
 *  @param duration The overall duration of the animation in seconds.
 *  @return The animation progress in the range zero (@num{0}) to one (@num{1}) at the given @par{time}.
 **/
CGFloat CPTAnimationTimingFunctionBounceIn(CGFloat time, CGFloat duration)
{
    return CPTFloat(1.0) - CPTAnimationTimingFunctionBounceOut(duration - time, duration);
}

/**
 *  @brief Computes a bounce out animation timing function.
 *  @param time The elapsed time of the animation between zero (@num{0}) and @par{duration}.
 *  @param duration The overall duration of the animation in seconds.
 *  @return The animation progress in the range zero (@num{0}) to one (@num{1}) at the given @par{time}.
 **/
CGFloat CPTAnimationTimingFunctionBounceOut(CGFloat time, CGFloat duration)
{
    if ( time <= CPTFloat(0.0) ) {
        return 0.0;
    }

    time /= duration;

    if ( time >= CPTFloat(1.0) ) {
        return 1.0;
    }

    if ( time < CPTFloat(1.0 / 2.75) ) {
        return CPTFloat(7.5625) * time * time;
    }
    else if ( time < CPTFloat(2.0 / 2.75) ) {
        time -= (1.5 / 2.75);

        return CPTFloat(7.5625) * time * time + CPTFloat(0.75);
    }
    else if ( time < CPTFloat(2.5 / 2.75) ) {
        time -= (2.25 / 2.75);

        return CPTFloat(7.5625) * time * time + CPTFloat(0.9375);
    }
    else {
        time -= (2.625 / 2.75);

        return CPTFloat(7.5625) * time * time + CPTFloat(0.984375);
    }
}

/**
 *  @brief Computes a bounce in and out animation timing function.
 *  @param time The elapsed time of the animation between zero (@num{0}) and @par{duration}.
 *  @param duration The overall duration of the animation in seconds.
 *  @return The animation progress in the range zero (@num{0}) to one (@num{1}) at the given @par{time}.
 **/
CGFloat CPTAnimationTimingFunctionBounceInOut(CGFloat time, CGFloat duration)
{
    if ( time < duration * CPTFloat(0.5) ) {
        return CPTAnimationTimingFunctionBounceIn(time * CPTFloat(2.0), duration) * CPTFloat(0.5);
    }
    else {
        return CPTAnimationTimingFunctionBounceOut(time * CPTFloat(2.0) - duration, duration) * CPTFloat(0.5) +
               CPTFloat(0.5);
    }
}

#pragma mark -
#pragma mark Circular

/**
 *  @brief Computes a circular in animation timing function.
 *  @param time The elapsed time of the animation between zero (@num{0}) and @par{duration}.
 *  @param duration The overall duration of the animation in seconds.
 *  @return The animation progress in the range zero (@num{0}) to one (@num{1}) at the given @par{time}.
 **/
CGFloat CPTAnimationTimingFunctionCircularIn(CGFloat time, CGFloat duration)
{
    if ( time <= CPTFloat(0.0) ) {
        return 0.0;
    }

    time /= duration;

    if ( time >= CPTFloat(1.0) ) {
        return 1.0;
    }

    return -( sqrt(CPTFloat(1.0) - time * time) - CPTFloat(1.0) );
}

/**
 *  @brief Computes a circular out animation timing function.
 *  @param time The elapsed time of the animation between zero (@num{0}) and @par{duration}.
 *  @param duration The overall duration of the animation in seconds.
 *  @return The animation progress in the range zero (@num{0}) to one (@num{1}) at the given @par{time}.
 **/
CGFloat CPTAnimationTimingFunctionCircularOut(CGFloat time, CGFloat duration)
{
    if ( time <= CPTFloat(0.0) ) {
        return 0.0;
    }

    time = time / duration - CPTFloat(1.0);

    if ( time >= CPTFloat(0.0) ) {
        return 1.0;
    }

    return sqrt(CPTFloat(1.0) - time * time);
}

/**
 *  @brief Computes a circular in and out animation timing function.
 *  @param time The elapsed time of the animation between zero (@num{0}) and @par{duration}.
 *  @param duration The overall duration of the animation in seconds.
 *  @return The animation progress in the range zero (@num{0}) to one (@num{1}) at the given @par{time}.
 **/
CGFloat CPTAnimationTimingFunctionCircularInOut(CGFloat time, CGFloat duration)
{
    if ( time <= CPTFloat(0.0) ) {
        return 0.0;
    }

    time /= duration * CPTFloat(0.5);

    if ( time >= CPTFloat(2.0) ) {
        return 1.0;
    }

    if ( time < CPTFloat(1.0) ) {
        return -CPTFloat(0.5) * ( sqrt(CPTFloat(1.0) - time * time) - CPTFloat(1.0) );
    }
    else {
        time -= 2.0;

        return CPTFloat(0.5) * ( sqrt(CPTFloat(1.0) - time * time) + CPTFloat(1.0) );
    }
}

#pragma mark -
#pragma mark Elastic

/**
 *  @brief Computes a elastic in animation timing function.
 *  @param time The elapsed time of the animation between zero (@num{0}) and @par{duration}.
 *  @param duration The overall duration of the animation in seconds.
 *  @return The animation progress in the range zero (@num{0}) to one (@num{1}) at the given @par{time}.
 **/
CGFloat CPTAnimationTimingFunctionElasticIn(CGFloat time, CGFloat duration)
{
    if ( time <= CPTFloat(0.0) ) {
        return 0.0;
    }

    time /= duration;

    if ( time >= CPTFloat(1.0) ) {
        return 1.0;
    }

    CGFloat period = duration * CPTFloat(0.3);
    CGFloat s      = period * CPTFloat(0.25);

    time -= 1.0;

    return -( pow(CPTFloat(2.0), CPTFloat(10.0) * time) * sin( (time * duration - s) * CPTFloat(2.0 * M_PI) / period ) );
}

/**
 *  @brief Computes a elastic out animation timing function.
 *  @param time The elapsed time of the animation between zero (@num{0}) and @par{duration}.
 *  @param duration The overall duration of the animation in seconds.
 *  @return The animation progress in the range zero (@num{0}) to one (@num{1}) at the given @par{time}.
 **/
CGFloat CPTAnimationTimingFunctionElasticOut(CGFloat time, CGFloat duration)
{
    if ( time <= CPTFloat(0.0) ) {
        return 0.0;
    }

    time /= duration;

    if ( time >= CPTFloat(1.0) ) {
        return 1.0;
    }

    CGFloat period = duration * CPTFloat(0.3);
    CGFloat s      = period * CPTFloat(0.25);

    return pow(CPTFloat(2.0), CPTFloat(-10.0) * time) * sin( (time * duration - s) * CPTFloat(2.0 * M_PI) / period ) + CPTFloat(1.0);
}

/**
 *  @brief Computes a elastic in and out animation timing function.
 *  @param time The elapsed time of the animation between zero (@num{0}) and @par{duration}.
 *  @param duration The overall duration of the animation in seconds.
 *  @return The animation progress in the range zero (@num{0}) to one (@num{1}) at the given @par{time}.
 **/
CGFloat CPTAnimationTimingFunctionElasticInOut(CGFloat time, CGFloat duration)
{
    if ( time <= CPTFloat(0.0) ) {
        return 0.0;
    }

    time /= duration * CPTFloat(0.5);

    if ( time >= CPTFloat(2.0) ) {
        return 1.0;
    }

    CGFloat period = duration * CPTFloat(0.3 * 1.5);
    CGFloat s      = period * CPTFloat(0.25);

    time -= 1.0;

    if ( time < CPTFloat(0.0) ) {
        return -CPTFloat(0.5) * ( pow(CPTFloat(2.0), CPTFloat(10.0) * time) * sin( (time * duration - s) * CPTFloat(2.0 * M_PI) / period ) );
    }
    else {
        return pow(CPTFloat(2.0), CPTFloat(-10.0) * time) * sin( (time * duration - s) * CPTFloat(2.0 * M_PI) / period ) * CPTFloat(0.5) + CPTFloat(1.0);
    }
}

#pragma mark -
#pragma mark Exponential

/**
 *  @brief Computes a exponential in animation timing function.
 *  @param time The elapsed time of the animation between zero (@num{0}) and @par{duration}.
 *  @param duration The overall duration of the animation in seconds.
 *  @return The animation progress in the range zero (@num{0}) to one (@num{1}) at the given @par{time}.
 **/
CGFloat CPTAnimationTimingFunctionExponentialIn(CGFloat time, CGFloat duration)
{
    if ( time <= CPTFloat(0.0) ) {
        return 0.0;
    }

    time /= duration;

    if ( time >= CPTFloat(1.0) ) {
        return 1.0;
    }

    return pow( CPTFloat(2.0), CPTFloat(10.0) * ( time - CPTFloat(1.0) ) );
}

/**
 *  @brief Computes a exponential out animation timing function.
 *  @param time The elapsed time of the animation between zero (@num{0}) and @par{duration}.
 *  @param duration The overall duration of the animation in seconds.
 *  @return The animation progress in the range zero (@num{0}) to one (@num{1}) at the given @par{time}.
 **/
CGFloat CPTAnimationTimingFunctionExponentialOut(CGFloat time, CGFloat duration)
{
    if ( time <= CPTFloat(0.0) ) {
        return 0.0;
    }

    time /= duration;

    if ( time >= CPTFloat(1.0) ) {
        return 1.0;
    }

    return -pow(CPTFloat(2.0), CPTFloat(-10.0) * time) + CPTFloat(1.0);
}

/**
 *  @brief Computes a exponential in and out animation timing function.
 *  @param time The elapsed time of the animation between zero (@num{0}) and @par{duration}.
 *  @param duration The overall duration of the animation in seconds.
 *  @return The animation progress in the range zero (@num{0}) to one (@num{1}) at the given @par{time}.
 **/
CGFloat CPTAnimationTimingFunctionExponentialInOut(CGFloat time, CGFloat duration)
{
    if ( time <= CPTFloat(0.0) ) {
        return 0.0;
    }

    time /= duration * CPTFloat(0.5);
    time -= 1.0;

    if ( time >= 1.0 ) {
        return 1.0;
    }

    if ( time < CPTFloat(0.0) ) {
        return CPTFloat(0.5) * pow(CPTFloat(2.0), CPTFloat(10.0) * time);
    }
    else {
        return CPTFloat(0.5) * ( -pow(CPTFloat(2.0), CPTFloat(-10.0) * time) + CPTFloat(2.0) );
    }
}

#pragma mark -
#pragma mark Sinusoidal

/**
 *  @brief Computes a sinusoidal in animation timing function.
 *  @param time The elapsed time of the animation between zero (@num{0}) and @par{duration}.
 *  @param duration The overall duration of the animation in seconds.
 *  @return The animation progress in the range zero (@num{0}) to one (@num{1}) at the given @par{time}.
 **/
CGFloat CPTAnimationTimingFunctionSinusoidalIn(CGFloat time, CGFloat duration)
{
    if ( time <= CPTFloat(0.0) ) {
        return 0.0;
    }

    time /= duration;

    if ( time >= CPTFloat(1.0) ) {
        return 1.0;
    }

    return -cos( time * CPTFloat(M_PI_2) ) + CPTFloat(1.0);
}

/**
 *  @brief Computes a sinusoidal out animation timing function.
 *  @param time The elapsed time of the animation between zero (@num{0}) and @par{duration}.
 *  @param duration The overall duration of the animation in seconds.
 *  @return The animation progress in the range zero (@num{0}) to one (@num{1}) at the given @par{time}.
 **/
CGFloat CPTAnimationTimingFunctionSinusoidalOut(CGFloat time, CGFloat duration)
{
    if ( time <= CPTFloat(0.0) ) {
        return 0.0;
    }

    time /= duration;

    if ( time >= CPTFloat(1.0) ) {
        return 1.0;
    }

    return sin( time * CPTFloat(M_PI_2) );
}

/**
 *  @brief Computes a sinusoidal in and out animation timing function.
 *  @param time The elapsed time of the animation between zero (@num{0}) and @par{duration}.
 *  @param duration The overall duration of the animation in seconds.
 *  @return The animation progress in the range zero (@num{0}) to one (@num{1}) at the given @par{time}.
 **/
CGFloat CPTAnimationTimingFunctionSinusoidalInOut(CGFloat time, CGFloat duration)
{
    if ( time <= CPTFloat(0.0) ) {
        return 0.0;
    }

    time /= duration;

    if ( time >= CPTFloat(1.0) ) {
        return 1.0;
    }

    return -CPTFloat(0.5) * ( cos(CPTFloat(M_PI) * time) - CPTFloat(1.0) );
}

#pragma mark -
#pragma mark Cubic

/**
 *  @brief Computes a cubic in animation timing function.
 *  @param time The elapsed time of the animation between zero (@num{0}) and @par{duration}.
 *  @param duration The overall duration of the animation in seconds.
 *  @return The animation progress in the range zero (@num{0}) to one (@num{1}) at the given @par{time}.
 **/
CGFloat CPTAnimationTimingFunctionCubicIn(CGFloat time, CGFloat duration)
{
    if ( time <= CPTFloat(0.0) ) {
        return 0.0;
    }

    time /= duration;

    if ( time >= CPTFloat(1.0) ) {
        return 1.0;
    }

    return time * time * time;
}

/**
 *  @brief Computes a cubic out animation timing function.
 *  @param time The elapsed time of the animation between zero (@num{0}) and @par{duration}.
 *  @param duration The overall duration of the animation in seconds.
 *  @return The animation progress in the range zero (@num{0}) to one (@num{1}) at the given @par{time}.
 **/
CGFloat CPTAnimationTimingFunctionCubicOut(CGFloat time, CGFloat duration)
{
    if ( time <= CPTFloat(0.0) ) {
        return 0.0;
    }

    time = time / duration - CPTFloat(1.0);

    if ( time >= CPTFloat(0.0) ) {
        return 1.0;
    }

    return time * time * time + CPTFloat(1.0);
}

/**
 *  @brief Computes a cubic in and out animation timing function.
 *  @param time The elapsed time of the animation between zero (@num{0}) and @par{duration}.
 *  @param duration The overall duration of the animation in seconds.
 *  @return The animation progress in the range zero (@num{0}) to one (@num{1}) at the given @par{time}.
 **/
CGFloat CPTAnimationTimingFunctionCubicInOut(CGFloat time, CGFloat duration)
{
    if ( time <= CPTFloat(0.0) ) {
        return 0.0;
    }

    time /= duration * CPTFloat(0.5);

    if ( time >= CPTFloat(2.0) ) {
        return 1.0;
    }

    if ( time < CPTFloat(1.0) ) {
        return CPTFloat(0.5) * time * time * time;
    }
    else {
        time -= 2.0;

        return CPTFloat(0.5) * ( time * time * time + CPTFloat(2.0) );
    }
}

#pragma mark -
#pragma mark Quadratic

/**
 *  @brief Computes a quadratic in animation timing function.
 *  @param time The elapsed time of the animation between zero (@num{0}) and @par{duration}.
 *  @param duration The overall duration of the animation in seconds.
 *  @return The animation progress in the range zero (@num{0}) to one (@num{1}) at the given @par{time}.
 **/
CGFloat CPTAnimationTimingFunctionQuadraticIn(CGFloat time, CGFloat duration)
{
    if ( time <= CPTFloat(0.0) ) {
        return 0.0;
    }

    time /= duration;

    if ( time >= CPTFloat(1.0) ) {
        return 1.0;
    }

    return time * time;
}

/**
 *  @brief Computes a quadratic out animation timing function.
 *  @param time The elapsed time of the animation between zero (@num{0}) and @par{duration}.
 *  @param duration The overall duration of the animation in seconds.
 *  @return The animation progress in the range zero (@num{0}) to one (@num{1}) at the given @par{time}.
 **/
CGFloat CPTAnimationTimingFunctionQuadraticOut(CGFloat time, CGFloat duration)
{
    if ( time <= CPTFloat(0.0) ) {
        return 0.0;
    }

    time /= duration;

    if ( time >= CPTFloat(1.0) ) {
        return 1.0;
    }

    return -time * ( time - CPTFloat(2.0) );
}

/**
 *  @brief Computes a quadratic in and out animation timing function.
 *  @param time The elapsed time of the animation between zero (@num{0}) and @par{duration}.
 *  @param duration The overall duration of the animation in seconds.
 *  @return The animation progress in the range zero (@num{0}) to one (@num{1}) at the given @par{time}.
 **/
CGFloat CPTAnimationTimingFunctionQuadraticInOut(CGFloat time, CGFloat duration)
{
    if ( time <= CPTFloat(0.0) ) {
        return 0.0;
    }

    time /= duration * CPTFloat(0.5);

    if ( time >= CPTFloat(2.0) ) {
        return 1.0;
    }

    if ( time < CPTFloat(1.0) ) {
        return CPTFloat(0.5) * time * time;
    }
    else {
        time -= 1.0;

        return -CPTFloat(0.5) * ( time * ( time - CPTFloat(2.0) ) - CPTFloat(1.0) );
    }
}

#pragma mark -
#pragma mark Quartic

/**
 *  @brief Computes a quartic in animation timing function.
 *  @param time The elapsed time of the animation between zero (@num{0}) and @par{duration}.
 *  @param duration The overall duration of the animation in seconds.
 *  @return The animation progress in the range zero (@num{0}) to one (@num{1}) at the given @par{time}.
 **/
CGFloat CPTAnimationTimingFunctionQuarticIn(CGFloat time, CGFloat duration)
{
    if ( time <= CPTFloat(0.0) ) {
        return 0.0;
    }

    time /= duration;

    if ( time >= CPTFloat(1.0) ) {
        return 1.0;
    }

    return time * time * time * time;
}

/**
 *  @brief Computes a quartic out animation timing function.
 *  @param time The elapsed time of the animation between zero (@num{0}) and @par{duration}.
 *  @param duration The overall duration of the animation in seconds.
 *  @return The animation progress in the range zero (@num{0}) to one (@num{1}) at the given @par{time}.
 **/
CGFloat CPTAnimationTimingFunctionQuarticOut(CGFloat time, CGFloat duration)
{
    if ( time <= CPTFloat(0.0) ) {
        return 0.0;
    }

    time = time / duration - CPTFloat(1.0);

    if ( time >= CPTFloat(0.0) ) {
        return 1.0;
    }

    return -( time * time * time * time - CPTFloat(1.0) );
}

/**
 *  @brief Computes a quartic in and out animation timing function.
 *  @param time The elapsed time of the animation between zero (@num{0}) and @par{duration}.
 *  @param duration The overall duration of the animation in seconds.
 *  @return The animation progress in the range zero (@num{0}) to one (@num{1}) at the given @par{time}.
 **/
CGFloat CPTAnimationTimingFunctionQuarticInOut(CGFloat time, CGFloat duration)
{
    if ( time <= CPTFloat(0.0) ) {
        return 0.0;
    }

    time /= duration * CPTFloat(0.5);

    if ( time >= CPTFloat(2.0) ) {
        return 1.0;
    }

    if ( time < CPTFloat(1.0) ) {
        return CPTFloat(0.5) * time * time * time * time;
    }
    else {
        time -= 2.0;

        return -CPTFloat(0.5) * ( time * time * time * time - CPTFloat(2.0) );
    }
}

#pragma mark -
#pragma mark Quintic

/**
 *  @brief Computes a quintic in animation timing function.
 *  @param time The elapsed time of the animation between zero (@num{0}) and @par{duration}.
 *  @param duration The overall duration of the animation in seconds.
 *  @return The animation progress in the range zero (@num{0}) to one (@num{1}) at the given @par{time}.
 **/
CGFloat CPTAnimationTimingFunctionQuinticIn(CGFloat time, CGFloat duration)
{
    if ( time <= CPTFloat(0.0) ) {
        return 0.0;
    }

    time /= duration;

    if ( time >= CPTFloat(1.0) ) {
        return 1.0;
    }

    return time * time * time * time * time;
}

/**
 *  @brief Computes a quintic out animation timing function.
 *  @param time The elapsed time of the animation between zero (@num{0}) and @par{duration}.
 *  @param duration The overall duration of the animation in seconds.
 *  @return The animation progress in the range zero (@num{0}) to one (@num{1}) at the given @par{time}.
 **/
CGFloat CPTAnimationTimingFunctionQuinticOut(CGFloat time, CGFloat duration)
{
    if ( time <= CPTFloat(0.0) ) {
        return 0.0;
    }

    time = time / duration - CPTFloat(1.0);

    if ( time >= CPTFloat(0.0) ) {
        return 1.0;
    }

    return time * time * time * time * time + CPTFloat(1.0);
}

/**
 *  @brief Computes a quintic in and out animation timing function.
 *  @param time The elapsed time of the animation between zero (@num{0}) and @par{duration}.
 *  @param duration The overall duration of the animation in seconds.
 *  @return The animation progress in the range zero (@num{0}) to one (@num{1}) at the given @par{time}.
 **/
CGFloat CPTAnimationTimingFunctionQuinticInOut(CGFloat time, CGFloat duration)
{
    if ( time <= CPTFloat(0.0) ) {
        return 0.0;
    }

    time /= duration * CPTFloat(0.5);

    if ( time >= CPTFloat(2.0) ) {
        return 1.0;
    }

    if ( time < CPTFloat(1.0) ) {
        return CPTFloat(0.5) * time * time * time * time * time;
    }
    else {
        time -= 2.0;

        return CPTFloat(0.5) * ( time * time * time * time * time + CPTFloat(2.0) );
    }
}
