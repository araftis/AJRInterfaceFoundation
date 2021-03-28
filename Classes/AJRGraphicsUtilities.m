/*
AJRGraphicsUtilities.m
AJRInterfaceFoundation

Copyright © 2021, AJ Raftis and AJRFoundation authors
All rights reserved.

Redistribution and use in source and binary forms, with or without modification,
are permitted provided that the following conditions are met:

* Redistributions of source code must retain the above copyright notice, this 
  list of conditions and the following disclaimer.
* Redistributions in binary form must reproduce the above copyright notice, 
  this list of conditions and the following disclaimer in the documentation 
  and/or other materials provided with the distribution.
* Neither the name of AJRFoundation nor the names of its contributors may be 
  used to endorse or promote products derived from this software without 
  specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED 
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE 
DISCLAIMED. IN NO EVENT SHALL AJ RAFTIS BE LIABLE FOR ANY DIRECT, INDIRECT, 
INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR 
PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF 
LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF 
ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#import "AJRGraphicsUtilities.h"

#import <dlfcn.h>
#import <AJRFoundation/AJRFoundation.h>

#pragma makr - Accessing the Current Graphics Context

typedef id (*AJRCurrentContextIMP)(Class class, SEL _cmd);
typedef CGContextRef (*AJRGetCGContextIMP)(Class class, SEL _cmd);
typedef CGContextRef (*AJRGetCGContextFunc)(void);

CGContextRef AJRGetCurrentContext(void) {
    static Class possibleClass = Nil;
    static SEL currentContextSelector;
    static AJRCurrentContextIMP getCurrentContextMethod;
    static SEL CGContextSelector;
    static AJRGetCGContextIMP getCGContextMethod;
    static AJRGetCGContextFunc getCGContextFunction;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        possibleClass = NSClassFromString(@"NSGraphicsContext");
        currentContextSelector = NSSelectorFromString(@"currentContext");
        getCurrentContextMethod = (AJRCurrentContextIMP)[possibleClass methodForSelector:currentContextSelector];
        CGContextSelector = NSSelectorFromString(@"CGContext");
        getCGContextMethod = (AJRGetCGContextIMP)[possibleClass instanceMethodForSelector:CGContextSelector];
    });
    
    if (!possibleClass) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            getCGContextFunction = (AJRGetCGContextFunc)dlsym(RTLD_DEFAULT, "UIGraphicsGetCurrentContext");
        });
    }
    
    CGContextRef context = NULL;
    
    if (possibleClass) {
        // We're drawing in Cocoa...
        id nsGraphicsContext = getCurrentContextMethod(possibleClass, currentContextSelector);
        if (nsGraphicsContext) {
            context = getCGContextMethod(nsGraphicsContext, CGContextSelector);
        }
    } else if (getCGContextFunction) {
        context = getCGContextFunction();
    }
    
    return context;
}

#pragma mark - Graphics State

CGFloat AJRGetCurrentScale(void) {
    CGFloat scale;
    if (AJRGetCurrentScales(&scale, NULL)) {
        return scale;
    }
    return 1.0;
}

BOOL AJRGetCurrentScales(CGFloat *xScale, CGFloat *yScale) {
    CGContextRef context = AJRGetCurrentContext();
    
    if (context) {
        CGAffineTransform aTransform = CGContextGetCTM(context);
        
        AJRSetOutParameter(xScale, fabs(aTransform.a));
        AJRSetOutParameter(yScale, fabs(aTransform.d));
        
        return YES;
    }
    return NO;
}

void AJRDrawWithSavedGraphicsState(CGContextRef context, void (^block)(CGContextRef context)) {
    CGContextSaveGState(context);
    block(context);
    CGContextRestoreGState(context);
}

#pragma mark - Paths

void AJRContextAddRoundedRectToPath(CGContextRef context, CGRect rect, CGFloat cornerRadius) {
    if (cornerRadius * 2.0 > rect.size.width) {
        cornerRadius = rect.size.width / 2.0;
    }
    if (cornerRadius * 2.0 > rect.size.height) {
        cornerRadius = rect.size.height / 2.0;
    }
    
    if (cornerRadius <= 0.0) {
        CGContextAddRect(context, rect);
    } else {
        CGContextMoveToPoint(context, CGRectGetMinX(rect), CGRectGetMidY(rect));
        CGContextAddArcToPoint(context, CGRectGetMinX(rect), CGRectGetMaxY(rect), CGRectGetMaxX(rect), CGRectGetMaxY(rect), cornerRadius);
        CGContextAddArcToPoint(context, CGRectGetMaxX(rect), CGRectGetMaxY(rect), CGRectGetMaxX(rect), CGRectGetMinY(rect), cornerRadius);
        CGContextAddArcToPoint(context, CGRectGetMaxX(rect), CGRectGetMinY(rect), CGRectGetMinX(rect), CGRectGetMinY(rect), cornerRadius);
        CGContextAddArcToPoint(context, CGRectGetMinX(rect), CGRectGetMinY(rect), CGRectGetMinX(rect), CGRectGetMaxY(rect), cornerRadius);
        CGContextClosePath(context);
    }
}
