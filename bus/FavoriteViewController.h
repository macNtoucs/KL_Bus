//
//  FavoriteViewController.h
//  bus
//
//  Created by mac_hero on 12/7/12.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <libxml/HTMLparser.h>
#import "TFHpple.h"
#import "EGORefreshTableHeaderView.h"

@interface FavoriteViewController : UITableViewController<EGORefreshTableHeaderDelegate>{

    NSMutableDictionary* favoriteDic ;
    NSMutableArray* m_waitTimeResult;
    NSMutableArray *m_routesResult;
    BOOL newSection ;
    EGORefreshTableHeaderView *_refreshHeaderView; 
    BOOL _reloading;
    NSDate * lastRefresh;
    
}

@property (nonatomic, retain)  NSMutableDictionary* favoriteDic ;
@property (nonatomic, retain)  NSMutableArray* m_waitTimeResult ;
@property (nonatomic, retain) NSMutableArray* m_routesResult;
@property (nonatomic, retain) NSDate *lastRefresh;
@end
