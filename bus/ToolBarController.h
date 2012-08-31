//
//  ToolBarController.h
//  bus
//
//  Created by mac_hero on 12/8/21.
//
//

#import <Foundation/Foundation.h>
#define ButtonText1 @"加入通知"
#define ButtonText2 @"加入常用"
#define ButtonText3 @"返回主頁"
#define ButtonText4 @"常用站牌"
#define AlarmUserDefaultKey @"alarm"
#define FavoriteUserDefaultKey @"user"
#define RouteNameKey @"Key1"
#define StopNameKey @"Key2"

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
