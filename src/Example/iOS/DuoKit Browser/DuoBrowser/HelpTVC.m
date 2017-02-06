//
//  HelpTVC.m
//  DuoKit Browser
//
//  The MIT License (MIT)
//
//  Copyright © 2017 MediaTek Inc. All rights reserved.
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

#import "HelpTVC.h"
#import <DuoKit/DuoKit.h>

@interface HelpTVC ()

@end

@implementation HelpTVC

- (void)viewDidLoad
{
    [super viewDidLoad];
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (section != [tableView numberOfSections] - 1) {
        return [super tableView:tableView heightForFooterInSection:section];
    }
    return 50.f;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if (section != [tableView numberOfSections] - 1) {
        return nil;
    }
    
    UILabel *label
    = [[UILabel alloc] initWithFrame:CGRectMake(0, 0,
                                                self.view.frame.size.width,
                                                44.f)];
    
    label.text = [NSString stringWithFormat:@"Version: %@ (%@)",
                  [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"],
                  [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]];
    
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont systemFontOfSize:[UIFont smallSystemFontSize] weight:UIFontWeightUltraLight];
    label.textColor = [UIColor lightGrayColor];
    
    return label;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    switch (cell.tag) {
        case 0: // Help
            [self showHelp:self];
            break;
        default:
            break;
    }
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [super prepareForSegue:segue sender:sender];
}

#pragma mark - Methods

- (IBAction)showHelp:(id)sender
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:kProjectURL]];
}

@end
