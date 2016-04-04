// clang-format off

//
//  Copyright (c) 2016 Google Inc.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

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