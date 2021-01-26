/*
 An Algorithm for Automatically Fitting Digitized Curves
 by Philip J. Schneider
 from "Graphics Gems", Academic Press, 1990
 */

/*  fit_cubic.c    */                     
/*    Piecewise cubic fitting code    */

#import "AJRBezierCurves.h"

#import "AJRGeometry.h"
#import "AJRVector.h"
#import "NSValue+Extensions.h"

#import <math.h>

/* Forward declarations */
static void FitCubic(CGPoint *points, NSInteger first, NSInteger last, AJRVector tHat1, AJRVector tHat2, double error, NSMutableArray *curves);
static double *Reparameterize(CGPoint *points, NSInteger first, NSInteger last, double *u, AJRBezierCurve bezierCurve);
static double NewtonRaphsonRootFind(AJRBezierCurve Q, CGPoint P, double u);
static CGPoint Bezier(NSInteger degree, CGPoint *V, double t);
static double B0(double), B1(double), B2(double), B3(double);
static AJRVector ComputeLeftTangent(CGPoint *points, NSInteger end);
static AJRVector ComputeRightTangent(CGPoint *points, NSInteger end);
static AJRVector ComputeCenterTangent(CGPoint *points, NSInteger center);
static double ComputeMaxError(CGPoint *points, NSInteger first, NSInteger last, AJRBezierCurve bezierCurve, double *u, NSInteger *splitPoint);
static double *ChordLengthParameterize(CGPoint *points, NSInteger first, NSInteger last);
static AJRBezierCurve GenerateBezier(CGPoint    *points, NSInteger first, NSInteger last, double *uPrime, AJRVector tHat1, AJRVector tHat2);

#define MAXPOINTS    1000       /* The most points you can have */

/*!
 * Fit a Bezier curve to a set of digitized points
 *
 * @param
 * points        array of digitized points
 * pointCount    count of points
 * error           user defined error squared
 */
static NSArray __attribute__((unused)) *AJRBezierCurvesFromPoints(CGPoint *points, NSInteger pointCount, double error) {
    AJRVector tangentHat1, tangentHat2;   /*  Unit tangent vectors at endpoints */
    NSMutableArray *array;
    
    tangentHat1 = ComputeLeftTangent(points, 0);
    tangentHat2 = ComputeRightTangent(points, pointCount - 1);
    
    array = [NSMutableArray arrayWithCapacity:16];
    
    FitCubic(points, 0, pointCount - 1, tangentHat1, tangentHat2, error, array);
    
    return array;
}

/*
 FitCubic :
 Fit a Bezier curve to a (sub)set of digitized points
 */
static void FitCubic(CGPoint *points, NSInteger first, NSInteger last, AJRVector tHat1, AJRVector tHat2, double error, NSMutableArray *curves) {
    AJRBezierCurve        bezierCurve;            /*Control points of fitted Bezier curve*/
    double                *u;                        /*  Parameter values for point  */
    double                *uPrime;                    /*  Improved parameter values */
    double                maxError;                /*  Maximum fitting error     */
    NSInteger                    splitPoint;                /*  Point to split point set at     */
    NSInteger                    nPts;                        /*  Number of points in subset  */
    double                iterationError;        /*Error below which you try iterating  */
    NSInteger                    maxIterations = 4;    /*  Max times to try iterating  */
    AJRVector            tHatCenter;                /* Unit tangent vector at splitPoint */
    NSInteger                    i;
    
    iterationError = error * error;
    nPts = last - first + 1;
    
    /*  Use heuristic if region only has two points in it */
    if (nPts == 2) {
        double dist = AJRDistanceBetweenPoints(points[last], points[first]) / 3.0;
        
        bezierCurve.start = points[first];
        bezierCurve.end = points[last];
        bezierCurve.handle1 = AJRVectorAdd(bezierCurve.start, AJRVectorScale(tHat1, dist));
        bezierCurve.handle2 = AJRVectorAdd(bezierCurve.end, AJRVectorScale(tHat2, dist));
        
        [curves addObject:[NSValue valueWithBezierCurve:bezierCurve]];
        
        return;
    }
    
    /*  Parameterize points, and attempt to fit curve */
    u = ChordLengthParameterize(points, first, last);
    bezierCurve = GenerateBezier(points, first, last, u, tHat1, tHat2);
    
    /*  Find max deviation of points to fitted curve */
    maxError = ComputeMaxError(points, first, last, bezierCurve, u, &splitPoint);
    if (maxError < error) {
        [curves addObject:[NSValue valueWithBezierCurve:bezierCurve]];
        return;
    }
    
    
    /*  If error not too large, try some reparameterization  */
    /*  and iteration */
    if (maxError < iterationError) {
        for (i = 0; i < maxIterations; i++) {
            uPrime = Reparameterize(points, first, last, u, bezierCurve);
            bezierCurve = GenerateBezier(points, first, last, uPrime, tHat1, tHat2);
            maxError = ComputeMaxError(points, first, last, bezierCurve, uPrime, &splitPoint);
            if (maxError < error) {
                [curves addObject:[NSValue valueWithBezierCurve:bezierCurve]];
                return;
            }
            free((char *)u);
            u = uPrime;
        }
    }
    
    /* Fitting failed -- split at max error point and fit recursively */
    tHatCenter = ComputeCenterTangent(points, splitPoint);
    FitCubic(points, first, splitPoint, tHat1, tHatCenter, error, curves);
    tHatCenter = AJRVectorNegate(tHatCenter);
    FitCubic(points, splitPoint, last, tHatCenter, tHat2, error, curves);
}


/*
 *  GenerateBezier :
 *  Use least-squares method to find Bezier control points for region.
 */
static AJRBezierCurve GenerateBezier(CGPoint    *points, NSInteger first, NSInteger last, double *uPrime, AJRVector tHat1, AJRVector tHat2)
// points                Array of digitized points
// first, last            Indices defining region
// uPrime                Parameter values for region
// tHat1, tHat2        Unit tangents at endpoints
{
    NSInteger                 i;
    AJRVector         A[MAXPOINTS][2];    /* Precomputed rhs for eqn    */
    NSInteger                 nPts;                    /* Number of pts in sub-curve */
    double             C[2][2];                /* Matrix C       */
    double             X[2];                    /* Matrix X         */
    double             det_C0_C1,            /* Determinants of matrices    */
    det_C0_X,
    det_X_C1;
    double             alpha_l,                /* Alpha values, left and right    */
    alpha_r;
    AJRVector         tmp;                    /* Utility variable       */
    AJRBezierCurve    bezierCurve;        /* RETURN bezier curve ctl pts    */
    
    nPts = last - first + 1;
    
    /* Compute the A's    */
    for (i = 0; i < nPts; i++) {
        A[i][0] = AJRVectorScale(tHat1, B1(uPrime[i]));
        A[i][1] = AJRVectorScale(tHat2, B2(uPrime[i]));
    }
    
    /* Create the C and X matrices    */
    C[0][0] = 0.0;
    C[0][1] = 0.0;
    C[1][0] = 0.0;
    C[1][1] = 0.0;
    X[0] = 0.0;
    X[1] = 0.0;
    
    for (i = 0; i < nPts; i++) {
        C[0][0] += AJRVectorDotProduct(A[i][0], A[i][0]);
        C[0][1] += AJRVectorDotProduct(A[i][0], A[i][1]);
        /*             C[1][0] += AJRVectorDotProduct(&A[i][0], &A[i][1]);*/
        C[1][0] = C[0][1];
        C[1][1] += AJRVectorDotProduct(A[i][1], A[i][1]);
        
        tmp = AJRVectorSubtract(points[first + i],
                               AJRVectorAdd(
                                           AJRVectorScale(points[first], B0(uPrime[i])),
                                           AJRVectorAdd(
                                                       AJRVectorScale(points[first], B1(uPrime[i])),
                                                       AJRVectorAdd(
                                                                   AJRVectorScale(points[last], B2(uPrime[i])),
                                                                   AJRVectorScale(points[last], B3(uPrime[i]))))));
        
        
        X[0] += AJRVectorDotProduct(A[i][0], tmp);
        X[1] += AJRVectorDotProduct(A[i][1], tmp);
    }
    
    /* Compute the determinants of C and X    */
    det_C0_C1 = C[0][0] * C[1][1] - C[1][0] * C[0][1];
    det_C0_X  = C[0][0] * X[1]    - C[0][1] * X[0];
    det_X_C1  = X[0]    * C[1][1] - X[1]    * C[0][1];
    
    /* Finally, derive alpha values    */
    if (det_C0_C1 == 0.0) {
        det_C0_C1 = (C[0][0] * C[1][1]) * 10e-12;
    }
    alpha_l = det_X_C1 / det_C0_C1;
    alpha_r = det_C0_X / det_C0_C1;
    
    
    /*  If alpha negative, use the Wu/Barsky heuristic (see text) */
    if (alpha_l < 0.0 || alpha_r < 0.0) {
        double    dist = AJRDistanceBetweenPoints(points[last], points[first]) / 3.0;
        
        bezierCurve.start = points[first];
        bezierCurve.end = points[last];
        bezierCurve.handle1 = AJRVectorAdd(bezierCurve.start, AJRVectorScale(tHat1, dist));
        bezierCurve.handle2 = AJRVectorAdd(bezierCurve.end, AJRVectorScale(tHat2, dist));
        
        return bezierCurve;
    }
    
    /*  First and last control points of the Bezier curve are */
    /*  positioned exactly at the first and last data points */
    /*  Control points 1 and 2 are positioned an alpha distance out */
    /*  on the tangent vectors, left and right, respectively */
    bezierCurve.start = points[first];
    bezierCurve.end = points[last];
    bezierCurve.handle1 = AJRVectorAdd(bezierCurve.start, AJRVectorScale(tHat1, alpha_l));
    bezierCurve.handle2 = AJRVectorAdd(bezierCurve.end, AJRVectorScale(tHat2, alpha_r));
    
    return bezierCurve;
}


/*
 *  Reparameterize:
 *    Given set of points and their parameterization, try to find a better parameterization.
 */
static double *Reparameterize(CGPoint *points, NSInteger first, NSInteger last, double *u, AJRBezierCurve bezierCurve)
// points            Array of digitized points
// first, last        Indices defining region
// u                Current parameter values
// bezierCurve    Current fitted curve
{
    NSInteger         nPts = last - first + 1;
    NSInteger         i;
    double    *uPrime;     /*  New parameter values    */
    
    uPrime = (double *)malloc(nPts * sizeof(double));
    for (i = first; i <= last; i++) {
        uPrime[i - first] = NewtonRaphsonRootFind(bezierCurve, points[i], u[i - first]);
    }
    
    return uPrime;
}



/*
 *  NewtonRaphsonRootFind :
 *    Use Newton-Raphson iteration to find better root.
 */
static double NewtonRaphsonRootFind(AJRBezierCurve curve, CGPoint P, double u)
// Q        Current fitted curve
// P        Digitized point
// u        Parameter value for "P"
{
    double        numerator, denominator;
    CGPoint       Q1[3], Q2[2];               /*  Q' and Q''       */
    CGPoint        Q_u, Q1_u, Q2_u;            /*u evaluated at Q, Q', & Q''   */
    double        uPrime;                        /*  Improved u         */
    NSInteger            i;
    CGPoint        *Q;
    
    Q = (CGPoint *)&curve;
    
    /* Compute Q(u)   */
    Q_u = Bezier(3, Q, u);
    
    /* Generate control vertices for Q'   */
    for (i = 0; i <= 2; i++) {
        Q1[i].x = (Q[i + 1].x - Q[i].x) * 3.0;
        Q1[i].y = (Q[i + 1].y - Q[i].y) * 3.0;
    }
    
    /* Generate control vertices for Q'' */
    for (i = 0; i <= 1; i++) {
        Q2[i].x = (Q1[i+1].x - Q1[i].x) * 2.0;
        Q2[i].y = (Q1[i+1].y - Q1[i].y) * 2.0;
    }
    
    /* Compute Q'(u) and Q''(u)   */
    Q1_u = Bezier(2, Q1, u);
    Q2_u = Bezier(1, Q2, u);
    
    /* Compute f(u)/f'(u) */
    numerator = (Q_u.x - P.x) * (Q1_u.x) + (Q_u.y - P.y) * (Q1_u.y);
    denominator = (Q1_u.x) * (Q1_u.x) + (Q1_u.y) * (Q1_u.y) + (Q_u.x - P.x) * (Q2_u.x) + (Q_u.y - P.y) * (Q2_u.y);
    
    /* u = u - f(u)/f'(u) */
    uPrime = u - (numerator / denominator);
    
    return uPrime;
}



/*
 *  Bezier :
 *      Evaluate a Bezier curve at a particular parameter value
 */
static CGPoint Bezier(NSInteger degree, CGPoint *V, double t)
// degree        The degree of the bezier curve
// V            Array of control points
// t                Parametric value to find point for
{
    NSInteger     i, j;
    CGPoint        Q;            /* Point on curve at parameter t    */
    CGPoint        *Vtemp;        /* Local copy of control points       */
    
    /* Copy array    */
    Vtemp = (CGPoint *)NSZoneMalloc(NSDefaultMallocZone(), (NSUInteger)((degree+1) * sizeof (CGPoint)) + 1024);
    for (i = 0; i <= degree; i++) {
        Vtemp[i] = V[i];
    }
    
    /* Triangle computation    */
    for (i = 1; i <= degree; i++) {
        for (j = 0; j <= degree-i; j++) {
            Vtemp[j].x = (1.0 - t) * Vtemp[j].x + t * Vtemp[j + 1].x;
            Vtemp[j].y = (1.0 - t) * Vtemp[j].y + t * Vtemp[j + 1].y;
        }
    }
    
    Q = Vtemp[0];
    NSZoneFree(NSDefaultMallocZone(), Vtemp);
    
    return Q;
}


inline CGPoint AJRBezierCurveAtT(AJRBezierCurve curve, double t)
{
    return Bezier(3, (CGPoint *)&curve, t);
}


/*
 *  B0, B1, B2, B3 :
 *    Bezier multipliers
 */
static double B0(double u)
{
    double tmp = 1.0 - u;
    return (tmp * tmp * tmp);
}


static double B1(double u)
{
    double tmp = 1.0 - u;
    return (3 * u * (tmp * tmp));
}

static double B2(double u)
{
    double tmp = 1.0 - u;
    return (3 * u * u * tmp);
}

static double B3(double u)
{
    return (u * u * u);
}



/*
 * ComputeLeftTangent, ComputeRightTangent, ComputeCenterTangent :
 *Approximate unit tangents at endpoints and "center" of digitized curve
 */
static AJRVector ComputeLeftTangent(CGPoint *points, NSInteger end)
// points        Digitized points
// end            Index to "left" end of region
{
    AJRVector    tHat1;
    tHat1 = AJRVectorSubtract(points[end + 1], points[end]);
    tHat1 = AJRVectorNormalize(tHat1);
    return tHat1;
}

static AJRVector ComputeRightTangent(CGPoint *points, NSInteger end)
// points        Digitized points
// end            Index to "right" end of region
{
    AJRVector    tHat2;
    tHat2 = AJRVectorSubtract(points[end - 1], points[end]);
    tHat2 = AJRVectorNormalize(tHat2);
    return tHat2;
}


static AJRVector ComputeCenterTangent(CGPoint *points, NSInteger center)
// points        Digitized points
// center        Index to point inside region
{
    AJRVector    V1, V2, tHatCenter;
    
    V1 = AJRVectorSubtract(points[center-1], points[center]);
    V2 = AJRVectorSubtract(points[center], points[center + 1]);
    tHatCenter.x = (V1.x + V2.x) / 2.0;
    tHatCenter.y = (V1.y + V2.y) / 2.0;
    tHatCenter = AJRVectorNormalize(tHatCenter);
    
    return tHatCenter;
}


/*
 *  ChordLengthParameterize :
 *    Assign parameter values to digitized points
 *    using relative distances between points.
 */
static double *ChordLengthParameterize(CGPoint *points, NSInteger first, NSInteger last)
// points            Array of digitized points
// first, last        Indices defining region
{
    NSInteger        i;
    double    *u;       /*  Parameterization       */
    
    u = (double *)malloc((NSUInteger)(last - first + 1) * sizeof(double));
    
    u[0] = 0.0;
    for (i = first+1; i <= last; i++) {
        u[i-first] = u[i-first-1] +
        AJRDistanceBetweenPoints(points[i], points[i - 1]);
    }
    
    for (i = first + 1; i <= last; i++) {
        u[i - first] = u[i - first] / u[last - first];
    }
    
    return u;
}

/*
 *  ComputeMaxError :
 *    Find the maximum squared distance of digitized points
 *    to fitted curve.
 */
static double ComputeMaxError(CGPoint *points, NSInteger first, NSInteger last, AJRBezierCurve bezierCurve, double *u, NSInteger *splitPoint)
// points                Array of digitized points
// first, last            Indices defining region
// bezierCurve        Fitted Bezier curve
// u                    Parameterization of points
// splitPoint            Point of maximum error
{
    NSInteger            i;
    double        maxDist;        /*  Maximum error       */
    double        dist;            /*  Current error       */
    CGPoint        P;                /*  Point on curve       */
    
    *splitPoint = (last - first + 1) / 2;
    maxDist = 0.0;
    for (i = first + 1; i < last; i++) {
        P = Bezier(3, (CGPoint *)&bezierCurve, u[i-first]);
        dist = AJRVectorSquaredLength(AJRVectorSubtract(P, points[i]));
        if (dist >= maxDist) {
            maxDist = dist;
            *splitPoint = i;
        }
    }
    return maxDist;
}

void AJRSplitBezierCurve(AJRBezierCurve input, AJRBezierCurve *left, AJRBezierCurve *right)
{
    left->start = input.start;
    right->end = input.end;
    left->handle1 = AJRMidpointBetweenPoints(input.start, input.handle1);
    right->handle2 = AJRMidpointBetweenPoints(input.handle2, input.end);
    right->handle1 = AJRMidpointBetweenPoints(input.handle1, input.handle2); // temporary holding spot
    left->handle2 = AJRMidpointBetweenPoints(left->handle1, right->handle1);
    right->handle1 = AJRMidpointBetweenPoints(right->handle1, right->handle2 ); // Real value this time
    left->end = AJRMidpointBetweenPoints(left->handle2, right->handle1);
    right->start = left->end;
}

extern void AJRSplitBezierCurveAtT(AJRBezierCurve input, AJRBezierCurve *left, AJRBezierCurve *right, double t) {
    if ((t <= 0.0) || (t >= 1.0)) {
        [NSException raise:NSRangeException format:@"The t value for splitting a bezier curve must be between <0.0..1.0>"];
    }
    
    *right = input;
    left->start = right->start;
    left->handle1.x = (double)right->start.x + t * ((double)right->handle1.x - (double)right->start.x);
    left->handle1.y = (double)right->start.y + t * ((double)right->handle1.y - (double)right->start.y);
    left->handle2.x = (double)right->handle1.x + t * ((double)right->handle2.x - (double)right->handle1.x);
    left->handle2.y = (double)right->handle1.y + t * ((double)right->handle2.y - (double)right->handle1.y);
    right->handle2.x = (double)right->handle2.x + t * ((double)right->end.x - (double)right->handle2.x);
    right->handle2.y = (double)right->handle2.y + t * ((double)right->end.y - (double)right->handle2.y);
    right->handle1.x = (double)left->handle2.x + t * ((double)right->handle2.x - (double)left->handle2.x);
    right->handle1.y = (double)left->handle2.y + t * ((double)right->handle2.y - (double)left->handle2.y);
    left->handle2.x = (double)left->handle1.x + t * ((double)left->handle2.x - (double)left->handle1.x);
    left->handle2.y = (double)left->handle1.y + t * ((double)left->handle2.y - (double)left->handle1.y);
    left->end.x = (double)left->handle2.x + t * ((double)right->handle1.x - left->handle2.x);
    left->end.y = (double)left->handle2.y + t * ((double)right->handle1.y - left->handle2.y);
    right->start = left->end;
}
