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
        NSArray *comps = [[[path pathComponents] lastObject] componentsSeparatedByString:@"."];
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
        GTMRegex *nameRegex = [GTMRegex regexWithPattern:@"^([^_]+)(_Failed)+(_Diff)*$"];
        _GTMDevLog(@"%@ => %@", nameRegex, name);
        _GTMDevAssert([nameRegex matchesString:name], @"Unable to match name with regex");
        
        NSArray *nameGroups = [nameRegex subPatternsOfString:name];
        
        _GTMDevLog(@"name groups for %@: %@", name, nameGroups);
        
        _GTMDevLog(@"Finding group with name %@, extension %@", [nameGroups objectAtIndex:GroupNameIndex], extension);
        
        id<TMOutputGroup> group = [factory groupWithName:[nameGroups objectAtIndex:GroupNameIndex]
                                               extension:extension];
        
        if([nameGroups lastObject] == [NSNull null]) { //_Failure
            group.outputPath = path;
        } else { //_Diff
            _GTMDevAssert([[nameGroups lastObject] isEqualToString:@"_Diff"], @"Unexpected last name group");
            group.failureDiffPath = path;
        }
        
        [groups addObject:group];
    }
    
    return groups;
}
@end
