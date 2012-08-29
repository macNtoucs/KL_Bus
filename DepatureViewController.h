//
//  DepatureViewController.h
//  bus
//
//  Created by mac_hero on 12/5/25.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <libxml/HTMLparser.h>
#import "TFHpple.h"
#import "EGORefreshTableHeaderView.h"
#import "ToolBarController.h"
@interface DepatureViewController : UITableViewController<EGORefreshTableHeaderDelegate>
{
    NSArray *item;
    NSURL* url;
    NSString* Route;
    EGORefreshTableHeaderView *_refreshHeaderView; 
    BOOL _reloading;
    UIBarButtonItem *anotherButton;
    NSTimer * refreshTimer;
    NSDate * lastRefresh;
    NSMutableArray *m_waitTime;
    NSMutableArray *m_waitTimeResult;
    NSMutableArray *m_RouteResult;
    UIImageView *success;
    ToolBarController* toolbar;
}

- (void) getURL:(NSString* ) inputURL andRoute:(NSString *) route; 
- (void)reloadTableViewDataSource; 
- (void)doneLoadingTableViewData; 
@property (nonatomic, retain) NSArray* item;
@property (nonatomic, retain) NSURL* url;
@property (nonatomic, retain) NSString* Route;
@property (nonatomic, retain) UIBarButtonItem *anotherButton;
@property (nonatomic, retain) NSTimer *refreshTimer;
@property (nonatomic, retain) NSDate *lastRefresh;
@property (nonatomic ,retain)  NSMutableArray *m_waitTime;
@property (nonatomic ,retain)  NSMutableArray *m_waitTimeResult;
@property (nonatomic,retain) NSMutableArray *m_RouteResult;
@property (nonatomic ,retain) UIImageView *success;
@property (nonatomic ,retain) ToolBarController* toolbar;
@end
