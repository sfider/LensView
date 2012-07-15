//
//  LOOMagGlassLensDecorView.m
//
//  Created by Marcin Świderski on 4/14/12.
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

#import "LOOMagGlassLensDecorView.h"

const CGFloat LOOMagGlassLensFrameWidth = 3.0f;
const CGFloat LOOMagGlassLensFrameBorderWidth = 0.25f;

@implementation LOOMagGlassLensDecorView

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
  
  // Draw glass effect.
  CGContextSaveGState(context);
  CGContextAddEllipseInRect(context, CGRectInset(bounds, LOOMagGlassLensFrameWidth, LOOMagGlassLensFrameWidth));
  CGContextClip(context);
  
  [[UIColor colorWithWhite:0.0f alpha:0.2f] setFill];
  CGContextFillRect(context, CGRectInset(bounds, LOOMagGlassLensFrameWidth, LOOMagGlassLensFrameWidth));
  
  CGFloat diameter = bounds.size.height - 2.0f * LOOMagGlassLensFrameWidth;
  
  CGFloat glareGradientComponents[] = {
      1.0f, 1.0f, 1.0f, 0.3f,
      1.0f, 1.0f, 1.0f, 0.8f };
  CGFloat glareGradientLocations[] = { 0.0f, 1.0f};
  CGGradientRef glareGradient = CGGradientCreateWithColorComponents(rgbSpace, glareGradientComponents, glareGradientLocations,
      sizeof(glareGradientLocations) / sizeof(CGFloat));
  CGPoint glareGradientCenter = CGPointMake(CGRectGetMidX(bounds), bounds.size.height * 2.0f);
  CGContextDrawRadialGradient(context, glareGradient, glareGradientCenter, bounds.size.height * 1.75f,
      glareGradientCenter, bounds.size.height * 2.0f, 0);
  CGGradientRelease(glareGradient);
  
  CGFloat touchGradientComponents[] = {
      1.0f, 1.0f, 1.0f, 0.9f,
      1.0f, 1.0f, 1.0f, 0.0f };
  CGFloat touchGradientLocations[] = { 0.0f, 1.0f };
  CGGradientRef touchGradient = CGGradientCreateWithColorComponents(rgbSpace, touchGradientComponents, touchGradientLocations,
      sizeof(touchGradientLocations) / sizeof(CGFloat));
  CGFloat touchGradientRadius = diameter / 2.0f;
  CGPoint touchGradientCenter = CGPointMake(CGRectGetMidX(bounds), LOOMagGlassLensFrameWidth + diameter * 0.75f);
  CGContextDrawRadialGradient(context, touchGradient, touchGradientCenter, 0.0f, touchGradientCenter, touchGradientRadius, 0);
  CGGradientRelease(touchGradient);
  
  CGContextRestoreGState(context);
  
  // Draw frame.
  CGContextSaveGState(context);
  CGContextAddEllipseInRect(context, bounds);
  CGContextClip(context);
  
  [[UIColor colorWithWhite:0.9f alpha:1.0f] setFill];
  [[UIColor blackColor] setStroke];
  CGContextSetLineWidth(context, LOOMagGlassLensFrameBorderWidth);
  CGContextSetShadow(context, CGSizeMake(0.0f, 1.0f), 1.0f);
  CGContextAddEllipseInRect(context, CGRectInset(bounds,
      LOOMagGlassLensFrameBorderWidth / 2.0f, LOOMagGlassLensFrameBorderWidth / 2.0f));
  CGContextAddEllipseInRect(context, CGRectInset(bounds,
      LOOMagGlassLensFrameWidth - LOOMagGlassLensFrameBorderWidth / 2.0f,
      LOOMagGlassLensFrameWidth - LOOMagGlassLensFrameBorderWidth / 2.0f));
  CGContextDrawPath(context, kCGPathEOFillStroke);
  
  CGContextRestoreGState(context);
  
  CGColorSpaceRelease(rgbSpace);
}

@end
