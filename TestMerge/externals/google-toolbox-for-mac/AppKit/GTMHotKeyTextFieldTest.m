//  GTMHotKeyTextFieldTest.m
//
//  Copyright 2006-2008 Google Inc.
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

#import "GTMHotKeyTextFieldTest.h"
#import "GTMHotKeyTextField.h"
#import "GTMSenTestCase.h"
#import "GTMUnitTestDevLog.h"
#import <Carbon/Carbon.h>

@interface GTMHotKeyTextField (PrivateMethods)
// Private methods which we want to access to test
+ (BOOL)isValidHotKey:(NSDictionary *)hotKey;
+ (NSString *)displayStringForHotKey:(NSDictionary *)hotKey;
@end

@interface GTMHotKeyTextFieldTest : GTMTestCase {
 @private
  GTMHotKeyTextFieldTestController *controller_;
  NSMutableDictionary *hotkeyValues_;
}
- (NSDictionary *)hotkeyValues;
- (void)setHotkeyValues:(NSDictionary*)values;
@end

@implementation GTMHotKeyTextFieldTest

- (void)setUp {
  controller_ = [[GTMHotKeyTextFieldTestController alloc] init];
  hotkeyValues_ 
    = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
       [NSNumber numberWithInt:NSCommandKeyMask], kGTMHotKeyModifierFlagsKey,
       [NSNumber numberWithInt:42], kGTMHotKeyKeyCodeKey,
       [NSNumber numberWithBool:NO], kGTMHotKeyDoubledModifierKey,
       nil];
  STAssertNotNil(hotkeyValues_, nil);
  STAssertNotNil(controller_, nil);
  STAssertNotNil([controller_ window], nil);
}

- (void)tearDown {
  [controller_ close];
  [controller_ release];
  [hotkeyValues_ release];
}

- (NSDictionary *)hotkeyValues {
  return hotkeyValues_;
}

- (void)setHotkeyValues:(NSDictionary*)values {
  [hotkeyValues_ autorelease];
  hotkeyValues_ = [values mutableCopy];
}

- (void)testStringForModifierFlags {
  
  // Make sure only the flags we expect generate things in their strings
  STAssertEquals([[GTMHotKeyTextField stringForModifierFlags:NSAlphaShiftKeyMask] length],
                 (NSUInteger)0, nil);
  STAssertEquals([[GTMHotKeyTextField stringForModifierFlags:NSShiftKeyMask] length],
                 (NSUInteger)1, nil);
  STAssertEquals([[GTMHotKeyTextField stringForModifierFlags:NSControlKeyMask] length],
                 (NSUInteger)1, nil);
  STAssertEquals([[GTMHotKeyTextField stringForModifierFlags:NSAlternateKeyMask] length],
                 (NSUInteger)1, nil);
  STAssertEquals([[GTMHotKeyTextField stringForModifierFlags:NSCommandKeyMask] length],
                 (NSUInteger)1, nil);
  STAssertEquals([[GTMHotKeyTextField stringForModifierFlags:NSNumericPadKeyMask] length],
                 (NSUInteger)0, nil);
  STAssertEquals([[GTMHotKeyTextField stringForModifierFlags:NSHelpKeyMask] length],
                 (NSUInteger)0, nil);
  STAssertEquals([[GTMHotKeyTextField stringForModifierFlags:NSFunctionKeyMask] length],
                 (NSUInteger)0, nil);
  
  // And some quick checks combining flags to make sure the string gets longer
  STAssertEquals([[GTMHotKeyTextField stringForModifierFlags:(NSShiftKeyMask |
                                                        NSAlternateKeyMask)] length],
                 (NSUInteger)2, nil);
  STAssertEquals([[GTMHotKeyTextField stringForModifierFlags:(NSShiftKeyMask |
                                                        NSAlternateKeyMask |
                                                        NSCommandKeyMask)] length],
                 (NSUInteger)3, nil);
  STAssertEquals([[GTMHotKeyTextField stringForModifierFlags:(NSShiftKeyMask |
                                                        NSAlternateKeyMask |
                                                        NSCommandKeyMask |
                                                        NSControlKeyMask)] length],
                 (NSUInteger)4, nil);
  
}

- (void)testStringForKeycode_useGlyph_resourceBundle {
  NSBundle *bundle = [NSBundle bundleForClass:[self class]];
  STAssertNotNil(bundle, @"failed to get our bundle?");
  NSString *str;
  
  // We need a better test, but for now, we'll just loop through things we know
  // we handle.
  
  // TODO: we need to force the pre leopard code path during tests.

  UInt16 testData[] = {
    123, 124, 125, 126, 122, 120, 99, 118, 96, 97, 98, 100, 101, 109, 103, 111,
    105, 107, 113, 106, 117, 36, 76, 48, 49, 51, 71, 53, 115, 116, 119, 121,
    114, 65, 67, 69, 75, 78, 81, 82, 83, 84, 85, 86, 87, 88, 89, 91, 92,
  };
  for (int useGlyph = 0 ; useGlyph < 2 ; ++useGlyph) {
    for (size_t i = 0; i < (sizeof(testData) / sizeof(UInt16)); ++i) {
      UInt16 keycode = testData[i];
      
      str = [GTMHotKeyTextField stringForKeycode:keycode
                                        useGlyph:useGlyph
                                  resourceBundle:bundle];
      STAssertNotNil(str,
                     @"failed to get a string for keycode %u (useGlyph:%@)",
                     keycode, (useGlyph ? @"YES" : @"NO"));
      STAssertGreaterThan([str length], (NSUInteger)0,
                          @"got an empty string for keycode %u (useGlyph:%@)",
                          keycode, (useGlyph ? @"YES" : @"NO"));
    }
  }
}

- (void)testGTMHotKeyPrettyString {
  NSDictionary *hkDict;
  
  hkDict = [NSDictionary dictionaryWithObjectsAndKeys:
            [NSNumber numberWithBool:NO],
            kGTMHotKeyDoubledModifierKey,
            [NSNumber numberWithUnsignedInt:114],
            kGTMHotKeyKeyCodeKey,
            [NSNumber numberWithUnsignedInt:NSCommandKeyMask],
            kGTMHotKeyModifierFlagsKey,
            nil];
  STAssertNotNil(hkDict, nil);
  STAssertNotNil([GTMHotKeyTextField displayStringForHotKey:hkDict], nil);
  
  hkDict = [NSDictionary dictionaryWithObjectsAndKeys:
            [NSNumber numberWithUnsignedInt:114],
            kGTMHotKeyKeyCodeKey,
            [NSNumber numberWithUnsignedInt:NSCommandKeyMask],
            kGTMHotKeyModifierFlagsKey,
            nil];
  STAssertNotNil(hkDict, nil);
  STAssertNotNil([GTMHotKeyTextField displayStringForHotKey:hkDict], nil);

  hkDict = [NSDictionary dictionaryWithObjectsAndKeys:
            [NSNumber numberWithBool:NO],
            kGTMHotKeyDoubledModifierKey,
            [NSNumber numberWithUnsignedInt:NSCommandKeyMask],
            kGTMHotKeyModifierFlagsKey,
            nil];
  STAssertNotNil(hkDict, nil);
  STAssertNil([GTMHotKeyTextField displayStringForHotKey:hkDict], nil);
  
  hkDict = [NSDictionary dictionaryWithObjectsAndKeys:
            [NSNumber numberWithBool:NO],
            kGTMHotKeyDoubledModifierKey,
            [NSNumber numberWithUnsignedInt:'A'],
            kGTMHotKeyKeyCodeKey,
            nil];
  STAssertNotNil(hkDict, nil);
  STAssertNil([GTMHotKeyTextField displayStringForHotKey:hkDict], nil);
  
  hkDict = [NSDictionary dictionary];
  STAssertNotNil(hkDict, nil);
  STAssertNil([GTMHotKeyTextField displayStringForHotKey:hkDict], nil);

  STAssertNil([GTMHotKeyTextField displayStringForHotKey:nil], nil);
  
}

- (void)testGTMHotKeyDictionaryAppearsValid {
  NSDictionary *hkDict;

  hkDict = [NSDictionary dictionaryWithObjectsAndKeys:
            [NSNumber numberWithBool:NO],
            kGTMHotKeyDoubledModifierKey,
            [NSNumber numberWithUnsignedInt:114],
            kGTMHotKeyKeyCodeKey,
            [NSNumber numberWithUnsignedInt:NSCommandKeyMask],
            kGTMHotKeyModifierFlagsKey,
            nil];
  STAssertNotNil(hkDict, nil);
  STAssertTrue([GTMHotKeyTextField isValidHotKey:hkDict], nil);
  
  hkDict = [NSDictionary dictionaryWithObjectsAndKeys:
            [NSNumber numberWithUnsignedInt:114],
            kGTMHotKeyKeyCodeKey,
            [NSNumber numberWithUnsignedInt:NSCommandKeyMask],
            kGTMHotKeyModifierFlagsKey,
            nil];
  STAssertNotNil(hkDict, nil);
  STAssertFalse([GTMHotKeyTextField isValidHotKey:hkDict], nil);
  
  hkDict = [NSDictionary dictionaryWithObjectsAndKeys:
            [NSNumber numberWithBool:NO],
            kGTMHotKeyDoubledModifierKey,
            [NSNumber numberWithUnsignedInt:NSCommandKeyMask],
            kGTMHotKeyModifierFlagsKey,
            nil];
  STAssertNotNil(hkDict, nil);
  STAssertFalse([GTMHotKeyTextField isValidHotKey:hkDict], nil);
  
  hkDict = [NSDictionary dictionaryWithObjectsAndKeys:
            [NSNumber numberWithBool:NO],
            kGTMHotKeyDoubledModifierKey,
            [NSNumber numberWithUnsignedInt:114],
            kGTMHotKeyKeyCodeKey,
            nil];
  STAssertNotNil(hkDict, nil);
  STAssertFalse([GTMHotKeyTextField isValidHotKey:hkDict], nil);
  
  hkDict = [NSDictionary dictionary];
  STAssertNotNil(hkDict, nil);
  STAssertFalse([GTMHotKeyTextField isValidHotKey:hkDict], nil);
  
  STAssertFalse([GTMHotKeyTextField isValidHotKey:nil], nil);
  
  // Make sure it doesn't choke w/ an object of the wrong time (since the dicts
  // have to be saved/reloaded.
  hkDict = (id)[NSString string];
  STAssertNotNil(hkDict, nil);
  STAssertFalse([GTMHotKeyTextField isValidHotKey:hkDict], nil);
}

- (void)testFieldEditorSettersAndGetters {
  NSWindow *window = [controller_ window];
  GTMHotKeyTextField *field = [controller_ view];
  STAssertNotNil(field, nil);
  GTMHotKeyFieldEditor *editor 
    = (GTMHotKeyFieldEditor *)[window fieldEditor:YES forObject:field];
  STAssertTrue([editor isMemberOfClass:[GTMHotKeyFieldEditor class]], nil);
  STAssertEqualObjects(editor, 
                       [GTMHotKeyFieldEditor sharedHotKeyFieldEditor], 
                       nil);
  SEL selectors[] =
  {
    @selector(readablePasteboardTypes),
    @selector(acceptableDragTypes),
    @selector(writablePasteboardTypes)
  };
  for (size_t i = 0; i < sizeof(selectors) / sizeof(selectors[0]); ++i) {
    NSArray *array = [editor performSelector:selectors[i]];
    STAssertNotNil(array, nil);
    STAssertEquals([array count], (NSUInteger)0, 
                   @"Failed Selector: %@", NSStringFromSelector(selectors[i]));
  }
}

- (void)testTextFieldSettersAndGetters {
  GTMHotKeyTextField *field = [controller_ view];
  STAssertNotNil(field, nil);
  NSString *expectedNumberString = @"Hot key fields don't take numbers.";
  [GTMUnitTestDevLog expect:6 casesOfString:expectedNumberString];
  [field setDoubleValue:2];
  [field setIntValue:-1];
  [field setFloatValue:0];
  STAssertEquals([field doubleValue], 0.0, nil);
  STAssertEquals([field intValue], 0, nil);
  STAssertEquals([field floatValue], 0.0f, nil);
#if MAC_OS_X_VERSION_MIN_REQUIRED >= MAC_OS_X_VERSION_10_5
  [GTMUnitTestDevLog expect:2 casesOfString:expectedNumberString];
  [field setIntegerValue:5];
  STAssertEquals([field integerValue], (NSInteger)0, nil);
#endif
  SEL takeNumberSels[] =
  {
    @selector(takeDoubleValueFrom:),
    @selector(takeFloatValueFrom:),
    @selector(takeIntValueFrom:)
  };
  for (size_t i = 0; 
       i < sizeof(takeNumberSels) / sizeof(takeNumberSels[0]); ++i) {
    [GTMUnitTestDevLog expect:2 casesOfString:expectedNumberString];
    [field performSelector:takeNumberSels[i] withObject:self];
    [field performSelector:takeNumberSels[i] withObject:nil];
  }

  NSString *expectedStringString 
    = @"Hot key fields want dictionaries, not strings.";
  [GTMUnitTestDevLog expect:6 casesOfString:expectedStringString];
  [field takeStringValueFrom:self];
  [field takeStringValueFrom:nil];
  [field setStringValue:nil];
  [field setStringValue:@"foo"];
  
  NSAttributedString *attrString 
    = [[[NSAttributedString alloc] initWithString:@"foo"] autorelease];
  [field setAttributedStringValue:nil];
  [field setAttributedStringValue:attrString];
  
  STAssertNil([field formatter], nil);
  [GTMUnitTestDevLog expectString:@"Hot key fields don't accept formatters."];
  [field setFormatter:nil];
  
  [GTMUnitTestDevLog expect:2 casesOfString:
   @"Hot key fields want dictionaries via bindings, not from controls."];
  [field takeObjectValueFrom:self];
  [field takeObjectValueFrom:nil];
}

- (void)pressKey:(NSString *)key code:(NSInteger)code 
   modifierFlags:(NSInteger)flags window:(NSWindow *)window {
  NSInteger windNum = [window windowNumber];
  NSGraphicsContext *context = [NSGraphicsContext currentContext];
  EventTime evtTime = GetCurrentEventTime();
  NSPoint loc = [NSEvent mouseLocation];
  NSEvent *keyDownEvt = [NSEvent keyEventWithType:NSKeyDown 
                                         location:loc 
                                    modifierFlags:flags 
                                        timestamp:evtTime
                                     windowNumber:windNum 
                                          context:context 
                                       characters:key 
                      charactersIgnoringModifiers:key 
                                        isARepeat:NO 
                                          keyCode:code];
  NSEvent *keyUpEvt = [NSEvent keyEventWithType:NSKeyUp 
                                       location:loc 
                                  modifierFlags:flags
                                      timestamp:evtTime
                                   windowNumber:windNum 
                                        context:context 
                                     characters:key 
                    charactersIgnoringModifiers:key 
                                      isARepeat:NO 
                                        keyCode:code];
  STAssertNotNil(keyDownEvt, nil);
  STAssertNotNil(keyUpEvt, nil);
  [window sendEvent:keyDownEvt];
  [window sendEvent:keyUpEvt];
}

- (void)testTextFieldBindings {
  NSObjectController *controller 
    = [[[NSObjectController alloc] init] autorelease];
  [controller bind:NSContentBinding 
          toObject:self 
       withKeyPath:@"self" 
           options:nil];
  STAssertNotNil(controller, nil);
  GTMHotKeyTextField *field = [controller_ view];
  STAssertNotNil(field, nil);
  [field bind:NSValueBinding 
     toObject:controller 
  withKeyPath:@"selection.hotkeyValues" 
      options:nil];
  id value = [field objectValue];
  STAssertEqualObjects(value, hotkeyValues_, nil);
  NSString *stringValue = [field stringValue];
  STAssertEqualObjects(stringValue, @"⌘\\", nil);
  NSAttributedString *attrStringValue = [field attributedStringValue];
  STAssertEqualObjects([attrStringValue string], stringValue, nil);
  
  // Try changing some values
  [self willChangeValueForKey:@"hotkeyValues"];
  [hotkeyValues_ setObject:[NSNumber numberWithInt:43] 
                    forKey:kGTMHotKeyKeyCodeKey];
  [self didChangeValueForKey:@"hotkeyValues"];
  stringValue = [field stringValue];
  STAssertEqualObjects(stringValue, @"⌘,", nil);
  
  // Now try some typing
  NSWindow *window = [controller_ window];
  STAssertTrue([window makeFirstResponder:field], nil);
  [self pressKey:@"A" code:0 modifierFlags:NSShiftKeyMask window:window];
  stringValue = [field stringValue];
  STAssertEqualObjects(stringValue, @"⇧A", nil);
  
  // field is supposed to give up first responder when editing is done.
  STAssertNotEqualObjects([window firstResponder], field, nil);
  
  // Do NOT attempt to set the key via pressKey to the same cmd-key combo
  // as a menu item. This works fine on Leopard, but fails on Tiger (and fails
  // on Leopard if you have linked to the Tiger libs). I hope control-shift-opt
  // J won't be used in our simple test app.
  STAssertTrue([window makeFirstResponder:field], nil);
  [self pressKey:@"J" 
            code:38 
   modifierFlags:NSAlternateKeyMask | NSShiftKeyMask | NSControlKeyMask
          window:window];
  stringValue = [field stringValue];
  STAssertEqualObjects(stringValue, @"⌃⌥⇧J", nil);
  
  // Try without a modifier. This should fail.
  STAssertTrue([window makeFirstResponder:field], nil);
  [self pressKey:@"j" code:38 modifierFlags:0 window:window];
  stringValue = [field stringValue];
  STAssertEqualObjects(stringValue, @"⌃⌥⇧J", nil);
 
  // Try cmd-q this should fail
  STAssertTrue([window makeFirstResponder:field], nil);
  [self pressKey:@"Q" code:12 modifierFlags:NSCommandKeyMask window:window];
  stringValue = [field stringValue];
  STAssertEqualObjects(stringValue, @"⌃⌥⇧J", nil);
  
  // Try cmd-w this should fail
  STAssertTrue([window makeFirstResponder:field], nil);
  [self pressKey:@"W" code:13 modifierFlags:NSCommandKeyMask window:window];
  stringValue = [field stringValue];
  STAssertEqualObjects(stringValue, @"⌃⌥⇧J", nil);
  
  // Try cmd-tab this should fail
  STAssertTrue([window makeFirstResponder:field], nil);
  [self pressKey:@"\t" code:48 modifierFlags:NSCommandKeyMask window:window];
  stringValue = [field stringValue];
  STAssertEqualObjects(stringValue, @"⌃⌥⇧J", nil);
  
  // Do it by dictionary
  NSDictionary *cmdSHotKey
    = [NSDictionary dictionaryWithObjectsAndKeys:
       [NSNumber numberWithInt:NSCommandKeyMask], kGTMHotKeyModifierFlagsKey,
       [NSNumber numberWithInt:1], kGTMHotKeyKeyCodeKey,
       [NSNumber numberWithBool:NO], kGTMHotKeyDoubledModifierKey,
       nil];
  [field setObjectValue:cmdSHotKey];
  stringValue = [field stringValue];
  STAssertEqualObjects(stringValue, @"⌘S", nil);
  
  // Check to make sure the binding stuck
  STAssertEqualObjects(cmdSHotKey, hotkeyValues_, nil);
  
  [field unbind:NSValueBinding];
  [controller unbind:NSContentBinding];
  
  NSDictionary *cmdDHotKey
    = [NSDictionary dictionaryWithObjectsAndKeys:
       [NSNumber numberWithInt:NSCommandKeyMask], kGTMHotKeyModifierFlagsKey,
       [NSNumber numberWithInt:2], kGTMHotKeyKeyCodeKey,
       [NSNumber numberWithBool:NO], kGTMHotKeyDoubledModifierKey,
       nil];
  [field setObjectValue:cmdDHotKey];
  stringValue = [field stringValue];
  STAssertEqualObjects(stringValue, @"⌘D", nil);
}
@end

@implementation GTMHotKeyTextFieldTestController
- (id)init {
  return [super initWithWindowNibName:@"GTMHotKeyTextFieldTest"];
}

- (GTMHotKeyTextField *)view {
  return view_;
}

@end

@implementation GTMHotKeyTextFieldTestControllerWindowDelegate

-(id)windowWillReturnFieldEditor:(NSWindow *)sender toObject:(id)anObject {
  id editor = nil;
  if ([anObject isKindOfClass:[GTMHotKeyTextField class]]) {
    editor = [GTMHotKeyFieldEditor sharedHotKeyFieldEditor];
  }
  return editor;
}
@end

