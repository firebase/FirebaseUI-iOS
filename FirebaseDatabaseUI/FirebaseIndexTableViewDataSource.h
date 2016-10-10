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

@import UIKit;

@import FirebaseDatabase;

NS_ASSUME_NONNULL_BEGIN

@interface FirebaseIndexTableViewDataSource : NSObject

- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithIndex:(FIRDatabaseQuery *)indexQuery
                         data:(FIRDatabaseReference *)dataQuery
                    tableView:(UITableView *)tableView
          cellReuseIdentifier:(NSString *)cellIdentifier
                 populateCell:(void (^)(UITableViewCell *cell,
                                        FIRDataSnapshot *_Nullable))populateCell NS_DESIGNATED_INITIALIZER;

@end

@interface FirebaseIndexTableViewDataSource (TableViewDataSource) <UITableViewDataSource>
@end

NS_ASSUME_NONNULL_END
