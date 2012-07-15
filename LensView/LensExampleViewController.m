//
//  LensExampleViewController.m
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

#import "LensExampleViewController.h"
#import "LensSierpinskiView.h"
#import "LOOMagGlassLensView.h"
#import "LOOReadingGlassLensView.h"

typedef enum {
  LensMagGlass,
  LensReadingGlass,
  LensCount
} LensType;

@interface LensExampleViewController () {
  LensType _currLensType;
}

@property (nonatomic, retain) UISegmentedControl *lensSelectControl;
@property (nonatomic, retain) LOOMagGlassLensView *magGlassLensView;
@property (nonatomic, retain) LOOReadingGlassLensView *readingGlassLensView;

- (void)nilifyOutlets;

- (void)lensSelectChanged:(UIControl *)control;
- (void)handlePanGesture:(UIPanGestureRecognizer *)gesture;

@end

@implementation LensExampleViewController

@synthesize lensSelectControl = _lensSelectControl;
@synthesize magGlassLensView = _magGlassLensView;
@synthesize readingGlassLensView = _readingGlassLensView;

- (id)init {
  self = [super initWithNibName:nil bundle:nil];
  if (self) {
    _currLensType = LensMagGlass;
  }
  return self;
}

- (void)dealloc {
  [self nilifyOutlets];
  [super dealloc];
}

- (void)nilifyOutlets {
  [self setLensSelectControl:nil];
  [self setMagGlassLensView:nil];
  [self setReadingGlassLensView:nil];
}

- (void)loadView {
  [self setView:[[[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]] autorelease]];
  
  NSArray *lensSelectItems = [NSArray arrayWithObjects:@"Magnifying Glass", @"Reading Glass", nil];
  [self setLensSelectControl:[[[UISegmentedControl alloc] initWithItems:lensSelectItems] autorelease]];
  CGRect lensSelectFrame = [[self lensSelectControl] frame];
  lensSelectFrame.size.width = [[self view] bounds].size.width;
  [[self lensSelectControl] setFrame:lensSelectFrame];
  [[self lensSelectControl] setAutoresizingMask:(UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin)];
  [[self lensSelectControl] setSegmentedControlStyle:UISegmentedControlStylePlain];
  [[self lensSelectControl] setSelectedSegmentIndex:_currLensType];
  [[self lensSelectControl] addTarget:self action:@selector(lensSelectChanged:) forControlEvents:UIControlEventValueChanged];
  [[self view] addSubview:[self lensSelectControl]];
  
  [[self view] addGestureRecognizer:[[[UIPanGestureRecognizer alloc]
      initWithTarget:self action:@selector(handlePanGesture:)] autorelease]];
  
  CGRect sierpinskiFrame = CGRectMake(0.0f, lensSelectFrame.size.height,
      lensSelectFrame.size.width, [[self view] bounds].size.height - lensSelectFrame.size.height);
  LensSierpinskiView *sierpinskiView = [[[LensSierpinskiView alloc] initWithFrame:sierpinskiFrame] autorelease];
  [sierpinskiView setAutoresizingMask:(UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight)];
  [[self view] addSubview:sierpinskiView];
  
  [self setMagGlassLensView:[[[LOOMagGlassLensView alloc] init] autorelease]];
  [[self magGlassLensView] setTargetView:[self view]];
  [[self magGlassLensView] setMagnification:2.0f];
  
  [self setReadingGlassLensView:[[[LOOReadingGlassLensView alloc] init] autorelease]];
  [[self readingGlassLensView] setTargetView:[self view]];
  [[self readingGlassLensView] setMagnification:2.0f];
}

- (void)viewDidUnload {
  [super viewDidUnload];
  [self nilifyOutlets];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
  if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
    return interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown;
  }
  return YES;
}

- (void)lensSelectChanged:(UIControl *)control {
  _currLensType = [[self lensSelectControl] selectedSegmentIndex];
}

- (void)handlePanGesture:(UIPanGestureRecognizer *)gesture {
  if ([gesture state] == UIGestureRecognizerStateBegan || [gesture state] == UIGestureRecognizerStateChanged) {
    
    if (_currLensType == LensMagGlass) {
      if (![[self magGlassLensView] superview]) {
        [[self view] addSubview:[self magGlassLensView]];
        [[self magGlassLensView] setTransformToHidden];
        [UIView animateWithDuration:0.2 animations:^{
          [[self magGlassLensView] setTransform:CGAffineTransformIdentity];
        }];
      }
      [[self magGlassLensView] setTargetPoint:[gesture locationInView:[self view]]];
    
    } else if (_currLensType == LensReadingGlass) {
      if (![[self readingGlassLensView] superview]) {
        [[self view] addSubview:[self readingGlassLensView]];
        [[self readingGlassLensView] setTransformToHidden];
        [UIView animateWithDuration:0.2 animations:^{
          [[self readingGlassLensView] setTransform:CGAffineTransformIdentity];
        }];
      }
      CGRect targetFrame;
      targetFrame.origin = [gesture locationInView:[self view]];
      targetFrame.origin.x -= 40.0f;
      targetFrame.origin.y -= 5.0f;
      targetFrame.size.width = 80.0f;
      targetFrame.size.height = 10.0f;
      [[self readingGlassLensView] setTargetFrame:targetFrame];
    }
    
  } else if ([gesture state] == UIGestureRecognizerStateEnded) {
    if (_currLensType == LensMagGlass) {
      [UIView animateWithDuration:0.2 animations:^{
        [[self magGlassLensView] setTransformToHidden];
      } completion:^(BOOL finished) {
        [[self magGlassLensView] removeFromSuperview];
      }];
    
    } else if (_currLensType == LensReadingGlass) {
      [UIView animateWithDuration:0.2 animations:^{
        [[self readingGlassLensView] setTransformToHidden];
      } completion:^(BOOL finished) {
        [[self readingGlassLensView] removeFromSuperview];
      }];
    }
  }
}

@end
