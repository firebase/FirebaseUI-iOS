// clang-format off

/*
 * Firebase UI Bindings iOS Library
 *
 * Copyright © 2015 Firebase - All Rights Reserved
 * https://www.firebase.com
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 * 1. Redistributions of source code must retain the above copyright notice, this
 * list of conditions and the following disclaimer.
 *
 * 2. Redistributions in binaryform must reproduce the above copyright notice,
 * this list of conditions and the following disclaimer in the documentation
 * and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY FIREBASE AS IS AND ANY EXPRESS OR
 * IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO
 * EVENT SHALL FIREBASE BE LIABLE FOR ANY DIRECT,
 * INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
 * BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
 * LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
 * OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
 * ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

// clang-format on

#ifndef XCodeMacros_h
#define XCodeMacros_h

#if defined(__has_feature) && __has_feature(nullability)
#define __ASSUME_NONNULL_BEGIN NS_ASSUME_NONNULL_BEGIN
#define __ASSUME_NONNULL_END NS_ASSUME_NONNULL_END
#define __NULLABLE nullable
#define __NULLABLE_PTR __nullable
#define __NON_NULL nonnull
#define __NON_NULL_PTR __nonnull
#else
#define __ASSUME_NONNULL_BEGIN
#define __ASSUME_NONNULL_END
#define __NULLABLE
#define __NULLABLE_PTR
#define __NON_NULL
#define __NON_NULL_PTR
#endif

#if defined(__has_feature) && __has_feature(objc_generics)
#define __GENERIC(...) <__VA_ARGS__>
#else
#define __GENERIC(...)
#endif

#if defined(__has_feature) && __has_feature(objc_kindof)
#define __KINDOF(cls) __kindof cls *
#else
#define __KINDOF(cls) id
#endif

#endif