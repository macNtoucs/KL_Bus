//
//  MapViewController.h
//  bus
//
//  Created by mac_hero on 12/8/6.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "Annotation.h"


@interface MapViewController : UIViewController{
    MKMapView *mapView;
    MKCoordinateSpan span;
    CLLocationCoordinate2D location;
    NSMutableArray *nearStop;
    CLLocationCoordinate2D nearStopLoction[30];
    NSString *BusTitle[30];
}
@property (retain,nonatomic) NSMutableArray *nearStop;
-(void) setlocation:(CLLocationCoordinate2D) inputloaction latitudeDelta:(double)latitude longitudeDelta:(double)longitude;
@end
