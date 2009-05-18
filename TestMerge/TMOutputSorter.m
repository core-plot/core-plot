//
//  TMOutputSorter.m
//  TestMerge
//
//  Created by Barry Wark on 5/18/09.
//  Copyright 2009 Barry Wark. All rights reserved.
//

#import "TMOutputSorter.h"
#import "GTMRegex.h"

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
    GTMRegex *regex;
    
    /* Match
     (name)([_Failure])([_Diff]).(arch).(system).(extension)
     */
    regex = [GTMRegex regexWithPattern:@"^(.+)(_*)(_*)\\.(.+)\\.([0-9]+\\.[0-9]+\\.[0-9]+)\\.(.+)$"];
    
    _GTMDevLog(@"%@", regex);
    
    for(NSString *path in self.referencePaths) {
        if([regex matchesString:[path lastPathComponent]]) {
            NSArray *elems = [regex subPatternsOfString:[path lastPathComponent]];
            
            if([[elems objectAtIndex:GroupNameIndex] length] > 0) {
                
                id<TMOutputGroup> group = [factory groupWithName:[elems objectAtIndex:GroupNameIndex]];
                
                group.name = [elems objectAtIndex:GroupNameIndex];
                group.referencePath = path;
            }
        }
    }
}
@end
