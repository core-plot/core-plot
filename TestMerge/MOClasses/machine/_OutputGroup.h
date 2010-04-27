// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to OutputGroup.h instead.

#import <CoreData/CoreData.h>


@class OutputFile;

@interface OutputGroupID : NSManagedObjectID {}
@end

@interface _OutputGroup : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (OutputGroupID*)objectID;



@property (nonatomic, retain) NSString *name;

//- (BOOL)validateName:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSNumber *replaceReference;

@property BOOL replaceReferenceValue;
- (BOOL)replaceReferenceValue;
- (void)setReplaceReferenceValue:(BOOL)value_;

//- (BOOL)validateReplaceReference:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSString *failureDiffPath;

//- (BOOL)validateFailureDiffPath:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSString *outputPath;

//- (BOOL)validateOutputPath:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSString *extension;

//- (BOOL)validateExtension:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) NSSet* referenceFiles;
- (NSMutableSet*)referenceFilesSet;




+ (NSArray*)fetchNamedGroup:(NSManagedObjectContext*)moc_ NAME:(NSString*)NAME_ EXTENSION:(NSString*)EXTENSION_ ;
+ (NSArray*)fetchNamedGroup:(NSManagedObjectContext*)moc_ NAME:(NSString*)NAME_ EXTENSION:(NSString*)EXTENSION_ error:(NSError**)error_;



+ (NSArray*)fetchGroupsWithSelectedMerge:(NSManagedObjectContext*)moc_ ;
+ (NSArray*)fetchGroupsWithSelectedMerge:(NSManagedObjectContext*)moc_ error:(NSError**)error_;



+ (NSArray*)fetchAllGroups:(NSManagedObjectContext*)moc_ ;
+ (NSArray*)fetchAllGroups:(NSManagedObjectContext*)moc_ error:(NSError**)error_;


@end

@interface _OutputGroup (CoreDataGeneratedAccessors)

- (void)addReferenceFiles:(NSSet*)value_;
- (void)removeReferenceFiles:(NSSet*)value_;
- (void)addReferenceFilesObject:(OutputFile*)value_;
- (void)removeReferenceFilesObject:(OutputFile*)value_;

@end
