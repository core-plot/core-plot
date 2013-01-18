//
//  main.m
//  CorePlot
//
//  Created by Barry Wark on 2/11/09.
//  Copyright 2009 Barry Wark. All rights reserved.
//

#import "GTMUnitTestingUtilities.h"

void GTMRestoreColorProfile(void);

int main(int argc, char *argv[])
{
    //configure environment for standard unit testing
    [GTMUnitTestingUtilities setUpForUIUnitTestsIfBeingTested];

    return NSApplicationMain(argc, (const char **)argv);

    //setUpForUIUnitTestsIfBeingTested modifies the system-wide color profile. Make sure it gets restored.
    GTMRestoreColorProfile();
}
