
#import <Foundation/Foundation.h>

typedef struct {
    CGFloat top;
    CGFloat left;
    CGFloat bottom;
    CGFloat right;
} AJRInset;

extern AJRInset AJRInsetZero;

extern NSString *AJRStringFromInset(AJRInset inset);
extern AJRInset AJRInsetFromString(NSString *inset);

extern NSDictionary *AJRDictionaryFromInset(AJRInset inset);
extern AJRInset AJRInsetFromDictionary(NSDictionary *inset);

extern BOOL AJRInsetEqual(AJRInset left, AJRInset right);

@interface NSDictionary (AJRInset)
- (AJRInset)insetForKey:(NSString *)key defaultValue:(AJRInset)defaultInset;
@end

@interface NSMutableDictionary (AJRInset)
- (void)setInset:(AJRInset)inset forKey:(NSString *)key;
@end

@interface NSUserDefaults (AJRInset)
- (void)setInset:(AJRInset)inset forKey:(NSString *)key;
- (AJRInset)insetForKey:(NSString *)key defaultValue:(AJRInset)defaultInset;
@end

@interface NSCoder (AJRInset)
- (void)encodeInset:(AJRInset)inset forKey:(NSString *)key;
- (AJRInset)decodeInsetForKey:(NSString *)key;
@end
