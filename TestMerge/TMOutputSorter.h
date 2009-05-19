//
//  TMOutputSorter.h
//  TestMerge
//
//  Created by Barry Wark on 5/18/09.
//  Copyright 2009 Barry Wark. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol TMOutputGroup <NSObject>

@property (copy,readwrite) NSString * name;
@property (copy,readwrite) NSString * referencePath;
@property (copy,readwrite) NSString * outputPath;
@property (copy,readwrite) NSString * outputDiffPath;
@property (copy,readwrite) NSString * extension;

@end

@protocol TMOutputGroupFactory <NSObject>

- (id<TMOutputGroup>)groupWithName:(NSString*)name extension:(NSString*)extension;

@end



@interface TMOutputSorter : NSObject {
    NSArray *referencePaths;
    NSArray *outputPaths;
}

@property (copy,readwrite) NSArray *referencePaths;
@property (copy,readwrite) NSArray *outputPaths;

- (id)initWithReferencePaths:(NSArray*)ref
                 outputPaths:(NSArray*)output;

- (void)sortWithOutputGroupFactory:(id<TMOutputGroupFactory>)factory;
@end
