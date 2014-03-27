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

#import <SVProgressHUD/SVProgressHUD.h>
#import <ChimpKit/ChimpKit.h>
#import <QuartzCore/QuartzCore.h>

#import <LSNewsletterInvite/LSNewsletterInvite.h>
#import <LSNewsletterInvite/LSNewsletterInviteSettings.h>

/*
 These definitions are the default values if a settings file is not assigned.
 */

static const BOOL kNewsletterMailchimpDoubleOptIn = YES;
static const BOOL kNewsletterInviteIgnoreCancel = NO;

static NSString * const kNewsletterInviteTitle = @"Sign Up Today!";
static NSString * const kNewsletterInviteTitleCustomImage = @"";

static const CGFloat kNewsletterInviteTitleFontSizePad = 42;
static const CGFloat kNewsletterInviteTitleFontSizePhone = 24;

static NSString * const kNewsletterInviteFirstCopy = @"";
static NSString * const kNewsletterInviteFirstCopyCustomImage = @"";

static const CGFloat kNewsletterInviteFirstCopyFontSizePad = 32;
static const CGFloat kNewsletterInviteFirstCopyFontSizePhone = 14;

static NSString * const kNewsletterInviteSecondCopy = @"We'd love to stay in touch for support, tips, and offers on all of our apps.";
static NSString * const kNewsletterInviteSecondCopyCustomImage = @"";

static NSString * const kNewsletterInviteSubmitButtonColor = @"3e8acc";
static const CGFloat kNewsletterInviteSubmitButtonWidth = 156;
static const CGFloat kNewsletterInviteSubmitButtonHeight = 44;

static const CGFloat kNewsletterInviteSecondCopyFontSizePad = 30;
static const CGFloat kNewsletterInviteSecondCopyFontSizePhone = 14;

static const CGFloat kNewsletterCopyFormMarginPad = 60;
static const CGFloat kNewsletterCopyFormMarginPhone35 = 0;
static const CGFloat kNewsletterCopyFormMarginPhone4 = 0;

static const CGFloat kNewsletterTableViewWidthRatioPad = 0.75;
static const CGFloat kNewsletterTableViewWidthRatioPhone = 0.90;

static const CGFloat kNewsletterInviteTopMarginPhone35 = 50;
static const CGFloat kNewsletterInviteTopMarginPhone4 = 75;

static const CGFloat kNewsletterInviteAfterLaunchCount = 0;
static const CGFloat kNewsletterInviteCount = 2;

static const CGFloat kNewsletterTitleTopMarginPad = 40;
static const CGFloat kNewsletterTitleTopMarginPhone35 = 20;
static const CGFloat kNewsletterTitleTopMarginPhone4 = 20;

static const CGFloat kNewsletterSectionMarginPad = 20;
static const CGFloat kNewsletterSectionMarginPhone35 = 15;
static const CGFloat kNewsletterSectionMarginPhone4 = 15;

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


@interface LSNewsletterInvite () <UITextFieldDelegate, ChimpKitRequestDelegate, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITextField *emailTextField;
@property (nonatomic, strong) UITextField *nameTextField;
@property (nonatomic, strong) UIButton *subscribeButton;
@property (nonatomic, strong) UIView *coverView;
@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) UIButton *dismissButton;
// It's possible to use a tap gesture recognizer on the view, but then it would be triggered when tapping inside of the invite view and not only around it.

@end

@implementation LSNewsletterInvite

+ (void)appLaunched:(BOOL)canPromptForNewsletter viewController:(UIViewController*)viewController {
    [LSNewsletterInvite appLaunched:canPromptForNewsletter viewController:viewController andSettings:nil];
}

+ (void)appLaunched:(BOOL)canPromptForNewsletter viewController:(UIViewController*)viewController andSettings:(LSNewsletterInviteSettings *)settings {
    
    /*
     First it checks to see if the user has already accepted an invite. Then it checks launch count, if launch count requirements have been met it checks to see if the user has been invited less than the number of invites allowed.
     */
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:kNewsletterInviteAcceptedKey]) {
        
        NSInteger launchCount = [[NSUserDefaults standardUserDefaults] integerForKey:kNewsletterInviteAppLaunchCountKey];
        launchCount++;
        
        CGFloat afterLaunchCount = kNewsletterInviteAfterLaunchCount;
        
        if (settings) {
            if (settings.afterLaunchCount > 0) {
                afterLaunchCount = settings.afterLaunchCount;
            }
        }
        
        if (launchCount > afterLaunchCount) {
            
            NSInteger inviteCount = [[NSUserDefaults standardUserDefaults] integerForKey:kNewsletterInviteCountKey];
            
            CGFloat allowedInviteCount = kNewsletterInviteCount;
            if (settings) {
                if (settings.inviteCount > 0) {
                    allowedInviteCount = settings.inviteCount;
                }
            }
            
            if (inviteCount < allowedInviteCount) {
                
                LSNewsletterInvite *invite = [[LSNewsletterInvite alloc] init];
                invite.viewController = viewController;
                if (settings) {
                    invite.settings = settings;
                }
                
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
        
        NSString *backgroundCustomImageName = nil;
        
        if (self.settings) {
            if ([self.settings.inviteBackgroundCustomImageName length] > 0) {
                backgroundCustomImageName = self.settings.inviteBackgroundCustomImageName;
            }
        }
        
        if (backgroundCustomImageName) {
            
            self.coverView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame];
            
            UIImageView * imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.coverView.frame.size.width, self.coverView.frame.size.height)];
            imageView.image = [UIImage imageNamed:backgroundCustomImageName];
            [self.coverView addSubview:imageView];
            
        } else {
            self.coverView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame];
            self.coverView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.8];
        }
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIView *rootView = UIApplication.sharedApplication.delegate.window.rootViewController.view;
    CGRect viewFrame;
    viewFrame = CGRectMake(0, 0, rootView.bounds.size.width, rootView.bounds.size.height);
    
    self.view.frame = viewFrame;
    self.coverView.frame = viewFrame;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    
    BOOL ignoreCancel = kNewsletterInviteIgnoreCancel;
    
    if (self.settings) {
        ignoreCancel = self.settings.ignoreCancel;
    }
    
    // The dismiss button takes up the entire screen behind the table view. If the user taps anyhere outside of the invite it will trigger a dismiss.
    
    if (!ignoreCancel) {
        // Tap gesture method
        // UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget: self action:@selector(dismiss)];
        // singleTap.numberOfTapsRequired = 1;
        // [singleTap setCancelsTouchesInView:NO];
        // [self.coverView addGestureRecognizer:singleTap];
        
        
        self.dismissButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.dismissButton.frame = self.view.frame;
        [self.dismissButton addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:self.dismissButton];
        
    }
    
    // The tableview's height is dynamically set to be the minimum height necessary to display all of the info set up in the header file.
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    
    self.tableView = [[UITableView alloc] initWithFrame:[self tableViewFrameForInterfaceOrientation:orientation] style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.clipsToBounds = NO;
    self.tableView.scrollEnabled = NO;
    
    if (self.settings) {
        if (!self.settings.roundedCornersOff) {
            if (self.settings.roundedCornerRadius > 0) {
                self.tableView.layer.cornerRadius = self.settings.roundedCornerRadius;
            } else {
                self.tableView.layer.cornerRadius = 6; // if you like rounded corners
            }
        }
    } else {
        self.tableView.layer.cornerRadius = 6; // if you like rounded corners
    }
    
	self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [self.view addSubview:self.tableView];
    [self.tableView setBackgroundView:[self viewBackgroundViewForInterfaceOrientation:orientation]];
    
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
    
    // The invite count is incremented when you initialize and present with the class method, and when you initialize and present your own.
    
    NSInteger inviteCount = [[NSUserDefaults standardUserDefaults] integerForKey:kNewsletterInviteCountKey];
    inviteCount++;
    
    [[NSUserDefaults standardUserDefaults] setInteger:inviteCount forKey:kNewsletterInviteCountKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    
    // The submit/subscribe button is dynamically updated to work only when their is an email in the email textfield
    
    [self updateChrome];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    
    self.emailTextField = nil;
    self.nameTextField = nil;
}

- (void)updateChrome {
    NSString *email = [[self.emailTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] lowercaseString];
    if ([[NSPredicate predicateWithFormat:@"SELF MATCHES %@", kEmailRegex]
         evaluateWithObject:email]) {
        
        self.subscribeButton.enabled = YES;
        self.subscribeButton.alpha = 1.0;
        
    } else {
        
        self.subscribeButton.enabled = NO;
        self.subscribeButton.alpha = 0.33;
        
    }
    
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    // The number of sections has an impact on layout. Because the tableview is a grouped table view there is a margin between sections. If you'd like to remove the margins, you'll need to merge the sections into one, and change to rows, or you'll need to change the table view type to plain.
    
    return TableViewSectionCount;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // Table view cell heights are dynaimcally set based on settings in the header.
    
    switch ([indexPath section]) {
        case TableViewTitleSection: {
            NSString *titleCustomImageName = kNewsletterInviteTitleCustomImage;
            
            if (self.settings) {
                if ([self.settings.inviteTitleCustomImage length] > 0) {
                    titleCustomImageName = self.settings.inviteTitleCustomImage;
                }
            }
            
            if ([titleCustomImageName length] > 0) {
                UIImage *titleCustomImage = [UIImage imageNamed:titleCustomImageName];
                
                return titleCustomImage.size.height;
            } else {
                
                CGFloat fontSizePad = kNewsletterInviteTitleFontSizePad;
                CGFloat fontSizePhone = kNewsletterInviteTitleFontSizePhone;
                
                if (self.settings) {
                    if (self.settings.titleFontSizePad > 0) {
                        fontSizePad = self.settings.titleFontSizePad;
                    }
                    if (self.settings.titleFontSizePhone > 0) {
                        fontSizePhone = self.settings.titleFontSizePhone;
                    }
                }
                
                NSString *inviteTitle = kNewsletterInviteTitle;
                if (self.settings) {
                    if ([self.settings.title length] > 0) {
                        inviteTitle = self.settings.title;
                    }
                }
                
                return [self cellHeightWithText:inviteTitle fontSize:(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? fontSizePad : fontSizePhone bold:YES];
            }
            break;
        }
        case TableViewCopySection: {
            switch ([indexPath row]) {
                case 0: {
                    NSString *firstCopyCustomImageName = kNewsletterInviteFirstCopyCustomImage;
                    
                    if (self.settings) {
                        if ([self.settings.firstCopyCustomImage length] > 0) {
                            firstCopyCustomImageName = self.settings.firstCopyCustomImage;
                        }
                    }
                    
                    if ([firstCopyCustomImageName length] > 0) {
                        UIImage *firstCopyCustomImage = [UIImage imageNamed:firstCopyCustomImageName];
                        
                        return firstCopyCustomImage.size.height;
                    } else {
                        
                        CGFloat fontSizePad = kNewsletterInviteFirstCopyFontSizePad;
                        CGFloat fontSizePhone = kNewsletterInviteFirstCopyFontSizePhone;
                        
                        if (self.settings) {
                            if (self.settings.firstCopyFontSizePad > 0) {
                                fontSizePad = self.settings.firstCopyFontSizePhone;
                            }
                            if (self.settings.titleFontSizePhone > 0) {
                                fontSizePhone = self.settings.titleFontSizePhone;
                            }
                        }
                        
                        NSString *inviteFirstCopy = kNewsletterInviteFirstCopy;
                        if (self.settings) {
                            if ([self.settings.firstCopy length] > 0) {
                                inviteFirstCopy = self.settings.firstCopy;
                            }
                        }
                        
                        return [self cellHeightWithText:inviteFirstCopy fontSize: (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? fontSizePad : fontSizePhone bold:YES];
                    }
                    break;
                }
                case 1:{
                    
                    CGFloat copyFormMarginPad = kNewsletterCopyFormMarginPad;
                    CGFloat copyFormMarginPhone35 = kNewsletterCopyFormMarginPhone35;
                    CGFloat copyFormMarginPhone4 = kNewsletterCopyFormMarginPhone4;
                    
                    if (self.settings) {
                        if (self.settings.copyFormMarginPad) {
                            copyFormMarginPad = [self.settings.copyFormMarginPad floatValue];
                        }
                        if (self.settings.copyFormMarginPhone35) {
                            copyFormMarginPhone35 = [self.settings.copyFormMarginPhone35 floatValue];
                        }
                        if (self.settings.copyFormMarginPhone4) {
                            copyFormMarginPhone4 = [self.settings.copyFormMarginPhone4 floatValue];
                        }
                    }
                    
                    CGFloat copyFormMargin = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? copyFormMarginPad : (IS_IPHONE_5) ? copyFormMarginPhone4 : copyFormMarginPhone35;
                    
                    CGFloat fontSizePad = kNewsletterInviteSecondCopyFontSizePad;
                    CGFloat fontSizePhone = kNewsletterInviteSecondCopyFontSizePhone;
                    
                    if (self.settings) {
                        if (self.settings.secondCopyFontSizePad > 0) {
                            fontSizePad = self.settings.secondCopyFontSizePad;
                        }
                        if (self.settings.titleFontSizePhone > 0) {
                            fontSizePhone = self.settings.titleFontSizePhone;
                        }
                    }
                    
                    NSString *inviteSecondCopy = kNewsletterInviteSecondCopy;
                    if (self.settings) {
                        if ([self.settings.secondCopy length] > 0) {
                            inviteSecondCopy = self.settings.secondCopy;
                        }
                    }
                    
                    return [self cellHeightWithText:inviteSecondCopy fontSize: (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? fontSizePad : fontSizePhone bold:NO] + copyFormMargin;
                    break;
                }
            }
            break;
        }
        case TableViewFormSection:
            return 44;
            break;
        case TableViewSubmitButtonSection: {
            
            if (self.settings) {
                if ([self.settings.submitButtonCustomImage length] > 0) {
                    UIImage *image = [UIImage imageNamed:self.settings.submitButtonCustomImage];
                    return image.size.height;
                } else {
                    if (self.settings.submitButtonHeight > 0) {
                        return self.settings.submitButtonHeight;
                    } else {
                        return kNewsletterInviteSubmitButtonHeight;
                    }
                }
            } else {
                return kNewsletterInviteSubmitButtonHeight;
            }
            break;
		}
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
    
    if (useBold) {
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

-(void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // This method captures the last section and row, and then updates the table view size to fit to the height of all visible cells.
    
    if ([indexPath section] == (TableViewSectionCount - 1)) {
        
        CGFloat topMarginPhone35 = kNewsletterInviteTopMarginPhone35;
        CGFloat topMarginPhone4 = kNewsletterInviteTopMarginPhone4;
        
        if (self.settings) {
            if (self.settings.topMarginPhone35 > 0) {
                topMarginPhone35 = self.settings.topMarginPhone35;
            }
            if (self.settings.topMarginPhone4 > 0) {
                topMarginPhone4 = self.settings.topMarginPhone4;
            }
        }
        CGFloat topMargin = 0;
        
        UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
        if (UIInterfaceOrientationIsLandscape(orientation)) {
            topMargin = (self.view.frame.size.height - [self tableView:tableView heightAfterIndexPath:indexPath]) / 2;
        } else {
            topMargin = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? (self.view.frame.size.height - [self tableView:tableView heightAfterIndexPath:indexPath]) / 2 : (IS_IPHONE_5) ? topMarginPhone4 : topMarginPhone35;
        }
        
        self.tableView.frame = CGRectMake(self.tableView.frame.origin.x, topMargin, self.tableView.frame.size.width, [self tableView:tableView heightAfterIndexPath:indexPath]);
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightAfterIndexPath:(NSIndexPath *)indexPath {
    
    // This is height AFTER index path, it adds in the last heightForRowAtIndexPath to the height of all visibleCells
    
    CGFloat maxY = 0;
    
    CGFloat margin = 0;
    for (NSInteger i = 0; i < TableViewSectionCount; i++) {
        margin += [self tableView:tableView heightForHeaderInSection:i];
    }
    
    for (UITableViewCell *cell in [self.tableView visibleCells]) {
        maxY = MAX(maxY,CGRectGetMaxY(cell.frame));
    }
    
    CGFloat cellHeight2 = [self tableView:tableView heightForRowAtIndexPath:indexPath];
    CGFloat total = maxY + cellHeight2 + margin;
    return total;
}

- (CGFloat)tableView:(UITableView *)tableView heightUpToIndexPath:(NSIndexPath *)indexPath {
    
    // This is height BEFORE index path, it only adds each cell's height that isn't beyond the given index path
    
    CGFloat height = 0;
    CGFloat margin = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? 20 : 15;
    for (int s = 0; s <= indexPath.section; s++) {
        for (int r = 0; r < [self tableView:tableView numberOfRowsInSection:s]; r++) {
            if (s == indexPath.section) {
                if (r < indexPath.row) {
                    UITableViewCell *cell = [self tableView:tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:r inSection:s]];
                    height += cell.frame.size.height;
                }
            } else {
                UITableViewCell *cell = [self tableView:tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:r inSection:s]];
                height += cell.frame.size.height;
            }
        }
    }
    
    CGFloat total = height + (margin * (indexPath.section + 2));
    return total;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // LSNewsletterInvite uses the system font. Any custom fonts would need to be updated here and in the cellHeightWithText method.
    
    // The cells are not dequeued. The table view is meant to be completely visible on screen with no scrolling.
    
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    switch (indexPath.section) {
        case TableViewTitleSection: {
            NSString *titleCustomImageName = kNewsletterInviteTitleCustomImage;
            
            if (self.settings) {
                if ([self.settings.inviteTitleCustomImage length] > 0) {
                    titleCustomImageName = self.settings.inviteTitleCustomImage;
                }
            }
            
            if ([titleCustomImageName length] > 0) {
                
                cell.backgroundColor = [UIColor clearColor];
                cell.backgroundView = [[UIView alloc] initWithFrame:CGRectZero];
                
                UIImage *titleCustomImage = [UIImage imageNamed:titleCustomImageName];
                UIImageView *titleImageView = [[UIImageView alloc] initWithImage:titleCustomImage];
                
                CGFloat margins = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? 60 : 15;
                
                titleImageView.frame = CGRectMake(((tableView.frame.size.width - margins) - titleCustomImage.size.width) / 2,
                                                  0, titleCustomImage.size.width, titleCustomImage.size.height);
                
                [cell.contentView addSubview:titleImageView];
                
            } else {
                
                CGFloat fontSizePad = kNewsletterInviteTitleFontSizePad;
                CGFloat fontSizePhone = kNewsletterInviteTitleFontSizePhone;
                
                if (self.settings) {
                    if (self.settings.titleFontSizePad > 0) {
                        fontSizePad = self.settings.titleFontSizePad;
                    }
                    if (self.settings.titleFontSizePhone > 0) {
                        fontSizePhone = self.settings.titleFontSizePhone;
                    }
                }
                
                NSString *inviteTitle = kNewsletterInviteTitle;
                if (self.settings) {
                    if ([self.settings.title length] > 0) {
                        inviteTitle = self.settings.title;
                    }
                }
                
                cell.textLabel.text = inviteTitle;
                cell.textLabel.font = [UIFont systemFontOfSize:(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? fontSizePad : fontSizePhone];
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
                    NSString *firstCopyCustomImageName = kNewsletterInviteFirstCopyCustomImage;
                    
                    if (self.settings) {
                        if ([self.settings.firstCopyCustomImage length] > 0) {
                            firstCopyCustomImageName = self.settings.firstCopyCustomImage;
                        }
                    }
                    
                    if ([firstCopyCustomImageName length] > 0) {
                        
                        cell.backgroundColor = [UIColor clearColor];
                        cell.backgroundView = [[UIView alloc] initWithFrame:CGRectZero];
                        
                        UIImage *firstCopyCustomImage = [UIImage imageNamed:firstCopyCustomImageName];
                        UIImageView *firstCopyImageView = [[UIImageView alloc] initWithImage:firstCopyCustomImage];
                        
                        CGFloat margins = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? 60 : 15;
                        
                        firstCopyImageView.frame = CGRectMake(((tableView.frame.size.width - margins) - firstCopyCustomImage.size.width) / 2,
                                                              0, firstCopyCustomImage.size.width, firstCopyCustomImage.size.height);
                        
                        [cell.contentView addSubview:firstCopyImageView];
                    } else {
                        
                        CGFloat fontSizePad = kNewsletterInviteFirstCopyFontSizePad;
                        CGFloat fontSizePhone = kNewsletterInviteFirstCopyFontSizePhone;
                        
                        if (self.settings) {
                            if (self.settings.firstCopyFontSizePad > 0) {
                                fontSizePad = self.settings.firstCopyFontSizePad;
                            }
                            if (self.settings.firstCopyFontSizePhone > 0) {
                                fontSizePhone = self.settings.firstCopyFontSizePhone;
                            }
                        }
                        
                        NSString *inviteFirstCopy = kNewsletterInviteFirstCopy;
                        if (self.settings) {
                            if ([self.settings.firstCopy length] > 0) {
                                inviteFirstCopy = self.settings.firstCopy;
                            }
                        }
                        
                        cell.textLabel.text = inviteFirstCopy;
                        cell.textLabel.font = [UIFont systemFontOfSize:(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? fontSizePad : fontSizePhone];
                        cell.textLabel.textAlignment = NSTextAlignmentCenter;
                        cell.textLabel.numberOfLines = 0;
                        cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
                        cell.backgroundColor = [UIColor clearColor];
                        cell.backgroundView = [[UIView alloc] initWithFrame:CGRectZero];
                    }
                    break;
                }
                case 1: {
                    NSString *secondCopyCustomImageName = kNewsletterInviteSecondCopyCustomImage;
                    
                    if (self.settings) {
                        if ([self.settings.secondCopyCustomImage length] > 0) {
                            secondCopyCustomImageName = self.settings.secondCopyCustomImage;
                        }
                    }
                    
                    if ([secondCopyCustomImageName length] > 0) {
                        
                        cell.backgroundColor = [UIColor clearColor];
                        cell.backgroundView = [[UIView alloc] initWithFrame:CGRectZero];
                        
                        UIImage *secondCopyCustomImage = [UIImage imageNamed:secondCopyCustomImageName];
                        UIImageView *secondCopyImageView = [[UIImageView alloc] initWithImage:secondCopyCustomImage];
                        
                        CGFloat margins = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? 60 : 15;
                        
                        secondCopyImageView.frame = CGRectMake(((tableView.frame.size.width - margins) - secondCopyCustomImage.size.width) / 2,
                                                               0, secondCopyCustomImage.size.width, secondCopyCustomImage.size.height);
                        
                        [cell.contentView addSubview:secondCopyImageView];
                        
                    } else {
                        
                        CGFloat fontSizePad = kNewsletterInviteSecondCopyFontSizePad;
                        CGFloat fontSizePhone = kNewsletterInviteSecondCopyFontSizePhone;
                        
                        if (self.settings) {
                            if (self.settings.secondCopyFontSizePad > 0) {
                                fontSizePad = self.settings.secondCopyFontSizePad;
                            }
                            if (self.settings.secondCopyFontSizePhone > 0) {
                                fontSizePhone = self.settings.secondCopyFontSizePhone;
                            }
                        }
                        
                        NSString *inviteSecondCopy = kNewsletterInviteSecondCopy;
                        if (self.settings) {
                            if ([self.settings.secondCopy length] > 0) {
                                inviteSecondCopy = self.settings.secondCopy;
                            }
                        }
                        
                        cell.textLabel.text = inviteSecondCopy;
                        cell.textLabel.font = [UIFont systemFontOfSize:(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? fontSizePad : fontSizePhone];
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
					cell.textLabel.textAlignment = NSTextAlignmentCenter;
                    self.emailTextField.frame = CGRectMake(0,
                                                           0,
                                                           tableView.bounds.size.width - (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 200.0f : 100.0f),
                                                           [self.emailTextField sizeThatFits:tableView.bounds.size].height);
                    cell.accessoryView = self.emailTextField;
                    break;
                case 1:
                    cell.textLabel.text = @"Name";
					cell.textLabel.textAlignment = NSTextAlignmentCenter;
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
            [self.subscribeButton setTitle:@"Submit" forState:UIControlStateNormal];
            
            if (self.settings) {
                if ([self.settings.submitButtonCustomImage length] > 0) {
                    UIImage *submitButtonImage = [UIImage imageNamed:self.settings.submitButtonCustomImage];
                    [self.subscribeButton setImage:submitButtonImage forState:UIControlStateNormal];
                    
                    // Center button within cell bounds.
                    self.subscribeButton.frame = CGRectMake(((tableView.frame.size.width - submitButtonImage.size.width) / 2),
                                                            0, submitButtonImage.size.width, submitButtonImage.size.height);
                    
                } else {
                    if ([self.settings.submitButtonText length] > 0) {
                        [self.subscribeButton setTitle:self.settings.submitButtonText forState:UIControlStateNormal];
                    }
                    
                    [self setSubscribeButtonStyleForTableView:tableView];
                }
            } else {
                [self setSubscribeButtonStyleForTableView:tableView];
            }
            
			[self.subscribeButton addTarget:self action:@selector(subscribe) forControlEvents:UIControlEventTouchUpInside];
			[cell addSubview:self.subscribeButton];
            
            cell.backgroundColor = [UIColor clearColor];
            cell.backgroundView = [[UIView alloc] initWithFrame:CGRectZero];
            [self updateChrome];
            break;
        }
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    CGFloat marginPad = kNewsletterSectionMarginPad;
    CGFloat marginPhone35 = kNewsletterSectionMarginPhone35;
    CGFloat marginPhone4 = kNewsletterSectionMarginPhone4;
    
    switch (section) {
        case TableViewTitleSection:
            
            marginPad = kNewsletterTitleTopMarginPad;
            marginPhone35 = kNewsletterTitleTopMarginPhone35;
            marginPhone4 = kNewsletterTitleTopMarginPhone4;
            
            if (self.settings) {
                
                if (self.settings.titleTopMarginPad) {
                    marginPad = [self.settings.titleTopMarginPad floatValue];
                }
                if (self.settings.titleTopMarginPhone4) {
                    marginPhone4 = [self.settings.titleTopMarginPhone4 floatValue];
                }
                if (self.settings.titleTopMarginPhone35) {
                    marginPhone35 = [self.settings.titleTopMarginPhone35 floatValue];
                }
            }
            
            break;
        case TableViewCopySection:
            
            if (self.settings) {
                
                if (self.settings.titleCopyMarginPad) {
                    marginPad = [self.settings.titleCopyMarginPad floatValue];
                }
                if (self.settings.titleCopyMarginPhone4) {
                    marginPhone4 = [self.settings.titleCopyMarginPhone4 floatValue];
                }
                if (self.settings.titleCopyMarginPhone35) {
                    marginPhone35 = [self.settings.titleCopyMarginPhone35 floatValue];
                }
            }
            
            break;
        case TableViewFormSection:
            
            if (self.settings) {
                
                if (self.settings.copyFormMarginPad) {
                    marginPad = [self.settings.copyFormMarginPad floatValue];
                }
                if (self.settings.copyFormMarginPhone4) {
                    marginPhone4 = [self.settings.copyFormMarginPhone4 floatValue];
                }
                if (self.settings.copyFormMarginPhone35) {
                    marginPhone35 = [self.settings.copyFormMarginPhone35 floatValue];
                }
            }
            
            break;
        case TableViewSubmitButtonSection:
            
            if (self.settings) {
                
                if (self.settings.formButtonMarginPad) {
                    marginPad = [self.settings.formButtonMarginPad floatValue];
                }
                if (self.settings.formButtonMarginPhone4) {
                    marginPhone4 = [self.settings.formButtonMarginPhone4 floatValue];
                }
                if (self.settings.formButtonMarginPhone35) {
                    marginPhone35 = [self.settings.formButtonMarginPhone35 floatValue];
                }
            }
            
            break;
    }
    
    return (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? marginPad : (IS_IPHONE_5) ? marginPhone4 : marginPhone35;
    
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = [UIView new];
    view.backgroundColor = [UIColor clearColor];
    return view;
}

- (void)setSubscribeButtonStyleForTableView:(UITableView *)tableView {
    
    if (self.settings) {
        if ([self.settings.submitButtonColorHex length] > 0) {
            self.subscribeButton.backgroundColor = [LSNewsletterInvite colorFromHexString:self.settings.submitButtonColorHex];
        } else {
            self.subscribeButton.backgroundColor = [LSNewsletterInvite colorFromHexString:kNewsletterInviteSubmitButtonColor];
        }
    }
    
    CGFloat width = kNewsletterInviteSubmitButtonWidth;
    CGFloat height = kNewsletterInviteSubmitButtonHeight;
    
    if (self.settings) {
        if (self.settings.submitButtonWidth > 0) {
            width = self.settings.submitButtonWidth;
        }
        if (self.settings.submitButtonHeight > 0) {
            height = self.settings.submitButtonHeight;
        }
    }
    
    // Center button within cell bounds.
    self.subscribeButton.frame = CGRectMake(((tableView.frame.size.width - width) / 2),
                                            0, width, height);
    
    if (self.settings) {
        if (!self.settings.roundedCornersOff) {
            if (self.settings.roundedCornerRadius > 0) {
                self.subscribeButton.layer.cornerRadius = self.settings.roundedCornerRadius;
            } else {
                self.subscribeButton.layer.cornerRadius = 6; // if you like rounded corners
            }
        }
    } else {
        self.subscribeButton.layer.cornerRadius = 6; // if you like rounded corners
    }
    
}

#pragma mark - Rotation Methods

- (CGRect)tableViewFrameForInterfaceOrientation:(UIInterfaceOrientation)orientation {
    
    CGFloat tableViewWidthRatioPad = kNewsletterTableViewWidthRatioPad;
    CGFloat tableViewWidthRatioPhone = kNewsletterTableViewWidthRatioPhone;
    
    if (self.settings) {
        if (self.settings.viewWidthRatioPad) {
            tableViewWidthRatioPad = self.settings.viewWidthRatioPad;
        }
        if (self.settings.viewWidthRatioPhone) {
            tableViewWidthRatioPhone = self.settings.viewWidthRatioPhone;
        }
    }
    
    CGFloat widthRatio = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? tableViewWidthRatioPad : tableViewWidthRatioPhone;
    return CGRectMake((1-widthRatio) * self.view.bounds.size.width / 2, 0, widthRatio * self.view.bounds.size.width, self.view.bounds.size.height);
}

- (UIView *)viewBackgroundViewForInterfaceOrientation:(UIInterfaceOrientation)orientation {
    
    NSString *customInviteImageName = nil;
    
    if (self.settings) {
        if ([self.settings.inviteCustomImageName length] > 0) {
            customInviteImageName = self.settings.inviteCustomImageName;
        }
    }
    
    UIView *backgroundView = [[UIView alloc] initWithFrame:self.tableView.frame];
    
    if ([customInviteImageName length] > 0) {
        UIImage *customInviteImage = [UIImage imageNamed:customInviteImageName];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:customInviteImage];
        imageView.frame = CGRectMake((self.tableView.frame.size.width - customInviteImage.size.width)/2, 0, customInviteImage.size.width, customInviteImage.size.height);
        
        backgroundView.backgroundColor = [UIColor clearColor];
        [self.tableView setBackgroundView:backgroundView];
        
        [self.tableView.backgroundView addSubview:imageView];
    } else {
        backgroundView.backgroundColor = [UIColor whiteColor];
        
        if (self.settings) {
            if (!self.settings.roundedCornersOff) {
                if (self.settings.roundedCornerRadius > 0) {
                    backgroundView.layer.cornerRadius = self.settings.roundedCornerRadius;
                } else {
                    backgroundView.layer.cornerRadius = 6; // if you like rounded corners
                }
            }
        } else {
            backgroundView.layer.cornerRadius = 6; // if you like rounded corners
        }
    }
    
    return backgroundView;
    
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    
    UIView *rootView = UIApplication.sharedApplication.delegate.window.rootViewController.view;
    CGRect viewFrame;
    viewFrame = CGRectMake(0, 0, rootView.bounds.size.width, rootView.bounds.size.height);
    
    self.view.frame = viewFrame;
    self.coverView.frame = viewFrame;
    self.dismissButton.frame = viewFrame;
    
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    
    CGRect frame = [self tableViewFrameForInterfaceOrientation:orientation];
    self.tableView.frame = frame;
    self.tableView.backgroundView = [self viewBackgroundViewForInterfaceOrientation:orientation];
    [self.tableView reloadData];
    
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    
    CGFloat statusHeight = 0;
    if (![UIApplication sharedApplication].statusBarHidden) {
        statusHeight = 20;
    }
    
    UIView *rootView = UIApplication.sharedApplication.delegate.window.rootViewController.view;
    CGRect viewFrame;
    
    CGFloat longestSide = MAX(rootView.bounds.size.height, rootView.bounds.size.width);
    viewFrame = CGRectMake(0, 0, longestSide + statusHeight, longestSide + statusHeight);
    
    self.view.frame = viewFrame;
    self.coverView.frame = viewFrame;
    
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
        
        UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
        CGFloat requiredSpace;
        if (UIInterfaceOrientationIsLandscape(orientation)) {
            requiredSpace = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? 140 : (IS_IPHONE_5) ? 90 : 90;
        } else {
            requiredSpace = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? 520 : (IS_IPHONE_5) ? 195 : 140;
        }
        
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
        
        CGFloat topMarginPhone35 = kNewsletterInviteTopMarginPhone35;
        CGFloat topMarginPhone4 = kNewsletterInviteTopMarginPhone4;
        
        if (self.settings) {
            if (self.settings.topMarginPhone35 > 0) {
                topMarginPhone35 = self.settings.topMarginPhone35;
            }
            if (self.settings.topMarginPhone4 > 0) {
                topMarginPhone4 = self.settings.topMarginPhone4;
            }
        }
        CGFloat topMargin;
        
        UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
        if (UIInterfaceOrientationIsLandscape(orientation)) {
            topMargin = (self.view.frame.size.height - self.tableView.frame.size.height) / 2;
        } else {
            topMargin = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? (self.view.frame.size.height - self.tableView.frame.size.height) / 2 : (IS_IPHONE_5) ? topMarginPhone4 : topMarginPhone35;
        }
        
        self.tableView.frame = CGRectMake(self.tableView.frame.origin.x, topMargin, self.tableView.frame.size.width, self.tableView.frame.size.height);
        
    }];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.emailTextField) {
        [self.nameTextField becomeFirstResponder];
    } else if (textField == self.nameTextField) {
        
        // The return button on the text fields will cycle through name and email until the string in the email textfield is an email, then it will submit.
        [self.nameTextField resignFirstResponder];
        
        if (self.subscribeButton.enabled) {
            [self subscribe];
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
    
	// Try to get MailChip values from settings object.
    NSString *mailChimpAPIKey = self.settings.mailchimpAPIKey;
    NSString *mailChimpListIDKey = self.settings.mailchimpListIDKey;
    NSArray *mailChimpGroups = self.settings.mailchimpGroups;
	
	// If the MailChimp values were not found in settings, try to get them from the main bundle's info dictionary.
	NSDictionary* mailChimpInfo = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"MailChimp"];
	if (mailChimpInfo) {
		if (!mailChimpAPIKey) {
			mailChimpAPIKey = [mailChimpInfo objectForKey:@"MailChimpAPIKey"];
		}
		if (!mailChimpListIDKey) {
			mailChimpListIDKey = [mailChimpInfo objectForKey:@"MailChimpListID"];
		}
		if (!mailChimpGroups) {
			mailChimpGroups = [mailChimpInfo objectForKey:@"MailChimpGroups"];
		}
	}
    
    BOOL mailChimpDoubleOptIn = kNewsletterMailchimpDoubleOptIn;
    if (self.settings) {
        mailChimpDoubleOptIn = self.settings.mailchimpDoubleOptIn;
    }
    
    [SVProgressHUD showWithStatus:@"Subscribing" maskType:SVProgressHUDMaskTypeClear];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setValue:mailChimpListIDKey forKey:@"id"];
    
    NSString *email = [self.emailTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    [params setValue:@{@"email":email} forKey:@"email"];
    
    [params setValue:@"false" forKey:@"replace_interests"];
    [params setValue:@"true" forKey:@"update_existing"];
    
    NSMutableDictionary *mergeVars = [NSMutableDictionary dictionary];
    NSString *name = self.nameTextField.text;
    if ([name length] > 0) {
        [mergeVars setValue:name forKey:@"FNAME"];
    }
    
    // If your NewsletterMailChimpGroup is set to @"" it will skip this section. You can group your email signups by app which allows for more control over your mailing schedules. This is not important to some developers.
    
    if ([mailChimpGroups count] > 0) {
        NSArray *groupings = [NSArray arrayWithArray:mailChimpGroups];
        [mergeVars setValue:groupings forKey:@"GROUPINGS"];
    }
    
    [params setValue:[NSNumber numberWithBool:mailChimpDoubleOptIn] forKey:@"double_optin"];
    [params setValue:mergeVars forKey:@"merge_vars"];
    
    ChimpKit *ck = [ChimpKit sharedKit];
    [ck callApiMethod:@"lists/subscribe" withApiKey:mailChimpAPIKey params:params andDelegate:self];
    
}

#pragma mark ChimpKitDelegate

- (void)ckRequestSucceeded:(ChimpKitRequest *)aRequest {
    
    [SVProgressHUD showSuccessWithStatus:@"Subscribed"];
    
    if (_delegate) {
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

- (void)ckRequestFailed:(ChimpKitRequest *)aRequest andError:(NSError *)anError {
    [SVProgressHUD showErrorWithStatus:@"Failed"];
}

- (void)dismiss {
    
    [self.view endEditing:YES];
    
    if (_delegate) {
        if ([_delegate respondsToSelector:@selector(newsletterInviteDidCancel:)]) {
            [_delegate newsletterInviteDidCancel:self];
        } else {
            [self.delegate newsletterInviteDidFinish:self];
        }
    } else {
        [self.viewController dismissNewsletterInvite:self];
    }
    
}

+ (UIColor *)colorFromHexString:(NSString *)hexString {
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}

@end

@implementation UIViewController (PopupViewController)

- (void)presentNewsletterInvite:(LSNewsletterInvite *)newsletterInvite {
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
	
    [UIView animateWithDuration:0.6 animations:^{
        
        modalView.frame = viewFrame;
        coverView.alpha = 1.0;
        
    }];
    
}

- (void)dismissNewsletterInvite:(LSNewsletterInvite*)newsletterInvite {
	UIView* modalView = newsletterInvite.view;
	UIView* coverView = newsletterInvite.coverView;
    
    [UIView animateWithDuration:0.6 animations:^{
        
        modalView.center = self.offscreenCenter;
        coverView.alpha = 0.0f;
        
    } completion:^(BOOL finished) {
        
        [coverView removeFromSuperview];
        [modalView removeFromSuperview];
        [newsletterInvite removeFromParentViewController];
        
    }];
    
}

- (CGPoint) offscreenCenter {
    CGPoint offScreenCenter = CGPointZero;
    
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    CGSize offSize = UIScreen.mainScreen.bounds.size;
    
	if (orientation == UIInterfaceOrientationLandscapeLeft || orientation == UIInterfaceOrientationLandscapeRight) {
		offScreenCenter = CGPointMake(offSize.height / 2.0, offSize.width * 1.5);
	} else {
		offScreenCenter = CGPointMake(offSize.width / 2.0, offSize.height * 1.5);
	}
    
    return offScreenCenter;
}


@end
