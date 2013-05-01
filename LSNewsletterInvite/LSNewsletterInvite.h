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
 This is the notification key that is posted when a user subscribes to the newsletter.
 The user data of the notification includes the email and name provided by the user at signup.
 */

static NSString * const kLSNewsletterInviteSuccessfulSignupNotificationKey = @"LSNewlsetterInviteSuccessfulSignupNotification";

static NSString * const kEmailKey = @"email";
static NSString * const kNameKey = @"name";

/*
 The settings are optional.
 
 If the settings are set, it will allow you to override layout settings and change the default values of
 view sizes.
 */

@class LSNewsletterInviteSettings;
@protocol LSNewsletterInviteDelegate;

@interface LSNewsletterInvite : UIViewController 

@property (nonatomic, assign) id<LSNewsletterInviteDelegate> delegate;
@property (nonatomic, strong) LSNewsletterInviteSettings *settings;
@property (nonatomic, strong) UIViewController *viewController;

/*
 This is the single line of code you need to call. This will initialize a NewsletterInvite and check to see if
 presentation conditions are met. If they are, it will present it
 */

+ (void)appLaunched:(BOOL)canPromptForNewsletter viewController:(UIViewController*)viewController andSettings:(LSNewsletterInviteSettings *)settings;

@end

/*
 The delegate is optional.
 
 If the delegate is set LSNewsletterInvite will not dismiss itself. It will rely on the delegate calls.
 If the delegate is not set, it will dismiss itself from the viewController that presented it.
 
 If you want to give the user a different experience if they sign up and if they cancel the invite you'll
 want to set up the delegate calls for Cancel and Finish.
 */

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




