//
//  CMChatMessageCell.h
//  xmppframework
//
//  Created by 23 on 2016/12/21.
//  Copyright © 2016年 23. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CMChatMessage;

@interface CMChatMessageCell : UITableViewCell
/**聊天信息*/
@property(nonatomic,strong) CMChatMessage *message;

@end
