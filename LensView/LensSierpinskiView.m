//
//  LensSierpinskiView.m
//  LensView
//
//  Created by Marcin Świderski on 7/15/12.
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

#import "LensSierpinskiView.h"

@interface LensSierpinskiView ()

- (void)step:(NSInteger)n path:(CGPathRef)path;

@end

@implementation LensSierpinskiView

- (id)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    [self setContentMode:UIViewContentModeRedraw];
  }
  return self;
}

- (void)drawRect:(CGRect)rect {
  CGContextRef context = UIGraphicsGetCurrentContext();
  CGRect bounds = [self bounds];
  
  [[UIColor whiteColor] setFill];
  CGContextFillRect(context, bounds);
  
  [[UIColor blackColor] setFill];
  CGContextMoveToPoint(context, CGRectGetMinX(bounds), CGRectGetMaxY(bounds));
  CGContextAddLineToPoint(context, CGRectGetMidX(bounds), CGRectGetMinY(bounds));
  CGContextAddLineToPoint(context, CGRectGetMaxX(bounds), CGRectGetMaxY(bounds));
  CGContextFillPath(context);
  
  CGMutablePathRef path = CGPathCreateMutable();
  CGPathMoveToPoint(path, NULL, CGRectGetMidX(bounds), CGRectGetMaxY(bounds));
  CGPathAddLineToPoint(path, NULL,
      CGRectGetMinX(bounds) + CGRectGetWidth(bounds) / 4.0f, CGRectGetMinY(bounds) + CGRectGetHeight(bounds) / 2.0f);
  CGPathAddLineToPoint(path, NULL,
      CGRectGetMaxX(bounds) - CGRectGetWidth(bounds) / 4.0f, CGRectGetMinY(bounds) + CGRectGetHeight(bounds) / 2.0f);
  
  [[UIColor whiteColor] setFill];
  [self step:6 path:path];
  
  CGPathRelease(path);
}

- (void)step:(NSInteger)n path:(CGPathRef)path {
  CGContextRef context = UIGraphicsGetCurrentContext();
  CGRect bounds = [self bounds];
  
  CGContextAddPath(context, path);
  CGContextFillPath(context);
  
  if (n > 0) {
    CGContextSaveGState(context);
    CGContextScaleCTM(context, 0.5f, 0.5f);
    
    CGContextTranslateCTM(context, bounds.size.width / 2.0f, 0.0f);
    [self step:(n - 1) path:path];
    
    CGContextTranslateCTM(context, -bounds.size.width / 2.0f, bounds.size.height);
    [self step:(n - 1) path:path];
    
    CGContextTranslateCTM(context, bounds.size.width, 0.0f);
    [self step:(n - 1) path:path];
    
    CGContextRestoreGState(context);
  }
}

@end
