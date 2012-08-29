//
//  Annotation.m
//  bus
//
//  Created by mac_hero on 12/8/6.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "Annotation.h"

@implementation Annotation

@synthesize title=_title,subtitle=_subTitle,coordinate=_coordiante2D;

-(void)dealloc
{
    [_title release];
    [_subTitle release];
    [super dealloc];
}

-(id) initWhithTitle:(NSString *) theTitle subTitle:(NSString *)theSubTitle andCoordiante:(CLLocationCoordinate2D) theCoordinate
{
    self = [super init];
    if (self) {
        _title = [theTitle copy];
        _subTitle = [theSubTitle copy];
        _coordiante2D = theCoordinate;
    }
    return self;
}

@end