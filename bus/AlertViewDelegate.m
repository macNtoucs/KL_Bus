//
//  AlertViewDelegate.m
//  bus
//
//  Created by mac_hero on 12/8/10.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "AlertViewDelegate.h"

@implementation AlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
}

-(void)AlertViewStart{
    loadingAlertView = [[UIAlertView alloc] 
                                     initWithTitle:nil message:@"\n\nDownloading\nPlease wait"
                                     delegate:nil cancelButtonTitle:nil
                                     otherButtonTitles: nil];
    CGRect frame = CGRectMake(120, 10, 40, 40);
    UIActivityIndicatorView* progressInd = [[UIActivityIndicatorView alloc] initWithFrame:frame];
    progressInd.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
    [progressInd startAnimating];
    [loadingAlertView addSubview:progressInd];
    [loadingAlertView show];
    [progressInd release];
}

-(void)AlertViewEnd{
    [loadingAlertView dismissWithClickedButtonIndex:0 animated:NO];
    [loadingAlertView release];
}

@end
