//
//  DetailTVC.m
//  DuoKit Browser
//
//  The MIT License (MIT)
//
//  Copyright © 2017 Zhi-Wei Cai (MediaTek Inc.). All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

#define kMaxUIElements  10

#import <CommonCrypto/CommonDigest.h>
#import "DetailTVC.h"
#import "Common.h"
#import "DetailAddItemTVC.h"
#import "DetailPinModeTVC.h"

#import "DetailWebUICell.h"
#import "DetailSwitchCell.h"
#import "DetailSetterCell.h"
#import "DetailSliderCell.h"
#import "DetailMiscDefaultCell.h"

@interface NSString (Extension)

- (NSString *)md5;

@end

@implementation NSString (Extension)

- (NSString *)md5
{
    const char *str = [self UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(str, (CC_LONG)strlen(str), result);
    NSMutableString *ret
    = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [ret appendFormat:@"%02x",result[i]];
    }
    return ret;
}

@end

typedef enum : uint8_t {
    DetailMiscNone  = 0,
    DetailMiscMode
} DetailMiscType;

@interface DetailTVC () <UITableViewDataSource, UITextFieldDelegate, DetailAddItemDelegate>
{
    NSString *hash;
    NSInteger editIndex;
}

@end

@implementation DetailTVC

- (void)loadView
{
    [super loadView];
    
    self.tableView.allowsMultipleSelectionDuringEditing = NO;
    
    _misc = @[@(DetailMiscMode)];
    
    UIBarButtonItem *addButton
    = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                    target:self
                                                    action:@selector(addButtonAction:)];
    self.navigationItem.rightBarButtonItem = addButton;
    
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.tintColor = kColorBase;
    self.refreshControl.attributedTitle
    = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"Reload Layout from %@",
                                                  _duo.name ? _duo.name : @"Device"]
                                      attributes:[NSDictionary dictionaryWithObject:kColorBase
                                                                             forKey:NSForegroundColorAttributeName]];
    [self.refreshControl addTarget:self
                            action:@selector(reloadLayouts)
                  forControlEvents:UIControlEventValueChanged];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (self.navigationItem.title && self.navigationItem.title.length) {
        hash = [self.navigationItem.title md5];
    }
    
    [self loadLayout];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(backAction:)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    for (id cell in self.tableView.visibleCells) {
        if ([cell respondsToSelector:@selector(setReloadInterval:)]) {
            [cell setReloadInterval:0];
        }
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)backAction:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)reloadLayouts
{
    self.tableView.userInteractionEnabled = NO;
    [_duo isDeviceReadyWithApi:kDuoKitMinVersion
             completionHandler:^(NSInteger api,
                                 BOOL isReady,
                                 NSString *profile,
                                 NSArray *layouts,
                                 NSString *errorMessage)
     {
         [self.refreshControl endRefreshing];
         if (isReady) {
             NSLog(@"%s: %@", __PRETTY_FUNCTION__, layouts);
             NSMutableArray *layoutArray = [NSMutableArray new];
             for (NSDictionary *dict in layouts) {
                 DuoUI *ui = [[DuoUI alloc] initWithDictionary:dict];
                 if (ui) {
                     [layoutArray addObject:ui];
                 }
             }
             if (profile) {
                 _duo.profile = profile;
             }
             if (layoutArray.count) {
                 _duo.layout = layoutArray;
             }
             self.navigationItem.title = _duo.profile ? _duo.profile : _duo.name;
             
             // User Defined
             if (self.navigationItem.title && self.navigationItem.title.length) {
                 hash = [self.navigationItem.title md5];
             }
             
             [self loadLayout];
             
             [self.tableView reloadData];
             
             self.tableView.userInteractionEnabled = YES;
         } else {
             UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error"
                                                                            message:errorMessage
                                                                     preferredStyle:UIAlertControllerStyleAlert];
             UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"OK"
                                                                     style:UIAlertActionStyleDefault
                                                                   handler:^(UIAlertAction * action) {
                                                                       self.tableView.userInteractionEnabled = YES;
                                                                   }];
             alert.view.tintColor = kColorButtonDefault;
             [alert addAction:defaultAction];
             [[[[UIApplication sharedApplication] keyWindow] rootViewController] presentViewController:alert
                                                                                              animated:YES
                                                                                            completion:nil];
         }
     }];
}

#pragma mark - Table view data source

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return @"Pre-Defined by Arduino";
        case 1:
            return @"User Defined";
        case 2:
            return @"Misc";
        default:
            break;
    }
    return nil;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return _duo.layout.count;
        case 1:
            return _layout.count;
        case 2:
            return _misc.count;
        default:
            return 0;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section != [tableView numberOfSections] - 1) {
        return 54;
    }
    return 44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 2) {
        switch ([[_misc objectAtIndex:indexPath.row] integerValue]) {
            case DetailMiscMode: {
                DetailMiscDefaultCell *cell =
                [tableView dequeueReusableCellWithIdentifier:kDetailMiscDefaultCellIdentifer
                                                forIndexPath:indexPath];
                cell.textLabel.text = @"Read / Change Pin Mode";
                return cell;
            }
            default:
                break;
        }
    } else {
        NSUInteger sectionDelay = 0;
        for (NSUInteger i = 0; i < indexPath.section; i++) {
            sectionDelay += [tableView numberOfRowsInSection:i];
        }
        DuoUI *ui;
        switch (indexPath.section) {
            case 1:
                ui = [_layout objectAtIndex:indexPath.row];
                break;
            default:
                ui = [_duo.layout objectAtIndex:indexPath.row];
                break;
        }
        
        switch (ui.type) {
            case DuoUIWebUI: {
                DetailWebUICell *cell =
                [tableView dequeueReusableCellWithIdentifier:kDetailWebUICellIdentifer
                                                forIndexPath:indexPath];
                cell.imageView.image = [UIImage imageNamed:@"tab-settings"];
                cell.duo = _duo;
                cell.textLabel.text = ui.name ? ui.name : _duo.name;
                cell.detailTextLabel.text = _duo.v4Addresses.count ?
                [_duo.v4Addresses firstObject] : _duo.v6Addresses.count ?
                [_duo.v6Addresses firstObject] : nil;
                return cell;
            }
            case DuoUISwitch: {
                DetailSwitchCell *cell =
                [tableView dequeueReusableCellWithIdentifier:kDetailSwitchCellIdentifer
                                                forIndexPath:indexPath];
                cell.title.text = ui.name;
                cell.title.textColor = [UIColor darkTextColor];
                cell.duo = _duo;
                cell.pin = ui.pin;
                cell.pinSwitch.onTintColor = ui.color ? ui.color : kColorUIDefault;
                [cell.pinSwitch setOn:ui.value animated:NO];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)((sectionDelay + indexPath.row) * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [cell setReloadInterval:ui.reloadInterval];
                });
                return cell;
            }
            case DuoUISetter:
            case DuoUIGetter: {
                DetailSetterCell *cell =
                [tableView dequeueReusableCellWithIdentifier:kDetailSetterCellIdentifer
                                                forIndexPath:indexPath];
                cell.title.text = ui.name;
                cell.title.textColor = [UIColor darkTextColor];
                cell.duo = _duo;
                cell.pin = ui.pin;
                cell.valueType = ui.valueType;
                cell.key = ui.key;
                switch (ui.valueType) {
                    case DuoIntType:
                        cell.textField.keyboardType = UIKeyboardTypeNumberPad;
                        cell.value = ui.value;
                        cell.textField.text = [NSString stringWithFormat:@"%ld", lroundf(ui.value)];
                        break;
                    case DuoDoubleType:
                        cell.textField.keyboardType = UIKeyboardTypeDecimalPad;
                        cell.value = ui.value;
                        cell.textField.text = [NSString stringWithFormat:@"%.*f", 2, ui.value];
                        break;
                    case DuoStringType:
                        cell.textField.keyboardType = UIKeyboardTypeASCIICapable;
                        cell.stringValue = ui.stringValue;
                        cell.textField.text = ui.stringValue;
                        break;
                    default:
                        break;
                }
                cell.textField.userInteractionEnabled = ui.type == DuoUISetter;
                cell.textField.borderStyle = ui.type == DuoUISetter ? UITextBorderStyleRoundedRect :  UITextBorderStyleNone;
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)((sectionDelay + indexPath.row) * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [cell setReloadInterval:ui.reloadInterval];
                });
                return cell;
            }
            case DuoUISlider: {
                DetailSliderCell *cell =
                [tableView dequeueReusableCellWithIdentifier:kDetailSliderCellIdentifer
                                                forIndexPath:indexPath];
                cell.title.text = ui.name;
                cell.title.textColor = [UIColor darkTextColor];
                cell.duo = _duo;
                cell.pin = ui.pin;
                if (ui.key) cell.key = ui.key;
                cell.slider.tintColor = ui.color ? ui.color : kColorUIDefault;
                if (ui.minimumValue > ui.maximumValue) {
                    cell.isReversedValue = YES;
                    cell.slider.maximumValue = ui.minimumValue;
                    cell.slider.minimumValue = ui.maximumValue;
                } else {
                    cell.slider.maximumValue = ui.maximumValue;
                    cell.slider.minimumValue = ui.minimumValue;
                }
                cell.slider.value = ui.value;
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)((sectionDelay + indexPath.row) * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [cell setReloadInterval:ui.reloadInterval];
                });
                return cell;
            }
            default:
                break;
        }
    }
    return [UITableViewCell new];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSArray *source;
    switch (indexPath.section) {
        case 1:
            source = _layout;
            break;
        case 2:
            source = _misc;
            break;
        default:
            source = _duo.layout;
            break;
    }
    
    if (indexPath.section == 2) {
        switch ([[source objectAtIndex:indexPath.row] integerValue]) {
            case DetailMiscMode: {
                [self performSegueWithIdentifier:kDetailPinModeSegueIdentifer
                                          sender:self];
                break;
            }
            default:
                break;
        }
    } else {
        switch (((DuoUI *)[source objectAtIndex:indexPath.row]).type) {
            case DuoUIWebUI: {
                DetailWebUICell *cell = [[tableView visibleCells] objectAtIndex:indexPath.row];
                [cell openWebUI];
                break;
            }
            default:
                break;
        }
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return indexPath.section == 1;
}

- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewRowAction *editAction
    = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal
                                         title:@"Edit"
                                       handler:^(UITableViewRowAction *action,
                                                 NSIndexPath *indexPath)
       {
           if (indexPath.row < _layout.count) {
               editIndex = indexPath.row;
               [self performSegueWithIdentifier:kDetailAddItemSegueIdentifer
                                         sender:[_layout objectAtIndex:indexPath.row]];
           }
       }];
    editAction.backgroundColor = kColorUIDefault;
    
    UITableViewRowAction *deleteAction
    = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive
                                         title:@"Delete"
                                       handler:^(UITableViewRowAction *action,
                                                 NSIndexPath *indexPath)
       {
           [_layout removeObjectAtIndex:indexPath.row];
           [self saveLayout];
           [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade|UITableViewRowAnimationLeft];
       }];
    deleteAction.backgroundColor = kColorBase;
    return @[deleteAction, editAction];
}

- (IBAction)addButtonAction:(id)sender
{
    editIndex = -1;
    if (_duo.layout.count + _layout.count >= kMaxUIElements) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Warning"
                                                                       message:[NSString stringWithFormat:@"You already have %u controls in the list.\n\nToo many requests will make the device unstable.\n\nPlease remove some of the items before you continue.", _duo.layout.count + _layout.count]
                                                                preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"Abort"
                                                                style:UIAlertActionStyleDefault
                                                              handler:nil];
        UIAlertAction *addAction = [UIAlertAction actionWithTitle:@"Continue"
                                                                style:UIAlertActionStyleDestructive
                                                              handler:^(UIAlertAction * action) {
                                                                  [self performSegueWithIdentifier:kDetailAddItemSegueIdentifer sender:sender];
                                                              }];
        alert.view.tintColor = kColorButtonDefault;
        [alert addAction:addAction];
        [alert addAction:defaultAction];
        [[[[UIApplication sharedApplication] keyWindow] rootViewController] presentViewController:alert
                                                                                         animated:YES
                                                                                       completion:nil];
    } else {
        [self performSegueWithIdentifier:kDetailAddItemSegueIdentifer sender:sender];
    }
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [super prepareForSegue:segue sender:sender];
    
    if ([segue.identifier isEqualToString:kDetailAddItemSegueIdentifer]) {
        DetailAddItemTVC *vc = segue.destinationViewController;
        vc.delegate = self;
        if (editIndex >= 0 && editIndex < _layout.count) {
            vc.editIndex = editIndex;
            vc.editLayout = [_layout objectAtIndex:editIndex];
        } else {
            vc.editIndex = -1;
        }
    } else if ([segue.identifier isEqualToString:kDetailPinModeSegueIdentifer]) {
        DetailPinModeTVC *vc = segue.destinationViewController;
        vc.duo = _duo;
    }
}

#pragma mark - DetailAddItemDelegate

- (void)newItemAdded:(DuoUI *)newUI
{
    [_layout addObject:newUI];
    [self.tableView reloadData];
    [self saveLayout];
}

- (void)itemEdited:(DuoUI *)newUI atIndex:(NSUInteger)index
{
    if (index < _layout.count) {
        [_layout removeObjectAtIndex:index];
        [_layout insertObject:newUI atIndex:index];
        [self.tableView reloadData];
        [self saveLayout];
    }
}

#pragma mark - Sync User Defaults

- (void)loadLayout
{
    _layout = nil;
    
    if (hash) {
        NSData *data;
        if ((data = [[NSUserDefaults standardUserDefaults] dataForKey:hash])) {
            NSMutableArray<DuoUI *> *source;
            if ((source = [NSKeyedUnarchiver unarchiveObjectWithData:data])) {
                _layout = [source mutableCopy];
            }
        }
    }
    
    if (!_layout) {
        _layout = [NSMutableArray new];
    }
}

- (void)saveLayout
{
    if (hash) {
        if (_layout.count) {
            NSData *data = [NSKeyedArchiver archivedDataWithRootObject:_layout];
            if (data) {
                [[NSUserDefaults standardUserDefaults] setObject:data
                                                          forKey:hash];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
        } else {
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:hash];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }
}

@end
