/*
AJRImageUtilities.h
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

NS_ASSUME_NONNULL_BEGIN

#pragma mark - Generating Image Data

extern NSData * _Nullable AJRPNGDataFromCGImage(CGImageRef image, BOOL interlace);
extern NSData * _Nullable AJRJPEGDataFromCGImage(CGImageRef image, CGFloat compression);
extern NSData * _Nullable AJRGIFDataFromCGImage(CGImageRef image, BOOL ditherTransparency);
extern NSData * _Nullable AJRBMPDataFromCGImage(CGImageRef image);

#pragma mark - Creating Images

extern CGImageRef AJRCreateImage(CGSize size, CGFloat scale, BOOL flipped, CGColorSpaceRef _Nullable colorSpace, void (^commands)(CGContextRef context)) CF_RETURNS_RETAINED;
extern CGImageRef AJRCreateInverseMask(CGImageRef input) CF_RETURNS_RETAINED;

NS_ASSUME_NONNULL_END
