//
//  CATransaction+Extensions.m
//  Meta Monkey
//
//  Created by A.J. Raftis on 1/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CATransaction+Extensions.h"

@implementation CATransaction (AJRInterfaceFoundationExtensions)

+ (void)ajr_preserveTransactionPropertyStateDuring:(void(^)(void))block {
    // Instead of getting each value locally, another implementation option would have been to have a method +allTransactionPropertyKeys,
    // and then to loop over those and call +valueForKey: and stick each value in a dictionary, and then go through the dictionary
    // after the block was called and call +setValue:forKey:. While this might have been cleaner, because this has the potential to
    // be a hot path, I didn't want to incur a mutable dictionary cost for something that would be more straight-forward.
    CAMediaTimingFunction *timingFunction = [CATransaction animationTimingFunction];
    CFTimeInterval animationDuration = [CATransaction animationDuration];
    void (^completionBlock)(void) = [CATransaction completionBlock];
    BOOL disableActions = [CATransaction disableActions];
    
    block();
    
    [CATransaction setAnimationTimingFunction:timingFunction];
    [CATransaction setAnimationDuration:animationDuration];
    [CATransaction setCompletionBlock:completionBlock];
    [CATransaction setDisableActions:disableActions];
}

@end
