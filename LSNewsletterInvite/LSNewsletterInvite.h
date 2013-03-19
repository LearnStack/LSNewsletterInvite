//
//  LSNewsletterInvite.h
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

#import <UIKit/UIKit.h>

/*
 Your Mailchimp Keys and IDs. If you leave the Group blank, it will not attempt to push to a group. If you
 update the mailchimp group, it will add group and groupname to the merge_vars dictionary
*/

#define NewsletterMailchimpKey @""
#define NewsletterMailchimpListId @""

// This one always gives grief. Make sure the group name is the top level grouping.

#define NewsletterMailchimpGroupName @""
#define NewsletterMailchimpGroup @""

// This allows you to disable Double Opt In, so they don't have to confirm that they really signed up

#define NewsletterMailchimpDoubleOptIn NO

/*
 The title of your invite, including font sizes for iPhone and iPad

 You can also use a custom image for your title view. If there is a custom image, it will not use the title text.
 */


#define NewsletterInviteTitle @"Sign Up Today!"
#define NewsletterInviteTitleCustomImage @""

#define NewsletterInviteTitleFontSizePad 42
#define NewsletterInviteTitleFontSizePhone 24

/*
 LSNewsletterInvite allows for two lines of copy with different font sizes and text. If either line is left blank
 it will simply give that row a height of 0.

 The first line of copy text, including font sizes for iPhone and iPad
*/

#define NewsletterInviteFirstCopy @""
#define NewsletterInviteFirstCopyCustomImage @""

#define NewsletterInviteFirstCopyFontSizePad 32
#define NewsletterInviteFirstCopyFontSizePhone 14

/*
 The second line of copy text, including font sizes for iPhone and iPad
 */

#define NewsletterInviteSecondCopy @"We'd love to stay in touch for support, give you tips for our apps and offers on the latest and greatest app on the app store."
#define NewsletterInviteSecondCopyCustomImage @""

#define NewsletterInviteSecondCopyFontSizePad 30
#define NewsletterInviteSecondCopyFontSizePhone 14

/*
 You can customize the margin between the copy and the form for iPhone and iPad
 */

#define NewsletterCopyFormMarginPad 60
#define NewsletterCopyFormMarginPhone35 0
#define NewsletterCopyFormMarginPhone4 0

/*
 You can customize the view with an invite image that will sit behind the table view (a sample image is included)
 You can also customize the background cover view image (this is a view that sits behind the invite. 
 */

#define NewsletterInviteBackgroundCustomImageName @"newsletter_background_custom_sample"
#define NewsletterInviteCustomImageName @"newsletter_invite_custom_sample"

/*
  The width of the table view is dependant on you. You can make it the full width of the view, or a portion. 
 The dismiss button is behind the table view. If you make the table view the full width, you will be effectively
 disabling the dismiss button.
*/

#define NewsletterTableViewWidthRatioPad 0.75
#define NewsletterTableViewWidthRatioPhone 0.90

/*
 The top margin for the iPhone and iPad. This will set how far down from the top of the screenthe invite title will start
 */

#define NewsletterInviteTopMarginPad 150
#define NewsletterInviteTopMarginPhone35 50
#define NewsletterInviteTopMarginPhone4 75

/*
 You can set the required launch count for the invite to be presented. I prefer to display it after the first launch.
 However, if you have something like OpenFeint/Gree in the app, you may want to display it on the second launch so that 
 the user doesn't get overwhelmed.
 */

#define NewsletterInviteAfterLaunchCount 0

/*
 You can set the invite count, as long as you call appLaunched it will count the number of times they have dismissed
 the invite rather than accepting it. If they haven't reached this count, it will display the invite again.
 */

#define NewsletterInviteCount 2

/* 
 You can also make it so they cannot dismiss the invite, but must subscribe. This is not recommended as it breaks
 MailChimp and Spam rules.
 */

#define NewsletterInviteAllowCancel YES

/*
 This is the notification key that is posted when a user subscribes to the newsletter. 
 The user data of the notification includes the email and name provided by the user at signup.
 */

static NSString * const kLSNewsletterInviteSuccessfulSignupNotificationKey = @"LSNewlsetterInviteSuccessfulSignupNotification";

static NSString * const kEmailKey = @"email";
static NSString * const kNameKey = @"name";

/*
 The delegate is optional.
 
 If the delegate is set LSNewsletterInvite will not dismiss itself. It will rely on the delegate calls.
 If the delegate is not set, it will dismiss itself from the viewController that presented it.
 
 If you want to give the user a different experience if they sign up and if they cancel the invite you'll
 want to set up the delegate calls for Cancel and Finish.
 */

@protocol LSNewsletterInviteDelegate;

@interface LSNewsletterInvite : UIViewController 

@property (nonatomic, assign) id<LSNewsletterInviteDelegate> delegate;
@property (nonatomic, strong) UIViewController *viewController;

/*
 This is the single line of code you need to call. This will initialize a NewsletterInvite and check to see if
 presentation conditions are met. If they are, it will present it 
 */

+ (void)appLaunched:(BOOL)canPromptForNewsletter viewController:(UIViewController*)viewController;

@end

@protocol LSNewsletterInviteDelegate <NSObject>

- (void)newsletterInviteDidFinish:(LSNewsletterInvite *)newsletterInvite;
@optional
- (void)newsletterInviteDidCancel:(LSNewsletterInvite *)newsletterInvite;

@end

/*
 LSNewsletterInvite uses a UIViewController category to be presented. Calling the present method will slide
 the newsletterInvite in over the view, and slowly animate the background cover from 0-50% opacity.
 
 Calling the dismiss method will do the reverse.
 */

@interface UIViewController (NewsletterInvite)

-(void)presentNewsletterInvite:(LSNewsletterInvite*)newsletterInvite;
-(void)dismissNewsletterInvite:(LSNewsletterInvite*)newsletterInvite;

@end




