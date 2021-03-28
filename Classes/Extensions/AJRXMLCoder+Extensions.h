
#import <AJRFoundation/AJRFoundation.h>

@interface AJRXMLCoder (Extensions)

// Encoding
- (void)encodePoint:(CGPoint)point forKey:(NSString *)key;
- (void)encodeSize:(CGSize)size forKey:(NSString *)key;
- (void)encodeRect:(CGRect)rect forKey:(NSString *)key;

// Decoding
- (void)decodePointForKey:(NSString *)key setter:(void (^)(CGPoint point))setter;
- (void)decodeSizeForKey:(NSString *)key setter:(void (^)(CGSize size))setter;
- (void)decodeRectForKey:(NSString *)key setter:(void (^)(CGRect rect))setter;

@end
