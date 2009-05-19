//
//  main.m
//  TestMerge
//
//  Created by Barry Wark on 5/18/09.
//  Copyright Barry Wark 2009. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "GTMUnitTestingUtilities.h"

int main(int argc, char *argv[])
{
    [GTMUnitTestingUtilities setUpForUIUnitTestsIfBeingTested];
    
    return NSApplicationMain(argc,  (const char **) argv);
}
