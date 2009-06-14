// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to OutputFile.h instead.

#import <CoreData/CoreData.h>


@class OutputGroup;

@interface OutputFileID : NSManagedObjectID {}
@end

@interface _OutputFile : NSManagedObject {}
+ (id)newInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (OutputFileID*)objectID;



- (NSString*)path;
- (void)setPath:(NSString*)value_;
#if defined(MAC_OS_X_VERSION_10_5) && MAC_OS_X_VERSION_MAX_ALLOWED >= MAC_OS_X_VERSION_10_5
@property (retain) NSString *path;
#endif

//- (BOOL)validatePath:(id*)value_ error:(NSError**)error_;




- (OutputGroup*)group;
- (void)setGroup:(OutputGroup*)value_;
//- (BOOL)validateGroup:(id*)value_ error:(NSError**)error_;
#if defined(MAC_OS_X_VERSION_10_5) && MAC_OS_X_VERSION_MAX_ALLOWED >= MAC_OS_X_VERSION_10_5
@property (retain) OutputGroup* group;
#endif


@end
