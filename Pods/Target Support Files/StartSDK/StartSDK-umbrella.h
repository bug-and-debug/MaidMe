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

#import "Start.h"
#import "StartCard.h"
#import "StartToken.h"

FOUNDATION_EXPORT double StartSDKVersionNumber;
FOUNDATION_EXPORT const unsigned char StartSDKVersionString[];

