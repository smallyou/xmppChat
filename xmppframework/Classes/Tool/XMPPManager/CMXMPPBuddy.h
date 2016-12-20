//
//  CMXMPPBuddy.h
//  xmppframework
//
//  Created by 23 on 2016/12/13.
//  Copyright © 2016年 23. All rights reserved.
//
/**
 <item jid="a1@127.0.0.1" name="a1" ask="subscribe" subscription="none">
 <group>Friends</group>
 </item>
 */

#import <Foundation/Foundation.h>
#import "CMXMPPManager.h"

@interface CMXMPPBuddy : NSObject
/**JID*/
@property(nonatomic,strong) XMPPJID *JID;
/**昵称*/
@property(nonatomic,copy) NSString *name;
/**ask*/
@property(nonatomic,copy) NSString *ask;
/**subscription*/
@property(nonatomic,copy) NSString *subscription;
/**group*/
@property(nonatomic,copy) NSString *group;

/**工厂方法*/
+(instancetype)xmppBuddyWithJid:(NSString *)jid name:(NSString *)name ask:(NSString *)ask subscription:(NSString *)subscription group:(NSString *)group;

@end
