//
//  AJRVertex.h
//  AJRInterface
//
//  Created by A.J. Raftis on 9/27/11.
//  Copyright (c) 2011 A.J. Raftis. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AJRVertex : NSObject

+ (id)vertexWithPoint:(CGPoint)point;

@property (nonatomic,assign) CGPoint point;
@property (nonatomic,strong) AJRVertex *next;
@property (nonatomic,strong) AJRVertex *previous;
@property (nonatomic,assign) BOOL intersect;
@property (nonatomic,assign) BOOL entryExit;
@property (nonatomic,strong) AJRVertex *neighbor;
@property (nonatomic,assign) double alpha;

@end
