//
//  CMXMPPManager.h
//  xmppframework
//
//  Created by 23 on 2016/12/12.
//  Copyright © 2016年 23. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XMPPFramework.h" //导入框架
#import "CMXMPPConstVA.h"
#import "XMPPModule.h"
#import "XMPPElement.h"
#import "XMPPAutoPing.h"
#import "CMXMPPBuddy.h"
#import "XMPPJID.h"
@class CMXMPPBuddy;

typedef NS_ENUM(NSInteger,CMChatMessageType) {
    CMChatMessageTypeText = 0,      //文本消息
    CMChatMessageTypeImage = 1,     //图片消息
    CMChatMessageTypeVoice = 2,     //语音消息
    CMChatMessageTypeVideo = 3      //视频消息
};

/**连接错误handle*/
typedef void(^XMPPConnectHandlerBlock)(BOOL success , NSError *error);



@interface CMXMPPManager : NSObject
/**单例对象*/
+(instancetype)shareManager;
/**好友列表类*/
@property(nonatomic,strong,readonly) XMPPRoster *xmppRoster;
/**xmpp管道*/
@property(nonatomic,strong,readonly) XMPPStream *xmppStream;




/**连接xmpp服务器*/
- (void)connectToXMPPServerWithUsername:(NSString *)username password:(NSString *)password handler:(XMPPConnectHandlerBlock)hander;

/**添加好友*/
- (void)addBuddyWithName:(NSString *)name;
/**删除好友*/
- (void)deleteBuddyWithName:(NSString *)name;
- (void)deleteBuddyWithJID:(XMPPJID *)jid;

/**发文本消息*/
- (void)sendTextMessageTo:(XMPPJID *)jid message:(NSString *)text;
@end
