//
//  SamplesViewController.m
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

#import "FUISamplesViewController.h"

#import <FirebaseAuthUI/FirebaseAuthUI.h>
#import "FUIAuthViewController.h"
#import "FUIChatViewController.h"
#import "FUISample.h"

@interface FUISamplesViewController ()

@property (nonatomic) NSArray *samplesContainer;

@end

@implementation FUISamplesViewController

- (void)viewDidLoad {
  [super viewDidLoad];

  self.navigationController.navigationBar.topItem.title = self.title;
  self.clearsSelectionOnViewWillAppear = NO;

  [self populateSamples];
}

- (void)populateSamples {
  UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main"
                                                       bundle:NULL];
  NSArray *samples = @[
    [FUISample sampleWithTitle:@"Auth"
            sampleDescription:@"Demonstrates the FirebaseAuthUI flow with customization options"
                   controller:^UIViewController *{
        UIViewController *controller =
            [storyboard instantiateViewControllerWithIdentifier:@"FUIAuthViewController"];
        return controller;
      }],
    [FUISample sampleWithTitle:@"Chat"
            sampleDescription:@"Demonstrates using a FUICollectionViewDataSource to load data from "
                               "Firebase Database into a UICollectionView for a basic chat app."
                   controller:^UIViewController *{
        UIViewController *controller =
          [storyboard instantiateViewControllerWithIdentifier:@"ViewController"];
        return controller;
      }],
    [FUISample sampleWithTitle:@"Storage"
            sampleDescription:@"Demonstrates using FirebaseStorageUI to populate an image view."
                   controller:^UIViewController *{
        UIViewController *controller =
          [storyboard instantiateViewControllerWithIdentifier:@"FUIStorageViewController"];
        return controller;
      }]];
  _samplesContainer = samples;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return _samplesContainer.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  static NSString *cellId = @"FUISampleCell";
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId
                                                          forIndexPath:indexPath];

  FUISample *sample = _samplesContainer[indexPath.row];
  cell.textLabel.text = sample.title;
  cell.detailTextLabel.text = sample.sampleDescription;

  return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  FUISample *sample = _samplesContainer[indexPath.row];
  UIViewController *viewController = sample.controllerBlock();

  [self.navigationController pushViewController:viewController animated:YES];
}

@end
