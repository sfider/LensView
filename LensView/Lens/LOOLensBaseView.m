//
//  LOOLensBaseView.m
//
//  Created by Marcin Świderski on 3/13/12.
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

#import "LOOLensBaseView.h"
#import "LOOLensBaseView+Protected.h"

@interface LOOLensBaseView ()

@property (nonatomic, assign) CGRect targetFrame;

@end

@implementation LOOLensBaseView

@synthesize targetView = _targetView;
@synthesize targetFrame = _targetFrame;

- (id)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    [self setContentMode:UIViewContentModeRedraw];
  }
  return self;
}

- (void)dealloc {
  [_targetView release];
  [super dealloc];
}

- (void)setTargetView:(UIView *)targetView {
  NSAssert(![targetView isKindOfClass:[UIWindow class]], @"Use UIViewController view instead.");
  [_targetView autorelease];
  _targetView = [targetView retain];
  [self setNeedsDisplay];
}

- (void)setTargetFrame:(CGRect)targetFrame {
  _targetFrame = targetFrame;
  [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
  CGContextRef context = UIGraphicsGetCurrentContext();
  CGRect bounds = [self bounds];
  
  CGContextSetFillColorWithColor(context, [[self backgroundColor] CGColor]);
  CGContextFillRect(context, rect);
  
  // Apply transform for target frame.
  CGRect targetFrame = [self targetFrame];
  CGContextScaleCTM(context, bounds.size.width / targetFrame.size.width, bounds.size.height / targetFrame.size.height);
  CGContextTranslateCTM(context, -targetFrame.origin.x, -targetFrame.origin.y);
  
  // Render without lens in view.
  [self setHidden:YES];
  [[[self targetView] layer] renderInContext:context];
  [self setHidden:NO];
}

@end

