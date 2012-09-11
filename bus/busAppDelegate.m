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
@synthesize memory;
@synthesize waitime_URL;
@synthesize backGround_updateNotification;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
     NSLog(@"%@", [NSThread currentThread]);
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
  NSArray *notificationArray = [[UIApplication sharedApplication]  scheduledLocalNotifications];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        while(1){
            dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [self updateNotification:notificationArray];
                sleep(30);
            });
        }
    });

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



-(void)updateNotification:(NSArray *)notificationArray{
    
    if (notificationArray == nil || notificationArray.count ==0) return;
  
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDirectory, YES);
    NSString *filePath = [paths objectAtIndex:0];
    filePath = [filePath stringByAppendingString:@"/database.plist"];
    memory = [[NSMutableDictionary alloc] initWithContentsOfFile:filePath];
    waitime_URL = [NSMutableString new];
        for (UILocalNotification *notifiction in notificationArray){
            NSString* query_StopName = [notifiction.userInfo objectForKey:StopNameKey];
            NSString* query_RouteName = [notifiction.userInfo objectForKey:RouteNameKey];
            NSArray *infoArray = [memory objectForKey:query_StopName];
            NSIndexSet* route_Index =  [infoArray indexesOfObjectsPassingTest:
                                        ^BOOL(id obj, NSUInteger idx, BOOL *stop) {
                                            if ( [query_RouteName isEqualToString:obj] ) return true;
                                            else return false;
                                        }];
            waitime_URL = [infoArray objectAtIndex:[route_Index firstIndex] +1];
            NSLog(@"\n==========================================\n");
            NSLog(@"%@,%@" , query_StopName,query_RouteName);
            NSLog(@"%@",[infoArray objectAtIndex:[route_Index firstIndex]]);
            NSLog(@"%@",waitime_URL);
            
          __block  bool busdidReach = false;
          __block  NSError *error;
            __block  NSData* data  = [NSData new];
            UInt32 big5 = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingBig5);
            dispatch_queue_t updateQueue= dispatch_queue_create("URLDataUpdate", nil);
            dispatch_sync(updateQueue, ^{  
            data= [[NSString stringWithContentsOfURL: [NSURL URLWithString:waitime_URL ] encoding:big5 error:&error] dataUsingEncoding:big5];
            if (!data)
            {
                busdidReach = false;
            }
            
            TFHpple* parser = [[TFHpple alloc] initWithHTMLData:data];
            NSArray *waittime  = [parser searchWithXPathQuery:@"//body//div//table//tr//td"]; // get the title
            TFHppleElement* T_ptr2 = [waittime objectAtIndex:2];
            NSArray *child2 = [T_ptr2 children];
            TFHppleElement* buf2 = [child2 objectAtIndex:0];
            NSString* result2 = [buf2 content];
            
            NSString *pureNumbers = [[result2 componentsSeparatedByCharactersInSet:[[NSCharacterSet characterSetWithCharactersInString:@"0123456789"] invertedSet]] componentsJoinedByString:@""];
            if ([pureNumbers intValue] == 0){
                NSLog(@"%@,%@",[notifiction.userInfo objectForKey:StopNameKey],[notifiction.userInfo objectForKey:RouteNameKey]);
                NSLog(@"%@",result2);
                if ([result2 isEqualToString:@"即將進站..."]) busdidReach = true;
                else busdidReach = false;
            }
                
           // [notifiction.fireDate initWithTimeIntervalSinceNow: [pureNumbers intValue]*60];
                [[UIApplication sharedApplication] cancelLocalNotification:notifiction];
                UILocalNotification *temp = [[UILocalNotification alloc]init];
                temp.fireDate =  [NSDate dateWithTimeIntervalSinceNow: [pureNumbers intValue]*60] ;
                temp.timeZone = [NSTimeZone localTimeZone]; temp.soundName = UILocalNotificationDefaultSoundName;
                temp.applicationIconBadgeNumber = 1;
                temp.userInfo = [NSDictionary dictionaryWithObjectsAndKeys:[notifiction.userInfo objectForKey:RouteNameKey],RouteNameKey,[notifiction.userInfo objectForKey:StopNameKey],StopNameKey, nil];
                temp.alertBody = [NSString stringWithFormat:@"%@\n%@\n即將到站.....",[temp.userInfo objectForKey:RouteNameKey],[temp.userInfo objectForKey:StopNameKey]];
                [[UIApplication sharedApplication] scheduleLocalNotification:temp];
                [temp release];

                
            NSLog(@"delay: %u",[pureNumbers intValue]*60);
            NSLog(@"update firedate:%@",notifiction.fireDate);
            NSLog(@"%@",result2);
            NSLog(@"\n==========================================\n");
            busdidReach = false;
            
           });
            if( busdidReach ) {

                [[UIApplication sharedApplication] cancelLocalNotification:notifiction];
                UILocalNotification *temp = [[UILocalNotification alloc]init];
                temp.fireDate =  [NSDate dateWithTimeIntervalSinceNow:5] ;
                temp.timeZone = [NSTimeZone localTimeZone]; temp.soundName = UILocalNotificationDefaultSoundName;
                temp.applicationIconBadgeNumber = 1;
                temp.userInfo = [NSDictionary dictionaryWithObjectsAndKeys:[notifiction.userInfo objectForKey:RouteNameKey],RouteNameKey,[notifiction.userInfo objectForKey:StopNameKey],StopNameKey, nil];
                temp.alertBody = [NSString stringWithFormat:@"%@\n%@\n即將到站.....",[temp.userInfo objectForKey:RouteNameKey],[temp.userInfo objectForKey:StopNameKey]];
                [[UIApplication sharedApplication] scheduleLocalNotification:temp];
                [temp release];
                NSLog(@"%@",[NSDate date]);
                NSLog(@"%@",notifiction.fireDate);
                break;
            }
               
        }
                          
    }
    


- (void)applicationDidEnterBackground:(UIApplication *)application
{
    NSLog(@"did enter background");
    NSArray *notificationArray = [[UIApplication sharedApplication]  scheduledLocalNotifications];
    UIApplication*    app = [UIApplication sharedApplication];
    UIBackgroundTaskIdentifier bgTask;
    bgTask = [app beginBackgroundTaskWithExpirationHandler:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                while(1){
                    dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                        [self updateNotification:notificationArray];
                        sleep(30);
                    });
                }
            });
        });
    }];

}

-(void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification{
    NSLog(@"//////////////enter receivelocalnotifiction////////////////\n ");
    NSLog(@"%@",notification.fireDate);
    NSLog(@"%@,%@",[notification.userInfo objectForKey:StopNameKey],[notification.userInfo objectForKey:RouteNameKey]);
    NSMutableDictionary *favoriteDictionary = [[[NSUserDefaults standardUserDefaults] objectForKey:AlarmUserDefaultKey] mutableCopy];
    NSMutableArray* temp = [[favoriteDictionary objectForKey:[notification.userInfo objectForKey:StopNameKey]] mutableCopy];
    NSInteger index = [temp indexOfObject:[notification.userInfo objectForKey:RouteNameKey]];
    
    if ( ([UIApplication sharedApplication].applicationState == UIApplicationStateBackground) ||
        ([UIApplication sharedApplication].applicationState == UIApplicationStateInactive)      ) {
        
        
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
    [favoriteDictionary removeAllObjects];
    [[NSUserDefaults standardUserDefaults] setObject:favoriteDictionary forKey:AlarmUserDefaultKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}



- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */

    NSLog(@"%@",[NSThread currentThread]);
    [backGround_updateNotification cancel];
    backGround_updateNotification =nil;
    [backGround_updateNotification cancel];
    application.applicationIconBadgeNumber = 0;
   // [application cancelAllLocalNotifications];
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
