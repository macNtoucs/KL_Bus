//
//  AboutMeTableViewController.h
//  bus
//
//  Created by mac_hero on 12/7/19.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "ScreenConstants.h"
@interface AboutMeTableViewController : UITableViewController<MFMailComposeViewControllerDelegate>{
    UIFont *_paragraphFont;
    NSString *aboutText;
}


@end
