//
//  AJRVertex.m
//  AJRInterface
//
//  Created by A.J. Raftis on 9/27/11.
//  Copyright (c) 2011 A.J. Raftis. All rights reserved.
//

#import "AJRVertex.h"

@implementation AJRVertex

+ (id)vertexWithPoint:(CGPoint)point {
    AJRVertex *vertex = [[self alloc] init];
    [vertex setPoint:point];
    return vertex;
}

@end
