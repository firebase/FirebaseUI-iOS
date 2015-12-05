//
//  FRestDataSnapshot.h
//  FirebaseUI
//
//  Created by Chris Ellsworth on 12/5/15.
//  Copyright © 2015 Firebase, Inc. All rights reserved.
//

#import <Firebase/Firebase.h>

@interface FRestDataSnapshot : FDataSnapshot
- (instancetype)initWithRef:(Firebase *)ref value:(id)value;
@end