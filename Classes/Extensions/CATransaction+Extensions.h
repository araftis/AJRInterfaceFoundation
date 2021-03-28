
#import <QuartzCore/QuartzCore.h>

@interface CATransaction (AJRInterfaceFoundationExtensions)

+ (void)ajr_preserveTransactionPropertyStateDuring:(void(^)(void))block;

@end
