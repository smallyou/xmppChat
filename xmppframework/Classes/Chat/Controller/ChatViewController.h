//
//  ChatViewController.h
//  xmppframework
//
//  Created by 23 on 2016/12/19.
//  Copyright © 2016年 23. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CMXMPPBuddy;

@interface ChatViewController : UIViewController
@property(nonatomic,strong) CMXMPPBuddy *buddy;
@end
