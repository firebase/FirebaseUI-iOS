//
//  SamplesViewController.m
//  FirebaseUIChat
//
//  Created by Yury Ramanchuk on 9/7/16.
//  Copyright © 2016 Firebase, Inc. All rights reserved.
//

#import "FIRSample.h"
#import "FIRSamplesViewController.h"
#import "ViewController.h"

@interface FIRSamplesViewController ()

@property (nonatomic) NSArray *samplesContainer;

@end

@implementation FIRSamplesViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationController.navigationBar.topItem.title = self.title;
    self.clearsSelectionOnViewWillAppear = NO;

    [self populateSamples];
}

- (void)populateSamples {
    NSMutableArray *samples = [[NSMutableArray alloc] init];

    [samples addObject:[FIRSample sampleWithTitle:@"Auth"
                                sampleDescription:@"Demonstrates the FirebaseAuthUI flow with customization options"
                                       controller:^UIViewController *{
        UIViewController *controller =
        [[UIStoryboard storyboardWithName:@"Main"
                                   bundle:NULL] instantiateViewControllerWithIdentifier:@"FIRAuthViewController"];
        return controller;
    }]];

    [samples addObject:[FIRSample sampleWithTitle:@"Chat"
                                sampleDescription:@"Demonstrates using a FirebaseCollectionViewDataSource to load data from Firebase Database into a UICollectionView for a basic chat app."
                                       controller:^UIViewController *{
                                           UIViewController *controller =
                                           [[UIStoryboard storyboardWithName:@"Main"
                                                                      bundle:NULL] instantiateViewControllerWithIdentifier:@"ViewController"];
                                           return controller;
                                       }]];


    _samplesContainer = samples;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _samplesContainer.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellId = @"FIRSampleCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId forIndexPath:indexPath];

    FIRSample *sample = _samplesContainer[indexPath.row];
    cell.textLabel.text = sample.title;
    cell.detailTextLabel.text = sample.sampleDescription;

    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    FIRSample *sample = _samplesContainer[indexPath.row];
    UIViewController *viewController = sample.controllerBlock();

    [self.navigationController pushViewController:viewController animated:YES];
}

@end
