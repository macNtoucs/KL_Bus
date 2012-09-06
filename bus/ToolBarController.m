//
//  ToolBarController.m
//  bus
//
//  Created by mac_hero on 12/8/21.
//
//

#import "ToolBarController.h"
#import "DepatureViewController.h"
#import "SearchStopRouteViewController.h"
#import "AlertViewDelegate.h"
#import "FavoriteViewController.h"
@implementation ToolBarController
@synthesize toolbarcontroller;
@synthesize button;
@synthesize success;
@synthesize localNotif;

-(id)init{
    if (self ==[super init]) {
        
        toolbarcontroller = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 436, 320, 44)];
        
        toolbarcontroller.barStyle = UIBarButtonItemStyleBordered;
        toolbarcontroller.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    }
    UIDevice* device = [UIDevice currentDevice];
    BOOL backgroundSupported = NO;
    if ([device respondsToSelector:@selector(isMultitaskingSupported)]){
        backgroundSupported = device.multitaskingSupported;
    }
    return self;
}



-(NSString*) fixedStringBrackets : (NSString *)oldString
{
    NSString* newString = [NSString new] ;
    NSRange range = [oldString rangeOfString:@")"];
    if (range.length!=0)
        return newString = [oldString substringFromIndex:range.location+1];
    else
        return oldString;
    
}
-(UILocalNotification *)returnLocalNotifiction{
    return localNotif;

}

-(void)addNotification:(NSString *)timeData RouteName:(NSString *)RouteName andStopName:(NSString *)StopName{
    NSLog(@"//////////add notification////////////");
    localNotif = [[UILocalNotification alloc] init];
    if (localNotif == nil){
        UIAlertView* alert = [[UIAlertView alloc]
                              initWithTitle:nil message:@"\n\nError"
                              delegate:nil cancelButtonTitle:@"確定"
                              otherButtonTitles: nil];
        [alert show];
        return;
    }
    NSString *pureNumbers = [[timeData componentsSeparatedByCharactersInSet:[[NSCharacterSet characterSetWithCharactersInString:@"0123456789"] invertedSet]] componentsJoinedByString:@""];
    NSLog(@"%@,%@",timeData,pureNumbers);
    NSLog(@"%@,%@",RouteName,StopName);
    if (![pureNumbers intValue]) {
        UIAlertView* alert = [[UIAlertView alloc]
                              initWithTitle:nil message:[NSString stringWithFormat:@"%@",timeData]
                              delegate:nil cancelButtonTitle:@"確定"
                              otherButtonTitles: nil];
        [alert show];
        return;
    }
    localNotif.fireDate = [NSDate dateWithTimeIntervalSinceNow: [pureNumbers intValue]*60];
    localNotif.timeZone = [NSTimeZone localTimeZone];
    
    
    
    localNotif.soundName = UILocalNotificationDefaultSoundName;
    localNotif.applicationIconBadgeNumber = 1;
    localNotif.userInfo = [NSDictionary dictionaryWithObjectsAndKeys:RouteName,RouteNameKey,StopName,StopNameKey, nil];
    localNotif.alertBody = [NSString stringWithFormat:@"%@\n%@\n即將到站.....",[localNotif.userInfo objectForKey:RouteNameKey],[localNotif.userInfo objectForKey:StopNameKey]];
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotif];
    [localNotif release];
    UIAlertView* alert = [[UIAlertView alloc]
                          initWithTitle:nil message:[NSString stringWithFormat:@"%@\n%@\n加入通知",[localNotif.userInfo objectForKey:RouteNameKey],[localNotif.userInfo objectForKey:StopNameKey]]
                          delegate:nil cancelButtonTitle:@"確定"
                          otherButtonTitles: nil];
    [alert show];
    NSLog(@"%@",localNotif.fireDate);
    NSLog(@"//////////exit add notification////////////\n");
}

-(void)removeNotificationRouteName:(NSString *)RouteName andStopName:(NSString *)StopName{
    NSArray *notificationArray = [[UIApplication sharedApplication]  scheduledLocalNotifications];
    for (UILocalNotification *row in notificationArray) {
        if ([[row.userInfo objectForKey:RouteNameKey] isEqualToString: RouteName]&&[[row.userInfo objectForKey:StopNameKey]isEqualToString:StopName]) {
            [[UIApplication sharedApplication] cancelLocalNotification:row];
        }
    }
}

-(IBAction)SaveUserDefault:(id)sender{
    int Tag = [sender tag]%1000-1;
    int section = [sender tag]/1000;
    NSUserDefaults *prefs = [[NSUserDefaults standardUserDefaults]retain];
    NSMutableArray *favoriteData;
    NSString * fixedStringStopName;
    NSString *RouteName;
    if (Fix) {
        RouteName = [delegate Route];
        favoriteData = [[NSMutableArray alloc] initWithObjects: RouteName , [[delegate m_waitTime] objectAtIndex:Tag],nil];
        fixedStringStopName = [self fixedStringBrackets: [[delegate m_RouteResult] objectAtIndex:Tag]];
    }
    else if ([delegate isKindOfClass:[FavoriteViewController class]]){
        NSArray* temp = [[delegate favoriteDic] objectForKey: [[[delegate favoriteDic] allKeys] objectAtIndex:section ]];
        RouteName = [temp objectAtIndex:Tag*2];
        favoriteData = [[NSMutableArray alloc] initWithObjects:RouteName, [temp objectAtIndex:Tag*2+1],nil];
        fixedStringStopName = [[[delegate favoriteDic] allKeys] objectAtIndex:section];
    }
    else{
        RouteName = [[delegate m_routes] objectAtIndex:Tag];
        favoriteData = [[NSMutableArray alloc] initWithObjects:RouteName, [[delegate m_waitTime] objectAtIndex:Tag],nil];
        fixedStringStopName = [delegate thisStop];
    }
    if (ButtonMode==1) {
        NSMutableDictionary *favoriteDictionary = [[prefs objectForKey:AlarmUserDefaultKey] mutableCopy];
        if (![prefs objectForKey:AlarmUserDefaultKey]) {
            favoriteDictionary = [ NSMutableDictionary new ];
        }
        NSMutableArray* temp = [[favoriteDictionary objectForKey:fixedStringStopName] mutableCopy];
        if ( temp ){
            if (![temp containsObject:RouteName]) {
                [temp addObjectsFromArray:favoriteData];
                [favoriteDictionary setObject:temp forKey:fixedStringStopName];
                [self addNotification:[[delegate m_waitTimeResult] objectAtIndex:Tag] RouteName:RouteName andStopName:fixedStringStopName];
            }
            else{
                NSInteger index = [temp indexOfObject:RouteName];
                [temp removeObjectAtIndex:index];
                [temp removeObjectAtIndex:index];
                [favoriteDictionary setObject:temp forKey:fixedStringStopName];
                [self removeNotificationRouteName:RouteName andStopName:fixedStringStopName];
            }
        }
        else{
            [favoriteDictionary setObject:favoriteData forKey:fixedStringStopName];
            [self addNotification:[[delegate m_waitTimeResult] objectAtIndex:Tag] RouteName:RouteName andStopName:fixedStringStopName];
        }
        [prefs setObject:favoriteDictionary forKey:AlarmUserDefaultKey];
        
    }
    else if (ButtonMode==2) {
        NSMutableDictionary *favoriteDictionary = [[prefs objectForKey:FavoriteUserDefaultKey] mutableCopy];
        if (![prefs objectForKey:FavoriteUserDefaultKey]) {
            favoriteDictionary = [ NSMutableDictionary new ];
        }
        NSMutableArray* temp = [[favoriteDictionary objectForKey:fixedStringStopName] mutableCopy];
        if ( temp ){
            if (![temp containsObject:RouteName]) {
                [temp addObjectsFromArray:favoriteData];
                [favoriteDictionary setObject:temp forKey:fixedStringStopName];
            }
        }
        else{
            [favoriteDictionary setObject:favoriteData forKey:fixedStringStopName];
        }
        [prefs setObject:favoriteDictionary forKey:FavoriteUserDefaultKey];
    }
    [prefs synchronize];
    [[delegate navigationController].view addSubview:success];
    success.alpha = 1.0f;
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:1.0f];
    success.alpha = 0.0f;
    [UIView commitAnimations];
    if (ButtonMode==1)
        [self isStopAdded:RouteName andStop:fixedStringStopName];
    else if (ButtonMode==2)
        [sender removeFromSuperview];
    [[delegate tableView] reloadData];
}


-(void) isStopAdded : (NSString*) input andStop: (NSString*)thisStop
{
    if (ButtonMode==0) {
        return;
    }
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *dic;
    if (ButtonMode==1) {
        dic = [[prefs objectForKey:AlarmUserDefaultKey] mutableCopy];
    }
    else if(ButtonMode==2){
        dic = [[prefs objectForKey:FavoriteUserDefaultKey] mutableCopy];
    }
    NSMutableArray* temp;
    if (Fix) {
        temp = [[dic objectForKey:[self fixedStringBrackets:thisStop]] mutableCopy];
    } else {
        temp = [[dic objectForKey:thisStop] mutableCopy];
    }
    if (ButtonMode==1) {
        if (temp &&[temp containsObject:input]) {
            [button setImage:[UIImage imageNamed:@"cancel.png"] forState:UIControlStateNormal];
            button.backgroundColor = [UIColor clearColor];
        }
    }
    else if(ButtonMode==2){
        if ( temp &&[temp containsObject:input])
            [button removeFromSuperview];
    }
}

-(UIButton *)CreateButton:(NSIndexPath *)indexPath{
    if (ButtonMode==0) {
        button = nil;
    }
    else if (ButtonMode==1){
        button = [UIButton buttonWithType:0];
        button.tag = indexPath.row+1+indexPath.section*1000;
        button.frame  = CGRectMake(275, 5, 30, 30);
        UIImage* star = [UIImage imageNamed:@"Alert.png"];
        [button setImage:star forState:UIControlStateNormal];
        button.backgroundColor =  [UIColor colorWithRed:255.0/255 green:228.0/255 blue:225.0/255 alpha:1.0];
        [button addTarget:self action:@selector(SaveUserDefault:) forControlEvents:UIControlEventTouchUpInside];
    }
    else if (ButtonMode==2) {
        button = [UIButton buttonWithType:0];
        button.tag = indexPath.row+1+indexPath.section*1000;
        button.frame  = CGRectMake(275, 5, 30, 30);
        UIImage* star = [UIImage imageNamed:@"star-button.png"];
        [button setImage:star forState:UIControlStateNormal];
        
        [button addTarget:self action:@selector(SaveUserDefault:) forControlEvents:UIControlEventTouchUpInside];
        button.backgroundColor =  [UIColor yellowColor];
    }
    return button;
}

- (IBAction)buttonPress:(UIBarButtonItem *)sender
{
    if ([sender.title isEqualToString:ButtonText1]) {
        ButtonMode=1;
    }
    else if ([sender.title isEqualToString:ButtonText2]){
        ButtonMode=2;
    }
    [[delegate tableView] reloadData];
}


- (IBAction)buttonPressHome:(UIBarButtonItem *)sender
{
    [[delegate navigationController] popToRootViewControllerAnimated:YES];
    
}

- (IBAction)buttonPressFavorite:(UIBarButtonItem *)sender{
    AlertViewDelegate *alert = [[AlertViewDelegate alloc]init];
    [alert AlertViewStart];
    FavoriteViewController *favorite = [[FavoriteViewController alloc] initWithStyle:UITableViewStylePlain];
    favorite.title = @"常用路線";
    [[delegate navigationController] pushViewController:favorite animated:YES];
    [favorite release];
    [alert AlertViewEnd];
}

-(UIToolbar *)CreatTabBarWithNoFavorite:(BOOL) favorite delegate:(id)dele{
    delegate = dele;
    if ([delegate isKindOfClass:[DepatureViewController class]]) {
        Fix = YES;
    }
    UIBarButtonItem* barItem1 = [[UIBarButtonItem alloc] initWithTitle:ButtonText1 style:UIBarButtonItemStyleBordered target:self action:@selector(buttonPress:)];
    UIBarButtonItem* barItem3 = [[UIBarButtonItem alloc] initWithTitle:ButtonText3 style:UIBarButtonItemStyleBordered target:self action:@selector(buttonPressHome:)];
    UIBarButtonItem* barItem4 = [[UIBarButtonItem alloc] initWithTitle:ButtonText4 style:UIBarButtonItemStyleBordered target:self action:@selector(buttonPressFavorite:)];
    if (favorite) {
        [toolbarcontroller setItems:[NSArray arrayWithObjects:barItem1, nil]];
    }
    else{
        UIBarButtonItem* barItem2 = [[UIBarButtonItem alloc] initWithTitle:ButtonText2 style:UIBarButtonItemStyleBordered target:self action:@selector(buttonPress:)];
        [toolbarcontroller setItems:[NSArray arrayWithObjects:barItem1,barItem2,barItem3,barItem4, nil]];
    }
    [toolbarcontroller addSubview:[delegate view]];
    return toolbarcontroller;
}

-(void)dealloc{
    [toolbarcontroller release];
    [super dealloc];
}

@end
