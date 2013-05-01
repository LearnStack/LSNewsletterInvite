//
//  LSNewsletterInviteSettings.h
//  LSNewsletterInviteDemo
//
//  Created by Joshua Howland on 5/1/13.
//  Copyright (c) 2013 LearnStack. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LSNewsletterInviteSettings : NSDictionary


// This allows you to disable Double Opt In, so they don't have to confirm that they really signed up

@property (nonatomic, assign) BOOL mailchimpDoubleOptIn;

/*
 The title of your invite, font sizes for iPhone and iPad are included in the settings file
 
 You can also use a custom image for your title view. If there is a custom image, it will not use the title text.
 */

@property (nonatomic, strong) NSString *title;
@property (nonatomic, assign) CGFloat titleFontSizePad;
@property (nonatomic, assign) CGFloat titleFontSizePhone;

/*
 LSNewsletterInvite allows for two lines of copy with different font sizes and text. If either line is left blank
 it will simply give that row a height of 0.
 
 The first line of copy text, including font sizes for iPhone and iPad
 */

@property (nonatomic, strong) NSString *firstCopy;
@property (nonatomic, assign) CGFloat firstCopyFontSizePad;
@property (nonatomic, assign) CGFloat firstCopyFontSizePhone;

/*
 The second line of copy text, including font sizes for iPhone and iPad
 */

@property (nonatomic, strong) NSString *secondCopy;
@property (nonatomic, assign) CGFloat secondCopyFontSizePad;
@property (nonatomic, assign) CGFloat secondCopyFontSizePhone;

/*
 You can customize the margin between the copy and the form for iPhone and iPad
 */

@property (nonatomic, assign) CGFloat copyFormMarginPad;
@property (nonatomic, assign) CGFloat copyFormMarginPhone35;
@property (nonatomic, assign) CGFloat copyFormMarginPhone4;

/*
 The width of the table view is dependant on you. You can make it the full width of the view, or a portion.
 The dismiss button is behind the table view. If you make the table view the full width, you will be effectively
 disabling the dismiss button.
 */

@property (nonatomic, assign) CGFloat tableViewWidthRatioPad;
@property (nonatomic, assign) CGFloat tableViewWidthRatioPhone;

/*
 The top margin for the iPhone and iPad. This will set how far down from the top of the screenthe invite title will start
 */

@property (nonatomic, assign) CGFloat topMarginPad;
@property (nonatomic, assign) CGFloat topMarginPhone35;
@property (nonatomic, assign) CGFloat topMarginPhone4;

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
