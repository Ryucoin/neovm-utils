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

#import "Neoutils.h"
#import "Neoutils.objc.h"
#import "ref.h"
#import "Universe.objc.h"

FOUNDATION_EXPORT double neovmUtilsVersionNumber;
FOUNDATION_EXPORT const unsigned char neovmUtilsVersionString[];

