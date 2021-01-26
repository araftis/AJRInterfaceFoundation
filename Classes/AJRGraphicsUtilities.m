//
//  AJRGraphicsUtilities.m
//  AJRInterfaceFoundation
//
//  Created by A.J. Raftis on 6/25/18.
//  Copyright © 2018 A.J. Raftis. All rights reserved.
//

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
