//
//  RootViewController.h
//  bus
//
//  Created by mac_hero on 12/5/18.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <MessageUI/MessageUI.h>
#import "CellTextField.h"
#import "SearchTableViewController.h"
#import "FavoriteViewController.h"
#import "AboutMeTableViewController.h"
#import "GpsTableViewController.h"
#import "AlertViewDelegate.h"
@class SearchTableViewController;
@interface RootViewController : UITableViewController<EditableTableViewCellDelegate,MFMailComposeViewControllerDelegate,CLLocationManagerDelegate>
{
    UITextField *_editWindow;
    CellTextField *_editCell;
    SearchTableViewController *instant_search;
    CLLocation *				lastLocation;
    CLLocationManager *			locationManager;
    bool isLocateFinished;
}

@property (nonatomic, retain) CellTextField *editCell;
@property (nonatomic, retain) UITextField *editWindow;

@end

