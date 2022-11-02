/*
 AJRVector.h
 AJRInterfaceFoundation

 Copyright © 2022, AJ Raftis and AJRInterfaceFoundation authors
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

typedef CGPoint AJRVector;

/* linear interpolation from l (when a=0) to h (when a=1)*/
/* (equal to (a*h)+((1-a)*l) */
#define AJRLinearInterpolation(a,l,h)  ((l) + (((h) - (l)) * (a)))

/* take binary sign of a, either -1, or 1 if >= 0 */
#define AJRBinarySign(a)    (((a) < 0) ? -1 : 0)

/* returns squared length of input vector */    
double AJRVectorSquaredLength(AJRVector a);
    
/* returns length of input vector */
double AJRVectorLength(AJRVector a);
    
/* negates the input vector and returns it */
AJRVector AJRVectorNegate(AJRVector v);

/* normalizes the input vector and returns it */
AJRVector AJRVectorNormalize(AJRVector v);

/* scales the input vector to the new length and returns it */
AJRVector AJRVectorScale(AJRVector v, double newLength);

/* return vector sum c = a+b */
AJRVector AJRVectorAdd(AJRVector a, AJRVector b);
    
/* return vector difference c = a-b */
AJRVector AJRVectorSubtract(AJRVector a, AJRVector b);

/* return the dot product of vectors a and b */
double AJRVectorDotProduct(AJRVector a, AJRVector b);

/* linearly interpolate between vectors by an amount alpha */
/* and return the resulting vector. */
/* When alpha=0, result=lo.  When alpha=1, result=hi. */
AJRVector AJRVectorLinearInterpolation(AJRVector lo, AJRVector hi, double alpha);

/* make a linear combination of two vectors and return the result. */
/* result = (a * ajrcl) + (b * bscl) */
AJRVector AJRVectorCombination(AJRVector a, AJRVector b, double ajrcl, double bscl);

/* multiply two vectors together component-wise */
AJRVector AJRVectorMultiply(AJRVector a, AJRVector b);

/* return the vector perpendicular to the input vector a */
AJRVector AJRPerpendicularVector(AJRVector a);

/* binary greatest common divisor by Silver and Terzian.  See Knuth */
/* both inputs must be >= 0 */
NSInteger AJRGreatestCommonDivisor(NSInteger u, NSInteger v);

/* return roots of ax^2+bx+c */
/* stable algebra derived from Numerical Recipes by Press et al.*/
NSInteger AJRQuadraticRoots(double a, double b, double c, double *roots);

/* generic 1d regula-falsi step.  f is function to evaluate */
/* interval known to contain root is given in left, right */
/* returns new estimate */
double AJRRegulaFalsi(double (*f)(double), double left, double right);

/* generic 1d Newton-Raphson step. f is function, df is derivative */
/* x is current best guess for root location. Returns new estimate */
double AJRNewtonRaphson(double (*f)(double), double (*df)(double), double x);

/* hybrid 1d Newton-Raphson/Regula Falsi root finder. */
/* input function f and its derivative df, an interval */
/* left, right known to contain the root, and an error tolerance */
/* Based on Blinn */
double AJRFindRoot(double left, double right, double tolerance, double (*f)(double), double (*df)(double));
