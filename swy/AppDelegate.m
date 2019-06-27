//
//  AppDelegate.m
//  swy
//
//  Created by panyuwen on 2019/5/8.
//  Copyright © 2019 panyuwen. All rights reserved.
//

#import "AppDelegate.h"
#import "customerListViewController.h"
#import "launchViewController.h"
#import "settingViewController.h"
#import "swyManage.h"

@interface AppDelegate ()<NSURLSessionTaskDelegate>

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    // Override point for customization after application launch.
    //设置ua
    NSDictionary *dictionnary = [[NSDictionary alloc] initWithObjectsAndKeys:@"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_14_0) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/74.0.3729.169 Safari/537.36", @"UserAgent", nil];
    [[NSUserDefaults standardUserDefaults] registerDefaults:dictionnary];
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];

    UIViewController * center = [[UINavigationController alloc] initWithRootViewController:[[customerListViewController alloc] init]];
    UIViewController * rightDrawer = [[UINavigationController alloc] initWithRootViewController:[[settingViewController alloc] init]];
    
    [swyManage manage].drawerController = [[MMDrawerController alloc]
                                             initWithCenterViewController:center
                                             leftDrawerViewController:nil
                                             rightDrawerViewController:rightDrawer];
    [swyManage manage].drawerController.openDrawerGestureModeMask = MMOpenDrawerGestureModeAll;
    [swyManage manage].drawerController.closeDrawerGestureModeMask = MMCloseDrawerGestureModeAll;
    [swyManage manage].drawerController.maximumRightDrawerWidth = 200;

    
    self.window.rootViewController = [swyManage manage].drawerController;
    [self.window makeKeyAndVisible];
    [self launchAnimation];
    return YES;
}

- (void)launchAnimation
{
    launchViewController *launchVC = [[launchViewController alloc] initWithNibName:@"launchViewController" bundle:nil];
    launchVC.view.frame = [UIScreen mainScreen].bounds;
    [[UIApplication sharedApplication].keyWindow addSubview:launchVC.view];
    [UIView animateWithDuration:0.5 delay:1.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        launchVC.view.alpha = 0;
    } completion:^(BOOL finished) {
        [launchVC.view removeFromSuperview];
    }];
}



- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
