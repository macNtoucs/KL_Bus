//
//  AlertViewDelegate.h
//  bus
//
//  Created by mac_hero on 12/8/10.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//


@interface AlertViewDelegate : NSObject{
    UIAlertView *loadingAlertView;
}
-(void)AlertViewStart;
-(void)AlertViewEnd;
@end
