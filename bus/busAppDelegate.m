//
//  busAppDelegate.m
//  bus
//
//  Created by mac_hero on 12/5/4.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "busAppDelegate.h"
#import "RootViewController.h"
#import "DepatureViewController.h"


@implementation busAppDelegate
@synthesize nav;
@synthesize window = _window;
@synthesize viewController = _viewController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    UIView *backgroundView = [[UIView alloc] initWithFrame: _window.frame];
    backgroundView.alpha = 0.7f;
    backgroundView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"BGP.png"]];
    [_window addSubview:backgroundView];
    [backgroundView release];
    
    RootViewController *root = [[RootViewController alloc] initWithStyle:UITableViewStyleGrouped];
    root.view.backgroundColor = [UIColor clearColor];
    
   
    nav = [UINavigationController new];
    root.title = @"公車導航系統";
    [nav pushViewController:root animated:NO];
    [root release];
    self.window.rootViewController = nav;
    [nav release];
  //  root.view.backgroundColor = [UIColor clearColor];
    [self.window makeKeyAndVisible];
    
    UILocalNotification *localNotif = [launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
    if (localNotif)
    {
        NSLog(@"Recieved Notification %@",localNotif);
        NSDictionary* infoDic = localNotif.userInfo;
        NSLog(@"userInfo description=%@",[infoDic description]);
    }
    
    BOOL success;
    NSError *error;
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filePath = [documentsDirectory stringByAppendingString:@"/database.plist"];
    
    success = [fileManager fileExistsAtPath:filePath];
    if (success) return YES;
    
    NSString *path = [[[NSBundle mainBundle] resourcePath] stringByAppendingFormat:@"/database.plist"];
    success = [fileManager copyItemAtPath:path toPath:filePath error:&error];
    
    if (!success) {
        NSAssert1(0, @"Failed to copy Plist. Error %@", [error localizedDescription]);
    }
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

-(void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification{
    NSMutableDictionary *favoriteDictionary = [[[NSUserDefaults standardUserDefaults] objectForKey:AlarmUserDefaultKey] mutableCopy];
    NSMutableArray* temp = [[favoriteDictionary objectForKey:[notification.userInfo objectForKey:StopNameKey]] mutableCopy];
    NSInteger index = [temp indexOfObject:[notification.userInfo objectForKey:RouteNameKey]];
    
    if ( ([UIApplication sharedApplication].applicationState == UIApplicationStateBackground) ||
        ([UIApplication sharedApplication].applicationState == UIApplicationStateInactive)      ) {
        // isInBackground = YES;
        //  ------ UI not available
    }
    else {
        UIAlertView* alert = [[UIAlertView alloc]
                              initWithTitle:nil message:[NSString stringWithFormat:@"%@\n%@\n即將到站.....",[notification.userInfo objectForKey:RouteNameKey],[notification.userInfo objectForKey:StopNameKey]]
                              delegate:nil cancelButtonTitle:@"確定"
                              otherButtonTitles: nil];
        [alert show];
        application.applicationIconBadgeNumber = 0;
        [application cancelAllLocalNotifications];
    }
    if ([self.nav.topViewController isKindOfClass:[DepatureViewController class]]) {
        UITableViewController* firstLevelViewController =(UITableViewController* )self.nav.topViewController;
        [firstLevelViewController.tableView reloadData];
    }
    else{
        DepatureViewController *detail = [DepatureViewController new];
        detail.title = @"站牌資訊";
        [detail getURL:[[[[temp objectAtIndex:index+1] componentsSeparatedByString:@"&"] objectAtIndex:0] stringByReplacingOccurrencesOfString:@"result" withString:@"stop"] andRoute:[temp objectAtIndex:index] andCorrect:NO];
        [self.nav pushViewController:detail animated:NO];
        [detail release];
    }
    
    if (index==NSNotFound) {
        return;
    }
    [temp removeObjectAtIndex:index];
    [temp removeObjectAtIndex:index];
    [favoriteDictionary setObject:temp forKey:[notification.userInfo objectForKey:StopNameKey]];
    [[NSUserDefaults standardUserDefaults] setObject:favoriteDictionary forKey:AlarmUserDefaultKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}



- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
    application.applicationIconBadgeNumber = 0;
    [application cancelAllLocalNotifications];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}

- (void)dealloc
{
    [_window release];
    [_viewController release];
    [super dealloc];
}

@end
