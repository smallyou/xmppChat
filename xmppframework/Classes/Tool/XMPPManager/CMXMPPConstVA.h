//
//  CMXMPPConstVA.h
//  xmppframework
//
//  Created by 23 on 2016/12/12.
//  Copyright © 2016年 23. All rights reserved.
//

/**
 常量文件
 */

#import <UIKit/UIKit.h>

#pragma mark - XMPPStream相关
/**主机名*/
UIKIT_EXTERN NSString * const xmpp_host;
/**端口号*/
UIKIT_EXTERN NSUInteger const xmpp_port;
/**域名*/
UIKIT_EXTERN NSString * const xmpp_domain;
/**资源*/
UIKIT_EXTERN NSString * const xmpp_resource;
/**连接超时时间*/
UIKIT_EXTERN NSTimeInterval const xmpp_conect_timeout;
/**消息类型*/
UIKIT_EXTERN NSString * const xmpp_message_type;

#pragma mark - 错误相关
/**错误描述*/
UIKIT_EXTERN NSString * const xmpp_error_info;


#pragma mark - 通知相关
/**接收到好友请求通知*/
UIKIT_EXTERN NSString * const XMPPReceiveSubscribeRequestNotification;
/**接收到消息的通知*/
UIKIT_EXTERN NSString * const XMPPReceiveMessageNotification;
