//
//  LOOReadingGlassLensView.m
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

#import "LOOReadingGlassLensView.h"
#import "LOOReadingGlassLensDecorView.h"
#import "LOOLensBaseView+Protected.h"

static const CGFloat DefaultMagnification = 1.5f;

@interface LOOReadingGlassLensView () {
  LOOReadingGlassLensDecorView *_decorView;
  CGPathRef _innerPath;
  CGPathRef _outerPath;
}

- (void)updateFrame;

@end

@implementation LOOReadingGlassLensView

@synthesize magnification = _magnification;
@dynamic targetFrame;

- (id)init {
  self = [super initWithFrame:CGRectMake(0.0f, 0.0f, 100.0f, 20.0f)];
  if (self) {
    [self setOpaque:NO];
    [self setClipsToBounds:NO];
    [self setMagnification:DefaultMagnification];
    
    [[self layer] setShadowOffset:CGSizeMake(0.0f, 3.0f)];
    [[self layer] setShadowOpacity:1.0f];
    
    CGRect decorViewFrame = CGRectInset([self bounds], -LOOReadingGlassLensFrameWidth, -LOOReadingGlassLensFrameWidth);
    decorViewFrame.size.height += LOOReadingGlassLensArrowHeight;
    _decorView = [[[LOOReadingGlassLensDecorView alloc] initWithFrame:decorViewFrame] autorelease];
    [self addSubview:_decorView];
  }
  return self;
}

- (void)dealloc {
  CGPathRelease(_innerPath);
  CGPathRelease(_outerPath);
  [super dealloc];
}

- (void)layoutSubviews {
  [super layoutSubviews];
  
  CGRect decorViewFrame = CGRectInset([self bounds], -LOOReadingGlassLensFrameWidth, -LOOReadingGlassLensFrameWidth);
  decorViewFrame.size.height += LOOReadingGlassLensArrowHeight;
  [_decorView setFrame:decorViewFrame];
  
  CGPathRelease(_innerPath);
  _innerPath = [LOOReadingGlassLensDecorView createInnerPathWithBounds:decorViewFrame];
  
  CGPathRelease(_outerPath);
  _outerPath = [LOOReadingGlassLensDecorView createOuterPathWithBounds:decorViewFrame];
  
  [[self layer] setShadowPath:_outerPath];
}

- (void)setMagnification:(CGFloat)magnification {
  _magnification = magnification;
  [self updateFrame];
}

- (void)setTargetFrame:(CGRect)targetFrame {
  [super setTargetFrame:targetFrame];
  [self updateFrame];
}

- (void)updateFrame {
  CGRect convTargetFrame = [[self targetView] convertRect:[self targetFrame] toView:[self superview]];
  CGRect frame = convTargetFrame;
  frame.size.width = ceilf(frame.size.width * [self magnification]);
  frame.size.height = ceilf(frame.size.height * [self magnification]);
  frame.origin.x -= ceilf((frame.size.width - convTargetFrame.size.width) / 2.0f);
  frame.origin.y -= frame.size.height - convTargetFrame.size.height;
  frame.origin.y -= frame.size.height + LOOReadingGlassLensArrowHeight;
  
  CGRect superviewBounds = [[self superview] bounds];
  
  if (frame.origin.y < CGRectGetMinY(superviewBounds) - frame.size.width * 0.3f) {
    frame.origin.y = CGRectGetMinY(superviewBounds) - frame.size.width * 0.3f;
  } else if (frame.origin.y > CGRectGetMaxY(superviewBounds) - frame.size.height * 0.7f) {
    frame.origin.y = CGRectGetMaxY(superviewBounds) - frame.size.height * 0.7f;
  }
  
  // Use bounds and center in case if transform is not idnetity.
  [self setBounds:CGRectMake(0.0f, 0.0f, CGRectGetWidth(frame), CGRectGetHeight(frame))];
  [self setCenter:CGPointMake(CGRectGetMidX(frame), CGRectGetMidY(frame))];
}

- (void)drawRect:(CGRect)rect {
  CGContextRef context = UIGraphicsGetCurrentContext();
  CGContextAddPath(context, _innerPath);
  CGContextClip(context);
  
  [super drawRect:rect];
}

- (void)setTransformToHidden {
  CGFloat translation = [_decorView bounds].size.height * 0.5f + ([_decorView center].y - [self bounds].size.height * 0.5f);
  CGAffineTransform hiddenTransform = CGAffineTransformMakeTranslation(0.0f, translation);
  hiddenTransform = CGAffineTransformScale(hiddenTransform, 0.01f, 0.01f);
  [self setTransform:hiddenTransform];
}

@end
