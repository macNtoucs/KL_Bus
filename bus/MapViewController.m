//
//  MapViewController.m
//  bus
//
//  Created by mac_hero on 12/8/6.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "MapViewController.h"

@interface MapViewController ()

@end

@implementation MapViewController
@synthesize nearStop;
-(void) setlocation:(CLLocationCoordinate2D) inputloaction latitudeDelta:(double)latitude longitudeDelta:(double)longitude{
    location = inputloaction;
    span.latitudeDelta  = latitude;
    span.longitudeDelta = longitude;
}

- (void)mapView:(MKMapView *)theMapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    [theMapView setCenterCoordinate:userLocation.location.coordinate animated:YES];
}

-(void)addBusAnnotationNearLatitude :(double)latitude andLongtitude:(double)longtitude{
    
    NSError *error = nil;
      NSRange  search_result_range;
    NSString *query = [NSString stringWithFormat: @"https://maps.google.com.tw/maps?near=%f,%f&geocode=&q=公車站&f=li&hl=zh-TW&jsv=428a&ll=%f,%f&output=js",latitude, longtitude,latitude, longtitude];
    NSString *mapUrl=[query stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    UInt32 big5 = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingBig5);
    NSString* mapHTML = [NSString stringWithContentsOfURL:[NSURL URLWithString:mapUrl] encoding:big5 error:&error] ;    
    NSString* locationSearchKey = @"x26ll";
    NSMutableString *searchHTML = [NSMutableString stringWithString:mapHTML];
    do{
        search_result_range = [searchHTML rangeOfString:locationSearchKey ];
        int searchResultLocation = search_result_range.location;
        if (searchResultLocation+26>[mapHTML length]) break;
        NSString *result = [searchHTML substringWithRange:NSMakeRange(searchResultLocation+6, 20)];   
        [nearStop addObject:result];
        searchHTML = [searchHTML substringFromIndex:searchResultLocation+26];
    }while(true);
    int nearStopNumber =0;
    for (NSString * locInfo in nearStop)
    {
        NSArray *loc = [locInfo componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@","]];
        double latitude = [ [loc objectAtIndex:0] doubleValue];
        double lontitude = [ [loc objectAtIndex:1] doubleValue];
         NSLog(@"%f  %f",latitude,lontitude);
        nearStopLoction[nearStopNumber].latitude=latitude;
        nearStopLoction[nearStopNumber].longitude=lontitude;
        ++nearStopNumber;
        
    }
    
    for (int j = 0 ; j <nearStopNumber; j++)
    {
        [mapView addAnnotation:[[Annotation alloc] initWhithTitle:nil
                                                         subTitle:nil 
                                                  andCoordiante:nearStopLoction[j]]];
    }

}



-(void)loadView
{
    [super loadView];
    
    nearStop = [NSMutableArray new];
    MKUserLocation *userlocation = [[MKUserLocation alloc]init];
    [userlocation setCoordinate:location];
    
    mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, 0, 320, 460)];
    MKCoordinateRegion region;
    region.center.latitude = location.latitude;
    region.center.longitude = location.longitude;
    //region.center.latitude = 25.150517;
    //region.center.longitude = 121.779973;
    region.span = span;
    [mapView setRegion:region animated:YES];
    [self mapView:mapView didUpdateUserLocation:userlocation];
    [self addBusAnnotationNearLatitude :region.center.latitude andLongtitude:region.center.longitude];
   // mapView.showsUserLocation = YES;
    [self.view addSubview:mapView];
    [mapView release];

}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}


- (void)dealloc
{
    [mapView release];
    [super dealloc];
}


@end
