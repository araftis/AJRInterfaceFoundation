/*
AJRInset.h
AJRInterfaceFoundation

Copyright © 2021, AJ Raftis and AJRFoundation authors
All rights reserved.

Redistribution and use in source and binary forms, with or without modification,
are permitted provided that the following conditions are met:

* Redistributions of source code must retain the above copyright notice, this 
  list of conditions and the following disclaimer.
* Redistributions in binary form must reproduce the above copyright notice, 
  this list of conditions and the following disclaimer in the documentation 
  and/or other materials provided with the distribution.
* Neither the name of AJRInterfaceFoundation nor the names of its contributors may be 
  used to endorse or promote products derived from this software without 
  specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED 
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE 
DISCLAIMED. IN NO EVENT SHALL AJ RAFTIS BE LIABLE FOR ANY DIRECT, INDIRECT, 
INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR 
PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF 
LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF 
ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

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
