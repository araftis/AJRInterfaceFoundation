//
//  CATransaction+Extensions.h
//  Meta Monkey
//
//  Created by A.J. Raftis on 1/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

@interface CATransaction (AJRInterfaceFoundationExtensions)

+ (void)ajr_preserveTransactionPropertyStateDuring:(void(^)(void))block;

@end
