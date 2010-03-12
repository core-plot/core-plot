#import "OutputGroup.h"
#import "OutputFile.h"

#import "GTMSystemVersion.h"

@interface OutputGroup ()

@end

@implementation OutputGroup

@dynamic referencePath;

+ (NSSet*)keysPathsForValuesAffectingReferencePath {
    return [NSSet setWithObject:@"referenceFiles"];
}


- (NSString*)referencePath {
    return [self mostSpecificGTMUnitTestOutputPathInSet:[[self referenceFiles] valueForKeyPath:@"path"] name:self.name extension:self.extension];
}


- (NSString*)mostSpecificGTMUnitTestOutputPathInSet:(NSSet*)paths name:(NSString*)name extension:(NSString*)ext {
    /* Cribbed from GTMNSObject+UnitTesting because we can't include 
     GTMNSObject+UnitTesting.h without SenTesting/SenTesting.h
     */
    
    // System Version
    SInt32 major, minor, bugFix;
    [GTMSystemVersion getMajor:&major minor:&minor bugFix:&bugFix];
    NSString *systemVersions[4];
    systemVersions[0] = [NSString stringWithFormat:@".%d.%d.%d", 
                         major, minor, bugFix];
    systemVersions[1] = [NSString stringWithFormat:@".%d.%d", major, minor];
    systemVersions[2] = [NSString stringWithFormat:@".%d", major];
    systemVersions[3] = @"";
    
    // Architectures
    NSString *extensions[2];
    extensions[0] 
    = [NSString stringWithFormat:@".%@", 
       [GTMSystemVersion runtimeArchitecture]];
    extensions[1] = @"";
    
    size_t i, j;
    // Note that we are searching for the most exact match first.
    for (i = 0; i < sizeof(extensions) / sizeof(*extensions); ++i) {
        for (j = 0; j < sizeof(systemVersions) / sizeof(*systemVersions); j++) {
           
            
            NSString *result = nil;
            for(NSString *path in paths) {
                NSString *fileName = [[path pathComponents] lastObject];
                
                NSString *fullName1 = [NSString stringWithFormat:@"%@%@%@.%@", 
                                       name, extensions[i], systemVersions[j], ext];
                NSString *fullName2 = [NSString stringWithFormat:@"%@%@%@", 
                                       name, systemVersions[j], extensions[i]];
                
                if([fileName isEqualToString:fullName1] ||
                    [fileName isEqualToString:fullName2]) {
                    if(result != nil) { //duplicate
                        [NSException raise:NSGenericException format:@"Multiple paths with suffix %@ | %@ in set", fullName1, fullName2];
                    }
                    
                    result = path;
                }
            }
            
            if(result != nil) return result;
        }
    }
    
    return nil;
}

- (void)addReferencePathsObject:(NSString*)newPath {
    OutputFile *file = [OutputFile insertInManagedObjectContext:[self managedObjectContext]];
    file.path = newPath;
    
    [self addReferenceFilesObject:file];
}
@end
