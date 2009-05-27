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
#import "TMOutputGroup.h"
#import "TMErrors.h"

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
    

- (NSSet*)sortedOutputWithGroupFactory:(id<TMOutputGroupFactory>)factory error:(NSError**)error {
    
    NSMutableSet *groups = [NSMutableSet set];
    
    for(NSString *path in self.referencePaths) {
        NSArray *comps = [path componentsSeparatedByString:@"."];
        if(comps.count < 2) {
            if(error != NULL) {
                *error = [NSError errorWithDomain:TMErrorDomain
                                             code:TMPathError
                                         userInfo:[NSDictionary dictionaryWithObject:NSLocalizedString(@"Path does not contain [name].[extension]",  @"Path does not contain [name].[extension]")
                                                                              forKey:NSLocalizedFailureReasonErrorKey]];
                return nil;
            }
        }
        
        NSString *name = [comps objectAtIndex:0];
        NSString *extension = [comps lastObject];
        
        
        id<TMOutputGroup> group = [factory groupWithName:name extension:extension];
        group.referencePath = path;
        
        [groups addObject:group];
    }
    
    for(NSString *path in self.outputPaths) {
        NSArray *comps = [path componentsSeparatedByString:@"."];
        if(comps.count < 2) {
            if(error != NULL) {
                *error = [NSError errorWithDomain:TMErrorDomain
                                             code:TMPathError
                                         userInfo:[NSDictionary dictionaryWithObject:NSLocalizedString(@"Path does not contain [name].[extension]",  @"Path does not contain [name].[extension]")
                                                                              forKey:NSLocalizedFailureReasonErrorKey]];
                return nil;
            }
        }
        
        NSString *name = [comps objectAtIndex:0];
        NSString *extension = [comps lastObject];
        
        //remove _Failed and _Diff from name
        GTMRegex *nameRegex = [GTMRegex regexWithPattern:@"^([^_]+)(_Failure)+(_Diff)+$@"];
        _GTMDevAssert([nameRegex matchesString:name], @"Unable to match name with regex");
        NSArray *nameGroups = [nameRegex subPatternsOfString:name];
        
        id<TMOutputGroup> group = [factory groupWithName:[nameGroups objectAtIndex:0]
                                               extension:extension];
        
        switch(nameGroups.count) {
            case 2: // _Failure
                group.outputPath = path;
                break;
            case 3: // _Diff
                group.failureDiffPath = path;
                break;
            default:
                if(error != NULL) {
                    *error = [NSError errorWithDomain:TMErrorDomain
                                                 code:TMPathError
                                             userInfo:[NSDictionary dictionaryWithObject:NSLocalizedString(@"Output path is not _Failure or _Failure_Diff",  @"Output path is not _Failure or _Failure_Diff")
                                                                                  forKey:NSLocalizedFailureReasonErrorKey]];
                    return nil;
                }
        }
        
        [groups addObject:group];
    }
    
    return groups;
}
@end
