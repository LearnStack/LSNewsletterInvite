//
//  LSNewsletterInviteSettings.h
//  LSNewsletterInviteDemo
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

#import <Foundation/Foundation.h>

@interface LSNewsletterInviteSettings : NSDictionary

/*
 You can customize the view with an invite image that will sit behind the view (a sample image is included)
 You can also customize the background cover view image (this is a view that sits behind the invite.
 */

@property (nonatomic, strong) NSString *inviteBackgroundCustomImageName;
@property (nonatomic, strong) NSString *inviteCustomImageName;

// This allows you to disable Double Opt In, so they don't have to confirm that they really signed up

@property (nonatomic, assign) BOOL mailchimpDoubleOptIn;

// If you set these programmatically, it will override the mailchimp settings stored in your Info.plist file.

@property (nonatomic, strong) NSString *mailchimpAPIKey;
@property (nonatomic, strong) NSString *mailchimpListIDKey;
@property (nonatomic, strong) NSArray *mailchimpGroups;

/*
 The title of your invite, font sizes for iPhone and iPad are included in the settings file
 
 You can also use a custom image for your title view. If there is a custom image, it will not use the title text.
 */

@property (nonatomic, strong) NSString *title;
@property (nonatomic, assign) CGFloat titleFontSizePad;
@property (nonatomic, assign) CGFloat titleFontSizePhone;

/*
 You can use a custom image for your title view. If there is a custom image, it will not use the title text.
 */

@property (nonatomic, strong) NSString *inviteTitleCustomImage;

/*
 LSNewsletterInvite allows for two lines of copy with different font sizes and text. If either line is left blank
 it will simply give that row a height of 0.
 
 The first line of copy text, including font sizes for iPhone and iPad
 */

@property (nonatomic, strong) NSString *firstCopy;
@property (nonatomic, assign) CGFloat firstCopyFontSizePad;
@property (nonatomic, assign) CGFloat firstCopyFontSizePhone;

/*
 LSNewsletterInvite allows for two lines of copy with different font sizes and text. If either line is left blank
 it will simply give that row a height of 0.
 
 The first line of copy image. If you use an image the text will not be used.
 */

@property (nonatomic, strong) NSString *firstCopyCustomImage;

/*
 The second line of copy text, including font sizes for iPhone and iPad
 */

@property (nonatomic, strong) NSString *secondCopy;
@property (nonatomic, assign) CGFloat secondCopyFontSizePad;
@property (nonatomic, assign) CGFloat secondCopyFontSizePhone;

/*
 The second line of copy image. If you use an image the text will not be used.
 */

@property (nonatomic, strong) NSString *secondCopyCustomImage;

/*
 You can customize the margin between each section of the form for iPhone and iPad
 */

@property (nonatomic, strong) NSNumber *titleTopMarginPad;
@property (nonatomic, strong) NSNumber *titleTopMarginPhone35;
@property (nonatomic, strong) NSNumber *titleTopMarginPhone4;

@property (nonatomic, strong) NSNumber *titleCopyMarginPad;
@property (nonatomic, strong) NSNumber *titleCopyMarginPhone35;
@property (nonatomic, strong) NSNumber *titleCopyMarginPhone4;

@property (nonatomic, strong) NSNumber *copyFormMarginPad;
@property (nonatomic, strong) NSNumber *copyFormMarginPhone35;
@property (nonatomic, strong) NSNumber *copyFormMarginPhone4;

@property (nonatomic, strong) NSNumber *formButtonMarginPad;
@property (nonatomic, strong) NSNumber *formButtonMarginPhone35;
@property (nonatomic, strong) NSNumber *formButtonMarginPhone4;

/* 
 
 You can customize the labels and placeholders of the form
 
 */

@property (nonatomic, strong) NSString *emailLabel;
@property (nonatomic, strong) NSString *emailPlaceholder;
@property (nonatomic, strong) NSString *nameLabel;
@property (nonatomic, strong) NSString *namePlaceholder;


/*
 You can use a custom image for your submit button. If there is a custom image, it will not use the text.
 */

@property (nonatomic, strong) NSString *submitButtonText;
@property (nonatomic, strong) NSString *submitButtonColorHex; // Include # (i.e. #999999)
@property (nonatomic, strong) NSString *submitButtonCustomImage;
@property (nonatomic, assign) CGFloat submitButtonWidth;
@property (nonatomic, assign) CGFloat submitButtonHeight;

/*
 The width of the view is dependant on you. You can make it the full width of the view, or a portion.
 The dismiss button is behind the view. If you make the view the full width, you will be effectively
 disabling the dismiss button.
 */

@property (nonatomic, assign) CGFloat viewWidthRatioPad;
@property (nonatomic, assign) CGFloat viewWidthRatioPhone;

/*
 The top margin for the iPhone. This will set how far down from the top of the screen the invite title will start.
 This setting is only used in portrait mode. In landscape mode, the view is centered.
 */

@property (nonatomic, assign) CGFloat topMarginPhone35;
@property (nonatomic, assign) CGFloat topMarginPhone4;

/*
 If you'd like to turn off rounded corners, set the bool to YES.
 This setting allows you to set a custom value for the corner radius.
 */

@property (nonatomic, assign) BOOL roundedCornersOff;
@property (nonatomic, assign) CGFloat roundedCornerRadius;

/*
 You can set the required launch count for the invite to be presented. I prefer to display it after the first launch.
 However, if you have something like GameCenter/Gree in the app, you may want to display it on the second launch so that
 the user doesn't get overwhelmed.
 */

@property (nonatomic, assign) CGFloat afterLaunchCount;


/*
 You can set the invite count, as long as you call appLaunched it will count the number of times they have dismissed
 the invite rather than accepting it. If they haven't reached this count, it will display the invite again.
 */

@property (nonatomic, assign) CGFloat inviteCount;

/*
 You can also make it so they cannot dismiss the invite, but must subscribe. This is not recommended as it breaks
 MailChimp and Spam rules.
 */

@property (nonatomic, assign) BOOL ignoreCancel;

@end
