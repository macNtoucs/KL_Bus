//
//  ToolBarController.h
//  bus
//
//  Created by mac_hero on 12/8/21.
//
//

#import <Foundation/Foundation.h>

@interface ToolBarController : NSObject{
    UIToolbar* toolbarcontroller;
    UIButton *button;
    int ButtonMode;
    id delegate;
    bool Fix;
    UIImageView *success;
}

-(UIToolbar *)CreatTabBarWithNoFavorite:(BOOL) favorite delegate:(id)dele;
-(UIButton *)CreateButton:(NSIndexPath *)indexPath;
-(void) isStopAdded : (NSString*) input andStop: (NSString*)thisStop;

@property (nonatomic, retain) UIToolbar* toolbarcontroller;
@property (nonatomic, retain) UIButton *button;
@property (nonatomic, retain)UIImageView *success;

@end
