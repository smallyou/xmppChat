//
//  CMMessageModel.m
//  xmppframework
//
//  Created by 23 on 2016/12/20.
//  Copyright © 2016年 23. All rights reserved.
//

#import "CMChatMessage.h"

@implementation CMChatMessage


-(void)setTime:(NSDate *)time
{
    _time = time;
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    formatter.dateFormat  = @"yyyy年MM月dd日 HH:mm:ss";
    self.timeStr = [formatter stringFromDate:time];
}

@end
