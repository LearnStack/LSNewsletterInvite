//
//  LSNewsletterInvite.m
//  LSNewsletterInvite
//
//  Copyright (c) 2013 LearnStack, LLC. All rights reserved.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "LSNewsletterInvite.h"
#import "SVProgressHUD.h"
#import "ChimpKit.h"

/*
 These keys are used to store invite and launch count in NSUserDefaults
 */

static NSString * const kNewsletterInviteAppLaunchCountKey = @"LSNewsletterInviteAppLaunchCount";
static NSString * const kNewsletterInviteCountKey = @"LSNewsletterInviteCount";
static NSString * const kNewsletterInviteAcceptedKey = @"LSNewsletterInviteAccepted";

/*
 The table view can be customized in a number of ways. This enum keeps track of each of the sections
 in the table view.
 */

enum {
    TableViewTitleSection = 0,
    TableViewCopySection,
    TableViewFormSection,
    TableViewSubmitButtonSection,
    TableViewSectionCount
};

#define RGBCOLOR(r,g,b) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1]
#define RGBACOLOR(r,g,b,a) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]
#define IS_IPHONE_5 ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )568 ) < DBL_EPSILON )

// From http://cocoawithlove.com/2009/06/verifying-that-string-is-email-address.html
static NSString * const kEmailRegex = (@"(?:[a-z0-9!#$%\\&'*+/=?\\^_`{|}~-]+(?:\\.[a-z0-9!#$%\\&'*+/=?\\^_`{|}"
                                       @"~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\"
                                       @"x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[a-z0-9](?:[a-"
                                       @"z0-9-]*[a-z0-9])?\\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\\[(?:(?:25[0-5"
                                       @"]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-"
                                       @"9][0-9]?|[a-z0-9-]*[a-z0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21"
                                       @"-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])");


@interface LSNewsletterInvite () <UITextFieldDelegate, ChimpKitDelegate, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITextField *emailTextField;
@property (nonatomic, strong) UITextField *nameTextField;
@property (nonatomic, strong) UIButton *subscribeButton;
@property (nonatomic, strong) UIView *coverView;
@property (nonatomic, strong) UITableView *tableView;

@end

@implementation LSNewsletterInvite

+ (void)appLaunched:(BOOL)canPromptForNewsletter viewController:(UIViewController*)viewController {
    
    /*
       First it checks to see if the user has already accepted an invite. Then it checks launch count, if launch count requirements have been met it checks to see if the user has been invited less than the number of invites allowed.
     */

    if (![[NSUserDefaults standardUserDefaults] boolForKey:kNewsletterInviteAcceptedKey]) {
        
        NSInteger launchCount = [[NSUserDefaults standardUserDefaults] integerForKey:kNewsletterInviteAppLaunchCountKey];
        launchCount++;
        
        if(launchCount > NewsletterInviteAfterLaunchCount) {
            
            NSInteger inviteCount = [[NSUserDefaults standardUserDefaults] integerForKey:kNewsletterInviteCountKey];
            if(inviteCount < NewsletterInviteCount) {
                
                LSNewsletterInvite *invite = [[LSNewsletterInvite alloc] init];
                invite.viewController = viewController;
                [viewController presentNewsletterInvite:invite];
                
            }
        }
        
        
        [[NSUserDefaults standardUserDefaults] setInteger:launchCount forKey:kNewsletterInviteAppLaunchCountKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        //TODO: If coverImage text is nil, add a simple dark background view
        
        NSString *backgroundCustomImageName = NewsletterInviteBackgroundCustomImageName;
        if(backgroundCustomImageName) {
            
            self.coverView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame];
            
            UIImageView * imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.coverView.frame.size.width, self.coverView.frame.size.height)];
            imageView.image = [UIImage imageNamed:backgroundCustomImageName];
            [self.coverView addSubview:imageView];
            
        } else {
            self.coverView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame];
            self.coverView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:1];
        }
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // The dismiss button takes up the entire screen behind the table view. If the user taps anyhere outside of the invite it will trigger a dismiss.
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];


    if(NewsletterInviteAllowCancel) {
        
        UIButton *dismissButton = [UIButton buttonWithType:UIButtonTypeCustom];
        dismissButton.frame = self.view.frame;
        [dismissButton addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:dismissButton];
        
    }
    
    CGFloat widthRatio = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? NewsletterTableViewWidthRatioPad : NewsletterTableViewWidthRatioPhone;

    
    // The tableview's height is dynamically set to be the minimum height necessary to display all of the info set up in the header file.
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake((1-widthRatio) * self.view.bounds.size.width / 2, 0, widthRatio * self.view.bounds.size.width, self.view.bounds.size.height) style:UITableViewStyleGrouped];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.clipsToBounds = NO;
    self.tableView.scrollEnabled = NO;
    [self.view addSubview:self.tableView];
    
    // TODO: Add the custom invite image to the background image of the table view.

    NSString *customInviteImageName = NewsletterInviteCustomImageName;
    UIView *backgroundView = [[UIView alloc] init];

    if([customInviteImageName length] > 0) {
        UIImage *customInviteImage = [UIImage imageNamed:customInviteImageName];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:customInviteImage];
        imageView.frame = CGRectMake((self.tableView.frame.size.width - customInviteImage.size.width)/2, 0, customInviteImage.size.width, customInviteImage.size.height);

        backgroundView.backgroundColor = [UIColor clearColor];
        [self.tableView setBackgroundView:backgroundView];

        [self.tableView.backgroundView addSubview:imageView];
    } else {
        backgroundView.backgroundColor = [UIColor whiteColor];
        [self.tableView setBackgroundView:backgroundView];
    }
    
    self.emailTextField = [[UITextField alloc] initWithFrame:CGRectZero];
    self.emailTextField.keyboardType = UIKeyboardTypeEmailAddress;
    self.emailTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.emailTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.emailTextField.returnKeyType = UIReturnKeyNext;
    self.emailTextField.placeholder = @"example@me.com";
    self.emailTextField.textColor = RGBCOLOR(50, 79, 133);
    self.emailTextField.delegate = self;
    [self.emailTextField addTarget:self action:@selector(emailTextFieldChanged) forControlEvents:UIControlEventEditingChanged];
    
    self.nameTextField = [[UITextField alloc] initWithFrame:CGRectZero];
    self.nameTextField.keyboardType = UIKeyboardTypeDefault;
    self.nameTextField.autocapitalizationType = UITextAutocapitalizationTypeWords;
    self.nameTextField.returnKeyType = UIReturnKeyNext;
    self.nameTextField.placeholder = @"optional";
    self.nameTextField.textColor = RGBCOLOR(50, 79, 133);
    self.nameTextField.delegate = self;
    
    // The submit/subscribe button is dynamically updated to work only when their is an email in the email textfield
    
    [self updateChrome];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    
    self.emailTextField = nil;
    self.nameTextField = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // [self.emailTextField becomeFirstResponder];

    // The invite count is incremented when you initialize and present with the class method, and when you initialize and present your own.
    
    NSInteger inviteCount = [[NSUserDefaults standardUserDefaults] integerForKey:kNewsletterInviteCountKey];
    inviteCount++;
    
    [[NSUserDefaults standardUserDefaults] setInteger:inviteCount forKey:kNewsletterInviteCountKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)updateChrome {
    NSString *email = [[self.emailTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] lowercaseString];
    if([[NSPredicate predicateWithFormat:@"SELF MATCHES %@", kEmailRegex]
        evaluateWithObject:email]) {

        self.subscribeButton.enabled = YES;
        self.subscribeButton.alpha = 1.0;
        
    } else {
    
        self.subscribeButton.enabled = NO;
        self.subscribeButton.alpha = 0.75;

    }
    
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    // The number of sections has an impact on layout. Because the tableview is a grouped table view there is a margin between sections. If you'd like to remove the margins, you'll need to merge the sections into one, and change to rows, or you'll need to change the table view type to plain.
    
    return TableViewSectionCount;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

    // Table view cell heights are dynaimcally set based on settins in the header.
    
    switch ([indexPath section]) {
        case TableViewTitleSection: {
            NSString *titleCustomImageName = NewsletterInviteTitleCustomImage;
            if ([titleCustomImageName length] > 0) {
                UIImage *titleCustomImage = [UIImage imageNamed:titleCustomImageName];
                
                return titleCustomImage.size.height;
            } else {
                return [self cellHeightWithText:NewsletterInviteTitle fontSize:(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? NewsletterInviteTitleFontSizePad : NewsletterInviteTitleFontSizePhone bold:YES];
            }
            break;
        }
        case TableViewCopySection: {
            switch ([indexPath row]) {
                case 0: {
                    NSString *firstCopyCustomImageName = NewsletterInviteFirstCopyCustomImage;
                    if ([firstCopyCustomImageName length] > 0) {
                        UIImage *firstCopyCustomImage = [UIImage imageNamed:firstCopyCustomImageName];
                        
                        return firstCopyCustomImage.size.height;
                    } else {
                    
                    return [self cellHeightWithText:NewsletterInviteFirstCopy fontSize: (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? NewsletterInviteFirstCopyFontSizePad : NewsletterInviteFirstCopyFontSizePhone bold:YES];
                    }
                    break;
                }
                case 1:{
                    CGFloat copyFormMargin = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? NewsletterCopyFormMarginPad : (IS_IPHONE_5) ? NewsletterCopyFormMarginPhone4 : NewsletterCopyFormMarginPhone35;
                    return [self cellHeightWithText:NewsletterInviteSecondCopy fontSize: (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? NewsletterInviteSecondCopyFontSizePad : NewsletterInviteSecondCopyFontSizePhone bold:NO] + copyFormMargin;
                    break;
                }
            }
            break;
        }
        case TableViewFormSection:
            return 44;
            break;
        case TableViewSubmitButtonSection:
            return 44;
            break;
    }
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    // Because the heights are dynamic, if there is no text in one of the copy sections, LSNewsletterInvite will simply set that row at a height of 0 the number of rows doesn't affect the layout.
    
    switch (section) {
        case TableViewTitleSection:
            return 1;
            break;
        case TableViewCopySection:
            return 2;
            break;
        case TableViewFormSection:
            return 2;
            break;
        case TableViewSubmitButtonSection:
            return 1;
            break;
    }
    return 0;

}

- (CGFloat) cellHeightWithText:(NSString *)text fontSize:(CGFloat)fontSize bold:(BOOL)useBold {
    
    // LSNewsletterInvite uses the system font. Any custom fonts would need to be updated here and in the cellForRowAtIndexPath method.
    
    if(useBold) {
        CGSize expectedLabelSize = [text sizeWithFont:[UIFont boldSystemFontOfSize:fontSize]
                                    constrainedToSize:CGSizeMake(self.tableView.frame.size.width - 20, 999)
                                        lineBreakMode:NSLineBreakByWordWrapping];
        return expectedLabelSize.height;
    } else {
        CGSize expectedLabelSize = [text sizeWithFont:[UIFont systemFontOfSize:fontSize]
                                    constrainedToSize:CGSizeMake(self.tableView.frame.size.width - 20, 999)
                                        lineBreakMode:NSLineBreakByWordWrapping];
        return expectedLabelSize.height;
    }    
}

-(void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // This method captures the last section and row, and then updates the table view size to fit to the height of all visible cells.
    
    if([indexPath section] == (TableViewSectionCount - 1)) {
        CGFloat topMargin = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? NewsletterInviteTopMarginPad : (IS_IPHONE_5) ? NewsletterInviteTopMarginPhone4 : NewsletterInviteTopMarginPhone35;
        self.tableView.frame = CGRectMake(self.tableView.frame.origin.x, topMargin, self.tableView.frame.size.width, [self tableView:tableView heightAfterIndexPath:indexPath]);
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightAfterIndexPath:(NSIndexPath *)indexPath {
    
    // This is height AFTER index path, it adds in the last heightForRowAtIndexPath to the height of all visibleCells
    
    CGFloat height = 0;
    CGFloat margin = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? 20 : 20;
    for (UITableViewCell *cell in [self.tableView visibleCells]) {
        height += cell.frame.size.height;
    }
    CGFloat total = height + [self tableView:tableView heightForRowAtIndexPath:indexPath] + (margin * (TableViewSectionCount + 2));
    return total;
}

- (CGFloat)tableView:(UITableView *)tableView heightUpToIndexPath:(NSIndexPath *)indexPath {

    // This is height BEFORE index path, it only adds each cell's height that isn't beyond the given index path
    
    CGFloat height = 0;
    CGFloat margin = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? 20 : 20;
    for (int s = 0; s <= indexPath.section; s++) {
        for (int r = 0; r < [self tableView:tableView numberOfRowsInSection:s]; r++) {
            if(s == indexPath.section) {
                if(r < indexPath.row) {
                    UITableViewCell *cell = [self tableView:tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:r inSection:s]];
                    height += cell.frame.size.height;
                }
            } else {
                UITableViewCell *cell = [self tableView:tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:r inSection:s]];
                height += cell.frame.size.height;
            }
        }
    }
    
    CGFloat total = height + (margin * (indexPath.section + 1));
    return total;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // LSNewsletterInvite uses the system font. Any custom fonts would need to be updated here and in the cellHeightWithText method.
    
    // The cells are not dequeued. The table view is meant to be completely visible on screen with no scrolling. 
    
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    switch (indexPath.section) {
        case TableViewTitleSection: {
            NSString *titleCustomImageName = NewsletterInviteTitleCustomImage;
            if ([titleCustomImageName length] > 0) {
                
                cell.backgroundColor = [UIColor clearColor];
                cell.backgroundView = [[UIView alloc] initWithFrame:CGRectZero];
                
                UIImage *titleCustomImage = [UIImage imageNamed:titleCustomImageName];
                UIImageView *titleImageView = [[UIImageView alloc] initWithImage:titleCustomImage];
                
                CGFloat margins = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? 60 : 20;
                
                titleImageView.frame = CGRectMake(((tableView.frame.size.width - margins) - titleCustomImage.size.width) / 2,
                                                  0, titleCustomImage.size.width, titleCustomImage.size.height);
                
                [cell.contentView addSubview:titleImageView];
                
            } else {
                
                cell.textLabel.text = NewsletterInviteTitle;
                cell.textLabel.font = [UIFont systemFontOfSize:(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ?NewsletterInviteTitleFontSizePad : NewsletterInviteTitleFontSizePhone];
                cell.textLabel.textAlignment = NSTextAlignmentCenter;
                cell.textLabel.numberOfLines = 0;
                cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
                cell.backgroundColor = [UIColor clearColor];
                cell.backgroundView = [[UIView alloc] initWithFrame:CGRectZero];
            }
            break;
        }
        case TableViewCopySection: {
            switch (indexPath.row) {
                case 0: {
                    NSString *firstCopyCustomImageName = NewsletterInviteFirstCopyCustomImage;
                    if ([firstCopyCustomImageName length] > 0) {
                        
                        cell.backgroundColor = [UIColor clearColor];
                        cell.backgroundView = [[UIView alloc] initWithFrame:CGRectZero];
                        
                        UIImage *firstCopyCustomImage = [UIImage imageNamed:firstCopyCustomImageName];
                        UIImageView *firstCopyImageView = [[UIImageView alloc] initWithImage:firstCopyCustomImage];
                        
                        CGFloat margins = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? 60 : 20;
                        
                        firstCopyImageView.frame = CGRectMake(((tableView.frame.size.width - margins) - firstCopyCustomImage.size.width) / 2,
                                                              0, firstCopyCustomImage.size.width, firstCopyCustomImage.size.height);
                        
                        [cell.contentView addSubview:firstCopyImageView];
                        
                    } else {
                        
                        
                        cell.textLabel.text = NewsletterInviteFirstCopy;
                        cell.textLabel.font = [UIFont systemFontOfSize:(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? NewsletterInviteFirstCopyFontSizePad : NewsletterInviteFirstCopyFontSizePhone];
                        cell.textLabel.textAlignment = NSTextAlignmentCenter;
                        cell.textLabel.numberOfLines = 0;
                        cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
                        cell.backgroundColor = [UIColor clearColor];
                        cell.backgroundView = [[UIView alloc] initWithFrame:CGRectZero];
                    }
                    break;
                }
                case 1: {
                    
                    NSString *secondCopyCustomImageName = NewsletterInviteSecondCopyCustomImage;
                    if ([secondCopyCustomImageName length] > 0) {
                        
                        cell.backgroundColor = [UIColor clearColor];
                        cell.backgroundView = [[UIView alloc] initWithFrame:CGRectZero];
                        
                        UIImage *secondCopyCustomImage = [UIImage imageNamed:secondCopyCustomImageName];
                        UIImageView *secondCopyImageView = [[UIImageView alloc] initWithImage:secondCopyCustomImage];
                        
                        CGFloat margins = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? 60 : 20;
                        
                        secondCopyImageView.frame = CGRectMake(((tableView.frame.size.width - margins) - secondCopyCustomImage.size.width) / 2,
                                                              0, secondCopyCustomImage.size.width, secondCopyCustomImage.size.height);
                        
                        [cell.contentView addSubview:secondCopyImageView];
                        
                    } else {
                        
                        
                        cell.textLabel.text = NewsletterInviteSecondCopy;
                        cell.textLabel.font = [UIFont systemFontOfSize:(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? NewsletterInviteSecondCopyFontSizePad : NewsletterInviteSecondCopyFontSizePhone];
                        cell.textLabel.textAlignment = NSTextAlignmentCenter;
                        cell.textLabel.numberOfLines = 0;
                        cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
                        cell.backgroundColor = [UIColor clearColor];
                        cell.backgroundView = [[UIView alloc] initWithFrame:CGRectZero];
                    }
                    break;
                }
            }
            break;
        }
        case TableViewFormSection:
            switch (indexPath.row) {
                case 0:
                    cell.textLabel.text = @"Email";
                    self.emailTextField.frame = CGRectMake(0,
                                                           0,
                                                           tableView.bounds.size.width - (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 200.0f : 100.0f),
                                                           [self.emailTextField sizeThatFits:tableView.bounds.size].height);
                    cell.accessoryView = self.emailTextField;
                    break;
                case 1:
                    cell.textLabel.text = @"Name";
                    self.nameTextField.frame = CGRectMake(0,
                                                          0,
                                                          tableView.bounds.size.width - (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 200.0f : 100.0f),
                                                          [self.nameTextField sizeThatFits:tableView.bounds.size].height);
                    cell.accessoryView = self.nameTextField;
                    break;
                    
            }
            break;
        case TableViewSubmitButtonSection: {

            self.subscribeButton = [UIButton buttonWithType:UIButtonTypeCustom];
            UIImage *submitButtonImage = [UIImage imageNamed:@"submit_button"];
            [self.subscribeButton setImage:submitButtonImage forState:UIControlStateNormal];
            
            CGFloat margins = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? 60 : 20;
            self.subscribeButton.frame = CGRectMake(((tableView.frame.size.width - margins) - submitButtonImage.size.width) / 2,
                                            0, submitButtonImage.size.width, submitButtonImage.size.height);
            [self.subscribeButton addTarget:self action:@selector(subscribe) forControlEvents:UIControlEventTouchUpInside];
            [cell.contentView addSubview:self.subscribeButton];
            
            cell.backgroundColor = [UIColor clearColor];
            cell.backgroundView = [[UIView alloc] initWithFrame:CGRectZero];
            [self updateChrome];
            break;
        }
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    id accessoryView = [tableView cellForRowAtIndexPath:indexPath].accessoryView;
    if ([accessoryView isKindOfClass:[UITextField class]]) {
        [(UITextField *)accessoryView becomeFirstResponder];
    }
}

#pragma mark - UITextFieldDelegate

- (void)keyboardWillShow:(NSNotification *)notification {

    NSDictionary *userInfo = [notification userInfo];
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    [UIView animateWithDuration:animationDuration animations:^{
        CGFloat height = [self tableView:self.tableView heightUpToIndexPath:[NSIndexPath indexPathForRow:0 inSection:TableViewFormSection]];
        
        CGFloat requiredSpace = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? 520 : (IS_IPHONE_5) ? 195 : 140;
        CGFloat offset = MIN(requiredSpace - height, self.tableView.frame.origin.y);
        self.tableView.frame = CGRectMake(self.tableView.frame.origin.x,
                                          offset, self.tableView.frame.size.width, self.tableView.frame.size.height);
    }];

}

- (void)keyboardWillHide:(NSNotification *)notification {

    NSDictionary *userInfo = [notification userInfo];    
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    [UIView animateWithDuration:animationDuration animations:^{
        
        CGFloat topMargin = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? NewsletterInviteTopMarginPad : (IS_IPHONE_5) ? NewsletterInviteTopMarginPhone4 : NewsletterInviteTopMarginPhone35;
        
        self.tableView.frame = CGRectMake(self.tableView.frame.origin.x, topMargin, self.tableView.frame.size.width, self.tableView.frame.size.height);
        
    }];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.emailTextField) {
        [self.nameTextField becomeFirstResponder];
    } else if (textField == self.nameTextField) {

        // The return button on the text fields will cycle through name and email until the string in the email textfield is an email, then it will submit.

        if(self.subscribeButton.enabled) {
            [self.nameTextField resignFirstResponder];
            [self subscribe];
        } else {
            [self.emailTextField becomeFirstResponder];
        }
    }
    
    return YES;
}

#pragma mark - UITextField Actions

- (void)emailTextFieldChanged {
    [self updateChrome];
}

#pragma mark - Navigation Item Actions

- (void)subscribe {
    [self.view endEditing:YES];
    
    [SVProgressHUD showWithStatus:@"Subscribing" maskType:SVProgressHUDMaskTypeClear];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setValue:NewsletterMailchimpListId forKey:@"id"];
    
    NSString *email = [self.emailTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    [params setValue:email forKey:@"email_address"];
    
    [params setValue:@"false" forKey:@"replace_interests"];
    [params setValue:@"true" forKey:@"update_existing"];
    
    NSMutableDictionary *mergeVars = [NSMutableDictionary dictionary];
    NSString *name = self.nameTextField.text;
    if ([name length] > 0) {
        [mergeVars setValue:name forKey:@"FNAME"];
    }
    
    // If your NewsletterMailChimpGroup is set to @"" it will skip this section. You can group your email signups by app which allows for more control over your mailing schedules. This is not important to some developers.
    
    NSString *group = NewsletterMailchimpGroup;
    if([group length] > 0) {
        
        NSMutableArray *groupings = [NSArray arrayWithObject:[NSDictionary dictionaryWithObjectsAndKeys:
                                                              NewsletterMailchimpGroupName, @"name",
                                                              NewsletterMailchimpGroup, @"groups",
                                                              nil]];
        [mergeVars setValue:groupings forKey:@"GROUPINGS"];
    }    
    
    [params setValue:[NSNumber numberWithBool:NewsletterMailchimpDoubleOptIn] forKey:@"double_optin"];    
    [params setValue:mergeVars forKey:@"merge_vars"];
    
    ChimpKit *ck = [[ChimpKit alloc] initWithDelegate:self andApiKey:NewsletterMailchimpKey];
    [ck callApiMethod:@"listSubscribe" withParams:params];
}

#pragma mark ChimpKitDelegate

- (void)ckRequestSucceeded:(ChimpKit *)ckRequest {
    [SVProgressHUD showSuccessWithStatus:@"Subscribed"];

    if(_delegate) {
        [self.delegate newsletterInviteDidFinish:self];
    } else {
        [self.viewController dismissNewsletterInvite:self];
    }
    
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kNewsletterInviteAcceptedKey];
    
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                     self.emailTextField.text, kEmailKey,
                                     self.nameTextField.text, kNameKey,
                                     nil];

    [[NSNotificationCenter defaultCenter] postNotificationName:kLSNewsletterInviteSuccessfulSignupNotificationKey object:nil userInfo:userInfo];
}

- (void)ckRequestFailed:(NSError *)error {
    [SVProgressHUD showErrorWithStatus:@"Failed"];
}

- (void)dismiss {
    
    [self.view endEditing:YES];
    
    if(_delegate) {
        if ([_delegate respondsToSelector:@selector(newsletterInviteDidCancel:)]) {
            [_delegate newsletterInviteDidCancel:self];
        } else {
            [self.delegate newsletterInviteDidFinish:self];
        }
    } else {
        [self.viewController dismissNewsletterInvite:self];
    }
}

@end

@implementation UIViewController (PopupViewController)

-(void)presentNewsletterInvite:(LSNewsletterInvite *)newsletterInvite {
	UIView* modalView = newsletterInvite.view;
    UIView* coverView = newsletterInvite.coverView;
    UIView *rootView = UIApplication.sharedApplication.delegate.window.rootViewController.view;
    
    [UIApplication.sharedApplication.delegate.window.rootViewController addChildViewController:newsletterInvite];
    
    CGRect viewFrame;
        
    viewFrame = CGRectMake(0, 0, rootView.bounds.size.width, rootView.bounds.size.height);
    
	coverView.frame = viewFrame;
    coverView.alpha = 0.0f;
    
    modalView.frame = viewFrame;
	modalView.center = self.offscreenCenter;
	
	[rootView addSubview:coverView];
	[rootView addSubview:modalView];
	
    [UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.6];
	
	modalView.frame = viewFrame;
	coverView.alpha = 1.0;
    
	[UIView commitAnimations];
    
}

-(void)dismissNewsletterInvite:(LSNewsletterInvite*)newsletterInvite {
	double animationDelay = 0.7;
	UIView* modalView = newsletterInvite.view;
	UIView* coverView = newsletterInvite.coverView;
    
	[UIView beginAnimations:nil context:(__bridge void *)(modalView)];
	[UIView setAnimationDuration:animationDelay];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(dismissSemiModalViewControllerEnded:finished:context:)];
	
    modalView.center = self.offscreenCenter;
	coverView.alpha = 0.0f;
    
	[UIView commitAnimations];
    
	[coverView performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:animationDelay];
    
    [newsletterInvite removeFromParentViewController];
}

-(CGPoint) offscreenCenter {
    CGPoint offScreenCenter = CGPointZero;
    
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;    
    CGSize offSize = UIScreen.mainScreen.bounds.size;
    
	if(orientation == UIInterfaceOrientationLandscapeLeft || orientation == UIInterfaceOrientationLandscapeRight) {
		offScreenCenter = CGPointMake(offSize.height / 2.0, offSize.width * 1.5);
	} else {
		offScreenCenter = CGPointMake(offSize.width / 2.0, offSize.height * 1.5);
	}
    
    return offScreenCenter;
}


@end
