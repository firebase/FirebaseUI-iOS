//
//  MessageDataSource.m
//  FirebaseUIChat
//
//  Created by Mike Mcdonald on 8/20/15.
//  Copyright © 2015 Firebase, Inc. All rights reserved.
//

#import "MessageDataSource.h"

@implementation MessageDataSource

- (BOOL)tableView:(UITableView *)tableView
    canEditRowAtIndexPath:(NSIndexPath *)indexPath;
{ return YES; }

- (void)tableView:(UITableView *)tableView
    commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
     forRowAtIndexPath:(NSIndexPath *)indexPath;
{
  if (editingStyle == UITableViewCellEditingStyleDelete) {
    [[self refForIndex:indexPath.row] removeValue];
  }
}

@end
