//
//  MessageTableViewCell.h
//  FirebaseUIChat
//
//  Created by Mike Mcdonald on 8/20/15.
//  Copyright © 2015 Firebase, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MessageTableViewCell : UITableViewCell
@property(weak, nonatomic) IBOutlet UILabel *myMessageLabel;
@property(weak, nonatomic) IBOutlet UILabel *myNameLabel;

@property(weak, nonatomic) IBOutlet UILabel *otherMessageLabel;
@property(weak, nonatomic) IBOutlet UILabel *otherNameLabel;

@end
