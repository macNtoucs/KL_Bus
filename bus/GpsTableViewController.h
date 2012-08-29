//
//  GpsTableViewController.h
//  bus
//
//  Created by mac_hero on 12/7/19.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ScreenConstants.h"
#import "MapViewController.h"
#import <CoreLocation/CoreLocation.h>
@interface GpsTableViewController : UITableViewController <CLLocationManagerDelegate,MKReverseGeocoderDelegate>{
    int sections;
    int dist;
    int show;
    double						accuracy;
    double minDistance;
    int maxToFind;
    BOOL						waitingForLocation;
    UIActivityIndicatorView *	_progressInd;
    UITableViewCell *			_progressCell;
    CLLocation *				_lastLocation;
    CLLocationManager *			_locationManager;
    NSDate *					_timeStamp;
}

@property (nonatomic, retain) UIActivityIndicatorView *progressInd;
@property (nonatomic, retain) UITableViewCell *progressCell;
@property (nonatomic, retain) CLLocation *lastLocation;
@property (nonatomic, retain) CLLocationManager *locationManager;
@property (nonatomic, retain) NSDate *timeStamp;


@end
