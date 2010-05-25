//
//  GTMNSData+Hex.h
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


// WARNING: This class provides a subset of the functionality available in
// GTMStringEncoding and may go away in the future.
// Please consider using GTMStringEncoding instead.


#import <Foundation/Foundation.h>

/// Helpers for dealing w/ hex encoded strings.
@interface NSData (GTMHexAdditions)

/// Return an autoreleased NSData w/ the result of decoding |hexString| to
/// binary data.
///
/// Will return |nil| if |hexString| contains any non-hex characters (i.e.
/// 0-9, a-f, A-F) or if the length of |hexString| is not cleanly divisible by
/// two.
/// Leading 0x prefix is not supported and will result in a |nil| return value.
+ (NSData *)gtm_dataWithHexString:(NSString *)hexString;

/// Return an autoreleased NSString w/ the result of encoding the NSData bytes
/// as hex. No leading 0x prefix is included.
- (NSString *)gtm_hexString;

@end
