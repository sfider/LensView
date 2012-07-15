//
//  LOOCGFunctions.m
//
//  Created by Marcin Swiderski on 1/31/12.
//  Copyright (c) 2012 Marcin Swiderski. All rights reserved.
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

#import "LOOCGFunctions.h"

void LOOCGContextAddRoundedPolygon(CGContextRef context, LOOCGCorner corners[], size_t cornersCnt) {
  CGFloat fstLstDx = corners[cornersCnt - 1].x - corners[0].x;
  CGFloat fstLstDy = corners[cornersCnt - 1].y - corners[0].y;
  CGFloat fstLstDst = sqrtf(fstLstDx * fstLstDx + fstLstDy * fstLstDy);
  CGContextMoveToPoint(context,
      corners[0].x + fstLstDx / fstLstDst * corners[0].radius,
      corners[0].y + fstLstDy / fstLstDst * corners[0].radius);
  for (NSInteger i = 0; i != cornersCnt; ++i) {
    NSInteger j = i + 1 != cornersCnt ? i + 1 : 0;
    CGContextAddArcToPoint(context, corners[i].x, corners[i].y, corners[j].x, corners[j].y, corners[i].radius);
  }
  CGContextClosePath(context);
}

void LOOCGPathAddRoundedPolygon(CGMutablePathRef path, const CGAffineTransform *m, LOOCGCorner corners[], size_t cornersCnt) {
  CGFloat fstLstDx = corners[cornersCnt - 1].x - corners[0].x;
  CGFloat fstLstDy = corners[cornersCnt - 1].y - corners[0].y;
  CGFloat fstLstDst = sqrtf(fstLstDx * fstLstDx + fstLstDy * fstLstDy);
  CGPathMoveToPoint(path, m,
      corners[0].x + fstLstDx / fstLstDst * corners[0].radius,
      corners[0].y + fstLstDy / fstLstDst * corners[0].radius);
  for (NSInteger i = 0; i != cornersCnt; ++i) {
    NSInteger j = i + 1 != cornersCnt ? i + 1 : 0;
    CGPathAddArcToPoint(path, m, corners[i].x, corners[i].y, corners[j].x, corners[j].y, corners[i].radius);
  }
  CGPathCloseSubpath(path);
}