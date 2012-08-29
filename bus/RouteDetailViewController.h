//
//  RouteDetailViewController.h
//  bus
//
//  Created by mac_hero on 12/5/18.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <libxml/HTMLparser.h>
#import "TFHpple.h"
#import "DepatureViewController.h"

@interface RouteDetailViewController : UITableViewController<UIApplicationDelegate>
{
         NSArray *item;
         NSURL* url;
}

- (void) getURL:(NSString* ) inputURL; 
@property (nonatomic, retain) NSArray* item;
@property (nonatomic, retain) NSURL* url;

@end
