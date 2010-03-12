//
//  GTMNSData+HexTest.m
//
//  Copyright 2009 Google Inc.
//
//  Licensed under the Apache License, Version 2.0 (the "License"); you may not
//  use this file except in compliance with the License.  You may obtain a copy
//  of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
//  WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.  See the
//  License for the specific language governing permissions and limitations under
//  the License.
//

#import "GTMSenTestCase.h"
#import "GTMNSData+Hex.h"

@interface GTMNSData_HexTest : GTMTestCase
@end

@implementation GTMNSData_HexTest

- (void)testNSDataHexAdditions {
  NSString *testString = @"1c2f0032f40123456789abcdef";
  char testBytes[] = { 0x1c, 0x2f, 0x00, 0x32, 0xf4, 0x01, 0x23,
                       0x45, 0x67, 0x89, 0xab, 0xcd, 0xef };
  NSData *testData = [NSData dataWithBytes:testBytes length:sizeof(testBytes)];

  STAssertTrue([[testData gtm_hexString] isEqual:testString],
               @"gtm_hexString doesn't encode as expected");

  STAssertEqualStrings([[NSData data] gtm_hexString], @"",
                       @"gtm_hexString empty data should return empty string");

  STAssertTrue([[NSData gtm_dataWithHexString:testString] isEqual:testData],
               @"gtm_dataWithHexString: doesn't decode as expected");

  STAssertNil([NSData gtm_dataWithHexString:@"1c2f003"],
              @"gtm_dataWithHexString: parsed hex from an odd size string");

  STAssertNil([NSData gtm_dataWithHexString:@"1c2f00ft"],
              @"gtm_dataWithHexString: parsed hex from a non hex string");

  STAssertNil([NSData gtm_dataWithHexString:@"abcdéf"],
              @"gtm_dataWithHexString: parsed a non-ASCII character");

  STAssertNotNil([NSData gtm_dataWithHexString:@""],
                 @"gtm_dataWithHexString: empty input resulted in nil output");

  STAssertNotNil([NSData gtm_dataWithHexString:nil],
                 @"gtm_dataWithHexString: nil input resulted in nil output");
}

@end
