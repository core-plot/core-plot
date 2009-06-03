//
//  TMImageViewTests.m
//  TestMerge
//
//  Created by Barry Wark on 5/28/09.
//  Copyright 2009 Physion Consulting LLC. All rights reserved.
//

#import "TMImageViewTests.h"

#import "GTMNSObject+UnitTesting.h"
#import "GTMNSObject+BindingUnitTesting.h"

@interface TMImageView (UnitTesting)

-(void)gtm_unitTestEncodeState:(NSCoder*)inCoder;

@end

@implementation TMImageView (UnitTesting)

-(void)gtm_unitTestEncodeState:(NSCoder*)inCoder {
    [super gtm_unitTestEncodeState:inCoder];
    
    [inCoder encodeBool:self.selected forKey:@"selected"];
}
    

@end


@implementation TMImageViewTests
@synthesize imageView;
@synthesize flag;

- (void)setUp {
    self.imageView = [[[TMImageView alloc] initWithFrame:NSMakeRect(0, 0, 100, 100)] autorelease];
    
    NSString *imagePath = [[NSBundle bundleForClass:[self class]] pathForImageResource:@"TMMergeControllerTests-testWindowUIRendering.tiff"];
    
    STAssertNotNil(imagePath, @"unable to find image");
    
    [self.imageView setImageWithURL:[NSURL fileURLWithPath:imagePath]];
    
    self.imageView.autoresizes = YES;
    self.imageView.autohidesScrollers = YES;
    
    self.imageView.selected = NO;
}

- (void)tearDown {
    self.imageView = nil;
}

- (void)testRenderNotSelected {
    self.imageView.selected = NO;
    GTMAssertObjectEqualToStateAndImageNamed(self.imageView, @"TMImageViewTests-testRenderNotSelected", @"");
}

- (void)testRenderSelected {
    self.imageView.selected = YES;
    GTMAssertObjectEqualToStateAndImageNamed(self.imageView, @"TMImageViewTests-testRenderSelected", @"");
}

- (void)testRenderNilURLImage {
    self.imageView.selected = NO;
    [[self imageView] setImageWithURL:nil];
    
    GTMAssertObjectImageEqualToImageNamed(self.imageView, @"TMImageViewTests-testRenderNilURLImage", @"");
}

- (void)testDelegateCalledForMouseDown {
    self.imageView.delegate = self;
    self.flag = NO;
    
    [[self imageView] mouseDown:[NSEvent mouseEventWithType:NSLeftMouseUp
                                                   location:[[self imageView] convertPoint:NSMakePoint(1,1) toView:nil]
                                              modifierFlags:0
                                                  timestamp:[NSDate timeIntervalSinceReferenceDate]
                                               windowNumber:0
                                                    context:nil
                                                eventNumber:1
                                                 clickCount:1
                                                   pressure:1.0]];
    
    STAssertTrue(self.flag, @"delegate method not recieved");
}

- (void)mouseDownInImageView:(TMImageView*)view {
    STAssertEquals(view, self.imageView, @"");
    self.flag = YES;
}

- (void)testBindings {
    GTMDoExposedBindingsFunctionCorrectly(self.imageView, NULL);
}
    
@end
