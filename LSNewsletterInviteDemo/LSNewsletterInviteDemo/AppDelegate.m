//
//  AppDelegate.m
//  LSNewsletterInvite
//
//  Copyright (c) 2013 LearnStack. All rights reserved.
//

#import "AppDelegate.h"
#import "DemoViewController.h"
#import "LSNewsletterInviteSettings.h"
#import "LSNewsletterInvite.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.

    DemoViewController *demoViewController = [[DemoViewController alloc] init];
    self.window.rootViewController = demoViewController;
    
    /*
     You can update the settings from here without changing the code.
     */
    
    LSNewsletterInviteSettings * settings = [[LSNewsletterInviteSettings alloc] init];
    
    /*
     You can use this single line implementation and it will track invite and launch count for you.
     */

    [LSNewsletterInvite appLaunched:YES viewController:demoViewController andSettings:settings];

    [self.window makeKeyAndVisible];
    return YES;
}

@end
