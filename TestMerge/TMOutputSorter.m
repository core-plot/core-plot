//
//  TMOutputSorter.m
//  TestMerge
//
//  Created by Barry Wark on 5/18/09.
//  Copyright 2009 Barry Wark. All rights reserved.
//

#import "TMOutputSorter.h"
#import "GTMRegex.h"
#import "GTMSystemVersion.h"

static const NSUInteger GroupNameIndex = 1;

@implementation TMOutputSorter
@synthesize referencePaths;
@synthesize outputPaths;


- (id)initWithReferencePaths:(NSArray*)ref
                 outputPaths:(NSArray*)output {
    
    if( (self = [super init]) ) {
        referencePaths = [ref copy];
        outputPaths = [output copy];
    }
    
    return self;
}

- (void)dealloc {
    [referencePaths release];
    [outputPaths release];
    
    [super dealloc];
}
    

- (void)sortWithOutputGroupFactory:(id<TMOutputGroupFactory>)factory {

    SInt32 major, minor, bugFix;
    [GTMSystemVersion getMajor:&major minor:&minor bugFix:&bugFix];
    
    NSString *systemVersion = [NSString stringWithFormat:@"%d.%d.%d", 
                              major, minor, bugFix];
    
    /* Match
     (name).(arch).(system).(extension)
     */
    GTMRegex *refRegex = [GTMRegex regexWithPattern:[NSString stringWithFormat:@"^([^_]+)\\.%@\\.%@\\.(.+)$", [GTMRegex escapedPatternForString:[GTMSystemVersion runtimeArchitecture]], [GTMRegex escapedPatternForString:systemVersion]]];
    
    _GTMDevLog(@"%@", refRegex);
    
    for(NSString *path in self.referencePaths) {
        //_GTMDevLog(@"%@",path);
        if([refRegex matchesString:[path lastPathComponent]]) {
            NSArray *elems = [refRegex subPatternsOfString:[path lastPathComponent]];
            _GTMDevLog(@"Ref elems: %@", elems);
            if([[elems objectAtIndex:GroupNameIndex] length] > 0) {
                
                id<TMOutputGroup> group = [factory groupWithName:[elems objectAtIndex:GroupNameIndex] 
                                                       extension:[elems lastObject]];
                
                group.referencePath = path;
            }
        }
    }
    
    /* Match
     (name)([_Failure])([_Diff]).(arch).(system).(extension)
     */
    GTMRegex *failureRegex = [GTMRegex regexWithPattern:[NSString stringWithFormat:@"^([^_]+)_Failed\\.%@\\.%@\\.(.+)$", [GTMRegex escapedPatternForString:[GTMSystemVersion runtimeArchitecture]], [GTMRegex escapedPatternForString:systemVersion]]];
    GTMRegex *diffRegex = [GTMRegex regexWithPattern:[NSString stringWithFormat:@"^([^_]+)_Failed_Diff\\.%@\\.%@\\.(.+)$", [GTMRegex escapedPatternForString:[GTMSystemVersion runtimeArchitecture]], [GTMRegex escapedPatternForString:systemVersion]]];
    
    for(NSString *path in self.outputPaths) {
        _GTMDevLog(@"%@", path);
        if([failureRegex matchesString:[path lastPathComponent]]) {
            NSArray *elems = [failureRegex subPatternsOfString:[path lastPathComponent]];
            _GTMDevLog(@"Failure elems: %@", elems);
            if([[elems objectAtIndex:GroupNameIndex] length] > 0) {
                
                id<TMOutputGroup> group = [factory groupWithName:[elems objectAtIndex:GroupNameIndex] 
                                                       extension:[elems lastObject]];
                
                
                group.outputPath = path;
            }
        } else if([diffRegex matchesString:[path lastPathComponent]]) {
            NSArray *elems = [diffRegex subPatternsOfString:[path lastPathComponent]];
            _GTMDevLog(@"Diff elems: %@", elems);
            if([[elems objectAtIndex:GroupNameIndex] length] > 0) {
                
                id<TMOutputGroup> group = [factory groupWithName:[elems objectAtIndex:GroupNameIndex] 
                                                       extension:[elems lastObject]];
                
                
                group.outputDiffPath = path;
            }
        }
    }
}
@end
