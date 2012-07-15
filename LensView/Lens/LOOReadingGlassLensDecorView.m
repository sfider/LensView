//
//  LOOReadingGlassLensDecorView.m
//
//  Created by Marcin Świderski on 4/18/12.
//  Copyright (c) 2012 Marcin Świderski. All rights reserved.
//
//  This software is provided 'as-is', without any express or implied
//  warranty.  In no event will the authors be held liable for any damages
//  arising from the use of this software.
//  
//  Permission is granted to anyone to use this software for any purpose,
//  including commercial applications, and to alter it and redistribute it
//  freely, subject to the following restrictions:
//  
//  1. The origin of this software must not be misrepresented; you must not
//     claim that you wrote the original software. If you use this software
//     in a product, an acknowledgment in the product documentation would be
//     appreciated but is not required.
//  2. Altered source versions must be plainly marked as such, and must not be
//     misrepresented as being the original software.
//  3. This notice may not be removed or altered from any source distribution.
//

#import "LOOReadingGlassLensDecorView.h"
#import "LOOCGFunctions.h"

const CGFloat LOOReadingGlassLensFrameWidth = 3.0f;
const CGFloat LOOReadingGlassLensFrameInnerBorderWidth = 0.5f;
const CGFloat LOOReadingGlassLensFrameOuterBorderWidth = 0.25f;
const CGFloat LOOReadingGlassLensArrowWidth = 24.0;
const CGFloat LOOReadingGlassLensArrowHeight = 12.0f;
const CGFloat LOOReadingGlassLensInnerCornerRadius = 5.0f;
const CGFloat LOOReadingGlassLensOuterCornerRadius = 8.0f;

@implementation LOOReadingGlassLensDecorView

+ (CGPathRef)createInnerPathWithBounds:(CGRect)bounds {
  CGMutablePathRef innerPath = CGPathCreateMutable();
  LOOCGCorner innerCorners[] = {
      { CGRectGetMinX(bounds) + LOOReadingGlassLensFrameWidth, CGRectGetMinY(bounds) + LOOReadingGlassLensFrameWidth,
          LOOReadingGlassLensInnerCornerRadius },
      { CGRectGetMaxX(bounds) - LOOReadingGlassLensFrameWidth, CGRectGetMinY(bounds) + LOOReadingGlassLensFrameWidth,
          LOOReadingGlassLensInnerCornerRadius },
      { CGRectGetMaxX(bounds) - LOOReadingGlassLensFrameWidth, CGRectGetMaxY(bounds) - LOOReadingGlassLensArrowHeight - LOOReadingGlassLensFrameWidth,
          LOOReadingGlassLensInnerCornerRadius },
      { CGRectGetMinX(bounds) + LOOReadingGlassLensFrameWidth, CGRectGetMaxY(bounds) - LOOReadingGlassLensArrowHeight - LOOReadingGlassLensFrameWidth,
          LOOReadingGlassLensInnerCornerRadius } };
  LOOCGPathAddRoundedPolygon(innerPath, NULL, innerCorners, sizeof(innerCorners) / sizeof(LOOCGCorner));
  return innerPath;
}

+ (CGPathRef)createOuterPathWithBounds:(CGRect)bounds {
  CGFloat hw = LOOReadingGlassLensFrameOuterBorderWidth / 2.0f;
  CGMutablePathRef outerPath = CGPathCreateMutable();
  LOOCGCorner outerCorners[] = {
      { CGRectGetMinX(bounds) + hw, CGRectGetMinY(bounds) + hw, LOOReadingGlassLensOuterCornerRadius - hw },
      { CGRectGetMaxX(bounds) - hw, CGRectGetMinY(bounds) + hw, LOOReadingGlassLensOuterCornerRadius - hw },
      { CGRectGetMaxX(bounds) - hw, CGRectGetMaxY(bounds) - LOOReadingGlassLensArrowHeight - hw, LOOReadingGlassLensOuterCornerRadius - hw },
      { CGRectGetMidX(bounds) + LOOReadingGlassLensArrowWidth / 2.0f, CGRectGetMaxY(bounds) - LOOReadingGlassLensArrowHeight - hw, 0.0f },
      { CGRectGetMidX(bounds), CGRectGetMaxY(bounds) - hw, 0.0f },
      { CGRectGetMidX(bounds) - LOOReadingGlassLensArrowWidth / 2.0f, CGRectGetMaxY(bounds) - LOOReadingGlassLensArrowHeight - hw, 0.0f },
      { CGRectGetMinX(bounds) + hw, CGRectGetMaxY(bounds) - LOOReadingGlassLensArrowHeight - hw, LOOReadingGlassLensOuterCornerRadius - hw } };
  LOOCGPathAddRoundedPolygon(outerPath, NULL, outerCorners, sizeof(outerCorners) / sizeof(LOOCGCorner));
  return outerPath;
}

- (id)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    [self setContentMode:UIViewContentModeRedraw];
    [self setOpaque:NO];
  }
  return self;
}

- (void)drawRect:(CGRect)rect {
  CGContextRef context = UIGraphicsGetCurrentContext();
  CGRect bounds = [self bounds];
  CGColorSpaceRef rgbSpace = CGColorSpaceCreateDeviceRGB();
  
  // Create inner and outer paths of the frame.
  CGPathRef innerPath = [LOOReadingGlassLensDecorView createInnerPathWithBounds:bounds];
  CGPathRef outerPath = [LOOReadingGlassLensDecorView createOuterPathWithBounds:bounds];
  
  // Draw glass.
  CGContextSaveGState(context);
  CGContextAddPath(context, innerPath);
  CGContextClip(context);
  
  CGFloat glassComponents[] = {
      1.0f, 1.0f, 1.0f, 0.8f,
      1.0f, 1.0f, 1.0f, 0.4f,
      1.0f, 1.0f, 1.0f, 0.0f,
      1.0f, 1.0f, 1.0f, 0.0f };
  CGFloat glassLocations[] = { 0.0f, 0.5f, 0.5f, 1.0f };
  CGGradientRef glassGradient = CGGradientCreateWithColorComponents(rgbSpace, glassComponents, glassLocations,
      sizeof(glassLocations) / sizeof(CGFloat));
  CGContextDrawLinearGradient(context, glassGradient, CGPointMake(0.0f, LOOReadingGlassLensFrameWidth),
      CGPointMake(0.0f, bounds.size.height - 2.0f * LOOReadingGlassLensFrameWidth - LOOReadingGlassLensArrowHeight), 0);
  CGGradientRelease(glassGradient);
  
  CGContextRestoreGState(context);
  
  // Draw frame filling.
  CGContextSaveGState(context);
  CGContextAddPath(context, outerPath);
  CGContextAddPath(context, innerPath);
  CGContextEOClip(context);
  
  CGFloat fillComponents[] = {
      237.0f / 255.0f, 238.0f / 255.0f, 240.0f / 255.0f, 1.0f,
      208.0f / 255.0f, 209.0f / 255.0f, 212.0f / 255.0f, 1.0f };
  CGFloat fillLocations[] = { 0.0f, 1.0f };
  CGGradientRef fillGradient = CGGradientCreateWithColorComponents(rgbSpace, fillComponents, fillLocations,
      sizeof(fillLocations) / sizeof(CGFloat));
  CGContextDrawLinearGradient(context, fillGradient, CGPointZero, CGPointMake(0.0f, bounds.size.height), 0);
  CGGradientRelease(fillGradient);
  
  CGContextRestoreGState(context);
  
  // Draw frame inner border.
  [[UIColor colorWithWhite:0.0f alpha:0.6f] setStroke];
  CGContextSetLineWidth(context, LOOReadingGlassLensFrameInnerBorderWidth);
  CGContextAddPath(context, innerPath);
  CGContextDrawPath(context, kCGPathStroke);
  
  // Draw frame outer border.
  [[UIColor colorWithWhite:0.0f alpha:0.8f] setStroke];
  CGContextSetLineWidth(context, LOOReadingGlassLensFrameOuterBorderWidth);
  CGContextAddPath(context, outerPath);
  CGContextDrawPath(context, kCGPathStroke);
  
  CGColorSpaceRelease(rgbSpace);
  CGPathRelease(innerPath);
  CGPathRelease(outerPath);
}

@end
