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

#import "FUICollationForCountries.h"

#import "FUIAuthUtils.h"
#import "FUICountryCodes.h"
#import "FUICountryTableViewController.h"
#import "FUIFeatureSwitch.h"
#import "FUIPhoneAuthStrings.h"

NS_ASSUME_NONNULL_BEGIN

@interface FUICountryTableViewController ()<UISearchResultsUpdating>

@property (nonatomic, readonly) FUICountryCodes *countryCodes;
@property (nonatomic, readwrite) FUICountryCodes *searchResults;
@property (nonatomic, readonly) FUICollationForCountries *collationForCountries;
@property (nonatomic, readonly) NSMutableDictionary *cachedNumberOfCountriesInSection;
@property (nonatomic, readonly) UISearchController *searchController;
@property (unsafe_unretained, nonatomic) IBOutlet UITableView *tableView;
@end


@implementation FUICountryTableViewController

- (instancetype)initWithCountryCodes:(FUICountryCodes *)countryCodes {
  if ((self = [super initWithNibName:NSStringFromClass([self class])
                              bundle:[FUIAuthUtils bundleNamed:FUIPhoneAuthBundleName]])) {
    _countryCodes = countryCodes;
    _collationForCountries =
        [[FUICollationForCountries alloc] initWithCountryCodes:self.countryCodes];
    _cachedNumberOfCountriesInSection = [NSMutableDictionary new];
    _searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    self.searchController.searchResultsUpdater = self;
    self.searchController.dimsBackgroundDuringPresentation = NO;
    self.definesPresentationContext = YES;
  }
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];

  self.tableView.tableHeaderView = self.searchController.searchBar;
}

- (UITableViewCell*)tableView:(UITableView*)tableView
        cellForRowAtIndexPath:(NSIndexPath*)indexPath {
  if ([self tableView:tableView numberOfRowsInSection:indexPath.section] == 0) {
    return nil;
  }

  static NSString *identifier = @"fui-country-cell";
  NSInteger textLabelTag = 1;
  NSInteger detailTextLabelTag = 2;
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
  UILabel *detailTextLabel;
  UILabel *textLabel;
  if (cell == nil) {
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                  reuseIdentifier:identifier];
    detailTextLabel = [[UILabel alloc] init];
    [detailTextLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    detailTextLabel.textColor = [UIColor grayColor];
    detailTextLabel.tag = detailTextLabelTag;
    [cell.contentView addSubview:detailTextLabel];
    
    textLabel = [[UILabel alloc] init];
    [textLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    textLabel.tag = textLabelTag;
    [cell.contentView addSubview:textLabel];

    NSDictionary *views = NSDictionaryOfVariableBindings(detailTextLabel, textLabel);
    NSArray *constraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[detailTextLabel]|"
                                                                   options:0
                                                                   metrics:nil
                                                                     views:views];
    [cell.contentView addConstraints:constraints];
    
    constraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[textLabel]|"
                                                          options: 0
                                                          metrics:nil
                                                            views:views];
    [cell.contentView addConstraints:constraints];
    
    constraints =
        [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[textLabel]-[detailTextLabel(<=90)]|"
                                                options: 0
                                                metrics:nil
                                                  views:views];
    [cell.contentView addConstraints:constraints];
  } else {
    detailTextLabel = [cell.contentView viewWithTag:detailTextLabelTag];
    textLabel = [cell.contentView viewWithTag:textLabelTag];
  }

  FUICountryCodeInfo* countryCodeInfo;
  NSInteger row = [self cumulativeRowForTableView:tableView indexPath:indexPath];
  if ([self isSearchActive]) {
    countryCodeInfo = [self.searchResults countryCodeInfoAtIndex:row];
  } else {
    countryCodeInfo = [self.countryCodes countryCodeInfoAtIndex:row];
  }

  if (countryCodeInfo) {
    if ([FUIFeatureSwitch isCountryFlagEmojiEnabled]) {
      NSString *countryFlag = [countryCodeInfo countryFlagEmoji];
      textLabel.text =
          [NSString stringWithFormat:@"%@ %@", countryFlag, countryCodeInfo.localizedCountryName];
    } else {
      textLabel.text = countryCodeInfo.localizedCountryName;
    }
    detailTextLabel.text = countryCodeInfo.dialCode;
  }
  return cell;
}

- (NSInteger)cumulativeRowForTableView:(UITableView*)tableView indexPath:(NSIndexPath*)indexPath {
  NSInteger row = indexPath.row;
  NSInteger section;
  for (section = 0; section < indexPath.section; section++) {
    row += [self tableView:tableView numberOfRowsInSection:section];
  }
  return row;
}

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath {
  NSInteger row = [self cumulativeRowForTableView:tableView indexPath:indexPath];

  FUICountryCodeInfo *selectedCountry;
  if ([self isSearchActive]) {
    selectedCountry = [self.searchResults countryCodeInfoAtIndex:row];
  } else {
    selectedCountry = [self.countryCodes countryCodeInfoAtIndex:row];
  }
  [self.delegate didSelectCountry:selectedCountry];

  [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark Section index

- (nullable NSString *)tableView:(UITableView *)tableView
         titleForHeaderInSection:(NSInteger)section {
  if ([self isSearchActive]) {
    NSString *queryString = self.searchController.searchBar.text;
    return queryString.length ? [[queryString substringToIndex:1] capitalizedString] : @"";
  }

  return [[self.collationForCountries sectionTitles] objectAtIndex:section];
}

- (nullable NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
  return [self.collationForCountries sectionIndexTitles];
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title
               atIndex:(NSInteger)index {
  return index;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  if ([self isSearchActive]) {
    return 1;
  }

  return [self.collationForCountries sectionIndexTitles].count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex {
  if ([self isSearchActive]) {
    return [self.searchResults count];
  }

  if (self.cachedNumberOfCountriesInSection[@(sectionIndex)] != nil) {
    return [self.cachedNumberOfCountriesInSection[@(sectionIndex)] integerValue];
  }

  NSInteger rows = [self.collationForCountries numberOfCountriesInSection:sectionIndex];
  self.cachedNumberOfCountriesInSection[@(sectionIndex)] = @(rows);

  return rows;
}

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
  self.searchResults = [self.countryCodes searchCountriesByName:searchController.searchBar.text];

  [self.tableView reloadData];
}

- (BOOL)isSearchActive {
  return self.searchResults != nil;
}

@end

NS_ASSUME_NONNULL_END
