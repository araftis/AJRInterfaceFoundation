//
//  AJRPathAnalyzer.h
//  AJRInterface
//
//  Created by A.J. Raftis on 10/21/11.
//  Copyright (c) 2011 A.J. Raftis. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AJRBezierPath;

@interface AJRPathAnalysisCorner : NSObject

@property (nonatomic,assign) CGFloat angle;
@property (nonatomic,assign) CGFloat delta;
@property (nonatomic,assign) CGPoint point;

@end


@interface AJRPathAnalysisContour : NSObject

@property (nonatomic,readonly,assign) CGRect bounds;
@property (nonatomic,readonly,strong) NSArray *corners;

@end


@interface AJRPathAnalyzer : NSObject

@property (nonatomic,readonly,strong) AJRBezierPath *path;
@property (nonatomic,readonly,strong) NSArray *contours;

- (id)initWithPath:(AJRBezierPath *)path;

- (AJRBezierPath *)simplifiedPath;

@end
