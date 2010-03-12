//
//  GTMUIImage+Resize.m
//
//  Copyright 2009 Google Inc.
//
//  Licensed under the Apache License, Version 2.0 (the "License"); you may not
//  use this file except in compliance with the License.  You may obtain a copy
//  of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
//  WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.  See the
//  License for the specific language governing permissions and limitations under
//  the License.
//

#import "GTMUIImage+Resize.h"

@implementation UIImage (GTMUIImageResizeAdditions)

- (UIImage *)gtm_imageByResizingToSize:(CGSize)targetSize
                   preserveAspectRatio:(BOOL)preserveAspectRatio
                             trimToFit:(BOOL)trimToFit {
  CGSize imageSize = [self size];
  if (imageSize.height < 1 || imageSize.width < 1) {
    return nil;
  }
  if (targetSize.height < 1 || targetSize.width < 1) {
    return nil;
  }
  CGFloat aspectRatio = imageSize.width / imageSize.height;
  CGFloat targetAspectRatio = targetSize.width / targetSize.height;
  CGRect projectTo = CGRectZero;
  if (preserveAspectRatio) {
    if (trimToFit) {
      // Scale and clip image so that the aspect ratio is preserved and the
      // target size is filled.
      if (targetAspectRatio < aspectRatio) {
        // clip the x-axis.
        projectTo.size.width = targetSize.height * aspectRatio;
        projectTo.size.height = targetSize.height;
        projectTo.origin.x = (targetSize.width - projectTo.size.width) / 2;
        projectTo.origin.y = 0;
      } else {
        // clip the y-axis.
        projectTo.size.width = targetSize.width;
        projectTo.size.height = targetSize.width / aspectRatio;
        projectTo.origin.x = 0;
        projectTo.origin.y = (targetSize.height - projectTo.size.height) / 2;
      }
    } else {
      // Scale image to ensure it fits inside the specified targetSize.
      if (targetAspectRatio < aspectRatio) {
        // target is less wide than the original.
        projectTo.size.width = targetSize.width;
        projectTo.size.height = projectTo.size.width / aspectRatio;
        targetSize = projectTo.size;
      } else {
        // target is wider than the original.
        projectTo.size.height = targetSize.height;
        projectTo.size.width = projectTo.size.height * aspectRatio;
        targetSize = projectTo.size;
      }
    } // if (clip)
  } else {
    // Don't preserve the aspect ratio.
    projectTo.size = targetSize;
  }

  projectTo = CGRectIntegral(projectTo);
  // There's no CGSizeIntegral, so we fake our own.
  CGRect integralRect = CGRectZero;
  integralRect.size = targetSize;
  targetSize = CGRectIntegral(integralRect).size;

  // Resize photo. Use UIImage drawing methods because they respect
  // UIImageOrientation as opposed to CGContextDrawImage().
  UIGraphicsBeginImageContext(targetSize);
  [self drawInRect:projectTo];
  UIImage* resizedPhoto = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  return resizedPhoto;
}
@end
