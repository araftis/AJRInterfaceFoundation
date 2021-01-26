//
//  AJRGraphicsUtilities.h
//  AJRInterfaceFoundation
//
//  Created by A.J. Raftis on 6/25/18.
//  Copyright © 2018 A.J. Raftis. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

#pragma mark - Accessing the Current Graphics Context

extern _Nullable CGContextRef AJRGetCurrentContext(void) CF_RETURNS_NOT_RETAINED;

#pragma mark - Graphics State

extern CGFloat AJRGetCurrentScale(void);
extern BOOL AJRGetCurrentScales(CGFloat * _Nullable xScale, CGFloat * _Nullable yScale);
extern void AJRDrawWithSavedGraphicsState(CGContextRef context, void (^block)(CGContextRef context));

#pragma mark - Paths

extern void AJRContextAddRoundedRectToPath(CGContextRef context, CGRect rect, CGFloat cornerRadius);

NS_ASSUME_NONNULL_END
