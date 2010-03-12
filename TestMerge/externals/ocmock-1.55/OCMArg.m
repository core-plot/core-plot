//---------------------------------------------------------------------------------------
//  $Id: $
//  Copyright (c) 2009 by Mulle Kybernetik. See License file for details.
//---------------------------------------------------------------------------------------

#import <OCMock/OCMArg.h>
#import <OCMock/OCMConstraint.h>
#import "OCMPassByRefSetter.h"

@implementation OCMArg

+ (id)any
{
	return [OCMAnyConstraint constraint];
}

+ (void *)anyPointer
{
	return (void *)0x01234567;
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

+ (id)checkWithSelector:(SEL)selector onObject:(id)anObject
{
	return [OCMConstraint constraintWithSelector:selector onObject:anObject];
}

+ (id *)setTo:(id)value;
{
	return (id *)[[OCMPassByRefSetter alloc] initWithValue:value];
}

+ (id)resolveSpecialValues:(NSValue *)value
{
	const char *type = [value objCType];
	if(type[0] == '^')
	{
		void *pointer = [value pointerValue];
		if(pointer == (void *)0x01234567)
			return [OCMArg any];
		if((pointer != NULL) && (((id)pointer)->isa == [OCMPassByRefSetter class]))
			return (id)pointer;
	}
	return value;
}

@end
