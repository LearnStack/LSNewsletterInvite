LSNewsletterInvite
==================

LSNewsletterInvite is a simple newsletter invite popup that works with MailChimp to help you get more newsletter signups. 

You can drop LSNewsletterInvite into any iPhone or iPad app (iOS 5.0 or later) and it will give your users a simple and enticing path to sign up for your newsletter. This code is released under MIT/X11, so feel free to modify and share your changes.

What makes LSNewsletterInvite better?
=====================================

There are 3 main reasons we put together LSNewsletterInvite. Almost all of them have to do with the way developers were unintentionally making it harder to gain newsletter signups.

1. Presenting a newsletter signup **form at launch** is the single most effective way to get signups. Presenting an alert view that follows up with a newsletter form is terribly inefficient and results in far more users dismissing the chance to sign up than users subscribing. Imagine if 50-75% of your users were signing up for your newsletter rather than the 10% you're seeing now. That's what will happen with a form at launch.

2. Providing an **attractive form** makes the user feel more invited, and more likely to give you their data. LSNewsletterInvite is intended to be used to create a unique and attractive invite experience. So often, developers drop their users into a basic white and gray table view to sign up for the newsletter. Users respond so much more willingly to enticing marketing copy and images. LSNewsletterInvite allows you to add Title, Background, Invite, and Copy Images. We'll continue to share examples of how this library is used to make a more beautiful experience.

3. The **dismiss button** is un-obvious. Signing up for the newsletter shouldn't be forced. You want your users to want to get emails. However, by creating an un-obvious method of dismissal, more users are going to take the few seconds to give you their email address and name.

Let's be honest. LSNewsletterInvite is a simple wrapper around ChimpKit, it's a pretty way to present it, and takes almost as much work as using the tools ChimpKit gives you. Let's be even more honest. You're not doing the things you need to get consistent newsletter signups. Here's hoping that this tool at least gives you a nudge in the right direction.

>When you talk to your users (especially via email) they’ll become more active.
>Email your users. Frequently.
[@jkhowland](https://twitter.com/jkhowland/status/313721204282376192)

Getting Started
===============

1. Add the LSNewsletterInvite code (directory) to your project
2. Add ChimpKit and SVProgressHUD libraries to your project
3. Link your apps binary with the QuartzCore framework (this is for SVProgressHUD
4. Add your MailChimp key and List ID in the LSNewsletterInvite.h file 
5. Call `[LSNewsletterInvite appLaunched:YES viewConroller:__YOUR_VIEW_CONTROLLER__]` in your app delegates `didFinishLaunchingWithOptions:` method. The viewController is provided for the Invite to be presented.

The tool is made for easy customization. You can add custom images, as well as custom text to each of the fields.

You also have the option to manually initialize and present LSNewsletterInvite. An example of this is in the demo projected included with the library.

License
=======
Copyright 2013 [LearnStack]
This library is distributed under the terms of MIT/X11

[LearnStack]: http://learnstack.com
