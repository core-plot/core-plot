// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to OutputFile.h instead.

#import <CoreData/CoreData.h>


@class OutputGroup;

@interface OutputFileID : NSManagedObjectID {}
@end

@interface _OutputFile : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (OutputFileID*)objectID;



@property (nonatomic, retain) NSString *path;

//- (BOOL)validatePath:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) OutputGroup* group;
//- (BOOL)validateGroup:(id*)value_ error:(NSError**)error_;



@end

@interface _OutputFile (CoreDataGeneratedAccessors)

@end
