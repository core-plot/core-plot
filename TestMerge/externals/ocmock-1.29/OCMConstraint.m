//---------------------------------------------------------------------------------------
//  $Id: $
//  Copyright (c) 2007-2008 by Mulle Kybernetik. See License file for details.
//---------------------------------------------------------------------------------------

#import <OCMock/OCMConstraint.h>

//---------------------------------------------------------------------------------------
//	OCMAnyConstraint
//---------------------------------------------------------------------------------------

@interface OCMAnyConstraint : OCMConstraint
@end

@implementation OCMAnyConstraint

- (BOOL)evaluate:(id)value
{
	return YES;
}

@end


//---------------------------------------------------------------------------------------
//	OCMIsNilConstraint
//---------------------------------------------------------------------------------------

@interface OCMIsNilConstraint : OCMConstraint
@end

@implementation OCMIsNilConstraint

- (BOOL)evaluate:(id)value
{
	return value == nil;
}

@end


//---------------------------------------------------------------------------------------
//	OCMIsNotNilConstraint
//---------------------------------------------------------------------------------------

@interface OCMIsNotNilConstraint : OCMConstraint
@end

@implementation OCMIsNotNilConstraint

- (BOOL)evaluate:(id)value
{
	return value != nil;
}

@end


//---------------------------------------------------------------------------------------
//	OCMIsNotEqualConstraint
//---------------------------------------------------------------------------------------

@interface OCMIsNotEqualConstraint : OCMConstraint
{
	@public
	id testValue;
}

@end

@implementation OCMIsNotEqualConstraint

- (BOOL)evaluate:(id)value
{
	return ![value isEqualTo:testValue];
}

@end


//---------------------------------------------------------------------------------------
//	OCMInvocationConstraint
//---------------------------------------------------------------------------------------

@interface OCMInvocationConstraint : OCMConstraint
{
	@public
	NSInvocation *invocation;
}

@end

@implementation OCMInvocationConstraint

- (BOOL)evaluate:(id)value
{
	[invocation setArgument:&value atIndex:2]; // should test if constraint takes arg
	[invocation invoke];
	BOOL returnValue;
	[invocation getReturnValue:&returnValue];
	return returnValue;
}

@end


//---------------------------------------------------------------------------------------
//	OCMConstraint
//---------------------------------------------------------------------------------------

@implementation OCMConstraint

+ (id)constraint
{
	return [[[self alloc] init] autorelease];
}


- (BOOL)checkAny:(id)theArg
{
	return YES;
}

- (BOOL)checkNil:(id)theArg
{
	return theArg == nil;
}

- (BOOL)checkNotNil:(id)theArg
{
	return ![self checkNil:theArg];
}


+ (id)any
{
	return [OCMAnyConstraint constraint];
}

+ (id)isNil
{
	return [OCMIsNilConstraint constraint];
}

+ (id)isNotNil
{
	return [OCMIsNotNilConstraint constraint];
}

+ (id)isNotEqual:(id)value
{
	OCMIsNotEqualConstraint *constraint = [OCMIsNotEqualConstraint constraint];
	constraint->testValue = value;
	return constraint;
}

+ (id)constraintWithSelector:(SEL)aSelector onObject:(id)anObject
{
	OCMInvocationConstraint *constraint = [OCMInvocationConstraint constraint];
	NSMethodSignature *signature = [anObject methodSignatureForSelector:aSelector]; 
	if(signature == nil)
		[NSException raise:NSInvalidArgumentException format:@"Unkown selector %@ used in constraint.", NSStringFromSelector(aSelector)];
	NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
	[invocation setTarget:anObject];
	[invocation setSelector:aSelector];
	constraint->invocation = invocation;
	return constraint;
}

+ (id)constraintWithSelector:(SEL)aSelector onObject:(id)anObject withValue:(id)aValue
{
	OCMInvocationConstraint *constraint = [self constraintWithSelector:aSelector onObject:anObject];
	if([[constraint->invocation methodSignature] numberOfArguments] < 4)
		[NSException raise:NSInvalidArgumentException format:@"Constraint with value requires selector with two arguments."];
	[constraint->invocation setArgument:&aValue atIndex:3];
	return constraint;
}

- (BOOL)evaluate:(id)value
{
	return NO;
}

@end

