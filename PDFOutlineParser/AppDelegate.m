/*
 *  AppDelegate.m
 *  PDFOutlineParser
 *
 *  Created by 弘樹 豊川 on 5/13/12.
 *  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
 */

#import "AppDelegate.h"
#import "ViewController.h"

@implementation AppDelegate

@synthesize window = _window;
@synthesize viewController = _viewController;

- (void)dealloc
{
    [_window release];
    [_viewController release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    
    ViewController *vc = [[ViewController alloc] initWithNibName:@"ViewController" bundle:nil];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    [nav.navigationBar setBarStyle:UIBarStyleBlack];
    self.window.rootViewController = nav;
    [nav release];
    [vc release];
    
    self.window.rootViewController = nav;
    
    [self.window makeKeyAndVisible];
    return YES;
}

@end
