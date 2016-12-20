//
//  CMXMPPBuddy.m
//  xmppframework
//
//  Created by 23 on 2016/12/13.
//  Copyright © 2016年 23. All rights reserved.
//

#import "CMXMPPBuddy.h"


@implementation CMXMPPBuddy
+(instancetype)xmppBuddyWithJid:(NSString *)jid name:(NSString *)name ask:(NSString *)ask subscription:(NSString *)subscription group:(NSString *)group
{
    CMXMPPBuddy *buddy = [[self alloc]init];
    buddy.JID = [XMPPJID jidWithString:jid];
    buddy.name = name;
    buddy.ask = ask;
    buddy.subscription = subscription;
    buddy.group = group;
    return buddy;
}
@end
