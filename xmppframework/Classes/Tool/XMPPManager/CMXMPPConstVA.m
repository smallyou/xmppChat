//
//  CMXMPPConstVA.m
//  xmppframework
//
//  Created by 23 on 2016/12/12.
//  Copyright © 2016年 23. All rights reserved.
//

#import "CMXMPPConstVA.h"

/**主机名*/
//NSString * const xmpp_host = @"192.168.0.251";
NSString * const xmpp_host = @"127.0.0.1";
/**端口号*/
NSUInteger  const xmpp_port = 5222;
/**域名*/
//NSString * const xmpp_domain = @"192.168.0.251";
NSString * const xmpp_domain = @"127.0.0.1";
/**资源*/
NSString * const xmpp_resource = @"usr/local/openfire";
/**连接超时时间*/
NSTimeInterval const xmpp_conect_timeout = 30.0f;
/**消息类型*/
NSString * const xmpp_message_type = @"xmpp_message_type";


/**错误描述*/
NSString * const xmpp_error_info = @"xmpp_error_info";


/**接收到好友请求通知*/
NSString * const XMPPReceiveSubscribeRequestNotification = @"XMPPReceiveSubscribeRequestNotification";
/**接收到消息的通知*/
NSString * const XMPPReceiveMessageNotification = @"XMPPReceiveMessageNotification";
