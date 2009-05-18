//---------------------------------------------------------------------------------------
//  $Id: OCMockObjectTests.m 28 2008-06-19 22:37:17Z erik $
//  Copyright (c) 2004-2008 by Mulle Kybernetik. See License file for details.
//---------------------------------------------------------------------------------------

#import "OCMock.h"
#import <OCMock/OCMConstraint.h>
#import "OCMockObjectTests.h"

@protocol TestProtocol
- (int)primitiveValue;
@end

@protocol ProtocolWithTypeQualifierMethod
- (bycopy NSString *)byCopyString;
@end


@implementation OCMockObjectTests

- (void)setUp
{
	mock = [OCMockObject mockForClass:[NSString class]];
}


- (void)testAcceptsStubbedMethod
{
	[[mock stub] lowercaseString];
	[mock lowercaseString];
}


- (void)testRaisesExceptionWhenUnknownMethodIsCalled
{
	[[mock stub] lowercaseString];
	STAssertThrows([mock uppercaseString], @"Should have raised an exception.");
}


- (void)testAcceptsStubbedMethodWithSpecificArgument
{
	[[mock stub] hasSuffix:@"foo"];
	[mock hasSuffix:@"foo"];
}


- (void)testAcceptsStubbedMethodWithConstraint
{
	[[mock stub] hasSuffix:[OCMConstraint any]];
	[mock hasSuffix:@"foo"];
	[mock hasSuffix:@"bar"];
}


- (void)testAcceptsStubbedMethodWithNilArgument
{
	[[mock stub] hasSuffix:nil];
	
	[mock hasSuffix:nil];
}

- (void)testRaisesExceptionWhenMethodWithWrongArgumentIsCalled
{
	[[mock stub] hasSuffix:@"foo"];
	STAssertThrows([mock hasSuffix:@"xyz"], @"Should have raised an exception.");
}


- (void)testAcceptsStubbedMethodWithScalarArgument
{
	[[mock stub] stringByPaddingToLength:20 withString:@"foo" startingAtIndex:5];
	[mock stringByPaddingToLength:20 withString:@"foo" startingAtIndex:5];
}


- (void)testRaisesExceptionWhenMethodWithOneWrongScalarArgumentIsCalled
{
	[[mock stub] stringByPaddingToLength:20 withString:@"foo" startingAtIndex:5];
	STAssertThrows([mock stringByPaddingToLength:20 withString:@"foo" startingAtIndex:3], @"Should have raised an exception.");	
}

- (void)testAcceptsStubbedMethodWithVoidPointerArgument
{
	mock = [OCMockObject mockForClass:[NSMutableData class]];
	[[mock stub] appendBytes:NULL length:0];
	[mock appendBytes:NULL length:0];
}


- (void)testRaisesExceptionWhenMethodWithWrongVoidPointerArgumentIsCalled
{
	mock = [OCMockObject mockForClass:[NSMutableData class]];
	[[mock stub] appendBytes:"foo" length:3];
	STAssertThrows([mock appendBytes:"bar" length:3], @"Should have raised an exception.");
}


- (void)testAcceptsStubbedMethodWithPointerPointerArgument
{
	NSError *error = nil;
	[[mock stub] initWithContentsOfFile:@"foo.txt" encoding:NSASCIIStringEncoding error:&error];	
	[mock initWithContentsOfFile:@"foo.txt" encoding:NSASCIIStringEncoding error:&error];
}


- (void)testRaisesExceptionWhenMethodWithWrongPointerPointerArgumentIsCalled
{
	NSError *error = nil, *error2;
	[[mock stub] initWithContentsOfFile:@"foo.txt" encoding:NSASCIIStringEncoding error:&error];	
	STAssertThrows([mock initWithContentsOfFile:@"foo.txt" encoding:NSASCIIStringEncoding error:&error2], @"Should have raised.");
}


- (void)testAcceptsStubbedMethodWithStructArgument
{
    NSRange range = NSMakeRange(0,20);
	[[mock stub] substringWithRange:range];
	[mock substringWithRange:range];
}


- (void)testRaisesExceptionWhenMethodWithWrongStructArgumentIsCalled
{
    NSRange range = NSMakeRange(0,20);
    NSRange otherRange = NSMakeRange(0,10);
	[[mock stub] substringWithRange:range];
	STAssertThrows([mock substringWithRange:otherRange], @"Should have raised an exception.");	
}


- (void)testReturnsStubbedReturnValue
{
	id returnValue;  

	[[[mock stub] andReturn:@"megamock"] lowercaseString];
	returnValue = [mock lowercaseString];
	
	STAssertEqualObjects(@"megamock", returnValue, @"Should have returned stubbed value.");
	
}

- (void)testReturnsStubbedIntReturnValue
{
    int expectedValue = 42;
	[[[mock stub] andReturnValue:OCMOCK_VALUE(expectedValue)] intValue];
	int returnValue = [mock intValue];
    
	STAssertEquals(expectedValue, returnValue, @"Should have returned stubbed value.");
}


- (void)testRaisesWhenBoxedValueTypesDoNotMatch
{
    double expectedValue = 42;
	[[[mock stub] andReturnValue:OCMOCK_VALUE(expectedValue)] intValue];
    
	STAssertThrows([mock intValue], @"Should have raised an exception.");
}

- (void)testReturnsStubbedNilReturnValue
{
	[[[mock stub] andReturn:nil] uppercaseString];
	
	id returnValue = [mock uppercaseString];
	
	STAssertNil(returnValue, @"Should have returned stubbed value, which is nil.");
}

- (void)testReturnsStubbedByCopyReturnValue
{
	id myMock = [OCMockObject mockForProtocol:@protocol(ProtocolWithTypeQualifierMethod)];
	
	[[[myMock stub] andReturn:@"megamock"] byCopyString];
	
	STAssertEqualObjects(@"megamock", [myMock byCopyString], @"Should have returned stubbed value.");
}


- (void)testAcceptsExpectedMethod
{
	[[mock expect] lowercaseString];
	[mock lowercaseString];
}


- (void)testAcceptsExpectedMethodAndReturnsValue
{
	id returnValue;

	[[[mock expect] andReturn:@"Objective-C"] lowercaseString];
	returnValue = [mock lowercaseString];

	STAssertEqualObjects(@"Objective-C", returnValue, @"Should have returned stubbed value.");
}


- (void)testAcceptsExpectedMethodsInRecordedSequence
{
	[[mock expect] lowercaseString];
	[[mock expect] uppercaseString];
	
	[mock lowercaseString];
	[mock uppercaseString];
}


- (void)testAcceptsExpectedMethodsInDifferentSequence
{
	[[mock expect] lowercaseString];
	[[mock expect] uppercaseString];
	
	[mock uppercaseString];
	[mock lowercaseString];
}


- (void)testAcceptsAndVerifiesTwoExpectedInvocationsOfSameMethod
{
	[[mock expect] lowercaseString];
	[[mock expect] lowercaseString];
	
	[mock lowercaseString];
	[mock lowercaseString];
	
	[mock verify];
}


- (void)testAcceptsAndVerifiesTwoExpectedInvocationsOfSameMethodAndReturnsCorrespondingValues
{
	[[[mock expect] andReturn:@"foo"] lowercaseString];
	[[[mock expect] andReturn:@"bar"] lowercaseString];
	
	STAssertEqualObjects(@"foo", [mock lowercaseString], @"Should have returned first stubbed value");
	STAssertEqualObjects(@"bar", [mock lowercaseString], @"Should have returned seconds stubbed value");
	
	[mock verify];
}

- (void)testReturnsStubbedValuesIndependentOfExpectations
{
	[[mock stub] hasSuffix:@"foo"];
	[[mock expect] hasSuffix:@"bar"];
	
	[mock hasSuffix:@"foo"];
	[mock hasSuffix:@"bar"];
	[mock hasSuffix:@"foo"]; // Since it's a stub, shouldn't matter how many times we call this
	
	[mock verify];
}

- (void)testAcceptsAndVerifiesExpectedMethods
{
	[[mock expect] lowercaseString];
	[[mock expect] uppercaseString];
	
	[mock lowercaseString];
	[mock uppercaseString];
	
	[mock verify];
}


- (void)testRaisesExceptionOnVerifyWhenNotAllExpectedMethodsWereCalled
{
	[[mock expect] lowercaseString];
	[[mock expect] uppercaseString];
	
	[mock lowercaseString];

	STAssertThrows([mock verify], @"Should have raised an exception.");
}


- (void)testRaisesExceptionWhenAskedTo
{
	NSException *exception = [NSException exceptionWithName:@"TestException" reason:@"test" userInfo:nil];
	[[[mock expect] andThrow:exception] lowercaseString];
	
	STAssertThrows([mock lowercaseString], @"Should have raised an exception.");
}

- (void)testCanStubValueForKeyMethod
{
	id returnValue;
	
	mock = [OCMockObject mockForClass:[NSObject class]];
	[[[mock stub] andReturn:@"SomeValue"] valueForKey:@"SomeKey"];
	
	returnValue = [mock valueForKey:@"SomeKey"];
	
	STAssertEqualObjects(@"SomeValue", returnValue, @"Should have returned value that was set up.");
}


- (void)testCanMockFormalProtocol
{
	mock = [OCMockObject mockForProtocol:@protocol(NSLocking)];
	[[mock expect] lock];
	
	[mock lock];
	
	[mock verify];
}


- (void)testRaisesWhenUnknownMethodIsCalledOnProtocol
{
	mock = [OCMockObject mockForProtocol:@protocol(NSLocking)];
	STAssertThrows([mock lowercaseString], @"Should have raised an exception.");
}


- (void)testMockedProtocolConforms
{
	mock = [OCMockObject mockForProtocol:@protocol(NSLocking)];
	STAssertTrue([mock conformsToProtocol:@protocol(NSLocking)], nil);
}


- (void)testReturnsDefaultValueWhenUnknownMethodIsCalledOnNiceClassMock
{
	mock = [OCMockObject niceMockForClass:[NSString class]];
	STAssertNil([mock lowercaseString], @"Should return nil on unexpected method call (for nice mock).");	
	[mock verify];
}

- (void)testRaisesAnExceptionWhenAnExpectedMethodIsNotCalledOnNiceClassMock
{
	mock = [OCMockObject niceMockForClass:[NSString class]];	
	[[[mock expect] andReturn:@"HELLO!"] uppercaseString];
	STAssertThrows([mock verify], @"Should have raised an exception because method was not called.");
}

- (void)testReturnDefaultValueWhenUnknownMethodIsCalledOnProtocolMock
{
	mock = [OCMockObject niceMockForProtocol:@protocol(TestProtocol)];
	STAssertTrue(0 == [mock primitiveValue], @"Should return 0 on unexpected method call (for nice mock).");
	[mock verify];
}

- (void)testRaisesAnExceptionWenAnExpectedMethodIsNotCalledOnNiceProtocolMock
{
	mock = [OCMockObject niceMockForProtocol:@protocol(TestProtocol)];	
	[[mock expect] primitiveValue];
	STAssertThrows([mock verify], @"Should have raised an exception because method was not called.");
}

- (void)testReRaisesFailFastExceptionsOnVerify
{
	@try
	{
		[mock lowercaseString];
	}
	@catch(NSException *exception)
	{
		// expected
	}
	STAssertThrows([mock verify], @"Should have reraised the exception.");
}


/*
- (void)testCanMockInformalProtocol
{
	mock = [OCMockObject mock];
	NSArray *params = [NSArray arrayWithObject:@"steve"];
	[[mock expect] authenticationDataForComponents:params];
	
	[mock authenticationDataForComponents:params];
	
	[mock verify];
}
*/

- (void)testCanCreateExpectationsAfterInvocations
{
	[[mock expect] lowercaseString];
	[mock lowercaseString];
	[mock expect];
}


@end
