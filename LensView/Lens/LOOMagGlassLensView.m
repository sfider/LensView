//
//  LOOMagGlassLensView.m
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

#import "LOOMagGlassLensView.h"
#import "LOOLensBaseView+Protected.h"
#import "LOOMagGlassLensDecorView.h"

static const CGFloat DefaultMagnification = 1.5f;
static const CGFloat Diameter = 118.0f;
static const CGPoint TargetPointOffset = { Diameter / 2.0f, Diameter - 44.0f };

@interface LOOMagGlassLensView ()

- (void)updateFrame;
- (void)updateTargetFrame;

@end

@implementation LOOMagGlassLensView

@synthesize magnification = _magnification;
@synthesize targetPoint = _targetPoint;

- (id)init {
  self = [super initWithFrame:CGRectMake(0.0f, 0.0f, Diameter, Diameter)];
  if (self) {
    [self setOpaque:NO];
    [self setClipsToBounds:NO];
    [self setMagnification:DefaultMagnification];
    
    [[self layer] setShadowOffset:CGSizeMake(0.0f, 3.0f)];
    [[self layer] setShadowOpacity:1.0f];
    [[self layer] setShadowPath:[[UIBezierPath bezierPathWithRoundedRect:[self bounds] cornerRadius:(Diameter / 2.0f)] CGPath]];
    
    LOOMagGlassLensDecorView *decorView = [[[LOOMagGlassLensDecorView alloc] initWithFrame:[self bounds]] autorelease];
    [decorView setAutoresizingMask:(UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight)];
    [self addSubview:decorView];
  }
  return self;
}

- (void)setMagnification:(CGFloat)magnification {
  _magnification = magnification;
  [self updateTargetFrame];
}

- (void)setTargetView:(UIView *)targetView {
  [super setTargetView:targetView];
  [self updateFrame];
  [self updateTargetFrame];
}

- (void)setTargetPoint:(CGPoint)targetPoint {
  _targetPoint = targetPoint;
  [self updateFrame];
  [self updateTargetFrame];
}

- (void)updateFrame {
  if (![self targetView]) {
    return;
  }
  
  // Magnifing glass view shouldn't go out from superview too much.
  CGRect superviewBounds = [[self superview] bounds];
  CGPoint superviewTargetPoint = [[self superview] convertPoint:[self targetPoint] fromView:[self targetView]];
  
  CGRect frame = CGRectZero;
  frame.size.width = frame.size.height = Diameter;
  
  frame.origin.x = superviewTargetPoint.x - Diameter / 2.0f;
  if (frame.origin.x < CGRectGetMinX(superviewBounds) - frame.size.width * 0.3f) {
    frame.origin.x = CGRectGetMinX(superviewBounds) - frame.size.width * 0.3f;
  } else if (frame.origin.x > CGRectGetMaxX(superviewBounds) - frame.size.width * 0.7f) {
    frame.origin.x = CGRectGetMaxX(superviewBounds) - frame.size.width * 0.7f;
  }
  
  frame.origin.y = superviewTargetPoint.y - Diameter;
  if (frame.origin.y < CGRectGetMinY(superviewBounds) - frame.size.height * 0.3f) {
    frame.origin.y = CGRectGetMinY(superviewBounds) - frame.size.height * 0.3f;
  } else if (frame.origin.y > CGRectGetMaxY(superviewBounds) - frame.size.height * 0.7f) {
    frame.origin.y = CGRectGetMaxY(superviewBounds) - frame.size.height * 0.7f;
  }
  
  // Use bounds and center in case if transform is not idnetity.
  [self setBounds:CGRectMake(0.0f, 0.0f, CGRectGetWidth(frame), CGRectGetHeight(frame))];
  [self setCenter:CGPointMake(CGRectGetMidX(frame), CGRectGetMidY(frame))];
}

- (void)updateTargetFrame {
  CGRect targetFrame = CGRectZero;
  targetFrame.origin.x = [self targetPoint].x - TargetPointOffset.x / [self magnification];
  targetFrame.origin.y = [self targetPoint].y - TargetPointOffset.y / [self magnification];
  targetFrame.size.width = targetFrame.size.height = Diameter / [self magnification];
  [self setTargetFrame:targetFrame];
}

- (void)drawRect:(CGRect)rect {
  CGContextRef context = UIGraphicsGetCurrentContext();
  CGContextAddEllipseInRect(context, CGRectInset([self bounds], LOOMagGlassLensFrameWidth, LOOMagGlassLensFrameWidth));
  CGContextClip(context);
  
  [super drawRect:rect];
}

- (void)setTransformToHidden {
  CGAffineTransform hiddenTransform = CGAffineTransformMakeTranslation(0.0f, [self bounds].size.height * 0.5f);
  hiddenTransform = CGAffineTransformScale(hiddenTransform, 0.01f, 0.01f);
  [self setTransform:hiddenTransform];
}

@end
