//
//  Annotation.h
//  bus
//
//  Created by mac_hero on 12/8/6.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface Annotation : NSObject <MKAnnotation> {
    NSString *_title;
    NSString *_subTitle;
    CLLocationCoordinate2D _coordiante2D;
}

@property (nonatomic , copy) NSString *title;
@property (nonatomic , copy) NSString *subtitle;
@property (nonatomic , readonly) CLLocationCoordinate2D coordinate;

-(id) initWhithTitle:(NSString *) theTitle subTitle:(NSString *)theSubTitle andCoordiante:(CLLocationCoordinate2D) theCoordinate;

@end

