//
//  AppDelegate.m
//  AWNavigationMenuItem
//
//  Created by Abe Wang on 2016/7/25.
//  Copyright © 2016 Abe Wang. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	ViewController *controller = [[ViewController alloc] init];
	UINavigationController *naviController = [[UINavigationController alloc] initWithRootViewController:controller];
	
	self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
	self.window.rootViewController = naviController;
	[self.window makeKeyAndVisible];
	
	return YES;
}

@end
