//
//  KTLayoutManager.h
//  KTUIKit
//
//  Created by Cathy Shive on 05/20/2008.
//
// Copyright (c) Cathy Shive
//
// Permission is hereby granted, free of charge, to any person
// obtaining a copy of this software and associated documentation
// files (the "Software"), to deal in the Software without
// restriction, including without limitation the rights to use,
// copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the
// Software is furnished to do so, subject to the following
// conditions:
//
// The above copyright notice and this permission notice shall be
// included in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
// EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
// OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
// NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
// HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
// WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
// FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
// OTHER DEALINGS IN THE SOFTWARE.
//
// If you use it, acknowledgement in an About Page or other appropriate place would be nice.
// For example, "Contains "KTUIKit" by Cathy Shive" will do.

#import <Cocoa/Cocoa.h>
#import "KTViewProtocol.h"

typedef enum
{
	KTSizeAbsolute = 0,
	KTSizeFill,
	KTSizePercentage,

} KTSizeType;


typedef enum
{
	KTHorizontalPositionAbsolute = 0,
	KTHorizontalPositionStickLeft,
	KTHorizontalPositionStickRight,
	KTHorizontalPositionKeepCentered,
	KTHorizontalPositionFloatLeft,
	KTHorizontalPositionFloatRight,
	KTHorizontalPositionProportional
	
}KTHorizontalPositionType;


typedef enum
{

	KTVerticalPositionAbsolute = 0,
	KTVerticalPositionStickTop,
	KTVerticalPositionStickBottom,
	KTVerticalPositionKeepCentered,
	KTVerticalPositionFloatUp,
	KTVerticalPositionFloatDown,
	KTVerticalPositionProportional
	
}KTVerticalPositionType;


@interface KTLayoutManager : NSObject
{
	id<KTViewLayout>			wView;
	
	BOOL						mShouldDoLayout;
	
	KTSizeType					mWidthType;
	KTSizeType					mHeightType;
	KTHorizontalPositionType	mHorizontalPositionType;
	KTVerticalPositionType		mVerticalPositionType;
	
	CGFloat						mWidthPercentage;
	CGFloat						mHeightPercentage;
	CGFloat						mHorizontalPositionPercentage;
	CGFloat						mVerticalPositionPercentage;
	
	CGFloat						mMarginLeft;
	CGFloat						mMarginRight;
	CGFloat						mMarginTop;
	CGFloat						mMarginBottom;
	
	CGFloat						mMinWidth;
	CGFloat						mMaxWidth;
	CGFloat						mMinHeight;
	CGFloat						mMaxHeight;
}

@property(nonatomic, readwrite, assign) BOOL shouldDoLayout;
@property(nonatomic, readwrite, assign) KTSizeType heightType;
@property(nonatomic, readwrite, assign) KTSizeType widthType;
@property(nonatomic, readwrite, assign) KTHorizontalPositionType horizontalPositionType;
@property(nonatomic, readwrite, assign) KTVerticalPositionType verticalPositionType;
@property(nonatomic, readwrite, assign) CGFloat marginTop;
@property(nonatomic, readwrite, assign) CGFloat marginBottom;
@property(nonatomic, readwrite, assign) CGFloat marginLeft;
@property(nonatomic, readwrite, assign) CGFloat marginRight;
@property(nonatomic, readwrite, assign) CGFloat heightPercentage;
@property(nonatomic, readwrite, assign) CGFloat widthPercentage;
@property(nonatomic, readwrite, assign) CGFloat horizontalPositionPercentage;
@property(nonatomic, readwrite, assign) CGFloat verticalPositionPercentage;
@property(nonatomic, readwrite, assign) CGFloat minWidth;
@property(nonatomic, readwrite, assign) CGFloat maxWidth;
@property(nonatomic, readwrite, assign) CGFloat minHeight;
@property(nonatomic, readwrite, assign) CGFloat maxHeight;
@property(nonatomic, readwrite, assign) id <KTViewLayout> view;
- (NSArray *)keysForCoding;

- (id)initWithView:(id<KTViewLayout>)theView;
- (void)setMargin:(float)theMargin;
- (void)setMarginTop:(float)theTopMargin 
			   right:(float)theRightMargin 
			  bottom:(float)theBottomMargin 
				left:(float)theLeftMargin;
				
- (void)refreshLayout;

@end
