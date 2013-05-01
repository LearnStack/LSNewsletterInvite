//
//  DemoViewController.m
//  LSNewsletterInvite
//
//  Copyright (c) 2013 LearnStack. All rights reserved.
//

#import "DemoViewController.h"
#import "LSNewsletterInvite.h"
#import "LSNewsletterInviteSettings.h"

@interface DemoViewController () <LSNewsletterInviteDelegate>

@end

@implementation DemoViewController 

- (void)viewDidLoad {

    self.view.backgroundColor = [UIColor lightGrayColor];

    UIButton *presentButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    CGSize buttonSize = CGSizeMake(200, 44);
    presentButton.frame = CGRectMake((self.view.frame.size.width - buttonSize.width) / 2, 200, buttonSize.width, buttonSize.height);
    [presentButton setTitle:@"Present Invite" forState:UIControlStateNormal];
    [presentButton addTarget:self action:@selector(presentNewsletter) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:presentButton];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newsletterSignupSuccessful:) name:kLSNewsletterInviteSuccessfulSignupNotificationKey object:nil];
    
}

- (void)newsletterSignupSuccessful:(NSNotification *)notification {

}

- (void)presentNewsletter {
    
    LSNewsletterInvite * newsletterInvite = [[LSNewsletterInvite alloc] init];
    newsletterInvite.delegate = self;
    
    LSNewsletterInviteSettings * settings = [[LSNewsletterInviteSettings alloc] init];
    newsletterInvite.settings = settings;

    /* If you wanted to localize LSNewsletterInvite you could update the settings like this
     Copy the strings file from 
    
     settings.title = NSLocalizedStringFromTable(@"InviteTitle", @"LSNewsletter", nil);
     settings.firstCopy = NSLocalizedStringFromTable(@"InviteFirstCopy", @"LSNewsletter", nil);
     settings.secondCopy = NSLocalizedStringFromTable(@"InviteSecondCopy", @"LSNewsletter", nil);
     
     */
    
    [self presentNewsletterInvite:newsletterInvite];

}

- (void)newsletterInviteDidFinish:(LSNewsletterInvite *)newsletterInvite {
    [self dismissNewsletterInvite:newsletterInvite];
}

@end
