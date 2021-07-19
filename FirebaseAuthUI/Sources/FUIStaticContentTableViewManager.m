//
//  Copyright (c) 2017 Google Inc.
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

#import "FirebaseAuthUI/Sources/FUIStaticContentTableViewManager.h"

#import "FirebaseAuthUI/Sources/Public/FirebaseAuthUI/FUIAuthUtils.h"

NS_ASSUME_NONNULL_BEGIN

/** @var kCellReuseIdentitfier
    @brief The reuse identifier for default style table view cell.
 */
static NSString *const kCellReuseIdentitfier = @"reuseIdentifier";

/** @var kValueCellReuseIdentitfier
    @brief The reuse identifier for value style table view cell.
 */
static NSString *const kValueCellReuseIdentitfier = @"reuseValueIdentifier";

/** @var kPasswordCellReuseIdentitfier
    @brief The reuse identifier for password style table view cell.
 */
static NSString *const kPasswordCellReuseIdentitfier = @"passwordCellReuseIdentitfier";

/** @var kInputCellReuseIdentitfier
    @brief The reuse identifier for input style table view cell.
 */
static NSString *const kInputCellReuseIdentitfier = @"inputCellReuseIdentitfier";

/** @var kVisibilityOffImage
    @brief Name of icon to show current password in secure input field.
 */
static NSString *const kVisibilityOffImage = @"ic_visibility_off.png";

/** @var kVisibilityOnImage
    @brief Name of icon to show current password in secure input field.
 */
static NSString *const kVisibilityOnImage = @"ic_visibility.png";

#pragma mark -

@implementation FUIStaticContentTableViewManager

- (void)setContents:(nullable FUIStaticContentTableViewContent *)contents {
  _contents = contents;
  [self.tableView reloadData];
}

- (void)setTableView:(nullable UITableView *)tableView {
  _tableView = tableView;
  [tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kCellReuseIdentitfier];

  UINib *passwordCellNib = [UINib nibWithNibName:NSStringFromClass([FUIPasswordTableViewCell class])
                                          bundle:[FUIAuthUtils authUIBundle]];
  [tableView registerNib:passwordCellNib forCellReuseIdentifier:kPasswordCellReuseIdentitfier];

  UINib *inputCellNib = [UINib nibWithNibName:NSStringFromClass([FUIInputTableViewCell class])
                                       bundle:[FUIAuthUtils authUIBundle]];
  [tableView registerNib:inputCellNib forCellReuseIdentifier:kInputCellReuseIdentitfier];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return _contents.sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return _contents.sections[section].cells.count;
}

- (nullable NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
  return _contents.sections[section].title;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
    cellForRowAtIndexPath:(NSIndexPath *)indexPath{
  FUIStaticContentTableViewCell *cellData =
      _contents.sections[indexPath.section].cells[indexPath.row];
  UITableViewCell *cell;
  if (cellData.type == FUIStaticContentTableViewCellTypePassword) {
    return [self dequeuePasswordCell:cellData tableView:tableView];
  } else if (cellData.type == FUIStaticContentTableViewCellTypeInput) {
    return [self dequeueInputCell:cellData tableView:tableView];
  } else if (cellData.value.length) {
    cell = [tableView dequeueReusableCellWithIdentifier:kValueCellReuseIdentitfier];
    if (!cell) {
      cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1
                                    reuseIdentifier:kValueCellReuseIdentitfier];
      cell.detailTextLabel.adjustsFontSizeToFitWidth = YES;
      cell.detailTextLabel.minimumScaleFactor = 0.5;
    }
  } else {
    // kCellReuseIdentitfier has already been registered.
    cell = [tableView dequeueReusableCellWithIdentifier:kCellReuseIdentitfier
                                           forIndexPath:indexPath];
  }
  cell.textLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
  cell.detailTextLabel.text = cellData.value;
  cell.textLabel.text = cellData.title;
  cell.accessoryType = cellData.action &&
      cellData.type == FUIStaticContentTableViewCellTypeDefault ?
      UITableViewCellAccessoryDisclosureIndicator : UITableViewCellAccessoryNone;
  cell.textLabel.textColor = cellData.type == FUIStaticContentTableViewCellTypeButton ?
      [UIColor blueColor] : [UIColor blackColor];
  cell.selectionStyle = cellData.action ? UITableViewCellSelectionStyleDefault :
                                          UITableViewCellSelectionStyleNone;
  return cell;
}

- (UITableViewCell *)dequeuePasswordCell:(FUIStaticContentTableViewCell *)cellData
                               tableView:(UITableView *)tableView{
  FUIPasswordTableViewCell *cell =
      [tableView dequeueReusableCellWithIdentifier:kPasswordCellReuseIdentitfier];
  cell.title.text = cellData.title;
  cell.password.text = cellData.value;
  cell.password.placeholder = cellData.placeholder;
  cell.cellData = cellData;
  cell.title.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
  return cell;
}

- (UITableViewCell *)dequeueInputCell:(FUIStaticContentTableViewCell *)cellData
                               tableView:(UITableView *)tableView{
  FUIInputTableViewCell *cell =
      [tableView dequeueReusableCellWithIdentifier:kInputCellReuseIdentitfier];
  cell.title.text = cellData.title;
  cell.input.text = cellData.value;
  cell.input.placeholder = cellData.placeholder;
  cell.cellData = cellData;
  cell.title.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
  return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  FUIStaticContentTableViewCell *cellData =
      _contents.sections[indexPath.section].cells[indexPath.row];
  BOOL hasAssociatedAction = cellData.action != nil;
  if (hasAssociatedAction) {
    cellData.action();
  }
  [tableView deselectRowAtIndexPath:indexPath animated:hasAssociatedAction];
}

@end

#pragma mark -

@implementation FUIStaticContentTableViewContent

+ (instancetype)contentWithSections:
    (nullable NSArray<FUIStaticContentTableViewSection *> *)sections {
  return [[self alloc] initWithSections:sections];
}

- (instancetype)initWithSections:(nullable NSArray<FUIStaticContentTableViewSection *> *)sections {
  self = [super init];
  if (self) {
    _sections = [sections copy];
  }
  return self;
}

@end

#pragma mark -

@implementation FUIStaticContentTableViewSection

+ (instancetype)sectionWithTitle:(nullable NSString *)title
                           cells:(nullable NSArray<FUIStaticContentTableViewCell *> *)cells {
  return [[self alloc] initWithTitle:title cells:cells];
}

- (instancetype)initWithTitle:(nullable NSString *)title
                        cells:(nullable NSArray<FUIStaticContentTableViewCell *> *)cells {
  self = [super init];
  if (self) {
    _title = [title copy];
    _cells = [cells copy];
  }
  return self;
}

@end

#pragma mark -

@implementation FUIStaticContentTableViewCell

+ (instancetype)cellWithTitle:(nullable NSString *)title {
  return [[self alloc] initWithTitle:title
                               value:nil
                         placeholder:nil
                                type:FUIStaticContentTableViewCellTypeDefault
                              action:nil];
}

+ (instancetype)cellWithTitle:(nullable NSString *)title
                        value:(nullable NSString *)value {
  return [[self alloc] initWithTitle:title
                               value:value
                         placeholder:nil
                                type:FUIStaticContentTableViewCellTypeDefault
                              action:nil];
}

+ (instancetype)cellWithTitle:(nullable NSString *)title
                       action:(nullable FUIStaticContentTableViewCellAction)action {
  return [[self alloc] initWithTitle:title
                               value:nil
                         placeholder:nil
                                type:FUIStaticContentTableViewCellTypeDefault
                              action:action];
}

+ (instancetype)cellWithTitle:(nullable NSString *)title
                         type:(FUIStaticContentTableViewCellType) type
                       action:(nullable FUIStaticContentTableViewCellAction)action {
  return [[self alloc] initWithTitle:title
                               value:nil
                         placeholder:nil
                                type:type
                              action:action];
}

+ (instancetype)cellWithTitle:(nullable NSString *)title
                        value:(nullable NSString *)value
                       action:(nullable FUIStaticContentTableViewCellAction)action {
  return [[self alloc] initWithTitle:title
                               value:value
                         placeholder:nil
                                type:FUIStaticContentTableViewCellTypeDefault
                              action:action];
}

+ (instancetype)cellWithTitle:(nullable NSString *)title
                        value:(nullable NSString *)value
                         type:(FUIStaticContentTableViewCellType) type
                       action:(nullable FUIStaticContentTableViewCellAction)action {
  return [[self alloc] initWithTitle:title
                               value:value
                          placeholder:nil
                               type:type
                              action:action];
}

+ (instancetype)cellWithTitle:(nullable NSString *)title
                        value:(nullable NSString *)value
                  placeholder:(nullable NSString *)placeholder
                         type:(FUIStaticContentTableViewCellType) type
                       action:(nullable FUIStaticContentTableViewCellAction)action {
  return [[self alloc] initWithTitle:title
                               value:value
                         placeholder:placeholder
                                type:type
                              action:action];
}

- (instancetype)initWithTitle:(nullable NSString *)title
                        value:(nullable NSString *)value
                  placeholder:(nullable NSString *)placeholder
                         type:(FUIStaticContentTableViewCellType) type
                       action:(nullable FUIStaticContentTableViewCellAction)action {
  self = [super init];
  if (self) {
    _title = [title copy];
    _value = [value copy];
    _action = [action copy];
    _placeholder = [placeholder copy];
    _type = type;
  }
  return self;
}

@end

@interface FUIPasswordTableViewCell ()
@property (weak, nonatomic) IBOutlet UIButton *visibilityButton;
@end

@implementation FUIPasswordTableViewCell

- (IBAction)onPasswordVisibilitySelected:(id)sender {
  self.password.secureTextEntry = ! self.password.secureTextEntry;
  UIImage *image = self.password.secureTextEntry ? [UIImage imageNamed:kVisibilityOnImage]
                                                 : [UIImage imageNamed:kVisibilityOffImage];
  [self.visibilityButton setImage:image forState:UIControlStateNormal];
}
- (IBAction)onPasswordChanged:(id)sender {
  self.cellData.value = self.password.text;
}

@end

@implementation FUIInputTableViewCell

- (IBAction)onInputChanged:(id)sender {
  self.cellData.value = self.input.text;
}

@end

NS_ASSUME_NONNULL_END
