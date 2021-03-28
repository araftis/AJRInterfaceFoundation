
#import "AJRVertex.h"

@implementation AJRVertex

+ (id)vertexWithPoint:(CGPoint)point {
    AJRVertex *vertex = [[self alloc] init];
    [vertex setPoint:point];
    return vertex;
}

@end
