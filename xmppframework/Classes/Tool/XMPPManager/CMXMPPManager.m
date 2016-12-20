//
//  CMXMPPManager.m
//  xmppframework
//
//  Created by 23 on 2016/12/12.
//  Copyright © 2016年 23. All rights reserved.
//

#import "CMXMPPManager.h"






@interface CMXMPPManager() <XMPPStreamDelegate,XMPPRosterDelegate>
/**用户名*/
@property(nonatomic,copy) NSString *xmppUser;
/**密码*/
@property(nonatomic,copy) NSString *xmppPwd;
/**保存操作*/
@property(nonatomic,copy) XMPPConnectHandlerBlock connectHandler; //连接登录xmpp的回调block


/**xmpp管道*/
@property(nonatomic,strong) XMPPStream *xmppStream;
/**好友列表类*/
@property(nonatomic,strong) XMPPRoster *xmppRoster;
/**自动重连类*/
@property(nonatomic,strong) XMPPReconnect *xmppReconnect;
/**消息类*/
@property(nonatomic,strong) XMPPMessage *xmppMessage;


@end


@implementation CMXMPPManager
/**实例*/
CMXMPPManager *_instance;

#pragma mark - 设置单例
+(instancetype)shareManager
{
    if (_instance == nil) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            _instance = [[CMXMPPManager alloc]init];
        });
    }
    return _instance;
}

+(instancetype)allocWithZone:(struct _NSZone *)zone
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
         _instance = [super allocWithZone:zone];
    });
    return _instance;
}

-(instancetype)copyWithZone:(NSZone *)zone
{
    //由于是对象方法，说明可能存在_instance对象，直接返回即可
    return _instance;
}

#pragma mark - 懒加载
-(XMPPStream *)xmppStream
{
    if (_xmppStream == nil) {
        //实例化
        _xmppStream = [[XMPPStream alloc]init];
        //添加代理
        [_xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
        //设置参数
        _xmppStream.hostName = xmpp_host; //主机名称
        _xmppStream.hostPort = xmpp_port; //端口号
    }
    return _xmppStream;
}




#pragma mark - private
/**配置XMPP模块*/
-(void)configXMPPModule
{
    /**1 激活好友列表模块*/
    //初始化XMPPCoreData
    XMPPRosterCoreDataStorage *rosterCoreDataStorage = [XMPPRosterCoreDataStorage sharedInstance];
    //初始化xmppRoster
    self.xmppRoster = [[XMPPRoster alloc]initWithRosterStorage:rosterCoreDataStorage dispatchQueue:dispatch_get_main_queue()];
    self.xmppRoster.autoFetchRoster = YES; //自动获取好友列表
    self.xmppRoster.autoAcceptKnownPresenceSubscriptionRequests = NO; //需要确认才能添加好友
    self.xmppRoster.autoClearAllUsersAndResources  = NO;
    //激活好友
    [self.xmppRoster activate:self.xmppStream];
    //设置代理
    [self.xmppRoster addDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    
    /**2 激活自动重连模块*/
    self.xmppReconnect = [[XMPPReconnect alloc]initWithDispatchQueue:dispatch_get_main_queue()];
    self.xmppReconnect.autoReconnect = YES; //自动重连
    self.xmppReconnect.reconnectTimerInterval = 30; //自动重连时间
    [self.xmppReconnect activate:self.xmppStream];
    [self.xmppReconnect addDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    
    /**3 激活AutoPing模块*/
    XMPPAutoPing *autoPing = [[XMPPAutoPing alloc]init];
    autoPing.respondsToQueries = YES; //自动相应服务器的请求
    //autoPing.pingTimeout = 20;
    //autoPing.pingInterval = 10;
    [autoPing activate:self.xmppStream];
    [autoPing addDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    
}

/**初始化方法*/
- (instancetype)init
{
    if (self = [super init]) {
        [self configXMPPModule];
    }
    return self;
}

/**上线*/
- (void)goOnline
{
    XMPPPresence *presence = [XMPPPresence presence]; //默认是上线的
    [self.xmppStream sendElement:presence];
    
}

/**下线*/
- (void)goOffline
{
    XMPPPresence *presence = [XMPPPresence presenceWithType:@"unavailable"];
    [self.xmppStream sendElement:presence];
}


#pragma mark - 工具方法
/**连接xmpp服务器*/
- (void)connectToXMPPServerWithUsername:(NSString *)username password:(NSString *)password handler:(XMPPConnectHandlerBlock)hander
{
    //如果有连接，中断
    if (self.xmppStream.isConnected || self.xmppStream.isConnecting) {
        [self.xmppStream disconnect];
    }
    
    //保存
    self.xmppUser = username;
    self.xmppPwd = password;
    self.connectHandler = hander;
    
    //设置Jid
    XMPPJID *jid = [XMPPJID jidWithUser:self.xmppUser domain:xmpp_domain resource:xmpp_resource];
    self.xmppStream.myJID = jid;
    
    //连接
    NSError *error = nil;
    [self.xmppStream connectWithTimeout:xmpp_conect_timeout error:&error];
    if(error)
    {
        NSLog(@"================》XMPP连接初始化失败《================");
        NSLog(@"error = %@",error);
        NSLog(@"================》XMPP连接初始化失败《================");
    }
}


/**添加好友*/
- (void)addBuddyWithName:(NSString *)name
{
    XMPPJID *jid = [XMPPJID jidWithUser:name domain:xmpp_domain resource:xmpp_resource];
    //[self.xmppRoster subscribePresenceToUser:jid];
    [self.xmppRoster addUser:jid withNickname:@"haha"];
}

/**删除好友*/
- (void)deleteBuddyWithName:(NSString *)name
{
    XMPPJID *jid = [XMPPJID jidWithUser:name domain:xmpp_domain resource:xmpp_resource];
    [self deleteBuddyWithJID:jid];
}
- (void)deleteBuddyWithJID:(XMPPJID *)jid
{
    [self.xmppRoster removeUser:jid];
}


/**发文本消息*/
- (void)sendTextMessageTo:(XMPPJID *)jid message:(NSString *)text
{
    XMPPMessage *message = [XMPPMessage messageWithType:@"chat" to:jid];
    [message addAttributeWithName:xmpp_message_type intValue:CMChatMessageTypeText];
    [message addBody:text];
    [self.xmppStream sendElement:message];
}



#pragma mark - XMPPStreamDelegate
/**连接超时*/
- (void)xmppStreamConnectDidTimeout:(XMPPStream *)sender
{
    NSError *error = [NSError errorWithDomain:@"XMPP_CONNECT" code:1 userInfo:@{xmpp_error_info:@"连接超时"}];
    if (self.connectHandler) {
        self.connectHandler(NO,error);
    }
}

/**连接成功*/
- (void)xmppStreamDidConnect:(XMPPStream *)sender
{
    NSLog(@"================》XMPP连接成功《================");
    NSLog(@"================》XMPP开始认证《================");
    NSError *error = nil;
    [self.xmppStream authenticateWithPassword:self.xmppPwd error:&error];
    if (error) {
        NSLog(@"================》XMPP认证初始化失败《================");
        NSLog(@"error = %@",error);
        NSLog(@"================》XMPP认证初始化失败《================");
    }
}

/**认证失败*/
- (void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(DDXMLElement *)error
{
    NSError *err = [NSError errorWithDomain:@"XMPP_AUTH" code:2 userInfo:@{xmpp_error_info:@"认证失败"}];
    if (self.connectHandler) {
        self.connectHandler(NO,err);
    }
}

/**认证成功*/
- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender
{
    if (self.connectHandler) {
        self.connectHandler(YES,nil);
    }
    
    //上线
    [self goOnline];
}

/**接收到IQ*/
- (BOOL)xmppStream:(XMPPStream *)sender didReceiveIQ:(XMPPIQ *)iq
{
    /**  
     服务器发过来的心跳包
     <iq xmlns="jabber:client" type="get" id="720-188" from="127.0.0.1" to="a@127.0.0.1/usr/local/openfire">
        <ping xmlns="urn:xmpp:ping"/>
     </iq>
     */
    
    //1 回应服务器的心跳包
    if ([iq.childElement.name isEqualToString:@"ping"]) {
        //回复心跳包
        NSXMLElement *q = [[DDXMLElement alloc] initWithName:@"iq"];
        [q addAttributeWithName:@"from" stringValue:self.xmppStream.myJID.full];
        [q addAttributeWithName:@"to" stringValue:[[iq attributeForName:@"from"] stringValue]];
        [q addAttributeWithName:@"id" stringValue:[[iq attributeForName:@"id"] stringValue]];
        [q addAttributeWithName:@"type" stringValue:@"get"];
        //[self.xmppStream sendElement:q];
    }
    NSLog(@"%@",iq);
    return YES;
}

/**发送消息*/
- (void)xmppStream:(XMPPStream *)sender didSendMessage:(XMPPMessage *)message
{
    //存数据库
    NSLog(@"%%%%%%%%%%%%%message = %@",message);
}

/**接收消息*/
- (void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message
{
    //存数据库
    
    //接收到信息
    [[NSNotificationCenter defaultCenter] postNotificationName:XMPPReceiveMessageNotification object:message userInfo:nil];
}



#pragma mark - XMPPRosterDelegate
/**接收到添加好友请求*/
- (void)xmppRoster:(XMPPRoster *)sender didReceivePresenceSubscriptionRequest:(XMPPPresence *)presence
{
    //接收到好友请求 -- 发出通知
    [[NSNotificationCenter defaultCenter] postNotificationName:XMPPReceiveSubscribeRequestNotification object:presence userInfo:nil];
}




#pragma mark - XMPPReconnectDelegate
#if MAC_OS_X_VERSION_MIN_REQUIRED <= MAC_OS_X_VERSION_10_5

- (void)xmppReconnect:(XMPPReconnect *)sender didDetectAccidentalDisconnect:(SCNetworkConnectionFlags)connectionFlags
{
    NSLog(@"didDetectAccidentalDisconnect --- %d",connectionFlags);
}
- (BOOL)xmppReconnect:(XMPPReconnect *)sender shouldAttemptAutoReconnect:(SCNetworkConnectionFlags)connectionFlags
{
    NSLog(@"shouldAttemptAutoReconnect --- %d",connectionFlags);
    return YES;
}

#else

- (void)xmppReconnect:(XMPPReconnect *)sender didDetectAccidentalDisconnect:(SCNetworkReachabilityFlags)connectionFlags
{
    NSLog(@"didDetectAccidentalDisconnect -- %d",connectionFlags);
}
- (BOOL)xmppReconnect:(XMPPReconnect *)sender shouldAttemptAutoReconnect:(SCNetworkReachabilityFlags)reachabilityFlags
{
    NSLog(@"shouldAttemptAutoReconnect --- %d",reachabilityFlags);
    return YES;
}

#endif


#pragma mark - XMPPAutoPingDelegate
- (void)xmppAutoPingDidSendPing:(XMPPAutoPing *)sender
{
    NSLog(@"xmppAutoPingDidSendPing");
}
- (void)xmppAutoPingDidReceivePong:(XMPPAutoPing *)sender
{
    NSLog(@"xmppAutoPingDidReceivePong");
}
- (void)xmppAutoPingDidTimeout:(XMPPAutoPing *)sender
{
    NSLog(@"xmppAutoPingDidTimeout");
}

@end
