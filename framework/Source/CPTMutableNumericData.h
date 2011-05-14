#import <Foundation/Foundation.h>
#import "CPTNumericDataType.h"
#import "CPTNumericData.h"

@interface CPTMutableNumericData : CPTNumericData {
	
}

/// @name Data Buffer
/// @{
@property (readonly) void *mutableBytes;
///	@}

/// @name Dimensions
/// @{
@property (copy, readwrite) NSArray *shape;
///	@}

/// @name Factory Methods
/// @{
+(CPTMutableNumericData *)numericDataWithData:(NSData *)newData
									dataType:(CPTNumericDataType)newDataType
									   shape:(NSArray *)shapeArray;

+(CPTMutableNumericData *)numericDataWithData:(NSData *)newData
							  dataTypeString:(NSString *)newDataTypeString
									   shape:(NSArray *)shapeArray;
///	@}

/// @name Initialization
/// @{
-(id)initWithData:(NSData *)newData
		 dataType:(CPTNumericDataType)newDataType
            shape:(NSArray *)shapeArray;
///	@}

@end
