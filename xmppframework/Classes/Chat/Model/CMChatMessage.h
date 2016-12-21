//
//  CMMessageModel.h
//  xmppframework
//
//  Created by 23 on 2016/12/20.
//  Copyright © 2016年 23. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CMXMPPManager.h"



typedef NS_ENUM(NSInteger,CMChatMessageFromToType) {
    CMChatMessageFromToTypeYours = 0, //对方发的
    CMChatMessageFromToTypeMe = 1,    //本人发的
};


@interface CMChatMessage : NSObject

/**消息类型*/
@property(nonatomic,assign) CMChatMessageType messageType;

/**收发件人类型*/
@property(nonatomic,assign) CMChatMessageFromToType fromToType;

/**发件人*/
@property(nonatomic,strong) XMPPJID *from;
@property(nonatomic,copy) NSString  *fromStr;

/**收件人*/
@property(nonatomic,strong) XMPPJID *to;
@property(nonatomic,copy) NSString  *toStr;

/**消息内容*/
@property(nonatomic,copy) NSString *body;

/**消息时间*/
@property(nonatomic,copy) NSString *time;

@end
