//
//  ViewController.h
//  FirebaseUIChat
//
//  Created by Mike Mcdonald on 8/20/15.
//  Copyright (c) 2015 Firebase, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Firebase/Firebase.h>
#import <FirebaseUI/FirebaseTableViewDataSource.h>
#import <FirebaseUI/FirebaseLoginViewController.h>

@interface ViewController : UIViewController <UITableViewDelegate, UITextFieldDelegate>

@property (strong, nonatomic) Firebase *ref;
@property (strong, nonatomic) FirebaseTableViewDataSource *dataSource;
@property (strong, nonatomic) FirebaseLoginViewController *loginViewController;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UITextField *inputTextField;

@end

