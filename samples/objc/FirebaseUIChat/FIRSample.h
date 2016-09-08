//
//  FIRSampleContainer.h
//  FirebaseUIChat
//
//  Created by Yury Ramanchuk on 9/8/16.
//  Copyright © 2016 Firebase, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef UIViewController *(^FIRControllerBlock)();

@interface FIRSample : NSObject

+ (instancetype)sampleWithTitle:(NSString *)title
              sampleDescription:(NSString *)description
                     controller:(FIRControllerBlock)block;

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *sampleDescription;
@property (nonatomic, copy) FIRControllerBlock controllerBlock;


@end