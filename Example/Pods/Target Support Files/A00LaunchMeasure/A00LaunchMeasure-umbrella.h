#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "fishhook.h"
#import "QiCallLib.h"
#import "QiCallTrace.h"
#import "QiCallTraceCore.h"
#import "QiCallTraceTimeCostModel.h"
#import "QiLagDB.h"
#import "A00LoadMeasure.h"
#import "HDLaunchTask.h"

FOUNDATION_EXPORT double A00LaunchMeasureVersionNumber;
FOUNDATION_EXPORT const unsigned char A00LaunchMeasureVersionString[];

