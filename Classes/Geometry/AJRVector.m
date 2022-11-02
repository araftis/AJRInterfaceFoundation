/*
 AJRVector.m
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

#import <AJRVector.h>

#import <math.h>

/******************/
/*   2d Library   */
/******************/

/* returns squared length of input vector */    
double AJRVectorSquaredLength(AJRVector a) {
   return (a.x * a.x) + (a.y * a.y);
}
    
/* returns length of input vector */
double AJRVectorLength(AJRVector a) {
   return sqrt(AJRVectorSquaredLength(a));
}
    
/* negates the input vector and returns it */
AJRVector AJRVectorNegate(AJRVector v) {
    v.x = -v.x;
    v.y = -v.y;
   
    return v;
}

/* normalizes the input vector and returns it */
AJRVector AJRVectorNormalize(AJRVector v) {
   double length = AJRVectorLength(v);
   
   if (length != 0.0) {
      v.x /= length;
      v.y /= length;
   };
    return v;
}

/* scales the input vector to the new length and returns it */
AJRVector AJRVectorScale(AJRVector v, double newLength) {
    double length = AJRVectorLength(v);

    if (length != 0.0) {
        v.x *= newLength / length;
        v.y *= newLength / length;
    }

    return v;
}

/* return vector sum c = a+b */
AJRVector AJRVectorAdd(AJRVector a, AJRVector b) {
    AJRVector c;

    c.x = a.x + b.x;
    c.y = a.y + b.y;
    
    return c;
}

/* return vector difference c = a-b */
AJRVector AJRVectorSubtract(AJRVector a, AJRVector b) {
    AJRVector c;

    c.x = a.x - b.x;
    c.y = a.y - b.y;

    return c;
}

/* return the dot product of vectors a and b */
double AJRVectorDotProduct(AJRVector a, AJRVector b) 
{
    return (a.x * b.x) + (a.y * b.y);
}

/* linearly interpolate between vectors by an amount alpha */
/* and return the resulting vector. */
/* When alpha=0, result=lo.  When alpha=1, result=hi. */
AJRVector AJRVectorLinearInterpolation(AJRVector lo, AJRVector hi, double alpha) 
{
   AJRVector result;

   result.x = AJRLinearInterpolation(alpha, lo.x, hi.x);
   result.y = AJRLinearInterpolation(alpha, lo.y, hi.y);

   return result;
}

/* make a linear combination of two vectors and return the result. */
/* result = (a * ajrcl) + (b * bscl) */
AJRVector AJRVectorCombination(AJRVector a, AJRVector b, double ajrcl, double bscl) 
{
   AJRVector result;

    result.x = (ajrcl * a.x) + (bscl * b.x);
    result.y = (ajrcl * a.y) + (bscl * b.y);
   
    return result;
}

/* multiply two vectors together component-wise */
AJRVector AJRVectorMultiply(AJRVector a, AJRVector b) 
{
   AJRVector result;
   
    result.x = a.x * b.x;
    result.y = a.y * b.y;
   
    return result;
}

/* return the vector perpendicular to the input vector a */
AJRVector AJRPerpendicularVector(AJRVector a)
{
   AJRVector    ap;
   
    ap.x = -a.y;
    ap.y = a.x;
   
    return ap;
}

/* binary greatest common divisor by Silver and Terzian.  See Knuth */
/* both inputs must be >= 0 */
NSInteger AJRGreatestCommonDivisor(NSInteger u, NSInteger v) {
    NSInteger k, t, f;

    if ((u < 0) || (v < 0)) return(1); /* error if u<0 or v<0 */
    k = 0;
    f = 1;
    while ((0 == (u % 2)) && (0 == (v % 2))) {
        k++;
        u >>= 1;
        v >>= 1;
        f *= 2;
    }
    if (u & 01) {
        t = -v;
        goto B4;
    } else {
        t = u;
    }

B3:
    if (t > 0) {
        t >>= 1;
    } else {
        t = -((-t) >> 1);
    }
B4:
    if (0 == (t % 2)) goto B3;

    if (t > 0) u = t;
    else v = -t;

    if (0 != (t = u - v)) goto B3;

    return u * f;
}    

/***********************/
/*   Useful Routines   */
/***********************/

/* return roots of ax^2+bx+c */
/* stable algebra derived from Numerical Recipes by Press et al.*/
NSInteger AJRQuadraticRoots(double a, double b, double c, double *roots)
{
   double     d, q;
   NSInteger         count = 0;
   
   d = (b * b) - (4 * a * c);
   if (d < 0.0) {
      *roots = *(roots+1) = 0.0;
      return 0;
   }
   
   q = -0.5 * (b + (AJRBinarySign(b) * sqrt(d)));
   if (a != 0.0) {
      *roots++ = q / a;
      count++;
   }
   if (q != 0.0) {
      *roots++ = c / q;
      count++;
   }

   return count;
}


/* generic 1d regula-falsi step.  f is function to evaluate */
/* interval known to contain root is given in left, right */
/* returns new estimate */
double AJRRegulaFalsi(double (*f)(double), double left, double right)
{
   double d = (*f)(right) - (*f)(left);
   
   if (d != 0.0) return (right - (*f)(right) * (right - left) / d);
   
   return (left + right) / 2.0;
}

/* generic 1d Newton-Raphson step. f is function, df is derivative */
/* x is current best guess for root location. Returns new estimate */
double AJRNewtonRaphson(double (*f)(double), double (*df)(double), double x)
{
   double d = (*df)(x);
   if (d != 0.0) return (x - ((*f)(x) / d));
   return x - 1.0;
}


/* hybrid 1d Newton-Raphson/Regula Falsi root finder. */
/* input function f and its derivative df, an interval */
/* left, right known to contain the root, and an error tolerance */
/* Based on Blinn */
double AJRFindRoot(double left, double right, double tolerance, double (*f)(double), double (*df)(double))
{
   double newx = left;
   
   while (fabs((*f)(newx)) > tolerance) {
      newx = AJRNewtonRaphson(f, df, newx);
      if (newx < left || newx > right)
         newx = AJRRegulaFalsi(f, left, right);
      if ((*f)(newx) * (*f)(left) <= 0.0) right = newx;
      else left = newx;
   }
   
   return newx;
}
